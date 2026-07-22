import { ForbiddenException } from '@nestjs/common';

/**
 * Church scoping for reads, as two pure decisions.
 *
 * The router resolves the requester's church and calls these; the decisions
 * live here so they can be tested without constructing `RpcRouterService` and
 * its thirty-odd dependencies. Same reasoning as `room-authorization.ts`.
 *
 * These are invisible to the parity table — it reads guard *helpers*, and a
 * `where` clause is not one. Tests are the only evidence that they exist, so
 * they are the point of this file, not a formality.
 */

/**
 * Force a list query onto the requester's own church.
 *
 * A `churchId` naming another church is **rejected, not overwritten**. Silently
 * substituting the caller's own church would answer a question they did not
 * ask, and hide from them that the answer was "no" — the same reason
 * `approver.list` rejects rather than ignores. It was the only read in the
 * router that already got this right.
 */
export function scopeQueryToChurch<T extends Record<string, any>>(
  query: T,
  requesterChurchId: number,
): T & { churchId: number } {
  const asked = query?.churchId;
  if (asked !== undefined && asked !== null && asked !== requesterChurchId) {
    throw new ForbiddenException('Not entitled to this church');
  }
  return { ...query, churchId: requesterChurchId };
}

/**
 * Assert a fetched row belongs to the requester's church.
 *
 * A non-numeric `rowChurchId` fails closed. That case is not hypothetical:
 * `Column`, `Membership` and `MembershipPosition` all declare `churchId` as
 * nullable, so a row genuinely can carry none — and a row that cannot be
 * scoped is refused rather than waved through.
 */
export function assertRowInChurch(
  rowChurchId: unknown,
  requesterChurchId: number,
): void {
  if (
    typeof rowChurchId !== 'number' ||
    rowChurchId !== requesterChurchId
  ) {
    throw new ForbiddenException('Not entitled to this record');
  }
}
