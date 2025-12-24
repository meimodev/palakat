import { Type } from 'class-transformer';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';
import { PaymentMethod } from '../../generated/prisma/client';
import {
  TransformToStartOfDayUtc,
  TransformToEndOfDayUtc,
} from '../../../common/transformers/utc-date.transformer';

export enum FinanceEntryType {
  REVENUE = 'REVENUE',
  EXPENSE = 'EXPENSE',
}

export class FinanceListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @IsEnum(PaymentMethod)
  paymentMethod?: PaymentMethod;

  @IsOptional()
  @IsEnum(FinanceEntryType)
  type?: FinanceEntryType;

  @IsOptional()
  @TransformToStartOfDayUtc()
  startDate?: Date;

  @IsOptional()
  @TransformToEndOfDayUtc()
  endDate?: Date;
}
