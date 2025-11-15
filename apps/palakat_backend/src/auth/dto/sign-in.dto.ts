import { IsString, MinLength } from 'class-validator';

export class SignInDto {
  @IsString()
  @MinLength(3)
  identifier!: string;

  @IsString()
  @MinLength(8)
  password!: string;
}
