# Screens 05: Kewajiban, WebKewajiban, Terbatas, WebTerbatas, Pemeriksa, WebPemeriksa, BantuanAI, WebBantuanAI, WebPaketLaporan

These nine boards are the later finance slices on the canvas page "Keuangan · P2 dan P3" (WebBantuanAI is on "Pelengkap"). They cover money that is still running (Uang Muka, Titipan, Penggantian biaya: decisions D15–D17), the restricted view of a Diakonia officer (D26, D27), the second-checker rule (Tahapan Draf → Sudah diperiksa → Dibukukan), AI help while recording a Belanja (D31), and the monthly report pack F01–F14 (D12–D14, D27, C01, C04). How they connect: on the phone, Main ("2 uang muka dengan sisa belum dipertanggungjawabkan") and Lainnya open Kewajiban, which pairs with KasusBaru; Main opens BantuanAI, which returns to Main; Lainnya opens Pemeriksa; Masuk (signed in as Akses terbatas) opens Terbatas, which opens A4Terbatas. On the laptop, the Bendahara side nav reaches WebKewajiban ("Uang Muka dan Titipan") and WebPaketLaporan ("Laporan"); WebKewajiban opens WebKasusBaru and WebKasus; WebPengaturan opens WebPemeriksa; WebCatat and TabCatat ("Dari kalimat") open WebBantuanAI, which goes on to WebCatat or WebTransaksi; WebMasuk opens WebTerbatas, which opens A4Terbatas and WebExcelTerbatas; WebPaketLaporan opens A4F01, WebExcel, WebFormatLaporan, WebBukti, WebLihatTransaksi, WebLaporan and WebTransaksi.

Shared rules for this file:

- Link navigation. Side-nav items use `go`. A back arrow or a breadcrumb that is an `<a>` to the parent board pops when the stack can pop, otherwise `go`es to the parent. A drill-in (`+ Kasus baru`, `Unduh PDF`, a No. Bukti link) uses `push`. An end-of-flow link (`Periksa dan bukukan`, `Simpan sebagai draf`) uses `go`.
- Web shell. Every web board here uses the shared Bendahara side nav from `lib/shell/` (logo mark 26 px + "palakat" 18/700 + "Jemaat Karunia" 13 `tinta3`; items 44 high, padding 0 12, radius 10, weight 600; the active item is a `tinta` field with `permukaan` text; footer above a 1 px `garis` top line, 13 px `tinta2`; below 860 px the "Menu"/"Tutup menu" drawer of the `.pn` CSS). Exceptions: WebTerbatas has a restricted three-item set and its own footer; WebPemeriksa has a fixed footer (see those boards). Main column: padding 28 top, `clamp(16px, 3vw, 40px)` sides, 40 bottom, gap 20, body `isiWeb`.
- Web vacancy banner (PitaJabatanKosong, web form), when `jabatanKosong` is on: a `tinta` field, radius 14, padding 12 16, 14 px, `role=status`: bold "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15." then, in `diTinta2`, "Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." The side-nav footer then reads "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat" instead of "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif".
- Phone vacancy banner (PitaJabatanKosong, phone form), when `jabatanKosong` is on: a full-width `tinta` strip above everything, padding 10 24 8, 13 px, line height 1.3, centred, `role=status`: bold "Menjalankan jabatan kosong" + " · Bendahara Jemaat".
- `tukarJk` is disabled (`if (jk && false)`) on the five boards that carry it (Kewajiban, WebKewajiban, BantuanAI, WebBantuanAI, WebPaketLaporan); Terbatas, WebTerbatas, Pemeriksa and WebPemeriksa have no `tukarJk`. No name is swapped anywhere.
- Bottom-sheet scrim `rgba(19,32,28,.45)` is `tinta` at 45 % opacity.
- Every amount uses the shared `rp()` formatter: `−` is U+2212, dot thousands.

---

### Kewajiban — 11 · Uang Muka, Titipan, Penggantian biaya

- **Source** `docs/design/handoff/canvas/boards/Kewajiban.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Phone 390×844 · interactive yes
- **Route** `/Kewajiban` plus child route `/Kewajiban/kasus/:id` (`id` ∈ `um1 um2 um3 tt1 tt2 pb1 pb2`; an unknown id redirects to `/Kewajiban`) · **Widget** `KewajibanScreen` in `lib/screens/lanjut/kewajiban.dart` (the child route renders the case view from the same file)
- **Purpose** Bendahara Jemaat, daily work ("1 · Harian" journey, step 2). The list of money still running, per kind, and one case's history with the actions that settle it. Shows D15 (the list is named "Uang yang masih berjalan"), D16 (spending beyond the advance is refused and sent to Penggantian biaya), D17 (a claim must be checked before it can be paid). The remainder is always computed from the entries, never typed (KartuKasus, BatangPembagian).
- **Shell** No tab bar. The board draws its own phone header with a back control (list: link to Main; case: state back). Phone vacancy banner on top when `jabatanKosong`.
- **Layout**
  1. Vacancy banner (only with `jabatanKosong`), see shared rules.
  2. **List view** (`buka == null`), full area, enters with `pudar`:
     1. Header row, padding 14 12 8, gap 8: back link 44×44 (chevron `M15 6l-6 6 6 6`, 22 px, stroke 2, `tinta`, label "Kembali ke Beranda") → Main; title "Uang yang masih berjalan" (`judulLayar` 18/700, flex 1); button "+ Kasus baru": min height 44, padding 0 14, margin-right 8, radius 12, `laut` field, `diLaut` text, 700 → KasusBaru.
     2. Kind chips, padding 0 20 10: three chips "Uang Muka", "Titipan", "Penggantian biaya"; each min height 44, padding 0 13, margin-right 6, radius 999, border 1.5, 13 px/600. Selected: `tinta` field, `permukaan` text, `tinta` border. Unselected: `permukaan` field, `tinta` text, `garisTegas` border. `aria-pressed` = selected.
     3. Scroll area, padding 4 20 20, gap 12:
        - Summary: "{L.sisa} · {bukaN} kasus" (14, `tinta2`); total of open cases (mono 30/500, letter spacing −1, = `jumlahIsian` size); caption `L.cat` (13, `tinta3`).
        - One case card per case of the selected kind (button, full width, radius 14, padding 14 16, gap 6). Open case (sisa > 0): `permukaan` field, 1 px `garisTegas` edge. Settled (sisa = 0): transparent, 1 px `garis` edge. Contents: row of title (15/700) and remainder (mono 500, `rp(sisa)`), space-between; "{L.pihak}: {pihak}" (13, `tinta2`); progress bar (height 8, radius 4, 1.5 dashed `putus` edge = `draf` line, inner fill `tinta` at width `round((awal − sisa)/awal·100)%`); status line (13, `tinta2`, weight 700 when past due and open, else 400).
        - Status line text: status word + due suffix. Status word: sisa 0 → `st[2]`; has entries → `st[1]`; no entries → `st[0]`. Suffix only when the case has a due date and is open: past due → " · Lewat jatuh tempo (jatuh tempo: {tempo})", otherwise " · jatuh tempo {tempo}".
  3. **Case view** (`buka != null`, child route), enters with `masuk`:
     1. Header, padding 14 12 8, gap 8: back button 44×44 (chevron, label "Kembali"); title block: case title (`judulLayar`) and "{L.pihak}: {pihak}" (13, `tinta2`).
     2. Scroll area, padding 8 20 20, gap 16:
        - `L.sisa` (14, `tinta2`); the displayed remainder `tampil` (mono 36/500, letter spacing −1, line height 1.15); caption "Dihitung dari catatan di bawah. Tidak ada isian untuk mengubahnya." (13, `tinta3`).
        - Progress bar: height 14, radius 7, 1.5 dashed `putus` edge, fill `tinta` at the case percentage, width animated 500 ms on the token curve.
        - Status row, wrap, gap 8: status badge (13/700, radius 6, padding 3 9). Open: transparent, `tinta2` text, 1.5 solid `tinta3` edge. Settled: `laut` field, `diLaut` text, 1.5 `laut` edge. Next to it the due text (13, `tinta`, 700 if past due): open and past due → "Lewat jatuh tempo (jatuh tempo: {tempo})"; open with due date → "Jatuh tempo {tempo}"; otherwise empty.
        - History card (`permukaan`, 1 px `garis`, radius 14, padding 4 16). First row (padding 12 0): left `L.awal` (15/600) over the opening note `awalCat` (13, `tinta3`); right `rp(awal)` (mono 500). For a Penggantian biaya case that has been checked and is still open, the note gets " · klaim sudah dicek" appended. Then one row per entry (1 px `garis` top line, padding 12 0, enters with `muncul`): left entry name (15/600) over "{No. Bukti in mono} · {date} · {cat}" (13, `tinta3`); right "− {rp(jm)}" (mono 500; note the space after the minus).
        - Footer note `L.kaki` (13, `tinta3`).
     3. Action bar, `permukaan`, 1 px `garis` top line, padding 12 20 22, gap 8: the action buttons (min height 50, radius 14, 700, centred). Primary: `laut` field, `diLaut` text, no border. Secondary: `permukaan` field, `tinta` text, 1.5 `tinta` border. When the case is settled there are no buttons; instead a status line (`role=status`, min height 50, centred, 700, `laut`, enters with `muncul`): "{status word} · tidak ada sisa".
  4. **Amount sheet** (over the case view): scrim (full area below the vacancy banner — the banner stays uncovered — label "Kembali ke kasus", `pudar`) and a panel from the bottom (`permukaan`, top radius 22, padding 10 20 24, gap 14, `naik`):
     - Handle 40×4, radius 2, `garisTegas`, centred, 4 below.
     - Title = action name (`judulLayar`), sub-line = action note (14, `tinta2`).
     - Label "Jumlah (Rp)" (14, `tinta2`; it is the input's label, so it becomes the field's Semantics label), then the input row: baseline row, gap 6, mono, 2 px `tinta` underline, padding-bottom 4; prefix "Rp" (20 px, `tinta3`); input mono 32/500, letter spacing −1, min height 44, placeholder "0", numeric keyboard. Read-only for the pay-claim action.
     - Refusal (only when amount > remainder): 14/600 `bata`: "Tidak dapat dilakukan: melebihi sisa {rp(sisa)}. {lebih}".
     - Book button (TombolBersyarat): min height 52, radius 14, 700, centred. Valid: `laut` / `diLaut`. Invalid: `garis` / `tinta3`.
     - "Kembali" text button (min height 44, 700, `tinta`).
- **Components** PitaJabatanKosong (phone); ChipPilihan (kind chips); KartuKasus (case cards); BatangPembagian (both progress bars); LencanaStatus-shaped status badge (open = `tinta3` line, settled = `laut` field); Tombol (primary and secondary actions); LembarBawah (amount sheet); IsianJumlah (sheet input); TombolBersyarat + Penolakan (book button and the over-remainder sentence). Repeated non-component pattern: the history row (label over mono caption, amount right).
- **Internal views and states** List view (initial); case view (child route, from a card); amount sheet (from an action button that is not "Cek klaim"); settled status line (case remainder 0). Initial state: `{ tab: 'um', buka: null, sheet: null, isi: '', tampil: 0, nomor: 150, cek: {}, kasus: [7 cases, see Mock data] }`. List and case view share one state object for as long as the board is on the stack (a board-scoped controller provided above both routes), so entries booked in a case show in the list after Back; leaving the board resets it. A deep link to `/Kewajiban/kasus/:id` sets `tab` to that case's kind so Back lands on the right list. This is also required for the case view itself: the board reads the case view's labels (`L.pihak`, `L.sisa`, `L.awal`, `L.kaki`) from the selected `tab`, not from the case's own kind.
- **Tweaks** `jabatanKosong` (boolean, default off) → Keadaan panel global switch `jabatanKosong`. On: phone vacancy banner above the screen. No other change (name swap disabled).
- **Interactions**
  - Kind chip → `tab = um|tt|pb`. Labels per kind (`LBL`):
    - um: pihak "Diberikan kepada", awal "Uang Muka diberikan", sisa "Sisa belum dipertanggungjawabkan", cat "Uang muka bukan Belanja saat diberikan.", statuses "Belum dipertanggungjawabkan" / "Sebagian dipertanggungjawabkan" / "Sudah dipertanggungjawabkan", kaki "Pertanggungjawaban yang diterima menjadi Belanja. Pengembalian sisa kembali ke Kas dan bukan Pendapatan."
    - tt: pihak "Titipan untuk", awal "Terkumpul", sisa "Sisa belum disalurkan", cat "Uang titipan untuk pihak lain, bukan Pendapatan dan bukan Belanja.", statuses "Belum disalurkan" / "Sebagian disalurkan" / "Sudah disalurkan", kaki "Sentralisasi dari uang milik sendiri dicatat sebagai Belanja biasa, tidak di sini."
    - pb: pihak "Dibayar kepada", awal "Klaim", sisa "Belum dibayar", cat "Klaim belum masuk saldo sampai dibayar.", statuses "Belum dibayar" / "Belum dibayar" / "Sudah dibayar", kaki "Mengecek klaim tidak mengubah saldo. Pembayarannya mencatat Belanja satu kali."
  - Case card → cancel any running count, `buka = id`, `tampil = current remainder`; push `/Kewajiban/kasus/{id}`. Settled cases open too (they show the settled status line).
  - Case back button → cancel the count, `buka = null`, `sheet = null`; pop.
  - Action buttons (only while remainder > 0), by kind, in this order:
    - um: "Catat pertanggungjawaban" (primary) and "Catat pengembalian sisa" (secondary).
    - tt: "Salurkan" (primary).
    - pb, claim not yet checked: only "Cek klaim · tidak mengubah saldo" (primary). Pressing it sets `cek[id] = true` and opens nothing; the button is then replaced by "Bayar penggantian biaya" (primary) and the opening note gains " · klaim sudah dicek". The pay button never shows before the check (D17).
  - Any other action button → `sheet = action`, `isi = String(remainder)` (the sheet opens filled with the whole remainder). Sheet contents per action:
    - "Catat pertanggungjawaban": note "Belanja dari uang muka, dengan nota.", button "Bukukan pertanggungjawaban", new entry "Pertanggungjawaban uang muka" / "menjadi Belanja", over-text "Kelebihan belanja dicatat sebagai Penggantian biaya."
    - "Catat pengembalian sisa": note "Uang kembali ke Kas. Bukan Pendapatan.", button "Bukukan pengembalian", entry "Pengembalian sisa uang muka" / "kembali ke Kas", over-text empty.
    - "Salurkan": note "Menyerahkan titipan kepada yang berhak. Bukan Belanja.", button "Bukukan penyaluran", entry "Penyaluran" / "bukan Belanja", over-text empty.
    - "Bayar penggantian biaya": note "Membayar klaim penuh dan mencatat Belanja satu kali.", button "Bukukan pembayaran", entry "Penggantian biaya dibayar" / "Belanja, dicatat satu kali", input locked (read-only: typing is ignored).
  - Amount input: keep digits only, strip leading zeros, at most 11 digits; display with dot thousands ("650000" → "650.000"). Empty shows the grey placeholder "0".
  - Book button condition, re-checked on press from the latest text: amount > 0 and amount ≤ remainder. Amount 0/empty → disabled look, no sentence. Amount > remainder → disabled look plus the refusal sentence. The first press after typing must use the typed value.
  - Book (valid) → append entry `{ n: entry, no: 'BKU-2026-0' + nomor, t: '16/11/2026', cat: entry note, jm: amount }`, close the sheet, `nomor + 1`. Then count `tampil` from the old remainder to the new one: 22 steps every 30 ms (660 ms), value `old + (new − old)·(1 − (1 − i/22)³)`, rounded. The bar width animates at the same time (500 ms). When the new remainder is 0: badge turns to the settled look, the due text disappears, the action buttons go and the settled status line appears.
  - Scrim or "Kembali" in the sheet → `sheet = null`.
  - Leaving the board cancels the count timer.
- **Motion** List view: `pudar` 200 ms (opacity 0→1) on enter. Case view: `masuk` 280 ms token curve (opacity 0→1, x +24→0) as the push transition; Back is instant; the list does not replay `pudar` (motion.md, Screen change). History rows and the settled status line: `muncul` 300 ms (opacity 0→1, y +8→0) on first build. Sheet: scrim `pudar` 200 ms, panel `naik` 280 ms token curve (y 100 %→0). Progress bar width: 500 ms token curve (BatangPembagian). Remainder count after booking: 660 ms ease-out-cubic, the balance part of `tinta`. Reduce motion: everything instant, the count jumps to the final figure.
- **Links out** Back chevron (aria "Kembali ke Beranda") → `/Main` (pop or go). "+ Kasus baru" → `/KasusBaru` (push). **Inbound** KasusBaru, Keputusan, Lainnya, Main.
- **Mock data** (amounts in Rp; remainder and percentage computed):
  - um1 "Panitia Natal", "Sdr. Rivo Mandagi", awal 1.500.000, note "BKU-2026-0129 · 01/11/2026 · dari peruntukan Umum Jemaat", due 30/11/2026, entry "Pertanggungjawaban uang muka" BKU-2026-0138 · 08/11/2026 · menjadi Belanja 850.000 → sisa Rp650.000, 57 %, "Sebagian dipertanggungjawabkan · jatuh tempo 30/11/2026".
  - um2 "Retret Pemuda", "Sdri. Natalia Rumengan", awal 800.000, note "BKU-2026-0112 · 20/10/2026 · dari peruntukan Umum Jemaat", due 10/11/2026, past due, entry BKU-2026-0150 · 05/11/2026 · menjadi Belanja 300.000 → sisa Rp500.000, 38 %, bold "Sebagian dipertanggungjawabkan · Lewat jatuh tempo (jatuh tempo: 10/11/2026)".
  - um3 "Perjalanan dinas Wilayah", "Pnt. Jefry Wowor", awal 400.000, note "BKU-2026-0103 · 07/10/2026", entry BKU-2026-0149 · 03/11/2026 · menjadi Belanja 400.000 → Rp0, 100 %, "Sudah dipertanggungjawabkan".
  - tt1 "Sentralisasi November", "Sinode", awal 2.400.000, note "Dari 4 persembahan · disimpan di Bank BNI ··4821", entry "Penyaluran" BKU-2026-0136 · 07/11/2026 · bukan Belanja 1.000.000 → Rp1.400.000, 42 %, "Sebagian disalurkan".
  - tt2 "Persembahan khusus", "Wilayah", awal 450.000, note "Dari persembahan khusus 9 November · disimpan di Kas", no entries → Rp450.000, 0 %, "Belum disalurkan".
  - pb1 "Alat kebersihan gereja", "Ibu Selvie Kalalo", awal 185.000, note "Nota 12/11/2026 terlampir · belum masuk saldo", no entries → Rp185.000, 0 %, "Belum dibayar".
  - pb2 "Bensin antar jemput", "Sdr. Rivo Mandagi", awal 120.000, note "Nota 02/11/2026 terlampir", entry "Penggantian biaya dibayar" BKU-2026-0134 · 05/11/2026 · Belanja, dicatat satu kali 120.000 → Rp0, 100 %, "Sudah dibayar".
  - List totals: um "Sisa belum dipertanggungjawabkan · 2 kasus" Rp1.150.000; tt "Sisa belum disalurkan · 2 kasus" Rp1.850.000; pb "Belum dibayar · 1 kasus" Rp185.000. Booking date 16/11/2026; next No. Bukti BKU-2026-0150, then 0151, …
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/Kewajiban` → "Uang Muka" chip is a `tinta` field; summary "Sisa belum dipertanggungjawabkan · 2 kasus" and "Rp1.150.000"; three cards; the Retret Pemuda status line is bold and reads "Sebagian dipertanggungjawabkan · Lewat jatuh tempo (jatuh tempo: 10/11/2026)"; Perjalanan dinas Wilayah card is transparent with a `garis` edge.
  2. Tap "Titipan" → "Sisa belum disalurkan · 2 kasus", "Rp1.850.000", caption "Uang titipan untuk pihak lain, bukan Pendapatan dan bukan Belanja."
  3. Tap Panitia Natal → `/Kewajiban/kasus/um1` slides in; "Rp650.000"; bar 57 % filled; badge "Sebagian dipertanggungjawabkan" and "Jatuh tempo 30/11/2026"; buttons "Catat pertanggungjawaban" (`laut`) and "Catat pengembalian sisa" (outline).
  4. Tap "Catat pertanggungjawaban" → sheet rises with "650.000" in the field. Type "1" at the end → "6.500.001", the sentence "Tidak dapat dilakukan: melebihi sisa Rp650.000. Kelebihan belanja dicatat sebagai Penggantian biaya." appears and the button turns `garis`/`tinta3`; pressing does nothing.
  5. Replace the amount with "200000" → shows "200.000"; press "Bukukan pertanggungjawaban" once → the sheet closes, a row "Pertanggungjawaban uang muka · BKU-2026-0150 · 16/11/2026 · menjadi Belanja · − Rp200.000" fades in, the figure counts from Rp650.000 down to Rp450.000 in about 660 ms, the bar grows to 70 %.
  6. Back → the list shows Panitia Natal "Rp450.000" and the total "Rp950.000".
  7. "Penggantian biaya" → open Alat kebersihan gereja → only "Cek klaim · tidak mengubah saldo". Tap it → it is replaced by "Bayar penggantian biaya" and the note ends "· klaim sudah dicek". Tap pay → sheet shows "185.000", typing changes nothing; "Bukukan pembayaran" → figure counts to "Rp0", badge "Sudah dibayar" on `laut`, status line "Sudah dibayar · tidak ada sisa", no buttons, and the note loses " · klaim sudah dicek" again (the suffix only shows while the claim is open); the new row is "Penggantian biaya dibayar · BKU-2026-0151 · 16/11/2026 · Belanja, dicatat satu kali · − Rp185.000" (0151 because check 5 already used 0150 on the same board state).
  8. In the sheet, typing "abc" adds nothing; typing "0005" shows "5"; a 12th digit is ignored.
  9. Switch `jabatanKosong` on → the one-line `tinta` banner "Menjalankan jabatan kosong · Bendahara Jemaat" sits above the header on both views.
- **Notes**
  - No. Bukti collision: the counter starts at 150, so the first new entry is BKU-2026-0150, which Retret Pemuda already uses, and Pemeriksa stamps BKU-2026-0151 on another transaction. The board wins: keep 150; list it in `mock-data.md`.
  - When the amount field is emptied the book button is disabled with no reason sentence (the board only words the over-remainder case). This breaks "a disabled action always shows its reason", but the board wins on what is shown; flag it for the product owner.
  - The entry amount is written "− Rp850.000" with a space; keep the board form, not `rp(-n)`.
  - The over-remainder sentence is all `bata` 14/600 (not the Penolakan split of `bata` cause + `tinta` rest). Keep the board.
  - For "Catat pengembalian sisa" and "Salurkan" the over-text is empty, so the sentence ends "… melebihi sisa Rp650.000. " (or "Rp1.400.000. ") with a trailing space; trim it. ("Bayar penggantian biaya" is locked to the remainder, so it never shows the sentence.)
  - Off-token sizes: 36, 32 (mono figures), 20 ("Rp" prefix), 15 (card titles). Copy them. (The 30 px list total is the `jumlahIsian` size.)
  - The figures differ from WebKewajiban (the web list has extra cases). Each board keeps its own.

### WebKewajiban — Web · Uang Muka dan Titipan

- **Source** `docs/design/handoff/canvas/boards/WebKewajiban.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebKewajiban`, no child routes · **Widget** `WebKewajibanScreen` in `lib/screens/lanjut/web_kewajiban.dart`
- **Purpose** Bendahara Jemaat at the desk: one table of running money per kind, read-only. Shows D15, D16 (an advance overspent is shown apart as "Lebih dipertanggungjawabkan" and paid through Penggantian biaya), and that the remainder is computed, not typed.
- **Shell** Web side nav: Beranda, Transaksi, **Uang Muka dan Titipan** (active), Rekonsiliasi, Bulan dan tutup buku, Laporan, Pengaturan. Footer "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (vacancy variant in shared rules).
- **Layout** (main column, top to bottom)
  1. Web vacancy banner when `jabatanKosong`.
  2. Title "Uang Muka dan Titipan" (`judulHalaman` 26/700) and sub-line "Uang yang masih berjalan, satu baris per kasus. Sisa dihitung dari catatannya dan tidak dapat diketik." (14, `tinta2`).
  3. Link row (margin-top −8, wrap, gap 0 22, 14/600, `laut` links, each min 44×44): "+ Kasus baru", "Catat pada kasus".
  4. Kind chips (wrap, gap 8): "Uang Muka", "Titipan", "Penggantian biaya"; min height 44, padding 0 16, radius 999, 1.5 border, 14/600; selected/unselected as in Kewajiban.
  5. Summary row (wrap, align end, gap 12 40): block A "{L.sisa} · {bukaN} kasus" (14, `tinta2`) over the total (mono 40/500, letter spacing −1, line height 1.1). Block B, only when a case is overspent: "Lebih dari uang muka · {n} kasus · tidak dikurangkan dari sisa di kiri" (14, `tinta2`) over the overspent total (mono 24/500, `bata`). Block C (flex 1 1 260): `L.cat` (14, `tinta2`).
  6. Table card: `permukaan`, 1 px `garis`, radius 14, horizontal scroll, inner min width 900. Grid columns `minmax(0,1.3fr) minmax(0,1.1fr) 130px 130px 140px minmax(0,1.5fr)`, gap 16.
     - Header row, padding 12 18, 13/600 `tinta2`: "Kasus" | `L.pihak` | `L.awal` (right) | `L.sudah` (right) | `L.sisaPendek` (right) | "Status".
     - Body rows (not pressable), min height 60, padding 8 18, 1 px `garis` top line, 14 px, centred vertically: title (600) over note (13, `tinta3`) | party | opening (mono, right) | recorded so far (mono, right; `—` when 0) | remainder (mono 600, right; `tinta`, or `bata` "lebih {rp}" when overspent) | status badge (13/700, radius 6, padding 3 9) with an optional due line under it (13, `tinta`, margin-top 3, 700 when past due).
     - Badge looks: settled → `laut` field, `diLaut` text, 1.5 `laut`; overspent → `permukaan`, `bata` text, 1.5 `bata` ("Lebih dipertanggungjawabkan"); open → `permukaan`, `tinta2` text, 1.5 `tinta3`.
  7. Footer note `L.kaki` (13, `tinta3`).
- **Components** PitaJabatanKosong (web); ChipPilihan; LencanaStatus-shaped badges; web side nav. Repeated pattern: web data table with header row and `garis` row lines.
- **Internal views and states** One view; state `{ tab: 'um' }`. Block B shows only on the Uang Muka tab (only there is a case overspent).
- **Tweaks** `jabatanKosong` (boolean, default off) → Keadaan panel global switch. On: web vacancy banner, side-nav footer becomes the Operator variant.
- **Interactions** Kind chip → `tab`. Labels per kind:
  - um: pihak "Diberikan kepada", awal "Diberikan", sudah "Sudah dicatat", sisaPendek "Sisa", sisa "Sisa belum dipertanggungjawabkan", cat "Uang muka bukan Belanja saat diberikan. Pertanggungjawaban yang diterima menjadi Belanja; pengembalian sisa bukan Pendapatan.", kaki "Kasus yang belanjanya melebihi uang muka ditampilkan terpisah dan tidak pernah mengurangi sisa kasus lain. Kelebihannya dibayar lewat Penggantian biaya."
  - tt: pihak "Titipan untuk", awal "Terkumpul", sudah "Disalurkan", sisaPendek "Sisa", sisa "Sisa belum disalurkan", cat "Uang titipan untuk pihak lain: bukan Pendapatan saat masuk, bukan Belanja saat disalurkan.", kaki "Sentralisasi dari uang milik sendiri dicatat sebagai Belanja biasa, tidak di sini. Aturan Jemaat yang menentukan, bukan nomor Mata Anggarannya."
  - pb: pihak "Dibayar kepada", awal "Klaim", sudah "Dibayar", sisaPendek "Belum dibayar", sisa "Belum dibayar", cat "Klaim belum masuk saldo. Pembayarannya mencatat Belanja satu kali.", kaki "Mengecek klaim tidak mengubah saldo."
  - Status words as in Kewajiban (`st[0..2]` per kind); overspent → "Lebih dipertanggungjawabkan". Due line hidden when settled.
- **Motion** none (the `muncul`, `isi`, `titik` keyframes are declared but unused).
- **Links out** "+ Kasus baru" → `/WebKasusBaru` (push); "Catat pada kasus" → `/WebKasus` (push); side nav (go): Beranda `/WebBeranda`, Transaksi `/WebTransaksi`, Uang Muka dan Titipan `/WebKewajiban`, Rekonsiliasi `/WebRekonsiliasi`, Bulan dan tutup buku `/WebTutupBuku`, Laporan `/WebPaketLaporan`, Pengaturan `/WebPengaturan`. **Inbound** 52 boards in all (see manifest): the side nav of the Bendahara web boards (including this board's own nav item), plus AIBulan and the tablet boards TabBeranda, TabCatat, TabTransaksi.
- **Mock data** (opening / recorded / remainder → status):
  - Uang Muka: "Panitia Natal" · "BKU-2026-0129 · 01/11/2026" · Sdr. Rivo Mandagi · Rp1.500.000 / Rp850.000 / Rp650.000 → "Sebagian dipertanggungjawabkan", "Jatuh tempo 30/11/2026". "Retret Pemuda" · "BKU-2026-0112 · 20/10/2026" · Sdri. Natalia Rumengan · Rp800.000 / Rp300.000 / Rp500.000 → "Sebagian dipertanggungjawabkan", bold "Lewat jatuh tempo (jatuh tempo: 10/11/2026)". "Konsumsi syukur HUT" · "BKU-2026-0119 · 25/10/2026" · Ibu Selvie Kalalo · Rp300.000 / Rp375.000 / "lebih Rp75.000" (`bata`) → "Lebih dipertanggungjawabkan". "Perjalanan dinas Wilayah" · "BKU-2026-0103 · 07/10/2026" · Pnt. Jefry Wowor · Rp400.000 / Rp400.000 / Rp0 → "Sudah dipertanggungjawabkan". Summary "Sisa belum dipertanggungjawabkan · 2 kasus" Rp1.150.000; block B "Lebih dari uang muka · 1 kasus · tidak dikurangkan dari sisa di kiri" Rp75.000.
  - Titipan: "Sentralisasi November" · "Disimpan di Bank BNI ··4821" · Sinode · Rp2.400.000 / Rp1.000.000 / Rp1.400.000 → "Sebagian disalurkan". "Persembahan khusus" · "Disimpan di Kas" · Wilayah · Rp450.000 / — / Rp450.000 → "Belum disalurkan". Summary "Sisa belum disalurkan · 2 kasus" Rp1.850.000.
  - Penggantian biaya: "Alat kebersihan gereja" · "Nota 12/11/2026 · klaim sudah dicek" · Ibu Selvie Kalalo · Rp185.000 / — / Rp185.000 → "Belum dibayar". "Kelebihan konsumsi syukur HUT" · "Dari uang muka BKU-2026-0119" · Ibu Selvie Kalalo · Rp75.000 / — / Rp75.000 → "Belum dibayar". "Bensin antar jemput" · "BKU-2026-0134 · 05/11/2026" · Sdr. Rivo Mandagi · Rp120.000 / Rp120.000 / Rp0 → "Sudah dibayar". Summary "Belum dibayar · 2 kasus" Rp260.000.
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/WebKewajiban` → side-nav item "Uang Muka dan Titipan" is the `tinta` field; total "Rp1.150.000"; block B "Rp75.000" in `bata`.
  2. The Konsumsi syukur HUT row shows "lebih Rp75.000" in `bata` and a `bata`-edged badge "Lebih dipertanggungjawabkan".
  3. Tap "Titipan" → headers "Titipan untuk", "Terkumpul", "Disalurkan", "Sisa"; total "Rp1.850.000"; block B gone; Persembahan khusus shows "—" under Disalurkan.
  4. Tap "Penggantian biaya" → headers "Dibayar kepada", "Klaim", "Dibayar", "Belum dibayar"; total "Rp260.000"; Bensin antar jemput badge is a `laut` field "Sudah dibayar".
  5. "+ Kasus baru" opens `/WebKasusBaru`; browser Back returns here with the same tab.
  6. At 860 px wide the side nav collapses behind "Menu" and the table scrolls sideways inside its card (min width 900).
  7. `jabatanKosong` on → the web banner is the first item of the main column and the footer reads "Yanti Sumual · Operator".
- **Notes**
  - Off-token sizes: 40 and 24 (mono figures). Copy them.
  - The overspent badge uses `bata`, which the rules reserve for blockers; it is the board's choice (an overspend needs a Penggantian biaya). Keep it.
  - Case list and figures differ from the phone board (web adds Konsumsi syukur HUT and Kelebihan konsumsi syukur HUT; Alat kebersihan gereja is already checked). Each board keeps its own.

### Terbatas — 12 · Akses terbatas per peruntukan

- **Source** `docs/design/handoff/canvas/boards/Terbatas.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Phone 390×844 · interactive yes
- **Route** `/Terbatas` plus child route `/Terbatas/transaksi/:no` (`no` ∈ BKU-2026-0141, BKU-2026-0135, BKU-2026-0122, BKU-2026-0098; unknown → `/Terbatas`) · **Widget** `TerbatasScreen` in `lib/screens/lanjut/terbatas.dart`
- **Purpose** A person with restricted access (Peruntukan Diakonia), reached right after sign-in (Masuk, `setelahMasuk: Akses terbatas`). Sees only the Diakonia part of each posted transaction. Shows D26 (restricted access still sees Mata Anggaran and Lingkup) and the restricted official report.
- **Shell** none: no tab bar and no back control on the list (system Back returns to Masuk); the transaction view has its own back button.
- **Layout**
  1. **List view** (scrolls as a whole, padding 20 20 28, gap 18, enters with `pudar`):
     1. Role banner (PitaPeran, role form): 1.5 solid `tinta` edge, radius 12, padding 10 14, 14 px: bold "Akses terbatas: Peruntukan Diakonia" over "Anda hanya melihat bagian Diakonia. Bagian lain tidak ditampilkan dan tidak ikut dijumlahkan." (`tinta2`).
     2. Balance: "Saldo buku peruntukan Diakonia" (14, `tinta2`); "Rp4.200.000" (`jumlahUtama`: mono 38/500, letter spacing −1, line height 1.1); "Hanya transaksi yang sudah dibukukan" (13, `tinta3`).
     3. Search input: full width, min height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan`; placeholder "Cari di peruntukan Diakonia"; semantics label "Cari transaksi Diakonia".
     4. List card (`permukaan`, 1 px `garis`, radius 14, padding 0 16): rows are buttons, min height 64, padding 8 0, gap 12, 1 px `garis` top line except the first. Left: "{No. Bukti} · {date}" (mono 13, `tinta2`) over the short Mata Anggaran name (15/600). Right (right-aligned): amount (mono 500) over "bagian Diakonia" (13, `tinta3`). Empty result: "Tidak ada transaksi peruntukan Diakonia yang cocok." (padding 18 0, 14, `tinta2`).
     5. Report card (`permukaan`, 1 px `garis`, radius 14, padding 14 16, a row centred vertically, gap 12): text block (flex 1) "Laporan resmi Oktober 2026" (15/600) over "TERBATAS · Peruntukan Diakonia · dibuat khusus untuk akses ini" (13, `tinta2`); secondary button "Unduh PDF" (min height 44, padding 0 14, radius 12, 1.5 `tinta`, `permukaan`, 700 `tinta`).
  2. **Transaction view** (child route, enters with `masuk`):
     1. Header, padding 14 12 8, gap 8: back button 44×44 (chevron, "Kembali"); No. Bukti as title (mono 17/600, flex 1); badge "Dibukukan" (13/700, `tinta` field, `permukaan` text, radius 6, padding 4 10, margin-right 8).
     2. Scroll area, padding 8 20 24, gap 16: "Bagian peruntukan Diakonia" (14, `tinta2`) over the amount (mono 34/500, letter spacing −1). Detail card (`permukaan`, 1 px `garis`, radius 14, padding 4 16) with three rows (padding 11 0, `garis` lines between; label 14 `tinta2`, value 14/600): "Tanggal transaksi" → date; "Mata Anggaran" → full name (right-aligned); "Lingkup" → "Jemaat". Hidden-parts card: 1.5 dashed `putus` edge, radius 14, padding 14 16, gap 6: "Tidak ditampilkan untuk akses terbatas" (15/700); five lines (14, `tinta2`): "Jumlah seluruh transaksi pada No. Bukti ini", "Bagian peruntukan lain", "Uraian dan catatan", "Nama pencatat dan pemberi persetujuan", "Dokumen pendukung asli"; caption (13, `tinta3`, margin-top 4) "Ini berlaku sama di layar, pencarian, PDF dan Excel. Bendahara dapat menjelaskan transaksi ini bila diperlukan."
- **Components** PitaPeran (role); LencanaStatus ("Dibukukan"); Tombol (secondary "Unduh PDF"). Pattern: the dashed "not shown" card (uses the `draf` line for withheld information).
- **Internal views and states** List (initial), transaction view (row tap), empty search result. Initial state `{ cari: '', buka: null }`. List and transaction view share the state, so the search text is still there after Back.
- **Tweaks** none.
- **Interactions**
  - Search: on every change `cari = text`. Filter: trimmed, lower-cased query; a row matches when "{no} {short MA} {date}" (lower case) contains it. Empty query shows all four.
  - Row → `buka = no`, push `/Terbatas/transaksi/{no}`.
  - Back button → `buka = null`, pop.
- **Motion** List `pudar` 200 ms on enter; transaction view `masuk` 280 ms token curve as the push transition; Back is instant; the list does not replay `pudar` (motion.md, Screen change). Reduce motion: instant.
- **Links out** "Unduh PDF" → `/A4Terbatas` (push). **Inbound** Keputusan, Masuk.
- **Mock data** Balance Rp4.200.000. Rows (No. Bukti · date · short MA · full MA · amount): BKU-2026-0141 · 10/11/2026 · Diakonia duka · Belanja 4.03.03.00 Diakonia duka · −Rp500.000; BKU-2026-0135 · 06/11/2026 · Persembahan Diakonia · Pendapatan 1.3.55.01.00 Persembahan Diakonia · Rp1.200.000; BKU-2026-0122 · 27/10/2026 · Diakonia sakit · Belanja 4.03.04.00 Diakonia sakit · −Rp300.000; BKU-2026-0098 · 04/10/2026 · Persembahan Diakonia · Pendapatan 1.3.55.01.00 Persembahan Diakonia · Rp950.000. Lingkup Jemaat. Report "Laporan resmi Oktober 2026".
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/Terbatas` → role banner, "Rp4.200.000", four rows, first row "BKU-2026-0141 · 10/11/2026", "Diakonia duka", "−Rp500.000".
  2. Type "duka" → only BKU-2026-0141 remains.
  3. Type "belanja" → the empty line "Tidak ada transaksi peruntukan Diakonia yang cocok." (the phone filter uses the short MA name).
  4. Type "10/2026" → BKU-2026-0122 and BKU-2026-0098.
  5. Clear, tap BKU-2026-0135 → `/Terbatas/transaksi/BKU-2026-0135` slides in; title "BKU-2026-0135", badge "Dibukukan", "Rp1.200.000", Mata Anggaran "Pendapatan 1.3.55.01.00 Persembahan Diakonia", Lingkup "Jemaat", five withheld items.
  6. Back → list returns with the earlier search text unchanged.
  7. "Unduh PDF" → `/A4Terbatas`; Back returns.
- **Notes**
  - The balance Rp4.200.000 does not equal the sum of the rows, nor F03 TERBATAS on WebPaketLaporan (Rp3.700.000 at 31/10, Rp4.400.000 after the two November rows). Keep each board's figure; list in `mock-data.md`.
  - No back control on the list. The board wins; rely on system Back.
  - Off-token sizes: 17 (mono title), 34 (amount), 15. Copy them.

### WebTerbatas — Web · Akses terbatas

- **Source** `docs/design/handoff/canvas/boards/WebTerbatas.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebTerbatas`, no child routes · **Widget** `WebTerbatasScreen` in `lib/screens/lanjut/web_terbatas.dart`
- **Purpose** The restricted Diakonia user on a laptop (after WebMasuk). Table plus a detail panel of the selected row. Shows D26 and the TERBATAS report copy (D27).
- **Shell** Web side nav with a restricted item set: **Beranda** (active), Transaksi, Laporan — all three link to `/WebTerbatas`. Footer "**Dkn. Olga Tamba**" / "Akses terbatas: Peruntukan Diakonia". No vacancy variant.
- **Layout** (main column)
  1. Role banner: 1.5 solid `tinta` edge, radius 12, padding 12 16, wrap, gap 4 16, baseline: bold "Akses terbatas: Peruntukan Diakonia" and "Anda hanya melihat bagian Diakonia. Bagian lain tidak ditampilkan dan tidak ikut dijumlahkan." (14, `tinta2`).
  2. Row (wrap, align end, gap 16 40): balance block "Saldo buku peruntukan Diakonia" (14, `tinta2`) / "Rp4.200.000" (mono 44/500, letter spacing −1, line height 1.1) / "Hanya transaksi yang sudah dibukukan" (13, `tinta3`); search input (flex 1 1 280, min height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan`, placeholder "Cari di peruntukan Diakonia", label "Cari transaksi Diakonia").
  3. Two columns (wrap, gap 24, align start):
     - Table card (flex 999 1 520; `permukaan`, 1 px `garis`, radius 14, horizontal scroll, inner min width 600). Grid `130px 100px minmax(0,1fr) 150px`, gap 14. Header (padding 12 18, 13/600 `tinta2`): "No. Bukti" | "Tanggal" | "Mata Anggaran" | "Bagian Diakonia" (right). Rows are buttons (min height 56, padding 8 18, 1 px `garis` top line, 14 px): No. Bukti (mono 13) | date (`tinta2`) | full MA (600) | amount (mono 500, right). Selected row: `lautLembut` field + 3 px inner `laut` line on the left edge; others `permukaan`. Empty: "Tidak ada transaksi peruntukan Diakonia yang cocok." (padding 18, 14 `tinta2`, `garis` top line).
     - Aside (flex 1 1 340, gap 14):
       - Detail card: `permukaan`, 1.5 solid `tinta` edge (`terpilih`), radius 16, padding 18, gap 4. Top row: badge "Dibukukan" (13/700, `tinta` field, `permukaan` text, radius 6, padding 4 10) and the No. Bukti (mono 14, `tinta2`), space-between. "Bagian peruntukan Diakonia" (14, `tinta2`, margin-top 6); amount (mono 30/500); "{full MA} · {date} · Lingkup Jemaat" (14, `tinta2`).
       - Withheld card: 1.5 dashed `putus`, radius 14, padding 14 16, gap 6: "Tidak ditampilkan untuk akses terbatas" (700); the same five lines as Terbatas (14, `tinta2`); caption "Berlaku sama di layar, pencarian, PDF dan Excel." (13, `tinta3`, margin-top 4).
       - Report card: `permukaan`, 1 px `garis`, radius 14, padding 14 16, wrap, centred vertically, gap 10: text block (flex 1 1 180) "Laporan resmi Oktober 2026" (600) over "TERBATAS · Peruntukan Diakonia" (13, `tinta2`); secondary buttons "Unduh PDF" and "Unduh Excel" (each min height 44, padding 0 14, radius 12, 1.5 `tinta`, `permukaan`, 700).
- **Components** PitaPeran; LencanaStatus ("Dibukukan"); Tombol (secondary ×2); restricted web side nav. Pattern: selected table row (`lautLembut` + 3 px `laut` left line).
- **Internal views and states** One view. State `{ cari: '', pilih: 'BKU-2026-0141' }`. The aside always shows the selected transaction, even when the search hides its row.
- **Tweaks** none.
- **Interactions** Search: `cari = text`; trimmed, lower-cased; matches "{no} {full MA} {date}". Row press → `pilih = no` (no navigation). `aria-pressed` = selected.
- **Motion** none (`muncul`, `isi`, `titik` declared, unused).
- **Links out** "Unduh PDF" → `/A4Terbatas` (push); "Unduh Excel" → `/WebExcelTerbatas` (push); side nav Beranda, Transaksi, Laporan → `/WebTerbatas` (go; staying on the same route keeps the state). **Inbound** WebMasuk.
- **Mock data** Same four transactions as Terbatas, full MA names; balance Rp4.200.000; user Dkn. Olga Tamba; "Laporan resmi Oktober 2026".
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/WebTerbatas` → BKU-2026-0141 row is `lautLembut` with a 3 px `laut` left line; aside shows "BKU-2026-0141", "−Rp500.000", "Belanja 4.03.03.00 Diakonia duka · 10/11/2026 · Lingkup Jemaat".
  2. Click BKU-2026-0098 → the highlight moves; aside "Rp950.000", "Pendapatan 1.3.55.01.00 Persembahan Diakonia · 04/10/2026 · Lingkup Jemaat".
  3. Type "belanja" → rows BKU-2026-0141 and BKU-2026-0122 (the web filter uses the full MA name).
  4. Type "xyz" → the empty line; the aside still shows the selected transaction.
  5. Every side-nav item stays on `/WebTerbatas`; footer reads "Dkn. Olga Tamba".
  6. "Unduh Excel" → `/WebExcelTerbatas` (pushed); Back returns to `/WebTerbatas` with the same row selected and the same search text.
- **Notes**
  - "Dkn. Olga Tamba" is not in the handoff's sample people list; keep it as drawn.
  - Off-token size: 44 (mono balance). Copy it. (The 30 px aside amount is the `jumlahIsian` size.)
  - Balance mismatch: see Terbatas notes.

### Pemeriksa — 13 · Wajib pemeriksa kedua

- **Source** `docs/design/handoff/canvas/boards/Pemeriksa.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Phone 390×844 · interactive yes
- **Route** `/Pemeriksa`, no child routes · **Widget** `PemeriksaScreen` in `lib/screens/lanjut/pemeriksa.dart`
- **Purpose** The second-checker rule, switched on from Lainnya. One Belanja draft goes Draf → Sudah diperiksa (by Pnt. Jefry Wowor, Pemeriksa kedua) → Dibukukan (by the Bendahara). The person who recorded it cannot mark it checked. Changing a checked transaction returns it to Draf and drops the check. Uses the Tahapan component and the `tinta` motion on Bukukan.
- **Shell** none: no tab bar, no header back control (system Back returns to Lainnya).
- **Layout**
  1. Top block, padding 20 20 8, gap 4: "Masuk sebagai **{siapa}** · Wajib pemeriksa kedua: hidup" (13, `tinta2`; name bold `tinta`); title "Belanja · Sewa kursi ibadah padang" (20/700).
  2. Scroll area, padding 8 20 20, gap 16:
     1. Tahapan row, gap 6: "1 · Draf", "2 · Sudah diperiksa", "3 · Dibukukan". Each chip min height 30, padding 0 10, radius 999, 13/700. Reached (index ≤ current step): `tinta` field, `permukaan` text, 1.5 solid `tinta`. Not reached: transparent, `tinta3` text, 1.5 dashed `putus`.
     2. Transaction card: radius 16, padding 18, gap 6, clips its children, background transition 300 ms. By status: Draf → transparent, 1.5 dashed `putus` (`draf`); Sudah diperiksa → `permukaan`, 1.5 solid `laut`; Dibukukan → `permukaan`, 1.5 solid `tinta` (`terpilih`). Contents:
        - Top row (space-between): status badge (13/700, radius 6, padding 3 9): Draf → "Draf · belum masuk saldo", transparent, `tinta2` text, 1.5 dashed `putus`; Sudah diperiksa → "Sudah diperiksa · belum masuk saldo", `permukaan`, `laut` text, 1.5 solid `laut`; Dibukukan → "Dibukukan", `tinta` field, `permukaan` text, 1.5 solid `tinta`. When Dibukukan, a stamp on the right: "No. Bukti BKU-2026-0151" (mono 14/600, `laut`, 2 px `laut` border, radius 8, padding 4 10).
        - Amount "−Rp900.000" (mono 30/500; `tinta2` before Dibukukan, `tinta` after).
        - "Kas · diambil dari peruntukan Umum Jemaat · Lingkup Jemaat" (14, `tinta2`).
        - "Belanja 5.05.02.00 Sewa peralatan · 16 November 2026" (14, `tinta2`).
        - Sweep overlay, only when Dibukukan: full-card `laut` layer, origin left, no hit testing (see Motion).
     3. Detail card (`permukaan`, 1 px `garis`, radius 14, padding 4 16), rows padding 11 0 with `garis` lines, label 14 `tinta2`, value 14/600: "Dicatat oleh" → "Meiske L. · 16/11/2026 09.40"; "Diperiksa oleh" → Draf: "Belum diperiksa" in `bata`; otherwise "Pnt. Jefry Wowor · 16/11/2026 10.05" in `tinta`; "Dokumen pendukung" → "Diunggah, belum diverifikasi".
     4. Explanation (14, `tinta2`), text per state (see Interactions).
  3. Action bar: `permukaan`, 1 px `garis` top line, padding 12 20 22, gap 8. Refusal line when present: "Tidak dapat dilakukan: {tolak}" (14/600, `bata`). Buttons min height 50, radius 14, 700, centred: primary `laut`/`diLaut`; secondary `permukaan`, `tinta`, 1.5 `tinta`; disabled `garis` field, `tinta3` text. The bar stays (empty, 34 px of padding) when there are no buttons.
  4. Confirm sheet (from "Ubah" when Sudah diperiksa): scrim (label "Kembali ke transaksi", `pudar`), panel (`permukaan`, top radius 22, padding 10 20 24, gap 14, `naik`): handle 40×4 `garisTegas`; "Ubah transaksi yang sudah diperiksa?" (19/700); "Transaksi kembali menjadi **Draf**. Tanda sudah diperiksa dari Pnt. Jefry Wowor dan persetujuan yang sudah dicatat akan hilang, lalu perlu diberikan lagi." (15); button "Ubah dan kembalikan ke Draf" (min height 52, radius 14, `tinta` field, `permukaan` text, 700); "Kembali" text button (min height 44, 700).
- **Components** Tahapan; LencanaStatus (Draf, Sudah diperiksa, Dibukukan); GarisStatus (card edge per status); TombolBersyarat + Penolakan (disabled "Tandai sudah diperiksa" with the refusal above); Tombol; LembarBawah; Gerak `tinta` (sweep + stamp).
- **Internal views and states** One view with five state combinations (status × who) plus the confirm sheet. Initial state `{ st: 'draf', sheet: false }`. Changing a tweak does not reset `st`, so the viewer plays both people by switching `masukSebagai` in the panel.
  - Draf + Bendahara + second checker assigned: refusal "Tidak dapat dilakukan: Anda yang mencatat transaksi ini, jadi orang lain yang harus menandainya sudah diperiksa. Pemeriksa kedua: Pnt. Jefry Wowor."; buttons "Tandai sudah diperiksa" (disabled) and "Ubah" (secondary, no action); explanation "Draf belum masuk saldo. Sampai diperiksa dan dibukukan, transaksi ini menjadi hambatan tutup buku November 2026."
  - Draf + Bendahara + no second checker: refusal "Tidak dapat dilakukan: belum ada pemeriksa kedua yang ditunjuk. Yang perlu bertindak: BPMJ menunjuk pemeriksa kedua."; same buttons and explanation.
  - Draf + Pemeriksa kedua: one primary "Tandai sudah diperiksa"; explanation "Menandai sudah diperiksa bukan persetujuan dan belum memasukkan transaksi ke saldo. Bendahara yang membukukan."
  - Sudah diperiksa + Bendahara: "Bukukan" (primary), "Ubah" (secondary); explanation "Sudah diperiksa, belum masuk saldo. Pindah tanggal dan Batalkan tetap tersedia dengan alasan."
  - Sudah diperiksa + Pemeriksa kedua: no buttons; explanation "Anda sudah menandai transaksi ini. Menunggu Bendahara membukukan; tidak ada yang perlu Anda lakukan."
  - Dibukukan (either): no buttons; explanation "Sudah masuk saldo. Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata Anggaran tidak dapat diubah lagi."
- **Tweaks**
  - `masukSebagai`: "Bendahara" (default) | "Pemeriksa kedua" → Keadaan panel. Changes the header name ("Meiske L., Bendahara" / "Pnt. Jefry Wowor, Pemeriksa kedua") and which buttons, refusal and explanation show (table above).
  - `adaPemeriksaKedua`: boolean, default on → Keadaan panel. Only matters in Draf as Bendahara: on → the "Anda yang mencatat…" refusal; off → the "belum ada pemeriksa kedua yang ditunjuk…" refusal. The header still says "Wajib pemeriksa kedua: hidup" in both.
- **Interactions** "Tandai sudah diperiksa" (Pemeriksa kedua, Draf) → `st = 'periksa'`. "Bukukan" (Bendahara, Sudah diperiksa) → `st = 'buku'`. "Ubah" (Bendahara, Sudah diperiksa) → `sheet = true`. "Ubah dan kembalikan ke Draf" → `st = 'draf'`, `sheet = false`. Scrim or "Kembali" → `sheet = false`. Disabled "Tandai sudah diperiksa" and Draf "Ubah" do nothing.
- **Motion** On entering Dibukukan (the `tinta` motion): sweep `sapu` 700 ms ease-out, fill both (laut layer scaleX 0→1 at opacity .2 until 65 %, then fades to 0 at 100 %); stamp `cap` 550 ms token curve, delay 350 ms, fill both (0 %: opacity 0, scale 1.7, rotate −9°; 55 %: opacity 1, scale .94, rotate −3°; 100 %: scale 1, rotate −3° — the stamp rests tilted −3°); card background 300 ms. Sheet: scrim `pudar` 200 ms, panel `naik` 280 ms token curve. Reduce motion: all instant (stamp shown at its final tilt). `muncul` is declared but unused.
- **Links out** none. **Inbound** Lainnya.
- **Mock data** Belanja "Sewa kursi ibadah padang", −Rp900.000, Kas, peruntukan Umum Jemaat, Lingkup Jemaat, Belanja 5.05.02.00 Sewa peralatan, 16 November 2026; recorded by Meiske L. 16/11/2026 09.40; checked by Pnt. Jefry Wowor 16/11/2026 10.05; No. Bukti BKU-2026-0151; close month November 2026.
- **Prototype-only** none on screen. The "Masuk sebagai …" line is app content (who is signed in); the role switch itself is the `masukSebagai` tweak in the Keadaan panel.
- **Acceptance checks**
  1. Default → step 1 filled, steps 2–3 dashed; card dashed and transparent; refusal "Tidak dapat dilakukan: Anda yang mencatat transaksi ini, jadi orang lain yang harus menandainya sudah diperiksa. Pemeriksa kedua: Pnt. Jefry Wowor."; "Tandai sudah diperiksa" is `garis`/`tinta3` and pressing it changes nothing; "Diperiksa oleh" reads "Belum diperiksa" in `bata`.
  2. `adaPemeriksaKedua` off → refusal changes to "Tidak dapat dilakukan: belum ada pemeriksa kedua yang ditunjuk. Yang perlu bertindak: BPMJ menunjuk pemeriksa kedua."
  3. `masukSebagai` = Pemeriksa kedua → header "Masuk sebagai Pnt. Jefry Wowor, Pemeriksa kedua"; one `laut` button. Press → step 2 filled, card `permukaan` with a `laut` edge, badge "Sudah diperiksa · belum masuk saldo", "Pnt. Jefry Wowor · 16/11/2026 10.05", no buttons.
  4. Switch back to Bendahara → "Bukukan" and "Ubah" appear (state kept).
  5. "Ubah" → sheet rises; "Kembali" closes it; "Ubah" again then "Ubah dan kembalikan ke Draf" → back to Draf with step 2 dashed.
  6. Through to "Bukukan" → the card is swept with a pale `laut` band in 700 ms, the stamp "No. Bukti BKU-2026-0151" lands after 350 ms tilted −3°, badge "Dibukukan", amount `tinta`, all three steps filled, explanation "Sudah masuk saldo. …", no buttons.
  7. Reduce motion on, Bukukan → stamp and badge appear at once, no sweep.
- **Notes**
  - The Draf "Ubah" button (Bendahara) has no handler on the board; keep it inert.
  - No back control on the board; system Back only.
  - Off-token sizes: 20 (title), 19 (sheet title), radius 8 on the stamp. Copy them. (The 30 px amount is the `jumlahIsian` size, without letter spacing.)
  - BKU-2026-0151 is also the second number Kewajiban hands out; see Kewajiban notes.

### WebPemeriksa — Web · Wajib pemeriksa kedua

- **Source** `docs/design/handoff/canvas/boards/WebPemeriksa.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebPemeriksa`, no child routes · **Widget** `WebPemeriksaScreen` in `lib/screens/lanjut/web_pemeriksa.dart`
- **Purpose** The second-checker queue on a laptop, reached from WebPengaturan ("Wajib pemeriksa kedua"). Three transactions waiting; pick one, act on it per role. Same rule as Pemeriksa; on web "Ubah" returns to Draf directly, without a sheet.
- **Shell** Web side nav: Beranda, **Transaksi** (active), Uang Muka dan Titipan, Rekonsiliasi, Bulan dan tutup buku, Laporan, Pengaturan. Footer "Jemaat Karunia" / "Wajib pemeriksa kedua: hidup" (fixed; no vacancy variant).
- **Layout** (main column)
  1. Title "Transaksi" (26/700) with " · menunggu diperiksa" (15/500, `tinta3`) inline; under it "Masuk sebagai **{siapa}** · Wajib pemeriksa kedua: hidup" (14, `tinta2`).
  2. Two columns (wrap, gap 24, align start):
     - Table card (flex 999 1 520; `permukaan`, 1 px `garis`, radius 14, horizontal scroll, inner min width 700). Grid `140px 96px minmax(0,1fr) 110px 120px`, gap 12. Header (padding 12 16, 13/600 `tinta2`): "Status" | "Tanggal" | "Uraian" | "Dicatat oleh" | "Jumlah (Rp)" (right). Rows are buttons (min height 56, padding 8 16, `garis` top line, 14 px, `aria-pressed` = selected): short status badge (13/700, padding 3 9, radius 6; "Draf": transparent, `tinta2`, 1.5 dashed `putus`; "Sudah diperiksa": `permukaan`, `laut` text, 1.5 `laut`; "Dibukukan": `tinta` field, `permukaan` text, 1.5 `tinta`) | date (`tinta2`) | description (600) | "Meiske L." (`tinta2`) | amount (mono 500, right; `tinta` when Dibukukan, else `tinta3`). Row field: selected → `lautLembut` + 3 px `laut` left line; else Draf → `kertas`; else `permukaan`.
     - Aside (flex 1 1 360, gap 14):
       1. Status card: radius 16, padding 18, gap 6; Draf: transparent + 1.5 dashed `putus`; Sudah diperiksa: `permukaan` + 1.5 `laut`; Dibukukan: `permukaan` + 1.5 `tinta`. Top row: long badge ("Draf · belum masuk saldo", "Sudah diperiksa · belum masuk saldo" or "Dibukukan") and, when Dibukukan, the stamp "No. Bukti {no}" (mono 14/600, `laut`, 2 px `laut`, radius 8, padding 4 10). Amount (mono 32/500, letter spacing −1; `tinta` when Dibukukan, else `tinta2`); description (600); sub-line (13, `tinta3`).
       2. Detail card (`permukaan`, 1 px `garis`, radius 14, padding 4 16; rows padding 10 0): "Dicatat oleh" → "Meiske L."; "Diperiksa oleh" → "Belum diperiksa" (`bata`) in Draf, else "Pnt. Jefry Wowor" (`tinta`); "Dokumen pendukung" → "Diunggah, belum diverifikasi".
       3. Refusal line when present (14/600 `bata`): "Tidak dapat dilakukan: {tolak}".
       4. Buttons (wrap, gap 8): min height 46, padding 0 18, radius 12, 700 14 px; primary `laut`/`diLaut`; secondary `permukaan`, 1.5 `tinta`; disabled `garis`/`tinta3`.
       5. Explanation (13, `tinta3`).
- **Components** LencanaStatus (three statuses, short in rows, long in the card); GarisStatus; TombolBersyarat + Penolakan; Tombol; web side nav. Pattern: selected table row.
- **Internal views and states** One view. Initial state `{ st: { a: 'draf', b: 'draf', c: 'periksa' }, pilih: 'a' }`. Per selected transaction, by its status and the tweak:
  - Draf + Bendahara: "Tandai sudah diperiksa" (disabled), "Ubah" (secondary, no action); refusal "Tidak dapat dilakukan: Anda yang mencatat transaksi ini. Pemeriksa kedua: Pnt. Jefry Wowor."; explanation "Draf belum masuk saldo dan menjadi hambatan tutup buku bulannya."
  - Draf + Pemeriksa kedua: "Tandai sudah diperiksa" (primary); explanation "Menandai sudah diperiksa bukan persetujuan dan belum memasukkan transaksi ke saldo. Bendahara yang membukukan."
  - Sudah diperiksa + Bendahara: "Bukukan" (primary), "Ubah · kembali ke Draf" (secondary); explanation "Mengubah mengembalikan transaksi ke Draf. Tanda sudah diperiksa dan persetujuan yang dicatat hilang dan perlu diberikan lagi."
  - Sudah diperiksa + Pemeriksa kedua: no buttons; explanation "Sudah Anda tandai. Menunggu Bendahara membukukan; tidak ada yang perlu Anda lakukan."
  - Dibukukan: no buttons; explanation "Sudah masuk saldo dan tidak dapat diubah lagi."
- **Tweaks** `masukSebagai`: "Bendahara" | "Pemeriksa kedua" (default "Pemeriksa kedua") → Keadaan panel. Changes the "Masuk sebagai" name ("Meiske L., Bendahara" / "Pnt. Jefry Wowor, Pemeriksa kedua") and the buttons/refusal/explanation above. Switching keeps the statuses.
- **Interactions** Row press → `pilih = id`. "Tandai sudah diperiksa" → status of the selected row = `periksa`. "Bukukan" → `buku`. "Ubah · kembali ke Draf" → `draf` (immediately, no confirmation). Disabled buttons do nothing.
- **Motion** The stamp enters with `muncul` 400 ms, fill both, when a row becomes Dibukukan (also when selecting a row that is already Dibukukan, since it mounts). No sweep on web. Reduce motion: instant.
- **Links out** Side nav only (go): as WebKewajiban. **Inbound** WebPengaturan.
- **Mock data** a: 16/11/2026 "Sewa kursi ibadah padang" −Rp900.000, "Kas · Belanja 5.05.02.00 Sewa peralatan", stamp BKU-2026-0151. b: 15/11/2026 "Honor pemusik" −Rp650.000, "Bank BNI ··4821 · Belanja 5.07.01.00 Honorarium pelayan", stamp BKU-2026-0152. c: 14/11/2026 "Fotokopi warta jemaat" −Rp150.000, "Kas · Belanja 5.02.01.00 Alat tulis dan fotokopi", stamp BKU-2026-0153 (starts Sudah diperiksa). Recorder Meiske L.; checker Pnt. Jefry Wowor.
- **Prototype-only** none on screen; the role is the `masukSebagai` tweak.
- **Acceptance checks**
  1. Open `/WebPemeriksa` → row a selected (`lautLembut`, 3 px `laut` left line); rows a and b are Draf on `kertas`, row c "Sudah diperiksa" on `permukaan`; header "Masuk sebagai Pnt. Jefry Wowor, Pemeriksa kedua"; one `laut` button "Tandai sudah diperiksa".
  2. Press it → row a badge "Sudah diperiksa", card edge `laut`, "Diperiksa oleh Pnt. Jefry Wowor", no buttons, explanation "Sudah Anda tandai. …".
  3. Switch to Bendahara → "Bukukan" and "Ubah · kembali ke Draf". Press "Bukukan" → stamp "No. Bukti BKU-2026-0151" fades up, badge "Dibukukan", amount in row a turns `tinta`.
  4. Select row c as Bendahara → "Ubah · kembali ke Draf" turns it to Draf at once (row field `kertas` when not selected).
  5. Select row b as Bendahara → refusal "Tidak dapat dilakukan: Anda yang mencatat transaksi ini. Pemeriksa kedua: Pnt. Jefry Wowor." above a disabled button.
  6. At 860 px the table scrolls sideways inside its card (min width 700).
- **Notes**
  - Web skips the phone's confirm sheet; keep each board's behaviour.
  - The Draf "Ubah" (Bendahara) has no handler; keep it inert.
  - Buttons are 46 high (between the 44 minimum and the 48 secondary token); copy 46.
  - Off-token: 32 px mono amount, radius 8 stamp.

### BantuanAI — 14 · Bantuan AI saat mencatat

- **Source** `docs/design/handoff/canvas/boards/BantuanAI.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Phone 390×844 · interactive yes
- **Route** `/BantuanAI`, no child routes · **Widget** `BantuanAIScreen` in `lib/screens/lanjut/bantuan_ai.dart`
- **Purpose** Bendahara recording a Belanja with optional AI help: type a sentence, get a suggestion, then Pakai, Ubah or Abaikan. Shows D31 (dotted `laut` edge and italic text for AI), D01 (peruntukan and Lingkup are never suggested or pre-filled), the AI cost states, and that the AI never books.
- **Shell** No tab bar. Own phone header with a back link to Main. Phone vacancy banner on top when `jabatanKosong`.
- **Layout**
  1. Vacancy banner (with `jabatanKosong`).
  2. Header, padding 14 12 8, gap 8: back link 44×44 (chevron, "Kembali ke Beranda") → Main; title "Belanja" (`judulLayar`, flex 1); save status (13/600, `tinta3`, padding-right 8): "Belum tersimpan" or "Tersimpan · Draf".
  3. Scroll area, padding 8 20 20, gap 16:
     1. AI panel (when AI is available): `lautLembut` field, radius 16, padding 14 16, gap 10.
        - Row: label "BANTUAN AI · PILIHAN" (13/700, `lautTua`, letter spacing .3; it labels the text area) and, with `biaya 70%`, "Biaya AI bulan ini 70% dari batas" (13, `tinta`) on the right.
        - Text area, 2 rows, padding 10 12, radius 12, 1 px `laut`, `permukaan`, no resize; value = the sentence.
        - Stage `belum`: button "Buat usulan dari kalimat ini" (min height 44, radius 12, 1.5 `laut`, `permukaan`, `lautTua` text, 700, centred).
        - Stage `proses`: status line (`role=status`, min height 44, gap 8, 14/600 `lautTua`) "Menyusun usulan" followed by three 6 px `laut` dots, gap 4.
        - Stage `ada`: the suggestion card (KartuUsulanAI): `permukaan`, 1.5 dotted `laut` (`usulanAI`), radius 12, padding 4 14, enters with `muncul`. Head row (padding 10 0 6): badge "Usulan AI" (13/700, `lautTua`, 1.5 dotted `laut`, radius 6, padding 2 8) and "dari kalimat Anda" (13, `tinta2`). Five rows (padding 9 0, 1 px dotted `garisTegas` top line): key (14, `tinta2`) | value (14/600 italic `lautTua`, right) with, for the uncertain row, "AI kurang yakin, mohon dicek" under it (13/600, `tinta`). Footer row (13, `tinta3`, padding 8 0, dotted top line): "Peruntukan dan Lingkup tidak diusulkan. Pilih sendiri."
          Then, when stale: "Usulan lama — draf sudah berubah. Buat usulan baru bila masih perlu." (14/600 `tinta`). Then a button row (gap 8, three equal buttons, min height 46, radius 12, 700, centred): "Pakai" (`laut`/`diLaut`; stale → `garis`/`tinta3`), "Ubah" (`permukaan`, 1.5 `tinta`), "Abaikan" (`permukaan`, 1.5 `tinta`). Then the caption "Usulan belum mengisi apa pun. Pakai mengisi draf; Ubah mengisi lalu membuka isian untuk diperbaiki. Tidak perlu alasan." (13, `tinta2`).
     2. AI off box (instead of the panel, when the limit is reached or AI is down): 1 px `garisTegas`, radius 14, padding 12 16, 14 `tinta2`: bold `tinta` title then the text (see Tweaks).
     3. Amount (column, gap 4): "Jumlah (Rp)" (14, `tinta2`), then the figure (mono 36/500, letter spacing −1, 2 px `tinta` underline, padding-bottom 4): "Rp0" in `tinta3` before Pakai, "Rp1.250.000" in `tinta` after.
     4. Field card (`permukaan`, 1 px `garis`, radius 14, padding 4 16): six rows (padding 12 0, `garis` line between): label (14, `tinta2`) | value (14/600, right): "Kas/Bank", "Dibayar kepada", "Tanggal transaksi", "Mata Anggaran", "Diambil dari peruntukan", "Lingkup". Empty value = "Belum diisi" in `tinta3`; filled in `tinta`. Before Pakai only "Tanggal transaksi" has a value: "16 November 2026".
     5. Caption "AI hanya mengusulkan. Membukukan, memverifikasi dokumen dan menutup buku selalu dilakukan orang." (13, `tinta3`).
  4. Bottom bar: `permukaan`, 1 px `garis` top line, padding 12 20 22, gap 6: "Periksa dan bukukan" (min height 52, radius 14, `laut`/`diLaut`, 700) and "Simpan sebagai draf" (min height 44, `laut` text, 700, no field).
- **Components** PitaJabatanKosong; KartuUsulanAI; StatusSimpan (header text); IsianJumlah (display form); Tombol (primary, text); TombolBersyarat-style disabled "Pakai" with the stale sentence as its reason.
- **Internal views and states** One view. Initial state `{ kalimat: 'Bayar PLN Rp1.250.000 dari BNI tanggal 6 Oktober', tahap: 'belum', dasar: '', dipakai: false }`. Stages: `belum` (button), `proses` (dots), `ada` (card), `ada` + stale (`kalimat != dasar`). Filled (`dipakai`) changes the amount, fields and save status and stays filled for the session of the board.
- **Tweaks**
  - `jabatanKosong` (boolean, default off) → Keadaan panel global switch; on: phone vacancy banner.
  - `keadaanAI`: "tersedia" (default) | "biaya 70%" | "batas biaya tercapai" | "sedang tidak tersedia" → Keadaan panel.
    - tersedia: AI panel as above.
    - biaya 70%: AI panel plus "Biaya AI bulan ini 70% dari batas" on the label row.
    - batas biaya tercapai: no panel; box "**Batas biaya AI per bulan tercapai.** Bantuan AI berhenti sampai Desember 2026. Mencatat, membukukan dan tutup buku berjalan seperti biasa."
    - sedang tidak tersedia: no panel; box "**AI sedang tidak tersedia.** Mencatat, membukukan dan tutup buku berjalan seperti biasa."
- **Interactions**
  - Text area change → `kalimat = text`. If a suggestion is shown and the text no longer equals the text it was made from, it is stale.
  - "Buat usulan dari kalimat ini" → remember the current text, `tahap = 'proses'`; after 1300 ms (fakes the AI call) `tahap = 'ada'`, `dasar = remembered text`. A new press cancels a pending timer. No check on an empty sentence.
  - "Pakai" and "Ubah" (same handler on the board) → when not stale: `dipakai = true`, `tahap = 'belum'` (card closes, "Buat usulan…" returns). When stale: nothing.
  - "Abaikan" → `tahap = 'belum'` → back to the "Buat usulan…" button; nothing is filled. Works also when stale.
  - After Pakai: amount "Rp1.250.000"; Kas/Bank "Bank BNI ··4821"; Dibayar kepada "PLN"; Tanggal transaksi "6 Oktober 2026"; Mata Anggaran "Belanja 5.01.02.00 Listrik, air dan telepon"; peruntukan and Lingkup stay "Belum diisi"; header "Tersimpan · Draf".
  - Leaving the screen cancels the 1300 ms timer.
- **Motion** Suggestion card `muncul` 300 ms. Thinking dots `titik`: 1 s loop, opacity .25 → 1 → .25, delays 0, 200, 400 ms. Filled values `turun` 400 ms (opacity 0→1, y −14→0), fill both, staggered by row index × 70 ms: Kas/Bank 0, Dibayar kepada 70, Tanggal transaksi 140, Mata Anggaran 210; runs once when Pakai first fills them. Reduce motion: instant, dots stop at full opacity. (`pudar` declared, unused.)
- **Links out** Back chevron → `/Main` (pop or go). "Periksa dan bukukan" → `/Main` (go). "Simpan sebagai draf" → `/Main` (go). **Inbound** Keputusan, Main.
- **Mock data** Sentence "Bayar PLN Rp1.250.000 dari BNI tanggal 6 Oktober". Suggestion rows: "Jumlah (Rp)" → "Rp1.250.000"; "Kas/Bank" → "Bank BNI ··4821"; "Dibayar kepada" → "PLN"; "Tanggal transaksi" → "6 Oktober 2026"; "Mata Anggaran" → "Belanja 5.01.02.00 Listrik, air dan telepon" (uncertain). Default date 16 November 2026. AI limit resumes Desember 2026; cost warning 70%.
- **Prototype-only** none. The pre-filled sentence is sample content and stays in the screen.
- **Acceptance checks**
  1. Open `/BantuanAI` → header "Belum tersimpan"; sentence pre-filled; "Buat usulan dari kalimat ini"; "Rp0" in `tinta3`; five fields "Belum diisi", Tanggal transaksi "16 November 2026".
  2. Press "Buat usulan dari kalimat ini" → "Menyusun usulan" with three pulsing dots; after 1.3 s the dotted card fades up with five rows; only Mata Anggaran shows "AI kurang yakin, mohon dicek"; values are italic `lautTua`.
  3. Add a word to the sentence → "Usulan lama — draf sudah berubah. Buat usulan baru bila masih perlu." appears; "Pakai" turns `garis`/`tinta3`; pressing "Pakai" or "Ubah" changes nothing.
  4. "Abaikan" → the card closes and the "Buat usulan…" button returns; fields unchanged.
  5. Make a fresh suggestion, press "Pakai" → card closes; amount "Rp1.250.000" in `tinta`; four values drop in one after another (70 ms apart); peruntukan and Lingkup still "Belum diisi"; header "Tersimpan · Draf".
  6. `keadaanAI` = "biaya 70%" → "Biaya AI bulan ini 70% dari batas" on the label row.
  7. `keadaanAI` = "batas biaya tercapai" → panel replaced by the box starting "Batas biaya AI per bulan tercapai."; amount and fields still shown.
  8. Press "Buat usulan…" and leave with Back before 1.3 s → no error, no late state change.
- **Notes**
  - "Ubah" uses the same handler as "Pakai" (the caption promises it also opens the fields; this board has no field editor). Keep the board.
  - When stale, "Ubah" is disabled but keeps its normal look; recommend giving it the same disabled look as "Pakai" (`garis`/`tinta3`) so it does not look pressable. Flag; the board shows the normal look.
  - "Tersimpan · Draf" is `tinta3` here although StatusSimpan says Tersimpan is `laut`. Board wins.
  - AI values ("Rp1.250.000") are italic sans, not mono; keep italic sans (D31). Only upright font files are bundled, so Flutter synthesises the italic; acceptable.
  - The amount shows "Rp0" in grey before filling (IsianJumlah would show a grey "0" hint). Board wins.
  - Off-token: 36 px mono amount.

### WebBantuanAI — Web · Bantuan AI dari kalimat

- **Source** `docs/design/handoff/canvas/boards/WebBantuanAI.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebBantuanAI`, no child routes · **Widget** `WebBantuanAIScreen` in `lib/screens/lengkap/web_bantuan_ai.dart`
- **Purpose** The same AI-from-a-sentence step at the desk, opened from "Dari kalimat" on WebCatat or TabCatat. Same rules and decisions as BantuanAI (D31, D01). The phone's single column becomes two columns: AI panel left, draft right.
- **Shell** Web side nav: Beranda, **Transaksi** (active), Uang Muka dan Titipan, Rekonsiliasi, Bulan dan tutup buku, Laporan, Pengaturan. Footer Bendahara/Operator variant per `jabatanKosong`.
- **Layout** (main column)
  1. Web vacancy banner when `jabatanKosong`.
  2. Heading block: breadcrumb link "Catat transaksi" (14/600, `laut`); title "Catat dari kalimat" (26/700, margin-top 2); "Ketik seperti bercerita. Usulan AI belum mengisi apa pun sampai dipakai." (14, `tinta2`).
  3. Two columns (wrap, gap 24, align start):
     - Left (flex 1 1 400, gap 14): the AI panel exactly as BantuanAI region 3.1 (or the AI off box, region 3.2), then the caption "AI hanya mengusulkan. Membukukan, memverifikasi dokumen dan menutup buku selalu dilakukan orang." (13, `tinta3`).
     - Right (flex 999 1 420, gap 16): head row (space-between, baseline): "Belanja" (17/700) and the save status (13/600 `tinta3`: "Belum tersimpan" / "Tersimpan · Draf"); amount block and six-row field card exactly as BantuanAI regions 3.3–3.4; button row (wrap, gap 8): "Periksa dan bukukan" (min height 46, padding 0 20, radius 12, `laut`/`diLaut`, 700) and "Simpan sebagai draf" (same size, `permukaan`, 1.5 `tinta`, `tinta` text, 700).
- **Components** PitaJabatanKosong (web); KartuUsulanAI; StatusSimpan; IsianJumlah (display); Tombol; web side nav.
- **Internal views and states** Same as BantuanAI: initial state `{ kalimat: 'Bayar PLN Rp1.250.000 dari BNI tanggal 6 Oktober', tahap: 'belum', dasar: '', dipakai: false }`; stages belum / proses / ada / ada + stale; filled.
- **Tweaks** `jabatanKosong` (boolean, default off) → global switch; on: web banner and Operator footer. `keadaanAI`: "tersedia" (default) | "biaya 70%" | "batas biaya tercapai" | "sedang tidak tersedia" → Keadaan panel; effects identical to BantuanAI (warning on the label row, or the off box with the same two texts).
- **Interactions** Identical to BantuanAI: text change; "Buat usulan dari kalimat ini" → proses, 1300 ms timer → ada; "Pakai"/"Ubah" fill when not stale; "Abaikan" → belum; timer cancelled on leave.
- **Motion** Suggestion card `muncul` 300 ms; dots `titik` 1 s loop with 0/200/400 ms delays; filled values `turun` 400 ms staggered 0/70/140/210 ms (see Notes). Reduce motion: instant.
- **Links out** "Catat transaksi" (breadcrumb) → `/WebCatat` (pop or go); "Periksa dan bukukan" → `/WebCatat` (go); "Simpan sebagai draf" → `/WebTransaksi` (go); side nav (go) as WebKewajiban. **Inbound** TabCatat, WebCatat.
- **Mock data** Same as BantuanAI.
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/WebBantuanAI` → side-nav "Transaksi" active; breadcrumb "Catat transaksi"; AI panel left, "Belanja" draft right with "Rp0" and "Belum tersimpan".
  2. "Buat usulan dari kalimat ini" → dots, then after 1.3 s the dotted card with five italic values.
  3. Edit the sentence → stale sentence shows and "Pakai" is disabled.
  4. Fresh suggestion, "Pakai" → right column shows "Rp1.250.000", the four values, "Tersimpan · Draf"; peruntukan and Lingkup "Belum diisi".
  5. `keadaanAI` = "sedang tidak tersedia" → left column shows "AI sedang tidak tersedia. Mencatat, membukukan dan tutup buku berjalan seperti biasa." and the caption; the right column is unchanged.
  6. "Simpan sebagai draf" → `/WebTransaksi`; "Catat transaksi" → `/WebCatat`.
  7. At 860 px the two columns stack (left above right) and the side nav collapses behind "Menu".
- **Notes**
  - The board uses `animation: turun …` on the filled values but does not declare `@keyframes turun`, so on the canvas the values appear without motion. Recommend reproducing `turun` as on BantuanAI (clearly intended); flag it.
  - "Ubah" = "Pakai" and its unchanged look when stale: as BantuanAI.
  - Off-token: 17 px "Belanja", 36 px mono amount.

### WebPaketLaporan — Web · Paket Laporan F01–F14

- **Source** `docs/design/handoff/canvas/boards/WebPaketLaporan.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Laptop page (preview 1440×1200) · interactive yes
- **Route** `/WebPaketLaporan`, no child routes (report choice is in-page state) · **Widget** `WebPaketLaporanScreen` in `lib/screens/lanjut/web_paket_laporan.dart`
- **Purpose** Bendahara, month-end step 5: the official GMIM monthly report pack for Oktober 2026, frozen at month close, report by report. Shows D12 (a reversal prints negative in the same column), D13 (advance settlements are not in F02), D14 (no signatures; link to the format approval), D27 (a TERBATAS copy holds F02, F03, F05, F07, F12), C01 (on screen, Kas/Bank is a second line under Uraian in F02), C04 (final titles, "Nihil", "Sentralisasi / Penyaluran"), R03 (advance settlements Rp0 in October; attachment 2 "Nihil").
- **Shell** Web side nav: Beranda, Transaksi, Uang Muka dan Titipan, Rekonsiliasi, Bulan dan tutup buku, **Laporan** (active), Pengaturan. Footer Bendahara/Operator variant per `jabatanKosong`.
- **Layout** (main column)
  1. Web vacancy banner when `jabatanKosong`.
  2. Title row (wrap, gap 12, centred): "Paket Laporan Bulanan GMIM" (26/700, flex 1 1 320) with " · Oktober 2026" (15/500 `tinta3`) inline; primary "Unduh PDF" (min height 44, padding 0 18, radius 12, `laut`/`diLaut`, 700); secondary "Unduh Excel" (same size, `permukaan`, 1.5 `tinta`, 700).
  3. Link row (margin-top −8, wrap, gap 0 22, 14/600 `laut`, each min 44×44): "Persetujuan format laporan", "Celah nomor", "Halaman A4", "Lihat transaksi di balik sebuah angka".
  4. Official banner (PitaLaporan, official): `tinta` field, `permukaan` text, radius 14, padding 12 16, wrap, gap 4 16, baseline: bold "Laporan resmi{cap}" and, 14 `diTinta2`, "Dibekukan saat tutup buku 16/11/2026 11.05 · ID " + "SNP-2026-10-01" (mono) + " · Versi Mata Anggaran 2026.1". `{cap}` = "" or " · TERBATAS · Peruntukan Diakonia".
  5. Two columns (wrap, gap 24, align start):
     - Report list (flex 1 1 216; `permukaan`, 1 px `garis`, radius 14, padding 6): 14 buttons (min height 44, padding 8 12, radius 10, gap 10, baseline, 14 px): code (mono 13, no shrink) + name (600). Selected: `tinta` field, `permukaan` text; others transparent, `tinta`. Items: F01 Laporan Perbendaharaan Bulanan · F02 Buku Kas Umum · F03 Buku Kas Pembantu · F04 Mata Anggaran Pendapatan · F05 Realisasi Pendapatan Menurut Mata Anggaran · F06 Mata Anggaran Belanja · F07 Realisasi Belanja Menurut Mata Anggaran · F08 Rekap Penerimaan · F09 Rekap Pengeluaran · F10 Posisi Kas & Bank · F11 Rekonsiliasi · F12 Daftar Bukti Kas · F13 Sentralisasi / Penyaluran · F14 Lampiran Laporan Bulanan.
     - Report page (flex 999 1 620; `permukaan`, 1.5 solid `tinta`, radius 6, padding `clamp(18px, 2vw, 28px)`, gap 18):
       1. Page head (2 px `tinta` bottom line, padding-bottom 14, gap 2): "{code} · LAPORAN RESMI{cap}" (13/600 `tinta2`, letter spacing .4); report name upper-cased (22/700, letter spacing .2); "Jemaat Karunia · Periode laporan 1–31 Oktober 2026"; "Format bawaan aplikasi. {description}" (13, `tinta3`).
       2. F01 only: secondary button "Buka halaman F01" (min height 44, padding 0 18, radius 12, 1.5 `tinta`, 700, start-aligned).
       3. F02: Buku Kas Umum table (horizontal scroll, inner min width 820, 13 px). Grid `78px 104px 104px minmax(0,1fr) 100px 100px 104px`, gap 10. Header (padding 8 0, 700, 1 px `tinta` bottom): "Tanggal" | "No. Bukti" | "No. MA" | "Uraian · Kas/Bank" | "Penerimaan" (right) | "Pengeluaran" (right) | saldo title (right). Opening row (600, padding 8 0, `garis` bottom): opening label in the Uraian column, opening balance (mono, right) in the last column. Transaction rows (padding 8 0, `garis` bottom, baseline): date | No. Bukti (mono, a `laut` link) | No. MA (mono; `—` when empty) | Uraian with an optional tag (13/700, 1.5 `tinta3` edge, `tinta2` text, radius 6, padding 0 6, no wrap) and Kas/Bank as a second line (`tinta3`) | receipt (mono right, blank when 0) | payment (mono right, blank when 0) | running balance (mono right). Footer line (padding 10 0, `tinta3`). Under the table (13, `tinta3`): "Pembayaran yang dibagi tampil satu kali dengan daftar No. MA-nya. Pembalikan tampil sebagai angka negatif dan tidak dipotong ke nol. Kolom saldo selalu menyebut Kas/Bank yang dijumlahkannya. Setiap No. Bukti membuka transaksinya."
       4. F03–F14 (full copy, or the TERBATAS versions of F03, F05, F07, F12): subtitle (700); a generic table (horizontal scroll, inner min width per table below, 13 px; grid with the template below, column gap 10), header (padding 8 0) 700 with a 1 px `tinta` bottom line, rows padding 8 0, cells aligned on the baseline, with a 1 px `garis` bottom line — rows flagged "bold" are 700 with a 1 px `tinta` bottom line; right-aligned and mono columns per table; then the footnote (13, `tinta3`).
       5. TERBATAS copy and a report not in it (F01 excepted, see Notes): instead of the table, a dashed box (1.5 dashed `putus`, radius 12, padding 16, 14 `tinta2`): "Laporan ini tidak termasuk salinan TERBATAS. Akses terbatas tidak melihat posisi Kas/Bank, rekening koran, titipan pihak lain, atau daftar yang mencakup seluruh Jemaat. Salinan terbatas memuat F02, F03, F05, F07 dan F12, masing-masing hanya bagian peruntukan Diakonia."
- **Components** PitaJabatanKosong (web); PitaLaporan (official, with TERBATAS title); LencanaStatus-shaped tags in F02 ("Dibalik oleh …", "Pembalikan", "Koreksi dari …"); Tombol (primary, secondary); web side nav. Pattern: the report page frame (1.5 `tinta`, radius 6, 2 px `tinta` head line) and the generic report table.
- **Internal views and states** One view. State `{ pilih: 'F02' }`. Page content per `pilih` × `salinan`: F01 (link button), F02 (BKU table), others (generic table), TERBATAS-excluded (dashed box). The report list does not change with `salinan`.
- **Tweaks**
  - `jabatanKosong` (boolean, default off) → global switch; on: web banner and Operator footer.
  - `salinan`: "Seluruh Jemaat" (default) | "TERBATAS · Peruntukan Diakonia" → Keadaan panel. TERBATAS: the banner and every page head gain " · TERBATAS · Peruntukan Diakonia"; F02 description becomes "Hanya bagian peruntukan Diakonia."; F02 shows two rows from opening "Saldo awal peruntukan Diakonia" Rp3.050.000 with the saldo column "Saldo Diakonia" and footer "2 baris. Jumlah seluruh transaksi, uraian, pelaku dan bagian peruntukan lain tidak ada di salinan ini."; F03, F05, F07, F12 switch to their TERBATAS tables; F04, F06, F08–F14 show the dashed box.
- **Interactions** Report list button → `pilih = code` (no navigation; `aria-pressed`). No typed input.
- **Motion** none (`muncul`, `isi`, `titik` declared, unused).
- **Links out** "Unduh PDF" → `/A4F01` (push); "Unduh Excel" → `/WebExcel` (push); "Persetujuan format laporan" → `/WebFormatLaporan` (push); "Celah nomor" → `/WebBukti` (push); "Halaman A4" → `/A4F01` (push); "Lihat transaksi di balik sebuah angka" → `/WebLihatTransaksi` (push); "Buka halaman F01" → `/WebLaporan` (push); every No. Bukti in F02 → `/WebTransaksi` (push); side nav (go) as WebKewajiban. **Inbound** Keputusan, AIBulan, TabBeranda, TabCatat, TabTransaksi and the side nav of every Bendahara web board (see manifest).
- **Mock data**
  - Report descriptions ("Format bawaan aplikasi. …"): F01 "Saldo awal dan akhir Kas/Bank, Pendapatan dan Belanja, Dana Transit masuk dan keluar, uang muka, kesimpulan rekonsiliasi." F02 "Semua Kas/Bank dalam satu buku, dengan label Kas/Bank per baris." (TERBATAS: "Hanya bagian peruntukan Diakonia.") F03 "Per Kas/Bank, per peruntukan, per Lingkup, per Uang Muka, per Titipan untuk." F04 and F06 "Semua baris versi yang diterbitkan, sesuai urutan sumber." F05 "Pendapatan per baris, termasuk baris bernilai Rp0. Tanpa kolom anggaran." F07 "Belanja per baris. Tanpa kolom anggaran." F08 "Penerimaan buku, tiap ukuran di kolomnya sendiri." F09 "Pengeluaran buku, termasuk belanja dari uang muka." F10 "Saldo buku, hasil hitung kas dan saldo rekening koran di kolom terpisah." F11 "Per Kas/Bank: item dalam perjalanan, saldo pembanding, yang cocok dan belum cocok." F12 "Daftar No. Bukti dengan persetujuan, dokumen pendukung dan pengecualian." F13 "Titipan per pihak: terkumpul, disalurkan, sisa. Sentralisasi dari uang milik sendiri terpisah." F14 "Delapan lampiran. Lampiran tanpa isi dicetak sebagai Nihil."
  - F02, full copy: saldo title "Saldo semua Kas/Bank", opening "Saldo awal Kas/Bank" Rp36.250.000, 31 rows, footer "31 baris · Saldo akhir Kas/Bank Rp38.465.000". Rows (date · No. Bukti · No. MA · Uraian [tag] · Kas/Bank line · receipt · payment · running balance):

    | Tanggal | No. Bukti | No. MA | Uraian [tag] | Kas/Bank | Penerimaan | Pengeluaran | Saldo |
    | --- | --- | --- | --- | --- | --- | --- | --- |
    | 04/10/2026 | BKU-2026-0098 | 1.3.53.07.00; 1.3.55.01.00 | Persembahan Ibadah Minggu dan Diakonia | Kas; Bank BNI ··4821 | Rp4.150.000 | | Rp40.400.000 |
    | 04/10/2026 | BKU-2026-0099 | 2.1.01.02.00 | Titipan untuk: Sinode · Sentralisasi | Kas | Rp600.000 | | Rp41.000.000 |
    | 05/10/2026 | BKU-2026-0100 | 5.07.01.00 | Honorarium pelayan | Bank BNI ··4821 | | Rp1.820.000 | Rp39.180.000 |
    | 06/10/2026 | BKU-2026-0101 | 5.01.02.00; 5.02.01.00 | Toko Sinar: listrik dan alat tulis, satu pembayaran | Bank BNI ··4821 | | Rp1.250.000 | Rp37.930.000 |
    | 06/10/2026 | BKU-2026-0102 | — | Setoran ke bank: ke Bank BNI ··4821 | Kas ke Bank BNI | Rp5.000.000 | Rp5.000.000 | Rp37.930.000 |
    | 07/10/2026 | BKU-2026-0103 | — | Uang Muka diberikan · Pnt. Jefry Wowor | Kas | | Rp400.000 | Rp37.530.000 |
    | 08/10/2026 | BKU-2026-0104 | — | Setoran ke bank: ke Bank SulutGo ··1107 | Kas ke Bank SulutGo | Rp1.500.000 | Rp1.500.000 | Rp37.530.000 |
    | 09/10/2026 | BKU-2026-0105 | 5.02.01.00 | Konsumsi rapat majelis [Dibalik oleh BKU-2026-0109] | Kas | | Rp750.000 | Rp36.780.000 |
    | 10/10/2026 | BKU-2026-0106 | — | Pengembalian sisa uang muka · Panitia HUT Jemaat | Kas | Rp350.000 | | Rp37.130.000 |
    | 11/10/2026 | BKU-2026-0107 | 1.3.53.07.00 | Persembahan Ibadah Minggu | Kas | Rp2.650.000 | | Rp39.780.000 |
    | 11/10/2026 | BKU-2026-0108 | 2.1.01.02.00 | Titipan untuk: Sinode · Sentralisasi | Kas | Rp600.000 | | Rp40.380.000 |
    | 12/10/2026 | BKU-2026-0109 | 5.02.01.00 | Pembalikan BKU-2026-0105 [Pembalikan] | Kas | | −Rp750.000 | Rp41.130.000 |
    | 12/10/2026 | BKU-2026-0110 | 5.04.01.00 | Konsumsi rapat majelis [Koreksi dari BKU-2026-0105] | Kas | | Rp750.000 | Rp40.380.000 |
    | 18/10/2026 | BKU-2026-0114 | 1.3.53.07.00 | Persembahan Ibadah Minggu | Kas | Rp2.400.000 | | Rp42.780.000 |
    | 18/10/2026 | BKU-2026-0115 | 1.4.10.02.00 | Sumbangan donatur | Bank BNI ··4821 | Rp700.000 | | Rp43.480.000 |
    | 18/10/2026 | BKU-2026-0117 | 2.1.01.02.00 | Titipan untuk: Sinode · Sentralisasi | Kas | Rp600.000 | | Rp44.080.000 |
    | 20/10/2026 | BKU-2026-0112 | — | Uang Muka diberikan · Sdri. Natalia Rumengan | Kas | | Rp800.000 | Rp43.280.000 |
    | 20/10/2026 | BKU-2026-0113 | 1.3.53.09.00 | Persembahan syukur | Kas | Rp1.220.000 | | Rp44.500.000 |
    | 22/10/2026 | BKU-2026-0116 | 5.08.02.00 | Pemeliharaan atap gedung | Bank BNI ··4821 | | Rp5.500.000 | Rp39.000.000 |
    | 25/10/2026 | BKU-2026-0119 | — | Uang Muka diberikan · Ibu Selvie Kalalo | Kas | | Rp300.000 | Rp38.700.000 |
    | 25/10/2026 | BKU-2026-0123 | 1.3.53.07.00 | Persembahan Ibadah Minggu | Kas | Rp2.700.000 | | Rp41.400.000 |
    | 25/10/2026 | BKU-2026-0125 | 2.1.01.02.00 | Titipan untuk: Sinode · Sentralisasi | Kas | Rp600.000 | | Rp42.000.000 |
    | 26/10/2026 | BKU-2026-0120 | 5.07.01.00 | Honorarium pelayan | Bank BNI ··4821 | | Rp1.820.000 | Rp40.180.000 |
    | 26/10/2026 | BKU-2026-0130 | — | Setoran ke bank: ke Bank BNI ··4821 | Kas ke Bank BNI | Rp2.690.000 | Rp2.690.000 | Rp40.180.000 |
    | 27/10/2026 | BKU-2026-0118 | 1.3.53.09.00 | Persembahan syukur | Bank BNI ··4821 | Rp500.000 | | Rp40.680.000 |
    | 27/10/2026 | BKU-2026-0122 | 4.03.04.00 | Diakonia sakit | Kas | | Rp300.000 | Rp40.380.000 |
    | 28/10/2026 | BKU-2026-0121 | 1.4.10.02.00 | Sumbangan donatur | Bank BNI ··4821 | Rp500.000 | | Rp40.880.000 |
    | 30/10/2026 | BKU-2026-0127 | — | Pindah antar Kas/Bank: Bank BNI ke Kas | Bank BNI ke Kas | Rp2.000.000 | Rp2.000.000 | Rp40.880.000 |
    | 30/10/2026 | BKU-2026-0128 | 2.1.01.02.00 | Penyaluran · Titipan untuk: Sinode | Bank BNI ··4821 | | Rp2.400.000 | Rp38.480.000 |
    | 31/10/2026 | BKU-2026-0131 | — | Setoran ke bank: ke Bank BNI ··4821 | Kas ke Bank BNI | Rp500.000 | Rp500.000 | Rp38.480.000 |
    | 31/10/2026 | BKU-2026-0133 | 5.03.03.00 | Biaya administrasi bank | Bank BNI ··4821 | | Rp15.000 | Rp38.465.000 |

    Running balance = previous + receipt − payment, so the reversal (payment −Rp750.000) raises it.
  - F02, TERBATAS: opening "Saldo awal peruntukan Diakonia" Rp3.050.000; 04/10/2026 · BKU-2026-0098 · 1.3.55.01.00 · "Bagian peruntukan Diakonia" · receipt Rp950.000 · Rp4.000.000; 27/10/2026 · BKU-2026-0122 · 4.03.04.00 · "Bagian peruntukan Diakonia" · payment Rp300.000 · Rp3.700.000 (no Kas/Bank line).
  - Generic tables (rows and figures exactly as in the source lines named; "R" = right-aligned columns, "M" = mono columns, by 0-based index; min width = sum of px columns + 10 per px column + 170 when a `fr` column exists):

    | Report | Source lines | Subtitle | Columns | Template | R | M | Min width | Bold rows | Footnote |
    | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
    | F03 | 148–150 | Buku per Kas/Bank · Kas | Tanggal, No. Bukti, Uraian, Penerimaan, Pengeluaran, Saldo Kas | 84px 118px 1fr 112px 112px 120px | 3,4,5 | 1,3,4,5 | 766 | "Saldo awal Kas" Rp4.070.000 | "22 baris Kas · Saldo akhir Kas Rp8.750.000. Buku pembantu juga dibuat per peruntukan, per Lingkup, per Uang Muka dan per Titipan untuk." |
    | F04 | 151–153 | Versi Mata Anggaran 2026.1 | No. MA, Nama Mata Anggaran, Jenis baris, Boleh untuk | 150px 1fr 250px 130px | — | 0 | 730 | PERSEMBAHAN, SUMBANGAN | "Contoh 6 dari 131 baris, sesuai urutan sumber. Nomor dan nama dicetak persis seperti tersimpan." |
    | F05 | 154–156 | Pendapatan menurut Mata Anggaran | No. MA, Nama Mata Anggaran, Oktober 2026 | 150px 1fr 170px | 2 | 0,2 | 510 | PERSEMBAHAN Rp13.620.000, SUMBANGAN Rp1.200.000, Jumlah Pendapatan Rp14.820.000 | "Contoh 7 dari 131 baris. Baris tanpa transaksi tetap dicetak sebagai Rp0. Tidak ada kolom anggaran, selisih atau persentase." |
    | F06 | 157–159 | Versi Mata Anggaran 2026.1 | as F04 | as F04 | — | 0 | 730 | BELANJA OPERASIONAL, BELANJA PELAYANAN | "Contoh 6 dari 158 baris, sesuai urutan sumber." |
    | F07 | 160–162 | Belanja menurut Mata Anggaran | No. MA, Nama Mata Anggaran, Oktober 2026 | 150px 1fr 170px | 2 | 0,2 | 510 | BELANJA OPERASIONAL Rp11.155.000, BELANJA PELAYANAN Rp300.000, Jumlah Belanja Rp11.455.000 | "Contoh 9 dari 158 baris. Alat tulis dan fotokopi sudah memuat pembalikan BKU-2026-0109; koreksinya masuk ke Konsumsi rapat. Tidak ada kolom anggaran." |
    | F08 | 163–165 | Penerimaan buku per Kas/Bank | Kas/Bank, Pendapatan, Titipan masuk, Pengembalian sisa uang muka, Pindah masuk, Jumlah penerimaan | 1fr 112px 112px 140px 112px 124px | 1–5 | 1–5 | 820 | Jumlah (… Rp29.260.000) | "Penerimaan bukan Pendapatan: kolom Pindah masuk, Titipan masuk dan Pengembalian sisa uang muka tidak pernah dijumlahkan ke Pendapatan." |
    | F09 | 166–168 | Pengeluaran buku per Kas/Bank | Kas/Bank, Belanja, Titipan disalurkan, Uang Muka diberikan, Pindah keluar, Jumlah pengeluaran | 1fr 112px 124px 124px 112px 124px | 1–5 | 1–5 | 816 | Jumlah (… Rp27.045.000) | "Belanja dari pertanggungjawaban uang muka dicetak di baris tersendiri dan tidak mengurangi Kas/Bank lagi: Rp0 pada Oktober 2026." |
    | F10 | 169–171 | Per 31 Oktober 2026 | Kas/Bank, Saldo buku, Hasil hitung kas, Saldo rekening koran, Selisih belum dijelaskan | 1fr 140px 140px 160px 170px | 1–4 | 1–4 | 820 | none | "Hasil hitung kas dan saldo rekening koran berada di kolom terpisah dan tidak dijumlahkan. Bank BNI: setoran dalam perjalanan Rp500.000 dijelaskan di F11." |
    | F11 | 172–174 | Per Kas/Bank | Baris, Kas, Bank BNI ··4821, Bank SulutGo ··1107 | 1fr 140px 150px 160px | 1–3 | 1–3 | 650 | Saldo pembanding, Saldo buku, Selisih belum dijelaskan | "Item dalam perjalanan dibawa ke November 2026 dan dicetak lagi di laporan bulan itu sampai cocok." |
    | F12 | 175–177 | No. Bukti Oktober 2026 | No. Bukti, Tanggal, Uraian, Jumlah (Rp), Persetujuan, Dokumen pendukung saat tutup buku | 104px 78px 1fr 104px 150px 160px | 3 | 0,3 | 816 | none | "Contoh 5 dari 33 baris. Kolom dokumen pendukung mencetak status saat tutup buku; dokumen susulan tidak mengubah halaman ini." |
    | F13 | 178–180 | Titipan per pihak, lalu Sentralisasi dari uang milik sendiri | Titipan untuk, Sisa awal, Terkumpul, Disalurkan, Sisa belum disalurkan | 1fr 130px 130px 130px 170px | 1–4 | 1–4 | 770 | Jumlah titipan | "Judul “Sentralisasi / Penyaluran” menggantikan judul sumber “Sentralisasi / Settlement”." |
    | F14 | 181–183 | Delapan lampiran | (blank), Lampiran, Isi pada Oktober 2026 | 40px 1fr 260px | — | 0 | 490 | none | "Lampiran tanpa isi dicetak sebagai “Nihil”, bukan halaman kosong." |
    | F03 T | 187 | Buku per peruntukan · Diakonia · TERBATAS | Tanggal, No. Bukti, No. MA, Penerimaan, Pengeluaran, Saldo Diakonia | 84px 118px 130px 120px 120px 130px | 3,4,5 | 1–5 | 762 | opening Rp3.050.000 (no label) | "2 baris. Uraian, pelaku dan bagian peruntukan lain tidak dicetak di salinan ini." |
    | F05 T | 188 | Pendapatan peruntukan Diakonia · TERBATAS | No. MA, Nama Mata Anggaran, Oktober 2026 | 150px 1fr 170px | 2 | 0,2 | 510 | Jumlah Pendapatan peruntukan Diakonia Rp950.000 | "Hanya baris yang punya bagian Diakonia. Baris peruntukan lain tidak dicetak, juga tidak sebagai Rp0." |
    | F07 T | 189 | Belanja peruntukan Diakonia · TERBATAS | No. MA, Nama Mata Anggaran, Oktober 2026 | 150px 1fr 170px | 2 | 0,2 | 510 | Jumlah Belanja peruntukan Diakonia Rp300.000 | "Hanya baris yang boleh dipakai peruntukan Diakonia." |
    | F12 T | 190 | No. Bukti dengan bagian Diakonia · TERBATAS | No. Bukti, Tanggal, Bagian Diakonia, Dokumen pendukung saat tutup buku | 130px 100px 160px 1fr | 2 | 0,2 | 590 | none | "Status dokumen dicetak; file aslinya, jumlah seluruh transaksi dan nama pemberi persetujuan tidak disertakan." |

    (`1fr` stands for the board's `minmax(0, 1fr)`.) Key figures: F10 Kas Rp8.750.000 / Rp8.750.000 / — / Rp0; Bank BNI ··4821 Rp24.600.000 / — / Rp24.100.000 / Rp0; Bank SulutGo ··1107 Rp5.115.000 / — / Rp5.115.000 / Rp0 (blank cells are empty strings, not `—`). F11 matches "13 / 0" and "1 / 0", status "Sudah dipastikan" ×3. F12 negatives "−Rp1.250.000", "−Rp750.000", "−Rp5.500.000"; BKU-2026-0116 "Sudah dicatat · Ketua BPMJ", "Dikecualikan · kuitansi menyusul". F13 Sinode Rp0 / Rp2.400.000 / Rp2.400.000 / Rp0. F14 rows "1 Uang Muka · 3 kasus", "2 Rincian Pertanggungjawaban Uang Muka · Nihil", "3 Penghitungan Persembahan · 4 ibadah", "4 Penggantian Biaya · Nihil", "5 Pengecualian Dokumen Pendukung · 1 dokumen", "6 Pembalikan dan Koreksi · 1 rangkaian", "7 Saldo Awal Pencatatan · Nihil", "8 Hasil Pengecekan Otomatis · 8 syarat terpenuhi".
  - Banner: closed 16/11/2026 11.05, ID SNP-2026-10-01, Versi Mata Anggaran 2026.1; period 1–31 Oktober 2026; church Jemaat Karunia.
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/WebPaketLaporan` → side-nav "Laporan" active; F02 selected (`tinta` field); page head "F02 · LAPORAN RESMI", "BUKU KAS UMUM"; opening "Saldo awal Kas/Bank" Rp36.250.000; 31 rows; last balance "Rp38.465.000"; footer "31 baris · Saldo akhir Kas/Bank Rp38.465.000".
  2. Row BKU-2026-0109 shows tag "Pembalikan", "−Rp750.000" in Pengeluaran and balance "Rp41.130.000"; row BKU-2026-0105 has tag "Dibalik oleh BKU-2026-0109"; every row has its Kas/Bank on a second `tinta3` line.
  3. Click F05 → table with 8 rows; PERSEMBAHAN, SUMBANGAN and "Jumlah Pendapatan Rp14.820.000" are bold with a `tinta` line; "Sumbangan natura" shows "Rp0".
  4. Click F01 → page shows only the head and "Buka halaman F01"; pressing it opens `/WebLaporan`.
  5. `salinan` = TERBATAS → banner "Laporan resmi · TERBATAS · Peruntukan Diakonia"; F02 shows two rows from "Saldo awal peruntukan Diakonia" Rp3.050.000, column "Saldo Diakonia", balances Rp4.000.000 then Rp3.700.000.
  6. TERBATAS + F04 → the dashed box "Laporan ini tidak termasuk salinan TERBATAS. …"; TERBATAS + F12 → two-row table with "−Rp300.000" under "Bagian Diakonia".
  7. Click a No. Bukti in F02 → `/WebTransaksi`; Back returns with F02 still selected.
  8. "Unduh PDF" and "Halaman A4" → `/A4F01`; "Unduh Excel" → `/WebExcel`; "Celah nomor" → `/WebBukti`.
  9. At 860 px the report page keeps its tables scrollable sideways (F02 min width 820) and the side nav collapses behind "Menu".
- **Notes**
  - In TERBATAS mode F01 still shows "Buka halaman F01", though D27 leaves F01 out of the restricted copy. The board wins; flag it.
  - TERBATAS F03's opening row has no label (only Rp3.050.000 in the last column). Keep as drawn; flag.
  - Every No. Bukti links to WebTransaksi, not to the individual transaction. Keep.
  - The F02 caption under the table stays the same in TERBATAS mode.
  - Off-token: 22 px page title; radius 6 on the report page (= `lencana` value); 13 px table text is `keterangan`.
  - Figures here (F03 TERBATAS Rp3.700.000, F14 "3 kasus") differ from Terbatas and the case boards; list in `mock-data.md`.
