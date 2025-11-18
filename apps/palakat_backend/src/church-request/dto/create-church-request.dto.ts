import { IsNotEmpty, IsString } from 'class-validator';

export class CreateChurchRequestDto {
  @IsNotEmpty()
  @IsString()
  churchName: string;

  @IsNotEmpty()
  @IsString()
  churchAddress: string;

  @IsNotEmpty()
  @IsString()
  contactPerson: string;

  @IsNotEmpty()
  @IsString()
  contactPhone: string;
}
