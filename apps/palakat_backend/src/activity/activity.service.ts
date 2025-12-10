import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { ActivityListQueryDto } from './dto/activity-list.dto';
import { CreateActivityDto } from './dto/create-activity.dto';
import { UpdateActivityDto } from './dto/update-activity.dto';
import { ApproverResolverService } from './approver-resolver.service';
import { NotificationService } from '../notification/notification.service';

/**
 * Service for managing church activities.
 *
 * This service handles:
 * - CRUD operations for activities
 * - Approver resolution based on approval rules
 * - Notification sending when activities are created
 *
 * **Validates: Requirements 8.3**
 */
@Injectable()
export class ActivitiesService {
  private readonly logger = new Logger(ActivitiesService.name);

  constructor(
    private prisma: PrismaService,
    private approverResolver: ApproverResolverService,
    private notificationService: NotificationService,
  ) {}

  async findAll(query: ActivityListQueryDto) {
    const {
      membershipId,
      churchId,
      columnId,
      startDate,
      endDate,
      activityType,
      search,
      skip,
      take,
      sortBy = 'date',
      sortOrder = 'desc',
      hasExpense,
      hasRevenue,
    } = query;

    const where: any = {};

    // Only filter by membershipId if provided
    if (membershipId !== undefined && membershipId !== null) {
      where.supervisorId = membershipId;
    }

    // Only filter by churchId or columnId if provided
    if (
      (churchId !== undefined && churchId !== null) ||
      (columnId !== undefined && columnId !== null)
    ) {
      where.supervisor = {};
      if (churchId !== undefined && churchId !== null) {
        where.supervisor.churchId = churchId;
      }
      if (columnId !== undefined && columnId !== null) {
        where.supervisor.columnId = columnId;
      }
    }

    if (startDate || endDate) {
      where.date = {};
      if (startDate) {
        where.date.gte = startDate;
      }
      if (endDate) {
        where.date.lte = endDate;
      }
    }

    if (activityType) {
      where.activityType = activityType;
    }

    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    // hasExpense filter: filter activities by expense record presence
    // For one-to-one relations, use 'is' and 'isNot' operators
    if (hasExpense === true) {
      where.expense = { isNot: null };
    } else if (hasExpense === false) {
      where.expense = { is: null };
    }

    // hasRevenue filter: filter activities by revenue record presence
    if (hasRevenue === true) {
      where.revenue = { isNot: null };
    } else if (hasRevenue === false) {
      where.revenue = { is: null };
    }

    const [total, activities] = await (this.prisma as any).$transaction([
      (this.prisma as any).activity.count({ where }),
      (this.prisma as any).activity.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },

        include: {
          supervisor: {
            select: {
              account: {
                select: {
                  name: true,
                  phone: true,
                  dob: true,
                },
              },
            },
          },
          approvers: {
            select: {
              id: true,
              membershipId: true,
              status: true,
              createdAt: true,
              updatedAt: true,
              membership: {
                select: {
                  id: true,
                  account: {
                    select: {
                      id: true,
                      name: true,
                      phone: true,
                      dob: true,
                    },
                  },
                },
              },
            },
          },
          revenue: {
            select: {
              id: true,
            },
          },
          expense: {
            select: {
              id: true,
            },
          },
        },
      }),
    ]);

    // Transform activities to include hasRevenue/hasExpense flags
    const transformedActivities = activities.map((activity: any) => {
      const { revenue, expense, ...rest } = activity;
      return {
        ...rest,
        hasRevenue: revenue !== null,
        hasExpense: expense !== null,
      };
    });

    // Track which fields matched the search
    let searchInfo = '';
    if (search && activities.length > 0) {
      const matchedFields = new Set<string>();
      activities.forEach((activity: any) => {
        if (activity.title?.toLowerCase().includes(search.toLowerCase())) {
          matchedFields.add('title');
        }
        if (
          activity.description?.toLowerCase().includes(search.toLowerCase())
        ) {
          matchedFields.add('description');
        }
      });
      if (matchedFields.size > 0) {
        searchInfo = ` (matched in: ${Array.from(matchedFields).join(', ')})`;
      }
    }

    return {
      message: `Activities retrieved successfully${searchInfo}`,
      data: transformedActivities,
      total,
    };
  }

  async findOne(id: number) {
    const activity = await (this.prisma as any).activity.findUniqueOrThrow({
      where: { id },
      include: {
        supervisor: {
          include: {
            membershipPositions: true,
            account: {
              select: {
                id: true,
                name: true,
                phone: true,
                dob: true,
              },
            },
          },
        },
        location: true,
        approvers: {
          include: {
            membership: {
              include: {
                membershipPositions: true,
                account: {
                  select: {
                    id: true,
                    name: true,
                    phone: true,
                    dob: true,
                  },
                },
              },
            },
          },
        },
        revenue: {
          select: {
            id: true,
            amount: true,
            accountNumber: true,
            paymentMethod: true,
            financialAccountNumber: {
              select: {
                accountNumber: true,
                description: true,
              },
            },
          },
        },
        expense: {
          select: {
            id: true,
            amount: true,
            accountNumber: true,
            paymentMethod: true,
            financialAccountNumber: {
              select: {
                accountNumber: true,
                description: true,
              },
            },
          },
        },
      },
    });

    // Transform to include hasRevenue/hasExpense flags and financial data
    const { revenue, expense, ...rest } = activity;
    const transformedActivity = {
      ...rest,
      hasRevenue: revenue !== null,
      hasExpense: expense !== null,
      revenue: revenue,
      expense: expense,
    };

    return {
      message: 'Activity retrieved successfully',
      data: transformedActivity,
    };
  }

  async remove(id: number) {
    await (this.prisma as any).activity.delete({
      where: { id },
    });
    return {
      message: 'Activity deleted successfully',
    };
  }

  async create(
    createActivityDto: CreateActivityDto,
  ): Promise<{ message: string; data: any }> {
    const {
      locationName,
      locationLatitude,
      locationLongitude,
      supervisorId,
      reminder,
      finance,
      ...activityData
    } = createActivityDto;

    // Validate that the membership exists and get church ID
    const membership = await (this.prisma as any).membership.findUnique({
      where: { id: supervisorId },
      select: {
        id: true,
        churchId: true,
      },
    });

    if (!membership) {
      throw new NotFoundException(
        `Membership with ID ${supervisorId} not found`,
      );
    }

    if (!membership.churchId) {
      throw new NotFoundException(
        `Membership with ID ${supervisorId} is not associated with a church`,
      );
    }

    // Build the activity create data
    const createData: any = {
      ...activityData,
      supervisor: {
        connect: { id: supervisorId },
      },
      reminder: reminder ?? null,
    };

    // If location data is provided, create a nested location
    if (
      locationLatitude !== undefined &&
      locationLongitude !== undefined &&
      locationLatitude !== null &&
      locationLongitude !== null
    ) {
      createData.location = {
        create: {
          name: locationName || '',
          latitude: locationLatitude,
          longitude: locationLongitude,
        },
      };
    }

    // Resolve approvers based on approval rules
    // Include financial data if provided for rule matching
    const approverResolution = await this.approverResolver.resolveApprovers({
      churchId: membership.churchId,
      activityType: activityData.activityType,
      supervisorId: supervisorId,
      financialAccountNumberId: finance?.financialAccountNumberId,
      financialType: finance?.type as 'REVENUE' | 'EXPENSE' | undefined,
    });

    // Use a transaction to create activity, link finance records, and create approvers
    const activity = await (this.prisma as any).$transaction(
      async (tx: any) => {
        // Create the activity
        const newActivity = await tx.activity.create({
          data: createData,
          include: {
            supervisor: {
              include: {
                account: {
                  select: {
                    id: true,
                    name: true,
                    phone: true,
                    dob: true,
                  },
                },
              },
            },
            location: true,
          },
        });

        // Create finance record (revenue or expense) alongside activity if provided
        if (finance) {
          const financeData = {
            accountNumber: finance.accountNumber,
            amount: finance.amount,
            paymentMethod: finance.paymentMethod,
            churchId: membership.churchId,
            activityId: newActivity.id,
            financialAccountNumberId: finance.financialAccountNumberId ?? null,
          };

          if (finance.type === 'REVENUE') {
            await tx.revenue.create({ data: financeData });
          } else {
            await tx.expense.create({ data: financeData });
          }
        }

        // Create approver records if any were resolved
        if (approverResolution.membershipIds.length > 0) {
          await tx.approver.createMany({
            data: approverResolution.membershipIds.map(
              (membershipId: number) => ({
                activityId: newActivity.id,
                membershipId: membershipId,
              }),
            ),
          });
        }

        // Fetch the activity with approvers and linked finance records included
        return tx.activity.findUnique({
          where: { id: newActivity.id },
          include: {
            supervisor: {
              include: {
                churchId: true,
                account: {
                  select: {
                    id: true,
                    name: true,
                    phone: true,
                    dob: true,
                  },
                },
              },
            },
            location: true,
            approvers: {
              include: {
                membership: {
                  include: {
                    account: {
                      select: {
                        id: true,
                        name: true,
                        phone: true,
                        dob: true,
                      },
                    },
                  },
                },
              },
            },
            revenue: {
              select: {
                id: true,
                amount: true,
                accountNumber: true,
                paymentMethod: true,
              },
            },
            expense: {
              select: {
                id: true,
                amount: true,
                accountNumber: true,
                paymentMethod: true,
              },
            },
          },
        });
      },
    );

    // Send notifications after activity creation (non-blocking)
    // **Validates: Requirements 8.3**
    this.notifyActivityCreated(activity, membership.churchId).catch((error) => {
      this.logger.error(
        `Failed to send activity creation notifications: ${error.message}`,
        error.stack,
      );
    });

    return {
      message: 'Activity created successfully',
      data: activity,
    };
  }

  /**
   * Helper method to send activity creation notifications.
   * This is called after the activity transaction completes.
   *
   * @param activity - The created activity with relations
   * @param churchId - The church ID for the activity
   *
   * **Validates: Requirements 8.3**
   */
  private async notifyActivityCreated(
    activity: any,
    churchId: number,
  ): Promise<void> {
    try {
      // Build the activity data structure expected by NotificationService
      const activityWithRelations = {
        id: activity.id,
        title: activity.title,
        bipra: activity.bipra,
        activityType: activity.activityType,
        date: activity.date,
        supervisorId: activity.supervisorId,
        supervisor: {
          id: activity.supervisor.id,
          churchId: churchId,
        },
        approvers: activity.approvers.map((approver: any) => ({
          id: approver.id,
          membershipId: approver.membershipId,
          membership: {
            id: approver.membership.id,
          },
        })),
      };

      await this.notificationService.notifyActivityCreated(
        activityWithRelations,
      );

      this.logger.log(
        `Activity creation notifications sent for activity ${activity.id}`,
      );
    } catch (error) {
      // Log error but don't throw - notifications should not block activity creation
      this.logger.error(
        `Failed to send activity creation notifications for activity ${activity.id}: ${error.message}`,
        error.stack,
      );
    }
  }

  async update(
    id: number,
    updateActivityDto: UpdateActivityDto,
  ): Promise<{ message: string; data: any }> {
    const {
      locationName,
      locationLatitude,
      locationLongitude,
      supervisorId,
      ...updateData
    } = updateActivityDto;

    // Build the update data
    const data: any = { ...updateData };

    // Handle supervisor update if provided
    if (supervisorId !== undefined) {
      data.supervisor = {
        connect: { id: supervisorId },
      };
    }

    // Handle location update if coordinates are provided
    if (
      locationLatitude !== undefined &&
      locationLongitude !== undefined &&
      locationLatitude !== null &&
      locationLongitude !== null
    ) {
      data.location = {
        upsert: {
          create: {
            name: locationName || '',
            latitude: locationLatitude,
            longitude: locationLongitude,
          },
          update: {
            name: locationName || '',
            latitude: locationLatitude,
            longitude: locationLongitude,
          },
        },
      };
    }

    const activity = await (this.prisma as any).activity.update({
      where: { id },
      data,
      include: {
        supervisor: {
          include: {
            account: {
              select: {
                id: true,
                name: true,
                phone: true,
                dob: true,
              },
            },
          },
        },
        location: true,
        approvers: true,
      },
    });
    return {
      message: 'Activity updated successfully',
      data: activity,
    };
  }
}
