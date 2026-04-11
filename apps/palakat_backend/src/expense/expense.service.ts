import {
  BadRequestException,
  Injectable,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { FinancialType } from '../generated/prisma/client';
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
  ) {}

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
    };
  }

  private async resolveFinanceApproverMembershipIds(
    churchId: number,
    financialAccountNumberId?: number | null,
  ): Promise<number[]> {
    const positionIds = new Set<number>();

    if (typeof financialAccountNumberId === 'number') {
      const accountRules = await (this.prisma as any).approvalRule.findMany({
        where: {
          churchId,
          financialAccountNumberId,
          active: true,
        },
        include: {
          positions: {
            select: {
              id: true,
            },
          },
        },
      });

      for (const rule of accountRules) {
        for (const position of rule.positions) {
          positionIds.add(position.id);
        }
      }
    }

    const financialTypeRules = await (this.prisma as any).approvalRule.findMany(
      {
        where: {
          churchId,
          financialType: FinancialType.EXPENSE,
          financialAccountNumberId: null,
          active: true,
        },
        include: {
          positions: {
            select: {
              id: true,
            },
          },
        },
      },
    );

    for (const rule of financialTypeRules) {
      for (const position of rule.positions) {
        positionIds.add(position.id);
      }
    }

    if (positionIds.size === 0) {
      return [];
    }

    const memberships = await (this.prisma as any).membership.findMany({
      where: {
        churchId,
        membershipPositions: {
          some: {
            id: {
              in: Array.from(positionIds),
            },
          },
        },
      },
      select: {
        id: true,
      },
    });

    return memberships.map((membership: { id: number }) => membership.id);
  }

  private async syncApprovers(
    tx: any,
    expenseId: number,
    churchId: number,
    financialAccountNumberId?: number | null,
  ): Promise<void> {
    await tx.expenseApprover.deleteMany({
      where: { expenseId },
    });

    const membershipIds = await this.resolveFinanceApproverMembershipIds(
      churchId,
      financialAccountNumberId,
    );

    if (membershipIds.length === 0) {
      return;
    }

    await tx.expenseApprover.createMany({
      data: membershipIds.map((membershipId: number) => ({
        expenseId,
        membershipId,
      })),
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
    const expense = await (this.prisma as any).expense.delete({
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

    this.emitExpenseFinanceEvent('finance.deleted', expense, new Date());

    return {
      message: 'Expense deleted successfully',
    };
  }

  async create(
    createExpenseDto: CreateExpenseDto,
  ): Promise<{ message: string; data: any }> {
    const { financialAccountNumberId, accountNumber, activityId, ...rest } =
      createExpenseDto;

    const resolvedFinancialAccount = await this.resolveFinancialAccount(
      rest.churchId,
      financialAccountNumberId,
      accountNumber,
    );

    const data: any = {
      ...rest,
      activityId,
      accountNumber: resolvedFinancialAccount.accountNumber,
    };

    if (resolvedFinancialAccount.financialAccountNumberId != null) {
      data.financialAccountNumberId =
        resolvedFinancialAccount.financialAccountNumberId;
    }

    const include = this.buildExpenseInclude();
    const expense = await (this.prisma as any).$transaction(async (tx: any) => {
      const createdExpense = await tx.expense.create({ data });
      await this.syncApprovers(
        tx,
        createdExpense.id,
        rest.churchId,
        resolvedFinancialAccount.financialAccountNumberId,
      );
      return tx.expense.findUniqueOrThrow({
        where: { id: createdExpense.id },
        include,
      });
    });

    this.emitExpenseFinanceEvent('finance.created', expense);

    return {
      message: 'Expense created successfully',
      data: expense,
    };
  }

  async update(
    id: number,
    updateExpenseDto: UpdateExpenseDto,
  ): Promise<{ message: string; data: any }> {
    const { financialAccountNumberId, accountNumber, activityId, ...rest } =
      updateExpenseDto;

    const currentExpense = await (this.prisma as any).expense.findUniqueOrThrow(
      {
        where: { id },
        select: {
          churchId: true,
          financialAccountNumberId: true,
        },
      },
    );

    const effectiveChurchId = rest.churchId ?? currentExpense.churchId;
    const data: any = { ...rest, activityId };

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
    const expense = await (this.prisma as any).$transaction(async (tx: any) => {
      const updatedExpense = await tx.expense.update({
        where: { id },
        data,
      });

      if (shouldRefreshApprovers) {
        const nextFinancialAccountNumberId =
          Object.prototype.hasOwnProperty.call(data, 'financialAccountNumberId')
            ? data.financialAccountNumberId
            : currentExpense.financialAccountNumberId;
        await this.syncApprovers(
          tx,
          id,
          effectiveChurchId,
          nextFinancialAccountNumberId,
        );
      }

      return tx.expense.findUniqueOrThrow({
        where: { id: updatedExpense.id },
        include,
      });
    });

    this.emitExpenseFinanceEvent('finance.updated', expense);

    return {
      message: 'Expense updated successfully',
      data: expense,
    };
  }
}
