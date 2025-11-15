import { Catch, ArgumentsHost, HttpStatus } from '@nestjs/common';
import { BaseExceptionFilter } from '@nestjs/core';
import { Prisma } from '@prisma/client';

@Catch()
export class PrismaExceptionFilter extends BaseExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    if (exception instanceof Prisma.PrismaClientValidationError) {
      response.status(HttpStatus.BAD_REQUEST).json({
        message: 'Invalid input parameter',
        error: exception.message,
      });
      return;
    }
    if (exception instanceof Prisma.PrismaClientKnownRequestError) {
      let message = 'Error Occurred';
      const error = exception.message;
      let code = HttpStatus.INTERNAL_SERVER_ERROR;

      // Check link bellow to see PrismaClientKnownRequestError codes definition
      // https://www.prisma.io/docs/orm/reference/error-reference#prisma-client-query-engine
      switch (exception.code) {
        case 'P2002':
          message = `Duplicate input attempt on unique column`;
          code = HttpStatus.BAD_REQUEST;
          break;
        case 'P2025':
          message = `Record not found`;
          code = HttpStatus.NOT_FOUND;
      }
      response.status(code).json({
        message: message,
        error: error,
      });
      return;
    }
    super.catch(exception, host);
  }
}
