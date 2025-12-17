import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '../generated/prisma/client';
import { MembershipPositionListQueryDto } from './dto/membership-position-list.dto';

@Injectable()
export class MembershipPositionService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: Prisma.MembershipPositionCreateInput) {
    const record = await this.prisma.membershipPosition.create({
      data: dto,
    });

    return {
      message: 'OK',
      data: record,
    } as const;
  }

  async findAll(query: MembershipPositionListQueryDto) {
    const {
      churchId,
      membershipId,
      skip,
      take,
      sortBy = 'name',
      sortOrder = 'asc',
    } = query ?? ({} as any);

    const where: Prisma.MembershipPositionWhereInput = {};
    if (churchId) where.churchId = churchId;
    if (membershipId) where.membershipId = membershipId;

    const [total, items] = await this.prisma.$transaction([
      this.prisma.membershipPosition.count({ where }),
      this.prisma.membershipPosition.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
      }),
    ]);

    return {
      message: 'OK',
      data: items,
      total,
    } as const;
  }

  async findOne(id: number) {
    const item = await this.prisma.membershipPosition.findUniqueOrThrow({
      where: { id },
      include: {
        membership: {
          select: {
            membershipPositions: {
              select: {
                name: true,
              },
            },
            account: {
              select: {
                name: true,
              },
            },
          },
        },
      },
    });

    const membership = item.membership;
    const { ...rest } = item;
    const membershipData = {
      positions: membership?.membershipPositions?.map((p) => p.name) ?? [],
      accountName: membership?.account?.name ?? null,
    } as const;

    return {
      message: 'OK',
      data: { ...rest, ...membershipData },
    };
  }

  async update(id: number, dto: Prisma.MembershipPositionUpdateInput) {
    const item = await this.prisma.membershipPosition.update({
      where: { id },
      data: dto,
    });
    return { message: 'OK', data: item };
  }

  async delete(id: number) {
    await this.prisma.membershipPosition.delete({ where: { id } });
    return { message: 'OK' } as const;
  }
}
