import { Module } from '@nestjs/common';
import { RealtimeModule } from '../realtime/realtime.module';
import { RevenueService } from './revenue.service';

@Module({
  imports: [RealtimeModule],
  providers: [RevenueService],
})
export class RevenueModule {}
