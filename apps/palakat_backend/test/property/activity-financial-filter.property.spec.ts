/**
 * Property-Based Tests for Activity Financial Filtering
 *
 * **Feature: activity-financial-filter, Property 1: hasExpense filter correctness**
 * **Validates: Requirements 1.1, 1.2**
 *
 * This test suite verifies that the hasExpense filter correctly filters activities
 * based on the presence or absence of associated expense records.
 */

import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import {
  ActivityType,
  FinancialType,
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
import { ActivitiesService } from '../../src/activity/activity.service';
import { PrismaService } from '../../src/prisma.service';
import { ApproverResolverService } from '../../src/activity/approver-resolver.service';
import { NotificationService } from '../../src/notification/notification.service';

describe('Activity Financial Filter Property Tests', () => {
  let prisma: PrismaClient;
  let pool: Pool;
  let prismaService: PrismaService;
  let activitiesService: ActivitiesService;
  let approverResolverService: ApproverResolverService;
  let notificationService: NotificationService;

  beforeAll(() => {
    pool = new Pool({
      connectionString: getDatabasePostgresUrl(),
      allowExitOnIdle: true,
    });
    const adapter = new PrismaPg(pool);
    prisma = new PrismaClient({ adapter });
    prismaService = prisma as unknown as PrismaService;
    approverResolverService = new ApproverResolverService(prismaService);
    // Create a mock NotificationService that does nothing
    notificationService = {
      notifyActivityCreated: async () => {},
      notifyApprovalStatusChanged: async () => {},
    } as unknown as NotificationService;
    activitiesService = new ActivitiesService(
      prismaService,
      approverResolverService,
      notificationService,
    );
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
    const prefix = 'test_prop_aff_';

    await prisma.approver.deleteMany({
      where: {
        activity: {
          title: { startsWith: prefix },
        },
      },
    });

    await prisma.revenue.deleteMany({
      where: {
        activity: {
          title: { startsWith: prefix },
        },
      },
    });

    await prisma.expense.deleteMany({
      where: {
        activity: {
          title: { startsWith: prefix },
        },
      },
    });

    await prisma.activity.deleteMany({
      where: {
        title: { startsWith: prefix },
      },
    });

    await (prisma as any).financialAccountNumber.deleteMany({
      where: {
        accountNumber: { startsWith: prefix },
      },
    });

    await prisma.membership.deleteMany({
      where: {
        account: {
          phone: { startsWith: prefix },
        },
      },
    });

    await prisma.account.deleteMany({
      where: {
        phone: { startsWith: prefix },
      },
    });

    await prisma.column.deleteMany({
      where: {
        name: { startsWith: prefix },
      },
    });

    await prisma.church.deleteMany({
      where: {
        name: { startsWith: prefix },
      },
    });

    await prisma.location.deleteMany({
      where: {
        name: { startsWith: prefix },
      },
    });
  }

  /**
   * **Feature: activity-financial-filter, Property 1: hasExpense filter correctness**
   * **Validates: Requirements 1.1, 1.2**
   *
   * Property: For any set of activities and any boolean value for hasExpense,
   * when the filter is applied, all returned activities SHALL have an expense
   * record if hasExpense=true, and no returned activities SHALL have an expense
   * record if hasExpense=false.
   */
  describe('Property 1: hasExpense filter correctness', () => {
    it('should return only activities with expense when hasExpense=true', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 5 }), // Number of activities with expense
          fc.integer({ min: 1, max: 5 }), // Number of activities without expense
          generators.activityTypeArb,
          async (
            numWithExpense: number,
            numWithoutExpense: number,
            activityType: string,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_aff_${testId}`;

            // Create test church
            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create financial account number for expenses
            const financialAccountNumber = await (
              prisma as any
            ).financialAccountNumber.create({
              data: {
                accountNumber: `${prefix}_account`,
                description: 'Test account',
                type: FinancialType.EXPENSE,
                churchId: church.id,
              },
            });

            const activitiesWithExpense: number[] = [];
            const activitiesWithoutExpense: number[] = [];

            // Create activities WITH expense
            for (let i = 0; i < numWithExpense; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_activity_with_expense_${i}`,
                  description: `Activity with expense ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              // Create expense for this activity
              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${i}`,
                  amount: 100000 + i * 10000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activitiesWithExpense.push(activity.id);
            }

            // Create activities WITHOUT expense
            for (let i = 0; i < numWithoutExpense; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_activity_without_expense_${i}`,
                  description: `Activity without expense ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              activitiesWithoutExpense.push(activity.id);
            }

            // Call the service with hasExpense=true
            const result = await activitiesService.findAll({
              churchId: church.id,
              hasExpense: true,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: All returned activities should have expense
            expect(result.data.length).toBe(numWithExpense);
            expect(result.total).toBe(numWithExpense);

            for (const activity of result.data) {
              expect(activity.hasExpense).toBe(true);
              expect(activitiesWithExpense).toContain(activity.id);
            }

            // Property: No activities without expense should be returned
            for (const activity of result.data) {
              expect(activitiesWithoutExpense).not.toContain(activity.id);
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should return only activities without expense when hasExpense=false', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 5 }), // Number of activities with expense
          fc.integer({ min: 1, max: 5 }), // Number of activities without expense
          generators.activityTypeArb,
          async (
            numWithExpense: number,
            numWithoutExpense: number,
            activityType: string,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_aff_${testId}`;

            // Create test church
            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create financial account number for expenses
            const financialAccountNumber = await (
              prisma as any
            ).financialAccountNumber.create({
              data: {
                accountNumber: `${prefix}_account`,
                description: 'Test account',
                type: FinancialType.EXPENSE,
                churchId: church.id,
              },
            });

            const activitiesWithExpense: number[] = [];
            const activitiesWithoutExpense: number[] = [];

            // Create activities WITH expense
            for (let i = 0; i < numWithExpense; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_activity_with_expense_${i}`,
                  description: `Activity with expense ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              // Create expense for this activity
              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${i}`,
                  amount: 100000 + i * 10000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activitiesWithExpense.push(activity.id);
            }

            // Create activities WITHOUT expense
            for (let i = 0; i < numWithoutExpense; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_activity_without_expense_${i}`,
                  description: `Activity without expense ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              activitiesWithoutExpense.push(activity.id);
            }

            // Call the service with hasExpense=false
            const result = await activitiesService.findAll({
              churchId: church.id,
              hasExpense: false,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: All returned activities should NOT have expense
            expect(result.data.length).toBe(numWithoutExpense);
            expect(result.total).toBe(numWithoutExpense);

            for (const activity of result.data) {
              expect(activity.hasExpense).toBe(false);
              expect(activitiesWithoutExpense).toContain(activity.id);
            }

            // Property: No activities with expense should be returned
            for (const activity of result.data) {
              expect(activitiesWithExpense).not.toContain(activity.id);
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should work correctly with mixed financial states', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 3 }), // Activities with expense only
          fc.integer({ min: 1, max: 3 }), // Activities with revenue only
          fc.integer({ min: 1, max: 3 }), // Activities with both
          fc.integer({ min: 1, max: 3 }), // Activities with neither
          generators.activityTypeArb,
          async (
            numExpenseOnly: number,
            numRevenueOnly: number,
            numBoth: number,
            numNeither: number,
            activityType: string,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_aff_${testId}`;

            // Create test church
            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create financial account number
            const financialAccountNumber = await (
              prisma as any
            ).financialAccountNumber.create({
              data: {
                accountNumber: `${prefix}_account`,
                description: 'Test account',
                type: FinancialType.EXPENSE,
                churchId: church.id,
              },
            });

            let expenseCount = 0;
            let revenueCount = 0;

            // Create activities with expense only
            for (let i = 0; i < numExpenseOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_expense_only_${i}`,
                  description: `Expense only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${expenseCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });
            }

            // Create activities with revenue only
            for (let i = 0; i < numRevenueOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_revenue_only_${i}`,
                  description: `Revenue only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${revenueCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });
            }

            // Create activities with both expense and revenue
            for (let i = 0; i < numBoth; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_both_${i}`,
                  description: `Both ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${expenseCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${revenueCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });
            }

            // Create activities with neither
            for (let i = 0; i < numNeither; i++) {
              await prisma.activity.create({
                data: {
                  title: `${prefix}_neither_${i}`,
                  description: `Neither ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });
            }

            // Test hasExpense=true
            const resultWithExpense = await activitiesService.findAll({
              churchId: church.id,
              hasExpense: true,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: Should return activities with expense (expense only + both)
            const expectedWithExpense = numExpenseOnly + numBoth;
            expect(resultWithExpense.total).toBe(expectedWithExpense);
            expect(resultWithExpense.data.length).toBe(expectedWithExpense);

            for (const activity of resultWithExpense.data) {
              expect(activity.hasExpense).toBe(true);
            }

            // Test hasExpense=false
            const resultWithoutExpense = await activitiesService.findAll({
              churchId: church.id,
              hasExpense: false,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: Should return activities without expense (revenue only + neither)
            const expectedWithoutExpense = numRevenueOnly + numNeither;
            expect(resultWithoutExpense.total).toBe(expectedWithoutExpense);
            expect(resultWithoutExpense.data.length).toBe(
              expectedWithoutExpense,
            );

            for (const activity of resultWithoutExpense.data) {
              expect(activity.hasExpense).toBe(false);
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  /**
   * **Feature: activity-financial-filter, Property 2: hasRevenue filter correctness**
   * **Validates: Requirements 1.3, 1.4**
   *
   * Property: For any set of activities and any boolean value for hasRevenue,
   * when the filter is applied, all returned activities SHALL have a revenue
   * record if hasRevenue=true, and no returned activities SHALL have a revenue
   * record if hasRevenue=false.
   */
  describe('Property 2: hasRevenue filter correctness', () => {
    it('should return only activities with revenue when hasRevenue=true', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 5 }), // Number of activities with revenue
          fc.integer({ min: 1, max: 5 }), // Number of activities without revenue
          generators.activityTypeArb,
          async (
            numWithRevenue: number,
            numWithoutRevenue: number,
            activityType: string,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_aff_${testId}`;

            // Create test church
            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create financial account number for revenues
            const financialAccountNumber = await (
              prisma as any
            ).financialAccountNumber.create({
              data: {
                accountNumber: `${prefix}_account`,
                description: 'Test account',
                type: FinancialType.REVENUE,
                churchId: church.id,
              },
            });

            const activitiesWithRevenue: number[] = [];
            const activitiesWithoutRevenue: number[] = [];

            // Create activities WITH revenue
            for (let i = 0; i < numWithRevenue; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_activity_with_revenue_${i}`,
                  description: `Activity with revenue ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              // Create revenue for this activity
              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${i}`,
                  amount: 100000 + i * 10000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activitiesWithRevenue.push(activity.id);
            }

            // Create activities WITHOUT revenue
            for (let i = 0; i < numWithoutRevenue; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_activity_without_revenue_${i}`,
                  description: `Activity without revenue ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              activitiesWithoutRevenue.push(activity.id);
            }

            // Call the service with hasRevenue=true
            const result = await activitiesService.findAll({
              churchId: church.id,
              hasRevenue: true,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: All returned activities should have revenue
            expect(result.data.length).toBe(numWithRevenue);
            expect(result.total).toBe(numWithRevenue);

            for (const activity of result.data) {
              expect(activity.hasRevenue).toBe(true);
              expect(activitiesWithRevenue).toContain(activity.id);
            }

            // Property: No activities without revenue should be returned
            for (const activity of result.data) {
              expect(activitiesWithoutRevenue).not.toContain(activity.id);
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should return only activities without revenue when hasRevenue=false', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 5 }), // Number of activities with revenue
          fc.integer({ min: 1, max: 5 }), // Number of activities without revenue
          generators.activityTypeArb,
          async (
            numWithRevenue: number,
            numWithoutRevenue: number,
            activityType: string,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_aff_${testId}`;

            // Create test church
            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create financial account number for revenues
            const financialAccountNumber = await (
              prisma as any
            ).financialAccountNumber.create({
              data: {
                accountNumber: `${prefix}_account`,
                description: 'Test account',
                type: FinancialType.REVENUE,
                churchId: church.id,
              },
            });

            const activitiesWithRevenue: number[] = [];
            const activitiesWithoutRevenue: number[] = [];

            // Create activities WITH revenue
            for (let i = 0; i < numWithRevenue; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_activity_with_revenue_${i}`,
                  description: `Activity with revenue ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              // Create revenue for this activity
              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${i}`,
                  amount: 100000 + i * 10000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activitiesWithRevenue.push(activity.id);
            }

            // Create activities WITHOUT revenue
            for (let i = 0; i < numWithoutRevenue; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_activity_without_revenue_${i}`,
                  description: `Activity without revenue ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              activitiesWithoutRevenue.push(activity.id);
            }

            // Call the service with hasRevenue=false
            const result = await activitiesService.findAll({
              churchId: church.id,
              hasRevenue: false,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: All returned activities should NOT have revenue
            expect(result.data.length).toBe(numWithoutRevenue);
            expect(result.total).toBe(numWithoutRevenue);

            for (const activity of result.data) {
              expect(activity.hasRevenue).toBe(false);
              expect(activitiesWithoutRevenue).toContain(activity.id);
            }

            // Property: No activities with revenue should be returned
            for (const activity of result.data) {
              expect(activitiesWithRevenue).not.toContain(activity.id);
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should work correctly with mixed financial states', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 3 }), // Activities with expense only
          fc.integer({ min: 1, max: 3 }), // Activities with revenue only
          fc.integer({ min: 1, max: 3 }), // Activities with both
          fc.integer({ min: 1, max: 3 }), // Activities with neither
          generators.activityTypeArb,
          async (
            numExpenseOnly: number,
            numRevenueOnly: number,
            numBoth: number,
            numNeither: number,
            activityType: string,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_aff_${testId}`;

            // Create test church
            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create financial account number
            const financialAccountNumber = await (
              prisma as any
            ).financialAccountNumber.create({
              data: {
                accountNumber: `${prefix}_account`,
                description: 'Test account',
                type: FinancialType.REVENUE,
                churchId: church.id,
              },
            });

            let expenseCount = 0;
            let revenueCount = 0;

            // Create activities with expense only
            for (let i = 0; i < numExpenseOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_expense_only_${i}`,
                  description: `Expense only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${expenseCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });
            }

            // Create activities with revenue only
            for (let i = 0; i < numRevenueOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_revenue_only_${i}`,
                  description: `Revenue only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${revenueCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });
            }

            // Create activities with both expense and revenue
            for (let i = 0; i < numBoth; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_both_${i}`,
                  description: `Both ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${expenseCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${revenueCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });
            }

            // Create activities with neither
            for (let i = 0; i < numNeither; i++) {
              await prisma.activity.create({
                data: {
                  title: `${prefix}_neither_${i}`,
                  description: `Neither ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });
            }

            // Test hasRevenue=true
            const resultWithRevenue = await activitiesService.findAll({
              churchId: church.id,
              hasRevenue: true,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: Should return activities with revenue (revenue only + both)
            const expectedWithRevenue = numRevenueOnly + numBoth;
            expect(resultWithRevenue.total).toBe(expectedWithRevenue);
            expect(resultWithRevenue.data.length).toBe(expectedWithRevenue);

            for (const activity of resultWithRevenue.data) {
              expect(activity.hasRevenue).toBe(true);
            }

            // Test hasRevenue=false
            const resultWithoutRevenue = await activitiesService.findAll({
              churchId: church.id,
              hasRevenue: false,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: Should return activities without revenue (expense only + neither)
            const expectedWithoutRevenue = numExpenseOnly + numNeither;
            expect(resultWithoutRevenue.total).toBe(expectedWithoutRevenue);
            expect(resultWithoutRevenue.data.length).toBe(
              expectedWithoutRevenue,
            );

            for (const activity of resultWithoutRevenue.data) {
              expect(activity.hasRevenue).toBe(false);
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  /**
   * **Feature: activity-financial-filter, Property 3: No filter returns all financial states**
   * **Validates: Requirements 1.5**
   *
   * Property: For any set of activities, when neither hasExpense nor hasRevenue
   * filters are provided, the returned activities SHALL include activities with
   * any combination of financial records (with expense only, with revenue only,
   * with both, with neither).
   */
  describe('Property 3: No filter returns all financial states', () => {
    it('should return all activities regardless of financial state when no filters are provided', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 3 }), // Activities with expense only
          fc.integer({ min: 1, max: 3 }), // Activities with revenue only
          fc.integer({ min: 1, max: 3 }), // Activities with both
          fc.integer({ min: 1, max: 3 }), // Activities with neither
          generators.activityTypeArb,
          async (
            numExpenseOnly: number,
            numRevenueOnly: number,
            numBoth: number,
            numNeither: number,
            activityType: string,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_aff_${testId}`;

            // Create test church
            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create financial account number
            const financialAccountNumber = await (
              prisma as any
            ).financialAccountNumber.create({
              data: {
                accountNumber: `${prefix}_account`,
                description: 'Test account',
                type: FinancialType.EXPENSE,
                churchId: church.id,
              },
            });

            let expenseCount = 0;
            let revenueCount = 0;

            const activityIds = {
              expenseOnly: [] as number[],
              revenueOnly: [] as number[],
              both: [] as number[],
              neither: [] as number[],
            };

            // Create activities with expense only
            for (let i = 0; i < numExpenseOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_expense_only_${i}`,
                  description: `Expense only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${expenseCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activityIds.expenseOnly.push(activity.id);
            }

            // Create activities with revenue only
            for (let i = 0; i < numRevenueOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_revenue_only_${i}`,
                  description: `Revenue only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${revenueCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activityIds.revenueOnly.push(activity.id);
            }

            // Create activities with both expense and revenue
            for (let i = 0; i < numBoth; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_both_${i}`,
                  description: `Both ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${expenseCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${revenueCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activityIds.both.push(activity.id);
            }

            // Create activities with neither
            for (let i = 0; i < numNeither; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_neither_${i}`,
                  description: `Neither ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              activityIds.neither.push(activity.id);
            }

            // Call the service WITHOUT any financial filters
            const result = await activitiesService.findAll({
              churchId: church.id,
              // No hasExpense or hasRevenue filters
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: Should return ALL activities regardless of financial state
            const totalExpected =
              numExpenseOnly + numRevenueOnly + numBoth + numNeither;
            expect(result.total).toBe(totalExpected);
            expect(result.data.length).toBe(totalExpected);

            // Property: Result should include activities from all financial states
            const returnedIds = result.data.map((a) => a.id);

            // Verify all expense-only activities are included
            for (const id of activityIds.expenseOnly) {
              expect(returnedIds).toContain(id);
            }

            // Verify all revenue-only activities are included
            for (const id of activityIds.revenueOnly) {
              expect(returnedIds).toContain(id);
            }

            // Verify all activities with both are included
            for (const id of activityIds.both) {
              expect(returnedIds).toContain(id);
            }

            // Verify all activities with neither are included
            for (const id of activityIds.neither) {
              expect(returnedIds).toContain(id);
            }

            // Property: Verify the financial state flags are correct
            for (const activity of result.data) {
              if (activityIds.expenseOnly.includes(activity.id)) {
                expect(activity.hasExpense).toBe(true);
                expect(activity.hasRevenue).toBe(false);
              } else if (activityIds.revenueOnly.includes(activity.id)) {
                expect(activity.hasExpense).toBe(false);
                expect(activity.hasRevenue).toBe(true);
              } else if (activityIds.both.includes(activity.id)) {
                expect(activity.hasExpense).toBe(true);
                expect(activity.hasRevenue).toBe(true);
              } else if (activityIds.neither.includes(activity.id)) {
                expect(activity.hasExpense).toBe(false);
                expect(activity.hasRevenue).toBe(false);
              }
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  /**
   * **Feature: activity-financial-filter, Property 4: Combined filter AND logic**
   * **Validates: Requirements 1.6, 1.7, 1.8**
   *
   * Property: For any set of activities and any combination of hasExpense and
   * hasRevenue values, the returned activities SHALL satisfy ALL filter conditions
   * simultaneously (AND logic).
   */
  describe('Property 4: Combined filter AND logic', () => {
    it('should return only activities with neither expense nor revenue when both filters are false', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 3 }), // Activities with expense only
          fc.integer({ min: 1, max: 3 }), // Activities with revenue only
          fc.integer({ min: 1, max: 3 }), // Activities with both
          fc.integer({ min: 1, max: 3 }), // Activities with neither
          generators.activityTypeArb,
          async (
            numExpenseOnly: number,
            numRevenueOnly: number,
            numBoth: number,
            numNeither: number,
            activityType: string,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_aff_${testId}`;

            // Create test church
            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create financial account number
            const financialAccountNumber = await (
              prisma as any
            ).financialAccountNumber.create({
              data: {
                accountNumber: `${prefix}_account`,
                description: 'Test account',
                type: FinancialType.EXPENSE,
                churchId: church.id,
              },
            });

            let expenseCount = 0;
            let revenueCount = 0;

            const activityIds = {
              expenseOnly: [] as number[],
              revenueOnly: [] as number[],
              both: [] as number[],
              neither: [] as number[],
            };

            // Create activities with expense only
            for (let i = 0; i < numExpenseOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_expense_only_${i}`,
                  description: `Expense only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${expenseCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activityIds.expenseOnly.push(activity.id);
            }

            // Create activities with revenue only
            for (let i = 0; i < numRevenueOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_revenue_only_${i}`,
                  description: `Revenue only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${revenueCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activityIds.revenueOnly.push(activity.id);
            }

            // Create activities with both expense and revenue
            for (let i = 0; i < numBoth; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_both_${i}`,
                  description: `Both ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${expenseCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${revenueCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activityIds.both.push(activity.id);
            }

            // Create activities with neither
            for (let i = 0; i < numNeither; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_neither_${i}`,
                  description: `Neither ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              activityIds.neither.push(activity.id);
            }

            // Test hasExpense=false AND hasRevenue=false
            // Property: Should return ONLY activities with neither expense nor revenue
            const result = await activitiesService.findAll({
              churchId: church.id,
              hasExpense: false,
              hasRevenue: false,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: Should return only activities with neither
            expect(result.total).toBe(numNeither);
            expect(result.data.length).toBe(numNeither);

            // Property: All returned activities should have neither expense nor revenue
            for (const activity of result.data) {
              expect(activity.hasExpense).toBe(false);
              expect(activity.hasRevenue).toBe(false);
              expect(activityIds.neither).toContain(activity.id);
            }

            // Property: No activities with expense should be returned
            const returnedIds = result.data.map((a) => a.id);
            for (const id of activityIds.expenseOnly) {
              expect(returnedIds).not.toContain(id);
            }

            // Property: No activities with revenue should be returned
            for (const id of activityIds.revenueOnly) {
              expect(returnedIds).not.toContain(id);
            }

            // Property: No activities with both should be returned
            for (const id of activityIds.both) {
              expect(returnedIds).not.toContain(id);
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should return only activities with both expense and revenue when both filters are true', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 3 }), // Activities with expense only
          fc.integer({ min: 1, max: 3 }), // Activities with revenue only
          fc.integer({ min: 1, max: 3 }), // Activities with both
          fc.integer({ min: 1, max: 3 }), // Activities with neither
          generators.activityTypeArb,
          async (
            numExpenseOnly: number,
            numRevenueOnly: number,
            numBoth: number,
            numNeither: number,
            activityType: string,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_aff_${testId}`;

            // Create test church
            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create financial account number
            const financialAccountNumber = await (
              prisma as any
            ).financialAccountNumber.create({
              data: {
                accountNumber: `${prefix}_account`,
                description: 'Test account',
                type: FinancialType.EXPENSE,
                churchId: church.id,
              },
            });

            let expenseCount = 0;
            let revenueCount = 0;

            const activityIds = {
              expenseOnly: [] as number[],
              revenueOnly: [] as number[],
              both: [] as number[],
              neither: [] as number[],
            };

            // Create activities with expense only
            for (let i = 0; i < numExpenseOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_expense_only_${i}`,
                  description: `Expense only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${expenseCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activityIds.expenseOnly.push(activity.id);
            }

            // Create activities with revenue only
            for (let i = 0; i < numRevenueOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_revenue_only_${i}`,
                  description: `Revenue only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${revenueCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activityIds.revenueOnly.push(activity.id);
            }

            // Create activities with both expense and revenue
            for (let i = 0; i < numBoth; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_both_${i}`,
                  description: `Both ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_${expenseCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              await prisma.revenue.create({
                data: {
                  accountNumber: `${prefix}_rev_${revenueCount++}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              activityIds.both.push(activity.id);
            }

            // Create activities with neither
            for (let i = 0; i < numNeither; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_neither_${i}`,
                  description: `Neither ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: activityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              activityIds.neither.push(activity.id);
            }

            // Test hasExpense=true AND hasRevenue=true
            // Property: Should return ONLY activities with both expense and revenue
            const result = await activitiesService.findAll({
              churchId: church.id,
              hasExpense: true,
              hasRevenue: true,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: Should return only activities with both
            expect(result.total).toBe(numBoth);
            expect(result.data.length).toBe(numBoth);

            // Property: All returned activities should have both expense and revenue
            for (const activity of result.data) {
              expect(activity.hasExpense).toBe(true);
              expect(activity.hasRevenue).toBe(true);
              expect(activityIds.both).toContain(activity.id);
            }

            // Property: No activities with only expense should be returned
            const returnedIds = result.data.map((a) => a.id);
            for (const id of activityIds.expenseOnly) {
              expect(returnedIds).not.toContain(id);
            }

            // Property: No activities with only revenue should be returned
            for (const id of activityIds.revenueOnly) {
              expect(returnedIds).not.toContain(id);
            }

            // Property: No activities with neither should be returned
            for (const id of activityIds.neither) {
              expect(returnedIds).not.toContain(id);
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should correctly combine financial filters with other existing filters', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 2, max: 4 }), // Activities matching all filters
          fc.integer({ min: 1, max: 3 }), // Activities matching only financial filters
          fc.integer({ min: 1, max: 3 }), // Activities matching only other filters
          generators.activityTypeArb,
          fc.constantFrom(
            'ANNOUNCEMENT',
            'SERVICE',
            'EVENT',
          ) as fc.Arbitrary<ActivityType>,
          async (
            numMatchingAll: number,
            numMatchingFinancialOnly: number,
            numMatchingOtherOnly: number,
            searchActivityType: string,
            filterActivityType: ActivityType,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_aff_${testId}`;

            // Create test church
            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create financial account number
            const financialAccountNumber = await (
              prisma as any
            ).financialAccountNumber.create({
              data: {
                accountNumber: `${prefix}_account`,
                description: 'Test account',
                type: FinancialType.EXPENSE,
                churchId: church.id,
              },
            });

            const matchingAllIds: number[] = [];
            const matchingFinancialOnlyIds: number[] = [];
            const matchingOtherOnlyIds: number[] = [];

            // Create activities matching ALL filters (financial + activityType)
            for (let i = 0; i < numMatchingAll; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_matching_all_${i}`,
                  description: `Matching all ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: filterActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              // Add expense to match hasExpense=true
              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_all_${i}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              matchingAllIds.push(activity.id);
            }

            // Create activities matching ONLY financial filters (wrong activityType)
            const otherActivityType =
              filterActivityType === 'ANNOUNCEMENT'
                ? 'SERVICE'
                : 'ANNOUNCEMENT';
            for (let i = 0; i < numMatchingFinancialOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_matching_financial_${i}`,
                  description: `Matching financial only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: otherActivityType as ActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              // Add expense to match hasExpense=true
              await prisma.expense.create({
                data: {
                  accountNumber: `${prefix}_exp_fin_${i}`,
                  amount: 100000,
                  paymentMethod: 'CASH',
                  churchId: church.id,
                  activityId: activity.id,
                  financialAccountNumberId: financialAccountNumber.id,
                },
              });

              matchingFinancialOnlyIds.push(activity.id);
            }

            // Create activities matching ONLY other filters (no expense)
            for (let i = 0; i < numMatchingOtherOnly; i++) {
              const activity = await prisma.activity.create({
                data: {
                  title: `${prefix}_matching_other_${i}`,
                  description: `Matching other only ${i}`,
                  date: new Date(),
                  bipra: 'PKB',
                  activityType: filterActivityType,
                  supervisorId: supervisorMembership.id,
                },
              });

              // No expense - doesn't match hasExpense=true

              matchingOtherOnlyIds.push(activity.id);
            }

            // Test combined filters: hasExpense=true AND activityType
            const result = await activitiesService.findAll({
              churchId: church.id,
              hasExpense: true,
              activityType: filterActivityType,
              page: 1,
              pageSize: 100,
              skip: 0,
              take: 100,
            });

            // Property: Should return ONLY activities matching ALL filters (AND logic)
            expect(result.total).toBe(numMatchingAll);
            expect(result.data.length).toBe(numMatchingAll);

            // Property: All returned activities should match all filters
            const returnedIds = result.data.map((a) => a.id);
            for (const activity of result.data) {
              expect(activity.hasExpense).toBe(true);
              expect(activity.activityType).toBe(filterActivityType);
              expect(matchingAllIds).toContain(activity.id);
            }

            // Property: Activities matching only financial filters should NOT be returned
            for (const id of matchingFinancialOnlyIds) {
              expect(returnedIds).not.toContain(id);
            }

            // Property: Activities matching only other filters should NOT be returned
            for (const id of matchingOtherOnlyIds) {
              expect(returnedIds).not.toContain(id);
            }
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
