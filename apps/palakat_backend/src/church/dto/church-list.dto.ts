import { IsOptional, IsString } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export class ChurchListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Type(() => Number)
  latitude?: number;

  @IsOptional()
  @Type(() => Number)
  longitude?: number;
}
