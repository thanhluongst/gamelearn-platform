import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, Index } from 'typeorm';

@Entity('leaderboard_snapshots')
@Index(['scope', 'period', 'scopeId', 'snapshotDate'])
export class LeaderboardSnapshotEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  scope: string; // 'class' | 'school' | 'global'

  @Column({ name: 'scope_id', nullable: true })
  scopeId: string;

  @Column()
  period: string; // 'daily' | 'weekly' | 'monthly' | 'all_time'

  @Column({ name: 'snapshot_date', type: 'date' })
  snapshotDate: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'full_name' })
  fullName: string;

  @Column({ name: 'avatar_url', nullable: true })
  avatarUrl: string;

  @Column({ default: 0 })
  score: number;

  @Column({ default: 0 })
  rank: number;

  @Column({ default: 1 })
  level: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
