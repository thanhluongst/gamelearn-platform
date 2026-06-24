import { Controller, Get, Post, Param, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { MissionsService } from './missions.service';

@Controller('missions')
@UseGuards(JwtAuthGuard)
export class MissionsController {
  constructor(private readonly missionsService: MissionsService) {}

  @Get()
  getMyMissions(@Request() req: any) {
    return this.missionsService.getUserMissions(req.user.sub);
  }

  @Post(':id/claim')
  claimMission(@Request() req: any, @Param('id', ParseUUIDPipe) id: string) {
    return this.missionsService.claimMission(req.user.sub, id);
  }
}
