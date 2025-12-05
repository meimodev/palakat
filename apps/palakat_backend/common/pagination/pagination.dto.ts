import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, IsString, Min, Max } from 'class-validator';
import {
  DEFAULT_PAGE,
  DEFAULT_PAGE_SIZE,
  MAX_PAGE_SIZE,
} from './pagination.types';

export type SortOrder = 'asc' | 'desc';

export class PaginationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = DEFAULT_PAGE;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_PAGE_SIZE)
  pageSize: number = DEFAULT_PAGE_SIZE;

  @IsOptional()
  @IsString()
  sortBy?: string;

  @IsOptional()
  @IsIn(['asc', 'desc'])
  sortOrder?: SortOrder;

  get skip() {
    return (this.page - 1) * this.pageSize;
  }

  get take() {
    return this.pageSize;
  }
}
