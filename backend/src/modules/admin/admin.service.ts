import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like, ILike } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { UserEntity } from '../users/entities/user.entity';
import { SchoolEntity } from '../schools/entities/school.entity';
import { GameSessionEntity } from '../games/entities/game-session.entity';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(UserEntity) private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(SchoolEntity) private readonly schoolRepo: Repository<SchoolEntity>,
    @InjectRepository(GameSessionEntity) private readonly sessionRepo: Repository<GameSessionEntity>,
  ) {}

  async getPlatformStats() {
    const [totalUsers, totalSchools, totalGames] = await Promise.all([
      this.userRepo.count(),
      this.schoolRepo.count(),
      this.sessionRepo.count(),
    ]);

    const roleStats = await this.userRepo
      .createQueryBuilder('u')
      .select('u.role, COUNT(*) as count')
      .groupBy('u.role')
      .getRawMany();

    return { totalUsers, totalSchools, totalGames, roleStats };
  }

  async listUsers(filters: { role?: string; schoolId?: string; page: number; limit: number; search?: string }) {
    const { role, schoolId, page, limit, search } = filters;
    const where: any = {};
    if (role) where.role = role;
    if (schoolId) where.schoolId = schoolId;
    if (search) where.fullName = ILike(`%${search}%`);

    const [data, total] = await this.userRepo.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });
    return { data, total, page, limit };
  }

  async createUser(dto: any) {
    const passwordHash = await bcrypt.hash(dto.password || 'Abc@12345', 10);
    const user = this.userRepo.create({ ...dto, passwordHash });
    const { passwordHash: _, ...result } = await this.userRepo.save(user) as any;
    return result;
  }

  async updateUser(id: string, dto: any) {
    if (dto.password) {
      dto.passwordHash = await bcrypt.hash(dto.password, 10);
      delete dto.password;
    }
    await this.userRepo.update(id, dto);
    return this.userRepo.findOne({ where: { id } });
  }

  async deleteUser(id: string) {
    await this.userRepo.update(id, { status: 'inactive' });
    return { success: true };
  }

  async listSchools(page: number, limit: number) {
    const [data, total] = await this.schoolRepo.findAndCount({
      order: { name: 'ASC' },
      skip: (page - 1) * limit,
      take: limit,
    });
    return { data, total, page, limit };
  }

  async createSchool(dto: any) {
    const school = this.schoolRepo.create(dto);
    return this.schoolRepo.save(school);
  }

  async updateSchool(id: string, dto: any) {
    await this.schoolRepo.update(id, dto);
    return this.schoolRepo.findOne({ where: { id } });
  }
}
