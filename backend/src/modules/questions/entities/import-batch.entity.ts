import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('import_batches')
export class ImportBatchEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'bank_id' })
  bankId: string;

  @Column({ name: 'uploaded_by' })
  uploadedBy: string;

  @Column({ name: 'file_name' })
  fileName: string;

  @Column({ name: 'file_url' })
  fileUrl: string;

  @Column({ default: 'processing' })
  status: string;

  @Column({ name: 'total_rows', default: 0 })
  totalRows: number;

  @Column({ name: 'processed_rows', default: 0 })
  processedRows: number;

  @Column({ name: 'success_rows', default: 0 })
  successRows: number;

  @Column({ name: 'error_rows', default: 0 })
  errorRows: number;

  @Column({ type: 'jsonb', default: [] })
  errors: any[];

  @Column({ name: 'ai_processing_status', default: 'pending' })
  aiProcessingStatus: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @Column({ name: 'completed_at', nullable: true })
  completedAt: Date;
}
