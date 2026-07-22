/**
 * Who may join which socket room.
 *
 * `sub.join` used to take the room name straight from the payload and call
 * `client.join(room)` with no check at all, so any authenticated user could
 * join `church.{any id}` and receive that church's activity, finance and
 * approval events — payloads that carry `entityTitle`, `actorName`,
 * `financeType`, `affectedMembershipIds` and `resultingStatus`.
 *
 * This also corrects a claim in §3 of the migration plan, which contrasts
 * "server-controlled" socket rooms with "client-controlled" FCM topics. The
 * rooms were client-controlled too. The content-free push rule in Phase 4 is
 * what finally closes this, not what opens it.
 *
 * The grammar is fixed by `pusher-beams.service.ts`, which formats every
 * interest name the system uses:
 *
 *   palakat                                             global
 *   account.{accountId}
 *   membership.{membershipId}
 *   membership.{membershipId}.birthday
 *   church.{churchId}
 *   church.{churchId}_bipra.{BIPRA}
 *   church.{churchId}_column.{columnId}
 *   church.{churchId}_column.{columnId}_bipra.{BIPRA}
 *
 * Anything not matching is refused. An allow-list is the only safe shape here:
 * a deny-list on a name the caller composes is a game you lose.
 */
export interface RoomScope {
  accountId: number;
  membershipId?: number | null;
  churchId?: number | null;
  columnId?: number | null;
}

const GLOBAL_ROOM = 'palakat';

// BIPRA is not a Membership column, so it cannot be checked against the caller.
// The church (and column, when named) is the trust boundary that matters —
// crossing it is the leak. Within-church BIPRA granularity is a delivery
// nicety, not a boundary.
const PATTERNS: {
  re: RegExp;
  allows: (m: RegExpMatchArray, s: RoomScope) => boolean;
}[] = [
  {
    re: /^account\.(\d+)$/,
    allows: (m, s) => Number(m[1]) === s.accountId,
  },
  {
    re: /^membership\.(\d+)(\.birthday)?$/,
    allows: (m, s) => s.membershipId != null && Number(m[1]) === s.membershipId,
  },
  {
    re: /^church\.(\d+)$/,
    allows: (m, s) => s.churchId != null && Number(m[1]) === s.churchId,
  },
  {
    re: /^church\.(\d+)_bipra\.([A-Za-z]+)$/,
    allows: (m, s) => s.churchId != null && Number(m[1]) === s.churchId,
  },
  {
    re: /^church\.(\d+)_column\.(\d+)(?:_bipra\.([A-Za-z]+))?$/,
    allows: (m, s) =>
      s.churchId != null &&
      Number(m[1]) === s.churchId &&
      s.columnId != null &&
      Number(m[2]) === s.columnId,
  },
];

export function canJoinRoom(room: string, scope: RoomScope): boolean {
  if (room === GLOBAL_ROOM) return true;
  for (const { re, allows } of PATTERNS) {
    const m = room.match(re);
    if (m) return allows(m, scope);
  }
  return false;
}
