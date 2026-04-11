import { Module } from '@nestjs/common';
import { RealtimeModule } from '../realtime/realtime.module';
import { ExpenseService } from './expense.service';

@Module({
  imports: [RealtimeModule],
  providers: [ExpenseService],
})
export class ExpenseModule {}
