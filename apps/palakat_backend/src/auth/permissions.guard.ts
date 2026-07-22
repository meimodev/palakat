import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS_KEY } from './permissions.decorator';
import { ChurchPermissionPolicyService } from '../church-permission-policy/church-permission-policy.service';
import { resolveRequesterChurchId } from '../church-permission-policy/resolve-requester-church-id';
import { PrismaService } from '../prisma.service';

/**
 * The HTTP half of the authorization model. It is a **verbatim port** of
 * `requireAnyOperationPermission` (`rpc-router.service.ts`), and deliberately
 * not an improvement on it: the permission model is not redesigned during a
 * transport migration. Any change to the model is a separate change with its
 * own review.
 *
 * Two details that are easy to lose and both matter:
 *
 * - **`churchId` is attached to the request.** RPC handlers receive it from the
 *   same call that authorizes them, and the ported services still read it. A
 *   guard that only answers allow/deny leaves every handler to re-resolve the
 *   caller's church, which is where scoping bugs come from.
 * - **The fallback path is part of the contract.** `getEffectivePermissions`
 *   returns `churchId: null` for an elevated role with no membership row, so
 *   the RPC helper falls back to resolving it from the membership. Dropping
 *   that fallback would 500 exactly the accounts with the most authority.
 */
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly policy: ChurchPermissionPolicyService,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const required = this.reflector.getAllAndOverride<string[]>(
      PERMISSIONS_KEY,
      [context.getHandler(), context.getClass()],
    );

    // No permission declared -> this guard has no opinion. Whether the route is
    // legitimately public is asserted by Phase 2's gate, not here.
    if (!required || required.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request?.user;
    if (!user?.userId) {
      throw new UnauthorizedException('Unauthenticated');
    }

    const res: any = await this.policy.getEffectivePermissions(user);
    const perms = res?.data?.permissions;

    // any-of, and the RPC path's ordering: the first *required* permission the
    // caller holds wins, not the first held permission that is required.
    const allowedPermission = Array.isArray(perms)
      ? required.find((p) => perms.includes(p))
      : undefined;

    if (!allowedPermission) {
      throw new ForbiddenException('Insufficient permission');
    }

    request.churchId =
      typeof res?.data?.churchId === 'number'
        ? (res.data.churchId as number)
        : await resolveRequesterChurchId(this.prisma, user.userId);
    request.allowedPermission = allowedPermission;

    return true;
  }
}
