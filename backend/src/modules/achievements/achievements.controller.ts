import { Controller, Get, Param, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AchievementsService } from './achievements.service';

@Controller('achievements')
@UseGuards(JwtAuthGuard)
export class AchievementsController {
  constructor(private readonly achievementsService: AchievementsService) {}

  @Get()
  getAllAchievements() {
    return this.achievementsService.getAllAchievements();
  }

  @Get('me')
  getMyAchievements(@Request() req: any) {
    return this.achievementsService.getUserAchievements(req.user.sub);
  }

  @Get('user/:id')
  getUserAchievements(@Param('id', ParseUUIDPipe) id: string) {
    return this.achievementsService.getUserAchievements(id);
  }
}
