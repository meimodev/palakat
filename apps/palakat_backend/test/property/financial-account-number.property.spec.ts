/**
 * Property-Based Tests for Financial Account Number
 *
 * **Feature: financial-account-number**
 *
 * This test suite verifies correctness properties for the
 * FinancialAccountNumber CRUD operations.
 */

import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import { PrismaClient } from '../../src/generated/prisma/client';
import * as fc from 'fast-check';
import {
  TEST_CONFIG,
  generateTestId,
  getDatabasePostgresUrl,
} from './utils/test-helpers';

// Generator for valid account numbers (6-20 digit strings)
const financialAccountNumberArb = fc
  .integer({ min: 100000, max: 99999999999999 })
  .map((n) => String(n));

// Generator for optional descriptions
const descriptionArb = fc.option(fc.string({ minLength: 1, maxLength: 200 }), {
  nil: undefined,
});

describe('Financial Account Number Property Tests', () => {
  let prisma: PrismaClient;
  let pool: Pool;
  let testChurchId: number;
  const testPrefix = 'test_fan_prop_';

  beforeAll(async () => {
    pool = new Pool({
      connectionString: getDatabasePostgresUrl(),
      allowExitOnIdle: true,
    });
    const adapter = new PrismaPg(pool);
    prisma = new PrismaClient({ adapter });

    // Create a test church for the property tests
    const testLocation = await prisma.location.create({
      data: {
        name: `${testPrefix}location_${generateTestId()}`,
        latitude: 1.0,
        longitude: 1.0,
      },
    });

    const testChurch = await prisma.church.create({
      data: {
        name: `${testPrefix}church_${generateTestId()}`,
        locationId: testLocation.id,
      },
    });

    testChurchId = testChurch.id;
  });

  afterAll(async () => {
    // Clean up all test financial account numbers
    await (prisma as any).financialAccountNumber.deleteMany({
      where: { churchId: testChurchId },
    });

    // Clean up test church and location
    const church = await prisma.church.findUnique({
      where: { id: testChurchId },
      include: { location: true },
    });

    if (church) {
      await prisma.church.delete({ where: { id: testChurchId } });
      if (church.location) {
        await prisma.location.delete({ where: { id: church.location.id } });
      }
    }

    await prisma.$disconnect();
    await pool.end();
  });

  afterEach(async () => {
    // Clean up test financial account numbers after each test
    await (prisma as any).financialAccountNumber.deleteMany({
      where: { churchId: testChurchId },
    });
  });

  // **Feature: financial-account-number, Property 1: Create-Read Round Trip**
  // **Validates: Requirements 1.3, 5.2**
  describe('Property 1: Create-Read Round Trip', () => {
    it('should return matching accountNumber and description when creating and retrieving a FinancialAccountNumber', async () => {
      await fc.assert(
        fc.asyncProperty(
          financialAccountNumberArb,
          descriptionArb,
          async (accountNumber: string, description: string | undefined) => {
            // Make account number unique per iteration to avoid conflicts
            const uniqueAccountNumber = `${accountNumber}_${generateTestId()}`;

            // Create the financial account number
            const created = await (prisma as any).financialAccountNumber.create(
              {
                data: {
                  accountNumber: uniqueAccountNumber,
                  description: description,
                  churchId: testChurchId,
                },
              },
            );

            // Retrieve by ID
            const retrieved = await (
              prisma as any
            ).financialAccountNumber.findUnique({
              where: { id: created.id },
            });

            // Verify the round trip
            expect(retrieved).not.toBeNull();
            expect(retrieved!.accountNumber).toBe(uniqueAccountNumber);
            expect(retrieved!.description).toBe(description ?? null);
            expect(retrieved!.churchId).toBe(testChurchId);
            expect(retrieved!.id).toBe(created.id);

            // Clean up this iteration's record
            await (prisma as any).financialAccountNumber.delete({
              where: { id: created.id },
            });

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: financial-account-number, Property 2: Delete Removes Record**
  // **Validates: Requirements 1.5, 5.4**
  describe('Property 2: Delete Removes Record', () => {
    it('should return not found when retrieving a deleted FinancialAccountNumber', async () => {
      await fc.assert(
        fc.asyncProperty(
          financialAccountNumberArb,
          descriptionArb,
          async (accountNumber: string, description: string | undefined) => {
            // Make account number unique per iteration to avoid conflicts
            const uniqueAccountNumber = `${accountNumber}_${generateTestId()}`;

            // Create the financial account number
            const created = await (prisma as any).financialAccountNumber.create(
              {
                data: {
                  accountNumber: uniqueAccountNumber,
                  description: description,
                  churchId: testChurchId,
                },
              },
            );

            const createdId = created.id;

            // Verify it exists before deletion
            const beforeDelete = await (
              prisma as any
            ).financialAccountNumber.findUnique({
              where: { id: createdId },
            });
            expect(beforeDelete).not.toBeNull();

            // Delete the record
            await (prisma as any).financialAccountNumber.delete({
              where: { id: createdId },
            });

            // Attempt to retrieve after deletion - should return null
            const afterDelete = await (
              prisma as any
            ).financialAccountNumber.findUnique({
              where: { id: createdId },
            });

            // Verify the record no longer exists
            expect(afterDelete).toBeNull();

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: financial-account-number, Property 4: Uniqueness Within Church**
  // **Validates: Requirements 2.5**
  describe('Property 4: Uniqueness Within Church', () => {
    it('should fail when creating two FinancialAccountNumbers with the same accountNumber in the same church', async () => {
      await fc.assert(
        fc.asyncProperty(
          financialAccountNumberArb,
          descriptionArb,
          descriptionArb,
          async (
            accountNumber: string,
            description1: string | undefined,
            description2: string | undefined,
          ) => {
            // Make account number unique per iteration
            const uniqueAccountNumber = `${accountNumber}_${generateTestId()}`;

            // Create the first financial account number - should succeed
            const first = await (prisma as any).financialAccountNumber.create({
              data: {
                accountNumber: uniqueAccountNumber,
                description: description1,
                churchId: testChurchId,
              },
            });

            expect(first).not.toBeNull();
            expect(first.accountNumber).toBe(uniqueAccountNumber);

            // Attempt to create a second with the same accountNumber in the same church
            // This should fail with a uniqueness violation
            let secondCreationFailed = false;
            try {
              await (prisma as any).financialAccountNumber.create({
                data: {
                  accountNumber: uniqueAccountNumber,
                  description: description2,
                  churchId: testChurchId,
                },
              });
            } catch (error: any) {
              // Prisma throws P2002 for unique constraint violations
              secondCreationFailed = true;
              expect(error.code).toBe('P2002');
            }

            // Verify the second creation failed
            expect(secondCreationFailed).toBe(true);

            // Clean up the first record
            await (prisma as any).financialAccountNumber.delete({
              where: { id: first.id },
            });

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: financial-account-number, Property 5: Search Filter Correctness**
  // **Validates: Requirements 2.6, 5.5**
  describe('Property 5: Search Filter Correctness', () => {
    it('should return only FinancialAccountNumbers where accountNumber or description contains the search string (case-insensitive)', async () => {
      // Generator for search query strings (non-empty alphanumeric strings)
      const searchQueryArb = fc.string({ minLength: 1, maxLength: 10 }).filter(
        (s) => /^[a-zA-Z0-9]+$/.test(s), // Only alphanumeric to avoid regex issues
      );

      await fc.assert(
        fc.asyncProperty(
          fc.array(
            fc.record({
              accountNumber: financialAccountNumberArb,
              description: descriptionArb,
            }),
            { minLength: 3, maxLength: 10 },
          ),
          searchQueryArb,
          async (
            records: Array<{
              accountNumber: string;
              description: string | undefined;
            }>,
            searchQuery: string,
          ) => {
            const createdRecords: Array<{ id: number }> = [];

            try {
              // Create multiple financial account numbers with unique identifiers
              for (const record of records) {
                const uniqueAccountNumber = `${record.accountNumber}_${generateTestId()}`;
                const created = await (
                  prisma as any
                ).financialAccountNumber.create({
                  data: {
                    accountNumber: uniqueAccountNumber,
                    description: record.description,
                    churchId: testChurchId,
                  },
                });
                createdRecords.push(created);
              }

              // Perform search query using Prisma directly (simulating service behavior)
              const searchLower = searchQuery.toLowerCase();
              const searchResults = await (
                prisma as any
              ).financialAccountNumber.findMany({
                where: {
                  churchId: testChurchId,
                  OR: [
                    {
                      accountNumber: {
                        contains: searchQuery,
                        mode: 'insensitive',
                      },
                    },
                    {
                      description: {
                        contains: searchQuery,
                        mode: 'insensitive',
                      },
                    },
                  ],
                },
              });

              // Verify: All returned results should contain the search string
              // in either accountNumber or description (case-insensitive)
              for (const result of searchResults) {
                const accountNumberLower = result.accountNumber.toLowerCase();
                const descriptionLower = (
                  result.description || ''
                ).toLowerCase();

                const matchesAccountNumber =
                  accountNumberLower.includes(searchLower);
                const matchesDescription =
                  descriptionLower.includes(searchLower);

                expect(matchesAccountNumber || matchesDescription).toBe(true);
              }

              // Verify: All records that should match are included in results
              const allRecords = await (
                prisma as any
              ).financialAccountNumber.findMany({
                where: { churchId: testChurchId },
              });

              for (const record of allRecords) {
                const accountNumberLower = record.accountNumber.toLowerCase();
                const descriptionLower = (
                  record.description || ''
                ).toLowerCase();

                const shouldMatch =
                  accountNumberLower.includes(searchLower) ||
                  descriptionLower.includes(searchLower);

                const isInResults = searchResults.some(
                  (r: any) => r.id === record.id,
                );

                if (shouldMatch) {
                  expect(isInResults).toBe(true);
                } else {
                  expect(isInResults).toBe(false);
                }
              }

              return true;
            } finally {
              // Clean up all created records
              for (const record of createdRecords) {
                await (prisma as any).financialAccountNumber.delete({
                  where: { id: record.id },
                });
              }
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
