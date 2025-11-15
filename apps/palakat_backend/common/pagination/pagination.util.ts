import { DEFAULT_PAGE, DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE, PaginationParams } from './pagination.types';

export function getPaginationParams(query: Record<string, any>): PaginationParams {
  const rawPage = Number(query.page);
  const rawPageSize = Number(query.pageSize);

  const page = Math.max(1, Number.isFinite(rawPage) && rawPage > 0 ? Math.floor(rawPage) : DEFAULT_PAGE);

  const baseSize = Number.isFinite(rawPageSize) && rawPageSize > 0 ? Math.floor(rawPageSize) : DEFAULT_PAGE_SIZE;
  const pageSize = Math.min(Math.max(1, baseSize), MAX_PAGE_SIZE);

  const take = pageSize;
  const skip = (page - 1) * pageSize;

  return { page, pageSize, take, skip };
}
