import { Injectable } from '@nestjs/common';
import { Prisma } from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import { ColumnListQueryDto } from './dto/column-list.dto';

@Injectable()
export class ColumnService {
  constructor(private readonly prismaService: PrismaService) {}

  async getColumns(query: ColumnListQueryDto) {
    const { churchId, skip, take, sortBy = 'name', sortOrder = 'asc' } = query;

    const where: Prisma.ColumnWhereInput = {};
    if (churchId) where.churchId = churchId;

    const [total, columns] = await this.prismaService.$transaction([
      this.prismaService.column.count({ where }),
      this.prismaService.column.findMany({
        where,
        skip,
        take,
        orderBy: { [sortBy]: sortOrder },
      }),
    ]);

    const data = columns.map((column: any) => {
      const { _count, ...rest } = column;
      return {
        ...rest,
        memberCount: _count?.memberships ?? 0,
      };
    });

    return {
      message: 'Columns fetched successfully',
      data,
      total,
    };
  }

  async findOne(id: number) {
    const column = await this.prismaService.column.findUniqueOrThrow({
      where: { id },
      include: {
        memberships: {
          select: {
            id: true,
            account: {
              select: {
                name: true,
              },
            },
          },
        },
      },
    });

    const { memberships, ...rest } = column;
    const membershipsData = memberships.map((m) => {
      return {
        membershipId: m.id,
        name: m.account.name,
      };
    });

    return {
      message: 'Column fetched successfully',
      data: {
        ...rest,
        memberships: membershipsData,
      },
    };
  }

  async remove(id: number): Promise<{ message: string }> {
    await this.prismaService.membership.updateMany({
      where: { columnId: id },
      data: { columnId: null },
    });

    await this.prismaService.column.delete({
      where: { id },
    });
    return {
      message: 'Column deleted successfully',
    };
  }

  async create(createColumn: Prisma.ColumnCreateInput) {
    const column = await this.prismaService.column.create({
      data: createColumn,
      include: {
        church: true,
      },
    });
    return {
      message: 'Column created successfully',
      data: column,
    };
  }

  async update(id: number, updateColumn: Prisma.ColumnUpdateInput) {
    const column = await this.prismaService.column.update({
      where: { id },
      data: updateColumn,
      include: { church: true },
    });
    return {
      message: 'column updated successfully',
      data: column,
    };
  }
}
