import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable, map } from 'rxjs';
import { PaginationMeta, PaginationParams } from './pagination.types';
import { getPaginationParams } from './pagination.util';

/**
 * PaginationInterceptor
 *
 * Controller handlers can simply return either:
 *  - { data: T[], total: number, message?: string }
 *  and this interceptor will inject a `pagination` object based on the request query (page/pageSize)
 *
 * If `total` is missing, the interceptor will pass through the response unchanged.
 */
@Injectable()
export class PaginationInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const pagination: PaginationParams = getPaginationParams(request.query || {});

    return next.handle().pipe(
      map((original) => {
        if (!original || typeof original !== 'object') return original;

        const { data, total, message, ...rest } = original as any;
        if (!Array.isArray(data) || typeof total !== 'number') {
          // Not a paginated shape; return as-is
          return original;
        }

        const totalPages = Math.ceil(total / pagination.pageSize);
        const meta: PaginationMeta = {
          page: pagination.page,
          pageSize: pagination.pageSize,
          total,
          totalPages,
          hasNext: pagination.page < totalPages,
          hasPrev: pagination.page > 1,
        };

        return {
          ...(message ? { message } : {}),
          data,
          pagination: meta,
          ...rest,
        };
      }),
    );
  }
}
