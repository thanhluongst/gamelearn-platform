import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SchoolEntity } from './entities/school.entity';

@Injectable()
export class SchoolsService {
  constructor(
    @InjectRepository(SchoolEntity) private readonly schoolRepo: Repository<SchoolEntity>,
  ) {}

  async findAll(page = 1, limit = 20) {
    const [data, total] = await this.schoolRepo.findAndCount({
      where: { isActive: true },
      order: { name: 'ASC' },
      skip: (page - 1) * limit,
      take: limit,
    });
    return { data, total, page, limit };
  }

  async findById(id: string): Promise<SchoolEntity> {
    const school = await this.schoolRepo.findOne({ where: { id } });
    if (!school) throw new NotFoundException('School not found');
    return school;
  }

  async create(dto: Partial<SchoolEntity>): Promise<SchoolEntity> {
    const existing = await this.schoolRepo.findOne({ where: { code: dto.code } });
    if (existing) throw new ConflictException('School code already exists');
    const school = this.schoolRepo.create(dto);
    return this.schoolRepo.save(school);
  }

  async update(id: string, dto: Partial<SchoolEntity>): Promise<SchoolEntity> {
    await this.findById(id);
    await this.schoolRepo.update(id, dto);
    return this.findById(id);
  }
}
