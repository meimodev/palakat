# RPC → REST permission parity table

**Generated** 2026-07-22 from `apps/palakat_backend/src/realtime/rpc-router.service.ts` at `afb6007`, cross-referenced against every `.rpc(` call site in `packages/palakat_shared`, `apps/palakat`, `apps/palakat_admin` and `apps/palakat_super_admin`.

> **Status: superseded as a gate, retained as a finding.** [ADR-0009](./adr/0009-parity-table-is-generated-not-reviewed.md)
> replaces the *"reviewed by someone who did not write it"* gate — unsatisfiable with one developer — with a
> generator plus a CI check that asserts each route's `@RequirePermissions` set equals its RPC allow-list.
> This hand-written table is also **about to go stale**: [ADR-0008](./adr/0008-authorization-hardening-precedes-transport.md)
> rewrites 94 of its rows in Phase 1.5. Treat the table below as **the findings that motivated both ADRs**, and
> the generated output as the artefact Phase 2 is written from.

The **Guard** and **Permissions** columns are transcribed from source and are the ones that matter; **Verb** and **Route** are mechanical proposals and are the least trustworthy part of this document. The **Findings** section is prose reasoning, not transcription — a generator cannot reproduce it, so it stays.

---

## How to read this

| Column | Meaning |
|---|---|
| **Action** | RPC action string, with its `case` line in the router |
| **Verb + Route** | *Proposed* REST mapping — review these |
| **Guard** | What the RPC path enforces today, transcribed from source |
| **Permissions** | Exact allow-list passed to `requireOperationPermission` / `requireAnyOperationPermission` |
| **Client payload** | Literal keys the Flutter clients send. *(dynamic)* = payload is a variable, needs tracing |
| **Callers** | Client packages calling it. **none** = no client calls this action |

Guard values, in descending strength:

| | Meaning |
|---|---|
| 🔐 permission | `requireAnyOperationPermission` / `requireOperationPermission` — the only real authorization |
| 👑 super-admin | `requireSuperAdminOrClient` — super-admin or signing client |
| 🔓 any-audience | `requireAuthAny` — any authenticated audience, user/admin/super-admin alike |
| 🔑 auth-only | `requireUserId` — authenticated, **no authorization** |
| 🟡 service-scoped | passes `getAuthContext(client)`, which returns `{}` when anonymous — **reachable unauthenticated**; the service decides what an empty context sees |
| ⚪ public | no check of any kind |

Per decision 18 the payload column is sourced from **what the clients actually send**, not from the 54 DTO files — those were written for a REST surface that has never served a request.

## Summary

| | Count |
|---|---:|
| Actions | **166** |
| 🔐 permission-guarded | 38 |
| 👑 super-admin | 12 |
| 🔓 any-audience | 7 |
| 🔑 authenticated, no authorization | **94** |
| 🟡 service-scoped | 1 |
| ⚪ public | 14 |
| Validated with `validateDto` | **4** |
| Never called by any client | **31** |

**94 of 166 actions are authenticated but unauthorized** — any signed-in user of any church can invoke them. Whether that is correct is the single biggest question this table raises, and it is the same question RLS would have to answer under a "go".

---

## Findings — read before using the table

Each of these would have been ported silently.

### 1. 🔴 `ops.approval.finance` does not exist

`rpc-router.service.ts:2075` and `:2096` pass `'ops.approval.finance'` in the allow-list for `finance.list` and `finance.approval.list`. The policy service defines only **`ops.approval.finance.override`** — in both the `OperationPermissionKey` union and `ALL_PERMISSIONS`. `getEffectivePermissions` can never return it, so the clause is dead.

The comment immediately above it:
```ts
// Allow finance creators OR finance approvers to read standalone entries
```

That intent is not achieved: a pure finance approver is denied. It **fails closed**, so it is not a vulnerability — but porting it verbatim into a Phase 2 guard or an RLS policy carries the bug forward. **Decide the intent before porting.**

### 2. 🟠 `ops.approvalRule.manage` is defined but never checked

It appears in `ALL_PERMISSIONS` and in the default position mapping, but no call site uses it — approval-rule actions are 🔑 auth-only or 👑 super-admin instead. Either the permission is dead or those actions are under-guarded. The table cannot say which; a reviewer must.

### 3. 🔴 Four client calls have no server handler

The router is one `switch` whose `default:` throws `Unknown action`. These throw at runtime today:

| Client call | Site | Server side |
|---|---|---|
| `approver.delete` | `approver_repository.dart:127` | has list/get/create/update/override — **no delete** |
| `churchLetterhead.getMe` | `church_letterhead_repository.dart:28` | **no `churchLetterhead.*` case exists** |
| `churchLetterhead.updateMe` | `church_letterhead_repository.dart:47` | ″ |
| `churchLetterhead.setLogo` | `church_letterhead_repository.dart:116` | ″ |

`ChurchLetterheadService` exists and is **never referenced by the router**, so church-letterhead management is unreachable from the app. Decide whether the feature is wanted before building REST routes for it.

### 4. 🟠 31 server actions that no client calls

Listed in the appendix. Per decision 17 these are **delete candidates, not port candidates** — a guarded route for an action nothing invokes is attack surface with no user-visible function.

### 5. 🟠 Only 4 of 166 actions validate input

`validateDto` is called at 4 sites. The global `ValidationPipe` (`main.ts:34`) is HTTP-only and the gateway declares no `@UsePipes`, so registering these as REST routes puts them behind validation the socket never applied. That is what the client-payload column is for.

---

## The table

### `account` — 6 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `account.count` | 1063 | POST | `/account/count` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `account.create` | 1094 | POST | `/account` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `account.delete` | 1194 | DELETE | `/account/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `account.get` | 1068 | GET | `/account/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `account.list` | 1082 | GET | `/account` | 🔐 permission | `ops.members.read` | *(dynamic)* | palakat_shared |
| `account.update` | 1172 | PATCH | `/account/:id` | 🔑 auth-only | — | `dto`, `id` | palakat_shared |

### `activity` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `activity.create` | 3626 | POST | `/activity` | 🔐 permission | `ops.activity.create` | *(dynamic)* | palakat_shared |
| `activity.delete` | 3645 | DELETE | `/activity/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `activity.get` | 3618 | GET | `/activity/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `activity.list` | 3609 | GET | `/activity` | 🟡 service-scoped | — | *(dynamic)* | palakat_shared |
| `activity.update` | 3637 | PATCH | `/activity/:id` | 🔑 auth-only | — | `dto`, `id` | palakat_shared |

### `admin` — 26 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `admin.articles.archive` | 1053 | POST | `/admin/articles/archive` | 🔓 any-audience | — | `id` | palakat_super_admin |
| `admin.articles.cover.upload.abort` | 1018 | POST | `/admin/articles/cover/upload/abort` | 👑 super-admin | — | `uploadId` | palakat_super_admin |
| `admin.articles.cover.upload.chunk` | 902 | POST | `/admin/articles/cover/upload/chunk` | 👑 super-admin | — | `dataBase64`, `uploadId` | palakat_super_admin |
| `admin.articles.cover.upload.complete` | 956 | POST | `/admin/articles/cover/upload/complete` | 👑 super-admin | — | `uploadId` | palakat_super_admin |
| `admin.articles.cover.upload.init` | 820 | POST | `/admin/articles/cover/upload/init` | 👑 super-admin | — | `contentType`, `id`, `originalName`, `sizeBytes` | palakat_super_admin |
| `admin.articles.create` | 802 | POST | `/admin/articles` | 🔓 any-audience | — | *(dynamic)* | palakat_super_admin |
| `admin.articles.get` | 790 | GET | `/admin/articles/:id` | 🔓 any-audience | — | `id` | palakat_super_admin |
| `admin.articles.list` | 780 | GET | `/admin/articles` | 🔓 any-audience | — | *(dynamic)* | palakat_super_admin |
| `admin.articles.publish` | 1035 | POST | `/admin/articles/publish` | 🔓 any-audience | — | `id` | palakat_super_admin |
| `admin.articles.unpublish` | 1044 | POST | `/admin/articles/unpublish` | 🔓 any-audience | — | `id` | palakat_super_admin |
| `admin.articles.update` | 807 | PATCH | `/admin/articles/:id` | 🔓 any-audience | — | `dto`, `id` | palakat_super_admin |
| `admin.churchRequest.approve` | 3582 | POST | `/admin/church-request/approve` | 👑 super-admin | — | `dto`, `id` | palakat_super_admin |
| `admin.churchRequest.delete` | 3574 | DELETE | `/admin/church-request/:id` | 👑 super-admin | — | `id` | palakat_shared |
| `admin.churchRequest.get` | 3558 | GET | `/admin/church-request/:id` | 👑 super-admin | — | `id` | palakat_super_admin |
| `admin.churchRequest.list` | 3551 | GET | `/admin/church-request` | 👑 super-admin | — | `page`, `pageSize` *(dynamic)* | palakat_super_admin, palakat_shared |
| `admin.churchRequest.reject` | 3595 | POST | `/admin/church-request/reject` | 👑 super-admin | — | `decisionNote`, `dto`, `id` | palakat_super_admin |
| `admin.churchRequest.update` | 3566 | PATCH | `/admin/church-request/:id` | 👑 super-admin | — | — | **none** |
| `admin.membershipInvitation.approve` | 1885 | POST | `/admin/membership-invitation/approve` | 🔑 auth-only | — | `id` | palakat_super_admin |
| `admin.membershipInvitation.delete` | 2054 | DELETE | `/admin/membership-invitation/:id` | 🔑 auth-only | — | `id` | palakat_super_admin |
| `admin.membershipInvitation.get` | 1842 | GET | `/admin/membership-invitation/:id` | 🔑 auth-only | — | `id` | palakat_super_admin |
| `admin.membershipInvitation.list` | 1756 | GET | `/admin/membership-invitation` | 🔑 auth-only | — | *(dynamic)* | palakat_super_admin |
| `admin.membershipInvitation.reject` | 1989 | POST | `/admin/membership-invitation/reject` | 🔑 auth-only | — | *(dynamic)* | palakat_super_admin |
| `admin.songDb.upload.abort` | 3978 | POST | `/admin/song-db/upload/abort` | 🔑 auth-only | — | `uploadId` | palakat_super_admin |
| `admin.songDb.upload.chunk` | 3784 | POST | `/admin/song-db/upload/chunk` | 🔑 auth-only | — | `dataBase64`, `uploadId` | palakat_super_admin |
| `admin.songDb.upload.complete` | 3846 | POST | `/admin/song-db/upload/complete` | 🔑 auth-only | — | `uploadId` | palakat_super_admin |
| `admin.songDb.upload.init` | 3653 | POST | `/admin/song-db/upload/init` | 🔑 auth-only | — | `contentType`, `fileId`, `originalName`, `sizeBytes` | palakat_super_admin |

### `app` — 1 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `app.home.get` | 534 | GET | `/app/home/:id` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |

### `approvalRule` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `approvalRule.create` | 3324 | POST | `/approval-rule` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `approvalRule.delete` | 3339 | DELETE | `/approval-rule/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `approvalRule.get` | 3316 | GET | `/approval-rule/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `approvalRule.list` | 3309 | GET | `/approval-rule` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `approvalRule.update` | 3330 | PATCH | `/approval-rule/:id` | 🔑 auth-only | — | `dto`, `id` | palakat_shared |

### `approver` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `approver.create` | 3386 | POST | `/approver` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `approver.get` | 3378 | GET | `/approver/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `approver.list` | 3348 | GET | `/approver` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `approver.override` | 3407 | POST | `/approver/override` | 🔐 permission | `ops.approval.activity.override` | `APPROVED`, `id`, `note`, `status` | palakat_shared |
| `approver.update` | 3391 | PATCH | `/approver/:id` | 🔑 auth-only | — | `dto`, `id` | palakat_shared |

### `articles` — 4 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `articles.get` | 753 | GET | `/articles/:id` | ⚪ public | — | `id` | palakat_shared |
| `articles.like` | 761 | POST | `/articles/like` | 🔑 auth-only | — | `id` | palakat_shared |
| `articles.list` | 747 | GET | `/articles` | ⚪ public | — | *(dynamic)* | palakat_shared |
| `articles.unlike` | 770 | POST | `/articles/unlike` | 🔑 auth-only | — | `id` | palakat_shared |

### `auth` — 13 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `auth.adminSignIn` | 632 | POST | `/auth/admin-sign-in` | ⚪ public | — | — | **none** |
| `auth.attach` | 623 | POST | `/auth/attach` | ⚪ public | — | `accessToken` | palakat_shared |
| `auth.changePassword` | 668 | POST | `/auth/change-password` | 🔑 auth-only | — | `currentPassword`, `newPassword` | palakat_shared |
| `auth.firebaseRegister` | 713 | POST | `/auth/firebase-register` | ⚪ public | — | `firebaseIdToken` | palakat_shared |
| `auth.firebaseSignIn` | 705 | POST | `/auth/firebase-sign-in` | ⚪ public | — | `firebaseIdToken` | palakat_shared |
| `auth.permissions.get` | 676 | GET | `/auth/permissions/:id` | 🔑 auth-only | — | — | palakat_shared |
| `auth.refresh` | 647 | POST | `/auth/refresh` | ⚪ public | — | — | **none** |
| `auth.signIn` | 626 | POST | `/auth/sign-in` | ⚪ public | — | — | **none** |
| `auth.signOut` | 663 | POST | `/auth/sign-out` | 🔑 auth-only | — | — | palakat_shared |
| `auth.signingClient` | 681 | GET | `/auth/signing-client` | ⚪ public | — | — | **none** |
| `auth.superAdminSignIn` | 638 | POST | `/auth/super-admin-sign-in` | ⚪ public | — | `password`, `phone` | palakat_super_admin |
| `auth.syncClaims` | 700 | POST | `/auth/sync-claims` | ⚪ public | — | `firebaseIdToken` | palakat_shared |
| `auth.validatePhone` | 644 | POST | `/auth/validate-phone` | ⚪ public | — | `phone` | palakat_shared |

### `cashAccount` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `cashAccount.create` | 2393 | POST | `/cash-account` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | `currency`, `name`, `openingBalance` | palakat_admin |
| `cashAccount.delete` | 2412 | DELETE | `/cash-account/:id` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | `id` | palakat_admin |
| `cashAccount.get` | 2382 | GET | `/cash-account/:id` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | `id` | palakat_shared |
| `cashAccount.list` | 2372 | GET | `/cash-account` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | *(dynamic)* | palakat_admin, palakat_shared |
| `cashAccount.update` | 2401 | PATCH | `/cash-account/:id` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | `currency`, `dto`, `id`, `name`, `openingBalance` | palakat_admin |

### `cashMutation` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `cashMutation.create` | 2444 | POST | `/cash-mutation` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | `amount`, `fromAccountId`, `happenedAt`, `note`, `toAccountId`, `type` | palakat_admin |
| `cashMutation.delete` | 2460 | DELETE | `/cash-mutation/:id` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | `id` | palakat_admin |
| `cashMutation.get` | 2433 | GET | `/cash-mutation/:id` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | `id` | palakat_admin |
| `cashMutation.list` | 2423 | GET | `/cash-mutation` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | *(dynamic)* | palakat_admin |
| `cashMutation.transfer` | 2452 | POST | `/cash-mutation/transfer` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | `amount`, `fromAccountId`, `happenedAt`, `note`, `toAccountId` | palakat_admin |

### `church` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `church.create` | 3174 | POST | `/church` | 👑 super-admin | — | *(dynamic)* | palakat_super_admin |
| `church.delete` | 3187 | DELETE | `/church/:id` | 👑 super-admin | — | `id` | palakat_super_admin |
| `church.get` | 3166 | GET | `/church/:id` | 🔑 auth-only | — | `id` | palakat_super_admin, palakat_shared |
| `church.list` | 3131 | GET | `/church` | 🔑 auth-only | — | *(dynamic)* | palakat_super_admin, palakat_shared |
| `church.update` | 3179 | PATCH | `/church/:id` | 🔑 auth-only | — | `dto`, `id` | palakat_super_admin, palakat_shared |

### `churchPermissionPolicy` — 2 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `churchPermissionPolicy.getMe` | 3139 | POST | `/church-permission-policy/get-me` | 🔑 auth-only | — | — | palakat_shared |
| `churchPermissionPolicy.updateMe` | 3144 | PATCH | `/church-permission-policy/update-me` | 🔑 auth-only | — | `policy` | palakat_shared |

### `churchRequest` — 2 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `churchRequest.create` | 3541 | POST | `/church-request` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `churchRequest.my` | 3546 | POST | `/church-request/my` | 🔑 auth-only | — | — | palakat_shared |

### `column` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `column.create` | 3211 | POST | `/column` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `column.delete` | 3224 | DELETE | `/column/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `column.get` | 3203 | GET | `/column/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `column.list` | 3196 | GET | `/column` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `column.update` | 3216 | PATCH | `/column/:id` | 🔑 auth-only | — | `dto`, `id` | palakat_shared |

### `document` — 6 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `document.create` | 2565 | POST | `/document` | 🔑 auth-only | — | — | **none** |
| `document.delete` | 2578 | DELETE | `/document/:id` | 🔑 auth-only | — | — | **none** |
| `document.generate` | 2586 | POST | `/document/generate` | 🔑 auth-only | — | `accountNumber`, `certificateTitle`, `certificateType`, `id`, `input`, `membershipId` | palakat_shared |
| `document.get` | 2557 | GET | `/document/:id` | 🔑 auth-only | — | — | **none** |
| `document.list` | 2550 | GET | `/document` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `document.update` | 2570 | PATCH | `/document/:id` | 🔑 auth-only | — | `dto`, `id` | palakat_shared |

### `expense` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `expense.create` | 2324 | POST | `/expense` | 🔐 permission | `ops.finance.expense.create` | *(dynamic)* | palakat_shared |
| `expense.delete` | 2353 | DELETE | `/expense/:id` | 🔐 permission | `ops.finance.expense.create` | `id` | palakat_shared |
| `expense.get` | 2305 | GET | `/expense/:id` | 🔐 permission | `ops.finance.expense.create` | `id` | palakat_shared |
| `expense.list` | 2291 | GET | `/expense` | 🔐 permission | `ops.finance.expense.create` | *(dynamic)* | palakat_shared |
| `expense.update` | 2333 | PATCH | `/expense/:id` | 🔐 permission | `ops.finance.expense.create` | `dto`, `id` | palakat_shared |

### `file` — 11 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `file.delete` | 3075 | DELETE | `/file/:id` | 🔑 auth-only | — | — | **none** |
| `file.download.chunk` | 3010 | POST | `/file/download/chunk` | 🔑 auth-only | — | — | **none** |
| `file.download.complete` | 3050 | POST | `/file/download/complete` | 🔑 auth-only | — | — | **none** |
| `file.download.init` | 2879 | POST | `/file/download/init` | 🔑 auth-only | — | — | **none** |
| `file.finalize` | 2607 | POST | `/file/finalize` | 🔑 auth-only | — | `bucket`, `churchId`, `contentType`, `originalName`, `path`, `sizeInKB` | palakat_shared |
| `file.get` | 2599 | GET | `/file/:id` | 🔑 auth-only | — | — | **none** |
| `file.list` | 2592 | GET | `/file` | 🔑 auth-only | — | — | **none** |
| `file.upload.abort` | 2803 | POST | `/file/upload/abort` | 🔑 auth-only | — | — | **none** |
| `file.upload.chunk` | 2693 | POST | `/file/upload/chunk` | 🔑 auth-only | — | — | **none** |
| `file.upload.complete` | 2747 | POST | `/file/upload/complete` | 🔑 auth-only | — | — | **none** |
| `file.upload.init` | 2612 | POST | `/file/upload/init` | 🔑 auth-only | — | — | **none** |

### `finance` — 7 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `finance.approval.get` | 2114 | GET | `/finance/approval/:id` | 🔑 auth-only | — | `financeType`, `id` | palakat_shared |
| `finance.approval.list` | 2082 | GET | `/finance/approval` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `finance.approver.override` | 2168 | POST | `/finance/approver/override` | 🔐 permission | `ops.approval.finance.override` | `APPROVED`, `approverId`, `financeType`, `note`, `status` | palakat_shared |
| `finance.approver.update` | 2145 | PATCH | `/finance/approver/:id` | 🔑 auth-only | — | `approverId`, `dto`, `financeType`, `status` | palakat_shared |
| `finance.get` | 2091 | GET | `/finance/:id` | 🔐 permission | `ops.approval.finance`<br>`ops.finance.expense.create`<br>`ops.finance.revenue.create` | `financeType`, `id` | palakat_shared |
| `finance.list` | 2070 | GET | `/finance` | 🔐 permission | `ops.approval.finance`<br>`ops.finance.expense.create`<br>`ops.finance.revenue.create` | *(dynamic)* | palakat_shared |
| `finance.overview` | 2137 | GET | `/finance/overview` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | — | palakat_shared |

### `financialAccountNumber` — 6 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `financialAccountNumber.available` | 3457 | POST | `/financial-account-number/available` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | *(dynamic)* | palakat_shared |
| `financialAccountNumber.create` | 3488 | POST | `/financial-account-number` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | *(dynamic)* | palakat_shared |
| `financialAccountNumber.delete` | 3520 | DELETE | `/financial-account-number/:id` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | `id` | palakat_shared |
| `financialAccountNumber.get` | 3472 | GET | `/financial-account-number/:id` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | — | **none** |
| `financialAccountNumber.list` | 3443 | GET | `/financial-account-number` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | *(dynamic)* | palakat, palakat_shared |
| `financialAccountNumber.update` | 3499 | PATCH | `/financial-account-number/:id` | 🔐 permission | `ops.finance.expense.create`<br>`ops.finance.revenue.create` | `dto`, `id` | palakat_shared |

### `location` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `location.create` | 3248 | POST | `/location` | 🔑 auth-only | — | — | **none** |
| `location.delete` | 3261 | DELETE | `/location/:id` | 🔑 auth-only | — | — | **none** |
| `location.get` | 3240 | GET | `/location/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `location.list` | 3233 | GET | `/location` | 🔑 auth-only | — | — | **none** |
| `location.update` | 3253 | PATCH | `/location/:id` | 🔑 auth-only | — | `dto`, `id` | palakat_shared |

### `member` — 1 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `member.create` | 1114 | POST | `/member` | 🔐 permission | `ops.members.invite` | *(dynamic)* | palakat_shared |

### `membership` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `membership.create` | 1204 | POST | `/membership` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `membership.delete` | 1237 | DELETE | `/membership/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `membership.get` | 1221 | GET | `/membership/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `membership.list` | 1209 | GET | `/membership` | 🔐 permission | `ops.members.read` | *(dynamic)* | palakat_shared |
| `membership.update` | 1229 | PATCH | `/membership/:id` | 🔑 auth-only | — | `dto`, `id` | palakat_shared |

### `membershipInvitation` — 4 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `membershipInvitation.create` | 1390 | POST | `/membership-invitation` | 🔐 permission | `ops.members.invite` | `baptize`, `churchId`, `columnId`, `inviteeId`, `sidi` | palakat_shared |
| `membershipInvitation.myPending` | 1543 | POST | `/membership-invitation/my-pending` | 🔑 auth-only | — | — | palakat_shared |
| `membershipInvitation.preview` | 1246 | GET | `/membership-invitation/preview` | 🔐 permission | `ops.members.invite` | `identifier` | palakat_shared |
| `membershipInvitation.respond` | 1581 | POST | `/membership-invitation/respond` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |

### `membershipPosition` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `membershipPosition.create` | 3285 | POST | `/membership-position` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `membershipPosition.delete` | 3300 | DELETE | `/membership-position/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `membershipPosition.get` | 3277 | GET | `/membership-position/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `membershipPosition.list` | 3270 | GET | `/membership-position` | 🔑 auth-only | — | `churchId`, `page`, `pageSize` *(dynamic)* | palakat_shared |
| `membershipPosition.update` | 3291 | PATCH | `/membership-position/:id` | 🔑 auth-only | — | `dto`, `id` | palakat_shared |

### `notifications` — 4 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `notifications.delete` | 3121 | DELETE | `/notifications/:id` | 🔑 auth-only | — | — | **none** |
| `notifications.get` | 3103 | GET | `/notifications/:id` | 🔑 auth-only | — | — | **none** |
| `notifications.list` | 3084 | GET | `/notifications` | 🔑 auth-only | — | — | **none** |
| `notifications.markRead` | 3112 | PATCH | `/notifications/mark-read` | 🔑 auth-only | — | — | **none** |

### `ping` — 1 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `ping` | 531 | POST | `/ping` | ⚪ public | — | — | **none** |

### `public` — 1 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `public.songDb.meta` | 2820 | GET | `/public/song-db/meta` | ⚪ public | — | `fileId` | palakat_shared |

### `report` — 6 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `report.create` | 2496 | POST | `/report` | 🔑 auth-only | — | — | **none** |
| `report.delete` | 2509 | DELETE | `/report/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `report.generate` | 2517 | POST | `/report/generate` | 🔐 permission | `ops.report.generate` | `activityType`, `columnId`, `congregationSubtype`, `financialSubtype`, `format`, `input` *(dynamic)* | palakat_shared |
| `report.get` | 2488 | GET | `/report/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `report.list` | 2471 | GET | `/report` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |
| `report.update` | 2501 | PATCH | `/report/:id` | 🔑 auth-only | — | — | **none** |

### `reportJob` — 3 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `reportJob.cancel` | 2541 | POST | `/report-job/cancel` | 🔑 auth-only | — | `id` | palakat_shared |
| `reportJob.get` | 2533 | GET | `/report-job/:id` | 🔑 auth-only | — | `id` | palakat_shared |
| `reportJob.list` | 2525 | GET | `/report-job` | 🔑 auth-only | — | *(dynamic)* | palakat_shared |

### `revenue` — 5 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `revenue.create` | 2244 | POST | `/revenue` | 🔐 permission | `ops.finance.revenue.create` | *(dynamic)* | palakat_shared |
| `revenue.delete` | 2273 | DELETE | `/revenue/:id` | 🔐 permission | `ops.finance.revenue.create` | `id` | palakat_shared |
| `revenue.get` | 2225 | GET | `/revenue/:id` | 🔐 permission | `ops.finance.revenue.create` | `id` | palakat_shared |
| `revenue.list` | 2211 | GET | `/revenue` | 🔐 permission | `ops.finance.revenue.create` | *(dynamic)* | palakat_shared |
| `revenue.update` | 2253 | PATCH | `/revenue/:id` | 🔐 permission | `ops.finance.revenue.create` | `dto`, `id` | palakat_shared |

### `sub` — 2 action(s)

| Action | Line | Verb | Proposed route | Guard | Permissions | Client payload | Callers |
|---|---:|---|---|---|---|---|---|
| `sub.join` | 726 | POST | `/sub/join` | 🔑 auth-only | — | — | **none** |
| `sub.leave` | 736 | POST | `/sub/leave` | 🔑 auth-only | — | — | **none** |

---

## Appendix — server actions no client calls

31 actions. Delete candidates per decision 17.

| Action | Line | Guard |
|---|---:|---|
| `admin.churchRequest.update` | 3566 | 👑 super-admin |
| `auth.adminSignIn` | 632 | ⚪ public |
| `auth.refresh` | 647 | ⚪ public |
| `auth.signIn` | 626 | ⚪ public |
| `auth.signingClient` | 681 | ⚪ public |
| `document.create` | 2565 | 🔑 auth-only |
| `document.delete` | 2578 | 🔑 auth-only |
| `document.get` | 2557 | 🔑 auth-only |
| `file.delete` | 3075 | 🔑 auth-only |
| `file.download.chunk` | 3010 | 🔑 auth-only |
| `file.download.complete` | 3050 | 🔑 auth-only |
| `file.download.init` | 2879 | 🔑 auth-only |
| `file.get` | 2599 | 🔑 auth-only |
| `file.list` | 2592 | 🔑 auth-only |
| `file.upload.abort` | 2803 | 🔑 auth-only |
| `file.upload.chunk` | 2693 | 🔑 auth-only |
| `file.upload.complete` | 2747 | 🔑 auth-only |
| `file.upload.init` | 2612 | 🔑 auth-only |
| `financialAccountNumber.get` | 3472 | 🔐 permission |
| `location.create` | 3248 | 🔑 auth-only |
| `location.delete` | 3261 | 🔑 auth-only |
| `location.list` | 3233 | 🔑 auth-only |
| `notifications.delete` | 3121 | 🔑 auth-only |
| `notifications.get` | 3103 | 🔑 auth-only |
| `notifications.list` | 3084 | 🔑 auth-only |
| `notifications.markRead` | 3112 | 🔑 auth-only |
| `ping` | 531 | ⚪ public |
| `report.create` | 2496 | 🔑 auth-only |
| `report.update` | 2501 | 🔑 auth-only |
| `sub.join` | 726 | 🔑 auth-only |
| `sub.leave` | 736 | 🔑 auth-only |
