# Test vectors

Fixtures for the first posting and close code, written 7 November 2026 from the approved worked example (S section 10) and the product decisions RD01–RD13 and EC06 (see `../implementation-readiness-addendum-2026-10-27.md`). They are inputs for a future test harness. No application exists yet, so nothing here has been run against code.

| File | Content |
|---|---|
| `arithmetic.vectors.json` | Balanced legs and expected measures (A01–A07): worked example, OPEN-period correction, Fund ownership transfer, restricted-view balance, the two EC06 rejects, the proposed refund. |
| `check_arithmetic.py` | Recomputes `C`, `A`, `L`, `N`, `I`, `E`, `Tin`, `Tout`, `GP`, `GB`, the three bridge equations and per-Fund balance from the legs, and compares them to `expect`. Run `python3 -I check_arithmetic.py`; it exits 1 on any mismatch. |
| `behavior.vectors.json` | Scenario vectors (B01–B36): given state, command, required outcome. |

Conventions:

- Amounts are integer rupiah and fictional. Names such as `EARLIER_PERIOD_OPEN` are fixture labels, not an API contract.
- `effects: NONE` means no journal, voucher, voucher counter, `posting_sequence`, case balance or snapshot change.
- `status: DECIDED` means the rule is in S. `status: PROPOSED` (B35, B36, A07) means the RD04 event table is not yet approved: do not implement those.
- B10 records a reading the product owner has not confirmed separately: a master row with no `allowed_effect_kinds` accepts owned posting and blocks custody posting.
- B21 documents a residual: a Fund-only viewer cannot list gaps or read other Funds' vouchers, but still sees that voucher numbers skip.

Not covered, because the contract is not decided or is engineering design still open: EC01–EC05, EC07, EC08, the pseudonymization action and PDF retention (RD11), the RD04 event table until approved.
