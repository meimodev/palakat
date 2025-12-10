import {
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Query,
  Req,
  UseGuards,
  BadRequestException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport/dist/auth.guard';
import { NotificationService } from './notification.service';
import { NotificationListQueryDto } from './dto/notification-list.dto';
import { PrismaService } from '../prisma.service';

/**
 * Controller for notification REST API endpoints.
 *
 * All endpoints require JWT authentication and operate on notifications
 * belonging to the authenticated user's membership.
 *
 * **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**
 */
@UseGuards(AuthGuard('jwt'))
@Controller('notifications')
export class NotificationController {
  constructor(
    private readonly notificationService: NotificationService,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * Gets the membership ID for the authenticated user.
   * @throws BadRequestException if user has no membership
   */
  private async getMembershipId(userId: number): Promise<number> {
    const membership = await (this.prisma as any).membership.findUnique({
      where: { accountId: userId },
      select: { id: true },
    });

    if (!membership) {
      throw new BadRequestException(
        'User does not have a membership. Cannot access notifications.',
      );
    }

    return membership.id;
  }

  /**
   * GET /notifications
   *
   * Retrieves paginated notifications for the authenticated user.
   *
   * @param query - Query parameters for filtering and pagination
   * @param req - Request object containing authenticated user
   * @returns Paginated list of notifications with unread count
   *
   * **Validates: Requirements 7.1, 7.5**
   */
  @Get()
  async findAll(@Query() query: NotificationListQueryDto, @Req() req: any) {
    const membershipId = await this.getMembershipId(req.user.userId);
    return this.notificationService.findAll(query, membershipId);
  }

  /**
   * GET /notifications/:id
   *
   * Retrieves a single notification by ID.
   *
   * @param id - The notification ID
   * @param req - Request object containing authenticated user
   * @returns The notification if authorized
   *
   * **Validates: Requirements 7.2**
   */
  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const membershipId = await this.getMembershipId(req.user.userId);
    return this.notificationService.findOne(id, membershipId);
  }

  /**
   * PATCH /notifications/:id/read
   *
   * Marks a notification as read.
   *
   * @param id - The notification ID
   * @param req - Request object containing authenticated user
   * @returns The updated notification
   *
   * **Validates: Requirements 7.3**
   */
  @Patch(':id/read')
  async markAsRead(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const membershipId = await this.getMembershipId(req.user.userId);
    return this.notificationService.markAsRead(id, membershipId);
  }

  /**
   * DELETE /notifications/:id
   *
   * Deletes a notification.
   *
   * @param id - The notification ID
   * @param req - Request object containing authenticated user
   *
   * **Validates: Requirements 7.4**
   */
  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const membershipId = await this.getMembershipId(req.user.userId);
    return this.notificationService.remove(id, membershipId);
  }
}
