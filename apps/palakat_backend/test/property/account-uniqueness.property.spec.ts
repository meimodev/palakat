/**
 * Property-Based Tests for Account Uniqueness Constraints
 *
 * **Feature: palakat-system-overview, Property 5: Account Uniqueness Constraints**
 * **Validates: Requirements 3.6, 3.7**
 *
 * This test suite verifies that the system enforces uniqueness constraints
 * for phone numbers and email addresses across all accounts.
 */

import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import { PrismaClient } from '../../src/generated/prisma/client';
import * as bcrypt from 'bcryptjs';
import * as fc from 'fast-check';
import * as generators from './generators';
import { TEST_CONFIG, getDatabasePostgresUrl } from './utils/test-helpers';

describe('Account Uniqueness Property Tests', () => {
  let prisma: PrismaClient;
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({
      connectionString: getDatabasePostgresUrl(),
      allowExitOnIdle: true,
    });
    const adapter = new PrismaPg(pool);
    prisma = new PrismaClient({ adapter });
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await pool.end();
  });

  beforeEach(async () => {
    // Clean up test accounts before each test
    await prisma.account.deleteMany({
      where: {
        OR: [
          { phone: { startsWith: 'test_prop_' } },
          { email: { endsWith: '@test-property.example.com' } },
        ],
      },
    });
  });

  afterEach(async () => {
    // Clean up test accounts after each test
    await prisma.account.deleteMany({
      where: {
        OR: [
          { phone: { startsWith: 'test_prop_' } },
          { email: { endsWith: '@test-property.example.com' } },
        ],
      },
    });
  });

  // **Feature: palakat-system-overview, Property 5: Account Uniqueness Constraints**
  // **Validates: Requirements 3.6, 3.7**
  describe('Property 5: Account Uniqueness Constraints', () => {
    it('should reject duplicate phone numbers across all accounts', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.nameArb,
          generators.nameArb,
          generators.genderArb,
          generators.maritalStatusArb,
          generators.dobArb,
          async (
            name1: string,
            name2: string,
            gender: string,
            maritalStatus: string,
            dob: Date,
          ) => {
            // Generate unique test phone number
            const uniquePhone = `test_prop_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
            const passwordHash = await bcrypt.hash(
              'TestPassword123!',
              TEST_CONFIG.HASH_ROUNDS,
            );

            // Create first account with the phone number
            const firstAccount = await prisma.account.create({
              data: {
                name: name1,
                phone: uniquePhone,
                passwordHash,
                gender: gender as any,
                maritalStatus: maritalStatus as any,
                dob,
              },
            });

            // Verify first account was created
            expect(firstAccount).toBeDefined();
            expect(firstAccount.phone).toBe(uniquePhone);

            // Attempt to create second account with the same phone number
            let errorOccurred = false;
            let errorCode: string | undefined;

            try {
              await prisma.account.create({
                data: {
                  name: name2,
                  phone: uniquePhone, // Same phone number
                  passwordHash,
                  gender: gender as any,
                  maritalStatus: maritalStatus as any,
                  dob,
                },
              });
            } catch (error: any) {
              errorOccurred = true;
              errorCode = error.code;
            }

            // Clean up the first account
            await prisma.account.delete({ where: { id: firstAccount.id } });

            // Assert that the duplicate phone was rejected
            expect(errorOccurred).toBe(true);
            expect(errorCode).toBe('P2002'); // Prisma unique constraint violation
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should reject duplicate email addresses where email is provided', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.nameArb,
          generators.nameArb,
          generators.genderArb,
          generators.maritalStatusArb,
          generators.dobArb,
          async (
            name1: string,
            name2: string,
            gender: string,
            maritalStatus: string,
            dob: Date,
          ) => {
            // Generate unique test email and phone numbers
            const uniqueEmail = `test_${Date.now()}_${Math.random().toString(36).substring(2, 9)}@test-property.example.com`;
            const phone1 = `test_prop_${Date.now()}_${Math.random().toString(36).substring(2, 9)}_1`;
            const phone2 = `test_prop_${Date.now()}_${Math.random().toString(36).substring(2, 9)}_2`;
            const passwordHash = await bcrypt.hash(
              'TestPassword123!',
              TEST_CONFIG.HASH_ROUNDS,
            );

            // Create first account with the email
            const firstAccount = await prisma.account.create({
              data: {
                name: name1,
                phone: phone1,
                email: uniqueEmail,
                passwordHash,
                gender: gender as any,
                maritalStatus: maritalStatus as any,
                dob,
              },
            });

            // Verify first account was created
            expect(firstAccount).toBeDefined();
            expect(firstAccount.email).toBe(uniqueEmail);

            // Attempt to create second account with the same email
            let errorOccurred = false;
            let errorCode: string | undefined;

            try {
              await prisma.account.create({
                data: {
                  name: name2,
                  phone: phone2, // Different phone
                  email: uniqueEmail, // Same email
                  passwordHash,
                  gender: gender as any,
                  maritalStatus: maritalStatus as any,
                  dob,
                },
              });
            } catch (error: any) {
              errorOccurred = true;
              errorCode = error.code;
            }

            // Clean up the first account
            await prisma.account.delete({ where: { id: firstAccount.id } });

            // Assert that the duplicate email was rejected
            expect(errorOccurred).toBe(true);
            expect(errorCode).toBe('P2002'); // Prisma unique constraint violation
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should allow multiple accounts with null email addresses', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.nameArb,
          generators.nameArb,
          generators.genderArb,
          generators.maritalStatusArb,
          generators.dobArb,
          async (
            name1: string,
            name2: string,
            gender: string,
            maritalStatus: string,
            dob: Date,
          ) => {
            // Generate unique test phone numbers
            const phone1 = `test_prop_${Date.now()}_${Math.random().toString(36).substring(2, 9)}_1`;
            const phone2 = `test_prop_${Date.now()}_${Math.random().toString(36).substring(2, 9)}_2`;
            const passwordHash = await bcrypt.hash(
              'TestPassword123!',
              TEST_CONFIG.HASH_ROUNDS,
            );

            // Create first account without email
            const firstAccount = await prisma.account.create({
              data: {
                name: name1,
                phone: phone1,
                email: null, // No email
                passwordHash,
                gender: gender as any,
                maritalStatus: maritalStatus as any,
                dob,
              },
            });

            // Create second account without email
            const secondAccount = await prisma.account.create({
              data: {
                name: name2,
                phone: phone2,
                email: null, // No email
                passwordHash,
                gender: gender as any,
                maritalStatus: maritalStatus as any,
                dob,
              },
            });

            // Verify both accounts were created successfully
            expect(firstAccount).toBeDefined();
            expect(secondAccount).toBeDefined();
            expect(firstAccount.email).toBeNull();
            expect(secondAccount.email).toBeNull();

            // Clean up
            await prisma.account.delete({ where: { id: firstAccount.id } });
            await prisma.account.delete({ where: { id: secondAccount.id } });
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should allow same phone number after account deletion', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.nameArb,
          generators.nameArb,
          generators.genderArb,
          generators.maritalStatusArb,
          generators.dobArb,
          async (
            name1: string,
            name2: string,
            gender: string,
            maritalStatus: string,
            dob: Date,
          ) => {
            // Generate unique test phone number
            const uniquePhone = `test_prop_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
            const passwordHash = await bcrypt.hash(
              'TestPassword123!',
              TEST_CONFIG.HASH_ROUNDS,
            );

            // Create first account
            const firstAccount = await prisma.account.create({
              data: {
                name: name1,
                phone: uniquePhone,
                passwordHash,
                gender: gender as any,
                maritalStatus: maritalStatus as any,
                dob,
              },
            });

            // Delete the first account
            await prisma.account.delete({ where: { id: firstAccount.id } });

            // Create second account with the same phone number (should succeed)
            const secondAccount = await prisma.account.create({
              data: {
                name: name2,
                phone: uniquePhone, // Reusing phone after deletion
                passwordHash,
                gender: gender as any,
                maritalStatus: maritalStatus as any,
                dob,
              },
            });

            // Verify second account was created successfully
            expect(secondAccount).toBeDefined();
            expect(secondAccount.phone).toBe(uniquePhone);

            // Clean up
            await prisma.account.delete({ where: { id: secondAccount.id } });
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should allow same email after account deletion', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.nameArb,
          generators.nameArb,
          generators.genderArb,
          generators.maritalStatusArb,
          generators.dobArb,
          async (
            name1: string,
            name2: string,
            gender: string,
            maritalStatus: string,
            dob: Date,
          ) => {
            // Generate unique test email and phone numbers
            const uniqueEmail = `test_${Date.now()}_${Math.random().toString(36).substring(2, 9)}@test-property.example.com`;
            const phone1 = `test_prop_${Date.now()}_${Math.random().toString(36).substring(2, 9)}_1`;
            const phone2 = `test_prop_${Date.now()}_${Math.random().toString(36).substring(2, 9)}_2`;
            const passwordHash = await bcrypt.hash(
              'TestPassword123!',
              TEST_CONFIG.HASH_ROUNDS,
            );

            // Create first account
            const firstAccount = await prisma.account.create({
              data: {
                name: name1,
                phone: phone1,
                email: uniqueEmail,
                passwordHash,
                gender: gender as any,
                maritalStatus: maritalStatus as any,
                dob,
              },
            });

            // Delete the first account
            await prisma.account.delete({ where: { id: firstAccount.id } });

            // Create second account with the same email (should succeed)
            const secondAccount = await prisma.account.create({
              data: {
                name: name2,
                phone: phone2,
                email: uniqueEmail, // Reusing email after deletion
                passwordHash,
                gender: gender as any,
                maritalStatus: maritalStatus as any,
                dob,
              },
            });

            // Verify second account was created successfully
            expect(secondAccount).toBeDefined();
            expect(secondAccount.email).toBe(uniqueEmail);

            // Clean up
            await prisma.account.delete({ where: { id: secondAccount.id } });
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
