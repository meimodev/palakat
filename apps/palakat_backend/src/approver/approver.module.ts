import { Module, forwardRef } from '@nestjs/common';
import { ApproverService } from './approver.service';
import { PrismaModule } from '../prisma.module';
import { NotificationModule } from '../notification/notification.module';

@Module({
  imports: [PrismaModule, forwardRef(() => NotificationModule)],
  providers: [ApproverService],
  exports: [ApproverService],
})
export class ApproverModule {}
