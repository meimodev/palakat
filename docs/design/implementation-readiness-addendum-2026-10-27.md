# Treasurer MVP — implementation readiness addendum

Date: 27 October 2026 (extended 7 November 2026 with RD09–RD13 and EC06–EC08; decided entries applied to S and P on 7 November 2026)  
Status: PARTLY DECIDED — only entries in the decision log are approved; every other recommendation is not approved policy  
Owners: Product owner (product decisions), implementation designer (engineering contracts), authorized church officer (deployment values)

## 1. Authority and readiness

This addendum turns the remaining specification gaps into decisions, deliverables and acceptance conditions. The user authorized its preparation; that authorization does not approve the recommendations below. The approved rounds 1–6 baseline, including irreversible close under D07, remains in force. On 7 November 2026 the decided entries in the decision log below were applied to S and P; a recommendation outside the log amends nothing.

References:

- [P: MVP specification v5.0](GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md), especially sections 2 and 17 (section 0.5 now points to S section 1, which holds the approved policy register). Its former section 19 is now a map to S; the engineering contract and acceptance cases are in S sections 1–15.
- [S: engineering specification v2.0](GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md), especially sections 3–8, 11 and 13–15.
- [R: design review, 19 October 2026](../reviews/design-analysis-2026-10-19.md), findings F01–F16 and policy risk R01. The review is evidence of gaps, not an approved amendment.
- [R2: supplementary review, 7 November 2026](../reviews/design-analysis-2026-11-07.md), findings N01–N09. Same status as R.

**Current readiness:** foundation work can start. The product decisions are recorded and applied to S and P. Complete the engineering contracts EC01–EC08 and the open conditions in the decision log before treating posting, close, restricted reporting or recovery as settled implementation contracts. Actual church values generally block activation or production use, rather than coding. No application acceptance test has run: this checkout contains specifications, review artifacts and test vectors (`test-vectors/`).

## 2. Product decision register

Every entry is **PROPOSED / awaiting product-owner decision** unless it appears in the decision log below. As of 2026-11-07 all thirteen RD entries are in the log: twelve decided and RD11 partly decided. The EC entries remain OPEN apart from the product part of EC06. The decided entries were applied to S and P on 2026-11-07. Each decision record must capture the selected behavior, any change from the recommendation, decision authority and date. Update the affected contract explicitly after approval; do not infer approval from this document's presence.

| ID | Decision | Review coverage | Blocks |
|---|---|---|---|
| RD01 | Close boundary and ordering | F01, F02 | Final period/close contract |
| RD02 | Shared data visibility | F03, F09 | Restricted reads, reports, attachments and exports |
| RD03 | Report release requirement | F13 | Launch criteria and report-template activation |
| RD04 | Genuine refunds and recoveries | F05 | Those transaction types |
| RD05 | Historical migration | F06 | Pre-cutover migration and reporting promises |
| RD06 | Version selection | F11 | Backdated posting and policy activation |
| RD07 | First authority and succession | F12 | Production onboarding and authority recovery |
| RD08 | Discoveries after close | R01 | Production close workflow and incident handling |
| RD09 | Open drafts and staged rows at close | N02 (R2) | Close workflow |
| RD10 | Master row effect eligibility | N03 (R2) | Custody collection/remittance posting; transit columns of F05/F07 |
| RD11 | Personal data retention and pseudonymization | N06 (R2) | Snapshot design; production use of personal data |
| RD12 | Per-Fund readiness before church-wide close | N09 (R2) | Close workflow for unit Treasurers |
| RD13 | Voucher series, visibility and year basis | N04, N05 (R2) | First finalization in a series; fiscal configuration |

**Decision log.** Entries decided so far. "Contract amendment" is the explicit update of S and P that the decision requires; this addendum does not itself amend either source specification.

| ID | Selected behavior | Change from recommendation | Decided by | Date | Contract amendment |
|---|---|---|---|---|---|
| RD05 | Balance-only cutover for the first release, as recommended | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 6.1; P 9.3 |
| RD06 | Resolve master and policy versions by business date, as recommended | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 4.1 (invariant 11), 5.1, 12; P rule M277 |
| RD10 | Explicit `allowed_effect_kinds` per published master row, as recommended; this extends the approved 289-row derivation | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 1 (effect eligibility), 2, 3, 4.1, 4.2, 7.3, 7.4 |
| EC06 (product part) | One case = one Fund, and per-Fund balance for every batch except Fund ownership transfer and opening, as recommended | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 3, 4.1, 4.2; the engineering design (EC06) is still open |
| RD01 | One church-wide close in chronological order, including empty months; a Fund-only role cannot close, as recommended | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 3, 5.5, 6.1, 6.4, 7.1; P 10.2 |
| RD09 | Open drafts, reviewed transactions and staged rows dated in the period block close until finalized, cancelled or redated, as recommended | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 5.1, 5.5, 6.4, 8/F12; P 10.2 |
| RD11 (snapshot part) | Frozen report data holds the Party ID and names are resolved when rendering, as recommended. Counsel's determination on the personal-data law, the retention rule for already-generated PDFs, and the pseudonymization action itself remain open | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07 (snapshot part): S 3, 7.1, 13. Not applied: counsel's view, PDF retention, pseudonymization |
| RD13 | Voucher year = calendar year with a required 1 January fiscal-year start; one series per workspace and year; typed `OPN` and `ADJ` series for opening and adjustment batches; Fund-only viewers see only vouchers in which they hold a slice, as recommended. The 1 January start is the user's assumption and still needs the church's confirmation | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: D08 in S 1; S 3, 8/F12; P 8.2. The church still confirms 1 January |
| RD02 | Fund-slice representation with separate entitlement for whole-voucher content, other-Fund allocations, original files and whole-Account observations; same representation on every surface, as recommended | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 3, 8/F10–F12, 13 |
| RD03 | Production may launch on an explicitly selected, reviewed default template covering F01–F14 with all eight proposed F14 annexes; no output claims to match original church forms, as recommended | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 6.4, 8/F14, 11, 15 |
| RD04 | A genuine supplier refund reduces current-period Belanja and a genuine donor return reduces current-period Pendapatan, as new events linked to the original; fees are separate; uncertain chargebacks stay unsupported, as recommended. The exact event table (legs, classifications, proof, limits, report placement) is now proposed under RD04 and awaits approval | None | The user, acting as product owner | 2026-11-07 | Principle applied 2026-11-07: S 4.2, 4.3, 7.2. The event table is not approved, so refund and return events are not yet supported postings |
| RD07 | Recorded church authorization naming nominee and authorizing person, verified by a designated human onboarding reviewer; recovery restores the same person, replacement needs new authorization and audited grant, emergency revocation allowed, as recommended. The church must still name its authorization source | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 3, 13; P 1.2, 14.5. The church still names its authorization source |
| RD08 | Keep irreversible close (D07). Before close show the final checks and irreversible consequence and record explicit confirmation. For later discoveries keep an incident (period, records, facts, reconciliation impact, responsible officer, escalation outcome), with narrative and financial resolution recorded separately; an incident never hides a difference or unblocks a close, as recommended. The operational consequence is not yet accepted by the pilot Treasurer | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 4.3, 6.4, 7.2; P 10.4. The pilot Treasurer has not accepted the consequence |
| RD12 | Per-Fund readiness attestation at a cutoff, invalidated by later changes in that Fund; close needs a current attestation for every Fund with activity or a balance; the workspace Treasurer may waive a missing one with a recorded reason, never covering arithmetic or security blockers; applies only once scoped preparers exist, as recommended | None | The user, acting as product owner | 2026-11-07 | Applied 2026-11-07: S 3, 5.5, 6.4, 13; P 10.2 |

### RD01 — One church-wide close in chronological order

**Status: DECIDED 2026-11-07 as recommended (see decision log). Contract amendment applied 2026-11-07.**

**Recommendation:** one authorized workspace-level close freezes every Fund and relevant Account for the month. A Fund-only role cannot close the workspace; its reports are permitted projections of the same frozen inputs. Close every month from cutover in order, including empty months. The first partial month starts at cutover; subsequent openings bind to the preceding final closing. Empty months still require applicable observations and checks. No posting may change an opening already accepted by a later CLOSED month.

**Acceptance:** November cannot close while October is OPEN; a Fund-A user cannot freeze Fund B; after closing November, no earlier effective posting can change its opening. S sections 3, 6.1, 6.4 and 7.1.

### RD02 — Explicit Fund slices and separate attachment entitlement

**Status: DECIDED 2026-11-07 as recommended (see decision log). Contract amendment applied 2026-11-07.**

**Recommendation:** a restricted view contains only authorized allocation amounts and permitted metadata. Whole-voucher totals, free text, actor details, other-Fund allocations and original attachments require explicit entitlement; voucher identity may support traceability without disclosing restricted content. Whole-Account observations, statement lines and matching totals require Account-wide reconciliation permission. A Fund view receives its own book balance and a permitted reconciliation status/reference; restricted observation fields are absent with an explanation. Never invent a Fund-specific observed bank balance.

Use the same representation for screens, search, AI context, PDF/Excel, direct downloads and portable exports. Shared files require separate access decisions; partial financial access does not grant the original file. Restricted report artifacts must be generated for the permitted population rather than exposing an unrestricted snapshot file.

**Acceptance:** BNI holds 1,000, of which Fund A owns 600. A-only F01/F10 book totals equal 600; no response, file link or export reveals Fund B's 400 or the unrestricted statement. S sections 3, 8/F10–F12 and 13.

### RD03 — Reviewed default reports may launch

**Status: DECIDED 2026-11-07 as recommended (see decision log). Contract amendment applied 2026-11-07.**

**Recommendation:** allow production with an explicitly selected, reviewed default template covering F01–F14, accepted by an authorized church officer. Propose all eight canonical F14 annexes in S section 8 as the default inventory; empty annexes are explicitly marked as having no applicable records. Original church forms are required before claiming a verified match to those forms, rather than for every deployment. Signature names/roles remain authorized configuration; a printed signature block is not approval.

**Acceptance:** a church without original forms has a deterministic reviewed-default launch path; no output claims verified original-form compatibility. Check sample PDF/Excel output, totals and negative/zero/null behavior before template activation. S sections 6.4, 8/F14, 11 and 15.

### RD04 — Enumerate new money events separately from corrections

**Status: DECIDED 2026-11-07 as recommended (see decision log), for the principle. The proposed event table below needs approval before refunds are implemented. The principle is applied to S 4.2, 4.3 and 7.2.**

**Recommendation for review:** a genuine supplier refund/recovery reduces current-period economic Belanja; a genuine return to a donor reduces current-period economic Pendapatan. Both use the actual current money movement, an eligible current-period classification and provenance to the earlier event. Neither reverses a CLOSED batch. Fees are separate expenses. Chargebacks with uncertain ownership or obligations remain unsupported until their exact event recipe is approved.

The approved event table must name each supported type, debit/credit legs, eligible classifications, proof/approval requirements, partial-amount limits and F02/F05/F07/F08/F09 placement. A new event can reference a CLOSED original; it cannot repair an erroneous CLOSED book entry by disguise. This is a proposed product rule, not a claim about GMIM accounting requirements.

**Acceptance:** a genuine November refund relating to October produces the approved November effects and leaves October untouched. An attempted correction of an October error still rejects. S sections 4.2, 4.3, 7.2 and 8.

**Proposed event table — written 2026-11-07, awaiting product-owner approval.** Nothing below is in S or P. `m` is the positive amount; legs follow S 4.2 and carry the Fund shown.

| Item | R1 — Supplier refund or recovery received | R2 — Donation returned to the donor |
|---|---|---|
| Meaning | Money comes back from a supplier, or from a person who was paid, for an earlier real payment (cancelled purchase, overpayment returned) | The church returns money to a donor for an earlier owned donation |
| Debit / credit | Debit Cash `m`; credit Expense `m` | Debit Income `m`; credit Cash `m` |
| Fund | The Fund of the original allocation | The Fund of the original allocation; that Fund must hold at least `m` of liquid money |
| Economic effect | Belanja `−m` in the event's own period | Pendapatan `−m` in the event's own period |
| Classification | A published, active, postable Belanja row that allows `ECONOMIC` on the event date. Default: the original row if still eligible; otherwise the Treasurer picks a row and records a reason | A published, active, postable Pendapatan row that allows `ECONOMIC` on the event date. Same default rule |
| Original that may be linked | A direct expense, a paid reimbursement or an own-church centralization expense. The original may be in a CLOSED period. Accepted advance spending is not refundable here: use the advance recipes | An OWNED donation or offering allocation with an identified donor Party. The original may be in a CLOSED period. CUSTODY money is not returnable here |
| Proof and approval | Evidence of the refund (supplier credit note, confirmation or bank line), due before close like other required evidence (S 5.3). Approval follows the church's configured policy | The donor's request or acknowledgement and proof of the payment out, due before close. An external approval declaration where the church requires one for payments |
| Amount limit | Cumulative refunds against one original allocation cannot exceed it. The remaining refundable amount is consumed atomically, so two simultaneous refunds cannot together exceed it (same mechanism as EC01). An excess is rejected, never booked as income | Cumulative returns against one original allocation cannot exceed it, consumed atomically. An excess is rejected |
| Date | The event's own effective date, in an OPEN period. It cannot be backdated into a CLOSED period | Same |
| Original wrongly recorded | Use the OPEN-period reversal and replacement (S 4.3). A refund records money that really came back, not a fix to a wrong entry. A CLOSED original is never repaired through a refund | Same |
| Later reversal of the original | Blocked while a linked refund exists. Reverse the refund first (dependency check, S 4.3) | Same |
| Report placement | F02 receipt column (a book receipt). F07 negative economic amount on its row. F09 classified correction row on the receipt side. F08 book receipts only; economic income unchanged. F10 liquid `+m`. F12 voucher linked to the original. F01 `E` reduced | F02 payment column. F05 negative economic amount on its row. F08 classified correction row (negative economic effect, not a positive receipt). F09 book payment. F10 liquid `−m`. F12 voucher linked to the original. F01 `I` reduced |
| Bank reconciliation | Matched to a statement line through its CashMovementGroup like any receipt | Matched like any payment |

Not supported, and rejected until a separate approval: a chargeback whose ownership or obligations are uncertain; returning CUSTODY (held) money to a donor, which settles a transit liability and needs its own recipe; a refund or return larger than its original. Bank or processing fees on a refund or return are an ordinary direct expense with its own row; no new recipe.

Choices to confirm when approving the table: (a) the original's classification row is the default; (b) the refund or return always uses the original allocation's Fund; (c) an offering with no identified donor cannot be returned through R2; (d) an excess over the original is rejected, not turned into income; (e) evidence is required by default for both events. Fixtures: arithmetic A07, behavior B35 and B36.

### RD05 — Balance-only cutover for the first release

**Status: DECIDED 2026-11-07 as recommended (see decision log). Contract amendment applied 2026-11-07.**

**Recommendation:** launch with reviewed liquid, advance and transit opening schedules. Earlier workbooks may support those balances but do not become authoritative pre-cutover journals. Ordinary imports remain available for supported events on/after cutover. Label reports as covering the available interval; no claim of complete pre-cutover month or YTD activity.

This narrows the currently stated historical-migration alternative and therefore requires explicit approval. If authoritative history is required at launch, specify its interval, earlier opening, master eligibility, historical posting authority, period states and available reports before implementing that route.

**Acceptance:** supporting history cannot add a second opening or bypass cutover/master guards. A mid-month start labels its actual coverage. S sections 4.1 and 6.1–6.2.

### RD06 — Resolve financial versions by business date

**Status: DECIDED 2026-11-07 as recommended (see decision log). Contract amendment applied 2026-11-07.**

**Recommendation:** ordinary entries use the published master and financial approval/evidence policy versions effective on their business date. Authorization is checked when each action occurs. Deactivation does not invalidate legitimate earlier OPEN-period capture. All applicable Fund restrictions must pass; incompatible policies block the transaction rather than selecting a permissive rule.

Policy changes take effect at a future period boundary by default. Do not retroactively invalidate finalized events. A draft whose resolved policy or material revision changes needs renewed applicable review/declaration. Close checks each finalized event against its captured applicable requirements and current required evidence status. Any retroactive policy change needs a separate explicit migration contract. Historical-version reversal permission remains restricted to eligible OPEN-period corrections.

**Acceptance:** an October entry finalized in November resolves the same versions through manual entry, import and AI preparation; a stale draft cannot bypass its applicable requirements. S sections 3–5 and 12; P rule M277.

### RD07 — Audited onboarding and manual succession

**Status: DECIDED 2026-11-07 as recommended (see decision log). The church-named authorization source remains a configuration value. Contract amendment applied 2026-11-07.**

**Recommendation:** establish the first Treasurer from a recorded church authorization naming the nominee and authorizing church role/person. A designated human onboarding reviewer verifies that evidence before granting the financial capability. Technical access alone cannot grant it. The church must name its legitimate authorization source; the product must not invent a universal ecclesiastical approver.

Account recovery re-establishes the same person's identity; replacing the Treasurer requires new church authorization, an audited grant and revocation of displaced access/sessions. Suspected compromise may trigger immediate revocation while succession is pending. No replacement inherits financial approvals or can rewrite history.

**Acceptance:** first activation and loss of the sole Treasurer both have a documented, auditable path without giving infrastructure staff unilateral financial authority. S sections 1, 3 and 13; P sections 1.2 and 14.5.

### RD08 — Incident handling preserves irreversible close

**Status: DECIDED 2026-11-07 as recommended (see decision log). Do not label the operational consequence resolved until the pilot Treasurer has also accepted that some discoveries may prevent later reconciliation or close under V1. Contract amendment applied 2026-11-07.**

**Recommendation:** retain approved D07. Before close, show the final checks, reporting coverage and irreversible consequence, and record explicit human confirmation. For a later discovered omission/error, retain an incident with affected period/records, supporting facts, reconciliation impact, responsible officer and escalation outcome. Record narrative resolution separately from financial resolution; an incident does not erase an unexplained difference or unblock close by itself.

Do not label the operational consequence resolved until the product owner and pilot Treasurer accept that some discoveries may prevent subsequent reconciliation/close under V1. If they require accounting remediation, design and approve a separate policy extension before production use; do not silently add a correction route.

**Acceptance:** the incident cannot mutate a CLOSED journal/snapshot, fabricate current income/expense or bypass a later close blocker. S sections 4.3, 6.4 and 7.2; R/R01.

### RD09 — Open drafts and staged rows block close

**Status: DECIDED 2026-11-07 as recommended (see decision log). Contract amendment applied 2026-11-07.**

**Recommendation:** a DRAFT or REVIEWED transaction, or a staged import row, with an effective date inside the closing period is a hard close blocker. The user clears each item by finalizing it, cancelling it, or redating it into a later OPEN period. Redating is a material edit: it resets review and needs a reason. Show the blockers through the existing nonofficial draft attention annex (S section 8/F12). After close, finalizing a stranded item is rejected with an explanatory message.

**Acceptance:** close fails and lists every such item; after close, finalizing a draft dated in the closed period is rejected with no journal, voucher or sequence effect. S sections 3, 6.4 and 8/F12; R2/N02.

### RD10 — Explicit effect eligibility per master row

**Status: DECIDED 2026-11-07 as recommended (see decision log), including the extension of the approved derivation. Contract amendment applied 2026-11-07.**

**Recommendation:** each published master row carries `allowed_effect_kinds` (`ECONOMIC`, `TRANSIT` or `BOTH`), set explicitly by an authorized human at publication. Never infer it from the family-6 code prefix (E011). Posting validates that a CUSTODY allocation uses a row that allows `TRANSIT` and an OWNED allocation uses a row that allows `ECONOMIC`. Until the church configures a row's value, CUSTODY posting against it is blocked; other work continues.

This adds an attribute to the approved 289-row derivation, which currently sets only `postable`. It therefore needs explicit approval and must not be applied silently to the published derivation.

**Acceptance:** a custody collection on an ordinary offering row is rejected; F05/F07 `direct_transit` contains only rows that allow `TRANSIT`. S sections 3, 4.2, 7.3 and 7.4; E011; R2/N03.

**Two points in the applied text that the product owner has not separately confirmed (2026-11-07):** (1) S treats a row with no `allowed_effect_kinds` as `ECONOMIC` only, so owned posting continues and CUSTODY posting is blocked, which is how "other work continues" was read. (2) Published rows are immutable (D11), so the value must be set when a version is published; a later change needs a new version that activates at a period boundary. A church that wants to post CUSTODY collections in its first month must therefore set the value on the family-6 rows before the first publication.

### RD11 — Personal data: retention basis and pseudonymization

**Status: PARTLY DECIDED 2026-11-07. Decided: snapshots hold the Party ID and resolve names at render time (option (a)). Still open: counsel's determination, the retention rule for already-generated PDF/Excel files that contain names, and the pseudonymization action. The snapshot part is applied to S 3, 7.1 and 13.**

**Recommendation:** obtain counsel's determination of whether Indonesia's personal data protection law (UU PDP, 2022) applies and which retention basis covers financial records. This addendum makes no legal conclusion. Independent of that answer:

- keep personal identifiers only in `Party`; ledger rows and snapshots reference the Party ID;
- provide an audited pseudonymize-Party action that never changes amounts, journals, vouchers or snapshot hashes;
- decide how snapshots hold names, either (a) store the Party ID and resolve the display identity at render time, or (b) freeze names with a documented legal basis.

Option (b) conflicts with pseudonymization, so this choice shapes snapshot design and must precede it. Define a retention rule for evidence files that contain personal data.

**Acceptance:** after pseudonymization of a Party, all report totals and snapshot hashes are unchanged and no restricted view reveals the former identity under option (a). S sections 3, 8/F03, 8/F12 and 13; D11; R2/N06.

### RD12 — Per-Fund readiness attestation

**Status: DECIDED 2026-11-07 as recommended (see decision log). Contract amendment applied 2026-11-07.**

**Recommendation:** for each Fund, a scoped preparer records readiness for a month at a posting cutoff. Later changes in that Fund invalidate the attestation, using the same rule as reconciliation confirmation. Close requires a current attestation for every Fund with activity or a balance. The workspace Treasurer may waive a missing attestation with a recorded reason. A waiver never covers hard arithmetic, tenant or security blockers (S section 6.4).

**Acceptance:** close lists each Fund without a current attestation; a waiver is audited; a Fund-A preparer can attest Fund A but cannot close the workspace. Builds on RD01. S sections 6.4 and 13; R2/N09.

### RD13 — Voucher series, visibility and year basis

**Status: DECIDED 2026-11-07 as recommended (see decision log). The 1 January fiscal-year start is an assumption until the church confirms it; the church-configuration row stays NOT YET RECORDED. Contract amendment applied 2026-11-07.**

**Recommendation:**

- keep one series per workspace and year (D08); do not split series per Fund;
- a restricted viewer sees only vouchers in which they hold an authorized slice; the gap listing in F12 requires workspace-wide capability;
- give opening and controlled-adjustment batches typed series (for example `OPN` and `ADJ`) from the same allocator, so the F12 statement that every batch has a voucher holds;
- require, for V1, that the fiscal year begin on 1 January, pending church confirmation. If the church uses another start, change D08 to the fiscal year instead.

**Acceptance:** a Fund-A-only voucher list exposes no gap from which another Fund's volume is evident; every posted batch has a voucher in a typed series; a non-January fiscal configuration is rejected, or numbers follow the fiscal year if D08 is changed. D08; E024; S sections 3 and 8/F12; R2/N04 and N05.

**Residual disclosure (noted 2026-11-07):** with one series per workspace, a Fund-only viewer cannot list gaps or read other Funds' vouchers, but still sees that numbers skip (for example 101, 102, 105). The decision hides the gap listing, other Funds' content and amounts, not the skip itself, so the acceptance sentence above is met only in that sense. If hiding the skip matters, the options are a per-viewer display sequence or a series per Fund, either of which changes D08 and this decision. Fixture B21 records the current behavior.

## 3. Engineering contracts to complete

Owner for EC01–EC08: **implementation designer**. Status: **OPEN — required design deliverables**. These complete existing guarantees; any discovered change to product behavior returns to the product owner. Database tables, framework and deployment vendor are engineering choices.

| ID / evidence | Required artifact and acceptance | Blocks |
|---|---|---|
| EC01 / F07 | Define atomic consumption of case balances and reconciliation source amounts, effective-date ordering and validation of affected later positions. Two simultaneous 700 settlements against 1,000 cannot both commit; a day-10 settlement cannot consume a day-20 issue. Validate correction bundles as one combined result. | Settlement, remittance, matching and backdated commands |
| EC02 / F08 | Define accepted claim/expense items, supported amount and atomic allocation across advance settlement/reimbursement, including partial repayments and cancellation/correction effects. Reject 700 + 700 against one supported 1,000 item; permit supported 600 + 400 without duplicate recognition. Reusing a file as nonfinancial support is distinct from consuming an expense item. | Expense-item and evidence-allocation model |
| EC03 / F10 | Define stable money components with Account, amount/direction, payment reference and allocation membership. Specify header/component/allocation and owned/custody sum rules. A 600 cash + 400 bank collection produces exactly two physical movements and 1,000 allocated money. Noncash settlement and ownership-only transfers retain their distinct recipes. | Multi-Account capture and posting model |
| EC04 / F04 | Select and document a durable commit/recovery mechanism covering journals, vouchers, idempotency records, audit, close manifests and required evidence/snapshot dependencies. Define when success is acknowledged and how recovery verifies the latest acknowledged state before writes resume. Demonstrate restoration from before an acknowledged close without losing that close or duplicating a retry. Preserve approved recovery targets; changing the guarantee requires policy approval. | Production durability/recovery architecture |
| EC05 / F14 | Give each portable export a manifest ID, consistent read cutoff and enumerated immutable file versions. Define current accountability versus frozen report status, retained file availability and incomplete-package behavior. Concurrent posting/upload cannot produce broken references; retries package the same population. Missing required files prevent a complete/success claim. | Full portable export implementation |
| EC06 / N01 | Add to S section 4.1 the invariant that, except for the Fund ownership transfer and opening, every batch balances per `fund_id` across all targets. Keep one case = one Fund; an advance issue with allocations in several Funds creates one case per Fund. Settlement, return and remittance allocations must use the case's Fund; a different Fund requires a Fund ownership transfer first. The posting module asserts per-Fund balance in the same transaction. The product decision "one case = one Fund" was confirmed on 2026-11-07 (see decision log) and S section 4.1 (invariants 3 and 9) now states the rule; the engineering design stays OPEN until the implementation designer delivers it. Fixtures: arithmetic A05–A06, behavior B12–B14. Acceptance: an advance issued from Fund A and settled with Fund B expense is rejected, as is a Fund B cash remittance against a Fund A case. | Posting module; advance and transit settlement |
| EC07 / N07 | Add a `REJECTED` decision, with a required reason, to the evidence-link decision log (S section 5.3). Status falls back to `REQUIRED_MISSING` when no valid link remains; the rejection stays in audit and in the UI. Acceptance: rejecting a receipt records who, when and why, keeps the close blocker, and leaves prior verification history intact. | Evidence model |
| EC08 / N08 | Store a reviewed IDR-per-provider-currency rate in each AI policy version, with its date and the authorized officer who set it. Do not fetch a live rate. Record the rate version on each usage record and use the same rate for the pre-request reservation. Acceptance: two concurrent requests cannot together exceed the Rp150,000 cap under the active rate. | AI cost metering |

## 4. Church configuration and source register

Owner: **authorized church officer**, with implementation support. Status: **NOT YET RECORDED**. No illustrative value is a production default. Record values in a reviewed deployment configuration with activation actor/time and version IDs.

| Required artifact | When it blocks |
|---|---|
| Church identity, timezone, fiscal calendar, first production month, cutover date | Workspace financial activation |
| Actual Accounts, Funds, Scopes and verified opening schedules, including zero positions and outstanding cases | Opening approval and first ordinary posting |
| Published 289-row production master, explicit postability and approved B113 correction; source catalogs retained | Classified posting; derivation is already approved and needs no new policy choice |
| Voucher series, prefixes/padding and year behavior consistent with D08 | First finalization in the series |
| Approval requirements/thresholds where used, external declaration requirements, maker/checker setting, permitted solo verification and exception authorities | Affected review, finalization, verification or exception action |
| Due-date/overdue restrictions where used; beneficiary identities, allocation formulas and rounding for applicable centralization/custody events | Affected case/event or close check |
| Selected reviewed default or verified original forms, F14 inventory, signature identities and sample output | Report-template activation and production close/export |
| Original blank/example forms and verified field/page/cell mappings, if exact church-form compatibility is promised | That compatibility claim; RD03 decides whether these block launch |
| Onboarding/succession authorization records and authorized financial capabilities | Initial access or replacement under RD07 |
| `allowed_effect_kinds` for each published master row, set when the version is published (published rows are immutable) | CUSTODY posting on that row (RD10) |
| Counsel's determination on personal data law and retention basis | Snapshot design and production use of personal data (RD11) |
| Confirmation that the fiscal year begins on 1 January, or the actual start | Fiscal configuration and voucher year (RD13) |
| Typed voucher series for opening and adjustment batches | First opening or adjustment finalization (RD13) |
| Reviewed IDR rate per AI policy version, with date and authorizing officer | Optional AI use (EC08) |

Absence of an optional threshold or due-date restriction must be an explicit permitted policy choice, not a guessed number. Missing required configuration blocks only the dependent action; draft preparation may continue where allowed. Approved AI models/privacy/cap and recovery targets remain existing requirements. Verify live AI endpoint eligibility during integration; unavailable assistance must leave manual finance operational.

## 5. Implementation sequence and completion evidence

1. **Foundations:** workspace, authentication, tenant/capability checks, Accounts/Funds/Scopes, reviewed masters and configuration. Define EC04 early enough to guide storage architecture. Use a single application and transactional database as specified in S section 3.
2. **First complete finance path:** approved opening, one receipt and one expense, required evidence/external declaration, reconciliation, chronological close and a basic snapshot report/export. Include audit, idempotency, authorization and integer arithmetic from the first posting. This is an implementation milestone, not the complete MVP.
3. **Expand:** advances, transit, reimbursements, transfers, multi-component collections and staged imports; finish F01–F14 PDF/Excel/print and full portable export, then optional AI. Preserve the baseline's explicit deferrals and later collaboration roadmap.

Resolve RD10 and EC06 before the first posting code, because they change the posting contract. Resolve RD11 before snapshot design. Resolve RD09 and RD12 before close design. RD13, EC07 and EC08 are small and can follow.

Before implementing each affected path, resolve its RD/EC entries and write the corresponding acceptance examples. Before production, record the required church values, visually verify report files, run the S section 15 acceptance cases plus this addendum's examples, and demonstrate restore/export integrity. Passing document checks is not application validation.

For each acceptance result retain scenario, expected/actual behavior, implementation revision and evidence. Include permission failures, concurrent/retried commands and OPEN/CLOSED boundaries, rather than only successful happy paths. The worked financial fixture and cross-report controls in S sections 9–10 supply common arithmetic expectations. Fixtures for the decided cases are in `test-vectors/`; run `python3 -I check_arithmetic.py` there for the arithmetic set.

## 6. Documentation follow-through

F15/F16 are documentation follow-ups, not new finance policies. When publishing the approved follow-up contract, link preserved rules to the active historical-inclusion and balance equations, identify which current contract governs each concern, and add a source manifest distinguishing embedded catalogs from externally held originals/predecessors. Keep historical editions and source snapshots intact. Do not repeat inherited verification claims as newly reproduced checks.

The policy register and the production-master derivation had two identical copies (P 0.5 and S section 1). On 2026-11-07 S section 1 became the canonical copy and P 0.5 became a pointer to it.

This addendum is the review entrypoint until its decisions are recorded. No RD or EC entry is closed merely because a recommendation or acceptance example has been written.
