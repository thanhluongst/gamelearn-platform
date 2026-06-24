import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { QuestionEntity } from './question.entity';

@Entity('answers')
export class AnswerEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'question_id' })
  questionId: string;

  @ManyToOne(() => QuestionEntity, (q) => q.answers, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'question_id' })
  question: QuestionEntity;

  @Column({ type: 'char', length: 1 })
  label: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ name: 'is_correct', default: false })
  isCorrect: boolean;

  @Column({ name: 'display_order', default: 0 })
  displayOrder: number;
}
