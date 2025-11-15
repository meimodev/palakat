import { Injectable } from '@nestjs/common';
import { PrismaService } from 'nestjs-prisma';
import { Prisma } from '../../prisma/generated/prisma';
import { LocationListQueryDto } from './dto/location-list.dto';

@Injectable()
export class LocationService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: Prisma.LocationCreateInput) {
    const location = await this.prisma.location.create({
      data: dto,
    });
    return { message: 'OK', data: location } as any;
  }

  async findAll(query: LocationListQueryDto) {
    const { search, skip, take } = query ?? ({} as any);

    const where: Prisma.LocationWhereInput = {};
    if (search && search.length >= 1) {
      where.name = { contains: search, mode: 'insensitive' } as any;
    }

    const [total, locations] = await this.prisma.$transaction([
      this.prisma.location.count({ where }),
      this.prisma.location.findMany({
        where,
        take,
        skip,
        orderBy: { id: 'desc' },
      }),
    ]);

    return { message: 'OK', data: locations, total } as any;
  }

  async findOne(id: number) {
    const location = await this.prisma.location.findUniqueOrThrow({
      where: { id },
    });
    return { message: 'OK', data: location } as any;
  }

  async update(id: number, dto: Prisma.LocationUpdateInput) {
    const location = await this.prisma.location.update({
      where: { id },
      data: dto,
    });
    return { message: 'OK', data: location } as any;
  }

  async delete(id: number) {
    await this.prisma.location.delete({ where: { id } });
    return { message: 'OK' } as any;
  }
}
