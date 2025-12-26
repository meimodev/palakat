import { Module } from '@nestjs/common';
import { AccountService } from './account.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  providers: [AccountService],
})
export class AccountModule {}
