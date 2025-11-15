import { IsInt, IsOptional, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export class MembershipPositionListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  churchId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  membershipId?: number;
}
