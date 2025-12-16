import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as bcrypt from 'bcryptjs';
import * as request from 'supertest';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma.service';

describe('Authentication Security (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let testAccountId: number;
  let testChurchId: number;
  let testLocationId: number;
  let testMembershipId: number;

  const unique = Date.now().toString().slice(-8);
  const testUserPhone = `08${unique}10`;
  const lockoutUserPhone = `08${unique}11`;
  const inactiveUserPhone = `08${unique}12`;
  const unclaimedUserPhone = `08${unique}13`;
  const testUserEmail = `test_${unique}@example.com`;
  const lockoutUserEmail = `lockout_${unique}@example.com`;
  const inactiveUserEmail = `inactive_${unique}@example.com`;
  const unclaimedUserEmail = `unclaimed_${unique}@example.com`;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
    await app.init();

    prisma = app.get<PrismaService>(PrismaService);

    // Create test data
    const location = await prisma.location.create({
      data: {
        name: 'Test Church Location',
        latitude: -6.2088,
        longitude: 106.8456,
      },
    });
    testLocationId = location.id;

    const church = await prisma.church.create({
      data: {
        name: 'Test Church',
        locationId: testLocationId,
      },
    });
    testChurchId = church.id;

    const account = await prisma.account.create({
      data: {
        name: 'Test User',
        phone: testUserPhone,
        email: testUserEmail,
        passwordHash: await bcrypt.hash('TestPassword123!', 10),
        gender: 'MALE',
        maritalStatus: 'SINGLE',
        dob: new Date('1990-01-01'),
        claimed: true,
        isActive: true,
      },
    });
    testAccountId = account.id;

    const membership = await prisma.membership.create({
      data: {
        accountId: testAccountId,
        churchId: testChurchId,
      },
    });
    testMembershipId = membership.id;
  });

  afterAll(async () => {
    // Cleanup
    await prisma.membership.deleteMany({ where: { id: testMembershipId } });
    await prisma.account.deleteMany({ where: { id: testAccountId } });
    await prisma.church.deleteMany({ where: { id: testChurchId } });
    await prisma.location.deleteMany({ where: { id: testLocationId } });
    await app.close();
  });

  describe('Password Hashing with bcryptjs', () => {
    it('should hash passwords with bcryptjs (10 rounds)', async () => {
      const account = await prisma.account.findUnique({
        where: { id: testAccountId },
        select: { passwordHash: true },
      });

      expect(account?.passwordHash).toBeDefined();
      expect(account?.passwordHash).toMatch(/^\$2[aby]\$/); // bcrypt hash format

      // Verify the hash uses bcrypt
      const isValidHash = await bcrypt.compare(
        'TestPassword123!',
        account!.passwordHash!,
      );
      expect(isValidHash).toBe(true);
    });

    it('should not store plain text passwords', async () => {
      const account = await prisma.account.findUnique({
        where: { id: testAccountId },
        select: { passwordHash: true },
      });

      expect(account?.passwordHash).not.toBe('TestPassword123!');
    });

    it('should reject login with incorrect password', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: testUserPhone,
          password: 'WrongPassword',
        })
        .expect(401);

      expect(response.body.message).toBe('Invalid credentials');
    });
  });

  describe('Account Lockout after Failed Login Attempts', () => {
    let lockoutTestAccountId: number;

    beforeEach(async () => {
      // Create a fresh account for lockout testing
      const account = await prisma.account.create({
        data: {
          name: 'Lockout Test User',
          phone: lockoutUserPhone,
          email: lockoutUserEmail,
          passwordHash: await bcrypt.hash('CorrectPassword123!', 10),
          gender: 'MALE',
          maritalStatus: 'SINGLE',
          dob: new Date('1990-01-01'),
          claimed: true,
          isActive: true,
          failedLoginAttempts: 0,
          lockUntil: null,
        },
      });
      lockoutTestAccountId = account.id;

      await prisma.membership.create({
        data: {
          accountId: lockoutTestAccountId,
          churchId: testChurchId,
        },
      });
    });

    afterEach(async () => {
      await prisma.membership.deleteMany({
        where: { accountId: lockoutTestAccountId },
      });
      await prisma.account.deleteMany({ where: { id: lockoutTestAccountId } });
    });

    it('should track failed login attempts', async () => {
      // First failed attempt
      await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: lockoutUserPhone,
          password: 'WrongPassword',
        })
        .expect(401);

      let account = await prisma.account.findUnique({
        where: { id: lockoutTestAccountId },
        select: { failedLoginAttempts: true, lockUntil: true },
      });

      expect(account?.failedLoginAttempts).toBe(1);
      expect(account?.lockUntil).toBeNull();

      // Second failed attempt
      await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: lockoutUserPhone,
          password: 'WrongPassword',
        })
        .expect(401);

      account = await prisma.account.findUnique({
        where: { id: lockoutTestAccountId },
        select: { failedLoginAttempts: true, lockUntil: true },
      });

      expect(account?.failedLoginAttempts).toBe(2);
    });

    it('should lock account after 5 failed login attempts', async () => {
      // Make 5 failed attempts
      for (let i = 0; i < 5; i++) {
        await request(app.getHttpServer())
          .post('/auth/sign-in')
          .send({
            identifier: lockoutUserPhone,
            password: 'WrongPassword',
          })
          .expect(401);
      }

      const account = await prisma.account.findUnique({
        where: { id: lockoutTestAccountId },
        select: { failedLoginAttempts: true, lockUntil: true },
      });

      expect(account?.failedLoginAttempts).toBe(0); // Reset after lockout
      expect(account?.lockUntil).toBeDefined();
      expect(account?.lockUntil).toBeInstanceOf(Date);
      expect(account!.lockUntil!.getTime()).toBeGreaterThan(Date.now());
    });

    it('should prevent login when account is locked', async () => {
      // Lock the account manually
      await prisma.account.update({
        where: { id: lockoutTestAccountId },
        data: {
          lockUntil: new Date(Date.now() + 5 * 60 * 1000), // 5 minutes from now
        },
      });

      // Try to login with correct password
      const response = await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: lockoutUserPhone,
          password: 'CorrectPassword123!',
        })
        .expect(403);

      expect(response.body.message).toBe('Account is locked. Try again later');
    });

    it('should reset failed attempts counter on successful login', async () => {
      // Make 3 failed attempts
      for (let i = 0; i < 3; i++) {
        await request(app.getHttpServer())
          .post('/auth/sign-in')
          .send({
            identifier: lockoutUserPhone,
            password: 'WrongPassword',
          })
          .expect(401);
      }

      let account = await prisma.account.findUnique({
        where: { id: lockoutTestAccountId },
        select: { failedLoginAttempts: true, lockUntil: true },
      });
      expect(account?.failedLoginAttempts).toBe(3);

      // Successful login
      await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: lockoutUserPhone,
          password: 'CorrectPassword123!',
        })
        .expect(201);

      account = await prisma.account.findUnique({
        where: { id: lockoutTestAccountId },
        select: { failedLoginAttempts: true, lockUntil: true },
      });

      expect(account?.failedLoginAttempts).toBe(0);
      expect(account?.lockUntil).toBeNull();
    });
  });

  describe('Refresh Token Rotation', () => {
    let accessToken: string;
    let refreshToken: string;

    beforeEach(async () => {
      // Get fresh tokens
      const response = await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: testUserPhone,
          password: 'TestPassword123!',
        })
        .expect(201);

      accessToken = response.body.data.tokens.accessToken;
      refreshToken = response.body.data.tokens.refreshToken;
    });

    it('should return new access and refresh tokens on refresh', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken })
        .expect(201);

      expect(response.body.data.accessToken).toBeDefined();
      expect(response.body.data.refreshToken).toBeDefined();
      expect(response.body.data.accessToken).not.toBe(accessToken);
      expect(response.body.data.refreshToken).not.toBe(refreshToken);
    });

    it('should invalidate old refresh token after use (one-time use)', async () => {
      // Use refresh token once
      const firstRefresh = await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken })
        .expect(201);

      expect(firstRefresh.body.data.refreshToken).toBeDefined();

      // Try to use the same refresh token again
      await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken })
        .expect(401);
    });

    it('should store hashed refresh token in database', async () => {
      const account = await prisma.account.findUnique({
        where: { id: testAccountId },
        select: { refreshTokenHash: true },
      });

      expect(account?.refreshTokenHash).toBeDefined();
      expect(account?.refreshTokenHash).not.toBe(refreshToken);
      expect(account?.refreshTokenHash).toMatch(/^\$2[aby]\$/); // bcrypt hash format
    });

    it('should reject invalid refresh token', async () => {
      await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken: 'invalid-token' })
        .expect(400);
    });

    it('should reject expired refresh token', async () => {
      // Set refresh token expiration to past
      await prisma.account.update({
        where: { id: testAccountId },
        data: {
          refreshTokenExpiresAt: new Date(Date.now() - 1000), // 1 second ago
        },
      });

      await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken })
        .expect(401);
    });
  });

  describe('JWT Expiration and Refresh Flow', () => {
    let accessToken: string;
    let refreshToken: string;

    beforeEach(async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: testUserPhone,
          password: 'TestPassword123!',
        })
        .expect(201);

      accessToken = response.body.data.tokens.accessToken;
      refreshToken = response.body.data.tokens.refreshToken;
    });

    it('should generate valid JWT tokens on sign-in', async () => {
      expect(accessToken).toBeDefined();
      expect(refreshToken).toBeDefined();
      expect(accessToken).toMatch(/^[\w-]+\.[\w-]+\.[\w-]+$/); // JWT format
      expect(refreshToken).toMatch(/^[\w-]+\.[\w-]+\.[\w-]+$/);
    });

    it('should allow access to protected routes with valid access token', async () => {
      await request(app.getHttpServer())
        .post('/auth/sign-out')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(201);
    });

    it('should reject access to protected routes without token', async () => {
      await request(app.getHttpServer()).post('/auth/sign-out').expect(401);
    });

    it('should reject access to protected routes with invalid token', async () => {
      await request(app.getHttpServer())
        .post('/auth/sign-out')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);
    });

    it('should invalidate refresh token on sign-out', async () => {
      // Sign out
      await request(app.getHttpServer())
        .post('/auth/sign-out')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(201);

      // Try to use refresh token after sign-out
      await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken })
        .expect(401);

      // Verify refresh token is cleared in database
      const account = await prisma.account.findUnique({
        where: { id: testAccountId },
        select: {
          refreshTokenHash: true,
          refreshTokenExpiresAt: true,
          refreshTokenJti: true,
        },
      });

      expect(account?.refreshTokenHash).toBeNull();
      expect(account?.refreshTokenExpiresAt).toBeNull();
      expect(account?.refreshTokenJti).toBeNull();
    });

    it('should include JTI (JWT ID) in refresh tokens for tracking', async () => {
      const account = await prisma.account.findUnique({
        where: { id: testAccountId },
        select: { refreshTokenJti: true },
      });

      expect(account?.refreshTokenJti).toBeDefined();
      expect(account?.refreshTokenJti).toMatch(/^[a-f0-9]{32}$/); // 16 bytes hex = 32 chars
    });
  });

  describe('Security Best Practices', () => {
    it('should not return password hash in sign-in response', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: testUserPhone,
          password: 'TestPassword123!',
        })
        .expect(201);

      expect(response.body.data.account.passwordHash).toBeUndefined();
    });

    it('should not return refresh token hash in sign-in response', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: testUserPhone,
          password: 'TestPassword123!',
        })
        .expect(201);

      expect(response.body.data.account.refreshTokenHash).toBeUndefined();
      expect(response.body.data.account.refreshTokenExpiresAt).toBeUndefined();
      expect(response.body.data.account.refreshTokenJti).toBeUndefined();
    });

    it('should reject inactive accounts', async () => {
      // Create inactive account
      const inactiveAccount = await prisma.account.create({
        data: {
          name: 'Inactive User',
          phone: inactiveUserPhone,
          email: inactiveUserEmail,
          passwordHash: await bcrypt.hash('Password123!', 10),
          gender: 'MALE',
          maritalStatus: 'SINGLE',
          dob: new Date('1990-01-01'),
          claimed: true,
          isActive: false,
        },
      });

      const response = await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: inactiveUserPhone,
          password: 'Password123!',
        })
        .expect(403);

      expect(response.body.message).toBe('Account is inactive');

      // Cleanup
      await prisma.account.delete({ where: { id: inactiveAccount.id } });
    });

    it('should reject unclaimed accounts without password', async () => {
      // Create unclaimed account
      const unclaimedAccount = await prisma.account.create({
        data: {
          name: 'Unclaimed User',
          phone: unclaimedUserPhone,
          email: unclaimedUserEmail,
          gender: 'MALE',
          maritalStatus: 'SINGLE',
          dob: new Date('1990-01-01'),
          claimed: false,
          isActive: true,
        },
      });

      await request(app.getHttpServer())
        .post('/auth/sign-in')
        .send({
          identifier: unclaimedUserPhone,
          password: 'AnyPassword',
        })
        .expect(401);

      // Cleanup
      await prisma.account.delete({ where: { id: unclaimedAccount.id } });
    });
  });
});
