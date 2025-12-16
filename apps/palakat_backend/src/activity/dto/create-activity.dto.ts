import { ActivityType, Bipra, PaymentMethod, Reminder } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsBoolean,
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

export class CreateActivityLocationDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @IsNumber()
  longitude?: number;
}

export class CreateActivityDto {
  @IsOptional()
  @IsInt()
  supervisorId?: number;

  @IsOptional()
  @IsBoolean()
  publishToColumnOnly?: boolean;

  @IsOptional()
  @IsEnum(Bipra)
  bipra?: Bipra;

  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateActivityLocationDto)
  location?: CreateActivityLocationDto;

  @IsOptional()
  @TransformToUtcDate()
  date?: Date;

  @IsOptional()
  @IsString()
  note?: string;

  @IsOptional()
  @IsInt()
  fileId?: number;

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
