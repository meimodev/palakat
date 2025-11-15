import { Module } from '@nestjs/common';
import { MembershipPositionService } from './membership-position.service';
import { MembershipPositionController } from './membership-position.controller';

@Module({
  controllers: [MembershipPositionController],
  providers: [MembershipPositionService],
})
export class MembershipPositionModule {}
