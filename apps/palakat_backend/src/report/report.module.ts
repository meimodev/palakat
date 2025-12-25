import { Module } from '@nestjs/common';
import { ReportService } from './report.service';
import { ReportQueueService } from './report-queue.service';
import { ReportController } from './report.controller';
import { NotificationModule } from '../notification/notification.module';

@Module({
  imports: [NotificationModule],
  controllers: [ReportController],
  providers: [ReportService, ReportQueueService],
  exports: [ReportService, ReportQueueService],
})
export class ReportModule {}
