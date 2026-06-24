import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('question_banks')
export class QuestionBankEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'owner_id' })
  ownerId: string;

  @Column({ name: 'school_id', nullable: true })
  schoolId: string;

  @Column()
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ nullable: true })
  subject: string;

  @Column({ nullable: true })
  grade: number;

  @Column({ name: 'total_questions', default: 0 })
  totalQuestions: number;

  @Column({ name: 'is_public', default: false })
  isPublic: boolean;

  @Column({ type: 'text', array: true, nullable: true })
  tags: string[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
