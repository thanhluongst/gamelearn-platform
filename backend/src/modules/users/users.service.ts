import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from './entities/user.entity';
import { XpLogEntity } from './entities/xp-log.entity';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity) private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(XpLogEntity) private readonly xpLogRepo: Repository<XpLogEntity>,
  ) {}

  async findById(id: string): Promise<UserEntity> {
    const user = await this.userRepo.findOne({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async findByUsername(username: string): Promise<UserEntity | null> {
    return this.userRepo.findOne({ where: { username } });
  }

  async findByEmail(email: string): Promise<UserEntity | null> {
    return this.userRepo.findOne({ where: { email } });
  }

  async updateProfile(id: string, dto: UpdateProfileDto): Promise<UserEntity> {
    const update: Partial<UserEntity> = {};
    if (dto.displayName) update.fullName = dto.displayName;
    if (dto.avatarUrl) update.avatarUrl = dto.avatarUrl;
    await this.userRepo.update(id, update);
    return this.findById(id);
  }

  async getPublicProfile(id: string) {
    const user = await this.findById(id);
    const { passwordHash, refreshTokenHash, ...safe } = user as any;
    return safe;
  }

  async addXp(userId: string, xp: number, reason: string): Promise<void> {
    await this.userRepo.increment({ id: userId }, 'xpTotal', xp);
    const log = this.xpLogRepo.create({ userId, xpAmount: xp, source: reason });
    await this.xpLogRepo.save(log);
  }

  async updateLastLogin(userId: string): Promise<void> {
    await this.userRepo.update(userId, { lastLoginAt: new Date() });
  }
}
