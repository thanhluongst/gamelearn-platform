import { Entity, PrimaryGeneratedColumn, Column, UpdateDateColumn } from 'typeorm';

@Entity('user_statistics')
export class UserStatisticsEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', unique: true })
  userId: string;

  @Column({ name: 'total_questions', default: 0 })
  totalQuestions: number;

  @Column({ name: 'correct_questions', default: 0 })
  correctQuestions: number;

  @Column({ name: 'total_games', default: 0 })
  totalGames: number;

  @Column({ name: 'total_play_time', default: 0 })
  totalPlayTime: number;

  @Column({ name: 'stats_by_type', type: 'jsonb', default: {} })
  statsByType: Record<string, any>;

  @Column({ name: 'stats_by_subject', type: 'jsonb', default: {} })
  statsBySubject: Record<string, any>;

  @Column({ name: 'stats_by_topic', type: 'jsonb', default: {} })
  statsByTopic: Record<string, any>;

  @Column({ name: 'current_daily_streak', default: 0 })
  currentDailyStreak: number;

  @Column({ name: 'max_daily_streak', default: 0 })
  maxDailyStreak: number;

  @Column({ name: 'last_played_date', type: 'date', nullable: true })
  lastPlayedDate: Date;

  @Column({ name: 'accuracy_rate', type: 'decimal', precision: 5, scale: 2, default: 0 })
  accuracyRate: number;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
