import { Injectable } from '@nestjs/common';
import { ActivityType, Bipra } from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';

/**
 * Input for resolving approvers for an activity
 */
export interface ApproverResolutionInput {
  /** The church ID where the activity belongs */
  churchId: number;
  /** The type of activity (SERVICE, EVENT, ANNOUNCEMENT) */
  activityType: ActivityType;
  /** The supervisor's membership ID */
  supervisorId: number;
  /**
   * Optional bipra category (PKB, WKI, PMD, RMJ, ASM).
   * When provided for SERVICE activities, the resolver first tries to match
   * rules with the same activityType + bipra combination before falling back
   * to activityType-only or generic rules.
   */
  bipra?: Bipra;
}

/**
 * Result of approver resolution
 */
export interface ApproverResolutionResult {
  /** List of membership IDs that should be approvers */
  membershipIds: number[];
  /** List of approval rule IDs that were matched */
  matchedRuleIds: number[];
}

@Injectable()
export class ApproverResolverService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Resolves approvers for an activity based on approval rules.
   *
   * Algorithm (priority order — first match wins):
   * 1. If bipra is provided: rules with (activityType + bipra)
   * 2. Rules with activityType only (bipra IS NULL)
   * 3. Generic rules (activityType IS NULL AND financialType IS NULL)
   */
  async resolveApprovers(
    input: ApproverResolutionInput,
  ): Promise<ApproverResolutionResult> {
    const { churchId, activityType, bipra } = input;

    const positionInclude = {
      positions: {
        select: { id: true },
      },
    };

    // Step 1 – bipra-specific service rules (only when bipra is provided)
    if (bipra) {
      const bipraRules = await this.prisma.approvalRule.findMany({
        where: { churchId, activityType, bipra, active: true },
        include: positionInclude,
      });

      if (bipraRules.length > 0) {
        return this._buildResult(bipraRules, churchId);
      }
    }

    // Step 2 – activityType-only rules (bipra IS NULL)
    const typeRules = await this.prisma.approvalRule.findMany({
      where: { churchId, activityType, bipra: null, active: true },
      include: positionInclude,
    });

    if (typeRules.length > 0) {
      return this._buildResult(typeRules, churchId);
    }

    // Step 3 – generic rules (no activityType, no financialType)
    const genericRules = await this.prisma.approvalRule.findMany({
      where: {
        churchId,
        activityType: null,
        financialType: null,
        active: true,
      },
      include: positionInclude,
    });

    return this._buildResult(genericRules, churchId);
  }

  private async _buildResult(
    rules: Array<{ id: number; positions: { id: number }[] }>,
    churchId: number,
  ): Promise<ApproverResolutionResult> {
    const matchedRuleIds: number[] = [];
    const positionIds = new Set<number>();

    for (const rule of rules) {
      matchedRuleIds.push(rule.id);
      for (const position of rule.positions) {
        positionIds.add(position.id);
      }
    }

    if (positionIds.size === 0) {
      return { membershipIds: [], matchedRuleIds };
    }

    const memberships = await this.prisma.membership.findMany({
      where: {
        churchId,
        membershipPositions: {
          some: { id: { in: Array.from(positionIds) } },
        },
      },
      select: { id: true },
    });

    return {
      membershipIds: memberships.map((m) => m.id),
      matchedRuleIds,
    };
  }
}
