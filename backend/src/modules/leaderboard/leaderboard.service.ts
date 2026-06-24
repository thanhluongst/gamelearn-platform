import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Cron, CronExpression } from '@nestjs/schedule';
import { LeaderboardSnapshotEntity } from './entities/leaderboard-snapshot.entity';
import { UserEntity } from '../users/entities/user.entity';
import { UserStatisticsEntity } from '../statistics/entities/user-statistics.entity';

export interface LeaderboardQuery {
  scope: 'class' | 'school' | 'global';
  scopeId?: string;
  period: 'daily' | 'weekly' | 'monthly' | 'all_time';
  limit?: number;
  page?: number;
}

@Injectable()
export class LeaderboardService {
  constructor(
    @InjectRepository(LeaderboardSnapshotEntity)
    private readonly snapshotRepo: Repository<LeaderboardSnapshotEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(UserStatisticsEntity)
    private readonly statsRepo: Repository<UserStatisticsEntity>,
    private readonly dataSource: DataSource,
  ) {}

  async getLeaderboard(query: LeaderboardQuery) {
    const { scope, scopeId, period, limit = 50, page = 1 } = query;
    const today = new Date().toISOString().split('T')[0];

    const qb = this.snapshotRepo.createQueryBuilder('s')
      .where('s.scope = :scope', { scope })
      .andWhere('s.period = :period', { period })
      .andWhere('s.snapshotDate = :date', { date: today });

    if (scopeId) qb.andWhere('s.scopeId = :scopeId', { scopeId });

    const [data, total] = await qb
      .orderBy('s.rank', 'ASC')
      .skip((page - 1) * limit)
      .take(limit)
      .getManyAndCount();

    return { data, total, page, limit };
  }

  async getUserRank(userId: string, scope: string, scopeId?: string, period = 'all_time') {
    const today = new Date().toISOString().split('T')[0];
    return this.snapshotRepo.findOne({
      where: { userId, scope, scopeId, period, snapshotDate: today },
    });
  }

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async refreshDailySnapshots(): Promise<void> {
    const today = new Date().toISOString().split('T')[0];
    await this.buildGlobalSnapshot(today, 'all_time');
    await this.buildGlobalSnapshot(today, 'daily');
    await this.buildGlobalSnapshot(today, 'weekly');
    await this.buildGlobalSnapshot(today, 'monthly');
  }

  private async buildGlobalSnapshot(date: string, period: string): Promise<void> {
    const users = await this.userRepo
      .createQueryBuilder('u')
      .leftJoinAndSelect('u.studentProfile', 'sp')
      .where('u.role = :role', { role: 'student' })
      .orderBy('u.xpTotal', 'DESC')
      .limit(1000)
      .getMany();

    await this.snapshotRepo.delete({ scope: 'global', period, snapshotDate: date });

    const snapshots = users.map((u, i) =>
      this.snapshotRepo.create({
        scope: 'global',
        period,
        snapshotDate: date,
        userId: u.id,
        fullName: u.fullName,
        avatarUrl: u.avatarUrl,
        score: u.xpTotal,
        rank: i + 1,
        level: u.level,
      }),
    );

    await this.snapshotRepo.save(snapshots, { chunk: 100 });
  }
}
