import { Test, TestingModule } from '@nestjs/testing';
import { ApprovalRuleService } from './approval-rule.service';
import { PrismaService } from '../prisma.service';

describe('ApprovalRuleService', () => {
  let service: ApprovalRuleService;

  const mockPrismaService = {
    approvalRule: {
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
});
