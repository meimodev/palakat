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
