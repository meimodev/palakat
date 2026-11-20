# Screens 03: WebRekonsiliasi, Laporan, WebLaporan, HitungKas, WebHitungKas, Bagi, WebBagi

These seven boards carry the Bendahara Jemaat's month-end and reporting work plus one daily-work detail. Month end: on the laptop, **WebRekonsiliasi** matches Bank BNI ··4821 mutations to posted transactions until "Selisih belum dijelaskan" reaches Rp0 and the reconciliation can be confirmed; its "Kas" chip and "Hitung kas" link lead to **WebHitungKas**, the cash count by denomination, whose bank chips lead back. On the phone the same cash count is **HitungKas**, opened from "2 · Akhir bulan" (TutupBuku) and returning to it. Reporting: **Laporan** (phone) lists the fourteen forms of the Paket Laporan Bulanan GMIM and shows any form as stacked cards (D30); **WebLaporan** is the F01 page on the laptop, reached from WebPaketLaporan and WebBeranda. Both have a `jenis` tweak (resmi / sementara) and lead to the A4 page (A4F01) and the sample Excel (WebExcel). Daily work: **Bagi** (phone, from Main's Catat form) and **WebBagi** (laptop, from WebCatat) split one Toko Sinar payment of Rp1.250.000 across several Mata Anggaran rows with a BatangPembagian. Phone and web boards of the same screen are specified separately. One rule recurs: a **back-style link** is a phone header back arrow or a web breadcrumb whose target is the screen the board was opened from. It runs `kembaliKe('/X')`: pop when the route directly below is `/X` or a child of `/X`, otherwise `go('/X')`. This keeps system Back and the in-screen back control in agreement. All other links follow CONVENTIONS: `go` for side-nav and chip-tab changes, `push` for drill-ins.

---

### WebRekonsiliasi — Web · Rekonsiliasi

- **Source** `docs/design/handoff/canvas/boards/WebRekonsiliasi.dc.html` · page Web (`web`) · form Laptop page (preview 1440×1100, `expand: fill`) · interactive yes
- **Route** `/WebRekonsiliasi`, no child routes · **Widget** `WebRekonsiliasiScreen` in `lib/screens/web/web_rekonsiliasi.dart`
- **Purpose** Bendahara Jemaat on the laptop, month end (journey "Bendahara Jemaat" step 4, the web side of "2 · Akhir bulan"). Reconciling Bank BNI ··4821 for Oktober 2026. The Bendahara matches bank mutations to posted transactions (many-to-many). She turns the bank fee into a new transaction and marks a deposit as in transit. When the difference is Rp0 and no mutation is left, she confirms. It shows the Gerak `kait` rule ("two sides meet and link; the difference counts down to Rp0"), the draf line for "dalam perjalanan", and the LencanaStatus pair Sedang dikerjakan / Sudah dipastikan. No numbered decision is attached. Its end state matches F10/F11 in Laporan: buku Rp24.600.000 against rekening koran Rp24.100.000 plus Rp500.000 in transit.
- **Shell** Web side nav, active item **Rekonsiliasi**. This is the shared side nav used by every web board here:
  - `nav`: flex-basis 220 (grows 1), padding 24 vertical × 16 horizontal, `permukaan`, right border 1 `garis`, column, gap 20.
  - Brand row (gap 10, padding 0 8): the 26×26 Palakat mark (rect 2,2,20,20 rx 6, no fill, stroke `laut` 2, dasharray 3 3; plus path `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z` filled `laut`). Beside it "palakat" (18 px, 700, line height 1.1) over "Jemaat Karunia" (`keterangan`, `tinta3`).
  - Items in order: "Beranda" → `/WebBeranda`, "Transaksi" → `/WebTransaksi`, "Uang Muka dan Titipan" → `/WebKewajiban`, "Rekonsiliasi" → `/WebRekonsiliasi`, "Bulan dan tutup buku" → `/WebTutupBuku`, "Laporan" → `/WebPaketLaporan`, "Pengaturan" → `/WebPengaturan`. Each item: min height 44, padding 0 12, radius 10 (off-token), weight 600, no underline. The active item has a `tinta` field with `permukaan` text; the others are transparent with `tinta` text. All use `go`.
  - Footer: pushed to the bottom (margin-top auto), padding 12 8 0, top border 1 `garis`, 13 px `tinta2`. Default: "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (the name is strong, `tinta`). With `jabatanKosong` on: "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat".
  - At 860 px wide and below (`max-width: 860px`, inclusive) the nav becomes a full-width top bar: row, wrap, items centred, gap 0 12, padding 8×16, bottom border 1 `garis`, no right border. A toggle button sits at the right (margin-left auto): min height 44, padding 0 16, radius 14, 1.5 `tinta` border, `permukaan`, 700 14 px, label "Menu". Items and footer are hidden while closed. When open it reads "Tutup menu" on a `tinta` field with `permukaan` text, and the items (padding 8 0) and the footer (no auto top margin, padding-bottom 8) show full width below the brand row.
  - Main column: flex 999 1 560, padding top 28, sides clamp(16 px, 3 vw, 40 px), bottom 40; column, gap 20. The page uses `kertas` and body `isiWeb` (15/1.45). Links are `laut` (hover `lautTua`).
- **Layout** main column, top to bottom:
  1. *PitaJabatanKosong (web)*, only with `jabatanKosong`. Uses `role=status`, a `tinta` field, `permukaan` text, radius 14, padding 12×16, 14 px. Bold "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15." then a space and, in `diTinta2`, "Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual."
  2. *Title row* (wrap, centred, gap 12). Left, flex 1 1 200: h1 `judulHalaman` "Rekonsiliasi " followed by " · Oktober 2026" in 15 px 500 `tinta3`. Right, the status badge (LencanaStatus): 13 px 700, radius 6, padding 4×10, 1.5 border.
     - "Sedang dikerjakan": transparent, `tinta2` text, `tinta3` border.
     - "Sudah dipastikan": `laut` field, `diLaut` text, `laut` border.
  3. *Link row* (wrap, gap 0 22, margin-top −8, 14 px 600): "Isi rekening koran" → `/WebRekonIsi`, then "Hitung kas" → `/WebHitungKas`. Each link has a min hit area of 44×44.
  4. *Kas/Bank chips* (wrap, gap 8). Each chip: min height 44, padding 0 16, radius 999, 1.5 border, 600 14 px.
     - "Kas · Sudah dipastikan": a link to `/WebHitungKas`, `garisTegas` border, `permukaan`, `tinta` text.
     - "Bank BNI ··4821": the current chip (`aria-current`), `tinta` field, `permukaan` text.
     - "Bank SulutGo ··1107 · Sudah dipastikan": not pressable, `garisTegas` border, `permukaan`, `tinta2` text.
  5. *Balance card* (`permukaan`, 1 `garis`, radius 16, padding 18 vertical × 20 horizontal; wrap, items aligned to the bottom; gap 12 rows × 28 columns). From left:
     - "Saldo buku" (13 px `tinta2`) over the value (mono 20 px 500).
     - "−" (mono 20 `tinta3`, hidden from screen readers).
     - "Saldo pembanding" (13 `tinta2`), then in `tinta3` "· rekening koran Rp24.100.000" plus " + dalam perjalanan Rp500.000" when in transit. The value is under it (mono 20 500).
     - "=" (mono 20 `tinta3`, hidden from screen readers).
     - Flex 1 1 220: "Selisih belum dijelaskan" (13 px 700) over the value (mono 32 px 600, line height 1.1). The value is `laut` when it is exactly 0, otherwise `bata`. The colour change animates over 300 ms.
     - Column (gap 6, left-aligned): button "Pastikan rekonsiliasi" (min height 48, padding 0 20, radius 12, no border, 700). Enabled: `laut` field, `diLaut` text. Disabled: `garis` field, `tinta3` text. Under it, the reason sentence (13 px `tinta2`, max width 260).
  6. *Selection bar*: 1.5 dashed `putus` (draf line), radius 14, padding 8×16, min height 52; wrap, centred, gap 12. On the left, the selection sentence (flex 1 1 320, 14 px `tinta2`). On the right, button "Cocokkan" (min height 44, padding 0 20, radius 12, 700). Enabled: `tinta` field, `permukaan` text. Disabled: `garis` field, `tinta3` text.
  7. *Two lists* in a grid: `repeat(auto-fit, minmax(min(440px, 100%), 1fr))`, gap 20, aligned to the top. That gives two columns on a laptop and one when narrow.
     - Left: h2 `judulBagian` "Mutasi bank " + " · belum cocok" (13 px 500 `tinta3`), then the rows, gap 8.
     - Right: h2 "Transaksi " + " · sudah dibukukan, belum cocok", then the rows.
     - **Selectable row** (repeated pattern, not a component): outer row with radius 12, margin-bottom 2, flex, stretch.
       - Off: `permukaan` with 1 `garis` (dibukukan line). On: `lautLembut` with 1.5 `laut`.
       - Inside, a full-width press target (min height 60, padding 8×14, gap 12, `aria-pressed`) holds a checkbox, the text and the amount.
       - The checkbox is 22×22, radius 6, border 2 `tinta`. Off: `permukaan` fill and no visible check. On: `tinta` fill with a 14 px check (path `M5 12.5l4.5 4.5L19 7.5`, stroke 3.4, round) in `permukaan`.
       - Text column: the name (14 px 600), then under it the date (13 px `tinta3`). Transaction rows show "‹No. Bukti in mono› · ‹date›" instead.
       - The amount on the right: mono 500 at the inherited body size of 15 px (the board sets no size, so not the 16 px `jumlah` token).
       - Some rows carry a side action button: flex none, margin 8 8 8 0, padding 0 12, radius 10, 1.5 `tinta` border, `permukaan`, 700 13 px.
     - Empty lines (14 px `tinta2`, padding 8 0): "Semua mutasi bank sudah cocok." and "Tidak ada transaksi yang belum cocok."
  8. *Dalam perjalanan* (only while in transit; appears with `muncul` 300 ms).
     - h2 "Dalam perjalanan " + " · dibawa ke bulan berikutnya".
     - One draf row: 1.5 dashed `putus`, radius 12, padding 8×14, min height 52, gap 12.
     - In the row: "Setoran dalam perjalanan" (600 14) then " · BKU-2026-0131 · 31/10/2026" (13 `tinta3`, the No. Bukti in mono); "Rp500.000" (mono 500); and a text button "Lepaskan" (min height 44, padding 0 12, `laut` 700 at the body size 15; the one on matched cards is 14).
  9. *Cocok*: h2 "Cocok " + " · ‹N› mutasi bank".
     - Each matched group is a 2-column grid (gap 28, centred, margin-bottom 4, `position: relative`).
     - Left card: `permukaan`, 1.5 `laut`, radius 12, padding 10×14. Caption "Mutasi bank" (13 `tinta3`), names (14 600), amount (mono 500).
     - Right card: same frame, flex row gap 8. Caption "Transaksi · ‹jenis›", the transaction names (14 600), the amount (mono 500), and a text button "Lepaskan" (min height 44, padding 0 10, `laut` 700 14).
     - Centred on the gap: a 30×30 `laut` circle holding a 15 px link icon (path `M9 15l6-6M10 6l1-1a5 5 0 0 1 7 7l-1 1M14 18l-1 1a5 5 0 0 1-7-7l1-1`, stroke `diLaut` 2.6, round).
     - Closing line (14 px `tinta2`): "12 mutasi bank lain sudah cocok dengan transaksinya."
- **Components** Web side nav (shell); PitaJabatanKosong (web); LencanaStatus (Sedang dikerjakan / Sudah dipastikan); ChipPilihan look for the Kas/Bank chips (selected = `tinta` field); TombolBersyarat for "Pastikan rekonsiliasi", with the reason under the button as drawn. "Cocokkan" is a secondary dark button whose explanation is the selection sentence. GarisStatus: dashed draf for the selection bar and the in-transit row; 1.5 `laut` for matched cards. Repeated patterns that are not components: selectable row with checkbox; matched pair with link badge.
- **Internal views and states** One page; everything is in-place state.
  - Initial state `{ selM: [], selT: [], grup: [], perjalanan: false, biaya: false, pasti: false, selisih: 515000 }`.
  - Derived state:
    - **target** = (24.615.000 − (biaya ? 15.000 : 0)) − (24.100.000 + (perjalanan ? 500.000 : 0)).
    - **dipakaiM** = mutation ids in groups, plus `m3` when biaya. **dipakaiT** = transaction ids in groups, plus `t4` when perjalanan. Rows whose id is in dipakai are hidden from the lists.
    - **sama** = at least one mutation and one transaction selected and their sums equal.
    - **nol** = target === 0. **habis** = no unmatched mutation left. **bisaPasti** = nol && habis && !pasti.
  - Visible states:
    - "Dalam perjalanan" section on/off (perjalanan).
    - Biaya group on/off (biaya). It is always rendered last in Cocok: mutation "BIAYA ADM", transaction "Biaya administrasi bank · BKU-2026-0133", jenis "Belanja 5.03.03.00 · Dibukukan", amount −Rp15.000.
    - The list empty lines.
    - Badge: Sedang dikerjakan / Sudah dipastikan.
  - Selection sentence:
    - Nothing selected: "Pilih mutasi bank dan transaksi yang sama jumlahnya. Satu mutasi boleh dicocokkan dengan beberapa transaksi, dan sebaliknya."
    - Otherwise: "Mutasi bank dipilih ‹rp(sum of selected mutations)› · transaksi dipilih ‹rp(sum of selected transactions)›". Append " · jumlah sama" when sama. Append " · sisa belum dicocokkan ‹rp(|difference|)›" when both sides have a selection but the sums differ. Append nothing when only one side has a selection.
  - Pastikan reason, first match wins:
    1. pasti: "Dipastikan oleh Meiske L. Perubahan pada buku membuatnya perlu dipastikan lagi."
    2. !nol: "Selisih belum dijelaskan harus Rp0."
    3. !habis: "Masih ada mutasi bank yang belum cocok."
    4. otherwise: "Selisih Rp0 dan semua mutasi bank sudah cocok."
  - Group text:
    - Mutation names joined with " + ". Transaction names joined with " + ".
    - jenis = "‹count› transaksi", e.g. "Transaksi · 2 transaksi".
    - The amount on both cards is rp(sum of the group's mutations).
  - Cocok count N = 12 + dipakaiM.length: 12 at start, 15 when everything is matched.
- **Tweaks** `jabatanKosong` (boolean, default false), Keadaan panel (global switch).
  - Off: no banner, nav footer shows Meiske L.
  - On: web banner (region 1) and the Operator nav footer. The board's `tukarJk` is **enabled** here (`jk && true`): any string containing "Meiske L." with no date other than 16/11/2026 has "Meiske L." replaced by "Yanti Sumual, Operator". On this board that hits only the pasti reason, which becomes "Dipastikan oleh Yanti Sumual, Operator Perubahan pada buku membuatnya perlu dipastikan lagi." (see Notes).
- **Interactions**
  - **Row press** (any visible mutation or transaction row): toggles its id in selM or selT. Selection does not change pasti or the difference.
  - **"Buat transaksi dari mutasi ini"** (only on row `m3` BIAYA ADM): runs `ubah({ biaya: true, selM: selM without m3 })`. The row leaves the list, the biaya group appears in Cocok, Saldo buku becomes Rp24.600.000, and the difference animates.
  - **"Tandai dalam perjalanan"** (only on row `t4`): runs `ubah({ perjalanan: true, selT: selT without t4 })`. The row leaves the list, the Dalam perjalanan section appears, Saldo pembanding becomes Rp24.600.000 with " + dalam perjalanan Rp500.000", and the difference animates.
  - **`ubah(patch)`**: sets `pasti: false` plus the patch at once. If the target differs from the current shown difference, it cancels any running count and counts from the current shown value to the new target in 22 steps of 30 ms (660 ms in all). Each step is value = round(from + (to − from) × (1 − (1 − i/22)³)). Implement this as one 660 ms controller with that exact curve, not Flutter's `Curves.easeOutCubic`, which only approximates it. Cancel it on dispose.
  - **"Cocokkan"**: acts only when sama. It appends a group `{ m: selM copy, t: selT copy }`, clears both selections and sets pasti false. The difference does not change, because the target ignores groups.
  - **"Lepaskan" on a user group**: removes that group (its rows return to the lists, unselected) and sets pasti false. There is no difference animation.
  - **"Lepaskan" on the biaya group**: `ubah({ biaya: false })`. BIAYA ADM returns and the difference counts back up by Rp15.000.
  - **"Lepaskan" in Dalam perjalanan**: `ubah({ perjalanan: false })`.
  - **"Pastikan rekonsiliasi"**: acts only when bisaPasti and sets pasti true. The badge turns "Sudah dipastikan" and the button greys out again, because bisaPasti needs !pasti. Any later change (ubah, Cocokkan, Lepaskan) sets pasti false.
  - bisaPasti uses the target, not the animated number, so the button can enable while the number is still counting.
  - The only complete path: match TRF MASUK IBU RUNTU with Persembahan syukur + Sumbangan donatur (Rp1.000.000 each side); match TARIK TUNAI with Pindah antar Kas/Bank (−Rp2.000.000); press both side actions; then Pastikan.
  - Other equal-sum combinations are allowed, for example m1 with t1 + t4. They strand rows, and Lepaskan undoes them.
- **Motion**
  - Difference count, 660 ms as above; the Gerak `kait` meaning.
  - Difference colour transition 300 ms (`bata` ↔ `laut`). The number turns `laut` only when the shown value is exactly 0.
  - Matched cards: left card `dariKiri` (60 px from the left plus fade), right card `dariKanan` (60 px from the right plus fade), each 450 ms on curve (.2,.8,.2,1). They play once when a group first appears; key groups by identity so other groups do not replay.
  - Link circle: `kait` keyframe (scale 0 → 1.25 at 70% → 1, opacity 0 → 1 by 70%), 400 ms after a 400 ms delay, CSS default ease, fill-mode both (hidden until it starts).
  - Dalam perjalanan section: `muncul` (8 px rise plus fade) 300 ms, default ease.
  - No timers fake progress. Under reduce motion everything is instant.
- **Links out**
  - Side nav (7 items): `go`. The active "Rekonsiliasi" item points at this board itself: a self link that does nothing (navigation.md, kind self).
  - "Isi rekening koran" → `/WebRekonIsi`, push. WebRekonIsi has a "Rekonsiliasi" breadcrumb back.
  - "Hitung kas" → `/WebHitungKas`, go (same section, sibling view).
  - Chip "Kas · Sudah dipastikan" → `/WebHitungKas`, go.
  - **Inbound** (from the manifest): every web board through its side nav: WebAI, WebAIFoto, WebAIMataAnggaran, WebAlihPeruntukan, WebAwal, WebAwalIsian, WebBagi, WebBantuanAI, WebBeranda, WebBukti, WebCari, WebCatat, WebDokumen, WebDraf, WebEkspor, WebExcel, WebExcelTerbatas, WebFormatLaporan, WebHitungKas, WebImpor, WebKasus, WebKasusBaru, WebKejadian, WebKeluar, WebKesiapan, WebKewajiban, WebKoreksi, WebLaporan, WebLihatDokumen, WebLihatTransaksi, WebMataAnggaran, WebMemuat, WebPaketLaporan, WebPemberitahuan, WebPemeriksa, WebPengaturan, WebPengembalian, WebPersembahan, WebPersetujuan, WebPilihBulan, WebRekonIsi, WebSambungan, WebSerahTerima, WebTanggal, WebTransaksi, WebTutupBuku, WebUbahPengaturan, WebUnggah. Also AIBulan, TabBeranda, TabCatat, TabTransaksi. Also the map sheets PetaLayar and Cakupan, whose links are built in their logic classes and so are missing from the manifest (navigation.md lists them).
- **Mock data**
  - Bank mutations (Bank BNI ··4821, Oktober 2026):
    - `m1` "TRF MASUK IBU RUNTU", 28/10/2026, Rp1.000.000
    - `m2` "TARIK TUNAI", 30/10/2026, −Rp2.000.000
    - `m3` "BIAYA ADM", 31/10/2026, −Rp15.000
  - Posted transactions:
    - `t1` "Persembahan syukur", BKU-2026-0118, 27/10/2026, Rp500.000
    - `t2` "Sumbangan donatur", BKU-2026-0121, 28/10/2026, Rp500.000
    - `t3` "Pindah antar Kas/Bank: Bank BNI ke Kas", BKU-2026-0127, 30/10/2026, −Rp2.000.000
    - `t4` "Setoran ke bank: Kas ke Bank BNI", BKU-2026-0131, 31/10/2026, Rp500.000
  - Saldo buku Rp24.615.000 (Rp24.600.000 after the fee). Rekening koran Rp24.100.000. In transit Rp500.000. Created fee transaction "Biaya administrasi bank", BKU-2026-0133, Belanja 5.03.03.00, −Rp15.000.
  - "12 mutasi bank lain".
  - People: Meiske L. (Bendahara), Yanti Sumual (Operator). Banner time 16/11/2026 08.15.
  - Other Kas/Bank: Kas, Bank SulutGo ··1107.
- **Prototype-only** none. Only `jabatanKosong` goes in the Keadaan panel.
- **Acceptance checks**
  1. Open `/WebRekonsiliasi`: badge "Sedang dikerjakan"; Saldo buku "Rp24.615.000"; Saldo pembanding "Rp24.100.000"; difference "Rp515.000" in `bata`. "Pastikan rekonsiliasi" is grey with "Selisih belum dijelaskan harus Rp0." and "Cocokkan" is grey. 3 mutation rows, 4 transaction rows; "Cocok · 12 mutasi bank"; no Dalam perjalanan section.
  2. Select TRF MASUK IBU RUNTU and Persembahan syukur. The sentence reads "Mutasi bank dipilih Rp1.000.000 · transaksi dipilih Rp500.000 · sisa belum dicocokkan Rp500.000" and Cocokkan stays grey. Add Sumbangan donatur: the sentence ends "· jumlah sama" and Cocokkan turns `tinta`.
  3. Press Cocokkan. A group appears with "Persembahan syukur + Sumbangan donatur" and "Transaksi · 2 transaksi". Its cards slide in from left and right and the link circle pops after about 400 ms. The heading reads "Cocok · 13 mutasi bank", the three rows leave the lists and nothing is selected.
  4. Press "Tandai dalam perjalanan" on Setoran ke bank. Dalam perjalanan appears; Saldo pembanding shows "Rp24.600.000" and its label ends "+ dalam perjalanan Rp500.000"; the difference counts from Rp515.000 to "Rp15.000" in about 660 ms.
  5. Press "Buat transaksi dari mutasi ini" on BIAYA ADM. Saldo buku shows "Rp24.600.000". A group "BIAYA ADM" ↔ "Biaya administrasi bank · BKU-2026-0133" with "Transaksi · Belanja 5.03.03.00 · Dibukukan" and "−Rp15.000" appears last in Cocok. The difference counts from Rp15.000 to "Rp0" and turns `laut`; the heading reads "Cocok · 14 mutasi bank"; Pastikan stays grey with "Masih ada mutasi bank yang belum cocok." (TARIK TUNAI is still unmatched).
  6. Match TARIK TUNAI with the −Rp2.000.000 transfer. The difference stays "Rp0" in `laut` (matching never moves it); "Semua mutasi bank sudah cocok."; "Tidak ada transaksi yang belum cocok."; "Cocok · 15 mutasi bank"; the reason reads "Selisih Rp0 dan semua mutasi bank sudah cocok." and Pastikan is `laut`.
  7. Press Pastikan. The badge turns "Sudah dipastikan" (`laut` field), the reason is "Dipastikan oleh Meiske L. Perubahan pada buku membuatnya perlu dipastikan lagi." and the button is grey. Press any "Lepaskan": the badge returns to "Sedang dikerjakan".
  8. Turn `jabatanKosong` on and repeat 7: the web banner shows, the nav footer shows Yanti Sumual · Operator, and the reason reads "Dipastikan oleh Yanti Sumual, Operator Perubahan pada buku membuatnya perlu dipastikan lagi."
  9. At 860 px the side nav collapses behind "Menu"; at 1280 px two list columns show side by side.
  10. With reduce motion on, steps 3 to 5 change instantly (no slide, no count).
- **Notes**
  - Off-token values: radius 10 (nav items, side-action buttons); radius 6 on the checkbox; mono 20 and 32 px in the balance card; 30 px link circle.
  - The `tukarJk` swap removes the period after "Meiske L.", so the jk sentence has no period after "Operator". CONVENTIONS asks for the board's effect, so reproduce it verbatim; the copy is flagged for the design owner.
  - The handoff README says this page is tight at 390 px. The balance card and the selection bar wrap; check for no horizontal overflow at 390.
  - The "Bank SulutGo ··1107 · Sudah dipastikan" chip is not a link, while WebHitungKas links its SulutGo chip here. Keep each as drawn.
  - The title says Oktober 2026 but WebHitungKas says November 2026. Each board keeps its own copy.
  - F11 in Laporan prints BNI "13 / 0" mutations matched, while this board ends at "Cocok · 15 mutasi bank". Each board keeps its own figure; list it in `docs/build/mock-data.md`.
  - Copy the reasons verbatim. TombolBersyarat's "Tidak dapat dilakukan: …" prefix is not on this board, and the board wins.

---

### Laporan — 15 · Laporan

- **Source** `docs/design/handoff/canvas/boards/Laporan.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Phone 390×844 · interactive yes
- **Route** `/Laporan` (list) plus child route `/Laporan/rinci/:f` (one form, `:f` = F01…F14; an unknown id falls back to F01, as the board does) · **Widget** `LaporanScreen` in `lib/screens/lanjut/laporan.dart`
- **Purpose** Bendahara Jemaat on the phone, journey step 5 ("15 · Laporan"). Reads the Paket Laporan Bulanan GMIM for Oktober 2026 as stacked cards (**D30**). It shows PitaLaporan in both kinds, the official copy ID, and C04 (report line names, F13 "Sentralisasi / Penyaluran", "Nihil" attachments). It also shows D12 (a reversal prints as a negative in the same column, −Rp750.000 for BKU-2026-0109), D13 (F02 footnote pointing at F12) and R03 (Lampiran 2 "Nihil").
- **Shell** Phone, no tab bar. A phone header with a back control in both views. The one-line PitaJabatanKosong sits above both views and does not move during view changes; put it in a ShellRoute around `/Laporan` and its child.
- **Layout**
  - *Frame*: 390×844, `kertas`, body `isi` (16/1.4). Optional jk line on top.
  - *List view* (`/Laporan`):
    1. *Header* (padding 14 12 8, gap 8). Back link 44×44: 22 px chevron `M15 6l-6 6 6 6`, stroke 2, round, `tinta`; label "Kembali ke Lainnya". Then a column: h1 `judulLayar` "Laporan" and subtitle 13 px `tinta2` "Oktober 2026 · Paket Laporan Bulanan GMIM".
    2. *Scroll body*: padding 8 20 20, column, gap 14.
       - a. Link "Lihat transaksi di balik sebuah angka" (min height 44, 700 14 px, `laut`, margin −6 0).
       - b. When `jenis` = resmi:
         - PitaLaporan resmi: `tinta` field, `permukaan` text, radius 14, padding 12×16. Bold "Laporan resmi" (16), then 13 px `diTinta2` "Dibekukan saat tutup buku 16/11/2026 11.05 · ID SNP-2026-10-01", with the ID in mono.
         - Under it, a row of two buttons (gap 8, each flex 1, min height 48, radius 14, 700, centred). "Unduh PDF": `laut` field, `diLaut` text. "Unduh Excel": 1.5 `tinta` border, `permukaan`, `tinta` text.
       - b'. When `jenis` = sementara: PitaLaporan sementara, 1.5 dashed `putus`, radius 14, padding 12×16. Bold "Laporan sementara", then 13 px `tinta2` "Bukan laporan resmi. Angka masih dapat berubah sampai Oktober 2026 ditutup; file resmi dibuat setelah tutup buku." There are no download buttons.
       - c. *Form list card*: `permukaan`, 1 `garis`, radius 14, padding 0 16. 14 rows. Each row is a full-width button: min height 56, padding 6 0, gap 12, top border 1 `garis` except the first. In each row: the id (mono 13 `tinta2`, width 30), the name (15 px 600, flex 1), and an 18 px chevron `M9 6l6 6-6 6` in `tinta3`.
  - *Detail view* (`/Laporan/rinci/:f`), whole view on `permukaan`:
    1. *Header* (padding 14 12 8, gap 8). Back button 44×44, same chevron, label "Kembali". Then mono 13 px `tinta2`, flex 1: "‹id› · LAPORAN RESMI" or "‹id› · LAPORAN SEMENTARA · BUKAN LAPORAN RESMI".
    2. *Scroll body*: padding 4 20 20, gap 12.
       - a. Title block: bottom border 2 `tinta`, padding-bottom 12. The form name (19 px 700, line height 1.25); "Jemaat Karunia · Periode laporan 1–31 Oktober 2026" (14); the form's `sub` (13 `tinta3`).
       - b. Stacked cards, one per table row.
         - Each card: padding 10 0. Bottom border 1 `garis`, or 1.5 `tinta` for a heading or total row.
         - Title: 15 px, weight 500, or 700 for heading/total rows.
         - Optional code line: mono 13 `tinta2`.
         - One line per number: label 13 `tinta2` on the left, value mono 15 px on the right (weight 500 or 700, no wrap). Baseline-aligned, gap 16, padding-top 3.
       - c. The form's footnote (13 `tinta3`).
       - d. Fixed line (13 `tinta3`): "Di ponsel tiap baris laporan ditumpuk; kolom dan angkanya sama dengan PDF dan Excel."
  - *How cards are built* (reproduce exactly). Each table has `cols`, `kanan` (indexes of number columns) and `rows`. A row whose last element is the marker `1` is a heading or total row; drop the marker.
    1. Walk the non-empty cells in column order.
    2. A cell whose index is in `kanan` becomes a number line (label = column name, value = cell).
    3. Otherwise, if it matches `^(BKU|OPN|ADJ)-|^\d\.\d|^\d\d/\d\d/\d{4}$` it is a code.
    4. Otherwise it is text.
    5. Card title = text cells joined by " · ". If there is no text, the title is the first code, removed from the codes.
    6. Code line = the remaining codes joined by " · ".
    - Example, F03 row 2: title "Persembahan Ibadah Minggu dan Diakonia", code line "04/10/2026 · BKU-2026-0098", lines "Penerimaan Rp3.200.000" and "Saldo Kas Rp7.270.000".
    - Example, F14 row 1: title "1 · Uang Muka · 3 kasus" (no number columns).
    - The board's `tpl` (grid widths) and `mono` fields are not used on the phone.
- **Components** PitaJabatanKosong (phone line); PitaLaporan (resmi and sementara); Tombol primary and secondary (Unduh PDF / Unduh Excel). The stacked report card is a repeated pattern that is not a component.
- **Internal views and states**
  - Initial state `{ buka: null }`.
  - List view (`buka` null) at `/Laporan`.
  - Detail view (`buka` = id) at `/Laporan/rinci/:f`, one per form, 14 in all.
  - Inside the list, the resmi or sementara variant comes from the tweak. The detail header caption also follows the tweak.
- **Tweaks**
  - `jabatanKosong` (boolean, default false), Keadaan panel (global). On: a one-line banner above both views: `role=status`, `tinta` field, `permukaan` text, padding 10 24 8, 13 px, line height 1.3, centred, "**Menjalankan jabatan kosong** · Bendahara Jemaat". `tukarJk` is disabled on this board, so no copy is swapped.
  - `jenis` (enum, options `resmi`, `sementara`, default **resmi**), Keadaan panel.
    - resmi: dark PitaLaporan with frozen time and ID, plus the two download buttons; detail caption "LAPORAN RESMI".
    - sementara: dashed PitaLaporan, no download buttons; detail caption "LAPORAN SEMENTARA · BUKAN LAPORAN RESMI".
- **Interactions**
  - Form row press → `push('/Laporan/rinci/‹id›')`, F01 to F14 (state `buka` = id).
  - Detail back button → pop (state `buka` = null). If there is nothing to pop, `go('/Laporan')`. System Back does the same.
  - There is no typed input, no condition and no timer.
- **Motion**
  - Detail view enters with `masuk` (24 px from the right plus fade) over 280 ms, curve (.2,.8,.2,1) (`pindahLayar`).
  - List view appears with `pudar` (fade) over 200 ms when the route is built; not on return.
  - `isi` and `muncul` are declared but unused. Under reduce motion all of this is instant.
- **Links out**
  - Back arrow "Kembali ke Lainnya" → `kembaliKe('/Lainnya')`.
  - "Lihat transaksi di balik sebuah angka" → `/LihatTransaksi`, push.
  - "Unduh PDF" → `/A4F01`, push.
  - "Unduh Excel" → `/WebExcel`, push. This is a laptop board, so it renders in laptop form.
  - **Inbound**: FormatLaporan ("Lihat contoh PDF"), Keputusan (decision 30), Lainnya, LihatTransaksi, Main ("Buat laporan sementara"), TutupBuku ("Lihat laporan sementara"), and the map sheet PetaLayar (a link built in its logic class, not in the manifest).
- **Mock data**
  - Form list, verbatim:
    - F01 Laporan Perbendaharaan Bulanan
    - F02 Buku Kas Umum
    - F03 Buku Kas Pembantu
    - F04 Mata Anggaran Pendapatan
    - F05 Realisasi Pendapatan Menurut Mata Anggaran
    - F06 Mata Anggaran Belanja
    - F07 Realisasi Belanja Menurut Mata Anggaran
    - F08 Rekap Penerimaan
    - F09 Rekap Pengeluaran
    - F10 Posisi Kas & Bank
    - F11 Rekonsiliasi
    - F12 Daftar Bukti Kas
    - F13 Sentralisasi / Penyaluran
    - F14 Lampiran Laporan Bulanan
  - The 14 tables (sub, cols, number columns, rows with total markers, footnote) are copied verbatim from source lines 66–101 (F03–F14), 104 (F01) and 105 (F02) into `lib/mock/laporan_oktober.dart`. Row counts: F01 8, F02 33, F03 23, F04 6, F05 8, F06 6, F07 11, F08 4, F09 4, F10 3, F11 8, F12 5, F13 4, F14 8.
  - F01 rows:
    - Saldo awal Kas/Bank Rp36.250.000 (total)
    - Pendapatan ekonomi Rp14.820.000
    - Belanja ekonomi −Rp11.455.000
    - Dana Transit masuk Rp2.400.000
    - Dana Transit keluar −Rp2.400.000
    - Uang Muka diberikan −Rp1.500.000
    - Pengembalian sisa uang muka Rp350.000
    - Saldo akhir Kas/Bank Rp38.465.000 (total)
    - F01 footnote: "Nama baris uang muka mengikuti format laporan yang disetujui 03/10/2026."
  - Subtitles:
    - F01 "Ringkasan bulan"
    - F02 "Semua Kas/Bank"
    - F03 "Buku per Kas/Bank · Kas"
    - F04 and F06 "Versi Mata Anggaran 2026.1"
    - F05 "Pendapatan menurut Mata Anggaran"
    - F07 "Belanja menurut Mata Anggaran"
    - F08 "Penerimaan buku per Kas/Bank"
    - F09 "Pengeluaran buku per Kas/Bank"
    - F10 "Per 31 Oktober 2026"
    - F11 "Per Kas/Bank"
    - F12 "No. Bukti Oktober 2026"
    - F13 "Titipan per pihak, lalu Sentralisasi dari uang milik sendiri"
    - F14 "Delapan lampiran"
  - Official copy ID "SNP-2026-10-01", frozen at 16/11/2026 11.05.
  - People in rows: Pnt. Jefry Wowor, Sdri. Natalia Rumengan, Ibu Selvie Kalalo, Panitia HUT Jemaat, Toko Sinar.
  - Kas/Bank: Kas, Bank BNI ··4821, Bank SulutGo ··1107.
- **Prototype-only** none. `jabatanKosong` and `jenis` go in the Keadaan panel.
- **Acceptance checks**
  1. Default (`jenis` resmi): the dark pita reads "Dibekukan saat tutup buku 16/11/2026 11.05 · ID SNP-2026-10-01"; "Unduh PDF" and "Unduh Excel" are visible; 14 rows F01–F14.
  2. Set `jenis` to sementara: the dashed pita "Laporan sementara" replaces the dark one and both download buttons disappear.
  3. Tap "F03 Buku Kas Pembantu". The detail slides in from the right in 280 ms on a white background. The header reads "F03 · LAPORAN RESMI" and the sub reads "Buku per Kas/Bank · Kas". The first card "Saldo awal Kas" is bold, with "Saldo Kas Rp4.070.000" and a 1.5 `tinta` bottom line. The footnote begins "22 baris Kas · Saldo akhir Kas Rp8.750.000."
  4. In F03 the card "Pembalikan BKU-2026-0105" shows code line "12/10/2026 · BKU-2026-0109" and "Pengeluaran −Rp750.000" (U+2212).
  5. In F14 the first card title is "1 · Uang Muka · 3 kasus" with no number lines.
  6. The detail back button and system Back both return to the list, which fades in. The browser URL goes from `/Laporan/rinci/F03` to `/Laporan`.
  7. With sementara, open F01: the header reads "F01 · LAPORAN SEMENTARA · BUKAN LAPORAN RESMI".
  8. The header back arrow goes to `/Lainnya`; "Unduh PDF" opens `/A4F01`.
  9. With `jabatanKosong` on, the one-line banner shows above both views and stays put during the slide.
- **Notes**
  - The source repeats some style properties; the later value wins. Subtitles are 13 px (not 14), the list gap is 14, the detail body has padding-top 4 and gap 12, and "Unduh PDF" is min height 48.
  - Off-token values: title 19 px; mono 15 px values.
  - In F11 the "Status" row's values ("Sudah dipastikan") render in mono, because they are in number columns. Keep as drawn.
  - Main and TutupBuku link here with "laporan sementara" labels, but the board default is resmi. Keep the default; reviewers switch `jenis` in the Keadaan panel.
  - The F01 footnote dates the format approval 03/10/2026; WebLaporan says 01/11/2026 (approval) and 02/11/2026 (recorded). Each board keeps its own; list it in `mock-data.md`.
  - WebPaketLaporan contains the same F03–F14 tables. Share the constants only if they are byte-identical; F01 and F02 differ.
  - The fixed line "Di ponsel tiap baris laporan ditumpuk; …" reads like a designer's note, but it is screen copy on the board. Keep it.

---

### WebLaporan — Web · Laporan F01

- **Source** `docs/design/handoff/canvas/boards/WebLaporan.dc.html` · page Web (`web`) · form Laptop page (preview 1440×1200, `expand: fill`) · interactive no (tweaks and links only)
- **Route** `/WebLaporan`, no child routes · **Widget** `WebLaporanScreen` in `lib/screens/web/web_laporan.dart`
- **Purpose** Bendahara Jemaat on the laptop, journey step 5. Shows F01 Laporan Perbendaharaan Bulanan for Oktober 2026 as an on-screen page, provisional or official.
  - PitaLaporan; the line language on the paper itself (dashed = sementara, solid `tinta` = resmi).
  - C04 line names ("Uang Muka diberikan", "Pengembalian sisa uang muka", "Dana Transit masuk/keluar").
  - F10 figures and the format-approval record (KartuPersetujuan, recorded state; approval given outside the app).
  - Related: D14 (no signatures on printed pages). This screen does draw two blank signature lines; see Notes.
- **Shell** Web side nav as in WebRekonsiliasi, active item **Laporan** (which itself links to `/WebPaketLaporan`). Main column gap **18** (not 20).
- **Layout** main column:
  1. *PitaJabatanKosong (web)*, as in WebRekonsiliasi region 1.
  2. *Title row* (wrap, centred, gap 12): h1 `judulHalaman` "Laporan " + " · Oktober 2026" (15 px 500 `tinta3`), flex 1 1 260. When resmi only, two link-buttons follow (min height 44, padding 0 18, radius 12, 700, centred). "Unduh PDF": `laut` field, `diLaut` text. "Unduh Excel": 1.5 `tinta` border, `permukaan`, `tinta` text.
  3. *PitaLaporan* (radius 14, padding 12×16; wrap, baseline-aligned, gap 4×16):
     - sementara: 1.5 dashed `putus`. Bold "Laporan sementara", then 14 px `tinta2` "Bukan laporan resmi. Angka masih dapat berubah sampai Oktober 2026 ditutup; file resmi dibuat setelah tutup buku."
     - resmi: `tinta` field, `permukaan` text. Bold "Laporan resmi", then 14 px `diTinta2` "Dibekukan saat tutup buku 16/11/2026 11.05 · ID SNP-2026-10-01 · Versi Mata Anggaran 2026.1", with the ID in mono.
  4. *Two columns* (wrap, gap 24, aligned to the top):
     - **Paper**: flex 999 1 560, `permukaan`, radius 6, padding clamp(20 px, 4 vw, 48 px), column, gap 22. Border 1.5 dashed `putus` when sementara, 1.5 solid `tinta` when resmi.
       - a. Head: column, gap 2, bottom border 2 `tinta`, padding-bottom 14.
         - "F01 · LAPORAN SEMENTARA · BUKAN LAPORAN RESMI" or "F01 · LAPORAN RESMI" (13 px 600 `tinta2`, letter-spacing 0.4).
         - "LAPORAN PERBENDAHARAAN BULANAN" (22 px 700, letter-spacing 0.2).
         - "Jemaat Karunia · Periode laporan 1–31 Oktober 2026" (15).
         - "Format bawaan aplikasi. Mencakup seluruh Jemaat: semua peruntukan dan semua kas/bank." (13 `tinta3`).
       - b. Eight lines. Each line: flex, baseline-aligned, gap 12, padding 9 0. Top border: none on the first, 1.5 `tinta` on total lines, 1 `garis` otherwise. In each line:
         - The label (flex 1, weight 700 for totals and 500 otherwise), with an optional " · ‹note›" in 13 `tinta3`.
         - On non-total lines, a link "Lihat transaksi" (13 px 600, min height 44).
         - The value: width 150, right-aligned, mono, weight 600 for totals and 400 otherwise.
         - Rows as in Mock data.
       - c. Posisi Kas & Bank: column, gap 8.
         - Title (700): "Posisi Kas & Bank per 31 Oktober 2026".
         - A horizontally scrollable table (min width 600, full width, 14 px).
           - Header cells: 600 `tinta2`, bottom 1 `tinta`. Padding 8 0 on the first cell; 8 0 8 12 and right-aligned on the others.
           - Columns: "Kas/Bank", "Saldo buku", "Hasil hitung kas", "Saldo rekening koran", "Selisih belum dijelaskan".
           - Body cells: bottom 1 `garis`; money right-aligned mono. Empty cells stay blank (not "—").
         - Note (13 `tinta3`): "Bank BNI ··4821: setoran dalam perjalanan Rp500.000, dibawa ke November 2026. Hasil hitung kas dan saldo rekening koran tidak dijumlahkan."
       - d. Signature grid: `repeat(auto-fit, minmax(min(200px,100%),1fr))`, gap 24, margin-top 8. Each column has gap 4: a 13 px `tinta2` label, a 56 px blank with a bottom 1 `tinta` line, and the name (600).
         - "Bendahara" / "Meiske Lumentut"
         - "Ketua BPMJ" / "[NAMA DARI PENGATURAN]"
     - **Aside**: flex 1 1 280, column, gap 14.
       - a. Card (`permukaan`, 1 `garis`, radius 14, padding 16, gap 4):
         - "Format laporan" (13 `tinta2`)
         - "Bawaan Palakat · v1" (700)
         - "Persetujuan format: sudah dicatat" (14 bold, margin-top 6)
         - 14 px: "Pemberi persetujuan:" in `tinta2`, then " [NAMA], Pimpinan Jemaat yang berwenang · 01/11/2026"
         - Footer (13 `tinta3`, top border 1 dashed `garisTegas`, margin-top 8, padding-top 8): "Dicatat oleh Meiske L., 02/11/2026 09.10. Persetujuan diberikan di luar aplikasi."
       - b. Card (same frame, gap 6):
         - "Isi Paket Laporan Bulanan GMIM" (700)
         - "F01 Laporan Perbendaharaan Bulanan" (14 600 `tinta`)
         - Link "Buka F02 sampai F14" (14 600, min height 44)
- **Components** Web side nav; PitaJabatanKosong (web); PitaLaporan (both kinds); Tombol primary and secondary (Unduh PDF / Unduh Excel); KartuPersetujuan (recorded state, as drawn). Repeated pattern: report line with "Lihat transaksi" drill link.
- **Internal views and states** No interaction state (`stateInit` null). There are two visual states from `jenis`; see Tweaks.
- **Tweaks**
  - `jabatanKosong` (boolean, default false), Keadaan panel (global). On: web banner (region 1) and the Operator nav footer. `tukarJk` is disabled here (`jk && false`): "Dicatat oleh Meiske L., …" and "Meiske Lumentut" stay.
  - `jenis` (enum, options `sementara`, `resmi`, default **sementara**; note the option order differs from Laporan), Keadaan panel.
    - sementara: dashed pita, dashed paper border, caption "F01 · LAPORAN SEMENTARA · BUKAN LAPORAN RESMI", no download buttons.
    - resmi: dark pita with ID and "Versi Mata Anggaran 2026.1", solid 1.5 `tinta` paper border, caption "F01 · LAPORAN RESMI", "Unduh PDF" and "Unduh Excel" in the title row.
- **Interactions** Links only (below). No handlers, no input, no timers.
- **Motion** none (no keyframes or transitions on this board).
- **Links out**
  - Side nav: `go`.
  - "Unduh PDF" → `/A4F01`, push.
  - "Unduh Excel" → `/WebExcel`, push.
  - "Lihat transaksi" (6 links, on lines 2–7) → `/WebTransaksi`, push (a drill-in from a figure).
  - "Buka F02 sampai F14" → `kembaliKe('/WebPaketLaporan')`. WebPaketLaporan opens this page with "Buka halaman F01", so this is the way back.
  - **Inbound**: TabBeranda ("Buat laporan sementara"), WebBeranda ("Buat laporan sementara"), WebPaketLaporan ("Buka halaman F01"), WebPengaturan ("Lihat laporan"), WebTutupBuku ("Lihat laporan resmi" and "Lihat laporan sementara"), and the map sheets PetaLayar and Cakupan (links built in their logic classes, not in the manifest).
- **Mock data**
  - F01 lines (label · value · note · total · has link):
    - Saldo awal Kas/Bank · Rp36.250.000 · total
    - Pendapatan ekonomi · Rp14.820.000 · link
    - Belanja ekonomi · −Rp11.455.000 · link
    - Dana Transit masuk · Rp2.400.000 · "titipan masuk" · link
    - Dana Transit keluar · −Rp2.400.000 · "titipan disalurkan" · link
    - Uang Muka diberikan · −Rp1.500.000 · link
    - Pengembalian sisa uang muka · Rp350.000 · link
    - Saldo akhir Kas/Bank · Rp38.465.000 · total
  - Posisi Kas & Bank:
    - Kas | Rp8.750.000 | Rp8.750.000 | (blank) | Rp0
    - Bank BNI ··4821 | Rp24.600.000 | (blank) | Rp24.100.000 | Rp0
    - Bank SulutGo ··1107 | Rp5.115.000 | (blank) | Rp5.115.000 | Rp0
  - SNP-2026-10-01; Versi Mata Anggaran 2026.1; Meiske Lumentut / Meiske L.; approval 01/11/2026, recorded 02/11/2026 09.10; format "Bawaan Palakat · v1".
- **Prototype-only** none. `jabatanKosong` and `jenis` go in the Keadaan panel.
- **Acceptance checks**
  1. Default: the dashed pita "Laporan sementara" shows; the paper border is dashed; the paper caption reads "F01 · LAPORAN SEMENTARA · BUKAN LAPORAN RESMI"; there is no "Unduh PDF" button.
  2. Set `jenis` to resmi: "Unduh PDF" and "Unduh Excel" appear beside the title; the dark pita ends "· Versi Mata Anggaran 2026.1"; the paper border is solid `tinta`; the caption is "F01 · LAPORAN RESMI".
  3. Exactly six "Lihat transaksi" links show (not on Saldo awal or Saldo akhir); each opens `/WebTransaksi`, and Back returns here.
  4. "Saldo akhir Kas/Bank" reads "Rp38.465.000" in mono 600, with a 1.5 `tinta` line above it.
  5. At 860 px the aside wraps under the paper and the Posisi table fits (about 736 px of paper content, table min width 600). At 390 px the table scrolls sideways inside the paper, and the page itself has no horizontal scroll.
  6. "Buka F02 sampai F14" returns to `/WebPaketLaporan`. The side nav shows "Laporan" active.
  7. With `jabatanKosong` on, the banner and the Operator footer show, and the aside footer still reads "Dicatat oleh Meiske L., 02/11/2026 09.10. …".
- **Notes**
  - Off-token values: paper radius 6; title 22 px with letter-spacing; line padding 9.
  - Signature lines with names appear on this web page even though D14 says printed pages carry no signatures. Keep them as drawn (the board wins), and flag them for the design owner.
  - "[NAMA DARI PENGATURAN]" and "[NAMA]" are placeholders drawn on the board. Keep them verbatim.
  - The dashed divider in the approval card is 1 px `garisTegas`, not the draf line. Copy it as drawn.
  - WebTutupBuku links here twice, as "Lihat laporan resmi" and "Lihat laporan sementara", but a link carries no tweak value: the page opens in its `jenis` default (sementara). Reviewers switch `jenis` in the Keadaan panel.

---

### HitungKas — 5 · Hitung kas

- **Source** `docs/design/handoff/canvas/boards/HitungKas.dc.html` · page Ponsel (`ponsel`) · form Phone 390×844 · interactive yes
- **Route** `/HitungKas` (count) plus child route `/HitungKas/banding` (comparison with Saldo buku) · **Widget** `HitungKasScreen` in `lib/screens/ponsel/hitung_kas.dart`
- **Purpose** Bendahara Jemaat on the phone, month end (journey step 4, with "2 · Akhir bulan"). Counts the cash box per denomination (**D09**), names the counters, attaches the count sheet, compares with Saldo buku, and saves even when there is a difference (**D10**). Shows the principle "not yet known is not zero" ("Belum dihitung. Kosong bukan Rp0.") and that a difference is never "fixed" in place.
- **Shell** Phone, no tab bar, phone header with back in both views. The one-line PitaJabatanKosong sits above both views. Board state (counts, counters, document, saved) lives in one controller owned by a ShellRoute around `/HitungKas` and `/HitungKas/banding`, so it survives the view change. Dispose it when the user leaves `/HitungKas` entirely.
- **Layout**
  - *Frame*: 390×844, `kertas`, `isi`. Optional jk line (same as Laporan).
  - *Count view* (`/HitungKas`):
    1. *Header* (padding 14 12 8, gap 8). Back link 44×44 with chevron `M15 6l-6 6 6 6`, label "Kembali ke Bulan". Then a column: h1 `judulLayar` "Hitung kas" and 13 px `tinta2` "Kas · 16 November 2026 · 11.30".
    2. *Scroll body*: padding 8 20 20, gap 18.
       - a. "Hasil hitung kas" (14 `tinta2`). Under it the result: mono 38 px 500, letter-spacing −1, line height 1.15. It is `tinta` when counted and `tinta3` "—" when not. Under that, a caption (13 `tinta3`).
       - b. *Denomination card* (`permukaan`, 1 `garis`, radius 14, padding 0 12 0 16). Seven PenghitungPecahan rows. Each row: min height 56, gap 8, top border 1 `garis` except the first. In each row:
         - The denomination: width 92, mono 15 500, e.g. "100.000" with no "Rp".
         - Minus button: 44×44, radius 12, 1.5 `garisTegas` border, `permukaan`, "−" at 22 px 600.
         - The count: width 36, centred, mono 17 600.
         - Plus button: 44×44, radius 12, `tinta` field, `permukaan` "+" at 22 px 600.
         - The product: flex 1, right-aligned, mono 14. `tinta` when the count > 0; "—" in `tinta3` when the count is 0.
         - Screen-reader labels: "Kurangi satu lembar Rp100.000" and "Tambah satu lembar Rp100.000" (per denomination).
       - c. Button "Kas kosong: catat Rp0": full width, min height 48, radius 12, 1.5 dashed `putus`, transparent, 700 `tinta2`, centred.
       - d. "Petugas penghitung" (14 `tinta2`), then " · paling sedikit satu" in `tinta3`, margin-bottom 8.
         - Three toggle chips, wrapping inline: min height 44, padding 0 14, margin 0 8 8 0, radius 999, 1.5 border, 600 14 px.
         - On: `tinta` field, `permukaan` text. Off: `garisTegas` border, `permukaan`, `tinta` text.
         - Each chip carries `aria-pressed`.
       - e. "Dokumen pendukung" (14 `tinta2`, margin-bottom 8). The content depends on whether a file is attached:
         - Not attached: button "Lampirkan lembar hitung kas", full width, min height 52, radius 12, 1.5 dashed `putus`, transparent, 600 `laut`, centred.
         - Attached: a card (radius 12, 1 `garisTegas`, `permukaan`, padding 12×14). "lembar-hitung-16-11.jpg · Terlampir" (14 600), then "Diunggah, belum diverifikasi" (13 `tinta2`).
    3. *Footer* (padding 12 20 22, `permukaan`, top border 1 `garis`, gap 8).
       - When blocked, the reason (14 `tinta2`).
       - Button "Bandingkan dengan Saldo buku": min height 52, radius 14, 700, centred. Enabled: `laut` field, `diLaut` text. Blocked: `garis` field, `tinta3` text.
  - *Comparison view* (`/HitungKas/banding`):
    1. *Header*: back button 44×44 (label "Kembali") and h1 `judulLayar` "Kas · hitung kas dan buku".
    2. *Scroll body*: padding 8 20 20, gap 18.
       - a. Card (`permukaan`, 1 `garis`, radius 16, padding 16, gap 10):
         - "Saldo buku" (`tinta2`) with "Rp8.420.000" (mono 500), 15 px.
         - "Hasil hitung kas" with the result, 15 px.
         - Total row: top border 1.5 `tinta`, padding-top 12, baseline. "Selisih belum dijelaskan" (700) with the absolute difference (mono 26 px 600), `laut` when 0 and `bata` otherwise.
       - b. Explanation block, depending on the difference:
         - Difference ≠ 0, column gap 10:
           - 15 px: bold "Uang di kas kurang ‹rp› dari buku." (or "Uang di kas lebih ‹rp› dari buku."), then " Hasil hitung disimpan apa adanya; tidak ada tindakan untuk menyamakan angka."
           - 14 px `tinta2`: "Selisih hilang hanya dengan mencatat transaksi yang terlewat, atau menghitung lagi. Bila masih ada saat akhir bulan, selisih menjadi hambatan tutup buku."
           - Link-button "Catat transaksi yang terlewat".
           - Button "Hitung lagi".
           - Both are full width, min height 48, radius 14, 1.5 `tinta` border, `permukaan`, 700, centred.
         - Difference = 0: a `lautLembut` card, radius 14, padding 14×16, 15 px 600: "Hasil hitung kas sama dengan Saldo buku."
       - c. Once saved, a row (gap 14):
         - A 56×56 seal. SVG viewBox 88: a circle r 38 filled `laut` with a 3 px `laut` stroke, dasharray 239, rotated −90°. Over it a check, path `M29 45l10 10 20-21`, stroke `diLaut` 5, round.
         - Beside it, `role=status`: "Hitung kas tersimpan" (700), then 14 `tinta2` "Dihitung oleh ‹names› · 16/11/2026 11.30".
    3. *Footer* (padding 12 20 22, `permukaan`, top 1 `garis`):
       - Before saving: primary button "Simpan hitung kas", full width, min height 52, radius 14, `laut`, 700.
       - After saving: a link-button "Kembali ke Bulan", same size, 1.5 `tinta` border, `permukaan`, 700.
- **Components** PitaJabatanKosong (phone line); PenghitungPecahan (7 rows); ChipPilihan (multi-select counters); TombolBersyarat ("Bandingkan dengan Saldo buku", reason above); Tombol (primary "Simpan hitung kas", secondary "Hitung lagi", "Catat transaksi yang terlewat", "Kembali ke Bulan"); a PanelDokumen-like attached-file card; StatusSimpan-like saved line.
- **Internal views and states**
  - Initial state `{ screen: 'hitung', n: null, nol: false, petugas: [], dok: false, tersimpan: false }`.
  - Denominations P = [100.000, 50.000, 20.000, 10.000, 5.000, 2.000, 1.000]. BUKU = 8.420.000.
  - Counts: `n` if set. Otherwise, from the tweak: `contohTerisi` on → [80, 5, 5, 1, 2, 0, 0]; off → all 0.
  - total = Σ count × P. **dihitung** = total > 0 or nol. **bisa** = dihitung and at least one counter. selisih = BUKU − total.
  - Count view states:
    - Result "—" in `tinta3` with caption "Belum dihitung. Kosong bukan Rp0." when not counted.
    - "Rp0" with "Dihitung: Rp0" when counted and the total is 0.
    - "‹rp(total)›" with "Dihitung per pecahan" otherwise.
    - Document absent or attached.
    - Footer reason: "Isi hasil hitung, atau catat Rp0 bila kas memang kosong." when not counted; else "Pilih petugas penghitung." when no counter; hidden when bisa.
  - Comparison view states:
    - Difference 0 or not, with the direction sentence "kurang" when selisih > 0, "lebih" when < 0.
    - Saved or not.
- **Tweaks**
  - `jabatanKosong` (boolean, default false), Keadaan panel (global). On: the one-line phone banner only. `tukarJk` is disabled; the counter chip "Meiske L." stays.
  - `contohTerisi` (boolean, default **true**), Keadaan panel.
    - On: counts 80/5/5/1/2/0/0, result Rp8.370.000.
    - Off: all counts 0, result "—", footer reason "Isi hasil hitung, atau catat Rp0 bila kas memang kosong."
    - The tweak only applies while the counts are untouched (`n` null). After any + or − or "Kas kosong", the counts are the user's.
- **Interactions**
  - **+ / −** on a row: count = max(0, count ± 1); sets `n` to the new array and `nol` false, `tersimpan` false. Pressing − at 0 still sets `nol` false. So after "Kas kosong", pressing − on any row makes the result "—" again.
  - **"Kas kosong: catat Rp0"**: counts all 0, `nol` true, `tersimpan` false. The result becomes "Rp0" with caption "Dihitung: Rp0".
  - **Counter chip**: toggles that name in `petugas`, keeping the order of selection.
  - **"Lampirkan lembar hitung kas"**: `dok` true at once. The attached card appears. There is no upload step and no way to detach.
  - **"Bandingkan dengan Saldo buku"**: acts only when bisa (TombolBersyarat checks again on press) → `push('/HitungKas/banding')`.
  - **Back in the comparison view** (header button, "Hitung lagi" and system Back): pop to `/HitungKas` and set `tersimpan` false. The counts, counters and document stay.
  - **"Simpan hitung kas"**: `tersimpan` true. The seal row appears and the footer becomes "Kembali ke Bulan". "Dihitung oleh" joins the names with " dan " in selection order, e.g. "Dihitung oleh Meiske L. dan Pnt. Jefry Wowor".
  - Opening `/HitungKas/banding` directly while bisa is false redirects to `/HitungKas`.
  - No typed input and no timers.
- **Motion**
  - Count view appears with `pudar` 200 ms (not replayed on return).
  - Comparison view enters with `masuk` 280 ms on curve (.2,.8,.2,1) (`pindahLayar`).
  - Attached-file card: `muncul` 280 ms.
  - In the comparison view, each with `muncul` 300 ms, fill-mode both:
    - the "Hasil hitung kas" row after a 150 ms delay;
    - the total row after 350 ms;
    - the explanation block (either kind) after 500 ms.
  - Saved row: `muncul` 300 ms. Its circle runs `lingkar`: stroke-dashoffset 239 → 0 over 700 ms, ease-out. The check runs `pudar` 300 ms after a 500 ms delay.
  - `denyut` is declared but unused. Under reduce motion everything shows at once.
- **Links out**
  - Count header back "Kembali ke Bulan" → `kembaliKe('/TutupBuku')`.
  - "Catat transaksi yang terlewat" → `/Main`, go (tab-level screen).
  - Footer "Kembali ke Bulan" (after saving) → `kembaliKe('/TutupBuku')`.
  - **Inbound**: TutupBuku ("Hitung kas", "Hitung kas · Kas belum dihitung"), Keputusan (decisions 9 and 10), and the map sheets PetaLayar and Cakupan (links built in their logic classes, not in the manifest).
- **Mock data** Saldo buku Kas Rp8.420.000 on 16 November 2026 11.30. Sample counts 80 × 100.000, 5 × 50.000, 5 × 20.000, 1 × 10.000, 2 × 5.000, giving Rp8.370.000 and a difference of Rp50.000 ("kurang"). Counters: "Meiske L.", "Pnt. Jefry Wowor", "Dkn. Olga Tamba". File "lembar-hitung-16-11.jpg".
- **Prototype-only** none on screen. `contohTerisi` and `jabatanKosong` go in the Keadaan panel.
- **Acceptance checks**
  1. Default: result "Rp8.370.000" with "Dihitung per pecahan"; row 100.000 shows count 80 and "Rp8.000.000"; rows 2.000 and 1.000 show 0 and "—". The footer reads "Pilih petugas penghitung." over a grey "Bandingkan dengan Saldo buku".
  2. Tap "Meiske L.": the chip turns `tinta`, the reason disappears and the button turns `laut`. Tap the button: the comparison slides in. Saldo buku "Rp8.420.000"; the result row fades in at about 150 ms; "Rp50.000" in `bata` at about 350 ms; "Uang di kas kurang Rp50.000 dari buku. …" at about 500 ms.
  3. Tap "Simpan hitung kas": the seal draws and the check fades in. "Hitung kas tersimpan" / "Dihitung oleh Meiske L. · 16/11/2026 11.30" shows, and the footer becomes "Kembali ke Bulan".
  4. Tap "Hitung lagi": back to the count, still Rp8.370.000. Tap + on 50.000 (count 6), then compare: "Rp0" in `laut` and "Hasil hitung kas sama dengan Saldo buku."
  5. Turn `contohTerisi` off on a fresh board: result "—" in `tinta3`, "Belum dihitung. Kosong bukan Rp0.", footer "Isi hasil hitung, atau catat Rp0 bila kas memang kosong." Tap "Kas kosong: catat Rp0": "Rp0" / "Dihitung: Rp0" and footer "Pilih petugas penghitung."
  6. Tap "Lampirkan lembar hitung kas": the card "lembar-hitung-16-11.jpg · Terlampir" / "Diunggah, belum diverifikasi" rises in.
  7. Select "Pnt. Jefry Wowor" and then "Meiske L.", compare and save: "Dihitung oleh Pnt. Jefry Wowor dan Meiske L. · 16/11/2026 11.30".
  8. System Back on `/HitungKas/banding` returns to the count with the counts kept; Back again goes to TutupBuku when that is below.
- **Notes**
  - Sizes: the result is the `jumlahUtama` style (mono 38/500), with the board's own line height 1.15 and letter-spacing −1. Off-token values: count 17 px; "+" and "−" 22 px; difference 26 px mono.
  - The board shows a refusal on an empty count when `contohTerisi` is off. TombolBersyarat says an empty form opens without one, but the board wins. Copy the reasons verbatim, without the "Tidak dapat dilakukan:" prefix.
  - The attachment is instant ("Terlampir" with no progress), unlike the rule that uploads always look in progress. Keep it as drawn.
  - The circle is filled `laut` from the start, so `lingkar` only animates its 3 px edge. Reproduce it as drawn.
  - Saldo buku Kas here (Rp8.420.000, 16/11) differs from F10 (Rp8.750.000, 31/10). They are different dates; each keeps its own.

---

### WebHitungKas — Web · Hitung kas

- **Source** `docs/design/handoff/canvas/boards/WebHitungKas.dc.html` · page Web (`web`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebHitungKas`, no child routes · **Widget** `WebHitungKasScreen` in `lib/screens/web/web_hitung_kas.dart`
- **Purpose** Bendahara Jemaat on the laptop, month end. The cash count for the Kas within Rekonsiliasi. It shows D09 (per denomination, typed counts here) and D10 (saving with a difference), and "Kosong bukan Rp0".
- **Shell** Web side nav as in WebRekonsiliasi, active item **Rekonsiliasi**. Main column gap 20.
- **Layout** main column:
  1. *PitaJabatanKosong (web)*, as in WebRekonsiliasi.
  2. h1 `judulHalaman` "Rekonsiliasi " + " · November 2026" (15 px 500 `tinta3`).
  3. *Kas/Bank chips* (wrap, gap 8). Each chip: min height 44, padding 0 16, radius 999, 1.5 border, 600 14.
     - "Kas · hitung kas": current (`aria-current=page`), `tinta` field, `permukaan` text.
     - "Bank BNI ··4821" and "Bank SulutGo ··1107": links, `garisTegas` border, `permukaan`, `tinta` text.
  4. *Two columns* (wrap, gap 24, aligned to the top):
     - **Left**: flex 999 1 420, gap 12.
       - a. A row (wrap, baseline, gap 6×16): h2 "Hitung kas" (18 px 700) and "16 November 2026 · 11.30" (14 `tinta2`).
       - b. Card (`permukaan`, 1 `garis`, radius 14, padding 4 18). All rows use a grid of `1fr 120px 1fr` with gap 16.
         - Header row (padding 10 0, 13 px 600 `tinta2`): "Pecahan" | "Lembar" (right) | "Jumlah" (right).
         - Seven rows (padding 6 0, top 1 `garis`, centred):
           - A label tied to its input: mono 500 "Rp100.000" (with "Rp").
           - The input: full cell width, min height 44, padding 0 12, radius 10, 1 `garisTegas`, `permukaan`, mono 15, right-aligned, placeholder "—", numeric keyboard.
           - The product: right-aligned mono. `tinta` when filled; "—" in `tinta3` when the cell is empty.
         - Total row (padding 12 0, top 1.5 `tinta`, 700): "Hasil hitung kas" | blank | the result (right, mono, `tinta` when counted, `tinta3` "—" when not).
       - c. A row (wrap, centred, gap 12):
         - Button "Kas kosong: catat Rp0": min height 44, padding 0 16, radius 12, 1.5 dashed `putus`, transparent, 700 `tinta2`.
         - The caption (13 `tinta3`, flex 1 1 240).
     - **Aside**: flex 1 1 340, gap 16.
       - a. Card (`permukaan`, 1 `garis`, radius 16, padding 18, gap 10):
         - "Saldo buku" (`tinta2`) with "Rp8.420.000" (mono 500).
         - "Hasil hitung kas" with the result (mono 500, `tinta` or `tinta3`).
         - Total row (top 1.5 `tinta`, padding-top 12, gap 12, baseline): "Selisih belum dijelaskan" (700) with the difference (mono 28 px 600). Colour: `tinta3` "—" when not counted, `laut` when 0, `bata` otherwise. The colour change animates over 300 ms.
         - The difference caption (14 `tinta2`).
       - b. "Petugas penghitung" + " · paling sedikit satu" (14 `tinta2` / `tinta3`, margin-bottom 8). Three toggle chips (wrap, gap 8, no margins), styled as in HitungKas.
       - c. A **non-interactive** dashed box (1.5 dashed `putus`, radius 12, padding 12×14, 14 px `tinta2`): bold `laut` "Lampirkan dokumen pendukung", then " · foto lembar hitung kas".
       - d. Column (gap 6):
         - Button "Simpan hitung kas": min height 50, radius 12, 700, centred. Enabled: `laut`, `diLaut`. Blocked: `garis`, `tinta3`.
         - Under it, the status line (`role=status`, 14 px): `laut` 700 when saved, otherwise `tinta2` 400.
- **Components** Web side nav; PitaJabatanKosong (web); ChipPilihan (Kas/Bank chips, counters); TombolBersyarat ("Simpan hitung kas", status sentence below); StatusSimpan (saved line in `laut`). The denomination table is the web form of PenghitungPecahan: typed counts, not steppers.
- **Internal views and states**
  - Initial state `{ v: ['80', '5', '5', '1', '2', '', ''], nol: false, petugas: [], tersimpan: false }`. The cells are strings; empty means "pecahan itu tidak ada".
  - total = Σ int(cell or 0) × P. **ada** = any cell not empty (a typed "0" counts). **dihitung** = ada or nol. **bisa** = dihitung and a counter chosen and not saved.
  - Caption under the table, first match:
    1. nol and total 0: "Dihitung: Rp0. Nol dicatat sebagai hasil hitung, bukan sebagai belum dihitung."
    2. dihitung: "Sel kosong berarti pecahan itu tidak ada."
    3. otherwise: "Belum dihitung. Kosong bukan Rp0."
  - Difference caption:
    - Not counted: "Selisih baru dapat dihitung setelah ada hasil hitung kas."
    - Difference 0: "Hasil hitung kas sama dengan Saldo buku."
    - Otherwise: "Uang di kas kurang dari buku. " or "Uang di kas lebih dari buku. ", followed by "Hasil hitung disimpan apa adanya; tidak ada tindakan untuk menyamakan angka."
  - Status line, first match:
    1. Saved: "Hitung kas tersimpan · dihitung oleh ‹names joined with " dan "›"
    2. Not counted: "Isi hasil hitung, atau catat Rp0 bila kas memang kosong."
    3. No counter: "Pilih petugas penghitung."
    4. Otherwise: "Siap disimpan."
- **Tweaks** `jabatanKosong` (boolean, default false), Keadaan panel (global). On: web banner and the Operator nav footer. `tukarJk` is disabled; the "Meiske L." chip and the saved line keep "Meiske L.".
- **Interactions**
  - **Typing in a count cell**, on every change:
    1. Remove non-digits.
    2. Strip leading zeros that are followed by a digit, so "007" becomes "7" and "0" stays "0".
    3. Keep at most 5 characters.
    4. Store the result, set `nol` false and `tersimpan` false.
    - No thousands separators. Keep the caret at the end after reformatting.
  - **"Kas kosong: catat Rp0"**: all cells empty, `nol` true, `tersimpan` false.
  - **Counter chip**: toggles the name (selection order kept) and sets `tersimpan` false.
  - **"Simpan hitung kas"**: TombolBersyarat. It re-checks bisa from the latest input on press, so the first press after typing works, and if bisa it sets `tersimpan` true. The button then greys out (bisa needs not saved). Any edit makes it "Siap disimpan." and active again.
  - No timers.
- **Motion** Difference colour transition 300 ms. `muncul` is declared but unused. There is no other motion.
- **Links out**
  - Side nav: `go`.
  - Chips "Bank BNI ··4821" and "Bank SulutGo ··1107" → `/WebRekonsiliasi`, go (both go to the same board).
  - **Inbound**: TabBeranda ("Hitung kas"), WebBeranda ("Hitung kas"), WebRekonsiliasi ("Hitung kas", "Kas · Sudah dipastikan"), and the map sheets PetaLayar and Cakupan (links built in their logic classes, not in the manifest).
- **Mock data** Saldo buku Rp8.420.000; date "16 November 2026 · 11.30"; denominations Rp100.000 down to Rp1.000; sample cells 80/5/5/1/2/empty/empty, giving Rp8.370.000 and a difference of Rp50.000; counters "Meiske L.", "Pnt. Jefry Wowor", "Dkn. Olga Tamba".
- **Prototype-only** none. `jabatanKosong` goes in the Keadaan panel.
- **Acceptance checks**
  1. Default: cells show 80, 5, 5, 1, 2, then two "—" placeholders. Products include "Rp8.000.000" and "—". Result "Rp8.370.000" with the caption "Sel kosong berarti pecahan itu tidak ada."; difference "Rp50.000" in `bata`; difference caption "Uang di kas kurang dari buku. Hasil hitung disimpan apa adanya; tidak ada tindakan untuk menyamakan angka."; status "Pilih petugas penghitung."; Simpan grey.
  2. Type "a1b2" in the Rp2.000 cell: it shows "12" and the product "Rp24.000". Type "007" in a cell: it shows "7". Type "123456": it shows "12345".
  3. Select "Meiske L.": status "Siap disimpan." and Simpan turns `laut`. Press it: the status reads "Hitung kas tersimpan · dihitung oleh Meiske L." in `laut` bold and the button is grey. Edit any cell: back to "Siap disimpan." with the button active.
  4. Press "Kas kosong: catat Rp0": all cells empty with "—" placeholders; result "Rp0"; caption "Dihitung: Rp0. Nol dicatat sebagai hasil hitung, bukan sebagai belum dihitung."; difference "Rp8.420.000".
  5. Clear every cell by hand: result "—", difference "—" in `tinta3`, "Selisih baru dapat dihitung setelah ada hasil hitung kas.", status "Isi hasil hitung, atau catat Rp0 bila kas memang kosong."
  6. Set the Rp50.000 cell to 6 (with the other default values): difference "Rp0" in `laut` and "Hasil hitung kas sama dengan Saldo buku."
  7. Click "Bank BNI ··4821": `/WebRekonsiliasi` opens.
  8. At 860 px the side nav collapses behind "Menu" and the aside still sits beside the table (420 + 24 + 340 = 784 fits in about 808 px of main column). Below about 834 px, and at 390, the aside wraps under the table.
- **Notes**
  - Off-token values: radius 10 on inputs; mono 28 px difference; button height 50.
  - X03: the denomination label also focuses its count field on tap, but it is excluded from semantics; the 44 px count field beside it is the target.
  - The title reads "· November 2026" while WebRekonsiliasi reads "· Oktober 2026". Each keeps its own.
  - The dashed "Lampirkan dokumen pendukung" box looks like a control but has no handler. Render it inert, as drawn.
  - The status sentence sits below the button, not above as the TombolBersyarat guideline says. The board wins.
  - The handoff README says this page is tight at 390 px. Check that the grid's 120 px middle column does not overflow.

---

### Bagi — 6 · Bagi ke beberapa Mata Anggaran

- **Source** `docs/design/handoff/canvas/boards/Bagi.dc.html` · page Ponsel (`ponsel`) · form Phone 390×844 · interactive yes
- **Route** `/Bagi`, no child routes (the Mata Anggaran picker is a bottom sheet) · **Widget** `BagiScreen` in `lib/screens/ponsel/bagi.dart`
- **Purpose** Bendahara Jemaat on the phone, daily work (journey step 2, from "1 · Harian" Catat). Splits one Belanja payment (Toko Sinar, Rp1.250.000) across several Mata Anggaran rows. It stays one transaction with one No. Bukti, and the rows must add up to Jumlah. Shows BatangPembagian and the split part of PemilihMataAnggaran. In the reports this payment is BKU-2026-0101 (F12) with 5.01.02.00 Rp1.000.000 and 5.02.01.00 Rp250.000 (F07). The board starts at Rp200.000 so a remainder is visible.
- **Shell** Phone, no tab bar, phone header with back. The one-line PitaJabatanKosong sits on top. The sheet and its backdrop cover only the area below that banner.
- **Layout**
  1. *Header* (padding 14 12 8, gap 8):
     - Back link 44×44, chevron `M15 6l-6 6 6 6`, label "Kembali ke transaksi".
     - Column, flex 1: h1 `judulLayar` "Bagi ke beberapa Mata Anggaran" (wraps to two lines) and 13 `tinta2` "Belanja · Toko Sinar · satu pembayaran".
     - Badge "Belanja": 13 px 700, `tinta` field, `permukaan` text, radius 6, padding 4×10, margin-right 8.
  2. *Scroll body*: padding 8 20 20, gap 16.
     - a. "Jumlah (Rp)" (14 `tinta2`) over "Rp1.250.000" (mono 34 px 500, letter-spacing −1).
     - b. *BatangPembagian* (column, gap 8):
       - The bar: height 18, radius 9, 1.5 dashed `putus` border, clipped, transparent. Inside, one segment per row in order. Each segment is full height, width = clamp(0–100 %, value ÷ max(Jumlah, total) × 100 %).
       - Segment colours by position: `tinta`, `laut`, #86B5B8 (illustration literal), `tinta2`, `garisTegas`, repeating.
       - Under the bar (space-between, baseline): the label (14 700) and the amount (mono 18 600). Both are `laut` when the remainder is 0, otherwise `bata`.
     - c. *Rows card* (`permukaan`, 1 `garis`, radius 14, padding 0 16). Each row: padding 12 0, top 1 `garis` except the first. Each row has two lines:
       - **Line 1** (align top, gap 10):
         - A colour swatch: 12×12, radius 3, the segment colour, margin-top 5.
         - Text (flex 1): mono 13 `tinta2` "Belanja ‹No. MA›", then the name as a label for the input (15 px 600).
         - A remove button: 44×44, margin −8 −10 0 0, an 18 px × icon (`M6 6l12 12M18 6L6 18`, `tinta3`, stroke 2), labelled "Lepas baris ‹name›".
       - **Line 2** (right-aligned, gap 10, margin-top 4):
         - Only when the row is empty and the remainder is above 0: button "Isi sisa" (min height 44, padding 0 12, radius 10, `tinta` field, `permukaan` text, 700 14).
         - The amount field: width 160, 1.5 `tinta` underline, baseline, gap 4.
           - "Rp" (14 `tinta3`).
           - The input: transparent, no border, mono 17 px 500, right-aligned, min height 44, placeholder "—", numeric keyboard.
     - d. Button "+ Tambah baris": full width, min height 48, radius 12, 1.5 dashed `putus`, transparent, 700 `laut`, centred.
     - e. Note (13 `tinta3`): "Pembayaran ini tetap satu transaksi dengan satu No. Bukti. Di laporan, jumlahnya tampil sekali dengan daftar Mata Anggarannya."
  3. *Footer* (padding 12 20 22, `permukaan`, top 1 `garis`, gap 8):
     - When not balanced, the reason (14 `tinta2`).
     - When used and still balanced, the status (`role=status`, 14 700 `laut`): "Mata Anggaran sudah dipilih · dibagi ke ‹n› baris".
     - Primary button "Pakai pembagian ini" (min height 52, radius 14, 700). Enabled: `laut`/`diLaut`. Blocked: `garis`/`tinta3`.
  4. *Sheet* "Pilih Mata Anggaran" (LembarBawah), only when open:
     - Backdrop: a full-area button in `tinta` at 45 % opacity, labelled "Kembali ke pembagian".
     - Panel at the bottom: `permukaan`, top radius 22, padding 10 20 24.
       - Handle: 40×4, radius 2, `garisTegas`, centred, margin-bottom 14.
       - h2 `judulLayar` "Pilih Mata Anggaran", margin-bottom 6.
       - One full-width button per unused Mata Anggaran: min height 60, top 1 `garis`, padding 8 0. Mono 13 `tinta2` "Belanja ‹No. MA›" over the name (15 px 600).
       - When none is left: "Semua baris contoh sudah dipakai." (14 `tinta2`, padding 12 0).
- **Components** PitaJabatanKosong (phone line); BatangPembagian; IsianJumlah (row form: "Rp" prefix plus an underline, as drawn); PemilihMataAnggaran (split rows plus picker); LembarBawah (picker sheet); TombolBersyarat ("Pakai pembagian ini", reason above); a LencanaStatus-shaped "Belanja" type badge.
- **Internal views and states**
  - Initial state `{ baris: [{ k: '5.01.02.00', v: '1000000' }, { k: '5.02.01.00', v: '200000' }], pilih: false, dipakai: false }`. `v` holds raw digit strings.
  - total = Σ int(v or 0). sisa = 1.250.000 − total. **kosong** = any row empty. **pas** = sisa 0 and not kosong and at least 2 rows.
  - Bar label:
    - sisa 0: "Total baris sama dengan Jumlah"
    - sisa < 0: "Total baris lebih dari Jumlah"
    - otherwise: "Sisa belum dibagi"
    - The amount shown is rp(|sisa|).
  - Footer reason, first match:
    1. fewer than 2 rows: "Pembagian memerlukan paling sedikit dua baris."
    2. kosong: "Masih ada baris yang belum diisi."
    3. otherwise: "Total baris harus sama dengan Jumlah."
  - The "used" status shows only while `dipakai` and pas.
  - Sheet open or closed (`pilih`). The sheet list holds the Mata Anggaran not yet in the rows, in source order, or the empty line when none is left.
  - With zero rows the card renders as an empty bordered strip. Keep it as drawn.
- **Tweaks** `jabatanKosong` (boolean, default false), Keadaan panel (global). On: the one-line phone banner only (`tukarJk` disabled).
- **Interactions**
  - **Typing an amount**, on every change:
    1. Remove non-digits (the dots typed or shown included).
    2. Strip leading zeros that are followed by a digit.
    3. Keep at most 11 digits.
    4. Store the raw digits and set `dipakai` false.
    - Display with dot thousands separators as the person types ("250000" shows "250.000"), keeping the caret sensible.
    - The bar, label and footer update on every change. The first press of "Pakai pembagian ini" after typing must see the latest value.
  - **"Isi sisa"**: sets that row to String(sisa), the exact remainder, so the row is balanced.
  - **× (Lepas baris)**: removes the row and sets `dipakai` false. The swatch and segment colours re-index by position.
  - **"+ Tambah baris"**: opens the sheet (`pilih` true).
  - **Sheet option**: appends `{ k, v: '' }`, closes the sheet and sets `dipakai` false.
  - **Backdrop tap**: closes the sheet. System Back while the sheet is open also closes it.
  - **"Pakai pembagian ini"**: TombolBersyarat. If pas on press, `dipakai` true and the status shows. Nothing navigates.
  - No timers.
- **Motion**
  - Segment width changes: 450 ms on curve (.2,.8,.2,1) (`kait` duration), on every value change.
  - Sheet: the backdrop runs `pudar` 200 ms; the panel runs `naik` (from 100 % below) 280 ms on the same curve (`pindahLayar`). The board closes the sheet with no exit animation; close it instantly.
  - "Used" status: `muncul` 300 ms.
  - `masuk` is declared but unused. Under reduce motion everything is instant.
- **Links out**
  - Header back "Kembali ke transaksi" → `kembaliKe('/Main')` (pops back to Main's Catat view when that is below).
  - **Inbound**: Main ("Bagi ke beberapa Mata Anggaran"), AIMataAnggaran ("Pilih sendiri"), and the map sheets PetaLayar and Cakupan (links built in their logic classes, not in the manifest).
- **Mock data**
  - Jumlah Rp1.250.000; "Toko Sinar"; type Belanja.
  - Mata Anggaran (Belanja, in order):
    - 5.01.02.00 "Listrik, air dan telepon"
    - 5.02.01.00 "Alat tulis dan fotokopi"
    - 5.03.03.00 "Biaya administrasi bank"
    - 5.04.01.00 "Konsumsi rapat"
    - 5.05.02.00 "Sewa peralatan"
  - Start rows Rp1.000.000 and Rp200.000, so the remainder is Rp50.000.
  - Segment colours `tinta`, `laut`, #86B5B8, `tinta2`, `garisTegas`.
  - Write the logic once and use it from both Bagi and WebBagi. The two boards' logic is identical.
- **Prototype-only** none on screen. `jabatanKosong` goes in the Keadaan panel.
- **Acceptance checks**
  1. Initial: the bar shows 80 % `tinta` and 16 % `laut`, with the dashed frame visible in the last 4 %. "Sisa belum dibagi" with "Rp50.000" in `bata`; the footer reads "Total baris harus sama dengan Jumlah." over a grey "Pakai pembagian ini".
  2. Change the second row to "250000": the field shows "250.000"; the bar fills in 450 ms; "Total baris sama dengan Jumlah" with "Rp0" in `laut`; the reason disappears and the button turns `laut`. Press it at once: "Mata Anggaran sudah dipilih · dibagi ke 2 baris" appears.
  3. Change it to "300000": "Total baris lebih dari Jumlah" with "Rp50.000" in `bata`; the status disappears.
  4. From the initial state tap "+ Tambah baris": the sheet rises in 280 ms with three options (5.03.03.00, 5.04.01.00, 5.05.02.00). Pick "Biaya administrasi bank": the sheet closes and row 3 appears with a #86B5B8 swatch, an empty "—" field and "Isi sisa". The reason reads "Masih ada baris yang belum diisi."
  5. Tap "Isi sisa": the field shows "50.000" and the button is enabled.
  6. Remove rows until one is left: the reason reads "Pembagian memerlukan paling sedikit dua baris."
  7. Add rows until all five are used, then open the sheet: it shows only "Semua baris contoh sudah dipakai."
  8. Tap the backdrop or press system Back with the sheet open: the sheet closes and the page stays.
  9. Tap the header back arrow: `/Main` shows (popped if it was below).
- **Notes**
  - Off-token values: amount 34 px; input 17 px; bar radius 9; swatch radius 3; "Isi sisa" radius 10; amount underline 1.5 instead of IsianJumlah's 2. Copy the board.
  - The board labels the remainder "Sisa belum dibagi" rather than PemilihMataAnggaran's "kurang Rp…". The board wins.
  - "Semua baris contoh sudah dipakai." mentions "contoh" (sample rows). It is screen copy on the board; keep it.
  - The board's reason has no "Tidak dapat dilakukan:" prefix. Copy it verbatim.

---

### WebBagi — Web · Bagi ke beberapa Mata Anggaran

- **Source** `docs/design/handoff/canvas/boards/WebBagi.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebBagi`, no child routes · **Widget** `WebBagiScreen` in `lib/screens/lengkap/web_bagi.dart`
- **Purpose** Bendahara Jemaat on the laptop, daily work: the same split as Bagi, reached from WebCatat. On the web the Mata Anggaran picker is inline (no sheet), following the rule that the web uses a side panel or inline content instead of a bottom sheet.
- **Shell** Web side nav as in WebRekonsiliasi, active item **Transaksi**. Main column gap 20.
- **Layout** main column:
  1. *PitaJabatanKosong (web)*, as in WebRekonsiliasi.
  2. *Title block*:
     - Breadcrumb link "Catat transaksi" (14 px 600, `laut`).
     - h1 `judulHalaman` "Bagi ke beberapa Mata Anggaran", margin-top 2.
     - 14 `tinta2` "Belanja · Toko Sinar · satu pembayaran, satu No. Bukti".
     - There is no type badge on the web.
  3. *Two columns* (wrap, gap 28, aligned to the top):
     - **Left**: flex 999 1 480, gap 14.
       - a. *Rows card* (`permukaan`, 1 `garis`, radius 14, padding 0 18). Each row is one wrapping line: centred, gap 10×14, padding 12 0, top 1 `garis` except the first. In order:
         - The swatch: 12×12, radius 3.
         - Text (flex 1 1 220): mono 13 `tinta2` "Belanja ‹No. MA›" over the name, 600 at the body size of 15.
         - "Isi sisa", under the same condition and style as in Bagi.
         - The amount field: width **170**, otherwise as in Bagi.
         - The remove button: 44×44, × icon in `tinta3`, labelled "Lepas baris ‹name›".
       - b. "Tambah baris" (14 `tinta2`, margin-bottom 8), followed by inline option chips. Each chip: inline-flex, baseline, gap 8, min height 44, padding 0 14, margin 0 8 8 0, radius 12, 1.5 dashed `putus`, transparent. Inside: mono 13 `tinta2` No. MA (no "Belanja" prefix) and the name (600 14). One chip per unused Mata Anggaran. When none is left, the label stands alone (there is no empty-state line on the web).
     - **Aside**: flex 1 1 340, gap 12.
       - a. "Jumlah (Rp)" (14 `tinta2`) over "Rp1.250.000" (mono 34 500, letter-spacing −1).
       - b. The bar, as in Bagi.
       - c. Label and amount, as in Bagi, with gap 16.
       - d. The reason (14 `tinta2`) when not balanced.
       - e. The status (`role=status`, 14 700 `laut`) "Mata Anggaran sudah dipilih · dibagi ke ‹n› baris". It has no animation on the web.
       - f. Primary "Pakai pembagian ini": min height 52, radius 14, padding 0 20, 700, colours as in Bagi.
       - g. Note (13 `tinta3`): "Di laporan, jumlahnya tampil sekali dengan daftar Mata Anggarannya."
- **Components** Web side nav; PitaJabatanKosong (web); BatangPembagian; IsianJumlah (row form); PemilihMataAnggaran (inline option chips with dashed draf lines); TombolBersyarat.
- **Internal views and states** Same state and derived values as Bagi: initial `{ baris: [5.01.02.00 '1000000', 5.02.01.00 '200000'], pilih: false, dipakai: false }`, the same labels, reasons and status. `pilih` exists in the state but is never shown, because there is no sheet.
- **Tweaks** `jabatanKosong` (boolean, default false), Keadaan panel (global). On: web banner and the Operator nav footer. `tukarJk` is disabled.
- **Interactions** As in Bagi, except:
  - Pressing an option chip appends that row directly (`{ k, v: '' }`) and sets `dipakai` false.
  - There is no "+ Tambah baris" button and no sheet.
  - Typing rules, "Isi sisa", remove, and the "Pakai pembagian ini" condition and its re-check on press are identical.
- **Motion**
  - Segment width transition 450 ms on curve (.2,.8,.2,1).
  - `muncul`, `isi` and `titik` are declared but unused. There is no other motion. Under reduce motion everything is instant.
- **Links out**
  - Side nav: `go`.
  - Breadcrumb "Catat transaksi" → `kembaliKe('/WebCatat')`.
  - **Inbound**: WebCatat ("Bagi ke beberapa Mata Anggaran"), TabCatat ("Bagi ke beberapa Mata Anggaran"), WebAIMataAnggaran ("Pilih sendiri"), and the map sheet PetaLayar (a link built in its logic class, not in the manifest).
- **Mock data** Identical to Bagi (Rp1.250.000, Toko Sinar, five Belanja Mata Anggaran, start rows Rp1.000.000 and Rp200.000, segment colours). Share the constant and the logic.
- **Prototype-only** none. `jabatanKosong` goes in the Keadaan panel.
- **Acceptance checks**
  1. Initial: two rows, three dashed option chips ("5.03.03.00 Biaya administrasi bank", "5.04.01.00 Konsumsi rapat", "5.05.02.00 Sewa peralatan"); "Sisa belum dibagi" "Rp50.000" in `bata`; reason "Total baris harus sama dengan Jumlah."; side nav "Transaksi" active.
  2. Click the "5.04.01.00 Konsumsi rapat" chip: the chip disappears and row 3 appears with a #86B5B8 swatch, an empty field and "Isi sisa"; the reason reads "Masih ada baris yang belum diisi."
  3. Click "Isi sisa": the field shows "50.000"; the label reads "Total baris sama dengan Jumlah" "Rp0" in `laut`; the button is enabled. Click it: "Mata Anggaran sudah dipilih · dibagi ke 3 baris".
  4. Type "1.300.000" into row 1: it shows "1.300.000"; the label reads "Total baris lebih dari Jumlah" with "Rp300.000" in `bata` (total Rp1.550.000); the bar is full (segments scaled to the total) and the status line is gone.
  5. Add all chips: the label "Tambah baris" stays with no chips under it.
  6. Click "Catat transaksi": `/WebCatat` shows (popped if it was below).
  7. At 860 px the aside wraps under the rows and the side nav collapses behind "Menu".
- **Notes**
  - On the web the status line has no `muncul` animation, unlike on the phone. Keep the difference.
  - The web header drops the "Belanja" badge and adds ", satu No. Bukti" to the subtitle; the note is shorter than the phone's. Copy each board verbatim.
  - The web option chips use radius 12 with a dashed draf line, not ChipPilihan's 999. Copy the board.
