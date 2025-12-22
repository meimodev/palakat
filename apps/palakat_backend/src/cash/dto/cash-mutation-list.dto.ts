import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, Min } from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';
import { CashMutationType } from '../../generated/prisma/client';
import {
  TransformToEndOfDayUtc,
  TransformToStartOfDayUtc,
} from '../../../common/transformers/utc-date.transformer';

export class CashMutationListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  churchId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  accountId?: number;

  @IsOptional()
  @IsEnum(CashMutationType)
  type?: CashMutationType;

  @IsOptional()
  @TransformToStartOfDayUtc()
  startDate?: Date;

  @IsOptional()
  @TransformToEndOfDayUtc()
  endDate?: Date;

  @IsOptional()
  @IsString()
  search?: string;
}
