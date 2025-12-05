import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateRevenueDto } from './dto/create-revenue.dto';
import { RevenueListQueryDto } from './dto/revenue-list.dto';
import { UpdateRevenueDto } from './dto/update-revenue.dto';

@Injectable()
export class RevenueService {
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

    const [total, revenues] = await (this.prisma as any).$transaction([
      (this.prisma as any).revenue.count({ where }),
      (this.prisma as any).revenue.findMany({
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
      message: 'Revenue retrieved successfully',
      data: revenue,
    };
  }

  async remove(id: number) {
    await (this.prisma as any).revenue.delete({
      where: { id },
    });
    return {
      message: 'Revenue deleted successfully',
    };
  }

  async create(
    createRevenueDto: CreateRevenueDto,
  ): Promise<{ message: string; data: any }> {
    const { financialAccountNumberId, accountNumber, ...rest } =
      createRevenueDto;

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

    const revenue = await (this.prisma as any).revenue.create({
      data,
      include: {
        activity: true,
        financialAccountNumber: true,
      },
    });

    return {
      message: 'Revenue created successfully',
      data: revenue,
    };
  }

  async update(
    id: number,
    updateRevenueDto: UpdateRevenueDto,
  ): Promise<{ message: string; data: any }> {
    const { financialAccountNumberId, accountNumber, ...rest } =
      updateRevenueDto;

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

    const revenue = await (this.prisma as any).revenue.update({
      where: { id },
      data,
      include: {
        activity: true,
        financialAccountNumber: true,
      },
    });

    return {
      message: 'Revenue updated successfully',
      data: revenue,
    };
  }
}
