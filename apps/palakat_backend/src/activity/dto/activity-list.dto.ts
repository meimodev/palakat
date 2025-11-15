import { Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Min,
  ValidateIf,
} from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';
import { BadRequestException } from '@nestjs/common';
import { ActivityType } from '@prisma/client';

export class ActivityListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  membershipId?: number;

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

  @IsOptional()
  @Type(() => Date)
  startDate?: Date;

  @IsOptional()
  @Type(() => Date)
  endDate?: Date;

  @IsOptional()
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
