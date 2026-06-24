import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { AnswerEntity } from './answer.entity';

@Entity('questions')
@Index(['bankId'])
@Index(['type'])
@Index(['difficulty'])
@Index(['subject'])
export class QuestionEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'bank_id' })
  bankId: string;

  @Column({
    type: 'enum',
    enum: ['multiple_choice', 'true_false', 'numeric'],
    default: 'multiple_choice',
  })
  type: string;

  @Column({
    type: 'enum',
    enum: ['easy', 'medium', 'hard'],
    default: 'medium',
  })
  difficulty: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ type: 'text', nullable: true })
  explanation: string;

  @Column({ name: 'image_url', nullable: true })
  imageUrl: string;

  @Column({ name: 'audio_url', nullable: true })
  audioUrl: string;

  @Column({ nullable: true })
  subject: string;

  @Column({ nullable: true })
  topic: string;

  @Column({ nullable: true })
  subtopic: string;

  @Column({ name: 'ai_confidence', type: 'decimal', precision: 3, scale: 2, nullable: true })
  aiConfidence: number;

  @Column({ name: 'time_limit', default: 30 })
  timeLimit: number;

  @Column({ name: 'xp_reward', default: 10 })
  xpReward: number;

  @Column({ name: 'total_attempts', default: 0 })
  totalAttempts: number;

  @Column({ name: 'correct_attempts', default: 0 })
  correctAttempts: number;

  @Column({ name: 'correct_answer', nullable: true })
  correctAnswer: string;

  @Column({ name: 'accepted_answers', type: 'jsonb', default: [] })
  acceptedAnswers: string[];

  @Column({ name: 'numeric_tolerance', type: 'decimal', precision: 10, scale: 4, default: 0.001 })
  numericTolerance: number;

  @Column({ name: 'import_row', nullable: true })
  importRow: number;

  @Column({ name: 'import_batch_id', nullable: true })
  importBatchId: string;

  @OneToMany(() => AnswerEntity, (a) => a.question, { cascade: true, eager: true })
  answers: AnswerEntity[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  get accuracyRate(): number {
    if (!this.totalAttempts) return 0;
    return Math.round((this.correctAttempts / this.totalAttempts) * 100);
  }
}
