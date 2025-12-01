import { ActivityType, FinancialType } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateApprovalRuleDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsBoolean()
  active?: boolean;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  churchId: number;

  @IsOptional()
  @IsEnum(ActivityType)
  activityType?: ActivityType;

  @IsOptional()
  @IsEnum(FinancialType)
  financialType?: FinancialType;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  financialAccountNumberId?: number;

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  positionIds?: number[];
}
