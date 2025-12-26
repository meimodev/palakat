import { Module } from '@nestjs/common';
import { ChurchRequestService } from './church-request.service';
import { NotificationModule } from '../notification/notification.module';

@Module({
  imports: [NotificationModule],
  providers: [ChurchRequestService],
})
export class ChurchRequestModule {}
