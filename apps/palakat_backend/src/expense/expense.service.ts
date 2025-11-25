import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { ExpenseListQueryDto } from './dto/expense-list.dto';

@Injectable()
export class ExpenseService {
  constructor(private prisma: PrismaService) {}

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

  async create(createExpenseDto: any): Promise<{ message: string; data: any }> {
    const expense = await (this.prisma as any).expense.create({
      data: createExpenseDto,
      include: {
        activity: true,
      },
    });
    return {
      message: 'Expense created successfully',
      data: expense,
    };
  }

  async update(
    id: number,
    updateExpenseDto: any,
  ): Promise<{ message: string; data: any }> {
    const expense = await (this.prisma as any).expense.update({
      where: { id },
      data: updateExpenseDto,
    });
    return {
      message: 'Expense updated successfully',
      data: expense,
    };
  }
}
