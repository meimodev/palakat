import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma.service';
import { HelperService } from '../../common/helper/helper.service';
import { ChurchListQueryDto } from './dto/church-list.dto';

@Injectable()
export class ChurchService {
  constructor(
    private prisma: PrismaService,
    private helperService: HelperService,
  ) {}
  async getChurches(query: ChurchListQueryDto) {
    const { search, latitude, longitude, skip, take } = query;

    const lat = typeof latitude === 'number' ? latitude : null;
    const lng = typeof longitude === 'number' ? longitude : null;

    // Apply search filter at database level
    const where: Prisma.ChurchWhereInput = {};
    if (search && search.length >= 3) {
      const keyword = search.toLowerCase();
      where.OR = [{ name: { contains: keyword, mode: 'insensitive' } }];
    }

    let churches = [];
    let total: number;

    if (lat != null && lng != null) {
      const [totalCount, allChurchesData] = await this.prisma.$transaction([
        this.prisma.church.count({ where }),
        this.prisma.church.findMany({ where, include: { location: true } }),
      ]);

      total = totalCount;

      // Calculate distance and sort
      const churchesWithDistance = allChurchesData
        .map((church) => ({
          ...church,
          distance: this.helperService.calculateDistance(
            lat,
            lng,
            Number(church.location.latitude),
            Number(church.location.longitude),
          ),
        }))
        .sort((a, b) => a.distance - b.distance);

      // Apply pagination AFTER sorting
      churches = churchesWithDistance.slice(skip, skip + take);
    } else {
      const [totalCount, churchesData] = await this.prisma.$transaction([
        this.prisma.church.count({ where }),
        this.prisma.church.findMany({
          where,
          take,
          skip,
          orderBy: { name: 'asc' },
          include: { location: true },
        }),
      ]);

      total = totalCount;
      churches = churchesData;
    }

    return {
      message: 'Churches fetched successfully',
      data: churches,
      total,
    } as any;
  }

  async findOne(id: number) {
    const church = await this.prisma.church.findUniqueOrThrow({
      where: { id },
      include: {
        location: true,
        columns: true,
        membershipPositions: true,
      },
    });
    return {
      message: 'Church fetched successfully',
      data: church,
    };
  }

  async remove(id: number) {
    await this.prisma.church.delete({
      where: { id },
    });
    return {
      message: 'Church deleted successfully',
    };
  }

  async create(createChurchDto: Prisma.ChurchCreateInput) {
    const church = await this.prisma.church.create({
      data: createChurchDto,
    });
    return {
      message: 'Church created successfully',
      data: church,
    };
  }

  async update(id: number, updateChurchDto: Prisma.ChurchUpdateInput) {
    const church = await this.prisma.church.update({
      where: { id },
      data: updateChurchDto,
      include: {
        location: true,
        columns: true,
        membershipPositions: true,
      },
    });
    return {
      message: 'Church updated successfully',
      data: church,
    };
  }
}
