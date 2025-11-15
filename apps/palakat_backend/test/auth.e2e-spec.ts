import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaClient, Gender, MaritalStatus } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

describe('Auth (e2e)', () => {
  let app: INestApplication;
  const prisma = new PrismaClient();

  const password = 'Password123!';
  let passwordHash: string;

  beforeAll(async () => {
    process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-secret';
    passwordHash = await bcrypt.hash(password, 12);

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, transform: true }),
    );
    await app.init();

    // Prepare test users
    await prisma.account.upsert({
      where: { phone: '081200000001' },
      update: {
        passwordHash,
        email: 'e2e_user1@example.com',
        isActive: true,
      } as any,
      create: {
        name: 'E2E User One',
        phone: '081200000001',
        email: 'e2e_user1@example.com',
        passwordHash,
        gender: Gender.MALE,
        maritalStatus: MaritalStatus.SINGLE,
        dob: new Date('1990-01-01'),
        isActive: true,
      } as any,
    });

    await prisma.account.upsert({
      where: { phone: '081200000002' },
      update: {
        passwordHash,
        email: 'e2e_user2@example.com',
        isActive: true,
      } as any,
      create: {
        name: 'E2E User Two',
        phone: '081200000002',
        email: 'e2e_user2@example.com',
        passwordHash,
        gender: Gender.FEMALE,
        maritalStatus: MaritalStatus.MARRIED,
        dob: new Date('1992-02-02'),
        isActive: true,
      } as any,
    });
  });

  afterAll(async () => {
    await app.close();
    await prisma.$disconnect();
  });

  it('POST /auth/sign-in with email identifier succeeds', async () => {
    const res = await request(app.getHttpServer())
      .post('/auth/sign-in')
      .send({ identifier: 'e2e_user1@example.com', password })
      .expect(201);

    expect(res.body?.data?.accessToken).toBeDefined();
    expect(res.body?.data?.account?.email).toBe('e2e_user1@example.com');
  });

  it('POST /auth/sign-in with phone identifier succeeds', async () => {
    const res = await request(app.getHttpServer())
      .post('/auth/sign-in')
      .send({ identifier: '081200000002', password })
      .expect(201);

    expect(res.body?.data?.accessToken).toBeDefined();
    expect(res.body?.data?.account?.phone).toBe('081200000002');
  });

  it('POST /auth/sign-in wrong password fails', async () => {
    await request(app.getHttpServer())
      .post('/auth/sign-in')
      .send({ identifier: 'e2e_user1@example.com', password: 'WrongPass!' })
      .expect(401);
  });

  it('POST /auth/refresh issues new tokens and rotates refresh token', async () => {
    const signin = await request(app.getHttpServer())
      .post('/auth/sign-in')
      .send({ identifier: 'e2e_user1@example.com', password })
      .expect(201);

    const oldRefresh = signin.body?.data?.refreshToken as string;
    expect(oldRefresh).toBeDefined();

    const refreshRes = await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken: oldRefresh })
      .expect(201);

    const newRefresh = refreshRes.body?.data?.refreshToken as string;
    expect(newRefresh).toBeDefined();
    expect(newRefresh).not.toBe(oldRefresh);

    // Optional: server may allow previous token until rotation persist is confirmed.
  });

  it('POST /auth/sign-out revokes refresh token and subsequent refresh fails', async () => {
    const signin = await request(app.getHttpServer())
      .post('/auth/sign-in')
      .send({ identifier: 'e2e_user1@example.com', password })
      .expect(201);

    const accessToken = signin.body?.data?.accessToken as string;
    const refreshToken = signin.body?.data?.refreshToken as string;

    await request(app.getHttpServer())
      .post('/auth/sign-out')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(201);

    await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken })
      .expect(401);
  });
});
