/**
 * Property-Based Tests for Activity Reminder Feature
 *
 * **Feature: activity-reminder**
 *
 * This test suite verifies the correctness properties for the activity reminder
 * feature, including persistence, validation, and retrieval of reminder values.
 */

import { ActivityType, Bipra, PrismaClient, Reminder } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import * as fc from 'fast-check';
import * as generators from './generators';
import { TEST_CONFIG } from './utils/test-helpers';

describe('Activity Reminder Property Tests', () => {
  let prisma: PrismaClient;
  let testChurchId: number;
  let testMembershipId: number;
  let testAccountId: number;
  let testLocationId: number;

  const TEST_PREFIX = 'test_reminder_';

  beforeAll(async () => {
    prisma = new PrismaClient();

    // Create test location
    const location = await prisma.location.create({
      data: {
        name: `${TEST_PREFIX}location`,
        latitude: 1.234,
        longitude: 5.678,
      },
    });
    testLocationId = location.id;

    // Create test church
    const church = await prisma.church.create({
      data: {
        name: `${TEST_PREFIX}church`,
        locationId: testLocationId,
      },
    });
    testChurchId = church.id;

    // Create test account
    const passwordHash = await bcrypt.hash(
      'TestPassword123!',
      TEST_CONFIG.HASH_ROUNDS,
    );
    const account = await prisma.account.create({
      data: {
        name: `${TEST_PREFIX}account`,
        phone: `${TEST_PREFIX}${Date.now()}`,
        passwordHash,
        gender: 'MALE',
        maritalStatus: 'SINGLE',
        dob: new Date('1990-01-01'),
      },
    });
    testAccountId = account.id;

    // Create test membership
    const membership = await prisma.membership.create({
      data: {
        accountId: testAccountId,
        churchId: testChurchId,
      },
    });
    testMembershipId = membership.id;
  });

  afterAll(async () => {
    // Clean up in reverse order of creation
    await prisma.activity.deleteMany({
      where: { supervisorId: testMembershipId },
    });
    await prisma.membership.deleteMany({
      where: { id: testMembershipId },
    });
    await prisma.account.deleteMany({
      where: { id: testAccountId },
    });
    await prisma.church.deleteMany({
      where: { id: testChurchId },
    });
    await prisma.location.deleteMany({
      where: { id: testLocationId },
    });
    await prisma.$disconnect();
  });

  afterEach(async () => {
    // Clean up activities created during tests
    await prisma.activity.deleteMany({
      where: { supervisorId: testMembershipId },
    });
  });

  // **Feature: activity-reminder, Property 1: Reminder persistence on create**
  // **Validates: Requirements 1.1, 2.1**
  describe('Property 1: Reminder persistence on create', () => {
    it('should persist reminder value when creating SERVICE or EVENT activity', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.reminderArb,
          fc.constantFrom('SERVICE', 'EVENT'),
          generators.bipraArb,
          generators.nameArb,
          async (
            reminder: string,
            activityType: string,
            bipra: string,
            title: string,
          ) => {
            // Create activity with reminder
            const activity = await prisma.activity.create({
              data: {
                title: title || 'Test Activity',
                activityType: activityType as ActivityType,
                bipra: bipra as Bipra,
                reminder: reminder as Reminder,
                supervisorId: testMembershipId,
              },
            });

            // Retrieve the activity
            const retrieved = await prisma.activity.findUnique({
              where: { id: activity.id },
            });

            // Verify reminder was persisted correctly
            expect(retrieved).toBeDefined();
            expect(retrieved?.reminder).toBe(reminder);

            // Clean up
            await prisma.activity.delete({ where: { id: activity.id } });
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: activity-reminder, Property 3: Announcement activities accept null reminder**
  // **Validates: Requirements 1.2**
  describe('Property 3: Announcement activities accept null reminder', () => {
    it('should accept ANNOUNCEMENT activities without requiring reminder', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.bipraArb,
          generators.nameArb,
          generators.optionalReminderArb,
          async (bipra: string, title: string, reminder: string | null) => {
            // Create ANNOUNCEMENT activity (with or without reminder)
            const activity = await prisma.activity.create({
              data: {
                title: title || 'Test Announcement',
                activityType: 'ANNOUNCEMENT' as ActivityType,
                bipra: bipra as Bipra,
                reminder: reminder as Reminder | null,
                supervisorId: testMembershipId,
              },
            });

            // Verify activity was created successfully
            expect(activity).toBeDefined();
            expect(activity.activityType).toBe('ANNOUNCEMENT');
            expect(activity.reminder).toBe(reminder);

            // Clean up
            await prisma.activity.delete({ where: { id: activity.id } });
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: activity-reminder, Property 4: Reminder included in list responses**
  // **Validates: Requirements 2.2, 2.3**
  describe('Property 4: Reminder included in list responses', () => {
    it('should include correct reminder value for each activity in list', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.array(
            fc.record({
              reminder: generators.optionalReminderArb,
              activityType: generators.activityTypeArb,
              bipra: generators.bipraArb,
            }),
            { minLength: 1, maxLength: 5 },
          ),
          async (
            activityConfigs: Array<{
              reminder: string | null;
              activityType: string;
              bipra: string;
            }>,
          ) => {
            // Create multiple activities with various reminder values
            const createdActivities = await Promise.all(
              activityConfigs.map((config, index) =>
                prisma.activity.create({
                  data: {
                    title: `Test Activity ${index}`,
                    activityType: config.activityType as ActivityType,
                    bipra: config.bipra as Bipra,
                    reminder: config.reminder as Reminder | null,
                    supervisorId: testMembershipId,
                  },
                }),
              ),
            );

            // Retrieve all activities for this supervisor
            const activities = await prisma.activity.findMany({
              where: { supervisorId: testMembershipId },
            });

            // Verify each activity has the correct reminder value
            for (const created of createdActivities) {
              const found = activities.find((a) => a.id === created.id);
              expect(found).toBeDefined();
              expect(found?.reminder).toBe(created.reminder);
            }

            // Clean up
            await Promise.all(
              createdActivities.map((a) =>
                prisma.activity.delete({ where: { id: a.id } }),
              ),
            );
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: activity-reminder, Property 5: Reminder update persistence**
  // **Validates: Requirements 3.1, 3.2**
  describe('Property 5: Reminder update persistence', () => {
    it('should persist updated reminder value including null', async () => {
      await fc.assert(
        fc.asyncProperty(
          generators.reminderArb,
          generators.optionalReminderArb,
          generators.activityTypeArb,
          generators.bipraArb,
          async (
            initialReminder: string,
            updatedReminder: string | null,
            activityType: string,
            bipra: string,
          ) => {
            // Create activity with initial reminder
            const activity = await prisma.activity.create({
              data: {
                title: 'Test Activity for Update',
                activityType: activityType as ActivityType,
                bipra: bipra as Bipra,
                reminder: initialReminder as Reminder,
                supervisorId: testMembershipId,
              },
            });

            // Update the reminder
            const updated = await prisma.activity.update({
              where: { id: activity.id },
              data: { reminder: updatedReminder as Reminder | null },
            });

            // Retrieve and verify
            const retrieved = await prisma.activity.findUnique({
              where: { id: activity.id },
            });

            expect(retrieved).toBeDefined();
            expect(retrieved?.reminder).toBe(updatedReminder);
            expect(updated.reminder).toBe(updatedReminder);

            // Clean up
            await prisma.activity.delete({ where: { id: activity.id } });
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
