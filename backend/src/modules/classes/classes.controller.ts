import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ClassesService } from './classes.service';

@Controller('classes')
@UseGuards(JwtAuthGuard)
export class ClassesController {
  constructor(private readonly classesService: ClassesService) {}

  @Post()
  create(@Request() req: any, @Body() dto: any) {
    return this.classesService.create(req.user.sub, dto);
  }

  @Get('teacher')
  getMyClasses(@Request() req: any) {
    return this.classesService.findByTeacher(req.user.sub);
  }

  @Get('student')
  getJoinedClasses(@Request() req: any) {
    return this.classesService.findByStudent(req.user.sub);
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.classesService.findById(id);
  }

  @Post('join')
  joinClass(@Request() req: any, @Body('code') code: string) {
    return this.classesService.joinByCode(req.user.sub, code);
  }

  @Get(':id/members')
  getMembers(@Param('id', ParseUUIDPipe) id: string) {
    return this.classesService.getMembers(id);
  }

  @Delete(':id/members/:userId')
  removeMember(
    @Param('id', ParseUUIDPipe) classId: string,
    @Param('userId', ParseUUIDPipe) userId: string,
  ) {
    return this.classesService.removeStudent(classId, userId);
  }
}
