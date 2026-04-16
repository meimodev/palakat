import { FinancialType } from '../../generated/prisma/client';
import {
  IsBoolean,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateFinancialAccountNumberDto {
  @IsString()
  @IsNotEmpty()
  accountNumber: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsEnum(FinancialType)
  @IsNotEmpty()
  type: FinancialType;

  @IsBoolean()
  @IsOptional()
  isCategory?: boolean;
}
