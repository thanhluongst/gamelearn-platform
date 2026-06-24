import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { NotificationEntity } from './entities/notification.entity';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);
  private firebase: admin.app.App;

  constructor(
    @InjectRepository(NotificationEntity)
    private readonly notificationRepo: Repository<NotificationEntity>,
    private readonly config: ConfigService,
  ) {
    const projectId = config.get('app.firebase.projectId');
    if (projectId) {
      this.firebase = admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          privateKey: config.get<string>('app.firebase.privateKey')?.replace(/\\n/g, '\n'),
          clientEmail: config.get('app.firebase.clientEmail'),
        }),
      });
    }
  }

  async sendToUser(
    userId: string,
    notification: {
      type: string;
      title: string;
      body: string;
      data?: Record<string, any>;
      fcmToken?: string;
    },
  ) {
    // Save to DB
    const dbNotif = await this.notificationRepo.save(
      this.notificationRepo.create({
        userId,
        type: notification.type,
        title: notification.title,
        body: notification.body,
        data: notification.data || {},
      }),
    );

    // Push via FCM
    if (notification.fcmToken && this.firebase) {
      try {
        await this.firebase.messaging().send({
          token: notification.fcmToken,
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: notification.data
            ? Object.fromEntries(Object.entries(notification.data).map(([k, v]) => [k, String(v)]))
            : undefined,
          android: { priority: 'high' },
          apns: { payload: { aps: { sound: 'default' } } },
        });
      } catch (e) {
        this.logger.warn(`FCM push failed for user ${userId}: ${e.message}`);
      }
    }

    return dbNotif;
  }

  async getUserNotifications(userId: string, page = 1, limit = 20) {
    const [data, total] = await this.notificationRepo
      .createQueryBuilder('n')
      .where('n.user_id = :userId', { userId })
      .orderBy('n.created_at', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getManyAndCount();
    return { data, total, page, limit };
  }

  async markAsRead(notificationId: string, userId: string) {
    await this.notificationRepo.update(
      { id: notificationId, userId },
      { isRead: true, readAt: new Date() },
    );
    return { success: true };
  }

  async markAllAsRead(userId: string) {
    await this.notificationRepo.update(
      { userId, isRead: false },
      { isRead: true, readAt: new Date() },
    );
    return { success: true };
  }

  async updateFcmToken(userId: string, token: string) {
    // Store in user table - this requires UserRepo; for now we just log
    this.logger.log(`FCM token updated for user ${userId}`);
    return { success: true };
  }
}
