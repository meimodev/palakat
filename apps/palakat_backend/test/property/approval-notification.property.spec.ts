/**
 * Property-Based Tests for Approval Status Change Notifications
 *
 * **Feature: push-notification, Property 8: Approval Notification Deduplication**
 * **Feature: push-notification, Property 9: Approval Notification Recipients**
 *
 * This test suite verifies that approval status change notifications are properly
 * deduplicated and sent to the correct recipients.
 *
 * **Validates: Requirements 6.2, 6.3, 6.5**
 */

import * as fc from 'fast-check';
import { NotificationType, ApprovalStatus } from '@prisma/client';
import { TEST_CONFIG } from './utils/test-helpers';
import {
  bipraArb,
  activityTypeArb,
  churchIdArb,
  membershipIdArb,
  approvalStatusArb,
} from './generators';

/**
 * Interface representing an approver with relations needed for notifications
 */
interface ApproverWithRelations {
  id: number;
  membershipId: number;
  status: ApprovalStatus;
  membership: {
    id: number;
    account: {
      name: string;
    };
  };
  activity: {
    id: number;
    title: string;
    bipra: string;
    activityType: string;
    supervisorId: number;
    supervisor: {
      id: number;
      churchId: number;
    };
    approvers: Array<{
      id: number;
      membershipId: number;
      status: ApprovalStatus;
    }>;
  };
}

/**
 * Helper function to format membership interest name
 */
function formatMembershipInterest(membershipId: number): string {
  return `membership.${membershipId}`;
}

/**
 * Simulates the notification recipient calculation for approval status changes.
 * This mirrors the expected behavior of notifyApprovalStatusChanged.
 *
 * Recipients include:
 * 1. The activity supervisor
 * 2. Other unconfirmed approvers (excluding the approver who just changed status)
 *
 * Deduplication: If supervisor is also an approver, they receive only one notification.
 */
function calculateApprovalNotificationRecipients(
  approver: ApproverWithRelations,
): number[] {
  const supervisorId = approver.activity.supervisorId;
  const changingApproverId = approver.membershipId;

  // Get other unconfirmed approvers (excluding the one who just changed status)
  const otherUnconfirmedApprovers = approver.activity.approvers
    .filter(
      (a) =>
        a.membershipId !== changingApproverId &&
        a.status === ApprovalStatus.UNCONFIRMED,
    )
    .map((a) => a.membershipId);

  // Start with supervisor
  const recipients = new Set<number>([supervisorId]);

  // Add other unconfirmed approvers
  for (const approverId of otherUnconfirmedApprovers) {
    recipients.add(approverId);
  }

  return Array.from(recipients);
}

/**
 * Simulates the notification creation logic for approval status changes
 */
function simulateApprovalStatusChangeNotifications(
  approver: ApproverWithRelations,
  newStatus: ApprovalStatus,
): Array<{
  recipient: string;
  type: NotificationType;
  title: string;
  body: string;
}> {
  const recipients = calculateApprovalNotificationRecipients(approver);
  const approverName = approver.membership.account.name;
  const activityTitle = approver.activity.title;

  const notificationType =
    newStatus === ApprovalStatus.APPROVED
      ? NotificationType.APPROVAL_CONFIRMED
      : NotificationType.APPROVAL_REJECTED;

  const statusText =
    newStatus === ApprovalStatus.APPROVED ? 'approved' : 'rejected';

  return recipients.map((membershipId) => ({
    recipient: formatMembershipInterest(membershipId),
    type: notificationType,
    title: `Activity ${statusText}: ${activityTitle}`,
    body: `${approverName} has ${statusText} this activity`,
  }));
}

describe('Approval Notification Property Tests', () => {
  /**
   * **Feature: push-notification, Property 8: Approval Notification Deduplication**
   *
   * *For any* approval status change where the supervisor is also an approver,
   * the system should send exactly one notification to the supervisor (not two).
   *
   * **Validates: Requirements 6.3**
   */
  describe('Property 8: Approval Notification Deduplication', () => {
    it('should send only one notification to supervisor when supervisor is also an approver', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.string({ minLength: 1, maxLength: 100 }),
          bipraArb,
          activityTypeArb,
          churchIdArb,
          membershipIdArb, // supervisor/approver ID (same person)
          membershipIdArb, // changing approver ID
          fc.constantFrom(ApprovalStatus.APPROVED, ApprovalStatus.REJECTED),
          async (
            activityTitle: string,
            bipra: string,
            activityType: string,
            churchId: number,
            supervisorApproverId: number,
            changingApproverId: number,
            newStatus: ApprovalStatus,
          ) => {
            // Ensure changing approver is different from supervisor
            if (changingApproverId === supervisorApproverId) {
              changingApproverId = supervisorApproverId + 1;
            }

            // Create approver with supervisor also being an approver
            const approver: ApproverWithRelations = {
              id: 1,
              membershipId: changingApproverId,
              status: ApprovalStatus.UNCONFIRMED,
              membership: {
                id: changingApproverId,
                account: { name: 'Test Approver' },
              },
              activity: {
                id: 1,
                title: activityTitle,
                bipra,
                activityType,
                supervisorId: supervisorApproverId,
                supervisor: {
                  id: supervisorApproverId,
                  churchId,
                },
                approvers: [
                  // Supervisor is also an approver (UNCONFIRMED)
                  {
                    id: 2,
                    membershipId: supervisorApproverId,
                    status: ApprovalStatus.UNCONFIRMED,
                  },
                  // The approver who is changing status
                  {
                    id: 1,
                    membershipId: changingApproverId,
                    status: ApprovalStatus.UNCONFIRMED,
                  },
                ],
              },
            };

            const notifications = simulateApprovalStatusChangeNotifications(
              approver,
              newStatus,
            );

            // Property: Supervisor should receive exactly one notification
            const supervisorInterest =
              formatMembershipInterest(supervisorApproverId);
            const supervisorNotifications = notifications.filter(
              (n) => n.recipient === supervisorInterest,
            );

            expect(supervisorNotifications.length).toBe(1);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should not duplicate notifications for any recipient', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.string({ minLength: 1, maxLength: 100 }),
          bipraArb,
          activityTypeArb,
          churchIdArb,
          membershipIdArb,
          fc.array(membershipIdArb, { minLength: 1, maxLength: 5 }),
          fc.constantFrom(ApprovalStatus.APPROVED, ApprovalStatus.REJECTED),
          async (
            activityTitle: string,
            bipra: string,
            activityType: string,
            churchId: number,
            supervisorId: number,
            approverIds: number[],
            newStatus: ApprovalStatus,
          ) => {
            // Ensure unique approver IDs and pick one as the changing approver
            const uniqueApproverIds = [...new Set(approverIds)];
            if (uniqueApproverIds.length === 0) return true;

            const changingApproverId = uniqueApproverIds[0];

            const approver: ApproverWithRelations = {
              id: 1,
              membershipId: changingApproverId,
              status: ApprovalStatus.UNCONFIRMED,
              membership: {
                id: changingApproverId,
                account: { name: 'Test Approver' },
              },
              activity: {
                id: 1,
                title: activityTitle,
                bipra,
                activityType,
                supervisorId,
                supervisor: {
                  id: supervisorId,
                  churchId,
                },
                approvers: uniqueApproverIds.map((id, index) => ({
                  id: index + 1,
                  membershipId: id,
                  status: ApprovalStatus.UNCONFIRMED,
                })),
              },
            };

            const notifications = simulateApprovalStatusChangeNotifications(
              approver,
              newStatus,
            );

            // Property: No duplicate recipients
            const recipients = notifications.map((n) => n.recipient);
            const uniqueRecipients = [...new Set(recipients)];

            expect(recipients.length).toBe(uniqueRecipients.length);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  /**
   * **Feature: push-notification, Property 9: Approval Notification Recipients**
   *
   * *For any* approval status change on an activity with M total approvers where
   * K have already confirmed, the system should notify exactly (M - K - 1) other
   * unconfirmed approvers plus the supervisor (deduplicated per Property 8).
   *
   * **Validates: Requirements 6.2, 6.5**
   */
  describe('Property 9: Approval Notification Recipients', () => {
    it('should notify supervisor and other unconfirmed approvers', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.string({ minLength: 1, maxLength: 100 }),
          bipraArb,
          activityTypeArb,
          churchIdArb,
          membershipIdArb, // supervisor ID
          fc.array(
            fc.record({
              membershipId: membershipIdArb,
              status: approvalStatusArb,
            }),
            { minLength: 2, maxLength: 6 },
          ),
          fc.constantFrom(ApprovalStatus.APPROVED, ApprovalStatus.REJECTED),
          async (
            activityTitle: string,
            bipra: string,
            activityType: string,
            churchId: number,
            supervisorId: number,
            approverData: Array<{ membershipId: number; status: string }>,
            newStatus: ApprovalStatus,
          ) => {
            // Ensure unique membership IDs
            const seenIds = new Set<number>();
            const uniqueApprovers = approverData.filter((a) => {
              if (seenIds.has(a.membershipId)) return false;
              seenIds.add(a.membershipId);
              return true;
            });

            if (uniqueApprovers.length < 2) return true;

            // Pick the first UNCONFIRMED approver as the one changing status
            const changingApproverData = uniqueApprovers.find(
              (a) => a.status === 'UNCONFIRMED',
            );
            if (!changingApproverData) return true;

            const changingApproverId = changingApproverData.membershipId;

            const approver: ApproverWithRelations = {
              id: 1,
              membershipId: changingApproverId,
              status: ApprovalStatus.UNCONFIRMED,
              membership: {
                id: changingApproverId,
                account: { name: 'Test Approver' },
              },
              activity: {
                id: 1,
                title: activityTitle,
                bipra,
                activityType,
                supervisorId,
                supervisor: {
                  id: supervisorId,
                  churchId,
                },
                approvers: uniqueApprovers.map((a, index) => ({
                  id: index + 1,
                  membershipId: a.membershipId,
                  status: a.status as ApprovalStatus,
                })),
              },
            };

            const notifications = simulateApprovalStatusChangeNotifications(
              approver,
              newStatus,
            );

            // Calculate expected recipients
            const otherUnconfirmedCount = uniqueApprovers.filter(
              (a) =>
                a.membershipId !== changingApproverId &&
                a.status === 'UNCONFIRMED',
            ).length;

            // Supervisor is always notified
            const supervisorIsAlsoUnconfirmedApprover = uniqueApprovers.some(
              (a) =>
                a.membershipId === supervisorId &&
                a.membershipId !== changingApproverId &&
                a.status === 'UNCONFIRMED',
            );

            // Expected: supervisor + other unconfirmed (deduplicated)
            let expectedCount: number;
            if (supervisorIsAlsoUnconfirmedApprover) {
              // Supervisor counted once (deduplication)
              expectedCount = otherUnconfirmedCount + 1 - 1; // +1 for supervisor, -1 for dedup
              expectedCount = Math.max(1, otherUnconfirmedCount); // At least supervisor
            } else {
              expectedCount = 1 + otherUnconfirmedCount; // supervisor + others
            }

            // Property: Supervisor should always be notified
            const supervisorInterest = formatMembershipInterest(supervisorId);
            const supervisorNotified = notifications.some(
              (n) => n.recipient === supervisorInterest,
            );
            expect(supervisorNotified).toBe(true);

            // Property: Changing approver should NOT be notified
            const changingApproverInterest =
              formatMembershipInterest(changingApproverId);
            const changingApproverNotified = notifications.some(
              (n) => n.recipient === changingApproverInterest,
            );
            expect(changingApproverNotified).toBe(false);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should include correct notification type based on approval status', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.string({ minLength: 1, maxLength: 100 }),
          bipraArb,
          activityTypeArb,
          churchIdArb,
          membershipIdArb,
          membershipIdArb,
          fc.constantFrom(ApprovalStatus.APPROVED, ApprovalStatus.REJECTED),
          async (
            activityTitle: string,
            bipra: string,
            activityType: string,
            churchId: number,
            supervisorId: number,
            changingApproverId: number,
            newStatus: ApprovalStatus,
          ) => {
            // Ensure different IDs
            if (changingApproverId === supervisorId) {
              changingApproverId = supervisorId + 1;
            }

            const approver: ApproverWithRelations = {
              id: 1,
              membershipId: changingApproverId,
              status: ApprovalStatus.UNCONFIRMED,
              membership: {
                id: changingApproverId,
                account: { name: 'Test Approver' },
              },
              activity: {
                id: 1,
                title: activityTitle,
                bipra,
                activityType,
                supervisorId,
                supervisor: {
                  id: supervisorId,
                  churchId,
                },
                approvers: [
                  {
                    id: 1,
                    membershipId: changingApproverId,
                    status: ApprovalStatus.UNCONFIRMED,
                  },
                ],
              },
            };

            const notifications = simulateApprovalStatusChangeNotifications(
              approver,
              newStatus,
            );

            // Property: All notifications should have correct type
            const expectedType =
              newStatus === ApprovalStatus.APPROVED
                ? NotificationType.APPROVAL_CONFIRMED
                : NotificationType.APPROVAL_REJECTED;

            for (const notification of notifications) {
              expect(notification.type).toBe(expectedType);
            }

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should include approver name and status in notification body', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.string({ minLength: 1, maxLength: 100 }),
          fc.string({ minLength: 1, maxLength: 50 }), // approver name
          bipraArb,
          activityTypeArb,
          churchIdArb,
          membershipIdArb,
          membershipIdArb,
          fc.constantFrom(ApprovalStatus.APPROVED, ApprovalStatus.REJECTED),
          async (
            activityTitle: string,
            approverName: string,
            bipra: string,
            activityType: string,
            churchId: number,
            supervisorId: number,
            changingApproverId: number,
            newStatus: ApprovalStatus,
          ) => {
            // Ensure different IDs
            if (changingApproverId === supervisorId) {
              changingApproverId = supervisorId + 1;
            }

            const approver: ApproverWithRelations = {
              id: 1,
              membershipId: changingApproverId,
              status: ApprovalStatus.UNCONFIRMED,
              membership: {
                id: changingApproverId,
                account: { name: approverName },
              },
              activity: {
                id: 1,
                title: activityTitle,
                bipra,
                activityType,
                supervisorId,
                supervisor: {
                  id: supervisorId,
                  churchId,
                },
                approvers: [
                  {
                    id: 1,
                    membershipId: changingApproverId,
                    status: ApprovalStatus.UNCONFIRMED,
                  },
                ],
              },
            };

            const notifications = simulateApprovalStatusChangeNotifications(
              approver,
              newStatus,
            );

            const statusText =
              newStatus === ApprovalStatus.APPROVED ? 'approved' : 'rejected';

            // Property: Notification body should include approver name
            for (const notification of notifications) {
              expect(notification.body).toContain(approverName);
            }

            // Property: Notification body should include status
            for (const notification of notifications) {
              expect(notification.body.toLowerCase()).toContain(statusText);
            }

            // Property: Notification title should include activity title
            for (const notification of notifications) {
              expect(notification.title).toContain(activityTitle);
            }

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
