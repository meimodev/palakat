import { NotificationType } from '../../generated/prisma/client';
import { IsEnum, IsInt, IsOptional, IsString } from 'class-validator';

/**
 * DTO for creating a notification record.
 *
 * **Validates: Requirements 1.2, 8.1**
 */
export class CreateNotificationDto {
  @IsString()
  title: string;

  @IsString()
  body: string;

  @IsEnum(NotificationType)
  type: NotificationType;

  @IsString()
  recipient: string;

  @IsOptional()
  @IsInt()
  activityId?: number;
}
