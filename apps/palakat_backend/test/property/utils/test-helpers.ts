/**
 * Property-Based Testing Utilities
 *
 * This module provides helper functions for setting up and managing
 * test data in property-based tests.
 */

import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import {
  Gender,
  MaritalStatus,
  PrismaClient,
} from '../../../src/generated/prisma/client';
import * as bcrypt from 'bcryptjs';

export function getDatabasePostgresUrl(): string {
  const raw = process.env.DATABASE_POSTGRES_URL;
  if (raw && !raw.includes('${')) {
    return raw;
  }

  const host = process.env.POSTGRES_HOST || 'localhost';
  const port = process.env.POSTGRES_PORT || '5432';
  const user = process.env.POSTGRES_USER || 'root';
  const password = process.env.POSTGRES_PASSWORD || 'password';
  const db = process.env.POSTGRES_DB || 'database';

  return `postgresql://${user}:${password}@${host}:${port}/${db}`;
}

// Default test configuration
export const TEST_CONFIG = {
  // Number of iterations for property tests (minimum 100 as per design doc)
  NUM_RUNS: 100,
  // Password hash rounds for test accounts
  HASH_ROUNDS: 10,
  // Default test password
  DEFAULT_PASSWORD: 'TestPassword123!',
  // JWT secret for tests
  JWT_SECRET: 'test-jwt-secret-key-for-property-tests',
};

/**
 * Creates a test Prisma client instance
 */
export function createTestPrismaClient(): PrismaClient {
  const pool = new Pool({
    connectionString: getDatabasePostgresUrl(),
    allowExitOnIdle: true,
  });
  const adapter = new PrismaPg(pool);
  return new PrismaClient({ adapter });
}

/**
 * Cleans up test data from the database
 * Use with caution - this deletes data!
 */
export async function cleanupTestData(
  prisma: PrismaClient,
  options: {
    phonePrefix?: string;
    emailDomain?: string;
  } = {},
): Promise<void> {
  const { phonePrefix = 'test_', emailDomain = 'test.example.com' } = options;

  // Delete in order respecting foreign key constraints
  await prisma.approver.deleteMany({
    where: {
      membership: {
        account: {
          OR: [
            { phone: { startsWith: phonePrefix } },
            { email: { endsWith: `@${emailDomain}` } },
          ],
        },
      },
    },
  });

  await prisma.activity.deleteMany({
    where: {
      supervisor: {
        account: {
          OR: [
            { phone: { startsWith: phonePrefix } },
            { email: { endsWith: `@${emailDomain}` } },
          ],
        },
      },
    },
  });

  await prisma.churchRequest.deleteMany({
    where: {
      requester: {
        OR: [
          { phone: { startsWith: phonePrefix } },
          { email: { endsWith: `@${emailDomain}` } },
        ],
      },
    },
  });

  await prisma.membership.deleteMany({
    where: {
      account: {
        OR: [
          { phone: { startsWith: phonePrefix } },
          { email: { endsWith: `@${emailDomain}` } },
        ],
      },
    },
  });

  await prisma.account.deleteMany({
    where: {
      OR: [
        { phone: { startsWith: phonePrefix } },
        { email: { endsWith: `@${emailDomain}` } },
      ],
    },
  });
}

/**
 * Creates a test account with the given data
 */
export async function createTestAccount(
  prisma: PrismaClient,
  data: {
    name: string;
    phone: string;
    email?: string;
    password?: string;
    gender?: 'MALE' | 'FEMALE';
    maritalStatus?: 'MARRIED' | 'SINGLE';
    dob?: Date;
    isActive?: boolean;
    claimed?: boolean;
  },
) {
  const passwordHash = data.password
    ? await bcrypt.hash(data.password, TEST_CONFIG.HASH_ROUNDS)
    : await bcrypt.hash(TEST_CONFIG.DEFAULT_PASSWORD, TEST_CONFIG.HASH_ROUNDS);

  return prisma.account.create({
    data: {
      name: data.name,
      phone: data.phone,
      email: data.email,
      passwordHash,
      gender: (data.gender || 'MALE') as Gender,
      maritalStatus: (data.maritalStatus || 'SINGLE') as MaritalStatus,
      dob: data.dob || new Date('1990-01-01'),
      isActive: data.isActive ?? true,
      claimed: data.claimed ?? true,
    },
  });
}

/**
 * Creates a test church with location
 */
export async function createTestChurch(
  prisma: PrismaClient,
  data: {
    name: string;
    phoneNumber?: string;
    email?: string;
    description?: string;
    location: {
      name: string;
      latitude: number;
      longitude: number;
    };
  },
) {
  const location = await prisma.location.create({
    data: {
      name: data.location.name,
      latitude: data.location.latitude,
      longitude: data.location.longitude,
    },
  });

  return prisma.church.create({
    data: {
      name: data.name,
      phoneNumber: data.phoneNumber,
      email: data.email,
      description: data.description,
      locationId: location.id,
    },
    include: {
      location: true,
    },
  });
}

/**
 * Creates a test membership linking account to church
 */
export async function createTestMembership(
  prisma: PrismaClient,
  data: {
    accountId: number;
    churchId: number;
    columnId?: number;
    baptize?: boolean;
    sidi?: boolean;
  },
) {
  return prisma.membership.create({
    data: {
      accountId: data.accountId,
      churchId: data.churchId,
      columnId: data.columnId,
      baptize: data.baptize ?? false,
      sidi: data.sidi ?? false,
    },
  });
}

/**
 * Generates a unique test identifier
 */
export function generateTestId(): string {
  return `test_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
}

/**
 * Waits for a specified duration (useful for testing time-based features)
 */
export function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Asserts that a value is within a range
 */
export function assertInRange(
  value: number,
  min: number,
  max: number,
  message?: string,
): void {
  if (value < min || value > max) {
    throw new Error(
      message || `Expected ${value} to be between ${min} and ${max}`,
    );
  }
}

/**
 * Asserts that two dates are within a tolerance of each other
 */
export function assertDatesClose(
  date1: Date,
  date2: Date,
  toleranceMs: number = 1000,
): void {
  const diff = Math.abs(date1.getTime() - date2.getTime());
  if (diff > toleranceMs) {
    throw new Error(
      `Expected dates to be within ${toleranceMs}ms, but difference was ${diff}ms`,
    );
  }
}
