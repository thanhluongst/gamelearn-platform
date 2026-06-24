import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ClassEntity } from './entities/class.entity';
import { ClassMemberEntity } from './entities/class-member.entity';

function generateJoinCode(length = 6): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  return Array.from({ length }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
}

@Injectable()
export class ClassesService {
  constructor(
    @InjectRepository(ClassEntity) private readonly classRepo: Repository<ClassEntity>,
    @InjectRepository(ClassMemberEntity) private readonly memberRepo: Repository<ClassMemberEntity>,
  ) {}

  async create(teacherId: string, dto: Partial<ClassEntity>): Promise<ClassEntity> {
    const joinCode = generateJoinCode();
    const cls = this.classRepo.create({ ...dto, teacherId, joinCode });
    return this.classRepo.save(cls);
  }

  async findByTeacher(teacherId: string) {
    return this.classRepo.find({ where: { teacherId, isActive: true }, order: { createdAt: 'DESC' } });
  }

  async findByStudent(userId: string) {
    const memberships = await this.memberRepo.find({ where: { userId } });
    const classIds = memberships.map(m => m.classId);
    if (!classIds.length) return [];
    return this.classRepo.findByIds(classIds);
  }

  async findById(id: string): Promise<ClassEntity> {
    const cls = await this.classRepo.findOne({ where: { id } });
    if (!cls) throw new NotFoundException('Class not found');
    return cls;
  }

  async joinByCode(userId: string, code: string): Promise<ClassMemberEntity> {
    const cls = await this.classRepo.findOne({ where: { joinCode: code.toUpperCase(), isActive: true } });
    if (!cls) throw new NotFoundException('Invalid join code');

    const existing = await this.memberRepo.findOne({ where: { classId: cls.id, userId } });
    if (existing) throw new ConflictException('Already a member of this class');

    const member = this.memberRepo.create({ classId: cls.id, userId });
    await this.memberRepo.save(member);
    await this.classRepo.increment({ id: cls.id }, 'studentCount', 1);
    return member;
  }

  async getMembers(classId: string) {
    return this.memberRepo.find({ where: { classId } });
  }

  async removeStudent(classId: string, userId: string): Promise<void> {
    const member = await this.memberRepo.findOne({ where: { classId, userId } });
    if (!member) throw new NotFoundException('Student not in this class');
    await this.memberRepo.remove(member);
    await this.classRepo.decrement({ id: classId }, 'studentCount', 1);
  }
}
