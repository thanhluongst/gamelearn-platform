import {
  Controller, Get, Post, Put, Delete, Body, Param, Query,
  UseGuards, Request, ParseUUIDPipe, UploadedFile, UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { QuestionsService } from './questions.service';
import { CreateQuestionBankDto } from './dto/create-question-bank.dto';
import { CreateQuestionDto } from './dto/create-question.dto';

@Controller('question-banks')
@UseGuards(JwtAuthGuard)
export class QuestionsController {
  constructor(private readonly questionsService: QuestionsService) {}

  @Get()
  getBanks(@Request() req: any, @Query('schoolId') schoolId: string) {
    return this.questionsService.getBanks(req.user.sub, schoolId);
  }

  @Post()
  createBank(@Request() req: any, @Body() dto: CreateQuestionBankDto) {
    return this.questionsService.createBank(req.user.sub, dto);
  }

  @Get(':id/questions')
  getQuestions(
    @Param('id', ParseUUIDPipe) id: string,
    @Query('difficulty') difficulty: string,
    @Query('subject') subject: string,
    @Query('topic') topic: string,
    @Query('type') type: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
    @Query('random') random: string,
  ) {
    return this.questionsService.getQuestions(id, {
      difficulty, subject, topic, type,
      page: +page, limit: +limit,
      random: random === 'true',
    });
  }

  @Post(':id/questions')
  addQuestion(
    @Param('id', ParseUUIDPipe) bankId: string,
    @Request() req: any,
    @Body() dto: CreateQuestionDto,
  ) {
    return this.questionsService.addQuestion(bankId, req.user.sub, dto);
  }

  @Post(':id/import')
  @UseInterceptors(FileInterceptor('file'))
  importExcel(
    @Param('id', ParseUUIDPipe) bankId: string,
    @Request() req: any,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.questionsService.importFromExcel(bankId, req.user.sub, file);
  }

  @Delete(':bankId/questions/:questionId')
  deleteQuestion(
    @Param('bankId', ParseUUIDPipe) bankId: string,
    @Param('questionId', ParseUUIDPipe) questionId: string,
  ) {
    return this.questionsService.deleteQuestion(bankId, questionId);
  }
}
