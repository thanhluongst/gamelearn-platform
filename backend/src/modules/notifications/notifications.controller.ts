import { Controller, Get, Put, Param, Body, UseGuards, Request, ParseUUIDPipe, Query } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { NotificationService } from './notification.service';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notificationService: NotificationService) {}

  @Get()
  getMyNotifications(
    @Request() req: any,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    return this.notificationService.getUserNotifications(req.user.sub, +page, +limit);
  }

  @Put(':id/read')
  markRead(@Param('id', ParseUUIDPipe) id: string, @Request() req: any) {
    return this.notificationService.markAsRead(id, req.user.sub);
  }

  @Put('read-all')
  markAllRead(@Request() req: any) {
    return this.notificationService.markAllAsRead(req.user.sub);
  }

  @Put('fcm-token')
  updateFcmToken(@Request() req: any, @Body('token') token: string) {
    return this.notificationService.updateFcmToken(req.user.sub, token);
  }
}
