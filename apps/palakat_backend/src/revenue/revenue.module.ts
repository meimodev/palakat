import { Module } from '@nestjs/common';
import { RevenueService } from './revenue.service';

@Module({
  providers: [RevenueService],
})
export class RevenueModule {}
