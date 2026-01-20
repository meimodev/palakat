import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';

export type OperationPermissionKey =
  | 'ops.activity.create'
  | 'ops.members.read'
  | 'ops.members.invite'
  | 'ops.report.generate'
  | 'ops.finance.revenue.create'
  | 'ops.finance.expense.create';

type GrantMode = 'member' | 'positionsAny';

type PermissionGrant =
  | {
      mode: 'member';
    }
  | {
      mode: 'positionsAny';
      positionIds: number[];
    };

type ChurchPermissionPolicyV1 = {
  version: 1;
  grants: Record<OperationPermissionKey, PermissionGrant>;
};

const POLICY_VERSION = 1 as const;

const ALL_PERMISSIONS: OperationPermissionKey[] = [
  'ops.activity.create',
  'ops.members.read',
  'ops.members.invite',
  'ops.report.generate',
  'ops.finance.revenue.create',
  'ops.finance.expense.create',
];

const DEFAULT_POSITION_NAMES: Partial<
  Record<OperationPermissionKey, { mode: 'positionsAny'; names: string[] }>
> = {
  'ops.members.invite': { mode: 'positionsAny', names: ['Sekretaris'] },
  'ops.report.generate': {
    mode: 'positionsAny',
    names: ['Sekretaris', 'Bendahara'],
  },
  'ops.finance.revenue.create': {
    mode: 'positionsAny',
    names: ['Bendahara'],
  },
  'ops.finance.expense.create': {
    mode: 'positionsAny',
    names: ['Bendahara'],
  },
};

@Injectable()
export class ChurchPermissionPolicyService {
  constructor(private readonly prisma: PrismaService) {}

  private async resolveRequesterMembership(userId: number): Promise<{
    membershipId: number;
    churchId: number;
    positionIds: number[];
    positionNames: string[];
  }> {
    const membership = await (this.prisma as any).membership.findUnique({
      where: { accountId: userId },
      select: {
        id: true,
        churchId: true,
        column: {
          select: {
            churchId: true,
          },
        },
        membershipPositions: {
          select: { id: true, name: true },
        },
      },
    });

    if (!membership?.id) {
      throw new BadRequestException('User does not have a membership');
    }

    const derivedChurchId =
      membership?.churchId ?? (membership?.column?.churchId as number | null);

    if (!derivedChurchId) {
      throw new BadRequestException(
        'Account does not have an active membership',
      );
    }

    const positions = Array.isArray(membership.membershipPositions)
      ? membership.membershipPositions
      : [];

    return {
      membershipId: membership.id,
      churchId: derivedChurchId,
      positionIds: positions
        .map((p: any) => p?.id)
        .filter((id: any) => typeof id === 'number'),
      positionNames: positions
        .map((p: any) => (p?.name ?? '').toString().trim())
        .filter((n: string) => n.length > 0),
    };
  }

  private buildEmptyPolicy(): ChurchPermissionPolicyV1 {
    return {
      version: POLICY_VERSION,
      grants: {
        'ops.activity.create': { mode: 'member' },
        'ops.members.read': { mode: 'member' },
        'ops.members.invite': { mode: 'positionsAny', positionIds: [] },
        'ops.report.generate': { mode: 'positionsAny', positionIds: [] },
        'ops.finance.revenue.create': { mode: 'positionsAny', positionIds: [] },
        'ops.finance.expense.create': { mode: 'positionsAny', positionIds: [] },
      },
    };
  }

  private async buildDefaultPolicyForChurch(
    churchId: number,
  ): Promise<ChurchPermissionPolicyV1> {
    const byName = await (this.prisma as any).membershipPosition.findMany({
      where: {
        churchId,
        name: {
          in: Array.from(
            new Set(
              Object.values(DEFAULT_POSITION_NAMES)
                .flatMap((v) => v?.names ?? [])
                .filter((n) => n && n.trim().length > 0),
            ),
          ),
        },
      },
      select: { id: true, name: true },
    });

    const idByName = new Map<string, number>();
    for (const p of byName ?? []) {
      const name = (p?.name ?? '').toString().trim();
      if (!name) continue;
      if (typeof p?.id !== 'number') continue;
      idByName.set(name, p.id);
    }

    const base = this.buildEmptyPolicy();

    for (const key of ALL_PERMISSIONS) {
      if (key === 'ops.activity.create') continue;
      const def = DEFAULT_POSITION_NAMES[key];
      if (!def) continue;

      const ids = def.names
        .map((n) => idByName.get(n))
        .filter((id): id is number => typeof id === 'number');

      base.grants[key] = { mode: 'positionsAny', positionIds: ids };
    }

    return base;
  }

  private normalizePolicy(input: any): ChurchPermissionPolicyV1 {
    if (!input || typeof input !== 'object') {
      throw new BadRequestException('Invalid policy');
    }

    const version = (input as any).version;
    if (version !== POLICY_VERSION) {
      throw new BadRequestException('Invalid policy version');
    }

    const grantsRaw = (input as any).grants;
    if (!grantsRaw || typeof grantsRaw !== 'object') {
      throw new BadRequestException('Invalid grants');
    }

    const policy = this.buildEmptyPolicy();

    for (const key of ALL_PERMISSIONS) {
      const grant = (grantsRaw as any)[key];
      if (!grant || typeof grant !== 'object') continue;

      if (key === 'ops.activity.create' || key === 'ops.members.read') {
        policy.grants[key] = { mode: 'member' };
        continue;
      }

      const mode = (grant as any).mode;
      if (mode === 'positionsAny') {
        const idsRaw = (grant as any).positionIds;
        const ids = Array.isArray(idsRaw)
          ? idsRaw
              .map((v) => (typeof v === 'number' ? v : Number(v)))
              .filter((v) => Number.isFinite(v))
          : [];

        policy.grants[key] = { mode: 'positionsAny', positionIds: ids };
      } else if (mode === 'member') {
        policy.grants[key] = { mode: 'member' };
      }
    }

    return policy;
  }

  private async assertCanManagePolicy(user: {
    userId: number;
    role?: string;
  }): Promise<{ churchId: number }> {
    if (user?.role === 'SUPER_ADMIN') {
      const membership = await (this.prisma as any).membership.findUnique({
        where: { accountId: user.userId },
        select: {
          churchId: true,
          column: {
            select: {
              churchId: true,
            },
          },
        },
      });
      const churchId = membership?.churchId ?? membership?.column?.churchId;
      if (churchId) return { churchId };
      throw new BadRequestException(
        'Account does not have an active membership',
      );
    }

    const requester = await this.resolveRequesterMembership(user.userId);

    const normalized = new Set(
      requester.positionNames.map((n) => n.toLowerCase().trim()),
    );

    const allowed =
      normalized.has('ketua majelis') ||
      normalized.has('sekretaris') ||
      normalized.has('pengurus harian');

    if (!allowed) {
      throw new ForbiddenException('Insufficient permission');
    }

    return { churchId: requester.churchId };
  }

  private async ensurePolicyExists(churchId: number) {
    const existing = await (
      this.prisma as any
    ).churchPermissionPolicy.findUnique({
      where: { churchId },
      select: { id: true },
    });

    if (existing?.id) return;

    const policy = await this.buildDefaultPolicyForChurch(churchId);

    await (this.prisma as any).churchPermissionPolicy.create({
      data: {
        church: { connect: { id: churchId } },
        policy: policy as any,
      },
    });
  }

  async getMe(user: { userId: number }) {
    const requester = await this.resolveRequesterMembership(user.userId);

    await this.ensurePolicyExists(requester.churchId);

    const row = await (this.prisma as any).churchPermissionPolicy.findUnique({
      where: { churchId: requester.churchId },
      select: { churchId: true, policy: true, updatedAt: true },
    });

    return { message: 'OK', data: row };
  }

  async updateMe(payload: any, user: { userId: number; role?: string }) {
    const { churchId } = await this.assertCanManagePolicy(user);

    const normalized = this.normalizePolicy(payload?.policy);

    const grant = normalized.grants;
    const positionIds = Array.from(
      new Set(
        Object.values(grant)
          .flatMap((g: any) =>
            g?.mode === 'positionsAny' ? g.positionIds : [],
          )
          .filter((v: any) => typeof v === 'number'),
      ),
    );

    if (positionIds.length > 0) {
      const found = await (this.prisma as any).membershipPosition.findMany({
        where: {
          id: { in: positionIds },
          churchId,
        },
        select: { id: true },
      });

      const foundIds = new Set(found.map((p: any) => p.id));
      const invalid = positionIds.filter((id) => !foundIds.has(id));
      if (invalid.length > 0) {
        throw new BadRequestException('Invalid positionIds');
      }
    }

    await this.ensurePolicyExists(churchId);

    const updated = await (this.prisma as any).churchPermissionPolicy.update({
      where: { churchId },
      data: { policy: normalized as any },
      select: { churchId: true, policy: true, updatedAt: true },
    });

    return { message: 'OK', data: updated };
  }

  async getEffectivePermissions(user: { userId: number; role?: string }) {
    if (user?.role === 'SUPER_ADMIN') {
      return {
        message: 'OK',
        data: {
          permissions: ALL_PERMISSIONS,
        },
      };
    }

    const requester = await this.resolveRequesterMembership(user.userId);

    await this.ensurePolicyExists(requester.churchId);

    const row = await (this.prisma as any).churchPermissionPolicy.findUnique({
      where: { churchId: requester.churchId },
      select: { policy: true, updatedAt: true },
    });

    const policy = this.normalizePolicy(row?.policy);

    const membershipPositionIds = new Set(requester.positionIds);
    const permissions: OperationPermissionKey[] = [];

    for (const key of ALL_PERMISSIONS) {
      const grant = policy.grants[key];
      if (!grant) continue;

      if (grant.mode === 'member') {
        permissions.push(key);
        continue;
      }

      if (
        grant.mode === 'positionsAny' &&
        Array.isArray((grant as any).positionIds) &&
        (grant as any).positionIds.some((id: number) =>
          membershipPositionIds.has(id),
        )
      ) {
        permissions.push(key);
      }
    }

    return {
      message: 'OK',
      data: {
        churchId: requester.churchId,
        permissions,
        policyUpdatedAt: row?.updatedAt ?? null,
      },
    };
  }
}
