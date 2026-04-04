import { Test, TestingModule } from '@nestjs/testing';
import { ApprovalRuleService } from './approval-rule.service';
import { PrismaService } from '../prisma.service';

describe('ApprovalRuleService', () => {
  let service: ApprovalRuleService;

  const mockPrismaService = {
    approvalRule: {
      findFirst: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    financialAccountNumber: {
      findUnique: jest.fn(),
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

  it('update normalizes `positions` into Prisma `set` when `positionIds` is not provided', async () => {
    mockPrismaService.approvalRule.findUnique.mockResolvedValue({
      financialType: null,
      financialAccountNumberId: null,
    });

    mockPrismaService.approvalRule.update.mockResolvedValue({
      id: 1,
      church: { id: 1, name: 'Church' },
      positions: [],
      financialAccountNumber: null,
    });

    await service.update(1, {
      positions: [{ id: 10 }, { id: 11 }],
    } as any);

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

  it('update can clear positions when `positionIds` is an empty array', async () => {
    mockPrismaService.approvalRule.findUnique.mockResolvedValue({
      financialType: null,
      financialAccountNumberId: null,
    });

    mockPrismaService.approvalRule.update.mockResolvedValue({
      id: 1,
      church: { id: 1, name: 'Church' },
      positions: [],
      financialAccountNumber: null,
    });

    await service.update(1, {
      positionIds: [],
    } as any);

    expect(mockPrismaService.approvalRule.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 1 },
        data: expect.objectContaining({
          positions: {
            set: [],
          },
        }),
      }),
    );
  });

  it('update ignores hydrated read-only fields from client payloads', async () => {
    mockPrismaService.approvalRule.findFirst.mockResolvedValue(null);
    mockPrismaService.approvalRule.findUnique.mockResolvedValue({
      financialType: null,
      financialAccountNumberId: null,
    });
    mockPrismaService.financialAccountNumber.findUnique.mockResolvedValue({
      description: 'Biaya Operasional - Kategori biaya operasional gereja',
    });

    mockPrismaService.approvalRule.update.mockResolvedValue({
      id: 9,
      church: { id: 1, name: 'Church' },
      positions: [],
      financialAccountNumber: null,
    });

    await service.update(9, {
      id: 9,
      name: 'Biaya Operasional',
      description: 'Deskripsi',
      active: false,
      createdAt: '2026-04-03T09:17:48.309Z',
      updatedAt: '2026-04-03T09:17:48.309Z',
      churchId: 1,
      church: { id: 1, name: 'GMIM Pondok Indah Utama' },
      positions: [{ id: 12 }, { id: 13 }],
      financialType: 'EXPENSE',
      financialAccountNumberId: 13,
      financialAccountNumber: {
        id: 13,
        accountNumber: '2.1',
      },
    } as any);

    expect(mockPrismaService.approvalRule.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 9 },
        data: expect.not.objectContaining({
          id: 9,
          createdAt: '2026-04-03T09:17:48.309Z',
          updatedAt: '2026-04-03T09:17:48.309Z',
          church: { id: 1, name: 'GMIM Pondok Indah Utama' },
          financialAccountNumber: {
            id: 13,
            accountNumber: '2.1',
          },
        }),
      }),
    );

    expect(mockPrismaService.approvalRule.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          name: 'Biaya Operasional - Kategori biaya operasional gereja',
          description: 'Deskripsi',
          active: false,
          church: { connect: { id: 1 } },
          positions: {
            set: [{ id: 12 }, { id: 13 }],
          },
          financialType: 'EXPENSE',
          financialAccountNumber: {
            connect: { id: 13 },
          },
        }),
      }),
    );
  });
});
