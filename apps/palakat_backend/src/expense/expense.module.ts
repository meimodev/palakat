import { Module } from '@nestjs/common';
import { CashModule } from '../cash/cash.module';
import { RealtimeModule } from '../realtime/realtime.module';
import { ExpenseService } from './expense.service';

@Module({
  imports: [RealtimeModule, CashModule],
  providers: [ExpenseService],
  exports: [ExpenseService],
})
export class ExpenseModule {}
