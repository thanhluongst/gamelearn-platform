import {
  Controller, Get, Post, Put, Delete, Body, Param,
  UseGuards, Query, ParseUUIDPipe, Request,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminService } from './admin.service';

@Controller('admin')
@UseGuards(JwtAuthGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('stats')
  getPlatformStats() {
    return this.adminService.getPlatformStats();
  }

  @Get('users')
  listUsers(
    @Query('role') role: string,
    @Query('schoolId') schoolId: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
    @Query('search') search: string,
  ) {
    return this.adminService.listUsers({ role, schoolId, page: +page, limit: +limit, search });
  }

  @Post('users')
  createUser(@Body() dto: any) {
    return this.adminService.createUser(dto);
  }

  @Put('users/:id')
  updateUser(@Param('id', ParseUUIDPipe) id: string, @Body() dto: any) {
    return this.adminService.updateUser(id, dto);
  }

  @Delete('users/:id')
  deleteUser(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminService.deleteUser(id);
  }

  @Get('schools')
  listSchools(@Query('page') page = 1, @Query('limit') limit = 20) {
    return this.adminService.listSchools(+page, +limit);
  }

  @Post('schools')
  createSchool(@Body() dto: any) {
    return this.adminService.createSchool(dto);
  }

  @Put('schools/:id')
  updateSchool(@Param('id', ParseUUIDPipe) id: string, @Body() dto: any) {
    return this.adminService.updateSchool(id, dto);
  }
}
