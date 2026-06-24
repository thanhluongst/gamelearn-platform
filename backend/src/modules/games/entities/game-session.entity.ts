import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('game_sessions')
export class GameSessionEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'class_id', nullable: true })
  classId: string;

  @Column({ name: 'teacher_id', nullable: true })
  teacherId: string;

  @Column({ name: 'bank_id', nullable: true })
  bankId: string;

  @Column({ name: 'game_type' })
  gameType: string;

  @Column({ default: 'waiting' })
  status: string;

  @Column({ nullable: true })
  title: string;

  @Column({ name: 'join_code', nullable: true, unique: true })
  joinCode: string;

  @Column({ name: 'max_players', default: 50 })
  maxPlayers: number;

  @Column({ name: 'question_count', default: 10 })
  questionCount: number;

  @Column({ name: 'time_per_question', default: 30 })
  timePerQuestion: number;

  @Column({ name: 'allow_late_join', default: true })
  allowLateJoin: boolean;

  @Column({ name: 'show_leaderboard', default: true })
  showLeaderboard: boolean;

  @Column({ name: 'randomize_questions', default: true })
  randomizeQuestions: boolean;

  @Column({ name: 'question_ids', type: 'uuid', array: true, default: [] })
  questionIds: string[];

  @Column({ name: 'current_question_index', default: 0 })
  currentQuestionIndex: number;

  @Column({ name: 'started_at', nullable: true })
  startedAt: Date;

  @Column({ name: 'ended_at', nullable: true })
  endedAt: Date;

  @Column({ name: 'total_players', default: 0 })
  totalPlayers: number;

  @Column({ name: 'avg_score', type: 'decimal', precision: 5, scale: 2, nullable: true })
  avgScore: number;

  @Column({ type: 'jsonb', default: {} })
  settings: Record<string, any>;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
