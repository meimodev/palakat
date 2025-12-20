import { Module } from '@nestjs/common';
import { ChurchRequestController } from './church-request.controller';
import { ChurchRequestService } from './church-request.service';
import { NotificationModule } from '../notification/notification.module';
import { ChurchRequestAdminController } from './church-request-admin.controller';

@Module({
  imports: [NotificationModule],
  controllers: [ChurchRequestController, ChurchRequestAdminController],
  providers: [ChurchRequestService],
})
export class ChurchRequestModule {}
