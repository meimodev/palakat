import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import {
  CashAccountListQueryDto,
  CreateCashAccountDto,
  UpdateCashAccountDto,
} from './dto';

@Injectable()
export class CashAccountService {
  constructor(private prisma: PrismaService) {}

  private async resolveRequesterChurchId(user?: any): Promise<number> {
    const userId = user?.userId;
    if (!userId) throw new BadRequestException('Invalid user');

    const membership = await this.prisma.membership.findUnique({
      where: { accountId: userId },
      select: { churchId: true },
    });

    if (!membership?.churchId) {
      throw new BadRequestException(
        'Account does not have an active membership',
      );
    }

    return membership.churchId;
  }

  private async computeBalance(params: {
    churchId: number;
    accountId: number;
  }): Promise<number> {
    const account = await this.prisma.cashAccount.findFirst({
      where: { id: params.accountId, churchId: params.churchId },
      select: { openingBalance: true },
    });

    if (!account) throw new NotFoundException('Cash account not found');

    const inAgg = await this.prisma.cashMutation.aggregate({
      where: { churchId: params.churchId, toAccountId: params.accountId },
      _sum: { amount: true },
    });

    const outAgg = await this.prisma.cashMutation.aggregate({
      where: { churchId: params.churchId, fromAccountId: params.accountId },
      _sum: { amount: true },
    });

    const incoming = inAgg?._sum?.amount ?? 0;
    const outgoing = outAgg?._sum?.amount ?? 0;

    return (account.openingBalance ?? 0) + incoming - outgoing;
  }

  async findAll(query: CashAccountListQueryDto, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);
    const {
      search,
      skip,
      take,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    const where: any = { churchId };
    if (search) {
      where.name = { contains: search, mode: 'insensitive' };
    }

    const [total, data] = await this.prisma.$transaction([
      this.prisma.cashAccount.count({ where }),
      this.prisma.cashAccount.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
      }),
    ]);

    const withBalance = await Promise.all(
      (data as Array<{ id: number }>).map(async (a: any) => ({
        ...a,
        balance: await this.computeBalance({ churchId, accountId: a.id }),
      })),
    );

    return {
      message: 'Cash accounts retrieved successfully',
      data: withBalance,
      total,
    };
  }

  async findOne(id: number, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);
    const account = await this.prisma.cashAccount.findFirst({
      where: { id, churchId },
    });

    if (!account) throw new NotFoundException('Cash account not found');

    const balance = await this.computeBalance({ churchId, accountId: id });

    return {
      message: 'Cash account retrieved successfully',
      data: { ...account, balance },
    };
  }

  async create(dto: CreateCashAccountDto, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const record = await this.prisma.cashAccount.create({
      data: {
        churchId,
        name: dto.name,
        currency: dto.currency ?? 'IDR',
        openingBalance: dto.openingBalance ?? 0,
      },
    });

    const balance = await this.computeBalance({
      churchId,
      accountId: record.id,
    });

    return {
      message: 'Cash account created successfully',
      data: { ...record, balance },
    };
  }

  async update(id: number, dto: UpdateCashAccountDto, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const existing = await this.prisma.cashAccount.findFirst({
      where: { id, churchId },
    });
    if (!existing) throw new NotFoundException('Cash account not found');

    const record = await this.prisma.cashAccount.update({
      where: { id },
      data: {
        ...(dto.name !== undefined ? { name: dto.name } : {}),
        ...(dto.currency !== undefined ? { currency: dto.currency } : {}),
        ...(dto.openingBalance !== undefined
          ? { openingBalance: dto.openingBalance }
          : {}),
      },
    });

    const balance = await this.computeBalance({ churchId, accountId: id });

    return {
      message: 'Cash account updated successfully',
      data: { ...record, balance },
    };
  }

  async remove(id: number, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const existing = await this.prisma.cashAccount.findFirst({
      where: { id, churchId },
    });
    if (!existing) throw new NotFoundException('Cash account not found');

    const mutationCount = await this.prisma.cashMutation.count({
      where: {
        churchId,
        OR: [{ fromAccountId: id }, { toAccountId: id }],
      },
    });

    if (mutationCount > 0) {
      throw new BadRequestException(
        'Cannot delete cash account that has mutations',
      );
    }

    await this.prisma.cashAccount.delete({ where: { id } });

    return { message: 'Cash account deleted successfully' };
  }
}
