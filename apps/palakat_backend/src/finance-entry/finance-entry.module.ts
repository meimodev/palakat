import { Module } from '@nestjs/common';
import { CashModule } from '../cash/cash.module';
import { RealtimeModule } from '../realtime/realtime.module';
import { FinanceEntryService } from './finance-entry.service';

@Module({
  imports: [RealtimeModule, CashModule],
  providers: [FinanceEntryService],
  exports: [FinanceEntryService],
})
export class FinanceEntryModule {}
