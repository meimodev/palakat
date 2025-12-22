import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import {
  CashMutationReferenceType,
  CashMutationType,
} from '../../generated/prisma/client';

export class CreateCashMutationDto {
  @IsEnum(CashMutationType)
  type: CashMutationType;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  amount: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  fromAccountId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  toAccountId?: number;

  @IsDate()
  @Type(() => Date)
  happenedAt: Date;

  @IsOptional()
  @IsString()
  note?: string;

  @IsOptional()
  @IsEnum(CashMutationReferenceType)
  referenceType?: CashMutationReferenceType;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  referenceId?: number;
}
