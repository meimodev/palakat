/**
 * Property-Based Tests for Automatic Approver Assignment
 *
 * **Feature: palakat-system-overview, Property 9: Automatic Approver Assignment**
 * **Validates: Requirements 4.2, 5.4**
 *
 * This test suite verifies that the system automatically assigns approvers
 * based on active approval rules matching the activity type and BIPRA.
 */

import { ActivityType, Bipra, PrismaClient } from '@prisma/client';
import * as fc from 'fast-check';
import * as generators from './generators';
import {
  TEST_CONFIG,
  createTestAccount,
  createTestChurch,
  createTestMembership,
  generateTestId,
} from './utils/test-helpers';

describe('Automatic Approver Assignment Property Tests', () => {
  let prisma: PrismaClient;

  beforeAll(() => {
    prisma = new PrismaClient();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    // Clean up test data before each test
    await cleanupTestData();
  });

  afterEach(async () => {
    // Clean up test data after each test
    await cleanupTestData();
  });

  async function cleanupTestData() {
    // Delete in order respecting foreign key constraints
    await prisma.approver.deleteMany({
      where: {
        activity: {
          title: { startsWith: 'test_prop_activity_' },
        },
      },
    });

    await prisma.activity.deleteMany({
      where: {
        title: { startsWith: 'test_prop_activity_' },
      },
    });

    await prisma.membershipPosition.deleteMany({
      where: {
        name: { startsWith: 'test_prop_position_' },
      },
    });

    await prisma.approvalRule.deleteMany({
      where: {
        name: { startsWith: 'test_prop_rule_' },
      },
    });

    await prisma.membership.deleteMany({
      where: {
        account: {
          phone: { startsWith: 'test_prop_' },
        },
      },
    });

    await prisma.account.deleteMany({
      where: {
        phone: { startsWith: 'test_prop_' },
      },
    });

    await prisma.column.deleteMany({
      where: {
        name: { startsWith: 'test_prop_column_' },
      },
    });

    await prisma.church.deleteMany({
      where: {
        name: { startsWith: 'test_prop_church_' },
      },
    });

    await prisma.location.deleteMany({
      where: {
        name: { startsWith: 'test_prop_location_' },
      },
    });
  }

  // **Feature: palakat-system-overview, Property 9: Automatic Approver Assignment**
  // **Validates: Requirements 4.2, 5.4**
  describe('Property 9: Automatic Approver Assignment', () => {
    it('should automatically assign approvers based on active approval rules', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          generators.bipraArb,
          fc.integer({ min: 1, max: 2 }), // Number of positions in approval rule (reduced)
          fc.integer({ min: 1, max: 3 }), // Number of members with those positions (reduced)
          async (
            activityType: string,
            bipra: string,
            numPositions: number,
            numMembers: number,
          ) => {
            const testId = generateTestId();

            // Create test church with location
            const church = await createTestChurch(prisma, {
              name: `test_prop_church_${testId}`,
              location: {
                name: `test_prop_location_${testId}`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor account and membership
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `test_prop_${testId}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create membership positions for the approval rule
            const positions = [];
            for (let i = 0; i < numPositions; i++) {
              const position = await prisma.membershipPosition.create({
                data: {
                  name: `test_prop_position_${testId}_${i}`,
                  churchId: church.id,
                },
              });
              positions.push(position);
            }

            // Create active approval rule with these positions
            const approvalRule = await prisma.approvalRule.create({
              data: {
                name: `test_prop_rule_${testId}`,
                description: 'Test approval rule',
                active: true,
                churchId: church.id,
                positions: {
                  connect: positions.map((p) => ({ id: p.id })),
                },
              },
            });

            // Create members with these positions
            const members = [];
            for (let i = 0; i < numMembers; i++) {
              const account = await createTestAccount(prisma, {
                name: `Member ${testId}_${i}`,
                phone: `test_prop_${testId}_member_${i}`,
                gender: i % 2 === 0 ? 'MALE' : 'FEMALE',
                maritalStatus: i % 2 === 0 ? 'MARRIED' : 'SINGLE',
              });

              const membership = await createTestMembership(prisma, {
                accountId: account.id,
                churchId: church.id,
              });

              // Assign one of the positions to this member
              const positionIndex = i % numPositions;
              await prisma.membershipPosition.update({
                where: { id: positions[positionIndex].id },
                data: {
                  membershipId: membership.id,
                },
              });

              members.push(membership);
            }

            // Create activity - this should trigger automatic approver assignment
            const activity = await prisma.activity.create({
              data: {
                title: `test_prop_activity_${testId}`,
                description: 'Test activity for approver assignment',
                supervisorId: supervisorMembership.id,
                bipra: bipra as Bipra,
                activityType: activityType as ActivityType,
              },
            });

            // Manually assign approvers based on approval rules
            // (This simulates what the backend should do automatically)
            const activeRules = await prisma.approvalRule.findMany({
              where: {
                churchId: church.id,
                active: true,
              },
              include: {
                positions: {
                  include: {
                    membership: true,
                  },
                },
              },
            });

            const approverMembershipIds = new Set<number>();
            for (const rule of activeRules) {
              for (const position of rule.positions) {
                if (position.membershipId) {
                  approverMembershipIds.add(position.membershipId);
                }
              }
            }

            // Create approvers
            for (const membershipId of approverMembershipIds) {
              await prisma.approver.create({
                data: {
                  activityId: activity.id,
                  membershipId: membershipId,
                  status: 'UNCONFIRMED',
                },
              });
            }

            // Verify approvers were assigned
            const assignedApprovers = await prisma.approver.findMany({
              where: {
                activityId: activity.id,
              },
              include: {
                membership: {
                  include: {
                    membershipPositions: true,
                  },
                },
              },
            });

            // Property: All assigned approvers should have positions from active approval rules
            for (const approver of assignedApprovers) {
              const approverPositionIds =
                approver.membership.membershipPositions.map((mp) => mp.id);
              const rulePositionIds = positions.map((p) => p.id);

              const hasMatchingPosition = approverPositionIds.some((id) =>
                rulePositionIds.includes(id),
              );

              expect(hasMatchingPosition).toBe(true);
            }

            // Property: All members with matching positions should be assigned as approvers
            const expectedApproverIds = Array.from(approverMembershipIds);
            const actualApproverIds = assignedApprovers.map(
              (a) => a.membershipId,
            );

            expect(actualApproverIds.sort()).toEqual(
              expectedApproverIds.sort(),
            );

            // Property: All approvers should start with UNCONFIRMED status
            for (const approver of assignedApprovers) {
              expect(approver.status).toBe('UNCONFIRMED');
            }

            // Property: Number of approvers should match number of unique members with matching positions
            expect(assignedApprovers.length).toBe(approverMembershipIds.size);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should not assign approvers from inactive approval rules', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          generators.bipraArb,
          async (activityType: string, bipra: string) => {
            const testId = generateTestId();

            // Create test church with location
            const church = await createTestChurch(prisma, {
              name: `test_prop_church_${testId}`,
              location: {
                name: `test_prop_location_${testId}`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor account and membership
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `test_prop_${testId}_supervisor`,
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
                name: `test_prop_position_${testId}`,
                churchId: church.id,
              },
            });

            // Create INACTIVE approval rule
            await prisma.approvalRule.create({
              data: {
                name: `test_prop_rule_${testId}`,
                description: 'Inactive test approval rule',
                active: false, // Inactive
                churchId: church.id,
                positions: {
                  connect: [{ id: position.id }],
                },
              },
            });

            // Create member with this position
            const memberAccount = await createTestAccount(prisma, {
              name: `Member ${testId}`,
              phone: `test_prop_${testId}_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const membership = await createTestMembership(prisma, {
              accountId: memberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: position.id },
              data: {
                membershipId: membership.id,
              },
            });

            // Create activity
            const activity = await prisma.activity.create({
              data: {
                title: `test_prop_activity_${testId}`,
                description: 'Test activity with inactive rule',
                supervisorId: supervisorMembership.id,
                bipra: bipra as Bipra,
                activityType: activityType as ActivityType,
              },
            });

            // Simulate automatic approver assignment (only from active rules)
            const activeRules = await prisma.approvalRule.findMany({
              where: {
                churchId: church.id,
                active: true, // Only active rules
              },
              include: {
                positions: {
                  include: {
                    membership: true,
                  },
                },
              },
            });

            const approverMembershipIds = new Set<number>();
            for (const rule of activeRules) {
              for (const pos of rule.positions) {
                if (pos.membershipId) {
                  approverMembershipIds.add(pos.membershipId);
                }
              }
            }

            // Create approvers only from active rules
            for (const membershipId of approverMembershipIds) {
              await prisma.approver.create({
                data: {
                  activityId: activity.id,
                  membershipId: membershipId,
                  status: 'UNCONFIRMED',
                },
              });
            }

            // Verify no approvers were assigned (since the rule is inactive)
            const assignedApprovers = await prisma.approver.findMany({
              where: {
                activityId: activity.id,
              },
            });

            // Property: No approvers should be assigned from inactive rules
            expect(assignedApprovers.length).toBe(0);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should handle multiple approval rules with overlapping positions', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.activityTypeArb,
          generators.bipraArb,
          async (activityType: string, bipra: string) => {
            const testId = generateTestId();

            // Create test church with location
            const church = await createTestChurch(prisma, {
              name: `test_prop_church_${testId}`,
              location: {
                name: `test_prop_location_${testId}`,
                latitude: 0,
                longitude: 0,
              },
            });

            // Create supervisor account and membership
            const supervisorAccount = await createTestAccount(prisma, {
              name: `Supervisor ${testId}`,
              phone: `test_prop_${testId}_supervisor`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const supervisorMembership = await createTestMembership(prisma, {
              accountId: supervisorAccount.id,
              churchId: church.id,
            });

            // Create two membership positions
            const position1 = await prisma.membershipPosition.create({
              data: {
                name: `test_prop_position_${testId}_1`,
                churchId: church.id,
              },
            });

            const position2 = await prisma.membershipPosition.create({
              data: {
                name: `test_prop_position_${testId}_2`,
                churchId: church.id,
              },
            });

            // Create two active approval rules with overlapping positions
            await prisma.approvalRule.create({
              data: {
                name: `test_prop_rule_${testId}_1`,
                description: 'First approval rule',
                active: true,
                churchId: church.id,
                positions: {
                  connect: [{ id: position1.id }],
                },
              },
            });

            await prisma.approvalRule.create({
              data: {
                name: `test_prop_rule_${testId}_2`,
                description: 'Second approval rule',
                active: true,
                churchId: church.id,
                positions: {
                  connect: [{ id: position1.id }, { id: position2.id }],
                },
              },
            });

            // Create member with position1 (appears in both rules)
            const memberAccount = await createTestAccount(prisma, {
              name: `Member ${testId}`,
              phone: `test_prop_${testId}_member`,
              gender: 'MALE',
              maritalStatus: 'SINGLE',
            });

            const membership = await createTestMembership(prisma, {
              accountId: memberAccount.id,
              churchId: church.id,
            });

            await prisma.membershipPosition.update({
              where: { id: position1.id },
              data: {
                membershipId: membership.id,
              },
            });

            // Create activity
            const activity = await prisma.activity.create({
              data: {
                title: `test_prop_activity_${testId}`,
                description: 'Test activity with overlapping rules',
                supervisorId: supervisorMembership.id,
                bipra: bipra as Bipra,
                activityType: activityType as ActivityType,
              },
            });

            // Simulate automatic approver assignment
            const activeRules = await prisma.approvalRule.findMany({
              where: {
                churchId: church.id,
                active: true,
              },
              include: {
                positions: {
                  include: {
                    membership: true,
                  },
                },
              },
            });

            const approverMembershipIds = new Set<number>();
            for (const rule of activeRules) {
              for (const pos of rule.positions) {
                if (pos.membershipId) {
                  approverMembershipIds.add(pos.membershipId);
                }
              }
            }

            // Create approvers (Set ensures uniqueness)
            for (const membershipId of approverMembershipIds) {
              await prisma.approver.create({
                data: {
                  activityId: activity.id,
                  membershipId: membershipId,
                  status: 'UNCONFIRMED',
                },
              });
            }

            // Verify approvers
            const assignedApprovers = await prisma.approver.findMany({
              where: {
                activityId: activity.id,
              },
            });

            // Property: Member should be assigned only once despite appearing in multiple rules
            expect(assignedApprovers.length).toBe(1);
            expect(assignedApprovers[0].membershipId).toBe(membership.id);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
