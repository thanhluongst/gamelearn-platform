import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('game_players')
export class GamePlayerEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'session_id' })
  sessionId: string;

  @Column({ name: 'player_id' })
  playerId: string;

  @Column({ nullable: true })
  nickname: string;

  @Column({ name: 'avatar_url', nullable: true })
  avatarUrl: string;

  @Column({ default: 0 })
  score: number;

  @Column({ name: 'correct_count', default: 0 })
  correctCount: number;

  @Column({ name: 'wrong_count', default: 0 })
  wrongCount: number;

  @Column({ default: 0 })
  streak: number;

  @Column({ name: 'max_streak', default: 0 })
  maxStreak: number;

  @Column({ nullable: true })
  rank: number;

  @Column({ name: 'xp_earned', default: 0 })
  xpEarned: number;

  @Column({ name: 'coins_earned', default: 0 })
  coinsEarned: number;

  @CreateDateColumn({ name: 'joined_at' })
  joinedAt: Date;

  @Column({ name: 'finished_at', nullable: true })
  finishedAt: Date;
}
