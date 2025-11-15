import { IsNumber, IsOptional } from 'class-validator';

export class AccountCountQueryDto {
  @IsOptional()
  @IsNumber()
  churchId?: number;
}
