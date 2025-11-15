import { IsEnum, IsOptional, IsString } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';
import { GeneratedBy } from '@prisma/client';

export class ReportListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Type(() => Number)
  churchId?: number;

  @IsOptional()
  @IsEnum(GeneratedBy)
  generatedBy?: GeneratedBy;
}
