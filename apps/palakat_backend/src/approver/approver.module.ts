import { Module } from '@nestjs/common';
import { ApproverService } from './approver.service';
import { NotificationModule } from '../notification/notification.module';

@Module({
  imports: [NotificationModule],
  providers: [ApproverService],
})
export class ApproverModule {}
