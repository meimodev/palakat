import { BadRequestException, Injectable } from '@nestjs/common';
import { PaymentMethod } from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import { FinanceEntryType, FinanceListQueryDto } from './dto/finance-list.dto';

@Injectable()
export class FinanceService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: FinanceListQueryDto, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const {
      search,
      paymentMethod,
      type,
      startDate,
      endDate,
      skip = 0,
      take = 10,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    // Build base where clause
    const baseWhere: any = { churchId };

    if (search) {
      baseWhere.OR = [
        { accountNumber: { contains: search, mode: 'insensitive' } },
        { activity: { title: { contains: search, mode: 'insensitive' } } },
      ];
    }

    if (paymentMethod) {
      baseWhere.paymentMethod = paymentMethod;
    }

    if (startDate || endDate) {
      baseWhere.createdAt = {};
      if (startDate) baseWhere.createdAt.gte = startDate;
      if (endDate) baseWhere.createdAt.lte = endDate;
    }

    // Determine which types to fetch
    const includeRevenue = !type || type === FinanceEntryType.REVENUE;
    const includeExpense = !type || type === FinanceEntryType.EXPENSE;

    const includeActivity = {
      activity: {
        include: {
          approvers: true,
          supervisor: true,
        },
      },
    };

    // Fetch data in parallel
    const [revenues, expenses, revenueCount, expenseCount] = await Promise.all([
      includeRevenue
        ? (this.prisma as any).revenue.findMany({
            where: baseWhere,
            include: includeActivity,
          })
        : [],
      includeExpense
        ? (this.prisma as any).expense.findMany({
            where: baseWhere,
            include: includeActivity,
          })
        : [],
      includeRevenue
        ? (this.prisma as any).revenue.count({ where: baseWhere })
        : 0,
      includeExpense
        ? (this.prisma as any).expense.count({ where: baseWhere })
        : 0,
    ]);

    // Combine and add type field
    const combined = [
      ...revenues.map((r: any) => ({ ...r, type: 'REVENUE' })),
      ...expenses.map((e: any) => ({ ...e, type: 'EXPENSE' })),
    ];

    // Sort combined data
    combined.sort((a: any, b: any) => {
      const aVal = a[sortBy];
      const bVal = b[sortBy];

      if (aVal instanceof Date && bVal instanceof Date) {
        return sortOrder === 'desc'
          ? bVal.getTime() - aVal.getTime()
          : aVal.getTime() - bVal.getTime();
      }

      if (typeof aVal === 'number' && typeof bVal === 'number') {
        return sortOrder === 'desc' ? bVal - aVal : aVal - bVal;
      }

      // Fallback to string comparison
      const aStr = String(aVal ?? '');
      const bStr = String(bVal ?? '');
      return sortOrder === 'desc'
        ? bStr.localeCompare(aStr)
        : aStr.localeCompare(bStr);
    });

    // Paginate
    const total = revenueCount + expenseCount;
    const data = combined.slice(skip, skip + take);

    return {
      message: 'Finance data retrieved successfully',
      data,
      total,
    };
  }

  private async resolveRequesterChurchId(user?: any): Promise<number> {
    const userId = user?.userId;
    if (!userId) throw new BadRequestException('Invalid user');

    const membership = await this.prisma.membership.findUnique({
      where: { accountId: userId },
      select: {
        churchId: true,
        column: {
          select: {
            churchId: true,
          },
        },
      },
    });

    const churchId = membership?.churchId ?? membership?.column?.churchId;
    if (!churchId) {
      throw new BadRequestException(
        'Account does not have an active membership',
      );
    }

    return churchId;
  }

  async getOverview(user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const [
      revenueCashAgg,
      revenueCashlessAgg,
      expenseCashAgg,
      expenseCashlessAgg,
    ] = await (this.prisma as any).$transaction([
      (this.prisma as any).revenue.aggregate({
        where: { churchId, paymentMethod: PaymentMethod.CASH },
        _sum: { amount: true },
        _max: { updatedAt: true },
      }),
      (this.prisma as any).revenue.aggregate({
        where: { churchId, paymentMethod: PaymentMethod.CASHLESS },
        _sum: { amount: true },
        _max: { updatedAt: true },
      }),
      (this.prisma as any).expense.aggregate({
        where: { churchId, paymentMethod: PaymentMethod.CASH },
        _sum: { amount: true },
        _max: { updatedAt: true },
      }),
      (this.prisma as any).expense.aggregate({
        where: { churchId, paymentMethod: PaymentMethod.CASHLESS },
        _sum: { amount: true },
        _max: { updatedAt: true },
      }),
    ]);

    const revenueCash = revenueCashAgg?._sum?.amount ?? 0;
    const revenueCashless = revenueCashlessAgg?._sum?.amount ?? 0;
    const expenseCash = expenseCashAgg?._sum?.amount ?? 0;
    const expenseCashless = expenseCashlessAgg?._sum?.amount ?? 0;

    const cashBalance = revenueCash - expenseCash;
    const cashlessBalance = revenueCashless - expenseCashless;
    const totalBalance = cashBalance + cashlessBalance;

    const updatedAts = [
      revenueCashAgg?._max?.updatedAt,
      revenueCashlessAgg?._max?.updatedAt,
      expenseCashAgg?._max?.updatedAt,
      expenseCashlessAgg?._max?.updatedAt,
    ].filter((d): d is Date => !!d);

    const lastUpdatedAt =
      updatedAts.sort((a, b) => b.getTime() - a.getTime())[0] ?? null;

    return {
      message: 'Finance overview retrieved successfully',
      data: {
        totalBalance,
        cashBalance,
        cashlessBalance,
        lastUpdatedAt,
      },
    };
  }
}
