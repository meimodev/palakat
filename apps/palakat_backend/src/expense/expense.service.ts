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
import { PrismaService } from '../prisma.service';
import { RealtimeEmitterService } from '../realtime/realtime-emitter.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { ExpenseListQueryDto } from './dto/expense-list.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';

@Injectable()
export class ExpenseService {
  constructor(
    private prisma: PrismaService,
    @Inject(forwardRef(() => RealtimeEmitterService))
    private realtime: RealtimeEmitterService,
    private cashMutationService: CashMutationService,
  ) {}

  private async assertCashAccountOwnedByChurch(
    tx: any,
    churchId: number,
    cashAccountId: number,
  ) {
    const exists = await tx.cashAccount.findFirst({
      where: { id: cashAccountId, churchId },
      select: { id: true },
    });
    if (!exists) {
      throw new BadRequestException(
        `Cash account ${cashAccountId} not found for church ${churchId}`,
      );
    }
  }

  private emitExpenseFinanceEvent(
    eventName: 'finance.created' | 'finance.updated' | 'finance.deleted',
    expense: any,
    updatedAt?: Date,
  ) {
    if (
      typeof expense?.id !== 'number' ||
      typeof expense?.churchId !== 'number'
    ) {
      return;
    }

    this.realtime.emitFinanceEvent({
      eventName,
      financeId: expense.id,
      financeType: 'EXPENSE',
      churchId: expense.churchId,
      activityId: expense.activityId ?? expense.activity?.id ?? null,
      affectedMembershipIds: (expense.approvers ?? []).map(
        (approver: any) => approver.membershipId,
      ),
      updatedAt: updatedAt ?? expense.updatedAt,
    });
  }

  private buildExpenseInclude() {
    return {
      approvers: {
        include: {
          membership: {
            include: {
              account: {
                select: {
                  id: true,
                  name: true,
                  phone: true,
                  dob: true,
                },
              },
              membershipPositions: true,
            },
          },
        },
      },
      activity: {
        include: {
          approvers: {
            include: {
              membership: {
                include: {
                  account: {
                    select: {
                      id: true,
                      name: true,
                      phone: true,
                      dob: true,
                    },
                  },
                  membershipPositions: true,
                },
              },
            },
          },
          supervisor: {
            include: {
              account: {
                select: {
                  id: true,
                  name: true,
                  phone: true,
                  dob: true,
                },
              },
              membershipPositions: true,
            },
          },
          location: true,
        },
      },
      financialAccountNumber: true,
      cashAccount: true,
    };
  }

  private async resolveFinanceApproverMembershipIds(
    churchId: number,
  ): Promise<number[]> {
    const rules = await (this.prisma as any).approvalRule.findMany({
      where: {
        churchId,
        financialType: FinancialType.EXPENSE,
        active: true,
      },
      include: {
        positions: { select: { id: true } },
      },
    });

    const positionIds = new Set<number>();
    for (const rule of rules) {
      for (const position of rule.positions) {
        positionIds.add(position.id);
      }
    }

    if (positionIds.size === 0) return [];

    const memberships = await (this.prisma as any).membership.findMany({
      where: {
        churchId,
        membershipPositions: { some: { id: { in: Array.from(positionIds) } } },
      },
      select: { id: true },
    });

    return memberships.map((m: { id: number }) => m.id);
  }

  private async syncApprovers(
    tx: any,
    expenseId: number,
    churchId: number,
  ): Promise<number[]> {
    await tx.expenseApprover.deleteMany({ where: { expenseId } });

    const membershipIds =
      await this.resolveFinanceApproverMembershipIds(churchId);

    if (membershipIds.length === 0) return [];

    await tx.expenseApprover.createMany({
      data: membershipIds.map((membershipId: number) => ({
        expenseId,
        membershipId,
      })),
    });

    return membershipIds;
  }

  private emitExpenseApprovalRequiredEvent(
    expense: any,
    membershipIds?: number[],
  ) {
    const affectedMembershipIds =
      membershipIds ??
      (expense?.approvers ?? []).map((approver: any) => approver.membershipId);

    if (
      typeof expense?.id !== 'number' ||
      typeof expense?.churchId !== 'number' ||
      !Array.isArray(affectedMembershipIds) ||
      affectedMembershipIds.length === 0
    ) {
      return;
    }

    this.realtime.emitApprovalLifecycleEvent({
      eventName: 'approval.required',
      entityType: 'EXPENSE',
      entityId: expense.id,
      entityTitle: expense.activity?.title ?? 'Expense approval',
      churchId: expense.churchId,
      resultingStatus: 'UNCONFIRMED',
      isOverride: false,
      affectedMembershipIds,
      updatedAt: expense.updatedAt,
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

  async findAll(query: ExpenseListQueryDto) {
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

    const include = this.buildExpenseInclude();
    const [total, expenses] = await (this.prisma as any).$transaction([
      (this.prisma as any).expense.count({ where }),
      (this.prisma as any).expense.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include,
      }),
    ]);

    let searchInfo = '';
    if (search && expenses.length > 0) {
      const matchedFields = new Set<string>();
      expenses.forEach((expense: any) => {
        if (
          expense.accountNumber?.toLowerCase().includes(search.toLowerCase())
        ) {
          matchedFields.add('accountNumber');
        }
        if (
          expense.activity?.title?.toLowerCase().includes(search.toLowerCase())
        ) {
          matchedFields.add('activity.title');
        }
      });
      if (matchedFields.size > 0) {
        searchInfo = ` (matched in: ${Array.from(matchedFields).join(', ')})`;
      }
    }

    return {
      message: `Expenses retrieved successfully${searchInfo}`,
      data: expenses,
      total,
    };
  }

  async findOne(id: number) {
    const expense = await (this.prisma as any).expense.findUniqueOrThrow({
      where: { id },
      include: this.buildExpenseInclude(),
    });
    return {
      message: 'Expense retrieved successfully',
      data: expense,
    };
  }

  async remove(id: number) {
    const expense = await (this.prisma as any).$transaction(async (tx: any) => {
      const deleted = await tx.expense.delete({
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
        referenceType: CashMutationReferenceType.EXPENSE,
        referenceId: deleted.id,
      });

      return deleted;
    });

    this.emitExpenseFinanceEvent('finance.deleted', expense, new Date());

    return {
      message: 'Expense deleted successfully',
    };
  }

  async create(
    createExpenseDto: CreateExpenseDto,
  ): Promise<{ message: string; data: any }> {
    const {
      financialAccountNumberId,
      accountNumber,
      activityId,
      cashAccountId,
      ...rest
    } = createExpenseDto;

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

    const include = this.buildExpenseInclude();
    const expense = await (this.prisma as any).$transaction(async (tx: any) => {
      await this.assertCashAccountOwnedByChurch(
        tx,
        rest.churchId,
        cashAccountId,
      );

      const createdExpense = await tx.expense.create({ data });
      await this.syncApprovers(tx, createdExpense.id, rest.churchId);

      const activityTitle = activityId
        ? await tx.activity.findUnique({
            where: { id: activityId },
            select: { title: true, date: true },
          })
        : null;

      await this.cashMutationService.syncMutationForReference(tx, {
        churchId: rest.churchId,
        referenceType: CashMutationReferenceType.EXPENSE,
        referenceId: createdExpense.id,
        type: CashMutationType.OUT,
        amount: createdExpense.amount,
        cashAccountId,
        happenedAt:
          activityTitle?.date ?? createdExpense.createdAt ?? new Date(),
        note: activityTitle?.title ?? null,
      });

      return tx.expense.findUniqueOrThrow({
        where: { id: createdExpense.id },
        include,
      });
    });

    this.emitExpenseFinanceEvent('finance.created', expense);
    this.emitExpenseApprovalRequiredEvent(expense);

    return {
      message: 'Expense created successfully',
      data: expense,
    };
  }

  async update(
    id: number,
    updateExpenseDto: UpdateExpenseDto,
  ): Promise<{ message: string; data: any }> {
    const {
      financialAccountNumberId,
      accountNumber,
      activityId,
      cashAccountId,
      ...rest
    } = updateExpenseDto;

    const currentExpense = await (this.prisma as any).expense.findUniqueOrThrow(
      {
        where: { id },
        select: {
          churchId: true,
          financialAccountNumberId: true,
          cashAccountId: true,
          amount: true,
        },
      },
    );

    const effectiveChurchId = rest.churchId ?? currentExpense.churchId;
    const effectiveCashAccountId =
      cashAccountId ?? currentExpense.cashAccountId;
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

    const include = this.buildExpenseInclude();
    let refreshedApproverMembershipIds: number[] = [];
    const expense = await (this.prisma as any).$transaction(async (tx: any) => {
      if (
        cashAccountId !== undefined ||
        (rest.churchId !== undefined &&
          rest.churchId !== currentExpense.churchId)
      ) {
        await this.assertCashAccountOwnedByChurch(
          tx,
          effectiveChurchId,
          effectiveCashAccountId,
        );
      }

      const updatedExpense = await tx.expense.update({
        where: { id },
        data,
      });

      if (shouldRefreshApprovers) {
        refreshedApproverMembershipIds = await this.syncApprovers(
          tx,
          id,
          effectiveChurchId,
        );
      }

      const effectiveActivityId =
        activityId !== undefined
          ? activityId
          : ((
              await tx.expense.findUnique({
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
        referenceType: CashMutationReferenceType.EXPENSE,
        referenceId: id,
        type: CashMutationType.OUT,
        amount: updatedExpense.amount,
        cashAccountId: effectiveCashAccountId,
        happenedAt:
          activityInfo?.date ?? updatedExpense.updatedAt ?? new Date(),
        note: activityInfo?.title ?? null,
      });

      return tx.expense.findUniqueOrThrow({
        where: { id: updatedExpense.id },
        include,
      });
    });

    this.emitExpenseFinanceEvent('finance.updated', expense);
    if (refreshedApproverMembershipIds.length > 0) {
      this.emitExpenseApprovalRequiredEvent(
        expense,
        refreshedApproverMembershipIds,
      );
    }

    return {
      message: 'Expense updated successfully',
      data: expense,
    };
  }
}
