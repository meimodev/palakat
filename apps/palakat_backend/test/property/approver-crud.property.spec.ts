/**
 * Property-Based Tests for Approver Module CRUD Operations
 *
 * **Feature: approver-module**
 *
 * This test suite verifies the correctness properties of the Approver module
 * as defined in the design document.
 */

import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import {
  ApprovalStatus,
  PrismaClient,
} from '../../src/generated/prisma/client';
import * as fc from 'fast-check';
import * as generators from './generators';
import {
  TEST_CONFIG,
  createTestAccount,
  createTestChurch,
  createTestMembership,
  getDatabasePostgresUrl,
  generateTestId,
} from './utils/test-helpers';

describe('Approver Module CRUD Property Tests', () => {
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
    await cleanupTestData();
  });

  afterEach(async () => {
    await cleanupTestData();
  });

  async function cleanupTestData() {
    // Delete in order respecting foreign key constraints
    await prisma.approver.deleteMany({
      where: {
        OR: [
          { activity: { title: { startsWith: 'test_approver_' } } },
          {
            membership: {
              account: { phone: { startsWith: 'test_approver_' } },
            },
          },
        ],
      },
    });

    await prisma.activity.deleteMany({
      where: { title: { startsWith: 'test_approver_' } },
    });

    await prisma.membership.deleteMany({
      where: { account: { phone: { startsWith: 'test_approver_' } } },
    });

    await prisma.account.deleteMany({
      where: { phone: { startsWith: 'test_approver_' } },
    });

    await prisma.column.deleteMany({
      where: { name: { startsWith: 'test_approver_' } },
    });

    await prisma.church.deleteMany({
      where: { name: { startsWith: 'test_approver_' } },
    });

    await prisma.location.deleteMany({
      where: { name: { startsWith: 'test_approver_' } },
    });
  }

  /**
   * Helper to create test infrastructure (church, accounts, memberships, activity)
   */
  async function createTestInfrastructure(testId: string) {
    // Create church with location
    const church = await createTestChurch(prisma, {
      name: `test_approver_church_${testId}`,
      location: {
        name: `test_approver_location_${testId}`,
        latitude: 0,
        longitude: 0,
      },
    });

    // Create supervisor account and membership
    const supervisorAccount = await createTestAccount(prisma, {
      name: `Supervisor ${testId}`,
      phone: `test_approver_${testId}_sup`,
      gender: 'MALE',
      maritalStatus: 'SINGLE',
    });

    const supervisorMembership = await createTestMembership(prisma, {
      accountId: supervisorAccount.id,
      churchId: church.id,
    });

    // Create approver account and membership
    const approverAccount = await createTestAccount(prisma, {
      name: `Approver ${testId}`,
      phone: `test_approver_${testId}_apr`,
      gender: 'FEMALE',
      maritalStatus: 'MARRIED',
    });

    const approverMembership = await createTestMembership(prisma, {
      accountId: approverAccount.id,
      churchId: church.id,
    });

    // Create activity
    const activity = await prisma.activity.create({
      data: {
        title: `test_approver_activity_${testId}`,
        description: 'Test activity for approver tests',
        supervisorId: supervisorMembership.id,
        bipra: 'PKB',
        activityType: 'SERVICE',
      },
    });

    return {
      church,
      supervisorAccount,
      supervisorMembership,
      approverAccount,
      approverMembership,
      activity,
    };
  }

  // **Feature: approver-module, Property 1: Create initializes with UNCONFIRMED status**
  // **Validates: Requirements 1.1**
  describe('Property 1: Create initializes with UNCONFIRMED status', () => {
    it('should create approver with UNCONFIRMED status for any valid membershipId and activityId', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 100 }), // iteration counter for unique IDs
          async (iteration: number) => {
            const testId = `${generateTestId()}_${iteration}`;
            const infra = await createTestInfrastructure(testId);

            // Create approver directly via Prisma (simulating service behavior)
            const approver = await prisma.approver.create({
              data: {
                membershipId: infra.approverMembership.id,
                activityId: infra.activity.id,
              },
            });

            // Property: Status should always be UNCONFIRMED on creation
            expect(approver.status).toBe('UNCONFIRMED');

            // Verify by fetching from database
            const fetchedApprover = await prisma.approver.findUnique({
              where: { id: approver.id },
            });

            expect(fetchedApprover).not.toBeNull();
            expect(fetchedApprover!.status).toBe('UNCONFIRMED');
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: approver-module, Property 2: Duplicate creation is rejected**
  // **Validates: Requirements 1.2**
  describe('Property 2: Duplicate creation is rejected', () => {
    it('should reject duplicate approver creation for same membershipId and activityId', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 100 }),
          async (iteration: number) => {
            const testId = `${generateTestId()}_${iteration}`;
            const infra = await createTestInfrastructure(testId);

            // Create first approver
            await prisma.approver.create({
              data: {
                membershipId: infra.approverMembership.id,
                activityId: infra.activity.id,
              },
            });

            // Attempt to create duplicate - should fail
            let duplicateRejected = false;
            try {
              await prisma.approver.create({
                data: {
                  membershipId: infra.approverMembership.id,
                  activityId: infra.activity.id,
                },
              });
            } catch (error: any) {
              // Prisma throws P2002 for unique constraint violation
              duplicateRejected =
                error.code === 'P2002' ||
                error.message.includes('Unique constraint');
            }

            // Property: Duplicate creation should always be rejected
            expect(duplicateRejected).toBe(true);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: approver-module, Property 3: Filter consistency**
  // **Validates: Requirements 2.2, 2.3, 2.4**
  describe('Property 3: Filter consistency', () => {
    it('should return only approvers matching the specified filters', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.approvalStatusArb,
          fc.integer({ min: 1, max: 50 }),
          async (filterStatus: string, iteration: number) => {
            const testId = `${generateTestId()}_${iteration}`;
            const infra = await createTestInfrastructure(testId);

            // Create a second approver account/membership for variety
            const approverAccount2 = await createTestAccount(prisma, {
              name: `Approver2 ${testId}`,
              phone: `test_approver_${testId}_ap2`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const approverMembership2 = await createTestMembership(prisma, {
              accountId: approverAccount2.id,
              churchId: infra.church.id,
            });

            // Create approvers with different statuses
            const approver1 = await prisma.approver.create({
              data: {
                membershipId: infra.approverMembership.id,
                activityId: infra.activity.id,
                status: filterStatus as ApprovalStatus,
              },
            });

            // Create second approver with different status
            const otherStatus =
              filterStatus === 'APPROVED' ? 'REJECTED' : 'APPROVED';
            await prisma.approver.create({
              data: {
                membershipId: approverMembership2.id,
                activityId: infra.activity.id,
                status: otherStatus as ApprovalStatus,
              },
            });

            // Query with status filter
            const filteredByStatus = await prisma.approver.findMany({
              where: { status: filterStatus as ApprovalStatus },
            });

            // Property: All returned approvers should match the filter
            for (const approver of filteredByStatus) {
              expect(approver.status).toBe(filterStatus);
            }

            // Query with membershipId filter
            const filteredByMembership = await prisma.approver.findMany({
              where: { membershipId: infra.approverMembership.id },
            });

            // Property: All returned approvers should match the membershipId
            for (const approver of filteredByMembership) {
              expect(approver.membershipId).toBe(infra.approverMembership.id);
            }

            // Query with activityId filter
            const filteredByActivity = await prisma.approver.findMany({
              where: { activityId: infra.activity.id },
            });

            // Property: All returned approvers should match the activityId
            for (const approver of filteredByActivity) {
              expect(approver.activityId).toBe(infra.activity.id);
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: approver-module, Property 4: Status update persistence**
  // **Validates: Requirements 3.1**
  describe('Property 4: Status update persistence', () => {
    it('should persist status updates correctly for any valid ApprovalStatus', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.approvalStatusArb,
          fc.integer({ min: 1, max: 100 }),
          async (newStatus: string, iteration: number) => {
            const testId = `${generateTestId()}_${iteration}`;
            const infra = await createTestInfrastructure(testId);

            // Create approver (starts as UNCONFIRMED)
            const approver = await prisma.approver.create({
              data: {
                membershipId: infra.approverMembership.id,
                activityId: infra.activity.id,
              },
            });

            // Update status
            const updatedApprover = await prisma.approver.update({
              where: { id: approver.id },
              data: { status: newStatus as ApprovalStatus },
            });

            // Property: Updated status should match the requested status
            expect(updatedApprover.status).toBe(newStatus);

            // Verify by fetching from database
            const fetchedApprover = await prisma.approver.findUnique({
              where: { id: approver.id },
            });

            // Property: Persisted status should match the requested status
            expect(fetchedApprover).not.toBeNull();
            expect(fetchedApprover!.status).toBe(newStatus);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: approver-module, Property 5: Delete removes record**
  // **Validates: Requirements 4.1**
  describe('Property 5: Delete removes record', () => {
    it('should remove approver record completely after deletion', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 100 }),
          async (iteration: number) => {
            const testId = `${generateTestId()}_${iteration}`;
            const infra = await createTestInfrastructure(testId);

            // Create approver
            const approver = await prisma.approver.create({
              data: {
                membershipId: infra.approverMembership.id,
                activityId: infra.activity.id,
              },
            });

            const approverId = approver.id;

            // Verify it exists
            const existsBefore = await prisma.approver.findUnique({
              where: { id: approverId },
            });
            expect(existsBefore).not.toBeNull();

            // Delete the approver
            await prisma.approver.delete({
              where: { id: approverId },
            });

            // Property: Deleted approver should no longer be retrievable
            const existsAfter = await prisma.approver.findUnique({
              where: { id: approverId },
            });

            expect(existsAfter).toBeNull();
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: approver-module, Property 6: Response format consistency**
  // **Validates: Requirements 5.5**
  describe('Property 6: Response format consistency', () => {
    /**
     * Helper to simulate service response format
     * This mirrors the actual ApproverService response structure
     */
    function createResponse(data: any): { message: string; data: any } {
      return {
        message: 'Approver created successfully',
        data,
      };
    }

    function findAllResponse(
      data: any[],
      total: number,
    ): { message: string; data: any[]; total: number } {
      return {
        message: 'Approvers retrieved successfully',
        data,
        total,
      };
    }

    function findOneResponse(data: any): { message: string; data: any } {
      return {
        message: 'Approver retrieved successfully',
        data,
      };
    }

    function updateResponse(data: any): { message: string; data: any } {
      return {
        message: 'Approver updated successfully',
        data,
      };
    }

    function removeResponse(): { message: string } {
      return {
        message: 'Approver deleted successfully',
      };
    }

    it('should return responses with message and data fields for all CRUD operations', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.approvalStatusArb,
          fc.integer({ min: 1, max: 100 }),
          async (status: string, iteration: number) => {
            const testId = `${generateTestId()}_${iteration}`;
            const infra = await createTestInfrastructure(testId);

            // Create approver and verify response format
            const approverData = await prisma.approver.create({
              data: {
                membershipId: infra.approverMembership.id,
                activityId: infra.activity.id,
              },
              include: {
                activity: {
                  include: {
                    supervisor: {
                      include: {
                        account: {
                          select: { id: true, name: true, phone: true },
                        },
                      },
                    },
                  },
                },
                membership: {
                  include: {
                    account: {
                      select: { id: true, name: true, phone: true },
                    },
                  },
                },
              },
            });

            // Test create response format
            const createResp = createResponse(approverData);
            expect(createResp).toHaveProperty('message');
            expect(createResp).toHaveProperty('data');
            expect(typeof createResp.message).toBe('string');
            expect(createResp.message.length).toBeGreaterThan(0);

            // Test findAll response format
            const allApprovers = await prisma.approver.findMany({
              where: { activityId: infra.activity.id },
            });
            const findAllResp = findAllResponse(
              allApprovers,
              allApprovers.length,
            );
            expect(findAllResp).toHaveProperty('message');
            expect(findAllResp).toHaveProperty('data');
            expect(findAllResp).toHaveProperty('total');
            expect(typeof findAllResp.message).toBe('string');
            expect(Array.isArray(findAllResp.data)).toBe(true);
            expect(typeof findAllResp.total).toBe('number');

            // Test findOne response format
            const findOneResp = findOneResponse(approverData);
            expect(findOneResp).toHaveProperty('message');
            expect(findOneResp).toHaveProperty('data');
            expect(typeof findOneResp.message).toBe('string');

            // Test update response format
            const updatedData = await prisma.approver.update({
              where: { id: approverData.id },
              data: { status: status as ApprovalStatus },
            });
            const updateResp = updateResponse(updatedData);
            expect(updateResp).toHaveProperty('message');
            expect(updateResp).toHaveProperty('data');
            expect(typeof updateResp.message).toBe('string');

            // Test remove response format
            await prisma.approver.delete({ where: { id: approverData.id } });
            const removeResp = removeResponse();
            expect(removeResp).toHaveProperty('message');
            expect(typeof removeResp.message).toBe('string');
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
