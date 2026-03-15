import { Injectable } from '@nestjs/common';
import { HealthLogEntry, HealthLogLevel } from './health.types';

@Injectable()
export class HealthLogBufferService {
  private readonly entries: HealthLogEntry[] = [];
  private readonly maxEntries = 200;

  add(
    level: HealthLogLevel,
    message: unknown,
    context?: string,
    trace?: string,
  ) {
    const entry: HealthLogEntry = {
      timestamp: new Date().toISOString(),
      level,
      context,
      message: this.serialize(message),
      trace: trace ? this.serialize(trace) : undefined,
    };

    this.entries.unshift(entry);
    if (this.entries.length > this.maxEntries) {
      this.entries.length = this.maxEntries;
    }
  }

  getRecent(limit = 40): HealthLogEntry[] {
    return this.entries.slice(0, limit);
  }

  private serialize(value: unknown): string {
    if (typeof value === 'string') return value;
    if (value instanceof Error) return value.message;
    if (value === null || value === undefined) return String(value);

    try {
      return JSON.stringify(value);
    } catch (_) {
      return String(value);
    }
  }
}
