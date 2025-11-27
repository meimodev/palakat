import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { ActivityListQueryDto } from './dto/activity-list.dto';

@Injectable()
export class ActivitiesService {
  constructor(private prisma: PrismaService) {}

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
      where.createdAt = {};
      if (startDate) {
        where.createdAt.gte = startDate;
      }
      if (endDate) {
        where.createdAt.lte = endDate;
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

    const [total, activities] = await (this.prisma as any).$transaction([
      (this.prisma as any).activity.count({ where }),
      (this.prisma as any).activity.findMany({
        where,
        take,
        skip,
        orderBy: { createdAt: 'desc' },

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
              status: true,
              createdAt: true,
              updatedAt: true,
              membership: {
                select: {
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
        },
      }),
    ]);

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
      data: activities,
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
      },
    });
    return {
      message: 'Activity retrieved successfully',
      data: activity,
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
    createActivityDto: any,
  ): Promise<{ message: string; data: any }> {
    const {
      locationName,
      locationLatitude,
      locationLongitude,
      ...activityData
    } = createActivityDto;

    // Build the activity create data
    const createData: any = {
      ...activityData,
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

    const activity = await (this.prisma as any).activity.create({
      data: createData,
      include: {
        supervisor: true,
        location: true,
      },
    });
    return {
      message: 'Activity created successfully',
      data: activity,
    };
  }

  async update(
    id: number,
    updateActivityDto: any,
  ): Promise<{ message: string; data: any }> {
    const activity = await (this.prisma as any).activity.update({
      where: { id },
      data: updateActivityDto,
    });
    return {
      message: 'Activity updated successfully',
      data: activity,
    };
  }
}
