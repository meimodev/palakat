import { IsEnum, IsOptional, IsString } from 'class-validator';
import { RequestStatus } from '../../generated/prisma/client';

export class UpdateChurchRequestDto {
  @IsOptional()
  @IsString()
  churchName?: string;

  @IsOptional()
  @IsString()
  churchAddress?: string;

  @IsOptional()
  @IsString()
  contactPerson?: string;

  @IsOptional()
  @IsString()
  contactPhone?: string;

  @IsOptional()
  @IsEnum(RequestStatus)
  status?: RequestStatus;

  @IsOptional()
  @IsString()
  decisionNote?: string;
}
