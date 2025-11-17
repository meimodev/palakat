import { BadRequestException } from '@nestjs/common';
import { ActivityType } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  ValidateIf,
} from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

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
  @Type(() => Date)
  startDate?: Date;

  @IsOptional()
  @Type(() => Date)
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
