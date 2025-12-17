import { NotificationType } from '../../generated/prisma/client';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsIn,
  IsOptional,
  IsString,
  ValidateIf,
} from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export type NotificationSortField = 'id' | 'createdAt';

/**
 * DTO for listing notifications with pagination and filtering.
 *
 * **Validates: Requirements 1.5, 7.1**
 */
export class NotificationListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsString()
  recipient?: string;

  @IsOptional()
  @Transform(({ value }) => {
    if (value === 'true') return true;
    if (value === 'false') return false;
    if (value === true || value === false) return value;
    return undefined;
  })
  @ValidateIf((o) => o.isRead !== undefined)
  @IsBoolean()
  isRead?: boolean;

  @IsOptional()
  @ValidateIf((o) => o.type !== undefined && o.type !== null && o.type !== '')
  @IsEnum(NotificationType)
  type?: NotificationType;

  @IsOptional()
  @IsIn(['id', 'createdAt'])
  declare sortBy?: NotificationSortField;
}
