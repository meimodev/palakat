# Who sends push notifications once Nest is gone?

Ticket: [meimodev/palakat#22](https://github.com/meimodev/palakat/issues/22) · Parent map: [#14](https://github.com/meimodev/palakat/issues/14)

## Verdict

Move to **FCM direct**. `firebase-admin` is already a backend dependency (used today for phone auth), so adding Cloud Messaging is a config change, not a new vendor — and it's free at any scale, unlike Pusher Beams' subscriber-tiered pricing. More decisively: this repo's own history shows Pusher Beams' web SDK already had to be surgically removed and replaced with a no-op stub, workspace-wide, because it broke the Flutter web build — web push notifications are dead today under Pusher Beams. Whichever thin server survives the Nest removal (an Edge Function called from application code) should call FCM's HTTP v1 API directly; do not move notification-sending into a database trigger/webhook.

## 1. Can Pusher Beams be driven from a Supabase Edge Function (Deno)?

Supabase Edge Functions run on Deno and support importing npm packages via the `npm:` specifier, with per-function `deno.json` recommended over global import maps ([Supabase: Managing dependencies](https://supabase.com/docs/guides/functions/import-maps)). Deno's Node compatibility layer supports npm packages that don't rely on native addons/postinstall build scripts; packages using Node-API addons need a local `node_modules` dir and `--allow-ffi`, and "if it doesn't work" is explicitly flagged for packages whose native bindings depend on skipped lifecycle scripts ([Deno: Node and npm compatibility](https://docs.deno.com/runtime/fundamentals/node/)).

`@pusher/push-notifications-server` is a thin REST wrapper (HTTP client + JWT signing for client auth), not a native-binding package, so `npm:@pusher/push-notifications-server` would plausibly load under Deno. But there's no reason to carry the dependency at all: the Publish API is a plain authenticated REST call —

```
POST https://<INSTANCE_ID>.pushnotifications.pusher.com/publish_api/v1/instances/<INSTANCE_ID>/publishes/interests
```

— with a JSON body containing `interests` (1–100 per request, each name ≤164 chars, body ≤10 KiB) and one or more of `apns`/`fcm`/`web` payloads ([Pusher Beams: Publish API](https://pusher.com/docs/beams/reference/publish-api/)). Deno's built-in `fetch` calls this directly with zero dependencies. **The REST API is the practical path**, not the npm-wrapped Node SDK — this sidesteps any Deno/npm compatibility risk entirely.

## 2. Can it be driven from a database trigger/webhook instead of application code?

Yes, mechanically: Supabase Database Webhooks are "a convenience wrapper around triggers using the `pg_net` extension. This extension is asynchronous, and therefore will not block your database changes for long-running network requests" ([Supabase: Database Webhooks](https://supabase.com/docs/guides/database/webhooks)). `pg_net` requests are not even started until the triggering transaction commits, which is why it's safe to call from a blocking trigger context ([Supabase: pg_net](https://supabase.com/docs/guides/database/extensions/pg_net)).

**Failure/retry semantics are the problem.** `pg_net` has no built-in automatic retry. A request's outcome (status code, `error_msg`, `timed_out` flag) is written to `net._http_response`, but that table is `UNLOGGED` — responses are "not preserved during a crash or unclean shutdown" — and rows expire after 6 hours by default ([Supabase: pg_net — Analyzing responses](https://supabase.com/docs/guides/database/extensions/pg_net)). Because the HTTP call fires post-commit and async, a failed push never rolls back or blocks the write that triggered it (good), but nothing re-tries it and nothing surfaces the failure unless you build a separate poller against `net._http_response` before it ages out. The current `pusher-beams.service.ts` already does the safer thing in application code: catch, log, and continue without throwing (`publishToInterests` swallows errors — see source, lines 135–142). A DB-trigger/pg_net path would silently regress that to "best-effort with no error visibility," not improve it. **Recommendation: keep notification-sending in application code (an Edge Function called explicitly from the mutation flow), not in a DB trigger.**

## 3. Is FCM direct simpler than keeping Pusher Beams?

| | Pusher Beams | FCM direct |
|---|---|---|
| **Setup cost** | Separate vendor, own instance ID + secret key, own Node SDK or REST auth scheme | `firebase-admin` already a dependency in `apps/palakat_backend/src/firebase/firebase-admin.service.ts` for phone auth (`getAuth`) and storage — same service-account credentials (`FIREBASE_PROJECT_ID`/`FIREBASE_CLIENT_EMAIL`/`FIREBASE_PRIVATE_KEY`) already configured. Adding `getMessaging(app).send()` is a few lines, no new vendor onboarding. |
| **Cost at scale** | Free "Sandbox" tier caps at 1,000 subscribers; $29/mo for 10k, $99/mo for 50k, up to $399/mo for 250k ([Pusher Beams pricing](https://pusher.com/beams/pricing/)) | Cloud Messaging is "No-cost" on both the Spark and Blaze plans, no usage-based charges ([Firebase pricing](https://firebase.google.com/pricing)) |
| **Topic/segment support** | "Device Interests" — pub/sub model, max 100 interests per publish call, interest name ≤164 chars ([Pusher Beams: Publish API](https://pusher.com/docs/beams/reference/publish-api/), [Device Interests concept](https://pusher.com/docs/beams/concepts/device-interests/)) | FCM Topics — same pub/sub model, devices subscribe/unsubscribe by topic string via `subscribeToTopic`/`unsubscribeFromTopic` ([Firebase: Manage Topic Subscriptions](https://firebase.google.com/docs/cloud-messaging/manage-topics)). This repo's existing interest-naming scheme (`church.{id}_bipra.{X}`, `membership.{id}`, `membership.{id}.birthday`, `account.{id}`, global `palakat` — see `pusher-beams.service.ts` `format*Interest` methods) maps 1:1 onto FCM topic name strings; the naming scheme survives the swap unchanged. |
| **Delivery reporting** | Partial: `PublishToUsersAttempt` webhook reports gateway-acceptance per user; `UserNotificationAcknowledgement` reports device-level "delivered" (requires iOS SDK ≥1.3.0 / Android SDK ≥1.4.0); `UserNotificationOpen` tracks opens — but the docs explicitly note some devices never report acknowledgement due to connectivity/OS limits ([Pusher Beams: Webhook Reference](https://pusher.com/docs/beams/reference/webhooks/)) | `messaging.send()` / multicast calls return per-message success/failure synchronously at send time (accepted-by-FCM confirmation, same granularity as Beams' gateway-acceptance report) via the Admin SDK messaging module ([Firebase Admin Node: messaging package](https://firebase.google.com/docs/reference/admin/node/firebase-admin.messaging)); FCM's REST endpoint is callable with a plain OAuth2-signed POST with no SDK required if preferred ([Firebase: FCM HTTP v1 API](https://firebase.google.com/docs/cloud-messaging/http-server-ref)). This repo isn't currently consuming Beams' richer open/ack webhooks, so no functionality is actually lost. |

Net: FCM direct is simpler on every axis that matters here — zero new setup (dependency already present), zero cost, equivalent interest/topic modeling, and delivery reporting parity for what this codebase actually uses today.

## 4. What do the Flutter clients have to change?

More than "nothing," and the repo's own history is the strongest evidence in this whole ticket. Commit `0285286` ("fix wasm build error on palakat admin") replaced the **official** `pusher_beams_web` package with a local no-op stub, `packages/pusher_beams_web_stub/lib/pusher_beams_web.dart` (a `registerWith` that does nothing), wired in via a **workspace-root** `dependency_overrides` in `pubspec.yaml`:

```yaml
dependency_overrides:
  pusher_beams_web:
    path: packages/pusher_beams_web_stub
```

Because this override lives in the root `pubspec.yaml`, it applies to every Flutter app in the monorepo, not just `palakat_admin`. The same commit deleted `apps/palakat_admin/web/service-worker.js`, which had done `importScripts('https://js.pusher.com/beams/service-worker.js')` — the official Pusher Beams web SDK broke Flutter's WASM web compilation, so it was cut out entirely. **Web push via Pusher Beams is completely disabled today, everywhere in this repo** — not a hypothetical gap the ticket is speculating about.

For contrast, the official `pusher_beams` Flutter package does claim Web/Android/iOS support with per-platform feature parity gaps even before the WASM issue (`onInterestChanges`, `onMessageReceivedInTheForeground`, `getInitialMessage`, `setUserId` are all unavailable on web per its own compatibility table) ([pub.dev: pusher_beams](https://pub.dev/packages/pusher_beams)).

`firebase_messaging` (official FlutterFire plugin) supports Android, iOS, and Web via `firebase_messaging_web` with no reported WASM conflict, and — notably — **this repo already depends on it**: `apps/palakat/pubspec.yaml` line 52 lists `firebase_messaging: ^15.1.5  # Required for Pusher Beams FCM integration` (Pusher's own Android transport rides on FCM under the hood). Moving to FCM direct means:

- Remove `pusher_beams` and the `packages/pusher_beams_web_stub` override/package entirely.
- Swap `PusherBeamsMobileService`/`pusher_beams_controller.dart`'s interest register/unregister calls for `FirebaseMessaging.instance.subscribeToTopic(...)` / `unsubscribeFromTopic(...)`, reusing the exact same interest-name strings as topic names.
- Keep the existing foreground/background message handling pattern (`onMessage`, `onMessageOpenedApp`) — conceptually the same shape `firebase_messaging` already exposes and that the app already imports.
- Delete the dead `pusher_beams_web_stub` package and its root `dependency_overrides` entry, since nothing needs a stub once the real vendor is gone.

This is a net reduction in Flutter dependency surface (two packages and a workspace override removed), not an addition.

## 5. Recommendation

**Move to FCM.** `firebase-admin` is already wired into the backend for auth and storage, so sending push via `getMessaging(app).send()`/multicast — or the raw HTTP v1 REST endpoint if the surviving compute is a Deno Edge Function — costs no new vendor setup and no new secret management, versus Pusher Beams' separate instance ID/secret key pair. It's free at any scale, where Pusher Beams starts charging past 1,000 subscribers. Its Topics model is a drop-in replacement for Pusher's Interests, using the exact same naming scheme already implemented in `pusher-beams.service.ts`. And on the client, the repo has already been forced to gut Pusher Beams' web support with a no-op stub because the real SDK broke the Flutter web build — while `firebase_messaging` is already a dependency, already used to make Pusher's own Android delivery work, and has no equivalent web breakage. Keeping Pusher Beams post-Nest would mean carrying a second paid vendor, a broken web platform, and a Deno-compatibility question that FCM's plain REST API sidesteps outright — for no capability this app actually uses that FCM lacks. Whichever thin service survives (an Edge Function invoked from application code, not a DB trigger — see §2 on `pg_net`'s lack of retry) should call FCM directly.

## Sources

- [Supabase: Managing dependencies (Edge Functions)](https://supabase.com/docs/guides/functions/import-maps)
- [Supabase: Edge Functions limits](https://supabase.com/docs/guides/functions/limits)
- [Deno: Node and npm compatibility](https://docs.deno.com/runtime/fundamentals/node/)
- [Supabase: Database Webhooks](https://supabase.com/docs/guides/database/webhooks)
- [Supabase: pg_net — Async Networking](https://supabase.com/docs/guides/database/extensions/pg_net)
- [Pusher Beams: Publish API](https://pusher.com/docs/beams/reference/publish-api/)
- [Pusher Beams: Node.js Server SDK](https://pusher.com/docs/beams/reference/server-sdk-node/)
- [Pusher Beams: Device Interests concept](https://pusher.com/docs/beams/concepts/device-interests/)
- [Pusher Beams: Webhook Reference](https://pusher.com/docs/beams/reference/webhooks/)
- [Pusher Beams pricing](https://pusher.com/beams/pricing/)
- [Firebase pricing](https://firebase.google.com/pricing)
- [Firebase Admin Node SDK: messaging package](https://firebase.google.com/docs/reference/admin/node/firebase-admin.messaging)
- [Firebase: Manage Topic Subscriptions](https://firebase.google.com/docs/cloud-messaging/manage-topics)
- [Firebase: FCM HTTP v1 API reference](https://firebase.google.com/docs/cloud-messaging/http-server-ref)
- [pub.dev: pusher_beams](https://pub.dev/packages/pusher_beams)
- [pub.dev: firebase_messaging](https://pub.dev/packages/firebase_messaging)

## Grounding in this repo (secondary, but load-bearing for §4)

- `apps/palakat_backend/src/notification/pusher-beams.service.ts` — current Pusher Beams wrapper, interest-naming scheme, swallow-and-log error handling.
- `apps/palakat_backend/src/firebase/firebase-admin.service.ts` — `firebase-admin` already initialized with a service account for `auth()`/`storage()`.
- `apps/palakat/pubspec.yaml:52` — `firebase_messaging: ^15.1.5  # Required for Pusher Beams FCM integration` (already present).
- `pubspec.yaml` (workspace root) — `dependency_overrides: pusher_beams_web: path: packages/pusher_beams_web_stub`.
- `packages/pusher_beams_web_stub/lib/pusher_beams_web.dart` — no-op `registerWith`.
- Commit `0285286` "fix wasm build error on palakat admin" — deleted `apps/palakat_admin/web/service-worker.js` (which loaded `https://js.pusher.com/beams/service-worker.js`) and introduced the stub above because the real web SDK broke WASM compilation.
