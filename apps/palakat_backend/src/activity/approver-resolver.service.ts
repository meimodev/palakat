import { Injectable } from '@nestjs/common';
import { ActivityType, FinancialType } from '../generated/prisma/client';
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
  /** Optional financial account number ID if activity has financial data */
  financialAccountNumberId?: number;
  /** Optional financial type (REVENUE or EXPENSE) */
  financialType?: FinancialType;
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
   * Algorithm:
   * 1. Query approval rules matching activityType and churchId where active = true
   * 2. If no type-specific rules found, query rules where activityType IS NULL
   * 3. If financial data exists, additionally query rules matching financialAccountNumberId or financialType
   * 4. Collect all MembershipPosition IDs from matched rules
   * 5. Deduplicate position IDs
   * 6. Find all Membership records that have these positions in the same church
   * 7. Include all memberships (including supervisor if they hold a matching position - self-approval scenario)
   * 8. Return unique membership IDs for approver creation
   */
  async resolveApprovers(
    input: ApproverResolutionInput,
  ): Promise<ApproverResolutionResult> {
    const { churchId, activityType, financialAccountNumberId, financialType } =
      input;

    const matchedRuleIds: number[] = [];
    const positionIds = new Set<number>();

    // Step 1: Find approval rules matching the activity type
    let activityTypeRules = await this.prisma.approvalRule.findMany({
      where: {
        churchId,
        activityType,
        active: true,
      },
      include: {
        positions: {
          select: {
            id: true,
          },
        },
      },
    });

    // Step 2: If no type-specific rules found, fall back to generic rules (activityType IS NULL)
    if (activityTypeRules.length === 0) {
      activityTypeRules = await this.prisma.approvalRule.findMany({
        where: {
          churchId,
          activityType: null,
          financialType: null, // Generic rules should not have financial type either
          active: true,
        },
        include: {
          positions: {
            select: {
              id: true,
            },
          },
        },
      });
    }

    // Collect positions from activity type rules
    for (const rule of activityTypeRules) {
      matchedRuleIds.push(rule.id);
      for (const position of rule.positions) {
        positionIds.add(position.id);
      }
    }

    // Step 3: If financial data exists, find additional financial rules
    if (financialType) {
      // First, try to find rules that match the specific financial account number
      if (financialAccountNumberId) {
        const accountSpecificRules = await this.prisma.approvalRule.findMany({
          where: {
            churchId,
            financialAccountNumberId,
            active: true,
          },
          include: {
            positions: {
              select: {
                id: true,
              },
            },
          },
        });

        for (const rule of accountSpecificRules) {
          if (!matchedRuleIds.includes(rule.id)) {
            matchedRuleIds.push(rule.id);
          }
          for (const position of rule.positions) {
            positionIds.add(position.id);
          }
        }
      }

      // Also find rules that match the financial type but don't have a specific account number
      const financialTypeRules = await this.prisma.approvalRule.findMany({
        where: {
          churchId,
          financialType,
          financialAccountNumberId: null, // Only rules without specific account
          active: true,
        },
        include: {
          positions: {
            select: {
              id: true,
            },
          },
        },
      });

      for (const rule of financialTypeRules) {
        if (!matchedRuleIds.includes(rule.id)) {
          matchedRuleIds.push(rule.id);
        }
        for (const position of rule.positions) {
          positionIds.add(position.id);
        }
      }
    }

    // Step 4 & 5: Position IDs are already deduplicated via Set

    // If no positions found, return empty result
    if (positionIds.size === 0) {
      return {
        membershipIds: [],
        matchedRuleIds,
      };
    }

    // Step 6: Find all memberships that hold these positions in the same church
    const positionIdArray = Array.from(positionIds);

    const membershipsWithPositions = await this.prisma.membership.findMany({
      where: {
        churchId,
        membershipPositions: {
          some: {
            id: {
              in: positionIdArray,
            },
          },
        },
      },
      select: {
        id: true,
      },
    });

    // Step 7: Collect unique membership IDs (including supervisor if they match - self-approval)
    const membershipIds = new Set<number>();
    for (const membership of membershipsWithPositions) {
      membershipIds.add(membership.id);
    }

    // Step 8: Return unique membership IDs
    return {
      membershipIds: Array.from(membershipIds),
      matchedRuleIds,
    };
  }
}
