import { Module } from '@nestjs/common';
import { RealtimeModule } from '../realtime/realtime.module';
import { FinanceService } from './finance.service';

@Module({
  imports: [RealtimeModule],
  providers: [FinanceService],
})
export class FinanceModule {}
