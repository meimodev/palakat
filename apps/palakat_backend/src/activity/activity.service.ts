import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  Logger,
} from '@nestjs/common';
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

  async findAll(query: ActivityListQueryDto, user?: any) {
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

    const isClientToken = Boolean(user?.clientId);
    const isSuperAdmin = user?.role === 'SUPER_ADMIN';
    let requesterMembership: {
      id: number;
      churchId: number;
      columnId: number | null;
    } | null = null;

    if (!isClientToken) {
      const userId = user?.userId;
      if (!userId) {
        throw new BadRequestException('Invalid user');
      }

      requesterMembership = await (this.prisma as any).membership.findUnique({
        where: { accountId: userId },
        select: {
          id: true,
          churchId: true,
          columnId: true,
        },
      });

      if (!requesterMembership) {
        throw new BadRequestException(
          'User does not have a membership. Cannot access activities.',
        );
      }

      if (
        churchId !== undefined &&
        churchId !== null &&
        churchId !== requesterMembership.churchId
      ) {
        throw new ForbiddenException(
          'You are not authorized to access activities for this church',
        );
      }
    }

    const where: any = {};

    const parseDateFilter = (
      value: unknown,
      field: 'startDate' | 'endDate',
    ): Date | undefined => {
      if (value === undefined || value === null || value === '') {
        return undefined;
      }

      if (value instanceof Date) {
        if (Number.isNaN(value.getTime())) {
          throw new BadRequestException(`${field} is not a valid date`);
        }
        return value;
      }

      if (typeof value === 'string') {
        const trimmed = value.trim();
        const hasTimezone =
          trimmed.endsWith('Z') ||
          /[+-]\d{2}:\d{2}$/.test(trimmed) ||
          /[+-]\d{4}$/.test(trimmed);

        const date = new Date(hasTimezone ? trimmed : `${trimmed}Z`);
        if (Number.isNaN(date.getTime())) {
          throw new BadRequestException(`${field} is not a valid ISO date`);
        }
        return date;
      }

      const date = new Date(value as any);
      if (Number.isNaN(date.getTime())) {
        throw new BadRequestException(`${field} is not a valid date`);
      }
      return date;
    };

    const parsedStartDate = parseDateFilter(startDate as any, 'startDate');
    const parsedEndDate = parseDateFilter(endDate as any, 'endDate');

    if (parsedStartDate && parsedEndDate && parsedStartDate > parsedEndDate) {
      throw new BadRequestException(
        'startDate must be before or equal to endDate',
      );
    }

    // Only filter by membershipId if provided
    if (membershipId !== undefined && membershipId !== null) {
      where.supervisorId = membershipId;
    }

    // Only filter by churchId or columnId if provided
    const effectiveChurchId =
      churchId ?? (!isClientToken ? requesterMembership?.churchId : undefined);
    if (effectiveChurchId !== undefined && effectiveChurchId !== null) {
      where.supervisor = {
        ...(where.supervisor ?? {}),
        churchId: effectiveChurchId,
      };
    }

    if (columnId !== undefined && columnId !== null) {
      where.columnId = columnId;
    }

    if (!isClientToken && requesterMembership && !isSuperAdmin) {
      const allowedAudience: any[] = [{ columnId: null }];
      if (requesterMembership.columnId !== null) {
        allowedAudience.push({ columnId: requesterMembership.columnId });
      }
      where.AND = [...(where.AND ?? []), { OR: allowedAudience }];
    }

    if (parsedStartDate || parsedEndDate) {
      where.date = {};
      if (parsedStartDate) {
        where.date.gte = parsedStartDate;
      }
      if (parsedEndDate) {
        where.date.lte = parsedEndDate;
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
          file: true,
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
        file: true,
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
    user?: any,
  ): Promise<{ message: string; data: any }> {
    const {
      location: locationDto,
      supervisorId: supervisorIdFromDto,
      reminder,
      finance,
      publishToColumnOnly,
      fileId,
      ...activityData
    } = createActivityDto;

    const isClientToken = Boolean(user?.clientId);
    let effectiveSupervisorId: number | undefined;
    let membership: {
      id: number;
      churchId: number | null;
      columnId: number | null;
    } | null = null;

    if (!isClientToken) {
      const userId = user?.userId;
      if (!userId) {
        throw new BadRequestException('Invalid user');
      }

      membership = await (this.prisma as any).membership.findUnique({
        where: { accountId: userId },
        select: {
          id: true,
          churchId: true,
          columnId: true,
        },
      });

      if (!membership) {
        throw new BadRequestException(
          'User does not have a membership. Cannot create activity.',
        );
      }

      effectiveSupervisorId = membership.id;
    } else {
      if (supervisorIdFromDto == null) {
        throw new BadRequestException('supervisorId is required');
      }
      effectiveSupervisorId = supervisorIdFromDto;
    }

    if (!membership) {
      // Validate that the membership exists and get church ID
      membership = await (this.prisma as any).membership.findUnique({
        where: { id: effectiveSupervisorId },
        select: {
          id: true,
          churchId: true,
          columnId: true,
        },
      });
    }

    if (!membership) {
      throw new NotFoundException(
        `Membership with ID ${effectiveSupervisorId} not found`,
      );
    }

    if (!membership.churchId) {
      throw new NotFoundException(
        `Membership with ID ${effectiveSupervisorId} is not associated with a church`,
      );
    }

    if (fileId !== undefined && fileId !== null) {
      if (activityData.activityType !== 'ANNOUNCEMENT') {
        throw new BadRequestException(
          'fileId is only supported for announcements',
        );
      }

      const file = await (this.prisma as any).fileManager.findUnique({
        where: { id: fileId },
        select: { id: true, churchId: true },
      });

      if (!file) {
        throw new NotFoundException('File not found');
      }

      if (file.churchId !== membership.churchId) {
        throw new BadRequestException('Invalid church context');
      }
    }

    // Build the activity create data
    const createData: any = {
      ...activityData,
      supervisor: {
        connect: { id: effectiveSupervisorId },
      },
      reminder: reminder ?? null,
    };

    if (fileId !== undefined && fileId !== null) {
      createData.file = { connect: { id: fileId } };
    }

    if (publishToColumnOnly === true) {
      if (!membership.columnId) {
        throw new BadRequestException(
          'Cannot publish to column only: supervisor is not assigned to a column',
        );
      }
      createData.column = {
        connect: {
          id: membership.columnId,
        },
      };
    }

    const locationName = locationDto?.name;
    const locationLatitude = locationDto?.latitude;
    const locationLongitude = locationDto?.longitude;

    const hasCoordinates =
      locationLatitude !== undefined &&
      locationLongitude !== undefined &&
      locationLatitude !== null &&
      locationLongitude !== null;

    const hasLocationName =
      locationName !== undefined &&
      locationName !== null &&
      locationName.trim().length > 0;

    // If location name/coordinates are provided, create a nested location
    if (hasCoordinates || hasLocationName) {
      createData.location = {
        create: {
          name: locationName ?? '',
          latitude: hasCoordinates ? locationLatitude : null,
          longitude: hasCoordinates ? locationLongitude : null,
        },
      };
    }

    // Resolve approvers based on approval rules
    // Include financial data if provided for rule matching
    const approverResolution = await this.approverResolver.resolveApprovers({
      churchId: membership.churchId,
      activityType: activityData.activityType,
      supervisorId: effectiveSupervisorId,
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
                church: true,
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
            file: true,
          },
        });
      },
    );

    // Send notifications after activity creation (non-blocking)
    // **Validates: Requirements 8.3**
    if (activity) {
      this.notifyActivityCreated(activity, membership.churchId).catch(
        (error) => {
          this.logger.error(
            `Failed to send activity creation notifications: ${error.message}`,
            error.stack,
          );
        },
      );
    } else {
      this.logger.warn(
        'Activity was null after creation, skipping notifications',
      );
    }

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
        columnId: activity.columnId ?? null,
        supervisorId: activity.supervisorId,
        supervisor: {
          id: activity.supervisor.id,
          churchId: churchId,
        },
        approvers: (activity.approvers || []).map((approver: any) => ({
          id: approver.id,
          membershipId: approver.membershipId,
          membership: {
            id: approver.membership?.id ?? approver.membershipId,
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
      location: locationDto,
      supervisorId,
      publishToColumnOnly,
      fileId,
      ...updateData
    } = updateActivityDto;

    const locationName = locationDto?.name;
    const locationLatitude = locationDto?.latitude;
    const locationLongitude = locationDto?.longitude;

    // Build the update data
    const data: any = { ...updateData };

    if ((updateActivityDto as any).fileId === null) {
      data.file = { disconnect: true };
    } else if (fileId !== undefined && fileId !== null) {
      const file = await (this.prisma as any).fileManager.findUnique({
        where: { id: fileId },
        select: { id: true, churchId: true },
      });

      if (!file) {
        throw new NotFoundException('File not found');
      }

      const activity = await (this.prisma as any).activity.findUnique({
        where: { id },
        select: { supervisor: { select: { churchId: true } } },
      });

      const activityChurchId = activity?.supervisor?.churchId;
      if (!activityChurchId) {
        throw new NotFoundException(`Activity with ID ${id} not found`);
      }

      if (file.churchId !== activityChurchId) {
        throw new BadRequestException('Invalid church context');
      }

      data.file = { connect: { id: fileId } };
    }

    // Handle supervisor update if provided
    if (supervisorId !== undefined) {
      data.supervisor = {
        connect: { id: supervisorId },
      };
    }

    if (publishToColumnOnly !== undefined) {
      const effectiveSupervisorId =
        supervisorId ??
        (
          await (this.prisma as any).activity.findUnique({
            where: { id },
            select: { supervisorId: true },
          })
        )?.supervisorId;

      if (!effectiveSupervisorId) {
        throw new NotFoundException(`Activity with ID ${id} not found`);
      }

      if (publishToColumnOnly === false) {
        data.columnId = null;
      } else {
        const supervisorMembership = await (
          this.prisma as any
        ).membership.findUnique({
          where: { id: effectiveSupervisorId },
          select: { columnId: true },
        });

        if (!supervisorMembership?.columnId) {
          throw new BadRequestException(
            'Cannot publish to column only: supervisor is not assigned to a column',
          );
        }
        data.columnId = supervisorMembership.columnId;
      }
    }

    if ((updateActivityDto as any).location === null) {
      data.location = { disconnect: true };
    }

    if (
      data.location === undefined &&
      locationName !== undefined &&
      (locationLatitude === undefined || locationLatitude === null) &&
      (locationLongitude === undefined || locationLongitude === null)
    ) {
      const existing = await (this.prisma as any).activity.findUnique({
        where: { id },
        select: { locationId: true },
      });

      if (existing?.locationId) {
        data.location = {
          update: {
            name: locationName || '',
            ...(locationLatitude === null ? { latitude: null } : {}),
            ...(locationLongitude === null ? { longitude: null } : {}),
          },
        };
      } else if (locationName !== null) {
        data.location = {
          create: {
            name: locationName || '',
            latitude: locationLatitude ?? null,
            longitude: locationLongitude ?? null,
          },
        };
      }
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
            name: locationName ?? '',
            latitude: locationLatitude,
            longitude: locationLongitude,
          },
          update: {
            ...(locationName !== undefined ? { name: locationName || '' } : {}),
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
        file: true,
      },
    });
    return {
      message: 'Activity updated successfully',
      data: activity,
    };
  }
}
