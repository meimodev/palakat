import { FinancialType } from '@prisma/client';
import { IsEnum, IsInt, IsOptional } from 'class-validator';
import { Transform } from 'class-transformer';

export class FindAvailableFinancialAccountNumberDto {
  @IsOptional()
  @IsEnum(FinancialType)
  type?: FinancialType;

  @IsOptional()
  @Transform(({ value }) => (value ? parseInt(value, 10) : undefined))
  @IsInt()
  currentRuleId?: number;
}
