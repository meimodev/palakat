import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { ApprovalRuleService } from './approval-rule.service';
import { PrismaService } from '../prisma.service';

describe('ApprovalRuleService', () => {
  let service: ApprovalRuleService;

  const mockPrismaService = {
    approvalRule: {
      findUniqueOrThrow: jest.fn(),
      update: jest.fn(),
    },
    membershipPosition: {
      findMany: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ApprovalRuleService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<ApprovalRuleService>(ApprovalRuleService);
    jest.clearAllMocks();
  });

  it('update uses positionIds to set positions via Prisma set', async () => {
    mockPrismaService.approvalRule.findUniqueOrThrow.mockResolvedValue({
      churchId: 1,
    });
    mockPrismaService.membershipPosition.findMany.mockResolvedValue([
      { id: 10, churchId: 1 },
      { id: 11, churchId: 1 },
    ]);
    mockPrismaService.approvalRule.update.mockResolvedValue({
      id: 1,
      church: { id: 1, name: 'Church' },
      positions: [{ id: 10 }, { id: 11 }],
    });

    await service.update(1, { positionIds: [10, 11] });

    expect(mockPrismaService.approvalRule.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 1 },
        data: expect.objectContaining({
          positions: {
            set: [{ id: 10 }, { id: 11 }],
          },
        }),
      }),
    );
  });

  it('update deduplicates positionIds before setting', async () => {
    mockPrismaService.approvalRule.findUniqueOrThrow.mockResolvedValue({
      churchId: 1,
    });
    mockPrismaService.membershipPosition.findMany.mockResolvedValue([
      { id: 10, churchId: 1 },
    ]);
    mockPrismaService.approvalRule.update.mockResolvedValue({
      id: 1,
      church: { id: 1, name: 'Church' },
      positions: [{ id: 10 }],
    });

    await service.update(1, { positionIds: [10, 10, 10] });

    expect(mockPrismaService.approvalRule.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          positions: {
            set: [{ id: 10 }],
          },
        }),
      }),
    );
  });

  it('update can clear positions when positionIds is an empty array', async () => {
    mockPrismaService.approvalRule.findUniqueOrThrow.mockResolvedValue({
      churchId: 1,
    });
    mockPrismaService.membershipPosition.findMany.mockResolvedValue([]);
    mockPrismaService.approvalRule.update.mockResolvedValue({
      id: 1,
      church: { id: 1, name: 'Church' },
      positions: [],
    });

    await service.update(1, { positionIds: [] });

    expect(mockPrismaService.approvalRule.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 1 },
        data: expect.objectContaining({
          positions: { set: [] },
        }),
      }),
    );
  });

  it('update omits positions clause when positionIds is not provided', async () => {
    mockPrismaService.approvalRule.update.mockResolvedValue({
      id: 1,
      church: { id: 1, name: 'Church' },
      positions: [],
    });

    await service.update(1, { name: 'New Name' });

    const callArg = mockPrismaService.approvalRule.update.mock.calls[0][0];
    expect(callArg.data).not.toHaveProperty('positions');
  });

  it('update rejects positionIds that belong to a different church', async () => {
    mockPrismaService.approvalRule.findUniqueOrThrow.mockResolvedValue({
      churchId: 1,
    });
    mockPrismaService.membershipPosition.findMany.mockResolvedValue([
      { id: 10, churchId: 1 },
      { id: 99, churchId: 2 }, // wrong church
    ]);

    await expect(service.update(1, { positionIds: [10, 99] })).rejects.toThrow(
      BadRequestException,
    );

    expect(mockPrismaService.approvalRule.update).not.toHaveBeenCalled();
  });

  it('update ignores hydrated read-only fields — no id/createdAt/updatedAt in data', async () => {
    mockPrismaService.approvalRule.findUniqueOrThrow.mockResolvedValue({
      churchId: 1,
    });
    mockPrismaService.membershipPosition.findMany.mockResolvedValue([
      { id: 12, churchId: 1 },
      { id: 13, churchId: 1 },
    ]);
    mockPrismaService.approvalRule.update.mockResolvedValue({
      id: 9,
      church: { id: 1, name: 'Church' },
      positions: [],
    });

    await service.update(9, {
      name: 'Biaya Operasional',
      description: 'Deskripsi',
      active: false,
      churchId: 1,
      positionIds: [12, 13],
      financialType: 'EXPENSE' as any,
    });

    const callArg = mockPrismaService.approvalRule.update.mock.calls[0][0];
    expect(callArg.data).not.toHaveProperty('id');
    expect(callArg.data).not.toHaveProperty('createdAt');
    expect(callArg.data).not.toHaveProperty('updatedAt');
    expect(callArg.data).not.toHaveProperty('church.id');
    expect(callArg.data.positions).toEqual({
      set: [{ id: 12 }, { id: 13 }],
    });
  });
});
