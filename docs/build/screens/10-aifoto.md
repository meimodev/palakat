# Screens 10: AIFoto, WebAIFoto, AIBulan, WebKasus, WebSerahTerima, KasusBaru, WebKasusBaru, Sambungan, WebSambungan, Kamera

These ten boards all sit on the canvas page "Pelengkap" (`lengkap`). They fill in the edges of the Bendahara Jemaat's daily work and month end. AIFoto and WebAIFoto turn an attached receipt photo into an optional AI suggestion for a Belanja. The suggestion has a dotted `laut` edge and italic text (D31). Kas/Bank, peruntukan and Lingkup are never suggested (D01). Using it saves only a Draf. AIBulan is the phone pair of WebAI (specified in `06-bukti.md`): AI help while preparing to close October 2026, with the monthly AI cost limit. WebKasus records repayments, payouts and claim payments against running cases of Uang Muka, Titipan and Penggantian biaya (D15–D17). KasusBaru and WebKasusBaru open a new case (D18–D20). WebSerahTerima hands the Bendahara post to a newly appointed person (D21). Sambungan and WebSambungan show what happens offline (input stays on screen and nothing is stored on the device, D35) and when a session ends. Kamera photographs a supporting document and uploads it honestly (uploaded is not verified). How they are reached:
- Main's "Catatan lain" sheet opens AIFoto and KasusBaru; the Keputusan sheet opens Sambungan (and KasusBaru).
- TutupBuku's readiness check opens AIBulan.
- WebCatat and TabCatat open WebAIFoto.
- WebKewajiban opens WebKasus and WebKasusBaru.
- WebPengaturan and WebKeluar open WebSerahTerima.
- Dokumen, KasusBaru and Koreksi open Kamera.
- The map sheet PetaLayar links to all ten boards, and Cakupan links to AIFoto, AIBulan, KasusBaru, Sambungan, WebSambungan and Kamera. Their logic classes build these links, so the manifest misses them (`navigation.md` 3.3).
- WebSambungan has no inbound link in the manifest. It is reached from PetaLayar, Cakupan and the launcher.

The phone boards have a header with a back arrow and no tab bar. The web boards use the standard side nav. The "today" is 16/11/2026; the actor is Meiske L., Bendahara.

Shared notes for this file:

- **Phone root**: 390 × 844, `kertas` background, `tinta` text, body `isi` (16, line-height 1.4).
- **Phone header** (AIFoto, AIBulan, KasusBaru, Sambungan form view, Kamera light view):
  - Row: padding 14 top, 12 sides, 8 bottom; gap 8.
  - Back target 44 × 44 with the chevron `M15 6l-6 6 6 6` (22 px, stroke 2, round caps, `tinta`). Its `aria-label` becomes a Semantics label.
  - Title `judulLayar` 18/700. Optional subtitle 13 `tinta2`: the boards write `font-size: 14px; … font-size: 13px`, and the later value, 13, wins.
- **Phone PitaJabatanKosong strip** (AIFoto, AIBulan, KasusBaru only, when `jabatanKosong` is on):
  - The first child of the root column, not scrolled, `role=status`.
  - `tinta` field, `permukaan` text, padding 10/24/8, 13 px, line-height 1.3, centred.
  - Text: "**Menjalankan jabatan kosong** · Bendahara Jemaat".
  - All three boards have `if (jk && false)`, so no text is replaced.
- **Web side nav**: exactly as specified in `06-bukti.md` → WebBukti → Shell.
  - Items: Beranda, Transaksi, Uang Muka dan Titipan, Rekonsiliasi, Bulan dan tutup buku, Laporan, Pengaturan, all `go`.
  - Footer "**Meiske L.** · Bendahara / Wewenang Bendahara aktif".
  - Below 860 px the "Menu" / "Tutup menu" collapse applies.
  - Each section names the active item. On WebSerahTerima and WebSambungan the footer is fixed: those boards have no `jabatanKosong` switch.
- **Web main column**: flex 999 1 560, padding 28 top, clamp(16, 3vw, 40) sides, 40 bottom, column gap 20, body `isiWeb` 15/1.45.
- **Web PitaJabatanKosong banner** (WebAIFoto, WebKasus, WebKasusBaru, when `jabatanKosong` is on):
  - The first child of main, `role=status`, `tinta` field, radius 14, padding 12/16, 14 px.
  - Text: "**Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.**" (bold part in `permukaan`), then " Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." in `diTinta2`.
  - No text replacement on any of them (`jk && false`).
- **Breadcrumb** (web): link 14/600 `laut` (`lautTua` on hover/press) above an h1 of 26/700 with a 2 px top margin.
- **Up link**: the phone back arrow or the web breadcrumb, plus the links this file marks as up links (AIBulan's "Kembali ke kesiapan tutup buku", "Buka di Uang yang masih berjalan" on KasusBaru and WebKasusBaru). It is `kembaliKe('/X')`: it pops when the route directly beneath is `/X` or a child route of `/X`; otherwise it does `go('/X')`. So Back after an up link does not return to the board that was left. Drill-ins into other boards are `push`; side-nav items are `go`.
- **`muncul`** in this file is opacity 0→1 and y +8→0 with CSS `ease` (the board's `animation: muncul .3s` names no curve), as in `motion.md`. It is 300 ms unless a section gives another duration.
- **Dotted and dashed lines** all come from the shared painter.
  - `usulanAI` = 1.5 dotted `laut`.
  - `draf` = 1.5 dashed `putus`.
  - AI row dividers are 1 px dotted `garisTegas`.
- **Rupiah** always through `rp()`. Amount inputs keep digits only, strip leading zeros and allow at most 11 digits. They display with dot thousands ("650000" → "650.000").
- **Chips** (ChipPilihan): inline, min-height 44, padding 0 14, radius 999, 1.5 border, 14/600, `aria-pressed`. Selected: `tinta` field and border, `permukaan` text. Unselected: `permukaan` field, `garisTegas` border, `tinta` text. On phone and WebKasusBaru each chip has an 8 px right and bottom margin; WebKasus uses a wrap gap of 8 instead.
- **Board-level state survives child routes** (Kamera only in this file): hold the state object and its timer in a `ChangeNotifier` created by a `ShellRoute` (or equivalent) around `/Kamera` and its child routes. Dispose it, cancelling the timer, only when the board is left for another stem.
- **Timers**: every `setTimeout`/`setInterval` becomes `Future.delayed`/`Timer` with the same milliseconds and is cancelled on dispose. Sambungan, WebSambungan and Kamera forget to clear theirs on the canvas; cancel them anyway.

---

### AIFoto — 35 · Bantuan AI dari foto nota
- **Source** `docs/design/handoff/canvas/boards/AIFoto.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/AIFoto`, no child routes (the suggestion appears in place) · **Widget** `AIFotoScreen` in `lib/screens/lengkap/ai_foto.dart`
- **Purpose** The Bendahara Jemaat, journey step 2 (daily recording), records a Belanja from a receipt photo. It is reached from Main's "Catatan lain" sheet chip "Dari foto nota". The board shows:
  - D31: the AI suggestion has a dotted `laut` edge and italic `lautTua` text (KartuUsulanAI).
  - "AI kurang yakin, mohon dicek" on the two uncertain split lines.
  - D01 and the four-separate-fields rule: AI never proposes Kas/Bank, peruntukan or Lingkup.
  - The photo is already attached as a supporting document "Diunggah, belum diverifikasi", and an AI reading is not a verification (PanelDokumen rule, D02).
  - Using the suggestion only saves a Draf "belum masuk saldo" (StatusSimpan).
- **Shell** Phone header with back, no tab bar. PitaJabatanKosong strip when `jabatanKosong` is on.
- **Layout**
  0. (only with `jabatanKosong`) Strip, as in the shared notes.
  1. Header: back → Main, `aria-label` "Kembali ke Beranda"; title "Belanja"; subtitle "Dari foto nota".
  2. Scroll area (fills the rest): padding 8 top, 20 sides, 20 bottom; column gap 16.
     a. **AI panel**: `lautLembut` field, radius 16, padding 14/16, column gap 10.
        - Label "BANTUAN AI · PILIHAN": 13/700 `lautTua`, letter-spacing 0.3.
        - Photo row (gap 12, centred vertically):
          - Placeholder 72 × 92, radius 8, `permukaan`, 1 px `laut` border, centred text "[Foto nota]" 13 `tinta2`.
          - Text 14: "**nota-toko-sinar.jpg**" (bold `tinta`), then on its own line in `tinta2`: "Terlampir sebagai dokumen pendukung · Diunggah, belum diverifikasi".
        - State block, one of:
          - *belum*: secondary button "Buat usulan dari foto ini". Full width, min-height 44, radius 12, 1.5 `laut` border, `permukaan` field, `lautTua` text 700, centred, padding 0 16.
          - *proses*: `role=status` line "Membaca foto…": min-height 44, vertically centred, 14/600 `lautTua`.
          - *ada*: the KartuUsulanAI card, then the button row (both described below).
          - *dipakai*: nothing.
        - KartuUsulanAI card (*ada*): `permukaan`, 1.5 dotted `laut`, radius 12, padding 4/14.
          - Tag row (padding 10 top, 6 bottom): tag "Usulan AI · dari foto". 13/700 `lautTua`, 1.5 dotted `laut` border, radius 6, padding 2/8, inline.
          - Five rows, each with padding 9/0 and a 1 px dotted `garisTegas` top border. Each row has:
            - the key, 13 `tinta2`;
            - the value, 14/600 italic `lautTua`;
            - for uncertain rows only, "AI kurang yakin, mohon dicek" in 13/600 `tinta`.
          - The rows are listed under Mock data.
          - Footer row: padding 8/0, 1 px dotted `garisTegas` top border, 13 `tinta3`: "Kas/Bank, peruntukan dan Lingkup tidak diusulkan. Pilih sendiri."
        - Button row (*ada*): row gap 8, three equal buttons (flex 1). Each is min-height 46, radius 12, 700, centred.
          - "Pakai": `laut` field, `diLaut` text, no border.
          - "Ubah": `permukaan`, 1.5 `tinta` border, `tinta` text.
          - "Abaikan": same as "Ubah".
        - Footer line 13 `tinta2`: "Hasil baca AI bukan verifikasi. Dokumen pendukung tetap perlu diverifikasi orang."
     b. **Jumlah**:
        - Label "Jumlah (Rp)" 14 `tinta2`.
        - Value mono 34/500, letter-spacing −1, 2 px `tinta` underline, padding-bottom 4.
        - Before Pakai: "Rp0" in `tinta3`. After Pakai: "Rp1.250.000" in `tinta`.
        - This is a display, not an input.
     c. **Field card**: `permukaan`, 1 px `garis` (dibukukan look), radius 14, padding 4/16.
        - Six rows: space-between, gap 16, padding 12/0, a 1 px `garis` top border on every row except the first.
        - Label 14 `tinta2`. Value 14/600, right-aligned: `tinta` when filled, otherwise "Belum diisi" in `tinta3`.
        - Rows in order: Dibayar kepada · Tanggal nota · Mata Anggaran · Kas/Bank · Diambil dari peruntukan · Lingkup.
        - Values after Pakai: "Toko Sinar" · "6 Oktober 2026" · "Dibagi ke 2 baris · total sama dengan Jumlah" · Belum diisi · Belum diisi · Belum diisi.
        - The rows are not pressable.
     d. **Saved line** (only after Pakai): `role=status`, 14 `tinta2`: "Tersimpan sebagai Draf · belum masuk saldo. Semua isian masih dapat diubah."
- **Components**
  - KartuUsulanAI: the dotted card, its tag, and Pakai/Ubah/Abaikan.
  - Tombol: Pakai is the one primary; Ubah, Abaikan and "Buat usulan dari foto ini" are secondary.
  - StatusSimpan: the saved line.
  - PitaJabatanKosong: the strip.
  - Patterns that are not components:
    - the AI panel frame "BANTUAN AI · PILIHAN" (`lautLembut`, radius 16), shared with WebAIFoto and AIBulan;
    - the attached-photo row;
    - the label/value field card.
- **Internal views and states** Initial state `{ tahap: 'belum', pakai: false }`.
  - A *belum* (`tahap 'belum'`, `pakai false`): request button shown. This is the initial state.
  - B *proses* (`tahap 'proses'`): "Membaca foto…" for 1400 ms.
  - C *ada* (`tahap 'ada'`): suggestion card and three buttons.
  - D *dipakai* (`pakai true`, `tahap 'belum'`):
    - The AI panel shows only its label "BANTUAN AI · PILIHAN", the photo row and the footer line. The request button stays hidden for good.
    - Jumlah and the three fields are filled, and the saved line shows.
  - No sheet, no toast, no empty state.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global switch). On: strip 0 shows above the header. No copy changes.
- **Interactions**
  - "Buat usulan dari foto ini" → `tahap = 'proses'`. Any running timer is cancelled, then after 1400 ms (this fakes the AI reading the photo) `tahap = 'ada'`. Cancel the timer on dispose.
  - "Pakai" → `pakai = true`, `tahap = 'belum'` → view D.
  - "Ubah" → the same handler as Pakai (the board binds `pakai` to both). View D says every field can still be changed.
  - "Abaikan" → `tahap = 'belum'`, `pakai` stays false → back to A. No reason is asked.
  - Back arrow → up link to `/Main`.
- **Motion**
  - KartuUsulanAI card: `muncul` 300 ms (opacity 0→1, y +8→0, CSS `ease`) each time C appears. The button row below it appears without animation.
  - Saved line: `muncul` 300 ms when D appears.
  - "Membaca foto…" is static (no pulse).
  - Timer 1400 ms (AI reading).
- **Links out** Back arrow (no visible label; "Kembali ke Beranda") → `/Main`, up link. **Inbound** Main (chip "Dari foto nota"), plus PetaLayar and Cakupan (computed links, `navigation.md` 3.3).
- **Mock data**
  - File: "nota-toko-sinar.jpg", attached, Diunggah, belum diverifikasi.
  - Suggestion rows (key → value · uncertain):
    - "Jumlah (Rp)" → "Rp1.250.000".
    - "Dibayar kepada" → "Toko Sinar".
    - "Tanggal nota" → "6 Oktober 2026".
    - "Bagian 1" → "Belanja 5.01.02.00 Listrik, air dan telepon · Rp1.000.000" · uncertain.
    - "Bagian 2" → "Belanja 5.02.01.00 Alat tulis dan fotokopi · Rp250.000" · uncertain.
  - Filled values after Pakai: as in Layout c.
- **Prototype-only** none of the four devices. The 1400 ms timer stands for the AI service; keep it. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/AIFoto` → panel shows "BANTUAN AI · PILIHAN", "nota-toko-sinar.jpg" and the outlined button "Buat usulan dari foto ini". Jumlah reads "Rp0" in `tinta3`. All six fields read "Belum diisi".
  2. Tap "Buat usulan dari foto ini" → "Membaca foto…" replaces the button. After 1.4 s a dotted card "Usulan AI · dari foto" rises in with five italic rows. "AI kurang yakin, mohon dicek" appears under Bagian 1 and Bagian 2 only.
  3. The card's last line reads "Kas/Bank, peruntukan dan Lingkup tidak diusulkan. Pilih sendiri."
  4. Tap "Abaikan" → card and buttons vanish and "Buat usulan dari foto ini" returns. Jumlah is still "Rp0".
  5. Request again, then tap "Ubah" → same result as Pakai: Jumlah "Rp1.250.000" in `tinta`, Dibayar kepada "Toko Sinar", Tanggal nota "6 Oktober 2026", Mata Anggaran "Dibagi ke 2 baris · total sama dengan Jumlah". Kas/Bank, Diambil dari peruntukan and Lingkup still read "Belum diisi". The saved line rises in. No request button remains.
  6. Leave the screen during "Membaca foto…" → no error and no late state change.
  7. Keadaan `jabatanKosong` on → the strip "Menjalankan jabatan kosong · Bendahara Jemaat" sits above the header.
  8. Back arrow → `/Main`.
- **Notes**
  - "Rp0" in `tinta3` stands for "not filled". IsianJumlah says an empty amount shows a grey hint, not zero. This is a display, not the input; keep the board.
  - The codes inside the italic AI values (5.01.02.00, 5.02.01.00) are sans italic, not mono. Keep the KartuUsulanAI text style for the whole line.
  - "[Foto nota]" is a drawn placeholder; keep it as a text box.
  - The Jumlah figure uses 34 px mono (off-token); copy it.
  - Radius 8 on the photo placeholder is off-token; copy it.
  - Manifest keyframes `isi`, `masuk` and `pudar` are declared but unused.

### WebAIFoto — Web · Bantuan AI dari foto nota
- **Source** `docs/design/handoff/canvas/boards/WebAIFoto.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebAIFoto`, no child routes · **Widget** `WebAIFotoScreen` in `lib/screens/lengkap/web_ai_foto.dart`
- **Purpose** The laptop pair of AIFoto, for the Bendahara Jemaat at the desk (journey step 2). It is reached from WebCatat and TabCatat. It shows the same decisions as AIFoto (D01, D31, PanelDokumen, StatusSimpan).
- **Shell** Web side nav, active item **Transaksi**. Footer switches with `jabatanKosong`. Web PitaJabatanKosong banner when on.
- **Layout**
  1. (only with `jabatanKosong`) web banner, as in the shared notes.
  2. Title block: breadcrumb "Transaksi" → `/WebCatat`; h1 "Belanja dari foto nota".
  3. Two-part row: wrap, gap 24, top-aligned.
     - Left column: flex 999 1 420, column gap 16. It holds, in order, the same Jumlah block, field card and saved line as AIFoto 2b–2d, with the same values and styles.
     - Right aside: flex 1 1 400. It holds the AI panel, identical to AIFoto 2a: frame, label, photo row, state block, card, button row and footer line.
     - Breakpoint: the aside wraps under the left column whenever the main column is narrower than 844 px. That happens at 860 px window width (nav collapsed). At 1280 both sit side by side.
- **Components** Same as AIFoto, with the web PitaJabatanKosong banner instead of the strip. The side nav is shared.
- **Internal views and states** Identical to AIFoto: initial `{ tahap: 'belum', pakai: false }`; views A *belum*, B *proses*, C *ada*, D *dipakai*.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global). On: banner 1 shows. The nav footer reads "**Yanti Sumual** · Operator / Menjalankan jabatan kosong Bendahara Jemaat". No copy replacement.
- **Interactions** Identical to AIFoto: "Buat usulan dari foto ini" → *proses*, then *ada* after 1400 ms; "Pakai" and "Ubah" → *dipakai*; "Abaikan" → *belum*. Breadcrumb → up link to `/WebCatat`. Side nav → `go`.
- **Motion** Card `muncul` 300 ms when C appears. Saved line `muncul` 300 ms. Timer 1400 ms. The manifest's `titik` and `isi` are unused.
- **Links out**
  - Breadcrumb "Transaksi" → `/WebCatat`, up link. Its label says Transaksi, but the target is WebCatat (the Catat transaksi page); keep the board.
  - Side nav (go): `/WebBeranda`, `/WebTransaksi`, `/WebKewajiban`, `/WebRekonsiliasi`, `/WebTutupBuku`, `/WebPaketLaporan`, `/WebPengaturan`.
  - **Inbound** TabCatat, WebCatat (both "Dari foto nota"), plus PetaLayar (computed link, `navigation.md` 3.3).
- **Mock data** Same as AIFoto.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/WebAIFoto` at 1280 → side-nav item "Transaksi" is the `tinta` field. h1 "Belanja dari foto nota". The AI panel is on the right and Jumlah "Rp0" on the left.
  2. "Buat usulan dari foto ini" → "Membaca foto…", then after 1.4 s the dotted card with five rows rises in.
  3. "Pakai" → Jumlah "Rp1.250.000"; the left column shows "Tersimpan sebagai Draf · belum masuk saldo. Semua isian masih dapat diubah."; Kas/Bank still reads "Belum diisi".
  4. "Abaikan" from C → back to the request button.
  5. At 860 px the nav collapses behind "Menu" and the AI panel moves below the field card.
  6. `jabatanKosong` on → the banner is the first item of main, and the footer names Yanti Sumual.
  7. Breadcrumb "Transaksi" → `/WebCatat`. Opened from WebCatat, it pops back to that WebCatat; opened from TabCatat or the launcher, it does `go('/WebCatat')`.
- **Notes** Same off-token values as AIFoto. Keep the breadcrumb label/target mismatch as drawn.

### AIBulan — 36 · Bantuan AI akhir bulan
- **Source** `docs/design/handoff/canvas/boards/AIBulan.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/AIBulan`, no child routes · **Widget** `AIBulanScreen` in `lib/screens/lengkap/ai_bulan.dart`
- **Purpose** The Bendahara Jemaat preparing to close October 2026 (journey step 4) opens the optional AI help from TutupBuku's readiness check ("Bantuan AI"). It is the phone pair of WebAI. The board shows:
  - D31: dotted `laut`, italic `lautTua`, and "AI kurang yakin, mohon dicek".
  - The monthly AI cost limit and what happens at 70 %, 90 % and 100 %.
  - AI only suggests and never closes the books: "Panel ini tidak punya tombol tutup buku."
  - AI stopping does not block closing.
- **Shell** Phone header with back, no tab bar. PitaJabatanKosong strip when `jabatanKosong` is on.
- **Layout**
  0. (only with `jabatanKosong`) Strip.
  1. Header: back → TutupBuku, `aria-label` "Kembali ke Bulan"; title "Bantuan AI"; subtitle "Persiapan tutup buku Oktober 2026".
  2. Scroll area: padding 8/20/20, column gap 16.
     a. **AI panel**: `lautLembut`, radius 16, padding 14/16, column gap 12.
        - Label "BANTUAN AI · PILIHAN" 13/700 `lautTua`, letter-spacing 0.3. It sits alone in a space-between row.
        - Cost block:
          - Text 13 `tinta`: "Batas biaya AI per bulan · {rp(150000 × p/100)} dari Rp150.000".
          - Bar 6 px below the text: height 8, radius 4, `permukaan` track, `laut` fill at min(p, 100) %, no animation.
          - Note 14/600 `tinta`, 6 px below the bar, hidden when empty (values under Tweaks).
        - When AI is on (p < 100), three cards:
          - **Summary card** (KartuUsulanAI): `permukaan`, 1.5 dotted `laut`, radius 12, padding 14, column gap 6.
            - Tag "Usulan AI · ringkasan": start-aligned, 13/700 `lautTua`, 1.5 dotted `laut`, radius 6, padding 2/8.
            - Italic 14 `lautTua`: "Selisih Rp515.000 di Bank BNI tampaknya terdiri dari satu setoran Rp500.000 yang belum muncul di rekening koran dan satu biaya administrasi Rp15.000 yang belum dicatat."
            - 13 `tinta3`: "Angka resmi tetap yang ada di halaman rekonsiliasi."
          - **Two suggestion cards**: the same frame with column gap 8. Each has:
            - its tag;
            - italic 14 `lautTua` text;
            - card 2 only: "AI kurang yakin, mohon dicek" 13/600 `tinta`.
          - While a suggestion card is undecided:
            - Row gap 8: primary button (flex 1, min-height 44, radius 10, `laut`/`diLaut`, 14/700, centred) with the card's label.
            - "Abaikan" (flex none, min-height 44, padding 0 16, radius 10, 1.5 `tinta`, `permukaan`, 14/700).
            - Under the row, a caption 13 `tinta3`.
          - Once decided: a `role=status` line 14/600 `tinta` replaces the buttons and caption.
        - When AI is off (p = 100): card `permukaan` with no border, radius 12, padding 14, 14 `tinta2`: "**Bantuan AI berhenti sampai Desember 2026.** Rekonsiliasi, laporan dan tutup buku berjalan seperti biasa. Ini tidak menghalangi tutup buku." The bold part is `tinta`.
        - Footer 13 `tinta2`: "AI hanya mengusulkan. Panel ini tidak punya tombol tutup buku."
     b. Secondary link button "Kembali ke kesiapan tutup buku": full width, min-height 48, radius 14, 1.5 `tinta`, `permukaan`, `tinta` 700, centred, no underline.
- **Components**
  - KartuUsulanAI: three cards.
  - Tombol: primary per card, "Abaikan" secondary, the bottom secondary link.
  - PitaJabatanKosong.
  - Pattern: the AI cost meter (text, bar and note), as on WebAI.
- **Internal views and states** Initial state `{ u: {} }`, where `u[id]` is `'pakai'` or `'abai'`.
  - Views: AI on (`biayaAI` < 100 %) and AI off (100 %).
  - Per suggestion (`cocok`, `ganda`): undecided, used, or ignored.
  - Decisions persist when `biayaAI` changes and show again when AI comes back on.
- **Tweaks**
  - `jabatanKosong` (boolean, default false) · Keadaan panel (global): the strip. No copy change.
  - `biayaAI` (enum `40%`, `75%`, `95%`, `100%`; default `75%`) · Keadaan panel. With p = the number:
    - `40%`: "Batas biaya AI per bulan · Rp60.000 dari Rp150.000"; bar 40 %; no note; cards shown.
    - `75%`: "… · Rp112.500 dari Rp150.000"; bar 75 %; note "Sudah melewati 70% dari batas bulan ini."; cards shown.
    - `95%`: "… · Rp142.500 dari Rp150.000"; bar 95 %; note "Hampir habis. AI memakai cara yang lebih hemat sampai akhir bulan."; cards shown.
    - `100%`: "… · Rp150.000 dari Rp150.000"; bar full; note "Batas tercapai."; the three cards are hidden and the AI-off card shows.
    - Rule from the source: p ≥ 100 → off; p ≥ 90 → "Hampir habis…"; p ≥ 70 → "Sudah melewati 70%…"; otherwise no note.
- **Interactions**
  - Card "Usulan AI · pencocokan":
    - Caption before deciding: "Belum mencocokkan apa pun."
    - Primary "Buka untuk dicocokkan" → `u.cocok = 'pakai'` → status "Dibuka di rekonsiliasi. Mutasi baru cocok setelah Anda menekan Cocokkan di sana."
    - "Abaikan" → `u.cocok = 'abai'` → "Diabaikan. Tidak perlu alasan."
  - Card "Usulan AI · mungkin perlu dicek":
    - Caption "Hanya informasi."
    - Primary "Lihat keduanya" → `u.ganda = 'pakai'` → "Kedua transaksi dibuka berdampingan. Tidak ada yang diubah."
    - "Abaikan" → "Diabaikan. Tidak perlu alasan."
  - No undo. Neither button navigates.
  - Back arrow and "Kembali ke kesiapan tutup buku" → up link to `/TutupBuku`. Pop when the route beneath is `/TutupBuku` or one of its child routes (normally `/TutupBuku/cek`, which pushed this board); otherwise `go('/TutupBuku')`.
- **Motion** Decision status line: `muncul` 300 ms when it appears. The cost bar does not animate. Manifest keyframes `isi`, `masuk` and `pudar` are unused.
- **Links out** Back arrow ("Kembali ke Bulan") → `/TutupBuku`; "Kembali ke kesiapan tutup buku" → `/TutupBuku`; both up links. **Inbound** TutupBuku ("Bantuan AI" on its readiness view `/TutupBuku/cek`), plus PetaLayar and Cakupan (computed links, `navigation.md` 3.3).
- **Mock data**
  - Month: Oktober 2026.
  - Bank BNI difference Rp515.000 = deposit Rp500.000 + admin fee Rp15.000.
  - Cost limit Rp150.000 per month; AI stops until Desember 2026.
  - Suggestion 1: "Mutasi bank “TARIK TUNAI −Rp2.000.000” (30/10) kemungkinan cocok dengan BKU-2026-0127 Pindah antar Kas/Bank: Bank BNI ke Kas."
  - Suggestion 2: "BKU-2026-0101 dan draf “Toko Sinar okt” sama-sama Rp1.250.000 ke Toko Sinar pada 06/10/2026. Bisa jadi tercatat dua kali, bisa juga dua tagihan."
- **Prototype-only** none. Keadaan panel: `jabatanKosong`, `biayaAI`.
- **Acceptance checks**
  1. Default (75%) → "Batas biaya AI per bulan · Rp112.500 dari Rp150.000", bar three quarters full, note "Sudah melewati 70% dari batas bulan ini.", three dotted cards.
  2. Only card 2 shows "AI kurang yakin, mohon dicek".
  3. "Buka untuk dicocokkan" → the button row and caption go, and "Dibuka di rekonsiliasi. Mutasi baru cocok setelah Anda menekan Cocokkan di sana." rises in. The route is unchanged.
  4. "Abaikan" on card 2 → "Diabaikan. Tidak perlu alasan.".
  5. `biayaAI` 100% → "Batas tercapai.", no dotted cards, card "Bantuan AI berhenti sampai Desember 2026. … Ini tidak menghalangi tutup buku."
  6. Back to `75%` → the cards return with their earlier decisions.
  7. `biayaAI` 40% → "Rp60.000 dari Rp150.000" and no note line.
  8. "Kembali ke kesiapan tutup buku" → returns to the TutupBuku view that opened this board.
- **Notes**
  - **Link test**: the source defines `navVals()` (the web side-nav array), but the phone markup never renders it, and `rv0()` never calls it. The seven web targets in the manifest's `jsLinks` for AIBulan are therefore false positives. Do not add a side nav. The link test must accept AIBulan with only `Tautan(ke: 'TutupBuku')`.
  - It differs from WebAI in several ways: panel radius 16 (WebAI 18), gap 12, no Hambatan list, different AI-off and footer copy, and the "Abaikan" button does not stretch. Each board keeps its own.
  - Radius 10 on the card buttons is off-token; copy it.

### WebKasus — Web · Uang Muka dan Titipan: catat pada kasus
- **Source** `docs/design/handoff/canvas/boards/WebKasus.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebKasus`, no child routes (the case detail is the right column of the same page, and the amount form is an inline panel) · **Widget** `WebKasusScreen` in `lib/screens/lengkap/web_kasus.dart`
- **Purpose** The Bendahara Jemaat at the desk records what happens on a running case: an Uang Muka is accounted for or its remainder repaid; a Titipan is passed on; a claim is checked and then paid. Journey step 2 ("11 · Uang Muka, Titipan, Penggantian biaya"). The board shows:
  - D15: the list of running money.
  - D16: spending beyond the advance is refused here — "Kelebihan belanja dicatat sebagai Penggantian biaya."
  - D17: a claim must be checked ("Cek klaim · tidak mengubah saldo") before "Bayar penggantian biaya" appears.
  - KartuKasus rules: the remainder is computed, never typed; the part not yet accounted for stays dashed; past due is bold without `bata`.
  - R03: the November settlements of Rp400.000 and Rp300.000.
  - The booking motion: a new No. Bukti, and the remainder counting down.
- **Shell** Web side nav, active item **Uang Muka dan Titipan**. Footer switches with `jabatanKosong`. Web banner when on.
- **Layout**
  1. (only with `jabatanKosong`) web banner.
  2. Title block: breadcrumb "Uang Muka dan Titipan" → `/WebKewajiban`; h1 "Catat pada kasus".
  3. Kind chips (wrap, gap 8): "Uang Muka", "Titipan", "Penggantian biaya" (ChipPilihan, shared chip style).
  4. Two-part row: wrap, gap 24, top-aligned.
     a. **Case list** (flex 1 1 340, column gap 10):
        - Summary:
          - "{L.sisa} · {n} kasus" 14 `tinta2`, where n = number of cases of this kind with remainder > 0.
          - Below it, the total of their remainders in mono 30/500 (`jumlahIsian`).
        - One card button per case of the kind, full width:
          - Column gap 6, radius 14, padding 14/16.
          - Open case: `permukaan` field, 1 px `garisTegas` border. Settled case: transparent field, 1 px `garis` border.
          - Row 1 (space-between, gap 16, centred): title 700 | remainder mono 500 (15).
          - Row 2: "{L.pihak}: {pihak}" 13 `tinta3`.
          - Bar: height 8, radius 4, 1.5 dashed `putus` border drawn inside. `tinta` fill at the accounted percentage. No animation in the list.
          - Row 4: status 13 `tinta2`, weight 700 when the case is past due and still open.
          - Status text = kind status + suffix:
            - " · jatuh tempo {tempo}" when the case has a due date and is open;
            - " · Lewat jatuh tempo (jatuh tempo: {tempo})" when it is past due.
          - The chosen card has no selected look.
     b. **Right column** (flex 999 1 480, column gap 14). One of:
        - **Placeholder** (no case open): 1.5 dashed `putus`, radius 14, padding 18, 14 `tinta2`: "Pilih satu kasus di kiri untuk melihat catatannya."
        - **Case detail** (a case open), in order:
          i. h2 title 20/700 (off-token); "{L.pihak}: {pihak}" 14 `tinta2`.
          ii. Row (wrap, baseline, gap 8 vertical, 20 horizontal):
              - Block: "{L.sisa}" 14 `tinta2` over the shown remainder `tampil` in mono 34/500, letter-spacing −1.
              - Badge 13/700, radius 6, padding 3/9. Open: transparent, 1.5 `tinta3` border, `tinta2` text. Settled: `laut` field and 1.5 `laut` border, `diLaut` text (the "Sudah dipastikan" shape). The text is the kind status.
              - Due text 13 (700 when past due): "Jatuh tempo {tempo}" or "Lewat jatuh tempo (jatuh tempo: {tempo})". Empty when the case has no due date or is settled.
          iii. Big bar: height 14, radius 7, 1.5 dashed `putus` border, `tinta` fill at the accounted percentage. The width animates (see Motion).
          iv. Entries card: `permukaan`, 1 px `garis`, radius 14, padding 4/16.
              - Opening row (padding 12/0, space-between, gap 16):
                - Left: "{L.awal}" 600 over the opening note 13 `tinta3`. A Penggantian biaya case that is checked and open adds " · klaim sudah dicek" to the note.
                - Right: the opening amount, mono 500.
              - One row per entry (1 px `garis` top border, padding 12/0):
                - Left: the entry name 600, then a line 13 `tinta3`: "{No. Bukti in mono} · {tanggal} · {catatan}".
                - Right: "− " + rp(amount), mono 500 (a minus, a space, then the figure).
          v. **Amount panel** (when an amount action is open): `permukaan`, 1.5 `tinta` border (terpilih), radius 14, padding 16, column gap 10.
             - Title 16/700; note 14 `tinta2`.
             - Input row: baseline, gap 6, mono, 2 px `tinta` underline, padding-bottom 4, max-width 300. "Rp" 18 `tinta3`. Input mono 26/500 (off-token), min-height 44, no border, numeric keyboard, Semantics "Jumlah (Rp)".
             - When the amount exceeds the remainder: a line 14/600 `bata`: "Tidak dapat dilakukan: melebihi sisa {rp(remainder)}. {over-text}".
             - Button row (wrap, gap 8):
               - Book button: min-height 46, padding 0 20, radius 12, 700. `laut`/`diLaut` when valid, `garis`/`tinta3` when not.
               - "Kembali": same size, 1.5 `tinta`, `permukaan`, `tinta`.
          vi. Action row (wrap, gap 8), shown only while the remainder is > 0. Buttons: min-height 46, padding 0 18, radius 12, 700. Primary = `laut`/`diLaut`, no border. Secondary = `permukaan`, 1.5 `tinta`, `tinta` text.
          vii. When the remainder is 0: a `role=status` line, 700 `laut`: "{status} · tidak ada sisa".
          viii. Footer 13 `tinta3`: "{L.kaki} Sisa dihitung dari catatan di atas; tidak ada isian untuk mengubahnya."
  - Labels `L` per kind (from the source `LBL`):

    | | pihak | awal | sisa | statuses (none / some / settled) | kaki |
    | --- | --- | --- | --- | --- | --- |
    | Uang Muka | Diberikan kepada | Uang Muka diberikan | Sisa belum dipertanggungjawabkan | Belum dipertanggungjawabkan / Sebagian dipertanggungjawabkan / Sudah dipertanggungjawabkan | "Pertanggungjawaban yang diterima menjadi Belanja. Pengembalian sisa kembali ke Kas dan bukan Pendapatan." |
    | Titipan | Titipan untuk | Terkumpul | Sisa belum disalurkan | Belum disalurkan / Sebagian disalurkan / Sudah disalurkan | "Sentralisasi dari uang milik sendiri dicatat sebagai Belanja biasa, tidak di sini." |
    | Penggantian biaya | Dibayar kepada | Klaim | Belum dibayar | Belum dibayar / Belum dibayar / Sudah dibayar | "Mengecek klaim tidak mengubah saldo. Pembayarannya mencatat Belanja satu kali." |

  - Status rule: remainder 0 → settled; otherwise "some" if the case has entries, else "none". Percentage = round((opening − remainder) / opening × 100).
  - In the detail column, `L.pihak`, `L.sisa`, `L.awal` and `L.kaki` come from the selected kind chip. The badge text, the settled line ("{status} · tidak ada sisa") and the action buttons come from the open case's own kind (`st(cur)`, `AKSI[cur.j]`).
  - The action row's wrapper stays in the column even when it is empty (remainder 0), so the column keeps one extra 14 px gap there.
- **Components**
  - KartuKasus: the list cards and the detail. The remainder is computed and the open part is dashed.
  - ChipPilihan: the kind chips.
  - LencanaStatus: the detail badge (outlined for open; the `laut`-field shape for settled).
  - BatangPembagian: the 14 px bar.
  - IsianJumlah: the amount input.
  - TombolBersyarat: the book button. It has a disabled look and a refusal sentence only when over the remainder.
  - Penolakan: the over-remainder line.
  - Tombol: the action buttons and "Kembali".
  - PitaJabatanKosong. Shared side nav.
  - Pattern: the entry ledger card (opening row plus entries).
- **Internal views and states** Initial state, verbatim: `{ tab: 'um', buka: null, sheet: null, isi: '', tampil: 0, nomor: 150, cek: {}, kasus: [7 cases, see Mock data] }`.
  - Kind: `tab` ∈ um, tt, pb.
  - Right column: placeholder (`buka` null) or case detail (`buka` = case id).
  - Amount panel: closed, or open for action `sheet` ∈ tj, kb, sl, by.
  - Per case: open or settled; for pb, claim checked (`cek[id]`) or not.
  - There is no control that returns the right column to the placeholder. The source defines `keDaftar` but never binds it.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global): banner and nav footer. No copy replacement.
- **Interactions**
  - Kind chip → `tab = t`.
    - The board keeps `buka` and `sheet`, so an open case from another kind stays on the right under the new kind's labels.
    - Recommended deviation (see Notes): also set `buka = null` and `sheet = null`.
  - Case card → cancel any running count, then `buka = id` and `tampil` = its remainder.
    - The board does not reset `sheet` or `isi`. The panel shows while the open case's kind has an action whose id equals `sheet`. So a panel open on one Uang Muka case stays open on another Uang Muka case with the old amount (not refilled), checked against the new remainder: tj open on Panitia Natal ("650.000"), then Retret Pemuda → the `bata` line "Tidak dapat dilakukan: melebihi sisa Rp500.000. Kelebihan belanja dicatat sebagai Penggantian biaya." For a case of another kind the panel hides, but `sheet` keeps its value.
    - Recommended: also set `sheet = null` so an amount panel never carries over to another case.
  - Action buttons, for an open case with remainder > 0:
    - Uang Muka: "Catat pertanggungjawaban" (primary) and "Catat pengembalian sisa" (secondary).
    - Titipan: "Salurkan" (primary).
    - Penggantian biaya, claim not checked: only "Cek klaim · tidak mengubah saldo" (primary). Pressing it sets `cek[id] = true` and opens nothing. The button is then replaced by "Bayar penggantian biaya" (primary), and the opening note gains " · klaim sudah dicek". The pay button never shows before the check (D17).
    - Any action other than Cek klaim → `sheet = action` and `isi = String(remainder)`: the panel opens filled with the whole remainder. Pressing another action while a panel is open switches the panel and refills it.
  - Panel contents per action (title · note · book button · new entry name / note · over-text):
    - tj: "Catat pertanggungjawaban" · "Belanja dari uang muka, dengan nota." · "Bukukan pertanggungjawaban" · "Pertanggungjawaban uang muka" / "menjadi Belanja" · "Kelebihan belanja dicatat sebagai Penggantian biaya."
    - kb: "Catat pengembalian sisa" · "Uang kembali ke Kas. Bukan Pendapatan." · "Bukukan pengembalian" · "Pengembalian sisa uang muka" / "kembali ke Kas" · (none).
    - sl: "Salurkan" · "Menyerahkan titipan kepada yang berhak. Bukan Belanja." · "Bukukan penyaluran" · "Penyaluran" / "bukan Belanja" · (none).
    - by: "Bayar penggantian biaya" · "Membayar klaim penuh dan mencatat Belanja satu kali." · "Bukukan pembayaran" · "Penggantian biaya dibayar" / "Belanja, dicatat satu kali" · (none). The input is locked: typing is ignored and it stays at the full claim.
  - Amount input → digits only, leading zeros stripped, at most 11 digits, shown with dot thousands. An empty input shows nothing.
  - Book-button condition: amount > 0 and amount ≤ remainder.
    - It is re-checked from the latest text on every press, so the first press after typing works. Keep `onPressed` set and test the condition inside.
    - Amount empty or 0 → disabled look, no sentence.
    - Amount > remainder → disabled look plus the `bata` refusal line. The over-text is empty for kb, sl and by, so the sentence ends after "{rp(remainder)}.".
  - Book (valid):
    - Append the entry `{ n: entry name, no: 'BKU-2026-0' + nomor, t: '16/11/2026', cat: entry note, jm: amount }`.
    - Close the panel and increment `nomor` (first booking → BKU-2026-0150, then 0151, …).
    - Then count `tampil` from the old remainder to the new one: 22 steps every 30 ms (660 ms in all). Each step's value is `old + (new − old) × (1 − (1 − i/22)³)`, rounded.
    - The list card, summary, percentage and status update at once.
    - When the new remainder is 0: the badge turns to the settled look; the due text, the action row and the panel go; the settled line appears; the list card turns transparent with a `garis` border.
  - "Kembali" in the panel → `sheet = null`.
  - Breadcrumb → up link to `/WebKewajiban`. Side nav → `go`.
  - Leaving the page cancels the count timer.
- **Motion**
  - Entry rows: `muncul` 300 ms on first build, so a new booking rises in.
  - Amount panel: `muncul` 300 ms when it opens; it closes instantly.
  - Big bar: width transition 500 ms, curve `Cubic(0.2, 0.8, 0.2, 1)` (BatangPembagian).
  - Remainder figure: the count above, 660 ms ease-out-cubic. This is the balance-count part of `tinta` (motion.md).
  - The settled line has no animation.
  - Reduce motion: the bar and the count jump to the final values.
  - Manifest `isi` and `titik` are unused.
- **Links out**
  - Breadcrumb "Uang Muka dan Titipan" → `/WebKewajiban`, up link.
  - Side nav (go): `/WebBeranda`, `/WebTransaksi`, `/WebKewajiban`, `/WebRekonsiliasi`, `/WebTutupBuku`, `/WebPaketLaporan`, `/WebPengaturan`.
  - **Inbound** WebKewajiban ("Catat pada kasus"), plus PetaLayar (computed link, `navigation.md` 3.3).
- **Mock data** Each case: id · kind · title · party · opening · opening note · due · entries (No. Bukti · date · note · amount) → remainder · % · status.
  - um1 · Uang Muka · "Panitia Natal" · Sdr. Rivo Mandagi · Rp1.500.000 · "BKU-2026-0129 · 01/11/2026 · dari peruntukan Umum Jemaat" · 30/11/2026 · "Pertanggungjawaban uang muka" BKU-2026-0138 · 08/11/2026 · menjadi Belanja · Rp850.000 → Rp650.000 · 57 % · "Sebagian dipertanggungjawabkan · jatuh tempo 30/11/2026".
  - um2 · Uang Muka · "Retret Pemuda" · Sdri. Natalia Rumengan · Rp800.000 · "BKU-2026-0112 · 20/10/2026 · dari peruntukan Umum Jemaat" · 10/11/2026 past due · "Pertanggungjawaban uang muka" BKU-2026-0150 · 05/11/2026 · menjadi Belanja · Rp300.000 → Rp500.000 · 38 % · bold "Sebagian dipertanggungjawabkan · Lewat jatuh tempo (jatuh tempo: 10/11/2026)".
  - um3 · Uang Muka · "Perjalanan dinas Wilayah" · Pnt. Jefry Wowor · Rp400.000 · "BKU-2026-0103 · 07/10/2026" · no due date · "Pertanggungjawaban uang muka" BKU-2026-0149 · 03/11/2026 · menjadi Belanja · Rp400.000 → Rp0 · 100 % · "Sudah dipertanggungjawabkan".
  - tt1 · Titipan · "Sentralisasi November" · Sinode · Rp2.400.000 · "Dari 4 persembahan · disimpan di Bank BNI ··4821" · "Penyaluran" BKU-2026-0136 · 07/11/2026 · bukan Belanja · Rp1.000.000 → Rp1.400.000 · 42 % · "Sebagian disalurkan".
  - tt2 · Titipan · "Persembahan khusus" · Wilayah · Rp450.000 · "Dari persembahan khusus 9 November · disimpan di Kas" · no entries → Rp450.000 · 0 % · "Belum disalurkan".
  - pb1 · Penggantian biaya · "Alat kebersihan gereja" · Ibu Selvie Kalalo · Rp185.000 · "Nota 12/11/2026 terlampir · belum masuk saldo" · no entries, not checked → Rp185.000 · 0 % · "Belum dibayar".
  - pb2 · Penggantian biaya · "Bensin antar jemput" · Sdr. Rivo Mandagi · Rp120.000 · "Nota 02/11/2026 terlampir" · "Penggantian biaya dibayar" BKU-2026-0134 · 05/11/2026 · Belanja, dicatat satu kali · Rp120.000 → Rp0 · 100 % · "Sudah dibayar".
  - Summaries:
    - Uang Muka: "Sisa belum dipertanggungjawabkan · 2 kasus" Rp1.150.000.
    - Titipan: "Sisa belum disalurkan · 2 kasus" Rp1.850.000.
    - Penggantian biaya: "Belum dibayar · 1 kasus" Rp185.000.
  - These figures are this board's own; WebKewajiban shows a different case list (it adds Konsumsi syukur HUT, and its pb1 is already checked).
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/WebKasus` → "Uang Muka" chip filled. Summary "Sisa belum dipertanggungjawabkan · 2 kasus" and "Rp1.150.000". Three cards; Retret Pemuda's status line is bold. Perjalanan dinas Wilayah is transparent with a `garis` border and a full bar. The right column shows the dashed placeholder.
  2. Click "Panitia Natal" → h2 "Panitia Natal", "Diberikan kepada: Sdr. Rivo Mandagi", "Rp650.000" (34 mono), outlined badge "Sebagian dipertanggungjawabkan", "Jatuh tempo 30/11/2026", bar 57 %. The entries card shows "Uang Muka diberikan" Rp1.500.000 and "Pertanggungjawaban uang muka" with "BKU-2026-0138 · 08/11/2026 · menjadi Belanja" and "− Rp850.000". Buttons: "Catat pertanggungjawaban" (`laut`) and "Catat pengembalian sisa" (outlined).
  3. "Catat pertanggungjawaban" → a panel with a `tinta` border rises in, prefilled "650.000". Type to make "800.000" → the `bata` line "Tidak dapat dilakukan: melebihi sisa Rp650.000. Kelebihan belanja dicatat sebagai Penggantian biaya." and the button turns grey.
  4. Clear the input → the button is grey and no sentence shows. Type "200000" and press "Bukukan pertanggungjawaban" once → the panel closes. A new row "BKU-2026-0150 · 16/11/2026 · menjadi Belanja", "− Rp200.000" rises in. The big figure counts down to "Rp450.000" in about 0.66 s while the bar grows to 70 %. The list card shows Rp450.000.
  5. "Catat pengembalian sisa" → prefilled "450.000". Book → "BKU-2026-0151" "kembali ke Kas". Remainder Rp0, `laut` badge "Sudah dipertanggungjawabkan", due text and buttons gone, line "Sudah dipertanggungjawabkan · tidak ada sisa". The summary reads "· 1 kasus" and "Rp500.000".
  6. Chip "Penggantian biaya", open "Alat kebersihan gereja" → only "Cek klaim · tidak mengubah saldo". Press it → the note reads "Nota 12/11/2026 terlampir · belum masuk saldo · klaim sudah dicek" and the button becomes "Bayar penggantian biaya". Open it → "185.000"; typing changes nothing. "Bukukan pembayaran" → badge "Sudah dibayar", the note loses " · klaim sudah dicek", and the summary reads "Belum dibayar · 0 kasus" over "Rp0".
  7. Chip "Titipan", open "Persembahan khusus" → only the "Terkumpul Rp450.000" row, bar empty, button "Salurkan" → panel button "Bukukan penyaluran".
  8. Breadcrumb → `/WebKewajiban` (it pops back when WebKewajiban opened this page).
  9. `jabatanKosong` on → the banner leads main; the footer names Yanti Sumual.
  10. At 860 px the nav collapses behind "Menu" and the right column wraps under the case list (340 + 24 + 480 = 844 is wider than main's 808 px). At 1280 they sit side by side.
- **Notes**
  - Kind change and case change keep the stale `buka`/`sheet` on the canvas. This mixes labels, for example "Titipan untuk: Sdr. Rivo Mandagi". The recommended fix (clear them) is the only intended deviation; flag it in review.
  - Duplicate No. Bukti: `nomor` starts at 150, but um2 already holds BKU-2026-0150, and Bukti lists the Biasa series only up to 0151. Keep 150 because the board shows it. Record the clash in `docs/build/mock-data.md`.
  - The entry amount is written "− Rp850.000" (minus, space, figure) rather than `rp(−850000)`. It is a deduction marker, not a negative balance; copy the board.
  - The book button has a disabled look with no reason when the amount is empty or 0. This breaks the "reason always shown" rule, but the board shows no sentence. Keep it, and give the disabled state a Semantics hint carrying the same condition, without visible text.
  - Off-token values: h2 20, input 26, radius 7 on the big bar, radius 4 on the small bar.
  - `L.cat` is defined but never shown.

### WebSerahTerima — Web · Serah terima Bendahara
- **Source** `docs/design/handoff/canvas/boards/WebSerahTerima.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebSerahTerima`, no child routes · **Widget** `WebSerahTerimaScreen` in `lib/screens/lengkap/web_serah_terima.dart`
- **Purpose** The Bendahara Jemaat at the desk hands the post to a newly appointed person (journey step 6, "9 · Bendahara, sesi, serah terima"). It is reached from WebPengaturan ("Serah terima Bendahara", in the link row and on the Bendahara card) and WebKeluar (the row "Sesi di perangkat lain"). The board shows:
  - D21: the handover is started by the active Bendahara.
  - The rules of a transfer: all of the old Bendahara's sessions end; approvals are not inherited; Riwayat keeps the old actor; never two active Bendahara.
  - Session management ("Akhiri sesi").
  - The locking state "Belum ada Bendahara aktif" (PitaPeran, `tinta` field), with R04: authority revoked 16/11/2026 08.10.
  - The linked-card line of RangkaianKoreksi used for the handover.
- **Shell** Web side nav, active item **Pengaturan**. The footer is fixed to "**Meiske L.** · Bendahara / Wewenang Bendahara aktif": this board has no `jabatanKosong` switch, and the global switch does not affect it.
- **Layout**
  1. Title block: breadcrumb "Pengaturan" → `/WebPengaturan`; h1 "Serah terima Bendahara".
  2. (only when `keadaan` = "Belum ada Bendahara aktif") **Locking banner**: `tinta` field, radius 14, padding 18/20, column gap 6.
     - "Belum ada Bendahara aktif" 19/700 `permukaan` (off-token 19).
     - 14 `diTinta`: "Wewenang Meiske Lumentut dicabut pada 16/11/2026 08.10 oleh Petugas verifikasi. Semua data hanya dapat dilihat. **Yang perlu bertindak: BPMJ Jemaat Karunia.**" The bold part is `permukaan`.
     - 14 `diTinta`: "Sementara itu, Operator Jemaat dapat [menjalankan jabatan kosong] ini. Setiap tindakannya tercatat atas namanya." The bracketed words are a link, `permukaan` 700, underlined → `/WebJabatanKosong`.
  3. Two-part row: wrap, gap 28, top-aligned.
     a. **Handover chain** (flex 1 1 380, column gap 6):
        - **Old card**: `permukaan`, radius 14, padding 14/16.
          - Border: before the handover 1.5 `tinta` (terpilih); after it 1.5 `tinta3`.
          - Row (space-between, gap 16, centred): "Meiske Lumentut" 700 + badge (13/700, radius 6, padding 3/9, 1.5 border).
            - Before: "Wewenang Bendahara aktif", `laut` field, `laut` border, `diLaut` text.
            - After: "Wewenang berakhir", `permukaan` field, `tinta3` border, `tinta2` text.
          - Sub 13 `tinta3`: before "Tetap aktif sampai Bendahara baru diverifikasi"; after "Berakhir 16/11/2026 · semua sesi diakhiri".
        - **Connector**: 2 × 22 `tinta` bar, 28 px from the left ("linked to").
        - **New card**: radius 14, padding 14/16, column gap 10.
          - Before: transparent field with 1.5 dashed `putus` (draf). After: `permukaan` with 1.5 solid `tinta`.
          - Row: "Bendahara baru" 700 + badge.
            - "Belum dikirim": transparent, 1.5 dashed `putus`, `tinta2`.
            - "Menunggu verifikasi wewenang": same look.
            - "Wewenang Bendahara aktif": `laut` field and border, `diLaut`.
          - Then one of:
            - *belum*:
              - Label "Nama yang ditunjuk" 14 `tinta2`, 6 px below it the text input. The input is full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan`, and starts with "Yohanis Tumbelaka".
              - Line 14 `tinta2`: "Surat penunjukan baru: **SK-BPMJ-09-2026.pdf · Terlampir**" (bold `tinta`).
              - Button "Kirim untuk diverifikasi": start-aligned, min-height 46, padding 0 20, radius 12, 700. `laut`/`diLaut` when the name is not blank, `garis`/`tinta3` when it is.
            - *tunggu*: `role=status` 14: "**{nama}** · menunggu Petugas verifikasi memeriksa surat penunjukan."
            - *aktif*: `role=status` 14: "**{nama}** · aktif sejak 16/11/2026 · SK-BPMJ-09-2026".
     b. **Rules and sessions** (flex 999 1 420, column gap 16):
        - Rules block (column gap 6, 14 `tinta2`):
          - Heading "Yang terjadi saat wewenang berpindah" 15/700 `tinta`.
          - Four lines: "Semua sesi Bendahara lama diakhiri saat itu juga." / "Bendahara baru tidak mewarisi persetujuan yang pernah dicatat Bendahara lama." / "Riwayat tetap mencatat Bendahara lama sebagai pelaku tindakannya." / "Sampai verifikasi selesai, Bendahara lama tetap aktif. Tidak pernah ada dua Bendahara aktif."
        - Sessions block (column gap 8):
          - Heading "Sesi yang sedang masuk · {namaAktif}" 15/700. The source sets 16 and then 15; use 15.
          - Card `permukaan`, 1 px `garis`, radius 14, padding 0 16.
          - Rows: min-height 56, gap 12, a 1 px `garis` top border except on the first.
          - Row text: name 600 over sub 13 `tinta3`.
          - Optional "Akhiri sesi" button: min-height 44, padding 0 12, radius 10, 1.5 `garisTegas`, `permukaan`, 14/700.
        - Footer 13 `tinta3`: "Pemulihan akun mengembalikan akses orang yang sama dan tidak memerlukan penunjukan baru."
- **Components**
  - PitaPeran: the locking banner, as a `tinta` field.
  - RangkaianKoreksi pattern: the two cards joined by the 2 px `tinta` line.
  - LencanaStatus / LencanaModul-style post badges: Aktif `laut` field; a dashed draft badge.
  - TombolBersyarat: Kirim, conditioned on a non-blank name.
  - Tombol: Akhiri sesi.
  - Shared side nav.
  - Pattern: the session list.
- **Internal views and states** Initial state, verbatim: `{ screen: 'utama', tahap: 'belum', nama: 'Yohanis Tumbelaka', sesi: ['Ponsel ini', 'Chrome di laptop'] }`.
  - `tahap`: belum → tunggu (2800 ms) → aktif.
  - Session list: rows from `sesi`; after *aktif*, the single row "Belum ada sesi" / "Semua sesi Meiske Lumentut diakhiri 16/11/2026" with no button.
  - `screen`, `keSerah`, `keUtama`, `isUtama`, `isSerah`, `aktifSejak`, `sudahPindah` and `belumPindah` are defined but never rendered. Ignore them.
- **Tweaks** `keadaan` (enum "Bendahara aktif", "Belum ada Bendahara aktif"; default "Bendahara aktif") · Keadaan panel.
  - "Bendahara aktif": no banner.
  - "Belum ada Bendahara aktif": the locking banner (Layout 2) appears under the title. Nothing else changes: the old card still says "Wewenang Bendahara aktif", the form still works, and the footer still names Meiske L.
- **Interactions**
  - Name input → `nama` = text, as typed.
  - "Kirim untuk diverifikasi" condition: `nama.trim()` is not empty.
    - Re-checked on press, so the first press after typing works.
    - Blank → disabled look and the press does nothing. No reason sentence on the board.
    - Valid → `tahap = 'tunggu'`. Any timer is cancelled, then after 2800 ms (this fakes the Petugas verifikasi on another device) `tahap = 'aktif'`.
  - On *aktif*:
    - The old card's border, badge and sub change. The new card turns solid with the `laut` badge.
    - The heading becomes "Sesi yang sedang masuk · {nama}", and the session list becomes the single "Belum ada sesi" row.
  - "Akhiri sesi" (only on "Chrome di laptop") → removes that row. "Ponsel ini" never has the button.
  - Breadcrumb → up link to `/WebPengaturan`. Banner link → push `/WebJabatanKosong`. Side nav → `go`.
  - There is no way to restart the handover except leaving the board; the state resets on re-entry.
- **Motion** The *aktif* status line: `muncul` 300 ms. Card and badge changes are instant. The 2800 ms timer is cancelled on dispose. Manifest `isi` and `titik` are unused.
- **Links out**
  - Breadcrumb "Pengaturan" → `/WebPengaturan`, up link.
  - Banner "menjalankan jabatan kosong" → `/WebJabatanKosong`, push.
  - Side nav (go): `/WebBeranda`, `/WebTransaksi`, `/WebKewajiban`, `/WebRekonsiliasi`, `/WebTutupBuku`, `/WebPaketLaporan`, `/WebPengaturan`.
  - **Inbound** WebKeluar, WebPengaturan, plus PetaLayar (computed link, `navigation.md` 3.3).
- **Mock data**
  - Old Bendahara: Meiske Lumentut. New appointee: Yohanis Tumbelaka. Letter: SK-BPMJ-09-2026.pdf. Effective 16/11/2026.
  - Revoked 16/11/2026 08.10 by Petugas verifikasi (R04). Who must act: BPMJ Jemaat Karunia.
  - Sessions: "Ponsel ini" / "Sesi ini · aktif sekarang"; "Chrome di laptop" / "Terakhir dipakai 14/11/2026 20.15".
- **Prototype-only** none of the four devices. The 2800 ms auto-verification stands for the Petugas verifikasi and stays (as on Bendahara/Awal). Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/WebSerahTerima` → nav item "Pengaturan" is active. The old card has a `tinta` border and the `laut` badge "Wewenang Bendahara aktif". The connector line shows. The new card is dashed with the dashed badge "Belum dikirim". The input holds "Yohanis Tumbelaka" and the button is `laut`.
  2. Clear the input (or type only spaces) → the button turns `garis`/`tinta3`; pressing does nothing.
  3. Type a name and press "Kirim untuk diverifikasi" once → the badge reads "Menunggu verifikasi wewenang" and the status reads "{nama} · menunggu Petugas verifikasi memeriksa surat penunjukan."
  4. 2.8 s later:
     - old card: border `tinta3`, outlined badge "Wewenang berakhir", "Berakhir 16/11/2026 · semua sesi diakhiri";
     - new card: solid `tinta`, `laut` badge "Wewenang Bendahara aktif", "{nama} · aktif sejak 16/11/2026 · SK-BPMJ-09-2026" rising in;
     - sessions: "Sesi yang sedang masuk · {nama}" with the one row "Belum ada sesi".
  5. Before sending, "Akhiri sesi" on "Chrome di laptop" → the row disappears; "Ponsel ini" remains without a button.
  6. Keadaan `keadaan` = "Belum ada Bendahara aktif" → the `tinta` banner under the title. Its link "menjalankan jabatan kosong" → `/WebJabatanKosong`.
  7. Breadcrumb → `/WebPengaturan`.
  8. Leave during the 2.8 s wait → no late state change.
  9. At 860 px the nav collapses behind "Menu" and the rules-and-sessions column wraps under the handover chain (380 + 28 + 420 = 828 is wider than main's 808 px). At 1280 they sit side by side.
- **Notes**
  - The board contradicts itself under "Belum ada Bendahara aktif": the banner says nobody is active, while the old card and the footer still say Meiske is. Keep it, since the board wins.
  - "Ponsel ini" on a laptop page is the board's session name; keep it.
  - Kirim is disabled with no visible reason. The board has none; add only a Semantics hint.
  - Off-token values: 19 px banner title, radius 10 on "Akhiri sesi".

### KasusBaru — 37 · Kasus baru: Uang Muka, Titipan, Penggantian biaya
- **Source** `docs/design/handoff/canvas/boards/KasusBaru.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/KasusBaru`, no child routes. The result replaces the form in place, under the same header and kind chips; the effect card stays and changes look. **Widget** `KasusBaruScreen` in `lib/screens/lengkap/kasus_baru.dart`
- **Purpose** The Bendahara Jemaat opens a new case (journey step 2). It is reached from Kewajiban "+ Kasus baru", Main's "Catatan lain" chip "Uang Muka, Titipan, klaim", and Keputusan. The board shows:
  - D18: an Uang Muka asks for no Mata Anggaran.
  - D19: a Titipan asks for no peruntukan; only the Mata Anggaran rows allowed for Titipan are listed.
  - D20: every case needs a supporting document, and a missing one blocks month close, not posting.
  - D01: Kas/Bank, peruntukan, Lingkup and due date are never pre-filled.
  - D17: a claim is only saved — "Simpan klaim", "belum masuk saldo".
  - The live effect preview ("Setelah dibukukan") and TombolBersyarat with ordered reasons.
- **Shell** Phone header with back, no tab bar. PitaJabatanKosong strip when on. A fixed action bar sits at the bottom while the form is shown.
- **Layout** The root is a column: the strip, then a relative area that fills the rest. Inside it is an absolute column holding the header, chips, scroll area and action bar.
  0. (only with `jabatanKosong`) Strip.
  1. Header: back → Kewajiban, `aria-label` "Kembali ke Uang yang masih berjalan"; title "Kasus baru"; subtitle "Uang yang masih berjalan".
  2. Kind chips: padding 0 20 4. "Uang Muka", "Titipan", "Penggantian biaya" (shared chip style, 8 px right and bottom margins). They stay visible and active in the result view.
  3. Scroll area: padding 8/20/20, column gap 16.
     - **Form** (only while not done), in order:
       a. Kind note 14 `tinta2` (`k.cat`).
       b. Party field:
          - Label 14 `tinta2` "{k.pihak} **· wajib**" (bold part `tinta`), 6 px below it the text input.
          - Input: full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan`.
          - Placeholder `k.ph`, in `tinta3`.
       c. Amount (IsianJumlah):
          - Label 14 `tinta2` `k.jm`.
          - Row (baseline, gap 6, mono, 2 px `tinta` underline, padding-bottom 4): "Rp" 20 `tinta3`, then the input mono 30/500 (`jumlahIsian`). The input has no border, min-height 44, a numeric keyboard and the placeholder "0" in `tinta3`.
       d. (Uang Muka and Titipan) Kas/Bank: label 14 `tinta2` `k.akun`, 8 px below it three chips: "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107".
       e. (Uang Muka only) "Diambil dari peruntukan" with chips "Umum Jemaat", "Diakonia", "Pembangunan". Then "Lingkup" with chips "Jemaat", "Kolom 3", "BIPRA Pemuda", "Panitia Natal".
       f. (Titipan only) Mata Anggaran list (column gap 8):
          - Label 14 `tinta2` "Mata Anggaran · hanya baris yang boleh untuk Titipan".
          - Two row buttons: full width, min-height 52, padding 6/14, radius 12, gap 12.
          - Each row: the code (mono 13 `tinta2`) and the name (600).
          - Unselected: `permukaan`, 1 px `garisTegas`. Selected: `lautLembut`, 1.5 `laut`.
          - Rows: "2.1.01.02.00 Sentralisasi Sinode", "2.2.01.02.00 Persembahan khusus Wilayah".
       g. Description field: label "{k.ur} **· wajib**", same input style as b, no placeholder.
       h. (Uang Muka only) "Jatuh tempo" chips: "30 November 2026", "15 Desember 2026", "31 Desember 2026".
       i. Document row: 1 px `garis` top border, padding-top 12, space-between, gap 16, centred.
          - Left: "Dokumen pendukung · {k.dok}" 14 `tinta2`; "Wajib, belum ada" 700 `bata`; "Tidak menghalangi pembukuan. Menghalangi tutup buku." 13 `tinta3`.
          - Right: secondary link button "Lampirkan" (flex none, min-height 44, padding 0 16, radius 12, 1.5 `tinta`, no fill (transparent, unlike the other secondary buttons), `tinta` 700, no underline) → Kamera.
     - **Effect card** (always shown): radius 16, padding 16, column gap 8.
       - Border/field: before done, 1.5 dashed `putus` and transparent. After done for Uang Muka and Titipan, 1.5 solid `tinta` and `permukaan`. Penggantian biaya stays dashed and transparent.
       - Header row (space-between): title 700, plus the No. Bukti stamp after done (Uang Muka and Titipan only).
         - Title: "Setelah dibukukan" (um/tt) or "Setelah disimpan" (pb); after done "Dibukukan" (um/tt) or "Tersimpan · belum masuk saldo" (pb).
         - Stamp: mono 14/600 `laut`, 2 px `laut` border, radius 8, padding 4/10: "No. Bukti BKU-2026-0153" (um) or "No. Bukti BKU-2026-0154" (tt).
       - Three effect rows: padding-top 8; a 1 px `garis` top border except on the first; space-between, baseline, gap 16.
         - Left: name 600/15 over sub 13 `tinta3`.
         - Right: value 15/500, flex none. Sans `tinta3` for "tidak berubah"; everything else is mono `tinta`, including the "—" shown when there is no amount.
       - Rows per kind (j = amount, S = balance of the chosen Kas/Bank, nama = the trimmed party or "…"):
         - Uang Muka:
           - "Saldo buku {Kas/Bank name or 'Kas/Bank'}" · "dari {rp(S)} menjadi {rp(S − j)}" or "pilih Kas/Bank" · rp(−j) or "—".
           - "Sisa belum dipertanggungjawabkan" · "atas nama {nama}" · rp(j) or "—".
           - "Belanja bulan ini" · "belum ada Belanja sampai dipertanggungjawabkan" · "tidak berubah".
         - Titipan:
           - "Saldo buku {…}" · "dari {rp(S)} menjadi {rp(S + j)}" or "pilih Kas/Bank" · "+" + rp(j) or "—".
           - "Sisa belum disalurkan" · "Titipan untuk: {nama}" · rp(j) or "—".
           - "Pendapatan bulan ini" · "titipan dihitung terpisah" · "tidak berubah".
         - Penggantian biaya:
           - "Saldo buku semua Kas/Bank" · "klaim belum masuk saldo" · "tidak berubah".
           - "Belum dibayar" · "Dibayar kepada: {nama}" · rp(j) or "—".
           - "Belanja bulan ini" · "dicatat satu kali, saat klaim dibayar" · "tidak berubah".
     - **Result** (only when done), column gap 10:
       - `role=status`: `k.hasil` 17/700 (off-token) over `k.hasilCat` 14 `tinta2`.
       - Case card: radius 14, padding 14/16, column gap 6.
         - Look: `permukaan` with 1 px `garis` (um/tt), or transparent with 1.5 dashed `putus` (pb).
         - Row: the description (trimmed) 700 | rp(j) mono 500.
         - "{k.pihak}: {nama}" 13 `tinta3`.
         - An empty bar: height 8, radius 4, 1.5 dashed `putus` (nothing accounted yet).
         - Status 13/600: `k.st`, plus " · jatuh tempo: {dd/mm/yyyy}" for an Uang Muka.
       - Secondary link "Buka di Uang yang masih berjalan": full width, min-height 48, radius 14, 1.5 `tinta`, `permukaan`, 700, centred → Kewajiban.
       - Text button "Catat kasus lain": min-height 44, `laut` 700, centred.
  4. **Action bar** (only while not done): padding 12 20 22, `permukaan`, 1 px `garis` top border, column gap 8.
     - While unmet: "Belum dapat disimpan: {alasan}" 14 `tinta2`.
     - Button `k.tombol`: full width, min-height 52, radius 14, 700, centred, padding 0 20. `laut`/`diLaut` when the condition is met, `garis`/`tinta3` when not.
  - Per-kind copy (`CFG`):

    | key | Uang Muka | Titipan | Penggantian biaya |
    | --- | --- | --- | --- |
    | pihak | Diberikan kepada | Titipan untuk | Dibayar kepada |
    | ph | Nama penerima uang muka | Contoh: Sinode | Nama yang mengajukan klaim |
    | jm | Jumlah uang muka (Rp) | Jumlah diterima (Rp) | Jumlah klaim (Rp) |
    | akun | Diambil dari Kas/Bank | Masuk ke Kas/Bank | (no field) |
    | ur | Untuk keperluan | Uraian | Yang dibeli |
    | dok | Tanda terima uang muka | Bukti penerimaan titipan | Nota atau kuitansi |
    | cat | Uang muka bukan Belanja saat diberikan. Mata Anggaran dipilih nanti, saat pertanggungjawabannya dicatat. | Uang titipan untuk pihak lain. Bukan Pendapatan saat diterima, dan bukan Belanja saat disalurkan. | Mencatat dan mengecek klaim tidak mengubah saldo. Pembayarannya mencatat Belanja satu kali. |
    | tombol | Periksa dan bukukan | Periksa dan bukukan | Simpan klaim |
    | st | Belum dipertanggungjawabkan | Belum disalurkan | Belum dibayar · klaim belum dicek |
    | hasil | Uang muka dibukukan | Titipan dibukukan | Klaim disimpan · belum masuk saldo |
    | hasilCat | Kasusnya terbuka sampai seluruh uang dipertanggungjawabkan atau dikembalikan. | Kasusnya terbuka sampai seluruh titipan disalurkan kepada yang berhak. | Cek klaim lebih dulu, lalu bayar. Mata Anggaran dipilih saat pembayaran. |

- **Components**
  - ChipPilihan: kind, Kas/Bank, peruntukan, Lingkup, due date.
  - IsianJumlah.
  - PemilihMataAnggaran: a reduced two-row list.
  - TombolBersyarat: the action bar.
  - PanelDokumen: the document row with "Wajib, belum ada".
  - KartuKasus: the result card.
  - Tombol: Lampirkan, Buka di…, Catat kasus lain.
  - PitaJabatanKosong.
  - Pattern: the effect preview card. It is dashed and turns solid with a No. Bukti stamp on posting.
- **Internal views and states** Initial state, verbatim: `{ tab: 'um', pihak: '', jm: '', akun: null, per: null, ling: null, ma: null, ur: '', tempo: null, selesai: false }`.
  - Views: Form (`selesai` false) and Result (`selesai` true), for each of the three kinds.
  - The form adapts: Kas/Bank is hidden for pb; peruntukan, Lingkup and due date are shown only for um; the Mata Anggaran list only for tt.
  - No sheet, no toast.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global): the strip. No copy change.
- **Interactions**
  - Kind chip → reset everything to the initial values with the new `tab`, including `selesai = false`. This works from the result view too, and also when the chip pressed is the one already selected (it clears the form).
  - Party, description: text as typed. They are ignored once done (the form is hidden then anyway).
  - Amount: digits only, leading zeros stripped, at most 11 digits, shown with dot thousands.
  - Chips and Mata Anggaran rows: set their field. There is no deselect: pressing the chosen chip keeps it. They do nothing once done.
  - Condition: the first unmet reason, checked in this order (reason text after "Belum dapat disimpan: "):
    1. party blank (trimmed) → "“{k.pihak}” belum diisi.", with curly quotes, e.g. "“Diberikan kepada” belum diisi.";
    2. amount ≤ 0 or empty → "jumlah belum diisi.";
    3. um/tt with no Kas/Bank → "Kas/Bank belum dipilih.";
    4. um with amount > that Kas/Bank's balance → "melebihi saldo buku {name} ({rp(balance)})." e.g. "melebihi saldo buku Bank SulutGo ··1107 (Rp5.380.000).";
    5. um with no peruntukan → "peruntukan belum dipilih.";
    6. um with no Lingkup → "Lingkup belum dipilih.";
    7. tt with no Mata Anggaran → "Mata Anggaran belum dipilih.";
    8. description blank → "uraian belum diisi.";
    9. um with no due date → "jatuh tempo belum dipilih.".
  - The reason shows from the first frame, on the empty form, as drawn.
  - Press the action button → re-check from the latest input (the first press after typing works). If met, `selesai = true`; otherwise nothing.
  - "Periksa dan bukukan" posts directly; there is no separate Periksa step on this board.
  - "Lampirkan" → push `/Kamera`. Back returns with the form as left.
  - "Buka di Uang yang masih berjalan" → `/Kewajiban`, an up link (pop when Kewajiban is beneath, else `go`).
  - "Catat kasus lain" → reset all fields and `selesai`, keeping `tab`.
  - Back arrow → up link to `/Kewajiban`.
- **Motion**
  - Result block: `muncul` 300 ms when it appears.
  - No. Bukti stamp: `muncul` 400 ms, fill-mode both.
  - Effect card: background transparent → `permukaan` over 300 ms. The border switches from dashed to solid instantly.
  - The form and the action bar disappear at once; only the result block animates in (above).
  - The token motion `tinta` (ink sweep) is not used here; follow the board.
  - Manifest `isi`, `masuk` and `pudar` are unused.
- **Links out** "Lampirkan" → `/Kamera` (push). Back arrow ("Kembali ke Uang yang masih berjalan") → `/Kewajiban` (up link). "Buka di Uang yang masih berjalan" → `/Kewajiban` (up link). **Inbound** Kewajiban ("+ Kasus baru"), Main ("Uang Muka, Titipan, klaim"), Keputusan (rows 18, 19 and 20), plus PetaLayar and Cakupan (computed links, `navigation.md` 3.3).
- **Mock data**
  - Kas/Bank balances (saldo buku): Kas Rp8.420.000; Bank BNI ··4821 Rp24.615.000; Bank SulutGo ··1107 Rp5.380.000.
  - peruntukan: Umum Jemaat, Diakonia, Pembangunan.
  - Lingkup: Jemaat, Kolom 3, BIPRA Pemuda, Panitia Natal.
  - Due dates: 30/11/2026, 15/12/2026, 31/12/2026, shown as "30 November 2026", "15 Desember 2026" and "31 Desember 2026".
  - Titipan Mata Anggaran: 2.1.01.02.00 Sentralisasi Sinode; 2.2.01.02.00 Persembahan khusus Wilayah.
  - No. Bukti: BKU-2026-0153 (Uang Muka) and BKU-2026-0154 (Titipan); none for a claim.
- **Prototype-only** none of the four devices. The Titipan placeholder "Contoh: Sinode" is an input hint, not a "Contoh:" button; keep it. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/KasusBaru` → "Uang Muka" chip filled. The action bar reads "Belum dapat disimpan: “Diberikan kepada” belum diisi." over a grey "Periksa dan bukukan". The effect card is dashed, titled "Setelah dibukukan", with rows "Saldo buku Kas/Bank" / "pilih Kas/Bank" / "—", "Sisa belum dipertanggungjawabkan" / "atas nama …" / "—" (the "…" is literal: no party yet) and "Belanja bulan ini" / "belum ada Belanja sampai dipertanggungjawabkan" / "tidak berubah".
  2. Type the party "Rivo Mandagi" and the amount "6000000" → the amount shows "6.000.000"; the reason becomes "Kas/Bank belum dipilih.". Choose "Bank SulutGo ··1107" → reason "melebihi saldo buku Bank SulutGo ··1107 (Rp5.380.000)."; the first effect row reads "dari Rp5.380.000 menjadi −Rp620.000".
  3. Choose "Kas" → "peruntukan belum dipilih." Then pick Umum Jemaat → "Lingkup belum dipilih." Then Jemaat → "uraian belum diisi." Type the description → "jatuh tempo belum dipilih.". Pick "30 November 2026" → the reason line disappears and the button turns `laut`.
  4. Press "Periksa dan bukukan" once → the form and bar go. The effect card turns solid `tinta` on `permukaan`, titled "Dibukukan", and the stamp "No. Bukti BKU-2026-0153" rises in. "Uang muka dibukukan" shows. The effect rows keep their values ("Saldo buku Kas", "dari Rp8.420.000 menjadi Rp2.420.000", "−Rp6.000.000"). The case card shows the trimmed description and "Rp6.000.000" on one row, then "Diberikan kepada: Rivo Mandagi", an empty dashed bar and "Belum dipertanggungjawabkan · jatuh tempo: 30/11/2026".
  5. "Catat kasus lain" → an empty Uang Muka form.
  6. Chip "Titipan" → placeholder "Contoh: Sinode"; the Mata Anggaran list shows two rows; no peruntukan or Lingkup. A completed Titipan on Bank BNI with 2400000 shows "dari Rp24.615.000 menjadi Rp27.015.000" and "+Rp2.400.000", and the stamp "No. Bukti BKU-2026-0154".
  7. Chip "Penggantian biaya" → no Kas/Bank; button "Simpan klaim". After saving: the effect card stays dashed, titled "Tersimpan · belum masuk saldo", with no stamp. The result is "Klaim disimpan · belum masuk saldo" with a dashed case card "Belum dibayar · klaim belum dicek".
  8. "Lampirkan" → `/Kamera`; Back → the form still holds its input.
  9. Back arrow and "Buka di Uang yang masih berjalan" → `/Kewajiban`.
- **Notes**
  - TombolBersyarat breaches, kept as drawn:
    - the refusal shows on the empty form;
    - its prefix is "Belum dapat disimpan:" in `tinta2`, not "Tidak dapat dilakukan: …" in `bata`.
  - The Mata Anggaran rows show no tree name (PemilihMataAnggaran asks for one); keep the board.
  - The No. Bukti is fixed per kind, so a second case after "Catat kasus lain" gets the same 0153/0154. Prototype only; note it in `mock-data.md`.
  - Off-token values: 17 px result title, 20 px "Rp", radius 8 on the stamp.

### WebKasusBaru — Web · Kasus baru: Uang Muka, Titipan, Penggantian biaya
- **Source** `docs/design/handoff/canvas/boards/WebKasusBaru.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1200) · interactive yes
- **Route** `/WebKasusBaru`, no child routes · **Widget** `WebKasusBaruScreen` in `lib/screens/lengkap/web_kasus_baru.dart`
- **Purpose** The laptop pair of KasusBaru, reached from WebKewajiban "+ Kasus baru". It shows the same decisions: D18, D19, D20, D01, D17, TombolBersyarat.
- **Shell** Web side nav, active item **Uang Muka dan Titipan**. Footer switches with `jabatanKosong`. Web banner when on.
- **Layout**
  1. (only with `jabatanKosong`) web banner.
  2. Title block: breadcrumb "Uang Muka dan Titipan" → `/WebKewajiban`; h1 "Kasus baru"; then 14 `tinta2` "Memberi uang muka, menerima titipan, atau mencatat klaim penggantian biaya."
  3. Kind chips (same three, with 8 px right and bottom margins).
  4. Two-part row: wrap, gap 24, top-aligned.
     a. **Form column** (flex 999 1 440, column gap 16): KasusBaru form items a–i with identical copy and styles.
        - The form stays visible after posting, with its values. It is frozen: typing and chip presses are ignored. Make the inputs read-only when done.
        - "Lampirkan" goes to `/WebDokumen` instead of Kamera. It stays a working link after posting.
     b. **Aside** (flex 1 1 380, column gap 14):
        - The effect card (as KasusBaru).
        - While not done: the reason line "Belum dapat disimpan: {alasan}" 14 `tinta2`, then the action button. The button is full aside width, min-height 52, radius 14, 700, `laut`/`diLaut` or `garis`/`tinta3`.
        - When done: the result block (status, case card, "Buka di Uang yang masih berjalan" → `/WebKewajiban`, "Catat kasus lain").
- **Components** Same as KasusBaru, with the web PitaJabatanKosong and the shared side nav.
- **Internal views and states** Initial state identical to KasusBaru. Form + aside (not done), and frozen form + aside result (done).
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global): banner and footer. No copy change.
- **Interactions** Identical to KasusBaru (same handlers, condition order and reasons), with these differences:
  - "Lampirkan" → push `/WebDokumen`.
  - "Buka di Uang yang masih berjalan" → `/WebKewajiban`, up link.
  - Breadcrumb → up link to `/WebKewajiban`.
  - Side nav → `go`.
- **Motion** Same as KasusBaru: result `muncul` 300 ms, stamp `muncul` 400 ms (both), effect-card background 300 ms. Manifest `isi` and `titik` are unused.
- **Links out**
  - "Lampirkan" → `/WebDokumen` (push).
  - "Buka di Uang yang masih berjalan" → `/WebKewajiban` (up link, as on KasusBaru).
  - Breadcrumb "Uang Muka dan Titipan" → `/WebKewajiban` (up link).
  - Side nav (go): `/WebBeranda`, `/WebTransaksi`, `/WebKewajiban`, `/WebRekonsiliasi`, `/WebTutupBuku`, `/WebPaketLaporan`, `/WebPengaturan`.
  - **Inbound** WebKewajiban ("+ Kasus baru"), plus PetaLayar (computed link, `navigation.md` 3.3).
- **Mock data** Same as KasusBaru.
- **Prototype-only** none (the "Contoh: Sinode" placeholder stays). Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/WebKasusBaru` at 1280 → the form is on the left, and the dashed "Setelah dibukukan" card with the reason "Belum dapat disimpan: “Diberikan kepada” belum diisi." and a grey button is on the right.
  2. Fill an Uang Muka (party, 500000, Kas, Umum Jemaat, Jemaat, description, 15 Desember 2026) → the first effect row reads "Saldo buku Kas · dari Rp8.420.000 menjadi Rp7.920.000 · −Rp500.000", and the button turns `laut`.
  3. Press once → the aside shows "Dibukukan", the stamp "No. Bukti BKU-2026-0153", "Uang muka dibukukan" and the case card "… · jatuh tempo: 15/12/2026". The form stays on the left with its values; typing into it changes nothing.
  4. Chip "Titipan" → the form resets; the Mata Anggaran list appears.
  5. "Lampirkan" → `/WebDokumen`; Back returns with the input intact.
  6. At 860 px the nav collapses behind "Menu" and the aside wraps under the form.
  7. `jabatanKosong` on → the banner leads main; the footer names Yanti Sumual.
- **Notes**
  - Same TombolBersyarat breaches as KasusBaru.
  - The web form does not hide after posting, unlike the phone; keep each board.
  - The preview height is 1200 (taller than the other web boards).

### Sambungan — 38 · Sambungan terputus dan sesi berakhir
- **Source** `docs/design/handoff/canvas/boards/Sambungan.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Sambungan`, no child routes. The session-ended view is a tweak state, not a navigation target. **Widget** `SambunganScreen` in `lib/screens/lengkap/sambungan.dart`
- **Purpose** Any finance user, shown with the Bendahara: the general states "offline" and "session ended" (journey "Anyone", item 4; finance journey step 6). The board shows:
  - D35: offline, the input stays on screen and nothing is stored on the device to send later.
  - StatusSimpan: "Mencoba menyimpan lagi…", Coba lagi never creates a second draft or a No. Bukti, and saved means saved once.
  - Rangka's offline rule: what is shown stays readable.
  - The three ways a session ends, including D21's consequence: on a transfer of authority all of the old Bendahara's sessions end and there is no "Masuk lagi".
- **Shell** Form view: phone header with back, no tab bar, a fixed action bar. Session view: no header, no back control. No `jabatanKosong` on this board.
- **Layout** The root is 390 × 844, `kertas`, and is not a flex column. Each view is an absolute layer filling it.
  - **Form view** (`keadaan` = "Tidak ada sambungan"):
    1. Header: back → Main, `aria-label` "Kembali ke Beranda"; title "Belanja" (no subtitle).
    2. Scroll area: padding 8/20/20, column gap 16.
       a. *putus* only — **offline banner**, `role=alert` (hambatan): `bataLembut` field, 1.5 `bata` border, radius 14, padding 14/16, column gap 4.
          - Row (gap 10, centred): wifi-off icon 22 px (stroke `bata` 2, round caps, paths `M2 8.5a15 15 0 0 1 20 0M5.5 12a10 10 0 0 1 13 0M9 15.5a5 5 0 0 1 6 0M3 3l18 18` plus a filled `bata` circle at 12,19 r 1), then "Tidak ada sambungan" 16/700.
          - 14 `tinta2`: "Palakat bekerja hanya saat tersambung. Isian di bawah belum tersimpan, dan tetap ada selama layar ini terbuka."
          - When n > 1: 14/700 `bata` "Masih belum tersambung · percobaan ke-{n}".
       b. *coba* only — **retry card**, `role=status`: `permukaan`, 1 px `garis`, radius 14, padding 14/16, column gap 10.
          - "Mencoba menyimpan lagi…" 700.
          - Bar: height 6, radius 3, `garis` track, `laut` fill growing 0→100 % linearly over 1600 ms.
          - 13 `tinta3`: "Percobaan ulang tidak membuat draf kedua dan tidak membuat No. Bukti."
       c. *simpan* only — **saved banner**, `role=status`: `lautLembut`, radius 14, padding 14/16. "Tersambung lagi. Draf tersimpan." 700, then 14 `tinta2` "Tersimpan satu kali. Tidak ada salinan ganda dari percobaan sebelumnya."
       d. **Draft card** (always): `permukaan`, radius 16, padding 18, column gap 6.
          - Border: 1.5 dashed `putus` before saving; 1.5 solid `tinta` after.
          - Badge: start-aligned, 13/700 `tinta2`, radius 6, padding 3/9, with the same border as the card. Text "{lencana} · Draf · belum masuk saldo", where lencana = "Belum tersimpan" / "Mencoba menyimpan lagi…" / "Tersimpan".
          - "−Rp85.000" mono 30/500 `tinta2`.
          - "Air minum untuk rapat" 600.
          - 13 `tinta3`: "Kas · diambil dari peruntukan Umum Jemaat · Lingkup Jemaat · 16 November 2026".
          - 13 `tinta3`: "Belanja 5.04.01.00 Konsumsi rapat".
       e. Not *simpan* — **waiting note** (column gap 6): "Menunggu sambungan" 15/700 (the source sets 16 then 15; use 15), then 14 `tinta2` "Simpan sebagai draf, Periksa dan bukukan, dan melampirkan dokumen pendukung. Semuanya berjalan di server, jadi tidak ada yang dibukukan dari perangkat ini saja."
    3. **Action bar**: padding 12 20 22, `permukaan`, 1 px `garis` top border, column gap 8.
       - *putus*: "Coba lagi". Full width, min-height 52, radius 14, `tinta` field, `permukaan` text, 700, centred.
       - *coba*: the same button, disabled, labelled "Mencoba menyimpan lagi…", in `garis` with `tinta3` text.
       - *simpan*: primary link "Periksa dan bukukan" (`laut`/`diLaut`, min-height 52, radius 14, centred) → Main.
  - **Session view** (any "Sesi berakhir: …"): fades in with `pudar` 250 ms. It is a column centred vertically, padding 0 28, gap 20. Horizontally everything starts at the left padding: the 56 px icon does not stretch or centre, and the text is left-aligned.
    1. Lock icon 56 × 56:
       - circle r 26 at 28,28, 2 px dashed 5 5 `putus`;
       - body rect 18,26, 20 × 15, rx 3, filled `tinta`;
       - shackle `M22 26v-4a6 6 0 0 1 12 0v4`, stroke `tinta` 2.5.
    2. h1 `{sJudul}` 24/700, line-height 1.2, 6 px bottom margin; then `{sCat}` 15 `tinta2`.
    3. Two lines (column gap 6, 14 `tinta2`): "**Tetap aman:** semua yang sudah dibukukan dan draf yang sudah tersimpan." / "**Tidak ikut tersimpan:** isian yang belum tersimpan di perangkat ini." The bold labels are `tinta`.
    4. Either the primary link "Masuk lagi" (full width, min-height 52, radius 14, `laut`/`diLaut`) → Masuk, or (authority moved) a box with 1.5 dashed `putus`, radius 14, padding 14/16, 14 `tinta`: "Anda tidak lagi memegang wewenang Bendahara Jemaat Karunia. Riwayat tetap mencatat tindakan Anda. Bila ini keliru, yang dapat membantu adalah BPMJ Jemaat Karunia."
- **Components**
  - StatusSimpan: the offline banner as its "Gagal" form, the "Mencoba menyimpan lagi…" card, Tersimpan, and "Coba lagi".
  - GarisStatus: the draft card, dashed → solid.
  - LencanaStatus-style badge.
  - Tombol: Coba lagi, Periksa dan bukukan, Masuk lagi.
  - PitaPeran-style dashed note (authority moved).
  - Patterns: the wifi-off icon and the session-ended lock icon (icon inventory entries 22 and 23).
- **Internal views and states** Initial state `{ st: 'putus', n: 1 }`.
  - Form view sub-states: *putus* (offline; n = attempt counter), *coba* (retrying, 1600 ms), *simpan* (saved).
  - Session view: three variants from the tweak.
  - The form state is kept while the tweak shows the session view, and returns when the tweak goes back.
- **Tweaks** Both in the Keadaan panel.
  - `keadaan` (enum; default "Tidak ada sambungan"):
    - "Tidak ada sambungan": the form view.
    - "Sesi berakhir: lama tidak dipakai": session view, h1 "Sesi Anda berakhir", "Aplikasi mengakhiri sesi yang lama tidak dipakai.", "Masuk lagi".
    - "Sesi berakhir: diakhiri dari perangkat lain": h1 "Sesi di perangkat ini diakhiri", "Diakhiri oleh Meiske L. dari perangkat lain, 16/11/2026 11.40.", "Masuk lagi".
    - "Sesi berakhir: wewenang berpindah": h1 "Sesi Anda berakhir", "Wewenang Bendahara berpindah pada 16/11/2026. Semua sesi Bendahara lama diakhiri saat itu juga.", no "Masuk lagi", the dashed authority box instead.
  - `sambunganKembali` (boolean, default true): whether the retry succeeds. On: *coba* → *simpan*. Off: *coba* → *putus* with n + 1. The value is read at the moment "Coba lagi" is pressed.
  - Board action **"Ulangi contoh"**: on the canvas this is a text button (min-height 44, `laut` 700, centred) under "Periksa dan bukukan" in *simpan*. It exists only to replay the demo, so per CONVENTIONS it moves to the Keadaan panel as a labelled action. It sets `st = 'putus'` and `n = 1`. In the panel it can be pressed during *coba*, which the board never allows, so it also cancels a running retry timer. It is not drawn in the screen.
- **Interactions**
  - "Coba lagi" (only in *putus*) → `st = 'coba'`. After 1600 ms (this fakes the reconnect-and-save attempt): if `sambunganKembali`, then `st = 'simpan'`; otherwise `st = 'putus'` and `n = n + 1`. Cancel on dispose.
  - The disabled "Mencoba menyimpan lagi…" button does nothing.
  - "Periksa dan bukukan" → push `/Main`.
  - Back arrow → up link to `/Main`.
  - "Masuk lagi" → `go('/Masuk')`. Signing in again starts a fresh stack.
  - The draft card is not pressable; nothing in it is editable on this board.
- **Motion**
  - Retry bar: `isi` 1600 ms linear, fill-mode both. It runs once per attempt and stands for the timer.
  - Saved banner: `muncul` 300 ms.
  - Session view: `pudar` 250 ms when it appears.
  - Draft card border (`transition: border .3s`): the line colour animates `putus` → `tinta` over 300 ms; the dash pattern swaps from dashed to solid at once, because border style does not animate (`motion.md`, CSS transitions). The badge border has no transition and swaps instantly.
  - Banners swap instantly otherwise.
  - Reduce motion: the bar shows full at once, but the 1600 ms timer still runs.
  - Manifest `masuk` is unused.
- **Links out**
  - Back arrow ("Kembali ke Beranda") → `/Main` (up link).
  - "Periksa dan bukukan" → `/Main` (push).
  - "Masuk lagi" → `/Masuk` (go).
  - **Inbound** Keputusan (row 35), plus PetaLayar and Cakupan (computed links, `navigation.md` 3.3).
- **Mock data**
  - Draft: −Rp85.000 "Air minum untuk rapat", Kas, peruntukan Umum Jemaat, Lingkup Jemaat, 16 November 2026, Belanja 5.04.01.00 Konsumsi rapat.
  - Session ended by Meiske L. from another device at 16/11/2026 11.40.
  - Authority moved on 16/11/2026.
  - Church: Jemaat Karunia; helper: BPMJ Jemaat Karunia.
- **Prototype-only** "Ulangi contoh" → Keadaan panel action (see Tweaks). Keadaan panel: `keadaan`, `sambunganKembali`, "Ulangi contoh".
- **Acceptance checks**
  1. Open `/Sambungan` → `bataLembut` banner "Tidak ada sambungan" with the wifi-off icon; dashed draft card with badge "Belum tersimpan · Draf · belum masuk saldo" and "−Rp85.000"; "Menunggu sambungan" note; a `tinta` "Coba lagi" in the bar.
  2. Press "Coba lagi" → the banner is replaced by the "Mencoba menyimpan lagi…" card, whose bar fills linearly over 1.6 s. The badge reads "Mencoba menyimpan lagi… · Draf · belum masuk saldo" and the bar button is grey and disabled.
  3. With `sambunganKembali` on, after 1.6 s → the `lautLembut` banner "Tersambung lagi. Draf tersimpan." rises in. The card edge turns solid `tinta` and the badge reads "Tersimpan · Draf · belum masuk saldo". The waiting note is gone, and the bar shows `laut` "Periksa dan bukukan". No "Ulangi contoh" button is drawn on screen.
  4. Keadaan "Ulangi contoh", then `sambunganKembali` off, then "Coba lagi" → after 1.6 s the offline banner returns with bold `bata` "Masih belum tersambung · percobaan ke-2". Retrying gives "ke-3".
  5. `keadaan` "Sesi berakhir: diakhiri dari perangkat lain" → the form disappears and the lock view fades in: "Sesi di perangkat ini diakhiri", "Diakhiri oleh Meiske L. dari perangkat lain, 16/11/2026 11.40.", "Masuk lagi".
  6. `keadaan` "Sesi berakhir: wewenang berpindah" → no "Masuk lagi"; the dashed box "Anda tidak lagi memegang wewenang …" shows.
  7. "Masuk lagi" → `/Masuk`. "Periksa dan bukukan" → `/Main`.
  8. Leave during a retry → no late state change.
- **Notes**
  - The offline "Coba lagi" uses a `tinta` field. Tombol lists "Coba lagi" on `bata` with `diBata`; keep the board.
  - The saved draft gets a solid `tinta` (terpilih) edge although it is still a Draf, which `draf` says should be dashed. Keep it: it marks "this one is saved".
  - Off-token values: 24 px session title, 15 px session caption.
  - The board's timer is not cleared on unmount; cancel it.

### WebSambungan — Web · Sambungan terputus dan sesi berakhir
- **Source** `docs/design/handoff/canvas/boards/WebSambungan.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebSambungan`, no child routes · **Widget** `WebSambunganScreen` in `lib/screens/lengkap/web_sambungan.dart`
- **Purpose** The laptop pair of Sambungan: offline while recording a transaction, and the three session-ended variants (D35, StatusSimpan, D21).
- **Shell** Web side nav, active item **Transaksi**. The footer is fixed to "**Meiske L.** · Bendahara / Wewenang Bendahara aktif" (no `jabatanKosong` on this board). The side nav stays visible and working in the session view as well.
- **Layout**
  - **Form view**:
    1. Title block: breadcrumb "Transaksi" → `/WebTransaksi`; h1 "Catat transaksi".
    2. Content column: max-width 640, column gap 16. It holds, in order, the offline banner, retry card, saved banner, draft card and waiting note, exactly as Sambungan form view 2a–2e (same copy, styles and states).
    3. Button row (wrap, gap 8, centred vertically), as the last item of the column, not a fixed bar:
       - *putus*: "Coba lagi" (min-height 52, padding 0 20, radius 14, `tinta` field, `permukaan` text, 700);
       - *coba*: the disabled grey "Mencoba menyimpan lagi…";
       - *simpan*: the primary link "Periksa dan bukukan" (`laut`/`diLaut`, min-height 52, padding 0 20, radius 14) → `/WebCatat`.
  - **Session view** (no breadcrumb or h1 in main): a centred wrapper fills main (flex 1, centred both ways, padding 40/0).
    - Card: width 100 %, max 460, `permukaan`, 1 px `garis`, radius 18 (off-token; the source sets 14 then 18), padding clamp(24, 4vw, 40), column gap 20.
    - Contents identical to Sambungan session view 1–4. "Masuk lagi" → `/WebMasuk`.
    - No entry animation.
- **Components** Same as Sambungan, with the shared side nav.
- **Internal views and states** Identical to Sambungan: initial `{ st: 'putus', n: 1 }`; *putus*, *coba*, *simpan*; three session variants.
- **Tweaks** `keadaan` (same four options, default "Tidak ada sambungan") and `sambunganKembali` (boolean, default true) · Keadaan panel. Same effects as Sambungan. The board action "Ulangi contoh" moves to the Keadaan panel, as on Sambungan.
- **Interactions**
  - "Coba lagi" → *coba*, then after 1600 ms *simpan* or *putus* with n + 1 (by `sambunganKembali` at press time).
  - "Periksa dan bukukan" → push `/WebCatat`.
  - Breadcrumb → up link to `/WebTransaksi`.
  - "Masuk lagi" → `go('/WebMasuk')`.
  - Side nav → `go`.
- **Motion** Retry bar `isi` 1600 ms linear. Saved banner `muncul` 300 ms. Draft border as on Sambungan: colour `putus` → `tinta` over 300 ms, dash pattern swaps at once. Session view appears without animation (the web board has no `pudar`). Manifest `titik` is unused.
- **Links out**
  - Breadcrumb "Transaksi" → `/WebTransaksi`.
  - "Periksa dan bukukan" → `/WebCatat` (push).
  - "Masuk lagi" → `/WebMasuk` (go).
  - Side nav (go): `/WebBeranda`, `/WebTransaksi`, `/WebKewajiban`, `/WebRekonsiliasi`, `/WebTutupBuku`, `/WebPaketLaporan`, `/WebPengaturan`.
  - **Inbound** none in the manifest. PetaLayar and Cakupan link here (computed links, `navigation.md` 3.2 and 3.3), and the launcher (`/`) lists it.
- **Mock data** Same as Sambungan.
- **Prototype-only** "Ulangi contoh" → Keadaan panel action. Keadaan panel: `keadaan`, `sambunganKembali`, "Ulangi contoh".
- **Acceptance checks**
  1. Open `/WebSambungan` → nav "Transaksi" active, breadcrumb "Transaksi", h1 "Catat transaksi", offline banner and dashed draft card in a column no wider than 640, "Coba lagi" as an inline button.
  2. "Coba lagi" → retry card with a 1.6 s linear bar, then (default) "Tersambung lagi. Draf tersimpan.", solid draft edge, and the `laut` "Periksa dan bukukan".
  3. `sambunganKembali` off → after a retry, "Masih belum tersambung · percobaan ke-2".
  4. `keadaan` "Sesi berakhir: lama tidak dipakai" → breadcrumb and form gone; a white card with radius 18, centred in main, with "Sesi Anda berakhir", "Aplikasi mengakhiri sesi yang lama tidak dipakai." and "Masuk lagi". The side nav is still shown.
  5. `keadaan` "Sesi berakhir: wewenang berpindah" → the dashed authority box, no "Masuk lagi".
  6. "Masuk lagi" → `/WebMasuk`. "Periksa dan bukukan" → `/WebCatat`. Breadcrumb → `/WebTransaksi`.
  7. At 860 px the nav collapses behind "Menu"; the session card stays centred and fits.
- **Notes**
  - The side nav stays live after the session has ended. That is odd for an ended session, but it is the board; keep it.
  - The breadcrumb label "Transaksi" leads to WebTransaksi while "Periksa dan bukukan" leads to WebCatat; keep both.

### Kamera — 39 · Foto dokumen pendukung
- **Source** `docs/design/handoff/canvas/boards/Kamera.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Kamera` (view *bidik*, the camera) plus child routes `/Kamera/tinjau` (review the shot) and `/Kamera/unggah` (the light "Dokumen pendukung" page covering the *unggah*, *gagal* and *lampir* states) · **Widget** `KameraScreen` in `lib/screens/lengkap/kamera.dart` (the child routes render their views from the same file; the board state is shared through the ShellRoute, see shared notes)
- **Purpose** The Bendahara Jemaat photographs the supporting document of BKU-2026-0143 "Sewa sound system" (journey step 2, "19 · Dokumen pendukung"). It is reached from Dokumen, KasusBaru ("Lampirkan") and Koreksi. The board shows:
  - Upload always looks in progress, and success is shown only after it happens (Gerak rule).
  - Uploaded is not verified: "Terlampir bukan terverifikasi."
  - Month close waits for Terverifikasi or Dikecualikan (D02).
  - "Gagal diunggah" in `bata` with a next step that never duplicates (PanelDokumen).
  - Multi-page documents ("Tambah halaman").
  - D07: "Lihat file dan verifikasi" opens the file inside the app (LihatDokumen).
  - `bayanganMelayang`, the only shadow, on the floating receipt.
- **Shell**
  - *bidik* and *tinjau*: a dark full screen (`tinta` field, `permukaan` text and icons). *bidik* has a header with back; *tinjau* has none.
  - `/Kamera/unggah`: phone header with back, no tab bar, a fixed action bar.
  - No `jabatanKosong` on this board.
- **Layout**
  - **Receipt** (shared widget, used in *bidik* and *tinjau*):
    - Paper 230 wide, field #FBFAF6 (allowed literal), `tinta` text, padding 18/16, mono 13, line-height 1.55.
    - Shadow `bayanganMelayang` (0 12 32 rgba(0,0,0,.4)).
    - Lines:
      - "CV NADA PRIMA" centred 600;
      - "Jl. Sam Ratulangi 14" centred;
      - a 1 px dashed `tinta3` rule (margin 8/0);
      - rows (space-between, gap 8) "Sewa sound system" | "" and "1 hari" | "600.000";
      - a dashed rule;
      - "TOTAL" | "Rp600.000" 600;
      - "11/11/2026" (margin-top 8);
      - "LUNAS".
  - ***bidik*** (`/Kamera`):
    1. Header (padding 14 12 8, gap 8):
       - Back target 44 × 44 with the chevron in `permukaan`, `aria-label` "Kembali ke Dokumen pendukung".
       - Title "Foto dokumen pendukung" 18/700 `permukaan`.
       - Subtitle 13 `diTinta2`: "BKU-2026-0143" (mono) + " · Sewa sound system · Rp600.000".
    2. Viewfinder (fills the rest, centred): a box with padding 26/30.
       - Four corner brackets 26 × 26 with 3 px `permukaan` lines: top-left uses top+left, top-right top+right, bottom-left bottom+left, bottom-right bottom+right.
       - Inside: the receipt, rotated −3°.
    3. Hint 14 `diTinta`, centred, padding 0 24: "Pastikan jumlah, tanggal dan nama penerima terbaca."
    4. Control row (padding 20 28 30, space-between, centred):
       - Text button "Pilih file": min-height 44, min-width 88, no fill or border, `permukaan` 700, text left-aligned in its 88 px.
       - Shutter: 76 × 76 circle, 4 px `permukaan` ring, transparent, 5 px padding, inner filled `permukaan` disc. Semantics "Ambil foto".
       - "Halaman {hal}": 13 `diTinta2`, min-width 88, right-aligned.
  - ***tinjau*** (`/Kamera/tinjau`):
    1. Header block (padding 22 20 8): "Terbaca dengan jelas?" 18/700, then 13 `diTinta2` "Foto yang buram akan ditolak saat verifikasi."
    2. Centre (fills the rest): the receipt scaled 1.25, not rotated.
    3. Buttons (padding 16 20 26, column gap 8):
       - "Pakai foto ini": min-height 52, radius 14, `permukaan` field, `tinta` text, 700. This is the primary on the dark screen.
       - "Ulangi": min-height 48, radius 14, transparent, 1.5 `permukaan` border, `permukaan` text, 700.
    4. Flash overlay: full screen, `permukaan` (white), ignores pointers, `kilat` (see Motion).
  - ***unggah / gagal / lampir*** (`/Kamera/unggah`, `kertas` page):
    1. Header: back → Dokumen ("Kembali ke Dokumen pendukung"), chevron `tinta`; title "Dokumen pendukung"; subtitle 13 `tinta2` "BKU-2026-0143 · Sewa sound system".
    2. Scroll area: padding 8/20/20, column gap 16.
       a. File card: `permukaan`, 1 px `garis`, radius 14, padding 14/16, row gap 14, centred.
          - Thumbnail 44 × 56: #FBFAF6 field, 1 px `garisTegas`, radius 4, padding 0 7. It holds a column of four 2 px lines, gap 4, centred: `tinta` full width; `putus` full; `putus` 70 %; `tinta` 50 % aligned right.
          - Text: "nota-sewa-sound-{hal}.jpg" mono 14/600, then 13 `tinta3` "1,2 MB · halaman {hal}".
       b. *unggah* — `role=status`, column gap 8:
          - "Sedang diunggah…" 700.
          - Bar: height 6, radius 3, `garis` track, `laut` fill 0→100 % linear over 1500 ms.
          - 13 `tinta3`: "Belum terlampir sampai selesai."
       c. *gagal* — `role=alert`, column gap 6:
          - "Gagal diunggah" 20/700 `bata`.
          - 14 `tinta2`: "File belum terlampir, dan dokumen pendukung masih “Wajib, belum ada”. Coba lagi tidak membuat salinan ganda."
       d. *lampir* — `role=status`, column gap 6:
          - "Dokumen pendukung · {hal} file terlampir" 14 `tinta2`.
          - "Diunggah, belum diverifikasi" 20/700 `bata`.
          - 14 `tinta2`: "Terlampir bukan terverifikasi. Tutup buku menunggu Terverifikasi atau Dikecualikan."
    3. Action bar (padding 12 20 22, `permukaan`, 1 px `garis` top border, column gap 8):
       - *unggah*: empty (the white bar stays, with its padding).
       - *gagal*: "Coba lagi" (full width, min-height 52, radius 14, `tinta` field, `permukaan` text, 700).
       - *lampir*: primary link "Lihat file dan verifikasi" (`laut`/`diLaut`, min-height 52, radius 14) → LihatDokumen; then secondary "Tambah halaman" (min-height 48, radius 14, 1.5 `tinta`, `permukaan`, `tinta` 700).
- **Components**
  - PanelDokumen: the file row, upload progress, Gagal diunggah, and Diunggah, belum diverifikasi.
  - Tombol: Pakai foto ini, Ulangi, Coba lagi, Lihat file…, Tambah halaman.
  - Patterns that are not components: the camera viewfinder (corner brackets and shutter), the receipt paper (one widget, used twice), and the document thumbnail.
- **Internal views and states** Initial state, verbatim: `{ st: 'bidik', hal: 1, sudahCoba: false }`.
  - `st` ∈ bidik, tinjau, unggah, gagal, lampir.
  - Mapping to routes: bidik → `/Kamera`; tinjau → `/Kamera/tinjau`; unggah, gagal and lampir → `/Kamera/unggah`.
  - `hal` (page number) and `sudahCoba` (an upload has been attempted) live in the shared board state.
- **Tweaks** `gagalUnggah` (boolean, default false) · Keadaan panel.
  - Off: every upload succeeds.
  - On: the first upload attempt of this board visit fails (*gagal*); every later attempt succeeds, including after "Tambah halaman".
- **Interactions**
  - "Pilih file" or the shutter ("Ambil foto") → `st = 'tinjau'`: push `/Kamera/tinjau`. "Pilih file" fakes choosing a file the same way.
  - "Ulangi" → `st = 'bidik'`: pop to `/Kamera`. System Back from *tinjau* does the same.
  - "Pakai foto ini" → upload: `st = 'unggah'`, replacing `/Kamera/tinjau` with `/Kamera/unggah` (pushReplacement). After 1500 ms (this fakes the upload): `st = (gagalUnggah && !sudahCoba) ? 'gagal' : 'lampir'` and `sudahCoba = true`. Both values are read at press time.
  - "Coba lagi" (*gagal*) → the same upload again, on the same route.
  - "Tambah halaman" (*lampir*) → `hal = hal + 1`, `st = 'bidik'`: pop to `/Kamera`, which now shows "Halaman 2". The next upload shows "nota-sewa-sound-2.jpg", "1,2 MB · halaman 2" and "2 file terlampir". Only the latest file card is shown.
  - "Lihat file dan verifikasi" → push `/LihatDokumen`.
  - Back arrow (in *bidik* and on `/Kamera/unggah`) → leave the board towards `/Dokumen`. Pop the Kamera routes; if `/Dokumen` (or `/Dokumen/rinci`) is then on top, stop there; otherwise `go('/Dokumen')`.
  - System Back from `/Kamera/unggah` returns to *bidik* and cancels a running upload timer.
  - Cancel the 1500 ms timer when the board is disposed.
- **Motion**
  - *tinjau*:
    - On entry, the flash overlay runs `kilat` 350 ms, ease-out, fill both: opacity 0.9 → 0.
    - At the same time the receipt runs `muncul` 300 ms (opacity 0→1, y +8→0).
    - The route change itself is instant (no page transition), so the flash carries the motion.
  - Upload bar: `isi` 1500 ms linear, fill both.
  - *lampir* status block: `muncul` 300 ms.
  - `/Kamera/unggah` entry: instant.
  - The source's `transform .25s` transition on the receipt never fires: the two receipts are separate elements. Do not animate rotate→scale.
  - Reduce motion: no flash, the bar shows full at once, and the 1500 ms timer still runs.
  - Manifest `masuk` and `pudar` are unused.
- **Links out**
  - Back arrow ("Kembali ke Dokumen pendukung", in two views) → `/Dokumen`.
  - "Lihat file dan verifikasi" → `/LihatDokumen` (push).
  - **Inbound** Dokumen ("Foto dengan kamera"), KasusBaru ("Lampirkan"), Koreksi ("Lampirkan dokumen pendukung", two places), plus PetaLayar and Cakupan (computed links, `navigation.md` 3.3).
- **Mock data**
  - Transaction BKU-2026-0143 · Sewa sound system · Rp600.000 (Bukti lists it as "wajib, belum ada").
  - Receipt: CV NADA PRIMA, Jl. Sam Ratulangi 14, "Sewa sound system", "1 hari" 600.000, TOTAL Rp600.000, 11/11/2026, LUNAS.
  - File "nota-sewa-sound-{hal}.jpg", 1,2 MB.
- **Prototype-only** none of the four devices. "Pilih file" fakes the file picker by reusing the shot, and the 1500 ms timer stands for the upload; both stay. Keadaan panel: `gagalUnggah`.
- **Acceptance checks**
  1. Open `/Kamera` → a dark screen: "Foto dokumen pendukung", subtitle with "BKU-2026-0143" in mono, a receipt tilted −3° with a shadow inside four white corner brackets, the hint line, "Pilih file", a white ring shutter and "Halaman 1".
  2. Tap the shutter → `/Kamera/tinjau`. A white flash fades out over 0.35 s; the receipt, enlarged 1.25× and upright, rises in. "Terbaca dengan jelas?" and the white "Pakai foto ini".
  3. "Ulangi" (or system Back) → back to the camera, still "Halaman 1".
  4. "Pakai foto ini" → `/Kamera/unggah`: file card "nota-sewa-sound-1.jpg" / "1,2 MB · halaman 1", "Sedang diunggah…" with a 1.5 s bar, an empty white bar at the bottom. Then "Dokumen pendukung · 1 file terlampir", "Diunggah, belum diverifikasi" (20/700 `bata`), "Lihat file dan verifikasi" and "Tambah halaman".
  5. Fresh visit with `gagalUnggah` on → after the upload, "Gagal diunggah" with the `tinta` "Coba lagi". Press it → it uploads again and reaches the *lampir* state.
  6. "Tambah halaman" → the camera shows "Halaman 2". Repeat → "nota-sewa-sound-2.jpg", "2 file terlampir".
  7. "Lihat file dan verifikasi" → `/LihatDokumen`; Back returns to the upload page.
  8. Back arrow from the camera or the upload page → `/Dokumen`.
  9. Reduce motion on → no flash; the bars appear full; the states still change after 1.5 s.
- **Notes**
  - White on `tinta` maps to `permukaan` (CONVENTIONS). In the dark theme the camera screen turns light. That is acceptable, since dark is not checked against boards.
  - The flash overlay should stay white in both themes. Use `permukaan` in light; in dark use `tinta`, the lightest token there, rather than a literal.
  - On the light page the subtitle "BKU-2026-0143 · Sewa sound system" is all sans in the source, while the dark camera header sets the code in mono. Keep each as drawn: the board wins over the "every code is mono" theme rule (CONVENTIONS, first paragraph), as `06-bukti.md` does for codes in running text.
  - "Diunggah, belum diverifikasi" in `bata` is the board's choice: it still blocks month close. Keep it.
  - Off-token values: radius 4 on the thumbnail, 20 px status titles, 3 px bracket lines, 76 px shutter.
  - The board's timer is not cleared on unmount; cancel it.
