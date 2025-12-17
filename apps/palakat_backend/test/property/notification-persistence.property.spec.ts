/**
 * Property-Based Tests for Notification Persistence
 *
 * **Feature: push-notification, Property 1: Notification Persistence Round-Trip**
 *
 * This test suite verifies that notifications can be created and retrieved
 * with all fields preserved correctly.
 *
 * **Validates: Requirements 1.2, 1.3**
 */

import * as fc from 'fast-check';
import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import {
  PrismaClient,
  NotificationType,
} from '../../src/generated/prisma/client';
import { TEST_CONFIG, getDatabasePostgresUrl } from './utils/test-helpers';
import {
  notificationTitleArb,
  notificationBodyArb,
  notificationTypeArb,
  notificationRecipientArb,
} from './generators';

describe('Notification Persistence Property Tests', () => {
  let prisma: PrismaClient;
  let pool: Pool;
  const createdNotificationIds: number[] = [];

  beforeAll(async () => {
    pool = new Pool({
      connectionString: getDatabasePostgresUrl(),
      allowExitOnIdle: true,
    });
    const adapter = new PrismaPg(pool);
    prisma = new PrismaClient({ adapter });
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
    await pool.end();
  });

  /**
   * **Feature: push-notification, Property 1: Notification Persistence Round-Trip**
   *
   * *For any* valid notification data (title, body, type, recipient, activityId),
   * creating a notification and then querying it by ID should return a notification
   * with matching fields.
   *
   * **Validates: Requirements 1.2, 1.3**
   */
  describe('Property 1: Notification Persistence Round-Trip', () => {
    it('should persist and retrieve notification with all fields matching', async () => {
      await fc.assert(
        fc.asyncProperty(
          notificationTitleArb,
          notificationBodyArb,
          notificationTypeArb,
          notificationRecipientArb,
          async (
            title: string,
            body: string,
            type: string,
            recipient: string,
          ) => {
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

            createdNotificationIds.push(created.id);

            // Query notification by ID
            const retrieved = await prisma.notification.findUnique({
              where: { id: created.id },
            });

            // Verify all fields match
            expect(retrieved).not.toBeNull();
            expect(retrieved!.title).toBe(title);
            expect(retrieved!.body).toBe(body);
            expect(retrieved!.type).toBe(type);
            expect(retrieved!.recipient).toBe(recipient);
            expect(retrieved!.isRead).toBe(false);
            expect(retrieved!.activityId).toBeNull();

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should persist notification with activityId when provided', async () => {
      // First, we need to create an activity to reference
      // For this test, we'll create a minimal setup
      const location = await prisma.location.create({
        data: {
          name: 'Test Location',
          latitude: 0,
          longitude: 0,
        },
      });

      const church = await prisma.church.create({
        data: {
          name: 'Test Church for Notification',
          locationId: location.id,
        },
      });

      const account = await prisma.account.create({
        data: {
          name: 'Test Account',
          phone: `test_notif_${Date.now()}`,
          gender: 'MALE',
          maritalStatus: 'SINGLE',
          dob: new Date('1990-01-01'),
        },
      });

      const membership = await prisma.membership.create({
        data: {
          accountId: account.id,
          churchId: church.id,
        },
      });

      const activity = await prisma.activity.create({
        data: {
          title: 'Test Activity',
          bipra: 'PKB',
          activityType: 'SERVICE',
          supervisorId: membership.id,
        },
      });

      try {
        await fc.assert(
          fc.asyncProperty(
            notificationTitleArb,
            notificationBodyArb,
            notificationTypeArb,
            notificationRecipientArb,
            async (
              title: string,
              body: string,
              type: string,
              recipient: string,
            ) => {
              // Create notification with activityId
              const created = await prisma.notification.create({
                data: {
                  title,
                  body,
                  type: type as NotificationType,
                  recipient,
                  activityId: activity.id,
                  isRead: false,
                },
              });

              createdNotificationIds.push(created.id);

              // Query notification by ID with activity relation
              const retrieved = await prisma.notification.findUnique({
                where: { id: created.id },
                include: { activity: true },
              });

              // Verify all fields match including activityId
              expect(retrieved).not.toBeNull();
              expect(retrieved!.title).toBe(title);
              expect(retrieved!.body).toBe(body);
              expect(retrieved!.type).toBe(type);
              expect(retrieved!.recipient).toBe(recipient);
              expect(retrieved!.activityId).toBe(activity.id);
              expect(retrieved!.activity).not.toBeNull();
              expect(retrieved!.activity!.id).toBe(activity.id);

              return true;
            },
          ),
          { numRuns: 20 }, // Reduced runs since we're using shared activity
        );
      } finally {
        // Clean up test data
        await prisma.notification.deleteMany({
          where: { activityId: activity.id },
        });
        await prisma.activity.delete({ where: { id: activity.id } });
        await prisma.membership.delete({ where: { id: membership.id } });
        await prisma.account.delete({ where: { id: account.id } });
        await prisma.church.delete({ where: { id: church.id } });
        await prisma.location.delete({ where: { id: location.id } });
      }
    });
  });
});
