import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { GameSessionEntity } from './entities/game-session.entity';
import { GamePlayerEntity } from './entities/game-player.entity';
import { GameAnswerEntity } from './entities/game-answer.entity';
import { QuestionEntity } from '../questions/entities/question.entity';
import { UserEntity } from '../users/entities/user.entity';
import { XpLogEntity } from '../users/entities/xp-log.entity';
import { QuestionsService } from '../questions/questions.service';
import { StatisticsService } from '../statistics/statistics.service';
import { AchievementsService } from '../achievements/achievements.service';
import { CreateGameSessionDto } from './dto/create-game-session.dto';

@Injectable()
export class GamesService {
  constructor(
    @InjectRepository(GameSessionEntity)
    private readonly sessionRepo: Repository<GameSessionEntity>,
    @InjectRepository(GamePlayerEntity)
    private readonly playerRepo: Repository<GamePlayerEntity>,
    @InjectRepository(GameAnswerEntity)
    private readonly answerRepo: Repository<GameAnswerEntity>,
    @InjectRepository(QuestionEntity)
    private readonly questionRepo: Repository<QuestionEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(XpLogEntity)
    private readonly xpLogRepo: Repository<XpLogEntity>,
    private readonly questionsService: QuestionsService,
    private readonly statsService: StatisticsService,
    private readonly achievementsService: AchievementsService,
    private readonly dataSource: DataSource,
  ) {}

  async createSession(teacherId: string, dto: CreateGameSessionDto) {
    // Select questions from bank
    const { data: questions } = await this.questionsService.getQuestions(dto.bankId, {
      difficulty: dto.difficulty,
      subject: dto.subject,
      topic: dto.topic,
      limit: dto.questionCount,
      random: true,
    });

    if (questions.length === 0) {
      throw new BadRequestException('Không có câu hỏi nào phù hợp');
    }

    const joinCode = this.generateJoinCode();
    const session = await this.sessionRepo.save(
      this.sessionRepo.create({
        ...dto,
        teacherId,
        joinCode,
        questionIds: questions.map((q) => q.id),
        status: 'waiting',
      }),
    );

    return session;
  }

  async joinSession(
    userId: string,
    sessionId?: string,
    joinCode?: string,
    nickname?: string,
  ) {
    const where = sessionId ? { id: sessionId } : { joinCode };
    const session = await this.sessionRepo.findOne({ where });
    if (!session) throw new NotFoundException('Không tìm thấy trò chơi');
    if (session.status === 'finished') throw new BadRequestException('Trò chơi đã kết thúc');
    if (session.status === 'playing' && !session.allowLateJoin) {
      throw new BadRequestException('Trò chơi đã bắt đầu, không cho phép vào muộn');
    }

    const user = await this.userRepo.findOne({ where: { id: userId } });
    const existingPlayer = await this.playerRepo.findOne({
      where: { sessionId: session.id, playerId: userId },
    });

    if (!existingPlayer) {
      await this.playerRepo.save(
        this.playerRepo.create({
          sessionId: session.id,
          playerId: userId,
          nickname: nickname || user.fullName,
          avatarUrl: user.avatarUrl,
        }),
      );
      await this.sessionRepo.increment({ id: session.id }, 'totalPlayers', 1);
    }

    return session;
  }

  async startSession(sessionId: string, teacherId: string) {
    const session = await this.sessionRepo.findOne({ where: { id: sessionId } });
    if (!session) throw new NotFoundException('Không tìm thấy trò chơi');
    if (session.teacherId !== teacherId) throw new ForbiddenException();
    if (session.status !== 'waiting') throw new BadRequestException('Trò chơi đã bắt đầu');

    await this.sessionRepo.update(sessionId, {
      status: 'playing',
      startedAt: new Date(),
      currentQuestionIndex: 0,
    });

    return this.sessionRepo.findOne({ where: { id: sessionId } });
  }

  async submitAnswer(
    sessionId: string,
    playerId: string,
    questionId: string,
    userAnswer: string,
    timeTaken: number,
  ) {
    const session = await this.sessionRepo.findOne({ where: { id: sessionId } });
    if (!session || session.status !== 'playing') {
      throw new BadRequestException('Trò chơi không còn hoạt động');
    }

    // Check if already answered this question
    const existing = await this.answerRepo.findOne({
      where: { sessionId, playerId, questionId },
    });
    if (existing) {
      return { alreadyAnswered: true, isCorrect: existing.isCorrect };
    }

    const { isCorrect, correctAnswer, explanation } =
      await this.questionsService.checkAnswer(questionId, userAnswer);

    // Calculate score: base + speed bonus
    const question = await this.questionRepo.findOne({ where: { id: questionId } });
    let scoreEarned = 0;
    let xpEarned = 0;

    if (isCorrect) {
      const timeBonus = Math.max(0, Math.floor((question.timeLimit * 1000 - timeTaken) / 1000));
      scoreEarned = 100 + timeBonus * 2;
      xpEarned = question.xpReward;
    }

    // Save answer
    await this.answerRepo.save(
      this.answerRepo.create({
        sessionId,
        playerId,
        questionId,
        answerGiven: userAnswer,
        isCorrect,
        timeTaken,
        scoreEarned,
      }),
    );

    // Update player stats
    const player = await this.playerRepo.findOne({ where: { sessionId, playerId } });
    const newStreak = isCorrect ? player.streak + 1 : 0;
    const streakBonus = isCorrect && newStreak >= 3 ? Math.floor(newStreak / 3) * 10 : 0;
    scoreEarned += streakBonus;

    await this.playerRepo.update({ sessionId, playerId }, {
      score: () => `score + ${scoreEarned}`,
      correctCount: isCorrect ? () => 'correct_count + 1' : undefined,
      wrongCount: !isCorrect ? () => 'wrong_count + 1' : undefined,
      streak: newStreak,
      maxStreak: () => `GREATEST(max_streak, ${newStreak})`,
      xpEarned: isCorrect ? () => `xp_earned + ${xpEarned}` : undefined,
    });

    // Grant XP to user
    if (xpEarned > 0) {
      await this.grantXp(playerId, xpEarned, 'game_answer', sessionId);
    }

    return {
      isCorrect,
      correctAnswer,
      explanation,
      scoreEarned,
      streakBonus,
      currentStreak: newStreak,
      xpEarned,
    };
  }

  async advanceQuestion(sessionId: string, teacherId: string) {
    const session = await this.sessionRepo.findOne({ where: { id: sessionId } });
    if (!session || session.teacherId !== teacherId) throw new ForbiddenException();

    const nextIndex = session.currentQuestionIndex + 1;
    if (nextIndex >= session.questionIds.length) return null;

    await this.sessionRepo.update(sessionId, { currentQuestionIndex: nextIndex });
    return this.sessionRepo.findOne({ where: { id: sessionId } });
  }

  async endSession(sessionId: string, teacherId: string) {
    const session = await this.sessionRepo.findOne({ where: { id: sessionId } });
    if (!session || session.teacherId !== teacherId) throw new ForbiddenException();

    const players = await this.playerRepo.find({
      where: { sessionId },
      order: { score: 'DESC' },
    });

    // Assign ranks and bonus XP for top 3
    const rankBonuses = [200, 100, 50];
    for (let i = 0; i < players.length; i++) {
      const rank = i + 1;
      const bonus = rankBonuses[i] || 0;
      await this.playerRepo.update(players[i].id, { rank, finishedAt: new Date() });
      if (bonus > 0) {
        await this.grantXp(players[i].playerId, bonus, 'game_rank', sessionId);
      }

      // Update user statistics
      await this.statsService.recordGameResult(players[i].playerId, {
        sessionId,
        isCorrect: players[i].correctCount,
        wrongCount: players[i].wrongCount,
        score: players[i].score,
        rank,
        totalPlayers: players.length,
      });
    }

    const avgScore = players.reduce((sum, p) => sum + p.score, 0) / (players.length || 1);
    await this.sessionRepo.update(sessionId, {
      status: 'finished',
      endedAt: new Date(),
      avgScore,
    });

    // Check achievements
    for (const player of players) {
      await this.achievementsService.checkAndGrant(player.playerId);
    }

    return { players, sessionId, avgScore };
  }

  async getSessionPlayers(sessionId: string) {
    return this.playerRepo.find({
      where: { sessionId },
      order: { score: 'DESC' },
    });
  }

  async getSessionLeaderboard(sessionId: string) {
    const players = await this.playerRepo.find({
      where: { sessionId },
      order: { score: 'DESC' },
      take: 20,
    });
    return players.map((p, i) => ({ rank: i + 1, ...p }));
  }

  async getSessionQuestion(sessionId: string, index: number) {
    const session = await this.sessionRepo.findOne({ where: { id: sessionId } });
    if (!session || !session.questionIds[index]) return null;

    return this.questionRepo.findOne({
      where: { id: session.questionIds[index] },
      relations: ['answers'],
    });
  }

  async findSessions(userId: string, filters: { status?: string; page: number; limit: number }) {
    const qb = this.sessionRepo.createQueryBuilder('s')
      .where('s.teacher_id = :userId', { userId });
    if (filters.status) qb.andWhere('s.status = :status', { status: filters.status });

    const [data, total] = await qb
      .orderBy('s.created_at', 'DESC')
      .skip((filters.page - 1) * filters.limit)
      .take(filters.limit)
      .getManyAndCount();
    return { data, total, page: filters.page, limit: filters.limit };
  }

  async findSessionById(id: string) {
    const session = await this.sessionRepo.findOne({ where: { id } });
    if (!session) throw new NotFoundException('Không tìm thấy phiên game');
    return session;
  }

  async getSessionResults(sessionId: string) {
    const [players, session] = await Promise.all([
      this.playerRepo.find({ where: { sessionId }, order: { score: 'DESC' } }),
      this.sessionRepo.findOne({ where: { id: sessionId } }),
    ]);
    return { session, players };
  }

  async getSessions(filters: {
    teacherId?: string;
    classId?: string;
    status?: string;
    limit?: number;
    offset?: number;
  }) {
    const qb = this.sessionRepo.createQueryBuilder('s');
    if (filters.teacherId) qb.andWhere('s.teacher_id = :teacherId', { teacherId: filters.teacherId });
    if (filters.classId) qb.andWhere('s.class_id = :classId', { classId: filters.classId });
    if (filters.status) qb.andWhere('s.status = :status', { status: filters.status });

    const total = await qb.getCount();
    qb.orderBy('s.created_at', 'DESC');
    if (filters.limit) qb.take(filters.limit);
    if (filters.offset) qb.skip(filters.offset);

    const data = await qb.getMany();
    return { data, meta: { total } };
  }

  private async grantXp(userId: string, amount: number, source: string, sourceId?: string) {
    await this.dataSource.transaction(async (manager) => {
      await manager.update(UserEntity, { id: userId }, { xpTotal: () => `xp_total + ${amount}` });
      await manager.save(XpLogEntity, { userId, xpAmount: amount, source, sourceId });
      // Level up check done by DB trigger / cron
    });
  }

  private generateJoinCode(): string {
    const chars = 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789';
    return Array.from({ length: 6 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
  }
}
