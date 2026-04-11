import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { ApprovalStatus, PaymentMethod } from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import { RealtimeEmitterService } from '../realtime/realtime-emitter.service';
import { FinanceEntryType, FinanceListQueryDto } from './dto/finance-list.dto';

@Injectable()
export class FinanceService {
  constructor(
    private prisma: PrismaService,
    @Inject(forwardRef(() => RealtimeEmitterService))
    private realtime: RealtimeEmitterService,
  ) {}

  private normalizeFinanceDate(value?: Date | string): Date | undefined {
    if (value == null) return undefined;

    if (value instanceof Date) {
      if (Number.isNaN(value.getTime())) {
        throw new BadRequestException('Invalid finance date range');
      }

      return value;
    }

    const trimmed = value.trim();
    if (!trimmed) return undefined;

    const hasTimezone =
      trimmed.endsWith('Z') ||
      /[+-]\d{2}:\d{2}$/.test(trimmed) ||
      /[+-]\d{4}$/.test(trimmed);

    const parsed = new Date(hasTimezone ? trimmed : `${trimmed}Z`);
    if (Number.isNaN(parsed.getTime())) {
      throw new BadRequestException('Invalid finance date range');
    }

    return parsed;
  }

  private buildRevenueInclude() {
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

  private buildFinanceWhere(query: FinanceListQueryDto, churchId: number) {
    const { search, paymentMethod, startDate, endDate, membershipId } = query;
    const normalizedStartDate = this.normalizeFinanceDate(startDate);
    const normalizedEndDate = this.normalizeFinanceDate(endDate);

    if (
      normalizedStartDate != null &&
      normalizedEndDate != null &&
      normalizedStartDate > normalizedEndDate
    ) {
      throw new BadRequestException('Invalid finance date range');
    }

    const where: any = { churchId };

    if (search) {
      where.OR = [
        { accountNumber: { contains: search, mode: 'insensitive' } },
        { activity: { title: { contains: search, mode: 'insensitive' } } },
      ];
    }

    if (paymentMethod) {
      where.paymentMethod = paymentMethod;
    }

    if (normalizedStartDate || normalizedEndDate) {
      where.createdAt = {};
      if (normalizedStartDate) where.createdAt.gte = normalizedStartDate;
      if (normalizedEndDate) where.createdAt.lte = normalizedEndDate;
    }

    if (membershipId != null) {
      where.approvers = {
        some: {
          membershipId,
        },
      };
    }

    return where;
  }

  async findAll(query: FinanceListQueryDto, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);
    const {
      type,
      skip = 0,
      take = 10,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    const baseWhere = this.buildFinanceWhere(query, churchId);
    const includeRevenue = !type || type === FinanceEntryType.REVENUE;
    const includeExpense = !type || type === FinanceEntryType.EXPENSE;

    const [revenues, expenses, revenueCount, expenseCount] = await Promise.all([
      includeRevenue
        ? (this.prisma as any).revenue.findMany({
            where: baseWhere,
            include: this.buildRevenueInclude(),
          })
        : [],
      includeExpense
        ? (this.prisma as any).expense.findMany({
            where: baseWhere,
            include: this.buildExpenseInclude(),
          })
        : [],
      includeRevenue
        ? (this.prisma as any).revenue.count({ where: baseWhere })
        : 0,
      includeExpense
        ? (this.prisma as any).expense.count({ where: baseWhere })
        : 0,
    ]);

    const combined = [
      ...revenues.map((revenue: any) => ({ ...revenue, type: 'REVENUE' })),
      ...expenses.map((expense: any) => ({ ...expense, type: 'EXPENSE' })),
    ];

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

      const aStr = String(aVal ?? '');
      const bStr = String(bVal ?? '');
      return sortOrder === 'desc'
        ? bStr.localeCompare(aStr)
        : aStr.localeCompare(bStr);
    });

    return {
      message: 'Finance data retrieved successfully',
      data: combined.slice(skip, skip + take),
      total: revenueCount + expenseCount,
    };
  }

  async findOne(
    params: {
      id: number;
      financeType: FinanceEntryType | 'REVENUE' | 'EXPENSE';
      membershipId?: number;
    },
    user?: any,
  ) {
    const churchId = await this.resolveRequesterChurchId(user);
    const membershipId = params.membershipId;
    const isRevenueType = `${params.financeType}` === FinanceEntryType.REVENUE;

    if (isRevenueType) {
      const revenue = await (this.prisma as any).revenue.findFirst({
        where: {
          id: params.id,
          churchId,
          ...(membershipId != null
            ? {
                approvers: {
                  some: {
                    membershipId,
                  },
                },
              }
            : {}),
        },
        include: this.buildRevenueInclude(),
      });

      if (!revenue) {
        throw new NotFoundException('Revenue not found');
      }

      return {
        message: 'Finance data retrieved successfully',
        data: {
          ...revenue,
          type: 'REVENUE',
        },
      };
    }

    const expense = await (this.prisma as any).expense.findFirst({
      where: {
        id: params.id,
        churchId,
        ...(membershipId != null
          ? {
              approvers: {
                some: {
                  membershipId,
                },
              },
            }
          : {}),
      },
      include: this.buildExpenseInclude(),
    });

    if (!expense) {
      throw new NotFoundException('Expense not found');
    }

    return {
      message: 'Finance data retrieved successfully',
      data: {
        ...expense,
        type: 'EXPENSE',
      },
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

  private async resolveRequesterMembershipId(user?: any): Promise<number> {
    const userId = user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    const membership = await this.prisma.membership.findUnique({
      where: { accountId: userId },
      select: { id: true },
    });

    if (!membership?.id) {
      throw new BadRequestException(
        'Account does not have an active membership',
      );
    }

    return membership.id;
  }

  async updateApprover(
    params: {
      financeType: FinanceEntryType | 'REVENUE' | 'EXPENSE';
      approverId: number;
      status: ApprovalStatus;
    },
    user?: any,
  ) {
    const churchId = await this.resolveRequesterChurchId(user);
    const requesterMembershipId = await this.resolveRequesterMembershipId(user);
    const isRevenueType = `${params.financeType}` === FinanceEntryType.REVENUE;

    if (isRevenueType) {
      const currentApprover = await (
        this.prisma as any
      ).revenueApprover.findUnique({
        where: { id: params.approverId },
        include: {
          revenue: {
            select: {
              id: true,
              churchId: true,
            },
          },
        },
      });

      if (!currentApprover?.revenue) {
        throw new NotFoundException('Finance approver not found');
      }

      if (currentApprover.revenue.churchId !== churchId) {
        throw new BadRequestException('Invalid church scope');
      }

      if (currentApprover.membershipId !== requesterMembershipId) {
        throw new ForbiddenException('You cannot update this approver');
      }

      const approver = await (this.prisma as any).revenueApprover.update({
        where: { id: params.approverId },
        data: { status: params.status },
        include: {
          revenue: {
            include: this.buildRevenueInclude(),
          },
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
            },
          },
        },
      });

      this.realtime.emitFinanceEvent({
        eventName: 'finance.updated',
        financeId: approver.revenue.id,
        financeType: 'REVENUE',
        churchId: approver.revenue.churchId,
        activityId:
          approver.revenue.activityId ?? approver.revenue.activity?.id ?? null,
        affectedMembershipIds: (approver.revenue.approvers ?? []).map(
          (item: any) => item.membershipId,
        ),
        updatedAt: approver.revenue.updatedAt,
      });

      return {
        message: 'Finance approver updated successfully',
        data: approver,
      };
    }

    const currentApprover = await (
      this.prisma as any
    ).expenseApprover.findUnique({
      where: { id: params.approverId },
      include: {
        expense: {
          select: {
            id: true,
            churchId: true,
          },
        },
      },
    });

    if (!currentApprover?.expense) {
      throw new NotFoundException('Finance approver not found');
    }

    if (currentApprover.expense.churchId !== churchId) {
      throw new BadRequestException('Invalid church scope');
    }

    if (currentApprover.membershipId !== requesterMembershipId) {
      throw new ForbiddenException('You cannot update this approver');
    }

    const approver = await (this.prisma as any).expenseApprover.update({
      where: { id: params.approverId },
      data: { status: params.status },
      include: {
        expense: {
          include: this.buildExpenseInclude(),
        },
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
          },
        },
      },
    });

    this.realtime.emitFinanceEvent({
      eventName: 'finance.updated',
      financeId: approver.expense.id,
      financeType: 'EXPENSE',
      churchId: approver.expense.churchId,
      activityId:
        approver.expense.activityId ?? approver.expense.activity?.id ?? null,
      affectedMembershipIds: (approver.expense.approvers ?? []).map(
        (item: any) => item.membershipId,
      ),
      updatedAt: approver.expense.updatedAt,
    });

    return {
      message: 'Finance approver updated successfully',
      data: approver,
    };
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
