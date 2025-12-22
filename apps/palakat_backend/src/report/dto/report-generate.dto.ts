import { IsEnum, IsInt, IsOptional } from 'class-validator';
import { TransformToUtcDate } from '../../../common/transformers/utc-date.transformer';
import {
  ActivityType,
  DocumentInput,
  ReportFormat,
  ReportGenerateType,
} from '../../generated/prisma/client';

export enum CongregationReportSubtype {
  WARTA_JEMAAT = 'WARTA_JEMAAT',
  HUT_JEMAAT = 'HUT_JEMAAT',
  KEANGGOTAAN = 'KEANGGOTAAN',
}

export enum FinancialReportSubtype {
  REVENUE = 'REVENUE',
  EXPENSE = 'EXPENSE',
  MUTATION = 'MUTATION',
}

export class ReportGenerateDto {
  @IsEnum(ReportGenerateType)
  type: ReportGenerateType;

  @IsOptional()
  @IsEnum(DocumentInput)
  input?: DocumentInput;

  @IsOptional()
  @IsEnum(ReportFormat)
  format?: ReportFormat;

  @IsOptional()
  @TransformToUtcDate()
  startDate?: Date;

  @IsOptional()
  @TransformToUtcDate()
  endDate?: Date;

  @IsOptional()
  @IsEnum(CongregationReportSubtype)
  congregationSubtype?: CongregationReportSubtype;

  @IsOptional()
  @IsInt()
  columnId?: number;

  @IsOptional()
  @IsEnum(ActivityType)
  activityType?: ActivityType;

  @IsOptional()
  @IsEnum(FinancialReportSubtype)
  financialSubtype?: FinancialReportSubtype;
}
