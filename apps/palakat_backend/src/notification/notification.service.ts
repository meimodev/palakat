import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { NotificationListQueryDto } from './dto/notification-list.dto';
import { PusherBeamsService } from './pusher-beams.service';
import { NotificationType } from '@prisma/client';

/**
 * Interface representing an activity with relations needed for notifications
 */
export interface ActivityWithRelations {
  id: number;
  title: string;
  bipra: string;
  activityType: string;
  date: Date | null;
  supervisorId: number;
  supervisor: {
    id: number;
    churchId: number;
  };
  approvers: Array<{
    id: number;
    membershipId: number;
    membership: {
      id: number;
    };
  }>;
}

/**
 * Interface representing an approver with relations needed for approval notifications
 */
export interface ApproverWithRelations {
  id: number;
  membershipId: number;
  status: string;
  membership: {
    id: number;
    account: {
      name: string;
    };
  };
  activity: {
    id: number;
    title: string;
    bipra: string;
    activityType: string;
    supervisorId: number;
    supervisor: {
      id: number;
      churchId: number;
    };
    approvers: Array<{
      id: number;
      membershipId: number;
      status: string;
    }>;
  };
}

/**
 * Service for managing notification records and sending push notifications.
 *
 * This service handles:
 * - CRUD operations for notification records
 * - Filtering and pagination of notifications
 * - Authorization checks for notification access
 * - Activity creation notifications
 *
 * **Validates: Requirements 1.2, 1.3, 1.4, 1.5, 5.1, 5.2, 5.3, 5.4, 5.5, 7.1, 7.2, 7.3, 7.4, 7.5, 8.1**
 */
@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor(
    private prisma: PrismaService,
    private pusherBeams: PusherBeamsService,
  ) {}

  /**
   * Creates a new notification record.
   *
   * @param createNotificationDto - The notification data
   * @returns The created notification
   *
   * **Validates: Requirements 1.2**
   */
  async create(createNotificationDto: CreateNotificationDto) {
    const notification = await (this.prisma as any).notification.create({
      data: {
        title: createNotificationDto.title,
        body: createNotificationDto.body,
        type: createNotificationDto.type,
        recipient: createNotificationDto.recipient,
        activityId: createNotificationDto.activityId ?? null,
        isRead: false,
      },
      include: {
        activity: true,
      },
    });

    return {
      message: 'Notification created successfully',
      data: notification,
    };
  }

  /**
   * Sends notifications when a new activity is created.
   *
   * This method:
   * 1. Sends a BIPRA group notification to church.{churchId}_bipra.{BIPRA}
   * 2. Sends individual notifications to each approver's membership.{membershipId}
   * 3. Creates Notification records for each recipient
   *
   * @param activity - The activity with relations (supervisor, approvers)
   *
   * **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**
   */
  async notifyActivityCreated(activity: ActivityWithRelations): Promise<void> {
    try {
      this.logger.log(
        `Starting notification for activity ${activity.id}: ${activity.title}`,
      );

      const churchId = activity.supervisor?.churchId;
      if (!churchId) {
        this.logger.error(
          `Cannot send notifications: churchId is missing for activity ${activity.id}`,
        );
        return;
      }

      const bipra = activity.bipra;
      // Handle date as either Date object or string
      let dateStr = 'No date set';
      if (activity.date) {
        const dateObj =
          activity.date instanceof Date
            ? activity.date
            : new Date(activity.date);
        dateStr = dateObj.toLocaleDateString();
      }

      // 1. Send BIPRA group notification
      const bipraInterest = this.pusherBeams.formatBipraInterest(
        churchId,
        bipra,
      );
      const bipraTitle = `New Activity: ${activity.title}`;
      const bipraBody = `${activity.activityType} - ${dateStr}`;

      // Create notification record for BIPRA group
      await (this.prisma as any).notification.create({
        data: {
          title: bipraTitle,
          body: bipraBody,
          type: NotificationType.ACTIVITY_CREATED,
          recipient: bipraInterest,
          activityId: activity.id,
          isRead: false,
        },
      });

      // Send push notification to BIPRA group
      await this.pusherBeams.publishToInterests([bipraInterest], {
        title: bipraTitle,
        body: bipraBody,
        deepLink: `/activities/${activity.id}`,
        data: {
          activityId: activity.id,
          type: 'ACTIVITY_CREATED',
        },
      });

      this.logger.log(
        `BIPRA notification sent for activity ${activity.id} to ${bipraInterest}`,
      );

      // 2. Send individual notifications to each approver
      for (const approver of activity.approvers) {
        const membershipInterest = this.pusherBeams.formatMembershipInterest(
          approver.membershipId,
        );
        const approverTitle = `Approval Required: ${activity.title}`;
        const approverBody = `You have been assigned to approve this ${activity.activityType.toLowerCase()}`;

        // Create notification record for approver
        await (this.prisma as any).notification.create({
          data: {
            title: approverTitle,
            body: approverBody,
            type: NotificationType.APPROVAL_REQUIRED,
            recipient: membershipInterest,
            activityId: activity.id,
            isRead: false,
          },
        });

        // Send push notification to approver
        await this.pusherBeams.publishToInterests([membershipInterest], {
          title: approverTitle,
          body: approverBody,
          deepLink: `/activities/${activity.id}/approve`,
          data: {
            activityId: activity.id,
            type: 'APPROVAL_REQUIRED',
          },
        });

        this.logger.log(
          `Approver notification sent for activity ${activity.id} to ${membershipInterest}`,
        );
      }

      this.logger.log(
        `Activity creation notifications completed for activity ${activity.id}: 1 BIPRA + ${activity.approvers.length} approvers`,
      );
    } catch (error) {
      // Log error but don't throw - notifications should not block activity creation
      // **Validates: Requirements 8.3**
      this.logger.error(
        `Failed to send activity creation notifications for activity ${activity.id}: ${error.message}`,
        error.stack,
      );
    }
  }

  /**
   * Retrieves paginated notifications with optional filtering.
   *
   * @param query - Query parameters for filtering and pagination
   * @param membershipId - The membership ID of the requesting user (for authorization)
   * @returns Paginated list of notifications with unread count
   *
   * **Validates: Requirements 1.5, 7.1, 7.5**
   */
  async findAll(query: NotificationListQueryDto, membershipId: number) {
    const {
      recipient,
      isRead,
      type,
      skip,
      take,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    // Build the recipient filter based on the user's membership
    // Users can only see notifications addressed to their membership interest
    const membershipInterest =
      this.pusherBeams.formatMembershipInterest(membershipId);

    const where: any = {
      recipient: membershipInterest,
    };

    // Additional recipient filter if provided (must still match user's interest)
    if (recipient !== undefined && recipient !== null) {
      // If a specific recipient is requested, it must match the user's membership interest
      if (recipient !== membershipInterest) {
        // Return empty result if trying to access other recipients
        return {
          message: 'Notifications retrieved successfully',
          data: [],
          total: 0,
          unreadCount: 0,
        };
      }
    }

    if (isRead !== undefined && isRead !== null) {
      where.isRead = isRead;
    }

    if (type !== undefined && type !== null) {
      where.type = type;
    }

    const [total, notifications, unreadCount] = await (
      this.prisma as any
    ).$transaction([
      (this.prisma as any).notification.count({ where }),
      (this.prisma as any).notification.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: {
          activity: {
            select: {
              id: true,
              title: true,
              bipra: true,
              activityType: true,
              date: true,
            },
          },
        },
      }),
      (this.prisma as any).notification.count({
        where: {
          recipient: membershipInterest,
          isRead: false,
        },
      }),
    ]);

    return {
      message: 'Notifications retrieved successfully',
      data: notifications,
      total,
      unreadCount,
    };
  }

  /**
   * Retrieves a single notification by ID with authorization check.
   *
   * @param id - The notification ID
   * @param membershipId - The membership ID of the requesting user
   * @returns The notification if authorized
   * @throws NotFoundException if notification doesn't exist
   * @throws ForbiddenException if user is not authorized
   *
   * **Validates: Requirements 1.3, 7.2**
   */
  async findOne(id: number, membershipId: number) {
    const notification = await (this.prisma as any).notification.findUnique({
      where: { id },
      include: {
        activity: {
          select: {
            id: true,
            title: true,
            bipra: true,
            activityType: true,
            date: true,
            description: true,
          },
        },
      },
    });

    if (!notification) {
      throw new NotFoundException(`Notification with ID ${id} not found`);
    }

    // Authorization check: user can only access their own notifications
    const membershipInterest =
      this.pusherBeams.formatMembershipInterest(membershipId);
    if (notification.recipient !== membershipInterest) {
      throw new ForbiddenException(
        'You are not authorized to access this notification',
      );
    }

    return {
      message: 'Notification retrieved successfully',
      data: notification,
    };
  }

  /**
   * Marks a notification as read.
   *
   * @param id - The notification ID
   * @param membershipId - The membership ID of the requesting user
   * @returns The updated notification
   * @throws NotFoundException if notification doesn't exist
   * @throws ForbiddenException if user is not authorized
   *
   * **Validates: Requirements 1.4, 7.3**
   */
  async markAsRead(id: number, membershipId: number) {
    // First check if notification exists and user is authorized
    const existing = await (this.prisma as any).notification.findUnique({
      where: { id },
    });

    if (!existing) {
      throw new NotFoundException(`Notification with ID ${id} not found`);
    }

    const membershipInterest =
      this.pusherBeams.formatMembershipInterest(membershipId);
    if (existing.recipient !== membershipInterest) {
      throw new ForbiddenException(
        'You are not authorized to update this notification',
      );
    }

    const notification = await (this.prisma as any).notification.update({
      where: { id },
      data: { isRead: true },
      include: {
        activity: {
          select: {
            id: true,
            title: true,
            bipra: true,
            activityType: true,
            date: true,
          },
        },
      },
    });

    return {
      message: 'Notification marked as read',
      data: notification,
    };
  }

  /**
   * Removes a notification.
   *
   * @param id - The notification ID
   * @param membershipId - The membership ID of the requesting user
   * @throws NotFoundException if notification doesn't exist
   * @throws ForbiddenException if user is not authorized
   *
   * **Validates: Requirements 7.4**
   */
  async remove(id: number, membershipId: number) {
    // First check if notification exists and user is authorized
    const existing = await (this.prisma as any).notification.findUnique({
      where: { id },
    });

    if (!existing) {
      throw new NotFoundException(`Notification with ID ${id} not found`);
    }

    const membershipInterest =
      this.pusherBeams.formatMembershipInterest(membershipId);
    if (existing.recipient !== membershipInterest) {
      throw new ForbiddenException(
        'You are not authorized to delete this notification',
      );
    }

    await (this.prisma as any).notification.delete({
      where: { id },
    });

    return {
      message: 'Notification deleted successfully',
    };
  }

  /**
   * Gets the count of unread notifications for a user.
   *
   * @param membershipId - The membership ID
   * @returns The unread notification count
   *
   * **Validates: Requirements 7.5**
   */
  async getUnreadCount(membershipId: number): Promise<number> {
    const membershipInterest =
      this.pusherBeams.formatMembershipInterest(membershipId);

    const count = await (this.prisma as any).notification.count({
      where: {
        recipient: membershipInterest,
        isRead: false,
      },
    });

    return count;
  }

  /**
   * Sends notifications when an approver changes the approval status of an activity.
   *
   * This method:
   * 1. Identifies the activity supervisor
   * 2. Identifies other unconfirmed approvers (excluding the approver who just changed status)
   * 3. Deduplicates if supervisor is also an approver
   * 4. Sends notifications to all recipients
   * 5. Creates Notification records with approver name and status in body
   *
   * @param approver - The approver with relations (activity, membership, other approvers)
   * @param newStatus - The new approval status (APPROVED or REJECTED)
   *
   * **Validates: Requirements 6.1, 6.2, 6.3, 6.4, 6.5**
   */
  async notifyApprovalStatusChanged(
    approver: ApproverWithRelations,
    newStatus: string,
  ): Promise<void> {
    try {
      const supervisorId = approver.activity.supervisorId;
      const changingApproverId = approver.membershipId;
      const approverName = approver.membership.account.name;
      const activityTitle = approver.activity.title;

      // Determine notification type and status text
      const notificationType =
        newStatus === 'APPROVED'
          ? NotificationType.APPROVAL_CONFIRMED
          : NotificationType.APPROVAL_REJECTED;
      const statusText = newStatus === 'APPROVED' ? 'approved' : 'rejected';

      // 1. Identify other unconfirmed approvers (excluding the one who just changed status)
      const otherUnconfirmedApprovers = approver.activity.approvers
        .filter(
          (a) =>
            a.membershipId !== changingApproverId && a.status === 'UNCONFIRMED',
        )
        .map((a) => a.membershipId);

      // 2. Build recipient list with deduplication
      // Start with supervisor
      const recipients = new Set<number>([supervisorId]);

      // Add other unconfirmed approvers (Set automatically deduplicates)
      for (const approverId of otherUnconfirmedApprovers) {
        recipients.add(approverId);
      }

      // 3. Send notifications to all recipients
      const title = `Activity ${statusText}: ${activityTitle}`;
      const body = `${approverName} has ${statusText} this activity`;

      for (const membershipId of recipients) {
        const membershipInterest =
          this.pusherBeams.formatMembershipInterest(membershipId);

        // Create notification record
        await (this.prisma as any).notification.create({
          data: {
            title,
            body,
            type: notificationType,
            recipient: membershipInterest,
            activityId: approver.activity.id,
            isRead: false,
          },
        });

        // Send push notification
        await this.pusherBeams.publishToInterests([membershipInterest], {
          title,
          body,
          deepLink: `/activities/${approver.activity.id}`,
          data: {
            activityId: approver.activity.id,
            type: notificationType,
            approverName,
            status: newStatus,
          },
        });

        this.logger.log(
          `Approval notification sent for activity ${approver.activity.id} to ${membershipInterest}`,
        );
      }

      this.logger.log(
        `Approval status change notifications completed for activity ${approver.activity.id}: ${recipients.size} recipients`,
      );
    } catch (error) {
      // Log error but don't throw - notifications should not block approval update
      // **Validates: Requirements 8.4**
      this.logger.error(
        `Failed to send approval status change notifications for activity ${approver.activity.id}: ${error.message}`,
        error.stack,
      );
    }
  }
}
