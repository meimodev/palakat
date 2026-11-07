# Supplementary design review — 7 November 2026

Scope: a second pass over the MVP specification v5.0 (**P**) and the engineering specification v2.0 (**S**), after the [19 October review](design-analysis-2026-10-19.md) (**R**, findings F01–F16, R01) and the [27 October addendum](../design/implementation-readiness-addendum-2026-10-27.md) (**A**). Findings here are additional to R and A: nothing below repeats F01–F16, RD01–RD08 or EC01–EC05.

Method: S sections 1–15 were read in full, with R and A. P was checked only by targeted search against S (recovery numbers, AI cap thresholds, model IDs, D07 wording, IN_APP deferral, accrual, fiscal year, offline, backdating, personal data). The appendices and P's M001–M775 rules were not read line by line, so P-only rules may hide further conflicts. This is a review of written contracts, not of an application, and not legal advice.

**Checked, no inconsistency:** RPO/RTO/PITR numbers, AI cap thresholds, D07 wording and the IN_APP deferral agree between P and S. The three balance equations and the worked example reconcile.

Status of every item when written: **PROPOSED**. Each maps to a decision (RD09–RD13) or engineering contract (EC06–EC08) in the addendum. Later on 7 November 2026 the user decided RD09–RD13 and the product part of EC06, and those decisions were applied to S and P (see the addendum decision log). EC06's engineering design, EC07 and EC08 remain open.

## N01 — Medium/High: cases are single-Fund but allocations are multi-Fund

Type: missing invariant. Evidence: S section 3 (`AdvanceCase` and `TransitCase` each carry one `Fund`; `TransactionAllocation` carries its own Fund), S section 4.1 invariant 3, invariant 6, S section 7.2 (`A` "by case/Fund").

Invariant 3 exempts only the Fund ownership transfer from per-Fund balance. It never states that every other recipe must balance per Fund. Invariant 6 forbids silently transferring Fund ownership, but nothing ties a settlement's Fund to the case's Fund.

Example: Fund A issues an advance of 1,000. The settlement allocates 700 of Expense to Fund B. Fund A's advance asset falls by 700 and Fund B bears the expense, with no Fund transfer. A remittance paid from Fund B's cash against a Fund A transit case does the same.

Recommendation: see EC06. Acceptance: an advance issued from Fund A and settled with Fund B expense is rejected; so is a Fund B cash remittance against a Fund A case.

## N02 — Medium: no close rule for drafts and staged rows

Type: missing blocker class. Evidence: S section 6.4 (blocker lists), S section 3 (`Period`: CLOSED rejects backdating and corrections), S section 8/F12 (draft attention annex).

Close checks classifications, reconciliation, balances, approvals and evidence. It does not say what happens to DRAFT or REVIEWED transactions, or staged import rows, dated inside the closing period. After close they can never finalize, so they are stranded.

Recommendation: see RD09. Acceptance: close fails with a list of such items; after close, finalizing one is rejected with a clear message.

## N03 — Medium: "approved transit row" has no definition

Type: undefined term in a posting recipe. Evidence: S section 4.2 (custody collection and remittance rows), S section 7.2 (`Tin`, `Tout`), S section 7.3 (family-6 rows may carry ECONOMIC effects), S section 3 (`MasterRow` fields), E011.

The custody recipes post to an "approved" transit row, but `MasterRow` has no attribute for that, and the approved 289-row derivation sets only `postable`. E011 forbids inferring behavior from code shape. Nothing stops a CUSTODY collection from posting to an ordinary offering row, which would move an economic row into `direct_transit` in F05/F07.

Recommendation: see RD10. Acceptance: a custody collection on an ordinary offering row is rejected.

## N04 — Low: voucher numbers leak Fund activity; some batches may have none

Type: disclosure gap and wording conflict. Evidence: S section 8/F12 (gaps remain traceable; "every batch has its committed voucher relationship"), E024, D08, A RD02.

A restricted Fund-A viewer who sees vouchers 101, 102, 105 can infer activity in other Funds. Separately, D08 numbers at finalization of a Transaction, while F12 claims every batch has a voucher; opening and controlled-adjustment batches are not ordinary finalizations.

Recommendation: see RD13.

## N05 — Low: calendar year versus fiscal year

Type: inconsistent terminology. Evidence: D08 (calendar year of effective date), S section 3 (`Workspace`: fiscal/calendar configuration), S section 8/F05 (YTD "from fiscal start"). The phrase "fiscal year" does not appear in P.

For a fiscal year that does not start on 1 January, voucher year and YTD year diverge.

Recommendation: see RD13.

## N06 — Medium: no personal-data retention or erasure rule

Type: missing policy; needs legal input. Evidence: D11, E045 (permanent retention), S section 3 (`Party`, optional member link), S section 8/F03 and F12 (names in frozen reports), S section 13 (Warta masking only).

Party identity, contact data and evidence are kept indefinitely in an immutable ledger and frozen snapshots. Neither document has an erasure, pseudonymization or retention rule for personal data, and neither mentions Indonesia's personal data protection law (UU PDP, 2022). Whether and how that law applies is a question for counsel; this review does not decide it.

Recommendation: see RD11.

## N07 — Low: evidence has no rejected state

Type: modeling gap. Evidence: S section 5.3 (statuses `NOT_REQUIRED`, `REQUIRED_MISSING`, `UPLOADED`, `VERIFIED`, `EXCEPTION_ACCEPTED`).

A reviewer who finds a receipt wrong cannot record that. It collapses into "missing" with no reason retained.

Recommendation: see EC07.

## N08 — Low: AI cap is in IDR but no exchange-rate source is allowed

Type: unenforceable control as written. Evidence: S section 12 (cap of Rp150,000 per month; "do not invent a fixed foreign-exchange rate").

Provider cost is probably denominated in another currency. The cap cannot be enforced, or its pre-request reservation computed, until a rate source is named.

Recommendation: see EC08.

## N09 — Product risk: unit Treasurers depend on the church-wide close

Type: workflow gap created by A RD01. Evidence: A RD01, S section 6.4 step 2, S section 1 (progressive adoption of scoped unit treasurers).

RD01 makes close church-wide and denies Fund-only roles the right to close. One unreconciled Account owned by another unit then blocks everyone's month, with no defined way to show readiness or escalate.

Recommendation: see RD12.

## Order of resolution

1. N01 and N03 before the first posting code: they change the posting contract.
2. N06 before snapshot design.
3. N02 and N09 before close design.
4. N04, N05, N07, N08 are small and can follow.

## Post-cleanup verification

The design files were cleaned up on 7 November 2026 (see P section 0.4 and the S header). These checks were re-run on the cleaned files. Values are in `design-analysis-checks-2026-10-19.json` under `post_cleanup`.

Passed:

- The three fenced JSON blocks in S are identical to git commit `1962b27`. P keeps one fenced block (the production-master derivation); its two catalog copies were removed.
- Both catalogs: 131 and 158 rows, six roots each, unique IDs, valid parents, level = parent level + 1, family consistent, display order sequential, source `postable` all `null`, `postable_proposal` matches topology, source codes unique.
- Branch/leaf counts: Pendapatan 23/108, Belanja 29/129. Approved derivation: 237 postable leaves and 52 nonpostable branches, total 289.
- Production codes are unique after the single B113 override (`2.3.08.02` to `2.3.02.02`).
- Master rules M001–M775 are present once each, in order. D01–D12, F01–F14, RC01–RC16 and E001–E051 are present in S.
- Worked example: C=12,500,000, A=0, L=500,000, N=12,000,000; both liquid bridges give 12,500,000. The OPEN-period correction gives E=1,900,000, C=12,600,000, N=12,100,000. AI cap thresholds are 105,000, 135,000 and 150,000.

Not re-verified, because the files are not in this repository:

- The SHA-256 values of the original classification `.xls` exports.
- The predecessor editions (Handover 4.0, Standalone 1.0) and the claim that they are unchanged.
- The upstream conversations and attachments named as sources.

Remaining overlap, left on purpose:

- P sections 1–15 and the section 16 rules cover the same ground in different words. A similarity check found no near-verbatim repeats, so they are two preserved source documents rather than copies. M-numbers are cited elsewhere, so section 16 stays.
- ~~P section 0.5 and S's approved policy register carry the same rounds 1–6 policy.~~ Resolved the same day: S section 1 is the canonical copy and P section 0.5 now points to it (see the amendment verification below).

## Post-amendment verification

After the product decisions were applied (7 November 2026) the same checks were re-run. Values are in `design-analysis-checks-2026-10-19.json` under `post_amendment`.

Passed:

- The three fenced JSON blocks in S are still identical to git commit `1962b27`. P no longer has a fenced block: the one it had (the production-master derivation) was identical to S's copy and was removed with P section 0.5's duplicate register.
- Both catalogs: 131 and 158 rows, six roots each, valid parents, branch/leaf counts 23/108 and 29/129, 237 postable leaves and 52 nonpostable branches, unique production codes after the B113 override.
- Master rules M001–M775 are present once each, in order. Only M277 changed (RD06). D01–D12, F01–F14, RC01–RC16 and E001–E060 are present in S.
- The arithmetic fixtures A01–A07 in `docs/design/test-vectors/` recompute exactly, including the worked example, the OPEN-period correction, the Fund ownership transfer, the two EC06 rejects and the proposed refund. A deliberate one-rupiah change to an expected value made the checker fail.

Not verified: the behavior fixtures B01–B36 have not run against code, because no application exists. The sources listed under "Not re-verified" above are still not in the repository.
