import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { UserEntity } from '../users/entities/user.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.userRepo.findOne({
      where: [{ email: dto.email }, { username: dto.username }],
    });
    if (existing) {
      throw new ConflictException('Email hoặc username đã tồn tại');
    }

    const passwordHash = await bcrypt.hash(dto.password, 12);
    const user = this.userRepo.create({
      ...dto,
      passwordHash,
      role: dto.role || 'student',
    });
    await this.userRepo.save(user);

    return this.generateTokens(user);
  }

  async login(dto: LoginDto) {
    const user = await this.userRepo.findOne({
      where: [{ email: dto.identifier }, { username: dto.identifier }],
      select: ['id', 'passwordHash', 'role', 'status', 'fullName', 'username', 'email', 'avatarUrl', 'xpTotal', 'level', 'coins'],
    });

    if (!user || !(await bcrypt.compare(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('Sai tên đăng nhập hoặc mật khẩu');
    }
    if (user.status === 'suspended') {
      throw new UnauthorizedException('Tài khoản đã bị khóa');
    }

    user.lastLoginAt = new Date();
    await this.userRepo.save(user);

    return this.generateTokens(user);
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.config.get('app.jwtRefreshSecret'),
      });
      const user = await this.userRepo.findOne({ where: { id: payload.sub } });
      if (!user) throw new UnauthorizedException();

      const valid = await bcrypt.compare(refreshToken, user.refreshTokenHash || '');
      if (!valid) throw new UnauthorizedException('Token không hợp lệ');

      return this.generateTokens(user);
    } catch {
      throw new UnauthorizedException('Token hết hạn hoặc không hợp lệ');
    }
  }

  async logout(userId: string) {
    await this.userRepo.update(userId, { refreshTokenHash: null });
    return { message: 'Đăng xuất thành công' };
  }

  async validateUser(userId: string) {
    return this.userRepo.findOne({
      where: { id: userId, status: 'active' },
      relations: ['school'],
    });
  }

  private async generateTokens(user: UserEntity) {
    const payload = { sub: user.id, role: user.role, username: user.username };

    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, {
      secret: this.config.get('app.jwtRefreshSecret'),
      expiresIn: this.config.get('app.jwtRefreshExpiry'),
    });

    const refreshTokenHash = await bcrypt.hash(refreshToken, 10);
    await this.userRepo.update(user.id, { refreshTokenHash });

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        avatarUrl: user.avatarUrl,
        level: user.level,
        xpTotal: user.xpTotal,
        coins: user.coins,
      },
    };
  }
}
