import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('missions')
export class MissionEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ nullable: true })
  description: string;

  @Column()
  type: string; // 'daily' | 'weekly'

  @Column({ name: 'mission_key' })
  missionKey: string; // 'play_game', 'correct_answers', 'streak', etc.

  @Column({ name: 'target_value' })
  targetValue: number;

  @Column({ name: 'xp_reward' })
  xpReward: number;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
