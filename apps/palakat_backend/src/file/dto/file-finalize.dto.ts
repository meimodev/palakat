import { IsInt, IsNumber, IsOptional, IsString } from 'class-validator';

export class FileFinalizeDto {
  @IsInt()
  churchId: number;

  @IsOptional()
  @IsString()
  bucket?: string;

  @IsString()
  path: string;

  @IsNumber()
  sizeInKB: number;

  @IsOptional()
  @IsString()
  contentType?: string;

  @IsOptional()
  @IsString()
  originalName?: string;
}
