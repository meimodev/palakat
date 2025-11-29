import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { ExpenseListQueryDto } from './dto/expense-list.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';

@Injectable()
export class ExpenseService {
  constructor(private prisma: PrismaService) {}

  /**
   * Resolves the accountNumber string from a FinancialAccountNumber if provided.
   * If financialAccountNumberId is provided, fetches the account number from the linked record.
   * Otherwise, uses the provided accountNumber string.
   */
  private async resolveAccountNumber(
    financialAccountNumberId?: number,
    accountNumber?: string,
  ): Promise<string> {
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

      return financialAccount.accountNumber;
    }

    if (!accountNumber) {
      throw new BadRequestException(
        'Either accountNumber or financialAccountNumberId must be provided',
      );
    }

    return accountNumber;
  }

  async findAll(query: ExpenseListQueryDto) {
    const { churchId, search, paymentMethod, startDate, endDate, skip, take } =
      query;

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
        where.createdAt.gte = new Date(startDate);
      }
      if (endDate) {
        where.createdAt.lte = new Date(endDate);
      }
    }

    const [total, expenses] = await (this.prisma as any).$transaction([
      (this.prisma as any).expense.count({ where }),
      (this.prisma as any).expense.findMany({
        where,
        take,
        skip,
        orderBy: { id: 'desc' },
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
    const { financialAccountNumberId, accountNumber, ...rest } =
      createExpenseDto;

    // Resolve the account number from FinancialAccountNumber if provided
    const resolvedAccountNumber = await this.resolveAccountNumber(
      financialAccountNumberId,
      accountNumber,
    );

    const data: any = {
      ...rest,
      accountNumber: resolvedAccountNumber,
    };

    // Link to FinancialAccountNumber if provided
    if (financialAccountNumberId) {
      data.financialAccountNumber = {
        connect: { id: financialAccountNumberId },
      };
    }

    const expense = await (this.prisma as any).expense.create({
      data,
      include: {
        activity: true,
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
    const { financialAccountNumberId, accountNumber, ...rest } =
      updateExpenseDto;

    const data: any = { ...rest };

    // If financialAccountNumberId is provided, resolve and update the account number
    if (financialAccountNumberId !== undefined) {
      if (financialAccountNumberId === null) {
        // Disconnect the financial account number
        data.financialAccountNumber = { disconnect: true };
      } else {
        // Resolve the account number from the linked FinancialAccountNumber
        const resolvedAccountNumber = await this.resolveAccountNumber(
          financialAccountNumberId,
          undefined,
        );
        data.accountNumber = resolvedAccountNumber;
        data.financialAccountNumber = {
          connect: { id: financialAccountNumberId },
        };
      }
    } else if (accountNumber !== undefined) {
      // If only accountNumber is provided (no financialAccountNumberId), update it directly
      data.accountNumber = accountNumber;
    }

    const expense = await (this.prisma as any).expense.update({
      where: { id },
      data,
      include: {
        activity: true,
        financialAccountNumber: true,
      },
    });

    return {
      message: 'Expense updated successfully',
      data: expense,
    };
  }
}
