import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Cron, CronExpression } from '@nestjs/schedule';
import { MissionEntity } from './entities/mission.entity';
import { UserMissionEntity } from './entities/user-mission.entity';
import { UserEntity } from '../users/entities/user.entity';

@Injectable()
export class MissionsService {
  constructor(
    @InjectRepository(MissionEntity) private readonly missionRepo: Repository<MissionEntity>,
    @InjectRepository(UserMissionEntity) private readonly userMissionRepo: Repository<UserMissionEntity>,
    @InjectRepository(UserEntity) private readonly userRepo: Repository<UserEntity>,
  ) {}

  async getUserMissions(userId: string) {
    const today = new Date().toISOString().split('T')[0];
    await this.ensureDailyMissionsForUser(userId, today);

    return this.userMissionRepo
      .createQueryBuilder('um')
      .leftJoinAndSelect('um.mission', 'mission')
      .where('um.userId = :userId', { userId })
      .andWhere('um.periodDate = :date', { date: today })
      .getMany();
  }

  async updateProgress(userId: string, missionKey: string, increment = 1): Promise<void> {
    const today = new Date().toISOString().split('T')[0];
    const missions = await this.missionRepo.find({ where: { missionKey, isActive: true } });

    for (const mission of missions) {
      const userMission = await this.userMissionRepo.findOne({
        where: { userId, missionId: mission.id, periodDate: today },
      });

      if (!userMission || userMission.status !== 'in_progress') continue;

      const newValue = Math.min(userMission.currentValue + increment, mission.targetValue);
      const updates: Partial<UserMissionEntity> = { currentValue: newValue };

      if (newValue >= mission.targetValue) {
        updates.status = 'completed';
        updates.completedAt = new Date();
      }

      await this.userMissionRepo.update(userMission.id, updates);
    }
  }

  async claimMission(userId: string, userMissionId: string) {
    const userMission = await this.userMissionRepo.findOne({
      where: { id: userMissionId, userId, status: 'completed' },
      relations: ['mission'],
    });
    if (!userMission) throw new NotFoundException('Mission not found or not completed');

    await this.userMissionRepo.update(userMissionId, { status: 'claimed' });
    await this.userRepo.increment({ id: userId }, 'xpTotal', (userMission as any).mission.xpReward);

    return { xpReward: (userMission as any).mission.xpReward };
  }

  private async ensureDailyMissionsForUser(userId: string, date: string): Promise<void> {
    const existing = await this.userMissionRepo.findOne({ where: { userId, periodDate: date } });
    if (existing) return;

    const dailyMissions = await this.missionRepo.find({ where: { type: 'daily', isActive: true } });
    const userMissions = dailyMissions.map(m =>
      this.userMissionRepo.create({
        userId,
        missionId: m.id,
        targetValue: m.targetValue,
        periodDate: date,
      }),
    );
    await this.userMissionRepo.save(userMissions);
  }

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async resetDailyMissions(): Promise<void> {
    // Old missions stay in DB for history; new ones auto-created on first access
  }
}
