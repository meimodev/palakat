import { IsString, MinLength } from 'class-validator';

export class SuperAdminSignInDto {
  @IsString()
  @MinLength(8)
  phone!: string;

  @IsString()
  @MinLength(8)
  password!: string;
}
