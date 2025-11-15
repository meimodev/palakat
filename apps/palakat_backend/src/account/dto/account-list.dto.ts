import { IsOptional, IsNumber, IsString } from 'class-validator';
import { PaginationQueryDto } from 'common/pagination/pagination.dto';

export class AccountListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsNumber()
  churchId?: number;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @IsString()
  position?: string;
}
