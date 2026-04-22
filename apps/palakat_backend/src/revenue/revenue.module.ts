import { Module } from '@nestjs/common';
import { CashModule } from '../cash/cash.module';
import { RealtimeModule } from '../realtime/realtime.module';
import { RevenueService } from './revenue.service';

@Module({
  imports: [RealtimeModule, CashModule],
  providers: [RevenueService],
  exports: [RevenueService],
})
export class RevenueModule {}
