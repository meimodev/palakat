import { Gender, MaritalStatus } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsDateString,
  IsEmail,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsPositive,
  IsString,
  ValidateNested,
} from 'class-validator';

class CreateMembershipPositionCreateDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsOptional()
  @IsInt()
  @IsPositive()
  churchId?: number;

  // Advanced users may pass direct Prisma object under `church`
  @IsOptional()
  @IsObject()
  church?: any;
}

class CreateMembershipDto {
  @IsOptional()
  @IsBoolean()
  baptize?: boolean;

  @IsOptional()
  @IsBoolean()
  sidi?: boolean;

  @IsOptional()
  @IsInt()
  @IsPositive()
  churchId?: number;

  @IsOptional()
  @IsInt()
  @IsPositive()
  columnId?: number;

  // Direct prisma sub-shapes optionally allowed for power users
  @IsOptional()
  @IsObject()
  church?: any;

  @IsOptional()
  @IsObject()
  column?: any;

  // Connect existing positions by id
  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  @IsPositive({ each: true })
  membershipPositionIds?: number[];

  // Create new positions
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateMembershipPositionCreateDto)
  membershipPositionsCreate?: CreateMembershipPositionCreateDto[];

  // Direct prisma object for power users - array of position objects with id
  @IsOptional()
  @IsArray()
  membershipPositions?: any[];
}

export class CreateAccountDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsString()
  @IsNotEmpty()
  // Keep generic validation; E.164 might be too strict for local numbers
  phone!: string;

  @IsOptional()
  @IsEmail()
  email?: string | null;

  @IsEnum(Gender)
  gender!: Gender;

  @IsEnum(MaritalStatus)
  maritalStatus!: MaritalStatus;

  @IsDateString()
  dob?: string; // ISO date string; service will accept as Date

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateMembershipDto)
  membership?:
    | CreateMembershipDto
    | {
        create?: any;
        connect?: any;
        connectOrCreate?: any;
      };
}
