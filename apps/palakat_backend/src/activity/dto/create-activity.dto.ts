import { ActivityType, Bipra, Reminder } from '@prisma/client';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsNumber, IsOptional, IsString } from 'class-validator';

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
  @Type(() => Date)
  date?: Date;

  @IsOptional()
  @IsString()
  note?: string;

  @IsEnum(ActivityType)
  activityType: ActivityType;

  @IsOptional()
  @IsEnum(Reminder)
  reminder?: Reminder;
}
