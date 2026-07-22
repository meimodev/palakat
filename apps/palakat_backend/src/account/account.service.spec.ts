import { Test, TestingModule } from '@nestjs/testing';
import { ForbiddenException } from '@nestjs/common';
import { AccountService } from './account.service';
import { PrismaService } from '../prisma.service';

/**
 * Phase 1.5e. `account.update` is called by both apps — `apps/palakat` for the
 * signed-in user's own profile, `palakat_admin` for other members — so it is
 * the one action in the phase that needs a compound rule rather than a flat
 * one: your own row always, someone else's only within your church.
 */
describe('AccountService.update — own row, or same church', () => {
  let service: AccountService;

  const prisma = {
    membership: { findUnique: jest.fn() },
    account: { update: jest.fn(), findUniqueOrThrow: jest.fn() },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AccountService, { provide: PrismaService, useValue: prisma }],
    }).compile();
    service = module.get(AccountService);
    jest.clearAllMocks();
    prisma.account.update.mockResolvedValue({ id: 1 });
  });

  it('updates your own account without consulting any membership', async () => {
    // A member with no church yet must still be able to edit their profile.
    await service.update(7, { name: 'New' } as any, { userId: 7 });

    expect(prisma.membership.findUnique).not.toHaveBeenCalled();
    expect(prisma.account.update).toHaveBeenCalled();
  });

  it('allows another account in the same church', async () => {
    prisma.membership.findUnique
      .mockResolvedValueOnce({ churchId: 3 }) // requester
      .mockResolvedValueOnce({ churchId: 3 }); // target

    await service.update(8, { name: 'New' } as any, { userId: 7 });

    expect(prisma.account.update).toHaveBeenCalled();
  });

  it('refuses an account in another church', async () => {
    prisma.membership.findUnique
      .mockResolvedValueOnce({ churchId: 3 })
      .mockResolvedValueOnce({ churchId: 4 });

    await expect(
      service.update(8, { name: 'New' } as any, { userId: 7 }),
    ).rejects.toThrow(ForbiddenException);
    expect(prisma.account.update).not.toHaveBeenCalled();
  });

  it('refuses when the requester has no church — fails closed', async () => {
    prisma.membership.findUnique
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce(null);

    await expect(
      service.update(8, { name: 'New' } as any, { userId: 7 }),
    ).rejects.toThrow(ForbiddenException);
  });

  it.each([undefined, null, {}, { userId: undefined }])(
    'refuses a caller with no identity (%p)',
    async (caller) => {
      await expect(
        service.update(8, { name: 'New' } as any, caller as any),
      ).rejects.toThrow(ForbiddenException);
      expect(prisma.account.update).not.toHaveBeenCalled();
    },
  );
});
