import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('ai_reports')
export class AiReportEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', nullable: true })
  userId: string;

  @Column({ name: 'session_id', nullable: true })
  sessionId: string;

  @Column({ name: 'report_type' })
  reportType: string;

  @Column({ type: 'jsonb' })
  content: Record<string, any>;

  @Column({ type: 'jsonb', default: [] })
  strengths: string[];

  @Column({ type: 'jsonb', default: [] })
  weaknesses: string[];

  @Column({ type: 'jsonb', default: [] })
  recommendations: string[];

  @CreateDateColumn({ name: 'generated_at' })
  generatedAt: Date;
}
