import { Module } from '@nestjs/common';
import { ActivitiesService } from './activity.service';
import { ActivitiesController } from './activity.controller';
import { ApproverResolverService } from './approver-resolver.service';
import { NotificationModule } from '../notification/notification.module';

/**
 * Activity module for managing church activities.
 *
 * This module imports NotificationModule to send notifications
 * when activities are created.
 *
 * **Validates: Requirements 8.3**
 */
@Module({
  imports: [NotificationModule],
  controllers: [ActivitiesController],
  providers: [ActivitiesService, ApproverResolverService],
})
export class ActivitiesModule {}
