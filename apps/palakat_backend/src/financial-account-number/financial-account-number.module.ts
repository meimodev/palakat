import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma.module';
import { FinancialAccountNumberController } from './financial-account-number.controller';
import { FinancialAccountNumberService } from './financial-account-number.service';

@Module({
  imports: [PrismaModule],
  controllers: [FinancialAccountNumberController],
  providers: [FinancialAccountNumberService],
  exports: [FinancialAccountNumberService],
})
export class FinancialAccountNumberModule {}
