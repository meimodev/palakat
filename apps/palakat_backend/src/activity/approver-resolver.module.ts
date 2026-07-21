import { Module } from '@nestjs/common';
import { ApproverResolverService } from './approver-resolver.service';

/**
 * Owns approver resolution against ApprovalRule → memberships. Shared by the
 * activity flow (activityType/bipra matching) and the finance flow
 * (financialType matching); both go through ApproverResolverService.
 * PrismaService comes from the global PrismaModule.
 */
@Module({
  providers: [ApproverResolverService],
  exports: [ApproverResolverService],
})
export class ApproverResolverModule {}
