import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma.module';
import { CashAccountService } from './cash-account.service';
import { CashMutationService } from './cash-mutation.service';

@Module({
  imports: [PrismaModule],
  providers: [CashAccountService, CashMutationService],
})
export class CashModule {}
