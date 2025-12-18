import { ArticleType } from '../../generated/prisma/client';
import { IsEnum, IsIn, IsOptional, IsString } from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export type ArticleSortField = 'publishedAt' | 'likesCount' | 'createdAt';

export class ArticleListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @IsEnum(ArticleType)
  type?: ArticleType;

  @IsOptional()
  @IsIn(['publishedAt', 'likesCount', 'createdAt'])
  declare sortBy?: ArticleSortField;
}
