import { ForbiddenException, UnauthorizedException } from '@nestjs/common';
import { PermissionsGuard } from './permissions.guard';

function contextFor(request: any) {
  return {
    getHandler: () => () => undefined,
    getClass: () => class {},
    switchToHttp: () => ({ getRequest: () => request }),
  } as any;
}

function guardWith(opts: {
  required?: string[];
  permissions?: string[];
  churchId?: number | null;
  membership?: any;
}) {
  const reflector = {
    getAllAndOverride: () => opts.required,
  } as any;
  const policy = {
    getEffectivePermissions: jest.fn(async () => ({
      data: { churchId: opts.churchId, permissions: opts.permissions },
    })),
  } as any;
  const prisma = {
    membership: { findUnique: jest.fn(async () => opts.membership) },
  } as any;
  return { guard: new PermissionsGuard(reflector, policy, prisma), policy, prisma };
}

describe('PermissionsGuard', () => {
  it('has no opinion on a route that declares no permission', async () => {
    const { guard, policy } = guardWith({ required: undefined });
    await expect(guard.canActivate(contextFor({}))).resolves.toBe(true);
    // and does not pay for a policy lookup to say so
    expect(policy.getEffectivePermissions).not.toHaveBeenCalled();
  });

  it('rejects an unauthenticated request on a permission-bearing route', async () => {
    const { guard } = guardWith({ required: ['ops.members.read'] });
    await expect(guard.canActivate(contextFor({}))).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('allows any-of and attaches churchId for the handler', async () => {
    const request = { user: { userId: 7 } };
    const { guard } = guardWith({
      required: ['ops.finance.revenue.create', 'ops.finance.expense.create'],
      permissions: ['ops.finance.expense.create'],
      churchId: 3,
    });
    await expect(guard.canActivate(contextFor(request))).resolves.toBe(true);
    expect((request as any).churchId).toBe(3);
    expect((request as any).allowedPermission).toBe('ops.finance.expense.create');
  });

  it('denies when the caller holds none of the required permissions', async () => {
    const { guard } = guardWith({
      required: ['ops.members.invite'],
      permissions: ['ops.members.read'],
      churchId: 3,
    });
    await expect(
      guard.canActivate(contextFor({ user: { userId: 7 } })),
    ).rejects.toThrow(ForbiddenException);
  });

  it('falls back to the membership when the policy returns no numeric churchId', async () => {
    // An elevated role with no membership row resolves churchId: null. Dropping
    // this fallback would break exactly the accounts with the most authority.
    const request = { user: { userId: 7, role: 'SUPER_ADMIN' } };
    const { guard, prisma } = guardWith({
      required: ['ops.members.read'],
      permissions: ['ops.members.read'],
      churchId: null,
      membership: { churchId: null, column: { churchId: 42 } },
    });
    await expect(guard.canActivate(contextFor(request))).resolves.toBe(true);
    expect(prisma.membership.findUnique).toHaveBeenCalled();
    expect((request as any).churchId).toBe(42);
  });
});
