/**
 * Unit tests for ApproverResolverService.resolveFinanceApprovers — the finance
 * (financialType) matching path added when revenue/expense approver resolution
 * moved behind this seam. Activity-side matching is covered by the property
 * specs under test/property.
 */

import { Test, TestingModule } from '@nestjs/testing';
import { ApproverResolverService } from './approver-resolver.service';
import { PrismaService } from '../prisma.service';
import { FinancialType } from '../generated/prisma/client';

describe('ApproverResolverService.resolveFinanceApprovers', () => {
  let service: ApproverResolverService;

  const mockPrisma: any = {
    approvalRule: { findMany: jest.fn() },
    membership: { findMany: jest.fn() },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ApproverResolverService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get(ApproverResolverService);
    jest.clearAllMocks();
  });

  it('queries active rules for the given financialType and church', async () => {
    mockPrisma.approvalRule.findMany.mockResolvedValue([]);
    mockPrisma.membership.findMany.mockResolvedValue([]);

    await service.resolveFinanceApprovers(42, FinancialType.EXPENSE);

    expect(mockPrisma.approvalRule.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { churchId: 42, financialType: FinancialType.EXPENSE, active: true },
      }),
    );
  });

  it('maps matched rule positions to membership ids', async () => {
    mockPrisma.approvalRule.findMany.mockResolvedValue([
      { id: 1, positions: [{ id: 10 }, { id: 11 }] },
      { id: 2, positions: [{ id: 11 }] },
    ]);
    mockPrisma.membership.findMany.mockResolvedValue([{ id: 100 }, { id: 101 }]);

    const result = await service.resolveFinanceApprovers(
      1,
      FinancialType.REVENUE,
    );

    // Deduped position ids feed the membership lookup.
    expect(mockPrisma.membership.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          churchId: 1,
          membershipPositions: { some: { id: { in: [10, 11] } } },
        }),
      }),
    );
    expect(result).toEqual({
      membershipIds: [100, 101],
      matchedRuleIds: [1, 2],
    });
  });

  it('returns no memberships when no rules match', async () => {
    mockPrisma.approvalRule.findMany.mockResolvedValue([]);

    const result = await service.resolveFinanceApprovers(
      1,
      FinancialType.REVENUE,
    );

    expect(mockPrisma.membership.findMany).not.toHaveBeenCalled();
    expect(result).toEqual({ membershipIds: [], matchedRuleIds: [] });
  });
});
