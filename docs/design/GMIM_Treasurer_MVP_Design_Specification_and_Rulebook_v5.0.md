# GMIM Treasurer MVP — Design Specification and Rulebook

**Handover date:** 8 October 2026  
**Product:** GMIM Bendahara-first financial workspace, with a future church-management platform  
**Source conversation:** Church Management System, conversation ID `6ac4de41-ebec-83ec-a1f2-73f30ae5be05`  
**Document version:** Handover 5.0 — approved rounds 1–6 policy baseline; irreversible D07; preserved source snapshots and reviewed production-master correction
**Versioned artifact:** `GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md`  
**Predecessor:** `GMIM_Treasurer_MVP_Design_Specification_and_Rulebook.md` (Handover 4.0; preserved unchanged)  
**Companion engineering specification:** `GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md`  
**Predecessor SHA-256:** `df7cf8d531db8455ab53e94ea95ec377680c37343d46b35152c1ba9e3319b791`

## 0. Read this before using the document as authority

This is the single-file handover of the current Treasurer-first design, the user-supplied **Design Specification & Rulebook — Current Source of Truth**, the user-supplied **Consolidated Master Rulebook**, and the recovered recent conversation. The supplied documents resolve the previous gaps concerning adoption levels, organizational roles, member lifecycle, Warta/privacy masking, Panitia, notifications and attendance.

**Section 16 retains all 775 rule numbers and source structure; incompatible rules are explicitly amended for approved rounds 1–6.** Appendix A retains the earlier conversation's AI-rule numbering 293–342; Appendix B retains controls C01–C20 with explicit OPEN-period correction limits. The untouched predecessor preserves original wording, while this edition records the changed rules and their authority. Their numbers belong to different source editions and must not be conflated. The prior handover's synthesized H001–H110 list has been replaced by the supplied master.

The two user-supplied classification exports have now been read directly. **All 131 Pendapatan and 158 Belanja codes and labels are embedded once, as machine-readable JSON, in Appendix B of the companion engineering specification (S)**, with exact string formatting, original label text and indentation, source order, source references and file hashes. Each master has six verified top-level families.

The exports show hierarchy through indentation but contain **no explicit `parent_id` or `postable` metadata**. This document preserves the source-derived parent map and source `postable: null` values. Approved production definitions assign leaves postable, parents nonpostable unless enabled, and correct B113 to `2.3.02.02`; the source code/display-parent discrepancy remains preserved as provenance. Exact GMIM report forms are still not supplied.

### 0.1 Authority and terminology

| Label | Meaning | Continuation treatment |
|---|---|---|
| **Confirmed baseline** | Accepted recent conversation or decisions supplied by the user for incorporation | Preserve unless explicitly changed |
| **Implementation clarification** | Interpretation needed for internally consistent behavior | Validate in the next engineering specification; do not mislabel as a historic decision |
| **Proposed continuation detail** | Useful concrete implementation proposal beyond supplied decisions | Remains proposed |
| **Unresolved / source gap** | Exact detail not present in available sources | Resolve rather than guess |

The recovered design/rulebook and approved rounds 1–6 establish the product baseline. Section 19 supplies the approved engineering contract: logical records, posting recipes, guards and report datasets. The approved settings in 0.5 supersede old proposal wording, including modified D07. Fictional financial examples remain illustrative; actual church thresholds/percentages/signatures and original-form bindings remain explicit configuration/source gaps. Pinned OpenRouter IDs are approved; runtime provider availability is checked without changing the policy.

### 0.2 Coverage and remaining gaps

| Area | Status |
|---|---|
| Treasurer-first scope, navigation, workflows and build order | Recovered and consolidated |
| Five progressive adoption levels | Recovered from supplied design |
| Shared finance engine; Account / Fund / Scope / Mata Anggaran | Recovered |
| Lifecycle, approvals, advances, transfers, evidence, migration, reconciliation and closing | Recovered constraints plus explicit engineering algorithms/state guards in section 19 |
| All 775 consolidated master rules | Embedded in full in section 16 |
| Earlier AI rules 293–342 and 20 tightened controls | Preserved in source-specific appendices |
| Pendapatan/Belanja counts and six family names each | Recovered |
| Exact 289 source codes/labels | Embedded as JSON in S Appendix B; counts and exact text verified |
| Explicit hierarchy and posting eligibility | Source flags preserved; reviewed production derivation approved with leaf/parent defaults and B113 correction |
| GMIM Report Pack, Buku Kas fields, drill-down and template architecture | Recovered; all fourteen semantic datasets, formulas and controls formalized in 19.6–19.10 |
| Exact church-specific printable field/cell/signature mapping | Not supplied; still needed |
| Warta, mandatory masking, roles, Operator, delegation, funds, Panitia and member lifecycle | Recovered; accepted future-platform constraints |
| Aggregate-only attendance, permissions/lifecycles/corrections and notifications with no quiet hours | Recovered |
| Recognition/posting matrix, reversals, suspense, numbering, imports and matching | Approved V1 engineering contract in section 19, including final CLOSED state |
| Deployment settings, thresholds, exceptions, recovery targets and live AI route IDs | Managed cloud/recovery/export/AI settings approved in 0.5; actual church thresholds remain configurable |

### 0.3 Source editions, precedence and references

Use **Master rule N** or `M001…M775` when referring to section 16. Use **Legacy AI rule N** or `L293…L342` for Appendix A. Use **Control C01…C20** for Appendix B. These aliases do not alter original source numbers. For example, Master rule 293 concerns Belanja's Marturia family, whereas Legacy AI rule 293 concerns OpenRouter.

The supplied documents are incorporated as the current product baseline under the user's instruction to update this handover. They do not prove that their 1–775 numbering is the original conversation's numbering; it is a consolidated source edition. The old chronological rules 1–292 are no longer a handover blocker because the supplied current master covers the accumulated decisions.

Preserve compatible requirements across all sources. Treasurer-first and explicit deferrals govern V1 scope; future-platform rules remain future constraints rather than launch dependencies. Approved rounds 1–6 explicitly resolve prior engineering/policy ambiguities. Any remaining source gap stays visible. The amendment register identifies changed source rules; a mere handover interpretation cannot override an approved policy.

### 0.4 Revision record

**Cleanup edit (7 November 2026, no policy change):** removed duplicated material, with git commit `1962b27` holding the full prior text. Section 19 (a near-verbatim copy of S sections 1–15, differing only in heading level and a few introductory words) is replaced by a section map to S. The readable catalog tables (Appendix C.1–C.2) and the duplicate JSON snapshots (Appendix D) are removed; the JSON in S Appendix B is the single copy and was byte-identical. Appendix C.3–C.4 and section 18.5, which only restated status or described a chat storage location, are removed. Three overview blocks that said they were superseded by S are removed: the 4.2 domain-record table, the 12.2 report-mapping table and the five 13.5 AI paragraphs that were word-for-word copies of S section 12 (13.5 now points to 0.5 and S section 12). Revision history above is condensed. M-rules, Appendix A (L293–L342), Appendix B (C01–C20) and Appendix C.5 are unchanged.

**Version 5.0 (8 October 2026):** Incorporated approved rounds 1–6; corrected the reviewed production B113 code while preserving both source catalogs/snapshots exactly; adopted D01–D12 with irreversible D07 and permanent retention of used master versions; settled approval/evidence/transit/backup/export/AI settings; rewrote all post-close correction assumptions in workflows, engineering rules, examples, report fields and acceptance requirements. Original Handover 4.0 and Standalone 1.0 files remain unchanged.

**Versions 2.0–4.0 (summary):** 2.0 added the complete 775-rule master and recovered adoption, approval, offering, reporting, permission and lifecycle decisions. 3.0 read both classification exports and embedded all 289 source rows with exact codes, source-derived parent maps, provenance and machine-readable catalogs, flagging the Belanja `2.3.08.02` display-parent discrepancy. 4.0 added the formal engineering contract (now S): glossary and logical schema, posting recipes, state machines, cutover/close algorithms, integer cash/advance/transit bridges, the fourteen report datasets, layout binding, worked arithmetic and E001–E046 (5.0 adds E047–E051).

### 0.5 Approved rounds 1–6 baseline

**Authority:** User decisions in **Next Steps After Docs**, conversation `6ac62014-70cc-83ec-acb6-4134bf1b9bc1`, consolidated in the final approved-decision summary and incorporated at the user's request on 8 October 2026. These are approved product policies; they are not claims that the original GMIM forms or source exports contained them. This register supersedes conflicting earlier proposal/status wording. The source snapshots remain evidence, separate from the approved production definitions.

| Round / area | Approved policy |
|---|---|
| 1 — Production master | Retain all 289 rows (131 Pendapatan, 158 Belanja). Preserve source code `2.3.08.02`; production Belanja B113 uses `2.3.02.02`, name `Kemitraan / Jemaat Mitra`, parent B110 / `2.3.02.00`. Record old/new values, source row/cells, reason and approving decision. |
| 1 — Postability | Detail leaves are postable by default; group/family parents are nonpostable by default. A parent requires explicit authorized enablement. Derive concrete booleans from the explicit hierarchy, never from `.00` or numeric prefixes. No parent enablement has been specified for this baseline. |
| 1 — Activation | First production master becomes effective on the first day of the first production accounting month. The actual month is a workspace deployment value, not the source filename date. Later versions activate at a period boundary; no retroactive reinterpretation. |
| 2 — D01–D12 | Approved as defined in the decision table, with D07 replaced by irreversible close and D11 retaining every used master version permanently. |
| 3A — Approval modes | MVP supports `NOT_REQUIRED` and `EXTERNAL`; `IN_APP` is a future collaboration mode, not an MVP dependency. |
| 3B — Thresholds | Amount thresholds are configurable per church/Fund policy; no universal rupiah approval threshold is invented. |
| 3C — Maker/checker | Configurable and off by default for solo use. When enabled, maker and checker must be distinct humans; multiple roles/logins belonging to one person do not satisfy the rule. |
| 3D — External declaration | Structured declared approver identity/role, approval date, method, notes and supporting reference/evidence where required; recorded actor remains distinct. Bind the declaration to the transaction's material revision/digest; material edits invalidate it. |
| 3E — Evidence timing | Required evidence may remain missing/uploaded/pending verification during the OPEN month, including after finalization. Resolve to `VERIFIED` or explicitly authorized `EXCEPTION_ACCEPTED` before close. A church may strengthen posting-time requirements. |
| 3F — Evidence defaults | Evidence is required by default for core spending and settlement cases: direct expenses, reimbursements, accepted advance spending and transit/centralization remittances. Evidence requirements for other transaction types are configured by church policy; required cash/bank reconciliation observations remain mandatory. |
| 3G — Solo verification | Solo Treasurer may verify evidence where church policy permits; a universal second reviewer is not imposed. |
| 3H — Evidence exceptions | Only an authorized human may explicitly accept an exception, with reason, authority, actor/time and the affected evidence/transaction link. AI, upload success and technical administration grant no exception authority. |
| 3I — Open advances | Valid, explained outstanding advances may carry forward across month-end. They are disclosed and do not automatically block close; missing required proof, unexplained/negative balances or a configured overdue restriction do. |
| 3J — Advance due dates | Configurable per church/case policy; no universal settlement deadline is imposed. |
| 4A — Ownership | Every relevant collection/allocation uses explicit `OWNED`, `CUSTODY` or `SPLIT`. A code or recipient does not establish ownership. Split components sum to the one physical collection. |
| 4B — Allocation | Centralization percentages, fixed amounts, manual allocations, retained shares and rounding are versioned authorized church configuration; never hard-coded. |
| 4C — Beneficiary | A custody/transit allocation cannot finalize without an identified beneficiary/destination obligation. |
| 4D — Presentation | MVP main reports use `ECONOMIC_WITH_TRANSIT_SCHEDULE`: economic Pendapatan/Belanja totals plus a separate Dana Transit schedule. Gross bridge measures remain available as labeled controls. A gross main-form adapter requires a future explicit policy amendment after form review. |
| 4E — Transit carry-forward | Valid, explained positive transit liabilities may carry forward. Negative cases, over-remittance, unknown beneficiaries, unexplained differences, missing required proof and unresolved policy-required overdue remittances block close. |
| 4F–4G — Owned contributions / no duplication | Contributions from church-owned money are economic Belanja. Custody collection/remittance are liability movements, excluded from economic income/expense. Each rupiah receives one ownership treatment; never count the same component twice. |
| 5A — Deployment | Managed cloud, server-authoritative finalization, numbering, reconciliation and close; no church self-hosting or offline financial finalization in MVP. |
| 5B — Security | Encrypted transport and database/storage at rest; evidence private by default; credentials/API keys server-side; tenant + role + Scope checks on reads, writes, downloads, exports and AI queries; high-privilege session revocation. Technical administration does not confer financial authority. |
| 5C — Backup set | Database, actual evidence objects, report snapshot datasets, rendered official reports, master/template/policy versions and required encryption/key-recovery material. |
| 5D — Recovery defaults | RPO **1 hour**, RTO **8 hours**, **7-day point-in-time recovery**, **35 daily backups**, **12 monthly recovery snapshots**. These are product/operational defaults, not GMIM legal-record-retention rules. |
| 5E — Restore verification | Full restore test at least quarterly and before/after major infrastructure or database migrations; verify financial integrity and evidence/report accessibility. |
| 5F — Export | Full portable church export, including actual church-owned evidence files, structured ledger/allocations, reports/snapshots, exact masters, Account/Fund/case data, approval/evidence metadata and a relationship/checksum manifest. |
| 5G — Backup / export | Infrastructure backups are restricted disaster-recovery material. Authorized church export is a separate application workflow; it requires no raw backup credentials. |
| 6A — Models | Pin `openai/gpt-6-luna` for routine assistance and `openai/gpt-6.1-sol` for escalation. No moving `latest` aliases, Astra or unapproved model fallback. Intentional upgrades require a reviewed AI policy version. |
| 6B — Privacy | Every AI request containing church data requires OpenRouter `provider.zdr = true` and an eligible endpoint with no provider training or intentional inference prompt retention. If unavailable, fail gracefully without weakening privacy. ZDR still involves transmission/processing by the provider. |
| 6C — Context | Minimum task-specific authorized context only; narrow candidate classifications and mask/remove unnecessary personal identifiers. |
| 6D — Routing | Deterministic rules → Luna → Sol where appropriate → human review. Sol escalation: insufficient confidence, ambiguous candidates, multi-document reasoning, difficult matching/reconciliation explanation, explicit deeper-analysis request or a suitable retry after deterministic rejection. |
| 6E — Output | Structured proposals; server validates schema, row/version existence, active/postable status, master kind, Fund/Scope authority and current revision before human acceptance. Invalid output is rejected. |
| 6F — Cost | **Rp150,000 per church/workspace per month**. Below 70% normal use; at 70% (Rp105,000) warn; at 90% (Rp135,000) conserve, prefer Luna/cheaper permitted processing and avoid unnecessary Sol calls; at 100% (Rp150,000) stop optional AI for the remainder of the monthly budget period. Accounting continues fully. No unlimited default. |
| 6G — Failure | OpenRouter/ZDR/model failure, exhausted budget or malformed output leaves manual capture/classification, reconciliation, close, reports and exports operational. |
| 6H — Audit | Feature, input digest, model ID, provider/route metadata, candidate/master versions, timestamp, structured proposal, confidence if supplied, human accepted/edited/rejected disposition, final value and token/cost usage. Do not duplicate unrestricted receipt/statement content in AI logs or treat proposals as financial evidence. |
| 6I — Untrusted documents | Receipts, PDFs, bank descriptions and imported text are data, never instructions or authority. All proposed actions remain subject to deterministic guards and permissions. |

**D07 control boundary:** `OPEN → CLOSED` is irreversible in MVP. Complete all financial corrections before the affected period closes. CLOSED accepts the transaction population and official snapshot as final. V1 has no reopen, unlock, closed-transaction reversal/replacement/adjustment, or later-period accounting correction against a CLOSED transaction. Required future support is outside MVP and needs an explicitly governed design extension. Valid later advance settlements/returns and transit remittances remain new events against carried-forward positions; they do not revise earlier postings or snapshots. Later supplementary evidence is append-only accountability information and cannot cure or rewrite the frozen close decision.

**Activation versus approval:** Policies above are approved, but workspace timezone/fiscal settings, first production month, actual church approvers/thresholds, beneficiary identities, allocation formulas, optional parent enablement, due dates and original report-form bindings must still be recorded where needed. Their values cannot be chosen by AI. Publication/activation records actual authorized human actor, timestamp and policy/source references; this document is not a deployed database publication.

### Approved production-master derivation

The fenced JSON source snapshots in S Appendix B are preserved byte-for-byte, including B113 `2.3.08.02`, `postable: null`, original spelling, indentation, source hashes and draft source-mapping flags. They are not mutated or published as the production master. Create a separate version-qualified reviewed master using the following approved definition:

```json
{
  "definition_version": "GMIM_TREASURER_PRODUCTION_MASTER_R1_2026-10-08",
  "decision_source": "6ac62014-70cc-83ec-acb6-4134bf1b9bc1",
  "status": "APPROVED_FOR_PUBLICATION",
  "source_catalog_row_counts": {"PENDAPATAN": 131, "BELANJA": 158},
  "retain_all_source_rows": true,
  "preserve_source_snapshots": true,
  "hierarchy": "explicit source-indentation parent map retained",
  "postability": {"leaf_default": true, "parent_default": false, "parent_overrides": []},
  "effective_from_rule": "FIRST_DAY_OF_FIRST_PRODUCTION_ACCOUNTING_MONTH",
  "later_activation_rule": "PERIOD_BOUNDARY",
  "used_version_deletion": "PROHIBITED_PERMANENTLY",
  "corrections": [{
    "kind": "BELANJA",
    "source_row_id": "B113",
    "source_row": "113",
    "source_cells": "Sheet0!B114:C114",
    "source_code": "2.3.08.02",
    "production_code": "2.3.02.02",
    "name": "Kemitraan / Jemaat Mitra",
    "parent_id": "B110",
    "parent_code": "2.3.02.00",
    "reason": "Authorized correction of anomalous source code to match reviewed hierarchy"
  }]
}
```

Derivation is deterministic: copy every source row with its source provenance; preserve the explicit parent/family/order/label mapping; apply only the B113 production-code override; assign explicit postability from actual child relationships (237 leaves true, 52 branch/root rows false, unless a later authorized parent override is recorded). Preserve `source_code`, raw label and source flags separately from the reviewed production `code` and resolved validation status. Validate uniqueness, all parent references, absence of cycles, six roots per kind and unchanged 131/158 counts. Record the correction decision and old/new values; do not propagate the unresolved source anomaly flag as an unresolved production blocker after its authorized resolution. Do not normalize other codes or labels. The production report F06/export uses `2.3.02.02`; source appendices continue to display `2.3.08.02`.

Assign actual immutable publication-version IDs by kind and deployment dates/actor metadata at activation. The first effective date is the first day of the chosen production accounting month, including when a later-in-month cutover is explicitly used. Retain every used version forever: a version referenced by any finalized transaction, report snapshot or historical dependency can never be deleted. Archival/deactivation only removes availability for new work; it preserves version-qualified rows, provenance and historical reproduction. Operational backup expiry is not authority to delete financial/master history.

## 1. Product vision and adoption strategy

**Confirmed baseline:** First make one Bendahara dramatically more productive, while preserving the architecture needed to grow into a full GMIM church platform later.

The initial product is a financial workspace that helps a Treasurer capture money movement, maintain trustworthy records, reconcile cash/bank positions, resolve evidence and classification issues, close a month, and produce the GMIM Report Pack. AI reduces preparation effort; the ledger and human-authorized workflows retain authority.

The primary market is local GMIM Jemaat in Minahasa / North Sulawesi. The product should replace scattered Excel bookkeeping, notebooks, WhatsApp transaction records, bank screenshots, receipt folders, manual classification, reconciliation work and monthly report reconstruction. The success criterion is a reliable GMIM-compatible month-end report produced from daily records without reconstructing those sources. The UI must be mobile-friendly and usable by non-technical church officers.

Value must not depend on BPMJ, Penatua, Syamas, BIPRA leaders, members or Panitia first adopting the application. A Treasurer can record information received through paper, bank proofs, messages, meetings or existing church processes. An absent in-app approver must not force a fictitious approval account or an inaccurate approval claim.

### 1.1 Priorities, in the accepted order

1. Treasurer core ledger.
2. Mata Anggaran Pendapatan and Belanja.
3. Evidence and cash/bank reconciliation.
4. GMIM Report Pack.
5. AI-assisted Treasurer workflows.
6. Progressive collaboration: **Church Operator → unit treasurers → approvals**.
7. The broader church-management platform later.

### 1.2 Confirmed five progressive adoption levels

| Level | Adoption | Work supported | Authority boundary |
|---|---|---|---|
| **Level 1 — Solo Bendahara** | Only church Treasurer uses the application | Complete capture/reconcile/close/report workflow; record approvals occurring outside the app | No other officer needs an account |
| **Level 2 — Bendahara + Assistant / Operator** | Finance assistant or Church Operator helps | Prepare drafts, upload receipts, enter references, digitize records, prepare supporting documents | Treasurer remains responsible for financial finalization |
| **Level 3 — Unit Treasurers** | Bendahara Kolom, BIPRA or Panitia participates | Submit transactions, evidence, settlement information and financial reports in scoped workspaces | Fund ownership and scoped governance remain explicit |
| **Level 4 — Digital Approval Workflow** | Authorized Penatua, Syamas, BPMJ, BIPRA/Panitia leaders and other approvers join | Approve financial requests in-app | Enforce permissions and applicable maker/checker/self-approval restrictions |
| **Level 5 — Full Church Platform** | Broader modules progressively activate | Member self-service, Warta, services, lifecycle, inventory, attendance and announcements | Publication/privacy and organizational authority rules remain effective |

The backend must support this growth while the first UI remains Treasurer-focused. Collaboration must never make solo use impossible. Scopes can exist without unit user accounts. Data is entered once and reused wherever authorized.

## 2. Treasurer-first MVP scope and explicit deferrals

### 2.1 Included financial capabilities

- Income and receipts, including offerings and donations.
- Expenses and reimbursements.
- Cash advances, settlement and unused-money returns.
- Cash and bank accounts, and transfers.
- Line-level classification into versioned Pendapatan and Belanja masters.
- External approval recording, with a compatible path to in-app approvals.
- Evidence/documents and structured evidence status.
- Cash and bank reconciliation.
- Controlled opening balances and staged legacy/bank imports.
- Monthly closing and period locks.
- Audit trail, security, backups and export.
- Deterministic reports, including PDF/Excel GMIM Report Pack outputs.
- Optional AI preparation, suggestions, search, explanations and issue summaries.

### 2.2 Explicitly deferred

**Budgeting, procurement and service roster are not in the current MVP.** Any future detailed workflows must preserve these deferrals and must not become dependencies of transaction recording or closing.

Mata Anggaran is a classification/reporting master. Using the word “Anggaran” does not imply that budget planning, budget approval, budget limits, purchase requests, purchase orders, supplier procurement or service scheduling have been included in V1.

**Implementation clarification:** If a supplied report contains budget columns, their V1 behavior must be specified explicitly. Do not invent budget values or implement a hidden budgeting module merely to fill a template. Mark unavailable budget fields appropriately until an approved source/input policy exists.

### 2.3 Deliberate V1 limitations

1. IDR only.
2. One church workspace per tenant.
3. One fiscal/calendar configuration per workspace.
4. No foreign-currency accounting or FX handling.

Multiple accounts, funds and organizational scopes can exist inside the one church workspace. Tenant isolation can support many churches on the platform without turning V1 into a multi-church consolidation product.

No detailed calendar, timezone, fiscal-year start or currency-input precision was recovered. Confirm those implementation settings instead of inferring them from this document's creation environment.

## 3. Primary workflow and product surfaces

### 3.1 Accepted Treasurer workflow

```text
Record / capture money movement
    ↓
Attach evidence
    ↓
Classify to Mata Anggaran
    ↓
Record external / in-app approval, if applicable
    ↓
Finalize ledger transaction
    ↓
Reconcile cash / bank
    ↓
Resolve missing items
    ↓
Close month
    ↓
Generate GMIM Report Pack
```

AI may assist at individual steps. It does not become an alternate route around the controls.

### 3.2 Treasurer navigation and attention-first dashboard

The supplied design proposes this minimal navigation; screen details remain design choices:

```text
Dashboard
Money → Income / Offerings / Donations / Expenses / Reimbursements / Cash Advances / Transfers
Cash & Bank → Cash / Bank Accounts / Reconciliation
Documents / Evidence
Reports → Monthly Financial Report / Buku Kas / Pendapatan / Belanja / GMIM Report Pack
Settings → Church / Accounts / Funds / Financial Scopes / Mata Anggaran
```

The confirmed dashboard emphasis is **Needs Attention**, rather than large CRUD menus. Show authoritative Cash/Bank positions, this-month income/expenses/net and operational items such as awaiting payment, open advances, missing receipts, unmatched bank lines and unresolved classifications. Offer quick Income, Expense, Offering, Reconcile and Generate Report actions. Numbers shown in source dashboard examples are illustrative.

The following workspaces refine those groupings for implementation planning:

| Workspace | Purpose |
|---|---|
| Overview / attention list | Balances from authoritative records, drafts, missing proof, unresolved reconciliation and close blockers |
| Transactions | Capture, edit drafts, inspect finalized entries, reverse and correct |
| Offerings / receipts | Capture collections and donations with appropriate context |
| Advances | See recipients, disbursements, settlements, returned money and outstanding amounts |
| Evidence | Upload, link, inspect, verify and search supporting documents |
| Cash / bank | Account position, statement staging, matches and reconciliation differences |
| Imports | Preview, map, validate, deduplicate, classify and commit |
| Month close | Deterministic checklist and period lock |
| GMIM Report Pack | Preview/export reports and inspect historical snapshots |
| Masters / settings | Controlled classifications, accounts, funds, scopes and template versions |
| Audit / export | Authorized traceability and church-owned data extraction |

A generic chatbot is not the primary financial interface. AI belongs in the relevant workflow, beside the draft or issue it is helping resolve.

## 4. Finance concepts and domain boundaries

### 4.1 Four independent dimensions

| Concept | Meaning | Illustrative values | Must not be confused with |
|---|---|---|---|
| **Account** | Where money physically is | Cash, BNI, BRI | Its owner, organizational unit or income/expense purpose |
| **Fund** | Which pool of money owns it | General, Diakonia, Panitia | A physical bank account |
| **Scope** | Which organizational unit the record concerns | Jemaat, Kolom, BIPRA, Panitia | A fund or classification code |
| **Mata Anggaran** | What the income/expense is for | An exact approved Pendapatan/Belanja row | An account or organizational permission |

Examples above were used in the recovered conversation; they are not a mandatory seed catalog. “Panitia” may identify an organizational scope and an associated fund, but these remain separate records with separate meaning.

One shared finance engine serves Jemaat, Kolom, BIPRA, Panitia and future units; separate accounting implementations for each unit are prohibited. Fund ownership determines the applicable governance workflow.

One BNI account can hold money attributed to several funds. One fund can have money in more than one physical account. A unit can use many Mata Anggaran rows. None of these relationships permits automatic conflation of the dimensions.

### 4.2 Domain record overview

Section 19.1–19.3 is the formal logical domain model and posting contract. It remains an engineering specification rather than a deployed database or historical church approval.

### 4.3 Amounts and date semantics

**Approved D02:** Store money as integer IDR with checked exact arithmetic and explicit allocation rounding; do not use binary floating-point ledger calculations. Validate totals server-side. Date parsing must not silently convert ambiguous Indonesian date/number formats.

Separate business-effective date, creation timestamp, posting/finalization timestamp and document date where they differ. Section 19 specifies the approved date/cutoff and irreversible-close contract; financial corrections are limited to affected OPEN periods. Preserve original imported strings and the interpreted result for review.

## 5. Transaction types and lifecycle

### 5.1 Accepted transaction families

| Type | Purpose | Accounting/report constraint |
|---|---|---|
| Income / receipt | Record money received | Classify relevant income lines to Pendapatan |
| Offering | Record church/service/unit collections | Preserve collection context; avoid recounting a deposit as new income |
| Donation | Record a gift | Preserve relevant donor/fund context without requiring full member-platform adoption |
| Expense | Record spending | Classify relevant lines to Belanja |
| Reimbursement | Repay a person for a documented church expense | Record the underlying expense once; distinguish reimbursement from an advance |
| Cash advance | Money entrusted before final accountability | Advance issue is not automatically final Belanja |
| Advance settlement | Recognize supported spending from an advance | Classify settled spending and retain the outstanding balance |
| Advance return | Record unused money returned | Separate from settlement expense; not fresh donation income |
| Account transfer | Move money between physical accounts | No artificial Pendapatan/Belanja inflation |
| Fund transfer | Reattribute money between funds under an explicit rule | Preserve overall money total and ownership trace |
| Centralization / settlement | Track GMIM collected/payable/remitted/received amounts | Precisely define each amount and avoid double counting |
| Opening entry | Establish controlled adoption-date positions | Not fabricated income |
| Reversal / correction / adjustment | Correct records while affected periods remain OPEN | Preserve history; CLOSED transactions have no correction path in MVP |

Section 19.3 specifies precise posting effects and permitted combinations as an explicit V1 engineering contract. Do not use a single generic “expense” flag to conceal an advance, transfer or opening entry.

### 5.2 Authoritative state machine

**Confirmed control:** Use explicit states such as:

```text
DRAFT → REVIEWED → FINALIZED
FINALIZED → REVERSED only while all affected periods remain OPEN
```

The supplied current design confirms these state names, and Master rule 72 requires an equivalent lifecycle. Detailed transition preconditions and review invalidation are formalized in section 19.4.

| State | Meaning | Official financial effect |
|---|---|---|
| DRAFT | Captured/prepared, including AI or import proposals | None |
| REVIEWED | Reviewed according to configured workflow | None until finalization |
| FINALIZED | Validated, human-authorized transaction committed to the ledger | Included in authoritative reporting/postings |
| REVERSED | Original finalized record has a linked compensating correction | Preserve original and reversing posting history |

Empty drafts may be deletable. Records that have participated in official workflows generally use reversal, cancellation or archival instead of physical deletion; finalized financial records are not physically deleted through ordinary administration. Cancellation/reversal remains auditable. Section 19.4 defines pre-post cancellation and review invalidation; D07 permits corrections only while affected periods remain OPEN; CLOSED has neither reopening nor a later-period correction path. Do not reuse issued voucher numbers or erase audit events.

### 5.3 Immutability and corrections

After finalization, amount, classification, date and other financially material fields must not be silently edited. While all affected periods remain OPEN, use:

```text
Reverse original → create corrected transaction
```

This applies while all affected periods remain OPEN, for solo and collaborative churches alike. Reversals require original linkage, reason, actor/time and configured authority. Once the affected period is CLOSED, this workflow is unavailable, including from a later OPEN period. AI may suggest fixes for eligible OPEN data; it cannot authorize or perform a correction.

**Implementation clarification — historical inclusion:** “Finalized only” means authoritative committed financial effects. If an original becomes `REVERSED`, do not simply remove it from every historical query while retaining its reversal, or remove both from an earlier report. Retain original posted effects and linked compensating effects with their effective periods. Report snapshots remain fixed. Approved D07 date/guard rules in 19.3.3 apply; no correction against a CLOSED transaction is available.

### 5.4 Finalization controls

Approved validation contract:

1. Confirm tenant, permission and accounting period are valid.
2. Validate the transaction type and its posting recipe.
3. Validate exact amount arithmetic and line/header equality.
4. Resolve required classification to a valid postable row/version.
5. Validate accounts, funds and scopes independently.
6. Record applicable approval provenance accurately.
7. Evaluate evidence requirements and allowed exception policy: default required evidence may remain pending during OPEN month, but close requires VERIFIED or human EXCEPTION_ACCEPTED; stronger church posting-time policy still applies.
8. Enforce duplicate/idempotency controls.
9. Commit postings, voucher allocation and audit record consistently.

No user-facing success should imply a posted transaction if only the AI draft or file upload succeeded. Partial failure must not leave duplicated or half-posted financial effects.

## 6. External approvals and in-app governance

### 6.1 External approval

The MVP may operate without BPMJ adopting the app. An external approval means:

> The Treasurer recorded that approval occurred outside the system.

It must not appear as “Approved by BPMJ in the app.” Store:

- Declared approver.
- Approval date.
- Method/channel.
- Notes.
- Evidence, when available.
- Recorder identity and record time.

The supplied baseline also requires the approver’s role/authority where known. Recorder/time make provenance traceable. The external record is a declaration, not proof of authenticated approval by the named person.

### 6.2 Approval modes and in-app authority

Support **EXTERNAL** and **NOT_REQUIRED** where applicable in MVP, with an architecture for future **IN_APP** approval. The original design names all three modes; approved Round 3 limits MVP to NOT_REQUIRED/EXTERNAL and reserves IN_APP for future collaboration.

True in-app approval can coexist later with external declarations. It requires an authenticated actor and an authorized workflow. Do not retroactively transform old external declarations into app approvals when an approver later joins.

**Confirmed AI boundary:** AI cannot approve expenditure, approve its own suggestions, bypass maker/checker or self-approval restrictions, or bypass governance permissions.

**Engineering status:** Scoped-role/delegation and separation-of-duties constraints are recovered in section 14. Section 19.4 separates approval mode from review and binds them to revision/authority. Exact expense thresholds, required approvers/quorum and exception capabilities remain church policy values; they are not invented. Maker/checker is off by default for solo use; when enabled it requires distinct humans under church policy. Where a maker/checker restriction applies, solo mode does not authorize bypassing it.

Request, Approve, Pay and Verify remain distinguishable actions. Treasurer authority is not technical super-administration; system administrator and Church Operator are not automatically financial authorities. Multiple roles must not bypass self-approval: a person submitting as Ketua Pemuda cannot switch to their BPMJ role to approve the same request where independent approval is required. Maker/checker is configurable but structurally supported.

Approval state, payment state, transaction lifecycle and reconciliation state are different concepts. An approved proposal is not evidence that money moved; a payment is not automatically approval.

## 7. Operational finance workflows

### 7.1 Offerings

**Confirmed:** Offerings are included; users should be able to query examples such as “persembahan Minggu pagi bulan Oktober.” Full service roster and individual attendance are not required for capture.

**Confirmed capture requirements:** Offering management is first-class. Support cash and transfer/QR components, their calculated total, service/source context without individual-attendee tracking, counting-sheet evidence, relevant Pendapatan classification, account/fund allocation, auditable verification and eventual deposit/reconciliation. More than one authorized person may count cash where church practice requires; this is not a universal two-counter prerequisite. Detailed denomination breakdown and counting policy remain to specify.

A collection received into Cash and later deposited into BNI is one receipt plus one account transfer. Recording another income for the deposit would inflate the reports. If collection is payable to another unit, follow the explicit centralization policy rather than automatically treating every collected rupiah as unrestricted church revenue.

### 7.2 Donations

**Confirmed:** Donations are in scope. The Treasurer must get value without member-platform rollout.

**Confirmed:** Donations may be general or designated to a Fund. Internal donor identity and published identity remain separate; mandatory eligible masking and audited exceptions follow section 14. Do not expose private donations through an automatic member transfer.

**Proposed capture detail:** Record donor information or an appropriate anonymous/unknown designation, date, amount, account, fund, scope, classification and proof. Full member-platform rollout is not required for legitimate receipts. Detailed restricted-gift conditions and receipt formats remain to specify.

### 7.3 Expenses and reimbursements

Capture actual payment details, payee/recipient, purpose, account, relevant fund/scope, Belanja lines, evidence and applicable approval. One actual payment may have several classification lines; the split sum must equal the payment amount.

For example, a Rp5,000,000 payment can contain Rp2,000,000 for one purpose and Rp3,000,000 for another. These illustrative purposes are not exact Mata Anggaran rows from the source master.

**Implementation clarification:** A reimbursement repays supported church spending already paid personally. Ensure the expense is recognized once, and do not recognize it again when proof is attached or reimbursement is paid if it was already posted under another approved recognition method. Approved D04 recognizes the reimbursement at repayment, once; claim review alone is not accrued expense.

### 7.4 Cash advances

Cash advances have their own state:

```text
OPEN → PARTIALLY SETTLED → SETTLED
```

An advance issue is not final expense. Settled spending maps into Belanja when appropriately accounted for. Unused money returned is recorded separately.

**Approved advance balance contract:**

```text
Outstanding advance
    = issued amount
    − accepted settlement expense
    − unused amount returned
    ± eligible OPEN-period authorized corrections
```

Issue, settlement and return must remain linked. A Rp1,000,000 advance with Rp750,000 supported settlement and Rp250,000 returned is fully settled; it produces Rp750,000 Belanja, not Rp1,000,000 plus another Rp750,000.

Settlement spending should have supporting evidence; partially settled advances show outstanding amounts. Open advances appear in Needs Attention and unresolved advances are disclosed appropriately in month-end reporting. AI can remind but cannot settle them automatically.

**Engineering status:** Sections 19.3–19.7 define advance posting, settlement/return state, excess-spending/top-up handling and noncash cash-book treatment. Recipient eligibility, due-date/overdue close restrictions and approval/exception authority remain configured policy values. An outstanding advance is an attention item; the recovered text does not say every open advance automatically blocks every month close.

### 7.5 Transfers

Moving Rp10,000,000 from Cash to BNI must not create Rp10,000,000 Pendapatan and Rp10,000,000 Belanja. Explicitly model both sides of a physical account transfer. Internal fund transfers also need explicit treatment to avoid inflated reporting.

Transfer fees, if any, are distinct actual expenses rather than a reason to disguise the whole transfer as Belanja. This is an implementation clarification; the exact fee classification requires the real master.

### 7.6 Centralization / settlement

Every related record must distinguish:

1. Amount collected.
2. Amount payable.
3. Amount remitted.
4. Amount received.

Solo MVP can record unit settlements manually; unit treasurers may later submit them directly. A single money movement can be observed at two organizational scopes without becoming two unrelated receipts. Link collections, obligations and remittances explicitly.

**Approved:** Ownership is explicit OWNED/CUSTODY/SPLIT, custody beneficiaries are mandatory, and main reports use ECONOMIC_WITH_TRANSIT_SCHEDULE. Actual allocation formulas/percentages, beneficiary identities, retained shares, due dates and settlement Accounts remain versioned church configuration. The supplied Belanja source now includes `1.1.00.00` “SENTRALISASI KE SINODE” and `1.2.00.00` “SENTRALISASI KE WILAYAH”; Dana Transit source categories are also embedded. Their presence does not determine whether every remittance is expense versus liability settlement, or authorize recognition of the same movement twice. Do not invent them. Sections 19.3, 19.6, F13 and 19.9 implement the approved ownership-based recipes and transit presentation; actual church percentages/allocations require authorized configuration.

## 8. Evidence and document numbering

### 8.1 Evidence status

Use structured states equivalent to:

1. Not required.
2. Required — missing.
3. Uploaded.
4. Verified.
5. Exception accepted.

The supplied baseline uses enum-style names `NOT_REQUIRED`, `REQUIRED_MISSING`, `UPLOADED`, `VERIFIED`, `EXCEPTION_ACCEPTED`. Evidence can include receipts, invoices, transfer proofs, bank statements, count sheets, reimbursement/advance-settlement documents, approval screenshots and meeting decisions. MVP documents may attach directly to related financial records; a sophisticated standalone document-management platform is not required.

Do not reduce this to `has_attachment=true`. An upload is not verification. An AI extraction confidence is not documentary evidence. Missing required proof and accepted exceptions must remain visible to close checks and Daftar Bukti Kas.

**Evidence contract:** Artifact ID, original filename, checksum, upload actor/time, private storage reference, evidence type, linked transaction(s), human verification actor/time and explicit exception reason/authority. Required evidence may remain pending during the OPEN month but must be VERIFIED or EXCEPTION_ACCEPTED before close. Core spending/settlement cases require evidence by default; solo verification is permitted by church policy. Actual exception authorities remain church configuration; backup retention is separately approved in 0.5.

Receipt images, invoice PDFs and bank-proof images are permitted AI-extraction examples. Files are untrusted inputs. AI cannot invent receipts, approval records or missing documentation.

### 8.2 Voucher/document numbering

Recovered examples:

```text
BKM-2026-000123   Bukti Kas Masuk
BKK-2026-000087   Bukti Kas Keluar
TRF-2026-000014   Transfer
UM-2026-000011    Uang Muka
```

Numbers are system-generated, unique within the church, and never silently reused after cancellation. The examples are not proof that the exact prefixes, counter resets or padding were finally selected.

**Engineering decision D08:** Allocate on successful finalization, use calendar year of effective date, and retain unique workspace/series/year counters with idempotent retries and traceable gaps. Series prefixes/padding are established church configuration; internal vouchers remain separate from original imported numbers. See 19.0, 19.4 and F12.

## 9. Imports and controlled opening balances

### 9.1 Staging-first import

```text
Import into workspace
    ↓
Validate
    ↓
Duplicate check
    ↓
Classification review
    ↓
Human confirmation / authorized commit to ledger
```

Uploaded spreadsheets must not immediately become authoritative ledger data. AI may infer columns, suggest field mappings and classifications, and identify suspicious rows. Validation and human confirmation remain required.

**Proposed staging metadata:** Import batch/source hash, original workbook/sheet/row, raw value, interpreted value, selected master version, duplicate candidates, validation errors, review actor/time and committed record ID.

Reject or flag malformed dates, ambiguous amounts, mismatched line totals, invalid/nonpostable categories, tenant/scope errors and known duplicate references. Do not silently normalize codes, overwrite records or turn unresolved source ambiguity into a guessed authoritative value.

### 9.2 Idempotency and duplicate handling

Re-importing the same bank statement must not duplicate its lines. Use fingerprints/reference IDs and explicit matching rules. Similar amount/vendor/date is a potential duplicate signal, not sufficient authority for automatic deletion.

**Implementation clarification:** Preserve provenance and explicit decisions for legitimate repeated transactions. Strong identity controls should prevent duplicate commit on retries; uncertain similarity should enter review. The same bank line cannot be consumed twice beyond an approved allocation/matching model.

### 9.3 Opening balances

Capture at adoption:

- Effective date.
- Cash balance.
- Bank balances.
- Fund balances.
- Outstanding cash advances.

These become controlled opening entries, not fake income transactions. Account and fund views must reconcile under the approved balance model. Evidence/support and actor/time should be retained.

**Engineering decision D09:** Section 19.5 defines one reviewed cutover population, balance-only versus history-derived migration, supported opening advances/transit liabilities and overlap prevention. Opening approval authority is configured policy; other receivables/liabilities are outside the approved V1 contract unless explicitly extended.

## 10. Reconciliation and monthly close

### 10.1 Reconciliation

Reconciliation is line-based and idempotent. Deterministic matching uses straightforward signals first: exact amount, nearby date, reference number and description similarity. AI can suggest uncertain matches; the Treasurer reviews them.

Keep book balance, physical cash count and bank statement position conceptually separate. Store explicit differences and explanations rather than manufacturing an adjustment to make the display balance.

**Approved matching contract:** Represent bounded human-confirmed match groups with allocated amounts, status and actor/time; one-to-one, one-to-many and many-to-one matching follows 19.5.3. A statement line's allocated total cannot exceed its available amount. Unmatching must not delete the source line or create another payment.

Source-specific statement formats, date tolerance, bank fees, deposits in transit and outstanding-payment handling remain implementation decisions.

### 10.2 Monthly closing as a control point

Close requires deterministic checks including:

- Cash/bank reconciliation.
- No unresolved required Mata Anggaran classifications.
- No invalid transaction totals.
- Required evidence status satisfied under the approved policy.
- Any other applicable governed blockers resolved.

AI can list and explain problems but cannot close a period. After close, the period is locked.

The recovered example included three missing receipts, an unmatched bank transaction, an unsettled advance and uncertain classifications in a close attention list. Approved Round 3/4 and 19.5 define warning versus blocker: valid explained open advances/transit may carry forward; required unresolved proof/approval/classification and unexplained money differences block close. Exceptions require authorized humans.

### 10.3 Unclassified / Suspense

Allow capturing known money movement without forcing a guessed Mata Anggaran. Mark it **NEEDS REVIEW / Unclassified / Suspense** in the reconciliation workspace. A period cannot close with required classifications unresolved.

**Engineering decision D03:** V1 unclassified records remain staged observations/drafts until required classification is reviewed. They have no official ledger effect and unresolved required period observations block close. This is the approved staging-only policy; it does not introduce a posted suspense account or silently assign “Other.”

### 10.4 Final close and correction boundary

**Approved amended D07:** `OPEN → CLOSED` is irreversible in MVP. Complete financial corrections before the affected period closes; after successful close its transaction population and official snapshot are accepted as final. There is no reopen/unlock, post-close reversal/replacement/adjustment, or later-period accounting correction against a CLOSED transaction. Authorized administrators, imports and AI have no bypass. A future governed extension would require explicit design and approval.

Eligible OPEN-period corrections preserve original postings and append reviewed linked compensating/replacement events. Their target and every affected original/dependency period must be OPEN, checked atomically with finalization and close. New later settlements/returns/remittances against valid carried-forward advances/transit are ordinary new events, not revisions to CLOSED postings. See 19.3.3 and E027.

## 11. Versioned Mata Anggaran masters

### 11.1 Verified source identity, counts and family codes

The original **Alfa Omega Rinegetan Tondano II** Pendapatan and Belanja classification exports named `20261007` are now supplied and extracted. Each `.xls` file is an HTML table exported for Excel, with a declared worksheet named `Sheet0`; it is not a binary BIFF workbook. Read the file format from its contents and keep all identifier values as text.

Both tables have columns **`#`, `Kode`, `Mata Anggaran`, `Aksi`**, one header row and respectively 131/158 numbered data rows. `Aksi` is empty for every data row and provides no approval/posting metadata. There are no transaction amounts or printable report forms in these classification-only exports.

| Master | Data rows | Root families | Source-derived branch rows, including roots | Source-derived detail leaves |
|---|---:|---:|---:|---:|
| Pendapatan | 131 | 6 | 23 | 108 |
| Belanja | 158 | 6 | 29 | 129 |
| Combined | 289 | 12 across two distinct masters | 52 | 237 |

Branch/leaf counts describe source topology. The approved default produces 237 postable leaves and 52 nonpostable branch/root rows unless a parent is explicitly enabled; 289 retained rows are not 289 postable categories. Source eligibility remains null in preserved snapshots.

| Root code — exact string | Pendapatan — exact label body | Rows in family, including root | Belanja — exact label body | Rows in family, including root |
|---|---|---:|---|---:|
| `1.0.00.00` | KEESAAN / PERSEKUTUAN (KOINONIA) | 88 | KEESAAN / PERSEKUTUAN (KOINONIA) | 104 |
| `2.0.00.00` | KESAKSIAN DAN KERJASAMA (MARTURIA) | 10 | KESAKSIAN DAN KERJASAMA (MARTURIA) | 9 |
| `3.0.00.00` | DIAKONIA | 10 | DIAKONIA | 19 |
| `4.0.00.00` | DANA PEMBANGUNAN | 6 | PEMBANGUNAN / INVENTARIS GEREJA | 12 |
| `5.0.00.00` | PENDAPATAN LAINNYA | 8 | PENGELUARAN LAINNYA | 5 |
| `6.0.00.00` | DANA TRANSIT | 9 | DANA TRANSIT | 9 |

Root labels are shown with original capitalization and body spelling. Original leading whitespace/nonbreaking-space indentation is retained in `name_raw` in S Appendix B. Family counts include the family row and its descendants. Both master totals match the earlier design: 131 and 158.

Confirmed required master attributes remain `code`, `name`, `parent_id`, `level`, `display_order`, `postable`, `active`, `version`, `effective_from`, `effective_to`. The source snapshot version IDs in S Appendix B identify extraction provenance only. The date `2026-10-07` comes from the filenames; it is **not evidence of the master’s accounting effective date or publication approval**. The approved first activation is the first day of the first production accounting month; its actual date is configured at deployment. Source snapshot dates remain unset as provenance.

### 11.2 Exact codes and no silent normalization

Codes must be stored as **strings**, preserving exact source spelling, punctuation, leading zeros, segment lengths and other meaningful formatting. Do not parse a dotted code into a decimal number, infer hierarchy solely from prefixes, pad/rewrite codes, deduplicate by a normalized key, or silently fix suspected mistakes.

Preserve original code and label separately from optional search aids. Search normalization cannot rewrite the authoritative display/export code. Any correction is an explicit reviewed change in a new version, with original provenance retained.

### 11.3 Explicit hierarchy and posting eligibility

Every source row needs an explicit parent relationship and `postable` flag, even if visual indentation makes the source appear obvious. Do not infer hierarchy or postability solely from a `.00` suffix: some `.00` entries can be actual posting categories. A parent can itself be postable. Rows receive direct postings only when their explicit eligibility allows it, not merely because they have a code or appear to be leaves.

**Confirmed rollup:** A postable parent total equals its direct postings plus eligible descendant postings, counted once. A nonpostable parent aggregates eligible descendants only. Preserve hierarchy/display order and offer transaction/evidence drill-down.

**Proposed row contract:**

| Field | Purpose |
|---|---|
| Internal row ID | Stable identity independent of displayed code |
| Master kind | `PENDAPATAN` or `BELANJA` |
| Version ID | Published classification version |
| Exact source code | String, unchanged from authoritative source |
| Exact source label | Authoritative wording |
| Parent row ID | Explicit hierarchy; null only for legitimate root rows |
| Top-level family row ID | Explicit family membership |
| Source order | Preserve report/template order |
| Node role | Family, grouping, detail, total or other explicitly reviewed role |
| Postable flag | Whether financial lines can map here |
| Source file/sheet/row or cell | Traceability |
| Source hash / validation note | Provenance and irregularity handling |
| Active/effective status | Availability for new work without changing old snapshots |

If the source contains duplicate codes, ambiguous indentation or missing parents, stop publication and resolve those exact rows. Do not create a silent interpretation. “Six families” is a validation target, not permission to force an arbitrary tree into six invented roots.

### 11.4 Version lifecycle

Maintain draft/reviewed/published versions under a controlled master workflow. Historical transactions retain their posted version. Every used master version can never be deleted, including after archival/deactivation; preserve every row, source/correction provenance and reference needed to reproduce finalized records and snapshots. New versions may change future choices; they cannot silently relabel old transactions or regenerate prior official outputs differently.

The recovered example “Alfa Omega 2026” is an illustrative version label. It is not a recovered filename, workbook checksum or complete master definition.

Each relevant transaction line maps to the correct master row/version. A split payment can map to several postable rows without creating several actual payments. Pendapatan and Belanja versions must be distinguished even if codes look similar.

### 11.5 Extraction verification and source-preserving mapping

Completed checks:

1. Exactly **131 Pendapatan** and **158 Belanja** data rows, with source `#` values sequential and complete.
2. Six top-level source-indentation families per master, with exact root codes `1.0.00.00` through `6.0.00.00`.
3. Exact code strings and original label text captured for every row; no duplicate codes within either master.
4. All codes, including five-part and two-digit segment variants, retained without padding, shortening or normalization.
5. Parent mapping derived from label indentation and row order, with explicit row IDs, parent IDs, level and family. No orphan, cycle, cross-master parent or indentation-level skip in that derived mapping.
6. Source irregularities preserved and disclosed; approved production B113 uses `2.3.02.02` under B110, with source `2.3.08.02` preserved separately.
7. The machine-readable catalogs contain all 289 records and are checked against the parsed source cells.
8. All 775 master numbers and legacy/control numbering are retained; this edition explicitly amends conflicting policy/correction wording. Original wording remains in the unchanged predecessor.

### 11.6 Hierarchy and posting-flag provenance

The original cells encode indentation as **0, 2, 4 or 6 leading `&nbsp;` entities followed by one ordinary separator space**. After HTML decoding these become 1, 3, 5 or 7 leading whitespace characters. That presentation prefix is recorded separately; removing it from the readable label body does not correct spelling, capitalization, punctuation or internal spaces. `name_raw` retains the full decoded source cell.

For each row, the derived parent is the nearest preceding row with the next lower indentation level. Root level is 0. Stable snapshot-local IDs are `P001…P131` and `B001…B158`; identical codes in the two masters do not create a shared identity. In production, bind these IDs to their master-version identity.

This is a source-derived **draft explicit hierarchy**, not an invented code-prefix tree. In particular, Belanja `2.3.08.02` “Kemitraan / Jemaat Mitra” appears under the indented group `2.3.02.00` “Hubungan Kerjasama”; preserve the original snapshot/display relationship; approved production B113 explicitly changes only the code to `2.3.02.02`, retains parent B110 and records the old/new value and approving decision. Do not invent `2.3.08.00`.

**Approved production postability defaults (source proposal preserved separately):** Detail leaves → `true`; group/family rows → `false`. This approved default permits `.00` leaves, for example Pendapatan `1.3.51.00` “PERSEMBAHAN PERSEPULUHAN” and Belanja `1.1.00.00` “SENTRALISASI KE SINODE”. It is not a `.00`-suffix rule. A branch may be postable under approved policy; the candidate `false` must then be explicitly changed and both its direct and descendant postings included without duplication.

The source has no true/false posting flag. Accordingly the machine-readable records use **`postable: null`** plus a separate **`postable_proposal` boolean**. Source maps retain `mapping_status: DRAFT_SOURCE_INDENTATION`. The approved production derivation in 0.5 creates separate version-qualified reviewed rows with concrete postability and the B113 override, then records publication/activation metadata. Do not rewrite source eligibility or publish the source snapshot in place.

### 11.7 Source irregularities retained without correction

| Master / source row | Exact code | Preserved issue / interpretation |
|---|---|---|
| Pendapatan 22 | `1.3.53.07.00` | Five-part code, family-offering subgroup; do not shorten it to four parts |
| Pendapatan 23–25 | `1.3.53.07.01`, `1.3.53.07.02`, `1.3.53.07.03` | Children of that five-part subgroup |
| Belanja 113 | `2.3.08.02` | Preserve original source anomaly; authorized production code is `2.3.02.02` under the unchanged parent `2.3.02.00` |
| Belanja 134 | `4.03.03.00` | Two-digit second segment `03`; do not rewrite as `4.3.03.00` |
| Belanja 146 | `5.03.02.00` | Preserve the second-segment leading zero |
| Belanja 147 | `5.03.03.00` | Preserve the second-segment leading zero |

Source label spellings such as “Ibadah Ibadah”, “Ibadh”, “Pengembagan”, “Tunjuangan”, “Majelelis”, “Konve” and “Saund System” remain unchanged. Internal double spaces remain in `name` and `name_raw`. Missing sequence numbers are not filled with synthetic categories. Any later corrected code/label/hierarchy belongs in an explicitly reviewed new master version with provenance.

## 12. GMIM Report Pack

### 12.1 Required pack contents

The following titles are preserved from the recovered baseline:

1. **Laporan Perbendaharaan Bulanan**.
2. **Buku Kas Umum**.
3. **Buku Kas Pembantu**.
4. **Mata Anggaran Pendapatan**.
5. **Realisasi Pendapatan Menurut Mata Anggaran**.
6. **Mata Anggaran Belanja**.
7. **Realisasi Belanja Menurut Mata Anggaran**.
8. **Rekap Penerimaan**.
9. **Rekap Pengeluaran**.
10. **Posisi Kas & Bank**.
11. **Rekonsiliasi**.
12. **Daftar Bukti Kas**.
13. **Sentralisasi / Settlement**.
14. **Supporting Accountability Outputs**.

Reports are prefilled from finalized ledger data. The Treasurer should not reconstruct them manually. PDF, Excel/spreadsheet and print outputs are in scope. AI may explain the pack and draft a narrative from ledger-derived values; it supplies no authoritative financial totals.

### 12.2 Logical report mapping — pending exact source layout

Confirmed report architecture:

```text
Authoritative Finance Data
    ↓
Default GMIM-compatible Template
    ↓
Jemaat-specific Report Mapping
```

Exact printable forms can vary by Jemaat; the database must not be designed around one spreadsheet layout. Buku Kas fields include **Tanggal, No. Bukti, No. MA/Kode, Uraian, Penerimaan, Pengeluaran, Saldo**. Realization values come from finalized classified lines with automatic parent totals; users must not retype them. Drill-down shows transaction date, amount, description, evidence status and permitted supporting records.

Section 19.7 supplies the precise semantic contract for all fourteen components and 19.6 specifies economic/transit/gross measures. Section 19.10 separates those mappings from **unverified physical cell/page/signature addresses**. Original forms are still required; the MVP presentation policy is approved ECONOMIC_WITH_TRANSIT_SCHEDULE; F14's canonical annexes are explicitly proposed.

### 12.3 Deterministic report invariants

**Recovered minimum invariant:**

```text
Opening balance
+ finalized Pendapatan
− finalized Belanja
± valid transfers / adjustments
= closing book balance
```

The result must reconcile to physical cash plus bank position according to the account model. Internal account transfers net to zero at the whole-workspace level; they affect individual account positions. Internal fund transfers net to zero at the whole-workspace level while changing fund ownership positions.

**Implementation clarification — basis and advances:** The recovered equation is a high-level requirement. It needs an explicit reconciliation bridge if an advance disbursement reduces Cash before becoming Belanja, or collections/remittances affect held money before income/expense recognition. Do not falsely assert that expense realization alone always equals cash outflow.

The exact posting matrix should establish at least:

```text
Closing liquid book position
    = opening liquid book position
    + all finalized liquid inflows
    − all finalized liquid outflows

Expense realization
    = finalized recognized Belanja allocations under the approved recognition basis

Outstanding advance
    = issued − accepted settlement − returned ± eligible OPEN-period authorized corrections

Book / physical difference
    = book position − observed physical cash / bank position,
      with explicitly identified reconciling items
```

For instance, a Rp1,000,000 advance reduces liquid cash by Rp1,000,000 at issue while Belanja may remain zero until settlement. A report must show the advance bridge, or use an explicitly broader “book position” definition that includes the advance position. Section 19 implements the now-approved recognition and ECONOMIC_WITH_TRANSIT_SCHEDULE policies, with formulas; the decision provenance is the rounds 1–6 conversation, not the classification exports.

Other implementation invariants:

- Drafts, uncommitted imports and unconfirmed AI proposals do not affect official totals.
- Transaction-line allocations equal the relevant transaction/header amount.
- Each applicable posting maps once to a postable classification row.
- Parent rollups include eligible direct-parent postings and descendant postings without adding already-rolled-up totals again.
- The same ledger population, dates, sign rules and basis apply to comparable totals across the pack.
- Transfers, opening entries, returned advances and centralization movements follow distinct posting recipes.
- Reversals preserve original and compensating history with defined period effects.
- A deterministic total cannot be overridden by an AI narrative or edited printable cell.
- Report generation is reproducible from its snapshot inputs and recorded software/template versions.

### 12.4 Official snapshots and versioned report templates

For an official report preserve:

- Exact classification version(s).
- Transaction set / authoritative posting population.
- Totals.
- Report-template version.
- Generation timestamp.

These five items are explicitly required by accepted control C08. The supplied current baseline also requires the **reporting period and applicable church configuration**. Future organizational changes must not rewrite historical reports. **Approved snapshot contract in 19.6:** Generator identity, deterministic parameters, output hash, snapshot ID and reconciliation/evidence/approval states at cutoff.

A subsequent master-label/code change or report-template change cannot alter a historical official October report. Example version labels from the source were “Mata Anggaran version: Alfa Omega 2026” and “Report template: GMIM Pack v1.2”; do not treat these illustrative labels as recovered actual version files.

Distinguish live/draft previews from official snapshots. Approved D12 freezes close/report inputs atomically and renders files independently afterward. CLOSED reports are final in MVP: no replacement/restatement mechanism. Re-rendering the same immutable snapshot is allowed; a future replacement policy requires an explicitly governed extension.

## 13. AI architecture, features and governance

### 13.1 Approved routing

```text
Finance application
    ↓
Internal AI service / provider abstraction
    ↓
OpenRouter
    ├── GPT-6 Luna — default / routine assistance
    └── GPT-6.1 Sol — difficult or low-confidence escalation
```

Only GPT-6-family models are in the currently approved configuration. **Astra is explicitly excluded**; use GPT-6 Luna and GPT-6.1 Sol as specified. Provider calls are isolated behind an internal application abstraction. Accounting logic must never depend directly on a specific model endpoint.

Approved pinned OpenRouter model IDs are `openai/gpt-6-luna` and `openai/gpt-6.1-sol`. Do not use moving latest aliases or silently substitute models. Intentional upgrades require a reviewed AI policy version. Runtime endpoint/modality/ZDR availability must be checked without weakening privacy or accounting controls.

### 13.2 Deterministic-rules-first flow

```text
User input / permitted document
    ↓
Deterministic business rules and mappings first
    ├── Resolved → use the deterministic result under normal workflow controls
    └── Unresolved → GPT-6 Luna with narrowed relevant candidates
                        ↓
                   confidence / complexity assessment
                        ├── routine / sufficient → Treasurer review
                        └── low confidence / complex → GPT-6.1 Sol
                                                        ↓
                                                   Treasurer review
    ↓
Human confirmation / authorized workflow
    ↓
Authoritative accepted value
```

AI confidence is separate from accounting confidence. A high confidence score never constitutes a receipt, approver decision or bypass of human confirmation. Narrow Mata Anggaran candidates when practical instead of sending all 289 source rows. Deterministic mappings take precedence over generative guesses.

### 13.3 Complete recovered Treasurer AI feature set

| Feature | Permitted assistance | Authority/confirmation boundary |
|---|---|---|
| Receipt/invoice/bank-proof extraction | Extract date, merchant, amount, document number, description, possible method and relevant lines | Draft until confirmed or deterministically verified |
| Transaction prefill | Prepare income/expense forms from evidence | No silent posting |
| Natural-language entry | Interpret “Bayar PLN Rp1.250.000 dari BNI tanggal 6 Oktober” into a draft | Treasurer reviews and confirms |
| Mata Anggaran suggestion | Suggest valid Pendapatan/Belanja candidates from selected master | Human selection becomes authoritative |
| Complex classification | Escalate ambiguous cases from Luna to Sol | Same confirmation requirement |
| Multi-line splitting | Suggest allocations across several categories for one payment | Split arithmetic deterministic; Treasurer confirms |
| Reconciliation matching | Help with uncertain bank/cash matches after rules | Explicit authorized match confirmation |
| Duplicate detection | Flag likely repeated receipt/payment/donation/import | No automatic deletion |
| Missing-evidence assistance | Explain required proof that is absent | Requirement/status comes from structured rules |
| Date/amount consistency | Flag document/transaction discrepancies | No silent amount/date changes |
| Anomaly detection | Flag unusual amounts, dates, vendors or classifications | Informational warning, not accusation |
| Month-end assistant | Summarize unresolved close items | Cannot close or override blockers |
| Report validation | Explain deterministic validation results and unusual classifications | Authoritative math is generated by the finance engine |
| Report explanation | Explain changes across periods | Numbers come from authorized structured data |
| Financial Q&A | Query electricity spending, offerings, Panitia transactions and other authorized facts | Access-scoped queries; no invented answer values |
| Legacy Excel import assistance | Infer columns, map fields and suggest categories | Staged validation and confirmation before ledger authority |
| Document search | Find receipt, invoice, proof or approval evidence | Only permitted records/documents |
| Correction suggestions | Recommend eligible OPEN-period classification/matching fixes | No closed-period correction path; cannot edit finalized records or bypass E027 |
| Treasurer narrative | Draft monthly report explanation | Ledger-derived numbers; human review |
| Bulk historical processing | Assist noninteractive classification/migration | Same staging/validation/confirmation restrictions |

The financial Q&A examples in the source include total electricity cost this year, Sunday morning offerings in October, all Panitia Natal transactions, and explaining a higher-spending October. These are illustrative queries, not actual church financial facts.

### 13.4 Hard governance restrictions

AI must not:

- Approve expenditure or approve its own suggestions.
- Bypass maker/checker or self-approval rules.
- Finalize transactions outside a human-authorized workflow.
- Close a period or alter a closed period.
- Delete or silently overwrite finalized records.
- Invent receipts, approvals or supporting documentation.
- Bypass permissions.
- Silently alter historical official reports.
- Calculate authoritative balances or replace deterministic aggregation.

Audit relevant material suggestions with model, suggestion, confidence, confirmation/override and final accepted value. A Treasurer override is valid and needs no reason unless another workflow requires one.

### 13.5 Privacy, validated output, cost and failure

The approved AI integration, context minimization, structured-proposal validation, Rp150,000 monthly cap (70/90/100% behavior), audit logging and failure behavior are specified once, in 0.5 (rounds 6A–6I) and S section 12. They are not repeated here.

## 14. Confirmed wider-platform roadmap and privacy architecture

The supplied documents recover these **accepted future-platform rules**. They constrain later expansion but do not make the whole platform a Treasurer MVP launch requirement. The long-term platform includes Jemaat and household data, Kolom, BIPRA, BPMJ, Komisi, Panitia/custom units, services, inventory, Warta, member lifecycle, notifications, reports, attendance, roles/delegation and audit/history.

### 14.1 Organization, roles and permissions

Use a generic organizational-unit model where practical rather than separate hardcoded accounting engines/tables for every type. One person has one account and may hold multiple simultaneous scoped role assignments. Avoid `user.role = "PENATUA"` as the entire authority model.

Role assignment records include Person, Role, Scope, Start Date, End Date and Status. Effective permissions derive from **role + scope + delegation + workflow rules + active service period**. Different BPMJ positions may have different permissions; BPMJ membership grants no blanket access. Technical administration and church/financial authority remain separate.

Historical context retains the role/scope in force when an action happened. Multiple concurrent users must not silently overwrite changes; provide conflict detection. Exact capability matrices and workflow thresholds remain engineering work.

### 14.2 Church Operator and delegation

Each church may have one or more Operators to reduce clerical work. Authorized Operators can prepare records/drafts, upload documents/evidence, assist member/document/service administration, process requests, help the Treasurer and update permitted administrative information.

Operator status does not automatically grant financial approval, leadership appointment, permission management or governance authority. Avoid an unlimited routine `SUPER_ADMIN`. At adoption level 2, Treasurer remains responsible for finalization.

Delegated actions retain **performed by, acting role, scope, on behalf of, duration and timestamp**. Delegation may have start/end dates, and temporary delegation expires automatically. Administrative delegation does not automatically transfer governance authority; all delegated work remains auditable.

### 14.3 Fund governance and unit autonomy

Each Fund has an owner and applicable governance, with operational Treasurer/responsible officer, visibility, approval and spending rules as relevant. Funding source determines the approval workflow. Church, Kolom, BIPRA and Panitia Fund governance can differ.

Future Church Fund flows may require **Request → Treasurer financial review → authorized BPMJ approval → payment → evidence**. Kolom/BIPRA/Panitia money follows its authorized unit governance. Church Treasurer can have consolidated oversight without approving every subordinate-fund transaction. Unit autonomy and church oversight can coexist; precise limits remain explicit policy decisions.

### 14.4 Panitia / temporary groups

Panitia is a temporary organizational unit. Lifecycle:

```text
PLANNING → ACTIVE → EVENT COMPLETED → FINANCIAL CLOSING → CLOSED → ARCHIVED
```

A Panitia can have Ketua, Sekretaris, Bendahara, members, its own Fund, transactions, reports and assets. It may receive approved church allocations and permitted donations/fundraising. Closed Panitia does not continue ordinary financial activity. Remaining money requires approved disposition; remaining assets require an approved owner/destination. Generate final accountability and retain history through archival. Do not strand balances in an archived committee.

### 14.5 Member self-service, household and lifecycle

Members supply their own eligible information where safe/practical rather than making officers retype it. Important changes can follow **Member submits → pending verification → officer verifies → authoritative update**. Self-service does not mean self-approval. Penatua/Syamas focus on supervision/approval; Operators assist exceptional administration.

Household/family is first-class; every person remains an individual record, including dependents. Preserve household-membership history. Households may have a publication/display name that does not automatically depend on the current household head. Internal person, household, member history and login identity remain distinguishable.

Lifecycle events include **Birth, Registration, Kolom movement, Incoming transfer, Outgoing transfer, Temporary relocation, Inactive and Death**. Do not overwrite history.

**Birth:** A formal event, not an ordinary profile edit. Parents/household may submit; verification precedes authoritative registration as required. Create an individual person linked to household and appropriate Kolom; update statistics. Birth does not imply baptism, Sidi or another sacramental/church status. Later service workflows reuse that child record. Birth information does not automatically become public Warta content.

**Death:** Confirm status `DECEASED` rather than delete the person. Preserve family, membership, role, donation, transaction, service and audit history. Confirmation disables login, stops personal notifications, removes active approval authority, ends/suspends active roles, flags leadership vacancies, reroutes pending workflows and updates household statistics. A Treasurer's death triggers critical operational review. Never automatically appoint a replacement or transfer financial access. Funeral/pastoral workflows may follow; health/cause-of-death information is not automatically public.

**Kolom movement:** Retain dated assignments and effective date; support individual, whole-household and selected-family-member transfer. Members/households may initiate with source/destination verification as required. Leadership roles do not automatically move; Penatua/Syamas movement triggers leadership review. Historical financial transactions retain original scope; future applicable transactions use new scope from effective date.

**Inter-church transfer:** Distinguish another GMIM church, non-GMIM church, temporary relocation and unknown destination. Outgoing members are not deleted. Retain effective date/destination and support external churches that do not use the platform. New registration without a previous church is not a transfer. Temporary relocation need not force transfer-out. Incoming GMIM transfers may use official documentation; incoming non-GMIM membership may follow a separately configurable workflow. Do not hardcode ecclesiastical eligibility without confirmed governance requirements.

If both churches use the platform, transfer only explicitly authorized information. Neither church gains unrestricted access to the other's database. Private donations, pastoral notes, internal financial data and unrelated confidential material do not automatically transfer. Existing financial/audit history remains unchanged.

### 14.6 Warta as a publication projection

Warta is a published compilation of authoritative information; it is not the canonical source of underlying transactions, announcements or services. Announcements exist independently. Reuse authorized services/schedules, announcements, Kolom/BIPRA activities, finalized attendance totals, financial summaries, lifecycle announcements, approved donations and other church information.

Lifecycle:

```text
DRAFT → REVIEW → APPROVED → PUBLISHED → ARCHIVED
```

Regular members see published editions. Preserve historical editions and support PDF/print. Published content must not silently change; corrections use traceable revisions. Exact template, reviewer/approver capabilities and publication scope remain to specify.

**Implementation clarification:** Apply audience/privacy rules when building the publication projection, before delivering its data or exports. Visual hiding alone does not enforce masking. Keep private canonical records separate from published identities and snapshots.

### 14.7 Mandatory publication masking and exceptions

Internal identity and publication identity are separate; masking does not alter authoritative records or transaction ownership. Supported modes are **Full Name, Family Name, Family + Kolom, Kolom, BIPRA, BIPRA + Kolom and Anonymous where applicable**. Family masking can represent an individual's activity; household-owned activity may use household as its authoritative subject.

For eligible ordinary publication, member-requested masking is **mandatory**. Editors and templates cannot casually override or weaken it. Full internal identity remains available only to authorized users. Household may have a default preference; a stricter individual preference overrides a less-private household default for that individual's activity. Sensitive categories may need stronger privacy than a general preference. Warn when a masked representation remains easily identifiable and let members preview it.

Financial transparency does not automatically require revealing full personal identity. If Fund/Scope/Kolom/BIPRA/Family identity satisfies transparency, masking remains. Overrides require a legitimate official, governance, legal or formal-accountability necessity, explicit reason and appropriate authority; ordinary editors cannot independently override protected identity. Inform affected members where appropriate.

Audit each exception with affected person, original preference, published representation, reason, publication/report, approver and timestamp. The controlling principle is:

> **Mask by request; reveal by exception; audit every exception.**

Snapshot the exact published representation. A family published as “Keluarga Wenas-Lasut — Kolom 7” remains so historically after moving to Kolom 12. Later privacy changes apply prospectively to future eligible publications and do not silently rewrite prior editions.

### 14.8 Services/events

Future services may include Sunday/Kolom/BIPRA worship, Baptism, Sidi, Marriage, Funeral, pastoral services, Panitia/special events and special worship. Reuse existing person/household data for member-requested services and permitted reports/Warta.

Normal event lifecycle in supplied design:

```text
DRAFT → APPROVED/SCHEDULED → LIVE → COMPLETED → CLOSED
```

This service/event capability does not bring deferred Pelayan scheduling/service roster into MVP.

### 14.9 Attendance — anonymous aggregate headcount only

Do not build named member/household check-in, individual QR attendance, personal attendance/absence histories, absent-member lists, attendance-based pastoral monitoring, attendance scores or attendance/donation member scoring.

Attendance belongs to a recognized Service/Event, normally approved/scheduled before counting. Authorized audited ad-hoc services and retroactive entry are permitted. Counts may be total-only or include non-identifying aggregate categories; categories never link to specific people. Multiple authorized counters/stations may contribute distinguishable internal subtotals, with realtime synchronization and offline counting where practical. Offline sync must avoid duplicates.

Attendance lifecycle:

```text
LIVE → REVIEW → FINALIZED
```

Only finalized counts enter official reports/Warta. Finalized counts are not casually editable. Corrections retain original value, corrected value, reason, responsible person and timestamp.

Scoped capabilities: `attendance.view`, `attendance.count`, `attendance.review`, `attendance.finalize`, `attendance.correct`, `attendance.assign_counter`. Temporary counters can receive only `attendance.count` for one specific service. Counting does not grant finalization; regular members do not need attendance-management access.

### 14.10 Notifications

Use a central Notification Engine with **realtime in-app updates and push**. WhatsApp/SMS/email may be added later. **Quiet hours are explicitly not part of the current design.**

Notifications are scope-aware, role-aware, relevant, action-oriented, deep-linked and aggregated where useful. Important action notifications may keep delivery/read/action status. Optional categories can be configurable; mandatory workflow items may remain visible in-app. Restrict urgent publishing. Resolve/remove notifications when underlying work completes as appropriate.

Treasurer triggers include missing evidence, overdue advances, unresolved bank reconciliation, external approval awaiting recording, transactions awaiting review and month-end issues. Notification delivery is not approval or financial evidence, and push failure does not stop accounting.

### 14.11 Reports, search, duplication and historical integrity

Future reports can cover Jemaat, Kolom, BIPRA, Panitia, Fund, Account, services/aggregate attendance, lifecycle statistics and inventory. Derive values from authoritative data; no generic custom-report/query builder is required initially. Global search respects permissions and cannot expose unrelated confidential records merely because a name matches.

Potential duplicate people support **Compare, Merge, Not Same Person**. Merge preserves financial history, roles, household relationships, service history and audit history. Use controlled master data where it improves consistency without making entry unnecessarily difficult.

Authoritative data favors lifecycle/history over destructive deletion: finalized transaction → reversal; published Warta → revision/archive; member → lifecycle status; closed Panitia → archive. Empty drafts may be deletable. Organizational/profile changes do not rewrite historical finance, publication or audit context.

## 15. Security, audit, backup/export and graceful degradation

### 15.1 Confirmed MVP infrastructure

- Encrypt sensitive files.
- Isolate each Jemaat tenant.
- Maintain automated backups.
- Log sensitive actions.
- Support session revocation.
- Allow church export of ledger, reports and evidence metadata.
- Keep financial data from becoming hostage to the application.

These are MVP requirements, not deferred platform improvements.

### 15.2 Security, recovery and export contract

**Confirmed supplied rules:** Protect sensitive finance data in storage and transit; secure authentication; high-privilege session revocation; operationally test backup restoration. Audit records actual user, acting role/context, scope, delegation, timestamp, previous/new values and required reason, including privacy overrides, attendance corrections and linked reversals. Audit history cannot be casually edited by administrators. Church export covers ledger, reports, Mata Anggaran master, Account/Fund information and evidence metadata.

**Implementation detail:** Use authenticated, server-enforced tenant/scope checks for records, queries, files, exports and AI data access. Keep credentials outside client code. Encrypt transport and sensitive stored artifacts; restrict evidence downloads to authorized users. Validate uploads and avoid executable handling of untrusted file content.

Audit meaningful lifecycle, approval, classification-version, evidence-verification, import, close, reversal, report, export and permission actions. Record actor/time, object identity, prior/new relevant values and declared reason where required. Audit does not mean logging passwords, tokens or unrestricted document contents.

Backups should include the data and artifact references necessary to recover finalized postings and historical official reports. Define recovery objectives, retention, restore procedure and operationally verify restoration as required by Master rule 447. Round 5 approved RPO 1 hour, RTO 8 hours, 7-day PITR, 35 daily backups and 12 monthly recovery snapshots; full restore tests run quarterly and before/after major migrations. Backup expiry is separate from financial-record retention and never permits deletion of used master versions.

Export should be usable outside the app: machine-readable ledger/line data, exact master versions, approval/evidence metadata, official PDF/Excel report snapshots and a manifest explaining their relationships. Round 5F selected full portable export: actual church-owned evidence files are included, with checksums and relationship manifest; metadata-only export does not satisfy MVP. This authorized export workflow is separate from restricted infrastructure backups.

### 15.3 Failure behavior

| Unavailable component | Required behavior |
|---|---|
| OpenRouter / GPT-6 Luna / GPT-6.1 Sol | Manual accounting and authoritative-record access continue |
| AI quota/spending allowance | AI can pause; ordinary accounting continues |
| Document extraction | Manual entry, classification and evidence handling continue as supported |
| Push notifications | Accounting workflow and in-app state remain usable |
| Report helper AI | Deterministic report generation continues |

**Implementation clarification:** Graceful AI degradation does not imply permission to bypass actual accounting validation, forge uploaded evidence or pretend a failed data commit succeeded. If an essential database/storage operation fails, retain a clear unsaved/error state and support safe retry. MVP deployment is approved managed cloud with server-authoritative finalization, numbering, reconciliation and close; no church self-hosting or offline financial finalization. Future attendance separately supports offline counting where practical with duplicate-safe synchronization; do not infer that as an approved offline accounting architecture.

## 16. Consolidated master rulebook — all 775 supplied rules

This is the user-supplied **Consolidated Master Rulebook**, embedded in full. Rule order/numbering and source subsections are retained. Identified round 1–6 amendments below change incompatible wording; all other rules retain source text. Source subsection headings are demoted one level to fit the document. The unchanged predecessor and recorded source hashes preserve original provenance. Refer to these as **Master rule N** (`M001…M775`). These numbers are independent from Legacy AI rules 293–342 in Appendix A and Controls C01–C20 in Appendix B.

The previous handover's H001–H110 synthesis is replaced by this recovered current master. Future-platform rules remain future constraints; their inclusion does not extend the Treasurer MVP scope beyond the explicit deferrals.

### A. Product & Adoption Principles

1. The application shall be architected as a multi-Jemaat platform even when initially deployed to one Jemaat.

2. Data belonging to different Jemaat tenants must be isolated.

3. The first usable product shall prioritize the Bendahara Jemaat rather than requiring whole-church adoption.

4. A Bendahara must be able to obtain meaningful value from the system without BPMJ, Penatua, Syamas, BIPRA leaders, Panitia leaders, or regular members having accounts.

5. Initial product positioning should focus on financial recording, reconciliation, evidence, Mata Anggaran, and GMIM-compatible reporting.

6. The MVP should reduce dependence on Excel sheets, notebooks, WhatsApp records, bank screenshots, receipt folders, and manually assembled reports.

7. The product should support progressive institutional adoption rather than requiring an organization-wide migration at launch.

8. Progressive adoption should support:
   - Solo Bendahara.
   - Bendahara + assistant/operator.
   - Unit Treasurers.
   - In-app approvers.
   - Full church-management platform.

9. Collaboration features must not make solo Bendahara use impossible.

10. The underlying architecture may be richer than the initial UI.

11. The MVP interface should hide unnecessary organizational complexity.

12. The system should prioritize workflows and “things requiring attention” instead of exposing large CRUD menus.

13. Data should be entered once and reused everywhere it is authorized to appear.

14. Reports must derive from authoritative system data rather than requiring repeated manual entry.

15. Privacy, auditability, backups, exportability, permissions, and data ownership are architectural requirements, not later add-ons.

16. The church retains ownership of its data.

17. The platform must support export of the church’s authoritative financial data.

18. The system must remain usable even when optional external services fail.

19. The application should be mobile-friendly and usable by non-technical church officers.

20. The wider GMIM church-management vision remains valid, but must not delay delivery of the Treasurer core.

---

### B. Current MVP Scope

21. The Treasurer MVP shall include financial recording.

22. The Treasurer MVP shall include cash and bank accounts.

23. The Treasurer MVP shall include Funds.

24. The Treasurer MVP shall include financial scopes.

25. The Treasurer MVP shall include Mata Anggaran Pendapatan.

26. The Treasurer MVP shall include Mata Anggaran Belanja.

27. The Treasurer MVP shall include income/receipts.

28. The Treasurer MVP shall include offerings.

29. The Treasurer MVP shall include donations.

30. The Treasurer MVP shall include expenses.

31. The Treasurer MVP shall include reimbursements.

32. The Treasurer MVP shall include cash advances.

33. The Treasurer MVP shall include internal transfers.

34. The Treasurer MVP shall include supporting financial evidence.

35. The Treasurer MVP shall support external approvals.

36. The Treasurer MVP shall support future in-app approvals without redesigning the ledger.

37. The Treasurer MVP shall include bank/cash reconciliation.

38. The Treasurer MVP shall include monthly closing.

39. The Treasurer MVP shall include audit history.

40. The Treasurer MVP shall include PDF report export.

41. The Treasurer MVP shall include spreadsheet/Excel-compatible export.

42. The Treasurer MVP shall include the GMIM Report Pack.

43. The Treasurer MVP shall include AI assistance as an optional productivity layer.

44. Budgeting is deferred.

45. Procurement is deferred.

46. Service roster/Pelayan scheduling is deferred.

47. Foreign-currency accounting is deferred.

48. V1 supports IDR only.

49. V1 supports one church workspace per tenant.

50. V1 uses one active fiscal/calendar configuration per workspace.

---

### C. Core Finance Concepts

51. Account, Fund, Scope, and Mata Anggaran must remain separate concepts.

52. An Account describes where money physically exists.

53. Typical Accounts include cash and bank accounts.

54. A Fund describes which pool of money owns or restricts the money.

55. A Scope describes which organizational entity or activity the financial record belongs to.

56. Mata Anggaran describes the economic classification or purpose of the receipt/expenditure.

57. An Account must not be used as a substitute for a Fund.

58. A Fund must not be used as a substitute for a Scope.

59. A Scope must not be used as a substitute for Mata Anggaran.

60. Mata Anggaran must not be used as a substitute for an Account.

61. Every relevant finalized transaction should identify the applicable Account.

62. Every relevant finalized transaction should identify the applicable Fund.

63. Every relevant finalized transaction should identify the applicable Scope.

64. Every relevant finalized income line should map to an applicable Mata Anggaran Pendapatan code.

65. Every relevant finalized expense/payment/settlement line should map to an applicable Mata Anggaran Belanja code.

66. Financial scopes may initially exist without requiring user accounts for the corresponding unit.

67. Examples of scopes include Jemaat, Kolom, BIPRA, Panitia, and custom units.

68. The same shared finance engine shall serve Jemaat, Kolom, BIPRA, Panitia, and future units.

69. Separate accounting engines must not be built for each organizational unit.

70. Fund ownership determines the applicable governance workflow.

---

### D. Transaction Lifecycle

71. The system shall have one authoritative financial transaction lifecycle.

72. The default lifecycle shall be equivalent to:
   `DRAFT → REVIEWED → FINALIZED → REVERSED`.

73. Only FINALIZED transactions affect official balances.

74. Only FINALIZED transactions affect Buku Kas outputs.

75. Only FINALIZED transactions affect Realisasi Pendapatan.

76. Only FINALIZED transactions affect Realisasi Belanja.

77. Only FINALIZED transactions affect official GMIM Report Pack totals.

78. Draft transactions must not affect authoritative financial statements.

79. Reviewed-but-not-finalized transactions must not affect official balances.

80. Finalized transactions are immutable in ordinary operation.

81. A finalized amount must not be silently overwritten.

82. Corrections to finalized transactions use linked adjustment/reversal mechanisms only while every affected original/dependency period and target period remains OPEN. CLOSED transactions have no later-period correction mechanism in MVP. **[Amended: Round 2 / D07.]**

83. A corrected transaction must preserve linkage to the original record where applicable.

84. Reversed transactions must remain visible in audit/history.

85. A record that has participated in an official workflow should generally be reversed, cancelled, or archived rather than physically deleted.

86. Empty drafts may be deletable.

87. Finalized financial records should not be physically deleted through ordinary administration.

88. Cancellation must remain auditable.

89. Reversal must remain auditable.

90. Transaction state must be explicit rather than inferred from missing fields.

---

### E. Unclassified / Suspense Transactions

91. The application must support captured transactions whose classification is not yet known.

92. The Treasurer must not be forced to guess a Mata Anggaran code.

93. An unresolved transaction may use a state such as NEEDS REVIEW or UNCLASSIFIED.

94. Unclassified transactions may participate in reconciliation when necessary.

95. Unresolved required classifications may block monthly closing.

96. The system should clearly show unresolved classifications on the Treasurer dashboard.

97. AI uncertainty must not force classification.

98. A transaction may remain unresolved until a human reviews it.

---

### F. Voucher & Reference Numbering

99. The system should generate unique voucher/reference numbers.

100. Cash-in vouchers may use a configurable series such as BKM.

101. Cash-out vouchers may use a configurable series such as BKK.

102. Transfers may use a configurable series such as TRF.

103. Cash advances may use a configurable series such as UM.

104. Voucher numbers must be unique within the applicable church workspace/series.

105. A voucher number must not be silently reused after cancellation.

106. Number generation must be auditable.

107. Exact numbering formats may later be configurable per Jemaat.

---

### G. Financial Transaction Types

108. The system shall support ordinary Income/Receipt transactions.

109. The system shall support Offering transactions.

110. The system shall support Donation transactions.

111. The system shall support Expense/Direct Payment transactions.

112. The system shall support Reimbursement transactions.

113. The system shall support Cash Advance transactions.

114. The system shall support Internal Transfer transactions.

115. The system shall support Reversal/Adjustment transactions.

116. Different transaction types must not be represented as fake generic expenses when their accounting meaning differs.

117. A reimbursement represents money previously spent personally and subsequently repaid.

118. A cash advance represents money issued before final expenditure is documented.

119. An internal cash-to-bank movement is not ordinary income.

120. An internal cash-to-bank movement is not ordinary expense.

---

### H. Cash Advances

121. Cash advances must have their own lifecycle.

122. The cash-advance lifecycle should support at least:
   `OPEN → PARTIALLY SETTLED → SETTLED`.

123. Issuing an advance must not automatically create final Belanja for the entire amount.

124. Actual spending against an advance should be classified during settlement.

125. Supporting evidence should attach to settled spending.

126. Unused cash returned from an advance must be recorded separately.

127. Partially settled advances must show their outstanding amount.

128. Open advances should appear in the Treasurer’s Needs Attention view.

129. Month-end reporting should disclose unresolved advances appropriately.

130. AI may remind the Treasurer of unresolved advances but may not settle them automatically.

---

### I. External & In-App Approvals

131. The MVP must support EXTERNAL approval.

132. The MVP must support NOT_REQUIRED approval status where applicable.

133. The architecture must support future IN_APP approvals.

134. EXTERNAL approval means that authorization occurred outside the application.

135. The application must never misrepresent an external approval as an in-app approval.

136. External approval should store the declared approver.

137. External approval should store the approver’s role/authority where known.

138. External approval should store approval date where known.

139. External approval should store approval method.

140. External approval may store notes.

141. External approval should allow supporting evidence.

142. Possible external evidence includes meeting minutes, WhatsApp screenshots, signed paper, or other supporting records.

143. BPMJ adoption is not required for the solo Treasurer MVP.

144. The application records external authorization; it does not impersonate the authorizing person.

---

### J. Separation of Duties

145. Treasurer-first does not mean Treasurer-super-admin.

146. Treasurer authority and technical administration must remain separate concepts.

147. System Administrator does not automatically equal financial authority.

148. Church Operator does not automatically equal financial approver.

149. Request, Approve, Pay, and Verify should remain distinguishable financial actions.

150. The same individual should not automatically control every financial step.

151. Self-approval restrictions must remain enforceable as collaboration is introduced.

152. Multiple roles must not allow a person to bypass self-approval restrictions.

153. A person submitting a request under one role may be prohibited from approving it under another role.

154. Maker/checker controls must be configurable but structurally supported.

155. AI can never serve as maker/checker approver.

---

### K. Offering Collection

156. Offering management shall be a first-class financial workflow.

157. Offering records may identify the relevant service/source without tracking individual attendees.

158. Offering records may contain cash portions.

159. Offering records may contain transfer/QR portions.

160. The system may calculate total offering from its components.

161. Offering records should identify the relevant Mata Anggaran Pendapatan.

162. Offering records should identify the destination Account.

163. Offering records should identify the applicable Fund.

164. Offering records may contain counting-sheet evidence.

165. Cash offering may be counted by more than one authorized person where church practice requires.

166. Offering verification should be auditable.

167. Offering collection, deposit, and reconciliation must not double-count the same money.

---

### L. Centralization / Settlement

168. Centralization/settlement must distinguish different monetary states.

169. The system should distinguish Amount Collected.

170. The system should distinguish Amount Payable.

171. The system should distinguish Amount Remitted.

172. The system should distinguish Amount Received.

173. These values must not be automatically treated as the same transaction.

174. Sentralisasi reporting must avoid double-counting.

175. Unit-level settlements may later be submitted directly by unit Treasurers.

176. Solo-Treasurer MVP may record these settlements manually.

---

### M. Evidence & Financial Documents

177. Financial evidence must use structured status.

178. Evidence status should support NOT_REQUIRED.

179. Evidence status should support REQUIRED_MISSING.

180. Evidence status should support UPLOADED.

181. Evidence status should support VERIFIED.

182. Evidence status should support EXCEPTION_ACCEPTED.

183. Evidence status must not be represented only as a boolean attachment flag.

184. Supporting evidence may include receipts.

185. Supporting evidence may include invoices.

186. Supporting evidence may include transfer proofs.

187. Supporting evidence may include bank statements.

188. Supporting evidence may include offering count sheets.

189. Supporting evidence may include reimbursement proof.

190. Supporting evidence may include cash-advance settlement proof.

191. Supporting evidence may include external approval documents.

192. The MVP does not require a sophisticated standalone document-management platform.

193. Documents may initially attach directly to their related financial record.

194. Evidence must remain traceable to the transaction/report it supports.

---

### N. Reconciliation

195. Reconciliation is a core MVP capability.

196. Reconciliation must operate against specific Account positions.

197. Bank-statement entries should be represented as individual lines.

198. Reconciliation should be line-based.

199. Reconciliation import must be idempotent.

200. Reimporting the same statement must not create duplicate statement lines.

201. Provider transaction IDs should be used where available.

202. Generated fingerprints may be used where provider IDs are unavailable.

203. Reconciliation should identify unmatched statement entries.

204. Reconciliation should identify unmatched ledger entries.

205. Exact/near-exact amount/date/reference matching should use deterministic logic first.

206. AI may assist ambiguous reconciliation.

207. AI may suggest a match but may not silently finalize the match.

208. Reconciliation differences must remain visible until resolved or explicitly explained.

---

### O. Imports

209. Financial imports must use staging.

210. Import workflow shall be:
   `IMPORT → VALIDATE → DUPLICATE CHECK → CLASSIFICATION REVIEW → COMMIT`.

211. Uploaded Excel files must not instantly become authoritative ledger data.

212. Uploaded bank statements must not instantly become authoritative ledger data.

213. Imports should report invalid dates.

214. Imports should report invalid amounts.

215. Imports should report likely duplicates.

216. Imports should report missing required information.

217. Imports may use AI to suggest mapping.

218. Imported classification suggestions must remain reviewable.

219. Committing staged data creates the authoritative records.

220. Bulk historical migration may use lower-cost noninteractive AI processing.

---

### P. Opening Balances

221. Initial onboarding must support explicit opening balances.

222. Opening balances must have an effective date.

223. Opening cash balances must be recorded explicitly.

224. Opening bank balances must be recorded explicitly.

225. Opening Fund balances must be represented consistently with the accounting model.

226. Outstanding cash advances may need opening-state representation.

227. Opening balances are not fake Pendapatan.

228. Opening balances must be distinguishable from current-period transactions.

229. Opening entries must be auditable.

---

### Q. Monthly Closing

230. Monthly closing is a formal control point.

231. Closing should run deterministic validation checks.

232. Required Account reconciliation should be complete before closing according to policy.

233. Required Mata Anggaran classifications should be resolved before closing.

234. Invalid transaction arithmetic must block closing.

235. Required evidence states should be resolved according to policy.

236. Invalid transaction states must block closing.

237. Outstanding advances should be surfaced before closing.

238. A month may be closed only by an authorized human workflow.

239. AI cannot close an accounting period.

240. A closed period is locked.

241. Ordinary edits must not alter a closed period.

242. After successful close, CLOSED is final and irreversible in MVP. No reopen, unlock or later-period accounting reversal/replacement/adjustment against a CLOSED transaction is provided. Financial corrections must be completed before the affected period closes. **[Replaced: Round 2 / amended D07.]**

243. The close action must be auditable.

---

### R. Deterministic Financial Invariants

244. Authoritative financial arithmetic must be deterministic software logic.

245. AI must never determine official financial totals.

246. At minimum:
   `Opening Balance + Finalized Pendapatan - Finalized Belanja ± valid transfers/adjustments = Closing Book Balance`.

247. Closing book balance must reconcile to applicable Cash/Bank Account positions according to the accounting model.

248. Internal transfers must not inflate total Pendapatan.

249. Internal transfers must not inflate total Belanja.

250. Report generation must detect inconsistent balances.

251. Reports that do not reconcile should show an explicit issue.

252. The system should not silently “fix” imbalances.

---

### S. Report Snapshotting & Versioning

253. Official reports must be reproducible historically.

254. Every official report should snapshot its reporting period.

255. Every official report should snapshot the transaction set used.

256. Every official report should snapshot totals.

257. Every official report should snapshot the Mata Anggaran version.

258. Every official report should snapshot the report-template version.

259. Every official report should record generation timestamp.

260. Applicable church configuration should be retained with the report snapshot.

261. Future Mata Anggaran changes must not rewrite historical reports.

262. Future report-template changes must not rewrite historical reports.

263. Future organizational changes must not rewrite historical reports.

---

### T. Mata Anggaran — General

264. Mata Anggaran Pendapatan and Belanja are classification masters, not budgeting modules.

265. Both classification trees must be versioned.

266. Codes must be stored as strings.

267. Exact source code formatting must be preserved.

268. The application must not silently normalize unusual code formatting.

269. Classification hierarchy must be explicit.

270. Each classification should support parent_id.

271. Each classification should support level.

272. Each classification should support display order.

273. Each classification should support postable/non-postable state.

274. Each classification should support active status.

275. Each classification should support effective dates/version.

276. Parent/postable status must not be inferred only from `.00` suffix.

277. Historical transactions retain the classification version effective when they were posted.

278. A future Mata Anggaran version must not mutate historical classifications.

---

### U. Mata Anggaran Pendapatan

279. The uploaded Alfa Omega Rinegetan Tondano II Pendapatan template is an accepted source classification for that church/version.

280. The analyzed Pendapatan template contains 131 data rows.

281. Its top-level families include Keesaan/Persekutuan (Koinonia).

282. Its top-level families include Kesaksian dan Kerjasama (Marturia).

283. Its top-level families include Diakonia.

284. Its top-level families include Dana Pembangunan.

285. Its top-level families include Pendapatan Lainnya.

286. Its top-level families include Dana Transit.

287. Every finalized income/receipt line should map to an applicable postable Pendapatan code where classification is required.

288. Deterministic mappings should prefill known Pendapatan codes.

289. Ambiguous Pendapatan classifications should require Treasurer review.

---

### V. Mata Anggaran Belanja

290. The uploaded Alfa Omega Rinegetan Tondano II Belanja template is an accepted source classification for that church/version.

291. The analyzed Belanja template contains 158 data rows.

292. Its top-level families include Keesaan/Persekutuan (Koinonia).

293. Its top-level families include Kesaksian dan Kerjasama (Marturia).

294. Its top-level families include Diakonia.

295. Its top-level families include Pembangunan/Inventaris Gereja.

296. Its top-level families include Pengeluaran Lainnya.

297. Its top-level families include Dana Transit.

298. Every finalized expense/payment/reimbursement/settlement line should map to an applicable postable Belanja code where classification is required.

299. Ambiguous Belanja classifications should require Treasurer review.

---

### W. Multi-Line Classification

300. One real-world payment may contain multiple Mata Anggaran lines.

301. One bank movement should not be duplicated merely because it contains several economic classifications.

302. One receipt/deposit may contain multiple Pendapatan lines.

303. Line classifications must sum correctly to the parent transaction amount where appropriate.

304. Mata Anggaran reporting should aggregate transaction lines, not fake duplicated payments.

305. Supporting evidence may apply to the whole transaction or specific lines where necessary.

---

### X. Hierarchical Report Aggregation

306. Parent Mata Anggaran totals should aggregate descendant transactions automatically.

307. If a parent code is itself postable, its total equals direct postings plus eligible descendant totals.

308. Parent aggregation must not double-count descendant amounts.

309. Reports should preserve hierarchy and display order.

310. Users should be able to drill from aggregated amount to supporting source transactions.

---

### Y. GMIM Report Pack

311. The GMIM Report Pack is a core Treasurer MVP output.

312. It shall include Laporan Perbendaharaan Bulanan.

313. It shall include Buku Kas Umum.

314. It shall include Buku Kas Pembantu.

315. It shall include Mata Anggaran Pendapatan.

316. It shall include Realisasi Pendapatan Menurut Mata Anggaran.

317. It shall include Mata Anggaran Belanja.

318. It shall include Realisasi Belanja Menurut Mata Anggaran.

319. It shall include Rekap Penerimaan.

320. It shall include Rekap Pengeluaran.

321. It shall include Posisi Kas & Bank.

322. It shall include Rekonsiliasi.

323. It shall include Daftar Bukti Kas.

324. It shall include Sentralisasi/Settlement reporting where relevant.

325. It shall support appropriate supporting accountability outputs.

326. Reports should support PDF output.

327. Reports should support Excel/spreadsheet output.

328. Reports should support printing.

329. Exact printable layouts may vary between Jemaat.

330. The finance database must not be designed around one spreadsheet layout.

331. The system should support a default GMIM-compatible report template.

332. The system should allow church/report-template mapping later.

---

### Z. Buku Kas

333. Buku Kas outputs should derive automatically from finalized ledger entries.

334. Buku Kas may include Tanggal.

335. Buku Kas may include No. Bukti.

336. Buku Kas may include No. MA/Kode.

337. Buku Kas may include Uraian.

338. Buku Kas may include Penerimaan.

339. Buku Kas may include Pengeluaran.

340. Buku Kas may include running Saldo.

341. Treasurer should not manually rebuild Buku Kas after entering transactions.

---

### AA. Realisasi Reports

342. Realisasi Pendapatan values must come from finalized classified income lines.

343. Realisasi Belanja values must come from finalized classified expense lines.

344. Parent totals must calculate automatically.

345. The Treasurer should not manually retype realization values.

346. Drill-down should show source transaction date.

347. Drill-down should show amount.

348. Drill-down should show description.

349. Drill-down should show evidence status.

350. Drill-down should permit access to supporting transaction/evidence according to permissions.

---

### AB. AI Architecture

351. OpenRouter is the approved AI gateway for the Treasurer MVP.

352. The application currently uses GPT-6 family models only.

353. GPT-6 Luna is the default routine model.

354. GPT-6.1 Sol is the difficult-case escalation model.

355. Astra is excluded from the approved model configuration.

356. AI provider calls must go through an internal application abstraction.

357. Finance logic must not depend directly on OpenRouter-specific code throughout the application.

358. Model changes must not require rewriting ledger logic.

359. Standard/low-latency routes should be used for interactive Treasurer actions.

360. Cheaper supported noninteractive routes may be used for bulk work.

---

### AC. AI Routing

361. Deterministic rules should run before AI whenever practical.

362. Deterministic classifications take precedence over generative classifications.

363. Known merchant/source mappings should not require unnecessary AI calls.

364. GPT-6 Luna should handle routine extraction and classification.

365. Low-confidence or genuinely complex cases may escalate to GPT-6.1 Sol.

366. AI should receive narrowed Mata Anggaran candidates where practical.

367. The full classification catalog should not be unnecessarily sent to the model for every transaction.

368. Treasurer confirmation remains required for AI-originated financial classification changes.

---

### AD. AI Features

369. AI may extract data from receipt images.

370. AI may extract data from invoices.

371. AI may extract data from bank-proof images/PDFs.

372. AI may prefill transaction forms.

373. AI may interpret natural-language transaction entry.

374. AI may suggest Pendapatan classification.

375. AI may suggest Belanja classification.

376. AI may suggest multi-line transaction splitting.

377. AI may suggest reconciliation matches.

378. AI may assist duplicate detection.

379. AI may detect missing evidence.

380. AI may compare evidence amount with entered amount.

381. AI may compare evidence date with transaction date.

382. AI may identify likely inconsistent classifications.

383. AI may identify unusual amounts.

384. AI may identify possible anomalies.

385. AI anomaly warnings are informational and must not imply misconduct.

386. AI may summarize month-end unresolved issues.

387. AI may explain GMIM reports.

388. AI may answer natural-language financial questions over authorized data.

389. AI may assist legacy Excel/notes migration.

390. AI may search authorized financial evidence/documents.

391. AI may suggest eligible OPEN-period corrections; it cannot offer or execute a CLOSED-transaction accounting correction workflow in MVP. **[Amended: D07 / Round 6.]**

392. AI may draft a plain-language Treasurer monthly narrative.

393. AI may assist bulk historical classification/import.

---

### AE. AI Governance

394. AI is a Treasurer copilot, not accounting authority.

395. AI may extract.

396. AI may suggest.

397. AI may prefill.

398. AI may match.

399. AI may search.

400. AI may explain.

401. AI may summarize.

402. AI may flag.

403. AI may draft.

404. AI cannot approve expenditure.

405. AI cannot approve its own suggestions.

406. AI cannot silently finalize transactions.

407. AI cannot close accounting periods.

408. AI cannot alter closed periods.

409. AI cannot silently delete finalized transactions.

410. AI cannot silently overwrite finalized transactions.

411. AI cannot bypass maker/checker controls.

412. AI cannot bypass self-approval rules.

413. AI cannot override governance permissions.

414. AI cannot fabricate receipts.

415. AI cannot fabricate payment evidence.

416. AI cannot fabricate approval evidence.

417. AI cannot silently change historical reports.

418. Low-confidence classifications require explicit human review.

419. AI confidence is not accounting evidence.

420. AI suggestion/confidence should be stored separately from authoritative accounting values.

421. The model used should be logged for material AI-assisted actions where useful.

422. User confirmation/override should be auditable where applicable.

423. The authoritative classification is the Treasurer-confirmed value.

424. A Treasurer may override an AI suggestion.

425. A Treasurer override need not require justification unless another workflow requires one.

---

### AF. AI Failure & Cost Controls

426. The accounting application must work with AI disabled.

427. The accounting application must work when OpenRouter is unavailable.

428. The accounting application must work when GPT-6 Luna is unavailable.

429. The accounting application must work when GPT-6.1 Sol is unavailable.

430. Manual transaction entry must remain available.

431. Manual classification must remain available.

432. Manual reconciliation must remain available.

433. Manual month closing must remain available.

434. Deterministic report generation must remain available.

435. AI usage should be measurable per church/workspace.

436. AI usage should be measurable per feature where practical.

437. The application must enforce Rp150,000 per church/workspace per month, with 70% warning, 90% conservation and optional AI stopped at 100%; accounting remains operational. **[Amended: Round 6F.]**

438. Hitting an AI spending cap must not disable accounting.

439. Optional AI features may degrade to manual workflows.

---

### AG. Security, Backup & Ownership

440. Tenant isolation is mandatory.

441. Sensitive financial data must be protected in storage.

442. Sensitive financial data must be protected in transit.

443. Authentication must be secure.

444. High-privilege sessions should support revocation.

445. Automated backups are MVP infrastructure.

446. Recovery capability is MVP infrastructure.

447. Backup restoration should be tested operationally.

448. Audit logging is MVP infrastructure.

449. Financial exports are MVP infrastructure.

450. The church must be able to export its ledger.

451. The church must be able to export reports.

452. The church must be able to export Mata Anggaran master information.

453. The church should be able to export Account/Fund information.

454. Evidence metadata and actual church-owned evidence files must be included in the full portable church export, with a relationship/checksum manifest. **[Extended: Round 5F.]**

455. The platform should not hold church data hostage.

---

### AH. Future Organizational Model

456. The long-term platform supports Jemaat organizational units.

457. The long-term platform supports Kolom.

458. The long-term platform supports BIPRA.

459. The long-term platform supports Komisi.

460. The long-term platform supports Panitia.

461. The long-term platform supports future/custom organizational units.

462. Organizational units should use a generic model rather than separate hardcoded tables wherever practical.

463. One person may hold multiple roles simultaneously.

464. One person uses one account rather than separate accounts per church role.

465. Role assignments must be scoped.

466. Role assignments may have start dates.

467. Role assignments may have end dates.

468. Role assignments have status.

469. Permissions derive from role + scope + delegation + workflow rules + active period.

470. BPMJ membership does not automatically grant unlimited access.

471. Specific BPMJ positions may have different permissions.

472. Technical administrator rights and church authority must remain separate.

---

### AI. Church Operator

473. A church may have one or more Church Operators.

474. Operator exists to reduce clerical work from officers.

475. Operator may assist member administration.

476. Operator may assist document administration.

477. Operator may assist service administration.

478. Operator may assist financial data preparation where authorized.

479. Operator may upload receipts/evidence.

480. Operator may prepare transaction drafts.

481. Operator does not automatically approve financial activity.

482. Operator does not automatically appoint leadership.

483. Operator does not automatically manage permissions.

484. Avoid generic unlimited SUPER_ADMIN for routine church operators.

485. Operator may act as an administrative delegate.

---

### AJ. Delegation

486. Delegation must identify the actual person acting.

487. Delegation must identify the acting role/context.

488. Delegation must identify organizational scope.

489. Delegation should identify on whose behalf the action occurs.

490. Delegation may have a start date.

491. Delegation may have an end date.

492. Temporary delegation should expire automatically.

493. Delegated activity must remain auditable.

494. Administrative delegation does not automatically transfer governance authority.

---

### AK. Fund Governance — Future Collaboration

495. Every Fund should have an owner.

496. Every Fund should have applicable financial governance rules.

497. Every Fund may identify an operational Treasurer/responsible officer.

498. Every Fund may define visibility rules.

499. Funding source determines the applicable approval workflow.

500. Church Fund governance differs from Kolom Fund governance.

501. Kolom Fund governance differs from BIPRA Fund governance.

502. Panitia Fund governance may be independent within authorized limits.

503. Church Treasurer may have consolidated oversight without approving all unit transactions.

504. Unit financial autonomy and church-level oversight can coexist.

---

### AL. Panitia / Temporary Groups

505. Panitia is modeled as a temporary organizational unit.

506. Panitia may have Ketua.

507. Panitia may have Sekretaris.

508. Panitia may have Bendahara.

509. Panitia may have members.

510. Panitia may have its own Fund.

511. Panitia may receive approved church allocations.

512. Panitia may receive donations/fundraising where allowed.

513. Panitia lifecycle should support PLANNING.

514. Panitia lifecycle should support ACTIVE.

515. Panitia lifecycle should support EVENT COMPLETED.

516. Panitia lifecycle should support FINANCIAL CLOSING.

517. Panitia lifecycle should support CLOSED.

518. Panitia lifecycle should support ARCHIVED.

519. A closed Panitia should not continue ordinary financial activity.

520. Remaining Panitia funds must have an approved disposition.

521. Remaining Panitia assets must have an approved owner/destination.

522. A Panitia should generate a final accountability report.

---

### AM. Member Self-Service — Future

523. Members should provide their own information wherever safe and practical.

524. Officers should not be forced to retype information members can safely supply.

525. Important member updates may require verification.

526. Member submission does not automatically become authoritative.

527. Self-service does not mean self-approval.

528. Penatua/Syamas should focus on supervision/approval rather than clerical entry.

529. Operators should handle exceptional administration where appropriate.

---

### AN. Household Model

530. Household/family is a first-class entity.

531. Individual persons remain separate records.

532. A person may belong to a household.

533. Household membership history should be preserved.

534. Household structure should support dependents.

535. A household may maintain a publication/display name.

536. Household publication identity must not automatically depend on current household head.

---

### AO. Birth

537. Birth is a formal lifecycle event.

538. Birth should not be handled as an ordinary profile edit.

539. Family/household may submit birth information where practical.

540. Birth may require verification before authoritative registration.

541. A newborn becomes an individual person record.

542. A newborn links to the appropriate household.

543. Birth may update applicable Kolom/demographic statistics.

544. Birth does not automatically imply baptism.

545. Birth does not automatically imply Sidi.

546. Birth does not automatically imply another sacramental status.

547. Later baptism/service workflows should reuse the existing child record.

548. Birth information must not automatically become public Warta information.

---

### AP. Death

549. Death is a formal lifecycle event.

550. A deceased member must not be deleted.

551. Member status should become DECEASED.

552. Historical household relationships remain preserved.

553. Historical roles remain preserved.

554. Historical financial transactions remain preserved.

555. Historical donations remain preserved.

556. Historical services remain preserved.

557. Historical audit records remain preserved.

558. Death confirmation should disable the deceased person's login.

559. Death confirmation should stop personal notifications.

560. Death should remove active approval authority.

561. Death should end/suspend active roles as appropriate.

562. Death should flag leadership vacancies.

563. Replacement leadership must not be assigned automatically.

564. Pending workflows assigned to a deceased approver should be rerouted appropriately.

565. Death of a Treasurer should trigger critical operational review.

566. Financial access must not automatically transfer to another person because of death.

567. Death may initiate funeral/pastoral workflows.

568. Sensitive cause-of-death/health information must not automatically become public.

---

### AQ. Kolom Movement

569. Movement between Kolom must preserve history.

570. Do not simply overwrite current Kolom without retaining prior assignment.

571. Internal transfer should have an effective date.

572. Member/household may initiate Kolom transfer where practical.

573. Transfer may require source/destination verification.

574. Individual transfer must be supported.

575. Whole-household transfer must be supported.

576. Selected-family-member transfer must be supported.

577. Leadership roles must not automatically move with the person.

578. Moving Penatua/Syamas should trigger leadership review.

579. Historical financial transactions remain associated with their original scope.

580. Future relevant transactions use the new scope after transfer effective date.

---

### AR. Inter-Church Transfers

581. Transfer to another GMIM church is distinct from internal Kolom movement.

582. Transfer to a non-GMIM church must be distinguishable.

583. Outgoing members are not deleted.

584. Transfer history must retain effective date.

585. Transfer history should retain destination where known.

586. External destination churches not using the platform must be supported.

587. Platform participation must not be required for recording an outgoing transfer.

588. If both churches use the platform, transfer information must be explicitly authorized.

589. One church must not gain unrestricted access to another church's database.

590. Private donations must not automatically transfer.

591. Pastoral notes must not automatically transfer.

592. Internal financial records must not automatically transfer.

593. Incoming GMIM transfer may support official transfer documentation.

594. Incoming non-GMIM membership may follow a separately configurable workflow.

595. Ecclesiastical eligibility rules should not be hardcoded without confirmed governance requirements.

596. New registration with no previous church is not a transfer.

597. Temporary relocation should be supported without forcing transfer-out.

598. Existing historical financial/audit context must not change after transfer.

---

### AS. Warta Jemaat

599. Warta Jemaat is a published compilation of authoritative system information.

600. Warta should not become the canonical source of underlying announcements or transactions.

601. Existing service/event information should be reused rather than retyped.

602. Existing financial information should be reused rather than retyped.

603. Existing attendance totals may feed Warta after finalization.

604. Announcements should exist independently from Warta.

605. Warta workflow should support DRAFT.

606. Warta workflow should support REVIEW.

607. Warta workflow should support APPROVED.

608. Warta workflow should support PUBLISHED.

609. Warta workflow should support ARCHIVED.

610. Regular members see published editions.

611. Historical Warta editions should remain available.

612. Published editions should not silently change afterward.

613. Corrections should use traceable revisions.

614. Warta should support PDF/printable output.

---

### AT. Publication Privacy & Masking

615. Internal identity and published identity are separate concepts.

616. Privacy masking never alters authoritative internal records.

617. Supported publication identities include Full Name.

618. Supported publication identities include Family Name.

619. Supported publication identities include Family + Kolom.

620. Supported publication identities include Kolom.

621. Supported publication identities include BIPRA.

622. Supported publication identities include BIPRA + Kolom.

623. Supported publication identities include Anonymous where applicable.

624. Member-requested eligible masking is mandatory for ordinary publication.

625. An editor cannot casually override active masking.

626. Publication templates cannot weaken a mandatory privacy request.

627. Full internal identity remains available only to appropriately authorized users.

628. Family masking may be used even when the underlying transaction belongs to an individual.

629. Family masking does not change transaction ownership internally.

630. Household-owned activity may use the household as the authoritative subject where applicable.

631. Financial transparency does not automatically require personal identity disclosure.

632. If Fund/Scope/Kolom/BIPRA/Family identification satisfies transparency, masking should remain.

633. Masking may be overridden only for a legitimate official/governance/legal/accountability necessity.

634. Ordinary editors cannot independently perform protected identity overrides.

635. Overrides require explicit reason.

636. Overrides require appropriate authority.

637. Overrides must be audited.

638. Affected members should be informed where appropriate.

639. Warta should normally honor masking.

640. Sensitive categories may require stronger privacy than the member’s general preference.

641. The system should warn when a masking choice still makes a person easily identifiable.

642. The member should be able to preview how their masking appears.

643. Historical publications snapshot the exact published identity.

644. Moving Kolom later must not rewrite historical publication identity.

645. Changing privacy preference later applies prospectively to future eligible publications.

646. Household may have a default publication preference.

647. An individual's stricter personal preference takes precedence over a less-private household default for their individual activity.

648. The publication principle is:
   **Mask by request; reveal by exception; audit every exception.**

---

### AU. Services — Future

649. Services/events may include Sunday worship.

650. Services/events may include Kolom worship.

651. Services/events may include BIPRA worship.

652. Services/events may include Baptism.

653. Services/events may include Sidi.

654. Services/events may include Marriage.

655. Services/events may include Funeral.

656. Services/events may include pastoral services.

657. Services/events may include Panitia/special events.

658. Service workflows should reuse existing member/household data.

659. Service data should be reusable in reports/Warta where permitted.

---

### AV. Attendance — Headcount Only

660. Attendance is aggregate headcount only.

661. The system must not identify which individual members attended.

662. The system must not store personal attendance history.

663. The system must not store individual absence records.

664. Attendance must not drive individual pastoral monitoring.

665. Attendance must not generate individual attendance scores.

666. Attendance must not be combined with donations to create member scores.

667. Every eligible Service/Event may maintain an aggregate attendance count.

668. Attendance belongs to a recognized Service/Event.

669. Normally the Service/Event should be approved/scheduled before attendance counting.

670. Authorized roles may create audited ad-hoc service records where necessary.

671. Authorized roles may enter retroactive attendance with audit trail.

672. Attendance may be total-only.

673. Attendance may optionally include non-identifying aggregate categories.

674. Aggregate categories must never link to specific persons.

675. Multiple authorized counters may contribute.

676. Counter contributions should remain distinguishable internally.

677. Multiple entrance/station subtotals may aggregate into one total.

678. Attendance counting should support realtime synchronization.

679. Offline counting should be supported where practical.

680. Offline synchronization must avoid duplicates.

681. Attendance lifecycle should support LIVE.

682. Attendance lifecycle should support REVIEW.

683. Attendance lifecycle should support FINALIZED.

684. Finalized attendance must not be casually editable.

685. Corrections require audit history.

686. Only finalized attendance may flow into Warta/reports.

687. Attendance permissions must be scoped.

688. Temporary per-service counter permission should be supported.

689. Counting permission does not automatically grant finalization permission.

690. Regular members do not need attendance-management access.

---

### AW. Notifications

691. The platform has a central Notification Engine.

692. Realtime in-app notifications are supported.

693. Push notifications are supported.

694. WhatsApp/SMS/email may be added later.

695. Quiet hours are not part of the current design.

696. Notifications must be scope-aware.

697. Notifications must be role-aware.

698. Only relevant users should receive action-required notifications.

699. Notifications should deep-link to the relevant task where possible.

700. Similar notifications should be aggregated where practical.

701. Important action notifications may retain delivery/read/action status.

702. Optional notification categories may be configurable.

703. Mandatory workflow notifications may remain visible in-app.

704. Urgent publishing ability should be restricted.

705. Notifications should disappear or resolve when the underlying work is completed where appropriate.

706. Treasurer notifications should emphasize operational issues rather than noise.

---

### AX. Audit

707. Every meaningful administrative action should be auditable.

708. Audit should record actual user.

709. Audit should record acting role/context.

710. Audit should record organizational scope.

711. Audit should record delegation where applicable.

712. Audit should record timestamp.

713. Audit should record previous value where applicable.

714. Audit should record new value where applicable.

715. Audit should record reason where required.

716. Audit history must not be casually editable.

717. AI involvement should be included in audit where materially relevant.

718. Reversals must retain links to original transactions.

719. Privacy overrides must be auditable.

720. Attendance corrections must be auditable.

721. External approvals must be distinguishable from in-app approvals in audit history.

---

### AY. General Data Integrity

722. Authoritative records should favor state change/history over destructive deletion.

723. Published records should favor revision/archive over destructive replacement.

724. Finalized transactions should favor reversal over editing.

725. Member records should use lifecycle status rather than deletion.

726. Panitia should use archive status rather than deletion after closure.

727. Historical context must remain attached to the role/scope that existed when an action occurred.

728. Later organizational changes must not rewrite historical audit context.

729. Multiple concurrent users must not silently overwrite one another’s changes.

730. Conflict detection should be supported for concurrently edited records.

---

### AZ. Reports & Search — Future

731. Reports should derive from authoritative data.

732. Reports may support Jemaat scope.

733. Reports may support Kolom scope.

734. Reports may support BIPRA scope.

735. Reports may support Panitia scope.

736. Reports may support Fund scope.

737. Reports may support Account scope.

738. Reports may support lifecycle statistics.

739. Reports may support aggregate attendance.

740. A generic custom-report builder is not required initially.

741. Global search should respect permissions.

742. Search must not expose unrelated confidential information.

---

### BA. Duplicate Member & Data Quality — Future

743. Potential duplicate members should be detectable.

744. Duplicate handling should support Compare.

745. Duplicate handling should support Merge.

746. Duplicate handling should support Not Same Person.

747. Merge must preserve financial history.

748. Merge must preserve roles.

749. Merge must preserve family relationships.

750. Merge must preserve service history.

751. Merge must preserve audit history.

752. Controlled master data should be used where it improves consistency without making entry unnecessarily difficult.

---

### BB. Final Product Principles

753. Treasurer-first is the immediate product strategy.

754. Progressive adoption is preferred over mandatory institution-wide rollout.

755. One shared financial engine should support future organizational growth.

756. Enter data once and reuse it everywhere authorized.

757. Account, Fund, Scope, and Mata Anggaran remain distinct.

758. Finalized financial history is immutable except through controlled reversals/adjustments.

759. Official financial calculations are deterministic.

760. AI assists interaction but never owns accounting truth.

761. Rules should resolve known situations before AI is called.

762. AI prepares; Treasurer confirms.

763. The application must work without AI.

764. Transparency and personal privacy must coexist.

765. Privacy masking is mandatory when requested and permitted.

766. Identity is revealed only through an authorized exception when genuinely necessary.

767. Authority and clerical work are separate concepts.

768. Self-service does not mean self-approval.

769. Role is always contextual and scoped.

770. Historical records must remain historically accurate.

771. The church owns its records and must be able to export them.

772. The MVP should optimize for simplicity and Treasurer time saved.

773. The primary operational success criterion is that month-end GMIM reporting can be generated reliably from daily transaction data.

774. The system should reduce the need for the Treasurer to reconstruct reports manually.

775. The next engineering specification should formalize database entities, transaction state machines, ledger behavior, closing logic, reconciliation logic, report mappings, permissions, and AI tool contracts before adding broader church features.

---

## 17. Continuation checklist and unresolved decisions

### 17.1 Remaining review and source material

The current design, all 775 rules and both full classification row exports are now incorporated. The supplied classification catalogs remove the previous missing-row blocker.

Policy decisions from rounds 1–6 are complete. Implementation still records the actual first production month and activation actor, creates the approved derived production masters, establishes needed church-specific thresholds/approvers/beneficiaries/formulas/due dates, and verifies deployed controls. Original GMIM report forms remain the external source gap: obtain page/cell/field/signature mappings and the exact accountability annex inventory. Source classification files do not supply those printable layouts.

### 17.2 Formalized design and remaining gates

The requested **Treasurer domain model + transaction state machines + exact semantic GMIM Report Pack mapping** is now formalized in section 19. It includes the glossary/schema, posting matrix, cash/recognition bridges, original/reversal period treatment, staging-only suspense proposal, approval/evidence guards, numbering, cutover, bank-match cardinality, close/snapshot algorithms and report controls.

Round 1–6 policy choices are approved. Remaining work is deployment/configuration and verification: publish the approved production derivation, record actual church authority/configuration values, supply/verify original report forms, implement recovery/export controls and connect the pinned models through eligible ZDR endpoints under the approved cap. See 19.14. No unprovided amount threshold, percentage, signature or cell address has been fabricated.

### 17.3 Verification examples for the continuation design

These are proposed acceptance scenarios, not a requirement to build a particular test framework:

1. A solo Treasurer can record, classify, reconcile, close and export without other church users or AI.
2. A draft and an uncommitted import do not change official balances.
3. A finalized amount cannot be edited; eligible OPEN-period reversal/replacement preserves history. After CLOSED, reject reopen and later-period correction with no changes to journals, vouchers or snapshots.
4. Cash-to-BNI transfer changes accounts but not total Pendapatan/Belanja.
5. Advance issue, partial settlement and return produce correct distinct cash, Belanja and outstanding positions.
6. The same statement imported twice creates no duplicate authoritative source lines.
7. Required unclassified items block close; configured evidence exceptions have explicit authority.
8. A closed report remains unchanged after a master/template version is updated.
9. Source snapshots remain exact strings, including `2.3.08.02`; derived production B113 imports/reports/exports use the authorized `2.3.02.02` and retain old/new provenance.
10. Hierarchy rollups count detail postings once.
11. External approval is visibly a recorded declaration, distinct from an in-app actor decision.
12. Cross-tenant/scope searches, files, exports and AI queries cannot reveal unauthorized records.
13. AI provider/quota/extraction/notification failures leave manual accounting usable.
14. Centralization observations do not double count a collection/remittance.
15. A restored backup can reproduce the ledger and official report snapshots.

### 17.4 Confirmed build priority

The current implementation order is:

1. Church workspace / tenant.
2. Authentication.
3. Cash and bank Accounts.
4. Funds.
5. Financial Scopes.
6. Mata Anggaran Pendapatan.
7. Mata Anggaran Belanja.
8. Ledger/transaction engine.
9. Income/Offering/Donation.
10. Expense/Reimbursement.
11. Cash Advance.
12. Internal Transfer.
13. Evidence.
14. External Approval.
15. Bank/Cash Reconciliation.
16. Monthly Closing.
17. GMIM Report Pack.
18. Audit.
19. AI Copilot using GPT-6 Luna and GPT-6.1 Sol through OpenRouter.
20. Progressive collaboration.
21. Wider church-management functionality after the Treasurer core is proven.

---

### 17.5 Product promise

**Aplikasi Bendahara Jemaat untuk pencatatan transaksi, Mata Anggaran GMIM, bukti keuangan, rekonsiliasi, dan pembuatan laporan keuangan GMIM secara otomatis.**

The broader multi-Jemaat platform remains the long-term architecture. V1 succeeds by making one Bendahara's finance operation easier, reliable, auditable and less dependent on manual spreadsheets.

## 18. Source register and fidelity

### 18.1 Supplied current design

Source: user-pasted **GMIM Treasurer-First Application — Design Specification & Rulebook — Current Source of Truth**, attachment `2f7b3e83-2c9a-40a6-9cac-05b9a4025567`, supplied 7 October 2026. Read through its 68 numbered design sections and final product positioning. Its last sentence (“The immediate product promise is simpler:”) has no following text; no missing ending was invented. The complete product promise is available in both supplied documents.

### 18.2 Supplied consolidated master

Source: user-pasted **GMIM Treasurer-First Application — Consolidated Master Rulebook**, attachment `5427d5ea-a3f3-4f80-9e1a-5496628eb785`, supplied 7 October 2026. All **775 rules in 54 source subsections A–BB** are embedded in section 16. Build priority and product promise are preserved in section 17. The 775-rule sequence has been checked for omissions and repeated numbers. The original handover verified source wording after restoring subsection heading levels. This edition retains all rule numbers and explicitly identifies the amendments to M082, M242, M391, M437 and M454; it does not claim the amended wording is the original source text.

### 18.3 Recovered conversation

Source conversation: **Church Management System**, ID `6ac4de41-ebec-83ec-a1f2-73f30ae5be05`. It supplied the handover request, acceptance of 20 controls, the controls proposal, updated Treasurer design/rules 293–342 and the GPT-6/OpenRouter AI feature review. No older history or original attachments were recovered. Appendix A/B retain the recovered rule/control numbering, with explicitly attributed D07 amendments to L321 and C02; original wording is preserved in the unchanged predecessor.

### 18.4 Source hashes

Hashes below identify the supplied text versions. The directly supplied classification-file hashes are recorded in section 18.6 and S Appendix B.

| Source | SHA-256 |
|---|---|
| Supplied design | `f9c7f6781b51c521e637bf6dc3369e4342c9678058b2a1337da19079d36e3faf` |
| Supplied 775-rule master | `03c39cb9e83dbec8e953e4ec337e85e2a9975b458c078226929d79b92c92b1e0` |

### 18.6 Direct classification source files — version 3.0

The user supplied both original named classification exports from Downloads. Both files were read without modification. Their contents are HTML-for-Excel tables with worksheet name `Sheet0`; source row 1 is the header, and source data row `n` occupies worksheet row `n + 1`. The exports have no additional sheets, formulas, hidden posting metadata or report data.

| Classification source | Format / range | SHA-256 |
|---|---|---|
| `ALFA OMEGA RINEGETAN TONDANO II - Mata Anggaran Pendapatan - 20261007.xls` | HTML-for-Excel, `Sheet0!A1:D132` | `de17693e72fc502bac0b70f89c607ac4ed979f037f37fd75e677f252c86f8fad` |
| `ALFA OMEGA RINEGETAN TONDANO II - Mata Anggaran Belanja - 20261007.xls` | HTML-for-Excel, `Sheet0!A1:D159` | `ed35818c3deb3d84363c14eac5869b32be81fb7c90c5b36c8d7508796e53409a` |

The full decoded text, string codes and source indentation are embedded in S Appendix B, so the catalogs can be reconstructed without access to the Downloads paths. File hashes refer to the original file bytes, while the embedded records contain decoded HTML cell text.

### 18.7 Policy amendment source and predecessor identity

Source: **Next Steps After Docs**, conversation `6ac62014-70cc-83ec-acb6-4134bf1b9bc1`; the final decision summary records approval of rounds 1–6 and the replacement D07. Retrieved recent turns include the rounds 4–6 proposals/approvals and final consolidated decisions; earlier round outcomes are carried by that consolidated decision record and the current user instruction. No claim is made that this reader recovered original report attachments or every older message. Policy adoption is complete; runtime activation/configuration and original printable forms remain separate.

Predecessor handover SHA-256: `df7cf8d531db8455ab53e94ea95ec377680c37343d46b35152c1ba9e3319b791`. Predecessor standalone SHA-256: `9e709f2d10964d559782baf9dccb26f3cb292fd0c18072f22e43c33d175598d7`. Both original files remain unchanged. The fenced source JSON objects (S Appendix B) remain byte-for-byte identical to the earlier editions. Active rule amendments: M082/M242/M391/M437/M454, L321, C02; E010/E018/E021/E025/E027/E045 and related report/workflow/status text are updated under the same approved baseline.

## 19. Formal Treasurer domain model, state machines and GMIM data mapping

Section 19 is the engineering contract. Its body was a near-verbatim copy of the companion engineering specification and was removed on 7 November 2026 so there is one editable copy. Read it in `GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md` (**S**). Section 19.n of earlier editions is S section n+1; references to "section 19.n" elsewhere in this document keep that meaning.

| Earlier P section | S section |
|---|---|
| 19.0 Status, scope and decision boundary | 1 |
| 19.1 Embedded domain glossary | 2 |
| 19.2 Logical domain records and relationships | 3 |
| 19.3 Posting and recognition contract | 4 |
| 19.4 Transaction and control state machines | 5 |
| 19.5 Opening, import, reconciliation and month-close algorithms | 6 |
| 19.6 Shared report population, measures and aggregation | 7 |
| 19.7 Semantic GMIM Report Pack mapping (F01–F14) | 8 |
| 19.8 Cross-report control matrix | 9 |
| 19.9 Worked posting and report example | 10 |
| 19.10 Layout adapter and exact-form register | 11 |
| 19.11 Service boundaries and human/AI interface | 12 |
| 19.12 Security, audit, backup/export | 13 |
| 19.13 Engineering rulebook E001–E051 | 14 |
| 19.14 Verification, gates and policy acceptance requirements | 15 |

If this document and S ever differ on an engineering rule, S governs; on product scope and deferrals, this document governs.

## Appendix A. Original AI governance rules 293–342

The following block is reproduced from the recovered conversation, retaining original numbers. Reference it as **Legacy AI rule N** (`L293…L342`), not Master rule N. The current consolidated master carries the same AI policy in its own numbering, especially rules 351–439. This appendix preserves prior wording and provenance; it is not a second global numbering sequence.

293. **OpenRouter is the AI gateway for the Treasurer MVP.**  
294. **Only GPT-6-family models are used in the currently approved AI configuration.**  
295. **GPT-6 Luna is the default model for routine Treasurer assistance.**  
296. **GPT-6.1 Sol is the escalation model for difficult or low-confidence cases.**  
297. **AI provider/model calls must be isolated behind an internal application abstraction.**  
298. **Accounting logic must never depend directly on a specific AI provider endpoint.**  
299. **Deterministic business rules should resolve a task before AI is invoked whenever practical.**  
300. **Deterministic classification mappings take precedence over generative classification.**  
301. **GPT-6 Luna should receive narrowed Mata Anggaran candidates whenever practical rather than the entire classification catalog.**  
302. **Low-confidence or genuinely complex Luna results may escalate to GPT-6.1 Sol.**  
303. **AI-generated financial classifications require Treasurer confirmation before becoming authoritative.**  
304. **AI may extract information from receipts, invoices, bank proofs and other permitted documents.**  
305. **Extracted data is treated as a draft until confirmed or deterministically verified.**  
306. **AI may prefill transaction forms but may not silently post transactions.**  
307. **AI may interpret natural-language transaction descriptions and create transaction drafts.**  
308. **AI may suggest Mata Anggaran Pendapatan and Belanja classifications.**  
309. **AI may suggest splitting a transaction across multiple Mata Anggaran lines.**  
310. **AI may suggest likely bank/cash reconciliation matches.**  
311. **AI may flag potential duplicate transactions or evidence.**  
312. **AI may identify missing evidence and inconsistent transaction/document information.**  
313. **AI may identify unusual amounts or probable classification anomalies.**  
314. **AI warnings are informational and must not imply wrongdoing automatically.**  
315. **AI may summarize unresolved month-end issues.**  
316. **AI may explain GMIM reports but must not determine authoritative report totals.**  
317. **Buku Kas, Mata Anggaran aggregation, balances and reconciliation arithmetic must be generated deterministically from ledger data.**  
318. **AI may answer natural-language questions only against financial data the current user is authorized to access.**  
319. **AI may assist legacy Excel/data migration but imported records require validation before becoming authoritative.**  
320. **AI may search financial evidence and documents within authorized scope.**  
321. **AI may suggest eligible OPEN-period corrections but cannot silently modify finalized transactions or provide a CLOSED-period accounting-correction path in MVP.** **[Amended: D07 / Round 6.]**  
322. **AI may draft Treasurer narrative summaries using ledger-derived numbers.**  
323. **AI cannot approve expenditure.**  
324. **AI cannot approve its own classifications or suggestions.**  
325. **AI cannot bypass maker/checker or self-approval restrictions.**  
326. **AI cannot finalize financial transactions without a human-authorized workflow.**  
327. **AI cannot close an accounting period.**  
328. **AI cannot alter a closed period.**  
329. **AI cannot delete or silently overwrite finalized financial records.**  
330. **AI cannot invent receipts, approval evidence or other accounting documentation.**  
331. **AI cannot bypass financial/governance permissions.**  
332. **AI cannot silently alter historical GMIM reports.**  
333. **AI involvement in material financial decisions must be auditable where applicable.**  
334. **The audit trail should record model, suggestion, confidence, confirmation/override and final accepted value when relevant.**  
335. **A Treasurer override of an AI suggestion is valid and does not require explaining why unless another workflow requires a reason.**  
336. **The application must remain fully usable when AI is disabled or unavailable.**  
337. **AI failure must never prevent access to authoritative accounting records.**  
338. **AI usage limits must not block ordinary manual accounting operations.**  
339. **Interactive Treasurer AI should use appropriate low-latency OpenRouter routes.**  
340. **Bulk/noninteractive operations may use cheaper supported processing routes when suitable.**  
341. **AI cost should be measurable per church/workspace and per capability.**  
342. **The system should support an AI spending limit without disabling core accounting.**

## Appendix B. The 20 accepted tightened accounting/control rules

These retain the recovered accepted controls and local numbering 1–20. C02 is explicitly amended for the later approved D07; its original text remains in the unchanged predecessor. For this handover, control 1 is also called C01, control 2 C02, and so on; no original global numbers are invented.

1. **Define one authoritative transaction lifecycle.** Every financial record should move through explicit states such as `DRAFT → REVIEWED → FINALIZED
FINALIZED → REVERSED only while all affected periods remain OPEN`. Reports, balances, Buku Kas, and Mata Anggaran realization should use **FINALIZED transactions only**. Drafts must never affect official balances.

2. **Make finalized transactions immutable.** No editing an Rp1,250,000 finalized expense into Rp1,150,000. While every affected period is OPEN, use `reverse original → create corrected transaction`; once CLOSED, no correction/reopen/later-period mechanism is available in MVP. The rule applies to solo Treasurers too. **[Amended C02: Round 2 / D07.]**

3. **Introduce “Unclassified / Suspense” safely.** Sometimes the Treasurer knows money moved but does not yet know the correct Mata Anggaran. Allow capture without forcing a guess:
   ```text
   Incoming transfer Rp2,500,000
   Classification: NEEDS REVIEW
   ```
   It can appear in the reconciliation workspace, but the month cannot close while required classifications remain unresolved.

4. **Lock the distinction between Account, Fund, Scope, and Mata Anggaran.** These should never be interchangeable:
   ```text
   Account        → where money physically is
                    Cash / BNI / BRI

   Fund           → which pool of money owns it
                    General / Diakonia / Panitia

   Scope          → which organizational unit
                    Jemaat / Kolom / BIPRA / Panitia

   Mata Anggaran  → what the income/expense is for
   ```
   This is probably the most important data-model rule after the ledger itself.

5. **Define voucher/document numbering early.** For example:
   ```text
   BKM-2026-000123   Bukti Kas Masuk
   BKK-2026-000087   Bukti Kas Keluar
   TRF-2026-000014   Transfer
   UM-2026-000011    Uang Muka
   ```
   Numbers should be generated by the system, unique within the church, and never silently reused after cancellation.

6. **Tighten external approval semantics.** Because the MVP may run without BPMJ adoption, an external approval should mean:
   > “The Treasurer recorded that approval occurred outside the system.”
   
   It must **not** appear as “Approved by BPMJ in the app.” Store the declared approver, date, method, notes, and evidence if available. Later, true in-app approval can coexist with this.

7. **Define monthly closing as a real control point.** Before closing, require deterministic checks such as cash/bank reconciliation, no unresolved required Mata Anggaran, no invalid transaction totals, and required evidence status. After close, that period becomes locked. AI can identify problems but cannot close it.

8. **Snapshot every official report.** When October 2026 is closed and the GMIM Report Pack is generated, preserve the exact classification version, transaction set, totals, report-template version, and generation timestamp. A future label/code/template change must not alter the historical October report.

9. **Version both report templates and Mata Anggaran.** You already have Pendapatan and Belanja versioning; apply the same rule to the printable report format:
   ```text
   Mata Anggaran version: Alfa Omega 2026
   Report template: GMIM Pack v1.2
   ```
   That will be essential when another Jemaat gives you a slightly different Excel/form.

10. **Define opening balances explicitly.** The first day a Treasurer adopts the app, they need:
   ```text
   Effective date
   Cash balance
   Bank balances
   Fund balances
   Outstanding cash advances
   ```
   These become controlled opening entries—not fake income transactions.

11. **Make reconciliation line-based and idempotent.** One bank statement line can only be matched according to defined rules, and re-importing the same statement must not duplicate it. Import fingerprints/reference IDs should prevent accidental duplicates.

12. **Cash advances need their own accounting state.** `OPEN → PARTIALLY SETTLED → SETTLED`. Spending from an advance should classify into Belanja only when settled appropriately; unused money returned must be recorded separately. Do not model an advance itself as final expense.

13. **Evidence status should be structured.** Avoid just `has_attachment=true`. Use something like:
   ```text
   Not required
   Required – missing
   Uploaded
   Verified
   Exception accepted
   ```
   That makes month-end checks and the Daftar Bukti Kas much better.

14. **The GMIM Report Pack needs a deterministic reconciliation invariant.** At minimum:
   ```text
   Opening balance
   + finalized Pendapatan
   - finalized Belanja
   ± valid transfers/adjustments
   = closing book balance
   ```
   And that must reconcile against physical cash + bank position according to the account model. AI never supplies these numbers.

15. **Keep transfers out of Pendapatan/Belanja unless accounting rules explicitly require otherwise.** Moving Rp10m from Cash to BNI should not create Rp10m income and Rp10m expense. Likewise, internal fund/account transfers need explicit treatment to prevent inflated reports.

16. **Centralization / settlement needs exact semantics.** Especially for GMIM flows, define whether a record is `amount collected`, `amount payable`, `amount remitted`, or `amount received`. Otherwise the same money can accidentally appear twice.

17. **Make imports staging-first.** Excel/bank imports should land in an import workspace:
   ```text
   Imported
      ↓
   Validate
      ↓
   Duplicate check
      ↓
   Classification review
      ↓
   Commit to ledger
   ```
   Never let an uploaded spreadsheet immediately become authoritative ledger data.

18. **Keep AI confidence separate from accounting confidence.** A Luna confidence score is not accounting evidence. The system should store:
   ```text
   AI suggestion: Listrik
   AI confidence: 93%
   Treasurer confirmed: Yes
   ```
   Once confirmed, the authoritative value is the Treasurer's selection—not the model's confidence.

19. **Design failure behavior now.** If OpenRouter, GPT-6 Luna, GPT-6.1 Sol, push notifications, or document extraction are unavailable, the Treasurer must still be able to record transactions, classify manually, reconcile, close the month, and generate reports.

20. **Security/backups/export should be MVP infrastructure, not future features.** Encrypt sensitive files, isolate each Jemaat tenant, maintain automated backups, log sensitive actions, revoke sessions, and let the church export its ledger/reports/evidence metadata. Financial data should never be hostage to the application.

## Appendix C. Full Mata Anggaran source catalogs

The full readable catalog tables formerly in C.1–C.2 were removed on 7 November 2026. The machine-readable catalogs in Appendix B of the companion engineering specification `GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md` carry every source row, exact code string, raw label with indentation, source cells and source-derived parent map. Source `postable` stays `null` there. Approved production eligibility is defined in 0.5 and the approved production-master derivation, not in the source snapshots. Former C.3 and C.4, which only pointed to section 19, were removed with them.

### C.5 Fidelity notes and unresolved source tensions

- Master rule 95 says required unresolved classifications **may** block close, while the supplied design and accepted Control C03 say unresolved **required** classifications prevent closing. Preserve the stricter accepted close rule: required unresolved classifications block close; optional classification policy can remain configurable. The original wording remains in the unchanged predecessor; approved source-rule amendments are identified in this edition.
- “FINALIZED only” alongside a `REVERSED` terminal state requires explicit posted-history semantics; original and compensating entries cannot simply disappear from historical reporting.
- Advance issue is not final Belanja, so the high-level cash/balance equation needs explicit outstanding-advance and settlement bridges.
- Classification code/label text is now verified directly; source indentation supplies a draft hierarchy but does not prove actual posting eligibility. Preserve the source snapshot row-113 relationship/code, while applying the explicitly authorized production correction `2.3.08.02` → `2.3.02.02` under `2.3.02.00`; production postability follows the approved defaults.

## Appendix D. Machine-readable source snapshots

The fenced JSON catalogs (Pendapatan 131 rows, Belanja 158 rows, with `name_raw`, source cells and explicit draft mappings) are kept once, in Appendix B of the companion engineering specification `GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md`. They were byte-identical to the copies formerly embedded here; the duplicate was removed on 7 November 2026.

**Continuation instruction:** Preserve the unchanged original artifacts, all source records/hashes and rule identifiers. Implement the approved rounds 1–6 baseline, record actual deployment/church values and obtain original report-form bindings. Further revisions use new versioned artifacts. Source null flags/unset dates remain provenance; approved production definitions and actual publication metadata are separate.
