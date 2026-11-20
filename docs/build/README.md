# Palakat demo app: build plan

20 November 2026. The plan for turning the Palakat clickable prototype (`prototype/`) into a demo app that runs on Android phones and tablets and on the web, with every module working on dummy data held in the app. It is written so that an autonomous run (a `/goal`) can execute it end to end and check itself after each milestone.

## Status

Not started. The prototype it starts from is built and verified (199 boards, one route per board, a Keadaan panel for board states). The plan for that prototype is in git history: `git show 19a71f9d:docs/build/README.md`.

What changes, in one paragraph: the prototype shows each board on its own, with its own copy of the data and a panel that switches its states. The demo app keeps the screens as drawn but puts them on one shared, in-memory state. What one persona does on one screen shows on every other screen and for every other persona. A persona picker is the only way in, and the seed story moves with the real date. All demo machinery is removed. "Done" means 42 flow tests that drive the real UI through every flow F1–F25 and P1–P17, plus a clean analyzer and successful web and Android builds.

## Goal

Copy this block as the goal for the run.

> Turn the Palakat clickable prototype in `prototype/` into the Palakat demo app described in `docs/build/README.md`, following that file and `docs/build/CONVENTIONS.md`. The demo app is one Flutter app for Android (phone and tablet) and web. It runs every module on dummy data held in memory, behind repository interfaces shaped after the domain model, on shared Riverpod state. A persona picker is the only entry, and the seed dates are shifted to the real date. Work milestone by milestone, M0 to M10, in the order and with the parallel batches the README gives. Commit each milestone on the working branch and never push. The goal is met when every item of "Definition of done" in the README passes:
> 1. `fvm flutter analyze` prints "No issues found!".
> 2. `fvm flutter test` passes with no skipped test, and `test/` holds only the flow harness and one or more flow test files for each of the 42 flows F1–F25 and P1–P17, each of which signs in through the picker.
> 3. `fvm flutter build web` and `fvm flutter build apk --debug` (with `JAVA_HOME` set as the README says) both succeed.
> 4. Every deleted path is gone, and every grep check in the README returns nothing.
> 5. The board accounting check passes: each of the 199 boards is mapped to an app screen or listed as dropped.

## Contents

1. Decisions this plan builds on
2. Sources
3. Target architecture
4. Repository interfaces
5. The seed
6. What is deleted and what replaces it
7. From boards to app screens
8. Flow tests
9. Milestones
10. Working in parallel, and run hygiene
11. Definition of done
12. Running and checking the app
13. Open items for the owner

## 1. Decisions this plan builds on

The product owner decided these on 20 November 2026. They are binding. Do not reopen them, and do not add options the owner did not ask for. Later sections cite them as "D1" to "D25".

| # | Decision |
| --- | --- |
| D1 | Dummy data is held in the app, behind repository interfaces shaped after the real domain model, so that a Supabase implementation can replace the in-memory one later. Commands keep their full signatures (actor, expectedRevision, idempotencyKey, reason). |
| D2 | `prototype/` is evolved in place. No tag or branch of the prototype is kept. |
| D3 | All modules are built, in phases, Finance first: 0 Core, 1 Finance, 2 C1 Operator and delegation, 3 Secretariat, 4 Membership, 5 Collaboration, 6 Joins. |
| D4 | Screens behave as the boards do: fixed sample outcomes and fake timers for AI, upload and similar work are fine. But they run on shared state, so what one screen does shows on every other screen and for every persona. |
| D5 | All demo tools are removed: the launcher, the Keadaan panel, tweaks (`PrototypeState`, `context.tweak`), per-board routes, the device frame, journeys, `Kendali` reset machinery, the component gallery, `belum_dibangun`, the generated `boards.dart` and `router.dart`, the `tool/` generators, and the boards that are not app screens. |
| D6 | State resets on every launch. Nothing persists. |
| D7 | The only entry is a persona picker. Signing out returns to the picker and keeps the in-memory state, so two-sided flows work on one device. |
| D8 | The clock is the real current date. Seed dates are shifted relative to today. Period and month labels are computed from the shifted dates. Story names (Panitia Natal, Advent offerings and so on) stay exactly as drawn. |
| D9 | Only real conditions are shown. There are no staged faults. UI for board states that real data can reach is kept; UI for states that only a fault could cause is dropped. |
| D10 | One church story is seeded: Jemaat Karunia. Plain rows may be invented in the boards' style (about 18 September transactions, bulk member and household records per Kolom, older periods). No new story lines. |
| D11 | Computed totals win. Screens show what the seed transactions add up to, and board strings are a guide, not a target. There are no balancing rows. |
| D12 | State management is Riverpod (`flutter_riverpod`). |
| D13 | The layout follows the platform. An Android phone shows phone screens. An Android tablet shows the tablet boards (TabBeranda, TabTransaksi, TabCatat), whose links open web-layout screens. The web shows web screens. Boards that exist only as phone boards are hidden on web: rows and links to them are removed from web screens. |
| D14 | "Done" means flow tests only. All prototype tests and the screenshot harness are deleted. Each flow (F1–F25, P1–P17) gets a flow test that drives the real UI through providers and asserts its end state. |
| D15 | Targets: local dev web (`fvm flutter run -d chrome`, `fvm flutter build web`) and a dev Android build. No production deploy, no signing, no store. |
| D16 | The plan is run by an autonomous agent. It must be executable end to end without a human, with machine-checkable checks per milestone. |
| D17 | The picker offers the core 11 personas (5.2). Stevi, Agustina, Kevin and the Petugas verifikasi are seed people only. |
| D18 | The seed starts with Meiske as Bendahara. Pdt. Lidya can end her term in the app. The post then shows as vacant with Operator cover: the vacancy footer on web finance screens and the `PitaJabatanKosong` strip on phone finance screens. A successor, Yohanis Tumbelaka, can then be assigned live through the handover flow. Deitje Kawengian is not the successor. |
| D19 | The sign-in boards are dropped: Masuk, AlurMasuk, Pemulihan and their Web twins. "Masuk lagi" (Sambungan) and "Keluar" open the picker. Awal and WebAwal show the completed opening read-only, not a first-run wizard. WebVerifikasi is dropped. |
| D20 | Every persona lands on its role home: BerandaJabatan on phone, WebBerandaJabatan on web. For Meiske, finance (Main or WebBeranda) opens from there, as for other roles. |
| D21 | All modules start ACTIVE. Modul can still switch modules off, and menus and routes react. |
| D22 | The membership applicant is Kevin, a seed person. His application waits in the verification queue. Novita stays an active member since 2021. |
| D23 | Where boards conflict, take the version most boards and the specs agree on (specs win over boards on rules), and list every pick in the Data picks table (5.8). |
| D24 | Rule changes the boards say start "from next month" (the second-checker rule and others) are already in force at launch. Switching a rule in the app still says it takes effect next month. |
| D25 | The refund boards (Pengembalian, AlurPengembalian) are built as drawn and post a refund transaction. They are flagged as pending spec RD04. |

## 2. Sources

Read these. This plan cites them by file and section instead of repeating them.

| Source | Use it for |
| --- | --- |
| `docs/build/research/roles.md` | Personas, posts and who holds them, screens per persona, module phases |
| `docs/build/research/code.md` | What to keep, refactor and delete in `prototype/`; twin patterns A and B (§4); migration risks (§5) |
| `docs/build/research/flows.md` | Flows F1–F25 and P1–P17 with end states; Static/Alur merges (§0); boards that are not app screens (§3) |
| `docs/build/research/seed.md` | Seed figures (§1), date-shift rules (§2), conflict resolutions (§3), seed records per board situation (§4), target data structure (§5) |
| `docs/build/research/domain.md` | Entities (§1), state machines (§2), repository interfaces (§3), what to simplify (§5) |
| `docs/build/screens/01-…md` to `23-…md` | Layout, copy, interactions, motion and acceptance checks of each board. Still the authority for how a screen looks and reads |
| `docs/build/mock-data.md` | Seed values per board (§2), board conflicts (§3), vacancy copy (§4.2) |
| `docs/build/navigation.md` | Shells and side-nav lists (§1.1–1.5), footers (§1.3), the platform tree and the 26 phone-only boards (§1.5), the board list (§2.2), links (§3) |
| `docs/build/CONVENTIONS.md` | Theme, tokens, form factors, copy, motion, accessibility. M0 rewrites its prototype-only sections (M0 step 10) |
| `docs/design/GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md` ("DM") | Entities §3, posting §4, state machines §5, close §6.4, reports §8, decisions RD01–RD13 and DL rows in §1 |
| `docs/design/platform-module-plan-2026-11-17.md` ("PMP") | Decisions DL1–DL33 (§2), core (§5), modules (§6, §6.1), switching modules (§8), roles (§10), capabilities (§11), build order (§12) |
| `docs/design/GMIM_Treasurer_MVP_Design_Specification_and_Rulebook_v5.0.md` | Rules the domain model cites (P sections, rule numbers) |
| `docs/design/stack-decision-2026-11-08.md` | Flutter + Supabase. The in-memory repositories are the seam for Supabase later |
| `docs/design/test-vectors/` | Behaviour vectors B01–B100 and arithmetic vectors A01–A10. Use the DECIDED ones as a guide for repository behaviour. Do not implement the PROPOSED ones (B35, B36, A07) beyond D25 |
| `docs/design/handoff/canvas/boards/<Stem>.dc.html` | The board sources, when a spec is unclear |

The five research reports were written for this plan and are committed in `docs/build/research/`, so every worktree sees them.

## 3. Target architecture

### 3.1 Folder layout

All paths are under `prototype/`. The package name stays `palakat_prototype`, and the Android `applicationId` stays `id.palakat.palakat_prototype`; renaming them would only cause churn (D2).

```
lib/
  main.dart                  runApp(ProviderScope(child: PalakatApp()))
  app/
    app.dart                 PalakatApp: MaterialApp.router, theme (light and dark follow the system), router from routerProvider
    tata.dart                enum Tata { ponsel, tablet, web } and how it is chosen (3.2)
    layar.dart               enum Layar: one value per app screen, with its path and the boards it replaces (7.2)
    router.dart              the phone route tree and the web route tree (3.6), guards, picker redirect
    belum_dipindah.dart      temporary marker used during migration (M0 step 5); deleted in M10
  core/
    format.dart              moved from lib/mock/format.dart: rp, tgl, tglPanjang, jam, bulanTahun, input filters, masks
    clock.dart               Clock (WITA), SystemClock, FixedClock
    tanggal.dart             Tanggal: a church-local date (year, month, day)
  domain/                    pure Dart: entities, enums, state machines, posting sign table, capability catalog
    core/ finance/ secretariat/ membership/ collaboration/
  data/
    repositories/            abstract interfaces, one file per repository (section 4)
    memory/                  in-memory implementations over SeedStore, one file per repository
    seed/
      seed_store.dart        SeedStore: the mutable in-memory tables, revision counters, voucher counters, idempotency log
      build_seed.dart        SeedStore buildSeed({required Tanggal anchor, required DateTime now})
      jangkar.dart           date anchors (5.3)
      tabel_inti.dart  tabel_keuangan.dart  tabel_sekretariat.dart  tabel_jemaat.dart  tabel_kolaborasi.dart
                             one class of tables per module, held by SeedStore (5.7)
      seed_inti.dart  seed_keuangan.dart  seed_keuangan_kasus.dart  seed_keuangan_akhir_bulan.dart
      seed_keuangan_pengaturan.dart  seed_sekretariat.dart  seed_jemaat.dart  seed_kolaborasi.dart
  providers/                 Riverpod providers: clock, seed, session, actor, layout, one file of repository providers
                             per module, and read models per feature (beranda_keuangan.dart, tutup_buku.dart, …)
  shell/                     product chrome kept from the prototype (section 6): layar_ponsel, kepala_ponsel,
                             ponsel_tab_bar, halaman_web, nav_samping, nav_item, panel_samping, halaman_a4,
                             halaman_lembar, tablet, toast, tautan, tidak_ditemukan
  screens/<pageId>/          the existing screen files, migrated in place. The pageId folders are kept to avoid
                             moving 240 files; `sistem/` is deleted. New: screens/pemilih/pemilih_persona.dart
  widgets/ motion/ theme/    kept (code.md §3, "Reusable as is"), except that M1 removes their date and year
                             defaults and examples (M1, "Date sweep")
test/
  flows/harness.dart         the flow-test harness (8.1)
  flows/<fNN|pNN>_<name>_test.dart
```

Naming: the domain and data layers use English names, so they map one to one onto DM §3 and onto future Supabase tables (`Transaction`, `TransactionRepository`, `finalize`). UI code keeps the prototype's Indonesian names (`Layar`, `Tautan`, `LayarPonsel`).

### 3.2 Layout by platform (D13)

`layoutProvider` returns a `Tata`, chosen once at launch by a pure function in `lib/app/tata.dart`, `Tata pilihTata({required bool web, required Size ukuranLogis})`. The provider's body calls it with `kIsWeb` and `PlatformDispatcher.instance.views.first`'s `physicalSize / devicePixelRatio`. It needs no `BuildContext` and never changes state during a build (the crash of commit 19a71f9d):

| Platform | Tata | Screens |
| --- | --- | --- |
| Web (`kIsWeb`), any window width | `web` | Web screens. Fluid; below 860 px the side nav collapses behind "Menu", as drawn |
| Android, logical `shortestSide >= 600` | `tablet` | The web route tree, with TabBeranda, TabTransaksi and TabCatat in place of WebBeranda, WebTransaksi and WebCatat (navigation.md §1.4) |
| Android, otherwise | `ponsel` | Phone screens, full screen. There is no device frame |

Flow tests override `layoutProvider` and set the test view size: 390 × 844 for `ponsel`, 834 × 1112 for `tablet`, 1440 × 1000 for `web`. P3 also tests `pilihTata` directly and pumps `PalakatApp` once with no overrides (8.3).

The tablet uses the web layout set, so the boards hidden on web are hidden on the tablet too. D13 does not say this; it is inferred, and it is listed in the open items (section 13).

### 3.3 Providers

Riverpod 3 (`flutter_riverpod: ^3.5.0`, which is in the pub cache), plain providers, no code generation.

| Provider | Type | What it holds |
| --- | --- | --- |
| `clockProvider` | `Provider<Clock>` | `SystemClock`: now in WITA (UTC+8, from `DateTime.now().toUtc()`). Tests override it with `FixedClock(...)`, which `majukan(Duration)` moves forward (8.1) |
| `launchProvider` | `Provider<({Tanggal anchor, DateTime now})>` | Read once: today and now in WITA at launch. The anchor does not move if the app runs past midnight |
| `seedProvider` | `Provider<SeedStore>` | `buildSeed(anchor:, now:)`, built once per `ProviderScope`, which is once per launch (D6) |
| `revisionProvider` | `NotifierProvider<StoreRevision, int>` | Bumped by every successful command. Read models watch it |
| `sessionProvider` | `NotifierProvider<SessionNotifier, Session?>` | The signed-in persona and the post they are acting in, or null (the picker shows) |
| `actorProvider` | `Provider<Actor?>` | Derived from the session: person, acting assignment, scope, and `via` (direct, delegation or vacancy cover) |
| `vacancyCoverProvider` | `Provider<bool>` | True while the actor acts by vacancy cover of the Bendahara post. The phone strip, the web band and the web footer read it (D18) |
| `<x>RepositoryProvider` | `Provider<XRepository>` | One per repository, built from `seedProvider`, `clockProvider` and the revision bump. Overriding one with a Supabase implementation later is the seam (D1) |
| `canProvider` | `Provider<Can>` | The capability gate (3.5) |
| Read models | `Provider<T>` per screen or feature | For example `berandaKeuanganProvider`, `blockersProvider(periodId)` and `homeRowsProvider`. Each watches `revisionProvider` and the repositories it reads |
| `layoutProvider`, `routerProvider` | `Provider` | 3.2 and 3.6 |

Rules:

- Never change a provider while widgets are building. Commands run in callbacks (`onTap`, `onPressed`), never in `build`. The prototype hit this on Android: commit 19a71f9d, `setState` during the first build (code.md §5 i).
- Domain data lives only in repositories. A widget, or a surviving `Kendali` controller, holds only UI state: form text, filters, an open sheet, a toast, the current step of a flow.
- Reads are synchronous: queries read the in-memory store. Commands are asynchronous: `Future<Result<T>>`. A Supabase implementation later keeps the same read signatures over a realtime local cache, and its commands become network calls. This is the one seam that changes shape. It is recorded in the open items.

### 3.4 Repositories, actor, results, audit and notifications

- **Actor.** `Actor { personId, assignmentId?, scopeId, via }` where `via` is `direct`, `delegation(delegationId)` or `vacancyCover(postId)`. Every command takes the actor as its first argument.
- **Result.** `sealed class Result<T>` with `Ok(value)` and `Refused(Refusal)`. `Refusal { action, because, whoCanAct? }` renders through the existing `widgets/penolakan.dart` as the boards draw it: "Tidak dapat dilakukan: {action}." followed by the reason and "Yang perlu bertindak: …". Refusal copy comes from the board or spec that draws the case.
- **Revision.** Every aggregate carries an `int revision`. A command that takes `expectedRevision` refuses when it does not match (the Draf board's "Sudah diubah sejak Anda membukanya" card).
- **Idempotency.** `SeedStore.idempotencyLog` maps each key to its first result. A repeated key returns that result and changes nothing (test vectors B45–B50). Screens make one key per submission: `'${actor.personId}-${clock.now().microsecondsSinceEpoch}-${counter}'`.
- **Audit.** Every successful command appends an `AuditRecord` (actor, acting role, scope, via, before/after summary, reason, time) inside the repository, never in the UI. Riwayat lists (Lainnya `/riwayat`, WebPengaturan, RiwayatAlur cards) read `AuditRepository`. The name shown on a record is its recorded actor. That is how "Yanti Sumual, Operator · menjalankan jabatan kosong Bendahara Jemaat" appears (it replaces `tukarJk`, section 6).
- **Notifications.** Repositories write notification rows for their recipients as part of the same command: the verifier when something is submitted, the requester when it is decided, the unit when the Bendahara clears its blocker (DL33), and so on. KotakMasuk, Pemberitahuan and the home rows read them.

### 3.5 The capability gate

One function decides who may act, and every repository command and every screen asks it. It answers PMP §5's core check, "may this person do this, in this scope, at this time":

```dart
// lib/domain/core/capabilities.dart
bool can(Actor actor, Capability capability, ScopeRef scope, {required Tanggal at});         // used by repositories
Refusal? whyNot(Actor actor, Capability capability, ScopeRef scope, {required Tanggal at});  // the refusal text for the UI
```

Repositories pass the command's date (today from `clockProvider`, or the effective date the command acts on); screens pass today.

- Capabilities are named `<module>.<action>` (PMP §11): `finance.record`, `finance.review`, `finance.finalize`, `finance.close`, `finance.reconcile`, `finance.view_fund`, `finance.settings`, `finance.clear_unit_blocker`, `core.assign_post`, `core.cover_vacancy`, `core.delegate`, `core.switch_module`, `documents.publish`, `documents.issue_letter`, `announcements.draft`, `announcements.publish`, `warta.publish`, `warta.reveal_identity`, `membership.import`, `membership.verify`, `membership.apply`, `services.approve`, `attendance.count`, `attendance.finalize`, `requests.submit`, `requests.approve`, `panitia.create`, `panitia.stage`, and the rest listed per module in PMP §10.
- The role → capability table comes from PMP §10, the "Can" and "Cannot" columns.
- `can` checks, in order:
  1. the module is ACTIVE (READ_ONLY allows reads only; PMP §8);
  2. the actor holds an assignment in force at `at` (start ≤ at ≤ end) whose role has the capability;
  3. or holds a delegation in force at `at` for it;
  4. or is an Operator covering, at `at`, the vacant post that has it (DL12);
  5. the scope matches: the same scope or a descendant, so a Penatua Kolom 7 acts only in Kolom 7.
- It is a static table plus these checks (domain.md §5 point 7), kept in one place so that it maps onto row-level security later. It takes no record, so it holds no rule that depends on one.
- **Workflow rules live in the commands that hold the record** (PMP §11). Each command refuses with the board's copy:

  | Rule | Enforced by |
  | --- | --- |
  | The maker is not the checker; a covering Operator is not the checker | `TransactionRepository.review` |
  | With the second-checker rule in force, a draft is finalized only after a review by someone other than its maker | `TransactionRepository.finalize` (reads `SettingsRepository.rulesInForce`) |
  | No self-verification | `VerificationRepository.verify`, `EvidenceRepository.verify` |
  | No self-approval | `FundRequestRepository.approve` |
  | No self-assignment | `RoleRepository.assign` |
  | Three distinct officers | `PanitiaRepository.create` |
  | A unit treasurer finalizes only in their own Fund on accounts their unit operates (DL26, DL32) | `TransactionRepository.finalize` |
  | A Fund-only viewer sees one Fund, a voucher included | the queries of `TransactionRepository`, `ReportRepository` and `FundRepository`, which filter by the actor's Fund |

### 3.6 Routing

- **`Layar`.** One enum value per app screen, not per board (7.2). Each value knows its path, which `Tata` values have a screen for it, its module, and the capability needed to open it.
- **Two route trees, one set of paths.**
  - `router.dart` builds the phone tree for `ponsel` and the web tree for `web` and `tablet`.
  - Both register the same path strings for the same `Layar`. Twins therefore share links: `Tautan(ke: Layar.tutupBuku)` opens TutupBuku on a phone and WebTutupBuku on the web.
  - A `Layar` with no screen for the current `Tata` is not registered in that tree.
  - The 17 phone boards with child routes keep their `ShellRoute` + `<Stem>Kendali` shape (navigation.md §2.1), under their new paths, with the same child path names (`/keuangan/catat`, `/tutup-buku/cek`).
  - Every page route is a sub-route of `/`, the role home, so the home is always the bottom page, as the launcher was. Back from finance therefore returns home. No link from Main or WebBeranda back to home is added (navigation.md §1.5); the route stack provides it.
- **Redirects and guards.**
  - With no session, every location redirects to `/pilih`. With a session, `/pilih` redirects to `/`.
  - When the assignment the signed-in persona acts in ends during the session (the handover of F20 activating), `SessionNotifier` ends the session and every location redirects to `/sesi-berakhir` (Sambungan, WebSambungan), whose "Masuk lagi" opens the picker (D19).
  - A `Layar` whose module is OFF, or whose capability the actor lacks, renders the matching KeadaanUmum or WebKeadaanUmum view ("Modul tidak aktif", "Tidak berwenang") in place of the screen.
  - `refreshListenable` follows `sessionProvider` and module status.
- **Links.** `Tautan(ke: Layar.x, param: {...}, cara: Cara.dorong | ganti | naik)` replaces the string stems.
  - The resolver turns `Layar` + params into a path.
  - A `Tautan` to a `Layar` whose module is OFF renders nothing, so menus, nav items and home rows react to Modul (D21).
  - A `Tautan` to a `Layar` with no screen for the current `Tata` fails an `assert` in debug, so any flow test on web or tablet that meets a phone-only link fails (D13).
  - `kembaliKe` keeps its pop-or-go behaviour. The pop-down when re-entering a board with child routes stays, because `ShellRoute` keys need it (navigation.md §2.1). The reset that went with it is removed (code.md §5 j).
- **Web URLs.** Hash URLs as today. A reload is a new launch: the state resets (D6) and the app shows the picker.

### 3.7 Timers

- A timer never holds domain state. When a board fakes outside work, the command is issued at once and the repository records the result.
  - Work that must finish after a delay, even if the user navigates away, is scheduled inside the repository on a `Timer` owned by the provider: AI proposals, the Petugas verifikasi activating a handover or a Sekretaris, generating report files.
  - The widget only shows progress.
- Timers that only delay a local effect (a toast that hides, an upload progress bar) stay in the widget.
- Every timer that remains in `lib/screens/` carries a trailing comment `// tiruan: <what it fakes>` on the same line (grep check G9).
- Durations are the board's milliseconds (CONVENTIONS, Behaviour).

## 4. Repository interfaces

These are the proposals of domain.md §3, trimmed to what the boards use. Queries are synchronous. Commands return `Future<Result<T>>` (`Result<void>` where no type is named). The state machine each repository enforces is named next to it (DM §5 and domain.md §2).

**The command envelope (D1).** Every command has this shape, with no exception except `SessionRepository.signIn` and `signOut`, which run before an actor exists:

```dart
Future<Result<T>> name(Actor actor, <the command's own arguments>, {
  required int expectedRevision,   // only on a command that changes an existing aggregate
  required String reason,          // only where a board or the spec gates on a reason
  required String idempotencyKey,  // on every command (engineering-contracts-draft-2026-11-07.md: every command carries one)
});
```

In the tables below, `rev` stands for `required int expectedRevision`, `why` for `required String reason`, `why?` for an optional reason, and `key` for `required String idempotencyKey`. The tables list every command in full under this rule; write them exactly so. M1 and M2 check the envelope mechanically (check C5 in section 9).

### 4.1 Core (M1, every command complete in M1)

| Repository | Queries | Commands | State machine |
| --- | --- | --- | --- |
| `SessionRepository` | `personas()`, `current()`, `devices(personId)` | `signIn(personaId)`, `signOut()` (no actor, exempt), `endDevice(actor, deviceId, rev, key)` | A session ends on sign-out, or when the assignment it acts in ends (3.6) |
| `WorkspaceRepository` | `workspace()`, `modules()` | `setModuleStatus(actor, module, status, why?, rev, key)`: a dependency order is enforced when switching on; switching off needs a reason | Module OFF / ACTIVE / READ_ONLY (PMP §8) |
| `PeopleRepository` | `person(id)`, `search(query)`, `parties()` | `linkPartyToPerson(actor, partyId, personId, rev, key)`, `unlinkParty(actor, partyId, why, rev, key)` | Person UNCONFIRMED → ACTIVE → DECEASED (PMP §5) |
| `OrgRepository` | `scopes({type})`, `scope(id)`, `ancestors(id)` | `createScope(actor, draft, key)` (Panitia, M9) | — |
| `RoleRepository` | `posts({scopeId})` with vacancy, cover and a pending handover, `assignmentsOf(personId)`, `delegations({personId})`, `grants({personId})` | `proposeHandover(actor, postId, toPersonId, documentRef, key)` (the outgoing Bendahara's SerahTerima, DP39); `assign(actor, postId, personId, start, documentRef?, rev, key)` (the authorized church officer, DL21; for the Bendahara and Sekretaris posts it creates a pending AuthorityGrant, "Menunggu verifikasi wewenang", that the Petugas verifikasi activates on the board's timer; at activation the previous holder's term ends, any cover ends, and sessions acting in the old assignment end); `endTerm(actor, assignmentId, end, why, rev, key)`; `coverVacancy(actor, postId, why, rev, key)`; `delegate(actor, task, toPersonId, start, end, key)`; `revokeGrant(actor, grantId, why, rev, key)` | Assignment in force or ended; vacancy is "no holder in force"; delegations expire on their end date (PMP §5); grants pending → active → revoked (DM §3 AuthorityGrant, DL10) |
| `AuditRepository` | `list(filter)` | — (appended by the others) | Append-only |
| `NotificationRepository` | `inbox(personId)`, `unreadCount(personId)`, `preferences(personId)` | `markRead(actor, id, rev, key)`, `setPreference(actor, type, on, rev, key)` | — |
| `FileRepository` | `files(recordRef)` | `attach(actor, recordRef, SampleFile, key)` | A file is a name plus a bundled sample image (domain.md §5 point 8) |
| `ExportRepository` | — | `build(actor, key)` returns a manifest (F18) | — |

### 4.2 Finance (interfaces and queries M2; commands M2–M5)

| Repository | Queries | Commands | State machine |
| --- | --- | --- | --- |
| `SettingsRepository` | `rulesInForce({required Tanggal at})`, `valueInForce(rule, {required Tanggal at})` (the value whose revision `setRule` names), `scheduled()`, `lingkup({at})` | `setRule(actor, rule, on, effectiveFrom, why, rev, key)`: a change takes effect from the 1st of M+1 (D24); `addLingkup(actor, scopeId, effectiveFrom, key)` (F19, from the 1st of a month not running or closed) | A rule value per date; scheduled changes are listed until they take effect |
| `AccountRepository` | `accounts({includeInactive})`, `balance(accountId, {at})`, `balanceByFund(accountId, {at})` | `add(actor, draft, effectiveFrom, key)`, `deactivate(actor, id, effectiveFrom, why, rev, key)`, `assignToUnit(actor, id, scopeId, effectiveFrom, rev, key)` (KasUnit) | Active dates; a used account is never deleted |
| `FundRepository` | `funds()`, `fund(id)`, `balance(fundId, {at})` | `add(actor, draft, effectiveFrom, key)` | — |
| `MasterRepository` | `versions(kind)`, `rows(versionId)`, `pickerRows(kind, date)` | `createDraftVersion(actor, kind, key)`, `editRow(actor, versionId, row, rev, key)`, `setAllowedEffect(actor, versionId, code, effects, rev, key)`, `review(actor, versionId, rev, key)`, `publish(actor, versionId, effectiveFrom, rev, key)` | DRAFT → REVIEWED → PUBLISHED (DM §5.5) |
| `TransactionRepository` | `list(periodId, filter)`, `get(id)`, `drafts({periodId})`, `voucherSeries(series, year)`, `gaps(series, year)` | `createDraft(actor, draft, key)` (allocations make a split), `editDraft(actor, id, patch, rev, key)`, `review(actor, id, rev, key)`, `finalize(actor, id, rev, key)` returns the voucher (a draft of a correction pair books with its partner, both or neither), `finalizeCorrection(actor, originalId, rev, key)` books the reversal and replacement DRAFTs of `originalId` together and returns both vouchers (DM 4.3; `rev` is the reversal's), `cancel(actor, id, why, rev, key)`, `redate(actor, id, newDate, why, rev, key)`, `reverse(actor, id, why, rev, key)`, `correct(actor, id, replacement, why, rev, key)` (the replacement's approval is derived as in `createDraft`; a reversal draft is not edited; a transaction with a refund linked by `refundOf` is not reversed) | DRAFT → REVIEWED → FINALIZED; a material edit or redate returns to DRAFT; DRAFT/REVIEWED → CANCELLED; REVERSED is derived from a posted reversal and only while every affected period is OPEN (DM §5.1). With the second-checker rule in force (D24), `finalize` refuses a draft that someone other than its maker has not reviewed |
| `ApprovalRepository` | `forTransaction(id)` | `recordExternal(actor, txnId, declaration, rev, key)`, `supersede(actor, approvalId, declaration, why, rev, key)` | NOT_REQUIRED; EXTERNAL MISSING → RECORDED, superseded on change; a material change voids it (DM §5.2) |
| `EvidenceRepository` | `forTransaction(id)`, `list(periodId, status)` | `upload(actor, txnId, SampleFile, rev, key)`, `verify(actor, evidenceId, rev, key)`, `reject(actor, evidenceId, why, rev, key)`, `acceptException(actor, txnId, why, rev, key)`, `release(actor, evidenceId, why, rev, key)` | NOT_REQUIRED / REQUIRED_MISSING / UPLOADED / VERIFIED / EXCEPTION_ACCEPTED (DM §5.3). The failed and quarantined states are not reachable (D9) |
| `CaseRepository` | `advances()`, `transits()`, `claims()`, `caseById(id)` with derived outstanding and an overdue flag at today | `issueAdvance(actor, caseDraft, key)`, `settle(actor, caseId, draft, rev, key)`, `returnUnused(actor, caseId, draft, rev, key)`, `collectTransit(actor, caseId, draft, rev, key)`, `remit(actor, caseId, draft, rev, key)`, `recordClaim(actor, claimDraft, key)` returns the claim id, `checkClaim(actor, claimId, rev, key)` ("Cek klaim", returns the case), `payClaim(actor, claimId, draft, rev, key)`, `refund(actor, originalTxnId, amount, {accountId}, why, key)` (D25, pending RD04; the draft carries `refundOf` = the original, and `accountId` defaults to the original's Kas/Bank). Transactions also carry `countedBy` (the offering's Petugas penghitung). Every command except `recordClaim` and `checkClaim` returns `Result<TransactionId>`: it creates the linked transaction as a DRAFT through `TransactionRepository.createDraft`, and that draft goes through the normal review and finalize. Outstanding amounts and case states are derived from FINALIZED linked transactions only. The draft uses the case's Fund (EC06). Persembahan's Titipan part is an allocation of the one offering draft that links the transit case | Advance OPEN / PARTIALLY_SETTLED / SETTLED + overdue; Transit OPEN / PARTIALLY_REMITTED / SETTLED (DM §5.4). A claim is not a DM entity: modelled here (domain.md §1, gap) |
| `ImportRepository` | `batches()`, `rows(batchId)` | `stage(actor, SampleImport, key)`, `validate(actor, batchId, rev, key)`, `reviewRows(actor, batchId, selection, rev, key)`, `commit(actor, batchId, rev, key)`: committed rows become DRAFT transactions (DM §5.5: a staged row blocks close until it is committed and finalized) | STAGED → VALIDATED → REVIEWED → COMMITTED; refused rows kept with their disposition (DM §5.5) |
| `ReconciliationRepository` | `session(accountId, periodId)`, `statementLines(sessionId)`, `cashCounts(accountId)` | `importStatement(actor, accountId, periodId, SampleStatement, key)`, `match(actor, sessionId, lineIds, txnIds, rev, key)`, `markTimingItem(actor, sessionId, txnId, why, rev, key)`, `createTxnFromLine(actor, lineId, draft, key)` (a DRAFT), `review(actor, sessionId, rev, key)`, `confirm(actor, sessionId, rev, key)`, `recordCashCount(actor, accountId, denominations, counters, key)` | Session OPEN → REVIEWED → CONFIRMED; a book change invalidates the confirmation; matching UNMATCHED / PARTIAL / MATCHED (DM §5.5) |
| `PeriodRepository` | `periods()`, `period(id)`, `blockers(periodId)` (computed, DM §6.4), `attestations(periodId)`, `incidents()` | `attest(actor, fundId, periodId, key)`, `waive(actor, fundId, periodId, why, rev, key)`, `clearUnitBlocker(actor, kind, targetId, why, rev, key)` (DL33; `rev` is the target's), `close(actor, periodId, confirmation, rev, key)` returns the snapshot, `recordIncident(actor, periodId, explanation, settlementDraft?, key)` (the settlement is a DRAFT in the open month), `resolveIncident(actor, incidentId, narrative, rev, key)` ("Catat penyelesaian keuangan") | Period OPEN → CLOSED, irreversible, in calendar order (DM §5.5, §6.4, RD01, RD08); attestation CURRENT → INVALIDATED (RD12) |
| `OpeningRepository` | `opening()` | — | Read-only: the cutover is seeded complete (D19) |
| `ReportRepository` | `preview(periodId, perimeter)`, `snapshot(periodId)`, `dataset(source, form)` for F01–F14, `restricted(source, fundId)`, `templates()` | `acceptTemplate(actor, templateId, rev, key)` | PREVIEW → SNAPSHOT; file generation is GENERATED at once (domain.md §5 point 4) |
| `AiRepository` | `budget()` | `propose(actor, kind, input, key)` completes after the board's delay with the board's fixed proposal and adds its cost; `dispose(actor, proposalId, disposition, rev, key)` | No network, ever. "Budget used up" is reached when spend + cost > cap |

### 4.3 Secretariat (M7)

| Repository | Queries | Commands | State machine |
| --- | --- | --- | --- |
| `DocumentRepository` | `list({audienceOf: personId})`, `get(id)` | `publish(actor, draft, signedCopy, audience, key)`, `revise(actor, id, ralat, signedCopy, rev, key)` | Revisions only, with no approval step; a ralat makes a new revision and the old one stays openable (PMP §6.1, proposed) |
| `AnnouncementRepository` | `list({audienceOf})` | `draft(actor, announcementDraft, key)`, `publish(actor, id, rev, key)`, `archive(actor, id, rev, key)` | DRAFT → PUBLISHED → ARCHIVED, auto-archived at the end date (DL14) |
| `WartaRepository` | `editions()`, `edition(id)`, `preview(id)` | `draft(actor, sunday, key)`, `submit(actor, id, rev, key)`, `approve(actor, id, rev, key)`, `publish(actor, id, rev, key)`, `ralat(actor, id, why, rev, key)`, `revealIdentity(actor, editionId, personId, why, rev, key)` | DRAFT → REVIEW → APPROVED → PUBLISHED → ARCHIVED; the Sekretaris performs every step (rulebook §14.7) |
| `LetterRepository` | `requests({personId})` | `request(actor, type, key)`, `recordAtOffice(actor, forPersonId, type, key)`, `issue(actor, id, number, signedCopy, rev, key)`, `refuse(actor, id, why, rev, key)` | Requested → issued or refused (inferred from boards) |

### 4.4 Membership (M8)

| Repository | Queries | Commands | State machine |
| --- | --- | --- | --- |
| `MemberRepository` | `members({kolom})`, `member(id)`, `households()`, `household(id)`, `bipra(personId)` | `overrideBipra(actor, personId, group, why, rev, key)` | BIPRA computed from birth date, sex and marital status with one fixed set of church limits (DL28, domain.md §5 point 10) |
| `VerificationRepository` | `queue(actor)`: applications, life events, data changes and household confirmations, routed by the assignments, delegations and cover in force | `verify(actor, itemId, rev, key)`, `returnForChanges(actor, itemId, why, rev, key)`, `decline(actor, itemId, why, rev, key)` | SUBMITTED → VERIFIED, or returned, or declined; no self-verification (PMP §6.1) |
| `ApplicationRepository` | `application(id)` | `apply(actor, form, consent, key)`, `submitLifeEvent(actor, event, attachment, key)`, `submitDataChange(actor, personId, change, key)`, `confirmHousehold(actor, householdId, rev, key)` | as above |
| `ConsentRepository` | `consents(personId)` | `record(actor, personId, consent, key)`, `withdraw(actor, personId, why, rev, key)`, `requestDeletion(actor, personId, why, key)`, `executeDeletion(actor, requestId, rev, key)` (DL13 keep and delete lists, in memory) | — |
| `MemberImportRepository` | `batches()`, `duplicates()` | `stage(actor, SampleBook, key)`, `resolveDuplicate(actor, caseId, merge or notSame, why, rev, key)`, `commit(actor, batchId, rev, key)` | Staged → checked → imported |
| `MaskingRepository` | `preference(personId)`, `printedName(personId, context)` | `set(actor, personId, preference, rev, key)` | — |

### 4.5 Collaboration (M9)

| Repository | Queries | Commands | State machine |
| --- | --- | --- | --- |
| `PanitiaRepository` | `list()`, `get(id)` | `create(actor, skDocumentId, officers, key)` (three distinct officers), `advanceStage(actor, id, why?, rev, key)`, `approveLeftover(actor, id, destinationFundId, rev, key)` | PLANNING → ACTIVE → EVENT COMPLETED → FINANCIAL CLOSING → CLOSED → ARCHIVED (rulebook §14.4, DL27) |
| `ServiceRepository` | `list({scopeId})`, `get(id)` | `draft(actor, serviceDraft, key)`, `approve(actor, id, rev, key)`, `close(actor, id, rev, key)` | Draf → Dijadwalkan → Selesai → Ditutup (board labels; no spec state machine, domain.md §2) |
| `AttendanceRepository` | `count(serviceId)` | `assignCounter(actor, serviceId, personId, post, rev, key)`, `increment(actor, serviceId, post, n, rev, key)`, `submitForReview(actor, serviceId, rev, key)`, `returnToCounter(actor, serviceId, why, rev, key)`, `finalize(actor, serviceId, rev, key)`, `correct(actor, serviceId, value, why, rev, key)` (keeps both values) | LIVE → REVIEW → FINALIZED (rulebook §14.9); the approver finalizes and counters only count (DL30) |
| `FundRequestRepository` | `list({personId})`, `get(id)` | `submit(actor, requestDraft, key)`, `approve(actor, id, rev, key)`, `refuse(actor, id, why, rev, key)`, `changeAmount(actor, id, amount, why, rev, key)`, `recordPayment(actor, id, rev, key)` (creates the Uang Muka diberikan draft through `CaseRepository.issueAdvance`; "Dibayar" once that draft is finalized) | Diajukan → disetujui / tidak disetujui / jumlah diubah → dibayar (board labels); IN_APP approval PENDING → APPROVED / REJECTED, reset to PENDING on a material change (DM §5.2); no self-approval; below the threshold no approval is needed (DL29) |
| `ApproverTableRepository` | `table()` | `set(actor, unitType, approverRole, threshold, rev, key)` | Defaults until filled (DL29) |

Unit finance reuses `TransactionRepository`, `ReconciliationRepository` and `PeriodRepository`. A unit treasurer finalizes only in their own Fund and only on accounts their unit operates (DL26, DL32). The church Bendahara may clear a unit's blockers with a reason (DL33).

### 4.6 Simplifications (domain.md §5)

Keep the signatures above whole. Implement them simply:

1. **Posting.**
   - Use the transaction types of DM §4.2 with a sign table: account delta, fund delta, I, E, Tin, Tout, and the case delta.
   - No persisted journal legs, `posting_sequence` or cash movement groups.
   - One debug `assert` in `SeedStore`: the account totals equal the fund totals.
2. **Vouchers.** One counter per series per year (5.5).
3. **Reports.**
   - F01, F02, F03, F05, F07, F10 and F12 are computed from state for any month.
   - The close snapshot is a deep copy of the datasets, with no hashes.
   - F04, F06, F08, F09, F11, F13 and F14 come from the same sums.
4. **Close.**
   - The blocker list of DM §6.4 is evaluated against state.
   - No locking, cutoffs or render queues.
5. **Reconciliation.**
   - Matching is on exact amounts and confirmed by a person.
   - "Cocokkan" suggestions return the board's fixed pairs (mock-data §2.11).
6. **AI.** The board's fixed proposal per input, plus a budget counter.
7. **Capabilities.** As in 3.5.
8. **Evidence and files.** Status changes only. No checksum.
9. **Approval.** External declarations, plus in-app approvals for fund requests only. No quorum.
10. **Membership.**
    - BIPRA is computed (see `MemberRepository`).
    - Deletion runs the DL13 lists in memory.
11. **Time.** Every seed date is an anchor relative to the launch date (5.3).

## 5. The seed

### 5.1 The story

One church, Jemaat Karunia (GMIM, time zone WITA, fiscal year from 1 January), on its third month of recording.

- **Recording.**
  - Recording started at the cutover on day 15 of M−2.
  - M−2 (the drawn September) is closed.
  - M−1 (October) is open and next to close.
  - M0 (November) is the running month.
- **Sources.**
  - Figures: seed.md §1 and mock-data.md §2.
  - Situations each board needs: seed.md §4.
- **Invented rows** (D10), in the boards' style:
  - about 18 transactions in M−2 that take the three church accounts from their opening Rp32.300.000 to the drawn Rp36.250.000 on day 1 of M−1 (Kas Kolom 7's Rp920.000 is on top of both figures, DP16);
  - bulk members and households per Kolom, to the drawn counts (1.284 active members, 412 families, Kolom 7 with 96 members and 31 families, 318 imported rows of which 241 are unconfirmed);
  - the allocated but unfinished voucher numbers of Data pick DP7.
- No other story lines, and no balancing rows (D11).

### 5.2 People and personas

The 23 named people of seed.md §1 are seeded except Deitje Kawengian (DP20), plus the Petugas verifikasi (a system actor from Tim Palakat, used only by the board timers that stand for verification). Posts, delegations and families follow mock-data §2.2–2.3 and roles.md §1, as amended by the Data picks.

The picker (D17) offers exactly these 11 personas. Each one lands on BerandaJabatan or WebBerandaJabatan (D20).

| Persona | Post line on the picker | Posts in the seed | Web footer (navigation.md §1.3) |
| --- | --- | --- | --- |
| Meiske Lumentut | Bendahara Jemaat | Bendahara Jemaat since `bln(-2, 15)`, SK-BPMJ-04 | "Meiske L. · Bendahara / Wewenang Bendahara aktif" |
| Olvie Pangemanan | Sekretaris Jemaat | Sekretaris Jemaat, Aktif since `hariLalu(3)` (SK BPMJ No. 12) | "Olvie Pangemanan · Sekretaris Jemaat" |
| Yanti Sumual | Operator · menjalankan Penatua Kolom 2 | Operator since `bln(0, 1)`; covers the vacant Penatua Kolom 2 since `bln(0, 1)`, the day after Altje's term ended (`akhirBln(-1)`); counter at Pintu depan | "Yanti Sumual · Operator", and the vacancy footer while she covers the Bendahara post |
| Pdt. Lidya Rondonuwu | Ketua Jemaat · Pimpinan Jemaat yang berwenang | Ketua Jemaat, Ketua BPMJ, authorized church officer, exception authority, default in-app approver | "Pdt. Lidya Rondonuwu · Ketua Jemaat / Pimpinan Jemaat yang berwenang" |
| Pnt. Hendrik Rumagit | Penatua Kolom 7 · Ketua Komisi Diakonia | Penatua Kolom 7, Ketua Komisi Diakonia | "Pnt. Hendrik Rumagit · Penatua Kolom 7" |
| Novita Wenas | Anggota jemaat · Kolom 7 | Member since 2021, as drawn (D22, `sejarah`); BIPRA Pemuda from her shifted birth date | — (phone screens; web home only) |
| Deasy Tumbelaka | Bendahara Kolom 7 | Unit treasurer, Kas Kolom 7 | — |
| Dkn. Olga Tamba | Bendahara Komisi Diakonia · Akses terbatas Diakonia | Unit treasurer Komisi Diakonia; Fund-only viewer Diakonia; counter | "Dkn. Olga Tamba / Akses terbatas: Peruntukan Diakonia" |
| Pnt. Jefry Wowor | Pemeriksa kedua · Wakil Ketua BPMJ | Checker, Wakil Ketua BPMJ | "Jemaat Karunia / Wajib pemeriksa kedua: hidup" |
| Sdr. Rivo Mandagi | Bendahara Panitia Natal 2026 · Ketua Pemuda | Panitia Natal Bendahara, Ketua Pemuda, preparer of the Pembangunan readiness | — |
| Sym. Greis Mamahit | Syamas Kolom 7 · menerima pelimpahan | Syamas Kolom 7; delegate of Hendrik for "Verifikasi data Kolom 7" from T to T + 14 days; counter at Pintu samping | — |

- **Who may act.** The acting post is chosen as PMP and the boards say: automatically when exactly one post can act, and asked ("Sebagai …", the AlurBeranda moment) when two can (Q31, screens/14).
- **Homes without a drawn view.** Lidya, Deasy, Olga, Jefry, Rivo and Greis have no drawn BerandaJabatan view. Their home rows come from their open items, using the row kinds the drawn views use.
- **The picker screen** (`lib/screens/pemilih/pemilih_persona.dart`, new, `/pilih`):
  - the title "Masuk sebagai";
  - one row per persona with name and post line, grouped under the role headings of the deleted `shell/perjalanan.dart` (copy them before deleting);
  - built from existing widgets and tokens.
  - Tapping a row signs in. There is nothing else on the screen.

### 5.3 Date shift (D8)

The seed is built from the launch date `T` (WITA) by `buildSeed(anchor: T, now:)`. The prototype's dates are story dates around the story today, 16/11/2026, a Monday at 12.05. `lib/data/seed/jangkar.dart` gives one helper per rule of seed.md §2. Seed files never contain a literal date, except history facts passed through `sejarah`.

| Rule | Helper | Use for |
| --- | --- | --- |
| Month anchor | `bln(m, d)` = day `d` of month M+m, where M is T's month, clamped to the month's length; `akhirBln(m)` = its last day | Every date in M−2 and M−1, dates fixed to a month in the future (the 1st of M+1, due at the end of M0), and the history dates that drive a computed age or a term in force (birth dates, terms since 01/01). They take the same month shift, so ages and terms stay the same, and Novita stays 30 for the BIPRA Pemuda rule |
| History fact | `sejarah(y, m, d)` = that date unchanged | Dates that only print and drive no computation: member since 2021 (D22), Baptism 1996 |
| Sunday anchor | `minggu(m, n)` = the nth Sunday of month M+m; `mingguLalu(k)` = the k-th Sunday on or before T, clamped to day 1 of M0 or later | Offerings, Warta editions and services. 04, 11, 18 and 25/10 become `minggu(-1, 1..4)`; 15, 08 and 01/11 become `mingguLalu(1..3)` |
| Today anchor, ledger | `hariCerita(d)` = T − (16 − d) days for d ≤ 16, clamped to day 1 of M0 or later; for d > 16, the first date on or after T + (d − 16) days that falls on the drawn weekday | M0 ledger and close records up to today (transactions, drafts, settlements, evidence, reconciliation lines), which must stay in M0 because M−1's figures are frozen, and future events (Kamis 19/11, Sabtu 21/11, Rabu 25/11, Warta 22/11, Adven I 29/11) |
| Today anchor, other records | `hariLalu(d)` = T − (16 − d) days for d ≤ 16, with no clamp | Past M0 dates of records outside the ledger: assignment starts, delegations, letter and life-event dates. A delegation drawn as ended (the Sekretaris to Yanti, story days 3–10) runs `hariLalu(3)` to `hariLalu(10)`, so it has ended at any T |
| Time of day | `jam(h, m)`, applied after anchoring to every seeded time that lands on today: if any of them is later than now, all of today's seeded times map linearly, in story order (story date, then time), onto 00.00 to now | No seeded time is ever later than now, also when T is day 1 and `hariCerita` clamps earlier story days (14/11 20.15, 15/11 16.20) onto today |
| Labels | `bulanTahun(tanggal)` from `core/format.dart` | Every month or period label ("Mei 2027", "Periode laporan 1–30 April 2027", "Hidup mulai Juni 2027"). Descriptions that carry a date or month ("Sentralisasi November", "Persembahan khusus 9 November") are built from the shifted date. Story names (Panitia Natal 2026, Panitia Paskah 2026, Minggu Adven I, katekisasi sidi 2027) stay exactly as drawn |

### 5.4 Edge cases (seed.md §2)

| Case | Rule |
| --- | --- |
| T in January | M−2 is November and M−1 is December of the year before. M0 vouchers restart at `BKU-{Y}-0001`. Year-to-date never claims anything before the cutover (DM RD05) |
| T in February | M−1 (January) and M0 share year Y's series; M−2 keeps the series of year Y−1 |
| Short months | Days past the end clamp to the last day; rows on the same day keep their ordinal order |
| T on day 1 to 6 | M0 may have no Sunday yet. `mingguLalu` and `hariCerita` clamp to day 1 of M0, so nothing slips into M−1, whose figures are frozen. Many M0 events then share day 1, and on day 1 that is today, so `jam` compresses their times (5.3) |
| Overdue advance um2 | Its due date is T − 6 days, and never earlier than its issue date (day 20 of M−1) |
| Seasonal names | Kept as drawn (D8), even when T is far from Christmas. Listed in the open items |
| The app running past midnight | The anchor stays fixed at launch. New records use the live clock |

`buildSeed` asserts these invariants, so that every flow test checks them:

- no seeded date or time is after now;
- every assignment start is on or before T, and every delegation drawn as ended has its end before T;
- account totals equal fund totals;
- the M−1 ledger (the drawn October) ends at the computed balance the October rows give.

P3 calls `buildSeed` for every day of the 366 days from `jangkarA`, at 00.01 and at 23.59, so these asserts run on every launch date, not only on the test anchors.

### 5.5 Vouchers and other identifiers

- **Vouchers.**
  - Each voucher is `BKU-{year of effective date}-{NNNN}`, numbered per series per year (DM D08, RD13).
  - `buildSeed` numbers every seeded voucher through the same counter the app uses (DP38). It walks the seeded rows in the boards' posting order (the drawn numbers, ascending) and gives each the next number of its own year's series. The allocated but unfinished numbers of DP7 take their number in the same walk. So:
    - posting order still differs from date order (the drawn 0112 and 0113 are dated after 0114);
    - every year's series runs from 0001 with no hole except the DP7 records, and the gap list is exactly those records;
    - a year boundary needs no extra rule: a row's year is its shifted effective date's year.
  - The screens therefore show computed numbers, not the drawn ones (at `jangkarA` September runs from 0001 and October starts right after it, not at the drawn 0098). This plan and the Data picks name a seeded row by its drawn number ("the drawn 0143"); the seed keeps that drawn number as a lookup key only.
  - New postings take the next free number. Tests assert "the next free number", never a literal (flows.md §0).
- **Other series and identifiers.**
  - `OPN-{cutover year}-0001`.
  - ADJ is listed but never used.
  - The snapshot is `SNP-{year}-{month of the closed period}-01`.
  - Incidents are `K-{year of recording}-NN`, numbered in order. The seeded incident is `K-{y}-01`; the live one F16 records takes the next number (DP18).
  - Letters are `NNN/SKet/{Roman month}/{year}`.
  - SK numbers take the year of their record's date.
  - File names are built from the shifted day and month (`nota-{dd}-{mm}.jpg`).
  - Mata Anggaran: `{cutover year}.1` is published. The draft takes the next number and is effective from M+1; it becomes `{Y+1}.1` when M+1 falls in a new year.

### 5.6 State at launch

- **Periods.** M−2 CLOSED, at M−1 day 5 19.02 by Meiske. M−1 OPEN and next to close. M0 OPEN, the running month. M+1 empty.
- **Close blockers on M−1** are computed (DM §6.4). With the seed they are:
  - BNI not reconciled;
  - the Kas count;
  - the SulutGo statement;
  - the Kas Kolom 7 reconciliation and the Kolom 7 draft dated M−1 day 28 (DP14);
  - the Kolom 7 readiness, missing (Deasy is its preparer);
  - the Diakonia readiness, out of date (Olga);
  - the Pembangunan readiness, missing (Rivo).
  
  The boards' "1 hambatan" is therefore not reproduced (D11).
- **Readiness attestations for M−1** (RD12, DM §3 ReadinessAttestation, DP37). An attestation is needed for each Fund that has a scoped preparer and activity or a balance in the period: Kolom 7 (missing), Diakonia (INVALIDATED by a later Diakonia posting) and Pembangunan (missing). Umum Jemaat has no scoped preparer, so no attestation applies to it, and the BIAYA ADM fee F15 posts in Umum invalidates nothing. Panitia Natal has no activity and no balance (DP27). Any posting in a Fund after its attestation invalidates it again, so a flow attests after the Fund's last posting.
- **Modules.** All 10 are ACTIVE (D21).
- **Rules in force (D24).**
  - The second checker ("Wajib pemeriksa kedua") is on, seeded in `seed_keuangan.dart` (M2) as a `SettingsRepository` rule value: every finalize needs a review by someone other than the maker. It covers unit treasurers' bookings too (Deasy, Olga, Rivo). No unit checker is drawn, so Pnt. Jefry Wowor, the Pemeriksa kedua, checks every booking in the workspace.
  - Turning it off in Lainnya or WebPengaturan (`SettingsRepository.setRule`, M5) says it stops from M+1, and it stays on for M0.
- **Posts.**
  - Bendahara: Meiske, in office (D18).
  - Penatua Kolom 2: vacant since Altje's term ended at `akhirBln(-1)`, with Yanti covering from `bln(0, 1)`.
  - Syamas Kolom 3: vacant, with no cover.
  - Sekretaris: Olvie, Aktif since `hariLalu(3)`.
  - The past delegation from the Sekretaris to Yanti (`hariLalu(3)` to `hariLalu(10)`) has ended. Hendrik's delegation to Greis (T to T + 14 days) is in force.
- **Open items.**
  - Finance: the drafts, cases, documents, imports, reconciliations and AI spend of seed.md §4, "Finance conditions".
  - Membership: Kevin's submitted application in the Kolom 2 queue (D22, DP36), Yohanis Rompas's death pending in the Kolom 2 queue, Gabriel's Baptism, Gabriela's Sidi, Ferry's unconfirmed family, the Keluarga Lasut Kolom move effective the 1st of M+1, the Rumagit change forwarded to Greis, and the Sumual change (Yanti's own family).
  - Secretariat and collaboration: Novita's letter request, 2 Atestasi requests, and Hendrik's Komisi Diakonia fund request of Rp750.000 waiting for Lidya.
- **Excluded as staged faults** (D9): everything in seed.md §4, "Excluded as staged faults".

### 5.7 Seed files and owners

So that no worker in a parallel batch has to touch a shared file (10.1):

- M1 writes `build_seed.dart` already calling every seed function of the table below, in table order, and M1 creates each seed file as an empty function, `void seed<Name>(SeedStore store, Jangkar a) {}`.
- `SeedStore` holds one tables object per module, `TabelInti`, `TabelKeuangan`, `TabelSekretariat`, `TabelJemaat` and `TabelKolaborasi`, each in its own `lib/data/seed/tabel_<modul>.dart`. M1 writes `TabelInti` complete and the other four as empty classes.
- The milestone named below owns its seed file. The milestone that builds a module's interfaces owns its `tabel_<modul>.dart`: M2 for finance (complete in M2, so M3–M5 only fill their seed files), M7, M8 and M9 for theirs.

| File | Milestone | Content |
| --- | --- | --- |
| `seed_inti.dart` | M1 | Workspace, people and parties, scopes (12 Kolom, BIPRA, Komisi, Panitia), posts, assignments, delegations, grants, modules, devices and sessions, core notifications |
| `seed_keuangan.dart` | M2 | Accounts, funds, Lingkup, Mata Anggaran versions, the opening batch, every M−2, M−1 and M0 transaction and draft, the DP7 records, the voucher numbering of 5.5, the second-checker rule value, AI spend |
| `seed_keuangan_kasus.dart` | M3 | Cases, approvals, evidence, import batches |
| `seed_keuangan_akhir_bulan.dart` | M4 | Statements, reconciliation sessions, cash counts, attestations (5.6), the seeded incident `K-{y}-01` (DP18), report template acceptance |
| `seed_keuangan_pengaturan.dart` | M5 | Scheduled settings (`SettingsRepository.scheduled`), history lines of the cutover and settings |
| `seed_sekretariat.dart` | M7 | Church documents, announcements, Warta editions, letter requests |
| `seed_jemaat.dart` | M8 | Member profiles (bulk per Kolom), households, consent, applications, life events, import rows, duplicates, masking |
| `seed_kolaborasi.dart` | M9 | Panitia, services, attendance counts, fund requests, approver table, unit finance rows |

### 5.8 Data picks (D23)

Each row is one conflict and the version the seed uses. "MD §3 #n" is row n of `docs/build/mock-data.md` §3. The owner may veto any row; a veto changes only seed data or one rule.

| # | Conflict | Pick | Source |
| --- | --- | --- | --- |
| DP1 | Saldo buku Rp38.415.000 vs Rp38.465.000; BNI Rp24.615.000 vs Rp24.600.000; Kas and SulutGo per month (MD §3 #1–3) | Not conflicts: different moments. Every balance is computed for its date | MD §3 #1–3, seed.md §3 |
| DP2 | Diakonia balance Rp3.700.000 vs Rp4.200.000 (MD §3 #4) | Computed from the seed rows | D11, seed.md §3 |
| DP3 | Fotokopi warta jemaat: draft dated 14/11 or 16/11, BKU-2026-0147 (MD §3 #5, #6) | One draft, Kas, −Rp150.000, dated `hariCerita(14)` (Main, PilihBulan and WebPemeriksa against WebTransaksi). Not posted in the seed; a flow that books it gets the next free number | Majority of boards |
| DP4 | Reused numbers 0150, 0151, 0152, 0153 (MD §3 #7–9) | 0150 is the Retret Pemuda settlement and 0151 the Kolom 7 Persembahan Ibadah Kolom (DP15). The rows that Pemeriksa, AlihPeruntukan, WebKasusBaru and Kewajiban create are made by flows and take the next free numbers | domain.md §5 point 2 |
| DP5 | Persembahan Ibadah Minggu of the last Sunday: BKU-0146 Rp3.450.000 vs a new posting BKU-0148 in parts Rp3.600.000 (MD §3 #10) | 0146, Rp3.450.000, is seeded as posted (Main, WebTransaksi and Bukti against Persembahan and WebPersembahan). Flow F4 records the Persembahan board's parts as a new posting. There is no duplicate check, because no board draws one, so after F4 that Sunday counts twice | Majority of boards; open item |
| DP6 | Who posted 0146, who closed October (MD §3 #11, #19) | Each record's audit actor: Meiske for seeded postings. A close is recorded under whoever closes it in the app | DM §3 AuditRecord |
| DP7 | Unused voucher numbers | 0111, 0124 and 0126 as drawn. 0133, 0147 and 0148 are also seeded as "nomor diberikan, pembukuannya tidak selesai", because their rows are now made by flows (the October fee in F15, the Catat posting, the parts offering). All six are numbered in the walk of 5.5. The gap list therefore shows 6 numbers at `jangkarA`, all in one year's series. At `jangkarB` it shows 4 in the series of M−1's year (the drawn 0111, 0124, 0126, 0133) and 2 in M0's (the drawn 0147, 0148) | D10, D11 |
| DP8 | The October bank fee BKU-0133 is in F02 but is created on the TutupBuku and RekonIsi boards (mock-data §2.11) | Not seeded. F15 creates it from the "BIAYA ADM" statement line, and it takes the next free number. October totals after the close then equal F02's ending figure plus the Kas Kolom 7 line (DP16) | Boards' flow wins over the printed report (D11) |
| DP9 | Selvie Kalalo's advance and the Rp75.000 overspend claim, web only (MD §3 #12) | Seeded: F02 0119, F14 and WebKewajiban all carry it. Phone Kewajiban shows it too, because it is computed | Majority of boards |
| DP10 | Advance settlements dated November, October Rp0 (MD §3 #13) | Not a conflict: seeded in M0 | MD §3 #13 |
| DP11 | Report format approval: 03/10 vs 01/11 vs 02/11 (MD §3 #21) | One record, M−1 day 3 at 10.15, by Meiske (A4F01, Lainnya riwayat, WebPengaturan riwayat) | Majority of boards |
| DP12 | 4 vs 5 Lingkup (MD §3 #22) | 5, including Komisi Diakonia: it is a Scope in the platform plan, so the forms list it | Spec (PMP §5) |
| DP13 | Mata Anggaran rows 2.2.01.02.00, 2.1.01.02.00, 1.4.10.03.00, and the "Baru" tags (MD §3 #23–26) | 2.1.01.02.00 and 1.4.10.03.00 are in 2026.1 (F02 and F05 use them). 2.2.01.02.00 takes its 2026.2 name. "Baru" is computed: shown only for rows not in the published version. The text "2 baris baru · 1 nama berubah" is computed too | seed.md §3 |
| DP14 | The Kolom 7 blocking draft: −Rp150.000 vs Rp185.000; "terhalang 2 hal" vs "1 hal" (MD §3 #14, #15) | One Kolom 7 draft "Konsumsi ibadah Kolom", −Rp150.000, on Bank BNI ··4821, dated M−1 day 28 (SelesaikanUnit and KeuanganUnit against AlurUnit). Deasy cannot finalize it on a church account (DL32), so it blocks M−1 until the Bendahara clears it (DL33). "Bantuan duka" −Rp200.000 from the Diakonia fund is a second Kolom 7 draft, in M0, refused for the unit. Blocker counts are computed | Majority of boards; DL32, DL33 |
| DP15 | BKU-0151, Persembahan Ibadah Kolom Rp320.000, booked 12/11 or 17/11 (MD §3 #7) | Booked by Deasy on Kas Kolom 7 at `hariCerita(12)`. 17/11 is after the story today | seed.md §3 #35 |
| DP16 | Kas Kolom 7 against "semua Kas/Bank" Rp38.415.000, and F10/F11 listing 3 accounts (seed.md §3, new conflicts) | Kas Kolom 7 is a workspace account operated by Kolom 7. It enters the cutover opening with Rp920.000 in the Kolom 7 fund and has no M−1 movement, matching the drawn October count 920 = 920. Every "semua Kas/Bank" total and every report covers all workspace accounts, and LaporanLintas splits by unit. Awal therefore shows 4 Kas/Bank and a higher opening total than drawn | DM §6.4 (one close covers every account); DL32 |
| DP17 | Honor pemusik draft: 08/11 BNI no MA, 15/11 with MA, 28 September, imported 08/11 (MD §3 #27) | Two drafts. (a) M0 `hariCerita(8)`, BNI, −Rp650.000, no Mata Anggaran (Main, WebTransaksi); together with DP3 these are the "2 draf · Rp800.000". (b) The Draf board's draft dated M−2 day 28, created in M0 after M−2 closed, so it never blocked that close (RD09) and F10 can move or cancel it. The Impor row stays a staged import row | Majority of boards; RD09 |
| DP18 | October Kas count: selisih Rp0 vs "+Rp85.000" on Kejadian (MD §3 #20) | Rp0 at the close (F10, F11). The +Rp85.000 finding is the incident F16 records after F15 closes M−1. The drawn K-2026-02 (a supporting document that arrived late, in closed M−2) is seeded as `K-{y}-01`, the first of its recording year. The live incident takes the next number: `K-{y}-02` at `jangkarA`. The boards draw the live one as K-2026-01; the order of recording wins (5.5) | Majority of boards; RD08 |
| DP19 | Penatua Kolom 2 vacancy: Altje's term ended vs Yohanis Rompas's death (MD §3 #16, #17) | Altje's term ended at the end of M−1, and Yanti covers from day 1 of M0 (Penugasan, AlurJabatanKosong, BerandaJabatan, AntreanVerifikasi). Yohanis Rompas's death is a pending life event in the Kolom 2 queue (the AntreanVerifikasi version), not yet verified. The two are unrelated | Majority of boards |
| DP20 | The new Bendahara: Yohanis Tumbelaka vs Deitje Kawengian (MD §3 #18) | Yohanis Tumbelaka, appointed live through the handover (D18). Deitje Kawengian is not seeded | D18 |
| DP21 | Ferry Wenas in Kolom 7 vs Kolom 2 (MD §3 #28) | Kolom 7, unconfirmed (ImporBuku, KonfirmasiKeluarga, AlurKeluarga). The Kolom 2 membership request on AlurJabatanKosong is Kevin's (D22) | Majority of boards; D22 |
| DP22 | Wenas-Lasut sampul syukur dated 01/11 vs 08/11 (MD §3 #29) | `mingguLalu(3)` (the 01/11 Sunday), BKU-0132 (PersembahanSaya, PersembahanBernama) | Majority of boards |
| DP23 | Novita's display name (MD §3 #30) | Seeded from the TampilanNama board's initial choice; every other screen computes from it | One source of truth |
| DP24 | Novita applying vs active since 2021 (MD §3 #31) | Active since 2021, kept as drawn through `sejarah` (5.3); Kevin is the applicant (D22) | D22 |
| DP25 | Sunday attendance 231 vs corrected 236; who finalizes the Sunday count, Hendrik (Kehadiran) or the Ketua Jemaat (MD §3 #32) | The last Sunday's "Ibadah Minggu pagi" count is seeded Ditetapkan at 231 (Pintu depan 142, Pintu samping 89), finalized by Pdt. Lidya. A Jemaat-wide service is approved by the Ketua Jemaat (DL11), and whoever approves finalizes (DL30). The correction to 236 is a live action. Hendrik approves and finalizes Kolom 7 services (P15) | Specs win on rules: DL11, DL30 |
| DP26 | Modules off or read-only on the Modul board vs boards acting as active (MD §3 #33) | All ACTIVE (D21) | D21 |
| DP27 | Panitia Natal money: saldo Rp4.350.000 (Panitia, LaporanLintas) vs Rp350.000 (AlurPanitia) vs advance remainder Rp650.000; "Kas Panitia Natal" only as text (MD §3 #34, #39) | Advance um1 belongs to Umum Jemaat, as drawn ("BKU-2026-0129 · … · dari peruntukan Umum Jemaat", mock-data §2.10). One case has one Fund, so its settlements and the return of its remainder are in Umum too (DM §3 AdvanceCase, EC06). The Panitia Natal 2026 fund holds no seed rows, so its own balance is computed as Rp0. The money the Panitia works with is um1 (Rp1.500.000, Rp850.000 settled), so "Sisa uang" on closing is the advance remainder, Rp650.000 (Panitia, Kewajiban). P16 closes the Panitia by returning that remainder into Umum (`CaseRepository.returnUnused`), with no alih peruntukan. No rows are invented to reach Rp4.350.000 (D11). There is no Kas Panitia Natal account until KasUnit creates one live | D11; DM EC06; majority on Rp650.000 |
| DP28 | Dates after the story today (MD §3 #35) | Drawn later states are actions in flows. Scheduled future events (Ibadah Kolom on the next Thursday, the Warta of the next Sunday, Adven I, the Lasut move, the due date at the end of M0, the Panitia closing date) use the future anchors of 5.3 | seed.md §3 |
| DP29 | Draft counts and row counts: "2 draf", "12 transaksi", "33 transaksi", "51 baris", "21 transaksi" in September (MD §3 #36, #38; seed.md §3 new conflicts) | Computed | D11 |
| DP30 | Second checker off (Lainnya) vs on (Pemeriksa) (MD §3 #37) | On at launch (D24) | D24 |
| DP31 | Sekretaris status: Aktif vs "Menunggu verifikasi wewenang" (MD §3 #40) | Aktif. The waiting state is reached live when a new Sekretaris is assigned | Majority of boards |
| DP32 | November Pendapatan Rp7.540.000 and Belanja Rp7.940.000; November cash flow vs the drawn balances (seed.md §3 new conflicts) | Computed from the seeded M0 rows: 0129, 0132, 0134–0146, 0149, 0150, 0151, the two rows the drawn cases need (0133a, Selvie's advance spent, Belanja Rp300.000, DP9; 0138b, tt2's Titipan Rp450.000 into Kas), the Sinode Titipan collections (0132a, 0132b, 0138a, 0146a), and the drafts | D11 |
| DP33 | The Sewa kursi ibadah padang draft (Pemeriksa, WebPemeriksa) | Not seeded, so "2 draf" stays true at launch. The Pemeriksa queue shows the real drafts awaiting a check | Majority of boards (Main, WebBeranda, KotakMasuk) |
| DP34 | Sambungan and Memuat: offline, failed load, "Bukukan tidak terjadi", three session-ended variants | Memuat and WebMemuat, and the offline, retry and failed-save states of Sambungan and WebSambungan, are dropped: no real condition reaches them in an in-memory app (D9). Sambungan and WebSambungan stay as `Layar.sesiBerakhir` with the session-ended view only, in the "wewenang berpindah" variant, which a real state reaches: the handover activating while the outgoing Bendahara is signed in (F20). That variant gains the "Masuk lagi" button of the other variants, opening the picker (D19). The "lama tidak dipakai" and "diakhiri dari perangkat lain" variants are dropped: there is one session on one device and no idle timeout | D9, D19 |
| DP35 | Kehadiran "Petugas penghitung" and "Koreksi" views; Ibadah Kolom 7 approver Hendrik or Greis | Real states: a counter sees the counter view and is refused "Tetapkan"; the approver corrects with a reason and both values are kept | DL30 |
| DP36 | PermohonanAnggota and AlurAnggota are drawn from the applicant's side (Novita), but the applicant is Kevin, who is not a persona (D17, D22) | The screen opens a submitted application, `/permohonan-anggota/:id`, from AntreanVerifikasi. Yanti (cover of Penatua Kolom 2) sees Kevin's form read-only and acts with AlurAnggota's verifier side ("Verifikasi data", "Kembalikan dengan alasan"). The empty applicant form and "Ajukan permohonan" are reachable by no persona, because every persona is already a member; they are kept in the code behind the `membership.apply` capability, which no persona holds | D17, D22; open item |
| DP37 | Which Funds need a readiness attestation to close M−1 (RD12 "applies once scoped preparers exist") | Per Fund: only Funds with a scoped preparer and activity or a balance in the period, that is Kolom 7 (Deasy), Diakonia (Olga) and Pembangunan (Rivo). Umum Jemaat has none. Kolom 7's is seeded missing, so F15 has Meiske waive it through SelesaikanUnit with a reason (DL33), and F23 has Deasy attest it | DM §3 ReadinessAttestation, §6.4 step 5; DL33 |
| DP38 | Voucher numbers: September has 21 transactions but the drawn numbers run to 0097 (seed.md §3), so drawn numbers leave dozens of untraceable holes, and a year boundary moves rows between series | Every seeded voucher is numbered by the app's own counter in the boards' posting order (5.5). The screens show computed numbers; drawn numbers are only lookup keys. The gap list is exactly the DP7 records | DM §8 F12 (gaps traceable, numbers not recycled); D11 |
| DP39 | Who assigns the new Bendahara: SerahTerima draws Meiske handing over and Yohanis Tumbelaka activating after verification; DL21 says the authorized church officer records every role assignment | Meiske prepares the handover in Bendahara `serah` or WebSerahTerima (`RoleRepository.proposeHandover`, with the church document). Pdt. Lidya, the authorized church officer, records it in Penugasan (`assign`), which shows "Menunggu verifikasi wewenang". After the board's timer the Petugas verifikasi activates it: Yohanis is "aktif sejak {today}", Meiske's term ends, and a session Meiske still has open ends on Sambungan (DP34). F20 and F25 use the same `assign` path | Spec wins on rules (D23): DL21, DL10 |

## 6. What is deleted and what replaces it

### 6.1 Deleted (D5, D14, D19)

All paths are under `prototype/`.

| What | Paths | Milestone |
| --- | --- | --- |
| Generated registry and router | `lib/boards.dart`, `lib/router.dart` | M0 |
| Launcher and journeys | `lib/shell/peluncur.dart`, `lib/shell/perjalanan.dart` (copy its role headings into the picker first) | M0 |
| Keadaan panel and device frame | `lib/shell/panel_keadaan.dart`, `lib/shell/bingkai_perangkat.dart` | M0 |
| Tweaks and prototype devices | `lib/shell/prototipe_state.dart`, `lib/shell/perangkat_prototipe.dart`, and every `AlatPrototipe` wrapper (19 screen files and `lib/widgets/alur_kit.dart`, including its "Dilihat sebagai" chips) | M0 |
| Reset machinery | `lib/shell/kendali.dart` (`ulangPapan`, `GenerasiPapan`, `DenganGenerasi`) and every use | M0 |
| Gallery and stubs | `lib/shell/komponen_galeri.dart`, `lib/shell/belum_dibangun.dart` | M0 |
| Design sheets (not app screens) | `lib/screens/sistem/` (`peta_layar.dart`, `cakupan.dart`, `keputusan.dart`, `peta_platform.dart`) | M0 |
| Sign-in boards (D19) | `lib/screens/lengkap/masuk.dart`, `masuk_langkah.dart`, `web_masuk.dart`, `pemulihan.dart`, `web_pemulihan.dart`; `lib/screens/p2/alur_masuk.dart`, `alur_masuk_isi.dart`, `web_alur_masuk.dart` | M0 |
| Internal Palakat page (D19) | `lib/screens/lengkap/web_verifikasi.dart` | M0 |
| Fault-only boards (DP34) | `lib/screens/lengkap/memuat.dart`, `memuat_isi.dart`, `web_memuat.dart`. Sambungan and WebSambungan stay, cut to their session-ended view in M1 | M0 |
| Generators and screenshot harness | all of `tool/` (`gen_boards.py`, `SHOTS.md`, `app_shot.sh`, `board_check.sh`, `board_shot.sh`, `compare.sh`, `shot_common.sh`, `dc/`) | M0 |
| Prototype tests | all of `test/` (18 files, including `shot_test.dart`) | M0 |
| Nav lists of dropped boards | `navMasuk`, `navVerifikasi`, `navPemulihan` in `lib/shell/nav_item.dart` | M0 |
| Vacancy string swap | `lib/mock/jabatan_kosong.dart` (`tukarJk`, `papanTukarJk`, `plk`, `plk2`, `jkPita*`, `navPengguna*`) | M0 (calls inlined), file M1 |
| Board-stem routing in data | `ItemKotak.ke`, `keWeb()` in `lib/mock/platform.dart` | M1 |
| Alur wrappers merged into their pair (7.1) | each in the milestone of its pair | M1–M9 |
| Mock data | all of `lib/mock/` once nothing imports it. `format.dart` moves to `lib/core/format.dart` in M0 | M10 |
| Migration marker | `lib/app/belum_dipindah.dart` | M10 |

### 6.2 What replaces each piece of demo machinery

| Demo machinery | Replaced by |
| --- | --- |
| Launcher `/` | The persona picker `/pilih` and the role home `/` (D7, D20) |
| `PrototypeState`, `context.tweak` (78 reads in 75 files), the Keadaan panel | **M0:** every read becomes `belumDipindah(<the board's default>)`, so each screen keeps its default state. **In each screen's milestone:** each non-default branch becomes a read of real state (a provider: period status, document status, the persona and post, data presence) or is deleted if only a fault reaches it (D9). Persona-view tweaks ("Dilihat Operator", `masukSebagai`) become the signed-in persona |
| `jabatanKosong` switch, `tukarJk`, the constant `jabatanKosong: true` on `LayarPonsel` and `HalamanWeb` | Real vacancy state. The shells become `ConsumerWidget`s. The parameter is renamed `layarKeuangan` (marks a finance screen), and the strip, band and footer show when the actor acts by vacancy cover of the Bendahara post (D18). Names in records come from the audit actor |
| `Kendali` ChangeNotifiers (about 18 files) | Domain data moves to repositories and read-model providers. The Kendali widgets stay only where they own UI state and `LayarPonsel` overlays (sheet, toast, tab bar) |
| `ulangPapan`, `DenganGenerasi`, reset on re-entry | Removed. Re-entering a screen shows the shared state (code.md §5 j) |
| About 745 `ke: '<Stem>'` literals, `kembaliKe:`, `keBagi:`, `ItemNav.ke`, `ItemKotak.ke`, `keWeb()` | Typed `Layar` values: `Tautan(ke: Layar.x)`, done by codemod in M0 (stem → `Layar` table in 7.2). Twins map to the same `Layar` |
| `hari = 20261116`, `hariTeks`, 240 "16/11/2026" literals in 95 files, month-year literals | `clockProvider`, seed anchors (5.3) and `bulanTahun`, screen by screen in each milestone |
| Static report tables (`lib/mock/laporan.dart`) and per-board data (`_dataRamai`, `web_excel_data.dart`, `web_paket_laporan_data.dart`, `terbatas_data.dart`) | `ReportRepository` datasets and the seed |
| 23 `Timer` / `Future.delayed` calls in 16 screen files | Kept only where the board fakes outside work, marked `// tiruan:` (3.7). Outcomes go through repositories |
| "Contoh:" buttons, code 123456, "Di prototipe ini" hints | The other persona does the step after a sign-out and sign-in (8.3) |
| Device frame | None. The Android phone layout fills the screen |
| Generated `boards.dart` and `router.dart` | Hand-written `lib/app/layar.dart` and `lib/app/router.dart` |
| Theme and reduce-motion switches in the panel | The system settings: `ThemeMode.system` and `MediaQuery.disableAnimations` |
| Prototype tests and screenshots | Flow tests (section 8) |

## 7. From boards to app screens

### 7.1 Rules

1. **Static and Alur pairs become one screen** (flows.md §0): the list from the static board, the behaviour from the Alur board. The Alur wrapper file is merged and deleted. The pairs are:
   - Penugasan/AlurPenugasan
   - Modul/AlurModul
   - Pelimpahan/AlurPelimpahan
   - JabatanKosong/AlurJabatanKosong
   - BerandaJabatan/AlurBeranda
   - CariOrang/AlurPulihkan
   - DokumenGereja + TerbitDokumen/AlurDokumen
   - PermohonanSurat/AlurSurat
   - WartaEditor/AlurWarta
   - PermohonanAnggota/AlurAnggota
   - Peristiwa/AlurPeristiwa
   - ImporBuku/AlurKeluarga
   - TampilanNama + CabutIzin/AlurNama, split by AlurNama's two parts: its name-form steps go to TampilanNama, its "Cabut izin dan hapus data saya" steps to CabutIzin (7.2)
   - KeuanganUnit/AlurUnit
   - PermintaanDana/AlurDana
   - Ibadah + Kehadiran/AlurIbadah
   - Panitia/AlurPanitia + AlurPanitiaBaru
   - Pengembalian/AlurPengembalian
   
   The Web twins pair the same way.
2. **Twins** (code.md §4):
   - **Pattern A, a shared body with thin wrappers.** The body (`*_isi.dart`, `*_bagian.dart`) reads providers once, and both wrappers stay thin.
   - **Pattern B, independent twins.** These are Main against WebBeranda, WebTransaksi, WebCatat and TabCatat; HitungKas; TutupBuku; Awal; MataAnggaran. Both twins read the same read-model provider. Fix twin drift in the data first: one record, one number, one date.
3. **Dropped boards** (D5, D19, DP34):
   - PetaLayar, Cakupan, Keputusan, PetaPlatform;
   - Masuk, WebMasuk, AlurMasuk, WebAlurMasuk, Pemulihan, WebPemulihan, WebVerifikasi;
   - Memuat, WebMemuat.
4. **Phone-only boards are hidden on web and tablet** (D13). These are the 26 boards of navigation.md §1.5:
   - AlurAnggota, AlurBeranda, AlurDana, AlurIbadah, AlurModul, AlurNama, AlurPanitia, AlurPanitiaBaru, AlurPelimpahan, AlurPenugasan, AlurPeristiwa;
   - AntreanVerifikasi, CabutIzin, Ibadah, Kehadiran, KeuanganUnit, KonfirmasiKeluarga, Modul, Panitia, Pelimpahan, PemberiPersetujuan, Peristiwa, PermintaanDana, PermohonanAnggota, PersembahanSaya, TampilanNama.

   Their `Layar` has no web screen.
   - Web screens drop every row and link to them, including the `hal()` rows of WebBerandaJabatan, WebKotakMasuk and WebCariOrang, and the `navPlatform` items "Ibadah dan kegiatan" and "Panitia".
   - The 5 other phone-only boards (Main, Lainnya, Bendahara, Kamera, AIBulan) have web counterparts under the same `Layar` (7.2). The exception is Bendahara's main view, whose web links are removed. WebSerahTerima covers the handover.
5. **Documents.** The A4 boards and the Excel pictures become document views rendered from report datasets, with the boards' layout:
   - A4F01, A4F02a–c (one paginated F02), A4F14 and A4Sementara (before the close);
   - A4Terbatas;
   - A4Warta;
   - WebExcel and WebExcelTerbatas.
   
   "Unduh PDF" and "Unduh Excel" open the view in the app. No file is written (D15, as in the prototype).
6. **Board states.** For each `keadaan` option and tweak, keep the UI when real data can reach it and drop it when only a fault can (D9). Kept, for example:
   - a close blocked by an unreconciled account;
   - the AI budget used up;
   - overdue cases;
   - "Belum ada Bendahara aktif" while the post is vacant;
   - "Modul tidak aktif" and "Tidak berwenang";
   - an empty month.

   Dropped, for example:
   - evidence upload failed or quarantined;
   - "File Excel laporan gagal dibuat";
   - "AI sedang tidak tersedia";
   - "Gagal memuat", "Tidak ada sambungan", `gagalSimpan`, `gagalUnggah`;
   - a staged Draf conflict;
   - WebEkspor's held and unreadable files.

### 7.2 Screen table

Paths are relative to the role home `/`. "ch:" lists the child routes of a phone board's `ShellRoute`. A `Layar` with "—" in a column has no screen on that layout.

**Core (M0–M1)**

| Layar | Path | Phone | Web (tablet: same) |
| --- | --- | --- | --- |
| `pemilih` | `/pilih` | PemilihPersona (new) | PemilihPersona |
| `beranda` | `/` | BerandaJabatan + AlurBeranda | WebBerandaJabatan |
| `kotakMasuk` | `/kotak-masuk` | KotakMasuk | WebKotakMasuk |
| `akun` | `/akun` | AkunSaya | WebAkunSaya |
| `keluar` | `/keluar` ch: `keluar` | Keluar | WebKeluar |
| `sesiBerakhir` | `/sesi-berakhir` | Sambungan (session-ended view only, DP34) | WebSambungan (the same) |
| guard views | — | KeadaanUmum | WebKeadaanUmum |

**Finance (M2–M5)**

| Layar | Path | Phone | Web | M |
| --- | --- | --- | --- | --- |
| `keuangan` | `/keuangan` | Main | WebBeranda (tablet: TabBeranda) | M2 |
| `transaksi` | `/keuangan/transaksi` | Main `transaksi` | WebTransaksi (tablet: TabTransaksi) | M2 |
| `transaksiRinci` | `/keuangan/detail/:id` | Main `detail` | WebTransaksi with the row selected | M2 |
| `catat` | `/keuangan/catat` | Main `catat`, `mata-anggaran`, `periksa` | WebCatat (tablet: TabCatat) | M2 |
| `tanggal` | `/tanggal` | Tanggal | WebTanggal | M2 |
| `bagi` | `/bagi` | Bagi | WebBagi | M2 |
| `bantuanAi` | `/bantuan-ai` | BantuanAI | WebBantuanAI | M2 |
| `aiFoto` | `/ai-foto` | AIFoto | WebAIFoto | M2 |
| `aiMataAnggaran` | `/ai-mata-anggaran` | AIMataAnggaran | WebAIMataAnggaran | M2 |
| `pilihBulan` | `/pilih-bulan` | PilihBulan | WebPilihBulan | M2 |
| `draf` | `/draf/:id` | Draf | WebDraf | M2 |
| `pemeriksa` | `/pemeriksa` | Pemeriksa | WebPemeriksa | M2 |
| `cari` | `/cari` | Cari | WebCari | M2 |
| `persembahan` | `/persembahan` ch: `hasil` | Persembahan | WebPersembahan | M3 |
| `kewajiban` | `/kewajiban` ch: `kasus/:id` | Kewajiban | WebKewajiban; `kasus/:id` → WebKasus | M3 |
| `kasusBaru` | `/kasus-baru` | KasusBaru | WebKasusBaru | M3 |
| `persetujuan` | `/persetujuan/:id` | Persetujuan | WebPersetujuan | M3 |
| `koreksi` | `/koreksi/:id` ch: `pembalikan`, `hasil`, `kejadian` | Koreksi | WebKoreksi | M3 |
| `pengembalian` | `/pengembalian` | Pengembalian + AlurPengembalian | WebPengembalian + WebAlurPengembalian | M3 |
| `alihPeruntukan` | `/alih-peruntukan` | AlihPeruntukan | WebAlihPeruntukan | M3 |
| `dokumen` | `/dokumen` ch: `rinci` | Dokumen | WebDokumen | M3 |
| `fotoDokumen` | `/foto-dokumen` ch: `tinjau`, `unggah` | Kamera | `unggah` → WebUnggah | M3 |
| `lihatDokumen` | `/lihat-dokumen/:id` | LihatDokumen | WebLihatDokumen | M3 |
| `impor` | `/impor` | Impor | WebImpor | M3 |
| `ekspor` | `/ekspor` | Ekspor | WebEkspor | M3 |
| `tutupBuku` | `/tutup-buku` ch: `cek`, `rekonsiliasi`, `konfirmasi`, `ditutup` | TutupBuku | WebTutupBuku; `rekonsiliasi` → WebRekonsiliasi | M4 |
| `rekeningKoran` | `/rekening-koran` | RekonIsi | WebRekonIsi | M4 |
| `hitungKas` | `/hitung-kas` ch: `banding` | HitungKas | WebHitungKas | M4 |
| `kesiapan` | `/kesiapan` | Kesiapan | WebKesiapan | M4 |
| `hambatanUnit` | `/hambatan-unit` | SelesaikanUnit | WebSelesaikanUnit | M4 |
| `aiBulan` | `/ai-bulan` | AIBulan | WebAI | M4 |
| `kejadian` | `/kejadian` ch: `rinci` | Kejadian | WebKejadian | M4 |
| `laporan` | `/laporan` ch: `rinci/:f` | Laporan | WebLaporan | M4 |
| `paketLaporan` | `/paket-laporan` | — | WebPaketLaporan | M4 |
| `lihatTransaksi` | `/lihat-transaksi` | LihatTransaksi | WebLihatTransaksi | M4 |
| `bukti` | `/bukti` | Bukti | WebBukti | M4 |
| `formatLaporan` | `/format-laporan` | FormatLaporan | WebFormatLaporan | M4 |
| `laporanResmi` | `/laporan-resmi/:periode/:bentuk` (`f01`, `f02`, `f14`, `sementara`, `excel`) | A4F01, A4F02a, A4F02b, A4F02c, A4F14, A4Sementara | the same, plus WebExcel | M4 |
| `terbatas` | `/terbatas` ch: `transaksi/:no` | Terbatas | WebTerbatas | M4 |
| `laporanTerbatas` | `/laporan-terbatas/:periode/:bentuk` (`pdf`, `excel`) | A4Terbatas | A4Terbatas, WebExcelTerbatas | M4 |
| `awal` | `/awal` ch: `tunjuk`, `saldo` | Awal (read-only, D19) | WebAwal (read-only) | M5 |
| `awalIsian` | `/awal-isian` | AwalIsian (read-only) | WebAwalIsian (read-only) | M5 |
| `pengaturan` | `/pengaturan` ch: `kas`, `aturan`, `riwayat` | Lainnya | WebPengaturan | M5 |
| `ubahPengaturan` | `/ubah-pengaturan` | UbahPengaturan | WebUbahPengaturan | M5 |
| `mataAnggaran` | `/mata-anggaran` ch: `rinci` | MataAnggaran | WebMataAnggaran | M5 |
| `kasUnit` | `/kas-unit` | KasUnit | WebKasUnit | M5 |
| `bendahara` | `/bendahara` ch: `serah` | Bendahara | `serah` → WebSerahTerima | M5 |
| `pemberitahuan` | `/pemberitahuan` | Pemberitahuan | WebPemberitahuan | M5 |

**C1 Operator and delegation (M6)**

| Layar | Path | Phone | Web |
| --- | --- | --- | --- |
| `penugasan` | `/penugasan` | Penugasan + AlurPenugasan | WebPenugasan |
| `jabatanKosong` | `/jabatan-kosong` | JabatanKosong + AlurJabatanKosong | WebJabatanKosong + WebAlurJabatanKosong |
| `pelimpahan` | `/pelimpahan` | Pelimpahan + AlurPelimpahan | — |
| `modul` | `/modul` | Modul + AlurModul | — |
| `cariOrang` | `/cari-orang` | CariOrang + AlurPulihkan | WebCariOrang + WebAlurPulihkan |

**Secretariat (M7)**

| Layar | Path | Phone | Web |
| --- | --- | --- | --- |
| `dokumenGereja` | `/dokumen-gereja` ch: `terbit`, `ralat` | DokumenGereja + TerbitDokumen + AlurDokumen | WebDokumenGereja + WebTerbitDokumen + WebAlurDokumen |
| `surat` | `/surat` | PermohonanSurat + AlurSurat | WebPermohonanSurat + WebAlurSurat |
| `pengumuman` | `/pengumuman` | Pengumuman | WebPengumuman |
| `warta` | `/warta` | WartaArsip | WebWartaArsip |
| `wartaEdisi` | `/warta/:edisi` | WartaEditor + AlurWarta | WebWartaEditor + WebAlurWarta |
| `bukaNama` | `/warta/:edisi/buka-nama` | BukaNama | WebBukaNama |
| `wartaPdf` | `/warta/:edisi/pdf` | A4Warta | A4Warta |

**Membership (M8)**

| Layar | Path | Phone | Web |
| --- | --- | --- | --- |
| `dataAnggota` | `/data-anggota` | DataAnggota | WebDataAnggota |
| `permohonanAnggota` | `/permohonan-anggota/:id` | PermohonanAnggota + AlurAnggota, a submitted application with the verifier side (DP36) | — |
| `imporBuku` | `/impor-buku` | ImporBuku + AlurKeluarga | WebImporBuku + WebAlurKeluarga |
| `konfirmasiKeluarga` | `/konfirmasi-keluarga` | KonfirmasiKeluarga | — |
| `verifikasi` | `/verifikasi` | AntreanVerifikasi | — |
| `peristiwa` | `/peristiwa` | Peristiwa + AlurPeristiwa | — |
| `dataGanda` | `/data-ganda` | DataGanda | WebDataGanda |
| `tampilanNama` | `/tampilan-nama` | TampilanNama + AlurNama's name-form steps | — |
| `cabutIzin` | `/cabut-izin` | CabutIzin + AlurNama's consent-withdrawal steps ("Cabut izin dan hapus data saya") | — |

**Collaboration (M9) and Joins (M10)**

| Layar | Path | Phone | Web | M |
| --- | --- | --- | --- | --- |
| `keuanganUnit` | `/keuangan-unit` | KeuanganUnit + AlurUnit | WebAlurUnit | M9 |
| `permintaanDana` | `/permintaan-dana` | PermintaanDana + AlurDana | — | M9 |
| `pemberiPersetujuan` | `/pemberi-persetujuan` | PemberiPersetujuan | — | M9 |
| `panitia` | `/panitia` | Panitia + AlurPanitia + AlurPanitiaBaru | — | M9 |
| `ibadah` | `/ibadah` | Ibadah + AlurIbadah | — | M9 |
| `kehadiran` | `/kehadiran/:ibadah` | Kehadiran | — | M9 |
| `laporanLintas` | `/laporan-lintas` | LaporanLintas | WebLaporanLintas | M9 |
| `persembahanBernama` | `/persembahan-bernama` | PersembahanBernama | WebPersembahanBernama | M10 |
| `persembahanSaya` | `/persembahan-saya` | PersembahanSaya | — | M10 |

`lib/app/layar.dart` carries, above each enum value, a comment naming the boards it replaces, and how a board split over two values divides (AlurNama) or which side of a board is reachable (PermohonanAnggota, DP36). At its end it carries a comment block `Papan yang dibuang:` that lists the dropped boards. The board accounting check (11, item 7) reads that file.

## 8. Flow tests

### 8.1 How they are written

- **Format.** Widget tests (`flutter_test`), one file per flow, in `test/flows/`. A flow with more than one layout or date runs as a `group` with a `testWidgets` per variant.
- **The harness** `test/flows/harness.dart` provides:
  - `bukaAplikasi(tester, {Tata tata = Tata.ponsel, DateTime saat = jangkarA})`. It pumps `ProviderScope(overrides: [clockProvider.overrideWithValue(FixedClock(saat)), layoutProvider.overrideWithValue(tata)], child: PalakatApp())` with the view size of 3.2, and returns the `ProviderContainer` so the test can read end states from repositories and read models.
  - `masukSebagai(tester, Persona p)`: taps the persona on the picker.
  - `keluar(tester)`: Keluar, then confirm. Back on the picker.
  - `tekan(tester, String teks)`, `isi(tester, String label, String nilai)`, `tahan(tester, String teks)` (hold buttons), `tungguTiruan(tester, Duration)` (pumps past a board timer).
  - `majukanJam(tester, Duration d)` (added in M1, with `revisionProvider`): moves the test's `FixedClock` forward by `d` (`FixedClock.majukan`), bumps `revisionProvider` and pumps. The seed anchor stays at launch (3.3), so dated states (a delegation's end, an overdue case) can be reached after launch.
  - `periksaOlehJefry(tester, String uraian)`: signs out, signs in as Jefry, marks the draft "Sudah diperiksa" in Pemeriksa, signs out and signs back in as the persona who was signed in before. The second-checker rule is in force (D24), so every booking flow uses it.
- **Dates.**
  - Every flow runs at `jangkarA` = 16/11/2026 12.05 WITA, the story date, where board dates and seed dates agree (voucher numbers are computed, DP38).
  - Flows F2, F5, F15, F17, P3 and P9 also run at `jangkarB` = 05/01/2027 10.00 WITA: a year boundary, M−1 is December of the year before, M0 vouchers restart at 0001, and today's seed times are compressed before 10.00.
  - F2 and F15 also run at `jangkarC` = 03/03/2027 09.00 WITA: M−1 is February, a short month, and M0 has no Sunday yet.
  - P3 also runs at `jangkarD` = 01/06/2027 08.00 WITA: day 1 of the month, where `hariCerita` clamps every past M0 date onto today and `jam` compresses the times (5.3).
  - The B and C runs assert computed labels ("Januari 2027", next to close "Desember 2026"), voucher years, and that no shown date is after `saat`.
- **Assertions.** Each test asserts what the screen shows (`find.text`, `find.textContaining`) and the repository state (status, number, balance, audit actor) through the container.
- **Fake time.** Board timers are pumped with `tester.pump(Duration(...))`. No test leaves a timer pending.
- **Isolation.** Each test builds a fresh `ProviderScope`, so the seed is rebuilt and nothing leaks between tests (D6).

### 8.2 The two-persona pattern

Two-sided flows run on one device, as the owner will run them (D7):

```dart
await masukSebagai(tester, Persona.hendrik);   // asks
await tekan(tester, 'Ajukan'); ...
await keluar(tester);                          // back to the picker; state kept
await masukSebagai(tester, Persona.lidya);     // decides
await tekan(tester, 'Setujui'); ...
await keluar(tester);
await masukSebagai(tester, Persona.meiske);    // sees the result
expect(find.text('Disetujui oleh Pdt. Lidya Rondonuwu'), findsOneWidget);
```

### 8.3 The flows

Layouts: P = phone, W = web, T = tablet. "M" is the milestone that writes the test. End states adapt flows.md §1–2 to the decisions.

| Test file | Flow | Personas | Layouts | M | End state asserted |
| --- | --- | --- | --- | --- | --- |
| `f01_awal_test.dart` | F1 Opening (read-only) | Meiske | P, W | M5 | Awal reads "6 dari 6 langkah"; the opening batch `OPN-{cutover year}-0001` with the computed total per account; no input is editable; "Mulai mencatat" opens the finance home |
| `f02_catat_bukukan_test.dart` | F2 Record and book | Meiske, Jefry | P, W, T; dates A, B, C | M2 | A Belanja recorded through Catat (Tanggal, Mata Anggaran) is refused at Bukukan until checked; after `periksaOlehJefry` it books with the next free BKU number of its year; "Saldo buku" and "Belanja bulan ini" on the finance home change by the amount; the row shows in Transaksi and Cari; "Simpan sebagai draf" instead adds to the dashed draft pill's count and sum. The document step is in F12 (M3), and Bukti and the provisional report in F17 (M4) |
| `f03_bantuan_ai_test.dart` | F3 AI help | Meiske | P, W | M2 | The draft fields are filled; Kas/Bank, peruntukan and Lingkup still read "Belum diisi"; status "Tersimpan · Draf"; nothing is booked; the AI spend rises by the fixed cost; repeated proposals reach the budget-used-up view |
| `f04_persembahan_test.dart` | F4 Offering in parts, named envelope | Meiske, Jefry, Novita, Olvie | P, W (Novita's PersembahanSaya check at P only) | M3 (parts), M10 (envelope) | One voucher for all parts; the Titipan part Rp450.000 is on the Sinode transit case in Kewajiban. M10: the envelope for Novita shows on her PersembahanSaya and on Meiske's view, not for Olvie; an envelope for Ferry (unconfirmed) is refused |
| `f05_kewajiban_test.dart` | F5 Advances, deposits, claims | Meiske, Jefry | P, W; dates A, B | M3 | A settlement of um1 lowers its remainder; KasusBaru lists a new case with its due date; spending above an advance is refused and offered as Penggantian biaya; the home row "N uang muka…" follows the count; um2 shows overdue at both dates |
| `f06_pemeriksa_test.dart` | F6 Second checker | Meiske, Jefry | P, W | M2 | Meiske cannot mark her own draft; Jefry marks it "Sudah diperiksa"; Meiske books it "Dibukukan"; "Ubah" returns it to Draf and drops the check. The Lainnya rule switch is in F19 (M5) |
| `f07_persetujuan_test.dart` | F7 External approval | Meiske | P, W | M3 | KartuPersetujuan is solid with giver, date and method; "Ganti" keeps the old one in Riwayat as "Digantikan"; changing the amount voids it ("Persetujuan belum dicatat") |
| `f08_koreksi_test.dart` | F8 Correction | Meiske, Jefry | P, W | M3 | The original reads "Dibalik oleh No. Bukti …"; the reversal and the correction take the next numbers; the net effect is Rp0; a correction of an M−2 transaction is refused with the Kejadian way forward |
| `f09_pengembalian_test.dart` | F9 Refund (pending RD04) | Meiske, Jefry | P, W | M3 | A new transaction linked to the original, at most its amount (a larger amount is refused); a supplier refund lowers Belanja of M0 |
| `f10_draf_bulan_ditutup_test.dart` | F10 Draft in a closed month | Meiske | P, W | M2 | The M−2-dated draft (DP17 b) is refused at Bukukan; "Pindah tanggal" with a reason moves it to M0, or "Batalkan" with a reason gives "Dibatalkan" and no number; the link "1 draf di bulan yang sudah ditutup" disappears |
| `f11_alih_peruntukan_test.dart` | F11 Move between funds | Meiske, Jefry | P, W | M3 | Both fund balances change by the amount; same source and target is refused; an amount above the balance is refused |
| `f12_dokumen_test.dart` | F12 Supporting documents | Meiske, Jefry | P, W | M3 | "Terverifikasi (oleh Meiske L.)" after Verifikasi; "Dikecualikan" with a reason; the missing document of the drawn 0143 (an M0 row) is captured through Kamera (P) or WebUnggah (W), and its attention item ("1 dokumen pendukung wajib, belum ada") leaves the finance home and Dokumen; `PeriodRepository.blockers(M0)` still lists it while it is uploaded and unverified (DM 6.4), and no longer lists it once Jefry (not the uploader) verifies it; a Belanja booked in the test after `periksaOlehJefry` gets its document through the same capture |
| `f13_impor_test.dart` | F13 Import | Meiske | P, W | M3 | "4 baris sudah diimpor · 1 tidak diimpor"; the unreadable date row is refused; the possible duplicate is flagged; the imported rows appear in Transaksi as drafts (`ImportRepository.commit` creates DRAFTs; booking them is the normal check and finalize) |
| `f14_cari_test.dart` | F14 Search | Meiske, Jefry | P, W | M2 | The answer total equals the sum of the posted records it lists; a transaction booked earlier in the test is found |
| `f15_tutup_buku_test.dart` | F15 Month end and close | Meiske, Jefry, Olga, Rivo | P, W; dates A, B, C | M4 | Every computed blocker of M−1 is cleared on the screens the boards draw: BNI (0131 in transit, the fee from "BIAYA ADM", match, confirm), the SulutGo statement, the Kas count (selisih Rp0), Kas Kolom 7, the Kolom 7 draft and the missing Kolom 7 readiness through SelesaikanUnit with a reason (DP37), Diakonia readiness by Olga, Pembangunan readiness by Rivo, each attested after its Fund's last posting in the test. Holding the button closes M−1: "Sudah ditutup", snapshot `SNP-{y}-{mm}-01`, M0 next to close; booking or correcting into M−1 is then refused. The test also exports a helper `tutupBulanLalu(tester)` for F16, F17 and F25 |
| `f16_kejadian_test.dart` | F16 Incident after close | Meiske, Jefry | P, W | M4 | After `tutupBulanLalu`, the incident "Kas … lebih Rp85.000" is recorded with the next K number, `K-{y}-02` (DP18); the closed figures are unchanged; the settlement in M0 is a separate draft, booked after `periksaOlehJefry`; the blocker on M0 stays (D11) |
| `f17_laporan_test.dart` | F17 Reports | Meiske, Jefry | P, W; dates A, B | M4 | A Belanja booked in the test after `periksaOlehJefry` shows in Bukti and in the provisional report; before the close the provisional ribbon; after it the official ribbon, and the F01, F02, F14 and Excel document views render; every report figure equals the sum of the rows LihatTransaksi lists for it; Bukti's gap view lists the allocated unfinished numbers: 6 at date A, and at date B 4 in M−1's year and 2 in M0's (DP7) |
| `f18_ekspor_test.dart` | F18 Export | Meiske | P, W | M3 | "Diunduh · ekspor-jemaat-karunia-{today}.zip"; "Belum lengkap" lists exactly the posted transactions with a required document still missing |
| `f19_pengaturan_test.dart` | F19 Settings | Meiske | P, W | M5 | The second-checker rule shows on in Lainnya or WebPengaturan; switching it off (`SettingsRepository.setRule`) says it stops from M+1, and Meiske's own unchecked draft is still refused at Bukukan in M0; adding a Kas/Bank, peruntukan or Lingkup states "berlaku mulai {M+1}" and adds a Riwayat line; a deactivated account shows dashed; the Mata Anggaran draft is reviewed and published from M+1; KasUnit assigns an account to a unit |
| `f20_serah_terima_test.dart` | F20 Sessions and handover | Meiske, Lidya | P, W | M6 | "Akhiri sesi" removes the other device; Meiske prepares the handover to Yohanis Tumbelaka in Bendahara `serah` or WebSerahTerima; Lidya records it in Penugasan and it shows "Menunggu verifikasi wewenang" (DP39); Meiske signs in again; after the board timer Yohanis is "aktif sejak {today}", Meiske's term has ended, and her session ends on Sambungan or WebSambungan; "Masuk lagi" opens the picker; picking Meiske again lands on a member home with no finance rows |
| `f21_pemberitahuan_test.dart` | F21 Finance notifications | Meiske | P, W | M5 | Opening an item lowers the unread count; switching a type off hides it while the home blockers stay |
| `f22_terbatas_test.dart` | F22 Restricted access | Meiske, Jefry, Olga | P, W | M4 | Olga sees only Diakonia rows and balance; a Diakonia transaction booked in the test appears; the TERBATAS PDF and Excel views hold only Diakonia rows; other funds' screens are "Tidak berwenang" for her |
| `f23_keuangan_unit_test.dart` | F23 Unit finance | Deasy, Jefry, Meiske | P (W for the Bendahara side) | M9 | Deasy books on Kas Kolom 7 in the Kolom 7 fund after `periksaOlehJefry`; the BNI draft and the Diakonia draft are refused (DL32); she declares readiness for M−1 after that booking; Meiske clears the Kolom 7 blockers with a reason and Deasy gets a notice (DL33); TutupBuku `/cek` no longer shows "hambatan dari unit" |
| `f24_permintaan_dana_test.dart` | F24 Fund request | Hendrik, Lidya, Meiske, Jefry | P | M9 | Hendrik cannot approve his own request; Lidya approves (and in a second test refuses with a reason); Meiske's "Catat pembayaran" books Uang Muka diberikan after the check; the request reads "Dibayar"; a new advance is in Kewajiban; a request below Rp250.000 needs no approval |
| `f25_jabatan_kosong_test.dart` | F25 Vacant Bendahara post | Lidya, Yanti, Jefry | P, W | M6 | Lidya ends Meiske's term in Penugasan; the post reads vacant; Yanti takes cover with a reason and acknowledgement; phone finance screens show `PitaJabatanKosong` and web finance screens the vacancy footer and band; Yanti records and, after Jefry's check, books, and the detail and Riwayat read "oleh Yanti Sumual, Operator …"; Yanti is refused as checker; Lidya assigns Yohanis Tumbelaka, who after the board timer is active; the cover ends and the strip is gone |
| `p01_beranda_<modul>_test.dart` | P1 Home and inbox | each persona | P, W | M2 (keuangan), then one file per module milestone | Each persona's "Perlu tindakan" rows come from real open items; finishing the item removes the row (booking the 2 drafts removes "2 draf belum dibukukan"); Hendrik is asked "Sebagai …" when two posts can act; no web home row links a phone-only screen |
| `p02_akun_saya_test.dart` | P2 My account | any | P, W | M1 | "Email cadangan disimpan."; a removed device is gone; sign-out returns to the picker |
| `p03_pemilih_test.dart` | P3 Picker (replaces sign-in) | all 11 | P, W, T; dates A, B, D | M0, extended in M1 | The picker lists exactly the 11 personas; each lands on its role home; after sign-out a change made by one persona shows for the next. Also: `pilihTata` returns `web`, `tablet` and `ponsel` for the sizes of 3.2; `PalakatApp` pumped with no overrides (real clock, real layout chooser) shows the picker; `buildSeed` runs without an assert for every day of the 366 from `jangkarA`, at 00.01 and 23.59 (5.4) |
| `p04_pulihkan_test.dart` | P4 Recover a member's account | Yanti, Hendrik | P, W | M6 | Hendrik confirms the identity and then sees "Tidak ada pemulihan akun yang menunggu Anda"; Yanti sees the completed status |
| `p05_modul_test.dart` | P5 Modules | Lidya, Hendrik | P | M6 | Switching a module off needs a reason; its menu items and home rows disappear for everyone; its paths show "Modul tidak aktif"; switching on follows the dependency order; switching back restores |
| `p06_penugasan_test.dart` | P6 Posts and delegation | Lidya, Yanti, Hendrik, Greis | P (W for Penugasan) | M6, extended by the main loop after the M6–M8 merge | Lidya assigns Penatua Kolom 2 to Altje: Yanti's cover ends; Lidya cannot assign herself; Hendrik's delegation to Greis shows in force in Pelimpahan, and after `majukanJam(tester, Duration(days: 15))` it reads ended. After the merge: the Kolom 2 queue (`VerificationRepository.queue`) routes to Altje once she is assigned, and Greis verifies a Kolom 7 item in AntreanVerifikasi while the delegation is in force |
| `p07_dokumen_gereja_test.dart` | P7 Church documents | Olvie, Novita | P, W | M7 | "Diterbitkan" only with a signed copy; a Ralat makes "Revisi 2" and the old version still opens; Novita sees only documents addressed to her |
| `p08_surat_test.dart` | P8 Letter request | Novita, Olvie, Yanti | P, W | M7 | The letter is issued with the number `NNN/SKet/{Roman M0}/{year}`; Novita's inbox shows "Surat keterangan … diterbitkan"; Yanti can record a request at the office |
| `p09_warta_test.dart` | P9 Announcements and Warta | Yanti, Olvie | P, W; dates A, B | M7, extended in M10 | Yanti drafts and Olvie publishes an announcement; the edition of the next Sunday goes Draf → diperiksa → disetujui → terbitkan and shows "Diterbitkan" in WartaArsip; A4Warta renders. M10: names follow TampilanNama; the finance excerpt comes from the latest closed snapshot; only finalized attendance shows; a BukaNama exception is recorded with its reason |
| `p10_impor_buku_test.dart` | P10 Member book import | Yanti, Hendrik | P, W (the family confirmation and Hendrik's verification at P only) | M8 | Check → duplicates → import; DataGanda merge or "bukan orang yang sama"; the family confirmation is entered; Hendrik verifies; the family badge reads "Aktif" and the home count of unconfirmed members drops |
| `p11_menjadi_anggota_test.dart` | P11 Become a member | Yanti | P | M8 | Yanti (cover) opens Kevin's application from the Kolom 2 queue in AntreanVerifikasi; PermohonanAnggota shows his submitted form read-only; "Verifikasi data" verifies it (DP36); Kevin is "Aktif" with BIPRA computed; Novita is unchanged |
| `p12_peristiwa_test.dart` | P12 Life events | Novita, Hendrik | P | M8 | Gabriel's Baptism is refused without an attachment; with one it is submitted; DataAnggota changes only after Hendrik verifies |
| `p13_data_saya_test.dart` | P13 My name and my data | Novita | P | M8, extended in M10 | The chosen name form is saved; withdrawing consent records the request; finance records keep the booked name. M10: the next Warta preview prints the chosen form |
| `p14_persembahan_saya_test.dart` | P14 My giving | Novita | P | M10 | PersembahanSaya lists the seeded sampul syukur and the envelope recorded in the test, and nobody else's |
| `p15_ibadah_test.dart` | P15 Worship and attendance | Hendrik, Greis, Lidya | P | M9 | Hendrik approves Ibadah Kolom 7 (the next Thursday) and assigns Greis; Greis counts and is refused "Tetapkan"; Hendrik finalizes; the count shows in LaporanLintas; the Sunday count is finalized by Lidya (DP25) |
| `p16_panitia_test.dart` | P16 Committees | Lidya, Meiske, Jefry | P | M9 | A new Panitia needs a decision document from P7 and three distinct officers; Panitia Natal closes after advance um1 is cleared: Meiske records the return of its unused Rp650.000 into Umum Jemaat (`CaseRepository.returnUnused`, booked after `periksaOlehJefry`, DP27) and approves the leftover's destination, Umum Jemaat: Ditutup → Diarsipkan |
| `p17_laporan_lintas_test.dart` | P17 Cross-module report | Lidya, Hendrik, Rivo | P, W | M9 | Each viewer sees only the figures they may see (Lidya all, Hendrik Kolom 7, Rivo Panitia Natal: advance um1, its settlements and its remainder, since the Panitia Natal fund itself is Rp0, DP27); every figure is computed |

## 9. Milestones

Build in this order. A milestone is done when its checks pass. The main loop then commits it on the working branch (`git commit` with a message starting `demo: M<n>`) and never pushes. Every milestone's checks include the **common checks**:

- C1: `cd prototype && fvm flutter analyze` prints "No issues found!".
- C2: the milestone's flow tests pass (`fvm flutter test test/flows/<file>` for each).
- C3: in the files the milestone migrated, these return nothing:
  - `grep -nE "belumDipindah|/mock/" <files>`;
  - `grep -nE "\b[0-3][0-9]/[01][0-9]/20[0-9]{2}\b|BKU-20[0-9]{2}-[0-9]{4}|(Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember) 20[0-9]{2}" <files>`.
- C4 (main loop, after the merge): the full `fvm flutter test` passes, `fvm flutter build web` succeeds, and `JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home fvm flutter build apk --debug` succeeds.
- C5 (from M1 on, in every milestone that writes repository interfaces): the command envelope of section 4 holds. From the repository root this prints `[]`:
  ```bash
  python3 -I - <<'EOF'
  import re, glob
  bad = []
  for f in glob.glob('prototype/lib/data/repositories/*.dart'):
      for m in re.finditer(r'Future<Result<[^;]*?\)\s*;', open(f).read(), re.S):
          sig = re.sub(r'\s+', ' ', m.group(0))
          if re.search(r'\b(signIn|signOut)\(', sig):
              continue
          if not re.search(r'\w+\(\s*Actor actor\b', sig) or 'required String idempotencyKey' not in sig:
              bad.append((f, sig[:100]))
  print(bad)
  EOF
  ```
  The check cannot know which commands change an existing aggregate, so `expectedRevision` and `reason` are checked against the tables of section 4 by reading.

### M0 · Clean-up and scaffolding (Phase 0)

Scope: remove the demo machinery and leave an app that compiles, starts at the picker, and shows every remaining screen in its default state through typed links.

1. Create `prototype/.fvmrc` with `{"flutter": "3.47.8"}`; the file does not exist today, and 3.47.8 is the fvm global version.
2. `cd prototype && fvm flutter pub add flutter_riverpod:^3.5.0`. Update the `description` in `pubspec.yaml` to "Palakat demo app: every module on dummy data, in memory."
3. `git rm -r prototype/test prototype/tool`.
4. Move `lib/mock/format.dart` to `lib/core/format.dart` and rewrite its imports (`../../mock/format.dart` in 63 screen files, plus widgets and motion).
5. Codemod. Put the scripts in `prototype/build/m0/`, which git ignores, and run them before deleting `boards.dart`.
   - a. Every `context.tweak<T>(stem, nama)` becomes `belumDipindah<T>(<default from boards.dart>)`, defined in `lib/app/belum_dipindah.dart` as `T belumDipindah<T>(T bawaan) => bawaan;`. About 10 reads pass a variable stem (`_stem`); resolve those by hand.
   - b. Every `ke:`, `kembaliKe:` and `keBagi:` string, `ItemNav.ke`, `ItemKotak.ke`, the 16 direct `kembaliKe('/<Stem>')` calls and the direct `go`/`push` calls in 15 files (code.md §2) become `Layar` values through the stem → `Layar` table of 7.2. A link to a dropped board is removed with its control.
   - c. Remove every `AlatPrototipe` wrapper and keep its child. `tukarJk(x)` becomes `x`. `jabatanKosong: true` becomes `layarKeuangan: true`.
   - d. Remove every use of `ulangPapan`, `GenerasiPapan` and `DenganGenerasi`.
6. Delete every M0 row of 6.1.
7. Write `lib/app/` (`app.dart`, `tata.dart`, `layar.dart` with every `Layar` of 7.2 and the board comments, `router.dart`), `lib/core/clock.dart`, `lib/core/tanggal.dart`, and `lib/providers/{clock,layout,session}.dart`. The session in M0 is a minimal `SessionNotifier` over a fixed persona list; M1 replaces it. Then rewrite `lib/main.dart`.
8. Shells: make `LayarPonsel`, `HalamanWeb` and `NavSamping` `ConsumerWidget`s. The footer comes from the session. The vacancy strip, band and footer read `vacancyCoverProvider` (false until M1).
9. Write the picker (5.2), `test/flows/harness.dart` and `test/flows/p03_pemilih_test.dart`. In M0 the test signs in as Meiske, lands on BerandaJabatan, signs out and lands on the picker, at P, W and T.
10. Docs:
    - In `docs/build/CONVENTIONS.md`, rewrite "What is being built", "Stack" (add `flutter_riverpod`), "Project layout", "One route per board" (now "Screens and routes", pointing to README §3.6 and §7), "Prototype chrome" (removed), "Behaviour" (shared state, D4, D9, D11), and "Definition of done for one board" (now per screen: its flow tests pass). Delete the `tukarJk` paragraph. Keep theme, tokens, form factors (minus the device frame), copy, motion and accessibility.
    - Add one line at the top of `docs/build/navigation.md` and `docs/build/mock-data.md`: "For the demo app, README.md supersedes the route table, launcher and per-board figures; this file still gives links, shells and seed values."
    - Rewrite `prototype/README.md` briefly: how to run it and what the picker is.

Checks:

- C1, C2 (`p03_pemilih_test.dart`), C4.
- Each deleted path is gone: `for p in lib/boards.dart lib/router.dart lib/shell/peluncur.dart lib/shell/perjalanan.dart lib/shell/panel_keadaan.dart lib/shell/bingkai_perangkat.dart lib/shell/prototipe_state.dart lib/shell/perangkat_prototipe.dart lib/shell/kendali.dart lib/shell/komponen_galeri.dart lib/shell/belum_dibangun.dart lib/screens/sistem tool lib/screens/lengkap/masuk.dart lib/screens/lengkap/web_verifikasi.dart lib/screens/lengkap/memuat.dart lib/screens/p2/alur_masuk.dart; do test ! -e prototype/$p || echo LEFT $p; done` prints nothing.
- `grep -rnE "PrototypeState|PrototipeLingkup|context\.tweak|AlatPrototipe|ulangPapan|DenganGenerasi|GenerasiPapan|tukarJk|BingkaiPerangkat|Peluncur|KomponenGaleri|Belum dibangun|semuaPapan|papanBerAnak|jabatanKosong:|(ke|kembaliKe|keBagi): '|kembaliKe\\('" prototype/lib` prints nothing.
- The board accounting check (11, item 7) passes.

### M1 · Core (Phase 0)

Scope: the core domain and data, the clock and seed skeleton, the session, the capability gate, audit, notifications, modules and guards, and the core screens on real state.

- Domain and data:
  - `lib/domain/core/*`, including `capabilities.dart` (3.5);
  - the core repositories of 4.1 (`lib/data/repositories/`, `lib/data/memory/`), every query and every command complete, `RoleRepository` and `WorkspaceRepository` included, so that F20 and F25 depend on no later command;
  - `seed_store.dart`, `build_seed.dart`, `jangkar.dart`, `seed_inti.dart`, `tabel_inti.dart`;
  - `lib/providers/{seed,revision,actor,core_repositories,home_rows}.dart`, with `vacancyCoverProvider` following real cover, so the strip, band and footer of the shells follow `coverVacancy` from M1 on (D18).
- Hooks for later milestones, so that no worker of a parallel batch needs a shared file (10.1):
  - every seed file of 5.7 as an empty function, already called from `build_seed.dart`, and `tabel_{keuangan,sekretariat,jemaat,kolaborasi}.dart` as empty classes that `SeedStore` already holds;
  - `homeRowsProvider` in `home_rows.dart` as a fixed list over `home_rows_{keuangan,inti,sekretariat,jemaat,kolaborasi}.dart`, each an empty row source that its milestone fills (M2, M6, M7, M8, M9).
- Session: the acting post is picked automatically when one post can act, and the "Sebagai …" choice (AlurBeranda) is asked when two can. A session ends when the assignment it acts in ends, and the router shows `Layar.sesiBerakhir` (3.6).
- Screens:
  - BerandaJabatan + AlurBeranda (merge, then delete `p2/alur_beranda.dart`), `p2/beranda_jabatan_isi.dart`, WebBerandaJabatan;
  - KotakMasuk, WebKotakMasuk; AkunSaya, WebAkunSaya;
  - Keluar (`lengkap/keluar.dart`, `keluar_akun.dart`), WebKeluar;
  - KeadaanUmum and WebKeadaanUmum as the guard views (only "Tidak berwenang" and "Modul tidak aktif" stay; the rest is dropped, D9);
  - Sambungan and WebSambungan cut to the session-ended view of DP34, with "Masuk lagi" opening the picker.
- Date sweep (main loop): remove the date and year defaults and examples from the shared files no milestone owns:
  - make `PitaJabatanKosong.sejak` (`widgets/pita_jabatan_kosong.dart`), `PemilihMataAnggaran.versi` (`widgets/pemilih_mata_anggaran.dart`) and the `subjudul`, `kakiKanan` and footer text of `shell/halaman_a4.dart` required, so callers pass computed values;
  - rewrite every date or year in a doc comment of `lib/widgets`, `lib/theme`, `lib/motion`, `lib/shell` and `lib/core/format.dart` as `dd/mm/yyyy`, `{bulan} {tahun}` or `BKU-{tahun}-NNNN`;
  - leave `hari` and `hariTeks` in `core/format.dart` for the screens not yet migrated; M10 deletes them;
  - move `GayaLabel` from `lib/mock/model.dart` into `lib/widgets/lencana_status.dart`, the one shared file that imports `lib/mock/` after M0, and import it from there.
- Remove `ItemKotak.ke` and `keWeb()` from `lib/mock/platform.dart`, and delete `lib/mock/jabatan_kosong.dart`.
- Flows: P2, P3 (all 11 personas, dates A, B and D, the no-override launch and the 366-day seed run).
- Checks:
  - C1–C5, with C3 over `lib/screens/p2/{beranda_jabatan,beranda_jabatan_isi,web_beranda_jabatan,kotak_masuk,web_kotak_masuk,akun_saya,web_akun_saya,keadaan_umum,web_keadaan_umum}.dart lib/screens/lengkap/{keluar,keluar_akun,web_keluar,sambungan,web_sambungan}.dart lib/shell lib/widgets lib/theme lib/motion`;
  - `test ! -e prototype/lib/mock/jabatan_kosong.dart`;
  - `grep -rn "keWeb" prototype/lib` prints nothing.

### M2 · Finance 1: ledger and daily work (Phase 1)

Scope:

- Domain and data:
  - `lib/domain/finance/*`, with the posting sign table (4.6 point 1);
  - every Finance repository interface of 4.2, `SettingsRepository` included, and every in-memory implementation file. Queries are complete, `SettingsRepository.rulesInForce` and `PeriodRepository.blockers` included. Commands are complete for `TransactionRepository`, `FundRepository`, the voucher counters and `AiRepository`. Every other command (those of `AccountRepository`, `MasterRepository` and `SettingsRepository` too) is a stub that returns `Refused` with "belum tersedia", for M3–M5 to fill;
  - `tabel_keuangan.dart`, complete.
- `seed_keuangan.dart`, the full ledger of 5.6 and the Data picks, with the voucher numbering of 5.5 and the second-checker rule value.
- Read models: the finance home, the transaction list, drafts, the Pemeriksa queue, search.
- Screens:
  - `lib/screens/ponsel/{main,main_catat,main_periksa,bagi,bagi_logika}.dart`;
  - `lib/screens/web/{web_beranda,web_transaksi,tab_beranda,tab_beranda_kit,tab_transaksi,tab_catat}.dart`;
  - `lib/screens/lengkap/{web_catat,web_bagi,tanggal,tanggal_kalender,web_tanggal,pilih_bulan,web_pilih_bulan,draf,web_draf,ai_foto,ai_foto_bagian,web_ai_foto,ai_mata_anggaran,ai_mata_anggaran_isi,web_ai_mata_anggaran,cari,cari_bagian,web_cari,web_bantuan_ai}.dart`;
  - `lib/screens/lanjut/{bantuan_ai,bantuan_ai_bagian,pemeriksa,pemeriksa_baris,web_pemeriksa}.dart`.
- Also: the finance home rows source (`providers/home_rows_keuangan.dart`), and the tablet layout.
- Flows: F2, F3, F6, F10, F14, and P1 (`p01_beranda_keuangan_test.dart`).
- Checks: C1–C5, with C3 over the files listed.

### M3, M4, M5 · Finance 2–4 (Phase 1, run in parallel)

Each fills the stub command files it owns. During this batch no file has two owners (10.1).

**M3 · Money in and out, cases, corrections, documents, import and export.**

- Owns:
  - `memory/{case,approval,evidence,import,export}_repository.dart`, `seed_keuangan_kasus.dart`;
  - `lanjut/{persembahan,web_persembahan,kewajiban,web_kewajiban,impor,web_impor,ekspor,web_ekspor}.dart`;
  - `lengkap/{web_kasus,kasus_baru,web_kasus_baru,persetujuan,web_persetujuan,pengembalian,pengembalian_isi,web_pengembalian,alur_pengembalian,alur_pengembalian_alur,web_alur_pengembalian,alih_peruntukan,web_alih_peruntukan,dokumen,web_dokumen,kamera,web_unggah,lihat_dokumen,lihat_dokumen_penampil,web_lihat_dokumen,web_koreksi}.dart`;
  - `ponsel/koreksi.dart`.
- Merges AlurPengembalian into Pengembalian.
- Flows: F4 (parts), F5, F7, F8, F9, F11, F12, F13, F18.

**M4 · Month end, close and reports.**

- Owns:
  - `memory/{reconciliation,period,report}_repository.dart`, `seed_keuangan_akhir_bulan.dart`;
  - `ponsel/{tutup_buku,hitung_kas}.dart`;
  - `web/{web_tutup_buku,web_rekonsiliasi,web_hitung_kas,web_laporan}.dart`;
  - `lengkap/{rekon_isi,web_rekon_isi,ai_bulan,kejadian,kejadian_bagian,web_kejadian,format_laporan,format_laporan_bagian,web_format_laporan,lihat_transaksi,lihat_transaksi_rinci,web_lihat_transaksi,web_excel_terbatas}.dart`;
  - `lanjut/{laporan,laporan_tabel,web_paket_laporan,web_paket_laporan_data,web_excel,web_excel_data,web_ai,bukti,web_bukti,terbatas,terbatas_data,web_terbatas}.dart`;
  - `a4/*`, `a4s/*`, `a4t/*`;
  - `p5/{kesiapan,kesiapan_isi,web_kesiapan,selesaikan_unit,selesaikan_unit_isi,web_selesaikan_unit}.dart`.
- Turns `web_excel_data.dart`, `web_paket_laporan_data.dart` and `terbatas_data.dart` into dataset readers, or deletes them.
- Flows: F15, F16, F17, F22.

**M5 · Setup, settings, handover, notifications.**

- Owns:
  - `memory/opening_repository.dart`, the command parts of `memory/{account,master,settings}_repository.dart`, `seed_keuangan_pengaturan.dart`;
  - `ponsel/{awal,lainnya,mata_anggaran,bendahara}.dart`;
  - `web/{web_awal,web_pengaturan,web_mata_anggaran}.dart`;
  - `lengkap/{awal_isian,awal_isian_isi,web_awal_isian,ubah_pengaturan,web_ubah_pengaturan,pemberitahuan,web_pemberitahuan,web_serah_terima}.dart`;
  - `p5/{kas_unit,kas_unit_isi,web_kas_unit}.dart`.
- Bendahara `serah` and WebSerahTerima call `RoleRepository.proposeHandover` from M1 (DP39). The rest of the handover, Lidya's `assign` in Penugasan and the Petugas verifikasi timer in the repository, is tested by F20 in M6, once Penugasan is migrated.
- Flows: F1, F19, F21.

Checks for each: C1–C3 in the worker. After all three merge, the main loop runs C4, and these:

- `grep -rn "Refused.*belum tersedia" prototype/lib/data/memory` prints nothing for Finance;
- `grep -rnE "Timer\(|Future\.delayed" prototype/lib/screens/{ponsel,web,lanjut,lengkap,a4,a4s,a4t} | grep -v "// tiruan:"` prints nothing.

### M6, M7, M8 · C1, Secretariat, Membership (Phases 2–4, run in parallel)

Each depends only on M1, except F20 and F25, which also use Finance from M2–M5.

**M6 · C1 Operator and delegation.**

- Owns:
  - `p2/{modul,alur_modul,penugasan,alur_penugasan,web_penugasan,jabatan_kosong,alur_jabatan_kosong,web_jabatan_kosong,web_alur_jabatan_kosong,pelimpahan,alur_pelimpahan,cari_orang,web_cari_orang,alur_pulihkan,web_alur_pulihkan}.dart`;
  - `providers/home_rows_inti.dart`.
- Merges the Alur pairs. JabatanKosong and Penugasan drive the real cover that the strip, band and footer already follow (M1, D18). The core commands are complete since M1, so M6 builds screens only.
- Flows: F20, F25, P4, P5, P6 (its M6 part), and `p01_beranda_inti_test.dart`.

**M7 · Secretariat.**

- Owns:
  - `domain/secretariat/*`, the 4.3 repository interfaces and implementations, `providers/repositories_sekretariat.dart`, `tabel_sekretariat.dart`, `seed_sekretariat.dart`;
  - every file in `lib/screens/p3/`;
  - `providers/home_rows_sekretariat.dart`.
- Merges the pairs. A4Warta becomes a document view.
- Flows: P7, P8, P9 (without the M10 parts), and `p01_beranda_sekretariat_test.dart`.

**M8 · Membership.**

- Owns:
  - `domain/membership/*`, the 4.4 repository interfaces and implementations, `providers/repositories_jemaat.dart`, `tabel_jemaat.dart`, `seed_jemaat.dart`, including the bulk generator: deterministic, plain Minahasa names, counts as in 5.1;
  - every file in `lib/screens/p4/` except `persembahan_saya.dart`;
  - `providers/home_rows_jemaat.dart`.
- Merges the pairs.
- Flows: P10, P11, P12, P13 (without the M10 part), and `p01_beranda_jemaat_test.dart`.

Checks for each: C1–C3 and C5 over its files. After all three merge, the main loop:

- extends `p06_penugasan_test.dart` with its post-merge part (8.3): the Kolom 2 queue routes to Altje once she is assigned, and Greis verifies a Kolom 7 item through the delegation;
- runs C4.

### M9 · Collaboration (Phase 5)

- Owns:
  - `domain/collaboration/*`, the 4.5 repository interfaces and implementations, `providers/repositories_kolaborasi.dart`, `tabel_kolaborasi.dart`, `seed_kolaborasi.dart`;
  - `lib/screens/p5/` except the M4 and M5 files and `persembahan_bernama*`/`web_persembahan_bernama`: that is `keuangan_unit`, `alur_unit`, `alur_unit_isi`, `web_alur_unit`, `permintaan_dana`, `permintaan_dana_keadaan`, `alur_dana`, `alur_dana_bagian`, `pemberi_persetujuan`, `panitia`, `alur_panitia`, `alur_panitia_baru`, `ibadah`, `kehadiran`, `alur_ibadah`, `laporan_lintas`, `web_laporan_lintas`;
  - `providers/home_rows_kolaborasi.dart`.
- Unit finance uses the Finance repositories with the DL26, DL32 and DL33 guards.
- Flows: F23, F24, P15, P16, P17, and `p01_beranda_kolaborasi_test.dart`.
- Checks: C1–C5, with C3 over the files listed.

### M10 · Joins and final sweep (Phase 6)

- J1, Party to Person:
  - PersembahanBernama, WebPersembahanBernama, PersembahanSaya (`p5/persembahan_bernama.dart`, `persembahan_bernama_blok.dart`, `web_persembahan_bernama.dart`, `p4/persembahan_saya.dart`);
  - the F4 envelope part and P14.
- J2, Warta masking: TampilanNama drives the printed names; BukaNama; letters from member records; the P9 and P13 extensions.
- J3: the Warta finance excerpt from the latest closed snapshot; the offering-to-service link; finalized attendance in the Warta.
- Delete `lib/mock/` and `lib/app/belum_dipindah.dart`. Delete `hari` and `hariTeks` from `lib/core/format.dart` once no screen reads them (G8). Refresh `prototype/README.md`.
- Checks: every item of section 11.

## 10. Working in parallel, and run hygiene

### 10.1 Parallel batches and the 4-agent cap

| Order | Runs | Agents at once |
| --- | --- | --- |
| 1 | M0 | 1 |
| 2 | M1 | 1 |
| 3 | M2 | 1 |
| 4 | M3, M4, M5 | 3 workers; the main loop only merges and checks |
| 5 | M6, M7, M8 | 3 workers; the main loop only merges and checks |
| 6 | M9 | 1 |
| 7 | M10 | 1 |

- **The cap.** No more than 4 agents run at once, the main loop included. Within M0 to M2, a milestone may use up to 3 helper agents for independent screen files, under the same file-ownership rule.
- **Worktrees.** Each worker works in its own git worktree, on a branch from the working branch's latest commit. The main loop merges a finished worker branch, then removes its worktree and branch at once (`git worktree remove --force <path>`, `git branch -D <branch>`). A built Flutter worktree is about 1 GB, and leftover worktrees once filled 220 GB.
- **File ownership.** Each file has one owner during a batch, as listed in section 9.
  - Shared files are owned by the main loop between batches: `lib/app/*`, `lib/core/*`, `lib/providers/{seed,revision,actor,session,layout,clock,home_rows}.dart`, the core and finance interfaces in `lib/data/repositories/` (4.1, 4.2), `lib/data/seed/{seed_store,build_seed,jangkar}.dart`, `lib/shell/*`, `lib/widgets/*`, `lib/theme/*`, `lib/motion/*`, `test/flows/harness.dart`.
  - Worker-owned, so that a worker never needs a shared file to finish its milestone: its module's seed file, `tabel_<modul>.dart` and `home_rows_<modul>.dart`, which M1 pre-creates as empty hooks already wired into `build_seed.dart`, `SeedStore` and `homeRowsProvider` (5.7, M1); and, for M7, M8 and M9, the interfaces of their own module (4.3, 4.4, 4.5).
  - A worker that needs a change to a shared file, such as a new query on an interface, a widget variant or a harness helper, writes it into its notes and stops that part. The main loop applies all such requests in one pass after the batch.
  - The one exception: a worker may add a `Layar` value its own screen needs, because `layar.dart` is append-only.
- **Tests and screenshots.**
  - A worker runs only its own flow tests (`fvm flutter test test/flows/<file>`), never the full suite.
  - The main loop runs the full suite (C4) only when no worker is running tests or builds.
  - Each agent takes at most one screenshot at a time. Screenshots are optional, since flow tests are the check. To look at a screen, run `fvm flutter run -d web-server --web-port 8080` and open `http://localhost:8080`.

### 10.2 Durable notes and crash safety

The machine crashed twice during the prototype build.

- **Notes.** Keep all notes, codemod scripts, progress logs and shared-file requests in the main checkout's `prototype/build/` (git ignores it), for example `prototype/build/notes/M3.md`. Never use `/tmp`. Workers write their notes there by absolute path, because a worktree's own `prototype/build/` disappears with the worktree.
- **Never run `fvm flutter clean`.** It deletes `prototype/build/`, notes included. If a build cache is broken, delete only `prototype/build/web`, `prototype/build/app` or `.dart_tool`.
- **Recovery.** After a crash, read `prototype/build/notes/`, run `git worktree list` and `git status`, remove stale worktrees, and resume from the last committed milestone.

### 10.3 Commits

- One commit per milestone on the working branch, after its checks pass. Never push: the owner pushes.
- End each commit message with the attribution lines the session gives.

## 11. Definition of done

Run from the repository root unless noted. Every item must pass.

1. `cd prototype && fvm flutter analyze` prints "No issues found!".
2. Flow tests:
   - `cd prototype && fvm flutter test` passes.
   - `grep -rnE "skip:" prototype/test/flows` prints nothing.
   - `for f in prototype/test/flows/[fp][0-9][0-9]_*_test.dart; do grep -q "masukSebagai(" "$f" || echo "$f"; done` prints nothing: every flow file drives the UI through the picker.
   - `ls prototype/test` shows only `flows`.
   - `ls prototype/test/flows/*_test.dart | sed -E 's#.*/([fp][0-9]{2})_.*#\1#' | sort -u | wc -l` prints 42.
   - `ls prototype/test/flows | grep -v -E '^([fp][0-9]{2}_.*_test\.dart|harness\.dart)$'` prints nothing.
3. Builds:
   - `cd prototype && fvm flutter build web` succeeds;
   - `cd prototype && JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home fvm flutter build apk --debug` succeeds.
4. Deleted paths are gone:
   - every path in 6.1;
   - `test ! -e prototype/lib/mock && test ! -e prototype/lib/app/belum_dipindah.dart && test ! -e prototype/tool`.
5. Grep checks over `prototype/lib` all print nothing. They also read comments, so example dates in doc comments are written as `dd/mm/yyyy`:
   - G1 `grep -rnE "PrototypeState|PrototipeLingkup|context\.tweak|tweak<|AlatPrototipe|ulangPapan|DenganGenerasi|GenerasiPapan|tukarJk|BingkaiPerangkat|Peluncur|KomponenGaleri|Belum dibangun|semuaPapan|papanBerAnak|belumDipindah" prototype/lib`
   - G2 `grep -rnE "(ke|kembaliKe|keBagi): '|kembaliKe\\('|\\.(go|push)\\('/" prototype/lib | grep -v "lib/app/router.dart"` (no string links)
   - G3 `grep -rn "jabatanKosong:" prototype/lib`
   - G4 `grep -rnE "\b[0-3][0-9]/[01][0-9]/20[0-9]{2}\b" prototype/lib` (no literal dates)
   - G5 `grep -rnE "(Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember) 20[0-9]{2}" prototype/lib`
   - G6 `grep -rnE "BKU-20[0-9]{2}-[0-9]{4}|OPN-20[0-9]{2}|SNP-20[0-9]{2}" prototype/lib`
   - G7 `grep -rnE "20(26|27)" prototype/lib | grep -v "lib/data/seed/"` (a year appears only in seed story names)
   - G8 `grep -rnE "hariTeks|const hari\b" prototype/lib`
   - G9 `grep -rnE "Timer\(|Future\.delayed" prototype/lib/screens | grep -v "// tiruan:"`
   - G10 `grep -rnE "shared_preferences|hive|sqflite|localStorage" prototype/lib prototype/pubspec.yaml` (D6)
   - G11 `grep -rnE "kIsWeb|defaultTargetPlatform" prototype/lib | grep -v "lib/app/tata.dart"` (the layout is chosen in one place)
6. `pubspec.yaml` dependencies are exactly `flutter`, `flutter_riverpod`, `go_router` and `flutter_svg`: `sed -n '/^dependencies:/,/^dev_dependencies:/p' prototype/pubspec.yaml | grep -oE '^  [a-z_]+' | sort | tr -d ' ' | paste -sd, -` prints `flutter,flutter_riverpod,flutter_svg,go_router`.
7. Board accounting: every board stem in `docs/build/navigation.md` §2.2 appears in `prototype/lib/app/layar.dart`. This prints `[]`:
   ```bash
   python3 -I - <<'EOF'
   import re
   nav = open('docs/build/navigation.md').read()
   sec = nav[nav.index('### 2.2 All 199 boards'):nav.index('#### Child routes')]
   stems = re.findall(r'^\| \d+ \| (\w+) \|', sec, re.M)
   assert len(stems) == 199
   src = open('prototype/lib/app/layar.dart').read()
   print([s for s in stems if not re.search(r'\b' + s + r'\b', src)])
   EOF
   ```
8. `git status --porcelain` is empty after the M10 commit, and the log has one `demo: M<n>` commit per milestone.

## 12. Running and checking the app

Flutter 3.47.8 through fvm, from `prototype/`.

| What | Command |
| --- | --- |
| Get packages | `fvm flutter pub get` |
| Run on web | `fvm flutter run -d chrome`, or `fvm flutter run -d web-server --web-port 8080` and open `http://localhost:8080` |
| Build web | `fvm flutter build web`, output in `build/web/`, served as static files (`python3 -m http.server -d build/web 8080`) |
| Android devices | `~/Library/Android/sdk/platform-tools/adb devices` |
| Run on Android | `JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home fvm flutter run -d <device-id>`. A phone shows phone screens; a tablet or tablet emulator (shortest side ≥ 600) shows the tablet layout |
| Debug APK | `JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home fvm flutter build apk --debug`, output `build/app/outputs/flutter-apk/app-debug.apk`; install with `~/Library/Android/sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-debug.apk` |
| Analyze | `fvm flutter analyze` |
| All flow tests | `fvm flutter test` (main loop only) |
| One flow | `fvm flutter test test/flows/f15_tutup_buku_test.dart` |
| One variant | `fvm flutter test test/flows/f02_catat_bukukan_test.dart --plain-name 'web'` |

Set `JAVA_HOME` on each Android command, as above; do not rely on the shell's default Java. No signing, no release APK, no store, and no deploy (D15).

How to try it by hand:

1. Pick Meiske and open Keuangan from her home.
2. Record and save a draft.
3. Sign out and pick Pnt. Jefry Wowor. Mark the draft checked.
4. Sign out and pick Meiske again. Book it.
5. Sign out and pick Dkn. Olga Tamba. If the draft was Diakonia, she sees it.

Reloading the page or restarting the app resets everything (D6).

## 13. Open items for the owner

None of these blocks the run. Each is built as stated, and the owner may change it later.

| # | Item | As built |
| --- | --- | --- |
| O1 | Refunds and donor returns are not supported postings until the RD04 event table is approved (DM §4.2; test vectors B35, B36 and A07 are PROPOSED) | Built as drawn and posting a refund transaction (D25). `CaseRepository.refund` and F9 are marked `// RD04: menunggu tabel kejadian` |
| O2 | Unit finalization: D17 and EC09 are still open for the engineering design | Only the product rules DL26, DL32 and DL33 are applied: a unit treasurer finalizes in their own Fund on accounts their unit operates; the Bendahara clears unit blockers with a reason |
| O3 | The second-checker rule in force at launch (D24) means every booking needs Pnt. Jefry's check, including offerings, settlements, the fee in reconciliation, fund-request payments and the unit treasurers' bookings (no unit checker is drawn). The boards draw Bukukan without it outside Pemeriksa | Built as decided. Turning it off in the app takes effect from M+1 |
| O4 | After a handover (F20) or an assignment (F25), the new Bendahara, Yohanis Tumbelaka, is not a picker persona | Finance can only be viewed for the rest of that run. A restart resets |
| O5 | Tablet and phone-only boards: D13 hides them on web; the plan also hides them on the tablet, which uses the web layout set | Hidden on the tablet |
| O6 | The applicant side of PermohonanAnggota and AlurAnggota is reachable by no persona, because the applicant, Kevin, is not one (D17, D22) | The screen opens Kevin's submitted application for the verifier (DP36); the empty form stays in the code, unreachable |
| O7 | The last Sunday's offering is seeded and F4 records it again in parts (DP5) | No duplicate check, because none is drawn |
| O8 | Panitia Natal holds no money of its own (DP27); Kas Kolom 7 is counted in all-account totals and the opening (DP16) | As in the Data picks |
| O9 | Seasonal story names (Natal, Adven, Paskah) keep their drawn names and years in any month (D8) | Kept |
| O10 | Reimbursement claims have no entity in DM §3; Service and FundRequest have no written state machine | A `Claim` record in `CaseRepository`; board labels as states |
| O11 | Reads are synchronous over the in-memory store; a Supabase implementation needs a realtime local cache behind the same read signatures (3.3) | Commands are already asynchronous with their full signatures (D1) |
| O12 | Homes for Lidya, Deasy, Olga, Jefry, Rivo and Greis are not drawn | Built from their open items with the drawn row kinds |
| O13 | Finance has no link back to the platform home (navigation.md §1.5) | Not added; Back returns home through the route stack |
| O14 | Voucher numbers are computed by the app's counter, so the screens do not show the drawn numbers (October starts right after September's last row, not at 0098) (DP38) | As in the Data picks |
| O15 | Who records the new Bendahara: the boards draw Meiske's handover alone; DL21 has the authorized church officer record it (DP39) | Meiske prepares, Pdt. Lidya records, the Petugas verifikasi activates |
