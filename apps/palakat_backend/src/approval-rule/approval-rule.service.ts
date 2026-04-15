import { BadRequestException, Injectable } from '@nestjs/common';
import { Prisma } from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import { ApprovalRuleListQueryDto } from './dto/approval-rule-list.dto';
import { CreateApprovalRuleDto } from './dto/create-approval-rule.dto';
import { UpdateApprovalRuleDto } from './dto/update-approval-rule.dto';

@Injectable()
export class ApprovalRuleService {
  constructor(private readonly prismaService: PrismaService) {}

  private async validatePositionsInChurch(
    positionIds: number[],
    churchId: number,
  ): Promise<void> {
    if (positionIds.length === 0) return;
    const positions = await this.prismaService.membershipPosition.findMany({
      where: { id: { in: positionIds } },
      select: { id: true, churchId: true },
    });
    const mismatched = positions.filter((p) => p.churchId !== churchId);
    if (mismatched.length > 0) {
      throw new BadRequestException(
        `MembershipPosition(s) [${mismatched.map((p) => p.id).join(', ')}] do not belong to church ${churchId}`,
      );
    }
  }

  async getApprovalRules(query: ApprovalRuleListQueryDto) {
    const {
      churchId,
      active,
      search,
      positionId,
      skip,
      take,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

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
        orderBy: { [sortBy]: sortOrder },
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

  async create(createApprovalRuleDto: CreateApprovalRuleDto) {
    const {
      name,
      description,
      active,
      activityType,
      bipra,
      churchId,
      positionIds,
      financialType,
    } = createApprovalRuleDto;

    const dedupedPositionIds = positionIds ? [...new Set(positionIds)] : [];
    await this.validatePositionsInChurch(dedupedPositionIds, churchId);

    const data: Prisma.ApprovalRuleCreateInput = {
      name,
      ...(description !== undefined ? { description } : {}),
      ...(active !== undefined ? { active } : {}),
      ...(activityType !== undefined ? { activityType } : {}),
      ...(bipra !== undefined ? { bipra } : {}),
      ...(financialType !== undefined ? { financialType } : {}),
      church: { connect: { id: churchId } },
      ...(dedupedPositionIds.length > 0
        ? {
            positions: {
              connect: dedupedPositionIds.map((id) => ({ id })),
            },
          }
        : {}),
    };

    const approvalRule = await this.prismaService.approvalRule.create({
      data,
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

  async update(id: number, updateApprovalRuleDto: UpdateApprovalRuleDto) {
    const {
      name,
      description,
      active,
      activityType,
      bipra,
      churchId,
      positionIds,
      financialType,
    } = updateApprovalRuleDto;

    const existing = await this.prismaService.approvalRule.findUniqueOrThrow({
      where: { id },
      select: { churchId: true },
    });
    const resolvedChurchId = churchId ?? existing.churchId;
    const churchChanged =
      churchId !== undefined && churchId !== existing.churchId;

    // When church changes without explicit positionIds, clear stale links
    const effectivePositionIds =
      positionIds !== undefined ? positionIds : churchChanged ? [] : undefined;

    if (effectivePositionIds !== undefined) {
      const dedupedPositionIds = [...new Set(effectivePositionIds)];
      await this.validatePositionsInChurch(
        dedupedPositionIds,
        resolvedChurchId,
      );
    }

    const data: Prisma.ApprovalRuleUpdateInput = {
      ...(name !== undefined ? { name } : {}),
      ...(description !== undefined ? { description } : {}),
      ...(active !== undefined ? { active } : {}),
      ...(activityType !== undefined ? { activityType } : {}),
      ...(bipra !== undefined ? { bipra } : {}),
      ...(financialType !== undefined ? { financialType } : {}),
      ...(churchId !== undefined
        ? { church: { connect: { id: churchId } } }
        : {}),
      ...(effectivePositionIds !== undefined
        ? {
            positions: {
              set: [...new Set(effectivePositionIds)].map((id) => ({ id })),
            },
          }
        : {}),
    };

    const approvalRule = await this.prismaService.approvalRule.update({
      where: { id },
      data,
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
