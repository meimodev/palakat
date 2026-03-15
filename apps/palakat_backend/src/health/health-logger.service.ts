import { ConsoleLogger, Injectable } from '@nestjs/common';
import { HealthLogBufferService } from './health-log-buffer.service';

@Injectable()
export class HealthLoggerService extends ConsoleLogger {
  constructor(private readonly logBuffer: HealthLogBufferService) {
    super();
  }

  log(message: any, ...optionalParams: any[]) {
    const { context, extras } = this.extractContext(optionalParams);
    this.logBuffer.add('log', this.joinMessage(message, extras), context);
    super.log(message, ...optionalParams);
  }

  warn(message: any, ...optionalParams: any[]) {
    const { context, extras } = this.extractContext(optionalParams);
    this.logBuffer.add('warn', this.joinMessage(message, extras), context);
    super.warn(message, ...optionalParams);
  }

  debug(message: any, ...optionalParams: any[]) {
    const { context, extras } = this.extractContext(optionalParams);
    this.logBuffer.add('debug', this.joinMessage(message, extras), context);
    super.debug(message, ...optionalParams);
  }

  verbose(message: any, ...optionalParams: any[]) {
    const { context, extras } = this.extractContext(optionalParams);
    this.logBuffer.add('verbose', this.joinMessage(message, extras), context);
    super.verbose(message, ...optionalParams);
  }

  error(message: any, ...optionalParams: any[]) {
    const trace =
      optionalParams.length > 0 && typeof optionalParams[0] === 'string'
        ? optionalParams[0]
        : undefined;
    const context =
      optionalParams.length > 1 &&
      typeof optionalParams[optionalParams.length - 1] === 'string'
        ? optionalParams[optionalParams.length - 1]
        : undefined;
    const extras = optionalParams.slice(trace ? 1 : 0, context ? -1 : undefined);

    this.logBuffer.add(
      'error',
      this.joinMessage(message, extras),
      context,
      trace,
    );
    super.error(message, ...optionalParams);
  }

  private extractContext(optionalParams: any[]) {
    if (
      optionalParams.length > 0 &&
      typeof optionalParams[optionalParams.length - 1] === 'string'
    ) {
      return {
        context: optionalParams[optionalParams.length - 1] as string,
        extras: optionalParams.slice(0, -1),
      };
    }

    return {
      context: undefined,
      extras: optionalParams,
    };
  }

  private joinMessage(message: unknown, extras: unknown[]): string {
    return [message, ...extras]
      .map((value) => this.serialize(value))
      .filter((value) => value.length > 0)
      .join(' ');
  }

  private serialize(value: unknown): string {
    if (typeof value === 'string') return value;
    if (value instanceof Error) return value.message;
    if (value === null || value === undefined) return '';

    try {
      return JSON.stringify(value);
    } catch (_) {
      return String(value);
    }
  }
}
