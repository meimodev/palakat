import { SetMetadata } from '@nestjs/common';

export const PERMISSIONS_KEY = 'permissions';

/**
 * The permissions a route accepts. Semantics are **any-of**, matching the RPC
 * path's `requireAnyOperationPermission`: the caller needs one of them, not all.
 * A single-permission route is just the one-element case, which is what
 * `requireOperationPermission` was.
 *
 * The set on each route is transcribed from the generated parity table, and CI
 * asserts it still equals the RPC case's allow-list — see
 * `scripts/check-permission-parity.ts`.
 */
export const RequirePermissions = (...permissions: string[]) =>
  SetMetadata(PERMISSIONS_KEY, permissions);
