import { IsEnum, IsOptional } from 'class-validator';
import { TransformToUtcDate } from '../../../common/transformers/utc-date.transformer';

export enum ReportGenerateType {
  INCOMING_DOCUMENT = 'INCOMING_DOCUMENT',
  CONGREGATION = 'CONGREGATION',
  SERVICES = 'SERVICES',
  ACTIVITY = 'ACTIVITY',
}

export class ReportGenerateDto {
  @IsEnum(ReportGenerateType)
  type: ReportGenerateType;

  @IsOptional()
  @TransformToUtcDate()
  startDate?: Date;

  @IsOptional()
  @TransformToUtcDate()
  endDate?: Date;
}
