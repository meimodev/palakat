import { IsEnum, IsOptional } from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';
import { ReportJobStatus } from '../../generated/prisma/client';

export class ReportJobListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsEnum(ReportJobStatus)
  status?: ReportJobStatus;
}
