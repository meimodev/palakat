import { Module, forwardRef } from '@nestjs/common';
import { ApproverService } from './approver.service';
import { PrismaModule } from '../prisma.module';
import { NotificationModule } from '../notification/notification.module';
import { DocumentModule } from '../document/document.module';

@Module({
  imports: [PrismaModule, DocumentModule, forwardRef(() => NotificationModule)],
  providers: [ApproverService],
  exports: [ApproverService],
})
export class ApproverModule {}
