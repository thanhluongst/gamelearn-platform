import { Controller, Get, Post, Body, Param, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AiService } from './ai.service';

@Controller('ai')
@UseGuards(JwtAuthGuard)
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('classify-batch/:batchId')
  classifyBatch(@Param('batchId', ParseUUIDPipe) batchId: string) {
    return this.aiService.classifyQuestionsInBatch(batchId);
  }

  @Post('generate-similar/:questionId')
  generateSimilar(
    @Param('questionId', ParseUUIDPipe) questionId: string,
    @Body('count') count = 3,
  ) {
    return this.aiService.generateSimilarQuestions(questionId, count);
  }

  @Post('analyze/:userId')
  analyzeStudent(@Param('userId', ParseUUIDPipe) userId: string) {
    return this.aiService.analyzeStudentPerformance(userId);
  }

  @Get('reports/:userId')
  getReports(@Param('userId', ParseUUIDPipe) userId: string) {
    return this.aiService.getReports(userId);
  }
}
