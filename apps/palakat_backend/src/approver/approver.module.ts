import { Module } from '@nestjs/common';
import { ApproverController } from './approver.controller';
import { ApproverService } from './approver.service';

@Module({
  controllers: [ApproverController],
  providers: [ApproverService],
})
export class ApproverModule {}
