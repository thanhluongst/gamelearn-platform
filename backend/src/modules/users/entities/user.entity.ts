import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Exclude } from 'class-transformer';

@Entity('users')
@Index(['email'], { unique: true, where: 'email IS NOT NULL' })
@Index(['username'], { unique: true })
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'school_id', nullable: true })
  schoolId: string;

  @Column({
    type: 'enum',
    enum: ['admin', 'teacher', 'student'],
    default: 'student',
  })
  role: string;

  @Column({
    type: 'enum',
    enum: ['active', 'inactive', 'suspended'],
    default: 'active',
  })
  status: string;

  @Column({ nullable: true, unique: true })
  email: string;

  @Column({ nullable: true })
  phone: string;

  @Column({ unique: true })
  username: string;

  @Column({ name: 'password_hash', select: false })
  @Exclude()
  passwordHash: string;

  @Column({ name: 'full_name' })
  fullName: string;

  @Column({ name: 'avatar_url', nullable: true })
  avatarUrl: string;

  @Column({ name: 'date_of_birth', type: 'date', nullable: true })
  dateOfBirth: Date;

  @Column({ nullable: true })
  gender: string;

  @Column({ name: 'xp_total', default: 0 })
  xpTotal: number;

  @Column({ default: 1 })
  level: number;

  @Column({ default: 0 })
  coins: number;

  @Column({ name: 'student_code', nullable: true })
  studentCode: string;

  @Column({ nullable: true })
  grade: number;

  @Column({ name: 'refresh_token_hash', nullable: true, select: false })
  @Exclude()
  refreshTokenHash: string;

  @Column({ name: 'last_login_at', nullable: true })
  lastLoginAt: Date;

  @Column({ type: 'jsonb', default: { notifications: true, sound: true, language: 'vi' } })
  settings: Record<string, any>;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Virtual
  get accuracyRate(): number {
    return 0;
  }
}
