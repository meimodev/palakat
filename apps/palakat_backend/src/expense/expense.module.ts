import { Module } from '@nestjs/common';
import { ExpenseService } from './expense.service';

@Module({
  providers: [ExpenseService],
})
export class ExpenseModule {}
