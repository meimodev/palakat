# Design review — 19 October 2026

Reviewed both documents in `docs/design`: the MVP specification v5.0 (**P**) and standalone engineering specification v2.0 (**S**), totaling **6,109 lines**. > **Note (7 November 2026):** the two design files were cleaned up after this review. Links below were re-pointed to the cleaned files by matching each target line's text; two targets no longer exist and were re-aimed (`p-storage` to the cleanup record, `p-remaining` from the removed Appendix C.4 to section 17.2). Source hashes in the checks JSON still describe the reviewed files at git commit `1962b27`; post-cleanup values are in that JSON's `post_cleanup` block. P section 19 is now a map to S, and the readable catalog tables and duplicate JSON in P were removed.

This is a review of the written contracts and embedded data, not an audit of a running application or an assessment of financial/legal compliance.

**Assessment:** The main financial model is coherent: Account, Fund, Scope and classification remain separate; advances and custody money have explicit bridges; posting is atomic; report calculations are deterministic. The documents are strong as a policy archive. They are less complete as an implementation contract: several decisions needed to preserve those invariants are still implicit, despite statements that only deployment/configuration work remains.

There are **16 findings: 4 high-priority gaps/conflicts, 10 implementation clarifications, and 2 documentation issues**, plus one explicit policy risk and five simplification opportunities. Priorities describe the consequence of implementing the text literally, not confirmed application defects. No source document or approved policy was changed.

**Evidence checked independently**

- All M001–M775 appear once, in order; E001–E051 and F01–F14 are complete in both documents.
- All three fenced JSON blocks in each document are byte-identical to their counterparts.
- Each catalog has the stated row count, six roots, unique codes, valid parent references and an acyclic hierarchy with consistent levels/families.
- The readable tables agree with their JSON rows, accounting for Markdown `&nbsp;` display escapes.
- Pendapatan has 108 leaves / 23 branches; Belanja has 129 leaves / 29 branches. The approved derivation produces 237 postable leaves / 52 nonpostable branches.
- Applying only B113's approved code override preserves unique production codes. Its different source and production codes are intentional provenance, not an inconsistency.
- The worked example yields C=Rp12,500,000, A=0, L=Rp500,000, N=Rp12,000,000; all three balance bridges hold. The alternative correction fixture and AI cap thresholds also reconcile.
- Comparing S sections 2–14 with P sections 19.1–19.13, after normalizing headings and section references, found 11 equal bodies and two editorial introduction differences. No material policy drift was found in those compared bodies.

Machine-readable results, source hashes and illustrative counterexamples are in [design-analysis-checks-2026-10-19.json][checks]. Historical source files/predecessors and live AI endpoints were not independently verified.

**F01 — High: close ordering does not protect later opening balances**  
Type: missing invariant. Evidence: [period schema][s-period], [close algorithm][s-close], [report opening population][s-population].

Close validates the requested period and blocks concurrent changes, but never requires earlier accounting periods to be closed. Posting only requires its own effective period to remain OPEN. These rules permit November to close while October remains OPEN.

Example: opening=1,000; October income=100; November income=50. November freezes closing=1,150. A later ordinary October receipt of 200 is permitted by October's OPEN status. October eventually closes at 1,300, while November's frozen opening remains 1,100. November's snapshot stays unchanged, but consecutive periods and the current ledger no longer agree. This is an ordinary earlier-period posting, so guarding CLOSED correction targets does not prevent it.

**Recommended contract:** Close periods chronologically from the approved cutover; bind each opening to the preceding final close; reject postings that would change a later CLOSED period's opening. For MVP, one workspace close frontier is simpler than independently mutable earlier periods. Specify the first partial month and empty-month handling.

**Acceptance:** November close fails while October is OPEN. After November closes, no command can introduce an earlier effective posting that changes its opening.

**F02 — High: the scope of close is inconsistent with the Period record**  
Type: ambiguous state ownership. Evidence: [Period and ReportSnapshot][s-period], [perimeter permissions][s-permissions], [close step 1][s-close].

The close command accepts a “period/perimeter,” and Fund-specific full packs are supported. Period has one status and one `closed_snapshot_id`, without a Fund perimeter. It is unclear whether a unit Treasurer closes only their Funds or closes the entire church month.

A Fund-A-only close could either mark the workspace Period CLOSED and freeze Fund B prematurely, or leave Fund B writable despite a globally CLOSED status. Cross-Fund transfers make independent close states more complicated.

**Recommended contract:** In MVP, one authorized workspace-level accounting close freezes all Funds and relevant Accounts. Fund reports are authorized projections of that close; scoped preparers may confirm readiness without changing Period status. If independent Fund closing is intended, it requires an explicit state model and cross-Fund transaction rules rather than an extra report filter.

**Acceptance:** An actor with Fund A access alone cannot close the workspace month. A workspace close includes Fund B and all applicable transfer dependencies.

**F03 — High: Fund reports lack a safe definition of shared-Account observations**  
Type: report-contract ambiguity with privacy consequences. Evidence: [Fund-only visibility][s-permissions], [full Fund pack completeness][s-completeness], [F10][s-f10], [F11][s-f11].

The permission contract correctly prohibits exposing another Fund's share or unrestricted statement details. F10 nevertheless describes one row per physical Account, observed statement closing and nested Fund slices. F11 exposes account-wide observations and matching amounts. Their controls also require F10 combined closing to equal F01 for the same perimeter.

If BNI holds 1,000, with A owning 600 and B owning 400, Fund A's F01 closing is 600. Using the physical Account's 1,000 as F10's primary closing breaks that equality. Copying the real statement closing into Fund A's report exposes information outside its Fund entitlement. A bank statement has no independently observed “Fund A balance” unless a separate supported observation exists.

**Recommended contract:** Define distinct whole-Account and Fund-slice projections. A Fund pack's book measures use its authorized slices; whole-Account observations, matching totals and statement lines require whole-Account capability. Fund-only viewers receive a permitted reconciliation status/reference, with restricted observation fields absent and explicitly explained. Do not allocate a statement closing pro rata and label it observed.

**Acceptance:** A Fund-A-only pack reconciles its book totals at 600 and exposes neither Fund B's 400 nor unrestricted statement metadata.

**F04 — High: the recovery guarantee exceeds what the stated RPO alone guarantees**  
Type: unresolved operational contract. Evidence: [approved recovery policy][s-recovery-policy], [recovery procedure][s-recovery].

The product permits a one-hour recovery point objective, but also says recovery must not undo a successfully CLOSED period and must recover committed events if restored data predates them. No independent durable source or replay protocol is specified for those missing events.

If a close succeeds at 10:30 and the newest recoverable data is from 10:00, its snapshot, vouchers, idempotency records and audit may all be missing. The instruction “recover those events” is not enough to reconstruct them exactly. Bank statements cannot recover classifications, approvals or all noncash postings.

**Recommended contract:** Define what constitutes an acknowledged durable financial commit, which protected data survives the recovery window, and how commits/close manifests/idempotency records are reconciled before writes resume. If successful closes must never be lost, identify the durability mechanism that provides that guarantee. Otherwise the user-facing recovery promise requires an explicit policy amendment acknowledging possible loss within RPO.

**Acceptance:** Restore to a point before an acknowledged close and demonstrate recovery of that exact close and its dependencies without duplicate vouchers or postings.

**F05 — Medium: genuine refunds are allowed without a posting recipe**  
Type: incomplete recognition contract. Evidence: [posting matrix][s-matrix], [refund paragraph][s-refunds], [canonical signed measures][s-measures].

The text distinguishes a genuine current-period refund/chargeback/recovery from a forbidden correction of a CLOSED original. It also allows negative economic categories. But the positive-amount posting matrix contains ordinary receipt and expense recipes plus OPEN-only reversals; it never specifies the permitted refund recipes.

A November refund for October spending could therefore become either new Pendapatan or negative Belanja depending on the implementer. A donor refund has the corresponding ambiguity. Reversing the October batch would violate D07.

**Recommended contract:** Enumerate supported real-event refund types, debit/credit legs, recognition/classification policy, proof requirements, provenance links and F08/F09 placement. Decide the treatment explicitly; do not infer it from cash direction or silently reuse reversal authority.

**Acceptance:** A genuine refund referencing a CLOSED original posts in the current OPEN period using its approved new-event recipe; the original stays unchanged and report measures agree.

**F06 — Medium: history import conflicts with the stated cutover/master window**  
Type: incomplete migration algorithm. Evidence: [initial master activation][s-activation], [cutover and history-derived opening][s-cutover], [ordinary posting guards][s-invariants].

Ordinary V1 transactions begin on/after cutover, and the first production master activates on the first day of the production month. The supported alternative migration approach imports history ending before cutover. The document does not say whether this history becomes authoritative journals, supporting source data, or a separate opening calculation.

For a 15 October cutover and August–October history, ordinary August posting would precede both cutover and the initial master's effective interval. If history is staging-only, it cannot automatically provide authoritative earlier-month realization/YTD.

**Recommended contract:** Specify the history-import interval, approved historical master eligibility, initial balance required before that history, posting authority, treatment of pre-cutover periods, and exactly which reports are available. Separate “derive cutover balances from reviewed source history” from “migrate authoritative historical journals.” Preserve the existing nonduplication rule.

**Acceptance:** A history spanning months before first production activation either follows a defined migration contract or is rejected with a clear supported alternative; it cannot bypass ordinary guards accidentally.

**F07 — Medium: case availability needs both temporal and concurrent validation**  
Type: missing command-level guarantees. Evidence: [atomic posting][s-invariants], [advance limits][s-advance-limits], [derived case balances][s-case-states], [reconciliation consumption][s-matching].

The nonnegative advance/transit and non-overallocated matching invariants are clear. The text does not define serialized consumption of shared case/source availability or whether “current outstanding” is evaluated by effective date or only by all committed postings. Period locking alone does not serialize two settlements in the same OPEN period.

Examples: two requests each see outstanding=1,000 and accept 700, producing −400 together; or an issue effective on day 20 is already committed and funds a backdated settlement effective on day 10. The eventual case total is positive, but the historical balance is negative.

**Recommended contract:** Serialize affected case/source consumption, or use an equivalent conditional transactional constraint. Define chronological availability at the event's effective date and validate affected subsequent positions when backdating. Apply the same principle to match allocations. Atomic correction bundles can still validate their combined final state as already specified.

**Acceptance:** Concurrent consumption cannot exceed availability; backdating cannot create an invalid historical case position. These are additional cases beyond correction-versus-close races.

**F08 — Medium: evidence allocation is named but not modeled enough to prevent double reimbursement**  
Type: incomplete supporting-object contract. Evidence: [evidence record][s-evidence-record], [advance/reimbursement nonduplication rule][s-advance-limits], [F14 annexes][s-f14].

The document correctly prohibits accepting one receipt as both advance spending and reimbursement, and says evidence allocation identifies each accepted portion. The logical record describes file links/status, without a supported-amount/item consumption contract or a rule for partial payments of one personal claim.

A receipt supporting 1,000 could back an accepted advance settlement of 700 and a separate reimbursement of 700. File checksums or “VERIFIED” status alone do not enforce the combined limit, especially with concurrent commands.

**Recommended contract:** Describe accepted expense/claim items and their allocated supported amount, link each recognized expense to its accepted portion, and define atomic reuse limits and explicit legitimate multi-event usage. This can be a small logical record; it does not require a document-management platform. Preserve nonfinancial reuse, such as one statement supporting several distinct payments.

**Acceptance:** The 700+700 example is rejected or requires an explicitly supported additional item; valid 600+400 allocation is counted once.

**F09 — Medium: mixed-Fund transactions need field-level and file-level disclosure rules**  
Type: authorization gap. Evidence: [transaction/allocations][s-transactions], [Fund visibility][s-permissions], [F12 nested fields][s-f12], [full export][s-export].

Fund isolation is required, but a single transaction can contain several Funds and a receipt can support several lines. F12 groups the whole voucher with nested allocations, approvals and evidence. A Fund-A user may be entitled to one allocation without being entitled to the whole voucher or attached unredacted receipt, which could expose Fund B.

Filtering ledger rows by Fund is insufficient to protect the shared header, descriptions, actor metadata, totals and original evidence file.

**Recommended contract:** Define the authorized representation of mixed transactions: permitted allocation slice, allowed header metadata, whether whole totals may be disclosed, and separate entitlement to the original attachment. Reuse that representation in drill-down, search, AI context, PDF/Excel and portable exports. An authorized financial slice must not implicitly grant access to a shared file's complete contents.

**Acceptance:** Fund-A access to a split voucher exposes only the approved representation; direct attachment links and export packaging do not reveal restricted Fund-B data.

**F10 — Medium: multi-Account transaction components are used before being defined**  
Type: incomplete logical schema/interface. Evidence: [transaction records][s-transactions], [offering components][s-offerings], [F02 row grain][s-f02].

Offerings can have Cash, QR and bank components; allocations sum to a “transaction component”; F02 sorts by `component_ordinal`. The logical schema defines a header amount and allocations, but no explicit component contract connecting Account, payment reference, ownership split and allocation subset. Account information first appears in the generated journal/movement group.

Two implementations could construct different movement groups or duplicate money when allocating one collection across Accounts and Funds.

**Recommended contract:** Define a minimal transaction-component structure with stable identity, Account, amount/direction, payment reference and associated allocations. State the sum rules between collection total, money components and economic/custody partitions. This is a logical contract and need not force a particular database table.

**Acceptance:** A collection containing 600 Cash and 400 bank, with an owned/custody split, yields exactly two physical movements and 1,000 total allocated money.

**F11 — Medium: policy/master selection needs an explicit time rule**  
Type: ambiguous version resolution. Evidence: [policy configuration][s-policy-config], [master eligibility][s-invariants], [approval/review binding][s-approval], [AI candidate validation][s-ai-validation], [Master rule 277][p-m277].

The documents distinguish effective business date from finalization timestamp, but “active” master eligibility is not explicitly tied to one of them. M277 says the version effective when transactions were “posted”; numbering uses effective-date year. AI validates active candidates, while reversals have a historical-version exception. Backdated ordinary posting during two OPEN months therefore needs a clear rule.

Approval/evidence policies are versioned, but their effective interval and the effect of a new policy on already-finalized OPEN-period transactions are also unspecified. A new policy could unexpectedly invalidate approvals at close, or an old draft might evade a newly activated restriction.

**Recommended contract:** State the resolver for each version type, including effective date, current authority and applicable policy precedence across multiple Funds. Keep authorization-at-action-time separate from financial-version selection. Define review invalidation and close checks after policy activation; require explicit handling of any retroactive change. Document master deactivation without making valid earlier OPEN-period capture impossible.

**Acceptance:** A backdated October transaction finalized in November uses the intended version and applicable policy consistently in manual entry, import and AI suggestions.

**F12 — Medium: solo onboarding and loss of the sole Treasurer have no authority-recovery path**  
Type: missing operational workflow. Evidence: [activation requires authorized humans][s-config-values], [technical versus financial authority][s-permissions], [solo use][p-adoption], [Treasurer death/access consequences][p-death].

Authorized humans must activate configuration and hold financial capabilities, while technical administration cannot confer financial authority automatically. The documents do not identify how the first authorized church officer is established or how authority is recovered after the sole authorized user is unavailable, compromised or loses credentials.

The future member-death rules correctly prohibit automatic financial access transfer. That leaves a practical MVP workflow to define even before member lifecycle features exist.

**Recommended contract:** Specify initial church authorization evidence, who grants the first financial role, how account recovery differs from replacement of a Treasurer, and an audited manual succession procedure. Keep operational identity recovery separate from approval of financial activity. No universal ecclesiastical approver identity should be invented.

**Acceptance:** A church can establish and later recover legitimate operational control without granting infrastructure staff unilateral financial authority.

**F13 — Medium: original forms are both a production gate and an optional later binding**  
Type: release-gate inconsistency. Evidence: [default report allowed at close][s-close], [default compatible template][s-template], [production gate table][s-gates], [M331/M332][p-template-rules].

Close permits an explicitly selected default compatible report when church policy allows it. The production gate table nevertheless calls for actual original forms and verified bindings; M332 describes church-specific mapping as something supported later. This leaves two different launch criteria.

**Recommended contract:** Separate the gate for using the reviewed default template from the gate for claiming verified compatibility with a specific church's original form. State whether default-template-only MVP production use is permitted, who selects it, and which required F14 annexes it includes. Keep unverified originals clearly labeled.

**Acceptance:** A deployment without original forms gets one deterministic outcome—permitted under a defined reviewed-default contract, or blocked with the exact required artifact.

**F14 — Medium: full portable export lacks a consistent read boundary**  
Type: missing export reproducibility contract. Evidence: [snapshot reproducibility][s-serialization], [full export and retries][s-export], [evidence updates after close][s-evidence].

The full export includes current ledger, cases, approvals, evidence files and versioned official snapshots. Unlike accounting reports, it has no declared dataset cutoff. Those records can change while packaging runs or between retries.

A manifest could list an evidence link before upload completion, package case status after a new settlement but omit that settlement's journal, or include newly committed records only on retry. Checksums show file identity, not relational consistency.

**Recommended contract:** Define an export manifest ID and consistent database read cutoff, enumerate immutable evidence-object versions from that population, distinguish current accountability data from frozen report status, and retry packaging against the same manifest. Specify how missing required files affect completion. This can reuse snapshot/manifest mechanisms rather than adding a separate export ledger.

**Acceptance:** An export started during posting/evidence updates contains a coherent documented population; retry preserves the selected population and every referenced file resolves.

**F15 — Low: preserved rules still look like conflicting executable requirements**  
Type: documentation hazard already partially acknowledged. Evidence: [M073–M077][p-finalized], [M246][p-formula], [historical-inclusion clarification][s-dates], [known source tensions][p-tensions].

M073–M077 say only FINALIZED transactions affect reports, while an original's display becomes REVERSED and its posting must remain included. M246 gives a simplified cash equation without the advance/transit bridges. Appendix C.5 already recognizes these tensions, and the engineering contract resolves them correctly. These are not newly discovered unresolved arithmetic defects; they remain risky when the master rulebook is consumed on its own.

**Recommended cleanup:** Preserve archived wording but add explicit rule-level interpretation links: “committed journal effects, including reversed originals,” and the applicable full balance equations. Make the active contract discoverable at the rule, rather than requiring readers to find a late appendix. Likewise label remaining historical “proposed” wording where later approval already supersedes it.

**F16 — Low: provenance claims cannot all be reproduced from this repository**  
Type: evidence-packaging gap. Evidence: [predecessor identity][p-predecessor], [source hashes][p-hashes], [old storage description][p-storage], [edition PASS claim][s-verification].

Only the two design Markdown files are tracked as design/source artifacts in this checkout. The original XLS exports, predecessor editions and prior verification materials named by the documents are absent. Embedded data makes the catalogs usable, but does not reproduce the original XLS byte hashes or prove predecessor preservation. P's storage description also refers to a prior chat's outputs folder rather than this repository. (That section, 18.5, was removed in the 7 November 2026 cleanup; its link now points at the cleanup record.)

**Recommended cleanup:** Add a repository-oriented source manifest identifying available embedded evidence, archived artifacts and externally held files. If originals are available and appropriate to retain, archive them immutably with hashes; otherwise mark historical verification claims as inherited, with current checks separately recorded. Do not imply that the current review reverified absent originals.

**Approved-policy risk R01 — D07 can leave an operational discrepancy unresolved**

Evidence: [irreversible-close policy][s-d07], [forgotten CLOSED events][s-adjustments], [required zero unexplained difference][s-close].

D07 is explicit, approved and internally repeated consistently. It is not an accidental contradiction to “fix.” Its consequence still deserves an explicit operational decision: a genuine previously omitted or erroneous CLOSED-period entry may become discoverable later, yet the MVP offers no correction mechanism and future reconciliation cannot hide the discrepancy.

**Recommendation:** Keep D07 enforced. Add an incident/discrepancy record and an escalation outcome for discoveries after close, and validate the exact pre-close acceptance experience with the Treasurer. If ongoing operation requires a governed later-period correction or report correction mechanism, that is a separately approved policy extension. Never disguise it as ordinary current income/expense or silently reopen a month. A stronger confirmation screen reduces mistaken closes but cannot guarantee that future discoveries never occur.

**Optimization O01 — Maintain one editable contract and generate handover editions**

The same engineering body appears twice, each source catalog appears as both readable tables and JSON in both documents, and policy decisions are repeated again in narrative, M/E/L/C rules and appendices. The copies currently agree well; maintaining them independently creates future drift risk and makes review expensive.

Use one canonical source per concern: current product scope/policy, engineering contract, versioned source catalogs and decision register. Generate readable catalog tables and any self-contained handover editions from those sources. Preserve the supplied v5.0/v2.0 files as immutable historical editions. Add a short entrypoint explaining which current source governs each concern and a rule-to-contract map. A few Markdown/JSON files and a small generation/check script are sufficient; no documentation platform is needed.

**Optimization O02 — Build an end-to-end finance slice before completing every layer**

Evidence: [build order][p-build-order], [posting must include audit][s-invariants].

The build list puts Audit after GMIM reports, but posting/close require atomic audit from their first implementation. It also delays the primary product outcome—usable reports—until many transaction families have been built.

Keep audit, isolation and permissions in the first posting path. Deliver a thin slice: workspace + account/fund/scope + published master + opening + one receipt + one expense + proof/external declaration + reconciliation + close + a basic report/export. Expand to advances, transit, imports and additional forms using the same interface. All approved MVP capabilities still need completion before declaring the whole MVP complete. This sequencing tests the product promise sooner without expanding scope.

**Optimization O03 — Use a small posting module with fixed recipes**

Evidence: [logical-model simplicity constraint][s-logical], [conceptual operations][s-modules].

The specification already rejects microservices, an event-store platform and a general workflow builder. Preserve that direction. A small posting interface should accept a reviewed business command, expected revision and idempotency key, resolve policy/authority internally, construct recipe-specific effects, and commit journal/number/audit together. Keep case-balance updates and reuse guards behind that same interface.

Avoid exposing journal-leg construction to every transaction screen, import handler or AI tool. Start with a monolith and ordinary transactional storage; introduce additional seams only where there is actual variation. The main design work is closing the missing contracts above, not adding more architecture.

**Optimization O04 — Turn acceptance prose into a small executable fixture set**

The current PASS sections carefully distinguish document checks from application testing. Preserve that distinction and make verification reproducible.

Reuse the existing worked example as a versioned fixture, then add the cases from F01–F14: close ordering, close scope, shared-Account access, case/evidence concurrent consumption, backdating, refunds, pre-cutover history, policy version changes, durable recovery and consistent export. Add multi-version and multi-Fund report fixtures: the existing main arithmetic example uses one workspace, no opening advances/liabilities and zero F/Taccount/J, so it cannot exercise those branches.

Use the existing RC controls as common assertions rather than building separate competing formulas per report. Table-driven fixtures can verify several reports through the same calculator interface.

**Optimization O05 — Replace vague “policy complete” claims with an actionable readiness register**

Evidence: [policy choices complete][p-remaining], [remaining activation values][s-config-values], [production gates][s-gates].

Distinguish approved product policy, remaining behavioral contract, church configuration, source artifacts and implementation verification. Give each remaining item an owner, a required artifact, a permitted default where approved, and the exact action it blocks. This avoids treating F01–F14 as mere deployment values and keeps optional source/form work from blocking unrelated draft capture.

Keep future-platform clarification in its own backlog. In particular, publication masking modes are not naturally one linear privacy scale (for example Family versus BIPRA+Kolom); define permitted audience/category representations before implementing “stricter preference” precedence. For attendance, define whether totals mean entries, concurrent presence or estimated distinct attendees and how stations combine counts, while preserving the explicit prohibition on personal attendance tracking. Neither is a Treasurer-MVP launch dependency.

**Recommended order of resolution**

1. Resolve F01–F04 before finalizing posting, close, report authorization or recovery implementation.
2. Settle F05–F14 as small command/data-contract decisions and add their acceptance cases.
3. Record R01's operational consequence without changing D07 implicitly.
4. Apply F15/F16 and O01/O05 when publishing the next versioned design edition.
5. Implement the vertical slice in O02, then broaden the transaction/report coverage with O03/O04.

**Review limits:** There is no application implementation in this checkout to test. Counterexamples demonstrate under-specified behaviors, not observed production failures. The source catalogs and arithmetic were checked locally; current provider routes, product pricing, financial-report compliance and the authenticity of external approval conversations were outside this review.


[s-period]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:206
[s-close]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:378
[s-population]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:414
[s-permissions]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:216
[s-completeness]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:418
[s-f10]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:577
[s-f11]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:583
[s-recovery-policy]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:86
[s-recovery]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:749
[s-matrix]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:231
[s-refunds]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:252
[s-measures]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:424
[s-activation]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:138
[s-cutover]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:344
[s-invariants]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:220
[s-advance-limits]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:256
[s-case-states]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:322
[s-matching]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:358
[s-evidence-record]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:198
[s-f14]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:601
[s-transactions]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:193
[s-f12]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:589
[s-export]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:751
[s-offerings]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:254
[s-f02]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:515
[s-policy-config]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:54
[s-approval]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:302
[s-ai-validation]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:737
[p-m277]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:1703
[s-config-values]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:102
[p-adoption]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:172
[p-death]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:940
[s-template]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:708
[s-gates]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:823
[p-template-rules]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:1831
[s-serialization]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:639
[s-evidence]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:316
[p-finalized]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:1228
[p-formula]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:1632
[s-dates]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:262
[p-tensions]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:3151
[p-predecessor]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:2946
[p-hashes]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:2935
[p-storage]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:63
[s-verification]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:855
[s-d07]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:100
[s-adjustments]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:260
[p-build-order]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:2874
[s-logical]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:180
[s-modules]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md:712
[p-remaining]: /Users/edotanod/Projects/palakat/docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md:2848
[checks]: /Users/edotanod/Projects/palakat/docs/reviews/design-analysis-checks-2026-10-19.json

