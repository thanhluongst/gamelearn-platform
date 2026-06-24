import {
  Controller, Get, Post, Put, Body, Param, Query,
  UseGuards, Request, ParseUUIDPipe,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GamesService } from './games.service';
import { CreateGameSessionDto } from './dto/create-game-session.dto';

@Controller('game-sessions')
@UseGuards(JwtAuthGuard)
export class GamesController {
  constructor(private readonly gamesService: GamesService) {}

  @Post()
  create(@Request() req: any, @Body() dto: CreateGameSessionDto) {
    return this.gamesService.createSession(req.user.sub, dto);
  }

  @Get()
  findAll(
    @Request() req: any,
    @Query('status') status: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    return this.gamesService.findSessions(req.user.sub, { status, page: +page, limit: +limit });
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.gamesService.findSessionById(id);
  }

  @Put(':id/start')
  startSession(@Request() req: any, @Param('id', ParseUUIDPipe) id: string) {
    return this.gamesService.startSession(id, req.user.sub);
  }

  @Put(':id/end')
  endSession(@Request() req: any, @Param('id', ParseUUIDPipe) id: string) {
    return this.gamesService.endSession(id, req.user.sub);
  }

  @Get(':id/results')
  getResults(@Param('id', ParseUUIDPipe) id: string) {
    return this.gamesService.getSessionResults(id);
  }

  @Get(':id/leaderboard')
  getLeaderboard(@Param('id', ParseUUIDPipe) id: string) {
    return this.gamesService.getSessionLeaderboard(id);
  }
}
