import { BadRequestException } from '@nestjs/common';

/**
 * The requester's church, resolved from their membership — directly, or via the
 * column they belong to.
 *
 * This is the fallback `getEffectivePermissions` needs when it returns no
 * numeric `churchId` (elevated roles with no membership row resolve `null`).
 * It lives here rather than in either caller because the RPC router and the
 * HTTP guard must not drift: they are two doors onto the same authorization
 * decision, and a difference between them is a scoping bug.
 */
export async function resolveRequesterChurchId(
  prisma: any,
  userId: number,
): Promise<number> {
  const membership = await prisma.membership.findUnique({
    where: { accountId: userId },
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
  if (!churchId) {
    throw new BadRequestException('Account does not have an active membership');
  }
  return churchId;
}
