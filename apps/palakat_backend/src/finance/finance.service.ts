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

  private async resolveActorName(user?: {
    userId?: number;
    name?: string | null;
  }): Promise<string | null> {
    const explicitName = user?.name?.trim();
    if (explicitName) {
      return explicitName;
    }

    if (typeof user?.userId !== 'number') {
      return null;
    }

    const account = await this.prisma.account.findUnique({
      where: { id: user.userId },
      select: { name: true },
    });

    return typeof account?.name === 'string' && account.name.trim().length > 0
      ? account.name.trim()
      : null;
  }

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

  private getFinanceApprovalEntityTitle(
    finance: any,
    entityType: 'REVENUE' | 'EXPENSE',
  ): string {
    const activityTitle = finance?.activity?.title?.toString().trim();
    if (activityTitle) {
      return activityTitle;
    }

    return entityType === 'REVENUE' ? 'Revenue approval' : 'Expense approval';
  }

  private emitFinanceApprovalLifecycleEvent(params: {
    eventName:
      | 'approval.approved'
      | 'approval.rejected'
      | 'approval.override.approved'
      | 'approval.override.rejected';
    entityType: 'REVENUE' | 'EXPENSE';
    finance: any;
    approver: any;
    actorName?: string | null;
    resultingStatus: ApprovalStatus;
    isOverride: boolean;
  }) {
    this.realtime.emitApprovalLifecycleEvent({
      eventName: params.eventName,
      entityType: params.entityType,
      entityId: params.finance.id,
      entityTitle: this.getFinanceApprovalEntityTitle(
        params.finance,
        params.entityType,
      ),
      churchId: params.finance.churchId,
      actorName:
        params.actorName ?? params.approver.membership?.account?.name ?? null,
      resultingStatus: params.resultingStatus,
      isOverride: params.isOverride,
      affectedMembershipIds: (params.finance.approvers ?? []).map(
        (item: any) => item.membershipId,
      ),
      updatedAt: params.finance.updatedAt,
    });
  }

  private buildFinanceWhere(query: FinanceListQueryDto, churchId: number) {
    const {
      search,
      paymentMethod,
      startDate,
      endDate,
      membershipId,
      standalone,
    } = query;
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

    if (standalone === true) {
      where.activityId = null;
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

      if (currentApprover.status !== ApprovalStatus.UNCONFIRMED) {
        throw new BadRequestException(
          'Approver decision has already been submitted',
        );
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

      this.emitFinanceApprovalLifecycleEvent({
        eventName:
          params.status === ApprovalStatus.APPROVED
            ? 'approval.approved'
            : 'approval.rejected',
        entityType: 'REVENUE',
        finance: approver.revenue,
        approver,
        resultingStatus: params.status,
        isOverride: false,
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

    if (currentApprover.status !== ApprovalStatus.UNCONFIRMED) {
      throw new BadRequestException(
        'Approver decision has already been submitted',
      );
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

    this.emitFinanceApprovalLifecycleEvent({
      eventName:
        params.status === ApprovalStatus.APPROVED
          ? 'approval.approved'
          : 'approval.rejected',
      entityType: 'EXPENSE',
      finance: approver.expense,
      approver,
      resultingStatus: params.status,
      isOverride: false,
    });

    return {
      message: 'Finance approver updated successfully',
      data: approver,
    };
  }

  /**
   * Admin override: skips the self-only check; forces a specific status on any
   * finance approver within the same church. Only callable from admin-app RPC actions.
   */
  async adminOverrideApprover(
    params: {
      financeType: FinanceEntryType | 'REVENUE' | 'EXPENSE';
      approverId: number;
      status: ApprovalStatus;
      overrideNote?: string;
    },
    user?: any,
  ) {
    const churchId = await this.resolveRequesterChurchId(user);
    const isRevenueType = `${params.financeType}` === FinanceEntryType.REVENUE;
    const actorName = await this.resolveActorName(user);

    if (isRevenueType) {
      const currentApprover = await (
        this.prisma as any
      ).revenueApprover.findUnique({
        where: { id: params.approverId },
        include: {
          revenue: { select: { id: true, churchId: true } },
        },
      });

      if (!currentApprover?.revenue) {
        throw new NotFoundException('Finance approver not found');
      }
      if (currentApprover.revenue.churchId !== churchId) {
        throw new BadRequestException('Invalid church scope');
      }

      const approver = await (this.prisma as any).revenueApprover.update({
        where: { id: params.approverId },
        data: { status: params.status },
        include: {
          revenue: { include: this.buildRevenueInclude() },
          membership: {
            include: {
              account: {
                select: { id: true, name: true, phone: true, dob: true },
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

      this.emitFinanceApprovalLifecycleEvent({
        eventName:
          params.status === ApprovalStatus.APPROVED
            ? 'approval.override.approved'
            : 'approval.override.rejected',
        entityType: 'REVENUE',
        finance: approver.revenue,
        approver,
        actorName,
        resultingStatus: params.status,
        isOverride: true,
      });

      return {
        message: 'Finance approver override applied successfully',
        data: approver,
      };
    }

    // EXPENSE branch
    const currentApprover = await (
      this.prisma as any
    ).expenseApprover.findUnique({
      where: { id: params.approverId },
      include: {
        expense: { select: { id: true, churchId: true } },
      },
    });

    if (!currentApprover?.expense) {
      throw new NotFoundException('Finance approver not found');
    }
    if (currentApprover.expense.churchId !== churchId) {
      throw new BadRequestException('Invalid church scope');
    }

    const approver = await (this.prisma as any).expenseApprover.update({
      where: { id: params.approverId },
      data: { status: params.status },
      include: {
        expense: { include: this.buildExpenseInclude() },
        membership: {
          include: {
            account: {
              select: { id: true, name: true, phone: true, dob: true },
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

    this.emitFinanceApprovalLifecycleEvent({
      eventName:
        params.status === ApprovalStatus.APPROVED
          ? 'approval.override.approved'
          : 'approval.override.rejected',
      entityType: 'EXPENSE',
      finance: approver.expense,
      approver,
      actorName,
      resultingStatus: params.status,
      isOverride: true,
    });

    return {
      message: 'Finance approver override applied successfully',
      data: approver,
    };
  }

  async getOverview(user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    // Fetch all revenues and expenses with their approvers to compute approval-aware totals
    const [revenues, expenses] = await (this.prisma as any).$transaction([
      (this.prisma as any).revenue.findMany({
        where: { churchId },
        include: { approvers: { select: { status: true } } },
      }),
      (this.prisma as any).expense.findMany({
        where: { churchId },
        include: { approvers: { select: { status: true } } },
      }),
    ]);

    // Helper to determine effective approval status matching shared client logic
    const getEffectiveStatus = (
      entry: any,
    ): { isApproved: boolean; isUnconfirmed: boolean; isRejected: boolean } => {
      const isOverridden = entry.isOverridden === true;
      const overrideStatus = entry.overrideStatus;

      // Overridden entries: override status determines effective status
      if (isOverridden && overrideStatus != null) {
        const isApproved = overrideStatus === ApprovalStatus.APPROVED;
        return {
          isApproved,
          isUnconfirmed:
            !isApproved && overrideStatus !== ApprovalStatus.REJECTED,
          isRejected: overrideStatus === ApprovalStatus.REJECTED,
        };
      }

      const approvers = entry.approvers ?? [];

      // Empty approver list is treated as unconfirmed (matches shared extension behavior)
      if (approvers.length === 0) {
        return { isApproved: false, isUnconfirmed: true, isRejected: false };
      }

      const hasRejected = approvers.some(
        (a: any) => a.status === ApprovalStatus.REJECTED,
      );
      if (hasRejected) {
        return { isApproved: false, isUnconfirmed: false, isRejected: true };
      }

      const allApproved = approvers.every(
        (a: any) => a.status === ApprovalStatus.APPROVED,
      );
      if (allApproved) {
        return { isApproved: true, isUnconfirmed: false, isRejected: false };
      }

      // Some pending/mixed states = unconfirmed
      return { isApproved: false, isUnconfirmed: true, isRejected: false };
    };

    let approvedCashRevenue = 0;
    let approvedCashlessRevenue = 0;
    let approvedCashExpense = 0;
    let approvedCashlessExpense = 0;
    let unconfirmedRevenueAmount = 0;
    let unconfirmedExpenseAmount = 0;
    const updatedAts: Date[] = [];

    for (const revenue of revenues) {
      const status = getEffectiveStatus(revenue);
      const isCash = revenue.paymentMethod === PaymentMethod.CASH;

      if (status.isApproved) {
        if (isCash) {
          approvedCashRevenue += revenue.amount ?? 0;
        } else {
          approvedCashlessRevenue += revenue.amount ?? 0;
        }
      } else if (status.isUnconfirmed) {
        unconfirmedRevenueAmount += revenue.amount ?? 0;
      }
      // Rejected entries are excluded from all totals

      if (revenue.updatedAt) {
        updatedAts.push(revenue.updatedAt);
      }
    }

    for (const expense of expenses) {
      const status = getEffectiveStatus(expense);
      const isCash = expense.paymentMethod === PaymentMethod.CASH;

      if (status.isApproved) {
        if (isCash) {
          approvedCashExpense += expense.amount ?? 0;
        } else {
          approvedCashlessExpense += expense.amount ?? 0;
        }
      } else if (status.isUnconfirmed) {
        unconfirmedExpenseAmount += expense.amount ?? 0;
      }
      // Rejected entries are excluded from all totals

      if (expense.updatedAt) {
        updatedAts.push(expense.updatedAt);
      }
    }

    const cashBalance = approvedCashRevenue - approvedCashExpense;
    const cashlessBalance = approvedCashlessRevenue - approvedCashlessExpense;
    const totalBalance = cashBalance + cashlessBalance;

    const lastUpdatedAt =
      updatedAts.sort((a, b) => b.getTime() - a.getTime())[0] ?? null;

    return {
      message: 'Finance overview retrieved successfully',
      data: {
        totalBalance,
        cashBalance,
        cashlessBalance,
        unconfirmedRevenueAmount,
        unconfirmedExpenseAmount,
        lastUpdatedAt,
      },
    };
  }
}
