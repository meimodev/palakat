import { ApprovalStatus } from '@prisma/client';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, Min } from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export class ApproverListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  membershipId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  activityId?: number;

  @IsOptional()
  @IsEnum(ApprovalStatus)
  status?: ApprovalStatus;
}
