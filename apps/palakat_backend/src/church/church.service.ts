import { Injectable } from '@nestjs/common';
import { Prisma } from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import { HelperService } from '../../common/helper/helper.service';
import { ChurchListQueryDto } from './dto/church-list.dto';

@Injectable()
export class ChurchService {
  constructor(
    private prisma: PrismaService,
    private helperService: HelperService,
  ) {}

  private normalizeDocumentPrefixAccountNumber(
    value: unknown,
  ): string | null | undefined {
    if (value === undefined) {
      return undefined;
    }
    if (value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      return undefined;
    }

    const normalized = value.trim().toUpperCase().replace(/\/+/g, '/');

    const withoutEdgeSlashes = normalized.replace(/^\/+|\/+$/g, '');
    return withoutEdgeSlashes.length ? withoutEdgeSlashes : null;
  }

  private normalizeCreateChurchInput(
    createChurchDto: Prisma.ChurchCreateInput,
  ): Prisma.ChurchCreateInput {
    const normalized = { ...createChurchDto };
    normalized.documentPrefixAccountNumber =
      this.normalizeDocumentPrefixAccountNumber(
        createChurchDto.documentPrefixAccountNumber,
      ) ?? null;
    return normalized;
  }

  private normalizeUpdateChurchInput(
    updateChurchDto: Prisma.ChurchUpdateInput,
  ): Prisma.ChurchUpdateInput {
    const normalized: Prisma.ChurchUpdateInput = { ...updateChurchDto };
    if (!('documentPrefixAccountNumber' in updateChurchDto)) {
      return normalized;
    }

    const value = updateChurchDto.documentPrefixAccountNumber;
    if (value && typeof value === 'object' && 'set' in value) {
      normalized.documentPrefixAccountNumber = {
        set: this.normalizeDocumentPrefixAccountNumber(value.set) ?? null,
      };
      return normalized;
    }

    normalized.documentPrefixAccountNumber =
      this.normalizeDocumentPrefixAccountNumber(value) ?? null;
    return normalized;
  }

  async getChurches(query: ChurchListQueryDto) {
    const {
      search,
      latitude,
      longitude,
      skip,
      take,
      sortBy = 'name',
      sortOrder = 'asc',
    } = query;

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
            church.location.latitude == null
              ? Number.NaN
              : Number(church.location.latitude),
            church.location.longitude == null
              ? Number.NaN
              : Number(church.location.longitude),
          ),
        }))
        .sort((a, b) => {
          const aDistance = Number.isFinite(a.distance)
            ? a.distance
            : Number.POSITIVE_INFINITY;
          const bDistance = Number.isFinite(b.distance)
            ? b.distance
            : Number.POSITIVE_INFINITY;
          return aDistance - bDistance;
        });

      // Apply pagination AFTER sorting
      churches = churchesWithDistance.slice(skip, skip + take);
    } else {
      const [totalCount, churchesData] = await this.prisma.$transaction([
        this.prisma.church.count({ where }),
        this.prisma.church.findMany({
          where,
          take,
          skip,
          orderBy: { [sortBy]: sortOrder },
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

  /**
   * Phase 5 §9.5: an opaque per-church staleness signal for palakat_admin's
   * poll transport (replacing its socket). The value is the max `updatedAt`
   * (epoch millis) across the church-scoped tables the admin watches. It only
   * has to *change* when relevant data changes — the client compares it to the
   * previous value and, on a change, marks its providers stale (§9.4). No schema
   * change: Activity and the approver tables carry no direct churchId, so they
   * scope through their relations.
   *
   * ponytail: 12 indexed MAX(updatedAt) aggregates per poll (~2 req/min per
   * admin). Cheap and correct; if poll volume ever dominates, collapse to one
   * raw `GREATEST()` query.
   */
  async getChangeVersion(churchId: number): Promise<{ version: number }> {
    const byChurch = { churchId };
    const activityByChurch = {
      OR: [{ supervisor: { churchId } }, { column: { churchId } }],
    };
    const max = { _max: { updatedAt: true as const } };

    const results = await Promise.all([
      this.prisma.revenue.aggregate({ ...max, where: byChurch }),
      this.prisma.expense.aggregate({ ...max, where: byChurch }),
      this.prisma.cashMutation.aggregate({ ...max, where: byChurch }),
      this.prisma.cashAccount.aggregate({ ...max, where: byChurch }),
      this.prisma.report.aggregate({ ...max, where: byChurch }),
      this.prisma.membership.aggregate({ ...max, where: byChurch }),
      this.prisma.document.aggregate({ ...max, where: byChurch }),
      this.prisma.approvalRule.aggregate({ ...max, where: byChurch }),
      this.prisma.activity.aggregate({ ...max, where: activityByChurch }),
      this.prisma.approver.aggregate({
        ...max,
        where: { activity: activityByChurch },
      }),
      this.prisma.revenueApprover.aggregate({
        ...max,
        where: { revenue: byChurch },
      }),
      this.prisma.expenseApprover.aggregate({
        ...max,
        where: { expense: byChurch },
      }),
    ]);

    const version = results.reduce((latest, result) => {
      const updatedAt = result._max.updatedAt?.getTime() ?? 0;
      return updatedAt > latest ? updatedAt : latest;
    }, 0);

    return { version };
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
      data: this.normalizeCreateChurchInput(createChurchDto),
    });
    return {
      message: 'Church created successfully',
      data: church,
    };
  }

  async update(id: number, updateChurchDto: Prisma.ChurchUpdateInput) {
    const church = await this.prisma.church.update({
      where: { id },
      data: this.normalizeUpdateChurchInput(updateChurchDto),
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
