---
status: accepted
date: 2026-07-22
relates-to: "#22, #26"
---

# Push splits by category: announced notifications, silent change signals

Replacing Socket.IO rooms with FCM topics changes the trust model — topics are
client-subscribable and Firebase performs no authorization check, so anyone guessing a
church id can subscribe. The migration plan's answer was to strip all content from every
push and have the client refetch over authenticated REST.

That is correct for cache invalidation and **wrong for notifications**. Data-only
messages render nothing: the operating system draws a tray notification from the
`notification`/`aps.alert` block, which today's Pusher Beams path sends
(`pusher-beams.service.ts:106-127`). Removing it means a backgrounded or killed app shows
the user nothing, and iOS throttles or drops the silent `content-available` pushes that
would otherwise wake it. The plan would have deleted the notification feature as a side
effect of a security fix.

**Decision:** push splits by what the message is for.

- **Notifications** (`notification.*`) carry an OS-rendered title and body, written
  **deliberately generic** — "Ada pemberitahuan baru", never the entity's own title,
  actor name, or amount — plus routing data. The user taps through and the app fetches
  the real content over an authenticated path.
- **Change signals** (`activity.*`, `finance.*`, `approval.*`) stay data-only: event name
  and entity id, nothing else.

## Why generic text is not a leak

A self-subscribed stranger already learns "something happened in church N" from the
subscription itself — the original design accepts that. A generic title reveals exactly
that and no more. What must never travel is the payload today's helpers build:
`entityTitle`, `actorName`, `financeType`, `affectedMembershipIds`, `resultingStatus`.

The rule is **content-free, not notification-free**.

## Consequences

- No `onBackgroundMessage` handler is needed, and none should be added. The OS renders
  the notification; the app is not woken to construct one. Adding a background isolate
  would reintroduce dependence on the least reliable delivery path FCM offers.
- **Change signals invalidate; they do not refetch.** The client marks the provider stale
  and reads only when the screen is next viewed. Eager refetch would fan a single
  church-wide event out to every subscribed device — the amplification that drives the
  egress and per-request costs this project is otherwise trying to contain.
- Notification copy becomes a **security surface**. Anyone editing that string is editing
  what leaks to an unauthorised subscriber; it belongs under review, not in a translation
  file someone edits casually.
