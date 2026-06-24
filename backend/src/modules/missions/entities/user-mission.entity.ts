import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('user_missions')
export class UserMissionEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'mission_id' })
  missionId: string;

  @Column({ name: 'current_value', default: 0 })
  currentValue: number;

  @Column({ name: 'target_value' })
  targetValue: number;

  @Column({ default: 'in_progress' })
  status: string; // 'in_progress' | 'completed' | 'claimed'

  @Column({ name: 'period_date', type: 'date' })
  periodDate: string;

  @Column({ name: 'completed_at', nullable: true, type: 'timestamp' })
  completedAt: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
