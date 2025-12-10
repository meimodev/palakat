import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from '../prisma.module';
import { PusherBeamsService } from './pusher-beams.service';
import { NotificationService } from './notification.service';
import { NotificationController } from './notification.controller';

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
  imports: [ConfigModule, PrismaModule],
  controllers: [NotificationController],
  providers: [PusherBeamsService, NotificationService],
  exports: [PusherBeamsService, NotificationService],
})
export class NotificationModule {}
