import { HttpException } from '@nestjs/common';

export function mapErrorToRpc(error: unknown): {
  code: string;
  message: string;
  details?: unknown;
} {
  const jwtErrorName = (error as any)?.name as string | undefined;
  if (
    jwtErrorName === 'JsonWebTokenError' ||
    jwtErrorName === 'TokenExpiredError'
  ) {
    return { code: 'UNAUTHENTICATED', message: 'Invalid token' };
  }

  if (error instanceof HttpException) {
    const status = error.getStatus();
    const response = error.getResponse() as any;
    const message =
      typeof response === 'string'
        ? response
        : response?.message
          ? Array.isArray(response.message)
            ? response.message.join(', ')
            : response.message
          : error.message;

    if (status === 401) return { code: 'UNAUTHENTICATED', message };
    if (status === 403) return { code: 'FORBIDDEN', message };
    if (status === 404) return { code: 'NOT_FOUND', message };
    if (status === 409) return { code: 'CONFLICT', message };
    if (status === 400)
      return { code: 'VALIDATION_ERROR', message, details: response };
    return { code: 'INTERNAL', message };
  }

  if (error instanceof Error) {
    return { code: 'INTERNAL', message: error.message || 'Internal error' };
  }

  return { code: 'INTERNAL', message: 'Unknown error' };
}
