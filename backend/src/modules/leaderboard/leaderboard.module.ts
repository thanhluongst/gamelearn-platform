import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LeaderboardService } from './leaderboard.service';
import { LeaderboardController } from './leaderboard.controller';
import { LeaderboardSnapshotEntity } from './entities/leaderboard-snapshot.entity';
import { UserEntity } from '../users/entities/user.entity';
import { UserStatisticsEntity } from '../statistics/entities/user-statistics.entity';

@Module({
  imports: [TypeOrmModule.forFeature([LeaderboardSnapshotEntity, UserEntity, UserStatisticsEntity])],
  controllers: [LeaderboardController],
  providers: [LeaderboardService],
  exports: [LeaderboardService],
})
export class LeaderboardModule {}
