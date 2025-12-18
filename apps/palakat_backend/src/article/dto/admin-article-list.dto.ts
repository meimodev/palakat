import { ArticleStatus, ArticleType } from '../../generated/prisma/client';
import { IsEnum, IsIn, IsOptional, IsString } from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export type AdminArticleSortField =
  | 'updatedAt'
  | 'createdAt'
  | 'publishedAt'
  | 'likesCount';

export class AdminArticleListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @IsEnum(ArticleType)
  type?: ArticleType;

  @IsOptional()
  @IsEnum(ArticleStatus)
  status?: ArticleStatus;

  @IsOptional()
  @IsIn(['updatedAt', 'createdAt', 'publishedAt', 'likesCount'])
  declare sortBy?: AdminArticleSortField;
}
