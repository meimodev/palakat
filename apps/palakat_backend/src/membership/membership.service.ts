import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from 'nestjs-prisma';
import { MembershipListQueryDto } from './dto/membership-list.dto';

@Injectable()
export class MembershipService {
  constructor(private prisma: PrismaService) {}

  async create(
    createMembershipDto: any,
  ): Promise<{ message: string; data: any }> {
    if (!createMembershipDto?.columnId && !createMembershipDto?.churchId) {
      throw new BadRequestException('Either columnId or churchId is required');
    }

    if (createMembershipDto?.columnId != null) {
      const column = await (this.prisma as any).column.findUnique({
        where: { id: createMembershipDto.columnId },
        select: { id: true, churchId: true },
      });
      if (!column) {
        throw new BadRequestException('columnId does not exist');
      }
      // If churchId not provided, derive from column
      if (createMembershipDto?.churchId == null) {
        createMembershipDto.churchId = column.churchId;
      } else if (column.churchId !== createMembershipDto.churchId) {
        throw new BadRequestException('columnId belongs to a different church');
      }
    }

    const membership = await (this.prisma as any).membership.create({
      data: createMembershipDto,
      include: {
        account: true,
        church: true,
        column: true,
        membershipPositions: true,
      },
    });

    return {
      message: 'Membership created successfully',
      data: membership,
    };
  }

  async findAll(query: MembershipListQueryDto): Promise<{
    message: string;
    data: any[];
    total: number;
  }> {
    const { churchId, columnId, skip, take } = query ?? ({} as any);
    const where: any = {};

    if (churchId) {
      where.churchId = churchId;
    }
    if (columnId) {
      where.columnId = columnId;
    }

    const [total, memberships] = await (this.prisma as any).$transaction([
      this.prisma.membership.count({ where }),
      this.prisma.membership.findMany({
        where,
        take,
        skip,
        orderBy: { id: 'desc' },
        include: {
          account: true,
          church: true,
          column: true,
          membershipPositions: true,
        },
      }),
    ]);
    return {
      message: 'Memberships retrieved successfully',
      data: memberships,
      total,
    } as any;
  }

  async findOne(id: number): Promise<{ message: string; data: any }> {
    const membership = await (this.prisma as any).membership.findUniqueOrThrow({
      where: { id },
      include: {
        account: true,
        church: true,
        column: true,
        membershipPositions: true,
      },
    });

    return {
      message: 'Membership retrieved successfully',
      data: membership,
    };
  }

  async update(
    id: number,
    updateMembershipDto: any,
  ): Promise<{ message: string; data: any }> {
    if (updateMembershipDto?.columnId != null) {
      const column = await (this.prisma as any).column.findUnique({
        where: { id: updateMembershipDto.columnId },
        select: { id: true, churchId: true },
      });
      if (!column) {
        throw new BadRequestException('columnId does not exist');
      }
      // If churchId not provided, derive from column; else validate match
      if (updateMembershipDto?.churchId == null) {
        updateMembershipDto.churchId = column.churchId;
      } else if (column.churchId !== updateMembershipDto.churchId) {
        throw new BadRequestException('columnId belongs to a different church');
      }
    }

    const membership = await (this.prisma as any).membership.update({
      where: { id },
      data: updateMembershipDto,
      include: {
        account: true,
        church: true,
        column: true,
        membershipPositions: true,
      },
    });

    return {
      message: 'Membership updated successfully',
      data: membership,
    };
  }

  async remove(id: number): Promise<{ message: string }> {
    await this.findOne(id);

    await (this.prisma as any).membership.delete({
      where: { id },
    });

    return {
      message: 'Membership deleted successfully',
    };
  }
}
