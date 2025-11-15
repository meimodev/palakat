import { IsOptional, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export class ColumnListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  churchId?: number;
}
