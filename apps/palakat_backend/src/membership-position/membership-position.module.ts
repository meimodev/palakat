import { Module } from '@nestjs/common';
import { MembershipPositionService } from './membership-position.service';

@Module({
  providers: [MembershipPositionService],
})
export class MembershipPositionModule {}
