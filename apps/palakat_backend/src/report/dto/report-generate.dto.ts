import { IsEnum, IsOptional } from 'class-validator';
import { TransformToUtcDate } from '../../../common/transformers/utc-date.transformer';
import {
  ReportFormat,
  ReportGenerateType,
} from '../../generated/prisma/client';

export class ReportGenerateDto {
  @IsEnum(ReportGenerateType)
  type: ReportGenerateType;

  @IsOptional()
  @IsEnum(ReportFormat)
  format?: ReportFormat;

  @IsOptional()
  @TransformToUtcDate()
  startDate?: Date;

  @IsOptional()
  @TransformToUtcDate()
  endDate?: Date;
}
