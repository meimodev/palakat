/**
 * Property-Based Tests for Activity Type Rule Matching
 *
 * **Feature: activity-approver-linking, Property 1: Activity Type Rule Matching**
 * **Validates: Requirements 1.2, 1.3, 1.4**
 *
 * This test suite verifies that for any activity with a specific activityType,
 * the system returns only approval rules that either match that activityType
 * or have no activityType filter (generic rules), and all returned rules
 * must belong to the same church as the activity.
 */

import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import { ActivityType, PrismaClient } from '../../src/generated/prisma/client';
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
import { ApproverResolverService } from '../../src/activity/approver-resolver.service';
import { PrismaService } from '../../src/prisma.service';

describe('Activity Type Rule Matching Property Tests', () => {
  let prisma: PrismaClient;
  let pool: Pool;
  let prismaService: PrismaService;
  let approverResolverService: ApproverResolverService;

  beforeAll(() => {
    pool = new Pool({
      connectionString: getDatabasePostgresUrl(),
      allowExitOnIdle: true,
    });
    const adapter = new PrismaPg(pool);
    prisma = new PrismaClient({ adapter });
    // Create a mock PrismaService that wraps the PrismaClient
    prismaService = prisma as unknown as PrismaService;
    approverResolverService = new ApproverResolverService(prismaService);
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
        activity: {
          title: { startsWith: 'test_prop_atrm_' },
        },
      },
    });

    await prisma.activity.deleteMany({
      where: {
        title: { startsWith: 'test_prop_atrm_' },
      },
    });

    await prisma.membershipPosition.deleteMany({
      where: {
        name: { startsWith: 'test_prop_atrm_' },
      },
    });

    await prisma.approvalRule.deleteMany({
      where: {
        name: { startsWith: 'test_prop_atrm_' },
      },
    });

    await prisma.membership.deleteMany({
      where: {
        account: {
          phone: { startsWith: 'test_prop_atrm_' },
        },
      },
    });

    await prisma.account.deleteMany({
      where: {
        phone: { startsWith: 'test_prop_atrm_' },
      },
    });

    await prisma.column.deleteMany({
      where: {
        name: { startsWith: 'test_prop_atrm_' },
      },
    });

    await prisma.church.deleteMany({
      where: {
        name: { startsWith: 'test_prop_atrm_' },
      },
    });

    await prisma.location.deleteMany({
      where: {
        name: { startsWith: 'test_prop_atrm_' },
      },
    });
  }

  /**
   * **Feature: activity-approver-linking, Property 1: Activity Type Rule Matching**
   * **Validates: Requirements 1.2, 1.3, 1.4**
   *
   * Property: For any activity with a specific activityType, the system should return
   * only approval rules that either match that activityType or have no activityType
   * filter (generic rules), and all returned rules must belong to the same church.
   */
  describe('Property 1: Activity Type Rule Matching', () => {
    it('should match rules with same activityType or generic rules (no activityType)', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          generators.bipraArb,
          fc.boolean(), // Whether to create type-specific rules
          fc.boolean(), // Whether to create generic rules
          async (
            activityType: string,
            bipra: string,
            hasTypeSpecificRules: boolean,
            hasGenericRules: boolean,
          ) => {
            const testId = generateTestId();
            const prefix = `test_prop_atrm_${testId}`;

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

            // Create membership position
            const position = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_position`,
                churchId: church.id,
              },
            });

            // Create a member with this position
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

            const createdRuleIds: number[] = [];

            // Create type-specific rule if requested
            if (hasTypeSpecificRules) {
              const typeRule = await prisma.approvalRule.create({
                data: {
                  name: `${prefix}_type_rule`,
                  description: 'Type-specific rule',
                  active: true,
                  churchId: church.id,
                  activityType: activityType as ActivityType,
                  positions: {
                    connect: [{ id: position.id }],
                  },
                },
              });
              createdRuleIds.push(typeRule.id);
            }

            // Create generic rule (no activityType) if requested
            if (hasGenericRules) {
              const genericRule = await prisma.approvalRule.create({
                data: {
                  name: `${prefix}_generic_rule`,
                  description: 'Generic rule',
                  active: true,
                  churchId: church.id,
                  activityType: null,
                  financialType: null,
                  positions: {
                    connect: [{ id: position.id }],
                  },
                },
              });
              createdRuleIds.push(genericRule.id);
            }

            // Create a rule with different activityType (should NOT match)
            const otherActivityTypes = [
              'SERVICE',
              'EVENT',
              'ANNOUNCEMENT',
            ].filter((t) => t !== activityType);
            if (otherActivityTypes.length > 0) {
              await prisma.approvalRule.create({
                data: {
                  name: `${prefix}_other_type_rule`,
                  description: 'Different type rule',
                  active: true,
                  churchId: church.id,
                  activityType: otherActivityTypes[0] as ActivityType,
                  positions: {
                    connect: [{ id: position.id }],
                  },
                },
              });
              // Note: This rule ID is NOT added to createdRuleIds as it should not match
            }

            // Call the approver resolver
            const result = await approverResolverService.resolveApprovers({
              churchId: church.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
            });

            // Verify the matched rules
            const matchedRules = await prisma.approvalRule.findMany({
              where: {
                id: { in: result.matchedRuleIds },
              },
            });

            // Property 1: All matched rules should belong to the same church
            for (const rule of matchedRules) {
              expect(rule.churchId).toBe(church.id);
            }

            // Property 2: All matched rules should either have matching activityType or no activityType
            for (const rule of matchedRules) {
              const matchesActivityType = rule.activityType === activityType;
              const isGenericRule =
                rule.activityType === null && rule.financialType === null;
              expect(matchesActivityType || isGenericRule).toBe(true);
            }

            // Property 3: If type-specific rules exist, they should be matched (not generic)
            if (hasTypeSpecificRules) {
              const hasTypeSpecificMatch = matchedRules.some(
                (r) => r.activityType === activityType,
              );
              expect(hasTypeSpecificMatch).toBe(true);
            }

            // Property 4: If only generic rules exist (no type-specific), generic rules should be matched
            if (!hasTypeSpecificRules && hasGenericRules) {
              const hasGenericMatch = matchedRules.some(
                (r) => r.activityType === null && r.financialType === null,
              );
              expect(hasGenericMatch).toBe(true);
            }

            // Property 5: Rules with different activityType should NOT be matched
            const hasWrongTypeMatch = matchedRules.some(
              (r) => r.activityType !== null && r.activityType !== activityType,
            );
            expect(hasWrongTypeMatch).toBe(false);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should fall back to generic rules when no type-specific rules exist', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          generators.bipraArb,
          async (activityType: string, bipra: string) => {
            const testId = generateTestId();
            const prefix = `test_prop_atrm_${testId}`;

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

            // Create membership position
            const position = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_position`,
                churchId: church.id,
              },
            });

            // Create a member with this position
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

            // Create ONLY generic rule (no activityType)
            const genericRule = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_generic_rule`,
                description: 'Generic rule for fallback',
                active: true,
                churchId: church.id,
                activityType: null,
                financialType: null,
                positions: {
                  connect: [{ id: position.id }],
                },
              },
            });

            // Call the approver resolver
            const result = await approverResolverService.resolveApprovers({
              churchId: church.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
            });

            // Property: When no type-specific rules exist, generic rules should be used
            expect(result.matchedRuleIds).toContain(genericRule.id);
            expect(result.membershipIds).toContain(memberMembership.id);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should use all matching active approval rules when multiple match', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          generators.bipraArb,
          fc.integer({ min: 2, max: 4 }), // Number of matching rules
          async (activityType: string, bipra: string, numRules: number) => {
            const testId = generateTestId();
            const prefix = `test_prop_atrm_${testId}`;

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

            // Create multiple positions and rules
            const createdRuleIds: number[] = [];
            for (let i = 0; i < numRules; i++) {
              const position = await prisma.membershipPosition.create({
                data: {
                  name: `${prefix}_position_${i}`,
                  churchId: church.id,
                },
              });

              // Create a member with this position
              const memberAccount = await createTestAccount(prisma, {
                name: `Member ${testId}_${i}`,
                phone: `${prefix}_member_${i}`,
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

              // Create rule with matching activityType
              const rule = await prisma.approvalRule.create({
                data: {
                  name: `${prefix}_rule_${i}`,
                  description: `Rule ${i}`,
                  active: true,
                  churchId: church.id,
                  activityType: activityType as ActivityType,
                  positions: {
                    connect: [{ id: position.id }],
                  },
                },
              });
              createdRuleIds.push(rule.id);
            }

            // Call the approver resolver
            const result = await approverResolverService.resolveApprovers({
              churchId: church.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
            });

            // Property: All matching active rules should be used
            for (const ruleId of createdRuleIds) {
              expect(result.matchedRuleIds).toContain(ruleId);
            }

            // Property: Number of matched rules should equal number of created rules
            expect(result.matchedRuleIds.length).toBe(numRules);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should not match rules from different churches', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          generators.bipraArb,
          async (activityType: string, bipra: string) => {
            const testId = generateTestId();
            const prefix = `test_prop_atrm_${testId}`;

            // Create two churches
            const church1 = await createTestChurch(prisma, {
              name: `${prefix}_church_1`,
              location: {
                name: `${prefix}_location_1`,
                latitude: 0,
                longitude: 0,
              },
            });

            const church2 = await createTestChurch(prisma, {
              name: `${prefix}_church_2`,
              location: {
                name: `${prefix}_location_2`,
                latitude: 1,
                longitude: 1,
              },
            });

            // Create supervisor in church1
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `${prefix}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church1.id,
            });

            // Create position and rule in church1
            const position1 = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_position_1`,
                churchId: church1.id,
              },
            });

            const memberAccount1 = await createTestAccount(prisma, {
              name: `Member ${testId}_1`,
              phone: `${prefix}_member_1`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const memberMembership1 = await createTestMembership(prisma, {
              accountId: memberAccount1.id,
              churchId: church1.id,
            });

            await prisma.membershipPosition.update({
              where: { id: position1.id },
              data: { membershipId: memberMembership1.id },
            });

            const rule1 = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_rule_1`,
                description: 'Rule in church 1',
                active: true,
                churchId: church1.id,
                activityType: activityType as ActivityType,
                positions: {
                  connect: [{ id: position1.id }],
                },
              },
            });

            // Create position and rule in church2 (should NOT match)
            const position2 = await prisma.membershipPosition.create({
              data: {
                name: `${prefix}_position_2`,
                churchId: church2.id,
              },
            });

            const memberAccount2 = await createTestAccount(prisma, {
              name: `Member ${testId}_2`,
              phone: `${prefix}_member_2`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const memberMembership2 = await createTestMembership(prisma, {
              accountId: memberAccount2.id,
              churchId: church2.id,
            });

            await prisma.membershipPosition.update({
              where: { id: position2.id },
              data: { membershipId: memberMembership2.id },
            });

            const rule2 = await prisma.approvalRule.create({
              data: {
                name: `${prefix}_rule_2`,
                description: 'Rule in church 2',
                active: true,
                churchId: church2.id,
                activityType: activityType as ActivityType,
                positions: {
                  connect: [{ id: position2.id }],
                },
              },
            });

            // Call the approver resolver for church1
            const result = await approverResolverService.resolveApprovers({
              churchId: church1.id,
              activityType: activityType as ActivityType,
              supervisorId: supervisorMembership.id,
            });

            // Property: Only rules from the same church should be matched
            expect(result.matchedRuleIds).toContain(rule1.id);
            expect(result.matchedRuleIds).not.toContain(rule2.id);

            // Property: Only memberships from the same church should be returned
            expect(result.membershipIds).toContain(memberMembership1.id);
            expect(result.membershipIds).not.toContain(memberMembership2.id);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
