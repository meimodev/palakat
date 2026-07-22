import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from './generated/prisma/client';
import { Pool } from 'pg';

/**
 * How many connections one process may hold. `pg` defaults to 10, which is a
 * single container spending most of a Supabase Free direct-connection budget
 * (§11 R4 of the Cloud Run migration plan) — and scale-to-zero makes the
 * number of containers spiky by design, so the real ceiling is this number
 * times however many instances happen to be warm.
 *
 * Parsed rather than `Number(env ?? 3)`: an unset variable gives `NaN` and an
 * empty one gives `0`, and a pool of zero is a service that accepts requests
 * and can never answer them. Anything that is not a positive integer means
 * "nobody made a decision here", so take the default.
 */
export function resolvePoolMax(raw: string | undefined, fallback = 3): number {
  const parsed = Number(raw);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : fallback;
}

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private pool: Pool;

  constructor() {
    const connectionString =
      process.env.DATABASE_URL && !process.env.DATABASE_URL.includes('${')
        ? process.env.DATABASE_URL
        : `postgresql://${process.env.POSTGRES_USER || 'root'}:${process.env.POSTGRES_PASSWORD || 'password'}@${process.env.POSTGRES_HOST || 'localhost'}:${process.env.POSTGRES_PORT || '5432'}/${process.env.POSTGRES_DB || 'database'}`;

    // Create connection pool
    const pool = new Pool({
      connectionString,
      max: resolvePoolMax(process.env.DATABASE_POOL_MAX),
      idleTimeoutMillis: 30_000,
      // Fail fast rather than hanging a request forever behind an exhausted
      // pool or an unreachable database.
      connectionTimeoutMillis: 10_000,
    });

    // Create adapter
    const adapter = new PrismaPg(pool);

    // Initialize PrismaClient with adapter
    super({
      adapter,
    });

    this.pool = pool;
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
    await this.pool.end();
  }
}
