import { Module } from '@nestjs/common';
import { ApprovalRuleService } from './approval-rule.service';

@Module({
  providers: [ApprovalRuleService],
})
export class ApprovalRuleModule {}
