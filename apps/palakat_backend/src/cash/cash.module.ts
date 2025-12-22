import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma.module';
import { CashAccountController } from './cash-account.controller';
import { CashAccountService } from './cash-account.service';
import { CashMutationController } from './cash-mutation.controller';
import { CashMutationService } from './cash-mutation.service';

@Module({
  imports: [PrismaModule],
  controllers: [CashAccountController, CashMutationController],
  providers: [CashAccountService, CashMutationService],
})
export class CashModule {}
