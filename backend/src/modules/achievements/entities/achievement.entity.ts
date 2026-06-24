import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('achievements')
export class AchievementEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ default: 'bronze' })
  tier: string;

  @Column({ name: 'icon_url', nullable: true })
  iconUrl: string;

  @Column({ type: 'jsonb' })
  conditions: Record<string, any>;

  @Column({ name: 'xp_reward', default: 0 })
  xpReward: number;

  @Column({ name: 'coin_reward', default: 0 })
  coinReward: number;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
