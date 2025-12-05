import { BadRequestException } from '@nestjs/common';
import { ActivityType } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  ValidateIf,
} from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';
import {
  TransformToStartOfDayUtc,
  TransformToEndOfDayUtc,
} from '../../../common/transformers/utc-date.transformer';

export type ActivitySortField = 'id' | 'date';

export class ActivityListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @ValidateIf((o) => o.membershipId !== undefined && o.membershipId !== null)
  @IsInt()
  membershipId?: number;

  @IsOptional()
  @Type(() => Number)
  @ValidateIf((o) => o.churchId !== undefined && o.churchId !== null)
  @IsInt()
  churchId?: number;

  @IsOptional()
  @Type(() => Number)
  @ValidateIf((o) => o.columnId !== undefined && o.columnId !== null)
  @IsInt()
  columnId?: number;

  @IsOptional()
  @TransformToStartOfDayUtc()
  startDate?: Date;

  @IsOptional()
  @TransformToEndOfDayUtc()
  endDate?: Date;

  @IsOptional()
  @ValidateIf(
    (o) =>
      o.activityType !== undefined &&
      o.activityType !== null &&
      o.activityType !== '',
  )
  @IsEnum(ActivityType)
  activityType?: ActivityType;

  @IsOptional()
  @IsString()
  search?: string;

  // Override to restrict sortBy to valid activity fields
  @IsOptional()
  @IsIn(['id', 'date'])
  declare sortBy?: ActivitySortField;

  @IsOptional()
  @Transform(({ value }) => {
    if (value === 'true') return true;
    if (value === 'false') return false;
    return value;
  })
  @IsBoolean()
  hasExpense?: boolean;

  @IsOptional()
  @Transform(({ value }) => {
    if (value === 'true') return true;
    if (value === 'false') return false;
    return value;
  })
  @IsBoolean()
  hasRevenue?: boolean;

  @ValidateIf((o) => {
    if (o.startDate && o.endDate && o.startDate > o.endDate) {
      throw new BadRequestException(
        'startDate must be before or equal to endDate',
      );
    }
    return false;
  })
  _validateDateRange?: never;
}
