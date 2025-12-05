import { ApprovalStatus } from '@prisma/client';
import { IsEnum } from 'class-validator';

export class UpdateApproverDto {
  @IsEnum(ApprovalStatus)
  status: ApprovalStatus;
}
