import { Controller, Get, Query, Param, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { LeaderboardService } from './leaderboard.service';

@Controller('leaderboard')
@UseGuards(JwtAuthGuard)
export class LeaderboardController {
  constructor(private readonly leaderboardService: LeaderboardService) {}

  @Get()
  getLeaderboard(
    @Query('scope') scope: 'class' | 'school' | 'global' = 'global',
    @Query('scopeId') scopeId: string,
    @Query('period') period: 'daily' | 'weekly' | 'monthly' | 'all_time' = 'all_time',
    @Query('page') page = 1,
    @Query('limit') limit = 50,
  ) {
    return this.leaderboardService.getLeaderboard({ scope, scopeId, period, page: +page, limit: +limit });
  }

  @Get('me')
  getMyRank(
    @Request() req: any,
    @Query('scope') scope = 'global',
    @Query('scopeId') scopeId: string,
    @Query('period') period = 'all_time',
  ) {
    return this.leaderboardService.getUserRank(req.user.sub, scope, scopeId, period);
  }
}
