import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import OpenAI from 'openai';
import { QuestionEntity } from '../questions/entities/question.entity';
import { ImportBatchEntity } from '../questions/entities/import-batch.entity';
import { AiReportEntity } from './entities/ai-report.entity';
import { UserStatisticsEntity } from '../statistics/entities/user-statistics.entity';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private openai: OpenAI | null = null;
  private readonly hasApiKey: boolean;

  constructor(
    private readonly config: ConfigService,
    @InjectRepository(QuestionEntity)
    private readonly questionRepo: Repository<QuestionEntity>,
    @InjectRepository(ImportBatchEntity)
    private readonly batchRepo: Repository<ImportBatchEntity>,
    @InjectRepository(AiReportEntity)
    private readonly reportRepo: Repository<AiReportEntity>,
    @InjectRepository(UserStatisticsEntity)
    private readonly statsRepo: Repository<UserStatisticsEntity>,
  ) {
    const apiKey = config.get<string>('app.openai.apiKey');
    this.hasApiKey = Boolean(apiKey);
    if (this.hasApiKey) {
      this.openai = new OpenAI({ apiKey });
      this.logger.log('AI service: OpenAI enabled');
    } else {
      this.logger.warn('AI service: No OpenAI API key – using mock responses');
    }
  }

  async classifyQuestionsInBatch(batchId: string) {
    const questions = await this.questionRepo.find({
      where: { importBatchId: batchId },
    });

    this.logger.log(`AI classifying ${questions.length} questions in batch ${batchId}`);
    await this.batchRepo.update(batchId, { aiProcessingStatus: 'processing' });

    // Process in chunks of 10
    const chunkSize = 10;
    for (let i = 0; i < questions.length; i += chunkSize) {
      const chunk = questions.slice(i, i + chunkSize);
      await Promise.all(chunk.map((q) => this.classifyQuestion(q)));
    }

    await this.batchRepo.update(batchId, { aiProcessingStatus: 'completed' });
    this.logger.log(`AI classification complete for batch ${batchId}`);
  }

  async classifyQuestion(question: QuestionEntity) {
    try {
      const prompt = `Phân loại câu hỏi sau cho hệ thống học tập K-12 Việt Nam:

Câu hỏi: "${question.content}"

Hãy trả lời theo định dạng JSON:
{
  "subject": "tên môn học (Toán, Tiếng Việt, Tiếng Anh, Khoa học, Lịch sử, Địa lý, Tin học, v.v.)",
  "topic": "chủ đề chính",
  "subtopic": "chủ đề phụ (nếu có)",
  "difficulty": "easy|medium|hard",
  "grade": số lớp phù hợp (1-9),
  "confidence": số từ 0.0 đến 1.0
}`;

      const response = await this.openai.chat.completions.create({
        model: this.config.get('app.openai.model'),
        messages: [{ role: 'user', content: prompt }],
        response_format: { type: 'json_object' },
        max_tokens: 200,
        temperature: 0.2,
      });

      const result = JSON.parse(response.choices[0].message.content);

      await this.questionRepo.update(question.id, {
        subject: result.subject,
        topic: result.topic,
        subtopic: result.subtopic,
        difficulty: ['easy', 'medium', 'hard'].includes(result.difficulty)
          ? result.difficulty
          : 'medium',
        aiConfidence: result.confidence,
      });
    } catch (e) {
      this.logger.error(`Failed to classify question ${question.id}: ${e.message}`);
    }
  }

  async generateSimilarQuestions(questionId: string, count = 3): Promise<string[]> {
    const question = await this.questionRepo.findOne({
      where: { id: questionId },
      relations: ['answers'],
    });
    if (!question) return [];

    const answerText = question.answers
      ?.map((a) => `${a.label}. ${a.content}${a.isCorrect ? ' (Đáp án đúng)' : ''}`)
      .join('\n');

    const prompt = `Dựa trên câu hỏi gốc, hãy tạo ${count} câu hỏi tương tự (cùng chủ đề, cùng độ khó):

Câu hỏi gốc:
${question.content}
${answerText || ''}

Môn học: ${question.subject || 'Chưa xác định'}
Chủ đề: ${question.topic || 'Chưa xác định'}

Trả lời theo định dạng JSON:
{
  "questions": [
    {
      "content": "nội dung câu hỏi",
      "type": "${question.type}",
      ${question.type === 'multiple_choice' ? '"options": {"A": "...", "B": "...", "C": "...", "D": "..."}, "answer": "A|B|C|D"' : ''}
      ${question.type === 'true_false' ? '"answer": "true|false"' : ''}
      ${question.type === 'numeric' ? '"answer": "giá trị số"' : ''}
    }
  ]
}`;

    const response = await this.openai.chat.completions.create({
      model: this.config.get('app.openai.model'),
      messages: [{ role: 'user', content: prompt }],
      response_format: { type: 'json_object' },
      max_tokens: 1000,
      temperature: 0.7,
    });

    const result = JSON.parse(response.choices[0].message.content);
    return result.questions || [];
  }

  async analyzeStudentPerformance(userId: string): Promise<{
    strengths: string[];
    weaknesses: string[];
    recommendations: string[];
    summary: string;
  }> {
    const stats = await this.statsRepo.findOne({ where: { userId } });
    if (!stats) {
      return {
        strengths: [],
        weaknesses: [],
        recommendations: ['Hãy bắt đầu làm bài để nhận phân tích chi tiết'],
        summary: 'Chưa có đủ dữ liệu học tập',
      };
    }

    const statsBySubject = stats.statsBySubject as Record<string, any>;
    const subjectSummary = Object.entries(statsBySubject)
      .map(([subject, data]) => `${subject}: ${data.correctRate}% chính xác (${data.total} câu)`)
      .join('\n');

    const prompt = `Phân tích năng lực học sinh từ dữ liệu sau:

Tổng câu hỏi: ${stats.totalQuestions}
Tỷ lệ chính xác: ${stats.accuracyRate}%
Streak hôm nay: ${stats.currentDailyStreak} ngày

Kết quả theo môn:
${subjectSummary}

Hãy phân tích và đưa ra:
1. Điểm mạnh (môn học hoặc kỹ năng tốt)
2. Điểm yếu (cần cải thiện)
3. Khuyến nghị học tập cụ thể
4. Tóm tắt tổng thể

Trả lời JSON:
{
  "strengths": ["điểm mạnh 1", "điểm mạnh 2"],
  "weaknesses": ["điểm yếu 1", "điểm yếu 2"],
  "recommendations": ["khuyến nghị 1", "khuyến nghị 2", "khuyến nghị 3"],
  "summary": "tóm tắt 2-3 câu"
}`;

    try {
      const response = await this.openai.chat.completions.create({
        model: this.config.get('app.openai.model'),
        messages: [{ role: 'user', content: prompt }],
        response_format: { type: 'json_object' },
        max_tokens: 500,
        temperature: 0.3,
      });

      const result = JSON.parse(response.choices[0].message.content);

      // Save report
      await this.reportRepo.save(
        this.reportRepo.create({
          userId,
          reportType: 'weakness_analysis',
          content: result,
          strengths: result.strengths,
          weaknesses: result.weaknesses,
          recommendations: result.recommendations,
        }),
      );

      return result;
    } catch (e) {
      this.logger.error(`AI analysis failed for user ${userId}: ${e.message}`);
      return {
        strengths: [],
        weaknesses: [],
        recommendations: ['Tiếp tục luyện tập đều đặn mỗi ngày'],
        summary: 'Đang phân tích dữ liệu học tập của bạn',
      };
    }
  }

  async getReports(userId: string) {
    return this.reportRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: 10,
    });
  }

  async generatePersonalizedExercise(userId: string, subject: string, count = 10) {
    const stats = await this.statsRepo.findOne({ where: { userId } });
    const subjectStats = (stats?.statsBySubject as any)?.[subject] || {};

    const weakTopics = Object.entries(subjectStats.byTopic || {})
      .filter(([, data]: any) => data.correctRate < 70)
      .map(([topic]) => topic)
      .slice(0, 3);

    return {
      userId,
      subject,
      focusTopics: weakTopics,
      recommendedDifficulty: subjectStats.correctRate > 80 ? 'hard' : subjectStats.correctRate > 60 ? 'medium' : 'easy',
      count,
    };
  }
}
