import { Module } from '@nestjs/common';
import { ReportService } from './report.service';
import { ReportQueueService } from './report-queue.service';
import { NotificationModule } from '../notification/notification.module';
import { RealtimeModule } from '../realtime/realtime.module';

@Module({
  imports: [NotificationModule, RealtimeModule],
  providers: [ReportService, ReportQueueService],
  exports: [ReportService, ReportQueueService],
})
export class ReportModule {}
