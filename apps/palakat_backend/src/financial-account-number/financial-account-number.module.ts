import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma.module';
import { FinancialAccountNumberService } from './financial-account-number.service';

@Module({
  imports: [PrismaModule],
  providers: [FinancialAccountNumberService],
  exports: [FinancialAccountNumberService],
})
export class FinancialAccountNumberModule {}
