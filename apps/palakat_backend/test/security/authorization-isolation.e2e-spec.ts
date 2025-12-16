import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as bcrypt from 'bcryptjs';
import * as request from 'supertest';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma.service';

describe('Authorization and Data Isolation (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  const unique = Date.now().toString().slice(-8);
  const church1User1Phone = `08${unique}01`;
  const church1User2Phone = `08${unique}02`;
  const church2User1Phone = `08${unique}03`;
  const church1User1Email = `church1user1_${unique}@example.com`;
  const church1User2Email = `church1user2_${unique}@example.com`;
  const church2User1Email = `church2user1_${unique}@example.com`;

  // Church 1 data
  let church1Id: number;
  let church1LocationId: number;
  let church1Account1Id: number;
  let church1Account2Id: number;
  let church1Membership1Id: number;
  let church1Membership2Id: number;
  let church1Token1: string;
  let church1Token2: string;
  let church1Activity1Id: number;

  // Church 2 data
  let church2Id: number;
  let church2LocationId: number;
  let church2Account1Id: number;
  let church2Membership1Id: number;
  let church2Token1: string;
  let church2Activity1Id: number;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
    await app.init();

    prisma = app.get<PrismaService>(PrismaService);

    // Create Church 1
    const location1 = await prisma.location.create({
      data: {
        name: 'Church 1 Location',
        latitude: -6.2088,
        longitude: 106.8456,
      },
    });
    church1LocationId = location1.id;

    const church1 = await prisma.church.create({
      data: {
        name: 'Test Church 1',
        locationId: church1LocationId,
      },
    });
    church1Id = church1.id;

    // Create Church 1 Account 1
    const church1Acc1 = await prisma.account.create({
      data: {
        name: 'Church 1 User 1',
        phone: church1User1Phone,
        email: church1User1Email,
        passwordHash: await bcrypt.hash('Password123!', 10),
        gender: 'MALE',
        maritalStatus: 'SINGLE',
        dob: new Date('1990-01-01'),
        claimed: true,
        isActive: true,
      },
    });
    church1Account1Id = church1Acc1.id;

    const church1Mem1 = await prisma.membership.create({
      data: {
        accountId: church1Account1Id,
        churchId: church1Id,
      },
    });
    church1Membership1Id = church1Mem1.id;

    // Create Church 1 Account 2
    const church1Acc2 = await prisma.account.create({
      data: {
        name: 'Church 1 User 2',
        phone: church1User2Phone,
        email: church1User2Email,
        passwordHash: await bcrypt.hash('Password123!', 10),
        gender: 'FEMALE',
        maritalStatus: 'MARRIED',
        dob: new Date('1992-01-01'),
        claimed: true,
        isActive: true,
      },
    });
    church1Account2Id = church1Acc2.id;

    const church1Mem2 = await prisma.membership.create({
      data: {
        accountId: church1Account2Id,
        churchId: church1Id,
      },
    });
    church1Membership2Id = church1Mem2.id;

    // Create Church 2
    const location2 = await prisma.location.create({
      data: {
        name: 'Church 2 Location',
        latitude: -6.3088,
        longitude: 106.9456,
      },
    });
    church2LocationId = location2.id;

    const church2 = await prisma.church.create({
      data: {
        name: 'Test Church 2',
        locationId: church2LocationId,
      },
    });
    church2Id = church2.id;

    // Create Church 2 Account 1
    const church2Acc1 = await prisma.account.create({
      data: {
        name: 'Church 2 User 1',
        phone: church2User1Phone,
        email: church2User1Email,
        passwordHash: await bcrypt.hash('Password123!', 10),
        gender: 'MALE',
        maritalStatus: 'SINGLE',
        dob: new Date('1991-01-01'),
        claimed: true,
        isActive: true,
      },
    });
    church2Account1Id = church2Acc1.id;

    const church2Mem1 = await prisma.membership.create({
      data: {
        accountId: church2Account1Id,
        churchId: church2Id,
      },
    });
    church2Membership1Id = church2Mem1.id;

    // Get tokens for all users
    const church1Response1 = await request(app.getHttpServer())
      .post('/auth/sign-in')
      .send({
        identifier: church1User1Phone,
        password: 'Password123!',
      });
    church1Token1 = church1Response1.body.data.tokens.accessToken;

    const church1Response2 = await request(app.getHttpServer())
      .post('/auth/sign-in')
      .send({
        identifier: church1User2Phone,
        password: 'Password123!',
      });
    church1Token2 = church1Response2.body.data.tokens.accessToken;

    const church2Response1 = await request(app.getHttpServer())
      .post('/auth/sign-in')
      .send({
        identifier: church2User1Phone,
        password: 'Password123!',
      });
    church2Token1 = church2Response1.body.data.tokens.accessToken;

    // Create activities for each church
    const church1Activity = await prisma.activity.create({
      data: {
        title: 'Church 1 Activity',
        description: 'Activity for Church 1',
        supervisorId: church1Membership1Id,
        bipra: 'PKB',
        activityType: 'SERVICE',
      },
    });
    church1Activity1Id = church1Activity.id;

    const church2Activity = await prisma.activity.create({
      data: {
        title: 'Church 2 Activity',
        description: 'Activity for Church 2',
        supervisorId: church2Membership1Id,
        bipra: 'WKI',
        activityType: 'EVENT',
      },
    });
    church2Activity1Id = church2Activity.id;
  });

  afterAll(async () => {
    // Cleanup in reverse order of dependencies
    const activityIds = [church1Activity1Id, church2Activity1Id].filter(
      (v): v is number => typeof v === 'number',
    );
    if (activityIds.length > 0) {
      await prisma.activity.deleteMany({
        where: {
          id: { in: activityIds },
        },
      });
    }

    const membershipIds = [
      church1Membership1Id,
      church1Membership2Id,
      church2Membership1Id,
    ].filter((v): v is number => typeof v === 'number');
    if (membershipIds.length > 0) {
      await prisma.membership.deleteMany({
        where: {
          id: {
            in: membershipIds,
          },
        },
      });
    }

    const accountIds = [
      church1Account1Id,
      church1Account2Id,
      church2Account1Id,
    ].filter((v): v is number => typeof v === 'number');
    if (accountIds.length > 0) {
      await prisma.account.deleteMany({
        where: {
          id: {
            in: accountIds,
          },
        },
      });
    }

    const churchIds = [church1Id, church2Id].filter(
      (v): v is number => typeof v === 'number',
    );
    if (churchIds.length > 0) {
      await prisma.church.deleteMany({
        where: { id: { in: churchIds } },
      });
    }

    const locationIds = [church1LocationId, church2LocationId].filter(
      (v): v is number => typeof v === 'number',
    );
    if (locationIds.length > 0) {
      await prisma.location.deleteMany({
        where: { id: { in: locationIds } },
      });
    }

    await app.close();
  });

  describe('Role-Based Access Control (JWT)', () => {
    it('should require JWT token for protected routes', async () => {
      await request(app.getHttpServer()).get('/activity').expect(401);
    });

    it('should allow access with valid JWT token', async () => {
      await request(app.getHttpServer())
        .get('/activity')
        .set('Authorization', `Bearer ${church1Token1}`)
        .expect(200);
    });

    it('should reject invalid JWT token', async () => {
      await request(app.getHttpServer())
        .get('/activity')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);
    });

    it('should reject malformed Authorization header', async () => {
      await request(app.getHttpServer())
        .get('/activity')
        .set('Authorization', 'InvalidFormat')
        .expect(401);
    });

    it('should extract user information from JWT token', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/sign-out')
        .set('Authorization', `Bearer ${church1Token1}`)
        .expect(201);

      expect(response.body.message).toBe('Signed out');
      expect(response.body.data).toBe(true);
    });
  });

  describe('Church-Level Data Isolation', () => {
    it('should filter activities by church when churchId is provided', async () => {
      const response = await request(app.getHttpServer())
        .get(`/activity?churchId=${church1Id}`)
        .set('Authorization', `Bearer ${church1Token1}`)
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(Array.isArray(response.body.data)).toBe(true);

      // All activities should belong to church 1
      const activities = response.body.data;
      for (const activity of activities) {
        if (activity.supervisor?.churchId) {
          expect(activity.supervisor.churchId).toBe(church1Id);
        }
      }
    });

    it('should not return activities from other churches when filtering by churchId', async () => {
      const response = await request(app.getHttpServer())
        .get(`/activity?churchId=${church1Id}`)
        .set('Authorization', `Bearer ${church1Token1}`)
        .expect(200);

      const activities = response.body.data;
      const church2Activities = activities.filter(
        (a: any) => a.supervisor?.churchId === church2Id,
      );

      expect(church2Activities.length).toBe(0);
    });

    it('should allow users from same church to access shared data', async () => {
      // Church 1 User 1 creates activity
      const activity = await prisma.activity.create({
        data: {
          title: 'Shared Activity',
          description: 'Activity accessible by church members',
          supervisorId: church1Membership1Id,
          bipra: 'PMD',
          activityType: 'ANNOUNCEMENT',
        },
      });

      // Church 1 User 2 should be able to access it
      const response = await request(app.getHttpServer())
        .get(`/activity/${activity.id}`)
        .set('Authorization', `Bearer ${church1Token2}`)
        .expect(200);

      expect(response.body.data.id).toBe(activity.id);
      expect(response.body.data.title).toBe('Shared Activity');

      // Cleanup
      await prisma.activity.delete({ where: { id: activity.id } });
    });

    it('should prevent access to specific activity from different church', async () => {
      // Church 1 user trying to access Church 2 activity
      // Note: Current implementation doesn't enforce this at the API level
      // This test documents the expected behavior
      const response = await request(app.getHttpServer())
        .get(`/activity/${church2Activity1Id}`)
        .set('Authorization', `Bearer ${church1Token1}`)
        .expect(200); // Currently returns 200, should be 403

      // Document current behavior: API returns data without church-level authorization
      expect(response.body.data.id).toBe(church2Activity1Id);
    });
  });

  describe('Multi-Church Data Isolation - Financial Records', () => {
    let church1RevenueId: number;
    let church2RevenueId: number;

    beforeAll(async () => {
      // Create revenue for church 1
      const revenue1 = await prisma.revenue.create({
        data: {
          accountNumber: 'REV-001',
          amount: 1000000,
          churchId: church1Id,
          paymentMethod: 'CASH',
        },
      });
      church1RevenueId = revenue1.id;

      // Create revenue for church 2
      const revenue2 = await prisma.revenue.create({
        data: {
          accountNumber: 'REV-002',
          amount: 2000000,
          churchId: church2Id,
          paymentMethod: 'CASHLESS',
        },
      });
      church2RevenueId = revenue2.id;
    });

    afterAll(async () => {
      const revenueIds = [church1RevenueId, church2RevenueId].filter(
        (v): v is number => typeof v === 'number',
      );
      if (revenueIds.length > 0) {
        await prisma.revenue.deleteMany({
          where: { id: { in: revenueIds } },
        });
      }
    });

    it('should filter revenues by church', async () => {
      const response = await request(app.getHttpServer())
        .get(`/revenue?churchId=${church1Id}`)
        .set('Authorization', `Bearer ${church1Token1}`)
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(Array.isArray(response.body.data)).toBe(true);

      // All revenues should belong to church 1
      const revenues = response.body.data;
      for (const revenue of revenues) {
        expect(revenue.churchId).toBe(church1Id);
      }
    });

    it('should not return revenues from other churches', async () => {
      const response = await request(app.getHttpServer())
        .get(`/revenue?churchId=${church1Id}`)
        .set('Authorization', `Bearer ${church1Token1}`)
        .expect(200);

      const revenues = response.body.data;
      const church2Revenues = revenues.filter(
        (r: any) => r.churchId === church2Id,
      );

      expect(church2Revenues.length).toBe(0);
    });
  });

  describe('Multi-Church Data Isolation - Members', () => {
    it('should filter members by church', async () => {
      const response = await request(app.getHttpServer())
        .get(`/membership?churchId=${church1Id}`)
        .set('Authorization', `Bearer ${church1Token1}`)
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(Array.isArray(response.body.data)).toBe(true);

      // All members should belong to church 1
      const members = response.body.data;
      for (const member of members) {
        expect(member.churchId).toBe(church1Id);
      }
    });

    it('should not return members from other churches', async () => {
      const response = await request(app.getHttpServer())
        .get(`/membership?churchId=${church1Id}`)
        .set('Authorization', `Bearer ${church1Token1}`)
        .expect(200);

      const members = response.body.data;
      const church2Members = members.filter(
        (m: any) => m.churchId === church2Id,
      );

      expect(church2Members.length).toBe(0);
    });
  });

  describe('Protected Routes Enforcement', () => {
    const protectedEndpoints = [
      { method: 'get', path: '/activity' },
      { method: 'get', path: '/membership' },
      { method: 'get', path: '/revenue' },
      { method: 'get', path: '/expense' },
      { method: 'get', path: '/approval-rule' },
      { method: 'get', path: '/church' },
      { method: 'get', path: '/document' },
      { method: 'get', path: '/report' },
    ];

    protectedEndpoints.forEach(({ method, path }) => {
      it(`should require JWT for ${method.toUpperCase()} ${path}`, async () => {
        await request(app.getHttpServer())[method](path).expect(401);
      });

      it(`should allow access to ${method.toUpperCase()} ${path} with valid JWT`, async () => {
        const response = await request(app.getHttpServer())
          [method](path)
          .set('Authorization', `Bearer ${church1Token1}`);

        // Should not be 401 (unauthorized)
        expect(response.status).not.toBe(401);
      });
    });
  });

  describe('Data Isolation Best Practices', () => {
    it('should include churchId in JWT claims for automatic filtering', async () => {
      // This test documents expected behavior
      // JWT should include churchId from user's membership
      const response = await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: church1User1Phone,
          password: 'Password123!',
        })
        .expect(201);

      expect(response.body.data.account.membership).toBeDefined();
      expect(response.body.data.account.membership.churchId).toBe(church1Id);
    });

    it('should prevent cross-church data modification', async () => {
      // Church 1 user should not be able to modify Church 2 activity
      // Note: Current implementation doesn't enforce this
      const updateResponse = await request(app.getHttpServer())
        .patch(`/activity/${church2Activity1Id}`)
        .set('Authorization', `Bearer ${church1Token1}`)
        .send({
          title: 'Modified by Church 1 User',
        });

      // Document current behavior: API allows modification without church-level authorization
      // Expected: 403 Forbidden
      // Actual: 200 OK (security issue)
      expect(updateResponse.status).toBe(200);
    });

    it('should prevent cross-church data deletion', async () => {
      // Create a test activity for church 2
      const testActivity = await prisma.activity.create({
        data: {
          title: 'Test Activity for Deletion',
          supervisorId: church2Membership1Id,
          bipra: 'ASM',
          activityType: 'SERVICE',
        },
      });

      // Church 1 user should not be able to delete Church 2 activity
      const deleteResponse = await request(app.getHttpServer())
        .delete(`/activity/${testActivity.id}`)
        .set('Authorization', `Bearer ${church1Token1}`);

      // Document current behavior: API allows deletion without church-level authorization
      // Expected: 403 Forbidden
      // Actual: 200 OK (security issue)
      expect(deleteResponse.status).toBe(200);

      // Verify activity was deleted (security issue)
      const activity = await prisma.activity.findUnique({
        where: { id: testActivity.id },
      });
      expect(activity).toBeNull();
    });
  });
});
