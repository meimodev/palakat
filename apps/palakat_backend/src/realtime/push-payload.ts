import { Message } from 'firebase-admin/messaging';

/**
 * What a push is allowed to carry.
 *
 * FCM topics are client-subscribable: any app instance can call
 * `subscribeToTopic('church.123')` and Firebase performs no authorization
 * check. Unlike `sub.join`, there is no server anywhere in that path to refuse
 * it — so the *content* rule is the only control there is. §3 of the migration
 * plan, decision 13, ADR-0003.
 *
 * Socket rooms had the same weakness until #56 (`sub.join` took the room name
 * straight from the payload), so this is not a hole FCM opens. It is the same
 * boundary, now with no server-side veto available at all.
 *
 * Hence an allow-list, matching `room-authorization.ts`: `event`, and one id.
 * Everything the callers pass is dropped here — `entityTitle`, `actorName`,
 * `financeType`, `affectedMembershipIds`, `resultingStatus`, and in
 * `notification.created` the entire Notification row with its Activity
 * `include`d. A deny-list over payloads that eleven call sites compose
 * independently is a game you lose.
 *
 * The id survives because it is the one field that is useless without the read
 * it points at: the client uses it to mark a provider stale (§9.4) or to route
 * a tap, and both then fetch the real content over REST, where the caller is
 * authenticated and church-scoped.
 */

/**
 * Generic by design. This text is rendered by the OS on a locked screen, to
 * whoever subscribed to the topic — so it is a security surface, not copy.
 * Deliberately says nothing about what happened or to whom.
 */
export const PUSH_NOTIFICATION_TITLE = 'Palakat';
export const PUSH_NOTIFICATION_BODY = 'Ada pemberitahuan baru';

/**
 * Only a *new* notification draws an OS banner. `notification.updated` is
 * mark-as-read and `notification.deleted` is a dismissal — announcing "Ada
 * pemberitahuan baru" for either would be a lie the user can see. They travel
 * as change signals instead.
 */
const OS_RENDERED_EVENTS = new Set(['notification.created']);

/**
 * First match wins. `entityId` is what the approval helpers use, the rest are
 * what the individual call sites happen to name their key — the three emitter
 * helpers build `{ data: { ... } }` but the direct callers do not, so both
 * shapes have to be probed.
 */
const ID_KEYS = [
  'entityId',
  'activityId',
  'financeId',
  'fileId',
  'id',
] as const;

function extractEntityId(payload: unknown): string | undefined {
  const body = (payload as any)?.data ?? payload;
  if (!body || typeof body !== 'object') return undefined;

  for (const key of ID_KEYS) {
    const value = body[key];
    if (typeof value === 'number' && Number.isFinite(value)) {
      return String(value);
    }
    if (typeof value === 'string' && value.trim().length > 0) {
      return value;
    }
  }

  return undefined;
}

export function buildPushMessage(
  topic: string,
  event: string,
  payload: unknown,
): Message {
  const entityId = extractEntityId(payload);

  // FCM data values must all be strings (§2.2).
  const data: Record<string, string> = {
    event,
    ...(entityId != null ? { entityId } : {}),
  };

  if (OS_RENDERED_EVENTS.has(event)) {
    return {
      topic,
      data,
      notification: {
        title: PUSH_NOTIFICATION_TITLE,
        body: PUSH_NOTIFICATION_BODY,
      },
      android: { priority: 'high' },
    };
  }

  return {
    topic,
    data,
    android: { priority: 'high' },
    // Wakes the app to invalidate without drawing anything. Best-effort by
    // design — §9.4 says the refetch happens when a screen next needs it, so a
    // dropped signal costs a stale provider, not a missed notification.
    apns: { payload: { aps: { 'content-available': 1 } } },
  };
}
