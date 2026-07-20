import { Module } from '@nestjs/common';
import { ActivitiesService } from './activity.service';
import { ApproverResolverModule } from './approver-resolver.module';
import { NotificationModule } from '../notification/notification.module';
import { RealtimeModule } from '../realtime/realtime.module';
import { CashModule } from '../cash/cash.module';

/**
 * Activity module for managing church activities.
 *
 * This module imports NotificationModule to send notifications
 * when activities are created.
 *
 * **Validates: Requirements 8.3**
 */
@Module({
  imports: [
    NotificationModule,
    RealtimeModule,
    CashModule,
    ApproverResolverModule,
  ],
  providers: [ActivitiesService],
})
export class ActivitiesModule {}
