import { PaymentMethod } from '@prisma/client';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, Min } from 'class-validator';

export class CreateRevenueDto {
  @IsOptional()
  @IsString()
  accountNumber?: string;

  @Type(() => Number)
  @IsInt()
  @Min(0)
  amount: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  churchId: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  activityId?: number;

  @IsEnum(PaymentMethod)
  paymentMethod: PaymentMethod;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  financialAccountNumberId?: number;
}
