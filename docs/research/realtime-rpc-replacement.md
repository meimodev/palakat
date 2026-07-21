# What replaces the Socket.IO RPC router on Supabase?

Wayfinder ticket: [#18](https://github.com/meimodev/palakat/issues/18) (part of map [#14](https://github.com/meimodev/palakat/issues/14))
Researched: 2026-07-21

## Verdict

Supabase Realtime is **not** a request/response RPC transport — it is strictly pub/sub (Broadcast, Presence, Postgres Changes), so `rpc-router.service.ts`'s ~100 `request → single reply` methods cannot be ported 1:1 onto a Realtime channel. They map instead to PostgREST `rpc()` calls or Edge Functions, both of which already exist as the parallel REST surface (132 routes / 27 controllers) this router duplicates. The one piece Realtime genuinely adds — server-pushed events (approval status, notifications) — is well covered by Postgres Changes/Broadcast-from-DB, and chunked binary upload is directly replaceable by Supabase Storage's TUS resumable-upload protocol, **except that TUS has no first-party Dart/Flutter implementation** (JS, Swift, Kotlin, Python are documented; Flutter is not), which is a real integration gap, not a blocker. Net: the RPC router should be **deleted, not ported** — its request/response methods collapse into the REST surface that already exists, and its push-notification role is better served by Postgres Changes/Broadcast, eliminating the Socket.IO gateway, the Redis adapter, and 4,009 lines of custom routing entirely.

## 1. What Supabase Realtime provides today

Source: [Realtime overview](https://supabase.com/docs/guides/realtime), [Realtime Concepts](https://supabase.com/docs/guides/realtime/concepts.md)

Three primitives, all built on a `channel` (a named topic/"room"):

- **Broadcast** — send low-latency, ephemeral messages between clients on a channel. Can originate from: client libraries, the REST API (`POST /realtime/v1/api/broadcast`, single or batched), or **directly from the database** via SQL functions. ([Broadcast docs](https://supabase.com/docs/guides/realtime/broadcast.md))
- **Presence** — each client publishes a small state payload to a shared channel; Realtime tracks and diffs it, emitting `sync`/`join`/`leave` events to all subscribers. Not a general message bus — scoped to "who is here and what is their state." ([Presence docs](https://supabase.com/docs/guides/realtime/presence.md))
- **Postgres Changes** — subscribe to `INSERT`/`UPDATE`/`DELETE` on Postgres tables; Realtime reads the WAL and pushes matching row changes to subscribed clients. Requires the table to be added to a publication (`supabase_realtime`), and — critically — **is gated by Row Level Security**: a subscribing client's role/JWT must satisfy a `SELECT` policy on the table (or on the relevant `realtime.messages` policies for private channels) to receive an event at all. ([Postgres Changes docs](https://supabase.com/docs/guides/realtime/postgres-changes.md))

### Broadcast-from-database (confirmed to exist)

Source: [Broadcast docs, "Broadcast from the Database" section](https://supabase.com/docs/guides/realtime/broadcast.md)

Two SQL-callable primitives plus a convenience trigger helper:

```sql
select realtime.send(
  jsonb_build_object('hello', 'world'), -- JSONB payload
  'event',                              -- event name
  'topic',                              -- topic
  false                                 -- public/private flag
);

select realtime.send_binary(
  '\x012345'::bytea, -- bytea payload
  'event', 'topic', true
);
```

- `realtime.broadcast_changes()` is a documented helper for wiring a table trigger that broadcasts on insert/update/delete, referenced from the Broadcast doc and detailed in ["Subscribing to Database Changes"](https://supabase.com/docs/guides/realtime/subscribing-to-database-changes).
- Mechanically, "Broadcast from the Database" works by Realtime reading the WAL via a publication against the internal `realtime.messages` table — messages land in a day-partitioned table and are auto-deleted after 3 days, then relayed over the same WebSocket transport as client-side broadcast.
- Public/private flags must match between the SQL call and the client's channel config or the message is silently dropped.
- **Binary broadcast client-version gate**: binary messages (`realtime.send_binary`) "only reach clients on supabase-js 2.91.0 and supabase-swift 2.44.0 or later; older clients silently drop them." **No Dart/Flutter client version is listed** — treat Dart binary-broadcast support as unverified/likely unsupported until confirmed against the `supabase-dart`/`realtime_client` changelog.

This is the recommended mechanism for "server-pushed events" (approval status changes, notifications, operations updates) — it decouples the push from Postgres Changes' RLS-per-row-read model and instead lets a trigger explicitly shape and broadcast a payload.

## 2. Can request/response RPC be expressed over Realtime? — No, definitively

Sources: [Realtime Concepts](https://supabase.com/docs/guides/realtime/concepts.md), [Broadcast docs](https://supabase.com/docs/guides/realtime/broadcast.md)

Realtime's message primitives are all **fire-and-forget publish**, not request/response:

- `channel.send({type: 'broadcast', ...})` returns only a local send-status (`'ok' | 'timed out' | 'rate limited'`), confirming the message reached the Realtime server — not that any specific peer processed it and produced a result. The docs describe an optional `acknowledgeBroadcasts` config that confirms *receipt by the server*, explicitly distinguished from any application-level reply.
- There is no built-in "reply-to" / correlation-ID / RPC envelope in the Broadcast, Presence, or Postgres Changes wire protocols. Building request/response semantics (e.g., a client broadcasts a request, a server-side listener processes it and broadcasts a correlated response on the same or a reply channel) would be **entirely custom application code layered on top of pub/sub** — Supabase does not provide this as a primitive, unlike Socket.IO's `emit`-with-`ack`/`.on('event', (data, callback) => ...)` pattern that `rpc-router.service.ts` currently relies on.

Conclusion: request/response RPC is not expressible as a first-class Supabase Realtime capability. Anything shaped like `auth.signIn` (compute a result and hand it back to the caller synchronously) does not belong on Realtime at all — it belongs on PostgREST `rpc()` or an Edge Function, both genuinely request/response HTTP mechanisms.

## 3. Replacement shape for the ~100 RPC methods

Sources: [Database Functions guide](https://supabase.com/docs/guides/database/functions.md), [Dart `rpc()` reference](https://supabase.com/docs/reference/dart/rpc), [Edge Functions guide](https://supabase.com/docs/guides/functions.md), [Dart `functions.invoke()` reference](https://supabase.com/docs/reference/dart/functions-invoke)

Three usable request/response mechanisms, all HTTP-based:

| Mechanism | Shape | Client-side cost |
|---|---|---|
| **PostgREST auto-generated CRUD** | `supabase.from('table').select/insert/update/delete()` — direct table access gated by RLS | Lowest cost; no server code to write per method, but only works for straightforward CRUD (most `*.get`, `*.list`, `*.create`, `*.update`, `*.delete` methods in the router) |
| **Postgres function via `rpc()`** | `supabase.rpc('fn_name', params: {...})` calling a `plpgsql`/SQL function | Low cost; one Dart call per method (`dart-rpc` reference confirms `fn` + `params` signature), logic lives in the DB, `security definer` functions must stay out of exposed schemas per Supabase's own security checklist |
| **Edge Function** | `supabase.functions.invoke('fn-name', body: {...})` — a Deno/TypeScript HTTP function | Needed for anything that isn't naturally SQL: multi-step orchestration, calling third-party APIs (e.g., Firebase, payment providers), chunked-upload session bookkeeping, `auth.adminSignIn`-style privileged flows. Requires an `Authorization` header; params follow the Fetch API shape |

Runtime limits on Edge Functions (relevant for anything currently doing heavier work inside the RPC router): 256 MB memory, 400s max wall-clock duration on paid plans (150s free), 2s CPU time per request, 150s idle timeout before a 504. Source: [Edge Functions limits](https://supabase.com/docs/guides/functions/limits).

**Practical mapping for the router's method families** (grounded in the method names surveyed in `rpc-router.service.ts`):

- `account.*`, `activity.*`, `articles.*`, `approvalRule.*`, `approver.*`, most `admin.*.list/get/create/update/delete` — straightforward CRUD → PostgREST, gated by RLS policies replacing the router's manual auth checks.
- `auth.signIn`, `auth.adminSignIn`, `auth.firebaseSignIn`, `auth.refresh`, `auth.changePassword` — these overlap heavily with **Supabase's own Auth product** (GoTrue), which is a separate, mature request/response HTTP API — not something to reimplement as an Edge Function at all in most cases. `auth.firebaseSignIn`/`firebaseRegister` (Firebase-federated identity) is the one auth flow that likely needs a custom Edge Function shim if the app is keeping Firebase auth alongside/instead of Supabase Auth.
- `finance.overview`, `app.home.get` — aggregate/dashboard-style reads with cross-table joins and business logic → best as Postgres functions via `rpc()` (keeps the query planning in the DB) or, if the aggregation logic needs non-SQL processing, an Edge Function.
- `membershipInvitation.respond`, `admin.membershipInvitation.approve/reject` — stateful, multi-table writes with side effects (notifications) → Postgres function via `rpc()` with a `SECURITY DEFINER` function (kept in a non-exposed schema per the security checklist) or an Edge Function if it needs to call out (e.g., send push/email).

## 4. Chunked binary upload — replaced by Storage resumable (TUS) uploads or signed upload URLs

Sources: [Resumable Uploads guide](https://supabase.com/docs/guides/storage/uploads/resumable-uploads.md), [Standard Uploads guide](https://supabase.com/docs/guides/storage/uploads/standard-uploads.md), [`supabase-flutter` `storage_file_api.dart` source](https://raw.githubusercontent.com/supabase/supabase-flutter/main/packages/storage_client/lib/src/storage_file_api.dart)

Supabase Storage implements the **TUS protocol** natively server-side for resumable uploads — this is the direct replacement for the router's `*.upload.init` / `.chunk` / `.complete` / `.abort` flow (25 MB max / 256 KB chunks today). Key facts from the official doc:

- Recommended whenever files may exceed 6 MB, network stability is a concern, or progress events are wanted — matches the router's stated intent (25 MB max file).
- TUS chunk size is fixed: `chunkSize: 6 * 1024 * 1024` — **"it must be set to 6MB (for now), do not change it."** This is a hard platform constraint, different from the router's current 256 KB chunking; any port must adopt Supabase's 6 MB chunk size, not carry over the existing constant.
- Performance note: uploads should target the dedicated storage hostname (`https://project-id.storage.supabase.co`) rather than the general API host.
- **Presigned/signed resumable uploads** are supported: call `createSignedUploadUrl(path, {upsert})` to get a short-lived (**1 minute** per the Dart source) upload token, then pass it in the `x-signature` header of the TUS session — useful for letting an already-authenticated backend hand out one-time upload permission without exposing broader Storage credentials to the client.
- Concurrency semantics are defined: two clients racing the same signed upload URL → the loser gets `409 Conflict`; with `x-upsert`, last-writer-wins instead.

### Language support gap — decisive for Flutter

The official resumable-uploads doc gives **first-party, fully worked code samples for JavaScript (using `tus-js-client`) and Python**, and separately states **"Kotlin supports resumable uploads natively for all targets."** **Dart/Flutter is not mentioned anywhere in that document** — no code sample, no native-support claim, no recommended package.

Cross-checked against the `supabase-flutter` `storage_client` package source directly (`storage_file_api.dart`): it implements `upload()`, `uploadBinary()`, `update()`, `createSignedUploadUrl()`, and `uploadToSignedUrl()` (all non-resumable, single-shot HTTP calls) — **no TUS/resumable-upload method exists in the official Dart Storage client.** A generic third-party TUS client for Dart exists on pub.dev (`tus_client_dart`), but integrating it against Supabase's `x-upsert`/`x-signature`/6 MB-chunk conventions would be unofficial, unmaintained-by-Supabase glue code — exactly the kind of bespoke client-side complexity the current 25 MB chunked-upload RPC methods already represent, just moved to a different, less-supported library.

**Practical recommendation**: for the two upload flows in the router (`admin.articles.cover.upload.*`, `admin.songDb.upload.*`, and the generic `file.upload.*`), prefer **`createSignedUploadUrl()` + a standard (non-resumable) upload** for files that reliably fit under Storage's plain upload path, and only reach for TUS via `tus_client_dart` if resumability across network interruptions is a hard requirement — in which case budget real integration/testing time, since it is not a Supabase-maintained code path on Flutter.

## 5. Server-pushed events (approval, notifications, operations updates)

Sources: [Postgres Changes docs](https://supabase.com/docs/guides/realtime/postgres-changes.md), [Broadcast docs](https://supabase.com/docs/guides/realtime/broadcast.md), [Realtime Authorization docs](https://supabase.com/docs/guides/realtime/authorization.md)

Two viable delivery mechanisms, not mutually exclusive:

- **Postgres Changes**: subscribe directly to the `approvals`/`notifications`/`operations` tables. **RLS is enforced** — a client only receives a change event if their role/JWT satisfies a `SELECT` policy on that row (with a caveat: RLS is not applied to `DELETE` events, since Postgres can't evaluate a policy against a row that's already gone; when `REPLICA IDENTITY FULL` is set, the delivered `old` record on delete is trimmed to primary keys only for that reason). Downsides: payload is the raw row (whatever columns are selectable), and every table needs its own publication/replication wiring (`alter table ... replica identity full` when "old" values are needed).
- **Broadcast-from-Database**: a trigger fires `realtime.send()`/`realtime.broadcast_changes()` with a hand-shaped JSON/binary payload on a named topic (e.g., `approval:{id}` or `user:{id}:notifications`) — better fit when the push payload needs to be curated (not "whatever the row contains") or needs authorization scoped by topic rather than by row, via RLS policies on `realtime.messages` (see [Realtime Authorization](https://supabase.com/docs/guides/realtime/authorization.md), which supports per-action policies: who can `select`/`insert` broadcasts on a given topic).

Both replace the router's `realtime-emitter.service.ts` push role; Broadcast-from-DB is the closer structural match to "server explicitly emits an event with a shaped payload," which is what the current emitter does.

## 6. Realtime connection and rate limits by plan

Source: [Realtime Limits doc](https://supabase.com/docs/guides/realtime/quotas) (confirmed against `supabase.com/pricing` for the same connection/message figures)

| Limit | Free | Pro | Pro (no spend cap) | Team | Enterprise |
|---|---|---|---|---|---|
| Concurrent connections | 200 | 500 | 10,000 | 10,000 | 10,000+ |
| Messages per second | 100 | 500 | 2,500 | 2,500 | 2,500+ |
| Channel joins per second | 100 | 500 | 2,500 | 2,500 | 2,500+ |
| Channels per connection | 100 | 100 | 100 | 100 | 100+ |
| Presence keys per object | 10 | 10 | 10 | 10 | 10+ |
| Presence messages per second | 20 | 50 | 1,000 | 1,000 | 1,000+ |
| Presence calls per client / 30s | 5 | 5 | 5 | 5 | 5 |
| Broadcast payload size | 256 KB | 3,000 KB | 3,000 KB | 3,000 KB | 3,000+ KB |
| Postgres change payload size | 1,024 KB | 1,024 KB | 1,024 KB | 1,024 KB | 1,024+ KB |
| Broadcast replay retention | 72h | 72h | 72h | 72h | 72h |

Monthly message volume (from [pricing page](https://supabase.com/pricing)): Free includes 2M messages/month; Pro/Team include 5M/month then $2.50/million overage. Connections beyond the included amount on Pro/Team cost $10/1,000.

Operational note: "Connections will be disconnected if your project is generating too many messages per second. `supabase-js` will reconnect automatically when throughput decreases below your plan limit" — i.e., exceeding the messages-per-second limit is a **hard disconnect**, not a soft-throttle, on every plan tier. For a pre-launch app this is a non-issue at current scale but should be load-tested before assuming Realtime replaces the Socket.IO gateway's implicit backpressure handling.

## 7. Dart (`supabase_flutter`) parity — flagged gaps vs. JS

Sources: [Dart Realtime `subscribe` reference](https://supabase.com/docs/reference/dart/subscribe), [Postgres Changes doc](https://supabase.com/docs/guides/realtime/postgres-changes.md) (Dart code samples present throughout), [Resumable Uploads doc](https://supabase.com/docs/guides/storage/uploads/resumable-uploads.md), `storage_file_api.dart` source

What **is** confirmed at parity in Dart:

- Postgres Changes: `.channel().onPostgresChanges(...)` with insert/update/delete/filter support, including a `PostgresChangeFilter` builder mirroring JS's `postgresChangesFilter()` (both documented side-by-side in the official Postgres Changes page).
- Standard (non-resumable) Storage uploads, `createSignedUploadUrl()`, `uploadToSignedUrl()` — all present in the Dart client source.
- `supabase.rpc()` for Postgres function calls, `supabase.functions.invoke()` for Edge Functions — both documented with Dart-specific reference pages.

What is **not** confirmed / flagged as a gap:

1. **TUS resumable uploads have no Dart implementation.** JS (`tus-js-client`), Python, and native Kotlin are documented; Dart is absent from the resumable-uploads guide and absent from the `storage_file_api.dart` source. This is the single decisive JS-vs-Dart capability gap for this ticket's chunked-upload question — see §4.
2. **Binary broadcast (`realtime.send_binary`) client support is version-gated for supabase-js (≥2.91.0) and supabase-swift (≥2.44.0) only** — the doc does not list a Dart/`realtime_client` (Dart) version, so binary broadcast support on Flutter should be verified directly against the `supabase-dart`/`realtime_client` changelog before relying on it, rather than assumed.

Everything else surveyed for this ticket (Postgres Changes, Broadcast, Presence, `rpc()`, Edge Function invocation, standard/signed Storage uploads) has first-party, documented Dart support.

## Capability mapping table

| RPC router capability | Supabase replacement | Gap / risk |
|---|---|---|
| Request/response method call (`auth.signIn`, `finance.overview`, etc.) | PostgREST CRUD, Postgres function via `rpc()`, or Edge Function | No native RPC-over-Realtime exists (§2) — must go through HTTP, duplicating the existing REST surface. Low risk: this *is* the REST surface, already built. |
| Chunked binary upload (`*.upload.init/.chunk/.complete/.abort`, 25MB/256KB) | Storage TUS resumable upload (6MB fixed chunk) or `createSignedUploadUrl` + standard upload | **No Dart TUS client from Supabase** — would require third-party `tus_client_dart` glue code, or fall back to non-resumable signed uploads and lose resumability (§4). Medium risk, scoped integration work. |
| Server push (approval/notification/operations events) | Postgres Changes (RLS-gated) or Broadcast-from-Database (`realtime.send`/`broadcast_changes`) | Low risk — both are first-class, RLS/topic-authorized, Dart-supported (§5, §7). Requires re-deriving auth policies as RLS rather than router-side checks. |
| Multi-instance scale-out (Redis Socket.IO adapter) | Not needed — Realtime is Supabase's managed, globally distributed cluster | Eliminated entirely; no replacement code required. |
| Ad-hoc request/response "ack" pattern (`socket.emit(event, data, callback)`) | None — must be re-architected as HTTP | Definitive capability loss if kept as pub/sub; not a gap if migrated to PostgREST/Edge Functions as intended (§2, §3). |
| Realtime scale ceiling | Plan-tier limits: 200–10,000+ concurrent connections, 100–2,500+ msg/s (§6) | Hard disconnect (not throttle) past the messages/sec ceiling on every tier — needs load testing before relying on Realtime as the sole push channel at scale. |

## Sources consulted (primary, official Supabase)

- https://supabase.com/docs/guides/realtime
- https://supabase.com/docs/guides/realtime/concepts.md
- https://supabase.com/docs/guides/realtime/broadcast.md
- https://supabase.com/docs/guides/realtime/presence.md
- https://supabase.com/docs/guides/realtime/postgres-changes.md
- https://supabase.com/docs/guides/realtime/authorization.md
- https://supabase.com/docs/guides/realtime/architecture.md
- https://supabase.com/docs/guides/realtime/quotas
- https://supabase.com/docs/guides/database/functions.md
- https://supabase.com/docs/reference/dart/rpc
- https://supabase.com/docs/guides/functions.md
- https://supabase.com/docs/guides/functions/limits
- https://supabase.com/docs/reference/dart/functions-invoke
- https://supabase.com/docs/guides/storage/uploads/resumable-uploads.md
- https://supabase.com/docs/guides/storage/uploads/standard-uploads.md
- https://supabase.com/docs/reference/dart/introduction
- https://supabase.com/docs/reference/dart/subscribe
- https://supabase.com/pricing
- https://raw.githubusercontent.com/supabase/supabase-flutter/main/packages/storage_client/lib/src/storage_file_api.dart (primary source code, not secondary commentary)
- https://pub.dev/packages?q=tus (confirms `tus_client_dart` exists only as an unofficial third-party package, cited as lower-trust/secondary — not a Supabase-maintained artifact)

## Code surveyed (this repo, for grounding — not a source of Supabase facts)

- `apps/palakat_backend/src/realtime/rpc-router.service.ts` (4,009 lines; ~100 `case` methods; chunked upload constants: `MAX_FILE_BYTES = 25 * 1024 * 1024`, `CHUNK_BYTES = 256 * 1024`)
- `apps/palakat_backend/src/realtime/{realtime.gateway.ts, realtime-emitter.service.ts, redis-io.adapter.ts, realtime.types.ts}`
