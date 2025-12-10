import { Module } from '@nestjs/common';
import { ApproverController } from './approver.controller';
import { ApproverService } from './approver.service';
import { NotificationModule } from '../notification/notification.module';

@Module({
  imports: [NotificationModule],
  controllers: [ApproverController],
  providers: [ApproverService],
})
export class ApproverModule {}
