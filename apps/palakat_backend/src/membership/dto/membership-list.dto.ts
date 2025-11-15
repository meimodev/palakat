import { IsOptional, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export class MembershipListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  churchId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  columnId?: number;
}
