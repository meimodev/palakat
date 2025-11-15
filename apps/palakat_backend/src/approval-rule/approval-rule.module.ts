import { Module } from '@nestjs/common';
import { ApprovalRuleService } from './approval-rule.service';
import { ApprovalRuleController } from './approval-rule.controller';

@Module({
  controllers: [ApprovalRuleController],
  providers: [ApprovalRuleService],
})
export class ApprovalRuleModule {}
