import { Controller, Get, Param, Query, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { StatisticsService } from './statistics.service';

@Controller('statistics')
@UseGuards(JwtAuthGuard)
export class StatisticsController {
  constructor(private readonly statisticsService: StatisticsService) {}

  @Get('me')
  getMyStats(@Request() req: any) {
    return this.statisticsService.getUserStats(req.user.sub);
  }

  @Get('user/:id')
  getUserStats(@Param('id', ParseUUIDPipe) id: string) {
    return this.statisticsService.getUserStats(id);
  }

  @Get('user/:id/chart')
  getUserChart(
    @Param('id', ParseUUIDPipe) id: string,
    @Query('period') period: 'week' | 'month' | 'year' = 'week',
  ) {
    return this.statisticsService.getDailyChart(id, period);
  }

  @Get('class/:classId')
  getClassStats(@Param('classId', ParseUUIDPipe) classId: string) {
    return this.statisticsService.getClassStats(classId);
  }
}
