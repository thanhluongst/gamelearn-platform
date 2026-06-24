import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MulterModule } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { QuestionsService } from './questions.service';
import { QuestionsController } from './questions.controller';
import { QuestionEntity } from './entities/question.entity';
import { AnswerEntity } from './entities/answer.entity';
import { QuestionBankEntity } from './entities/question-bank.entity';
import { ImportBatchEntity } from './entities/import-batch.entity';
import { AiModule } from '../ai/ai.module';
import { StorageModule } from '../storage/storage.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([QuestionEntity, AnswerEntity, QuestionBankEntity, ImportBatchEntity]),
    MulterModule.register({ storage: memoryStorage() }),
    AiModule,
    StorageModule,
  ],
  controllers: [QuestionsController],
  providers: [QuestionsService],
  exports: [QuestionsService],
})
export class QuestionsModule {}
