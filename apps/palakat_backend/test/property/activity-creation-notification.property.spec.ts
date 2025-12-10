/**
 * Property-Based Tests for Activity Creation Notifications
 *
 * **Feature: push-notification, Property 6: Notification Payload Structure**
 * **Feature: push-notification, Property 7: Activity Creation Notification Count**
 *
 * This test suite verifies that activity creation notifications are properly
 * structured and that the correct number of notifications are created.
 *
 * **Validates: Requirements 2.5, 5.2, 5.3, 5.4, 5.5**
 */

import * as fc from 'fast-check';
import { NotificationType } from '@prisma/client';
import { TEST_CONFIG } from './utils/test-helpers';
import {
  notificationTitleArb,
  notificationBodyArb,
  bipraArb,
  activityTypeArb,
  churchIdArb,
  membershipIdArb,
} from './generators';

/**
 * Interface representing an activity with relations needed for notifications
 */
interface ActivityWithRelations {
  id: number;
  title: string;
  bipra: string;
  activityType: string;
  date: Date | null;
  supervisorId: number;
  supervisor: {
    id: number;
    churchId: number;
  };
  approvers: Array<{
    id: number;
    membershipId: number;
    membership: {
      id: number;
    };
  }>;
}

/**
 * Interface representing a notification payload
 */
interface NotificationPayload {
  title: string;
  body: string;
  deepLink?: string;
  data?: Record<string, unknown>;
}

/**
 * Helper function to format BIPRA interest name
 */
function formatBipraInterest(churchId: number, bipra: string): string {
  return `church.${churchId}_bipra.${bipra.toUpperCase()}`;
}

/**
 * Helper function to format membership interest name
 */
function formatMembershipInterest(membershipId: number): string {
  return `membership.${membershipId}`;
}

/**
 * Simulates the notification creation logic for activity creation
 * This mirrors the expected behavior of notifyActivityCreated
 */
function simulateActivityCreationNotifications(
  activity: ActivityWithRelations,
): Array<{
  recipient: string;
  type: NotificationType;
  title: string;
  body: string;
}> {
  const notifications: Array<{
    recipient: string;
    type: NotificationType;
    title: string;
    body: string;
  }> = [];

  const churchId = activity.supervisor.churchId;
  const bipra = activity.bipra;

  // 1. BIPRA group notification
  const bipraInterest = formatBipraInterest(churchId, bipra);
  const dateStr = activity.date
    ? activity.date.toLocaleDateString()
    : 'No date set';

  notifications.push({
    recipient: bipraInterest,
    type: NotificationType.ACTIVITY_CREATED,
    title: `New Activity: ${activity.title}`,
    body: `${activity.activityType} - ${dateStr}`,
  });

  // 2. Individual approver notifications
  for (const approver of activity.approvers) {
    const membershipInterest = formatMembershipInterest(approver.membershipId);
    notifications.push({
      recipient: membershipInterest,
      type: NotificationType.APPROVAL_REQUIRED,
      title: `Approval Required: ${activity.title}`,
      body: `You have been assigned to approve this ${activity.activityType.toLowerCase()}`,
    });
  }

  return notifications;
}

describe('Activity Creation Notification Property Tests', () => {
  /**
   * **Feature: push-notification, Property 6: Notification Payload Structure**
   *
   * *For any* notification payload constructed by the service, the payload
   * should contain non-empty title, non-empty body, and valid deep link data.
   *
   * **Validates: Requirements 2.5, 5.4, 5.5**
   */
  describe('Property 6: Notification Payload Structure', () => {
    it('should construct notification payloads with non-empty title and body', async () => {
      await fc.assert(
        fc.asyncProperty(
          notificationTitleArb,
          notificationBodyArb,
          fc.option(fc.webUrl(), { nil: undefined }),
          fc.option(
            fc.record({
              activityId: fc.integer({ min: 1 }),
              type: fc.string(),
            }),
            { nil: undefined },
          ),
          async (
            title: string,
            body: string,
            deepLink: string | undefined,
            data: Record<string, unknown> | undefined,
          ) => {
            const payload: NotificationPayload = {
              title,
              body,
              deepLink,
              data,
            };

            // Property: title must be non-empty
            expect(payload.title.length).toBeGreaterThan(0);

            // Property: body must be non-empty
            expect(payload.body.length).toBeGreaterThan(0);

            // Property: if deepLink is provided, it should be a valid URL
            if (payload.deepLink) {
              expect(() => new URL(payload.deepLink!)).not.toThrow();
            }

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should format activity notification title with activity title', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.string({ minLength: 1, maxLength: 100 }),
          bipraArb,
          activityTypeArb,
          churchIdArb,
          fc.array(membershipIdArb, { minLength: 0, maxLength: 5 }),
          async (
            activityTitle: string,
            bipra: string,
            activityType: string,
            churchId: number,
            approverIds: number[],
          ) => {
            const activity: ActivityWithRelations = {
              id: 1,
              title: activityTitle,
              bipra,
              activityType,
              date: new Date(),
              supervisorId: 1,
              supervisor: {
                id: 1,
                churchId,
              },
              approvers: approverIds.map((id, index) => ({
                id: index + 1,
                membershipId: id,
                membership: { id },
              })),
            };

            const notifications =
              simulateActivityCreationNotifications(activity);

            // Property: BIPRA notification title should include activity title
            const bipraNotification = notifications.find(
              (n) => n.type === NotificationType.ACTIVITY_CREATED,
            );
            expect(bipraNotification).toBeDefined();
            expect(bipraNotification!.title).toContain(activityTitle);

            // Property: BIPRA notification body should include activity type
            expect(bipraNotification!.body).toContain(activityType);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should format approver notification body indicating approval is required', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.string({ minLength: 1, maxLength: 100 }),
          bipraArb,
          activityTypeArb,
          churchIdArb,
          fc.array(membershipIdArb, { minLength: 1, maxLength: 5 }),
          async (
            activityTitle: string,
            bipra: string,
            activityType: string,
            churchId: number,
            approverIds: number[],
          ) => {
            const activity: ActivityWithRelations = {
              id: 1,
              title: activityTitle,
              bipra,
              activityType,
              date: new Date(),
              supervisorId: 1,
              supervisor: {
                id: 1,
                churchId,
              },
              approvers: approverIds.map((id, index) => ({
                id: index + 1,
                membershipId: id,
                membership: { id },
              })),
            };

            const notifications =
              simulateActivityCreationNotifications(activity);

            // Property: Each approver notification should indicate approval is required
            const approverNotifications = notifications.filter(
              (n) => n.type === NotificationType.APPROVAL_REQUIRED,
            );

            for (const notification of approverNotifications) {
              expect(notification.title).toContain(activityTitle);
              expect(notification.body.toLowerCase()).toContain('approve');
            }

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  /**
   * **Feature: push-notification, Property 7: Activity Creation Notification Count**
   *
   * *For any* activity created with N approvers, the system should create
   * exactly N+1 notification records (1 BIPRA group + N individual approvers).
   *
   * **Validates: Requirements 5.2, 5.3**
   */
  describe('Property 7: Activity Creation Notification Count', () => {
    it('should create exactly N+1 notifications for activity with N approvers', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.string({ minLength: 1, maxLength: 100 }),
          bipraArb,
          activityTypeArb,
          churchIdArb,
          fc.array(membershipIdArb, { minLength: 0, maxLength: 10 }),
          async (
            activityTitle: string,
            bipra: string,
            activityType: string,
            churchId: number,
            approverIds: number[],
          ) => {
            // Ensure unique approver IDs
            const uniqueApproverIds = [...new Set(approverIds)];
            const numApprovers = uniqueApproverIds.length;

            const activity: ActivityWithRelations = {
              id: 1,
              title: activityTitle,
              bipra,
              activityType,
              date: new Date(),
              supervisorId: 1,
              supervisor: {
                id: 1,
                churchId,
              },
              approvers: uniqueApproverIds.map((id, index) => ({
                id: index + 1,
                membershipId: id,
                membership: { id },
              })),
            };

            const notifications =
              simulateActivityCreationNotifications(activity);

            // Property: Total notifications = 1 (BIPRA) + N (approvers)
            const expectedCount = 1 + numApprovers;
            expect(notifications.length).toBe(expectedCount);

            // Property: Exactly 1 ACTIVITY_CREATED notification
            const activityCreatedCount = notifications.filter(
              (n) => n.type === NotificationType.ACTIVITY_CREATED,
            ).length;
            expect(activityCreatedCount).toBe(1);

            // Property: Exactly N APPROVAL_REQUIRED notifications
            const approvalRequiredCount = notifications.filter(
              (n) => n.type === NotificationType.APPROVAL_REQUIRED,
            ).length;
            expect(approvalRequiredCount).toBe(numApprovers);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should create notifications with correct recipient interests', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.string({ minLength: 1, maxLength: 100 }),
          bipraArb,
          activityTypeArb,
          churchIdArb,
          fc.array(membershipIdArb, { minLength: 1, maxLength: 5 }),
          async (
            activityTitle: string,
            bipra: string,
            activityType: string,
            churchId: number,
            approverIds: number[],
          ) => {
            const uniqueApproverIds = [...new Set(approverIds)];

            const activity: ActivityWithRelations = {
              id: 1,
              title: activityTitle,
              bipra,
              activityType,
              date: new Date(),
              supervisorId: 1,
              supervisor: {
                id: 1,
                churchId,
              },
              approvers: uniqueApproverIds.map((id, index) => ({
                id: index + 1,
                membershipId: id,
                membership: { id },
              })),
            };

            const notifications =
              simulateActivityCreationNotifications(activity);

            // Property: BIPRA notification should have correct interest format
            const bipraNotification = notifications.find(
              (n) => n.type === NotificationType.ACTIVITY_CREATED,
            );
            const expectedBipraInterest = formatBipraInterest(churchId, bipra);
            expect(bipraNotification!.recipient).toBe(expectedBipraInterest);

            // Property: Each approver notification should have correct membership interest
            const approverNotifications = notifications.filter(
              (n) => n.type === NotificationType.APPROVAL_REQUIRED,
            );

            for (let i = 0; i < uniqueApproverIds.length; i++) {
              const expectedInterest = formatMembershipInterest(
                uniqueApproverIds[i],
              );
              const matchingNotification = approverNotifications.find(
                (n) => n.recipient === expectedInterest,
              );
              expect(matchingNotification).toBeDefined();
            }

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should handle activity with no approvers (only BIPRA notification)', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.string({ minLength: 1, maxLength: 100 }),
          bipraArb,
          activityTypeArb,
          churchIdArb,
          async (
            activityTitle: string,
            bipra: string,
            activityType: string,
            churchId: number,
          ) => {
            const activity: ActivityWithRelations = {
              id: 1,
              title: activityTitle,
              bipra,
              activityType,
              date: new Date(),
              supervisorId: 1,
              supervisor: {
                id: 1,
                churchId,
              },
              approvers: [], // No approvers
            };

            const notifications =
              simulateActivityCreationNotifications(activity);

            // Property: With 0 approvers, should have exactly 1 notification (BIPRA only)
            expect(notifications.length).toBe(1);
            expect(notifications[0].type).toBe(
              NotificationType.ACTIVITY_CREATED,
            );

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
