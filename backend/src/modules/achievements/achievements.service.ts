import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AchievementEntity } from './entities/achievement.entity';
import { UserAchievementEntity } from './entities/user-achievement.entity';
import { UserEntity } from '../users/entities/user.entity';
import { UserStatisticsEntity } from '../statistics/entities/user-statistics.entity';

@Injectable()
export class AchievementsService {
  private readonly logger = new Logger(AchievementsService.name);

  constructor(
    @InjectRepository(AchievementEntity)
    private readonly achievementRepo: Repository<AchievementEntity>,
    @InjectRepository(UserAchievementEntity)
    private readonly userAchievementRepo: Repository<UserAchievementEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(UserStatisticsEntity)
    private readonly statsRepo: Repository<UserStatisticsEntity>,
  ) {}

  async checkAndGrant(userId: string): Promise<UserAchievementEntity[]> {
    const [user, stats, allAchievements, earnedIds] = await Promise.all([
      this.userRepo.findOne({ where: { id: userId } }),
      this.statsRepo.findOne({ where: { userId } }),
      this.achievementRepo.find({ where: { isActive: true } }),
      this.userAchievementRepo.find({ where: { userId }, select: ['achievementId'] })
        .then((ua) => new Set(ua.map((a) => a.achievementId))),
    ]);

    if (!user || !stats) return [];

    const newlyEarned: UserAchievementEntity[] = [];

    for (const achievement of allAchievements) {
      if (earnedIds.has(achievement.id)) continue;

      const conditions = achievement.conditions as any;
      let qualifies = false;

      switch (conditions.type) {
        case 'correct_answers':
          qualifies = stats.correctQuestions >= conditions.value;
          break;
        case 'total_correct':
          qualifies = stats.correctQuestions >= conditions.value;
          break;
        case 'daily_streak':
          qualifies = stats.currentDailyStreak >= conditions.value;
          break;
        case 'level':
          qualifies = user.level >= conditions.value;
          break;
        case 'games_played':
          qualifies = stats.totalGames >= conditions.value;
          break;
        case 'first_answer':
          qualifies = stats.totalQuestions >= 1;
          break;
      }

      if (qualifies) {
        try {
          const earned = await this.userAchievementRepo.save(
            this.userAchievementRepo.create({ userId, achievementId: achievement.id }),
          );
          newlyEarned.push(earned);

          // Grant rewards
          if (achievement.xpReward > 0 || achievement.coinReward > 0) {
            await this.userRepo.update(userId, {
              xpTotal: () => `xp_total + ${achievement.xpReward}`,
              coins: () => `coins + ${achievement.coinReward}`,
            });
          }

          this.logger.log(`User ${userId} earned achievement: ${achievement.name}`);
        } catch (e) {
          // Unique constraint - already earned
        }
      }
    }

    return newlyEarned;
  }

  async getUserAchievements(userId: string) {
    return this.userAchievementRepo.find({
      where: { userId },
      relations: ['achievement'],
      order: { earnedAt: 'DESC' },
    });
  }

  async getAllAchievements() {
    return this.achievementRepo.find({ where: { isActive: true }, order: { tier: 'ASC' } });
  }
}
