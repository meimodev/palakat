import { Module } from '@nestjs/common';
import { CashModule } from '../cash/cash.module';
import { RealtimeModule } from '../realtime/realtime.module';
import { ApproverResolverModule } from '../activity/approver-resolver.module';
import { FinanceEntryService } from './finance-entry.service';

@Module({
  imports: [RealtimeModule, CashModule, ApproverResolverModule],
  providers: [FinanceEntryService],
  exports: [FinanceEntryService],
})
export class FinanceEntryModule {}
