import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import * as ExcelJS from 'exceljs';
import { QuestionEntity } from './entities/question.entity';
import { AnswerEntity } from './entities/answer.entity';
import { QuestionBankEntity } from './entities/question-bank.entity';
import { ImportBatchEntity } from './entities/import-batch.entity';
import { AiService } from '../ai/ai.service';
import { StorageService } from '../storage/storage.service';
import { CreateQuestionBankDto } from './dto/create-question-bank.dto';
import { CreateQuestionDto } from './dto/create-question.dto';
import { NumericAnswerValidator } from './validators/numeric-answer.validator';

@Injectable()
export class QuestionsService {
  constructor(
    @InjectRepository(QuestionEntity)
    private readonly questionRepo: Repository<QuestionEntity>,
    @InjectRepository(AnswerEntity)
    private readonly answerRepo: Repository<AnswerEntity>,
    @InjectRepository(QuestionBankEntity)
    private readonly bankRepo: Repository<QuestionBankEntity>,
    @InjectRepository(ImportBatchEntity)
    private readonly batchRepo: Repository<ImportBatchEntity>,
    private readonly aiService: AiService,
    private readonly storageService: StorageService,
  ) {}

  async createBank(userId: string, dto: CreateQuestionBankDto) {
    const bank = this.bankRepo.create({ ...dto, ownerId: userId });
    return this.bankRepo.save(bank);
  }

  async getBanks(userId: string, schoolId?: string) {
    return this.bankRepo.find({
      where: [
        { ownerId: userId },
        ...(schoolId ? [{ schoolId, isPublic: true }] : []),
      ],
      order: { createdAt: 'DESC' },
    });
  }

  async importFromExcel(
    bankId: string,
    userId: string,
    file: Express.Multer.File,
  ) {
    const bank = await this.bankRepo.findOne({ where: { id: bankId } });
    if (!bank) throw new NotFoundException('Không tìm thấy ngân hàng câu hỏi');

    const fileUrl = await this.storageService.uploadFile(file, 'excel-imports');

    const batch = await this.batchRepo.save(
      this.batchRepo.create({
        bankId,
        uploadedBy: userId,
        fileName: file.originalname,
        fileUrl,
        status: 'processing',
      }),
    );

    const result = await this.processExcelFile(file.buffer, bankId, batch.id);

    await this.batchRepo.update(batch.id, {
      status: result.errorRows > 0 && result.successRows === 0 ? 'failed' : 'completed',
      totalRows: result.totalRows,
      processedRows: result.totalRows,
      successRows: result.successRows,
      errorRows: result.errorRows,
      errors: result.errors,
      completedAt: new Date(),
    });

    // Trigger AI classification in background
    this.aiService.classifyQuestionsInBatch(batch.id).catch(console.error);

    return {
      batchId: batch.id,
      ...result,
    };
  }

  private async processExcelFile(
    buffer: Buffer,
    bankId: string,
    batchId: string,
  ) {
    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(buffer);

    let totalRows = 0;
    let successRows = 0;
    let errorRows = 0;
    const errors: Array<{ sheet: string; row: number; error: string }> = [];

    // Sheet 1: MULTIPLE_CHOICE
    const mcSheet = workbook.getWorksheet('MULTIPLE_CHOICE') || workbook.worksheets[0];
    if (mcSheet) {
      const result = await this.processMultipleChoice(mcSheet, bankId, batchId);
      totalRows += result.total;
      successRows += result.success;
      errorRows += result.errors.length;
      errors.push(...result.errors.map((e) => ({ sheet: 'MULTIPLE_CHOICE', ...e })));
    }

    // Sheet 2: TRUE_FALSE
    const tfSheet = workbook.getWorksheet('TRUE_FALSE');
    if (tfSheet) {
      const result = await this.processTrueFalse(tfSheet, bankId, batchId);
      totalRows += result.total;
      successRows += result.success;
      errorRows += result.errors.length;
      errors.push(...result.errors.map((e) => ({ sheet: 'TRUE_FALSE', ...e })));
    }

    // Sheet 3: NUMERIC
    const numSheet = workbook.getWorksheet('NUMERIC');
    if (numSheet) {
      const result = await this.processNumeric(numSheet, bankId, batchId);
      totalRows += result.total;
      successRows += result.success;
      errorRows += result.errors.length;
      errors.push(...result.errors.map((e) => ({ sheet: 'NUMERIC', ...e })));
    }

    return { totalRows, successRows, errorRows, errors };
  }

  private async processMultipleChoice(
    sheet: ExcelJS.Worksheet,
    bankId: string,
    batchId: string,
  ) {
    const questions: QuestionEntity[] = [];
    let total = 0;
    const errors: Array<{ row: number; error: string }> = [];

    sheet.eachRow((row, rowNumber) => {
      if (rowNumber === 1) return; // Skip header
      total++;
      try {
        const content = String(row.getCell(1).value || '').trim();
        const optA = String(row.getCell(2).value || '').trim();
        const optB = String(row.getCell(3).value || '').trim();
        const optC = String(row.getCell(4).value || '').trim();
        const optD = String(row.getCell(5).value || '').trim();
        const answer = String(row.getCell(6).value || '').trim().toUpperCase();

        if (!content) throw new Error('Câu hỏi không được để trống');
        if (!optA || !optB) throw new Error('Cần ít nhất 2 đáp án (A và B)');
        if (!['A', 'B', 'C', 'D'].includes(answer)) throw new Error(`Đáp án "${answer}" không hợp lệ, phải là A, B, C hoặc D`);

        const q = this.questionRepo.create({
          bankId,
          type: 'multiple_choice',
          content,
          importRow: rowNumber,
          importBatchId: batchId,
          answers: [
            { label: 'A', content: optA, isCorrect: answer === 'A', displayOrder: 0 },
            { label: 'B', content: optB, isCorrect: answer === 'B', displayOrder: 1 },
            ...(optC ? [{ label: 'C', content: optC, isCorrect: answer === 'C', displayOrder: 2 }] : []),
            ...(optD ? [{ label: 'D', content: optD, isCorrect: answer === 'D', displayOrder: 3 }] : []),
          ],
        });
        questions.push(q);
      } catch (e) {
        errors.push({ row: rowNumber, error: e.message });
      }
    });

    if (questions.length > 0) {
      await this.questionRepo.save(questions);
    }

    return { total, success: questions.length, errors };
  }

  private async processTrueFalse(
    sheet: ExcelJS.Worksheet,
    bankId: string,
    batchId: string,
  ) {
    const questions: QuestionEntity[] = [];
    let total = 0;
    const errors: Array<{ row: number; error: string }> = [];

    sheet.eachRow((row, rowNumber) => {
      if (rowNumber === 1) return;
      total++;
      try {
        const content = String(row.getCell(1).value || '').trim();
        const answerRaw = String(row.getCell(2).value || '').trim().toUpperCase();

        if (!content) throw new Error('Câu hỏi không được để trống');
        const validAnswers = ['TRUE', 'FALSE', 'ĐÚNG', 'SAI', 'T', 'F', '1', '0'];
        if (!validAnswers.includes(answerRaw)) {
          throw new Error(`Đáp án "${answerRaw}" không hợp lệ. Sử dụng TRUE/FALSE`);
        }

        const isTrue = ['TRUE', 'ĐÚNG', 'T', '1'].includes(answerRaw);

        const q = this.questionRepo.create({
          bankId,
          type: 'true_false',
          content,
          correctAnswer: isTrue ? 'true' : 'false',
          importRow: rowNumber,
          importBatchId: batchId,
        });
        questions.push(q);
      } catch (e) {
        errors.push({ row: rowNumber, error: e.message });
      }
    });

    if (questions.length > 0) {
      await this.questionRepo.save(questions);
    }

    return { total, success: questions.length, errors };
  }

  private async processNumeric(
    sheet: ExcelJS.Worksheet,
    bankId: string,
    batchId: string,
  ) {
    const questions: QuestionEntity[] = [];
    let total = 0;
    const errors: Array<{ row: number; error: string }> = [];

    sheet.eachRow((row, rowNumber) => {
      if (rowNumber === 1) return;
      total++;
      try {
        const content = String(row.getCell(1).value || '').trim();
        const answerRaw = String(row.getCell(2).value || '').trim();

        if (!content) throw new Error('Câu hỏi không được để trống');

        const numericValue = NumericAnswerValidator.parse(answerRaw);
        if (numericValue === null) {
          throw new Error(`Không thể đọc giá trị số từ "${answerRaw}"`);
        }

        const q = this.questionRepo.create({
          bankId,
          type: 'numeric',
          content,
          correctAnswer: String(numericValue),
          importRow: rowNumber,
          importBatchId: batchId,
        });
        questions.push(q);
      } catch (e) {
        errors.push({ row: rowNumber, error: e.message });
      }
    });

    if (questions.length > 0) {
      await this.questionRepo.save(questions);
    }

    return { total, success: questions.length, errors };
  }

  async checkAnswer(
    questionId: string,
    userAnswer: string,
  ): Promise<{ isCorrect: boolean; correctAnswer: string; explanation?: string }> {
    const question = await this.questionRepo.findOne({
      where: { id: questionId },
      relations: ['answers'],
    });
    if (!question) throw new NotFoundException('Không tìm thấy câu hỏi');

    let isCorrect = false;
    let correctAnswer = '';

    if (question.type === 'multiple_choice') {
      const correctAns = question.answers.find((a) => a.isCorrect);
      correctAnswer = correctAns?.label || '';
      isCorrect = userAnswer.toUpperCase() === correctAnswer.toUpperCase();
    } else if (question.type === 'true_false') {
      correctAnswer = question.correctAnswer;
      const normalized = ['true', 'đúng', 't', '1'].includes(userAnswer.toLowerCase())
        ? 'true'
        : 'false';
      isCorrect = normalized === question.correctAnswer;
    } else if (question.type === 'numeric') {
      correctAnswer = question.correctAnswer;
      const userNum = NumericAnswerValidator.parse(userAnswer);
      const correctNum = NumericAnswerValidator.parse(question.correctAnswer);
      if (userNum !== null && correctNum !== null) {
        isCorrect = Math.abs(userNum - correctNum) <= question.numericTolerance;
      }
      // Check accepted alternatives
      if (!isCorrect && question.acceptedAnswers?.length) {
        for (const alt of question.acceptedAnswers) {
          const altNum = NumericAnswerValidator.parse(String(alt));
          if (altNum !== null && userNum !== null && Math.abs(userNum - altNum) <= question.numericTolerance) {
            isCorrect = true;
            break;
          }
        }
      }
    }

    // Update stats
    await this.questionRepo.update(questionId, {
      totalAttempts: () => 'total_attempts + 1',
      ...(isCorrect ? { correctAttempts: () => 'correct_attempts + 1' } : {}),
    });

    return { isCorrect, correctAnswer, explanation: question.explanation };
  }

  async addQuestion(bankId: string, userId: string, dto: any) {
    const bank = await this.bankRepo.findOne({ where: { id: bankId } });
    if (!bank) throw new NotFoundException('Không tìm thấy ngân hàng câu hỏi');

    const question = this.questionRepo.create({
      ...dto,
      bankId,
    });
    const saved = await this.questionRepo.save(question);

    if (dto.answers?.length) {
      const answers = dto.answers.map((a: any) =>
        this.answerRepo.create({ ...a, questionId: saved.id }),
      );
      await this.answerRepo.save(answers);
    }

    return this.questionRepo.findOne({ where: { id: saved.id }, relations: ['answers'] });
  }

  async deleteQuestion(bankId: string, questionId: string) {
    const question = await this.questionRepo.findOne({ where: { id: questionId, bankId } });
    if (!question) throw new NotFoundException('Không tìm thấy câu hỏi');
    await this.questionRepo.remove(question);
    return { success: true };
  }

  async getQuestions(bankId: string, filters?: {
    type?: string;
    difficulty?: string;
    subject?: string;
    topic?: string;
    limit?: number;
    page?: number;
    offset?: number;
    random?: boolean;
  }) {
    const qb = this.questionRepo.createQueryBuilder('q')
      .leftJoinAndSelect('q.answers', 'a')
      .where('q.bank_id = :bankId', { bankId });

    if (filters?.type) qb.andWhere('q.type = :type', { type: filters.type });
    if (filters?.difficulty) qb.andWhere('q.difficulty = :difficulty', { difficulty: filters.difficulty });
    if (filters?.subject) qb.andWhere('q.subject = :subject', { subject: filters.subject });
    if (filters?.topic) qb.andWhere('q.topic = :topic', { topic: filters.topic });

    const total = await qb.getCount();

    if (filters?.random) {
      qb.orderBy('RANDOM()');
    } else {
      qb.orderBy('q.created_at', 'DESC');
    }

    if (filters?.limit) qb.take(filters.limit);
    if (filters?.offset) {
      qb.skip(filters.offset);
    } else if (filters?.page && filters?.limit) {
      qb.skip((filters.page - 1) * filters.limit);
    }

    const data = await qb.getMany();
    return { data, meta: { total, limit: filters?.limit, offset: filters?.offset } };
  }
}
