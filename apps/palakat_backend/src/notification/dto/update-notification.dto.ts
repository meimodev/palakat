import { IsBoolean, IsOptional } from 'class-validator';

/**
 * DTO for updating a notification record.
 *
 * **Validates: Requirements 1.4, 7.3**
 */
export class UpdateNotificationDto {
  @IsOptional()
  @IsBoolean()
  isRead?: boolean;
}
