import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { ChurchRequestListQueryDto } from './dto/church-request-list.dto';
import { CreateChurchRequestDto } from './dto/create-church-request.dto';
import { UpdateChurchRequestDto } from './dto/update-church-request.dto';
import { NotificationType, RequestStatus } from '../generated/prisma/client';
import { PusherBeamsService } from '../notification/pusher-beams.service';
import { ApproveChurchRequestDto } from './dto/approve-church-request.dto';
import { RejectChurchRequestDto } from './dto/reject-church-request.dto';

@Injectable()
export class ChurchRequestService {
  constructor(
    private prisma: PrismaService,
    private pusherBeams: PusherBeamsService,
  ) {}

  private requesterSelect = {
    select: {
      id: true,
      name: true,
      phone: true,
      email: true,
      gender: true,
      maritalStatus: true,
      dob: true,
      claimed: true,
      createdAt: true,
      updatedAt: true,
    },
  } as const;

  private async notifyRequester(
    requesterId: number,
    payload: {
      title: string;
      body: string;
      type: NotificationType;
      data?: Record<string, any>;
    },
  ): Promise<void> {
    const membership = await this.prisma.membership.findUnique({
      where: { accountId: requesterId },
      select: { id: true },
    });

    const membershipId: number | null = membership?.id ?? null;
    if (!membershipId) {
      return;
    }

    const recipient = this.pusherBeams.formatMembershipInterest(membershipId);

    await this.prisma.notification.create({
      data: {
        title: payload.title,
        body: payload.body,
        type: payload.type,
        recipient,
        activityId: null,
        isRead: false,
      },
    });

    await this.pusherBeams.publishToInterests([recipient], {
      title: payload.title,
      body: payload.body,
      data: {
        ...(payload.data ?? {}),
        type: payload.type,
      },
    });
  }

  async createOrResubmit(requesterId: number, dto: CreateChurchRequestDto) {
    const existing = await this.prisma.churchRequest.findUnique({
      where: { requesterId },
      select: { id: true, status: true },
    });

    if (!existing) {
      const churchRequest = await this.prisma.churchRequest.create({
        data: {
          churchName: dto.churchName,
          churchAddress: dto.churchAddress,
          contactPerson: dto.contactPerson,
          contactPhone: dto.contactPhone,
          requesterId,
          status: RequestStatus.TODO,
        },
        include: { requester: this.requesterSelect },
      });

      return {
        message: 'Church request submitted successfully',
        data: churchRequest,
      };
    }

    if (existing.status !== RequestStatus.REJECTED) {
      throw new ConflictException('Church request already exists');
    }

    const churchRequest = await this.prisma.churchRequest.update({
      where: { requesterId },
      data: {
        churchName: dto.churchName,
        churchAddress: dto.churchAddress,
        contactPerson: dto.contactPerson,
        contactPhone: dto.contactPhone,
        status: RequestStatus.TODO,
        decisionNote: null,
        reviewedAt: null,
        reviewedById: null,
        approvedChurchId: null,
      },
      include: { requester: this.requesterSelect },
    });

    return {
      message: 'Church request resubmitted successfully',
      data: churchRequest,
    };
  }

  async findAll(query: ChurchRequestListQueryDto) {
    const {
      skip,
      take,
      search,
      requesterId,
      status,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    // Build where clause
    const where: any = {};

    if (search && search.length >= 3) {
      where.OR = [
        { churchName: { contains: search, mode: 'insensitive' } },
        { churchAddress: { contains: search, mode: 'insensitive' } },
        { contactPerson: { contains: search, mode: 'insensitive' } },
        { contactPhone: { contains: search, mode: 'insensitive' } },
      ];
    }

    if (requesterId) {
      where.requesterId = requesterId;
    }

    if (status) {
      where.status = status;
    }

    const [total, data] = await this.prisma.$transaction([
      this.prisma.churchRequest.count({ where }),
      this.prisma.churchRequest.findMany({
        where,
        skip,
        take,
        orderBy: { [sortBy]: sortOrder },
        include: {
          requester: this.requesterSelect,
        },
      }),
    ]);

    return {
      message: 'Church requests fetched successfully',
      data,
      total,
    };
  }

  async findOne(id: number) {
    const churchRequest = await this.prisma.churchRequest.findUniqueOrThrow({
      where: { id },
      include: {
        requester: this.requesterSelect,
      },
    });

    if (!churchRequest) {
      throw new NotFoundException(`Church request with ID ${id} not found`);
    }

    return {
      message: 'Church request fetched successfully',
      data: churchRequest,
    };
  }

  async findByRequester(requesterId: number) {
    const churchRequest = await this.prisma.churchRequest.findUnique({
      where: { requesterId },
      include: {
        requester: this.requesterSelect,
      },
    });

    return {
      message: churchRequest
        ? 'Church request fetched successfully'
        : 'No church request found',
      data: churchRequest,
    };
  }

  async update(id: number, dto: UpdateChurchRequestDto) {
    const churchRequest = await this.prisma.churchRequest.update({
      where: { id },
      data: dto,
      include: {
        requester: this.requesterSelect,
      },
    });

    return {
      message: 'Church request updated successfully',
      data: churchRequest,
    };
  }

  async remove(id: number) {
    await this.prisma.churchRequest.delete({
      where: { id },
    });

    return {
      message: 'Church request deleted successfully',
    };
  }

  async approve(id: number, reviewerId: number, dto: ApproveChurchRequestDto) {
    const request = await this.prisma.churchRequest.findUniqueOrThrow({
      where: { id },
      select: {
        id: true,
        requesterId: true,
        status: true,
        churchName: true,
        churchAddress: true,
        contactPerson: true,
        contactPhone: true,
      },
    });

    if (
      request.status === RequestStatus.DONE ||
      request.status === RequestStatus.REJECTED
    ) {
      throw new ConflictException('Church request already resolved');
    }

    const resolvedName = dto.churchName ?? request.churchName;
    const resolvedAddress = dto.churchAddress ?? request.churchAddress;
    const resolvedContactPhone = dto.contactPhone ?? request.contactPhone;

    const { updatedRequest, church } = await this.prisma.$transaction(
      async (tx) => {
        const createdChurch = await tx.church.create({
          data: {
            name: resolvedName,
            phoneNumber: resolvedContactPhone,
            location: {
              create: {
                name: resolvedAddress,
                latitude: dto.latitude ?? null,
                longitude: dto.longitude ?? null,
              },
            },
          },
        });

        const updated = await tx.churchRequest.update({
          where: { id: request.id },
          data: {
            status: RequestStatus.DONE,
            decisionNote: dto.decisionNote ?? null,
            reviewedAt: new Date(),
            reviewedById: reviewerId,
            approvedChurchId: createdChurch.id,
          },
          include: { requester: this.requesterSelect },
        });

        return { updatedRequest: updated, church: createdChurch };
      },
    );

    await this.notifyRequester(request.requesterId, {
      title: 'Church request approved',
      body: `Your church "${resolvedName}" has been registered. Please join manually from the app.`,
      type: NotificationType.CHURCH_REQUEST_APPROVED,
      data: {
        churchRequestId: request.id,
        approvedChurchId: church.id,
      },
    });

    return {
      message: 'Church request approved successfully',
      data: updatedRequest,
      church,
    } as any;
  }

  async reject(id: number, reviewerId: number, dto: RejectChurchRequestDto) {
    const request = await this.prisma.churchRequest.findUniqueOrThrow({
      where: { id },
      select: {
        id: true,
        requesterId: true,
        status: true,
        churchName: true,
      },
    });

    if (
      request.status === RequestStatus.DONE ||
      request.status === RequestStatus.REJECTED
    ) {
      throw new ConflictException('Church request already resolved');
    }

    const updatedRequest = await this.prisma.churchRequest.update({
      where: { id: request.id },
      data: {
        status: RequestStatus.REJECTED,
        decisionNote: dto.decisionNote,
        reviewedAt: new Date(),
        reviewedById: reviewerId,
        approvedChurchId: null,
      },
      include: { requester: this.requesterSelect },
    });

    await this.notifyRequester(request.requesterId, {
      title: 'Church request rejected',
      body: `Your church request for "${request.churchName}" was rejected. Note: ${dto.decisionNote}`,
      type: NotificationType.CHURCH_REQUEST_REJECTED,
      data: {
        churchRequestId: request.id,
      },
    });

    return {
      message: 'Church request rejected successfully',
      data: updatedRequest,
    };
  }
}
