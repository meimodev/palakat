/**
 * Property-Based Tests for Activity Response Consistency
 *
 * **Feature: activity-financial-filter, Properties 6, 7, 8**
 * **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
 */

import { PrismaClient } from '@prisma/client';
import * as fc from 'fast-check';
import {
  TEST_CONFIG,
  createTestAccount,
  createTestChurch,
  createTestMembership,
  generateTestId,
} from './utils/test-helpers';
import { ActivitiesService } from '../../src/activity/activity.service';
import { ApproverResolverService } from '../../src/activity/approver-resolver.service';
import { PrismaService } from '../../src/prisma.service';

describe('Activity Response Consistency Property Tests', () => {
  let prisma: PrismaClient;
  let prismaService: PrismaService;
  let activitiesService: ActivitiesService;
  let approverResolverService: ApproverResolverService;
  let testChurch: any;
  let testMembership: any;
  let testActivities: any[] = [];
  const TEST_PREFIX = 'test_prop_arc_';

  beforeAll(async () => {
    prisma = new PrismaClient();
    prismaService = prisma as unknown as PrismaService;
    approverResolverService = new ApproverResolverService(prismaService);
    activitiesService = new ActivitiesService(
      prismaService,
      approverResolverService,
    );
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    await cleanupTestData();
    await setupTestData();
  });

  afterEach(async () => {
    await cleanupTestData();
  });

  async function cleanupTestData() {
    await prisma.approver.deleteMany({
      where: { activity: { title: { startsWith: TEST_PREFIX } } },
    });
    await prisma.revenue.deleteMany({
      where: { activity: { title: { startsWith: TEST_PREFIX } } },
    });
    await prisma.expense.deleteMany({
      where: { activity: { title: { startsWith: TEST_PREFIX } } },
    });
    await prisma.activity.deleteMany({
      where: { title: { startsWith: TEST_PREFIX } },
    });
    await prisma.membership.deleteMany({
      where: { account: { phone: { startsWith: TEST_PREFIX } } },
    });
    await prisma.account.deleteMany({
      where: { phone: { startsWith: TEST_PREFIX } },
    });
    await prisma.column.deleteMany({
      where: { name: { startsWith: TEST_PREFIX } },
    });
    await prisma.church.deleteMany({
      where: { name: { startsWith: TEST_PREFIX } },
    });
    await prisma.location.deleteMany({
      where: { name: { startsWith: TEST_PREFIX } },
    });
  }

  async function setupTestData() {
    const testId = generateTestId();
    testChurch = await createTestChurch(prisma, {
      name: `${TEST_PREFIX}church_${testId}`,
      location: {
        name: `${TEST_PREFIX}location_${testId}`,
        latitude: 0,
        longitude: 0,
      },
    });
    const supervisorAccount = await createTestAccount(prisma, {
      name: `Supervisor ${testId}`,
      phone: `${TEST_PREFIX}supervisor_${testId}`,
      gender: 'MALE',
      maritalStatus: 'SINGLE',
    });
    testMembership = await createTestMembership(prisma, {
      accountId: supervisorAccount.id,
      churchId: testChurch.id,
    });
    testActivities = [];

    const activityNoFinance = await prisma.activity.create({
      data: {
        title: `${TEST_PREFIX}activity_no_finance`,
        description: 'No finance',
        date: new Date(),
        bipra: 'PKB',
        activityType: 'SERVICE',
        supervisorId: testMembership.id,
      },
    });
    testActivities.push({
      ...activityNoFinance,
      hasExpense: false,
      hasRevenue: false,
    });

    const activityWithExpense = await prisma.activity.create({
      data: {
        title: `${TEST_PREFIX}activity_with_expense`,
        description: 'With expense',
        date: new Date(),
        bipra: 'WKI',
        activityType: 'EVENT',
        supervisorId: testMembership.id,
      },
    });
    await prisma.expense.create({
      data: {
        accountNumber: '123456',
        amount: 100000,
        paymentMethod: 'CASH',
        churchId: testChurch.id,
        activityId: activityWithExpense.id,
      },
    });
    testActivities.push({
      ...activityWithExpense,
      hasExpense: true,
      hasRevenue: false,
    });

    const activityWithRevenue = await prisma.activity.create({
      data: {
        title: `${TEST_PREFIX}activity_with_revenue`,
        description: 'With revenue',
        date: new Date(),
        bipra: 'PMD',
        activityType: 'ANNOUNCEMENT',
        supervisorId: testMembership.id,
      },
    });
    await prisma.revenue.create({
      data: {
        accountNumber: '654321',
        amount: 200000,
        paymentMethod: 'CASHLESS',
        churchId: testChurch.id,
        activityId: activityWithRevenue.id,
      },
    });
    testActivities.push({
      ...activityWithRevenue,
      hasExpense: false,
      hasRevenue: true,
    });

    const activityWithBoth = await prisma.activity.create({
      data: {
        title: `${TEST_PREFIX}activity_with_both`,
        description: 'With both',
        date: new Date(),
        bipra: 'RMJ',
        activityType: 'SERVICE',
        supervisorId: testMembership.id,
      },
    });
    await prisma.expense.create({
      data: {
        accountNumber: '111111',
        amount: 50000,
        paymentMethod: 'CASH',
        churchId: testChurch.id,
        activityId: activityWithBoth.id,
      },
    });
    await prisma.revenue.create({
      data: {
        accountNumber: '222222',
        amount: 150000,
        paymentMethod: 'CASHLESS',
        churchId: testChurch.id,
        activityId: activityWithBoth.id,
      },
    });
    testActivities.push({
      ...activityWithBoth,
      hasExpense: true,
      hasRevenue: true,
    });
  }

  function buildQuery(params: {
    membershipId?: number;
    page?: number;
    pageSize?: number;
    hasExpense?: boolean;
    hasRevenue?: boolean;
  }): any {
    const page = params.page ?? 1;
    const pageSize = params.pageSize ?? 100;
    return {
      membershipId: params.membershipId,
      page,
      pageSize,
      skip: (page - 1) * pageSize,
      take: pageSize,
      hasExpense: params.hasExpense,
      hasRevenue: params.hasRevenue,
    };
  }

  /** **Feature: activity-financial-filter, Property 6: Response structure consistency** **Validates: Requirements 3.1, 3.2** */
  describe('Property 6: Response structure consistency', () => {
    const financialFilterArb = fc.record({
      hasExpense: fc.constantFrom(true, false, undefined),
      hasRevenue: fc.constantFrom(true, false, undefined),
    });

    it('should return consistent response structure regardless of financial filters', async () => {
      await fc.assert(
        fc.asyncProperty(financialFilterArb, async (filters) => {
          const query = buildQuery({
            membershipId: testMembership.id,
            hasExpense: filters.hasExpense,
            hasRevenue: filters.hasRevenue,
          });
          const result = await activitiesService.findAll(query);
          expect(result).toHaveProperty('message');
          expect(result).toHaveProperty('data');
          expect(result).toHaveProperty('total');
          expect(typeof result.message).toBe('string');
          expect(Array.isArray(result.data)).toBe(true);
          expect(typeof result.total).toBe('number');
          expect(result.total).toBeGreaterThanOrEqual(0);
          for (const activity of result.data) {
            expect(activity).toHaveProperty('id');
            expect(activity).toHaveProperty('title');
            expect(activity).toHaveProperty('supervisor');
            expect(activity).toHaveProperty('approvers');
            expect(activity).toHaveProperty('hasExpense');
            expect(activity).toHaveProperty('hasRevenue');
            expect(typeof activity.hasExpense).toBe('boolean');
            expect(typeof activity.hasRevenue).toBe('boolean');
          }
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should return same structure for filtered and unfiltered queries', async () => {
      const unfilteredQuery = buildQuery({ membershipId: testMembership.id });
      const unfilteredResult = await activitiesService.findAll(unfilteredQuery);
      await fc.assert(
        fc.asyncProperty(financialFilterArb, async (filters) => {
          const filteredQuery = buildQuery({
            membershipId: testMembership.id,
            hasExpense: filters.hasExpense,
            hasRevenue: filters.hasRevenue,
          });
          const filteredResult = await activitiesService.findAll(filteredQuery);
          const unfilteredKeys = Object.keys(unfilteredResult).sort();
          const filteredKeys = Object.keys(filteredResult).sort();
          expect(filteredKeys).toEqual(unfilteredKeys);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  /** **Feature: activity-financial-filter, Property 7: Total count accuracy** **Validates: Requirements 3.3** */
  describe('Property 7: Total count accuracy', () => {
    const financialFilterArb = fc.record({
      hasExpense: fc.constantFrom(true, false, undefined),
      hasRevenue: fc.constantFrom(true, false, undefined),
    });

    it('should return accurate total count matching filter criteria', async () => {
      await fc.assert(
        fc.asyncProperty(financialFilterArb, async (filters) => {
          const query = buildQuery({
            membershipId: testMembership.id,
            hasExpense: filters.hasExpense,
            hasRevenue: filters.hasRevenue,
          });
          const result = await activitiesService.findAll(query);
          const expectedCount = testActivities.filter((activity) => {
            let matches = true;
            if (filters.hasExpense !== undefined)
              matches = matches && activity.hasExpense === filters.hasExpense;
            if (filters.hasRevenue !== undefined)
              matches = matches && activity.hasRevenue === filters.hasRevenue;
            return matches;
          }).length;
          expect(result.total).toBe(expectedCount);
          expect(result.data.length).toBeLessThanOrEqual(result.total);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should return total count independent of pagination parameters', async () => {
      await fc.assert(
        fc.asyncProperty(
          financialFilterArb,
          fc.integer({ min: 1, max: 5 }),
          fc.integer({ min: 1, max: 3 }),
          async (filters, page, pageSize) => {
            const query = buildQuery({
              membershipId: testMembership.id,
              page,
              pageSize,
              hasExpense: filters.hasExpense,
              hasRevenue: filters.hasRevenue,
            });
            const result = await activitiesService.findAll(query);
            const queryNoPagination = buildQuery({
              membershipId: testMembership.id,
              page: 1,
              pageSize: 1000,
              hasExpense: filters.hasExpense,
              hasRevenue: filters.hasRevenue,
            });
            const resultNoPagination =
              await activitiesService.findAll(queryNoPagination);
            expect(result.total).toBe(resultNoPagination.total);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  /** **Feature: activity-financial-filter, Property 8: Pagination with filters** **Validates: Requirements 3.4** */
  describe('Property 8: Pagination with filters', () => {
    const financialFilterArb = fc.record({
      hasExpense: fc.constantFrom(true, false, undefined),
      hasRevenue: fc.constantFrom(true, false, undefined),
    });

    it('should correctly paginate filtered results', async () => {
      await fc.assert(
        fc.asyncProperty(
          financialFilterArb,
          fc.integer({ min: 1, max: 3 }),
          fc.integer({ min: 1, max: 3 }),
          async (filters, page, pageSize) => {
            const query = buildQuery({
              membershipId: testMembership.id,
              page,
              pageSize,
              hasExpense: filters.hasExpense,
              hasRevenue: filters.hasRevenue,
            });
            const result = await activitiesService.findAll(query);
            const skip = (page - 1) * pageSize;
            expect(result.data.length).toBeLessThanOrEqual(pageSize);
            if (skip < result.total) {
              const expectedMaxLength = Math.min(pageSize, result.total - skip);
              expect(result.data.length).toBeLessThanOrEqual(expectedMaxLength);
            }
            if (skip >= result.total) expect(result.data.length).toBe(0);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should return non-overlapping pages when paginating', async () => {
      await fc.assert(
        fc.asyncProperty(financialFilterArb, async (filters) => {
          const page1Query = buildQuery({
            membershipId: testMembership.id,
            page: 1,
            pageSize: 2,
            hasExpense: filters.hasExpense,
            hasRevenue: filters.hasRevenue,
          });
          const page1Result = await activitiesService.findAll(page1Query);
          const page2Query = buildQuery({
            membershipId: testMembership.id,
            page: 2,
            pageSize: 2,
            hasExpense: filters.hasExpense,
            hasRevenue: filters.hasRevenue,
          });
          const page2Result = await activitiesService.findAll(page2Query);
          const page1Ids = new Set(page1Result.data.map((a: any) => a.id));
          const page2Ids = new Set(page2Result.data.map((a: any) => a.id));
          for (const id of page2Ids) expect(page1Ids.has(id)).toBe(false);
          expect(page1Result.total).toBe(page2Result.total);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should return all items when combining all pages', async () => {
      await fc.assert(
        fc.asyncProperty(financialFilterArb, async (filters) => {
          const allQuery = buildQuery({
            membershipId: testMembership.id,
            page: 1,
            pageSize: 100,
            hasExpense: filters.hasExpense,
            hasRevenue: filters.hasRevenue,
          });
          const allResult = await activitiesService.findAll(allQuery);
          const pageSize = 2;
          const allPagedIds: number[] = [];
          let currentPage = 1;
          let totalFetched = 0;
          while (totalFetched < allResult.total) {
            const pageQuery = buildQuery({
              membershipId: testMembership.id,
              page: currentPage,
              pageSize,
              hasExpense: filters.hasExpense,
              hasRevenue: filters.hasRevenue,
            });
            const pageResult = await activitiesService.findAll(pageQuery);
            allPagedIds.push(...pageResult.data.map((a: any) => a.id));
            totalFetched += pageResult.data.length;
            currentPage++;
            if (pageResult.data.length === 0) break;
          }
          expect(allPagedIds.length).toBe(allResult.total);
          const allIds = allResult.data
            .map((a: any) => a.id)
            .sort((a: number, b: number) => a - b);
          const pagedIdsSorted = allPagedIds.sort((a, b) => a - b);
          expect(pagedIdsSorted).toEqual(allIds);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
