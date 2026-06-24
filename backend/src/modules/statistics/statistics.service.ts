import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserStatisticsEntity } from './entities/user-statistics.entity';
import { DailyStatisticsEntity } from './entities/daily-statistics.entity';

@Injectable()
export class StatisticsService {
  constructor(
    @InjectRepository(UserStatisticsEntity)
    private readonly userStatsRepo: Repository<UserStatisticsEntity>,
    @InjectRepository(DailyStatisticsEntity)
    private readonly dailyStatsRepo: Repository<DailyStatisticsEntity>,
  ) {}

  async recordGameResult(userId: string, result: {
    sessionId: string;
    isCorrect: number;
    wrongCount: number;
    score: number;
    rank: number;
    totalPlayers: number;
  }) {
    const today = new Date().toISOString().split('T')[0];

    // Update aggregate stats
    await this.userStatsRepo
      .createQueryBuilder()
      .update()
      .set({
        totalGames: () => 'total_games + 1',
        totalQuestions: () => `total_questions + ${result.isCorrect + result.wrongCount}`,
        correctQuestions: () => `correct_questions + ${result.isCorrect}`,
      })
      .where('user_id = :userId', { userId })
      .execute();

    // Ensure stat row exists
    await this.userStatsRepo
      .createQueryBuilder()
      .insert()
      .into(UserStatisticsEntity)
      .values({ userId })
      .orIgnore()
      .execute();

    // Update accuracy rate
    const stats = await this.userStatsRepo.findOne({ where: { userId } });
    if (stats && stats.totalQuestions > 0) {
      const rate = (stats.correctQuestions / stats.totalQuestions) * 100;
      await this.userStatsRepo.update({ userId }, { accuracyRate: rate });
    }

    // Update daily stats
    await this.dailyStatsRepo
      .createQueryBuilder()
      .insert()
      .into(DailyStatisticsEntity)
      .values({
        userId,
        date: today as any,
        questionsAnswered: result.isCorrect + result.wrongCount,
        correctAnswers: result.isCorrect,
        gamesPlayed: 1,
      })
      .orUpdate(['questions_answered', 'correct_answers', 'games_played'], ['user_id', 'date'])
      .execute();

    // Update streak
    await this.updateStreak(userId, today);
  }

  async recordAnswer(userId: string, questionId: string, isCorrect: boolean, subject?: string, topic?: string) {
    const today = new Date().toISOString().split('T')[0];

    await this.dailyStatsRepo
      .createQueryBuilder()
      .insert()
      .into(DailyStatisticsEntity)
      .values({
        userId,
        date: today as any,
        questionsAnswered: 1,
        correctAnswers: isCorrect ? 1 : 0,
      })
      .orUpdate(['questions_answered', 'correct_answers'], ['user_id', 'date'])
      .execute();

    if (subject) {
      await this.updateSubjectStats(userId, subject, topic, isCorrect);
    }
  }

  private async updateStreak(userId: string, today: string) {
    const stats = await this.userStatsRepo.findOne({ where: { userId } });
    if (!stats) return;

    const lastPlayed = stats.lastPlayedDate?.toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

    let newStreak = 1;
    if (lastPlayed === yesterday) {
      newStreak = stats.currentDailyStreak + 1;
    } else if (lastPlayed === today) {
      newStreak = stats.currentDailyStreak;
    }

    await this.userStatsRepo.update({ userId }, {
      currentDailyStreak: newStreak,
      maxDailyStreak: Math.max(stats.maxDailyStreak, newStreak),
      lastPlayedDate: today as any,
    });
  }

  private async updateSubjectStats(userId: string, subject: string, topic: string, isCorrect: boolean) {
    const stats = await this.userStatsRepo.findOne({ where: { userId } });
    const bySubject = (stats?.statsBySubject || {}) as Record<string, any>;

    if (!bySubject[subject]) {
      bySubject[subject] = { total: 0, correct: 0, correctRate: 0, byTopic: {} };
    }
    bySubject[subject].total++;
    if (isCorrect) bySubject[subject].correct++;
    bySubject[subject].correctRate = Math.round((bySubject[subject].correct / bySubject[subject].total) * 100);

    if (topic) {
      if (!bySubject[subject].byTopic[topic]) {
        bySubject[subject].byTopic[topic] = { total: 0, correct: 0, correctRate: 0 };
      }
      bySubject[subject].byTopic[topic].total++;
      if (isCorrect) bySubject[subject].byTopic[topic].correct++;
      bySubject[subject].byTopic[topic].correctRate = Math.round(
        (bySubject[subject].byTopic[topic].correct / bySubject[subject].byTopic[topic].total) * 100,
      );
    }

    await this.userStatsRepo.update({ userId }, { statsBySubject: bySubject });
  }

  async getUserStats(userId: string) {
    return this.userStatsRepo.findOne({ where: { userId } });
  }

  async getClassStats(classId: string) {
    const stats = await this.userStatsRepo
      .createQueryBuilder('s')
      .leftJoin('users', 'u', 'u.id = s.user_id')
      .leftJoin('class_members', 'cm', 'cm.user_id = s.user_id AND cm.class_id = :classId', { classId })
      .where('cm.class_id = :classId', { classId })
      .getMany();
    return stats;
  }

  async getDailyChart(userId: string, period: 'week' | 'month' | 'year' | number = 'week') {
    const days = period === 'week' ? 7 : period === 'month' ? 30 : period === 'year' ? 365 : Number(period);
    const dates = Array.from({ length: days }, (_, i) => {
      const d = new Date(Date.now() - (days - 1 - i) * 86400000);
      return d.toISOString().split('T')[0];
    });

    const dailyStats = await this.dailyStatsRepo
      .createQueryBuilder('d')
      .where('d.user_id = :userId', { userId })
      .andWhere('d.date >= :start', { start: dates[0] })
      .getMany();

    return dates.map((date) => {
      const stat = dailyStats.find((s) => s.date?.toString() === date);
      return {
        date,
        questionsAnswered: stat?.questionsAnswered || 0,
        correctAnswers: stat?.correctAnswers || 0,
        gamesPlayed: stat?.gamesPlayed || 0,
        xpEarned: stat?.xpEarned || 0,
      };
    });
  }
}
