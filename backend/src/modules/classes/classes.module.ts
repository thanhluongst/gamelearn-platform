import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ClassesService } from './classes.service';
import { ClassesController } from './classes.controller';
import { ClassEntity } from './entities/class.entity';
import { ClassMemberEntity } from './entities/class-member.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ClassEntity, ClassMemberEntity])],
  controllers: [ClassesController],
  providers: [ClassesService],
  exports: [ClassesService],
})
export class ClassesModule {}
