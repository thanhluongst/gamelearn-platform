import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { UserEntity } from '../users/entities/user.entity';
import { SchoolEntity } from '../schools/entities/school.entity';
import { GameSessionEntity } from '../games/entities/game-session.entity';

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity, SchoolEntity, GameSessionEntity])],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
