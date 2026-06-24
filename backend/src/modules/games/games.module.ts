import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { GamesService } from './games.service';
import { GamesController } from './games.controller';
import { GameGateway } from './game.gateway';
import { GameSessionEntity } from './entities/game-session.entity';
import { GamePlayerEntity } from './entities/game-player.entity';
import { GameAnswerEntity } from './entities/game-answer.entity';
import { QuestionEntity } from '../questions/entities/question.entity';
import { UserEntity } from '../users/entities/user.entity';
import { XpLogEntity } from '../users/entities/xp-log.entity';
import { QuestionsModule } from '../questions/questions.module';
import { StatisticsModule } from '../statistics/statistics.module';
import { AchievementsModule } from '../achievements/achievements.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      GameSessionEntity, GamePlayerEntity, GameAnswerEntity,
      QuestionEntity, UserEntity, XpLogEntity,
    ]),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get('app.jwtSecret'),
        signOptions: { expiresIn: config.get('app.jwtExpiry') },
      }),
    }),
    QuestionsModule,
    StatisticsModule,
    AchievementsModule,
  ],
  controllers: [GamesController],
  providers: [GamesService, GameGateway],
  exports: [GamesService],
})
export class GamesModule {}
