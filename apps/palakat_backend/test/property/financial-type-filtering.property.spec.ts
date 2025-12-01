/**
 * Property-Based Tests for Financial Type Filtering
 *
 * **Feature: activity-approver-linking, Property 2: Financial Type Filtering**
 * **Validates: Requirements 2.2, 2.3, 2.4**
 *
 * This test suite verifies that for any activity:
 * - If it has revenue data, only REVENUE-type financial rules should be considered
 * - If it has expense data, only EXPENSE-type financial rules should be considered
 * - If it has no financial data, no financial-type rules should be applied
 */

import { ActivityType, FinancialType, PrismaClient } from '@prisma/client';
import * as fc from 'fast-check';
import * as generators from './generators';
import {
  TEST_CONFIG,
  createTestAccount,
  createTestChurch,
  createTestMembership,
  generateTestId,
} from './utils/test-helpers';
import { ApproverResolverService } from '../../src/activity/approver-resolver.service';
import { PrismaService } from '../../src/prisma.service';

describe('Financial Type Filtering Property Tests', () => {
  let prisma: PrismaClient;
  let prismaService: PrismaService;
  let approverResolverService: ApproverResolverService;

  beforeAll(() => {
    prisma = new PrismaClient();
    prismaService = prisma as unknown as PrismaService;
    approverResolverService = new ApproverResolverService(prismaService);
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    await cleanupTestData();
  });

  afterEach(async () => {
    await cleanupTestData();
  });

  async function cleanupTestData() {
    // Delete in order respecting foreign key constraints
    const prefix = 'test_prop_ftf_';

    await prisma.approver.deleteMany({
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

    await prisma.membershipPosition.deleteMany({
      where: {
        name: { startsWith: prefix },
      },
    });

    await prisma.approvalRule.deleteMany({
      where: {
        name: { startsWith: prefix },
      },
    });

    await prisma.financialAccountNumber.deleteMany({
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
   * **Feature: activity-approver-linking, Property 2: Financial Type Filtering**
   * **Validates: Requirements 2.2, 2.3, 2.4**
   *
   * Property: For any activity:
   * - If it has revenue data (financialType = REVENUE), only REVENUE-type rules should be considered
   * - If it has expense data (financialType = EXPENSE), only EXPENSE-type rules should be considered
   * - If it has no financial data, no financial-type rules should be applied
   */
  describe('Property 2: Financial Type Filtering', () => {
    it('should only match REVENUE-type rules when activity has revenue data', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          async (activityType: string) => {
            const testId = generateTestId();
            const prefix = `test_prop_ftf_${testId}`;

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

            // Create positions for different rule types
            const revenuePosition = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_revenue_position`,
                churchId: church.id,
              },
            });

            const expensePosition = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_expense_position`,
                churchId: church.id,
              },
            });

            // Create members with these positions
            const revenueMemberAccount = await createTestAccount(prisma, {
              name: `Revenue Member ${testId}`,
              phone: `${prefix}_rev_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const revenueMembership = await createTestMembership(prisma, {
              accountId: revenueMemberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: revenuePosition.id },
              data: { membershipId: revenueMembership.id },
            });

            const expenseMemberAccount = await createTestAccount(prisma, {
              name: `Expense Member ${testId}`,
              phone: `${prefix}_exp_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const expenseMembership = await createTestMembership(prisma, {
              accountId: expenseMemberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: expensePosition.id },
              data: { membershipId: expenseMembership.id },
            });

            // Create REVENUE-type approval rule
            const revenueRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_revenue_rule`,
                description: 'Revenue type rule',
                active: true,
                churchId: church.id,
                financialType: FinancialType.REVENUE,
                positions: {
                  connect: [{ id: revenuePosition.id }],
                },
              },
            });

            // Create EXPENSE-type approval rule (should NOT match)
            const expenseRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_expense_rule`,
                description: 'Expense type rule',
                active: true,
                churchId: church.id,
                financialType: FinancialType.EXPENSE,
                positions: {
                  connect: [{ id: expensePosition.id }],
                },
              },
            });

            // Call the approver resolver with REVENUE financial type
            const result = await approverResolverService.resolveApprovers({
              churchId: church.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
              financialType: FinancialType.REVENUE,
            });

            // Property: REVENUE rule should be matched
            expect(result.matchedRuleIds).toContain(revenueRule.id);

            // Property: EXPENSE rule should NOT be matched
            expect(result.matchedRuleIds).not.toContain(expenseRule.id);

            // Property: Revenue member should be in approvers
            expect(result.membershipIds).toContain(revenueMembership.id);

            // Property: Expense member should NOT be in approvers
            expect(result.membershipIds).not.toContain(expenseMembership.id);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should only match EXPENSE-type rules when activity has expense data', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          async (activityType: string) => {
            const testId = generateTestId();
            const prefix = `test_prop_ftf_${testId}`;

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

            // Create positions for different rule types
            const revenuePosition = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_revenue_position`,
                churchId: church.id,
              },
            });

            const expensePosition = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_expense_position`,
                churchId: church.id,
              },
            });

            // Create members with these positions
            const revenueMemberAccount = await createTestAccount(prisma, {
              name: `Revenue Member ${testId}`,
              phone: `${prefix}_rev_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const revenueMembership = await createTestMembership(prisma, {
              accountId: revenueMemberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: revenuePosition.id },
              data: { membershipId: revenueMembership.id },
            });

            const expenseMemberAccount = await createTestAccount(prisma, {
              name: `Expense Member ${testId}`,
              phone: `${prefix}_exp_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const expenseMembership = await createTestMembership(prisma, {
              accountId: expenseMemberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: expensePosition.id },
              data: { membershipId: expenseMembership.id },
            });

            // Create REVENUE-type approval rule (should NOT match)
            const revenueRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_revenue_rule`,
                description: 'Revenue type rule',
                active: true,
                churchId: church.id,
                financialType: FinancialType.REVENUE,
                positions: {
                  connect: [{ id: revenuePosition.id }],
                },
              },
            });

            // Create EXPENSE-type approval rule
            const expenseRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_expense_rule`,
                description: 'Expense type rule',
                active: true,
                churchId: church.id,
                financialType: FinancialType.EXPENSE,
                positions: {
                  connect: [{ id: expensePosition.id }],
                },
              },
            });

            // Call the approver resolver with EXPENSE financial type
            const result = await approverResolverService.resolveApprovers({
              churchId: church.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
              financialType: FinancialType.EXPENSE,
            });

            // Property: EXPENSE rule should be matched
            expect(result.matchedRuleIds).toContain(expenseRule.id);

            // Property: REVENUE rule should NOT be matched
            expect(result.matchedRuleIds).not.toContain(revenueRule.id);

            // Property: Expense member should be in approvers
            expect(result.membershipIds).toContain(expenseMembership.id);

            // Property: Revenue member should NOT be in approvers
            expect(result.membershipIds).not.toContain(revenueMembership.id);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should not apply financial-type rules when activity has no financial data', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          async (activityType: string) => {
            const testId = generateTestId();
            const prefix = `test_prop_ftf_${testId}`;

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

            // Create positions for different rule types
            const revenuePosition = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_revenue_position`,
                churchId: church.id,
              },
            });

            const expensePosition = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_expense_position`,
                churchId: church.id,
              },
            });

            const genericPosition = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_generic_position`,
                churchId: church.id,
              },
            });

            // Create members with these positions
            const revenueMemberAccount = await createTestAccount(prisma, {
              name: `Revenue Member ${testId}`,
              phone: `${prefix}_rev_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const revenueMembership = await createTestMembership(prisma, {
              accountId: revenueMemberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: revenuePosition.id },
              data: { membershipId: revenueMembership.id },
            });

            const expenseMemberAccount = await createTestAccount(prisma, {
              name: `Expense Member ${testId}`,
              phone: `${prefix}_exp_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const expenseMembership = await createTestMembership(prisma, {
              accountId: expenseMemberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: expensePosition.id },
              data: { membershipId: expenseMembership.id },
            });

            const genericMemberAccount = await createTestAccount(prisma, {
              name: `Generic Member ${testId}`,
              phone: `${prefix}_gen_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const genericMembership = await createTestMembership(prisma, {
              accountId: genericMemberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: genericPosition.id },
              data: { membershipId: genericMembership.id },
            });

            // Create REVENUE-type approval rule (should NOT match)
            const revenueRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_revenue_rule`,
                description: 'Revenue type rule',
                active: true,
                churchId: church.id,
                financialType: FinancialType.REVENUE,
                positions: {
                  connect: [{ id: revenuePosition.id }],
                },
              },
            });

            // Create EXPENSE-type approval rule (should NOT match)
            const expenseRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_expense_rule`,
                description: 'Expense type rule',
                active: true,
                churchId: church.id,
                financialType: FinancialType.EXPENSE,
                positions: {
                  connect: [{ id: expensePosition.id }],
                },
              },
            });

            // Create generic approval rule (no financial type) - should match
            const genericRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_generic_rule`,
                description: 'Generic rule without financial type',
                active: true,
                churchId: church.id,
                activityType: null,
                financialType: null,
                positions: {
                  connect: [{ id: genericPosition.id }],
                },
              },
            });

            // Call the approver resolver WITHOUT financial type (no financial data)
            const result = await approverResolverService.resolveApprovers({
              churchId: church.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
              // No financialType provided - activity has no financial data
            });

            // Property: Financial-type rules should NOT be matched
            expect(result.matchedRuleIds).not.toContain(revenueRule.id);
            expect(result.matchedRuleIds).not.toContain(expenseRule.id);

            // Property: Generic rule should be matched (fallback)
            expect(result.matchedRuleIds).toContain(genericRule.id);

            // Property: Financial members should NOT be in approvers
            expect(result.membershipIds).not.toContain(revenueMembership.id);
            expect(result.membershipIds).not.toContain(expenseMembership.id);

            // Property: Generic member should be in approvers
            expect(result.membershipIds).toContain(genericMembership.id);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should combine activity type rules with financial type rules when both apply', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          fc.constantFrom('REVENUE', 'EXPENSE'),
          async (activityType: string, financialType: string) => {
            const testId = generateTestId();
            const prefix = `test_prop_ftf_${testId}`;

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

            // Create positions
            const activityTypePosition = await prisma.membershipPosition.create(
              {
                data: {
                  name: `${prefix}_activity_position`,
                  churchId: church.id,
                },
              },
            );

            const financialPosition = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_financial_position`,
                churchId: church.id,
              },
            });

            // Create members with these positions
            const activityMemberAccount = await createTestAccount(prisma, {
              name: `Activity Member ${testId}`,
              phone: `${prefix}_act_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const activityMembership = await createTestMembership(prisma, {
              accountId: activityMemberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: activityTypePosition.id },
              data: { membershipId: activityMembership.id },
            });

            const financialMemberAccount = await createTestAccount(prisma, {
              name: `Financial Member ${testId}`,
              phone: `${prefix}_fin_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const financialMembership = await createTestMembership(prisma, {
              accountId: financialMemberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: financialPosition.id },
              data: { membershipId: financialMembership.id },
            });

            // Create activity type rule
            const activityTypeRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_activity_rule`,
                description: 'Activity type rule',
                active: true,
                churchId: church.id,
                activityType: activityType as ActivityType,
                positions: {
                  connect: [{ id: activityTypePosition.id }],
                },
              },
            });

            // Create financial type rule
            const financialRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_financial_rule`,
                description: 'Financial type rule',
                active: true,
                churchId: church.id,
                financialType: financialType as FinancialType,
                positions: {
                  connect: [{ id: financialPosition.id }],
                },
              },
            });

            // Call the approver resolver with both activity type and financial type
            const result = await approverResolverService.resolveApprovers({
              churchId: church.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
              financialType: financialType as FinancialType,
            });

            // Property: Both rules should be matched
            expect(result.matchedRuleIds).toContain(activityTypeRule.id);
            expect(result.matchedRuleIds).toContain(financialRule.id);

            // Property: Both members should be in approvers
            expect(result.membershipIds).toContain(activityMembership.id);
            expect(result.membershipIds).toContain(financialMembership.id);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
