import { ArticleType } from '../../generated/prisma/client';
import { IsEnum, IsOptional, IsString } from 'class-validator';

export class CreateArticleDto {
  @IsEnum(ArticleType)
  type: ArticleType;

  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  slug?: string;

  @IsOptional()
  @IsString()
  excerpt?: string;

  @IsString()
  content: string;

  @IsOptional()
  @IsString()
  coverImageUrl?: string;
}
