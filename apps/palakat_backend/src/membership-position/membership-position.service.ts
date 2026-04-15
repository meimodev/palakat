import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '../generated/prisma/client';
import { MembershipPositionListQueryDto } from './dto/membership-position-list.dto';
import {
  CreateMembershipPositionDto,
  UpdateMembershipPositionDto,
} from './dto/membership-position-write.dto';

const RULE_SUMMARY_SELECT = {
  id: true,
  name: true,
  active: true,
  activityType: true,
  financialType: true,
} as const;

@Injectable()
export class MembershipPositionService {
  constructor(private readonly prisma: PrismaService) {}

  private async validateRulesInChurch(
    ruleIds: number[],
    churchId: number,
  ): Promise<void> {
    if (ruleIds.length === 0) return;
    const rules = await this.prisma.approvalRule.findMany({
      where: { id: { in: ruleIds } },
      select: { id: true, churchId: true },
    });
    const mismatched = rules.filter((r) => r.churchId !== churchId);
    if (mismatched.length > 0) {
      throw new BadRequestException(
        `ApprovalRule(s) [${mismatched.map((r) => r.id).join(', ')}] do not belong to church ${churchId}`,
      );
    }
  }

  async create(dto: CreateMembershipPositionDto) {
    const { name, churchId, membershipId, approvalRuleIds } = dto;

    const dedupedRuleIds = approvalRuleIds ? [...new Set(approvalRuleIds)] : [];
    await this.validateRulesInChurch(dedupedRuleIds, churchId);

    const record = await this.prisma.membershipPosition.create({
      data: {
        name,
        church: { connect: { id: churchId } },
        ...(membershipId !== undefined && membershipId !== null
          ? { membership: { connect: { id: membershipId } } }
          : {}),
        ...(dedupedRuleIds.length > 0
          ? { approvalRules: { connect: dedupedRuleIds.map((id) => ({ id })) } }
          : {}),
      },
      include: {
        approvalRules: { select: RULE_SUMMARY_SELECT },
      },
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
        include: {
          approvalRules: { select: RULE_SUMMARY_SELECT },
        },
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
        approvalRules: { select: RULE_SUMMARY_SELECT },
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
    const membershipData = {
      positions: membership?.membershipPositions?.map((p) => p.name) ?? [],
      accountName: membership?.account?.name ?? null,
    } as const;

    return {
      message: 'OK',
      data: { ...item, ...membershipData },
    };
  }

  async update(id: number, dto: UpdateMembershipPositionDto) {
    const { name, churchId, membershipId, approvalRuleIds } = dto;

    const existing = await this.prisma.membershipPosition.findUniqueOrThrow({
      where: { id },
      select: { churchId: true },
    });
    const resolvedChurchId = churchId ?? existing.churchId;
    const churchChanged =
      churchId !== undefined &&
      existing.churchId !== null &&
      churchId !== existing.churchId;

    // When church changes without explicit approvalRuleIds, clear stale links
    const effectiveRuleIds =
      approvalRuleIds !== undefined
        ? approvalRuleIds
        : churchChanged
          ? []
          : undefined;

    if (resolvedChurchId !== null && effectiveRuleIds !== undefined) {
      const dedupedRuleIds = [...new Set(effectiveRuleIds)];
      await this.validateRulesInChurch(dedupedRuleIds, resolvedChurchId);
    }

    const item = await this.prisma.membershipPosition.update({
      where: { id },
      data: {
        ...(name !== undefined ? { name } : {}),
        ...(churchId !== undefined
          ? { church: { connect: { id: churchId } } }
          : {}),
        ...(membershipId !== undefined
          ? membershipId === null
            ? { membership: { disconnect: true } }
            : { membership: { connect: { id: membershipId } } }
          : {}),
        ...(effectiveRuleIds !== undefined
          ? {
              approvalRules: {
                set: [...new Set(effectiveRuleIds)].map((rid) => ({ id: rid })),
              },
            }
          : {}),
      },
      include: {
        approvalRules: { select: RULE_SUMMARY_SELECT },
      },
    });
    return { message: 'OK', data: item };
  }

  async delete(id: number) {
    await this.prisma.membershipPosition.delete({ where: { id } });
    return { message: 'OK' } as const;
  }
}
