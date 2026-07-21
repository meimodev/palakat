import {
  BadRequestException,
  Injectable,
  Inject,
  forwardRef,
} from '@nestjs/common';
import {
  CashMutationReferenceType,
  CashMutationType,
  FinancialType,
} from '../generated/prisma/client';
import { CashMutationService } from '../cash/cash-mutation.service';
import { ApproverResolverService } from '../activity/approver-resolver.service';
import { PrismaService } from '../prisma.service';
import { RealtimeEmitterService } from '../realtime/realtime-emitter.service';
import { CreateFinanceEntryDto } from './dto/create-finance-entry.dto';
import { FinanceEntryListQueryDto } from './dto/finance-entry-list.dto';
import { UpdateFinanceEntryDto } from './dto/update-finance-entry.dto';
import { financeEntryInclude } from './finance-entry.include';

// Everything that varies between a revenue and an expense. Revenue and expense
// were previously two byte-identical services; the only differences are the
// values below, all derivable from the FinancialType kind.
interface KindConfig {
  noun: string; // singular, user-facing message noun
  nounPlural: string;
  model: string; // Prisma delegate: 'revenue' | 'expense'
  approverModel: string; // 'revenueApprover' | 'expenseApprover'
  approverFk: string; // FK column on the approver join: 'revenueId' | 'expenseId'
  financeType: 'REVENUE' | 'EXPENSE'; // realtime event label
  financialType: FinancialType;
  referenceType: CashMutationReferenceType;
  mutationType: CashMutationType; // IN for revenue, OUT for expense
  approvalTitle: string;
}

/**
 * FinanceEntryService — the single deep module behind revenue and expense.
 * `kind` selects the four axes that differ (ledger direction, reference type,
 * financial type, and the Prisma model/approver table); all behaviour is shared.
 */
@Injectable()
export class FinanceEntryService {
  constructor(
    private prisma: PrismaService,
    @Inject(forwardRef(() => RealtimeEmitterService))
    private realtime: RealtimeEmitterService,
    private cashMutationService: CashMutationService,
    private approverResolver: ApproverResolverService,
  ) {}

  private kindConfig(kind: FinancialType): KindConfig {
    if (kind === FinancialType.REVENUE) {
      return {
        noun: 'Revenue',
        nounPlural: 'Revenues',
        model: 'revenue',
        approverModel: 'revenueApprover',
        approverFk: 'revenueId',
        financeType: 'REVENUE',
        financialType: FinancialType.REVENUE,
        referenceType: CashMutationReferenceType.REVENUE,
        mutationType: CashMutationType.IN,
        approvalTitle: 'Revenue approval',
      };
    }
    return {
      noun: 'Expense',
      nounPlural: 'Expenses',
      model: 'expense',
      approverModel: 'expenseApprover',
      approverFk: 'expenseId',
      financeType: 'EXPENSE',
      financialType: FinancialType.EXPENSE,
      referenceType: CashMutationReferenceType.EXPENSE,
      mutationType: CashMutationType.OUT,
      approvalTitle: 'Expense approval',
    };
  }

  // Ownership lookup lives in CashMutationService; the finance flow keeps its
  // own 400 contract (the cash flow uses 404 for the same lookup).
  private async assertCashAccountOwnedByChurch(
    tx: any,
    churchId: number,
    cashAccountId: number,
  ) {
    const owned = await this.cashMutationService.isAccountOwnedByChurch({
      churchId,
      accountId: cashAccountId,
      client: tx,
    });
    if (!owned) {
      throw new BadRequestException(
        `Cash account ${cashAccountId} not found for church ${churchId}`,
      );
    }
  }

  private emitFinanceEvent(
    cfg: KindConfig,
    eventName: 'finance.created' | 'finance.updated' | 'finance.deleted',
    entry: any,
    updatedAt?: Date,
  ) {
    if (typeof entry?.id !== 'number' || typeof entry?.churchId !== 'number') {
      return;
    }

    this.realtime.emitFinanceEvent({
      eventName,
      financeId: entry.id,
      financeType: cfg.financeType,
      churchId: entry.churchId,
      activityId: entry.activityId ?? entry.activity?.id ?? null,
      affectedMembershipIds: (entry.approvers ?? []).map(
        (approver: any) => approver.membershipId,
      ),
      updatedAt: updatedAt ?? entry.updatedAt,
    });
  }

  private async syncApprovers(
    cfg: KindConfig,
    tx: any,
    entryId: number,
    churchId: number,
  ): Promise<number[]> {
    await tx[cfg.approverModel].deleteMany({
      where: { [cfg.approverFk]: entryId },
    });

    const { membershipIds } = await this.approverResolver.resolveFinanceApprovers(
      churchId,
      cfg.financialType,
    );

    if (membershipIds.length === 0) return [];

    await tx[cfg.approverModel].createMany({
      data: membershipIds.map((membershipId: number) => ({
        [cfg.approverFk]: entryId,
        membershipId,
      })),
    });

    return membershipIds;
  }

  private emitApprovalRequiredEvent(
    cfg: KindConfig,
    entry: any,
    membershipIds?: number[],
  ) {
    const affectedMembershipIds =
      membershipIds ??
      (entry?.approvers ?? []).map((approver: any) => approver.membershipId);

    if (
      typeof entry?.id !== 'number' ||
      typeof entry?.churchId !== 'number' ||
      !Array.isArray(affectedMembershipIds) ||
      affectedMembershipIds.length === 0
    ) {
      return;
    }

    this.realtime.emitApprovalLifecycleEvent({
      eventName: 'approval.required',
      entityType: cfg.financeType,
      entityId: entry.id,
      entityTitle: entry.activity?.title ?? cfg.approvalTitle,
      churchId: entry.churchId,
      resultingStatus: 'UNCONFIRMED',
      isOverride: false,
      affectedMembershipIds,
      updatedAt: entry.updatedAt,
    });
  }

  private async resolveFinancialAccount(
    churchId: number,
    financialAccountNumberId?: number,
    accountNumber?: string,
  ): Promise<{
    accountNumber: string;
    financialAccountNumberId: number | null;
  }> {
    if (financialAccountNumberId) {
      const financialAccount = await (
        this.prisma as any
      ).financialAccountNumber.findUnique({
        where: { id: financialAccountNumberId },
      });

      if (!financialAccount) {
        throw new BadRequestException(
          `Financial account number with id ${financialAccountNumberId} not found`,
        );
      }

      return {
        accountNumber: financialAccount.accountNumber,
        financialAccountNumberId: financialAccount.id,
      };
    }

    const normalizedAccountNumber = accountNumber?.trim();

    if (!normalizedAccountNumber) {
      throw new BadRequestException(
        'Either accountNumber or financialAccountNumberId must be provided',
      );
    }

    const financialAccount = await (
      this.prisma as any
    ).financialAccountNumber.findUnique({
      where: {
        churchId_accountNumber: {
          churchId,
          accountNumber: normalizedAccountNumber,
        },
      },
      select: {
        id: true,
        accountNumber: true,
      },
    });

    return {
      accountNumber: financialAccount?.accountNumber ?? normalizedAccountNumber,
      financialAccountNumberId: financialAccount?.id ?? null,
    };
  }

  async findAll(kind: FinancialType, query: FinanceEntryListQueryDto) {
    const cfg = this.kindConfig(kind);
    const {
      churchId,
      search,
      paymentMethod,
      startDate,
      endDate,
      skip,
      take,
      sortBy = 'id',
      sortOrder = 'desc',
    } = query;

    const where: any = {
      churchId,
    };

    if (search) {
      where.OR = [
        { accountNumber: { contains: search, mode: 'insensitive' } },
        { activity: { title: { contains: search, mode: 'insensitive' } } },
      ];
    }

    if (paymentMethod) {
      where.paymentMethod = paymentMethod;
    }

    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) {
        where.createdAt.gte = startDate;
      }
      if (endDate) {
        where.createdAt.lte = endDate;
      }
    }

    const [total, entries] = await (this.prisma as any).$transaction([
      (this.prisma as any)[cfg.model].count({ where }),
      (this.prisma as any)[cfg.model].findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: financeEntryInclude,
      }),
    ]);

    let searchInfo = '';
    if (search && entries.length > 0) {
      const matchedFields = new Set<string>();
      entries.forEach((entry: any) => {
        if (entry.accountNumber?.toLowerCase().includes(search.toLowerCase())) {
          matchedFields.add('accountNumber');
        }
        if (
          entry.activity?.title?.toLowerCase().includes(search.toLowerCase())
        ) {
          matchedFields.add('activity.title');
        }
      });
      if (matchedFields.size > 0) {
        searchInfo = ` (matched in: ${Array.from(matchedFields).join(', ')})`;
      }
    }

    return {
      message: `${cfg.nounPlural} retrieved successfully${searchInfo}`,
      data: entries,
      total,
    };
  }

  async findOne(kind: FinancialType, id: number) {
    const cfg = this.kindConfig(kind);
    const entry = await (this.prisma as any)[cfg.model].findUniqueOrThrow({
      where: { id },
      include: financeEntryInclude,
    });
    return {
      message: `${cfg.noun} retrieved successfully`,
      data: entry,
    };
  }

  async remove(kind: FinancialType, id: number) {
    const cfg = this.kindConfig(kind);
    const entry = await (this.prisma as any).$transaction(async (tx: any) => {
      const deleted = await tx[cfg.model].delete({
        where: { id },
        include: {
          approvers: {
            select: {
              membershipId: true,
            },
          },
          activity: {
            select: {
              id: true,
            },
          },
        },
      });

      await this.cashMutationService.deleteMutationForReference(tx, {
        churchId: deleted.churchId,
        referenceType: cfg.referenceType,
        referenceId: deleted.id,
      });

      return deleted;
    });

    this.emitFinanceEvent(cfg, 'finance.deleted', entry, new Date());

    return {
      message: `${cfg.noun} deleted successfully`,
    };
  }

  async create(
    kind: FinancialType,
    createDto: CreateFinanceEntryDto,
  ): Promise<{ message: string; data: any }> {
    const cfg = this.kindConfig(kind);
    const {
      financialAccountNumberId,
      accountNumber,
      activityId,
      cashAccountId,
      ...rest
    } = createDto;

    const resolvedFinancialAccount = await this.resolveFinancialAccount(
      rest.churchId,
      financialAccountNumberId,
      accountNumber,
    );

    const data: any = {
      ...rest,
      activityId,
      cashAccountId,
      accountNumber: resolvedFinancialAccount.accountNumber,
    };

    if (resolvedFinancialAccount.financialAccountNumberId != null) {
      data.financialAccountNumberId =
        resolvedFinancialAccount.financialAccountNumberId;
    }

    const entry = await (this.prisma as any).$transaction(async (tx: any) => {
      await this.assertCashAccountOwnedByChurch(tx, rest.churchId, cashAccountId);

      const created = await tx[cfg.model].create({ data });
      await this.syncApprovers(cfg, tx, created.id, rest.churchId);

      const activityInfo = activityId
        ? await tx.activity.findUnique({
            where: { id: activityId },
            select: { title: true, date: true },
          })
        : null;

      await this.cashMutationService.syncMutationForReference(tx, {
        churchId: rest.churchId,
        referenceType: cfg.referenceType,
        referenceId: created.id,
        type: cfg.mutationType,
        amount: created.amount,
        cashAccountId,
        happenedAt: activityInfo?.date ?? created.createdAt ?? new Date(),
        note: activityInfo?.title ?? null,
      });

      return tx[cfg.model].findUniqueOrThrow({
        where: { id: created.id },
        include: financeEntryInclude,
      });
    });

    this.emitFinanceEvent(cfg, 'finance.created', entry);
    this.emitApprovalRequiredEvent(cfg, entry);

    return {
      message: `${cfg.noun} created successfully`,
      data: entry,
    };
  }

  async update(
    kind: FinancialType,
    id: number,
    updateDto: UpdateFinanceEntryDto,
  ): Promise<{ message: string; data: any }> {
    const cfg = this.kindConfig(kind);
    const {
      financialAccountNumberId,
      accountNumber,
      activityId,
      cashAccountId,
      ...rest
    } = updateDto;

    const current = await (this.prisma as any)[cfg.model].findUniqueOrThrow({
      where: { id },
      select: {
        churchId: true,
        financialAccountNumberId: true,
        cashAccountId: true,
        amount: true,
      },
    });

    const effectiveChurchId = rest.churchId ?? current.churchId;
    const effectiveCashAccountId = cashAccountId ?? current.cashAccountId;
    const data: any = { ...rest, activityId };
    if (cashAccountId !== undefined) {
      data.cashAccountId = cashAccountId;
    }

    if (financialAccountNumberId !== undefined) {
      if (financialAccountNumberId === null) {
        data.financialAccountNumberId = null;
        if (accountNumber !== undefined) {
          const normalizedAccountNumber = accountNumber.trim();
          if (!normalizedAccountNumber) {
            throw new BadRequestException(
              'Either accountNumber or financialAccountNumberId must be provided',
            );
          }
          data.accountNumber = normalizedAccountNumber;
        }
      } else {
        const resolvedFinancialAccount = await this.resolveFinancialAccount(
          effectiveChurchId,
          financialAccountNumberId,
          accountNumber,
        );
        data.accountNumber = resolvedFinancialAccount.accountNumber;
        data.financialAccountNumberId =
          resolvedFinancialAccount.financialAccountNumberId;
      }
    } else if (accountNumber !== undefined) {
      const resolvedFinancialAccount = await this.resolveFinancialAccount(
        effectiveChurchId,
        undefined,
        accountNumber,
      );
      data.accountNumber = resolvedFinancialAccount.accountNumber;
      data.financialAccountNumberId =
        resolvedFinancialAccount.financialAccountNumberId;
    }

    const shouldRefreshApprovers =
      Object.prototype.hasOwnProperty.call(data, 'financialAccountNumberId') ||
      Object.prototype.hasOwnProperty.call(data, 'accountNumber') ||
      rest.churchId !== undefined;

    let refreshedApproverMembershipIds: number[] = [];
    const entry = await (this.prisma as any).$transaction(async (tx: any) => {
      if (
        cashAccountId !== undefined ||
        (rest.churchId !== undefined && rest.churchId !== current.churchId)
      ) {
        await this.assertCashAccountOwnedByChurch(
          tx,
          effectiveChurchId,
          effectiveCashAccountId,
        );
      }

      const updated = await tx[cfg.model].update({
        where: { id },
        data,
      });

      if (shouldRefreshApprovers) {
        refreshedApproverMembershipIds = await this.syncApprovers(
          cfg,
          tx,
          id,
          effectiveChurchId,
        );
      }

      const effectiveActivityId =
        activityId !== undefined
          ? activityId
          : ((
              await tx[cfg.model].findUnique({
                where: { id },
                select: { activityId: true },
              })
            )?.activityId ?? null);

      const activityInfo = effectiveActivityId
        ? await tx.activity.findUnique({
            where: { id: effectiveActivityId },
            select: { title: true, date: true },
          })
        : null;

      await this.cashMutationService.syncMutationForReference(tx, {
        churchId: effectiveChurchId,
        referenceType: cfg.referenceType,
        referenceId: id,
        type: cfg.mutationType,
        amount: updated.amount,
        cashAccountId: effectiveCashAccountId,
        happenedAt: activityInfo?.date ?? updated.updatedAt ?? new Date(),
        note: activityInfo?.title ?? null,
      });

      return tx[cfg.model].findUniqueOrThrow({
        where: { id: updated.id },
        include: financeEntryInclude,
      });
    });

    this.emitFinanceEvent(cfg, 'finance.updated', entry);
    if (refreshedApproverMembershipIds.length > 0) {
      this.emitApprovalRequiredEvent(cfg, entry, refreshedApproverMembershipIds);
    }

    return {
      message: `${cfg.noun} updated successfully`,
      data: entry,
    };
  }
}
