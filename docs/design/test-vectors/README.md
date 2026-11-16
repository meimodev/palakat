# Test vectors

Fixtures for the first posting and close code, written 7 November 2026 from the approved worked example (S section 10) and the product decisions RD01–RD13 and EC06 (see `../implementation-readiness-addendum-2026-10-27.md`). Extended 15 November 2026 with reconciliation, import, approval and evidence fixtures from S, and with fixtures for the draft engineering contracts. They are inputs for a future test harness. No application exists yet, so nothing here has been run against code.

| File | Content |
|---|---|
| `arithmetic.vectors.json` | Balanced legs and expected measures (A01–A07): worked example, OPEN-period correction, Fund ownership transfer, restricted-view balance, the two EC06 rejects, the proposed refund. Reconciliation equations (A08–A10): bank with timing items, bank with an unexplained difference, cash count. |
| `check_arithmetic.py` | Recomputes `C`, `A`, `L`, `N`, `I`, `E`, `Tin`, `Tout`, `GP`, `GB`, the three bridge equations and per-Fund balance from the legs, and the S 6.3 adjusted statement closing and unexplained difference, and compares them to `expect`. Run `python3 -I check_arithmetic.py`; it exits 1 on any mismatch. |
| `behavior.vectors.json` | Scenario vectors (B01–B92): given state, command, required outcome. |

Behavior vectors by area:

| Area | Vectors | Status |
|---|---|---|
| Close, periods, drafts (RD01, RD09, RD12, RD08) | B01–B07, B15–B18, B29–B30 | DECIDED |
| Effect eligibility, case Fund integrity (RD10, EC06) | B08–B14 | DECIDED |
| Restricted views, vouchers, fiscal year (RD02, RD13) | B19–B24, B60 | DECIDED |
| Cutover, versions, Party IDs, template, onboarding (RD05, RD06, RD11, RD03, RD07) | B25–B28, B31–B34 | DECIDED |
| Refunds and donor returns (RD04) | B35–B36 | PROPOSED |
| Reconciliation (RC11, S 6.3) | B37–B44 | DECIDED |
| Import and finalize idempotency (RC15, S 6.2, S 5.1) | B45–B50 | DECIDED |
| Approval declarations and maker/checker (S 5.2) | B51–B56 | DECIDED |
| Evidence timing and authority (S 5.3) | B57–B59 | DECIDED |
| AI failure leaves finance running (S 12) | B61 | DECIDED |
| Rejected evidence (EC07) | B62–B65 | DRAFT_EC |
| Concurrency and date order (EC01) | B66–B71 | DRAFT_EC |
| Expense items (EC02) | B72–B76 | DRAFT_EC |
| Money components (EC03) | B77–B80 | DRAFT_EC |
| Restore drill and close archive (EC04) | B81–B85 | DRAFT_EC |
| Portable export (EC05) | B86–B88 | DRAFT_EC |
| AI cap reservation (EC08) | B89–B92 | DRAFT_EC |

Conventions:

- Amounts are integer rupiah and fictional. Names such as `EARLIER_PERIOD_OPEN` are fixture labels, not an API contract.
- `effects: NONE` means no journal, voucher, voucher counter, `posting_sequence`, case balance or snapshot change.
- `status: DECIDED` means the rule is in S. `status: PROPOSED` (B35, B36, A07) means the RD04 event table is not yet approved: do not implement those. `status: DRAFT_EC` means the vector follows `../engineering-contracts-draft-2026-11-07.md`, which the implementation designer has not approved: expect changes when the EC is approved, then mark the vector DECIDED.
- A `concurrent` command list runs the commands at the same time; `outcomes` describes the set of results, not their order.
- B10 records a reading the product owner has not confirmed separately: a master row with no `allowed_effect_kinds` accepts owned posting and blocks custody posting.
- B21 documents a residual: a Fund-only viewer cannot list gaps or read other Funds' vouchers, but still sees that voucher numbers skip.
- B76 and B85 depend on open designer decisions (who sets `supported_amount`; whether a close may depend on the write-once store). Their notes say so.

Not covered, because the contract is not decided: the pseudonymization action and PDF retention (RD11), the RD04 event table until approved, the EC05 package format and export retention, and EC07 coverage when one requirement spans several items (the draft says one verified link is enough).
