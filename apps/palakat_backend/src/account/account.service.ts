import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '../generated/prisma/client';
import { AccountListQueryDto } from './dto/account-list.dto';
import { AccountCountQueryDto } from './dto/account-count.dto';
@Injectable()
export class AccountService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params: AccountListQueryDto) {
    const {
      churchId,
      skip,
      take,
      search,
      position,
      sortBy = 'name',
      sortOrder = 'asc',
    } = params;

    const where: Prisma.AccountWhereInput = {};
    const membershipWhere: any = {};
    if (typeof churchId === 'number') {
      membershipWhere.churchId = churchId;
    }
    if (typeof position === 'string' && position.trim().length > 0) {
      membershipWhere.membershipPositions = {
        some: { name: { contains: position.trim(), mode: 'insensitive' } },
      };
    }
    if (Object.keys(membershipWhere).length > 0) {
      (where as any).membership = membershipWhere;
    }

    const baseSelect = {
      id: true,
      name: true,
      phone: true,
      email: true,
      isActive: true,
      claimed: true,
      failedLoginAttempts: true,
      lockUntil: true,
      gender: true,
      maritalStatus: true,
      dob: true,
      createdAt: true,
      updatedAt: true,
      membership: {
        select: {
          id: true,
          churchId: true,
          columnId: true,
          baptize: true,
          sidi: true,
          createdAt: true,
          updatedAt: true,
          column: {
            select: {
              id: true,
              name: true,
              churchId: true,
              createdAt: true,
              updatedAt: true,
            },
          },
          membershipPositions: {
            select: {
              id: true,
              name: true,
              churchId: true,
              createdAt: true,
              updatedAt: true,
            },
          },
        },
      },
    } as const;

    // Tiered search: account.name -> membership.column.name -> membership.membershipPositions.name
    const normalizedSearch =
      typeof search === 'string' && search.trim().length > 0
        ? search.trim()
        : null;

    let activeWhere: Prisma.AccountWhereInput = { ...where };
    if (normalizedSearch) {
      activeWhere = {
        ...where,
        name: { contains: normalizedSearch, mode: 'insensitive' },
      };
    }

    let searchSource: string | null = null;

    let [total, accounts] = await (this.prisma as any).$transaction([
      (this.prisma as any).account.count({ where: activeWhere }),
      (this.prisma as any).account.findMany({
        where: activeWhere,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        select: baseSelect,
      }),
    ]);

    if (normalizedSearch) {
      searchSource = 'account.name';
    }

    if (normalizedSearch && total === 0) {
      // Fallback 2: search by column.name
      activeWhere = {
        ...where,
        membership: {
          ...(where.membership as any),
          column: { name: { contains: normalizedSearch, mode: 'insensitive' } },
        } as any,
      };

      [total, accounts] = await (this.prisma as any).$transaction([
        (this.prisma as any).account.count({ where: activeWhere }),
        (this.prisma as any).account.findMany({
          where: activeWhere,
          take,
          skip,
          orderBy: { [sortBy]: sortOrder },
          select: baseSelect,
        }),
      ]);

      if (normalizedSearch) {
        searchSource = 'column.name';
      }
    }

    if (normalizedSearch && total === 0) {
      // Fallback 3: search by membershipPositions.name
      activeWhere = {
        ...where,
        membership: {
          ...(where.membership as any),
          membershipPositions: {
            some: { name: { contains: normalizedSearch, mode: 'insensitive' } },
          },
        } as any,
      };

      [total, accounts] = await (this.prisma as any).$transaction([
        (this.prisma as any).account.count({ where: activeWhere }),
        (this.prisma as any).account.findMany({
          where: activeWhere,
          take,
          skip,
          orderBy: { [sortBy]: sortOrder },
          select: baseSelect,
        }),
      ]);

      if (normalizedSearch) {
        searchSource = 'membershipPosition.name';
      }
    }

    return {
      message: normalizedSearch ? `OK - ${searchSource}` : 'OK',
      data: accounts,
      total,
    };
  }

  async findOne(identifier: { accountId: number } | { phone: string }) {
    // Determine which identifier to use
    const where: Prisma.AccountWhereUniqueInput =
      'accountId' in identifier
        ? { id: identifier.accountId }
        : { phone: identifier.phone };

    const account = await this.prisma.account.findUniqueOrThrow({
      where,
      select: {
        id: true,
        name: true,
        phone: true,
        email: true,
        isActive: true,
        claimed: true,
        gender: true,
        maritalStatus: true,
        dob: true,
        createdAt: true,
        updatedAt: true,
        membership: {
          select: {
            id: true,
            columnId: true,
            baptize: true,
            sidi: true,
            createdAt: true,
            updatedAt: true,
            column: {
              select: {
                id: true,
                name: true,
                churchId: true,
                createdAt: true,
                updatedAt: true,
              },
            },
            membershipPositions: {
              select: {
                id: true,
                name: true,
                churchId: true,
                createdAt: true,
                updatedAt: true,
              },
            },
          },
        },
      },
    });

    return {
      message:
        'accountId' in identifier
          ? `OK - accountId: ${identifier.accountId}`
          : `OK - phone: ${identifier.phone}`,
      data: account,
    };
  }

  async count(params: AccountCountQueryDto) {
    const { churchId } = params;
    const baseMembershipWhere: any = {};
    if (typeof churchId === 'number') {
      baseMembershipWhere.churchId = churchId;
    }

    const totalWhere: Prisma.AccountWhereInput = {};
    if (Object.keys(baseMembershipWhere).length > 0) {
      (totalWhere as any).membership = baseMembershipWhere as any;
    }

    const claimedWhere: Prisma.AccountWhereInput = {
      ...totalWhere,
      claimed: true,
    };

    const baptizedWhere: Prisma.AccountWhereInput = {
      ...totalWhere,
      membership: (Object.keys(baseMembershipWhere).length > 0
        ? { ...baseMembershipWhere, baptize: true }
        : { baptize: true }) as any,
    };

    const sidiWhere: Prisma.AccountWhereInput = {
      ...totalWhere,
      membership: (Object.keys(baseMembershipWhere).length > 0
        ? { ...baseMembershipWhere, sidi: true }
        : { sidi: true }) as any,
    };

    const [total, claimed, baptized, sidi] = await this.prisma.$transaction([
      this.prisma.account.count({ where: totalWhere }),
      this.prisma.account.count({ where: claimedWhere }),
      this.prisma.account.count({ where: baptizedWhere }),
      this.prisma.account.count({ where: sidiWhere }),
    ]);

    return {
      message: 'OK',
      data: {
        total,
        claimed,
        baptized,
        sidi,
      },
    };
  }

  async create(createAccountDto: Prisma.AccountCreateInput) {
    // Allow flexible payloads that may include a simplified membership object
    // and transform them into Prisma nested create/connect shapes.
    const { membership: rawMembership, ...accountData } =
      (createAccountDto as any) || {};

    const data: Prisma.AccountCreateInput = { ...(accountData as any) } as any;

    if (rawMembership) {
      // Support two styles:
      // 1) Direct Prisma nested input already provided -> pass through as-is
      // 2) Simplified input with keys like churchId, columnId, membershipPositionIds, membershipPositionsCreate
      const isDirectPrismaShape =
        typeof rawMembership === 'object' &&
        (rawMembership.create ||
          rawMembership.connect ||
          rawMembership.connectOrCreate);

      if (isDirectPrismaShape) {
        (data as any).membership = rawMembership;
      } else {
        const {
          churchId,
          columnId,
          baptize,
          sidi,
          membershipPositionIds,
          membershipPositionsCreate,
          // power users may still pass direct prisma sub-shapes
          church,
          column,
          membershipPositions,
          ...restMembership
        } = rawMembership as any;

        const membershipCreate: any = { ...restMembership };
        if (typeof baptize === 'boolean') membershipCreate.baptize = baptize;
        if (typeof sidi === 'boolean') membershipCreate.sidi = sidi;

        if (typeof churchId === 'number') {
          membershipCreate.church = { connect: { id: churchId } };
        } else if (church) {
          // allow advanced users to pass prisma shape
          membershipCreate.church = church;
        }

        if (typeof columnId === 'number') {
          membershipCreate.column = { connect: { id: columnId } };
        } else if (column) {
          membershipCreate.column = column;
        }

        // Build membershipPositions relation operations
        const mpOps: any = {};
        if (
          Array.isArray(membershipPositionIds) &&
          membershipPositionIds.length > 0
        ) {
          mpOps.connect = membershipPositionIds.map((id: number) => ({ id }));
        }
        if (
          Array.isArray(membershipPositionsCreate) &&
          membershipPositionsCreate.length > 0
        ) {
          mpOps.create = membershipPositionsCreate.map((p: any) => ({
            name: p.name,
            ...(p?.churchId
              ? { church: { connect: { id: p.churchId } } }
              : p?.church
                ? { church: p.church }
                : {}),
          }));
        }
        if (membershipPositions) {
          // allow direct prisma operations for membershipPositions
          Object.assign(mpOps, membershipPositions);
        }
        if (Object.keys(mpOps).length > 0) {
          membershipCreate.membershipPositions = mpOps;
        }

        (data as any).membership = { create: membershipCreate };
      }
    }

    const account = await this.prisma.account.create({
      data,
      include: {
        membership: {
          include: {
            church: true,
            column: true,
            membershipPositions: true,
          },
        },
      },
    });
    if (account) {
      return {
        message: 'OK',
        data: account,
      };
    }
  }

  async update(id: number, updateAccountDto: Prisma.AccountUpdateInput) {
    // Allow flexible payloads that may include a simplified membership object
    // and transform them into Prisma nested update/upsert shapes.
    const { membership: rawMembership, ...accountData } =
      (updateAccountDto as any) || {};

    const data: Prisma.AccountUpdateInput = { ...(accountData as any) } as any;

    if (rawMembership) {
      // Support two styles:
      // 1) Direct Prisma nested input already provided -> pass through as-is
      // 2) Simplified input with keys like churchId, columnId, membershipPositionIds, etc.
      const isDirectPrismaShape =
        typeof rawMembership === 'object' &&
        (rawMembership.create ||
          rawMembership.update ||
          rawMembership.upsert ||
          rawMembership.connect ||
          rawMembership.connectOrCreate ||
          rawMembership.delete ||
          rawMembership.disconnect);

      if (isDirectPrismaShape) {
        (data as any).membership = rawMembership;
      } else {
        const {
          churchId,
          columnId,
          baptize,
          sidi,
          membershipPositionIds,
          membershipPositionsCreate,
          membershipPositionsDisconnect,
          // power users may still pass direct prisma sub-shapes
          church,
          column,
          membershipPositions,
          ...restMembership
        } = rawMembership as any;

        const membershipUpdate: any = { ...restMembership };
        if (typeof baptize === 'boolean') membershipUpdate.baptize = baptize;
        if (typeof sidi === 'boolean') membershipUpdate.sidi = sidi;

        if (typeof churchId === 'number') {
          membershipUpdate.church = { connect: { id: churchId } };
        } else if (churchId === null) {
          membershipUpdate.church = { disconnect: true };
        } else if (church) {
          // allow advanced users to pass prisma shape
          membershipUpdate.church = church;
        }

        if (typeof columnId === 'number') {
          membershipUpdate.column = { connect: { id: columnId } };
        } else if (columnId === null) {
          membershipUpdate.column = { disconnect: true };
        } else if (column) {
          membershipUpdate.column = column;
        }

        // Build membershipPositions relation operations
        const mpOps: any = {};
        if (
          Array.isArray(membershipPositionIds) &&
          membershipPositionIds.length > 0
        ) {
          mpOps.connect = membershipPositionIds.map((id: number) => ({ id }));
        }
        if (
          Array.isArray(membershipPositionsCreate) &&
          membershipPositionsCreate.length > 0
        ) {
          mpOps.create = membershipPositionsCreate.map((p: any) => ({
            name: p.name,
            ...(p?.churchId
              ? { church: { connect: { id: p.churchId } } }
              : p?.church
                ? { church: p.church }
                : {}),
          }));
        }
        if (
          Array.isArray(membershipPositionsDisconnect) &&
          membershipPositionsDisconnect.length > 0
        ) {
          mpOps.disconnect = membershipPositionsDisconnect.map(
            (id: number) => ({ id }),
          );
        }
        if (membershipPositions) {
          // allow direct prisma operations for membershipPositions
          Object.assign(mpOps, membershipPositions);
        }
        if (Object.keys(mpOps).length > 0) {
          membershipUpdate.membershipPositions = mpOps;
        }

        (data as any).membership = { update: membershipUpdate };
      }
    }

    const account = await this.prisma.account.update({
      where: { id: id },
      data,
      select: {
        id: true,
        name: true,
        phone: true,
        email: true,
        isActive: true,
        claimed: true,
        failedLoginAttempts: true,
        lockUntil: true,
        gender: true,
        maritalStatus: true,
        dob: true,
        createdAt: true,
        updatedAt: true,
        membership: {
          include: {
            column: true,
            membershipPositions: true,
          },
        },
      },
    });
    if (account) {
      return {
        message: 'OK',
        data: account,
      };
    }
  }

  async delete(id: number) {
    // Delete in transaction: first delete membership, then account
    await this.prisma.$transaction(async (tx) => {
      // Delete membership if exists
      await tx.membership.deleteMany({
        where: { accountId: id },
      });

      // Then delete the account
      await tx.account.delete({
        where: { id: id },
      });
    });

    return {
      message: 'OK',
      data: {},
    };
  }
}
