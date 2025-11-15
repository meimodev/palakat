import { Module } from '@nestjs/common';
import { RevenueService } from './revenue.service';
import { RevenueController } from './revenue.controller';

@Module({
  controllers: [RevenueController],
  providers: [RevenueService],
})
export class RevenueModule {}
