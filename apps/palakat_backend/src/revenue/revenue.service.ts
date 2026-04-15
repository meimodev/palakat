import {
  BadRequestException,
  Injectable,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { FinancialType } from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import { RealtimeEmitterService } from '../realtime/realtime-emitter.service';
import { CreateRevenueDto } from './dto/create-revenue.dto';
import { RevenueListQueryDto } from './dto/revenue-list.dto';
import { UpdateRevenueDto } from './dto/update-revenue.dto';

@Injectable()
export class RevenueService {
  constructor(
    private prisma: PrismaService,
    @Inject(forwardRef(() => RealtimeEmitterService))
    private realtime: RealtimeEmitterService,
  ) {}

  private emitRevenueFinanceEvent(
    eventName: 'finance.created' | 'finance.updated' | 'finance.deleted',
    revenue: any,
    updatedAt?: Date,
  ) {
    if (
      typeof revenue?.id !== 'number' ||
      typeof revenue?.churchId !== 'number'
    ) {
      return;
    }

    this.realtime.emitFinanceEvent({
      eventName,
      financeId: revenue.id,
      financeType: 'REVENUE',
      churchId: revenue.churchId,
      activityId: revenue.activityId ?? revenue.activity?.id ?? null,
      affectedMembershipIds: (revenue.approvers ?? []).map(
        (approver: any) => approver.membershipId,
      ),
      updatedAt: updatedAt ?? revenue.updatedAt,
    });
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

  private async resolveFinanceApproverMembershipIds(
    churchId: number,
  ): Promise<number[]> {
    const rules = await (this.prisma as any).approvalRule.findMany({
      where: {
        churchId,
        financialType: FinancialType.REVENUE,
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
    revenueId: number,
    churchId: number,
  ): Promise<number[]> {
    await tx.revenueApprover.deleteMany({ where: { revenueId } });

    const membershipIds =
      await this.resolveFinanceApproverMembershipIds(churchId);

    if (membershipIds.length === 0) return [];

    await tx.revenueApprover.createMany({
      data: membershipIds.map((membershipId: number) => ({
        revenueId,
        membershipId,
      })),
    });

    return membershipIds;
  }

  private emitRevenueApprovalRequiredEvent(
    revenue: any,
    membershipIds?: number[],
  ) {
    const affectedMembershipIds =
      membershipIds ??
      (revenue?.approvers ?? []).map((approver: any) => approver.membershipId);

    if (
      typeof revenue?.id !== 'number' ||
      typeof revenue?.churchId !== 'number' ||
      !Array.isArray(affectedMembershipIds) ||
      affectedMembershipIds.length === 0
    ) {
      return;
    }

    this.realtime.emitApprovalLifecycleEvent({
      eventName: 'approval.required',
      entityType: 'REVENUE',
      entityId: revenue.id,
      entityTitle: revenue.activity?.title ?? 'Revenue approval',
      churchId: revenue.churchId,
      resultingStatus: 'UNCONFIRMED',
      isOverride: false,
      affectedMembershipIds,
      updatedAt: revenue.updatedAt,
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

  async findAll(query: RevenueListQueryDto) {
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

    const include = this.buildRevenueInclude();
    const [total, revenues] = await (this.prisma as any).$transaction([
      (this.prisma as any).revenue.count({ where }),
      (this.prisma as any).revenue.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include,
      }),
    ]);

    let searchInfo = '';
    if (search && revenues.length > 0) {
      const matchedFields = new Set<string>();
      revenues.forEach((revenue: any) => {
        if (
          revenue.accountNumber?.toLowerCase().includes(search.toLowerCase())
        ) {
          matchedFields.add('accountNumber');
        }
        if (
          revenue.activity?.title?.toLowerCase().includes(search.toLowerCase())
        ) {
          matchedFields.add('activity.title');
        }
      });
      if (matchedFields.size > 0) {
        searchInfo = ` (matched in: ${Array.from(matchedFields).join(', ')})`;
      }
    }

    return {
      message: `Revenues retrieved successfully${searchInfo}`,
      data: revenues,
      total,
    };
  }

  async findOne(id: number) {
    const revenue = await (this.prisma as any).revenue.findUniqueOrThrow({
      where: { id },
      include: this.buildRevenueInclude(),
    });
    return {
      message: 'Revenue retrieved successfully',
      data: revenue,
    };
  }

  async remove(id: number) {
    const revenue = await (this.prisma as any).revenue.delete({
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

    this.emitRevenueFinanceEvent('finance.deleted', revenue, new Date());

    return {
      message: 'Revenue deleted successfully',
    };
  }

  async create(
    createRevenueDto: CreateRevenueDto,
  ): Promise<{ message: string; data: any }> {
    const { financialAccountNumberId, accountNumber, activityId, ...rest } =
      createRevenueDto;

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

    const include = this.buildRevenueInclude();
    const revenue = await (this.prisma as any).$transaction(async (tx: any) => {
      const createdRevenue = await tx.revenue.create({ data });
      await this.syncApprovers(tx, createdRevenue.id, rest.churchId);
      return tx.revenue.findUniqueOrThrow({
        where: { id: createdRevenue.id },
        include,
      });
    });

    this.emitRevenueFinanceEvent('finance.created', revenue);
    this.emitRevenueApprovalRequiredEvent(revenue);

    return {
      message: 'Revenue created successfully',
      data: revenue,
    };
  }

  async update(
    id: number,
    updateRevenueDto: UpdateRevenueDto,
  ): Promise<{ message: string; data: any }> {
    const { financialAccountNumberId, accountNumber, activityId, ...rest } =
      updateRevenueDto;

    const currentRevenue = await (this.prisma as any).revenue.findUniqueOrThrow(
      {
        where: { id },
        select: {
          churchId: true,
          financialAccountNumberId: true,
        },
      },
    );

    const effectiveChurchId = rest.churchId ?? currentRevenue.churchId;
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

    const include = this.buildRevenueInclude();
    let refreshedApproverMembershipIds: number[] = [];
    const revenue = await (this.prisma as any).$transaction(async (tx: any) => {
      const updatedRevenue = await tx.revenue.update({
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

      return tx.revenue.findUniqueOrThrow({
        where: { id: updatedRevenue.id },
        include,
      });
    });

    this.emitRevenueFinanceEvent('finance.updated', revenue);
    if (refreshedApproverMembershipIds.length > 0) {
      this.emitRevenueApprovalRequiredEvent(
        revenue,
        refreshedApproverMembershipIds,
      );
    }

    return {
      message: 'Revenue updated successfully',
      data: revenue,
    };
  }
}
