import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateApproverDto } from './dto/create-approver.dto';
import { UpdateApproverDto } from './dto/update-approver.dto';
import { ApproverListQueryDto } from './dto/approver-list.dto';
import { NotificationService } from '../notification/notification.service';
import { ApprovalStatus } from '../generated/prisma/client';
import { DocumentService } from '../document/document.service';
import { RealtimeEmitterService } from '../realtime/realtime-emitter.service';

@Injectable()
export class ApproverService {
  constructor(
    private prisma: PrismaService,
    private documentService: DocumentService,
    @Inject(forwardRef(() => NotificationService))
    private notificationService: NotificationService,
    @Inject(forwardRef(() => RealtimeEmitterService))
    private realtime: RealtimeEmitterService,
  ) {}

  private async resolveActorName(actor?: {
    userId?: number;
    name?: string | null;
  }): Promise<string | null> {
    const explicitName = actor?.name?.trim();
    if (explicitName) {
      return explicitName;
    }

    if (typeof actor?.userId !== 'number') {
      return null;
    }

    const account = await (this.prisma as any).account.findUnique({
      where: { id: actor.userId },
      select: { name: true },
    });

    return typeof account?.name === 'string' && account.name.trim().length > 0
      ? account.name.trim()
      : null;
  }

  private isFullyApproved(activity: any): boolean {
    const approvers = Array.isArray(activity?.approvers)
      ? activity.approvers
      : [];
    return (
      approvers.length > 0 &&
      approvers.every(
        (approver: any) => approver?.status === ApprovalStatus.APPROVED,
      )
    );
  }

  private async maybeAutoGenerateLinkedDocument(approver: any): Promise<void> {
    const activity = approver?.activity;
    const linkedDocument = activity?.document;
    const requesterUserId = approver?.membership?.account?.id;

    if (!activity || !linkedDocument || typeof requesterUserId !== 'number') {
      return;
    }

    if (
      typeof linkedDocument?.id !== 'number' ||
      linkedDocument.fileId != null
    ) {
      return;
    }

    if (!this.isFullyApproved(activity)) {
      return;
    }

    try {
      await this.documentService.generate(
        {
          id: linkedDocument.id,
          regenerate: false,
        },
        { userId: requesterUserId },
      );
    } catch (error) {
      if (error instanceof ConflictException) {
        return;
      }

      throw error;
    }
  }

  private emitActivityUpdatedEvent(activity: any): void {
    const churchId = activity?.supervisor?.churchId;
    if (typeof churchId !== 'number' || typeof activity?.id !== 'number') {
      return;
    }

    this.realtime.emitActivityEvent({
      eventName: 'activity.updated',
      activityId: activity.id,
      churchId,
      affectedMembershipIds: [
        activity.supervisorId,
        ...(activity.approvers ?? []).map(
          (approver: any) => approver.membershipId,
        ),
      ],
      updatedAt: activity.updatedAt,
    });
  }

  /** Emit a richer approval-lifecycle event for admin notifications */
  private emitApprovalLifecycleEvent(params: {
    activityId: number;
    churchId: number;
    activity: any;
    approver: any;
    newStatus: ApprovalStatus;
    actorName?: string | null;
    isOverride?: boolean;
  }): void {
    const {
      activityId,
      churchId,
      activity,
      approver,
      newStatus,
      actorName,
      isOverride,
    } = params;
    const allApprovers = activity?.approvers ?? [];
    const affectedMembershipIds = [
      activity?.supervisorId,
      ...allApprovers.map((a: any) => a.membershipId),
    ].filter((id): id is number => typeof id === 'number');

    let eventName: string;
    if (isOverride) {
      eventName =
        newStatus === ApprovalStatus.APPROVED
          ? 'approval.override.approved'
          : 'approval.override.rejected';
    } else {
      eventName =
        newStatus === ApprovalStatus.APPROVED
          ? 'approval.approved'
          : 'approval.rejected';
    }

    this.realtime.emitApprovalLifecycleEvent({
      eventName: eventName as any,
      entityType: 'ACTIVITY',
      entityId: activityId,
      entityTitle: activity?.title ?? null,
      churchId,
      actorName: actorName ?? approver?.membership?.account?.name ?? null,
      resultingStatus: newStatus,
      isOverride: isOverride ?? false,
      affectedMembershipIds,
      updatedAt: activity?.updatedAt ?? new Date(),
    });
  }

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
            approvers: {
              select: {
                membershipId: true,
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

    const churchId = approver?.activity?.supervisor?.churchId;
    if (typeof churchId === 'number') {
      this.realtime.emitApprovalLifecycleEvent({
        eventName: 'approval.required',
        entityType: 'ACTIVITY',
        entityId: approver.activityId,
        entityTitle: approver.activity?.title ?? null,
        churchId,
        resultingStatus: ApprovalStatus.UNCONFIRMED,
        isOverride: false,
        affectedMembershipIds: [
          approver.activity?.supervisorId,
          ...(approver.activity?.approvers ?? []).map(
            (item: any) => item.membershipId,
          ),
        ],
        updatedAt: approver.activity?.updatedAt ?? new Date(),
      });
    }

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
      churchId,
      startDate,
      endDate,
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

    if (churchId !== undefined && churchId !== null) {
      where.activity = {
        ...(where.activity ?? {}),
        supervisor: {
          churchId,
        },
      };
    }

    if (startDate || endDate) {
      where.activity = {
        ...(where.activity ?? {}),
        date: {
          ...(where.activity?.date ?? {}),
          ...(startDate ? { gte: startDate } : {}),
          ...(endDate ? { lte: endDate } : {}),
        },
      };
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
              approvers: {
                select: {
                  id: true,
                  membershipId: true,
                  status: true,
                  createdAt: true,
                  updatedAt: true,
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
            approvers: {
              select: {
                id: true,
                membershipId: true,
                status: true,
                createdAt: true,
                updatedAt: true,
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

  /**
   * Normal self-update: requester can only update their own approver record.
   * The requesterMembershipId must match the approver's membershipId.
   */
  async update(
    id: number,
    updateApproverDto: UpdateApproverDto,
    requesterMembershipId?: number,
  ): Promise<{ message: string; data: any }> {
    const approverInclude = {
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
          approvers: {
            select: {
              id: true,
              membershipId: true,
              status: true,
              createdAt: true,
              updatedAt: true,
            },
          },
          document: {
            include: {
              church: true,
              file: true,
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
    };

    // First load the record to enforce self-only constraint
    if (typeof requesterMembershipId === 'number') {
      const existing = await (this.prisma as any).approver.findUnique({
        where: { id },
        select: { membershipId: true },
      });
      if (!existing) {
        throw new NotFoundException('Approver not found');
      }
      if (existing.membershipId !== requesterMembershipId) {
        throw new ForbiddenException(
          'You can only update your own approver record',
        );
      }
    }

    const approver = await (this.prisma as any).approver.update({
      where: { id },
      data: {
        status: updateApproverDto.status,
      },
      include: approverInclude,
    });

    this.emitActivityUpdatedEvent(approver.activity);

    const churchId = approver?.activity?.supervisor?.churchId;
    if (typeof churchId === 'number' && updateApproverDto.status) {
      this.emitApprovalLifecycleEvent({
        activityId: approver.activityId,
        churchId,
        activity: approver.activity,
        approver,
        newStatus: updateApproverDto.status,
        isOverride: false,
      });
    }

    if (updateApproverDto.status === ApprovalStatus.APPROVED) {
      await this.maybeAutoGenerateLinkedDocument(approver);
    }

    // Send approval status change notifications
    try {
      await this.notificationService.notifyApprovalStatusChanged(
        approver,
        updateApproverDto.status,
      );
    } catch {
      // Notification errors are already logged in NotificationService
    }

    return {
      message: 'Approver updated successfully',
      data: approver,
    };
  }

  /**
   * Admin override: bypasses self-only check; sets the target's status
   * unconditionally. Used only through admin-app override RPC actions.
   */
  async adminOverride(
    id: number,
    newStatus: ApprovalStatus,
    overrideNote?: string,
    actor?: {
      userId?: number;
      name?: string | null;
    },
  ): Promise<{ message: string; data: any }> {
    void overrideNote;
    const approverInclude = {
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
          approvers: {
            select: {
              id: true,
              membershipId: true,
              status: true,
              createdAt: true,
              updatedAt: true,
            },
          },
          document: {
            include: {
              church: true,
              file: true,
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
    };

    const actorName = await this.resolveActorName(actor);

    const approver = await (this.prisma as any).approver.update({
      where: { id },
      data: {
        status: newStatus,
      },
      include: approverInclude,
    });

    this.emitActivityUpdatedEvent(approver.activity);

    const churchId = approver?.activity?.supervisor?.churchId;
    if (typeof churchId === 'number') {
      this.emitApprovalLifecycleEvent({
        activityId: approver.activityId,
        churchId,
        activity: approver.activity,
        approver,
        newStatus,
        actorName,
        isOverride: true,
      });
    }

    if (newStatus === ApprovalStatus.APPROVED) {
      await this.maybeAutoGenerateLinkedDocument(approver);
    }

    return {
      message: 'Approver override applied successfully',
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
