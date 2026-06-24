import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('daily_statistics')
export class DailyStatisticsEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ type: 'date' })
  date: Date;

  @Column({ name: 'questions_answered', default: 0 })
  questionsAnswered: number;

  @Column({ name: 'correct_answers', default: 0 })
  correctAnswers: number;

  @Column({ name: 'games_played', default: 0 })
  gamesPlayed: number;

  @Column({ name: 'xp_earned', default: 0 })
  xpEarned: number;

  @Column({ name: 'time_spent', default: 0 })
  timeSpent: number;
}
