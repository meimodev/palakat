import { ActivityType, FinancialType } from '../../generated/prisma/client';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';

class ApprovalRulePositionDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  id: number;
}

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

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ApprovalRulePositionDto)
  positions?: ApprovalRulePositionDto[];
}
