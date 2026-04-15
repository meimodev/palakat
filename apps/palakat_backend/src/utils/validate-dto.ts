import { BadRequestException } from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';

/**
 * Validates a plain payload against a DTO class using class-transformer +
 * class-validator. Throws BadRequestException on validation failure.
 *
 * Use this to enforce the same DTO contract on RPC payloads that the REST
 * layer enforces automatically via NestJS pipes.
 */
export function validateDto<T extends object>(
  DtoClass: new () => T,
  payload: unknown,
): T {
  const instance = plainToInstance(DtoClass, payload ?? {});
  const errors = validateSync(instance as object, {
    whitelist: true,
    forbidNonWhitelisted: false,
  });
  if (errors.length > 0) {
    const messages = errors.flatMap((e) =>
      e.constraints ? Object.values(e.constraints) : [],
    );
    throw new BadRequestException(messages);
  }
  return instance;
}
