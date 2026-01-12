import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from '../prisma.module';
import { RealtimeModule } from '../realtime/realtime.module';
import { PusherBeamsService } from './pusher-beams.service';
import { BirthdayNotificationService } from './birthday-notification.service';
import { NotificationService } from './notification.service';

/**
 * Notification module for handling push notifications via Pusher Beams.
 *
 * This module provides:
 * - PusherBeamsService for sending push notifications
 * - NotificationService for CRUD operations on notification records
 * - NotificationController for REST API endpoints
 *
 * **Validates: Requirements 8.1**
 */
@Module({
  imports: [ConfigModule, PrismaModule, RealtimeModule],
  providers: [
    PusherBeamsService,
    NotificationService,
    BirthdayNotificationService,
  ],
  exports: [PusherBeamsService, NotificationService],
})
export class NotificationModule {}
