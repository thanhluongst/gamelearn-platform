import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { AchievementEntity } from './achievement.entity';

@Entity('user_achievements')
export class UserAchievementEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'achievement_id' })
  achievementId: string;

  @ManyToOne(() => AchievementEntity)
  @JoinColumn({ name: 'achievement_id' })
  achievement: AchievementEntity;

  @CreateDateColumn({ name: 'earned_at' })
  earnedAt: Date;
}
