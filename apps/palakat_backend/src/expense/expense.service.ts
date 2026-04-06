import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { ExpenseListQueryDto } from './dto/expense-list.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';

@Injectable()
export class ExpenseService {
  constructor(private prisma: PrismaService) {}

  /**
   * Resolves the persisted account number and optional linked financial account.
   * When only accountNumber is provided, this attempts to normalize it against
   * the church-scoped FinancialAccountNumber table so returned relations stay
   * populated server-side.
   */
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
      churchId: churchId,
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

    const [total, expenses] = await (this.prisma as any).$transaction([
      (this.prisma as any).expense.count({ where }),
      (this.prisma as any).expense.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: {
          activity: {
            include: {
              approvers: true,
              supervisor: true,
            },
          },
        },
      }),
    ]);

    // Track which fields matched the search
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
      include: {
        activity: {
          include: {
            approvers: true,
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
      },
    });
    return {
      message: 'Expense retrieved successfully',
      data: expense,
    };
  }

  async remove(id: number) {
    await (this.prisma as any).expense.delete({
      where: { id },
    });
    return {
      message: 'Expense deleted successfully',
    };
  }

  async create(
    createExpenseDto: CreateExpenseDto,
  ): Promise<{ message: string; data: any }> {
    const { financialAccountNumberId, accountNumber, activityId, ...rest } =
      createExpenseDto;

    // Validate: activity can only have revenue OR expense, not both
    if (activityId) {
      const existingRevenue = await (this.prisma as any).revenue.findUnique({
        where: { activityId },
      });
      if (existingRevenue) {
        throw new BadRequestException(
          'Activity already has a revenue. An activity can only have one revenue or one expense, not both.',
        );
      }
    }

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

    const expense = await (this.prisma as any).expense.create({
      data,
      include: {
        activity: {
          include: {
            approvers: true,
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
      },
    });

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

    // Validate: activity can only have revenue OR expense, not both
    if (activityId) {
      const existingRevenue = await (this.prisma as any).revenue.findUnique({
        where: { activityId },
      });
      if (existingRevenue) {
        throw new BadRequestException(
          'Activity already has a revenue. An activity can only have one revenue or one expense, not both.',
        );
      }
    }

    const currentExpense = await (this.prisma as any).expense.findUniqueOrThrow(
      {
        where: { id },
        select: { churchId: true },
      },
    );

    const effectiveChurchId = rest.churchId ?? currentExpense.churchId;
    const data: any = { ...rest, activityId };

    // If financialAccountNumberId is provided, resolve and update the account number
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

    const expense = await (this.prisma as any).expense.update({
      where: { id },
      data,
      include: {
        activity: {
          include: {
            approvers: true,
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
      },
    });

    return {
      message: 'Expense updated successfully',
      data: expense,
    };
  }
}
