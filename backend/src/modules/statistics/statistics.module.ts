import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StatisticsService } from './statistics.service';
import { StatisticsController } from './statistics.controller';
import { UserStatisticsEntity } from './entities/user-statistics.entity';
import { DailyStatisticsEntity } from './entities/daily-statistics.entity';

@Module({
  imports: [TypeOrmModule.forFeature([UserStatisticsEntity, DailyStatisticsEntity])],
  controllers: [StatisticsController],
  providers: [StatisticsService],
  exports: [StatisticsService],
})
export class StatisticsModule {}
