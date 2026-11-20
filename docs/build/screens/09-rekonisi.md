# Screens 09: RekonIsi, WebRekonIsi, AlihPeruntukan, WebAlihPeruntukan, UbahPengaturan, WebUbahPengaturan, PilihBulan, WebPilihBulan, Pemulihan, WebPemulihan

These ten boards sit on the canvas page "Pelengkap" (`lengkap`). They are five phone/laptop pairs that fill gaps in the Bendahara Jemaat's finance work and in the sign-in path.

- **RekonIsi / WebRekonIsi**: the rekening koran of Bank BNI ··4821 for Oktober 2026. The Bendahara enters its closing balance, reads the mutations from a CSV or types one, matches each mutation to one or more posted transactions (partial matching) and confirms. Reached from TutupBuku and WebRekonsiliasi ("Isi rekening koran").
- **AlihPeruntukan / WebAlihPeruntukan**: moves money between peruntukan inside one Kas/Bank, with a required basis (D04). Reached from Main's Catat sheet, from Keputusan (decision 4) and from WebCatat/TabCatat ("Alih peruntukan").
- **UbahPengaturan / WebUbahPengaturan**: adds a Kas/Bank, changes the No. Bukti series or the approval rule, always as a new version that starts in a later month (D23, D24). Reached from Lainnya, Keputusan (decisions 23 and 24) and WebPengaturan.
- **PilihBulan / WebPilihBulan**: the month picker of the Transaksi list, with a closed month and an empty month. Reached from Main's month pill and "Pilih bulan", LihatTransaksi, WebBeranda, WebTransaksi, WebLihatTransaksi, TabBeranda and TabTransaksi.
- **Pemulihan / WebPemulihan**: account recovery with the backup email (P06, P07). Reached from Masuk/AlurMasuk and WebMasuk/WebAlurMasuk. It ends on Beranda (Main / WebBeranda) or Akun saya (AkunSaya / WebAkunSaya).

None of the phone boards has a tab bar. Four have a phone header with a back arrow; PilihBulan has no back control at all. Four web boards use the standard finance side nav (specified once under WebRekonIsi). WebPemulihan uses the signed-out side nav.

The two boards of a pair run the same logic class. Put the pure state and derived values as one plain Dart class in the phone file and import it from the web file. Each screen still owns its own instance, so the two boards never share state.

**Up link**, used in the Links bullets below, means a phone back arrow or a web breadcrumb. It pops when the route directly beneath is the target or one of the target's child routes; otherwise it does `go` to the target. Side-nav items use `go`, and drill-ins into other boards use `push`.

All copy is quoted from the boards. "Today" is 16/11/2026 and the actor is Meiske L., Bendahara, unless `jabatanKosong` is on. The two shared pieces used below are:

- **Phone header** (RekonIsi, AlihPeruntukan, UbahPengaturan, Pemulihan): a row, items centred, gap 8, padding 14 12 8.
  - Back link 44×44, centred 22 px chevron (path `M15 6l-6 6 6 6`, stroke 2, round caps, `tinta`), with a Semantics label (given per board).
  - Then a column, flex 1: h1 `judulLayar` (18/700), and under it an optional subtitle in 13 px `tinta2`. The source writes `font-size: 14px; … font-size: 13px`, and the later 13 wins.
- **Phone PitaJabatanKosong line** (with `jabatanKosong`): flex none, `tinta` field, `permukaan` text, padding 10 24 8, 13 px, line height 1.3, centred, `role=status`. Text: bold "Menjalankan jabatan kosong" then " · Bendahara Jemaat".

---

### RekonIsi — 30 · Rekonsiliasi: isi rekening koran dan cocok sebagian

- **Source** `docs/design/handoff/canvas/boards/RekonIsi.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/RekonIsi`, no child routes (every change happens in place on one scrolling screen) · **Widget** `RekonIsiScreen` in `lib/screens/lengkap/rekon_isi.dart`
- **Purpose**
  - **Who and when**: the Bendahara Jemaat on the phone at month end (journey "Bendahara Jemaat" step 4, with "2 · Akhir bulan" and "5 · Hitung kas").
  - **What she does**, for Bank BNI ··4821, Oktober 2026:
    - enters the closing balance of the rekening koran;
    - loads the bank mutations from a CSV, or types one;
    - matches each mutation to one or more posted transactions (partial matching: one bank credit of Rp1.000.000 against two Rp500.000 transactions) until "Sisa belum dicocokkan" is Rp0;
    - confirms the reconciliation.
  - **Rules it shows**:
    - "Not yet known is not zero" ("Rekening koran belum diisi. Kosong bukan Rp0.").
    - Tahapan with the optional second checker ("Wajib pemeriksa kedua", Pnt. Jefry Wowor).
    - The statuses "Sudah dipastikan" / "Perlu dipastikan lagi". The board draws them as the last Tahapan chip and the title of the hambatan card, not as LencanaStatus badges. A change to the October book after confirming voids the confirmation and becomes a hambatan for tutup buku.
    - The PitaJabatanKosong line.
  - **Decisions**: no numbered decision.
- **Shell** Phone, no tab bar.
  - Root: 390×844, `kertas`, `tinta` text, `isi` (16/1.4), column.
  - The PitaJabatanKosong line sits on top when `jabatanKosong` is on.
  - The rest is the phone header (back label "Kembali ke Bulan") over one scroll body that fills the remaining height.
- **Layout**
  1. *PitaJabatanKosong line* (only with `jabatanKosong`).
  2. *Header*: h1 "Rekonsiliasi", subtitle "Bank BNI ··4821 · Oktober 2026".
  3. *Scroll body*: padding 8 20 20, column, gap 16, scrolls vertically. Children in order:
     - a. **Input card**: `permukaan`, 1 `garis` (dibukukan), radius 14, padding 16, column gap 12.
       - **Saldo field**:
         - Label "Saldo rekening koran" (14, `tinta2`).
         - Under it a row (baseline, gap 6, 2 px `tinta` underline, padding-bottom 4). The row holds "Rp" (mono 18, `tinta3`) and the input: mono 26/500, transparent, no border, no padding, min height 44, placeholder "—", numeric keyboard.
         - Under the row, margin-top 4, a 13/600 caption:
           - empty: `bata` "Rekening koran belum diisi. Kosong bukan Rp0.";
           - filled: `tinta2` "Saldo rekening koran per 31/10/2026".
       - **Upload button**, only while no CSV is loaded and the state is `kerja`: full width, min height 48, radius 14, 1.5 `tinta`, `permukaan`, `tinta` 700, centred, padding 0 16. Label "Unggah mutasi dari file CSV".
       - **CSV line**, once loaded: 14 `tinta2`, enters with `muncul` 300 ms. Bold `tinta` "mutasi-bni-okt.csv", then " · 3 mutasi dibaca. Belum ada yang dicocokkan."
       - **Typing block**, only in state `kerja`: top border 1 `garis`, padding-top 12, column gap 8.
         - "Atau ketik satu mutasi" (14, `tinta2`).
         - Text input: full width, min height 48, padding 0 14, radius 12, 1 `garisTegas`, `permukaan`. Placeholder "Uraian di rekening koran", Semantics "Uraian mutasi".
         - A row, gap 8:
           - Amount input, flex 1: same box but mono, numeric keyboard, placeholder "Jumlah masuk", Semantics "Jumlah mutasi".
           - Button "Tambah": flex none, min height 48, padding 0 16, radius 12, 1.5 `tinta`, `permukaan`, 700.
     - b. **Mutation list**, one block:
       - **No mutation yet**: a draf box with 1.5 dashed `putus`, radius 14, padding 16, 14 `tinta2`: "Belum ada mutasi bank. Unggah file CSV dari bank, atau ketik satu per satu."
       - **Otherwise, one card per mutation**, 12 apart (margin-bottom 12). The last card keeps its margin-bottom 12 too, so on the phone the Tahapan row sits 12 + 16 = 28 below it.
         - Card box: `permukaan`, radius 14, padding 14 16, column gap 6.
         - Border: 1.5 `laut` when the mutation is matched in full ("Cocok"); otherwise 1 `garis`.
         - Line 1 (space-between, centred, gap 16): the match badge on the left, the amount (`jumlah`, mono 16/500, `tinta`) on the right.
         - The match badge is 13/700, radius 6, padding 3 9, 1.5 border, in three looks:
           - "Cocok": `laut` field, `diLaut` text, `laut` border.
           - "Sebagian cocok": `permukaan`, `tinta` text, `tinta` border.
           - "Belum cocok": `permukaan`, `tinta2` text, `tinta3` border.
         - Line 2: the bank text (600), then inline " · ‹tanggal›" (13/400 `tinta3`).
         - Remainder line, only for "Sebagian cocok": 14/700 `tinta`, "sisa belum dicocokkan: Rp500.000".
         - One line per matched transaction: mono 13 `tinta2`, entering with `muncul` 300 ms. For example "↔ BKU-2026-0118 · Persembahan syukur · Rp500.000". The source writes 14 then 13, and 13 wins.
         - Action line (inline, wrapping). Its wrapper is always present, so even when it holds nothing (state not `kerja`, or a typed mutation) it still adds one 6 px column gap at that place:
           - One button per remaining candidate, only while `st` is `kerja`: inline, min height 44, padding 0 12, margin 4 8 0 0, radius 10, 1.5 `tinta`, `permukaan`, 700 13. Text "Cocokkan · " followed by a mono span (margin-left 4) "‹No. Bukti› · ‹rp›", for example "Cocokkan · BKU-2026-0121 · Rp500.000".
           - Then the text button "Lepaskan", only while `st` is `kerja` and the card has at least one matched transaction: min height 44, padding 0 12, margin-top 4, no border, no fill, `laut` 700 14.
         - No-candidate line (typed mutations only): 14 `tinta2`, "Belum ada transaksinya. Buat transaksi dari mutasi ini, atau periksa lagi rekening korannya."
     - c. **Tahapan row**: wrap, gap 6.
       - Chips: min height 30, padding 0 10, radius 999, 13/700.
       - Done: `tinta` field, `permukaan` text, 1.5 `tinta`. Not done: transparent, `tinta3` text, 1.5 dashed `putus`.
       - Labels without the second checker: "1 · Sedang dikerjakan", "2 · Sudah dipastikan". With it: "1 · Sedang dikerjakan", "2 · Sudah diperiksa", "3 · Sudah dipastikan".
     - d. **Total row**: top border 1.5 `tinta`, padding-top 10, space-between, baseline, gap 16.
       - Left: "Sisa belum dicocokkan" (700).
       - Right: the total, mono 22/600, `laut` when it is 0 and there is at least one mutation, otherwise `bata`.
     - e. **Invalid card** (hambatan), only in the invalid state: `permukaan`, 1.5 `bata` (the source sets 1 `garis` and then overrides it), radius 14, padding 14 16, column gap 8. Enters with `muncul` 300 ms.
       - "Perlu dipastikan lagi" (700, `bata`).
       - 14 `tinta2`: "BKU-2026-0127 dibalik setelah rekonsiliasi dipastikan. Pencocokan tetap tersimpan; hanya kepastiannya yang tidak berlaku lagi, dan ini menjadi hambatan tutup buku."
       - Button "Pastikan lagi": hugs its text (align start), min height 46, padding 0 20, radius 12, no border, `laut`, `diLaut` 700.
     - f. **Confirmed card**, only when confirmed and not invalid: `lautLembut`, radius 14, padding 14 16, 600, enters with `muncul` 300 ms. Text: "Sudah dipastikan oleh ‹plk›, 16/11/2026. Perubahan pada buku Oktober membuatnya perlu dipastikan lagi.", where ‹plk› is "Meiske L." or, with `jabatanKosong`, "Yanti Sumual, Operator".
     - g. **Action**, only in states `kerja` and `periksa`. Two direct children of the scroll body, so they sit 16 apart:
       - The reason line (14 `tinta2`).
       - The button: full width, min height 52, radius 14, no border, 700, centred, padding 0 20. Ready: `laut` field, `diLaut` text. Not ready: `garis` field, `tinta3` text. Its label depends on the state (see Internal views).
- **Components**
  - PitaJabatanKosong (phone line).
  - An IsianJumlah variant for the saldo field (26 px, not 30).
  - TombolBersyarat for "Pastikan rekonsiliasi" / "Tandai sudah diperiksa", with the reason above it.
  - Tahapan.
  - Tombol: secondary "Unggah mutasi dari file CSV", "Tambah" and "Cocokkan · …"; text "Lepaskan"; primary "Pastikan lagi".
  - The match badge reuses the LencanaStatus box, but its three words (Cocok, Sebagian cocok, Belum cocok) are not in the LencanaStatus table. Build it as a local badge that uses the LencanaStatus padding and radius.
  - Repeated pattern, not a component: the mutation card.
  - Line language:
    - draf: the empty box and the Tahapan chips not yet reached;
    - dibukukan: the input card and the unmatched mutation cards;
    - hambatan: the invalid card.
- **Internal views and states**
  - **Initial state**: `{ saldo: '', csv: false, tambah: [], fu: '', fj: '', m: {}, st: 'kerja', lagi: false }`. `st` runs `kerja` → (`periksa`, only with the second checker) → `pasti`.
  - **Transactions T**:

    | Key | No. Bukti | Text | Amount |
    | --- | --- | --- | --- |
    | t1 | BKU-2026-0118 | "Persembahan syukur" | 500000 |
    | t2 | BKU-2026-0121 | "Sumbangan donatur" | 500000 |
    | t3 | BKU-2026-0127 | "Pindah antar Kas/Bank: Bank BNI ke Kas" | −2000000 |
    | t4 | BKU-2026-0133 | "Biaya administrasi bank" | −15000 |

  - **Mutations L**:
    - When `csv` is true, three mutations:

      | Id | Text | Date | Amount | Candidates | Pre-matched |
      | --- | --- | --- | --- | --- | --- |
      | l1 | "TRF MASUK IBU RUNTU" | 28/10/2026 | 1000000 | t1, t2 | none |
      | l2 | "TARIK TUNAI" | 30/10/2026 | −2000000 | t3 | none |
      | l3 | "BIAYA ADM" | 31/10/2026 | −15000 | t4 | t4 |

    - Typed mutations follow, each dated 31/10/2026, with no candidates.
  - **Derived values**:
    - Matched list of a mutation: `m[id]` when that key is set, even to an empty list; otherwise its pre-match; otherwise empty.
    - sisa = amount − Σ matched amounts.
    - Badge: "Cocok" when sisa = 0; "Sebagian cocok" when sisa ≠ 0 and something is matched; "Belum cocok" otherwise.
    - Total = Σ |sisa|.
    - semua = at least one mutation and every sisa is 0.
    - okSaldo = the saldo is not empty. siap = semua and okSaldo.
    - invalid = `st` is `pasti` and the tweak `bukuBerubah` is on and `lagi` is false.
    - A Tahapan chip i is done when (i ≤ current step and not invalid), or when (invalid and i < last). The current step is 0 for `kerja`, 1 for `periksa`, and last for `pasti`.
  - **Button label**:
    - `kerja`: "Pastikan rekonsiliasi", or "Tandai sudah diperiksa" with the second checker.
    - `periksa`: "Pastikan rekonsiliasi".
    - `pasti`: the action area is gone.
  - **Reason line** (the first that applies):
    1. "Saldo rekening koran belum diisi."
    2. "Belum ada mutasi bank."
    3. "Masih ada mutasi bank yang belum cocok seluruhnya."
    4. In `periksa`: "Sudah diperiksa oleh Pnt. Jefry Wowor. Bendahara memastikan."
    5. Otherwise: "Semua mutasi bank cocok dan selisih belum dijelaskan Rp0."
  - **Views** (all in place):
    1. **Kosong** (initial): empty box, total "Rp0" in `bata`, reason "Saldo rekening koran belum diisi.".
    2. **CSV dibaca**: three cards. BIAYA ADM is already "Cocok"; the total is Rp3.000.000.
    3. **Sebagian cocok**: some cards show a remainder and matched lines.
    4. **Siap**: total Rp0 in `laut`, saldo filled, button `laut`.
    5. **Sudah diperiksa** (second checker on): typing, upload, Cocokkan and Lepaskan are hidden; the saldo field is frozen; chips 1–2 are done.
    6. **Sudah dipastikan**: the confirmed card; the action area, upload, typing, Cocokkan and Lepaskan are hidden; the saldo field is frozen.
    7. **Perlu dipastikan lagi**: the invalid card replaces the confirmed card, and the last chip is dashed again.
    8. **Typed mutation added**: an extra "Belum cocok" card with the no-candidate line.
- **Tweaks** (all in the Keadaan panel, read live, not reset on change)
  - `jabatanKosong` (boolean, default off), the panel's global switch.
    - On: the phone PitaJabatanKosong line, and the confirmed card names "Yanti Sumual, Operator".
    - `tukarJk` is enabled on this board, but no other string here contains "Meiske L.", so nothing else changes.
  - `wajibPemeriksaKedua` (boolean, default off).
    - Off: two Tahapan chips, and the button "Pastikan rekonsiliasi" goes straight to `pasti`.
    - On: three chips. The first button is "Tandai sudah diperiksa" and moves to `periksa`. The button then reads "Pastikan rekonsiliasi", with the reason "Sudah diperiksa oleh Pnt. Jefry Wowor. Bendahara memastikan.", and moves to `pasti`.
  - `bukuBerubah` (boolean, default off). It only matters once `st` is `pasti`.
    - On, and "Pastikan lagi" not yet pressed: view 7, the invalid card with the last chip dashed.
    - On already when the reconciliation is confirmed: the confirm press goes straight to view 7; the confirmed card never shows until "Pastikan lagi".
    - Off: view 6.
    - After "Pastikan lagi" the tweak has no further effect until the board is reset.
- **Interactions**
  - **Saldo input**, on every keystroke and only while `st` is `kerja`: keep digits, strip leading zeros, keep at most 12 digits. Display with dot thousands ("24100000" → "24.100.000"), cursor at the end.
    - Typing "0" alone leaves the field empty, which still reads as "not filled in".
    - Outside `kerja` the input ignores typing; make it read-only and keep showing the value.
  - **"Unggah mutasi dari file CSV"**: `csv` = true at once. No file picker, no progress, no timer.
  - **Uraian input**: stored as typed.
  - **Amount input**: digits only, leading zeros stripped, at most 11 digits, dot thousands.
  - **"Tambah"**: enabled when the uraian, trimmed, is not empty and the amount is > 0. The condition is checked again on press, so the first press after typing works.
    - It appends `{ n: trimmed uraian, jm: amount }` (always a positive amount) and clears both fields.
    - A typed mutation can be neither matched nor removed.
  - **"Cocokkan · X"** on a card: appends X to that card's matched list. That candidate disappears, the matched line fades in, and the badge, remainder and total update.
  - **"Lepaskan"**: sets that card's matched list to empty. All its matches go, including BIAYA ADM's pre-match, and its candidates come back.
  - **Main button**: does nothing unless siap. Otherwise `st` becomes `periksa` when it is `kerja` and the second checker is on; otherwise it becomes `pasti`.
  - **"Pastikan lagi"**: `lagi` = true. The confirmed card comes back, and every Tahapan chip is done.
  - No timers.
- **Motion**
  - `muncul` (fade in plus 8 px rise), 300 ms, CSS default curve `ease` (no timing function given, so not the Gerak curve), on mount of: the CSV line, each matched line (including BIAYA ADM's pre-matched line when the CSV loads, and a line that returns after "Lepaskan" and a new match), the invalid card, and the confirmed card. The mutation cards themselves do not animate.
  - Keyframes `isi`, `masuk` and `pudar` are declared but unused.
  - The Gerak `kait` motion is not used, although this is a matching screen. Reproduce it as drawn.
  - Under reduce motion everything appears at once.
- **Links out**
  - Header back (Semantics "Kembali ke Bulan") → `/TutupBuku`, up link.
  - **Inbound**: TutupBuku ("Isi rekening koran"); also the JS-built rows of PetaLayar ("Isi rekening koran") and Cakupan ("Isi rekening koran", twice), which the manifest's `inbound` leaves out (`navigation.md` lists them).
- **Mock data**
  - Bank BNI ··4821, Oktober 2026, statement date 31/10/2026, file "mutasi-bni-okt.csv".
  - Mutations and transactions as in the tables above.
  - People: confirmer Meiske L. (or Yanti Sumual, Operator), second checker Pnt. Jefry Wowor.
  - Confirmation date 16/11/2026.
- **Prototype-only** Nothing on screen. The Keadaan panel holds `jabatanKosong`, `wajibPemeriksaKedua` and `bukuBerubah`.
- **Acceptance checks**
  1. **Fresh board.** The saldo field shows "—" with the `bata` caption "Rekening koran belum diisi. Kosong bukan Rp0.". Below come "Unggah mutasi dari file CSV", the typing block, and the dashed box "Belum ada mutasi bank. …". Chip "1 · Sedang dikerjakan" is filled and "2 · Sudah dipastikan" is dashed. "Sisa belum dicocokkan" shows "Rp0" in `bata`, then the reason "Saldo rekening koran belum diisi." over a grey "Pastikan rekonsiliasi".
  2. **Tap "Unggah mutasi dari file CSV".**
     - The upload button goes, and "mutasi-bni-okt.csv · 3 mutasi dibaca. Belum ada yang dicocokkan." rises in.
     - Three cards appear. "BIAYA ADM · 31/10/2026" has a `laut` "Cocok" badge and a `laut` border, the line "↔ BKU-2026-0133 · Biaya administrasi bank · −Rp15.000" and "Lepaskan".
     - The total reads "Rp3.000.000" in `bata`.
  3. **Tap "Cocokkan · BKU-2026-0118 · Rp500.000" on "TRF MASUK IBU RUNTU".** The badge becomes "Sebagian cocok" and "sisa belum dicocokkan: Rp500.000" appears. Only "Cocokkan · BKU-2026-0121 · Rp500.000" remains, and the total is "Rp2.500.000". Tap it: "Cocok", total "Rp2.000.000".
  4. **Match "TARIK TUNAI".** The total becomes "Rp0" in `laut`, but the reason stays "Saldo rekening koran belum diisi.". Type 24100000: the field shows "24.100.000", the caption turns `tinta2` "Saldo rekening koran per 31/10/2026", the reason reads "Semua mutasi bank cocok dan selisih belum dijelaskan Rp0." and the button turns `laut`.
  5. **Tap "Pastikan rekonsiliasi".** Both chips are filled. "Sudah dipastikan oleh Meiske L., 16/11/2026. Perubahan pada buku Oktober membuatnya perlu dipastikan lagi." rises in. The button, the reason, the typing block, "Cocokkan" and "Lepaskan" disappear, and typing in the saldo field changes nothing.
  6. **Then switch `bukuBerubah` on.**
     - The `bata`-edged "Perlu dipastikan lagi" card replaces the confirmed card, and chip 2 is dashed again.
     - "Pastikan lagi" brings back the confirmed card with both chips filled.
     - Switching `bukuBerubah` off and on again changes nothing.
  7. **Fresh board with `wajibPemeriksaKedua` on, brought to ready.**
     - Three chips show, and the button reads "Tandai sudah diperiksa".
     - Press it: chips 1–2 are filled, the reason is "Sudah diperiksa oleh Pnt. Jefry Wowor. Bendahara memastikan." and the button reads "Pastikan rekonsiliasi".
     - Press it: all three chips are filled.
  8. **Typed mutation.**
     - Type uraian "SETORAN" and amount "0": the amount stays empty and "Tambah" does nothing.
     - Type "250000": it shows "250.000".
     - "Tambah" adds a "Belum cocok" card "SETORAN · 31/10/2026", "Rp250.000", with "Belum ada transaksinya. …". Both fields clear, the total rises by Rp250.000, and the reason (with the saldo filled) is "Masih ada mutasi bank yang belum cocok seluruhnya.".
  9. **"Lepaskan" on BIAYA ADM.** "Belum cocok", the button "Cocokkan · BKU-2026-0133 · −Rp15.000", and the total rises by Rp15.000.
  10. **`jabatanKosong` on.** The line "Menjalankan jabatan kosong · Bendahara Jemaat" sits above the header. After confirming, the card reads "Sudah dipastikan oleh Yanti Sumual, Operator, 16/11/2026. …".
- **Notes**
  - **Off-token values**: saldo input mono 26 (not `jumlahIsian` 30); "Rp" prefix 18; total mono 22/600; badge padding 3 9 (LencanaStatus elsewhere uses 4 10); candidate radius 10; "Pastikan lagi" height 46. Copy them.
  - **The reason shows on an empty form.** TombolBersyarat says an empty form opens without a refusal, but the board wins. Copy each reason verbatim, without the "Tidak dapat dilakukan:" prefix.
  - **"Tambah" has no disabled look.** The board's CSS keeps the same colours when it is disabled, and it shows no reason. Keep the look and block the press. Added for rules A02/A03 (rules-checklist 4.1), not on the board: once Uraian or Jumlah holds text and the condition is unmet, "Tidak dapat dilakukan: Tambah. Uraian mutasi belum diisi." (or "… Jumlah mutasi belum diisi.") shows between the Uraian field and the Jumlah/Tambah row, drawn with Penolakan 14 (the outlined button and its row stay the board's; the button's semantics hint is the same reason). The empty pair shows none.
  - **Saldo field height (X03).** The field measured 43.6; it has a 44 minimum, the extra 0.4 below the top-aligned figure, so the figure does not move.
  - **A typed mutation blocks confirmation.** It can never be matched or removed, so it blocks confirmation until the board is re-entered. Keep as drawn.
  - **The CSV line keeps saying "Belum ada yang dicocokkan."** even though BIAYA ADM is pre-matched and after matching. Keep it verbatim.
  - **The upload is instant**, against the rule "upload always looks in progress". Keep as drawn and flag.
  - **The empty total is "Rp0"**, in `bata`, not "—". Keep the board.
  - **Changing `wajibPemeriksaKedua` in mid-flow is read live**, as on the canvas: switching it off while in `periksa` shows two chips, both filled, with "Pastikan rekonsiliasi". Start the acceptance checks from a fresh board.
  - **Cross-board figures**: BKU-2026-0127 is −Rp2.000.000 here (bank side), but +Rp2.000.000 on PilihBulan's October list. Each board keeps its own figure. `mock-data.md` records 0127 only as a transfer with In and Out 2.000.000 (§2.7) and has no row for this in "Where boards disagree" (§3); add one there.

---

### WebRekonIsi — Web · Rekonsiliasi: isi rekening koran dan cocok sebagian

- **Source** `docs/design/handoff/canvas/boards/WebRekonIsi.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebRekonIsi`, no child routes · **Widget** `WebRekonIsiScreen` in `lib/screens/lengkap/web_rekon_isi.dart`
- **Purpose** The same work as RekonIsi on the laptop: the Bendahara Jemaat at month end, from WebRekonsiliasi's "Isi rekening koran". Same rules; no numbered decision.
- **Shell** Web side nav (the standard finance nav), active item **Rekonsiliasi**. It is specified here once and referenced by the other web boards in this file.
  - **Page**: row, wrap, min height 100% of the viewport, `kertas`, `tinta` text, `isiWeb` (15/1.45). Links are `laut`, hover `lautTua`.
  - **`nav`**: flex 1 1 220, padding 24 16, `permukaan`, right border 1 `garis`, column, gap 20.
    - Brand row (gap 10, padding 0 8): the 26×26 mark. It is an SVG on viewBox 24: rect 2,2,20,20 rx 6 with no fill, stroke `laut` 2, dasharray 3 3, plus the path `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z` filled `laut`. Beside it, "palakat" (18/700, line height 1.1) over "Jemaat Karunia" (13, `tinta3`).
    - Items, in order:
      1. "Beranda" → `/WebBeranda`
      2. "Transaksi" → `/WebTransaksi`
      3. "Uang Muka dan Titipan" → `/WebKewajiban`
      4. "Rekonsiliasi" → `/WebRekonsiliasi`
      5. "Bulan dan tutup buku" → `/WebTutupBuku`
      6. "Laporan" → `/WebPaketLaporan`
      7. "Pengaturan" → `/WebPengaturan`

      All use `go`. Each item: min height 44, padding 0 12, radius 10 (off-token), 600, no underline. The active item has a `tinta` field and `permukaan` text; the others are transparent with `tinta` text.
    - Footer: margin-top auto, padding 12 8 0, top border 1 `garis`, 13 `tinta2`.
      - Default: bold `tinta` "Meiske L." then " · Bendahara", a line break, "Wewenang Bendahara aktif".
      - With `jabatanKosong`: bold "Yanti Sumual" then " · Operator", a line break, "Menjalankan jabatan kosong Bendahara Jemaat".
  - **Below 860 px**: the nav becomes a full-width top bar (row, wrap, items centred, gap 0 12, padding 8 16, bottom border 1 `garis`, no right border).
    - A toggle sits at the right: min height 44, padding 0 16, radius 14, 1.5 `tinta`, `permukaan`, 700 14, labelled "Menu".
    - When open it reads "Tutup menu" on a `tinta` field with `permukaan` text, and the items (padding 8 0) and the footer (padding-bottom 8) show full width below the brand row.
  - **Main column**: flex 999 1 560, min width 0, padding top 28, sides clamp(16 px, 3 vw, 40 px), bottom 40; column, gap 20.
  - **Web PitaJabatanKosong** (with `jabatanKosong`), first in the main column: `role=status`, `tinta` field, `permukaan` text, radius 14, padding 12 16, 14 px. Bold "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.", a space, then in `diTinta2` "Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual."
- **Layout** (main column)
  1. *Web PitaJabatanKosong* (only with `jabatanKosong`).
  2. *Title block*:
     - Breadcrumb link "Rekonsiliasi" (14/600, `laut`).
     - h1 `judulHalaman` (26/700, margin-top 2) "Isi rekening koran ", followed by a span "· Bank BNI ··4821 · Oktober 2026" (15/500 `tinta3`).
  3. *Two columns*: row, wrap, gap 24, aligned to the top.
     - **Left**: flex 1 1 340, min width 0, column gap 16, in this order:
       - (a) the input card, same as RekonIsi 3a;
       - (c) the Tahapan row;
       - (d) the total row;
       - (e) the invalid card;
       - (f) the confirmed card;
       - (g) the reason line and the button, 16 apart.

       All the same as RekonIsi. Note the order: on the phone the mutation list comes before the Tahapan; here it is in the right column.
     - **Right**: flex 999 1 480, min width 0. The mutation list, same as RekonIsi 3b: the empty draf box or the cards, 12 apart.
     - At 1440 the two columns sit side by side (left about 340 px, right the rest, about 775 px). When narrow, the right column wraps below the left.
- **Components** As RekonIsi, plus the web side nav and the web PitaJabatanKosong.
- **Internal views and states** Same state object, derived values, reasons and views as RekonIsi.
- **Tweaks** (all in the Keadaan panel)
  - `jabatanKosong` (boolean, default off), global. On: the web banner, the nav footer shows "Yanti Sumual · Operator / Menjalankan jabatan kosong Bendahara Jemaat", and the confirmed card names "Yanti Sumual, Operator".
  - `wajibPemeriksaKedua` (boolean, default off) and `bukuBerubah` (boolean, default off): exactly as RekonIsi.
- **Interactions** Same handlers and input rules as RekonIsi.
- **Motion** Same as RekonIsi: `muncul` 300 ms on the CSV line, the matched lines, the invalid card and the confirmed card. Keyframes `isi` and `titik` are declared but unused. Instant under reduce motion.
- **Links out**
  - Breadcrumb "Rekonsiliasi" → `/WebRekonsiliasi`, up link.
  - Side-nav items as listed in Shell, `go`.
  - **Inbound**: WebRekonsiliasi ("Isi rekening koran"); also PetaLayar's JS-built row "Isi rekening koran" (`navigation.md`).
- **Mock data** Same as RekonIsi.
- **Prototype-only** Nothing on screen. The Keadaan panel holds the three tweaks.
- **Acceptance checks**
  1. **At 1440**:
     - "Rekonsiliasi" is filled `tinta` in the side nav.
     - The breadcrumb "Rekonsiliasi" sits above "Isi rekening koran · Bank BNI ··4821 · Oktober 2026".
     - The input card, chips, total and grey button are on the left; the dashed empty box is on the right.
  2. Run RekonIsi checks 2–5 here: the cards appear in the right column, and the total, chips, confirmed card and button update in the left column.
  3. Run RekonIsi checks 6–9 here: the same results.
  4. **At 800 px wide**: the nav is a top bar with "Menu". Tapping it shows the seven items and the footer, and it reads "Tutup menu". The mutation cards stack below the button.
  5. **`jabatanKosong` on**: the banner "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15. …" is above the breadcrumb, and the nav footer shows "Yanti Sumual · Operator".
  6. **Breadcrumb "Rekonsiliasi"** returns to WebRekonsiliasi (a pop when that page is beneath).
- **Notes** Same notes as RekonIsi (off-token sizes, reason on an empty form, "Tambah" without a disabled look and its added reason, the 44 Saldo field, the instant upload, the empty total "Rp0"). This board's h1 is 26 and its suffix 15/500, and the body text is `isiWeb`.

---

### AlihPeruntukan — 31 · Alih peruntukan

- **Source** `docs/design/handoff/canvas/boards/AlihPeruntukan.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/AlihPeruntukan`, no child routes · **Widget** `AlihPeruntukanScreen` in `lib/screens/lengkap/alih_peruntukan.dart`
- **Purpose**
  - **Who and when**: the Bendahara Jemaat on the phone, daily work (journey "Bendahara Jemaat" step 3, after "4 · Koreksi" and "25 · Pengembalian"). Opened from the "Catatan lain" chips of Main's Catat sheet.
  - **What it does**: moves an amount from one peruntukan to another inside the same Kas/Bank (Bank BNI ··4821). The bank's Saldo buku does not change; only its split by peruntukan does, and the bar previews it.
  - **Decisions and rules it shows**:
    - **D04**: "Dasar keputusan · wajib"; posting is refused until it is filled.
    - **D01**: the peruntukan chips start unselected.
    - **C05**: the glossary term "Alih peruntukan" is final.
    - The "Tidak dapat dibukukan: …" reason above the primary button.
    - After posting, a No. Bukti and the sentence that the entry appears in neither Pendapatan, Belanja nor the rekening koran.
- **Shell** Phone, no tab bar.
  - Root: 390×844, `kertas`, `isi`.
  - The PitaJabatanKosong line sits on top with `jabatanKosong`.
  - Then the phone header (back label "Kembali ke Beranda"), and under it a scroll body.
- **Layout**
  1. *PitaJabatanKosong line* (only with `jabatanKosong`).
  2. *Header*: h1 "Alih peruntukan", subtitle "Dalam satu Kas/Bank".
  3. *Scroll body*: padding 8 20 20, column, gap 16.
     - a. **Intro box** (draf line): 1.5 dashed `putus`, radius 14, padding 12 16, 14 px. Bold "Alih peruntukan.", a space, then in `tinta2` "Uang tetap di Kas/Bank yang sama; hanya pemiliknya yang berpindah. Bukan Pendapatan dan bukan Belanja."
     - b. **Kas/Bank row**: space-between, centred, gap 16. "Kas/Bank" (14 `tinta2`) on the left, "Bank BNI ··4821" (700) on the right. It is not a control.
     - c. **"Dari peruntukan"** (14 `tinta2`, margin-bottom 8), then three chips: "Umum Jemaat", "Diakonia", "Pembangunan".
       - Chip: inline, min height 44, padding 0 14, margin 0 8 8 0, radius 999, 1.5 border, 600 14, with `aria-pressed`.
       - Selected: `tinta` field, `permukaan` text, `tinta` border. Unselected: `permukaan`, `tinta` text, `garisTegas` border.
     - d. **"Ke peruntukan"**: the same three chips, independent of c.
     - e. **Amount** (IsianJumlah):
       - Label "Jumlah (Rp)" (14 `tinta2`).
       - Row: baseline, gap 6, 2 px `tinta` underline, padding-bottom 4. It holds "Rp" (mono 20, `tinta3`) and the input: mono 30/500 (`jumlahIsian`), transparent, no border, min height 44, placeholder "0" as a grey hint, numeric keyboard.
     - f. **Basis**:
       - Label (block, 14 `tinta2`, margin-bottom 6) "Dasar keputusan ", followed by bold `tinta` "· wajib".
       - Input: full width, min height 48, padding 0 14, radius 12, 1 `garisTegas`, `permukaan`, placeholder "Contoh: keputusan BPMJ 09/11/2026".
     - g. **Balance card** (terpilih line): radius 16, padding 16, `permukaan`, 1.5 `tinta`, column gap 10.
       - Top row (space-between, centred, gap 16):
         - Left: "Saldo buku Bank BNI ··4821" (14 `tinta2`) over "Rp24.615.000" (mono 24/500).
         - Right, after posting only, the stamp: mono 14/600 `laut`, 2 `laut` border, radius 8, padding 4 10, text "No. Bukti BKU-2026-0152".
       - Caption (13 `tinta3`): "Tidak berubah. Yang berubah hanya pembagiannya per peruntukan:"
       - Bar: height 18, radius 9, clipped, three segments in a row, with no gaps.
         - Each segment is round(value / 24.615.000 × 100) % of the bar width, left-aligned in a row (not `Flexible`). The rounded widths can total 99 or 101 %:
           - 99 % (for example Umum Jemaat → Diakonia Rp25.000: 73 / 17 / 9) leaves a 1 % gap at the right end, where the card's `permukaan` shows (the bar has no fill of its own).
           - 101 % (for example Diakonia → Pembangunan Rp40.000: 74 / 17 / 10) does not overflow: the segments are CSS flex items with the default shrink of 1, so each is scaled by 100 / 101 to fit. In Flutter, scale every width by 100 / total whenever the total is above 100.
         - Colours: "Umum Jemaat" `tinta`, "Diakonia" `laut`, "Pembangunan" #86B5B8 (an allowed literal).
         - Widths animate (see Motion).
       - Legend, one row per peruntukan: centred, gap 10, padding-top 8, top border 1 `garis` on rows 2 and 3 (none on row 1).
         - A swatch 12×12, radius 3, in the segment colour.
         - The name: flex 1, 600.
         - The change: mono 13 `tinta2`, "− Rp500.000" or "+ Rp500.000" (sign, space, amount), empty when unchanged.
         - The value: mono 16/500 (`jumlah`).
     - h. **Before posting**:
       - The reason line, only while the condition is unmet: 14 `tinta2`, "Tidak dapat dibukukan: ‹alasan›".
       - 16 below it, the button "Periksa dan bukukan": full width, min height 52, radius 14, no border, 700, centred, padding 0 20. Ready: `laut`, `diLaut`. Not ready: `garis`, `tinta3`.
     - i. **After posting**: 14 `tinta2`, entering with `muncul` 300 ms: "Dibukukan pada 16/11/2026 11.55. Tidak muncul di Pendapatan, Belanja, atau rekening koran."
- **Components**
  - PitaJabatanKosong (phone line).
  - ChipPilihan: two single-choice groups.
  - IsianJumlah.
  - A text input for the basis. Not IsianAlasan, which is two lines; here it is one line.
  - BatangPembagian, used as a three-part split bar with a legend.
  - TombolBersyarat: "Periksa dan bukukan" with "Tidak dapat dibukukan: …" above it.
  - The No. Bukti stamp: a local widget.
  - Line language: draf (intro box), terpilih (balance card).
- **Internal views and states**
  - **Initial state**: `{ dari: null, ke: null, jm: '', dasar: '', posted: false }`.
  - **Peruntukan P**:

    | Key | Name | Saldo | Bar width |
    | --- | --- | --- | --- |
    | umum | "Umum Jemaat" | 18.115.000 | 74 % |
    | diak | "Diakonia" | 4.200.000 | 17 % |
    | bang | "Pembangunan" | 2.300.000 | 9 % |

    The total is 24.615.000.
  - **Reason** (the first unmet, shown after "Tidak dapat dibukukan: "):
    1. Dari or Ke not chosen: "pilih peruntukan asal dan tujuan."
    2. Dari = Ke: "peruntukan asal dan tujuan harus berbeda."
    3. Amount empty or 0: "jumlah belum diisi."
    4. Amount > the saldo of Dari: "melebihi saldo peruntukan ‹Umum Jemaat|Diakonia|Pembangunan› di Bank BNI ··4821."
    5. Basis blank after trimming: "dasar keputusan belum diisi."

    The form is ready when no reason applies.
  - **Preview** (the "efek" flag): while ready or posted, Dari shows value − amount with "− ‹rp›", and Ke shows value + amount with "+ ‹rp›". Otherwise every row shows its original value with no change text.
  - **Views**:
    1. **Isian**: reason and grey button; original bar.
    2. **Siap**: no reason, `laut` button, the bar and legend show the move.
    3. **Dibukukan**: stamp, posted line, button and reason gone, every control frozen, the preview kept.
- **Tweaks**
  - `jabatanKosong` (boolean, default off), Keadaan panel (global): the phone PitaJabatanKosong line only.
  - `tukarJk` is disabled, and nothing names a person anyway.
- **Interactions**
  - **A Dari or Ke chip**: selects that peruntukan in its group; tapping the selected chip keeps it, with no deselect. Ignored after posting.
  - **Amount**, on every keystroke: digits only, leading zeros stripped, at most 11 digits, dot thousands. Ignored after posting.
  - **Basis**: stored as typed. Ignored after posting (make both inputs read-only).
  - **"Periksa dan bukukan"**: re-checks the condition on press. When ready, `posted` = true at once.
    - No confirmation sheet, no separate "Periksa" step, no timer.
    - The first press after typing the basis works.
- **Motion**
  - Bar segment widths: a CSS `transition: width .5s cubic-bezier(.2,.8,.2,1)`. Use an implicit width animation of 500 ms on the Gerak curve (`keluar`); `motion.md` names `AnimatedFractionallySizedBox`. It runs whenever a width changes: when the form becomes ready or not ready, and on each keystroke of the amount while ready.
  - The stamp: `muncul` 400 ms, fill-mode both, CSS default curve `ease`.
  - The posted line: `muncul` 300 ms, `ease`.
  - Keyframes `isi`, `masuk` and `pudar` are declared but unused. Under reduce motion, widths jump and nothing animates.
- **Links out**
  - Header back (Semantics "Kembali ke Beranda") → `/Main`, up link.
  - **Inbound**: Keputusan ("4 Alih peruntukan wajib menyebut dasar keputusan."), Main (Catat sheet chip "Alih peruntukan"), and PetaLayar's JS-built row "Alih peruntukan" (`navigation.md`).
- **Mock data**
  - Bank BNI ··4821, Saldo buku Rp24.615.000.
  - Peruntukan: Umum Jemaat Rp18.115.000, Diakonia Rp4.200.000, Pembangunan Rp2.300.000.
  - Posting: No. Bukti BKU-2026-0152, dated "16/11/2026 11.55".
  - The placeholder's sample basis is dated 09/11/2026.
- **Prototype-only** Nothing on screen.
  - The placeholder "Contoh: keputusan BPMJ 09/11/2026" is a field hint, not one of the "Contoh:" buttons, so it stays in the field.
  - The Keadaan panel holds `jabatanKosong`.
- **Acceptance checks**
  1. **Fresh board.** No chip is selected and the amount shows a grey "0". The reason reads "Tidak dapat dibukukan: pilih peruntukan asal dan tujuan." over a grey "Periksa dan bukukan". The bar is split 74 % / 17 % / 9 %, the legend shows "Rp18.115.000", "Rp4.200.000" and "Rp2.300.000", and there is no change text.
  2. **Dari "Diakonia" and Ke "Diakonia".** The reason becomes "Tidak dapat dibukukan: peruntukan asal dan tujuan harus berbeda.".
  3. **Ke "Pembangunan".** The reason becomes "… jumlah belum diisi.". Type 5000000: the field shows "5.000.000" and the reason "… melebihi saldo peruntukan Diakonia di Bank BNI ··4821.".
  4. **Change the amount to 500000.** The reason becomes "… dasar keputusan belum diisi.". Type "keputusan BPMJ 09/11/2026":
     - The reason goes and the button turns `laut`.
     - The bar animates to 74 % / 15 % / 11 %.
     - The legend reads Diakonia "− Rp500.000" "Rp3.700.000" and Pembangunan "+ Rp500.000" "Rp2.800.000".
     - "Rp24.615.000" stays.
  5. **Replace the basis with spaces.** The reason "… dasar keputusan belum diisi." returns, and the bar animates back to 74 / 17 / 9 with no change text.
  6. **Restore the basis and tap "Periksa dan bukukan".**
     - "No. Bukti BKU-2026-0152" fades up in the card.
     - The button and the reason disappear, and "Dibukukan pada 16/11/2026 11.55. Tidak muncul di Pendapatan, Belanja, atau rekening koran." rises in.
     - Tapping chips or typing changes nothing.
  7. **`jabatanKosong` on.** The line "Menjalankan jabatan kosong · Bendahara Jemaat" sits above the header.
  8. **The back arrow** returns to Main (Beranda).
  9. **Rounding.** Fresh board, Dari "Umum Jemaat", Ke "Diakonia", amount 25000, any basis: the bar reads 73 / 17 / 9 with a 1 % strip of `permukaan` at its right end. Change to Dari "Diakonia", Ke "Pembangunan", amount 40000: 74 / 17 / 10 squeezed to fill the bar exactly, nothing clipped.
- **Notes**
  - **The reason uses "Tidak dapat dibukukan:"** (not "Tidak dapat dilakukan:"), and it shows on the empty form. The board wins over the TombolBersyarat rule. Copy it verbatim.
  - **The stamp uses `muncul` 400 ms**, not the `tinta` motion of Bukukan, and the balance does not count. Copy the board.
  - **Off-token values**: "Rp" prefix 20, balance mono 24, stamp radius 8 and border 2, bar radius 9, swatch radius 3.
  - **Saldo buku**: Bank BNI is Rp24.615.000 here (16/11). TutupBuku and WebRekonsiliasi show Rp24.615.000 before the bank fee and Rp24.600.000 after it (31/10). Each keeps its own figure; `mock-data.md` §3 row 2 already lists this.
  - **Bar widths** are rounded percentages and may total 99 or 101. Keep the CSS behaviour: a gap at 99, a proportional squeeze at 101 (see Layout g).
  - **The Kas/Bank is fixed** to Bank BNI ··4821 and cannot be chosen, although D01 says Kas/Bank is never pre-filled. Keep as drawn and flag it for the design owner.

---

### WebAlihPeruntukan — Web · Alih peruntukan

- **Source** `docs/design/handoff/canvas/boards/WebAlihPeruntukan.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebAlihPeruntukan`, no child routes · **Widget** `WebAlihPeruntukanScreen` in `lib/screens/lengkap/web_alih_peruntukan.dart`
- **Purpose** AlihPeruntukan on the laptop, for the Bendahara Jemaat's daily work. Reached from WebCatat and TabCatat ("Alih peruntukan"). Shows D04, D01 and C05, as the phone board does.
- **Shell** The standard web side nav (see WebRekonIsi), active item **Transaksi**. The footer and the web PitaJabatanKosong follow `jabatanKosong`. It collapses below 860 px.
- **Layout** (main column, gap 20)
  1. *Web PitaJabatanKosong* (only with `jabatanKosong`).
  2. *Title block*: breadcrumb link "Transaksi" (14/600 `laut`), then h1 `judulHalaman` "Alih peruntukan" (margin-top 2). There is no suffix.
  3. *Two columns*: row, wrap, gap 24, aligned to the top.
     - **Left**: flex 999 1 440, min width 0, column gap 16. The intro box, the Kas/Bank row, "Dari peruntukan", "Ke peruntukan", the amount and the basis, all the same as AlihPeruntukan 3a–3f.
     - **Aside**: flex 1 1 380, min width 0, column gap 14. The balance card (3g), the reason line plus the button (3h, here 14 apart), and the posted line (3i), all the same as on the phone.
     - When narrow, the aside wraps below the form.
- **Components** As AlihPeruntukan, plus the web side nav and the web PitaJabatanKosong.
- **Internal views and states** Same as AlihPeruntukan.
- **Tweaks**
  - `jabatanKosong` (boolean, default off), Keadaan panel (global). On: the web banner and the nav footer showing "Yanti Sumual · Operator / Menjalankan jabatan kosong Bendahara Jemaat".
  - `tukarJk` is disabled.
- **Interactions** Same as AlihPeruntukan.
- **Motion** Same as AlihPeruntukan: the 500 ms bar width animation, the stamp `muncul` 400 ms, the posted line `muncul` 300 ms. Keyframes `isi` and `titik` are declared but unused.
- **Links out**
  - Breadcrumb "Transaksi" → `/WebTransaksi`, up link.
  - Side nav as in WebRekonIsi, `go`.
  - **Inbound**: TabCatat and WebCatat (both "Alih peruntukan"), and PetaLayar's JS-built row "Alih peruntukan" (`navigation.md`).
- **Mock data** Same as AlihPeruntukan.
- **Prototype-only** Nothing on screen; the placeholder "Contoh: …" stays as a field hint. The Keadaan panel holds `jabatanKosong`.
- **Acceptance checks**
  1. **At 1440**: "Transaksi" is active in the nav. The breadcrumb "Transaksi" sits over the h1 "Alih peruntukan". The form is on the left; the balance card, the reason "Tidak dapat dibukukan: pilih peruntukan asal dan tujuan." and the grey button are on the right.
  2. Run AlihPeruntukan checks 2–6 here: the reasons, the bar animation and the posting result are identical, and they appear in the aside.
  3. **At 800 px**: the nav collapses behind "Menu", and the aside stacks under the basis field.
  4. **`jabatanKosong` on**: the web banner is above the breadcrumb, and the nav footer reads "Yanti Sumual · Operator".
  5. **Breadcrumb "Transaksi"** returns to WebTransaksi.
- **Notes** Same as AlihPeruntukan. The aside gap is 14, so the reason sits 14 above the button (16 on the phone).

---

### UbahPengaturan — 32 · Pengaturan: tambah dan ubah, berlaku mulai bulan tertentu

- **Source** `docs/design/handoff/canvas/boards/UbahPengaturan.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/UbahPengaturan`, no child routes (the three tab chips switch content in place) · **Widget** `UbahPengaturanScreen` in `lib/screens/lengkap/ubah_pengaturan.dart`
- **Purpose**
  - **Who and when**: the Bendahara Jemaat on the phone, settings. Reached from Lainnya's row "Tambah dan ubah pengaturan" (subtitle "Kas/Bank, seri No. Bukti, aturan · berlaku mulai bulan tertentu"). The board is not named in the handoff's "Journeys by role" list.
  - **What it does**, each change saved as a new version that waits for its month, never edited in place:
    - adds a Kas or Bank;
    - changes the regular ("Biasa") No. Bukti series for 2027;
    - changes the amount from which approval is required for Belanja.
  - **Decisions it shows**:
    - **D23**: a settings change takes effect from a following month (choices Desember 2026 and Januari 2027).
    - **D24**: a series change takes effect from Januari 2027.
    - The "effective-from sentence" pattern.
    - Draf lines for changes that are not yet in force.
- **Shell** Phone, no tab bar, phone header with back (Semantics "Kembali ke Lainnya"). The board has no PitaJabatanKosong line and no `jabatanKosong` tweak. Root: 390×844, `kertas`, `isi`.
- **Layout**
  1. *Header*: h1 "Ubah pengaturan", subtitle "Selalu sebagai versi baru".
  2. *Tab chips* (fixed above the scroll body): padding 0 20 4.
     - Three chips, inline and wrapping: "Tambah Kas/Bank", "Seri No. Bukti", "Aturan persetujuan".
     - Chip: min height 44, padding 0 12, margin 0 6 6 0, radius 999, 1.5 border, 600 **13**, with `aria-pressed`.
     - Selected: `tinta` field, `permukaan` text, `tinta` border. Unselected: `permukaan`, `tinta`, `garisTegas`.
     - At 390 wide they wrap onto two lines.
  3. *Scroll body*: padding 8 20 20, column, gap 16.
     - a. **Tab content**: column, gap 14.
       - **"Tambah Kas/Bank"** (tab `kas`):
         - "Jenis" (14 `tinta2`, margin-bottom 8), then the chips "Kas" and "Bank". These are standard chips: padding 0 14, margin 0 8 8 0, 600 14, same colours.
         - Name field:
           - Label (block, 14 `tinta2`, margin-bottom 6): "Nama bank" for Bank, "Tempat atau pemegang" for Kas.
           - Input: full width, min height 48, padding 0 14, radius 12, 1 `garisTegas`, `permukaan`. Placeholder "Misalnya: Mandiri" (Bank) or "Misalnya: Panitia Natal" (Kas).
           - Hint below (13 `tinta3`, margin-top 4): "Jangan memakai nama peruntukan atau Lingkup."
         - Bank only: label "Empat angka akhir No. rekening", then an input in the same box style but mono, max width 160, numeric keyboard, no placeholder.
         - "Berlaku mulai" (14 `tinta2`, margin-bottom 8), then the chips "Desember 2026" and "Januari 2027".
       - **"Seri No. Bukti"** (tab `seri`):
         - Current card: `permukaan`, 1 `garis`, radius 14, padding 12 16. "Sekarang, sejak September 2026" (14 `tinta2`) over "BKU-2026-0151" (mono 16/600).
         - Field: label "Awalan seri Biasa · 2 sampai 4 huruf"; input mono, max width 160, no placeholder, initial value "BKU".
         - "Jumlah angka", then the chips "4 angka" and "5 angka".
         - Preview block:
           - "Nomor pertama tahun 2027" (14 `tinta2`).
           - The number (mono 24/500), for example "BKU-2027-0001".
           - 13 `tinta3`: "Satu seri Biasa per tahun kalender. Seri OPN dan ADJ tetap. Nomor selalu dibuat aplikasi."
       - **"Aturan persetujuan"** (tab `aturan`):
         - Current card: "Sekarang, sejak September 2026" (14 `tinta2`) over "Persetujuan wajib untuk Belanja Rp2.000.000 ke atas" (600).
         - Field: label "Wajib untuk Belanja mulai dari" (14 `tinta2`, inline label). Under it a row (baseline, gap 6, 2 px `tinta` underline, padding-bottom 4, max width 280) holding "Rp" (mono 18, `tinta3`) and the input: mono 26/500, transparent, no border, min height 44, numeric keyboard, initial "3.000.000".
         - "Berlaku mulai", then the chips "Desember 2026" and "Januari 2027". This is the same state as on the Kas tab.
     - b. **Button "Simpan sebagai versi baru"**: full width, min height 52, radius 14, no border, 700, centred, padding 0 20. Valid: `laut`, `diLaut`. Invalid: `garis`, `tinta3`. There is no reason line.
     - c. **"Perubahan yang menunggu berlaku"**: 16/700 (`judulBagian`), a plain div.
     - d. **Pending entries**: one per tab that has been saved, in the order they were first saved. Each is a draf card: 1.5 dashed `putus`, radius 14, padding 12 16, 14/600, entering with `muncul` 300 ms. With no entries, nothing shows here (no empty text).
     - e. **Footnote** (13 `tinta3`): "Pengaturan tidak diubah di tempat. Versi lama tetap berlaku untuk bulan-bulan sebelumnya dan tidak mengubah transaksi yang sudah dibukukan. Yang sudah dipakai hanya dapat dinonaktifkan."
- **Components**
  - ChipPilihan: the tabs (smaller variant), Jenis, Berlaku mulai, Jumlah angka.
  - IsianJumlah variant (26 px) for the approval threshold.
  - Text inputs.
  - TombolBersyarat "Simpan sebagai versi baru" (`utama`, unmet text `tinta3`); the board draws no reason, the prototype adds one (Notes).
  - Line language: draf, for the pending entries.
  - The "effective-from sentence" pattern is in every entry.
- **Internal views and states**
  - **Initial state**: `{ tab: 'kas', jenis: 'Bank', nama: '', akhir: '', mulai: 'Desember 2026', awalan: 'BKU', digit: 4, batas: '3000000', jadi: {} }`.
  - **Valid** (per active tab):
    - `kas`: the name, trimmed, is not empty, and either the Jenis is Kas or the last four digits are exactly 4 digits.
    - `seri`: the prefix matches `^[A-Z]{2,4}$`.
    - `aturan`: the threshold is > 0.
  - **Preview number**: ‹awalan›-2027- followed by (digit − 1) zeros and "1". With 4 digits that is "BKU-2027-0001"; with 5 it is "BKU-2027-00001".
  - **Entry texts**, with the values at the moment of saving:
    - `kas`, Bank: "Bank ‹nama trimmed› ··‹akhir› · berlaku mulai ‹mulai› · belum dapat dipakai untuk transaksi sebelum itu"
    - `kas`, Kas: "Kas ‹nama trimmed› · berlaku mulai ‹mulai› · belum dapat dipakai untuk transaksi sebelum itu"
    - `seri`: "Seri Biasa menjadi ‹preview number› · berlaku mulai Januari 2027 · nomor yang sudah diberikan tidak berubah"
    - `aturan`: "Persetujuan wajib untuk Belanja ‹rp(batas)› ke atas · berlaku mulai ‹mulai› · transaksi sebelumnya tetap memakai Rp2.000.000"
  - **Views**: the three tab contents. The Bank or Kas variant of the Kas tab. The pending list: empty, or 1–3 entries.
  - Field values are kept when switching tabs or Jenis. The four-digit value stays in state while the Jenis is Kas.
- **Tweaks** None. The global `jabatanKosong` switch has no effect here.
- **Interactions**
  - **Tab chip**: sets `tab`.
  - **Jenis chip**: sets `jenis`. The label, placeholder and four-digit field follow.
  - **Name**: stored as typed.
  - **Last four digits**: digits only, at most 4.
  - **Berlaku mulai chip**: sets `mulai`, shared by Kas and Aturan.
  - **Prefix**: upper-cased, letters A–Z only, at most 4. For example, typing "gk1a" gives "GKA".
  - **Jumlah angka chip**: sets `digit` to 4 or 5. The preview updates.
  - **Threshold**: digits only, leading zeros stripped, at most 10 digits, dot thousands.
  - **"Simpan sebagai versi baru"**: re-checks on press. When valid, it stores the entry text under the active tab's key.
    - Saving the same tab again replaces that entry's text in place (same position, no second card).
    - Later edits do not change a saved entry until it is saved again.
    - No timer and no confirmation.
- **Motion**
  - `muncul` 300 ms (CSS default curve `ease`) when a pending entry first appears. Replacing the text of an existing entry does not animate again: key each entry by its tab.
  - Keyframes `isi`, `masuk` and `pudar` are declared but unused. Instant under reduce motion.
- **Links out**
  - Header back (Semantics "Kembali ke Lainnya") → `/Lainnya`, up link.
  - **Inbound**: Keputusan ("23 Perubahan pengaturan berlaku mulai bulan berikutnya.", "24 Perubahan seri No. Bukti berlaku mulai Januari 2027."), Lainnya ("Tambah dan ubah pengaturan"), and PetaLayar's JS-built row "Tambah dan ubah" (`navigation.md`).
- **Mock data**
  - Current series BKU-2026-0151, since September 2026. Series OPN and ADJ are named.
  - Current approval rule Rp2.000.000, since September 2026. Proposed default Rp3.000.000.
  - Months "Desember 2026" and "Januari 2027"; first number for 2027.
  - Name examples "Mandiri" and "Panitia Natal".
- **Prototype-only** None.
- **Acceptance checks**
  1. **Fresh board.**
     - "Tambah Kas/Bank" and "Bank" are selected.
     - The label "Nama bank" shows the placeholder "Misalnya: Mandiri", and the four-digit field is visible.
     - "Desember 2026" is selected and the button is grey.
     - "Perubahan yang menunggu berlaku" has no entries; the footnote is below it.
  2. **Type "Mandiri" and "12a34".** The digits field shows "1234" and the button turns `laut`. Tap it: the dashed card "Bank Mandiri ··1234 · berlaku mulai Desember 2026 · belum dapat dipakai untuk transaksi sebelum itu" rises in.
  3. **Tap "Kas".**
     - The label is "Tempat atau pemegang" and the four-digit field is hidden. The field still holds "Mandiri", so its new placeholder "Misalnya: Panitia Natal" shows only once the field is cleared.
     - The button stays `laut` (the name is "Mandiri").
     - Choose "Januari 2027" and save: the same card now reads "Kas Mandiri · berlaku mulai Januari 2027 · belum dapat dipakai untuk transaksi sebelum itu". There is still one card.
  4. **Tab "Seri No. Bukti".**
     - The card shows "BKU-2026-0151", the prefix is "BKU", "4 angka" is selected, the preview is "BKU-2027-0001" and the button is `laut`.
     - Tap "5 angka": the preview becomes "BKU-2027-00001".
     - Clear the prefix and type "g": it shows "G", the button is grey, and tapping it does nothing.
  5. **Type "mim" after the "G".** The prefix shows "GMIM" and the preview "GMIM-2027-00001". Save: a second card "Seri Biasa menjadi GMIM-2027-00001 · berlaku mulai Januari 2027 · nomor yang sudah diberikan tidak berubah" appears below the Kas card.
  6. **Tab "Aturan persetujuan".**
     - The field shows "3.000.000", and "Berlaku mulai" shows "Januari 2027" (chosen on the Kas tab).
     - Save: a third card "Persetujuan wajib untuk Belanja Rp3.000.000 ke atas · berlaku mulai Januari 2027 · transaksi sebelumnya tetap memakai Rp2.000.000".
     - Clear the field: the button turns grey.
  7. **The back arrow** returns to Lainnya.
- **Notes**
  - The label "Empat angka akhir No. rekening" focuses its field on tap (`<label for>`) but is excluded from semantics: the field carries the label, so there is no separate small tap target (X03, rules-checklist 4.1; also WebUbahPengaturan).
  - **No reason when the button is disabled** on the board. Added for rules A02/A03 (rules-checklist 4.1), not on the board: "Simpan sebagai versi baru" is TombolBersyarat; once a field of the open tab differs from its start value and the tab's condition is unmet, it shows "Tidak dapat dilakukan: Simpan sebagai versi baru. {field} belum diisi." above the button, {field} the first unmet one as labelled on the board: "Nama bank" / "Tempat atau pemegang", then "Empat angka akhir No. rekening" (Kas/Bank); "Awalan seri Biasa" (Seri); "Wajib untuk Belanja mulai dari" (Aturan). The untouched form shows none.
  - **The tab chips are 13 px with padding 0 12 and margin 0 6 6 0**, smaller than the other chips (14 px, 0 14). Copy it.
  - **Off-token values**: preview mono 24, threshold mono 26, "Rp" prefix 18.
  - **Seri and Aturan are valid from the start**, so saving without any change creates an entry ("Seri Biasa menjadi BKU-2027-0001 …"). Keep as drawn.
  - **The heading is a plain div styled 16/700.** Give it heading semantics for screen readers.

---

### WebUbahPengaturan — Web · Pengaturan: tambah dan ubah

- **Source** `docs/design/handoff/canvas/boards/WebUbahPengaturan.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebUbahPengaturan`, no child routes · **Widget** `WebUbahPengaturanScreen` in `lib/screens/lengkap/web_ubah_pengaturan.dart`
- **Purpose** UbahPengaturan on the laptop: the Bendahara Jemaat's settings, from WebPengaturan ("Tambah dan ubah"). Shows D23 and D24.
- **Shell** The standard web side nav (see WebRekonIsi), active item **Pengaturan**.
  - The footer is fixed: bold "Meiske L." then " · Bendahara", a line break, "Wewenang Bendahara aktif". It has no `jabatanKosong` variant on this board.
  - No banner.
  - It collapses below 860 px.
- **Layout** (main column, gap 20)
  1. *Title block*: breadcrumb link "Pengaturan" (14/600 `laut`), then h1 `judulHalaman` "Tambah dan ubah".
  2. *Tab chips*: row, wrap, gap 8. The same three chips as UbahPengaturan, but at the standard size: padding 0 14, 600 **14**, margin 0.
  3. *Two columns*: row, wrap, gap 28, aligned to the top.
     - **Left**: flex 999 1 420, min width 0, max width 620, column gap 16. The tab content (same as UbahPengaturan 3a, all three tabs, the same fields and sizes), then the button "Simpan sebagai versi baru" (same as 3b).
     - **Aside**: flex 1 1 360, min width 0, column gap 12.
       - "Perubahan yang menunggu berlaku" (16/700).
       - The pending entries (draf cards, `muncul` 300 ms).
       - The footnote (13 `tinta3`), with the same text as UbahPengaturan.
- **Components** As UbahPengaturan, plus the web side nav.
- **Internal views and states** Same as UbahPengaturan.
- **Tweaks** None. The global `jabatanKosong` switch changes nothing here, including the nav footer.
- **Interactions** Same as UbahPengaturan.
- **Motion** `muncul` 300 ms on a new pending entry. Keyframes `isi` and `titik` are declared but unused.
- **Links out**
  - Breadcrumb "Pengaturan" → `/WebPengaturan`, up link.
  - Side nav as in WebRekonIsi, `go`.
  - **Inbound**: WebPengaturan ("Tambah dan ubah"), and PetaLayar's JS-built row "Tambah dan ubah" (`navigation.md`).
- **Mock data** Same as UbahPengaturan.
- **Prototype-only** None.
- **Acceptance checks**
  1. **At 1440**: "Pengaturan" is active in the nav, the breadcrumb "Pengaturan" sits over "Tambah dan ubah", and the tab chips are 14 px in one row. The form is on the left (at most 620 wide). On the right: "Perubahan yang menunggu berlaku" with no entries, and the footnote.
  2. Run UbahPengaturan checks 2–6 here: the cards appear in the right column with the same texts.
  3. **Switch the global `jabatanKosong` on**: no banner, and the footer still reads "Meiske L. · Bendahara".
  4. **At 800 px**: the nav collapses behind "Menu", and the pending list stacks under the button.
  5. **Breadcrumb "Pengaturan"** returns to WebPengaturan.
- **Notes** Same as UbahPengaturan, including the added reason sentence above the button. The nav footer ignores the vacancy switch because the board has no such tweak.

---

### PilihBulan — 33 · Pemilih bulan dan daftar kosong

- **Source** `docs/design/handoff/canvas/boards/PilihBulan.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/PilihBulan`, no child routes. The month picker is a bottom sheet overlay, not a route. · **Widget** `PilihBulanScreen` in `lib/screens/lengkap/pilih_bulan.dart`
- **Purpose**
  - **Who and when**: the Bendahara Jemaat on the phone, daily work. "33 · Pemilih bulan dan daftar kosong" is not named in the handoff's "Journeys by role" list; it belongs beside step 2 of "Bendahara Jemaat" ("1 · Harian"), whose month pill opens it. This is the Transaksi list of "1 · Harian" with its month picker opened from the month pill.
  - **What it shows**:
    - choosing any month since the start of recording;
    - a closed month that is read-only (ditutup line: a `tinta` field) with no offer to reopen it;
    - Draf rows on a dashed line and Dibukukan / Dibalik rows on a solid line;
    - the empty-month rule "Bulan tanpa transaksi belum selesai: …".
  - **Rules**: the line is the status; never offer to reopen a month; LembarBawah for a short choice. D32 (a closed month is the lightest block in the dark theme) applies to the September option in dark mode. No numbered decision is attached.
- **Shell** Phone, no tab bar and **no back control**. The board is drawn as a stand-alone list; leaving it uses system or browser Back.
  - Root: 390×844, `kertas`, `isi`, column.
  - The PitaJabatanKosong line sits on top with `jabatanKosong`.
  - Below it, a relative area that fills the rest and holds the screen and, when open, the sheet overlay.
- **Layout**
  1. *PitaJabatanKosong line* (only with `jabatanKosong`).
  2. *Header*: padding 24 20 10, column gap 10.
     - h1 `judulBesar` (22/700) "Transaksi".
     - The month button: hugs its text (align start), min height 44, padding 0 16, radius 999, 1.5 `tinta`, `permukaan`, 700 (16). Label "‹bulan› · ‹status› ▾", for example "November 2026 · Belum ditutup ▾". It carries `aria-expanded`.
  3. *Scroll body*: padding 4 20 20 (top 4 overrides 8), column, gap 16.
     - a. **Closed banner** (closed month only), ditutup line: `tinta` field, `permukaan` text, radius 14, padding 12 16, 14 px. Bold "September 2026 sudah ditutup." then " Hanya dapat dilihat. Dokumen susulan dan kejadian dicatat dari tiap transaksi."
     - b. **Rows** (a month with transactions), one block:
       - Each row card: margin-bottom 10, radius 14, padding 12 14, column gap 4.
       - Dibukukan and Dibalik: `permukaan` with 1 `garis` (dibukukan). Draf: transparent with 1.5 dashed `putus` (draf).
       - Line 1 (space-between, centred, gap 16):
         - The LencanaStatus badge: 13/700, radius 6, padding 3 9.
           - "Dibukukan": `tinta` field, `permukaan` text, 1.5 `tinta`.
           - "Draf": transparent, `tinta2` text, 1.5 dashed `putus`.
           - "Dibalik": `permukaan`, `tinta2` text, 1.5 `tinta3`.
         - The amount: mono 16/500, `tinta`, or `tinta3` for Draf.
       - Line 2: the uraian (600).
       - Line 3 (13 `tinta3`): mono "‹No. Bukti›" (or mono "Belum ada No. Bukti" for a draft), then " · ‹tanggal›".
       - After the rows, the caption (13 `tinta3`): "Contoh 3 baris."
     - c. **Empty month** (Desember): draf box, 1.5 dashed `putus`, radius 14, padding 18 16, 14 `tinta2`. Bold `tinta` "Belum ada transaksi di Desember 2026.", then " Bulan tanpa transaksi belum selesai: tiap Kas/Bank tetap perlu hitung kas atau rekening koran, lalu tutup buku." There is no caption.
  4. *Sheet overlay* (while open). It covers the whole area below the PitaJabatanKosong line, including the header.
     - **Scrim**: fills the area, `tinta` at 45 % opacity (the board's rgba(19,32,28,.45)), entering with `pudar` 200 ms. Pressable, with Semantics "Kembali ke daftar".
     - **Sheet** (LembarBawah): pinned to the bottom, full width, `kertas`, radius 22 22 0 0, padding 18 20 20, entering with `muncul` 280 ms.
       - h2 `judulLayar` (18/700, margin-bottom 4) "Pilih bulan".
       - 14 `tinta2` (margin-bottom 12): "Semua bulan sejak tanggal mulai pencatatan."
       - Four option buttons, each full width: column gap 2, padding 12 14, margin-bottom 8, radius 14, with `aria-pressed`.
         - Top line (space-between, centred, gap 16): the month (700 16) and a badge (13/700, radius 6, padding 3 9).
         - Second line: 13 px.
         - Looks:

           | Option | Background | Border | Text | Second line | Badge |
           | --- | --- | --- | --- | --- | --- |
           | Open month, not selected | `permukaan` | 1 `garis` | `tinta` | `tinta3` | transparent, `tinta2` text, 1.5 `tinta3` |
           | Open month, selected | `lautLembut` | 2 `laut` | `tinta` | `tinta3` | as above |
           | Closed month (September), not selected | `tinta` field | 2 `tinta` | `permukaan` | `diTinta2` | `permukaan` field, `tinta` text, 1.5 `permukaan` |
           | Closed month (September), selected | `tinta` field | 2 `laut` | `permukaan` | `diTinta2` | as above |

- **Components**
  - PitaJabatanKosong (phone line).
  - LencanaStatus (Dibukukan, Draf, Dibalik in the rows; Belum ditutup, Sudah ditutup in the sheet).
  - LembarBawah.
  - PitaPeran-style locking banner (`tinta` field) for the closed month.
  - Line language: draf (draft row, empty box), dibukukan (rows), ditutup (closed banner, September option).
  - Repeated patterns, not components: the transaction row card and the month option.
- **Internal views and states**
  - **Initial state**: `{ bulan: 'November 2026', buka: false }`.
  - **Months**, in sheet order:
    1. "Desember 2026" · "Belum ditutup" · "Belum ada transaksi"
    2. "November 2026" · "Belum ditutup" · "Bulan berjalan · 12 transaksi"
    3. "Oktober 2026" · "Belum ditutup" · "Berikutnya untuk tutup buku · 33 transaksi"
    4. "September 2026" · "Sudah ditutup" · "Periode laporan 15–30 September 2026 · 21 transaksi" (closed)
  - **Rows by month** (status · No. Bukti · date · uraian · amount):
    - November 2026:
      1. Dibukukan · BKU-2026-0146 · 15/11/2026 · "Persembahan Ibadah Minggu" · Rp3.450.000
      2. Draf · (none: "Belum ada No. Bukti") · 14/11/2026 · "Fotokopi warta jemaat" · −Rp150.000
      3. Dibukukan · BKU-2026-0143 · 11/11/2026 · "Sewa sound system" · −Rp600.000
    - Oktober 2026:
      1. Dibukukan · BKU-2026-0133 · 31/10/2026 · "Biaya administrasi bank" · −Rp15.000
      2. Dibukukan · BKU-2026-0127 · 30/10/2026 · "Pindah antar Kas/Bank: Bank BNI ke Kas" · Rp2.000.000
      3. Dibalik · BKU-2026-0105 · 09/10/2026 · "Konsumsi rapat majelis" · −Rp750.000
    - September 2026:
      1. Dibukukan · BKU-2026-0031 · 22/09/2026 · "Alat tulis Toko Sinar" · −Rp85.000
      2. Dibukukan · BKU-2026-0019 · 18/09/2026 · "Persembahan Ibadah Minggu" · Rp2.900.000
      3. Dibukukan · OPN-2026-0001 · 15/09/2026 · "Saldo awal pencatatan" · Rp32.300.000
    - Desember 2026: no rows.
  - **Views**:
    1. **Open month with rows**: November (default) or Oktober.
    2. **Closed month**: September, with the banner and the rows.
    3. **Empty month**: Desember.
    4. **Sheet open**, over any of these.
- **Tweaks**
  - `jabatanKosong` (boolean, default off), Keadaan panel (global). On: the phone PitaJabatanKosong line on top. The sheet and its scrim sit below it.
  - `tukarJk` is disabled.
- **Interactions**
  - **Month button**: toggles `buka`.
  - **Scrim**: `buka` = false.
  - **Option**: `bulan` = that month and `buka` = false. The month button, banner, rows or empty box update at once.
  - **System Back while the sheet is open**: closes the sheet (recommended, so Back never leaves the screen with the sheet up). Otherwise Back leaves the board.
  - No typed input and no timers.
- **Motion**
  - Scrim: `pudar` 200 ms. Sheet: `muncul` 280 ms (fade plus 8 px rise, not a full slide from the bottom edge). Both use the CSS default curve `ease`, not the Gerak curve (`motion.md`: LembarBawah's `masuk` parameter set to `muncul`).
  - Closing is instant on the board: no exit animation.
  - Keyframes `isi` and `masuk` are declared but unused. Under reduce motion both appear at once.
- **Links out**
  - None: no `<a>` and no JS link.
  - **Inbound**: LihatTransaksi ("Buka Transaksi Oktober 2026"), Main (month pill "November 2026", whose Semantics label is "Pilih bulan, sekarang November 2026", and the link "Pilih bulan"), and PetaLayar's JS-built row "Pemilih bulan" (`navigation.md`).
- **Mock data** As listed under Internal views. Counts: 12 (November), 33 (Oktober), 21 (September). Recording started 15/09/2026, and the September report period is 15–30 September 2026.
- **Prototype-only** Nothing on screen. "Contoh 3 baris." is a design caption, not one of the listed prototype devices; keep it on screen as drawn (the same choice as Bukti's "Contoh 5 dari 51."). The Keadaan panel holds `jabatanKosong`.
- **Acceptance checks**
  1. **Fresh board.**
     - "Transaksi", and the button "November 2026 · Belum ditutup ▾".
     - Three rows: "Dibukukan" "Persembahan Ibadah Minggu" "Rp3.450.000" "BKU-2026-0146 · 15/11/2026"; then a dashed draft "Fotokopi warta jemaat" "−Rp150.000" in `tinta3` with "Belum ada No. Bukti · 14/11/2026"; then "Sewa sound system" "−Rp600.000".
     - Under them, "Contoh 3 baris.".
  2. **Tap the month button.** The dark scrim fades in (200 ms) and the sheet rises (280 ms) with "Pilih bulan". The November option is `lautLembut` with a 2 px `laut` border. The September option is a `tinta` block with a white "Sudah ditutup" badge.
  3. **Tap the scrim.** The sheet closes and November is still shown.
  4. **Open the sheet and pick "Desember 2026".** The sheet closes. The button reads "Desember 2026 · Belum ditutup ▾". There are no rows and no caption, only the dashed box "Belum ada transaksi di Desember 2026. Bulan tanpa transaksi belum selesai: tiap Kas/Bank tetap perlu hitung kas atau rekening koran, lalu tutup buku."
  5. **Pick "September 2026".**
     - The dark banner reads "September 2026 sudah ditutup. Hanya dapat dilihat. Dokumen susulan dan kejadian dicatat dari tiap transaksi.".
     - Rows include "OPN-2026-0001 · 15/09/2026" "Saldo awal pencatatan" "Rp32.300.000".
     - The button reads "September 2026 · Sudah ditutup ▾", and in the sheet September now has a `laut` border.
  6. **Pick "Oktober 2026".** The row "Konsumsi rapat majelis" has a "Dibalik" badge (`permukaan`, `tinta3` line) and "−Rp750.000". "Pindah antar Kas/Bank: Bank BNI ke Kas" shows "Rp2.000.000".
  7. **`jabatanKosong` on.** The line sits above "Transaksi". The open sheet's scrim starts below the line, and the line stays visible.
  8. **System Back with the sheet open** closes the sheet. Back again leaves to the previous screen.
- **Notes**
  - **The opening month is fixed.** LihatTransaksi's link reads "Buka Transaksi Oktober 2026", but the board always opens on November 2026, because it takes no parameter. Keep November and flag it.
  - **There is no in-screen back control.** The prototype relies on system and browser Back.
  - **Build the sheet as an overlay in the screen's own `Stack`**, under the PitaJabatanKosong line, not with `showModalBottomSheet`, which would cover the line.
  - **The sheet is `kertas`**, not `permukaan`, and it rises with `muncul` 280 ms rather than a full slide. Copy the board.
  - **"Belum ada No. Bukti" is set in mono** inside the code span. Keep as drawn.
  - **Cross-board figure**: BKU-2026-0127 is +Rp2.000.000 here and −Rp2.000.000 in RekonIsi. Each keeps its own; list it in `mock-data.md`.

---

### WebPilihBulan — Web · Pemilih bulan dan daftar kosong

- **Source** `docs/design/handoff/canvas/boards/WebPilihBulan.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebPilihBulan`, no child routes. The picker is a side panel. · **Widget** `WebPilihBulanScreen` in `lib/screens/lengkap/web_pilih_bulan.dart`
- **Purpose** PilihBulan on the laptop: the Bendahara Jemaat's Transaksi list with the month picker, opened from the month pill "November 2026 · Belum ditutup" on WebBeranda, WebTransaksi, TabBeranda and TabTransaksi, and from WebLihatTransaksi. On web, the phone's bottom sheet is a side panel, not a sheet covering the page (Foundations, "Phone and web").
- **Shell** The standard web side nav (see WebRekonIsi), active item **Transaksi**. The footer and the web PitaJabatanKosong follow `jabatanKosong`. It collapses below 860 px.
- **Layout** (main column, gap 20)
  1. *Web PitaJabatanKosong* (only with `jabatanKosong`).
  2. *Title row*: row, wrap, centred, gap 12.
     - h1 `judulHalaman` "Transaksi", flex 1 1 200.
     - The month button (same style as PilihBulan, 15 px body): "November 2026 · Belum ditutup ▾", with `aria-expanded`.
  3. *Two columns*: row, wrap, gap 24, aligned to the top.
     - **Left**: flex 999 1 460, min width 0, column gap 14. The closed banner, the rows plus the caption "Contoh 3 baris.", and the empty box, all the same as PilihBulan 3a–3c.
     - **Picker panel** (only while open): an aside, flex 1 1 340, min width 0, entering with `muncul` 300 ms.
       - "Pilih bulan": a plain div styled 16/700, margin-bottom 4.
       - "Semua bulan sejak tanggal mulai pencatatan." (14 `tinta2`, margin-bottom 12).
       - The four option buttons, identical to PilihBulan's.
     - There is no scrim. When narrow, the panel wraps below the list.
- **Components** As PilihBulan, but the LembarBawah content becomes a side panel. Plus the web side nav and the web PitaJabatanKosong.
- **Internal views and states** Same state, months and rows as PilihBulan. Views: list (November, Oktober), closed (September), empty (Desember), each with or without the panel.
- **Tweaks**
  - `jabatanKosong` (boolean, default off), Keadaan panel (global). On: the web banner, and the nav footer showing "Yanti Sumual · Operator / Menjalankan jabatan kosong Bendahara Jemaat".
  - `tukarJk` is disabled.
- **Interactions**
  - **Month button**: toggles the panel.
  - **Option**: sets the month and closes the panel.
  - There is no other way to close the panel. The board's "close" handler exists but nothing is bound to it.
- **Motion**
  - Panel: `muncul` 300 ms (CSS default curve `ease`) on open. Closing is instant.
  - Keyframes `isi` and `titik` are declared but unused.
- **Links out**
  - Side nav only (as WebRekonIsi, `go`).
  - **Inbound**: TabBeranda, TabTransaksi, WebBeranda and WebTransaksi (month pill "November 2026 · Belum ditutup"), WebLihatTransaksi ("Buka Transaksi Oktober 2026"), and PetaLayar's JS-built row "Pemilih bulan" (`navigation.md`).
- **Mock data** Same as PilihBulan.
- **Prototype-only** Nothing on screen. "Contoh 3 baris." stays as a design caption. The Keadaan panel holds `jabatanKosong`.
- **Acceptance checks**
  1. **At 1440**: "Transaksi" is active in the nav. The h1 "Transaksi" has the button "November 2026 · Belum ditutup ▾" at the right of the title row. The three November rows and "Contoh 3 baris." are below; there is no panel.
  2. **Click the month button**: the panel "Pilih bulan" rises in on the right of the list, and the page is not dimmed. Click again: it closes.
  3. **Pick "Desember 2026"** in the panel: the panel closes, and the left column shows only the dashed empty box.
  4. **Pick "September 2026"**: the dark closed banner and the September rows show, and the button reads "September 2026 · Sudah ditutup ▾".
  5. **At 800 px**: the nav collapses behind "Menu", and the open panel stacks under the list.
  6. **`jabatanKosong` on**: the web banner is above the title row, and the nav footer reads "Yanti Sumual · Operator".
- **Notes**
  - The panel title is a 16/700 div, while the phone uses an 18/700 h2. Give it heading semantics.
  - The left column gap is 14 here (16 on the phone).
  - The Oktober-from-WebLihatTransaksi mismatch is the same as on the phone: the board opens on November.

---

### Pemulihan — 34 · Pemulihan akun

- **Source** `docs/design/handoff/canvas/boards/Pemulihan.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Pemulihan`, no child routes. The three steps change in place under one fixed header. · **Widget** `PemulihanScreen` in `lib/screens/lengkap/pemulihan.dart`
- **Purpose**
  - **Who and when**: anyone signed out who still has their account but lost their phone number (the same person). "34 · Pemulihan akun" is not named in the handoff's "Journeys by role" list; it branches off the sign-in of "Anyone, before a post applies" step 1. Reached from Masuk and AlurMasuk ("Tidak bisa menerima kode? Pemulihan akun").
  - **What it does**: enter the backup email, receive a code, enter the six digits, and the account is recovered. Other sessions are ended, and the person is pointed to Akun saya to set the new number.
  - **Decisions it shows**:
    - **P01 / D25**: sign-in is by a code to a phone number; email is only a backup.
    - **P06**: the backup email is used only for recovery.
    - **P07**: recovery without a backup email. For the Bendahara Jemaat, the Petugas verifikasi with BPMJ; for others, the Operator after the Penatua Kolom confirms identity.
    - **P04**: other devices are signed out.
    - Recovery is not a handover: "Bila Bendahara berganti orang, pakai Serah terima Bendahara." (D21).
- **Shell** Phone, no tab bar, phone header with back (Semantics "Kembali ke Masuk"). The screen surface is `permukaan`: the whole area under the root is white, the signed-out look. There is no PitaJabatanKosong.
- **Layout**
  1. *Header*: h1 "Tidak bisa masuk" (`judulLayar`), no subtitle.
  2. *Scroll body*: padding 24 on all sides, column, gap 24. It holds exactly one step block (column gap 14).
     - **Step `mulai`**:
       - Title block: h1 24/700 (margin-bottom 4) "Pemulihan akun". Under it, 15 `tinta2`: "Untuk orang yang sama yang kehilangan nomor ponselnya. Bila Bendahara berganti orang, pakai Serah terima Bendahara."
       - Field:
         - Label (block, 14 `tinta2`, margin-bottom 6) "Email cadangan akun".
         - Input: email keyboard, full width, min height 48, padding 0 14, radius 12, 1 `garisTegas`, `permukaan`, placeholder "nama@contoh.id".
       - Button "Kirim kode pemulihan": full width, min height 52, radius 14, no border, 700, centred. Valid: `laut`, `diLaut`. Invalid: `garis`, `tinta3`.
       - Info card: `permukaan`, 1 `garis`, radius 14, padding 12 16, 14 px. Bold "Tidak punya email cadangan, atau tidak bisa membukanya?", a space, then in `tinta2` "Bendahara Jemaat: Petugas verifikasi memulihkan akun setelah memeriksa identitas Anda bersama BPMJ. Anggota dan pelayan lain: Operator memulihkan akun setelah Penatua Kolom memastikan identitas Anda."
     - **Step `kode`** (the block enters with `muncul` 300 ms):
       - h1 "Masukkan kode pemulihan".
       - 15 `tinta2`: "Dikirim ke ", then bold `tinta` ‹the email exactly as typed›.
       - Code input: full width, min height 60, padding 0 14, radius 12, 1 `garisTegas`, `permukaan`. Mono 26, letter spacing 8, centred, numeric keyboard, no placeholder, Semantics "Kode enam angka".
       - Button "Pulihkan akun", same style as above.
     - **Step `selesai`** (the block enters with `muncul` 300 ms):
       - h1 "Akun dipulihkan".
       - 15 `tinta`: "Meiske Lumentut · Wewenang Bendahara aktif".
       - Card: `permukaan`, 1 `garis`, radius 14, padding 4 16. Three rows, each padding 12 0 and 14 px; rows 2 and 3 have a top border of 1 `garis`:
         1. Bold "Orangnya sama, wewenangnya tetap." then " Tidak perlu surat penunjukan baru."
         2. Bold "Semua sesi lain diakhiri." then " Perangkat lain harus masuk lagi. ", the link "Pasang nomor ponsel baru di Akun saya" (700 `laut`), then ".".
         3. Bold "Tercatat di Riwayat aktivitas" then " sebagai pemulihan akun, 16/11/2026 12.05."
       - Link-button "Buka Beranda": full width, min height 52, radius 14, `laut`, `diLaut` 700, centred, no underline.
- **Components**
  - TombolBersyarat (`utama`, unmet text `tinta3`); the board draws no reason line, the prototype adds one (Notes).
  - The pattern "six-digit code entry", a reduced form: no wrong-code path.
  - A plain info card.
  - A 3-row confirmation card.
- **Internal views and states**
  - **Initial state**: `{ tahap: 'mulai', email: '', kode: '' }`.
  - **Email valid**: matches `.+@.+\..+`.
  - **Code valid**: exactly 6 digits.
  - The button condition follows the step: email valid in `mulai`, code valid in `kode`.
  - **Views**: `mulai` → `kode` → `selesai`. Nothing moves backwards inside the board.
- **Tweaks** None. The global `jabatanKosong` has no effect.
- **Interactions**
  - **Email**: stored as typed, not trimmed.
  - **"Kirim kode pemulihan"**: re-checks on press. When valid, `tahap` = `kode` at once (no sending timer).
  - **Code**: on every keystroke, digits only, at most 6.
  - **"Pulihkan akun"**: re-checks on press. At 6 digits, `tahap` = `selesai`. **Any six digits are accepted.**
  - The first press after typing works, because the condition is read from the latest input.
- **Motion**
  - `muncul` 300 ms (CSS default curve `ease`) on the `kode` and `selesai` blocks as they appear. The `mulai` block shows without motion.
  - Keyframes `isi`, `masuk` and `pudar` are declared but unused. Instant under reduce motion.
- **Links out**
  - Header back (Semantics "Kembali ke Masuk") → `/Masuk`, up link.
  - "Pasang nomor ponsel baru di Akun saya" → `/AkunSaya`, push.
  - "Buka Beranda" → `/Main`, go. The person is now signed in, so the sign-in screens leave the stack.
  - **Inbound**: AlurMasuk and Masuk ("Tidak bisa menerima kode? Pemulihan akun"), and PetaLayar's JS-built row "Pemulihan akun" (`navigation.md`).
- **Mock data**
  - Recovered account: "Meiske Lumentut", Bendahara Jemaat, "Wewenang Bendahara aktif".
  - Recorded 16/11/2026 12.05.
  - Placeholder "nama@contoh.id".
- **Prototype-only** Nothing on screen. The board accepts any six-digit code and shows no "123456" hint. In the Keadaan panel, add a labelled note "Kode: enam angka apa saja" so reviewers know any code passes.
- **Acceptance checks**
  1. **Fresh board.** A white screen with the header "Tidak bisa masuk" and the back arrow. "Pemulihan akun" and its 15 px line. "Email cadangan akun" is empty with the placeholder "nama@contoh.id". The "Kirim kode pemulihan" button is grey, and the info card sits under it.
  2. **Type "meiske@".** The button stays grey. Continue to "meiske@contoh.id": the button turns `laut`. Tap it: "Masukkan kode pemulihan" rises in, with "Dikirim ke **meiske@contoh.id**".
  3. **Type "12a3".** The field shows "123" in wide-spaced mono, and the button is grey. Type "456": "123456" and `laut`. Type "7": it stays "123456".
  4. **Tap "Pulihkan akun".**
     - "Akun dipulihkan" rises in with "Meiske Lumentut · Wewenang Bendahara aktif".
     - The three rows, the last ending in "16/11/2026 12.05.".
     - The `laut` "Buka Beranda".
  5. **Tap "Pasang nomor ponsel baru di Akun saya".** AkunSaya opens. Back returns to the `selesai` step, unchanged.
  6. **Tap "Buka Beranda".** Main (Beranda) opens.
  7. **The header back arrow**, in any step, returns to Masuk.
- **Notes**
  - **Off-token values**: step titles 24/700 (between `judulBesar` 22 and `judulHalaman` 26); 15 px body on the phone (the `isiWeb` size); code input mono 26 with letter spacing 8 and height 60.
  - **Two h1s** (the header and the step title). Keep the look, but give the step title heading semantics as the page heading and the header the app-bar role.
  - **No reason line under either disabled button** on the board. Added for rules A02/A03 (rules-checklist 4.1), not on the board: both buttons are TombolBersyarat; once the step's field holds text and is unmet, "Tidak dapat dilakukan: Kirim kode pemulihan. Email cadangan akun belum diisi." or "Tidak dapat dilakukan: Pulihkan akun. Kode enam angka belum diisi." shows above the button. The empty field shows none.
  - **The six-digit code pattern** (a wrong code clears the field, three attempts) is not drawn here: any code passes. The code is "sent" instantly, with no progress. Keep as drawn.
  - **The email check `.+@.+\..+` also accepts spaces**, for example "a b@c.d". Keep it.

---

### WebPemulihan — Web · Pemulihan akun

- **Source** `docs/design/handoff/canvas/boards/WebPemulihan.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebPemulihan`, no child routes · **Widget** `WebPemulihanScreen` in `lib/screens/lengkap/web_pemulihan.dart`
- **Purpose** Pemulihan on the laptop, signed out. Reached from WebMasuk and WebAlurMasuk ("Tidak bisa menerima kode? Pemulihan akun"). Shows P01/D25, P04, P06, P07 and D21, as the phone board does.
- **Shell** The signed-out web side nav. It has the same structure, measurements and below-860 collapse as the standard nav (see WebRekonIsi), but:
  - Items, both `go`:
    1. "Masuk" → `/WebMasuk`. It is drawn **active** (`tinta` field, `permukaan` text), although this page is Pemulihan.
    2. "Pemulihan akun" → `/WebPemulihan`, transparent.
  - Footer: plain 13 `tinta2` "Belum masuk" (no bold name).
  - No banner.
- **Layout** (main column, gap 20)
  1. *Centring wrapper*: flex 1, centred both ways, padding 40 0. The page is at least the viewport's height, so the card sits in the middle of the window.
  2. *Card*: width 100 %, max width 460, `permukaan`, 1 `garis`, radius **18** (off-token), padding clamp(24 px, 4 vw, 40 px), column gap 24.
     - Inside is exactly one step block, identical to Pemulihan's `mulai`, `kode` and `selesai` blocks: the same copy, sizes, colours and `muncul` entries.
     - There is no "Tidak bisa masuk" header on web. The info card inside is also `permukaan` with 1 `garis`.
- **Components** As Pemulihan, plus the signed-out side nav.
- **Internal views and states** Same as Pemulihan: initial `{ tahap: 'mulai', email: '', kode: '' }`, then `mulai` → `kode` → `selesai`.
- **Tweaks** None.
- **Interactions**
  - Same handlers and input rules as Pemulihan; any six digits are accepted.
  - The nav item "Pemulihan akun" links to this same board (kind **self** in `navigation.md`: its `Tautan` does not navigate on the current board and calls `diSini` instead, components.md 1.6). The screen gives it an in-board effect: pressing it resets the board to its initial state, as reopening the board on the canvas does. Build the nav as `NavSamping(item: navPemulihan, aktif: 0, pengguna: …, diSini: _ulang)`, `_ulang` setting the state back to `{ tahap: 'mulai', email: '', kode: '' }` and clearing both input fields. `diSini` runs on "Pemulihan akun" (its `ke` is the current board), not on the active "Masuk", which still goes to `/WebMasuk`. The link test finds both targets through `item: navPemulihan`.
- **Motion** `muncul` 300 ms (`ease`) on the `kode` and `selesai` blocks. Keyframes `isi` and `titik` are declared but unused. Instant under reduce motion.
- **Links out**
  - "Pasang nomor ponsel baru di Akun saya" → `/WebAkunSaya`, push.
  - "Buka Beranda" → `/WebBeranda`, go.
  - Nav "Masuk" → `/WebMasuk`, go. Nav "Pemulihan akun" → `/WebPemulihan`, self (resets the board, see Interactions).
  - There is no breadcrumb.
  - **Inbound**: WebAlurMasuk and WebMasuk ("Tidak bisa menerima kode? Pemulihan akun"), and PetaLayar's JS-built row "Pemulihan akun" (`navigation.md`).
- **Mock data** Same as Pemulihan.
- **Prototype-only** Nothing on screen. The Keadaan panel gets the same note: "Kode: enam angka apa saja".
- **Acceptance checks**
  1. **At 1440**: the nav shows "Masuk" filled and "Pemulihan akun" plain, with the footer "Belum masuk". A white card about 460 wide with radius 18 is centred in the content area, showing "Pemulihan akun", the email field, a grey "Kirim kode pemulihan" and the info card.
  2. Run Pemulihan checks 2–4 inside the card: the same results.
  3. **"Pasang nomor ponsel baru di Akun saya"** opens WebAkunSaya, and Back returns to the `selesai` card. **"Buka Beranda"** opens WebBeranda.
  4. **In step `kode`, click the nav "Pemulihan akun"**: the card returns to `mulai` with an empty email.
  5. **At 800 px**: the nav is a top bar with "Menu", showing "Masuk", "Pemulihan akun" and "Belum masuk" when open. The card fills the width up to 460.
- **Notes**
  - **The active nav item is "Masuk"**, not "Pemulihan akun": the board copied WebMasuk's nav and kept index 0 active. The board wins on what is shown; flag it for the design owner.
  - **Off-token radius 18** on the card, plus Pemulihan's off-token sizes (24 titles, 15 body, code 26/letter spacing 8).
  - No reason line under the disabled buttons on the board; the phone's added reason sentences apply (shared `LangkahPemulihan`).
