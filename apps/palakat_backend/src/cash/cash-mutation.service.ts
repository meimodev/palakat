import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  CashMutationReferenceType,
  CashMutationType,
} from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import {
  CashMutationListQueryDto,
  CreateCashMutationDto,
  TransferCashDto,
} from './dto';

@Injectable()
export class CashMutationService {
  constructor(private prisma: PrismaService) {}

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

  private async assertAccountOwnedByChurch(params: {
    churchId: number;
    accountId: number;
  }) {
    const exists = await this.prisma.cashAccount.findFirst({
      where: { id: params.accountId, churchId: params.churchId },
      select: { id: true },
    });

    if (!exists) throw new NotFoundException('Cash account not found');
  }

  private validateMutation(dto: CreateCashMutationDto) {
    if (dto.type === CashMutationType.IN) {
      if (!dto.toAccountId || dto.fromAccountId) {
        throw new BadRequestException(
          'IN mutation requires toAccountId and must not include fromAccountId',
        );
      }
    }

    if (dto.type === CashMutationType.OUT) {
      if (!dto.fromAccountId || dto.toAccountId) {
        throw new BadRequestException(
          'OUT mutation requires fromAccountId and must not include toAccountId',
        );
      }
    }

    if (dto.type === CashMutationType.TRANSFER) {
      if (!dto.fromAccountId || !dto.toAccountId) {
        throw new BadRequestException(
          'TRANSFER mutation requires fromAccountId and toAccountId',
        );
      }
      if (dto.fromAccountId === dto.toAccountId) {
        throw new BadRequestException('TRANSFER requires different accounts');
      }
    }

    if (dto.type === CashMutationType.ADJUSTMENT) {
      // For adjustment we allow either fromAccountId (negative) or toAccountId (positive)
      // but not both. Amount is always positive.
      const hasFrom = !!dto.fromAccountId;
      const hasTo = !!dto.toAccountId;
      if (hasFrom === hasTo) {
        throw new BadRequestException(
          'ADJUSTMENT requires exactly one of fromAccountId or toAccountId',
        );
      }
    }
  }

  async findAll(query: CashMutationListQueryDto, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);
    const {
      accountId,
      type,
      startDate,
      endDate,
      search,
      skip,
      take,
      sortBy = 'happenedAt',
      sortOrder = 'desc',
    } = query;

    const where: any = { churchId };

    if (accountId) {
      where.OR = [{ fromAccountId: accountId }, { toAccountId: accountId }];
    }

    if (type) where.type = type;

    if (startDate && endDate) {
      where.happenedAt = { gte: startDate, lte: endDate };
    }

    if (search) {
      where.note = { contains: search, mode: 'insensitive' };
    }

    const [total, data] = await this.prisma.$transaction([
      this.prisma.cashMutation.count({ where }),
      this.prisma.cashMutation.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: {
          fromAccount: true,
          toAccount: true,
          createdBy: { select: { id: true, name: true } },
        },
      }),
    ]);

    return { message: 'Cash mutations retrieved successfully', data, total };
  }

  async findOne(id: number, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const record = await this.prisma.cashMutation.findFirst({
      where: { id, churchId },
      include: {
        fromAccount: true,
        toAccount: true,
        createdBy: { select: { id: true, name: true } },
      },
    });

    if (!record) throw new NotFoundException('Cash mutation not found');

    return { message: 'Cash mutation retrieved successfully', data: record };
  }

  async create(dto: CreateCashMutationDto, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);
    const userId = user?.userId;

    this.validateMutation(dto);

    if (dto.fromAccountId) {
      await this.assertAccountOwnedByChurch({
        churchId,
        accountId: dto.fromAccountId,
      });
    }

    if (dto.toAccountId) {
      await this.assertAccountOwnedByChurch({
        churchId,
        accountId: dto.toAccountId,
      });
    }

    const record = await this.prisma.cashMutation.create({
      data: {
        churchId,
        type: dto.type,
        amount: dto.amount,
        fromAccountId: dto.fromAccountId ?? null,
        toAccountId: dto.toAccountId ?? null,
        happenedAt: dto.happenedAt,
        note: dto.note,
        referenceType: dto.referenceType ?? CashMutationReferenceType.MANUAL,
        referenceId: dto.referenceId ?? null,
        createdById: userId ?? null,
      },
      include: {
        fromAccount: true,
        toAccount: true,
        createdBy: { select: { id: true, name: true } },
      },
    });

    return { message: 'Cash mutation created successfully', data: record };
  }

  async transfer(dto: TransferCashDto, user?: any) {
    const mutation = await this.create(
      {
        type: CashMutationType.TRANSFER,
        amount: dto.amount,
        fromAccountId: dto.fromAccountId,
        toAccountId: dto.toAccountId,
        happenedAt: dto.happenedAt,
        note: dto.note,
        referenceType: CashMutationReferenceType.TRANSFER,
      },
      user,
    );

    return mutation;
  }

  async remove(id: number, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const existing = await this.prisma.cashMutation.findFirst({
      where: { id, churchId },
    });

    if (!existing) throw new NotFoundException('Cash mutation not found');

    await this.prisma.cashMutation.delete({ where: { id } });

    return { message: 'Cash mutation deleted successfully' };
  }
}
