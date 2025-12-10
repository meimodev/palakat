/**
 * Property-Based Tests for Notification CRUD Operations
 *
 * **Feature: push-notification, Property 2: Read Status State Transition**
 * **Feature: push-notification, Property 3: Notification Filtering Correctness**
 * **Feature: push-notification, Property 10: Notification Authorization**
 * **Feature: push-notification, Property 11: Notification Deletion**
 * **Feature: push-notification, Property 12: Unread Count Accuracy**
 *
 * This test suite verifies correctness properties for notification CRUD operations.
 *
 * **Validates: Requirements 1.4, 1.5, 7.1, 7.2, 7.3, 7.4, 7.5**
 */

import * as fc from 'fast-check';
import { PrismaClient, NotificationType } from '@prisma/client';
import { TEST_CONFIG } from './utils/test-helpers';
import {
  notificationTitleArb,
  notificationBodyArb,
  notificationTypeArb,
} from './generators';

describe('Notification CRUD Property Tests', () => {
  let prisma: PrismaClient;
  const createdNotificationIds: number[] = [];
  const testMembershipIds: number[] = [];

  beforeAll(async () => {
    prisma = new PrismaClient();
    await prisma.$connect();
  });

  afterAll(async () => {
    // Clean up created notifications
    if (createdNotificationIds.length > 0) {
      await prisma.notification.deleteMany({
        where: { id: { in: createdNotificationIds } },
      });
    }
    await prisma.$disconnect();
  });

  /**
   * **Feature: push-notification, Property 2: Read Status State Transition**
   *
   * *For any* unread notification, marking it as read should result in isRead being true,
   * and the change should persist across queries.
   *
   * **Validates: Requirements 1.4, 7.3**
   */
  describe('Property 2: Read Status State Transition', () => {
    it('should transition isRead from false to true and persist', async () => {
      await fc.assert(
        fc.asyncProperty(
          notificationTitleArb,
          notificationBodyArb,
          notificationTypeArb,
          fc.integer({ min: 1, max: 1000000 }),
          async (
            title: string,
            body: string,
            type: string,
            membershipId: number,
          ) => {
            const recipient = `membership.${membershipId}`;

            // Create an unread notification
            const created = await prisma.notification.create({
              data: {
                title,
                body,
                type: type as NotificationType,
                recipient,
                isRead: false,
              },
            });
            createdNotificationIds.push(created.id);

            // Verify initial state is unread
            expect(created.isRead).toBe(false);

            // Mark as read
            const updated = await prisma.notification.update({
              where: { id: created.id },
              data: { isRead: true },
            });

            // Verify state transition
            expect(updated.isRead).toBe(true);

            // Verify persistence by re-querying
            const retrieved = await prisma.notification.findUnique({
              where: { id: created.id },
            });
            expect(retrieved!.isRead).toBe(true);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should be idempotent - marking as read multiple times keeps isRead true', async () => {
      await fc.assert(
        fc.asyncProperty(
          notificationTitleArb,
          notificationBodyArb,
          fc.integer({ min: 1, max: 1000000 }),
          async (title: string, body: string, membershipId: number) => {
            const recipient = `membership.${membershipId}`;

            // Create notification
            const created = await prisma.notification.create({
              data: {
                title,
                body,
                type: 'ACTIVITY_CREATED',
                recipient,
                isRead: false,
              },
            });
            createdNotificationIds.push(created.id);

            // Mark as read multiple times
            await prisma.notification.update({
              where: { id: created.id },
              data: { isRead: true },
            });
            await prisma.notification.update({
              where: { id: created.id },
              data: { isRead: true },
            });
            await prisma.notification.update({
              where: { id: created.id },
              data: { isRead: true },
            });

            // Verify still read
            const retrieved = await prisma.notification.findUnique({
              where: { id: created.id },
            });
            expect(retrieved!.isRead).toBe(true);

            return true;
          },
        ),
        { numRuns: 50 },
      );
    });
  });

  /**
   * **Feature: push-notification, Property 3: Notification Filtering Correctness**
   *
   * *For any* set of notifications with varying recipients, isRead statuses, and types,
   * filtering by any combination of these fields should return only notifications
   * matching all specified criteria.
   *
   * **Validates: Requirements 1.5, 7.1**
   */
  describe('Property 3: Notification Filtering Correctness', () => {
    it('should filter by isRead status correctly', async () => {
      const testMembershipId = Math.floor(Math.random() * 1000000) + 1;
      const recipient = `membership.${testMembershipId}`;

      // Create a mix of read and unread notifications
      const notifications = await Promise.all([
        prisma.notification.create({
          data: {
            title: 'Test 1',
            body: 'Body 1',
            type: 'ACTIVITY_CREATED',
            recipient,
            isRead: false,
          },
        }),
        prisma.notification.create({
          data: {
            title: 'Test 2',
            body: 'Body 2',
            type: 'APPROVAL_REQUIRED',
            recipient,
            isRead: true,
          },
        }),
        prisma.notification.create({
          data: {
            title: 'Test 3',
            body: 'Body 3',
            type: 'APPROVAL_CONFIRMED',
            recipient,
            isRead: false,
          },
        }),
      ]);

      notifications.forEach((n) => createdNotificationIds.push(n.id));

      // Filter by isRead = false
      const unreadNotifications = await prisma.notification.findMany({
        where: { recipient, isRead: false },
      });

      // All returned notifications should be unread
      expect(unreadNotifications.every((n) => n.isRead === false)).toBe(true);
      expect(unreadNotifications.length).toBe(2);

      // Filter by isRead = true
      const readNotifications = await prisma.notification.findMany({
        where: { recipient, isRead: true },
      });

      // All returned notifications should be read
      expect(readNotifications.every((n) => n.isRead === true)).toBe(true);
      expect(readNotifications.length).toBe(1);
    });

    it('should filter by type correctly', async () => {
      const testMembershipId = Math.floor(Math.random() * 1000000) + 1;
      const recipient = `membership.${testMembershipId}`;

      // Create notifications with different types
      const notifications = await Promise.all([
        prisma.notification.create({
          data: {
            title: 'Activity Created',
            body: 'Body',
            type: 'ACTIVITY_CREATED',
            recipient,
            isRead: false,
          },
        }),
        prisma.notification.create({
          data: {
            title: 'Approval Required',
            body: 'Body',
            type: 'APPROVAL_REQUIRED',
            recipient,
            isRead: false,
          },
        }),
        prisma.notification.create({
          data: {
            title: 'Approval Confirmed',
            body: 'Body',
            type: 'APPROVAL_CONFIRMED',
            recipient,
            isRead: false,
          },
        }),
      ]);

      notifications.forEach((n) => createdNotificationIds.push(n.id));

      // Filter by type
      const activityCreatedNotifications = await prisma.notification.findMany({
        where: { recipient, type: 'ACTIVITY_CREATED' },
      });

      // All returned notifications should have the correct type
      expect(
        activityCreatedNotifications.every(
          (n) => n.type === 'ACTIVITY_CREATED',
        ),
      ).toBe(true);
      expect(activityCreatedNotifications.length).toBe(1);
    });

    it('should filter by recipient correctly', async () => {
      const membershipId1 = Math.floor(Math.random() * 1000000) + 1;
      const membershipId2 = membershipId1 + 1;
      const recipient1 = `membership.${membershipId1}`;
      const recipient2 = `membership.${membershipId2}`;

      // Create notifications for different recipients
      const notifications = await Promise.all([
        prisma.notification.create({
          data: {
            title: 'For User 1',
            body: 'Body',
            type: 'ACTIVITY_CREATED',
            recipient: recipient1,
            isRead: false,
          },
        }),
        prisma.notification.create({
          data: {
            title: 'For User 2',
            body: 'Body',
            type: 'ACTIVITY_CREATED',
            recipient: recipient2,
            isRead: false,
          },
        }),
      ]);

      notifications.forEach((n) => createdNotificationIds.push(n.id));

      // Filter by recipient
      const user1Notifications = await prisma.notification.findMany({
        where: { recipient: recipient1 },
      });

      // All returned notifications should have the correct recipient
      expect(user1Notifications.every((n) => n.recipient === recipient1)).toBe(
        true,
      );
      expect(user1Notifications.length).toBe(1);
    });

    it('should filter by combined criteria correctly', async () => {
      const testMembershipId = Math.floor(Math.random() * 1000000) + 1;
      const recipient = `membership.${testMembershipId}`;

      // Create notifications with various combinations
      const notifications = await Promise.all([
        prisma.notification.create({
          data: {
            title: 'Unread Activity',
            body: 'Body',
            type: 'ACTIVITY_CREATED',
            recipient,
            isRead: false,
          },
        }),
        prisma.notification.create({
          data: {
            title: 'Read Activity',
            body: 'Body',
            type: 'ACTIVITY_CREATED',
            recipient,
            isRead: true,
          },
        }),
        prisma.notification.create({
          data: {
            title: 'Unread Approval',
            body: 'Body',
            type: 'APPROVAL_REQUIRED',
            recipient,
            isRead: false,
          },
        }),
      ]);

      notifications.forEach((n) => createdNotificationIds.push(n.id));

      // Filter by type AND isRead
      const unreadActivityNotifications = await prisma.notification.findMany({
        where: {
          recipient,
          type: 'ACTIVITY_CREATED',
          isRead: false,
        },
      });

      // All returned notifications should match all criteria
      expect(
        unreadActivityNotifications.every(
          (n) =>
            n.type === 'ACTIVITY_CREATED' &&
            n.isRead === false &&
            n.recipient === recipient,
        ),
      ).toBe(true);
      expect(unreadActivityNotifications.length).toBe(1);
    });
  });

  /**
   * **Feature: push-notification, Property 10: Notification Authorization**
   *
   * *For any* notification query or update operation, the operation should succeed
   * only if the requesting user's membership interest matches the notification's recipient field.
   *
   * **Validates: Requirements 7.2**
   */
  describe('Property 10: Notification Authorization', () => {
    it('should only return notifications matching the user membership interest', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 1000000 }),
          fc.integer({ min: 1, max: 1000000 }),
          async (membershipId1: number, membershipId2: number) => {
            // Ensure different membership IDs
            const actualMembershipId2 =
              membershipId1 === membershipId2
                ? membershipId2 + 1
                : membershipId2;

            const recipient1 = `membership.${membershipId1}`;
            const recipient2 = `membership.${actualMembershipId2}`;

            // Create notifications for both users
            const notification1 = await prisma.notification.create({
              data: {
                title: 'For User 1',
                body: 'Body',
                type: 'ACTIVITY_CREATED',
                recipient: recipient1,
                isRead: false,
              },
            });
            createdNotificationIds.push(notification1.id);

            const notification2 = await prisma.notification.create({
              data: {
                title: 'For User 2',
                body: 'Body',
                type: 'ACTIVITY_CREATED',
                recipient: recipient2,
                isRead: false,
              },
            });
            createdNotificationIds.push(notification2.id);

            // Query as user 1 - should only see their notifications
            const user1Notifications = await prisma.notification.findMany({
              where: { recipient: recipient1 },
            });

            // Verify user 1 only sees their notifications
            expect(
              user1Notifications.every((n) => n.recipient === recipient1),
            ).toBe(true);
            expect(
              user1Notifications.some((n) => n.recipient === recipient2),
            ).toBe(false);

            return true;
          },
        ),
        { numRuns: 50 },
      );
    });
  });

  /**
   * **Feature: push-notification, Property 11: Notification Deletion**
   *
   * *For any* notification that is deleted, subsequent queries for that notification
   * should return not found or empty result.
   *
   * **Validates: Requirements 7.4**
   */
  describe('Property 11: Notification Deletion', () => {
    it('should not find deleted notifications', async () => {
      await fc.assert(
        fc.asyncProperty(
          notificationTitleArb,
          notificationBodyArb,
          notificationTypeArb,
          fc.integer({ min: 1, max: 1000000 }),
          async (
            title: string,
            body: string,
            type: string,
            membershipId: number,
          ) => {
            const recipient = `membership.${membershipId}`;

            // Create notification
            const created = await prisma.notification.create({
              data: {
                title,
                body,
                type: type as NotificationType,
                recipient,
                isRead: false,
              },
            });

            // Verify it exists
            const beforeDelete = await prisma.notification.findUnique({
              where: { id: created.id },
            });
            expect(beforeDelete).not.toBeNull();

            // Delete notification
            await prisma.notification.delete({
              where: { id: created.id },
            });

            // Verify it no longer exists
            const afterDelete = await prisma.notification.findUnique({
              where: { id: created.id },
            });
            expect(afterDelete).toBeNull();

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  /**
   * **Feature: push-notification, Property 12: Unread Count Accuracy**
   *
   * *For any* user with N total notifications where K are unread,
   * the unread count returned should equal K.
   *
   * **Validates: Requirements 7.5**
   */
  describe('Property 12: Unread Count Accuracy', () => {
    it('should return accurate unread count', async () => {
      // Use a counter to ensure unique recipients for each test iteration
      let testCounter = Date.now();

      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 0, max: 5 }),
          fc.integer({ min: 0, max: 5 }),
          async (unreadCount: number, readCount: number) => {
            // Generate a unique recipient for this test iteration
            testCounter++;
            const recipient = `membership.test_${testCounter}`;

            // Create unread notifications
            const unreadNotifications = await Promise.all(
              Array.from({ length: unreadCount }, (_, i) =>
                prisma.notification.create({
                  data: {
                    title: `Unread ${i}`,
                    body: 'Body',
                    type: 'ACTIVITY_CREATED',
                    recipient,
                    isRead: false,
                  },
                }),
              ),
            );

            // Create read notifications
            const readNotifications = await Promise.all(
              Array.from({ length: readCount }, (_, i) =>
                prisma.notification.create({
                  data: {
                    title: `Read ${i}`,
                    body: 'Body',
                    type: 'ACTIVITY_CREATED',
                    recipient,
                    isRead: true,
                  },
                }),
              ),
            );

            // Track for cleanup
            [...unreadNotifications, ...readNotifications].forEach((n) =>
              createdNotificationIds.push(n.id),
            );

            // Count unread notifications
            const actualUnreadCount = await prisma.notification.count({
              where: {
                recipient,
                isRead: false,
              },
            });

            // Verify count matches expected
            expect(actualUnreadCount).toBe(unreadCount);

            // Also verify total count
            const totalCount = await prisma.notification.count({
              where: { recipient },
            });
            expect(totalCount).toBe(unreadCount + readCount);

            return true;
          },
        ),
        { numRuns: 50 },
      );
    });
  });
});
