import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { MembershipListQueryDto } from './dto/membership-list.dto';

@Injectable()
export class MembershipService {
  constructor(private prisma: PrismaService) {}

  /**
   * The caller's own membership. `accountId` is taken from the authenticated
   * user and any value the client sent is discarded — a membership is the link
   * between an account and a church, so letting the payload name the account
   * is letting the caller enrol somebody else.
   *
   * This also repairs the flow: the member app's join screen sends only
   * `{churchId, columnId, baptize, sidi}`, and `accountId` is a required column,
   * so every create through it failed on a missing field. Deriving the id is
   * both the guard and the fix.
   */
  async create(
    createMembershipDto: any,
    user: { userId: number },
  ): Promise<{ message: string; data: any }> {
    const accountId = user?.userId;
    if (typeof accountId !== 'number') {
      throw new ForbiddenException('Requester identity is required');
    }

    // One membership per account — the column is @unique, and
    // membershipInvitation.respond already refuses on the same grounds. Without
    // this the caller gets a raw Prisma constraint error.
    const existing = await (this.prisma as any).membership.findUnique({
      where: { accountId },
      select: { id: true },
    });
    if (existing?.id) {
      throw new ConflictException('User already has a membership');
    }

    createMembershipDto = { ...createMembershipDto, accountId };

    if (!createMembershipDto?.columnId && !createMembershipDto?.churchId) {
      throw new BadRequestException('Either columnId or churchId is required');
    }

    if (createMembershipDto?.columnId != null) {
      const column = await (this.prisma as any).column.findUnique({
        where: { id: createMembershipDto.columnId },
        select: { id: true, churchId: true },
      });
      if (!column) {
        throw new BadRequestException('columnId does not exist');
      }
      // If churchId not provided, derive from column
      if (createMembershipDto?.churchId == null) {
        createMembershipDto.churchId = column.churchId;
      } else if (column.churchId !== createMembershipDto.churchId) {
        throw new BadRequestException('columnId belongs to a different church');
      }
    }

    const membership = await (this.prisma as any).membership.create({
      data: createMembershipDto,
      include: {
        account: true,
        church: true,
        column: true,
        membershipPositions: true,
      },
    });

    return {
      message: 'Membership created successfully',
      data: membership,
    };
  }

  async findAll(query: MembershipListQueryDto): Promise<{
    message: string;
    data: any[];
    total: number;
  }> {
    const {
      churchId,
      columnId,
      search,
      requireColumnId,
      skip,
      take,
      sortBy = 'id',
      sortOrder = 'desc',
    } = query ?? ({} as any);
    const normalizedSearch =
      typeof search === 'string' && search.trim().length > 0
        ? search.trim()
        : undefined;
    const and: any[] = [];

    if (requireColumnId && !columnId) {
      throw new BadRequestException('columnId is required for this request');
    }

    if (churchId) {
      and.push({
        OR: [
          { churchId },
          {
            column: {
              churchId,
            },
          },
        ],
      });
    }
    if (columnId) {
      and.push({ columnId });
    }
    if (normalizedSearch) {
      and.push({
        account: {
          is: {
            OR: [
              { name: { contains: normalizedSearch, mode: 'insensitive' } },
              { phone: { contains: normalizedSearch, mode: 'insensitive' } },
            ],
          },
        },
      });
    }

    const where: any =
      and.length === 0 ? {} : and.length === 1 ? and[0] : { AND: and };

    const [total, memberships] = await (this.prisma as any).$transaction([
      this.prisma.membership.count({ where }),
      this.prisma.membership.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: {
          account: true,
          church: true,
          column: true,
          membershipPositions: true,
        },
      }),
    ]);
    return {
      message: 'Memberships retrieved successfully',
      data: memberships,
      total,
    } as any;
  }

  async findOne(id: number): Promise<{ message: string; data: any }> {
    const membership = await (this.prisma as any).membership.findUniqueOrThrow({
      where: { id },
      include: {
        account: true,
        church: true,
        column: true,
        membershipPositions: true,
      },
    });

    return {
      message: 'Membership retrieved successfully',
      data: membership,
    };
  }

  /**
   * Self-only. `apps/palakat` is the sole caller — the same join screen, editing
   * a membership that already exists — so there is no administrative path to
   * keep open here. `accountId` is stripped from the payload for the same
   * reason it is derived in `create`: re-pointing a membership at another
   * account is the same act as creating one for them.
   */
  async update(
    id: number,
    updateMembershipDto: any,
    user: { userId: number },
  ): Promise<{ message: string; data: any }> {
    if (typeof user?.userId !== 'number') {
      throw new ForbiddenException('Requester identity is required');
    }

    const existing = await (this.prisma as any).membership.findUnique({
      where: { id },
      select: { accountId: true },
    });
    if (!existing) {
      throw new NotFoundException('Membership not found');
    }
    if (existing.accountId !== user.userId) {
      throw new ForbiddenException('You can only update your own membership');
    }

    const { accountId: _ignored, ...rest } = updateMembershipDto ?? {};
    updateMembershipDto = rest;

    if (updateMembershipDto?.columnId != null) {
      const column = await (this.prisma as any).column.findUnique({
        where: { id: updateMembershipDto.columnId },
        select: { id: true, churchId: true },
      });
      if (!column) {
        throw new BadRequestException('columnId does not exist');
      }
      // If churchId not provided, derive from column; else validate match
      if (updateMembershipDto?.churchId == null) {
        updateMembershipDto.churchId = column.churchId;
      } else if (column.churchId !== updateMembershipDto.churchId) {
        throw new BadRequestException('columnId belongs to a different church');
      }
    }

    const membership = await (this.prisma as any).membership.update({
      where: { id },
      data: updateMembershipDto,
      include: {
        account: true,
        church: true,
        column: true,
        membershipPositions: true,
      },
    });

    return {
      message: 'Membership updated successfully',
      data: membership,
    };
  }

  async remove(id: number): Promise<{ message: string }> {
    await this.findOne(id);

    await (this.prisma as any).membership.delete({
      where: { id },
    });

    return {
      message: 'Membership deleted successfully',
    };
  }
}
