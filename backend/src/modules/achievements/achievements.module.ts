import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AchievementsService } from './achievements.service';
import { AchievementsController } from './achievements.controller';
import { AchievementEntity } from './entities/achievement.entity';
import { UserAchievementEntity } from './entities/user-achievement.entity';
import { UserEntity } from '../users/entities/user.entity';
import { UserStatisticsEntity } from '../statistics/entities/user-statistics.entity';

@Module({
  imports: [TypeOrmModule.forFeature([AchievementEntity, UserAchievementEntity, UserEntity, UserStatisticsEntity])],
  controllers: [AchievementsController],
  providers: [AchievementsService],
  exports: [AchievementsService],
})
export class AchievementsModule {}
