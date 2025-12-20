import { IsNotEmpty, IsString } from 'class-validator';

export class RejectChurchRequestDto {
  @IsNotEmpty()
  @IsString()
  decisionNote: string;
}
