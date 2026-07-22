# Phase 1.5 — authorization triage of the 94 unguarded actions

**Date:** 2026-07-22 · **Ticket:** [#45](https://github.com/meimodev/palakat/issues/45) ·
**Decision:** 31 · **ADR:** [0008](./adr/0008-authorization-hardening-precedes-transport.md)

The parity table reports **94 of 166 actions authenticated but unauthorized**. That number is a
*router-level* measurement — it counts cases whose only gate is `requireUserId`. It is the right
number to have raised the alarm and the wrong number to plan against, because it mixes two
populations that need completely different work.

## The split that matters

| | Count | What it means |
|---|---:|---|
| **Inline-guarded** | 11 | The case authorizes by hand — `if (auth?.role !== 'SUPER_ADMIN') throw …` — instead of calling a helper. **Guarded. Not work.** |
| **Scoped-arg** | 27 | The case hands the service the authenticated `user`, or an id resolved from them. Authorization *may* happen in the service, and for several it does. Needs verifying, not fixing. |
| **Bare** | **56** | No helper, no inline check, and nothing caller-derived reaches the service. **No layer can be enforcing anything.** Unguarded as a matter of structure. |

The 56 are the real work. All three groups are computed mechanically over the case bodies (guard
line excluded), so the split is reproducible rather than a reading.

> ### Two ways the "94" over-counts, both found the hard way
>
> **Service-layer guards.** `churchPermissionPolicy.updateMe` is one of the 94 and looks
> catastrophic — rewrite your church's permission policy with nothing but a login. It is guarded:
> `ChurchPermissionPolicyService.updateMe` calls `assertCanManagePolicy(user)` first.
>
> **Inline guards.** The nine `admin.membershipInvitation.*` and `admin.songDb.upload.*` actions
> were classified as holes in the first draft of this triage, and a fix adding
> `requireSuperAdminOrClient` to all nine was written before anyone read far enough into the case
> bodies to see `if (auth?.role !== 'SUPER_ADMIN')` already sitting there. The fix would have been
> nine redundant checks presented as a security improvement.
>
> **The generator now detects inline guards** and reports `inlineGuarded` alongside
> `trulyUnguarded`, so this particular trap is closed for Phase 2. But the general lesson stands and
> belongs on the record before Phase 2 leans on the table: **the parity table sees helpers, not
> authorization.** A guard it cannot see reads exactly like a guard that is not there.

---

## 🔴 Finding 1 — `sub.join` accepts any room name. Socket rooms are *not* server-controlled.

`rpc-router.service.ts:710`:

```ts
case 'sub.join': {
  this.requireUserId(client);
  const room = payload.room as string;
  if (!room || room.trim().length === 0) throw new BadRequestException('room is required');
  client.join(room);          // ← no membership check of any kind
  return { message: 'OK', data: { room } };
}
```

Any authenticated user can join `church.{any id}` and receive everything
`RealtimeEmitterService.emitToRoom` publishes to it — which per §3 of the migration plan carries
`entityTitle`, `actorName`, `financeType`, `affectedMembershipIds` and `resultingStatus`.

**This falsifies a load-bearing claim in the plan.** §3 says:

> Socket rooms are **server-controlled** — the server authenticates, then decides membership. FCM
> topics are **client-controlled** […]

They are not server-controlled. The client names the room and the server obeys. §3 frames
content-free push as a constraint that FCM *introduces*; in fact the exposure **already exists on
the socket**, and the FCM design in Phase 4 is what finally closes it rather than what opens it.

Consequences for the plan, none of which change its direction:

- §3's mandate — no push carries entity content — is **still right**, and now has a second,
  independent justification.
- The exposure is **live today**, not prospective. `palakat_admin` is deployed (decision 21).
- It should be fixed here, on the RPC path, because Phase 5 does not delete the socket until after
  three clients migrate.

**Bucket: its own.** Not a permission and not service scoping — a membership check in the router,
against the rooms the caller is actually entitled to.

## 🔴 Finding 2 — `ops.approvalRule.manage` is not dead. The approval-rule actions are under-guarded.

The generator reports it defined in `ALL_PERMISSIONS` and never checked. The triage resolves the
question the plan left open — *"either it is dead, or the approval-rule actions are under-guarded"*:

`approvalRule.create`, `.update`, `.delete`, `.list`, `.get` were all `requireUserId` only, and all
five were bare. The permission exists, is granted by the policy, and describes exactly these
actions. **It is the second horn: they were under-guarded.**

**Fixed here.** All five now call `requireOperationPermission(client, 'ops.approvalRule.manage')`.
Reads are included deliberately: approval rules are configuration that decides who signs off on a
church's finances, not member-facing content, and under the release freeze over-tightening costs
dev-build friction while under-tightening ships a hole. The generator now reports `unchecked: []` —
the finding is closed, and provably so rather than by assertion.

## 🟠 Finding 3 — `ops.approval.finance` is a phantom, and fixing it *widens* access

Passed at `rpc-router.service.ts:2075` and `:2096`, never defined; only
`ops.approval.finance.override` exists. The clause is dead, so today `finance.get` and
`finance.list` admit only holders of `ops.finance.revenue.create` / `ops.finance.expense.create`.

The code says what was meant, immediately above the call:

```ts
// Allow finance creators OR finance approvers to read detail
```

So the intent was to include approvers, and a typo has been excluding them. **Correcting it is a
widening, not a tightening** — the one change in this phase that grants access rather than removing
it. Flagged rather than folded in silently: it is a behaviour change to a finance read path and
deserves an explicit yes.

---

## The buckets

### Bucket 1 — correct as authenticated-only (no work; reason recorded)

| Actions | Why it is correct |
|---|---|
| `location.list`, `location.get` | Reference data — provinces/districts, not church-owned. The ticket's own example. |
| `sub.leave` | Leaving a room you are not in is a no-op. No information flows. |
| `auth.signOut`, `auth.changePassword`, `auth.permissions.get` | Act on `user.userId` only. The caller *is* the scope. |
| `articles.like`, `articles.unlike` | Pass `user.userId`; articles are public content. |
| `churchRequest.create`, `churchRequest.my` | Keyed to `user.userId`. Creating a church request is how an unaffiliated user enters the system. |
| `churchPermissionPolicy.getMe`, `.updateMe` | Guarded in the service by `assertCanManagePolicy`. |
| `app.home.get` | Scoped via `resolveMembershipIdForUser`. |
| `notifications.list`, `.get`, `.markRead`, `.delete` | All four resolve `membershipId` from the caller and pass it to the service. |
| `finance.approval.list`, `.get` | Resolve `membershipId` from the caller first. |
| `membershipInvitation.myPending` | Keyed to the caller. |
| `approver.list` | Explicitly forces `query.churchId` to the requester's own church and rejects mismatches. The model to copy. |

### Bucket 2 — needs a permission ✅ done (#57), except four

Church-scoped writes. **26 actions. 22 gated, 4 could not be.**

Before assigning anything, the callers were traced — the clients speak RPC through
`packages/palakat_shared/lib/core/repositories`, **not** through `apps/*/lib`, so a first sweep over
the app trees reported 25 of 26 uncalled. That was wrong, and acting on it would have gated the
member app's own screens. Re-run against the shared package, 20 of 26 are live.

| Actions | Guard applied | Caller |
|---|---|---|
| ~~`approvalRule.*`~~ | `ops.approvalRule.manage` | done earlier, closes Finding 2 |
| `church.update`, `column.*`, `membershipPosition.*`, `location.update`, `document.create`, `document.delete`, `file.delete` | **`ops.church.manage`** (new) | `palakat_admin` |
| `activity.update`, `activity.delete`, `approver.create` | `ops.activity.create` | `palakat_admin` |
| `report.create`, `.update`, `.delete` | `ops.report.generate` | `palakat_admin` |
| `account.create`, `account.delete`, `membership.delete` | `ops.members.invite` | `palakat_admin` |
| `location.create`, `location.delete` | **super-admin** | uncalled — national reference data |
| `membership.create`, `membership.update`, `account.update`, `document.update` | ⛔ **none — see below** | **`palakat`, the member app** |

One new permission key rather than six. `ops.church.manage` covers the church's own structure —
profile, columns, positions, location, documents, files — and takes the same default positions as
`ops.approvalRule.manage`, the other "administer the church itself" capability. The rest reuse
existing keys: a holder of `ops.activity.create` may now also update and delete activities, which is
a widening of that key's meaning but not of its holder set, and every one of these actions was
reachable by *any* signed-in account before.

Adding the key surfaced a latent bug: `buildEmptyPolicy()` hand-listed all nine permissions, so a new
one would have been silently absent from every empty policy — a grant that cannot be configured. It
now derives from `ALL_PERMISSIONS`.

## 🔴 Finding 5 — four of the bare writes belong to the member app

`membership.create`, `membership.update`, `account.update` and `document.update` are called from
`apps/palakat`: joining a church, editing your own membership, your own profile, your own certificate
request. **A leadership permission on any of them locks ordinary members out of their own records**,
and on `membership.create` it is circular — that action *is* how a user joins.

They need **self-scoping in the service**, not a permission. `account.update` and `document.update`
are called by both apps, so the rule is compound — your own row always, someone else's only with the
members-manage permission — a shape that exists nowhere in the codebase yet. Tracked as
[#63](https://github.com/meimodev/palakat/issues/63).

`rpc-parity.spec.ts` pins all four as deliberately ungated, so a later well-meaning "finish the
bucket" commit fails the suite instead of breaking church-joining in production.

**The general lesson, which is the third one this phase has produced about the parity table: it names
actions, not audiences.** Two actions can look identical in the table and have opposite correct
answers because different apps call them. Phase 2 writes REST routes from this table — the audience
is not in it.

### Bucket 3 — needs church-scoping ✅ done (#58), except two

Reads that should return *your church's* rows rather than any row whose id you can guess. A
permission would be the wrong fix — the caller is entitled to read these, just not all of them.

**17 actions. 15 scoped, 2 deliberately left open.**

| Actions | Treatment |
|---|---|
| `account.count`, `membershipPosition.list`, `document.list`, `report.list`, `file.list` | query forced to the requester's church |
| `church.get`, `column.get`, `membershipPosition.get`, `document.get`, `report.get`, `file.get`, `activity.get`, `approver.get` | fetched row's church compared to the requester's |
| `account.get`, `membership.get` | **compound** — your own row always, someone else's only within your church |
| `church.list`, `column.list` | ⛔ **stay open — see below** |

The decision lives in `src/realtime/church-scoping.ts` as two pure functions, tested directly. It is
in the router rather than the services because `approver.list` — the one read that already got this
right — does it there, and because one code path reaches every list service.

**Conventions settled, since the ticket asked for one and not a case-by-case:**

- **A list rejects a foreign `churchId`, it does not silently substitute your own.** Overwriting
  answers a question the caller did not ask and hides that the real answer was "no".
- **A get compares the fetched row and throws `Forbidden`.** This confirms the row exists, which is a
  weak enumeration oracle — accepted deliberately, because it matches the six existing
  `Invalid church context` sites, and uniformity across two doors is worth more here than closing an
  oracle over "does church 4 have a column with id 12".
- **An unscopeable row fails closed.** `Column`, `Membership` and `MembershipPosition` all declare
  `churchId` nullable, so a row genuinely can carry none. It is refused, not waved through.

## 🔴 Finding 6 — two of the reads are the onboarding pickers

`church.list` and `column.list` are `dialog_church_picker_widget` and `dialog_column_picker_widget`
in the member app. **A user picks their church and column before they have a membership**, so
scoping either to "the requester's church" is circular in exactly the way gating
`membership.create` was in #57. They stay open, and that is now a recorded reason rather than an
omission. Sensitivity is low: a church name and a column name.

This is the second time in two tickets that the correct answer for an action was decided by *which
app calls it*. The pattern is now established well enough to state plainly: **for any action in this
phase, trace the caller before choosing the guard.**

## 🟠 Finding 7 — two scoping holes that looked like scoping

Found while wiring the above, both worth recording because neither is visible from the router:

- **`report.list` already received the auth context** and passed it to `getReports`, which used it
  only for an optional `mine` filter. The identity was accepted and then ignored for scoping — the
  precise shape [#59](https://github.com/meimodev/palakat/issues/59) went looking for.
- **`getFiles` had no `churchId` at all** — not on the DTO, not in the `where`. Forcing a `churchId`
  into the query would have set a field the service ignores. **Setting a field a service does not
  read is a guard that only looks like one**, so the DTO and the `where` clause were both given one.

Every list service used here was checked for this before being trusted.

### Needs verification, not fixing (the 29 scoped-arg)

Each passes `user` or a caller-derived id. Confirmed guarded: `churchPermissionPolicy.*`,
`notifications.*`, `finance.approval.*`, `approver.list`, `app.home.get`, `auth.*`, `churchRequest.*`,
`articles.like/unlike`, `membershipInvitation.myPending`.

**All eleven were read in Phase 1.5d (#59). Verdicts below.**

| Action | Enforces? | How |
|---|---|---|
| `membershipInvitation.respond` | ✅ | `invitation.inviteeId !== user.userId` → `Forbidden` |
| `finance.approver.update` | ✅ | church scope **and** `currentApprover.membershipId !== requesterMembershipId` |
| `reportJob.list` | ✅ | `where: { requestedById: userId }` |
| `reportJob.get` | ✅ | `job.requestedById !== userId` → `Forbidden` |
| `reportJob.cancel` | ✅ | `job.requestedById !== userId` → `Forbidden` |
| `document.generate` | ✅ | `document.churchId !== resolveRequesterChurchId(user)` |
| `file.finalize` | ✅ | membership church must equal `dto.churchId`; path prefix pinned to it |
| `file.upload.init` | ✅ | same church check, in the router before any bucket work |
| `file.upload.complete` | ✅ | `session.socketId !== socketId` — the session *is* the capability |
| `file.download.init` | ✅ | deliberate public exception for the shared song DB; everything else requires a membership whose `churchId` matches the file |
| `approver.update` | ⚠️ **on the RPC path only** — see below |

Nothing moves to 1.5b or 1.5c. The scoped-arg population is real scoping, not decoration.

## 🔴 Finding 4 — `approver.update` enforced on one door and not the other

The RPC case resolved the caller's `membershipId` and passed it in, and the service compared it. But
the parameter was optional and the comparison was wrapped in it:

```ts
async update(id, dto, requesterMembershipId?: number) {
  if (typeof requesterMembershipId === 'number') {   // ← the whole check
    …
    if (existing.membershipId !== requesterMembershipId) throw new ForbiddenException(…);
  }
  return prisma.approver.update({ where: { id }, data: { status: dto.status } });
}
```

`ApproverController.update` — `PATCH /approver/:id`, behind `AuthGuard('jwt')` and nothing else —
called `approverService.update(id, dto)` with **no third argument**. The condition was false, the
check was skipped, and any signed-in account could set any approver row's status by id: approving or
rejecting activities and documents on behalf of other people, in other churches. Approval forgery,
and it drives `maybeAutoGenerateLinkedDocument`, so a forged approval can mint a certificate.

Fixed by moving the resolution *into* the service — it now derives the requester from `user` itself
and refuses when there is none, so no caller can reach the update without an identity. Both doors
now go through the same comparison.

**The general shape, which is worth more than the instance: an optional identity parameter whose
absence silences the check.** Fail-open by omission. A caller that forgets to pass it gets a
successful write, not an error. Every such parameter should refuse rather than skip.

### 🔴 Second limit of the parity table — it only walks one of the two doors

Recorded next to the "helpers, not authorization" limit, because Phase 2 leans on this table:

**The generator walks the RPC `handle()` switch. The 27 REST controllers are a second, independent
door into the same services, and the table cannot see them at all.** `approver.update` is the proof —
guarded in the switch the table reads, unguarded in the controller it does not.

Twelve controllers never reference the requester at all: `account`, `approval-rule`, `approver`,
`church`, `column`, `document`, `financial-account-number`, `location`, `membership-position`,
`membership`, `verify`, `health`. Most are harmless because the service resolves the requester itself
and throws when absent — every `resolveRequesterChurchId` in the codebase opens with
`if (!userId) throw` — so those routes fail closed. The dangerous ones are where enforcement is
*conditional* on a parameter the controller omits. A sweep for that shape found exactly two:
`approver.service.update` (fixed here) and `churchRequest.findAll`, whose `requesterId` comes from
the **query string** rather than the caller, so `GET /church-request` returns every church request
with its contact name, phone and address. That one is a read leak on a separate door and is tracked
as its own ticket.

Phase 2 deletes all 27 controllers, which closes this door by construction — but only when it lands.

---

## Sequencing

`sub.join` and the nine `admin.*` actions are the ones that leak across church boundaries with no
permission model needed to decide the answer — they land first. `ops.approvalRule.manage` follows,
because it closes a finding rather than inventing a policy. The remaining bucket 2/3 work is
per-module and is tracked as its own tickets off the map.
