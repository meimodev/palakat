# Screens 08: Cari, WebCari, WebCatat, WebVerifikasi, PetaLayar, Cakupan, WebExcel, Persetujuan, WebPersetujuan

These nine boards are mixed supporting screens. **Cari** (phone) and **WebCari** (laptop) answer a search typed in everyday words with a total the app computes from the records shown (D33), plus optional AI help that explains the result or proposes a monthly narrative (D31). Main and Lainnya open Cari; WebBeranda, WebTransaksi, TabBeranda and TabTransaksi open WebCari. The result rows lead to Main or WebTransaksi. **WebCatat** is the laptop form for recording a Pendapatan, Belanja or Pindah antar Kas/Bank, with a live checklist and Bukukan. WebTransaksi, TabTransaksi and most web "Catat" links open it, and its link row opens eight specialised boards (WebBagi, WebPersembahan, WebAlihPeruntukan, WebAIFoto, WebPersetujuan, WebTanggal, WebAIMataAnggaran, WebBantuanAI). **WebVerifikasi** is the internal page of the Palakat Petugas verifikasi, who activates, returns or revokes the Bendahara's authority. The launcher, PetaLayar and Cakupan reach it; no app board does. **PetaLayar** and **Cakupan** are design sheets on the page "Peta dan keputusan": a map of every finance screen and a table of which states are drawn where. Every name on them opens its board. Keputusan opens PetaLayar; Cakupan is reached only from the launcher. **WebExcel** shows the October 2026 official report pack as an Excel workbook with one sheet per form F01–F14. Phone and web report screens open it (Laporan, TutupBuku, FormatLaporan, WebLaporan, WebPaketLaporan, WebTutupBuku, WebFormatLaporan). **Persetujuan** (phone, from Koreksi and Lainnya) and **WebPersetujuan** (laptop, from WebCatat, TabCatat, and "Catat persetujuan" on WebTransaksi and TabTransaksi) replace a wrong approval record without editing it, and show an approval becoming void when the amount changes. Two rules apply throughout. An **up link** is a phone back arrow or a web breadcrumb: it runs `kembaliKe('/X')`, which pops when the route directly below is `/X` or a child of `/X` and otherwise does `go('/X')`. Every other board link is `push`, and side-nav items are `go`. Each board owns its interaction state for as long as it stays in the navigation stack, so returning to it with Back finds it as it was. Reopening it fresh resets it, as reopening an artboard on the canvas does. "Today" is 16/11/2026 and the actor is Meiske L., Bendahara. The shared web side nav is specified once, under WebCari.

---

### Cari — 28 · Cari dan tanya
- **Source** `docs/design/handoff/canvas/boards/Cari.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/Cari`. No child routes: every state changes in place. · **Widget** `CariScreen` in `lib/screens/lengkap/cari.dart`
- **Purpose** Bendahara Jemaat on the phone, in daily work (03's role journeys do not name "28 · Cari dan tanya"; it sits beside journey "Bendahara Jemaat" step 2, "1 · Harian". It is reached from Main's Transaksi link "Cari" and Lainnya's "Cari · Dengan kata sehari-hari"). She searches in everyday words. The app shows how it read the query ("Dibaca sebagai …"), a total computed by the app from the four posted records shown (D33, "bukan oleh AI"), and the records themselves. An optional AI panel can explain the result or propose a monthly narrative. Both are KartuUsulanAI cards with a dotted `laut` edge and italic text (D31), and the AI never gives an official figure. Ignoring an AI suggestion needs no reason. Keputusan links D33 to this board.
- **Shell** Phone header with back, no tab bar. Root column 390×844: `kertas` background, `tinta` text, sans 16 / line-height 1.4. When `jabatanKosong` is on, the phone PitaJabatanKosong strip sits above the header (Layout 0). Below it the content fills the rest: a fixed header, then one vertical scroll area.
- **Layout**
  0. (only when `jabatanKosong`) Strip, live region (`role=status`): full width, not scrolled, `tinta` field, `permukaan` text, padding 10/24/8, 13 px line-height 1.3, centred: "**Menjalankan jabatan kosong** · Bendahara Jemaat".
  1. Header row: padding 14 top, 12 sides, 8 bottom; gap 8; items centred. Back target 44×44 with the chevron icon (path `M15 6l-6 6 6 6`, 22 px, stroke 2, round caps, `tinta`), Semantics "Kembali ke Beranda". Title block (flex 1): "Cari" (`judulLayar` 18/700, margin 0); under it "Jemaat Karunia" (13 px `tinta2`. The board sets 14 and then overrides it with 13.)
  2. Scroll area (flex 1, scrolls vertically): padding 8 top, 20 sides, 20 bottom; column gap 16. Children:
     a. **Search field**: full width, min-height 52, padding 0 14, radius 12 (`isian`), 1 px `garisTegas` border, `permukaan` field, text 16 `tinta`. Hint "Cari dengan kata sehari-hari". Semantics label "Cari transaksi". Initial value "persembahan Minggu pagi bulan Oktober".
     b. **Answer** (only when the query matches): a block of three lines.
        - "Dibaca sebagai: Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu · Oktober 2026 · ibadah pagi" (14 `tinta2`).
        - "Rp10.950.000" (mono 30/500, letter-spacing −1, `tinta`; this is `jumlahIsian` plus the letter-spacing).
        - "Jumlah dari 4 transaksi yang sudah dibukukan. Angka ini dihitung aplikasi dari catatan, bukan oleh AI." (13 `tinta3`).
     c. **Results card** (only when the query matches): `permukaan`, 1 px `garis` border (dibukukan), radius 14, padding 0 16. Four link rows: flex, centred vertically, gap 12, min-height 56, a 1 px `garis` top rule from the second row on, `tinta`, no underline. Left side (flex 1): "Persembahan Ibadah Minggu" (15/600, block), then a second line at 13 `tinta3`: No. Bukti in mono + " · {tanggal} · Kas". Right side: the amount, mono 16/500 `tinta` (`jumlah`). Rows are under Mock data.
     d. **Empty state** (only when the query does not match): 1.5 dashed `putus` border (draf), radius 14, padding 16, 14 `tinta2`: "Tidak ada transaksi yang cocok di Jemaat Karunia."
     e. **AI panel**: `lautLembut` field, radius 16 (`kartuBesar`), padding 14/16, column gap 10, no border. In order:
        - Label "BANTUAN AI · PILIHAN": 13/700 `lautTua`, letter-spacing 0.3.
        - Explanation slot. It shows exactly one of the following, or nothing:
          - `aiBelum` (ai is 'belum' and the query matches): button "Jelaskan hasil ini". Full width (the column stretches it), min-height 44, radius 12, 1.5 solid `laut` border, `permukaan` field, `lautTua` text 16/700 centred, padding 0 16.
          - `aiProses`: status line "Menyusun penjelasan…" (min-height 44, centred vertically, 14/600 `lautTua`), live region.
          - `aiAda`: an explanation card (KartuUsulanAI): `permukaan` field, 1.5 dotted `laut` border (usulanAI), radius 12, padding 14, column gap 6. It contains:
            - Tag "Usulan AI · penjelasan", aligned left: 13/700 `lautTua`, 1.5 dotted `laut` border, radius 6, padding 2 8.
            - Text (14 italic `lautTua`): "Empat ibadah Minggu pagi di Oktober tercatat, dengan persembahan terbesar pada 4 Oktober. Persembahan 18 Oktober paling kecil; itu bertepatan dengan ibadah padang."
            - Caption (13 `tinta3`): "Berdasarkan 4 transaksi di atas saja. AI tidak melihat peruntukan atau Jemaat lain."
          - Nothing when ai is 'belum' and the query does not match.
        - Narrative block: 1 px solid top border #C9DAD9 (see Notes), padding-top 10, column gap 8. It shows exactly one of:
          - `nBelum`: button "Buat usulan narasi bulanan Oktober", styled like "Jelaskan hasil ini".
          - `nAda`: a narrative card. Same card as the explanation, except column gap 8.
            - Tag "Usulan AI · narasi bulanan".
            - Italic text: "Pada Oktober 2026 Pendapatan Jemaat Rp14.820.000 dan Belanja Rp11.455.000. Belanja terbesar adalah pemeliharaan gedung. Semua Kas/Bank sudah direkonsiliasi tanpa selisih."
            - Action row (wrap, gap 8), three buttons, each min-height 44, padding 0 16, radius 10, 700: "Pakai" (`laut` field, `diLaut` text, no border), then "Ubah" and "Abaikan" (both 1.5 `tinta` border, `permukaan` field, `tinta` text).
          - `nPakai`: status line 14/600 `tinta`, live region: "Narasi disalin ke catatan pengantar laporan dan dapat Anda ubah. Angka di laporan resmi tetap dari catatan."
          - `nAbai`: status line 14/600 `tinta`, live region: "Diabaikan. Tidak perlu alasan."
        - Footer "AI hanya mengusulkan dan tidak memberi angka resmi." (13 `tinta2`. The board sets `tinta3` and then overrides it with `tinta2`.)
- **Components** Two KartuUsulanAI cards (explanation, narrative). The narrative card has the component's three actions Pakai/Ubah/Abaikan, with no confidence line. PitaJabatanKosong (phone strip). Tombol: primary "Pakai", secondary "Ubah" and "Abaikan". The AI buttons are a `laut`-outlined secondary variant. GarisStatus: results card dibukukan, empty box draf, AI cards usulanAI. Repeated pattern that is not a component: a result row (title, "No. Bukti · tanggal · Kas", amount on the right), shared with WebCari.
- **Internal views and states** Initial state `{ q: 'persembahan Minggu pagi bulan Oktober', ai: 'belum', narasi: 'belum' }`. Derived: `cocok` = the query matches `/persembahan|minggu|oktober/i` (case-insensitive, anywhere in the text). The views:
  - Match: answer and results shown.
  - No match: the empty box is shown and the explanation button is hidden.
  - The explanation goes 'belum' → 'proses' → 'ada'.
  - The narrative goes 'belum' → 'ada' → 'pakai' or 'abai'. It does not depend on the query.

  No sheets, toasts or routes.
- **Tweaks** `jabatanKosong` (boolean, default false), in the Keadaan panel as the global switch. On: shows strip 0 and nothing else. The text swap is disabled on this board (`jk && false`), and no string on the board contains "Meiske L." anyway.
- **Interactions**
  - Search field `onQ`, on every keystroke: `q` = the field text and `ai` = 'belum'. Results, answer and empty state follow `cocok` live. The narrative state is untouched. On the board the 1300 ms timer started by "Jelaskan hasil ini" is *not* cancelled here (see Notes; the recommendation is to cancel it).
  - "Jelaskan hasil ini" (`tanya`): `ai` = 'proses'. Cancel any running timer, then after 1300 ms set `ai` = 'ada'. The delay fakes the AI composing. Use `Future.delayed` or a `Timer`, cancelled on dispose.
  - "Buat usulan narasi bulanan Oktober" (`buatNarasi`): `narasi` = 'ada', instantly with no delay.
  - "Pakai" and "Ubah" (both `pakaiNarasi`): `narasi` = 'pakai'.
  - "Abaikan" (`abaiNarasi`): `narasi` = 'abai'. No reason is asked.
  - The board has no way back from 'pakai' or 'abai'.
  - Result row: push `/Main`.
  - Back arrow: up link to `/Main`.
  - On unmount, cancel the timer.
- **Motion**
  - The explanation card and the narrative card each enter with `muncul` (motion.md: muncul): 300 ms, fade in from opacity 0 while rising 8 px, CSS `ease`. It runs each time the card appears.
  - "Menyusun penjelasan…" has no animation. It stays for exactly 1300 ms, the timer that fakes AI work.
  - The board also declares the keyframes `masuk`, `pudar` and `isi` but never uses them.
  - Under reduce motion, the cards appear at once. The 1300 ms wait stays, because it is a state, not an animation.
- **Links out**
  - Back arrow (no label, Semantics "Kembali ke Beranda") → `/Main`, up link.
  - Each of the four result rows → `/Main`, push. All rows use `Tautan(ke: 'Main')`.

  **Inbound** Keputusan, Lainnya, Main (manifest), plus PetaLayar ("Cari dan tanya", JS-built, missing from the manifest).
- **Mock data**
  - Query: "persembahan Minggu pagi bulan Oktober".
  - Reading: "Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu · Oktober 2026 · ibadah pagi".
  - Rows (No. Bukti · tanggal · amount, all titled "Persembahan Ibadah Minggu", Kas/Bank "Kas"):
    1. BKU-2026-0098 · 04/10/2026 · Rp3.200.000
    2. BKU-2026-0107 · 11/10/2026 · Rp2.650.000
    3. BKU-2026-0114 · 18/10/2026 · Rp2.400.000
    4. BKU-2026-0123 · 25/10/2026 · Rp2.700.000
  - Total Rp10.950.000, which is exactly the sum of the four rows.
  - Narrative figures: Pendapatan Rp14.820.000 and Belanja Rp11.455.000 for Oktober 2026. These match WebExcel F05 and F07.
  - Church: Jemaat Karunia.
- **Prototype-only** None of the four devices appear on this board. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/Cari`. The field reads "persembahan Minggu pagi bulan Oktober", the answer shows "Rp10.950.000", and the first of four rows reads "BKU-2026-0098 · 04/10/2026 · Kas" with "Rp3.200.000" on the right.
  2. Replace the query with "listrik". The dashed box "Tidak ada transaksi yang cocok di Jemaat Karunia." appears, answer and rows disappear, "Jelaskan hasil ini" disappears, and "Buat usulan narasi bulanan Oktober" is still shown.
  3. Type "OKTOBER". The results return, because matching is case-insensitive.
  4. Tap "Jelaskan hasil ini". "Menyusun penjelasan…" shows for 1300 ms, then the dotted card "Usulan AI · penjelasan" rises in over 300 ms with italic `lautTua` text.
  5. With the explanation shown, type one more character. The card goes and "Jelaskan hasil ini" returns.
  6. Tap "Buat usulan narasi bulanan Oktober". The narrative card appears immediately with "Pakai", "Ubah" and "Abaikan".
  7. Tap "Ubah". The line "Narasi disalin ke catatan pengantar laporan dan dapat Anda ubah. Angka di laporan resmi tetap dari catatan." replaces the card. On a fresh open, "Abaikan" shows "Diabaikan. Tidak perlu alasan." instead.
  8. Tap row 2. `/Main` opens. Back returns to `/Cari` with the same query and AI state.
  9. The back arrow leads to `/Main`.
  10. Turn on `jabatanKosong` in the Keadaan panel. The strip "Menjalankan jabatan kosong · Bendahara Jemaat" appears above the header.
- **Notes**
  - #C9DAD9, the divider above the narrative block, is not a token. CONVENTIONS allows it as a literal illustration colour and says it is used in A4Warta and WebWartaEditor. In fact Cari and WebCari are the only boards that use it. Keep the literal in `lib/theme/` as a named constant, and use `garis` for it in dark mode.
  - Timer race on the board: typing while "Menyusun penjelasan…" shows resets `ai` to 'belum', but the 1300 ms timer still fires. The explanation then appears even when the new query matches nothing. Recommended: cancel the timer in `onQ`. It is a one-line fix and avoids an AI card that explains records no longer on screen. List it as a deliberate deviation.
  - "Ubah" behaves exactly like "Pakai" (the text is copied into the report introduction, where it can be edited). The board has no edit view. Keep it.
  - Result rows open Main (Beranda), not a transaction detail. Keep as drawn.
  - D33: the board hard-codes "Rp10.950.000". Compute it as `rp(sum of the shown rows)` from the same mock list; the result is identical and the rule holds by construction.
  - 15 px for the row titles is off-token on the phone. Copy it.
  - The manifest's `hasSideNav: true` is a false positive: the board has no side nav.

### WebCari — Web · Cari dan tanya
- **Source** `docs/design/handoff/canvas/boards/WebCari.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebCari`, no child routes · **Widget** `WebCariScreen` in `lib/screens/lengkap/web_cari.dart`
- **Purpose** The same search as Cari for the Bendahara Jemaat at the desk (D33, D31). The search and results sit on the left, and the optional AI panel is a right-hand column, following the rule that phone panels become side columns on web. It is reached from "Cari dan tanya" on WebBeranda and TabBeranda, and "Cari" on WebTransaksi and TabTransaksi.
- **Shell** Web side nav, active item **Transaksi**. It is specified once here, and WebCatat, WebExcel and WebPersetujuan use it too:
  - Page root: `kertas` background, `tinta` text, sans 15 / line-height 1.45 (`isiWeb`). It is a wrapping row of nav plus main and fills the window height.
  - Nav column: flex basis 220 (grows 1), padding 24 vertical / 16 horizontal, `permukaan` field, 1 px `garis` right border, column gap 20.
  - Brand row (gap 10, padding 0 8, centred): the Palakat mark 26×26. It is a rect at 2,2 sized 20×20 with rx 6, no fill, `laut` stroke 2 dashed 3 3, plus the path `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z` filled `laut`. Beside it "palakat" (18/700, line-height 1.1) over "Jemaat Karunia" (13 `tinta3`).
  - Items, in this order:
    - "Beranda" → `/WebBeranda`
    - "Transaksi" → `/WebTransaksi`
    - "Uang Muka dan Titipan" → `/WebKewajiban`
    - "Rekonsiliasi" → `/WebRekonsiliasi`
    - "Bulan dan tutup buku" → `/WebTutupBuku`
    - "Laporan" → `/WebPaketLaporan`
    - "Pengaturan" → `/WebPengaturan`

    Each item: min-height 44, padding 0 12, radius 10 (off-token), 600, no underline. Active: `tinta` field with `permukaan` text. The others: transparent with `tinta` text. All items use `go` via `Tautan`.
  - Footer: margin-top auto, padding 12/8/0, 1 px `garis` top rule, 13 `tinta2`. Default: "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif", with the name in `tinta`. With `jabatanKosong`: "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat".
  - At 860 px and below (`max-width: 860px`) the nav becomes a full-width top bar (row, wrap, centred, padding 8/16, no right border, 1 px `garis` bottom border, gap 0 12). While the menu is closed only the brand row and the toggle show; the items and the footer are hidden.
    - A toggle sits at the right: min-height 44, padding 0 16, radius 14, 1.5 `tinta` border, `permukaan` field, 14/700, label "Menu".
    - When open it becomes a `tinta` field with `permukaan` text labelled "Tutup menu". The items and the footer then show at full width below the brand (items padding 8 0; footer without the auto margin, padding-bottom 8).
  - Main column: flex 999 1 560, min-width 0, padding 28 top / clamp(16, 3vw, 40) sides / 40 bottom, column gap 20.
  - With `jabatanKosong` on, the first child of main is the web PitaJabatanKosong, a live region: `tinta` field, radius 14, padding 12/16, 14 px. Text: "**Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.**" followed by " Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." in `diTinta2`.
- **Layout**
  1. h1 "Cari" (`judulHalaman` 26/700, margin 0). There is no breadcrumb.
  2. Two-column row: wrap, gap 24, aligned top. The left column takes flex 999 1 480 and the right aside takes 1 1 380. At 1440 the aside is about 380 wide on the right. When main is narrower than 884 the aside drops below the left column.
     - Left column (column, gap 16): same as Cari regions 2a–2d. The search field is identical (min-height 52, 16 px text). The answer is identical. The results card is identical except the row amount is mono 15/500, inheriting the web body size, and the rows link to `/WebTransaksi`. The empty box is identical.
     - Aside: the AI panel, identical to Cari region 2e. Button labels inherit 15/700 instead of 16/700. The panel is as tall as its content, not stretched.
- **Components** As Cari, plus the shared web side nav and the web PitaJabatanKosong.
- **Internal views and states** Same state object and views as Cari: `{ q: 'persembahan Minggu pagi bulan Oktober', ai: 'belum', narasi: 'belum' }`.
- **Tweaks** `jabatanKosong` (boolean, default false), in the Keadaan panel as the global switch. On: the web banner appears at the top of main, and the nav footer switches to Yanti Sumual. The text swap is disabled (`jk && false`).
- **Interactions** Identical to Cari: `onQ`, `tanya` (1300 ms), `buatNarasi`, `pakaiNarasi` (Pakai and Ubah), `abaiNarasi`. The recommended timer cancellation in `onQ` applies here too. Result row: push `/WebTransaksi`. Side-nav items use `go`. Cancel the timer on dispose.
- **Motion** The cards enter with `muncul` 300 ms (CSS `ease`). The board also declares `isi` and `titik` but does not use them. Under reduce motion the cards appear at once.
- **Links out** Each of the four result rows → `/WebTransaksi`, push (`Tautan(ke: 'WebTransaksi')`). Side nav: WebBeranda, WebTransaksi, WebKewajiban, WebRekonsiliasi, WebTutupBuku, WebPaketLaporan, WebPengaturan, all `go`. **Inbound** TabBeranda, TabTransaksi, WebBeranda, WebTransaksi (manifest), plus PetaLayar ("Cari dan tanya", JS-built, missing from the manifest).
- **Mock data** As Cari: the same four rows, total Rp10.950.000, the same reading and the same two AI texts. Banner: since 16/11/2026 08.15, Operator Yanti Sumual.
- **Prototype-only** None. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/WebCari` at 1440. Side-nav "Transaksi" is filled `tinta`, the AI panel sits right of the results, and four rows are shown.
  2. Type "zzz". The empty box appears, the aside keeps "BANTUAN AI · PILIHAN" and the narrative button, and there is no explanation button.
  3. Click "Jelaskan hasil ini". "Menyusun penjelasan…" shows, and after 1.3 s the dotted explanation card rises in.
  4. Click the "BKU-2026-0114" row. `/WebTransaksi` opens, and browser Back returns with the AI card still shown.
  5. Narrow the window to 860 px. The nav becomes a top bar with "Menu" and the AI panel moves below the results without horizontal page scroll.
  6. Turn on `jabatanKosong`. The banner "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15." shows above "Cari", and the nav footer reads "Yanti Sumual · Operator".
- **Notes**
  - The #C9DAD9 divider and the timer race are the same as on Cari; apply the same choices.
  - The side nav marks "Transaksi" active because search lives under Transaksi on web, while PetaLayar files "Cari dan tanya" under Beranda. Keep the board.

### WebCatat — Web · Catat transaksi
- **Source** `docs/design/handoff/canvas/boards/WebCatat.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1150, `expand: fill`) · interactive yes
- **Route** `/WebCatat`. No child routes: the posted state replaces the aside in place. · **Widget** `WebCatatScreen` in `lib/screens/lengkap/web_catat.dart`
- **Purpose** Bendahara Jemaat at the desk, daily work (journey "Bendahara Jemaat" step 2: the web side of "1 · Harian: catat sampai bukukan"). She records a Belanja, Pendapatan or Pindah antar Kas/Bank, sees a live checklist of what Bukukan needs, and posts it. The board shows:
  - D01: Kas/Bank, peruntukan and Lingkup are never pre-filled; they start empty as separate fields. Mata Anggaran also starts empty (that part is the board's, not D01's wording).
  - D02: a missing supporting document is only "Untuk diketahui" (dashed circle). It does not block Bukukan, but it is a blocker for month close.
  - PemilihMataAnggaran rules: the tree name appears with each number; group headings cannot be chosen; "Simpan tanpa Mata Anggaran" exists; there is no "Lainnya".
  - A Pindah is neither Pendapatan nor Belanja.
  - The line language: a dashed draft card becomes solid when "Dibukukan".
- **Shell** Web side nav as WebCari, active item **Transaksi**. It includes the `jabatanKosong` banner and footer.
- **Layout** Main column children, top to bottom:
  1. Title block: breadcrumb link "Transaksi" (14/600 `laut`, underlined as a plain link, `lautTua` on hover), then h1 "Catat transaksi" (26/700, margin-top 2).
  2. Link row, pulled up 8 px (margin-top −8): wrap, gap 0 22, 14/600 `laut` underlined links. Each is a 44×44-minimum target with its text centred vertically. In order: "Bagi ke beberapa Mata Anggaran", "Persembahan", "Alih peruntukan", "Dari foto nota", "Ganti catatan persetujuan", "Tanggal transaksi", "Usulan Mata Anggaran", "Dari kalimat". Targets are under Links out.
  3. Jenis chips (ChipPilihan): wrap, gap 8, margin 0. The chips, in order: "Pendapatan", "Belanja", "Pindah antar Kas/Bank".
     - Each chip: min-height 44, padding 0 14, radius 999, 1.5 border, 14/600.
     - Selected: `tinta` field, `tinta` border, `permukaan` text.
     - Unselected: `permukaan` field, `garisTegas` border, `tinta` text.
     - Semantics: selected state (`aria-pressed`). "Belanja" starts selected. Every chip in the form (Kas/Bank, Ke Kas/Bank, peruntukan, Lingkup) and every postable Mata Anggaran row carries the same `aria-pressed` selected state.
  4. Two-column body: wrap, gap 28, aligned top. The left form takes flex 999 1 480 and the right aside takes 1 1 360. At 1440 the aside is about 360 wide. When main is narrower than 868 the aside drops below the form.
     **Left form** (column, gap 18):
     a. **Jumlah** (IsianJumlah).
        - Label "Jumlah (Rp)" (14 `tinta2`, tied to the field).
        - Input row: baseline-aligned, gap 8, mono, a 2 px `tinta` underline, padding-bottom 4, max-width 420.
        - Prefix "Rp" (mono 24, `tinta3`).
        - Input: mono 40/500, letter-spacing −1, transparent, no border, padding 0, min-height 44, numeric keyboard.
        - When empty it shows the hint "0" in `tinta3`. Formatting is under Interactions.
     b. Field grid: auto-fit columns, each at least min(260, 100%), gap 18. At 1440 this gives two columns. Each field has a label (14 `tinta2`, margin-bottom 8) and chips that flow inline (same chip style as 3, but margin 0 8 8 0).
        - Kas/Bank field. Label "Kas/Bank", or "Dari Kas/Bank" when Pindah. Chips "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107".
        - (Pindah only) "Ke Kas/Bank": the same three chips, then the caption "Bukan Pendapatan dan bukan Belanja. Biaya bank dicatat sebagai Belanja tersendiri." (13 `tinta3`).
        - (Belanja/Pendapatan only) Peruntukan field. Label "Diambil dari peruntukan" (Belanja) or "Masuk ke peruntukan" (Pendapatan), followed by " · uang siapa ini" in `tinta3`. Chips "Umum Jemaat", "Diakonia", "Pembangunan".
        - (Belanja/Pendapatan only) "Lingkup". Chips "Jemaat", "Kolom 3", "BIPRA Pemuda", "Panitia Natal".
     c. (Belanja/Pendapatan only) **Mata Anggaran** (PemilihMataAnggaran), a column with gap 8.
        - Heading row (wrap, centred, gap 10): "Mata Anggaran" (14 `tinta2`) + " · untuk apa" (`tinta3`), then a tree badge: 13/700, radius 6, padding 3 9, `tinta` field, `permukaan` text, reading "Belanja" or "Pendapatan".
        - Picker card: `permukaan`, 1 px `garis`, radius 14, padding 10/14.
        - Search input inside the card: full width, min-height 44 (the board sets 48 and then overrides it), padding 0 14, radius 12, 1 px `garisTegas`, `kertas` field (overridden from `permukaan`). Hint "Cari nomor atau nama". Semantics "Cari Mata Anggaran".
        - Rows, in list order:
          - Group heading (not pressable): padding 10 top / 4 bottom. Mono 13 `tinta3` number, a space, the name in 14/700 `tinta2`, then " · Judul kelompok, tidak dapat dibukukan" in 13 `tinta3`.
          - Postable row (button): full width, baseline row, gap 12, min-height 44, padding 8/12, radius 10, `permukaan`, margin-top 4. Border 1 px `garis`, or 2 px `tinta` when selected. Text: mono 13 `tinta2` "{tree} {number}" (e.g. "Belanja 5.01.02.00"), then the name at 15/600.
        - Below the list, the button "Simpan tanpa Mata Anggaran": margin-top 10, min-height 44, padding 0 16, radius 10, 1.5 dashed `putus` (draf), transparent, 700 `tinta2`.
     d. (Belanja/Pendapatan only) Text fields grid (same auto-fit 260 rule, gap 18). Each has a label (14 `tinta2`, block, margin-bottom 6) and an input (full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan`).
        - Left label: "Dibayar kepada" (Belanja) or "Diterima dari (boleh tanpa nama)" (Pendapatan).
        - Right label: "Uraian".
        - Both start empty.
     e. Footer row: wrap, centred, gap 12/24, 1 px `garis` top rule, padding-top 14.
        - Text: "Tanggal transaksi" (14 `tinta2`), a space, then "**16 November 2026**" (700).
        - Attach button: min-height 44, padding 0 16, radius 12, 600.
          - Not attached: "Lampirkan dokumen pendukung", 1.5 dashed `putus`, transparent, `laut` text.
          - Attached: "nota-16-11.jpg · Terlampir", 1 px `garisTegas`, `permukaan`, `tinta` text.
     **Right aside** (column, gap 14):
     f. **Draft card**: radius 16, padding 18, column gap 6, clipped. Draft: transparent field, 1.5 dashed `putus` (draf). Posted: `permukaan` field, 1.5 solid `tinta` (terpilih).
        - Top row (space-between, gap 16, centred):
          - Status badge, 13/700, radius 6, padding 3 9. Draft: "Draf · belum masuk saldo", transparent, 1.5 dashed `putus`, `tinta2` text. Posted: "Dibukukan", `tinta` field, 1.5 `tinta` border, `permukaan` text.
          - (posted only) Stamp "No. Bukti BKU-2026-0147": mono 14/600 `laut`, 2 px `laut` border, radius 8, padding 4 10.
        - Amount: mono 32/500, letter-spacing −1, `tinta2` (draft) or `tinta` (posted). Value: `rp(jumlah × sign)`, where sign is −1 for Belanja and +1 otherwise. "Rp0" when empty.
        - Summary line (600):
          - Pindah: "Dari {asal or …} ke {tujuan or …}", using U+2026 for an unchosen side.
          - Otherwise: Uraian if filled, else Pihak, else the jenis name ("Belanja" / "Pendapatan").
     g. (not posted) **Checklist card**: `permukaan`, 1 px `garis`, radius 14, padding 4/16. Rows: gap 10, aligned top, padding 10 0, a 1 px `garis` top rule from the second row on. Each row has a 20×20 icon, then text at 14/600 `tinta`.
        - Icons, each drawn from the board's SVG:
          - Terpenuhi: a circle r 11 filled `laut`, with the tick `M7 12.5l3.2 3.2L17 9` in `diLaut`, stroke 2.2, round.
          - Belum terpenuhi: a rect at 1,1 sized 22×22 with rx 6, filled `bata`, with `M12 6.5v7M12 17v.5` in `diBata`, stroke 2.4, round.
          - Untuk diketahui: a circle r 10, no fill, `tinta3` stroke 2, dashed 3 3.
        - Semantics labels: "Terpenuhi", "Belum terpenuhi", "Untuk diketahui".
        - Lines in order are under Interactions.
     h. (not posted, at least one unmet) Refusal line: 14/600 `bata` "Tidak dapat dilakukan: {n} syarat belum terpenuhi."
     i. (not posted) Action row (wrap, gap 8):
        - "Periksa dan bukukan": min-height 46, padding 0 20, radius 12, no border, 700. Enabled: `laut` field, `diLaut` text. Unmet: `garis` field, `tinta3` text.
        - "Simpan sebagai draf": a link styled as a secondary button. Min-height 46, padding 0 20, radius 12, 1.5 `tinta` border, `permukaan`, `tinta` 700, centred, no underline.
     j. (posted) "Dibukukan pada 16/11/2026 10.42 · tidak dapat diubah lagi." (14 `tinta2`). Then the button "Catat lagi" (secondary: 46 high, 1.5 `tinta`, `permukaan`, 700), aligned left.
- **Components**
  - ChipPilihan: jenis, Kas/Bank, Ke Kas/Bank, peruntukan, Lingkup.
  - IsianJumlah.
  - PemilihMataAnggaran: search, group headings, "Simpan tanpa Mata Anggaran".
  - LencanaStatus: "Draf · belum masuk saldo" uses the Draf shape; "Dibukukan" uses the Dibukukan shape. The tree badge reuses the `tinta`-field shape but is a label, not a status.
  - TombolBersyarat-style "Periksa dan bukukan" with its refusal line. Tombol secondary: "Simpan sebagai draf", "Catat lagi".
  - ButirPerhatian "Untuk diketahui" as the plain document line.
  - PitaJabatanKosong (web) and the shared side nav.
  - Repeated pattern, not a component: the checklist row with the three status icons. Main's Periksa view uses the same icons.
- **Internal views and states** Initial state `{ jenis: 'belanja', jm: '', pihak: '', ur: '', akun: null, ke: null, per: null, ling: null, ma: null, cari: '', dok: false, posted: false }`. Views:
  - Jenis Belanja (default) or Pendapatan: Kas/Bank, peruntukan, Lingkup, Mata Anggaran and the text fields are shown.
  - Jenis Pindah: "Dari Kas/Bank" and "Ke Kas/Bank" with the caption. Peruntukan, Lingkup, Mata Anggaran and the text fields are hidden.
  - Draft vs posted (`posted`): the aside changes as in f–j. The form stays visible.
  - Document attached or not (`dok`).
  - Live filter of the Mata Anggaran list (`cari`).

  No sheets, toasts or routes.
- **Tweaks** `jabatanKosong` (boolean, default false), in the Keadaan panel as the global switch. On: the web banner and the nav footer switch. The text swap is disabled (`jk && false`).
- **Interactions**
  - Jenis chip (`jenis[].pick`): does nothing when posted. Otherwise sets `jenis`, and resets `ma` = null, `ke` = null and `cari` = ''. Kas/Bank (`akun`), peruntukan, Lingkup, amount, Pihak, Uraian and `dok` are kept. Peruntukan and Lingkup are only hidden while Pindah. Tapping the jenis chip that is already selected still clears `ma`, `ke` and `cari` (the board sets the state unconditionally).
  - Amount (`onJm`, every keystroke): does nothing when posted. Keep digits only, strip leading zeros, cap at 12 digits, and store the raw digits in `jm`. The field displays them with dot thousands separators while typing ("001250000" → "1.250.000"). Implement it as a `TextInputFormatter` that keeps the caret at the end. Store on every change, so the first press of "Periksa dan bukukan" after the last keystroke works.
  - Kas/Bank, Ke Kas/Bank, peruntukan and Lingkup chips: do nothing when posted. Otherwise each sets its own field to the chip's id ('kas', 'bni', 'bsg' for the Kas/Bank chips; the label for the others). Picking the selected chip again keeps it selected; there is no deselect.
  - Mata Anggaran search (`onCari`, every keystroke): `cari` = text. The list keeps every group heading, plus each postable row whose "{number} {name}" lower-cased contains the lower-cased query. This handler also works when posted.
  - Mata Anggaran row (`r.pick`): does nothing when posted. Otherwise `ma` = the number, and the row gets a 2 px `tinta` border.
  - "Simpan tanpa Mata Anggaran" (`tanpaMa`): does nothing when posted. Otherwise `ma` = null. It saves nothing and does not navigate; the Mata Anggaran line becomes unmet again.
  - Pihak (`onPihak`) and Uraian (`onUr`): free text, stored on every keystroke. On the board they stay editable after posting (see Notes).
  - "Lampirkan dokumen pendukung" (`lampir`): does nothing when posted. Otherwise `dok` = true. There is no way to detach.
  - Checklist lines, in order. Each is met (✓) or unmet (!) unless marked "info". The TombolBersyarat condition is "no unmet line".
    1. Jumlah: met "Jumlah {rp(j)}" (always positive, e.g. "Jumlah Rp1.250.000"), else unmet "Jumlah belum diisi".
    2. Belanja/Pendapatan:
       - Kas/Bank: met "Kas/Bank: {name}", else unmet "Kas/Bank belum dipilih".
       - Peruntukan: met "{label}: {value}" (e.g. "Diambil dari peruntukan: Diakonia", "Masuk ke peruntukan: Umum Jemaat"), else unmet "Peruntukan belum dipilih".
       - Lingkup: met "Lingkup: {value}", else unmet "Lingkup belum dipilih".
       - Mata Anggaran: met "Mata Anggaran sudah dipilih", else unmet "Mata Anggaran belum dipilih · tetap bisa disimpan sebagai draf".
       - Always met: "Persetujuan: tidak diperlukan (aturan: transaksi rutin)".
    3. Pindah:
       - Met "Dari {asal} ke {tujuan}" when both are chosen and different, else unmet "Kas/Bank asal dan tujuan belum dipilih, dan harus berbeda".
       - Always met: "Bukan Pendapatan dan bukan Belanja".
    4. Document: met "Dokumen pendukung: diunggah, belum diverifikasi" when attached, else info (dashed circle, never counted) "Dokumen pendukung: wajib, belum ada · menjadi hambatan tutup buku".
  - Refusal: while n ≥ 1 unmet lines, show "Tidak dapat dilakukan: {n} syarat belum terpenuhi." (initially n = 5). The button looks disabled. Build it as TombolBersyarat: `onPressed` re-checks the latest state and does nothing while unmet, and Semantics reads the refusal.
  - "Periksa dan bukukan" (`bukukan`): if no line is unmet, `posted` = true. Nothing else is asked; posting happens in one press, with no Periksa step on this board.
  - "Simpan sebagai draf": a link to `/WebTransaksi`. There is no save state; it just leaves the page.
  - "Catat lagi" (`lagi`): resets `jm`, `pihak`, `ur`, `akun`, `ke`, `per`, `ling`, `ma`, `cari` and `dok`, and sets `posted` = false. `jenis` is kept. Clear the amount, search, Pihak and Uraian text controllers too.
  - Link-row links, the breadcrumb and the side nav: see Links out.
- **Motion**
  - On posting, the stamp "No. Bukti BKU-2026-0147" enters with `muncul` (motion.md: muncul): 400 ms, CSS `ease`, fill-mode `both`, so it is invisible until the animation starts. It fades in and rises 8 px.
  - The card border, badge and amount colour change instantly. There is no `tinta` ink sweep on this board.
  - The board also declares `isi` and `titik` but does not use them.
  - Under reduce motion the stamp appears at once.
- **Links out**
  - "Transaksi" breadcrumb → `/WebTransaksi`, up link.
  - "Simpan sebagai draf" → `/WebTransaksi`, up link: it returns to the list, and Back must not reopen the filled form.
  - Link row, each pushed:
    - "Bagi ke beberapa Mata Anggaran" → `/WebBagi`
    - "Persembahan" → `/WebPersembahan`
    - "Alih peruntukan" → `/WebAlihPeruntukan`
    - "Dari foto nota" → `/WebAIFoto`
    - "Ganti catatan persetujuan" → `/WebPersetujuan`
    - "Tanggal transaksi" → `/WebTanggal`
    - "Usulan Mata Anggaran" → `/WebAIMataAnggaran`
    - "Dari kalimat" → `/WebBantuanAI`
  - Side nav: the seven items, `go`.

  **Inbound** TabTransaksi, WebAIFoto, WebAIMataAnggaran, WebBagi, WebBantuanAI, WebDraf, WebSambungan, WebTanggal, WebTransaksi (manifest), plus PetaLayar ("Catat transaksi", JS-built, missing from the manifest).
- **Mock data**
  - Kas/Bank (`akun`/`ke` ids): kas "Kas", bni "Bank BNI ··4821", bsg "Bank SulutGo ··1107".
  - Peruntukan: Umum Jemaat, Diakonia, Pembangunan.
  - Lingkup: Jemaat, Kolom 3, BIPRA Pemuda, Panitia Natal.
  - Mata Anggaran, Belanja tree: 5.00.00.00 BELANJA OPERASIONAL (group); 5.01.02.00 Listrik, air dan telepon; 5.02.01.00 Alat tulis dan fotokopi; 5.03.03.00 Biaya administrasi bank; 4.00.00.00 BELANJA PELAYANAN (group); 4.03.03.00 Diakonia duka.
  - Mata Anggaran, Pendapatan tree: 1.3.53.00.00 PERSEMBAHAN (group); 1.3.53.07.00 Persembahan Ibadah Minggu; 1.3.53.09.00 Persembahan syukur; 1.4.10.00.00 SUMBANGAN (group); 1.4.10.02.00 Sumbangan donatur.
  - Labels per jenis:
    - Belanja: tree "Belanja", "Kas/Bank", "Diambil dari peruntukan", "Dibayar kepada", sign −1.
    - Pendapatan: tree "Pendapatan", "Kas/Bank", "Masuk ke peruntukan", "Diterima dari (boleh tanpa nama)", sign +1.
    - Pindah: "Dari Kas/Bank", sign +1.
  - Date 16 November 2026. Attached file "nota-16-11.jpg".
  - Posted: No. Bukti BKU-2026-0147, "Dibukukan pada 16/11/2026 10.42".
- **Prototype-only** None. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/WebCatat`. "Belanja" is filled `tinta`. The card shows "Draf · belum masuk saldo", "Rp0" and "Belanja". The checklist has 7 lines: 5 red squares, 1 tick ("Persetujuan: tidak diperlukan (aturan: transaksi rutin)") and 1 dashed circle. "Tidak dapat dilakukan: 5 syarat belum terpenuhi." is shown, and "Periksa dan bukukan" is `garis` with `tinta3` text.
  2. Type "001250000" in Jumlah. The field shows "1.250.000", the card shows "−Rp1.250.000", line 1 reads "Jumlah Rp1.250.000" with a tick, and the refusal says 4.
  3. Pick Kas, Diakonia, Kolom 3 and "Belanja 5.02.01.00 Alat tulis dan fotokopi". The refusal disappears and the button turns `laut`. The first click posts: the card gets a solid `tinta` border, the badge reads "Dibukukan", the stamp "No. Bukti BKU-2026-0147" rises in over 400 ms, and the aside shows "Dibukukan pada 16/11/2026 10.42 · tidak dapat diubah lagi." and "Catat lagi".
  4. After posting, clicking "Pendapatan", a chip or the attach button changes nothing.
  5. "Catat lagi" clears the form. "Belanja" stays selected and the refusal says 5 again.
  6. Type "listrik" in "Cari nomor atau nama". Only "Belanja 5.01.02.00 Listrik, air dan telepon" stays among the postable rows, and both group headings remain.
  7. Choose "Pindah antar Kas/Bank". Peruntukan, Lingkup, Mata Anggaran, Pihak and Uraian disappear, and "Dari Kas/Bank" and "Ke Kas/Bank" appear. Pick Kas in both: the line stays "Kas/Bank asal dan tujuan belum dipilih, dan harus berbeda". Pick Bank BNI ··4821 as Ke: the line and the card read "Dari Kas ke Bank BNI ··4821".
  8. Click "Lampirkan dokumen pendukung". The button becomes "nota-16-11.jpg · Terlampir" with a solid line, and the last line becomes a tick "Dokumen pendukung: diunggah, belum diverifikasi".
  9. Click "Ganti catatan persetujuan". `/WebPersetujuan` is pushed, and Back returns to `/WebCatat` with the typed amount intact.
  10. "Simpan sebagai draf" leads to `/WebTransaksi`. At 860 px wide the aside sits below the form and the nav shows "Menu".
- **Notes**
  - Off-token sizes: amount input 40, "Rp" prefix 24, card amount 32, stamp radius 8, MA rows and the "tanpa" button radius 10, buttons 46 high. Copy all of them.
  - The refusal is a count ("5 syarat"), not TombolBersyarat's first unmet reason, and it shows on an empty form. The board wins.
  - The disabled look uses `tinta3` text, where TombolBersyarat says `tinta2`. The board wins.
  - The Mata Anggaran line is counted as unmet, so Bukukan stays blocked until a row is chosen, even though the line says it can still be saved as a draft. This is consistent: only "Simpan sebagai draf" leaves without one.
  - Gerak says Bukukan uses `tinta` (700 ms ink sweep, stamp, count-up). This board only runs `muncul` on the stamp. The board wins; do not add the sweep here.
  - After posting, the board still lets you type in Pihak, Uraian and the MA search, and the summary line follows the typed Uraian even on the posted card, although the page says "tidak dapat diubah lagi". Recommended: make Pihak and Uraian read-only while posted, matching every other handler's posted guard. Flag it as a deviation.
  - No. Bukti BKU-2026-0147 is also the "Fotokopi warta jemaat" row on Bukti and WebBukti. Each screen keeps its own board's figure; list this in `mock-data.md`.
  - Plain `<a>` links (breadcrumb, link row) are underlined because the board does not remove the browser default.

### WebVerifikasi — Web · Verifikasi wewenang (halaman internal)
- **Source** `docs/design/handoff/canvas/boards/WebVerifikasi.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebVerifikasi`. No child routes: the states change in place. · **Widget** `WebVerifikasiScreen` in `lib/screens/lengkap/web_verifikasi.dart`
- **Purpose** The Palakat Petugas verifikasi, an internal Palakat team role outside the Bendahara's app, checks the BPMJ letter that appoints a Bendahara and then activates the authority, returns it to the BPMJ with a reason, or revokes it in an emergency. It shows:
  - Authority comes only from a verified church decision. This is step 1 of "3 · Pengaturan awal" seen from the other side; Awal's checklist mentions this check.
  - The states of "Wewenang Bendahara" from Cakupan row 21: Menunggu verifikasi, aktif, dicabut, and "Belum ada Bendahara aktif".
  - P07: the Bendahara Jemaat is recovered through the Petugas verifikasi with BPMJ.
  - P12: a reason must not be blank, and there is no minimum length.
  - Nothing can be recorded, posted or closed from here.
- **Shell** A variant of the web side nav, specific to this page:
  - Brand row as WebCari.
  - One item only, "Verifikasi wewenang" → `/WebVerifikasi` (active: `tinta` field, `permukaan` text).
  - Footer (13 `tinta2`): "**Petugas verifikasi**" (`tinta`), a line break, then "Tim Palakat · halaman internal".
  - There is no `jabatanKosong` banner or footer swap on this board.
  - The below-860 px "Menu" drawer behaves as WebCari's. Main column as WebCari.
- **Layout**
  1. Title block: h1 "Verifikasi wewenang" (26/700), then "Halaman internal untuk Petugas verifikasi, di luar aplikasi Bendahara. Dari sini tidak ada yang dapat dicatat, dibukukan atau ditutup." (14 `tinta2`).
  2. Two-column row: wrap, gap 28, aligned top. The left queue takes flex 1 1 320 and the right column takes 999 1 520. At 1440 the queue is about 320 wide. When main is narrower than 868 the right column drops below.
     **Left: queue card**: `permukaan`, 1 px `garis`, radius 14, clipped. Two rows, not pressable:
     - Row 1, the selected row: padding 14/18, `lautLembut` field, a 3 px inner `laut` line on the left edge (the selected web table row rule).
       - Top line (space-between, gap 16, centred): "Jemaat Karunia" (700), then the status badge (13/700, radius 6, padding 3 9, shape per state, see Internal views).
       - "Penunjukan Bendahara · Meiske Lumentut" (14).
       - "Dikirim 14/09/2026 15.20" (13 `tinta3`).
     - Row 2: padding 14/18, 1 px `garis` top rule.
       - "Jemaat Contoh Dua" (700), with the badge "Menunggu verifikasi wewenang" (1.5 dashed `putus`, `tinta2` text, transparent).
       - "Serah terima Bendahara · [NAMA]" (14).
       - "Dikirim 13/09/2026 09.05" (13 `tinta3`).
     **Right column** (column, gap 16):
     a. Facts card: `permukaan`, 1 px `garis`, radius 14, padding 4/18. Three rows (space-between, gap 16, padding 12 0, a 1 px `garis` top rule from the second row on). Each has a label (14 `tinta2`) and a value (600, right-aligned):
        - "Yang ditunjuk" · "Meiske Lumentut · meiske@contoh.id"
        - "Yang menunjuk" · "BPMJ Jemaat Karunia · Pdt. Lidya Rondonuwu, Ketua"
        - "Surat penunjukan" · "SK-BPMJ-04-2026.pdf · 2 halaman"
     b. Letter placeholder: 1.5 dashed `putus`, radius 14, min-height 120, centred, 14 `tinta2`: "[Isi surat penunjukan]".
     c. State 'antre' only:
        - "Yang diperiksa" (15/700). Below it a column of three checkbox rows, gap 4. Each row is a `<label>` wrapping the checkbox first and the text after it: gap 12, centred, min-height 44, the whole row pressable. Checkbox 22×22, no margin, no shrink (a native box with `accent-color` `laut`): `laut` when checked, with a `diLaut` tick; unchecked side `garisTegas`. Text 15:
          1. "Nama yang ditunjuk sama dengan nama di akun"
          2. "Surat ditandatangani oleh BPMJ yang berwenang"
          3. "Tanggal dan nomor surat terbaca"
        - Without the return form: a row (wrap, gap 8) with "Verifikasi dan aktifkan wewenang" and "Kembalikan dengan alasan".
          - "Verifikasi dan aktifkan wewenang": min-height 46, padding 0 20, radius 12, no border, 700. All three ticked: `laut` field, `diLaut` text. Otherwise `garis` field, `tinta3` text.
          - "Kembalikan dengan alasan": secondary, 46 high, 1.5 `tinta`, `permukaan`, 700.
        - With the return form: a card (`permukaan`, 1 px `garis`, radius 14, padding 16, column gap 10) containing:
          - Label "Alasan dikembalikan **· wajib**" (14 `tinta2`, the "· wajib" part strong `tinta`), tied to the textarea.
          - Textarea (IsianAlasan): 2 rows, padding 12/14, radius 12, 1 px `garisTegas`, `permukaan`, no resize, inherits 15 px.
          - Buttons (wrap, gap 8): "Kembalikan ke BPMJ" (46 high, radius 12, 700; with a non-blank reason it is a `tinta` field with `permukaan` text, otherwise `garis` with `tinta3`), then "Kembali" (secondary).
          - While the form is open, the two buttons above are hidden and the checkboxes stay.
     d. State 'aktif' only:
        - Result card: `permukaan`, 1.5 solid `tinta` (terpilih), radius 14, padding 16. "Wewenang Bendahara aktif" (17/700), then "Meiske Lumentut · Jemaat Karunia · diverifikasi oleh Petugas verifikasi, 15/09/2026 10.15 · tercatat di Riwayat aktivitas Jemaat." (14 `tinta2`).
        - Emergency section: column, gap 8, 1 px `garis` top rule, padding-top 14.
          - "Keadaan darurat" (15/700).
          - "Mencabut wewenang berlaku saat itu juga, mengakhiri semua sesi, dan dapat membuat Jemaat tanpa Bendahara aktif sampai BPMJ menunjuk yang baru." (14 `tinta2`).
          - Label "Alasan pencabutan **· wajib**", then a textarea styled as c.
          - Button "Cabut wewenang": 46 high, aligned left. With a non-blank reason it is a `tinta` field with `permukaan` text, otherwise `garis` with `tinta3`.
     e. State 'kembali' only: a card (`permukaan`, 1.5 `tinta`, radius 14, padding 16) with:
        - "Dikembalikan ke BPMJ" (17/700).
        - "Alasan: {reason}" (14 `tinta2`).
        - "Meiske Lumentut tetap masuk tanpa wewenang keuangan dan melihat “Menunggu verifikasi wewenang” beserta alasannya." (13 `tinta3`).
     f. State 'dicabut' only: a card (`tinta` field, `permukaan` text, radius 14, padding 16, the ditutup line) with:
        - "Wewenang dicabut · Belum ada Bendahara aktif di Jemaat Karunia" (17/700).
        - "Semua sesi Meiske Lumentut diakhiri. Data Jemaat hanya dapat dilihat. Alasan: {reason}" (14 `diTinta`).
        - The 'aktif' card and the emergency section are gone in this state.
- **Components**
  - Status badges in LencanaStatus shapes. They are "Wewenang" states, not finance statuses; a LencanaModul post badge would also fit.
  - IsianAlasan: both reason fields.
  - Tombol: primary `laut`; the permanent-style `tinta` field for "Kembalikan ke BPMJ" and "Cabut wewenang"; secondary "Kembalikan dengan alasan" and "Kembali".
  - TombolBersyarat-style disabled looks.
  - PitaPeran-like locking card for 'dicabut' (`tinta` field, "Belum ada Bendahara aktif").
  - Patterns: the selected queue row (3 px `laut` inner left line) and the label–value facts card.
  - A side-nav variant with a single item.
- **Internal views and states** Initial state `{ st: 'antre', cek: [false, false, false], form: false, alasan: '', alasanAkhir: '' }`. Views by `st` and `form`:
  - 'antre' without the form: the default.
  - 'antre' with the form: "Kembalikan dengan alasan" opens it.
  - 'aktif': the result card and the emergency section.
  - 'kembali': terminal.
  - 'dicabut': terminal.

  Badge of row 1 per state:
  - antre: "Menunggu verifikasi wewenang" (transparent, `tinta2` text, 1.5 dashed `putus`).
  - aktif: "Wewenang Bendahara aktif" (`laut` field, `diLaut` text, 1.5 `laut`).
  - kembali: "Dikembalikan" (`permukaan` field, `tinta2` text, 1.5 solid `tinta3`).
  - dicabut: "Wewenang dicabut" (`tinta` field, `permukaan` text, 1.5 `tinta`).

  The board has no reset from the terminal states; reopening the route starts again at 'antre'.
- **Tweaks** none. The Keadaan panel shows only the global switches; `jabatanKosong` has no effect here.
- **Interactions**
  - Checkbox row `i` (`cek[i].pick`, the label is part of the target): toggles `cek[i]`.
  - "Verifikasi dan aktifkan wewenang" (`aktifkan`): only when all three are ticked; then `st` = 'aktif' and `alasan` = ''. It is a TombolBersyarat with the condition "all three ticked". `onPressed` re-checks and does nothing otherwise.
  - "Kembalikan dengan alasan" (`bukaForm`): `form` = true and `alasan` = ''.
  - Reason textarea (`onAlasan`, every keystroke): `alasan` = text. The return form and the emergency section share this one value; each is cleared when it opens.
  - "Kembalikan ke BPMJ" (`kembalikan`): only when `alasan.trim()` is not empty; then `st` = 'kembali', `alasanAkhir` = the trimmed reason, `form` = false.
  - "Kembali" (`batalForm`): `form` = false. The typed reason is kept in state but cleared the next time the form opens.
  - "Cabut wewenang" (`cabut`): only when `alasan.trim()` is not empty; then `st` = 'dicabut' and `alasanAkhir` = the trimmed reason.
  - Whitespace-only reasons are refused, and any non-blank reason is accepted (P12). The first press after typing works, because the state is updated on each keystroke.
  - Side-nav item "Verifikasi wewenang" → `/WebVerifikasi` (`go` to the current route; nothing happens and the state is kept).
- **Motion**
  - The return form, the 'aktif' result card, the 'kembali' card and the 'dicabut' card each enter with `muncul` 300 ms (CSS `ease`) when they appear.
  - The emergency section and the badge change instantly.
  - The board also declares `isi` and `titik` but does not use them.
  - Under reduce motion, everything appears at once.
- **Links out** The side-nav item "Verifikasi wewenang" → `/WebVerifikasi` (`Tautan(ke: 'WebVerifikasi')`, the manifest's only jsLink). **Inbound** none in the manifest. In practice the launcher, PetaLayar ("Petugas verifikasi" under Web · Peran lain) and Cakupan ("Petugas verifikasi" in the row "Wewenang Bendahara") lead here. Those JS-built links are missing from the manifest.
- **Mock data**
  - Jemaat Karunia: "Penunjukan Bendahara · Meiske Lumentut", sent 14/09/2026 15.20.
  - Jemaat Contoh Dua: "Serah terima Bendahara · [NAMA]", sent 13/09/2026 09.05.
  - Yang ditunjuk: Meiske Lumentut · meiske@contoh.id.
  - Yang menunjuk: BPMJ Jemaat Karunia · Pdt. Lidya Rondonuwu, Ketua.
  - Letter: SK-BPMJ-04-2026.pdf · 2 halaman.
  - Verified 15/09/2026 10.15. This matches "Aktif sejak 15/09/2026 · SK-BPMJ-04-2026" on Bendahara and WebPengaturan.
- **Prototype-only** None of the four listed devices. "[NAMA]" and "[Isi surat penunjukan]" are placeholders drawn on the board; copy them verbatim. Keadaan panel: global switches only.
- **Acceptance checks**
  1. Open `/WebVerifikasi`. The nav has one active item "Verifikasi wewenang" and the footer reads "Petugas verifikasi" (strong, `tinta`) with "Tim Palakat · halaman internal" on the next line. There is no `jabatanKosong` banner. Row 1 has the `lautLembut` field with a 3 px `laut` left line and the dashed badge "Menunggu verifikasi wewenang".
  2. "Verifikasi dan aktifkan wewenang" is `garis` with `tinta3` text. Clicking it does nothing.
  3. Tick the three boxes by clicking their text. The button turns `laut`. Click it: the row 1 badge becomes the `laut` field "Wewenang Bendahara aktif", the card "Wewenang Bendahara aktif" rises in, and "Keadaan darurat" shows with a disabled "Cabut wewenang".
  4. Type three spaces in "Alasan pencabutan": still disabled. Type "Surat ternyata palsu": the button becomes a `tinta` field. Click it: the `tinta` card "Wewenang dicabut · Belum ada Bendahara aktif di Jemaat Karunia" ends with "Alasan: Surat ternyata palsu", and the badge reads "Wewenang dicabut".
  5. On a fresh open, click "Kembalikan dengan alasan". The form rises in and the two action buttons disappear. Click "Kembali": the buttons return.
  6. Open the form again, type a reason and click "Kembalikan ke BPMJ". The card "Dikembalikan ke BPMJ" shows "Alasan: …", and the badge "Dikembalikan" has a solid `tinta3` line.
  7. At 860 px the nav becomes a top bar with "Menu", and the right column drops below the queue.
- **Notes**
  - The disabled buttons have no reason sentence next to them. CONVENTIONS asks for one, but the board wins on what is shown. Give each disabled button a Semantics hint with its unmet condition ("Ketiga pemeriksaan belum dicentang", "Alasan belum diisi") and flag it for the design owner.
  - Off-token: 17 px card titles, 46 px buttons, side-nav radius 10. Copy them.
  - "[NAMA]" is a design placeholder for an unnamed person. It is not prototype chrome, so keep it.
  - The manifest lists no inbound links. Make sure the launcher lists this board under "Peran lain" / Petugas verifikasi.

### PetaLayar — Peta layar
- **Source** `docs/design/handoff/canvas/boards/PetaLayar.dc.html` · page Peta dan keputusan (`sistem`) · form Sheet 1760×1860 (fixed size, scrolls both ways) · interactive yes (links only)
- **Route** `/PetaLayar`, no child routes · **Widget** `PetaLayarScreen` in `lib/screens/sistem/peta_layar.dart`
- **Purpose** For reviewers and builders (03-screens-and-flows: "Start on the page 'Peta dan keputusan'"). A map of where every finance screen sits in navigation, phone and web, with its tier (T1 first path, T2, T3, Sementara). Every name opens its board. It shows D29 (phone: five bottom tabs with Catat in the centre; web: a side bar with seven destinations), and Keputusan links D29 here.
- **Shell** none. A fixed 1760×1860 sheet: `kertas` field, padding 56, column gap 32, sans 15/1.45 `tinta`. Centre it, and let it scroll both ways in smaller windows. Show it at 100 % and do not scale it.
- **Layout**
  1. Header row: space-between, aligned to the bottom, gap 40.
     - Left:
       - "Peta layar": 36/700, line-height 1.1, letter-spacing −0.5. Off-token.
       - Below it (margin-top 4, 15 `tinta2`): "Di mana tiap layar berada dalam navigasi. Saat diputar, tiap nama membuka artboard-nya."
     - Right, a legend (wrap, gap 8). Three badges, each 13/700, radius 6, padding 3 9:
       - "T1 jalur pertama": `tinta` field, `permukaan` text.
       - "T2 dan T3": 1.5 solid `tinta` line, `tinta` text.
       - "Sementara": 1.5 dashed `putus`, `tinta2` text.
  2. Two platform sections, each a column with gap 14:
     - Title row (baseline, gap 12): h2 at 22/700 (`judulBesar`), then a caption at 14 `tinta2`.
       - Section "Ponsel": caption "Tab bawah: Beranda · Transaksi · Catat · Bulan · Lainnya". Grid of 6 equal columns.
       - Section "Web": caption "Bilah samping". Grid of 8 equal columns.
     - Grid gap 16, cards aligned to the top (not stretched).
     - Group card: `permukaan`, 1 px `garis`, radius 14, padding 12/14, column gap 2.
       - Title: 15/700, padding-bottom 6, a 1.5 solid `tinta` bottom rule, margin-bottom 4.
       - Screen rows (links): space-between, centred, gap 6, min-height 30, 13/600 `tinta`, no underline. The name is on the left. The tier tag is on the right: 13/700, radius 5, padding 1 6, no shrink.
         - T1: `tinta` field, `permukaan` text, 1.5 `tinta` border.
         - T2 and T3: transparent, `tinta` text, 1.5 solid `tinta`.
         - Sem.: transparent, `tinta2` text, 1.5 dashed `putus`.
  3. Footer paragraph (14 `tinta2`): "Ponsel memakai lima tab bawah dengan tombol Catat di tengah. Web memakai bilah samping dengan tujuh tujuan; Rekonsiliasi dan Laporan berdiri sendiri di web karena dikerjakan di layar lebar. “Peran lain” adalah tampilan untuk orang selain Bendahara."
- **Components** None from the design system. The legend and tags reuse the line language: ditutup field, terpilih line, draf line. Repeated pattern: a group card with a ruled title and link rows with tags.
- **Internal views and states** none (static, no state).
- **Tweaks** none. The Keadaan panel shows only the global switches.
- **Interactions** Only links: each screen row pushes its board. No handlers. Keep the sheet's scroll position when coming back; a push keeps the sheet alive below, so this needs nothing extra.
- **Motion** none. The board declares `masuk`, `pudar`, `muncul` and `isi` but uses none of them.
- **Links out** 101 links (100 distinct boards; `/Main` appears twice), each a `push` via `Tautan(ke: '<Stem>')`. The format is: "label" `tag` → route.
  - **Ponsel**
    - **Beranda** (7): "Beranda dan catat" `T1` → `/Main`; "Cari dan tanya" `T3` → `/Cari`; "Pemberitahuan" `Sem.` → `/Pemberitahuan`; "Masuk" `T1` → `/Masuk`; "Pemulihan akun" `T1` → `/Pemulihan`; "Sambungan dan sesi" `T1` → `/Sambungan`; "Memuat dan gagal" `T1` → `/Memuat`
    - **Transaksi** (17): "Daftar dan rincian" `T1` → `/Main`; "Pemilih bulan" `T1` → `/PilihBulan`; "Ganti persetujuan" `T1` → `/Persetujuan`; "Alih peruntukan" `T1` → `/AlihPeruntukan`; "AI dari foto nota" `T3` → `/AIFoto`; "Pindah tanggal, batalkan" `T1` → `/Draf`; "Koreksi dan persetujuan" `T1` → `/Koreksi`; "Dokumen pendukung" `T1` → `/Dokumen`; "Bagi Mata Anggaran" `T1` → `/Bagi`; "Persembahan" `T2` → `/Persembahan`; "Pemeriksa kedua" `T1` → `/Pemeriksa`; "Pengembalian" `Sem.` → `/Pengembalian`; "Bantuan AI" `T3` → `/BantuanAI`; "Foto dokumen" `T1` → `/Kamera`; "Tanggal transaksi" `T1` → `/Tanggal`; "AI: Mata Anggaran" `T3` → `/AIMataAnggaran`; "Lihat file" `T1` → `/LihatDokumen`
    - **Bulan** (8): "Rekonsiliasi dan tutup buku" `T1` → `/TutupBuku`; "Hitung kas" `T1` → `/HitungKas`; "Pernyataan kesiapan" `T2` → `/Kesiapan`; "Kejadian" `T1` → `/Kejadian`; "Laporan" `T1` → `/Laporan`; "Isi rekening koran" `T1` → `/RekonIsi`; "AI akhir bulan" `T3` → `/AIBulan`; "Lihat transaksi" `T2` → `/LihatTransaksi`
    - **Lainnya** (11): "Pengaturan" `T1` → `/Lainnya`; "Tambah dan ubah" `T1` → `/UbahPengaturan`; "Mata Anggaran" `T1` → `/MataAnggaran`; "Bendahara dan sesi" `T1` → `/Bendahara`; "Format laporan" `T1` → `/FormatLaporan`; "Uang Muka dan Titipan" `T2` → `/Kewajiban`; "Kasus baru" `T2` → `/KasusBaru`; "Daftar Bukti Kas" `T2` → `/Bukti`; "Impor" `T2` → `/Impor`; "Ekspor" `T3` → `/Ekspor`; "Akun dan keluar" `T1` → `/Keluar`
    - **Pertama kali** (2): "Langkah dan saldo awal" `T1` → `/Awal`; "Identitas dan daftar" `T1` → `/AwalIsian`
    - **Peran lain** (1): "Akses terbatas" `T2` → `/Terbatas`
  - **Web**
    - **Beranda** (8): "Beranda" `T1` → `/WebBeranda`; "Cari dan tanya" `T3` → `/WebCari`; "Pemberitahuan" `Sem.` → `/WebPemberitahuan`; "Masuk" `T1` → `/WebMasuk`; "Pemulihan akun" `T1` → `/WebPemulihan`; "Sambungan dan sesi" `T1` → `/WebSambungan`; "Memuat dan gagal" `T1` → `/WebMemuat`; "Lebar tablet" `T1` → `/TabBeranda`
    - **Transaksi** (19): "Daftar dan rincian" `T1` → `/WebTransaksi`; "Pemilih bulan" `T1` → `/WebPilihBulan`; "Bagi Mata Anggaran" `T1` → `/WebBagi`; "Ganti persetujuan" `T1` → `/WebPersetujuan`; "Alih peruntukan" `T1` → `/WebAlihPeruntukan`; "AI dari foto nota" `T3` → `/WebAIFoto`; "Catat transaksi" `T1` → `/WebCatat`; "Pindah tanggal, batalkan" `T1` → `/WebDraf`; "Koreksi dan persetujuan" `T1` → `/WebKoreksi`; "Dokumen pendukung" `T1` → `/WebDokumen`; "Persembahan" `T2` → `/WebPersembahan`; "Pemeriksa kedua" `T1` → `/WebPemeriksa`; "Impor" `T2` → `/WebImpor`; "Pengembalian" `Sem.` → `/WebPengembalian`; "Lihat file" `T1` → `/WebLihatDokumen`; "Unggah dokumen" `T1` → `/WebUnggah`; "Tanggal transaksi" `T1` → `/WebTanggal`; "AI dari kalimat" `T3` → `/WebBantuanAI`; "AI: Mata Anggaran" `T3` → `/WebAIMataAnggaran`
    - **Uang Muka dan Titipan** (3): "Kasus dan sisa" `T2` → `/WebKewajiban`; "Catat pada kasus" `T2` → `/WebKasus`; "Kasus baru" `T2` → `/WebKasusBaru`
    - **Rekonsiliasi** (3): "Rekening koran" `T1` → `/WebRekonsiliasi`; "Hitung kas" `T1` → `/WebHitungKas`; "Isi rekening koran" `T1` → `/WebRekonIsi`
    - **Bulan dan tutup buku** (4): "Tutup buku" `T1` → `/WebTutupBuku`; "Pernyataan kesiapan" `T2` → `/WebKesiapan`; "Kejadian" `T1` → `/WebKejadian`; "Bantuan AI akhir bulan" `T3` → `/WebAI`
    - **Laporan** (7): "F01" `T1` → `/WebLaporan`; "F01 sampai F14" `T2` → `/WebPaketLaporan`; "Contoh Excel" `T2` → `/WebExcel`; "Daftar Bukti Kas" `T2` → `/WebBukti`; "Format laporan" `T1` → `/WebFormatLaporan`; "Halaman A4" `T1` → `/A4F01`; "Lihat transaksi" `T2` → `/WebLihatTransaksi`
    - **Pengaturan** (8): "Pengaturan" `T1` → `/WebPengaturan`; "Tambah dan ubah" `T1` → `/WebUbahPengaturan`; "Serah terima" `T1` → `/WebSerahTerima`; "Saldo awal" `T1` → `/WebAwal`; "Identitas dan daftar" `T1` → `/WebAwalIsian`; "Mata Anggaran" `T1` → `/WebMataAnggaran`; "Ekspor" `T3` → `/WebEkspor`; "Akun dan keluar" `T1` → `/WebKeluar`
    - **Peran lain** (3): "Akses terbatas" `T2` → `/WebTerbatas`; "Excel TERBATAS" `T2` → `/WebExcelTerbatas`; "Petugas verifikasi" `T1` → `/WebVerifikasi`

  **Inbound** Keputusan.
- **Mock data** The tables above are the data. Copy the board's `P` and `W` arrays into `lib/mock/` as `(stem, label, tier)` triples, grouped. Tier codes: 1 → "T1", 2 → "T2", 3 → "T3", 0 → "Sem.".
- **Prototype-only** none. The whole sheet is design documentation; render it as drawn.
- **Acceptance checks**
  1. Open `/PetaLayar` in a 1280×800 window. A 1760×1860 `kertas` sheet scrolls horizontally and vertically, and the header reads "Peta layar" with the three legend badges.
  2. The Ponsel grid shows 6 cards in one row and the Web grid 8 cards in one row. The cards are top-aligned with uneven heights.
  3. "Pemberitahuan" carries the dashed "Sem." tag, "Persembahan" (Ponsel · Transaksi) a solid-line "T2" tag, and "Masuk" the filled "T1" tag.
  4. Click "Ganti persetujuan" (Ponsel · Transaksi). `/Persetujuan` opens in the phone frame. Back returns to the sheet at the same scroll offset.
  5. Click "Petugas verifikasi" (Web · Peran lain). `/WebVerifikasi` opens.
  6. A source test finds 101 `Tautan(ke: …)` entries on this screen (or one data-driven `Tautan` per row over the 101-row list), and every target is a registered route.
- **Notes**
  - The manifest's `jsLinks` is empty for this board because the links are built by string concatenation (`l[0] + '.dc.html'`). The link-coverage test will not see them, and the targets' `inbound` lists miss PetaLayar. Recommended: add these links to the manifest generator, or give this board its own coverage test over the mock list.
  - Rows are 30 px high, below the 44 px minimum. This is a fixed-size canvas map, not an app screen, and 44 px rows would push the sheet past its 1860 px height. Keep 30 px. If `Tautan` always forces 44×44, give it an opt-out used only on PetaLayar and Cakupan, and list the breach.
  - Off-token: title 36 px, tag radius 5. Copy them.
  - C06 says Pemberitahuan is final and no longer labelled provisional, and RD04/D05 settled Pengembalian, yet the board still tags Pemberitahuan and Pengembalian "Sem." (Sementara). (C05 is about glossary terms marked "usulan", not about these tags.) Keep the board copy and flag it.
  - Inline link colour `tinta` overrides the global `a:hover` colour, so there is no hover colour change.

### Cakupan — Cakupan keadaan
- **Source** `docs/design/handoff/canvas/boards/Cakupan.dc.html` · page Peta dan keputusan (`sistem`) · form Sheet 1400×1660 (fixed size, scrolls both ways) · interactive yes (links only)
- **Route** `/Cakupan`, no child routes · **Widget** `CakupanScreen` in `lib/screens/sistem/cakupan.dart`
- **Purpose** For reviewers and builders: every state from the brief, per finance object, with links to the boards where it is drawn, and a column for states not yet drawn live. In every row that column is "Tidak ada". 03-screens-and-flows names it among the sheets to read first.
- **Shell** none. A fixed 1400×1660 sheet: `kertas`, padding 56, column gap 32, sans 15/1.45 `tinta`. Centred, scrolls both ways, not scaled.
- **Layout**
  1. Title block:
     - "Cakupan keadaan": 36/700, line-height 1.1, letter-spacing −0.5.
     - Below it (margin-top 4, 15 `tinta2`): "Tiap keadaan dari brief dan layar tempat ia digambar. Yang belum digambar hidup ditandai apa adanya."
  2. Table card: `permukaan`, 1 px `garis`, radius 14, padding 0 18.
     - Grid columns 190 · 1.5fr · 1fr · 1fr, gap 16.
     - Header row: padding 12 0, 13/700 `tinta2`: "Objek", "Keadaan yang digambar", "Layar", "Belum digambar hidup".
     - 21 body rows: padding 10 0, a 1 px `garis` top rule, 13 px, aligned to the top.
       - Objek: 14/700.
       - Keadaan: 13 `tinta`.
       - Layar: links that flow inline, each with margin 0 10 2 0, 13/600 `laut`, underlined (browser default), `lautTua` on hover.
       - Last column: "Tidak ada" in 13/400 `tinta3`.
- **Components** none. Pattern: a 4-column data table, the same table language as the web tables (header 13/700 `tinta2`, `garis` rules).
- **Internal views and states** none (static).
- **Tweaks** none. The Keadaan panel shows only the global switches.
- **Interactions** Links only; each pushes its board. Keep the scroll position on return, as PetaLayar does.
- **Motion** none. The board declares `masuk`, `pudar`, `muncul` and `isi` but uses none of them.
- **Links out** 57 links over 43 distinct boards, all `push`. Rows, in the form: Objek · Keadaan · Layar links:
  1. **Transaksi** · "Draf · Sudah diperiksa · Dibukukan · Dibalik · Dibatalkan" · "Harian" → `/Main`, "Pemeriksa kedua" → `/Pemeriksa`, "Koreksi" → `/Koreksi`, "Draf" → `/Draf`
  2. **Mata Anggaran pada transaksi** · "Belum dipilih · sudah dipilih · dibagi ke beberapa baris" · "Harian" → `/Main`, "Bagi" → `/Bagi`
  3. **Persetujuan** · "Tidak diperlukan (dengan aturannya) · belum dicatat · sudah dicatat" · "Harian" → `/Main`, "Koreksi" → `/Koreksi`, "Ganti catatan" → `/Persetujuan`
  4. **Dokumen pendukung** · "Tidak diperlukan · Wajib, belum ada · Diunggah, belum diverifikasi · Terverifikasi · Dikecualikan · Status saat tutup buku" · "Dokumen pendukung" → `/Dokumen`
  5. **File dokumen** · "Sedang diunggah · Gagal diunggah · Terlampir · Dilepas · Ditahan · Ditolak" · "Harian" → `/Main`, "Dokumen pendukung" → `/Dokumen`, "Kamera" → `/Kamera`, "Lihat file" → `/LihatDokumen`, "Unggah di web" → `/WebUnggah`
  6. **Bulan** · "Belum ditutup · Sedang menutup buku · Sudah ditutup · tutup buku tidak terjadi" · "Tutup buku" → `/TutupBuku`, "Web" → `/WebTutupBuku`
  7. **Syarat tutup buku** · "Hambatan dengan tautan perbaikan · Untuk diketahui" · "Tutup buku" → `/TutupBuku`, "Kejadian" → `/Kejadian`
  8. **Pernyataan kesiapan** · "Sudah dinyatakan · Perlu dinyatakan lagi · belum ada · Dibebaskan" · "Pernyataan kesiapan" → `/Kesiapan`
  9. **Rekonsiliasi** · "Rekening koran belum diisi · Sedang dikerjakan · Sudah diperiksa · Sudah dipastikan · Perlu dipastikan lagi" · "Tutup buku" → `/TutupBuku`, "Web" → `/WebRekonsiliasi`, "Isi rekening koran" → `/RekonIsi`
  10. **Mutasi bank** · "Belum cocok · Sebagian cocok dengan sisanya · Cocok · satu ke banyak" · "Web" → `/WebRekonsiliasi`, "Isi rekening koran" → `/RekonIsi`
  11. **Hitung kas** · "Belum dihitung · Dihitung: Rp0 · hasil hitung" · "Hitung kas" → `/HitungKas`, "Web" → `/WebHitungKas`
  12. **Uang muka dan titipan** · "Belum · Sebagian · Sudah · Lewat jatuh tempo · lebih dari uang muka" · "Ponsel" → `/Kewajiban`, "Web" → `/WebKewajiban`, "Kasus baru" → `/KasusBaru`
  13. **Impor** · "Ditampung · Lolos pengecekan · Sudah diperiksa · Sudah diimpor · Tidak diimpor" · "Ponsel" → `/Impor`, "Web" → `/WebImpor`
  14. **Versi Mata Anggaran** · "Draf · Sudah diperiksa · Diterbitkan" · "Ponsel" → `/MataAnggaran`, "Web" → `/WebMataAnggaran`
  15. **Laporan** · "Laporan sementara · Laporan resmi · Sedang disiapkan · Siap diunduh · File gagal dibuat" · "F01" → `/WebLaporan`, "Tutup buku" → `/TutupBuku`, "Excel" → `/WebExcel`, "Halaman A4" → `/A4F01`, "Lihat transaksi" → `/LihatTransaksi`
  16. **Simpan** · "Belum tersimpan · Tersimpan · Mencoba menyimpan lagi · Gagal disimpan · sudah diubah sejak dibuka" · "Harian" → `/Main`, "Draf" → `/Draf`, "Sambungan" → `/Sambungan`
  17. **Sambungan dan sesi** · "Tidak ada sambungan · tersambung lagi · sesi berakhir (lama tidak dipakai, diakhiri dari perangkat lain, wewenang berpindah)" · "Ponsel" → `/Sambungan`, "Web" → `/WebSambungan`, "Akhiri sesi" → `/Bendahara`
  18. **Memuat** · "Sedang memuat · gagal memuat · Bukukan tidak terjadi · dimuat" · "Ponsel" → `/Memuat`, "Web" → `/WebMemuat`
  19. **Tanggal** · "Tanggal transaksi · tanggal dokumen · dicatat pada · dibukukan pada · bulan sudah ditutup · setelah hari ini" · "Ponsel" → `/Tanggal`, "Web" → `/WebTanggal`
  20. **Usulan AI** · "Belum dipakai · dipakai · diabaikan · kurang yakin · usulan lama (draf berubah) · AI tidak tersedia" · "Dari kalimat" → `/BantuanAI`, "Dari foto" → `/AIFoto`, "Mata Anggaran" → `/AIMataAnggaran`, "Akhir bulan" → `/AIBulan`
  21. **Wewenang Bendahara** · "Menunggu verifikasi · aktif · dicabut · belum ada Bendahara aktif" · "Pengaturan awal" → `/Awal`, "Bendahara" → `/Bendahara`, "Petugas verifikasi" → `/WebVerifikasi`, "Masuk, termasuk administrator sistem" → `/Masuk`

  The last column reads "Tidak ada" on all 21 rows. **Inbound** none in the manifest; the launcher reaches it.
- **Mock data** The rows above are the data. Copy the board's `R` array into `lib/mock/` as (objek, keadaan, [(stem, label)], belum). Every `belum` is '' and renders as "Tidak ada".
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/Cakupan`. A 1400×1660 sheet shows the title "Cakupan keadaan" and a table with header "Objek · Keadaan yang digambar · Layar · Belum digambar hidup" and 21 rows.
  2. Row 1 "Transaksi" lists the links "Harian", "Pemeriksa kedua", "Koreksi", "Draf", underlined in `laut`.
  3. Every cell of the last column reads "Tidak ada" in `tinta3`, weight 400.
  4. Click "Ganti catatan" in the row "Persetujuan". `/Persetujuan` opens. Back returns to `/Cakupan`.
  5. Click "Excel" in the row "Laporan". `/WebExcel` opens.
  6. All 57 link targets are registered routes.
- **Notes**
  - Like PetaLayar, the manifest has no `jsLinks` for this board: the 57 links are concatenated in JS. Apply the same recommendation.
  - The board has a branch that shows the last column in `bata` 600 when a state is not drawn. It is unused because every row is empty. Implement only the "Tidak ada" look, or keep the branch for data parity.
  - Inline 13 px links are below 44 px. Keep the drawn size on this sheet, as for PetaLayar.
  - Off-token title size 36. Copy it.

### WebExcel — Web · Contoh file Excel
- **Source** `docs/design/handoff/canvas/boards/WebExcel.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebExcel`. No child routes: the sheet tabs switch in place. · **Widget** `WebExcelScreen` in `lib/screens/lanjut/web_excel.dart`
- **Purpose** Bendahara Jemaat, journey step 5 ("15 · Laporan"). It shows what the downloaded Excel file of the October 2026 official report pack looks like: one sheet per form F01–F14, the same content as the PDF pages, and numbers stored as numbers. It shows:
  - C01: the Excel keeps Kas/Bank as its own column (F02 column E).
  - D12: a reversal prints as a negative in the same column (BKU-2026-0109 in Pengeluaran).
  - D13 and R03: advance settlements are not in F02, and the October figure is Rp0.
  - C04: the F01 line names, F13 "Sentralisasi / Penyaluran", F14 "Lampiran Laporan Bulanan", and an empty attachment printed as "Nihil".
  - The three file rules written under the sheet.
- **Shell** Web side nav as WebCari, active item **Laporan**, with the `jabatanKosong` banner and footer.
- **Layout**
  1. Title block:
     - Breadcrumb "Laporan": 14/600 `laut`, underlined.
     - h1 "Contoh file Excel": 26/700, margin-top 2.
     - Under it, 14 `tinta2`: "Isi tiap lembar sama dengan halaman PDF-nya. Angka disimpan sebagai angka, bukan teks."
  2. Workbook frame: `permukaan`, 1 px `garisTegas`, radius 10, clipped, column. Inside, top to bottom:
     a. File bar: padding 10/14, 1 px `garis` bottom rule, wrap, baseline, gap 6/16.
        - File name "Paket-Laporan-GMIM_Jemaat-Karunia_2026-10.xlsx": mono 14/600.
        - Caption "Laporan resmi · ID SNP-2026-10-01 · satu lembar per laporan": 13 `tinta3`.
     b. Grid area: scrolls horizontally on its own. The inner block has a minimum width (per sheet, see below) and uses mono 13 by default. Build each row as a fixed-column `Row` that uses the column template, with the `fr` column taking the remaining width.
        - Column template: a 44 px row-number column, then the sheet's own columns. Every px width in the source template gets +28. The single `minmax(0, 1fr)` column flexes.
        - Minimum width: 44 + Σ(px + 28), + 300 when the template has an `fr` column.
        - Templates per sheet:
          | Sheet | Columns after the 44 px row-number column | Min width |
          | --- | --- | --- |
          | F01 | 1fr · 198 | 542 |
          | F02 | 112 · 146 · 178 · 1fr · 178 · 140 · 140 · 158 | 1396 |
          | F03 | 112 · 146 · 1fr · 140 · 140 · 148 | 1030 |
          | F04, F06 | 178 · 1fr · 278 · 158 | 958 |
          | F05, F07 | 178 · 1fr · 198 | 720 |
          | F08 | 1fr · 140 · 140 · 168 · 140 · 152 | 1084 |
          | F09 | 1fr · 140 · 152 · 152 · 140 · 152 | 1080 |
          | F10 | 1fr · 168 · 168 · 188 · 198 | 1066 |
          | F11 | 1fr · 168 · 178 · 188 | 878 |
          | F12 | 132 · 106 · 1fr · 132 · 178 · 188 | 1080 |
          | F13 | 1fr · 158 · 158 · 158 · 198 | 1016 |
          | F14 | 68 · 1fr · 288 | 700 |
        - Column-letter row: `kertas` field, 1 px `garisTegas` bottom rule. Cells: padding 4/8, centred, mono 13 (inherited from the grid block), `tinta2`, 400, 1 px `garis` right rule. Contents: an empty corner cell, then "A", "B", … one letter per column (F02: A–H).
        - Sheet rows: 1 px `garis` bottom rule. The row field is `permukaan`, except row 6, which is `kertas`. The weight is per row (700 or 400) and applies to every cell, including the row number.
        - Row-number cell: the row number in mono, centred, `tinta2`, `kertas` field, no wrap, clipped.
        - Other cells: padding 6/8, 1 px `garis` right rule, `tinta` text, transparent. The rules for each cell:
          - Money: a value starting with "Rp" or "−Rp" is a money cell. Show it without "Rp", with "−Rp" turned into an ASCII "-" ("Rp4.150.000" → "4.150.000", "−Rp750.000" → "-750.000"). Font mono, right-aligned.
          - Codes: a value matching `^(BKU|OPN|ADJ)-` or `^\d\.\d` is in mono. This covers No. Bukti and Mata Anggaran numbers, including lists such as "1.3.53.07.00; 1.3.55.01.00".
          - Everything else is sans 13. Dates, headers, names, "1"–"8" on F14 and "13 / 0" all fall here.
          - Alignment: right for money cells, and right for any data-row cell in a column the sheet marks `kanan` (e.g. F11 "13 / 0", "Sudah dipastikan"). Everything else, including the row-6 headers, is left-aligned.
          - Wrap: rows 1–4 do not wrap and their text spills visibly across the empty cells to the right, as Excel does; draw the text over the cells and do not clip it to column A. All other rows wrap inside their cell and clip.
        - Fixed rows on every sheet:
          - Row 1: the form name in upper case, 700 (e.g. "BUKU KAS UMUM", "POSISI KAS & BANK", "SENTRALISASI / PENYALURAN").
          - Row 2: "Jemaat Karunia".
          - Row 3: "Periode laporan: 01/10/2026 s.d. 31/10/2026".
          - Row 4: "Laporan resmi · SNP-2026-10-01 · Versi Mata Anggaran 2026.1".
          - Row 5: empty.
          - Row 6: the column headers, 700, on `kertas`.
          - Rows 7 onward: the data rows. A row whose source entry ends with the marker `1` is a total or heading row, drawn at 700.
     c. Sheet tab strip: horizontal scroll, `kertas` field, 1 px `garisTegas` top rule. Fourteen buttons "F01" … "F14": no shrink, min-height 44, padding 0 16, 1 px `garis` right rule only, mono 13, `tinta`. Selected: `permukaan` field, 700, with a 3 px inner `laut` line on the bottom edge (the selected-tab rule). Others: transparent, 500. Semantics: selected state.
  3. Notes grid: auto-fit columns, each at least min(280, 100%), gap 12/28, 14 `tinta2`. Three paragraphs, each starting with a bold `tinta` part:
     - "**Baris 1 sampai 4** selalu memuat judul, Jemaat, Periode laporan dan ID laporan resmi, supaya lembar yang dicetak sendiri tetap dapat dikenali."
     - "**Angka negatif** memakai tanda minus dan tidak dipotong ke nol. **Nol** ditulis 0. **Yang tidak ada** dibiarkan kosong, bukan 0."
     - "**Nomor Mata Anggaran dan No. Bukti** disimpan sebagai teks, persis seperti tersimpan, supaya Excel tidak mengubahnya menjadi tanggal atau angka."
- **Components** PitaJabatanKosong (web) and the shared side nav. The tab strip follows the "selected tab: 3 px `laut` line on the bottom edge" rule. Pattern, not a component: the spreadsheet grid. Build it once in this screen file; no other board uses it except WebExcelTerbatas, which may reuse it.
- **Internal views and states** Initial state `{ pilih: 'F02' }`. Fourteen views, one per sheet. No sheets, toasts or empty states.
- **Tweaks** `jabatanKosong` (boolean, default false), in the Keadaan panel as the global switch. On: the web banner and the nav footer switch. The text swap is disabled (`jk && false`).
- **Interactions** Sheet tab `tab[].pick` sets `pilih` to that form; the grid, column letters, minimum width and row 1 change at once. No other handlers. The grid scroll offset may stay where it is.
- **Motion** none. The board declares `muncul`, `isi` and `titik` but uses none of them.
- **Links out** "Laporan" breadcrumb → `/WebPaketLaporan`, up link. Side nav: seven items, `go`. **Inbound** FormatLaporan, Laporan, TutupBuku, WebFormatLaporan, WebLaporan, WebPaketLaporan, WebTutupBuku (manifest), plus PetaLayar ("Contoh Excel") and Cakupan ("Excel"), whose JS-built links the manifest misses.
- **Mock data** Copy the board's `F` list and the `LAP` object (source lines 75–116) verbatim into `lib/mock/excel.dart`. That covers the 14 forms with their columns, `kanan` indices and rows; each row ends with the marker `1` when it is bold. Summary:
  - Forms: F01 Laporan Perbendaharaan Bulanan; F02 Buku Kas Umum; F03 Buku Kas Pembantu; F04 Mata Anggaran Pendapatan; F05 Realisasi Pendapatan Menurut Mata Anggaran; F06 Mata Anggaran Belanja; F07 Realisasi Belanja Menurut Mata Anggaran; F08 Rekap Penerimaan; F09 Rekap Pengeluaran; F10 Posisi Kas & Bank; F11 Rekonsiliasi; F12 Daftar Bukti Kas; F13 Sentralisasi / Penyaluran; F14 Lampiran Laporan Bulanan.
  - F01, column B "Oktober 2026":
    - Saldo awal Kas/Bank Rp36.250.000 (bold)
    - Pendapatan ekonomi Rp14.820.000
    - Belanja ekonomi −Rp11.455.000
    - Dana Transit masuk Rp2.400.000
    - Dana Transit keluar −Rp2.400.000
    - Uang Muka diberikan −Rp1.500.000
    - Pengembalian sisa uang muka Rp350.000
    - Saldo akhir Kas/Bank Rp38.465.000 (bold)
  - F02, 33 data rows (sheet rows 7–39):
    - Columns: Tanggal, No. Bukti, No. MA, Uraian, Kas/Bank, Penerimaan, Pengeluaran, Saldo semua Kas/Bank.
    - Row 7: "Saldo awal Kas/Bank" 36.250.000 (bold).
    - Rows 8–38: BKU-2026-0098 (04/10/2026) to BKU-2026-0133 (31/10/2026). Row 19, "BKU-2026-0109 · Pembalikan BKU-2026-0105", shows Pengeluaran "-750.000".
    - Row 39: "Jumlah dan saldo akhir Kas/Bank" 29.260.000 · 27.045.000 · 38.465.000 (bold).
  - F03, Kas only, 23 rows: saldo awal Kas 4.070.000, ending 8.750.000.
  - F04: 6 rows (2 group rows bold).
  - F05: 8 rows. Persembahan Ibadah Minggu 10.950.000, which matches Cari. Total Pendapatan 14.820.000.
  - F06: 6 rows.
  - F07: 11 rows. Pemeliharaan gedung 5.500.000. Total Belanja 11.455.000.
  - F08: Kas / Bank BNI ··4821 / Bank SulutGo ··1107, total penerimaan 29.260.000.
  - F09: total pengeluaran 27.045.000.
  - F10: Kas 8.750.000; BNI saldo buku 24.600.000 vs rekening koran 24.100.000; SulutGo 5.115.000; selisih 0.
  - F11: 8 rows, including "13 / 0" and "1 / 0", and "Sudah dipastikan" ×3.
  - F12: 5 rows, including BKU-2026-0116 "Sudah dicatat · Ketua BPMJ" / "Dikecualikan · kuitansi menyusul".
  - F13: Sinode 2.400.000 terkumpul and disalurkan.
  - F14: 8 attachments, including "Nihil" ×3, "3 kasus", "4 ibadah", "1 dokumen", "1 rangkaian", "8 syarat terpenuhi".
  - People and parties in the rows: Pnt. Jefry Wowor, Sdri. Natalia Rumengan, Ibu Selvie Kalalo, Panitia HUT Jemaat, Toko Sinar.
  - The `sub` and `kaki` strings in `LAP` are not shown on screen (see Notes).
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/WebExcel`. Side-nav "Laporan" is active. Tab "F02" is `permukaan`, 700, with a 3 px `laut` bottom line. Column letters run A–H, and row 1 reads "BUKU KAS UMUM" in bold, spilling across the columns.
  2. Row 6 shows the headers "Tanggal … Saldo semua Kas/Bank" on `kertas`, in bold. The last row number is 39, and its H cell reads "38.465.000", right-aligned and bold.
  3. Row 19 column G reads "-750.000" with an ASCII hyphen. Column C of row 8 reads "1.3.53.07.00; 1.3.55.01.00" in mono, and dates are in sans.
  4. Click "F13". Row 1 reads "SENTRALISASI / PENYALURAN", there are five letter columns (A–E), and the last data row (row 10) shows "0" under column D.
  5. Click "F14". Rows 7–14 list the eight attachments, and column C shows "Nihil" three times (rows 8, 10 and 13).
  6. Click "F01". The grid narrows to a 542 px minimum, and row 9 reads "Belanja ekonomi … -11.455.000".
  7. At 860 px wide, F02 scrolls horizontally inside the workbook frame (min 1396) while the page itself does not scroll sideways, and the tab strip scrolls on its own.
  8. Click "Laporan" in the breadcrumb. `/WebPaketLaporan` opens (popped if it was below).
- **Notes**
  - The `sub` (subtitle) and `kaki` (footnote) strings of every form are defined in the logic but never rendered. The board wins: do not show them. Keep them in the mock for WebExcelTerbatas or later use.
  - The `mono` index lists in `LAP` are unused. Font choice comes only from the money and code patterns above, so dates and the F14 numbers are sans.
  - Money cells show an ASCII "-" rather than U+2212, because they imitate Excel's own display. This is file content, not an app-formatted amount, so do not route it through `rp()`.
  - Radius 10 on the workbook frame and 13 px mono grid text are copied as drawn.
  - Phone boards (Laporan, TutupBuku, FormatLaporan) also link here. The page renders in laptop form in every case.

### Persetujuan — 29 · Persetujuan: ganti catatan, gugur karena perubahan
- **Source** `docs/design/handoff/canvas/boards/Persetujuan.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/Persetujuan`. No child routes: forms and warnings open in place. · **Widget** `PersetujuanScreen` in `lib/screens/lengkap/persetujuan.dart`
- **Purpose** Bendahara Jemaat on the phone, corrections (journey "Bendahara Jemaat" step 3, beside "4 · Koreksi, persetujuan, kejadian"). The approval for a draft Belanja of Rp2.500.000 was given outside the app and recorded by the Bendahara (KartuPersetujuan). The board shows that:
  - A wrong record is replaced by a new one, never edited, and the old one stays in "Riwayat persetujuan" marked as replaced, with a required reason (P12).
  - Changing the amount (or the payee, Kas/Bank, peruntukan, Mata Anggaran, date or description) voids the approval, which must then be recorded again before Bukukan.
  - There is no "Approve" button and no signature (Foundations, KartuPersetujuan).

  Lainnya's row "Persetujuan di luar aplikasi · Ganti catatan, dan yang terjadi bila transaksi diubah" opens it.
- **Shell** Phone header with back, no tab bar. Root as Cari (`kertas`, `tinta`, sans 16/1.4), with the phone PitaJabatanKosong strip on top when `jabatanKosong` is on.
- **Layout**
  0. (only when `jabatanKosong`) The strip, as Cari 0.
  1. Header: as Cari 1, with title "Persetujuan" and subtitle "Catatan yang keliru digantikan, tidak diubah" (13 `tinta2`). Back Semantics: "Kembali ke Beranda".
  2. Scroll area: padding 8/20/20, column gap 16. Children in order (several are conditional):
     a. **Draft card**, always shown: 1.5 dashed `putus` (draf), radius 16 (the board sets 14 and then overrides it), padding 18, column gap 6, transparent. It contains:
        - Badge "Draf · belum masuk saldo" (13/700, radius 6, padding 3 9, 1.5 dashed `putus`, `tinta2`), aligned left.
        - Amount: mono 30/500 `tinta2` (`jumlahIsian`), "−Rp2.500.000" and later "−Rp2.750.000".
        - "Perbaikan sound system" (600).
        - "Bank BNI ··4821 · Belanja 5.08.02.00 Pemeliharaan gedung · 16 November 2026" (13 `tinta3`).
        - "Aturan: persetujuan wajib untuk Belanja Rp2.000.000 ke atas" (13 `tinta3`).
     b. **Recorded card** (`ada`, when a valid record exists): `permukaan`, 1 px `garis` (dibukukan), radius 14, padding 14/16, column gap 4. Lines:
        - "Persetujuan di luar aplikasi" (14 `tinta2`).
        - "Persetujuan sudah dicatat" (700).
        - "Pemberi persetujuan: **{nama}**, {jabatan}" (14, label `tinta2`, name 700).
        - "{tgl} · cara: {cara}" (14 `tinta2`).
        - Footer: 13 `tinta3`, with a 1 px dashed `garisTegas` top rule, margin-top 8, padding-top 8: "Dicatat oleh Meiske L., {oleh}. Pernyataan Bendahara, bukan persetujuan di dalam aplikasi."
     c. **Not-recorded card** (`belum`): 1.5 dashed `putus`, radius 14, padding 14/16. Lines:
        - "Persetujuan di luar aplikasi" (14 `tinta2`).
        - "Persetujuan belum dicatat" (700 `bata`).
        - "Draf ini belum dapat dibukukan sampai persetujuan untuk jumlah yang baru dicatat." (14 `tinta2`).
     d. **Warning card** (`peringatan`): `permukaan`, 1.5 solid `tinta` (terpilih), radius 14, padding 16, column gap 10. Contents:
        - "Mengubah jumlah membuat persetujuan tidak berlaku" (16/700).
        - "Persetujuan dicatat untuk Rp2.500.000. Perubahan pada jumlah, pihak yang dibayar, Kas/Bank, peruntukan, Mata Anggaran, tanggal atau uraian mengembalikannya ke belum dicatat." (14 `tinta2`).
        - Buttons (wrap, gap 8): "Ubah menjadi Rp2.750.000" (min-height 46, padding 0 20, radius 12, no border, `tinta` field, `permukaan` text, 700), then "Kembali" (secondary: 46, 1.5 `tinta`, `permukaan`, `tinta` 700).
     e. **Form card** (`adaForm`): `permukaan`, 1 px `garis`, radius 14, padding 16, column gap 10. Contents:
        - Title {formJudul} (16/700) over {formCat} (14 `tinta2`), in one block with no gap between them:
          - 'ganti': "Ganti catatan persetujuan" over "Catatan lama tidak diubah. Ia tetap ada di Riwayat dengan tanda digantikan."
          - 'catat': "Catat persetujuan" over "Anda mencatat persetujuan yang diberikan di luar aplikasi."
        - Field "Pemberi persetujuan **· wajib**": label 14 `tinta2` (block, margin-bottom 6, "· wajib" strong `tinta`). Input: full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan`. Starts empty.
        - Field "Jabatan": the same input, prefilled "Ketua BPMJ".
        - ('ganti' only) Field "Alasan mengganti **· wajib**": IsianAlasan textarea with 2 rows, padding 12/14, radius 12, 1 px `garisTegas`, no resize, hint "Contoh: nama pemberi persetujuan keliru".
        - Buttons (wrap, gap 8):
          - Submit, labelled {formJudul}: min-height 46, padding 0 20, radius 12, no border, 700. Valid: `laut` field, `diLaut` text. Otherwise `garis` field, `tinta3` text.
          - "Kembali" (secondary).
     f. **Action row** (`tanpaForm`: no form and no warning open): wrap, gap 8. It shows, in order:
        - "Ganti catatan persetujuan" (secondary), when a record exists.
        - "Catat persetujuan" (primary: 46 high, `laut` field, `diLaut` text, no border), when none exists.
        - "Ubah jumlah" (secondary), while the amount is still Rp2.500.000.
     g. **Riwayat** (`adaLama`, when at least one old record exists): column, gap 8. Heading "Riwayat persetujuan" (15/700; the board sets 16 and then overrides it). Then one card per old record, newest replaced first: 1.5 dashed `putus`, radius 14, padding 12/14. Each card has two lines:
        - "{nama}, {jabatan} · {tgl} · dicatat {oleh}" (14 `tinta2`).
        - {catatan} (14/600 `tinta`).
- **Components**
  - KartuPersetujuan: recorded in region b, not recorded in region c. "Catat persetujuan" is its button.
  - IsianAlasan: "Alasan mengganti".
  - LencanaStatus: the Draf shape.
  - GarisStatus: draf (draft card, not-recorded card, history cards), dibukukan (recorded card), terpilih (warning card).
  - Tombol: primary `laut` "Catat persetujuan" and the submit; `tinta`-field "Ubah menjadi Rp2.750.000"; secondary buttons.
  - TombolBersyarat-style submit.
  - PitaJabatanKosong (phone).
  - Pattern: the history list. It is close to RiwayatAlur but drawn as dashed cards; follow the board.
- **Internal views and states** Initial state `{ jm: 2500000, form: null, nama: '', jab: 'Ketua BPMJ', alasan: '', peringatan: false, rec: [{ nama: 'Pdt. Lidya Rondonuwu', jab: 'Ketua BPMJ', tgl: '08/11/2026', cara: 'notulen rapat', oleh: '16/11/2026 11.20', st: 'berlaku', cat: '' }] }`.
  - Derived values:
    - `cur` = the first record with `st` 'berlaku'.
    - `ada` = `cur` exists, and `belum` = it does not.
    - `tanpaForm` = `!form && !peringatan`.
    - `bisaUbah` = `jm == 2500000`.
    - `lama` = records with `st` other than 'berlaku', in list order.
  - Views:
    1. Recorded with actions (the default).
    2. Ganti form (`form` 'ganti').
    3. Catat form (`form` 'catat', no reason field).
    4. Warning (`peringatan`).
    5. Not recorded after an amount change, with the "Catat persetujuan" action.
    6. Any of these plus Riwayat.
- **Tweaks** `jabatanKosong` (boolean, default false), in the Keadaan panel as the global switch. On: shows strip 0. "Dicatat oleh Meiske L." stays, because the text swap is disabled (`jk && false`) and the name is hard-coded.
- **Interactions**
  - "Ganti catatan persetujuan" (`bukaGanti`): `form` = 'ganti', `nama` = '', `alasan` = ''. `jab` keeps its current value.
  - "Catat persetujuan" (`bukaCatat`): `form` = 'catat', `nama` = '', `alasan` = ''.
  - Inputs `onNama`, `onJab` and `onAlasan` update on every keystroke. They are free text; trim only when checking and saving.
  - Submit condition, re-checked on press:
    - 'catat': `nama.trim()` is not empty.
    - 'ganti': `nama.trim()` is not empty and `alasan.trim()` is not empty.
    - Jabatan is never checked and may be blank.
    - No refusal sentence is drawn; see Notes.
  - Submit (`simpan`), when the condition holds:
    - Every 'berlaku' record becomes `st` 'lama' with `cat` = "Digantikan 16/11/2026 11.45 · alasan: {alasan.trim()}". In the 'catat' case there is none, because no valid record exists.
    - A new record goes first in the list: `{ nama: nama.trim(), jab: jab, tgl: '16/11/2026', cara: 'notulen rapat', oleh: '16/11/2026 11.45', st: 'berlaku', cat: '' }`.
    - Then `form` = null.
  - "Kembali", in the form or the warning (`batal`): `form` = null and `peringatan` = false.
  - "Ubah jumlah" (`mintaUbah`): `peringatan` = true and `form` = null.
  - "Ubah menjadi Rp2.750.000" (`ubah`):
    - The 'berlaku' record becomes 'lama' with `cat` = "Tidak berlaku lagi sejak 16/11/2026 11.50 · jumlah diubah dari Rp2.500.000 menjadi Rp2.750.000".
    - `jm` = 2750000 and `peringatan` = false.
    - Result: the amount reads "−Rp2.750.000", the not-recorded card appears, "Ubah jumlah" is gone for good, and only "Catat persetujuan" remains.
  - Back arrow: up link to `/Main`.
  - Typed-input rules: none beyond trimming. No dates or amounts are typed here.
- **Motion**
  - These elements enter with `muncul` 300 ms (CSS `ease`) when they appear: the not-recorded card, the warning card, the form card, and each history card.
  - The recorded card and the action row appear without animation, including when the recorded card comes back after a save.
  - The board also declares `masuk`, `pudar` and `isi` but does not use them.
  - Under reduce motion, everything appears at once.
- **Links out** Back arrow (no label, Semantics "Kembali ke Beranda") → `/Main`, up link (`Tautan(ke: 'Main')`). It goes to `/Main` when opened from Lainnya or Koreksi. **Inbound** Koreksi, Lainnya (manifest), plus PetaLayar ("Ganti persetujuan") and Cakupan ("Ganti catatan"), whose JS-built links the manifest misses.
- **Mock data**
  - Draft: Perbaikan sound system, −Rp2.500.000 (later −Rp2.750.000), Bank BNI ··4821, Belanja 5.08.02.00 Pemeliharaan gedung, 16 November 2026. Rule: approval required for Belanja Rp2.000.000 and above.
  - Initial record: Pdt. Lidya Rondonuwu, Ketua BPMJ, 08/11/2026, cara "notulen rapat", recorded 16/11/2026 11.20 by Meiske L.
  - New records: tgl 16/11/2026, recorded 16/11/2026 11.45, cara "notulen rapat".
  - Times used: replaced 11.45, voided 11.50.
- **Prototype-only** None of the four devices. The hint "Contoh: nama pemberi persetujuan keliru" is an IsianAlasan sample-reason placeholder, not a "Contoh:" button, so keep it in the field. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/Persetujuan`. The dashed card shows "−Rp2.500.000" in `tinta2`. The recorded card reads "Pemberi persetujuan: Pdt. Lidya Rondonuwu, Ketua BPMJ", "08/11/2026 · cara: notulen rapat" and "Dicatat oleh Meiske L., 16/11/2026 11.20. Pernyataan Bendahara, bukan persetujuan di dalam aplikasi." The buttons are "Ganti catatan persetujuan" and "Ubah jumlah".
  2. Tap "Ganti catatan persetujuan". The form rises in with title "Ganti catatan persetujuan" over "Catatan lama tidak diubah. Ia tetap ada di Riwayat dengan tanda digantikan.", Jabatan "Ketua BPMJ", an empty name, and a reason field with hint "Contoh: nama pemberi persetujuan keliru". The submit is `garis` with `tinta3` text, and the action row is hidden.
  3. Type the name "Pnt. Jefry Wowor": still disabled. Type the reason "nama keliru": it turns `laut`. The first tap saves. The recorded card shows "Pnt. Jefry Wowor, Ketua BPMJ", "16/11/2026 · cara: notulen rapat" and "Dicatat oleh Meiske L., 16/11/2026 11.45.". "Riwayat persetujuan" shows "Pdt. Lidya Rondonuwu, Ketua BPMJ · 08/11/2026 · dicatat 16/11/2026 11.20" / "Digantikan 16/11/2026 11.45 · alasan: nama keliru".
  4. Tap "Ubah jumlah". The warning card rises in and the action row is hidden. "Kembali" returns to the previous view.
  5. Tap "Ubah jumlah", then "Ubah menjadi Rp2.750.000". The amount reads "−Rp2.750.000", the dashed card with the `bata` "Persetujuan belum dicatat" rises in, the only action is "Catat persetujuan" (`laut`), and Riwayat gains "Tidak berlaku lagi sejak 16/11/2026 11.50 · jumlah diubah dari Rp2.500.000 menjadi Rp2.750.000".
  6. Tap "Catat persetujuan". The form is titled "Catat persetujuan" over "Anda mencatat persetujuan yang diberikan di luar aplikasi." and has no reason field; Jabatan still reads "Ketua BPMJ" (or what was last typed there). Type a name; the submit enables. Save: the recorded card returns, and "Ubah jumlah" does not come back.
  7. A name of only spaces never enables the submit.
  8. The back arrow leads to `/Main`. With `jabatanKosong` on, the strip shows and the footer still says "Dicatat oleh Meiske L.".
- **Notes**
  - The submit has no "Tidak dapat dilakukan: …" sentence while unmet; the "· wajib" labels are the only cue. This breaks the CONVENTIONS rule that a disabled action shows its reason, but the board wins. Add a Semantics hint ("Pemberi persetujuan belum diisi" / "Alasan mengganti belum diisi") and flag it.
  - The disabled look uses `tinta3` text; TombolBersyarat says `tinta2`. The board wins.
  - "Dicatat oleh Meiske L." is hard-coded even with `jabatanKosong` on. PitaJabatanKosong says every action records the Operator. Keep the board and flag it.
  - The footer rule of the recorded card is 1 px dashed `garisTegas`, outside the line-language set. Copy it.
  - An empty Jabatan saves a record that reads "{nama}, " with a trailing comma. Keep it as the board does.
  - Radius 16 on the draft card is `kartuBesar`. The 46 px buttons are off-token; copy them.
  - The manifest's `hasSideNav: true` is a false positive.

### WebPersetujuan — Web · Persetujuan: ganti catatan dan perubahan
- **Source** `docs/design/handoff/canvas/boards/WebPersetujuan.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebPersetujuan`, no child routes · **Widget** `WebPersetujuanScreen` in `lib/screens/lengkap/web_persetujuan.dart`
- **Purpose** The same as Persetujuan for the Bendahara Jemaat at the desk, reached from the link "Ganti catatan persetujuan" on WebCatat and TabCatat, and from the action "Catat persetujuan" in the transaction detail of WebTransaksi and TabTransaksi. The same decisions: KartuPersetujuan, no Approve and no signature, replace rather than edit, void on change, and P12.
- **Shell** Web side nav as WebCari, active item **Transaksi**, with the `jabatanKosong` banner and footer.
- **Layout**
  1. Title block:
     - Breadcrumb "Transaksi": 14/600 `laut`, underlined.
     - h1 "Persetujuan di luar aplikasi": 26/700, margin-top 2.
     - Under it, 14 `tinta2`: "Catatan yang keliru digantikan catatan baru, tidak diubah. Perubahan pada transaksi membuat persetujuan perlu dicatat lagi."
  2. Two-column row: wrap, gap 24, aligned top. The left column takes flex 1 1 360 and the right column takes 999 1 440. At 1440 the left is about 360 wide. When main is narrower than 824 the right column drops below.
     - Left: the draft card, the same as Persetujuan 2a (amount mono 30, body text inherits 15).
     - Right (column, gap 14): Persetujuan regions 2b–2g in the same order with the same styles and copy. Body text inherits 15 px where the phone has 16 (the "Persetujuan sudah dicatat" line, the button labels).
- **Components** As Persetujuan, plus the shared web side nav and the web PitaJabatanKosong.
- **Internal views and states** Same state object, derived values and views as Persetujuan.
- **Tweaks** `jabatanKosong` (boolean, default false), in the Keadaan panel as the global switch. On: the web banner and the nav footer switch. The text swap is disabled, so "Dicatat oleh Meiske L." stays.
- **Interactions** Identical to Persetujuan: `bukaGanti`, `bukaCatat`, `onNama`, `onJab`, `onAlasan`, `simpan` (same condition and the same records and times), `batal`, `mintaUbah`, `ubah`. Breadcrumb and side nav: see Links out.
- **Motion** As Persetujuan: `muncul` 300 ms on the not-recorded card, the warning, the form and the history cards. The board also declares `isi` and `titik` but does not use them.
- **Links out** "Transaksi" breadcrumb → `/WebTransaksi`, up link: from WebCatat it does `go('/WebTransaksi')`, because the route below is `/WebCatat`. Side nav: seven items, `go`. **Inbound** TabCatat, WebCatat (manifest), plus JS-built links the manifest misses: WebTransaksi and TabTransaksi (the detail action "Catat persetujuan", from their `TUJU` map) and PetaLayar ("Ganti persetujuan").
- **Mock data** Same as Persetujuan.
- **Prototype-only** None. The reason hint "Contoh: nama pemberi persetujuan keliru" stays in the field. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/WebPersetujuan` at 1440. Side-nav "Transaksi" is active. The draft card ("−Rp2.500.000") is on the left, and the recorded card and actions are on the right.
  2. Click "Ganti catatan persetujuan", fill the name and reason, and save. The right column shows the new record and "Riwayat persetujuan" with "Digantikan 16/11/2026 11.45 · alasan: …".
  3. Click "Ubah jumlah", then "Ubah menjadi Rp2.750.000". The left card reads "−Rp2.750.000", and on the right "Persetujuan belum dicatat" rises in with only "Catat persetujuan".
  4. Opened from `/WebCatat`, browser Back returns to `/WebCatat`. Clicking the breadcrumb "Transaksi" goes to `/WebTransaksi`.
  5. At 820 px wide, the nav shows "Menu" and the right column sits below the draft card.
  6. Turn on `jabatanKosong`. The banner appears above the breadcrumb, and the footer reads "Yanti Sumual · Operator".
- **Notes** Same as Persetujuan: no reason sentence for the disabled submit, the `tinta3` disabled text, the hard-coded "Meiske L.", and the dashed `garisTegas` footer rule. The breadcrumb says "Transaksi", though the usual entry is WebCatat. Keep the board.
