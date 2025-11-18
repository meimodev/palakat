import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, ValidateIf } from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export class ChurchRequestListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Type(() => Number)
  @ValidateIf((o) => o.requesterId !== undefined && o.requesterId !== null)
  @IsInt()
  requesterId?: number;
}
