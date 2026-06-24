import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('classes')
export class ClassEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ name: 'school_id' })
  schoolId: string;

  @Column({ name: 'teacher_id' })
  teacherId: string;

  @Column()
  grade: number;

  @Column({ name: 'academic_year' })
  academicYear: string;

  @Column({ name: 'join_code', unique: true })
  joinCode: string;

  @Column({ name: 'student_count', default: 0 })
  studentCount: number;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @Column({ type: 'jsonb', default: {} })
  settings: Record<string, any>;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
