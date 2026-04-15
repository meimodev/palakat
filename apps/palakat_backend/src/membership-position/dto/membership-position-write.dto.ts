import { Type } from 'class-transformer';
import {
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateMembershipPositionDto {
  @IsString()
  name: string;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  churchId: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  membershipId?: number;

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  approvalRuleIds?: number[];
}

export class UpdateMembershipPositionDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  churchId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  membershipId?: number | null;

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  approvalRuleIds?: number[];
}
