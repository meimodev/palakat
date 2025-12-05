import { Injectable, BadRequestException } from '@nestjs/common';
import { FinancialType, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma.service';
import { ApprovalRuleListQueryDto } from './dto/approval-rule-list.dto';
import { CreateApprovalRuleDto } from './dto/create-approval-rule.dto';
import { UpdateApprovalRuleDto } from './dto/update-approval-rule.dto';

@Injectable()
export class ApprovalRuleService {
  constructor(private readonly prismaService: PrismaService) {}

  /**
   * Validates that when a financial type is set, a financial account number must also be provided.
   * @param financialType - The financial type (REVENUE or EXPENSE)
   * @param financialAccountNumberId - The ID of the financial account
   * @throws BadRequestException if financial type is set but no account is provided
   */
  validateFinancialTypeRequiresAccount(
    financialType: FinancialType | null | undefined,
    financialAccountNumberId: number | null | undefined,
  ): void {
    if (financialType && !financialAccountNumberId) {
      throw new BadRequestException(
        'Financial account number is required when financial type is set',
      );
    }
  }

  /**
   * Validates that a financial account number is not already linked to another approval rule.
   * @param financialAccountNumberId - The ID of the financial account to validate
   * @param excludeRuleId - Optional rule ID to exclude from the check (used for updates)
   * @throws BadRequestException if the account is already linked to another rule
   */
  async validateFinancialAccountUniqueness(
    financialAccountNumberId: number,
    excludeRuleId?: number,
  ): Promise<void> {
    const existingRule = await this.prismaService.approvalRule.findFirst({
      where: {
        financialAccountNumberId,
        ...(excludeRuleId !== undefined ? { id: { not: excludeRuleId } } : {}),
      },
      include: {
        financialAccountNumber: {
          select: {
            accountNumber: true,
          },
        },
      },
    });

    if (existingRule) {
      const accountNumber =
        existingRule.financialAccountNumber?.accountNumber ?? 'Unknown';
      throw new BadRequestException(
        `Financial account ${accountNumber} is already linked to approval rule "${existingRule.name}"`,
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
          financialAccountNumber: {
            select: {
              id: true,
              accountNumber: true,
              description: true,
              type: true,
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
          financialAccountNumber: {
            select: {
              id: true,
              accountNumber: true,
              description: true,
              type: true,
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
      churchId,
      positionIds,
      financialAccountNumberId,
      financialType,
      ...rest
    } = createApprovalRuleDto;

    // Validate financial type requires account number
    this.validateFinancialTypeRequiresAccount(
      financialType,
      financialAccountNumberId,
    );

    // Validate financial account uniqueness before creating
    if (financialAccountNumberId) {
      await this.validateFinancialAccountUniqueness(financialAccountNumberId);
    }

    // When a financial account is linked, use its description as the rule name
    let ruleName = rest.name;
    if (financialAccountNumberId) {
      const financialAccount =
        await this.prismaService.financialAccountNumber.findUnique({
          where: { id: financialAccountNumberId },
          select: { description: true },
        });
      if (financialAccount?.description) {
        ruleName = financialAccount.description;
      }
    }

    const data: Prisma.ApprovalRuleCreateInput = {
      ...rest,
      name: ruleName,
      financialType,
      church: { connect: { id: churchId } },
      ...(positionIds && positionIds.length > 0
        ? { positions: { connect: positionIds.map((id) => ({ id })) } }
        : {}),
      ...(financialAccountNumberId
        ? {
            financialAccountNumber: {
              connect: { id: financialAccountNumberId },
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
        financialAccountNumber: {
          select: {
            id: true,
            accountNumber: true,
            description: true,
            type: true,
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
      churchId,
      positionIds,
      financialAccountNumberId,
      financialType,
      ...rest
    } = updateApprovalRuleDto;

    // Get the current rule to check existing values for validation
    const currentRule = await this.prismaService.approvalRule.findUnique({
      where: { id },
      select: {
        financialType: true,
        financialAccountNumberId: true,
      },
    });

    // Determine the effective financial type and account after update
    const effectiveFinancialType =
      financialType !== undefined ? financialType : currentRule?.financialType;
    const effectiveAccountId =
      financialAccountNumberId !== undefined
        ? financialAccountNumberId
        : currentRule?.financialAccountNumberId;

    // Validate financial type requires account number
    this.validateFinancialTypeRequiresAccount(
      effectiveFinancialType,
      effectiveAccountId,
    );

    // Validate financial account uniqueness before updating (exclude current rule)
    if (
      financialAccountNumberId !== undefined &&
      financialAccountNumberId !== null
    ) {
      await this.validateFinancialAccountUniqueness(
        financialAccountNumberId,
        id,
      );
    }

    // When a financial account is linked, use its description as the rule name
    let ruleName = rest.name;
    if (effectiveAccountId) {
      const financialAccount =
        await this.prismaService.financialAccountNumber.findUnique({
          where: { id: effectiveAccountId },
          select: { description: true },
        });
      if (financialAccount?.description) {
        ruleName = financialAccount.description;
      }
    }

    const data: Prisma.ApprovalRuleUpdateInput = {
      ...rest,
      ...(ruleName !== undefined ? { name: ruleName } : {}),
      ...(financialType !== undefined ? { financialType } : {}),
      ...(churchId !== undefined
        ? { church: { connect: { id: churchId } } }
        : {}),
      ...(positionIds !== undefined
        ? { positions: { set: positionIds.map((id) => ({ id })) } }
        : {}),
      ...(financialAccountNumberId !== undefined
        ? financialAccountNumberId === null
          ? { financialAccountNumber: { disconnect: true } }
          : {
              financialAccountNumber: {
                connect: { id: financialAccountNumberId },
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
        financialAccountNumber: {
          select: {
            id: true,
            accountNumber: true,
            description: true,
            type: true,
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
