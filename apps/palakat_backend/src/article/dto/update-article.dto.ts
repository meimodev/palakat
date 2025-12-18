import { ArticleType } from '../../generated/prisma/client';
import { IsEnum, IsOptional, IsString, ValidateIf } from 'class-validator';

export class UpdateArticleDto {
  @IsOptional()
  @IsEnum(ArticleType)
  type?: ArticleType;

  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  slug?: string;

  @IsOptional()
  @ValidateIf((_, value) => value !== null)
  @IsString()
  excerpt?: string | null;

  @IsOptional()
  @IsString()
  content?: string;

  @IsOptional()
  @ValidateIf((_, value) => value !== null)
  @IsString()
  coverImageUrl?: string | null;
}
