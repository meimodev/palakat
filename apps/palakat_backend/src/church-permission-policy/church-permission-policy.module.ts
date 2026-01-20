import { Module } from '@nestjs/common';
import { ChurchPermissionPolicyService } from './church-permission-policy.service';

@Module({
  providers: [ChurchPermissionPolicyService],
  exports: [ChurchPermissionPolicyService],
})
export class ChurchPermissionPolicyModule {}
