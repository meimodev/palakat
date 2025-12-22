import { Type } from 'class-transformer';
import { IsDate, IsInt, IsOptional, IsString, Min } from 'class-validator';

export class TransferCashDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  fromAccountId: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  toAccountId: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  amount: number;

  @IsDate()
  @Type(() => Date)
  happenedAt: Date;

  @IsOptional()
  @IsString()
  note?: string;
}
