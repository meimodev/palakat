import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma.service';
import { ApprovalRuleListQueryDto } from './dto/approval-rule-list.dto';

@Injectable()
export class ApprovalRuleService {
  constructor(private readonly prismaService: PrismaService) {}

  async getApprovalRules(query: ApprovalRuleListQueryDto) {
    const { churchId, active, search, positionId, skip, take } = query;

    const where: Prisma.ApprovalRuleWhereInput = {};
    if (churchId) where.churchId = churchId;
    if (active !== undefined) where.active = active === 'true';
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }
    if (positionId) {
      where.positions = {
        some: {
          id: positionId,
        },
      };
    }

    const [total, approvalRules] = await this.prismaService.$transaction([
      this.prismaService.approvalRule.count({ where }),
      this.prismaService.approvalRule.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          church: {
            select: {
              id: true,
              name: true,
            },
          },
          positions: {
            select: {
              id: true,
              name: true,
              churchId: true,
            },
          },
        },
      }),
    ]);

    return {
      message: 'Approval rules fetched successfully',
      data: approvalRules,
      total,
    };
  }

  async findOne(id: number) {
    const approvalRule =
      await this.prismaService.approvalRule.findUniqueOrThrow({
        where: { id },
        include: {
          church: {
            select: {
              id: true,
              name: true,
            },
          },
          positions: {
            select: {
              id: true,
              name: true,
              churchId: true,
            },
          },
        },
      });

    return {
      message: 'Approval rule fetched successfully',
      data: approvalRule,
    };
  }

  async remove(id: number): Promise<{ message: string }> {
    await this.prismaService.approvalRule.delete({
      where: { id },
    });
    return {
      message: 'Approval rule deleted successfully',
    };
  }

  async create(createApprovalRule: Prisma.ApprovalRuleCreateInput) {
    const approvalRule = await this.prismaService.approvalRule.create({
      data: createApprovalRule,
      include: {
        church: {
          select: {
            id: true,
            name: true,
          },
        },
        positions: {
          select: {
            id: true,
            name: true,
            churchId: true,
          },
        },
      },
    });
    return {
      message: 'Approval rule created successfully',
      data: approvalRule,
    };
  }

  async update(id: number, updateApprovalRule: Prisma.ApprovalRuleUpdateInput) {
    const approvalRule = await this.prismaService.approvalRule.update({
      where: { id },
      data: updateApprovalRule,
      include: {
        church: {
          select: {
            id: true,
            name: true,
          },
        },
        positions: {
          select: {
            id: true,
            name: true,
            churchId: true,
          },
        },
      },
    });
    return {
      message: 'Approval rule updated successfully',
      data: approvalRule,
    };
  }
}
