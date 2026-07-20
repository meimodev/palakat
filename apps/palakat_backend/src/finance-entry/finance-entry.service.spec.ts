/**
 * Characterization tests for FinanceEntryService.
 *
 * This service collapses the former byte-identical RevenueService and
 * ExpenseService into one module keyed by FinancialType. These tests lock the
 * four axes that differ between the two kinds — ledger direction, cash-mutation
 * reference type, financial type used for approver resolution, and the Prisma
 * model / approver table — plus the shared include carrying `cashAccount`.
 */

import { Test, TestingModule } from '@nestjs/testing';
import { FinanceEntryService } from './finance-entry.service';
import { PrismaService } from '../prisma.service';
import { RealtimeEmitterService } from '../realtime/realtime-emitter.service';
import { CashMutationService } from '../cash/cash-mutation.service';
import { ApproverResolverService } from '../activity/approver-resolver.service';
import {
  CashMutationReferenceType,
  CashMutationType,
  FinancialType,
  PaymentMethod,
} from '../generated/prisma/client';
import { financeEntryInclude } from './finance-entry.include';

describe('FinanceEntryService', () => {
  let service: FinanceEntryService;
  let mockTx: any;

  const mockPrisma: any = {
    financialAccountNumber: { findUnique: jest.fn() },
    approvalRule: { findMany: jest.fn() },
    membership: { findMany: jest.fn() },
    revenue: { findUniqueOrThrow: jest.fn() },
    expense: { findUniqueOrThrow: jest.fn() },
    $transaction: jest.fn(),
  };

  const mockRealtime = {
    emitFinanceEvent: jest.fn(),
    emitApprovalLifecycleEvent: jest.fn(),
  };

  const mockCashMutation = {
    syncMutationForReference: jest.fn(),
    deleteMutationForReference: jest.fn(),
    assertAccountOwnedByChurch: jest.fn(),
  };

  const mockApproverResolver = {
    resolveFinanceApprovers: jest
      .fn()
      .mockResolvedValue({ membershipIds: [], matchedRuleIds: [] }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FinanceEntryService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: RealtimeEmitterService, useValue: mockRealtime },
        { provide: CashMutationService, useValue: mockCashMutation },
        { provide: ApproverResolverService, useValue: mockApproverResolver },
      ],
    }).compile();

    service = module.get<FinanceEntryService>(FinanceEntryService);
    jest.clearAllMocks();

    // Fresh transaction client per test — one delegate object per Prisma model.
    const makeModel = (finalRecord: any) => ({
      create: jest.fn().mockResolvedValue({
        id: 10,
        amount: 1000,
        churchId: 1,
        createdAt: new Date('2026-01-01T00:00:00Z'),
      }),
      update: jest.fn().mockResolvedValue({
        id: 10,
        amount: 1000,
        churchId: 1,
        updatedAt: new Date('2026-01-02T00:00:00Z'),
      }),
      findUnique: jest.fn().mockResolvedValue({ activityId: null }),
      findUniqueOrThrow: jest.fn().mockResolvedValue(finalRecord),
      delete: jest.fn().mockResolvedValue({ id: 10, churchId: 1 }),
    });

    const finalRecord = {
      id: 10,
      churchId: 1,
      approvers: [],
      updatedAt: new Date('2026-01-02T00:00:00Z'),
    };

    mockTx = {
      cashAccount: { findFirst: jest.fn().mockResolvedValue({ id: 7 }) },
      activity: { findUnique: jest.fn().mockResolvedValue(null) },
      revenue: makeModel(finalRecord),
      expense: makeModel(finalRecord),
      revenueApprover: {
        deleteMany: jest.fn(),
        createMany: jest.fn(),
      },
      expenseApprover: {
        deleteMany: jest.fn(),
        createMany: jest.fn(),
      },
    };

    // For update path, current-record lookup on the real prisma delegate.
    mockPrisma.revenue.findUniqueOrThrow.mockResolvedValue({
      churchId: 1,
      financialAccountNumberId: 5,
      cashAccountId: 7,
      amount: 500,
    });
    mockPrisma.expense.findUniqueOrThrow.mockResolvedValue({
      churchId: 1,
      financialAccountNumberId: 5,
      cashAccountId: 7,
      amount: 500,
    });

    mockPrisma.financialAccountNumber.findUnique.mockResolvedValue({
      id: 5,
      accountNumber: 'ACC-1',
    });
    // No approvers resolved by default.
    mockApproverResolver.resolveFinanceApprovers.mockResolvedValue({
      membershipIds: [],
      matchedRuleIds: [],
    });

    mockPrisma.$transaction.mockImplementation(async (arg: any) => {
      if (typeof arg === 'function') return arg(mockTx);
      return Promise.all(arg);
    });
  });

  const baseCreateDto = {
    amount: 1000,
    churchId: 1,
    paymentMethod: PaymentMethod.CASH,
    financialAccountNumberId: 5,
    cashAccountId: 7,
  } as any;

  describe('create — ledger direction & model wiring per kind', () => {
    it('REVENUE: writes to revenue model, IN mutation, REVENUE reference', async () => {
      await service.create(FinancialType.REVENUE, baseCreateDto);

      expect(mockTx.revenue.create).toHaveBeenCalled();
      expect(mockTx.expense.create).not.toHaveBeenCalled();

      expect(mockCashMutation.syncMutationForReference).toHaveBeenCalledWith(
        mockTx,
        expect.objectContaining({
          type: CashMutationType.IN,
          referenceType: CashMutationReferenceType.REVENUE,
        }),
      );
    });

    it('EXPENSE: writes to expense model, OUT mutation, EXPENSE reference', async () => {
      await service.create(FinancialType.EXPENSE, baseCreateDto);

      expect(mockTx.expense.create).toHaveBeenCalled();
      expect(mockTx.revenue.create).not.toHaveBeenCalled();

      expect(mockCashMutation.syncMutationForReference).toHaveBeenCalledWith(
        mockTx,
        expect.objectContaining({
          type: CashMutationType.OUT,
          referenceType: CashMutationReferenceType.EXPENSE,
        }),
      );
    });

    it('resolves approvers through the resolver seam by financialType', async () => {
      await service.create(FinancialType.REVENUE, baseCreateDto);
      expect(
        mockApproverResolver.resolveFinanceApprovers,
      ).toHaveBeenCalledWith(1, FinancialType.REVENUE);

      mockApproverResolver.resolveFinanceApprovers.mockClear();
      await service.create(FinancialType.EXPENSE, baseCreateDto);
      expect(
        mockApproverResolver.resolveFinanceApprovers,
      ).toHaveBeenCalledWith(1, FinancialType.EXPENSE);
    });

    it('reads back through the shared include (carries cashAccount)', async () => {
      await service.create(FinancialType.REVENUE, baseCreateDto);
      expect(mockTx.revenue.findUniqueOrThrow).toHaveBeenCalledWith(
        expect.objectContaining({ include: financeEntryInclude }),
      );
      expect((financeEntryInclude as any).cashAccount).toBe(true);
    });

    it('returns the kind-specific success message', async () => {
      const res = await service.create(FinancialType.REVENUE, baseCreateDto);
      expect(res.message).toBe('Revenue created successfully');
      const res2 = await service.create(FinancialType.EXPENSE, baseCreateDto);
      expect(res2.message).toBe('Expense created successfully');
    });

    it('delegates cash-account ownership to CashMutationService', async () => {
      await service.create(FinancialType.REVENUE, baseCreateDto);
      expect(mockCashMutation.assertAccountOwnedByChurch).toHaveBeenCalledWith(
        expect.objectContaining({ churchId: 1, accountId: 7, client: mockTx }),
      );
    });
  });

  describe('update — ledger direction per kind', () => {
    it('REVENUE update keeps IN / REVENUE', async () => {
      await service.update(FinancialType.REVENUE, 10, { amount: 2000 } as any);
      expect(mockTx.revenue.update).toHaveBeenCalled();
      expect(mockCashMutation.syncMutationForReference).toHaveBeenCalledWith(
        mockTx,
        expect.objectContaining({
          type: CashMutationType.IN,
          referenceType: CashMutationReferenceType.REVENUE,
        }),
      );
    });

    it('EXPENSE update keeps OUT / EXPENSE', async () => {
      await service.update(FinancialType.EXPENSE, 10, { amount: 2000 } as any);
      expect(mockTx.expense.update).toHaveBeenCalled();
      expect(mockCashMutation.syncMutationForReference).toHaveBeenCalledWith(
        mockTx,
        expect.objectContaining({
          type: CashMutationType.OUT,
          referenceType: CashMutationReferenceType.EXPENSE,
        }),
      );
    });
  });
});
