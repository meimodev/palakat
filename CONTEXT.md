# Context

Domain glossary for palakat. Engineering skills read this before exploring and
use these terms in issue titles, refactor proposals, and test names.

## Glossary

### Finance Entry

A single church financial record — either a **Revenue** (money in) or an
**Expense** (money out). The two are the same concept with opposite ledger
direction: they share one create/update/list/delete flow, one approver
resolution, and one cash-account mutation, differing only by `kind`
(`FinancialType.REVENUE` / `FinancialType.EXPENSE`) which selects the ledger
direction (`CashMutationType.IN` / `OUT`), the cash-mutation reference type, and
the backing Prisma model. Backed by `FinanceEntryService`
(`apps/palakat_backend/src/finance-entry/`). The shared read shape is
`financeEntryInclude`.

Not to be confused with **Finance** (`FinanceService`), which is the
cross-entity reader/approver-override surface over finance entries — combined
list, detail, approver update, admin override, and overview.

### Church-local day

The single calendar date the app treats as "today" for every church, fixed to
**`Asia/Makassar` (WITA)**. GMIM is a Minahasa synod, so no church sits in
another Indonesian zone and no church carries its own timezone. Anything that
matches on a date rather than an instant — birthday notifications, daily
sweeps — resolves it in this zone, never in the process's local time.

_Avoid_: server date, UTC date, today.

### Effective permissions

The set of permission strings a member currently holds in their church,
resolved from their live membership at the moment a request is authorised.
Distinct from a **claim snapshot** — the identity and scope values baked into a
token when it was issued, which may be stale. Identity comes from the token;
effective permissions never do.

_Avoid_: role, claims, grants.

### Column

A named subdivision of a congregation — the neighbourhood grouping a member
belongs to. Unique by name within a church, and the unit activities and
membership invitations are addressed to.

**Not a database column.** In migration and schema documents, always qualify:
"a Column" (the domain concept) versus "a table column".

_Avoid_: group, sector, kolom (in English prose).

### BIPRA

The five-way categorisation of church members by life stage —
**B**apak, **I**bu, **P**emuda, **R**emaja, **A**nak — used to target
activities and announcements. Its values are `PKB` (Pria Kaum Bapa),
`WKI` (Wanita Kaum Ibu), `PMD` (Pemuda), `RMJ` (Remaja) and
`ASM` (Anak Sekolah Minggu).

A member has exactly one. Orthogonal to **Column**: a member has both, and
both are addressable targets.

_Avoid_: age group, category, demographic.

### Notification

A user-facing record that something happened, addressed to a member and
readable in the app. It has content — a title, a body, a thing it refers to —
and it survives being read later. It is a domain object, not a delivery
mechanism.

_Avoid_: push, alert, message.

### Change signal

A hint that some entity changed, carrying an event name and an entity id and
**no content**. It exists to tell a client its cached copy is stale; the client
learns what actually changed by reading over an authorised path. A change
signal is disposable — missing one costs a stale screen, never lost
information.

Distinct from a **Notification**, which has content and is the thing the user
reads. The two travel over the same transport and must not be conflated: a
Notification may be *announced* by a change signal, but the announcement is
never the notification itself.

_Avoid_: event, ping, realtime message.
