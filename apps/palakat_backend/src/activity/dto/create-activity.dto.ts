import { ActivityType, Bipra, PaymentMethod, Reminder } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { TransformToUtcDate } from '../../../common/transformers/utc-date.transformer';

// Nested DTO for creating finance record alongside activity
export class CreateFinanceDto {
  @IsEnum(['REVENUE', 'EXPENSE'])
  type: 'REVENUE' | 'EXPENSE';

  @IsString()
  accountNumber: string;

  @IsInt()
  amount: number;

  @IsEnum(PaymentMethod)
  paymentMethod: PaymentMethod;

  @IsOptional()
  @IsInt()
  financialAccountNumberId?: number;
}

export class CreateActivityDto {
  @IsInt()
  supervisorId: number;

  @IsEnum(Bipra)
  bipra: Bipra;

  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  locationName?: string;

  @IsOptional()
  @IsNumber()
  locationLatitude?: number;

  @IsOptional()
  @IsNumber()
  locationLongitude?: number;

  @IsOptional()
  @TransformToUtcDate()
  date?: Date;

  @IsOptional()
  @IsString()
  note?: string;

  @IsEnum(ActivityType)
  activityType: ActivityType;

  @IsOptional()
  @IsEnum(Reminder)
  reminder?: Reminder;

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateFinanceDto)
  finance?: CreateFinanceDto;
}
