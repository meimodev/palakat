import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'nestjs-prisma';
import { ChurchRequestListQueryDto } from './dto/church-request-list.dto';
import { CreateChurchRequestDto } from './dto/create-church-request.dto';
import { UpdateChurchRequestDto } from './dto/update-church-request.dto';

@Injectable()
export class ChurchRequestService {
  constructor(private prisma: PrismaService) {}

  async create(requesterId: number, dto: CreateChurchRequestDto) {
    const churchRequest = await this.prisma.churchRequest.create({
      data: {
        churchName: dto.churchName,
        churchAddress: dto.churchAddress,
        contactPerson: dto.contactPerson,
        contactPhone: dto.contactPhone,
        requesterId: requesterId,
      },
      include: {
        requester: {
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
        },
      },
    });

    return {
      message: 'Church request submitted successfully',
      data: churchRequest,
    };
  }

  async findAll(query: ChurchRequestListQueryDto) {
    const { skip, take, search, requesterId } = query;

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

    const [total, data] = await this.prisma.$transaction([
      this.prisma.churchRequest.count({ where }),
      this.prisma.churchRequest.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          requester: {
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
          },
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
        requester: {
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
        },
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
        requester: {
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
        },
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
        requester: {
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
        },
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
}
