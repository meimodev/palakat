import { IsBoolean, IsEnum, IsOptional, IsString } from 'class-validator';
import { Transform, Type } from 'class-transformer';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';
import { GeneratedBy } from '../../generated/prisma/client';

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

  @IsOptional()
  @Type(() => Number)
  createdById?: number;

  @IsOptional()
  @IsBoolean()
  @Transform(({ value }) => value === 'true' || value === true)
  mine?: boolean;
}
