# Domain model → repository contracts (read-only analysis)

Sources: **S** = `docs/design/GMIM_Treasurer_Domain_Model_..._v2.0.md`, **P-plan** = `docs/design/platform-module-plan-2026-11-17.md`, **R** = `docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md`, **MD** = `docs/build/mock-data.md`. Anything marked *(inferred)* or *(proposed)* is my own reading and is not stated in the files.

---

## 1. Entities per module

### Core (P-plan §5; S §3)
| Entity | Key fields / relations | Ref |
|---|---|---|
| Workspace | church identity, timezone, IDR, fiscal config (1 Jan start, RD13), active policy-version IDs | S §3, P-plan §5 |
| Person | name, status `UNCONFIRMED/ACTIVE/DECEASED/…`, optional login link | P-plan §5 |
| Party *(Finance-owned, but every module links to it)* | display identity, optional member (Person) link, minimal contact. Ledger rows and snapshots hold only the Party ID (RD11). Deletion removes the link and keeps the name (DL13) | S §3 |
| Scope (org unit) | type Jemaat/Kolom/BIPRA/Komisi/Panitia/custom, name, parent, effective dates, status. The hierarchy has no cycles | S §3, P-plan §5 |
| RoleAssignment | person, role, scope, start, end, status. A post with no holder is **vacant** | P-plan §5 |
| Delegation | actor, acting role, scope, on behalf of, start, end. It expires automatically | P-plan §5 |
| VacancyCover | Operator acts in a vacant post. Every action is audited as "acting for vacant post" | DL12, P-plan §5/§6.1 |
| AuthorityGrant | person, capability (Treasurer or Secretary), church authorization record, verifying reviewer, grant/revoke actor and time | S §3, DL10 |
| Capability check | `may(person, capability, scope, at)`, counting period, ancestry, delegation, vacancy and module status | P-plan §5, §11 |
| ModuleRegistry | module, status `OFF/ACTIVE/READ_ONLY`, who switched it, config version | P-plan §5, §8 |
| AuditRecord | actor, acting role, scope, delegation/cover, before/after, reason, UTC time. Append-only | S §3 |
| File | one private store, with an access decision per linked record | P-plan §5 |
| Notification | one outbox and inbox. Push goes through FCM | P-plan §5 |
| Export | church-owned export covering all modules | P-plan §5, S §13 |

### Finance (S §3)
| Entity | Key fields / relations |
|---|---|
| PhysicalAccount | name, type `CASH/BANK`, institution/ref, active dates. A used Account is never deleted. "Operated by unit" is still an open EC09 question (DL32) |
| Fund | name, owner Scope, restriction, governance-policy ref, active dates |
| MasterVersion / MasterRow | kind `PENDAPATAN/BELANJA`, status, effective interval. A row has `(version_id,row_id)`, code, name, parent, level/order, `postable`, `allowed_effect_kinds` ECONOMIC/TRANSIT/BOTH/unset (RD10) |
| Transaction | type, effective_date, description, revision, amount, creator, review metadata, policy refs, voucher, original/correction link |
| TransactionAllocation | ordinal, amount, Fund, activity Scope, Party, master row/version, advance/transit case link |
| PostedBatch / JournalLeg | batch_id, sequence, effective date. Legs carry target (`LIQUID(acct)`, `ADVANCE(case)`, `TRANSIT_PAYABLE(case)`, `INCOME`, `EXPENSE`, `OPENING_EQUITY`, `CONTROLLED_ADJUSTMENT`), Dr/Cr, Fund and Scope. Each batch balances overall and per Fund. Voucher series are ordinary / `OPN` / `ADJ` (S §3, §4.1) |
| CashMovementGroup | links an original posting and its correction to one real bank movement |
| ApprovalRecord | mode, revision digest, declared vs recorded-by, role/scope, date, method, evidence |
| EvidenceItem | file ref, checksum, uploader, link to transaction or settlement, append-only decisions |
| AdvanceCase / TransitCase | recipient or beneficiary, Fund (one Fund per case, EC06), issue/collection links, due date. Outstanding is **derived** |
| ImportBatch / StagedRow | source hash, raw and interpreted fields, validation, duplicate flag, idempotency key, committed ID |
| StatementLine, ReconciliationSession / MatchGroup, CashCount | observations, matching allocations, timing items. An observed zero must be explicit |
| OpeningBatch | cutover date, Account/Fund balances, opening advances and transit |
| Period | month boundaries, status, close actor/time, confirmation, cutoff, snapshot ID |
| ReportSnapshot, ReportTemplate/LayoutMapping | frozen IDs, versions, datasets and hashes. The template is versioned |
| ReadinessAttestation, CloseIncident | per Fund per period (RD12). A close incident never mutates closed data (RD08) |
| AIProposal | input digest, candidates, result, human disposition, cost |
| *Reimbursement claim* | **Not a record in S §3.** S §4.2 says only that "a reviewed personal claim can become a payment draft". MD models it as `Kasus.penggantianBiaya` (MD §2.10). It needs a claim entity *(inferred)* |

### Secretariat (P-plan §6, §6.1; R §14.6–14.7; S §13)
- **ChurchDocument**: kind (decision/circular, minutes, rule/liturgy, member letter, asset handover), audience (all members / officers / one unit), revisions. A correction is a new revision (rule 723).
- **Announcement**: audience and an optional end date (DL14).
- **WartaEdition**: sources (announcements, services, attendance, finance excerpt bound to a closed snapshot), masking, revisions/ralat.
- **LetterRequest**: member or household, letter type (surat keterangan, atestasi), channel (app or office), issued signed copy.
- **IdentityReveal**: Secretary only, with reason and audit (DL5).

### Membership (P-plan §6.1; DL6–8, 13, 18, 28)
- **MemberProfile** (extends Person): birth date, sex, marital status, Kolom history. BIPRA is derived (DL28) and the Penatua can override it.
- **Household**: representative and members.
- **MembershipApplication**, **ConsentRecord** (text version, date, channel app/paper, scanned form, given by), **LifeEvent** (birth, Baptism, Sidi, Marriage, death, Kolom move, transfer; may reference a Service), **DataChangeRequest**, **MemberImportRow** (paper book), **MaskingPreference**, **DeletionRequest** and **DeletionRecord**, **DuplicateCase**.

### Collaboration (P-plan §6, §12 track C)
- **Panitia**: a Scope with officers, SK document and its own Fund.
- **Service**: kind, time, audience, place, approver.
- **AttendanceCount**: per-post counts, counters, corrections that keep the original value.
- **FundRequest** (IN_APP approval).
- **ApproverTable**: one row per unit type (DL29), with a threshold below which no approval is needed.
- Unit finance reuses the Finance entities, filtered by Fund and Account.

---

## 2. State machines

| Object | States / transitions | Ref |
|---|---|---|
| Transaction | `DRAFT→REVIEWED→FINALIZED`. `REVIEWED→DRAFT` on a material edit or a redate. `DRAFT/REVIEWED→CANCELLED`. `FINALIZED→REVERSED` is **derived** from a posted reversal link, allowed only while every affected period is OPEN. A solo Treasurer may review and finalize in one action | S §5.1 |
| Approval | `NOT_REQUIRED`. `EXTERNAL`: `MISSING→RECORDED`, can be superseded. `IN_APP`: `PENDING→APPROVED/REJECTED`, and a material change resets it to PENDING | S §5.2 |
| Evidence | `NOT_REQUIRED / REQUIRED_MISSING / UPLOADED / VERIFIED / EXCEPTION_ACCEPTED`, a projection of append-only decisions. Failed or quarantined files leave a trace | S §5.3 |
| AdvanceCase | derived `OPEN / PARTIALLY_SETTLED / SETTLED`, plus a separate overdue flag | S §5.4 |
| TransitCase | derived `OPEN / PARTIALLY_REMITTED / SETTLED` | S §5.4 |
| Master version | `DRAFT→REVIEWED→PUBLISHED` | S §5.5 |
| Import batch | `STAGED→VALIDATED→REVIEWED→COMMITTED`. Rejected rows are kept with a disposition | S §5.5 |
| Statement matching | derived `UNMATCHED / PARTIAL / MATCHED` | S §5.5 |
| Reconciliation session | `OPEN→REVIEWED→CONFIRMED`. A book change invalidates the confirmation | S §5.5 |
| Readiness attestation | `CURRENT→INVALIDATED` (or waived) | S §5.5 |
| Period | `OPEN→CLOSED`, irreversible, in chronological order | S §5.5, §6.4 |
| Report data | `PREVIEW→SNAPSHOT`. File generation: `QUEUED→GENERATED/FAILED` | S §5.5 |
| Warta | `DRAFT→REVIEW→APPROVED→PUBLISHED→ARCHIVED`. The Secretary performs every step | R §14.7, S §13 |
| Announcement | `DRAFT→PUBLISHED→ARCHIVED`, auto-archived at the end date | DL14 |
| Church document | revisions only, with no approval step (signed scan) *(proposed)* | P-plan §6.1 |
| Membership application / life event | `SUBMITTED→VERIFIED`, or returned, or declined | P-plan §6.1 |
| Person | `UNCONFIRMED→ACTIVE`, `→DECEASED`. Deletion removes the profile | P-plan §5, §6.1 |
| Panitia | `PLANNING→ACTIVE→EVENT COMPLETED→FINANCIAL CLOSING→CLOSED→ARCHIVED` | R §14.4, DL27 |
| Attendance | `LIVE→REVIEW→FINALIZED`, with corrections recorded | R §14.9 |
| Module | `OFF / ACTIVE / READ_ONLY` | P-plan §8 |
| Service, FundRequest | **No state machine is written in the specs.** MD shows the labels: Ibadah Draf → approved → Ditutup (MD §2.20); PermintaanDana Diajukan → approved / refused / amount changed (MD §2.20) *(inferred from boards)* |

Labels in MD: `StatusTransaksi {draf, dibukukan, dibalik, dibatalkan}` (MD §1) **has no REVIEWED state**. The Pemeriksa/WebPemeriksa boards show it as "checked by Pnt. Jefry Wowor" (MD §2.15), so the enum must gain `diperiksa` *(inferred)*.

---

## 3. Proposed repository interfaces *(proposed; operations from S §5.1, §12 and P-plan §5)*

Every command takes an `actor` context (person, acting role, scope, delegation or vacancy cover). Every command writes audit and notifications inside the repository.

**Core**
- `SessionRepository`: personas(), signIn(persona), signOut(), current().
- `WorkspaceRepository`: workspace(), modules(), setModuleStatus(m, s).
- `PeopleRepository`: person(id), search(q), parties(), linkPartyToPerson(), unlinkParty().
- `OrgRepository`: scopes(type?), scope(id), createScope().
- `RoleRepository`: assignments(scope?/person?), posts() including vacancy, assign(), end(), delegations(), delegate(), grants(), recordGrant(), revokeGrant(), `can(actor, capability, scope)`.
- `AuditRepository`: list(filter). Records are appended by the other repositories.
- `NotificationRepository`: inbox(person), watch, markRead(), preferences().
- `FileRepository`: attach(record, file), files(record).
- `ExportRepository`: build() *(a manifest only in the demo)*.

**Finance**
- `AccountRepository`: accounts(), balance(account, at), balanceByFund(account), deactivate().
- `FundRepository`: funds(), fund(id), fundBalance(fund).
- `MasterRepository`: versions(kind), rows(version, kind), pickerRows(kind, date), createDraftVersion(), editRow(), setAllowedEffect(), review(), publish().
- `TransactionRepository`:
  - Queries: list(period, filter), get(id), drafts(period), voucherSeries(period, series).
  - Commands: createDraft, editDraft(expectedRevision), review, finalize(id, expectedRevision, idempotencyKey) returning voucher, cancel(reason), redate(newDate, reason), reverse(id, reason), correct(id, replacement), split(allocations).
- `ApprovalRepository`: forTransaction(), recordExternal(), supersede().
- `EvidenceRepository`: forTransaction(), list(period, status), upload(), verify(), acceptException(reason).
- `CaseRepository`: advances(), transits(), claims(), case(id) with derived outstanding. Commands: issueAdvance, settle(spending), returnUnused, collectTransit, remit, recordClaim, payClaim. Each command creates and finalizes a linked transaction.
- `ImportRepository`: batches(), stage(file), validate(), reviewRows(selection), commit().
- `ReconciliationRepository`: session(account, period), statementLines(), importStatement(), match(lines, txns), markTimingItem(), createTxnFromLine(), confirm(), cashCounts(account), recordCashCount(denominations, counters).
- `PeriodRepository`: periods(), blockers(period), attestations(period), attest(fund), waive(fund, reason), close(period, confirmation) returning a snapshot, incidents(), recordIncident().
- `OpeningRepository`: opening(), recordOpening(accountFundSplits, cases).
- `ReportRepository`: preview(period, perimeter), snapshot(id), dataset(snapshot, F01…F14), restricted(snapshot, fund), templates(), acceptTemplate().
- `AiRepository`: propose(kind, input) returning a fixed proposal, budget(), dispose(proposal, accepted/edited/rejected).

**Secretariat**
- `DocumentRepository`: list(audience?), publish(), revise().
- `AnnouncementRepository`: list(), draft(), publish(), archive().
- `WartaRepository`: editions(), draft(edition), submit(), approve(), publish(), ralat(), revealIdentity(reason).
- `LetterRepository`: requests(), request(), recordAtOffice(), issue().

**Membership**
- `MemberRepository`: members(kolom?), member(id), households(), household(id), bipra(person), overrideBipra().
- `VerificationRepository`: queue(scope) covering applications, life events, data changes and household confirmations; verify(), returnForChanges(), decline(). Routing follows role assignments and vacancy.
- `ApplicationRepository`: apply(withConsent), submitLifeEvent(), submitDataChange(), confirmHousehold().
- `ConsentRepository`: record(), withdraw(), requestDeletion(), executeDeletion().
- `MemberImportRepository`: stage(rows), resolveDuplicate(), commit().
- `MaskingRepository`: preference(person), set().

**Collaboration**
- `PanitiaRepository`: list(), create(sk), advanceStage(), approveLeftover().
- `ServiceRepository`: list(), draft(), approve(), close().
- `AttendanceRepository`: count(service), assignCounter(), increment(post), review(), finalize(), correct(reason).
- `FundRequestRepository`: list(), submit(), approve(), refuse(reason), changeAmount().
- `ApproverTableRepository`: table(), set().
- Unit finance reuses `TransactionRepository` and `PeriodRepository` with Fund/Account guards (DL26, DL32) plus `clearUnitBlocker(cancel/redate/confirmRecon, reason)` (DL33).

---

## 4. What the boards exercise (cross-check against MD)

| Entity / operation | Boards (MD section) | Exercised? |
|---|---|---|
| Transaction draft → finalize, voucher BKU-2026-0147 | Catat (Main/TabCatat/WebCatat), §2.9 | Yes |
| Review by a second checker (maker/checker) | Pemeriksa, WebPemeriksa, §2.15 | Yes |
| Cancel, conflicting edit, redate | WebTransaksi (dibatalkan), Draf/WebDraf, §2.9, §2.15 | Yes |
| Split allocations | Bagi/WebBagi, §2.15. Multi-part offering: Persembahan, §2.13 | Yes |
| Reverse / correct (classification) | Koreksi/WebKoreksi, §2.15. Lainnya riwayat "pembalikan BKU-2026-0144", §2.21 | Yes |
| Account transfer / Fund ownership transfer | Setoran/Pindah (§2.7, 2.11). AlihPeruntukan (§2.4, row 9 of §3) | Yes |
| External approval declare / supersede | Persetujuan/WebPersetujuan, §2.15 | Yes |
| Evidence upload / verify / exception (+ failed, quarantined) | Dokumen/WebDokumen §2.14, Ekspor §2.9 | Yes |
| Advance / transit / claim cases, overdue | Kewajiban, WebKasus, WebKewajiban, KasusBaru, §2.10 | Yes |
| Import STAGED…COMMITTED, duplicates, refused row | Impor/WebImpor, §2.9 | Yes |
| Bank reconciliation, match, timing item, txn from line, confirm | TutupBuku, WebRekonsiliasi, RekonIsi, §2.11 | Yes |
| Cash count | HitungKas/WebHitungKas, §2.12 | Yes |
| Opening / cutover (OPN) | Awal/WebAwal, §2.4 | Yes |
| Period close with blockers, snapshot SNP-2026-10-01 | TutupBuku/WebTutupBuku, §2.6, §2.8, §2.11 | Yes |
| Readiness attestation | Kesiapan (Jefry, Rivo), §2.2 | Yes |
| Close incident | Kejadian, §2.15 | Yes |
| Reports F01–F14, restricted view | Laporan, WebLaporan, A4*, WebExcel, Terbatas, §2.8 | Yes. **They are currently const strings** (MD §0) |
| Master version draft → publish, allowed effect | MataAnggaran/WebMataAnggaran, §2.5 | Yes |
| Refund / donor return | Pengembalian, AlurPengembalian, §2.15 | Yes, **but S §4.2 RD04 says these "are not supported postings"** until the event table is approved |
| AI proposals and budget | AIFoto, BantuanAI, AIMataAnggaran, AIBulan, WebAI, §2.15, §2.1 | Yes |
| Unit finance, Bendahara clears a unit blocker | KeuanganUnit, AlurUnit, SelesaikanUnit, §2.11, §3 row 14 | Yes |
| Posts, vacancy cover, delegation, authority grant and handover | Penugasan, AlurPenugasan, JabatanKosong, Bendahara/WebSerahTerima, WebVerifikasi, §2.2–2.3, §4.2 | Yes |
| Modules, approver table | Modul, PemberiPersetujuan, §2.17 | Yes |
| Notifications / inbox / per-role home | §2.16 | Yes |
| Membership: import, household confirm, application, life events, BIPRA, masking, deletion, duplicates, recovery | ImporBuku, KonfirmasiKeluarga, PermohonanAnggota, AntreanVerifikasi, Peristiwa, TampilanNama, CabutIzin, DataGanda, AlurPulihkan, §2.18 | Yes |
| Secretariat: documents, announcements, Warta, reveal identity, letters | §2.19 | Yes |
| Panitia, services, attendance, fund requests | §2.20 | Yes |
| Sessions / account | §2.21, §2.18 | Yes |
| **Not visible on any board** | JournalLeg, posting_sequence, CashMovementGroup, idempotency keys, ReportSnapshot hashes, LayoutMapping bindings (only "Bawaan Palakat v1" format acceptance, §2.1), controlled ADJ postings (series only listed), multi-version master reversal | No *(inferred from MD contents)* |

**Model gaps in MD that block shared state** *(inferred)*:
- MD §1 stores printed strings where the contract needs IDs and typed values: `Transaksi.kasBank` is "as printed", statuses and dates are strings, `Kasus.awalCatatan`, and `ItemKotak.ke` is a board stem.
- MD has no Party separate from `Orang`. Suppliers and beneficiaries ("TOKO SINAR", "Sinode") are bare strings.
- `Lingkup` has no link to `Unit`.
- Per MD §0 the reports are const tables "not computed totals". Shared state needs them computed.

---

## 5. What the demo should simplify while keeping the contract shape *(proposed)*

Keep the full method signatures in §3, including `expectedRevision`, `idempotencyKey`, `actor` and `reason`, so a Supabase implementation drops in later. Implement them in memory in a simple way.

1. **Posting.** Keep the transaction types of S §4.2 and a per-type sign table: Account delta, Fund delta, I/E/Tin/Tout, advance/transit case delta. Boards need Account balances (Beranda §2.9), balances by Fund (AlihPeruntukan §2.4), F01 lines (§2.8) and case remainders (§2.10), so this much math is required. Skip persisted JournalLegs, `posting_sequence` cutoffs, CashMovementGroup and per-Fund balance assertions. Keep one debug assert that the Account totals equal the sum of Fund totals.
2. **Vouchers.** One counter per series per year, continuing from the seed's highest number (BKU-2026-0151+). The board-level number reuse in MD §3 rows 6–9 disappears.
3. **Reports.** Compute F01, F02, F03, F05, F07, F10 and F12 from state for any month. Freeze the close snapshot as a deep copy of those datasets (no hashes). F04, F06, F08, F09, F11, F13 and F14 can come from the same sums, or stay seed-only for September and October where the board strings are richer *(judgment call for the planner)*. Only the 2.5 sample rows of the master exist, so F05/F07 rollups run over that subset.
4. **Close.** Evaluate the blocker list in S §6.4 against state: earlier period closed, reconciliation confirmed per Account, classification, required approval and evidence, drafts and staged rows in the period, attestations. Skip locking, cutoffs and render queues. File generation is GENERATED immediately.
5. **Reconciliation.** Matching is exact-amount and human-confirmed. "Suggest" returns the fixed board pairs (m1↔t1+t2, m2↔t3, §2.11). No tolerance logic is needed.
6. **AI.** Fixed proposals per input, as the boards show (§2.15), plus a budget counter. Never call the network.
7. **Capabilities.** A static role → capability table plus scope match, vacancy cover and delegation date checks. Keep `can()` as the single gate so it maps to RLS later.
8. **Evidence and files.** Status transitions only. A file is a name plus a bundled sample image. No checksum is computed.
9. **Approval.** External declaration only, plus the FundRequest flow for IN_APP. No quorum.
10. **Membership.** BIPRA is computed from birth date, sex and marital status using one fixed set of church age limits. Deletion runs the DL13 keep/delete lists in memory.
11. **Time.** All seed dates are offsets from launch "today" (MD §2.1 anchors 16/11/2026). Period status derives from those offsets.

**Contradictions the planner must settle for one shared story** (MD §3):
- Two different new Bendahara: Yohanis Tumbelaka (16/11) vs Deitje Kawengian (18/11) (row 18).
- Novita is both an active member since 2021 and a new applicant (row 31).
- Ferry Wenas belongs to Kolom 7 vs Kolom 2 (row 28).
- Modules marked inactive while the boards behave as active (row 33).
- Penatua Kolom 2 vacancy has two causes (row 16).
- Panitia Natal money: three different saldo values (row 34).
- Kas October count: Rp0 vs +Rp85.000 difference (row 20).
- Dates after "today" (row 35) must become future-relative or later events.

**"Real conditions only"** may exclude several board states:
- Evidence `gagal` / `ditahan` (MD §1, §2.9).
- n2 "File Excel laporan gagal dibuat" and n5 "AI sedang tidak tersedia" (§2.16).
- WebTutupBuku `adaHambatan` (row 15).
- The vacancy scenario switch (§4.2).

The planner must decide whether each one is reachable naturally or dropped.

---

Not done: I did not read S §8 (F01–F14 field paths), S §14/§15, R beyond the grep hits, or the prototype `lib/mock/*.dart` code; the coverage claims rest on MD alone. Two risks: the refund boards contradict RD04, and the RD04 event table and the unit-finalization rules (D17/EC09) are still open, so those parts of the contract are not settled.