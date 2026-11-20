# Seed-data plan: turning the mock data into one Jemaat Karunia story with dates that follow the real date

Sources: `docs/build/mock-data.md` (abbreviated MD below), `prototype/lib/mock/*.dart` and `docs/design/GMIM_Treasurer_Domain_Model_…_v2.0.md` (abbreviated DM below). Anything I inferred is marked **[inferred]**.

## 1. Seed entities and figures

**Church** (MD 2.1, `gereja.dart`)
- Name "Jemaat Karunia"; the Warta prints "GMIM Jemaat Karunia".
- Time zone WITA. Fiscal year starts 1 January and cannot be changed (DM D08/RD13).
- Recording started 15/09/2026. Seed "today" is 16/11/2026, a Monday.
- Rules:
  - Approval is required for Belanja of Rp2.000.000 and above.
  - A supporting document is required for every Belanja.
  - The fund-request threshold is Rp250.000.
  - The AI cost cap is Rp150.000.
- Voucher series: BKU, OPN and ADJ.

**Kas/Bank** (MD 2.4, `keuangan.dart`)

| id | Opening 15/09 | 1 Okt | 31 Okt | 16 Nov |
|---|---|---|---|---|
| kas | 3.200.000 | 4.070.000 | 8.750.000 | 8.420.000 |
| bni ··4821 | 24.000.000 | 28.565.000 (derived) | 24.600.000 | 24.615.000 |
| bsg ··1107 | 5.100.000 | 3.615.000 (derived) | 5.115.000 | 5.380.000 |
| Total | 32.300.000 | 36.250.000 | 38.465.000 | 38.415.000 |

Three more accounts:
- `hut` Kas Panitia HUT, deactivated 28/10/2026 16.44.
- `kol7` Kas Kolom 7, managed by Deasy Tumbelaka: Rp920.000 in October, Rp1.240.000 in November.
- "Kas Panitia Natal" appears only as text.

**Peruntukan (funds)**
- Jemaat funds: `umum`, `diak`, `bang`. Unit funds: Kolom 7 and Panitia Natal.
- Kas split at opening: Umum 2.000.000, Diakonia 700.000, Pembangunan blank (Rp500.000 balances it).
- BNI by fund on 16/11: Umum 18.115.000, Diakonia 4.200.000, Pembangunan 2.300.000.
- Lingkup: Jemaat, Kolom 3, BIPRA Pemuda, Panitia Natal, and on Lainnya also Komisi Diakonia.

**Mata Anggaran** (MD 2.5)
- Version 2026.1 is published, valid from September 2026, with 131 Pendapatan and 158 Belanja rows. About 20 of those rows are drawn.
- Version 2026.2 is a draft valid from December 2026: 2 new rows and 1 renamed.
- Picker lists are in `keuangan.dart:267-296`.

**Months** (MD 2.6)
- September: closed 05/10/2026 19.02, "21 transaksi".
- October: open, next to close, "33 transaksi".
- November: running month, "12 transaksi".
- December: empty.

**Transactions**
- September (MD 2.7): OPN-2026-0001, BKU-2026-0019, BKU-2026-0031, and a draft "Honor pemusik" dated 28/09.
- October (MD 2.7, `transaksi.dart:123` `f02Oktober`): 31 F02 rows from BKU-0098 to BKU-0133. They total In 29.260.000 and Out 27.045.000, ending at 38.465.000, and they tie to F01, F05, F07, F08, F09 and F11 (MD 2.8).
  - Unused numbers: 0111, 0124, 0126.
  - Numbers in the range that belong to November: 0129 and 0132.
- November (MD 2.9): the union drawn across boards is BKU-0129 to BKU-0155, plus 3 drafts or cancelled rows.

**Cases** (MD 2.10)

| Case | Who / what | Amount | Note |
|---|---|---|---|
| um1 Panitia Natal | Rivo | 1.500.000 | Rp850.000 settled, due 30/11 |
| um2 Retret Pemuda | Natalia | 800.000 | Rp300.000 settled, overdue (due 10/11) |
| um3 Perjalanan dinas Wilayah | Jefry | 400.000 | Settled |
| Web-only advance | Selvie | 300.000 | Rp375.000 used, gives the overspend claim of Rp75.000 |
| tt1 Titipan | Sinode | 2.400.000 | Rp1.000.000 paid out |
| tt2 Titipan | Wilayah | 450.000 | |
| pb1 Claim | Selvie | 185.000 | Open |
| pb2 Claim | Rivo | 120.000 | Paid with BKU-0134 |

**Month-end** (MD 2.11–2.12)
- BNI reconciliation: 3 bank mutations (Ibu Runtu Rp1.000.000, TARIK TUNAI −Rp2.000.000, BIAYA ADM −Rp15.000). Rp500.000 is in transit (0131) and 12 mutations are already matched.
- Kas count on 16/11: Rp8.370.000 against a book balance of Rp8.420.000.

**People** (MD 2.2–2.3, `orang.dart`)
- 23 named people: Meiske, Olvie, Yanti, Lidya, Jefry, Hendrik, Deasy, Stevi, Natalia, Rivo, Novita, Agustina, Ferry, Gabriel, Olga, Greis, Altje, Yohanis Rompas, Kevin, Gabriela, Selvie, Yohanis Tumbelaka, Deitje.
- 10 posts, 2 delegations, and 5 families: Wenas-Lasut, Lasut, Rumagit, Sumual, Mamahit.
- Bulk counts with no names behind them: 1.284 active members, 412 families, 12 Kolom with 11 of 12 Penatua posts filled, Kolom 7 with 96 members and 31 families, 318 imported rows (241 unconfirmed).

**Units**
- 12 Kolom; those named are 2, 3, 4, 5, 7 and 11.
- BIPRA Pemuda and Remaja.
- Komisi Diakonia and Komisi Pembangunan.
- Panitia Natal 2026, Panitia HUT, Panitia Paskah 2026.

**Committees** (MD 2.20)
- Panitia Natal 2026: Stevi, Natalia and Rivo, under SK BPMJ No. 11/2026, balance Rp4.350.000.

**Documents** (MD 2.14, 2.19)
- Supporting documents, ids a–f.
- 6 church documents, 4 announcements, Warta editions dated 25/10 to 22/11, and 3 letter requests.

**Approvals and incidents** (MD 2.15)
- Approval records: 0116, 0137, and the Koreksi flow (Lidya, 08/11, recorded from meeting minutes).
- Incidents: K-2026-01 (Toko Sinar receipt recorded twice) and K-2026-02 (supporting document arrived late).

**Platform** (MD 2.16–2.17)
- Notifications n1–n5, 10 modules, and an empty approver table.

## 2. Hard-coded dates and a rule for shifting them

**How the dates relate:**
- "Today" is 16/11/2026, a Monday. It is held as `hari = 20261116` / `hariTeks` in `format.dart:7`, which the screens reference 31 times, and on 34 boards.
- The months follow a fixed pattern relative to today:
  - M−2 is September, the cutover month. Recording starts on the 15th and the month is closed.
  - M−1 is October, the last unclosed month, with a full ledger.
  - M0 is November, the running month.
  - M+1 is December: the draft Mata Anggaran version takes effect then and its due dates fall there.
  - One date falls in M+2: 05/01/2027 (Panitia closing).
- The most frequent dates in `prototype/lib` are 16/11 (233 occurrences), 15/11 (62), 12/11 (47) and 08/11 (40).
- Month names appear as "Oktober 2026" (172), "November 2026" (108), "September 2026" (63), "Desember 2026" (38) and "Januari 2027" (5).

**Weekdays are part of the story.** These dates must stay on the same weekday after shifting:
- Sundays: 04, 11, 18 and 25/10, and 01, 08, 15, 22 and 29/11 (offerings, Warta editions, Adven I).
- "Kamis, 19/11" and "Kamis 12/11".
- "Sabtu, 21 November".
- "Rabu, 25/11".

**Identifiers that contain a year or month:**
- Voucher numbers `BKU-2026-NNNN` (503 occurrences), `OPN-2026-0001`, `ADJ`.
- Report id `SNP-2026-10-01` and Excel file `…_2026-10.xlsx`.
- Incident numbers `K-2026-0n`.
- SK numbers: SK BPMJ No. 11/12/14/15/2026, SK-BPMJ-04/09-2026.
- Letter number `027/SKet/XI/2026` (Roman-numeral month).
- Mata Anggaran versions `2026.1` / `2026.2`.
- File names `nota-16-11.jpg`, `lembar-hitung-16-11.jpg`, `lembar-penghitungan-15-11.jpg`.
- Names: "Panitia Natal 2026", "Panitia Paskah 2026", "katekisasi sidi 2027", "Sentralisasi November", "Persembahan khusus 9 November", "Minggu Adven I".

**Proposed rule [inferred]:** build the seed once at app launch from `T`, the real date in WITA. Write every seed date as a relative anchor instead of a literal:

1. **Month anchor (M).** Used for all dates before M0 and for month-fixed future dates.
   - `Δm = (T.year*12 + T.month) − (2026*12 + 11)`.
   - A date `(y, m, d)` becomes `(y, m+Δm, min(d, daysInMonth))`.
   - The last day of a month is written as an explicit `endOfMonth` marker, not as a number. This covers 30/09 ("15–30 September"), 31/10 (in transit, BIAYA ADM, F10 "Per 31 Oktober"), due date 30/11 and 31/12.
   - "Berlaku 01/12" becomes the 1st of M+1.
   - History dates (01/01/2026 "Sejak", birth dates, Baptisan 1996, Kolom 7 since 2021) take the same Δm, so ages and terms stay the same. Novita has to stay 30 for the BIPRA Pemuda rule.
2. **Weekday anchor (S).** Used for services and schedules.
   - Write the date as the nth Sunday of the shifted month. Example: 04/10 becomes the 1st Sunday of M−1.
   - Future events are written as the next matching weekday after T: Ibadah Kolom on Thursday, Warta 22/11 and Adven 29/11 on Sundays.
3. **Today anchor (T).** Used for M0 events up to seed-today.
   - Date = `T − (16 − d)` days, clamped to be no earlier than the 1st of M0. M0 events must never fall into M−1, or October's frozen figures would change.
   - Times on "today" are placed relative to a seed "now" of 16/11 12.05 (the latest seed time; Pemulihan is 12.05). Times later than the real now move earlier, keeping their order, so nothing seeded lies in the future.
4. **Generated identifiers.**
   - Voucher numbers are `BKU-{year of effective date}-{ordinal}`, numbered per series per year (DM D08/RD13). The seed keeps each voucher's ordinal from the boards, so posting order still differs from date order (0112 and 0113 are dated after 0114, as on F02). When a year boundary splits the seed, each year's series is renumbered from 0001 in ordinal order.
   - `OPN-{cutover year}-0001`.
   - `SNP-{yyyy}-{mm of M−1}-01`.
   - Letter number: Roman numeral of the issue month.
   - File names built from dd-mm.
   - SK and K numbers use the year of the record's own date.
   - Mata Anggaran: `{cutover year}.1` is published; the draft is next-numbered and takes effect at M+1, and becomes `{Y+1}.1` if M+1 falls in a new year **[inferred naming]**.
   - Month words come from `bulanTahun()`.
5. **Closing a month** comes from period records, not from strings:
   - M−2 is CLOSED and M−1 is OPEN. Periods close in calendar order (DM 5.5/RD01) and closing is irreversible (D07).
   - Close blockers are computed. Under DM 6.4 the seed gives more than the board's "1 hambatan" **[inferred]**:
     - the Kolom 7 draft dated 28/10
     - BNI reconciliation not confirmed
     - Diakonia readiness out of date
     - Pembangunan readiness missing (it holds a balance)

**Edge cases:**
- **T in January.** M−2 is November Y−1 and M−1 is December Y−1, so M0 vouchers restart at BKU-Y-0001. The October-equivalent close becomes the year-end month. Year-to-date runs from 1 January but never claims anything before cutover (DM 4.3/RD05).
- **T in February.** M−1 is January Y, so the M−1 and M0 vouchers share year Y's series, while M−2 (December) keeps Y−1.
- **Short months.** If M−1 is February, the vouchers on the 29th, 30th and 31st all clamp to the 28th; sort them by ordinal.
- **T on the 1st to 6th.** M0 may have no Sunday yet. Clamp the "last Sunday" offering to the 1st of M0 rather than letting it slip into M−1. Many M0 events will share day 1.
- **Overdue advance um2.** Its due date must stay before T, so write it as T−6 days, and never before the 20/10 issue.
- **Seasonal names** (Natal, Adven, Paskah, "Sentralisasi {M0 name}") read wrongly when T is far from November. This needs a PO decision: re-theme by month, or keep Natal with the year of the coming 25 December **[open question]**.
- **Day rollover while the app runs.** Keep the anchor fixed at launch; the clock display can stay live **[inferred]**.

## 3. Where the figures disagree, and how one story settles them

MD section 3 lists 40 conflicts. Basic approach **[inferred]**: M−2 and M−1 stay exactly as drawn, because the October set already adds up. M0 becomes a consistent subset of the November rows, and every total is computed from it.

| MD §3 row | Resolution |
|---|---|
| 1–3 balance at a different moment | Not real conflicts. Computed balances come out right for each date. |
| 4 Diakonia 3.7 M vs 4.2 M | Compute it. The 4.2 M figure is dropped because it cannot be derived. |
| 5, 6, 10 Fotokopi draft, BKU-0147, 0146/0148 | One draft "Fotokopi warta" dated today. Catat posts it at the next real number. The 15/11 Persembahan is seeded once as the multi-part offering (3.600.000); 0146 is dropped. |
| 7, 9, 8 reused numbers 0151, 0152, 0150 | Numbers are allocated, so they are unique. The rows Pemeriksa, AlihPeruntukan and Kewajiban create get the next numbers at action time. |
| 11, 19 who posted or closed | Comes from the acting persona's audit record. |
| 12 Selvie's advance | Seed it. F14 already counts 3 October advances; the Rp75.000 overspend claim follows from it. |
| 14 Kolom 7 blocking draft | One draft: Kas Kolom 7, dated 28/10, −150.000. AlurUnit's 185.000 is dropped. |
| 15 blockers | Computed (section 2). |
| 16, 17 Kolom 2 vacancy and the death | Altje's term ends at end of M−2+1 (31/10); Yanti covers from 01/11. Yohanis Rompas's death (14/11) is a pending event in the Kolom 2 queue. The two are not causally linked. |
| 18 new Bendahara | Not seeded. Becomes the result of a handover action. |
| 20 Kejadian K-01 vs F10 Rp0 | Drop K-2026-01: an extra Rp85.000 found at the October count would make October unclosable (DM RD08). Seed K-2026-02 only. |
| 21 report format approval | One record dated 03/10 (M−1 day 3). |
| 22 Lingkup | 5 Lingkup, including Komisi Diakonia. |
| 23–26 Mata Anggaran naming | 2.1.01.02.00 is in 2026.1 (F02 uses it). 2.2.01.02.00 takes the 2026.2 name. Drop the "Baru" tags on rows already in 2026.1. |
| 27 Honor pemusik | One draft, dated in M0 (08/11 equivalent), BNI, no Mata Anggaran. A draft in closed September breaks DM RD09. |
| 28 Ferry's Kolom | Kolom 7, unconfirmed. Kevin Rompas is the Kolom 2 applicant. |
| 29 sampul syukur date | 01/11 equivalent, BKU-0132. |
| 31 Novita's membership | She stays active. The application journey goes to Kevin (or to a new person). |
| 32, 35 attendance correction and dates after today | Actions, not seed. |
| 33 modules | Module states must match the personas that are enabled. Data jemaat, Ibadah and Kehadiran must be active if their screens are reachable **[PO decision]**. |
| 34, 39 Panitia Natal money | Hold it as a Panitia Natal fund inside a Jemaat account. The balance is computed, so 4.35 M only holds if the seed is tuned. |
| 36 draft counts, 38 row counts | Computed. |
| 37 second checker | Off by default, as Lainnya shows. |
| 40 Sekretaris status | Active. |

**New conflicts not listed in MD §3:**
- November's drawn rows net to about −4,46 M of cash flow, but the balances show −50.000 between 31/10 and 16/11.
- Beranda shows Pendapatan 7.540.000 and Belanja 7.940.000; no subset of the drawn rows produces these.
- "12 transaksi" (PilihBulan) vs "51 baris" (Bukti).
- September has "21 transaksi" yet the numbers run up to 0097: 0019 is on 18/09 and 0031 on 22/09.
- Getting from 32,3 M to 36,25 M across September needs about 18 invented rows.
- F10/F11 list 3 accounts, but closing October also requires reconciling Kas Kolom 7 (SelesaikanUnit). DM 6.4 says one close covers every account.

Recommendation: compute the figures and accept that they drift from the drawn M0 figures. Tune with one balancing row only if the PO wants 38.415.000 exactly.

## 4. Board situations that need their own seed records

- **Vacancies:** the Penatua Kolom 2 post with Yanti's cover from 01/11, and Syamas Kolom 3 with nobody covering. The R04 Bendahara vacancy (`jabatan_kosong.dart`) should not be seeded; make it an authority-revocation action **[open question: which persona does it]**.
- **Refusals that should arise from the rules:**
  - Kolom 7 drafts "Konsumsi ibadah Kolom" (Jemaat BNI, not allowed for the unit) and "Bantuan duka" (Diakonia fund).
  - Imported row "31/11/26" (date unreadable).
  - A named envelope for Ferry, who is unconfirmed.
  - The Atestasi refused on 16/11.
  - The Gabriel baptism returned on 16/11.
- **Incident:** K-2026-02 in the closed September.
- **Pending requests:**
  - Kevin Rompas's membership application (Kolom 2, through the vacancy cover).
  - Ferry Wenas's family confirmation and unconfirmed status.
  - Gabriel's baptism and Gabriela's Sidi.
  - Yohanis Rompas's death.
  - Keluarga Lasut moving Kolom, effective the 1st of M+1.
  - The Rumagit data change, forwarded to the Syamas.
  - The Sumual data change, which is Yanti's own family, so she cannot verify it.
  - The letter request from Novita, 2 Atestasi requests, and the Diakonia fund request of Rp750.000 waiting for Lidya.
- **Finance conditions:**
  - Overdue um2, open um1, Selvie's overspend, open titipan.
  - Missing document 0143; uploaded but unverified 0147.
  - Document exceptions on 0116 and 0137.
  - Reversal chains 0105/0109/0110 and 0139/0144/0145.
  - Cancelled "bunga altar" (recorded twice).
  - Unused numbers 0111, 0124, 0126.
  - Rp500.000 in transit; BIAYA ADM not yet matched (the 3-mutation CSV is staged, not matched).
  - Deactivated Kas HUT.
  - Diakonia and Pembangunan readiness.
  - Mata Anggaran 2026.2 draft.
  - Staged November imports, including a possible duplicate.
- **Excluded as staged faults** (the task says no staged faults):
  - n2 "Excel gagal dibuat" and the close's Excel failure.
  - n5 "AI tidak tersedia".
  - WebEkspor's held and unreadable files.
  - The Draf conflict.
  - "Sambungan diakhiri".
  - The partial-count selisih (prefilled Kas count).

## 5. How `prototype/lib/mock` is built today, and what must change

**Today:**
- 14 files and about 4,770 lines; `mock.dart` exports 12 of them.
- Everything is `const`. Dates are kept as strings because `DateTime` has no const constructor (`model.dart:1-6`).
- Records refer to each other by display text, not by id: `kasBank: 'Bank BNI ··4821'`, `kodeMA: '1.3.53.07.00; 1.3.55.01.00'`, people's names.
- Pre-computed snapshots are stored instead of computed: `saldoPembukaan`, `saldo1Oktober`, `saldo31Oktober`, `saldoNovember`.
- Report tables are fixed string arrays (`laporan.dart` F01–F14).
- Each board has its own copy where boards differ: `semuaKasus` vs `kewajibanWeb`, `drafFotokopiWarta` vs `…Web`, `rekonBniOktober` vs `rekonIsiBni`, `pemeriksa` vs `pemeriksaWeb`, `berandaJabatan` per keadaan, `kotakMasukAda` / `…Keuangan`.
- Demo machinery lives in the data:
  - `jabatan_kosong.dart` (`tukarJk`, `papanTukarJk`, `plk`).
  - `ItemKotak.ke` holds board stems, and `platform.dart:69 keWeb()` routes on them.
- Supporting pieces:
  - `kasusNomorBerikut = 150` is a hard-coded next-number counter.
  - `format.dart` holds `hari`.
  - 97 screen, shell and widget files import `mock/`.
  - `test/mock_test.dart` and `format_test.dart` test it.

**Change to:**
1. **`domain/`**: entities shaped like DM §3. Each has an id and holds references by id.
   - Finance: Workspace, PhysicalAccount, Fund, Scope (unit), Party/Person, MasterVersion/MasterRow, Transaction + Allocation + voucher, ApprovalRecord, EvidenceItem, AdvanceCase, TransitCase, ImportBatch/StagedRow, StatementLine, Reconciliation/MatchGroup, CashCount, OpeningBatch, Period, ReportSnapshot, AuditRecord, ReadinessAttestation, CloseIncident, AuthorityGrant.
   - Platform side: Assignment, Delegation, Family, MemberEvent, ChurchDocument, Announcement, WartaEdition, LetterRequest, Committee, Service, Attendance, FundRequest, Module.
   - Reimbursement claims have no domain record in DM **[gap]**.
   - Dates use a church-local date type; money is `int`.
2. **`data/`**: an abstract repository per aggregate, plus in-memory implementations built over one `SeedStore`. The store is built by `buildSeed(anchor: T)` from relative-anchor seed files, one per module, Finance first.
3. **Riverpod**: providers for `clockProvider` (WITA), `seedProvider` (built once per launch) and the repositories. Use services for posting, voucher allocation, closing and reconciliation.
4. **Derived, not stored**: balances, F01–F14 (frozen in a snapshot at close), counts, case remainders, Beranda figures, notifications and inbox items, close blockers.
5. **Delete**: the per-board variants, keadaan sets, `jabatan_kosong.dart`, `ItemKotak.ke` / `keWeb`, `hari` / `hariTeks`, and the string report tables.
6. **Keep**: the `format.dart` helpers (`rp`, `tgl`, `tglPanjang`, `bulanTahun`, input filters, masks) and their tests. Replace `mock_test` with checks on the seed: the October ledger reaches 38.465.000, the funds balance, and no seeded date is after T.

Not checked: I did not read the `screens/*.md` specs or the board sources, so the seed counts per screen are not verified. The voucher figure of 503 is a count of occurrences in the code, not of distinct numbers.
Risks:
- Matching the drawn November totals is not possible from the drawn rows without tuning.
- About 18 September rows and the bulk member records have to be invented, which needs PO approval because MD says "Nothing here is invented".
- The seasonal names need a decision.