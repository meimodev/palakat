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

### Bucket 2 — needs a permission (the real work)

Church-scoped writes where a permission already exists or obviously should.

| Actions | Proposed permission |
|---|---|
| ~~`approvalRule.*`~~ | **done** — `ops.approvalRule.manage`, closes Finding 2. |
| `location.create`, `.update`, `.delete` | **super-admin** — national reference data; reads stay open (bucket 1). |
| `church.update` | church-management permission |
| `column.create`, `.update`, `.delete` | church-scoped write |
| `membership.create`, `.update`, `.delete` | `ops.members.invite` / a members-manage permission |
| `account.create`, `.update`, `.delete` | members-manage; `account` is the person record behind a membership |
| `membershipPosition.create`, `.update`, `.delete` | church-scoped write |
| `activity.update`, `.delete` | `ops.activity.create`'s manage counterpart |
| `document.create`, `.update`, `.delete` | church-scoped write |
| `report.create`, `.update`, `.delete` | `ops.report.generate`'s counterpart |
| `approver.create` | approver-manage; pairs with `approver.delete`, which decision 36 builds in Phase 2 |
| `file.delete` | church-scoped write |

### Bucket 3 — needs church-scoping in the service, not a permission

Reads that should return *your church's* rows rather than any row whose id you can guess. Adding a
permission here would be the wrong fix: the caller is entitled to read these, just not all of them.

`account.count`, `account.get`, `membership.get`, `church.list`, `church.get`, `column.list`,
`column.get`, `membershipPosition.list`, `membershipPosition.get`, `approvalRule.list`,
`approvalRule.get`, `document.list`, `document.get`, `report.list`, `report.get`, `file.list`,
`file.get`, `activity.get`, `approver.get`

> `approvalRule.list` / `.get` appear in both bucket 2 and bucket 3 — they need the permission
> *and* the scoping. Listed in each because the two changes land in different layers.

### Needs verification, not fixing (the 29 scoped-arg)

Each passes `user` or a caller-derived id. Confirmed guarded: `churchPermissionPolicy.*`,
`notifications.*`, `finance.approval.*`, `approver.list`, `app.home.get`, `auth.*`, `churchRequest.*`,
`articles.like/unlike`, `membershipInvitation.myPending`.

Still to verify — the service receives `user` but enforcement is unread:
`membershipInvitation.respond`, `finance.approver.update`, `reportJob.list/get/cancel`,
`document.generate`, `file.finalize`, `file.upload.init/complete`, `file.download.init`,
`approver.update`.

---

## Sequencing

`sub.join` and the nine `admin.*` actions are the ones that leak across church boundaries with no
permission model needed to decide the answer — they land first. `ops.approvalRule.manage` follows,
because it closes a finding rather than inventing a policy. The remaining bucket 2/3 work is
per-module and is tracked as its own tickets off the map.
