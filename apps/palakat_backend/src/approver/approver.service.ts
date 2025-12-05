import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateApproverDto } from './dto/create-approver.dto';
import { UpdateApproverDto } from './dto/update-approver.dto';
import { ApproverListQueryDto } from './dto/approver-list.dto';

@Injectable()
export class ApproverService {
  constructor(private prisma: PrismaService) {}

  async create(
    createApproverDto: CreateApproverDto,
  ): Promise<{ message: string; data: any }> {
    const { membershipId, activityId } = createApproverDto;

    // Validate membership exists
    const membership = await (this.prisma as any).membership.findUnique({
      where: { id: membershipId },
    });
    if (!membership) {
      throw new NotFoundException(
        `Membership with ID ${membershipId} not found`,
      );
    }

    // Validate activity exists
    const activity = await (this.prisma as any).activity.findUnique({
      where: { id: activityId },
    });
    if (!activity) {
      throw new NotFoundException(`Activity with ID ${activityId} not found`);
    }

    // Check for duplicate approver
    const existingApprover = await (this.prisma as any).approver.findUnique({
      where: {
        activityId_membershipId: {
          activityId,
          membershipId,
        },
      },
    });
    if (existingApprover) {
      throw new BadRequestException(
        'Approver already exists for this activity and membership',
      );
    }

    // Create approver with UNCONFIRMED status (default from schema)
    const approver = await (this.prisma as any).approver.create({
      data: {
        membershipId,
        activityId,
      },
      include: {
        activity: {
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
          },
        },
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
    });

    return {
      message: 'Approver created successfully',
      data: approver,
    };
  }

  async findAll(query: ApproverListQueryDto): Promise<{
    message: string;
    data: any[];
    total: number;
  }> {
    const {
      membershipId,
      activityId,
      status,
      skip,
      take,
      sortBy = 'id',
      sortOrder = 'desc',
    } = query;

    const where: any = {};

    if (membershipId !== undefined && membershipId !== null) {
      where.membershipId = membershipId;
    }

    if (activityId !== undefined && activityId !== null) {
      where.activityId = activityId;
    }

    if (status !== undefined && status !== null) {
      where.status = status;
    }

    const [total, approvers] = await (this.prisma as any).$transaction([
      (this.prisma as any).approver.count({ where }),
      (this.prisma as any).approver.findMany({
        where,
        skip,
        take,
        orderBy: { [sortBy]: sortOrder },
        include: {
          activity: {
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
            },
          },
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
      }),
    ]);

    return {
      message: 'Approvers retrieved successfully',
      data: approvers,
      total,
    };
  }

  async findOne(id: number): Promise<{ message: string; data: any }> {
    const approver = await (this.prisma as any).approver.findUniqueOrThrow({
      where: { id },
      include: {
        activity: {
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
          },
        },
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
    });

    return {
      message: 'Approver retrieved successfully',
      data: approver,
    };
  }

  async update(
    id: number,
    updateApproverDto: UpdateApproverDto,
  ): Promise<{ message: string; data: any }> {
    const approver = await (this.prisma as any).approver.update({
      where: { id },
      data: {
        status: updateApproverDto.status,
      },
      include: {
        activity: {
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
          },
        },
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
    });

    return {
      message: 'Approver updated successfully',
      data: approver,
    };
  }

  async remove(id: number): Promise<{ message: string }> {
    await (this.prisma as any).approver.delete({
      where: { id },
    });

    return {
      message: 'Approver deleted successfully',
    };
  }
}
