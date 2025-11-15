import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, IsString, Min } from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export class ApprovalRuleListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  churchId?: number;

  @IsOptional()
  @IsIn(['true', 'false'])
  active?: string;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  positionId?: number;
}
