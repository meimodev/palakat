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
