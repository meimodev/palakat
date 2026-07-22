import { Test, TestingModule } from '@nestjs/testing';
import { ConflictException, ForbiddenException } from '@nestjs/common';
import { MembershipService } from './membership.service';
import { PrismaService } from '../prisma.service';

/**
 * Phase 1.5e. A membership is the link between an account and a church, so
 * whoever names the `accountId` decides who gets enrolled. These tests pin that
 * the caller cannot name anyone but themselves.
 */
describe('MembershipService — self-scoping', () => {
  let service: MembershipService;

  const prisma = {
    membership: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    column: { findUnique: jest.fn() },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MembershipService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();
    service = module.get(MembershipService);
    jest.clearAllMocks();
  });

  describe('create', () => {
    it('takes accountId from the caller and discards the payload’s', async () => {
      // The member app's join screen sends {churchId, columnId, baptize, sidi}
      // and no accountId at all — a required column — so this both closes the
      // hole and repairs a flow that could not have worked.
      prisma.membership.findUnique.mockResolvedValue(null);
      prisma.column.findUnique.mockResolvedValue({ id: 5, churchId: 3 });
      prisma.membership.create.mockResolvedValue({ id: 1 });

      await service.create(
        { churchId: 3, columnId: 5, accountId: 999 },
        { userId: 7 },
      );

      expect(prisma.membership.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ accountId: 7 }),
        }),
      );
    });

    it.each([undefined, null, {}, { userId: undefined }])(
      'refuses a caller with no identity (%p)',
      async (caller) => {
        await expect(
          service.create({ churchId: 3 }, caller as any),
        ).rejects.toThrow(ForbiddenException);
        expect(prisma.membership.create).not.toHaveBeenCalled();
      },
    );

    it('refuses a second membership rather than surfacing a Prisma error', async () => {
      prisma.membership.findUnique.mockResolvedValue({ id: 42 });

      await expect(
        service.create({ churchId: 3 }, { userId: 7 }),
      ).rejects.toThrow(ConflictException);
      expect(prisma.membership.create).not.toHaveBeenCalled();
    });
  });

  describe('update', () => {
    it('refuses another account’s membership', async () => {
      prisma.membership.findUnique.mockResolvedValue({ accountId: 8 });

      await expect(
        service.update(1, { baptize: true }, { userId: 7 }),
      ).rejects.toThrow(ForbiddenException);
      expect(prisma.membership.update).not.toHaveBeenCalled();
    });

    it('strips accountId so a membership cannot be re-pointed', async () => {
      prisma.membership.findUnique.mockResolvedValue({ accountId: 7 });
      prisma.membership.update.mockResolvedValue({ id: 1 });

      await service.update(1, { accountId: 999, baptize: true }, { userId: 7 });

      const data = prisma.membership.update.mock.calls[0][0].data;
      expect(data).not.toHaveProperty('accountId');
      expect(data).toMatchObject({ baptize: true });
    });
  });
});
