import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('game_answers')
export class GameAnswerEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'session_id' })
  sessionId: string;

  @Column({ name: 'player_id' })
  playerId: string;

  @Column({ name: 'question_id' })
  questionId: string;

  @Column({ name: 'answer_given', nullable: true })
  answerGiven: string;

  @Column({ name: 'is_correct', default: false })
  isCorrect: boolean;

  @Column({ name: 'time_taken', nullable: true })
  timeTaken: number;

  @Column({ name: 'score_earned', default: 0 })
  scoreEarned: number;

  @CreateDateColumn({ name: 'answered_at' })
  answeredAt: Date;
}
