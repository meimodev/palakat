import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { getPaginationParams } from './pagination.util';
import { PaginationParams } from './pagination.types';

export const Pagination = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): PaginationParams => {
    const request = ctx.switchToHttp().getRequest();
    return getPaginationParams(request.query || {});
  },
);
