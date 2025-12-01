/**
 * Property-Based Tests for Financial Account Number Matching
 *
 * **Feature: activity-approver-linking, Property 3: Financial Account Number Matching**
 * **Validates: Requirements 3.2, 3.3, 3.4**
 *
 * This test suite verifies that for any activity with financial data:
 * - Approval rules with a financialAccountNumberId should only match if the activity's
 *   financial account number matches
 * - Rules with only financialType (no specific account) should match any activity
 *   with that financial type
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

describe('Financial Account Number Matching Property Tests', () => {
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
    const prefix = 'test_prop_fanm_';

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

    await prisma.approvalRule.deleteMany({
      where: {
        name: { startsWith: prefix },
      },
    });

    await prisma.membershipPosition.deleteMany({
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
   * **Feature: activity-approver-linking, Property 3: Financial Account Number Matching**
   * **Validates: Requirements 3.2, 3.3, 3.4**
   */
  describe('Property 3: Financial Account Number Matching', () => {
    it('should only match rules with specific financialAccountNumberId when activity has that account number', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          fc.constantFrom('REVENUE', 'EXPENSE'),
          async (activityType: string, financialType: string) => {
            const testId = generateTestId();
            const prefix = `test_prop_fanm_${testId}`;

            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

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

            // Create two financial account numbers with required type field
            const financialAccount1 =
              await prisma.financialAccountNumber.create({
                data: {
                  accountNumber: `${prefix}_account_1`,
                  description: 'Account 1',
                  type: financialType as FinancialType,
                  churchId: church.id,
                },
              });

            const financialAccount2 =
              await prisma.financialAccountNumber.create({
                data: {
                  accountNumber: `${prefix}_account_2`,
                  description: 'Account 2',
                  type: financialType as FinancialType,
                  churchId: church.id,
                },
              });

            const position1 = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_position_1`,
                churchId: church.id,
              },
            });

            const position2 = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_position_2`,
                churchId: church.id,
              },
            });

            const member1Account = await createTestAccount(prisma, {
              name: `Member 1 ${testId}`,
              phone: `${prefix}_member_1`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const member1Membership = await createTestMembership(prisma, {
              accountId: member1Account.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: position1.id },
              data: { membershipId: member1Membership.id },
            });

            const member2Account = await createTestAccount(prisma, {
              name: `Member 2 ${testId}`,
              phone: `${prefix}_member_2`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const member2Membership = await createTestMembership(prisma, {
              accountId: member2Account.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: position2.id },
              data: { membershipId: member2Membership.id },
            });

            // Create rule linked to account 1 (should match)
            const rule1 = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_rule_account_1`,
                description: 'Rule for account 1',
                active: true,
                churchId: church.id,
                financialType: financialType as FinancialType,
                financialAccountNumberId: financialAccount1.id,
                positions: {
                  connect: [{ id: position1.id }],
                },
              },
            });

            // Create rule linked to account 2 (should NOT match)
            const rule2 = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_rule_account_2`,
                description: 'Rule for account 2',
                active: true,
                churchId: church.id,
                financialType: financialType as FinancialType,
                financialAccountNumberId: financialAccount2.id,
                positions: {
                  connect: [{ id: position2.id }],
                },
              },
            });

            // Call the approver resolver with account 1
            const result = await approverResolverService.resolveApprovers({
              churchId: church.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
              financialType: financialType as FinancialType,
              financialAccountNumberId: financialAccount1.id,
            });

            // Property: Rule with matching account should be matched
            expect(result.matchedRuleIds).toContain(rule1.id);

            // Property: Rule with different account should NOT be matched
            expect(result.matchedRuleIds).not.toContain(rule2.id);

            // Property: Member from matching rule should be in approvers
            expect(result.membershipIds).toContain(member1Membership.id);

            // Property: Member from non-matching rule should NOT be in approvers
            expect(result.membershipIds).not.toContain(member2Membership.id);
          },
        ),
        { numRuns: 10 },
      );
    }, 60000);

    it('should match rules with only financialType (no specific account) for any activity with that financial type', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          fc.constantFrom('REVENUE', 'EXPENSE'),
          async (activityType: string, financialType: string) => {
            const testId = generateTestId();
            const prefix = `test_prop_fanm_${testId}`;

            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

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

            // Create a financial account number with required type field
            const financialAccount = await prisma.financialAccountNumber.create(
              {
                data: {
                  accountNumber: `${prefix}_account`,
                  description: 'Test Account',
                  type: financialType as FinancialType,
                  churchId: church.id,
                },
              },
            );

            const position = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_position`,
                churchId: church.id,
              },
            });

            const memberAccount = await createTestAccount(prisma, {
              name: `Member ${testId}`,
              phone: `${prefix}_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const memberMembership = await createTestMembership(prisma, {
              accountId: memberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: position.id },
              data: { membershipId: memberMembership.id },
            });

            // Create rule with financialType but NO specific account number
            const rule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_rule_type_only`,
                description: 'Rule with financial type only',
                active: true,
                churchId: church.id,
                financialType: financialType as FinancialType,
                financialAccountNumberId: null, // No specific account
                positions: {
                  connect: [{ id: position.id }],
                },
              },
            });

            // Call the approver resolver with any account number
            const result = await approverResolverService.resolveApprovers({
              churchId: church.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
              financialType: financialType as FinancialType,
              financialAccountNumberId: financialAccount.id,
            });

            // Property: Rule with only financialType should match any activity with that type
            expect(result.matchedRuleIds).toContain(rule.id);

            // Property: Member from the rule should be in approvers
            expect(result.membershipIds).toContain(memberMembership.id);
          },
        ),
        { numRuns: 10 },
      );
    }, 60000);

    it('should require both financialType and financialAccountNumber to match when rule has both', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          async (activityType: string) => {
            const testId = generateTestId();
            const prefix = `test_prop_fanm_${testId}`;

            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

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

            // Create financial account number with REVENUE type
            const financialAccount = await prisma.financialAccountNumber.create(
              {
                data: {
                  accountNumber: `${prefix}_account`,
                  description: 'Test Account',
                  type: FinancialType.REVENUE,
                  churchId: church.id,
                },
              },
            );

            const position = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_position`,
                churchId: church.id,
              },
            });

            const memberAccount = await createTestAccount(prisma, {
              name: `Member ${testId}`,
              phone: `${prefix}_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const memberMembership = await createTestMembership(prisma, {
              accountId: memberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: position.id },
              data: { membershipId: memberMembership.id },
            });

            // Create rule with REVENUE type and specific account
            const revenueRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_revenue_rule`,
                description: 'Revenue rule with specific account',
                active: true,
                churchId: church.id,
                financialType: FinancialType.REVENUE,
                financialAccountNumberId: financialAccount.id,
                positions: {
                  connect: [{ id: position.id }],
                },
              },
            });

            // Test 1: Activity with EXPENSE type and same account should NOT match
            const resultExpense =
              await approverResolverService.resolveApprovers({
                churchId: church.id,
                activityType: activityType as ActivityType,
                supervisorId: supervisorMembership.id,
                financialType: FinancialType.EXPENSE,
                financialAccountNumberId: financialAccount.id,
              });

            // Property: Rule should NOT match when financialType doesn't match
            expect(resultExpense.matchedRuleIds).not.toContain(revenueRule.id);

            // Test 2: Activity with REVENUE type and same account SHOULD match
            const resultRevenue =
              await approverResolverService.resolveApprovers({
                churchId: church.id,
                activityType: activityType as ActivityType,
                supervisorId: supervisorMembership.id,
                financialType: FinancialType.REVENUE,
                financialAccountNumberId: financialAccount.id,
              });

            // Property: Rule should match when both financialType and account match
            expect(resultRevenue.matchedRuleIds).toContain(revenueRule.id);
            expect(resultRevenue.membershipIds).toContain(memberMembership.id);
          },
        ),
        { numRuns: 10 },
      );
    }, 60000);

    it('should combine account-specific rules with type-only rules when both match', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          fc.constantFrom('REVENUE', 'EXPENSE'),
          async (activityType: string, financialType: string) => {
            const testId = generateTestId();
            const prefix = `test_prop_fanm_${testId}`;

            const church = await createTestChurch(prisma, {
              name: `${prefix}_church`,
              location: {
                name: `${prefix}_location`,
                latitude: 0,
                longitude: 0,
              },
            });

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

            // Create financial account number with required type field
            const financialAccount = await prisma.financialAccountNumber.create(
              {
                data: {
                  accountNumber: `${prefix}_account`,
                  description: 'Test Account',
                  type: financialType as FinancialType,
                  churchId: church.id,
                },
              },
            );

            const positionSpecific = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_position_specific`,
                churchId: church.id,
              },
            });

            const positionGeneral = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_position_general`,
                churchId: church.id,
              },
            });

            const memberSpecificAccount = await createTestAccount(prisma, {
              name: `Member Specific ${testId}`,
              phone: `${prefix}_member_specific`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const memberSpecificMembership = await createTestMembership(
              prisma,
              {
                accountId: memberSpecificAccount.id,
                churchId: church.id,
              },
            );

            await prisma.membershipPosition.update({
              where: { id: positionSpecific.id },
              data: { membershipId: memberSpecificMembership.id },
            });

            const memberGeneralAccount = await createTestAccount(prisma, {
              name: `Member General ${testId}`,
              phone: `${prefix}_member_general`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const memberGeneralMembership = await createTestMembership(prisma, {
              accountId: memberGeneralAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: positionGeneral.id },
              data: { membershipId: memberGeneralMembership.id },
            });

            // Create account-specific rule
            const accountSpecificRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_rule_specific`,
                description: 'Account-specific rule',
                active: true,
                churchId: church.id,
                financialType: financialType as FinancialType,
                financialAccountNumberId: financialAccount.id,
                positions: {
                  connect: [{ id: positionSpecific.id }],
                },
              },
            });

            // Create type-only rule (no specific account)
            const typeOnlyRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_rule_type_only`,
                description: 'Type-only rule',
                active: true,
                churchId: church.id,
                financialType: financialType as FinancialType,
                financialAccountNumberId: null,
                positions: {
                  connect: [{ id: positionGeneral.id }],
                },
              },
            });

            // Call the approver resolver
            const result = await approverResolverService.resolveApprovers({
              churchId: church.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
              financialType: financialType as FinancialType,
              financialAccountNumberId: financialAccount.id,
            });

            // Property: Both rules should be matched
            expect(result.matchedRuleIds).toContain(accountSpecificRule.id);
            expect(result.matchedRuleIds).toContain(typeOnlyRule.id);

            // Property: Both members should be in approvers
            expect(result.membershipIds).toContain(memberSpecificMembership.id);
            expect(result.membershipIds).toContain(memberGeneralMembership.id);
          },
        ),
        { numRuns: 10 },
      );
    }, 60000);
  });
});
