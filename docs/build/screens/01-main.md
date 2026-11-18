# Screens 01: Main, TutupBuku, WebTutupBuku

These three boards carry the Bendahara Jemaat's core money journey of round 1. `Main` ("1 · Harian: catat sampai bukukan") is the phone app's home: Beranda with the combined Saldo buku, the Transaksi tab, the "Catat apa?" sheet, the Catat form, the Mata Anggaran picker, Periksa dan bukukan with the Bukukan motion (`tinta`), and the booked transaction. Its "Bulan" tab, its "Oktober 2026 belum ditutup" row and its "Rekonsiliasi" link all open `TutupBuku` ("2 · Akhir bulan: rekonsiliasi dan tutup buku"), the phone month-end flow: the month list, the readiness check for October 2026, the Bank BNI reconciliation with the match motion (`kait`), the permanent-close confirmation with the hold button (`segelTahan`), and the sealed result (`segel`). `WebTutupBuku` ("Web · Tutup buku") is the laptop version of the same month close on one fluid page with the finance side nav: the three month cards, an optional blocker list, the confirmation panel with the same hold button, and the sealed result panel. Each board keeps its own state and its own figures (CONVENTIONS, Behaviour); the web board does not share state with the phone board.

---

### Main — 1 · Harian: catat sampai bukukan

- **Source** `docs/design/handoff/canvas/boards/Main.dc.html` · page Ponsel (`ponsel`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/Main` (Beranda) plus child routes `/Main/transaksi` (Transaksi tab), `/Main/catat` (Catat form), `/Main/mata-anggaran` (Pilih Mata Anggaran), `/Main/periksa` (Periksa dan bukukan / Sudah dibukukan), `/Main/detail` (booked transaction) · **Widget** `MainScreen` in `lib/screens/ponsel/main.dart`
- **Purpose** The Bendahara Jemaat's daily work, journey step 2 of "Bendahara Jemaat" in `03-screens-and-flows.md`: see the combined book balance, see what needs action, record a Pendapatan, Belanja, Persembahan or Pindah antar Kas/Bank, check it and post it (Bukukan), or keep it as a Draf. Decisions shown: D03 (one combined "Saldo buku semua Kas/Bank" on Beranda), D01 (Kas/Bank, peruntukan, Lingkup and Mata Anggaran start empty, four separate chip fields, never pre-filled), D02 (a missing supporting document does not block Bukukan; it is shown as "Boleh dibukukan, tetapi menjadi hambatan tutup buku"), D29 (five bottom tabs with Catat in the centre), R04 and PitaJabatanKosong (`jabatanKosong`), StatusSimpan rules (honest save state, input stays on screen on failure), PemilihMataAnggaran rules (group headings not postable, "Simpan tanpa Mata Anggaran" only for a draft, no "Lainnya"), Gerak `tinta` (ink sweep, No. Bukti stamp, balance counting).
- **Shell** Board root: 390×844 column, background `kertas`, text `tinta`, sans 16 line-height 1.4. On top, when `jabatanKosong` is on, the phone PitaJabatanKosong strip (full width, `flex: none`, pushes everything below down). Below it one stacked content area (relative, fills the rest) in which the views are layered absolutely:
  - Phone tab bar, only on Beranda and Transaksi: Beranda (active `laut` on Beranda), Transaksi (active `laut` on Transaksi), centre Catat button, Bulan, Lainnya (both always `tinta3`, they are links out). Hidden on every other view.
  - Phone header with back on Catat, Pilih Mata Anggaran, Periksa (back only before posting) and Detail.
  - Bottom sheet "Catat apa?" (LembarBawah) over Beranda or Transaksi, covering the tab bar.
  - Flutter structure: `MainKendali` builds `LayarPonsel(jabatanKosong:…)` whose Stack holds, in order: the nested navigator (the child pages render only their view), `PonselTabBar` while the top location is /Main or /Main/transaksi, `Toast` while `toast` is true and the top location is /Main or /Main/transaksi, and the LembarBawah sheet. Child pages never build LayarPonsel. The top location is the ShellRoute builder's `state.uri.path`.
- **Layout**

  **0. PitaJabatanKosong strip (when `jabatanKosong` on, every view).** `role="status"`. Background `tinta`, text `permukaan`, padding 10 24 8, `keterangan` 13 line-height 1.3, centred: "**Menjalankan jabatan kosong** · Bendahara Jemaat" (the first part weight 700).

  **A. Beranda (`/Main`).** Scroll area from the top of the content area to 84 px above the bottom (the tab bar sits in those 84 px), padding 24 20 28, column gap 22.
  1. Header row, space-between, centred vertically. Left: logo mark 26×26 (path data: `<rect x="2" y="2" width="20" height="20" rx="6" fill="none" stroke="laut" stroke-width="2" stroke-dasharray="3 3"/><path d="M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z" fill="laut"/>`), gap 10, "Jemaat Karunia" 17 px 700 (off-token). Right: month pill, a link "November 2026", 14 px 600 `tinta2`, 1 px `garisTegas` border, radius 999, padding 0 14, min height 44, no underline. Semantics label "Pilih bulan, sekarang November 2026".
  2. Balance block, column gap 6: "Saldo buku semua Kas/Bank" `pendamping` `tinta2`; total `jumlahUtama` (mono 38 500, letter spacing −1, line-height 1.1) "Rp38.415.000"; "Hanya transaksi yang sudah dibukukan" `keterangan` `tinta3`. When there are drafts: a pill (line `draf`: 1.5 dashed `putus`, radius 999, padding 6 12, margin-top 6, aligned left, `keterangan` `tinta2`): "<mono>Rp800.000</mono> · 2 draf · belum masuk saldo".
  3. Kas/Bank card: `permukaan`, 1 px `garis` (line `dibukukan`), radius 14, padding 4 16. Three rows, min height 46, space-between, divider 1 px `garis` above every row but the first: name 15 px 400, amount mono 15 500. Rows: "Kas" "Rp8.420.000"; "Bank BNI ··4821" "Rp24.615.000"; "Bank SulutGo ··1107" "Rp5.380.000".
  4. "Perlu tindakan" section, column gap 10. Heading row gap 8: "Perlu tindakan" `judulBagian`; counter badge `bata` field, text `diBata` 13 700, radius 999, min width 22, height 22, padding 0 6, centred: "4". Card: `permukaan`, 1 px `garis`, radius 14, padding 0 16:
     - Row 1 (link → TutupBuku), min height 60, gap 12: "Oktober 2026 belum ditutup" 15 px 600 `tinta`; under it "1 hambatan · bulan berikutnya untuk tutup buku" 13 600 `bata`; chevron right 18 (`M9 6l6 6-6 6`, stroke `tinta3` 2, round caps).
     - Rows 2–4 (buttons, full width, divider 1 px `garis` above, min height 60, gap 12): title 15 px 600, caption `keterangan` `tinta3`, chevron. Copy: "2 draf belum dibukukan" / "Belum masuk saldo"; "1 dokumen pendukung wajib, belum ada" / "BKU-2026-0143 · Rp600.000"; "1 Mata Anggaran belum dipilih" / "Draf · Honor pemusik". The number in row 2 follows the draft count.
     - When `bulan` = sepi, rows 2–4 are gone and a box follows the card: line `draf` (1.5 dashed `putus`), radius 14, padding 14 16, `pendamping` `tinta2`: "**Belum ada transaksi di November.** Bulan tanpa transaksi belum selesai: tiap Kas/Bank tetap perlu hitung kas atau rekening koran, lalu tutup buku." (bold part `tinta`).
  5. "Untuk diketahui" (only when `bulan` = ramai), column gap 6: heading `judulBagian`; a plain link, `pendamping` `tinta2`, min height 44: "2 uang muka dengan sisa belum dipertanggungjawabkan". No frame, no warning colour.
  6. Link row (margin −8 0, wrap, gap 0 22, 14 px 600, links in `laut`, pressed `lautTua`, each min 44×44): "Rekonsiliasi", "Buat laporan sementara".
  7. "Bulan ini" section, column gap 10. Heading: "Bulan ini" `judulBagian` followed inline by " · tanpa titipan, hanya yang sudah dibukukan" 13 500 `tinta3`. Two equal tiles (grid 2 columns, gap 10), each `permukaan`, 1 px `garis`, radius 14, padding 12 14: label 13 `tinta2`, amount `jumlah` (mono 16 500): "Pendapatan" "Rp7.540.000"; "Belanja" "Rp7.940.000". Then a row, padding 0 2, space-between: "Surplus/Defisit bulan ini" `pendamping` `tinta2`, amount mono 16 600 "−Rp400.000".

  **B. Phone tab bar (Beranda and Transaksi only).** Pinned to the bottom of the content area, height 84, `permukaan`, top border 1 px `garis`, five equal columns, items aligned to the top, padding-top 8. Each side item: min height 52, column, centred, gap 3, label 13 600; icon 22×22 stroke 2, round caps, colour follows the label.
     - "Beranda": icon `M4 11l8-7 8 7v9H4z` (round joins). Colour `laut` on Beranda, `tinta3` elsewhere.
     - "Transaksi": icon `M5 7h14M5 12h14M5 17h9`. Colour `laut` on Transaksi, `tinta3` elsewhere.
     - Centre: circular button 58×58 outer (border 4 `kertas` included), margin-top −22 so it rises above the bar, `laut` field, plus icon 24 (`M12 5v14M5 12h14`, stroke 2.4, `diLaut`). Semantics label "Catat transaksi".
     - "Bulan": icon `<rect x="4" y="5" width="16" height="15" rx="3"/><path d="M4 10h16M9 3v4M15 3v4"/>`, `tinta3`. Link.
     - "Lainnya": three filled dots (`circle` r 2 at x 5, 12, 19, y 12), `tinta3`. Link.

  **C. Transaksi (`/Main/transaksi`).** Same scroll area as Beranda (bottom 84 px left for the tab bar), padding 24 20 28, column gap 14, fades in (`pudar` 200 ms).
  1. Title: "Transaksi" `judulBesar` followed inline by " · November 2026" 14 500 `tinta3`.
  2. Link row (margin −6 0, wrap, gap 0 22, 14 600, each min 44×44): "Pilih bulan", "1 draf di bulan yang sudah ditutup", "Cari".
  3. Filter chips (ChipPilihan look): "Semua", "Draf", "Dibukukan". Min height 44, padding 0 16, margin-right 8, radius 999, border 1.5; selected `tinta` field, `permukaan` text, `tinta` border; unselected `permukaan` field, `tinta` text, `garisTegas` border; 14 600. `aria-pressed` → Semantics `selected`.
  4. Transaction cards, 10 apart, radius 14, padding 12 14, column gap 6:
     - Top row, space-between, gap 8: LencanaStatus (13 700, letter spacing 0.3, padding 3 9, radius 6) and the amount (mono 16 500).
     - Uraian 15 px 600.
     - Meta line `keterangan` `tinta3`: "<mono>{No. Bukti}</mono> · {dd/mm/yyyy} · {Kas/Bank}".
     - Optional extra line `keterangan` `tinta2`: "Belum masuk saldo" on every Draf; "Dibalik oleh No. Bukti BKU-2026-0144" on the Dibalik row.
     - Shapes by status (every badge carries a 1.5 border, so all three are the same size): Dibukukan card `permukaan` + 1 px `garis` (line `dibukukan`), badge `tinta` field / `permukaan` text / 1.5 solid `tinta`, amount `tinta`. Draf card transparent + 1.5 dashed `putus` (line `draf`), badge transparent / `tinta2` text / 1.5 dashed `putus`, amount `tinta3`. Dibalik card as Dibukukan, badge `permukaan` field / `tinta2` text / 1.5 solid `tinta3`.
     - Rows in order (ramai): see Mock data.
  5. Empty state (no row matches, always in sepi): box line `draf`, radius 14, padding 16, `pendamping` `tinta2`: "Belum ada transaksi yang cocok di November 2026."

  **D. Toast (over Beranda after "Simpan sebagai draf").** `role="status"`. Absolute, left 20, right 20, bottom 100 (just above the tab bar). The board layers it above Beranda and Transaksi and the tab bar, below the sheet and below the full views (Catat, Pilih Mata Anggaran, Periksa, Detail): if Transaksi is opened within the 2.6 s, the toast stays visible there until it times out. `tinta` field, 1.5 dashed `garisTegas` border, radius 14, padding 12 16, 14 600 `permukaan`: "Draf tersimpan · belum masuk saldo". Enters with `muncul` 280 ms on the `keluar` curve.

  **E. Sheet "Catat apa?" (LembarBawah, not a route).** Covers the whole content area including the tab bar.
  - Scrim: full-size button, `tinta` at 45 % opacity (board `rgba(19,32,28,.45)`), fades in (`pudar` 200 ms). Semantics label "Kembali ke Beranda".
  - Sheet: pinned bottom, `permukaan`, top corners 22 (`radius-lembar`), padding 10 20 28, rises (`naik` 280 ms, `keluar` curve).
  - Handle 40×4, radius 2, `garisTegas`, centred, 14 below.
  - Title "Catat apa?" `judulLayar`, margin-bottom 6.
  - Four rows (buttons), min height 64, divider 1 px `garis` above each, gap 14. Leading tile 44×44, radius 12, `lautLembut` field, sign in `laut` mono 18 600; then title 16 600 and caption `keterangan` `tinta3`:
    - "+" "Pendapatan" / "Uang masuk milik Jemaat"
    - "−" "Belanja" / "Pembayaran langsung"
    - "+" "Persembahan" / "Persembahan ibadah, dicatat sebagai Pendapatan"
    - "⇄" "Pindah antar Kas/Bank" / "Termasuk setoran ke bank"
  - "Catatan lain": divider 1 px `garis` above, padding-top 4; caption "Catatan lain" `keterangan` `tinta3` (padding-top 8); then seven link chips that wrap: min height 44, padding 0 14, margin 8 8 0 0, radius 999, 1.5 `garisTegas` border, 14 600 `tinta`, no underline: "Persembahan beberapa bagian", "Uang Muka, Titipan, klaim", "Alih peruntukan", "Pengembalian", "Dari foto nota", "Dari kalimat", "Usulan Mata Anggaran".

  **F. Catat form (`/Main/catat`).** Full content area, `kertas`, enters with `masuk` 280 ms (`keluar` curve). Column: header, optional banner, scrolling body, fixed footer.
  1. Header (padding 14 12 8, gap 8): back button 44×44 (chevron left `M15 6l-6 6 6 6`, 22, stroke 2), Semantics "Kembali"; title `judulLayar` = "Belanja" / "Pendapatan" / "Pindah antar Kas/Bank"; on the right the StatusSimpan text, 13 600, padding-right 8: "Belum tersimpan" (`tinta3`), "Tersimpan" (`laut`), "Gagal disimpan" (`bata`), "Mencoba menyimpan lagi…" (`tinta3`).
  2. Failure banner (StatusSimpan, only while "Gagal disimpan"): `role="alert"`, margin 0 20 8, `bataLembut` field, 1 px `bata` border, radius 12, padding 10 14, row gap 10, enters with `muncul` 200 ms. Text `pendamping` `tinta`: "**Gagal disimpan.** Isian Anda masih ada di layar ini." Button "Coba lagi": min height 44, padding 0 14, radius 10, `bata` field, `diBata` 14 700.
  3. Body (scrolls), padding 8 20 20, column gap 18:
     - **Jumlah** (IsianJumlah): label "Jumlah (Rp)" `pendamping` `tinta2`. Row aligned on baseline, gap 6, 2 px `tinta` underline, padding-bottom 4: "Rp" mono 22 `tinta3`; input mono 38 500, letter spacing −1, transparent, no border, min height 44, numeric keyboard, hint "0" in `tinta3` when empty.
     - **Kas/Bank** label `pendamping` `tinta2`, margin-bottom 8: "Kas/Bank" (Belanja, Pendapatan) or "Dari Kas/Bank" (Pindah). Chips (ChipPilihan, min height 44, padding 0 14, margin 0 8 8 0, radius 999, border 1.5, 14 600, same colours as the Transaksi filters): "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107". None selected at first.
     - Pindah only: label "Ke Kas/Bank", the same three chips, then caption `keterangan` `tinta3`: "Pindah antar Kas/Bank bukan Pendapatan dan bukan Belanja. Biaya bank dicatat sebagai Belanja tersendiri."
     - Belanja and Pendapatan only (column gap 18):
       - Peruntukan label: "Diambil dari peruntukan" (Belanja) or "Masuk ke peruntukan" (Pendapatan), then " · uang siapa ini" in `tinta3`. Chips "Umum Jemaat", "Diakonia", "Pembangunan".
       - "Lingkup" label, chips "Jemaat", "Kolom 3", "BIPRA Pemuda", "Panitia Natal".
       - Mata Anggaran label "Mata Anggaran" + " · untuk apa" in `tinta3`. One full-width button, min height 56, padding 10 14, radius 12, gap 12, chevron right 18 `tinta3`. Not chosen: transparent, line `draf` (1.5 dashed `putus`); first line (mono 13 `tinta2`) "Draf boleh disimpan tanpa Mata Anggaran"; second line 15 600 "Mata Anggaran belum dipilih". Chosen: `permukaan`, 1 px `garisTegas`; first line "{Belanja|Pendapatan} {kode}" e.g. "Belanja 5.02.01.00"; second line the name e.g. "Alat tulis dan fotokopi".
       - Party: label "Dibayar kepada" (Belanja) or "Diterima dari (boleh tanpa nama)" (Pendapatan); text input min height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan`.
     - "Uraian" label and a text input styled the same.
     - Date row: min height 48, 1 px `garis` above and below, space-between: "Tanggal transaksi" `pendamping` `tinta2`; link "16 November 2026 " 16 600 `tinta` + "Ubah" 700 `laut`, gap 6, min height 44.
     - "Dokumen pendukung" label then one of (PanelDokumen-like, board-specific):
       - Empty: full-width button, min height 56, radius 12, transparent, line `draf`, centred, gap 8, 16 600 `laut`: camera icon 20 (`M4 8h3l2-3h6l2 3h3v11H4z` + circle cx 12 cy 13 r 3.5, round joins) + "Lampirkan dokumen pendukung".
       - Uploading: box radius 12, 1 px `garisTegas`, `permukaan`, padding 12 14: "Sedang diunggah…" 14 600; track 4 px high, radius 2, `garis`, margin-top 8, clipped; fill `laut` animated by `isi` (width 0 → 100 %, 1200 ms linear, holds at full).
       - Attached: same box as a row, gap 12, enters with `muncul` 280 ms: thumbnail 40×48, radius 6, `lautLembut` field, 1 px `garisTegas`; "nota-16-11.jpg · Terlampir" 14 600; "Diunggah, belum diverifikasi" `keterangan` `tinta2`.
  4. Footer (padding 12 20 22, `permukaan`, top border 1 px `garis`, column gap 6): primary "Periksa dan bukukan" (min height 52, radius 14, `laut`, `diLaut` 700, centred); text button "Simpan sebagai draf" (min height 44, `laut` 700, centred).

  **G. Pilih Mata Anggaran (`/Main/mata-anggaran`).** Full content area, `permukaan`, rises from the bottom (`naik` 280 ms, `keluar` curve).
  1. Header (padding 14 12 8, gap 8): back 44×44 "Kembali"; "Pilih Mata Anggaran" `judulLayar`; tree badge at the right: "Belanja" or "Pendapatan", 13 700, `tinta` field, `permukaan` text, radius 6, padding 4 10, margin-right 8.
  2. Search (padding 4 20 10): input min height 48, padding 0 14, radius 12, 1 px `garisTegas`, field `kertas`, hint "Cari nomor atau nama", Semantics "Cari Mata Anggaran".
  3. List (scrolls, padding 0 20):
     - Group heading (padding 14 0 6, not pressable): code mono 13 `tinta3`; name 14 700 `tinta2`; "Judul kelompok, tidak dapat dibukukan" `keterangan` `tinta3`.
     - Postable row (button, min height 60, divider 1 px `garis` above, padding 6 0 6 14 so it is indented 14): "{tree} {kode}" mono 13 `tinta2`; name 15 600.
  4. Footer (padding 12 20 22, top border 1 px `garis`, column gap 8): link button "Bagi ke beberapa Mata Anggaran" (min height 48, radius 14, 1.5 `tinta` border, 700 `tinta`, centred); button "Simpan tanpa Mata Anggaran" (min height 48, radius 14, line `draf`, transparent, 700 `tinta2`, centred).

  **H. Periksa dan bukukan (`/Main/periksa`).** Full content area, `kertas`, `masuk` 280 ms.
  1. Header (padding 14 12 8, min height 44): back 44×44 "Kembali" only before posting; title (margin-left 8) `judulLayar`: "Periksa dan bukukan" before posting, "Sudah dibukukan" after.
  2. Body (scrolls), padding 8 20 20, column gap 18.
     - Before posting, draft card: line `draf` (1.5 dashed `putus`), radius 16, padding 18, column gap 6: badge "Draf · belum masuk saldo" (13 700, 1.5 dashed `putus`, `tinta2`, radius 6, padding 3 9, aligned left); amount mono 30 500 `tinta2` (`jumlahIsian` size) signed by type; summary 16 600; second line `keterangan` `tinta3` "{Kas/Bank name or 'Kas/Bank belum dipilih'} · 16 November 2026", or for Pindah "Pindah antar Kas/Bank · 16 November 2026".
     - Before posting, checks card: `permukaan`, 1 px `garis`, radius 14, padding 4 16. One row per check, row gap 12, padding 12 0, divider 1 px `garis` above all but the first, each row enters with `muncul` 300 ms delayed 90 ms × index. Icon 22×22:
       - met: filled `laut` circle r 11 with `diLaut` tick `M7 12.5l3.2 3.2L17 9` (stroke 2.2), Semantics "Terpenuhi";
       - unmet: `bata` rounded square (x 1 y 1 22×22 rx 6) with `diBata` "!" (`M12 6.5v7M12 17v.5`, stroke 2.4), Semantics "Belum terpenuhi";
       - for information: dashed `tinta3` circle r 10 stroke 2, dash 3 3, Semantics "Untuk diketahui".
       Title 15 600; optional caption `keterangan` `tinta3`. Rows: see Interactions, "Checks".
     - After posting, booked card: line `terpilih`-weight solid `tinta` (1.5), `permukaan`, radius 16, padding 18, column gap 6, clipped. Overlay ink: `laut` layer over the whole card, animated by `sapu`. Top row space-between: LencanaStatus "Dibukukan" (13 700, `tinta` field, `permukaan` text, radius 6, padding 4 10) and the stamp "No. Bukti BKU-2026-0147" (mono 14 600 `laut`, 2 px `laut` border, radius 8, padding 4 10, animated by `cap` with rotation). Amount mono 30 500 `tinta`, margin-top 6. Summary 16 600. "Dibukukan pada 16/11/2026 10.42 · tidak dapat diubah lagi" `keterangan` `tinta3`.
     - After posting, balance card: `permukaan`, 1 px `garis`, radius 14, padding 14 16, enters `muncul` 300 ms after 500 ms: "Saldo buku {Kas/Bank name}" `pendamping` `tinta2`; counting figure mono 26 500; "Sebelumnya {old balance}" `keterangan` `tinta3`.
  3. Footer (padding 12 20 22, `permukaan`, top border 1 px `garis`):
     - Before posting, all checks met: primary "Bukukan" (min height 52, radius 14, `laut`, `diLaut` 700).
     - Before posting, any unmet: refusal (Penolakan) `pendamping` 600 `bata`: "Tidak dapat dilakukan: {n} syarat belum terpenuhi. Tidak ada yang dibukukan." then secondary "Ubah" (min height 52, radius 14, 1.5 `tinta` border, `permukaan`, 700). Gap 8.
     - After posting (enters `muncul` 300 ms after 800 ms, gap 6): primary "Lihat transaksi"; text button "Kembali ke Beranda" (min height 44, `laut` 700).

  **I. Detail (`/Main/detail`).** Full content area, `kertas`, `masuk` 280 ms.
  1. Header (padding 14 12 8, gap 8): back 44×44, Semantics "Kembali ke Beranda"; title "BKU-2026-0147" mono 17 600; LencanaStatus "Dibukukan" at the right, margin-right 8.
  2. Body (scrolls), padding 8 20 24, column gap 16:
     - Amount mono 34 500, letter spacing −1 (signed); summary 16 600 under it.
     - Detail card: `permukaan`, 1 px `garis`, radius 14, padding 4 16. Rows space-between, gap 16, padding 11 0, divider above all but the first; key `pendamping` `tinta2`, value 14 600 right-aligned. Rows: see Interactions, `rinci`.
     - Document card: `permukaan`, 1 px `garis`, radius 14, padding 14 16, row gap 12: "Dokumen pendukung" `pendamping` `tinta2`; status 15 600: "Wajib, belum ada" / "Diunggah, belum diverifikasi" / "Terverifikasi (oleh Meiske L.)". When uploaded and not verified, a button "Verifikasi" (min height 44, padding 0 16, radius 12, 1.5 `laut` border, `permukaan`, `laut` 700).
     - "Riwayat" (15 700, margin-bottom 8), then three lines `pendamping` `tinta2`, gap 4: "10.42 · Dibukukan oleh Meiske L.", "10.41 · Dokumen pendukung diunggah", "10.39 · Draf dicatat oleh Meiske L.".
     - Caption `keterangan` `tinta3`: "Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata Anggaran tidak dapat diubah. Selama bulannya belum ditutup, kesalahan dikoreksi dengan pembalikan."
     - Link button "Koreksi dengan pembalikan": min height 48, radius 14, 1.5 `tinta` border, `permukaan`, 700 `tinta`, centred.
- **Components** PitaJabatanKosong (phone strip); LencanaStatus (Dibukukan, Draf, Dibalik on rows; Draf · belum masuk saldo and Dibukukan on Periksa; Dibukukan on Detail); ChipPilihan (filters, Kas/Bank, Ke Kas/Bank, peruntukan, Lingkup); IsianJumlah (Jumlah); PemilihMataAnggaran (field button + picker view); StatusSimpan (header text + failure banner); LembarBawah ("Catat apa?"); ButirPerhatian (Perlu tindakan rows, Untuk diketahui link); Penolakan (Periksa refusal); Tombol (primary, secondary, text); GarisStatus (`draf` pill, cards, empty boxes); Gerak (`tinta`). Repeated patterns that are not components: the phone tab bar (shared shell, also drawn on Lainnya); the header with a 44×44 back chevron; the inline link row (14 600 `laut` links, 22 apart, each 44×44); the check row with three icons (met, unmet, for information); the key–value detail card; the counter badge (`bata` circle).
- **Internal views and states**
  - Initial state (verbatim): `{ screen: 'beranda', sheet: false, toast: false, filter: 'Semua', jenis: 'belanja', jumlah: '', pihak: '', uraian: '', akun: null, ke: null, per: null, ling: null, ma: null, cari: '', dok: 'kosong', verif: false, posted: false, simpan: 'belum', sudahCoba: false, hitung: 0, saldoLama: 0, saldo: { kas: 8420000, bni: 24615000, bsg: 5380000 }, pend: 7540000, bel: 7940000, drafN: 2, drafRp: 800000, baru: null }`. One state object for the board, shared by `/Main` and all its child routes; created when `/Main` enters the stack and disposed (timers cancelled) when no `/Main…` route is left.
  - `screen` values → views: `beranda` → `/Main`; `daftar` → `/Main/transaksi`; `form` → `/Main/catat`; `ma` → `/Main/mata-anggaran`; `periksa` → `/Main/periksa`; `detail` → `/Main/detail`.
  - Beranda variants: ramai (default) / sepi (tweak); with or without the draft pill (`drafN > 0`).
  - Transaksi variants: filter Semua / Draf / Dibukukan; empty state when no row matches; a new first row (`baru`) after Simpan sebagai draf or Bukukan.
  - Sheet open (`sheet: true`) over Beranda or Transaksi. Reached by the centre tab button.
  - Toast (`toast: true`) on Beranda for 2600 ms after Simpan sebagai draf.
  - Catat form variants: jenis belanja / pendapatan / pindah (Pindah hides peruntukan, Lingkup, Mata Anggaran and party, and shows "Ke Kas/Bank"); save state belum / tersimpan / gagal (with banner) / mencoba; document kosong / unggah / terlampir; Mata Anggaran chosen or not.
  - Pilih Mata Anggaran: full list or filtered by search.
  - Periksa: before posting (all met → Bukukan; any unmet → refusal + Ubah) and after posting (booked card, counting balance, footer).
  - Detail: document Wajib, belum ada / Diunggah, belum diverifikasi (with Verifikasi) / Terverifikasi.
  - Direct entry to a child URL renders that view from the current board state (a fresh state if the board was not open: empty Belanja form).
- **Tweaks** (Keadaan panel)
  - `jabatanKosong` (boolean, default false) → the global switch. On: the PitaJabatanKosong strip on every view; Riwayat lines read "Dibukukan oleh Yanti Sumual, Operator" and "Draf dicatat oleh Yanti Sumual, Operator"; the Detail document status "Terverifikasi (oleh Yanti Sumual, Operator)" (the board's `tukarJk` swap; the string has no date so it is swapped).
  - `bulan` (enum ramai · sepi, default ramai). sepi: draft count, Pendapatan and Belanja are forced to 0 (the draft pill disappears, "Bulan ini" tiles read "Rp0", net "Rp0"), Perlu tindakan keeps only the "Oktober 2026 belum ditutup" row and the counter reads "1", the dashed "Belum ada transaksi di November." box appears, "Untuk diketahui" is hidden, and the transaction list is empty (only a new `baru` row can appear). The Kas/Bank balances and total are unchanged. Read live: switching while on a view updates it.
  - `gagalSimpan` (boolean, default false). On: every field change in the Catat form (`ubah`) sets the save state to "Gagal disimpan" with the failure banner, until "Coba lagi" has been pressed once for this form; after that changes show "Tersimpan". Off: changes show "Tersimpan".
- **Interactions** (handlers of the logic class)
  - `ubah(patch)` (helper used by every form field change): applies the patch and sets `simpan` to `gagal` when `gagalSimpan` is on and `sudahCoba` is false, else `tersimpan`.
  - Month pill "November 2026" → push `/PilihBulan`.
  - Perlu tindakan row 1 → push `/TutupBuku`. Rows 2–4 (`bukaDaftar`) → `/Main/transaksi` (filter unchanged).
  - "2 uang muka dengan sisa belum dipertanggungjawabkan" → push `/Kewajiban`. "Rekonsiliasi" → push `/TutupBuku`. "Buat laporan sementara" → push `/Laporan`.
  - Navigation inside the board: "pop to `/Main`" means pop every `/Main/…` route above `/Main` (or go `/Main` when it is not in the stack), so whatever opened `/Main` stays beneath it and Back keeps working. Tab "Beranda" (`keBeranda`) → pop to `/Main`, closes the sheet. Tab "Transaksi" (`bukaDaftar`) → pop to `/Main`, then push `/Main/transaksi` (a tab change: Back from Transaksi returns to Beranda). Centre button (`bukaSheet`) → opens the sheet. Tab "Bulan" → go `/TutupBuku` (`Tautan(ke: 'TutupBuku', cara: Cara.ganti)`, navigation.md 1.1). Tab "Lainnya" → go `/Lainnya`.
  - Filter chip (`filters[].pick`) → `filter` = Semua / Draf / Dibukukan. Semua shows every row; Draf only Draf rows; Dibukukan only Dibukukan rows (the Dibalik row is hidden under Dibukukan).
  - Transaksi links: "Pilih bulan" → push `/PilihBulan`; "1 draf di bulan yang sudah ditutup" → push `/Draf`; "Cari" → push `/Cari`. Transaction cards are not pressable.
  - Scrim (`tutupSheet`) → closes the sheet, stays on the current tab. System Back with the sheet open closes the sheet.
  - Sheet row (`jenisList[].pick`) → closes the sheet, pops to `/Main` and pushes `/Main/catat` (so system Back and the form's back both land on Beranda, as on the board) with a reset form: `{ screen: 'form', sheet: false, jenis: <id>, jumlah: '', pihak: '', uraian: <ur or ''>, akun: null, ke: null, per: null, ling: null, ma: null, cari: '', dok: 'kosong', verif: false, posted: false, simpan: 'belum', sudahCoba: false }`. Pendapatan → jenis pendapatan; Belanja → belanja; Persembahan → pendapatan with Uraian prefilled "Persembahan Ibadah Minggu"; Pindah antar Kas/Bank → pindah.
  - Sheet "Catatan lain" chips (links): close the sheet, then push `/Persembahan`, `/KasusBaru`, `/AlihPeruntukan`, `/Pengembalian`, `/AIFoto`, `/BantuanAI`, `/AIMataAnggaran`.
  - Catat back (`keBeranda`) → pop to `/Main` (always Beranda, even when the sheet was opened from Transaksi). Form state is kept until a jenis is picked again.
  - Jumlah (`onJumlah`): on every change keep digits only, strip leading zeros, cap at 12 digits; store the raw digits; display with dot thousands separators ("12500" → "12.500"); then `ubah`. Typing "0012a500" shows "12.500". Use a `TextInputFormatter` that reformats and keeps the caret at the end. The value is committed on every keystroke so the first press of "Periksa dan bukukan" after typing reads it.
  - Kas/Bank, Ke Kas/Bank, peruntukan, Lingkup chips (`chips(...).pick`) → `ubah({akun|ke|per|ling: id})`. Tapping a selected chip keeps it selected (no deselect). The same Kas/Bank may be chosen in both Pindah fields; Periksa refuses it.
  - Party (`onPihak`), Uraian (`onUraian`) → `ubah` with the typed text. No validation.
  - Mata Anggaran field (`bukaMa`) → push `/Main/mata-anggaran`, clears the search.
  - Search (`onCari`) → filters live, case-insensitive, on "{kode} {nama}"; group headings always stay. Does not touch the save state.
  - Postable row (`maRows[].pick`) → `ubah({ma: row})` and pop back to `/Main/catat`. Back (`keForm`) → pop. "Simpan tanpa Mata Anggaran" (`tanpaMa`) → `ubah({ma: null})` and pop. "Bagi ke beberapa Mata Anggaran" → push `/Bagi`.
  - Date link "16 November 2026 Ubah" → push `/Tanggal`.
  - "Lampirkan dokumen pendukung" (`lampirkan`) → document state "unggah" (no save-state change), progress bar runs; after 1300 ms `ubah({dok: 'terlampir'})` (fakes the upload; save state updates then).
  - "Coba lagi" (`cobaLagi`) → save state "Mencoba menyimpan lagi…", `sudahCoba` true; after 1100 ms "Tersimpan" (fakes the retry). Banner disappears with the "gagal" state.
  - "Periksa dan bukukan" (`kePeriksa`) → push `/Main/periksa`. No validation on press; the checks are on the next view.
  - "Simpan sebagai draf" (`simpanDraf`) → pop to `/Main` with the toast; `drafN` + 1, `drafRp` + amount; `baru` = `{ st: 'Draf', no: 'Belum ada No. Bukti', tgl: '16/11/2026', ur: <summary>, ak: <Kas/Bank name or 'Kas/Bank belum dipilih'>, jm: amount × (sign or +1) }`; toast hides after 2600 ms. Works in every save state (the board does not check `gagalSimpan` here). A later save replaces the previous `baru` row.
  - Summary (`ringkas`): Pindah → "Dari {asal or '…'} ke {tujuan or '…'}"; otherwise Uraian, else party, else the type title ("Belanja" / "Pendapatan").
  - Sign: Belanja −1, Pendapatan +1, Pindah 0. Displayed amount = amount × (sign or 1): Belanja "−Rp150.000", Pendapatan and Pindah positive.
  - Checks (`cek`), in order:
    - All types first: amount > 0 → met "Jumlah Rp{amount}" (unsigned, e.g. "Jumlah Rp150.000"); else unmet "Jumlah belum diisi".
    - Belanja and Pendapatan: Kas/Bank chosen → met "Kas/Bank: {name}", else unmet "Kas/Bank belum dipilih"; peruntukan → met "{label}: {value}" ("Diambil dari peruntukan: Diakonia", "Masuk ke peruntukan: Umum Jemaat"), else unmet "Peruntukan belum dipilih"; Lingkup → met "Lingkup: {value}", else unmet "Lingkup belum dipilih"; Mata Anggaran → met "Mata Anggaran sudah dipilih" with caption "{tree} {kode} · {nama}", else unmet "Mata Anggaran belum dipilih" with caption "Tetap bisa disimpan sebagai draf"; always met "Persetujuan: tidak diperlukan" with caption "Aturan: transaksi rutin di bawah batas Jemaat".
    - Pindah: both chosen and different → met "Dari {asal} ke {tujuan}", else unmet "Kas/Bank asal dan tujuan belum dipilih" with caption "Keduanya harus berbeda"; always met "Bukan Pendapatan dan bukan Belanja" with caption "Tidak memerlukan Mata Anggaran".
    - All types last: document attached → met "Dokumen pendukung: diunggah, belum diverifikasi" with caption "Wajib terverifikasi sebelum tutup buku"; else for information "Dokumen pendukung: wajib, belum ada" with caption "Boleh dibukukan, tetapi menjadi hambatan tutup buku". Never unmet.
    - n = number of unmet rows. n = 0 → "Bukukan"; n > 0 → "Tidak dapat dilakukan: {n} syarat belum terpenuhi. Tidak ada yang dibukukan." + "Ubah" (`keForm` → pop to `/Main/catat`). An empty Belanja form gives n = 5; an empty Pindah form n = 2.
  - Periksa back (`keForm`, before posting) → pop to `/Main/catat`.
  - "Bukukan" (`bukukan`): new balances (Pindah: source − amount, target + amount; otherwise account + sign × amount); `posted` true; `hitung` and `saldoLama` = the source account's old balance; Pendapatan adds the amount to `pend`, Belanja to `bel`; `baru` = `{ st: 'Dibukukan', no: 'BKU-2026-0147', tgl: '16/11/2026', ur: <summary>, ak: <name>, jm: amount × (sign or −1) }` (so a booked Pindah row is negative). The balance card uses motion.md `Hitung(dari: saldoLama, nilai: saldoBaru, lama: Duration(milliseconds: 780), tunda: Duration(milliseconds: 750))` keyed on `posted`; no Timer. The title becomes "Sudah dibukukan" and the back button disappears; system Back on this view pops to `/Main` (same as "Kembali ke Beranda"), never back to the form.
  - "Lihat transaksi" (`keDetail`) → pop to `/Main`, then push `/Main/detail` (Back then returns to Beranda, as the board's back does). "Kembali ke Beranda" (`keBeranda`) → pop to `/Main`.
  - Detail back (`keBeranda`) → pop to `/Main`. "Verifikasi" (`verifikasi`) → `verif` true: status "Terverifikasi (oleh Meiske L.)", button gone. "Koreksi dengan pembalikan" → push `/Koreksi`.
  - Detail rows (`rinci`): Belanja/Pendapatan: "Kas/Bank" {name}; "Diambil dari peruntukan" or "Masuk ke peruntukan" {value}; "Lingkup" {value}; "Mata Anggaran" "{tree} {kode} {nama}" (e.g. "Belanja 5.02.01.00 Alat tulis dan fotokopi"); "Versi Mata Anggaran" "2026.1"; "Persetujuan" "Tidak diperlukan (aturan: transaksi rutin)". Pindah: "Dari Kas/Bank" {asal}; "Ke Kas/Bank" {tujuan}. Then for all: "Tanggal transaksi" "16/11/2026"; "Dicatat pada" "16/11/2026 10.39"; "Dibukukan pada" "16/11/2026 10.42".
  - Unmount (`componentWillUnmount`): cancel the 1100, 1300 and 2600 ms timers (the count is `Hitung`, which owns no timer). On the board the 750 ms count-start and the 1100 ms "Coba lagi" timer share one slot (`t2`): "Bukukan" cancels a pending retry. The form is off screen by then and the next jenis pick resets `simpan`, so nothing visible changes; one cancellable timer per purpose is fine.
- **Motion**
  - `pudar` 200 ms (opacity 0 → 1): Transaksi view entering; sheet scrim.
  - `naik` 280 ms, `keluar` curve (translateY 100 % → 0) = `pindahLayar`: the sheet rising; the Pilih Mata Anggaran view rising.
  - `masuk` 280 ms, `keluar` curve (opacity 0 → 1, translateX 24 → 0) = `pindahLayar`: Catat, Periksa, Detail entering.
  - `muncul` (opacity 0 → 1, translateY 8 → 0): toast 280 ms `keluar` curve; failure banner 200 ms; attached-document box 280 ms; each check row 300 ms with delay index × 90 ms; booked balance card 300 ms after 500 ms; posted footer 300 ms after 800 ms (all "both" fill: hidden until their delay).
  - `isi` 1200 ms linear: upload progress fill (width 0 → 100 %). The swap to "Terlampir" comes at 1300 ms.
  - `tinta` sequence on Bukukan (Gerak `tinta`): `sapu` 700 ms ease-out on the `laut` overlay (0 %: scaleX 0 from the left, opacity 0.2; 65 %: scaleX 1, opacity 0.2; 100 %: opacity 0); `cap` 550 ms `keluar` curve after 350 ms on the No. Bukti stamp, rotated variant (0 %: opacity 0, scale 1.7, rotate −9°; 55 %: opacity 1, scale 0.94, rotate −3°; 100 %: scale 1, rotate −3°; stays tilted −3°); balance count-up 750 → 1530 ms (`Hitung`, above).
  - Reduce motion: every keyframe completes instantly; the count-up shows the final balance at once; the toast and upload timers still run (they fake time, not motion).
- **Links out** (label → route, method)
  - "November 2026" (month pill) → `/PilihBulan`, push
  - "Oktober 2026 belum ditutup …" → `/TutupBuku`, push
  - "2 uang muka dengan sisa belum dipertanggungjawabkan" → `/Kewajiban`, push
  - "Rekonsiliasi" → `/TutupBuku`, push
  - "Buat laporan sementara" → `/Laporan`, push
  - Tab "Bulan" → `/TutupBuku`, go (see Notes)
  - Tab "Lainnya" → `/Lainnya`, go
  - "Pilih bulan" → `/PilihBulan`, push
  - "1 draf di bulan yang sudah ditutup" → `/Draf`, push
  - "Cari" → `/Cari`, push
  - "Persembahan beberapa bagian" → `/Persembahan`, push
  - "Uang Muka, Titipan, klaim" → `/KasusBaru`, push
  - "Alih peruntukan" → `/AlihPeruntukan`, push
  - "Pengembalian" → `/Pengembalian`, push
  - "Dari foto nota" → `/AIFoto`, push
  - "Dari kalimat" → `/BantuanAI`, push
  - "Usulan Mata Anggaran" → `/AIMataAnggaran`, push
  - "16 November 2026 Ubah" → `/Tanggal`, push
  - "Bagi ke beberapa Mata Anggaran" → `/Bagi`, push
  - "Koreksi dengan pembalikan" → `/Koreksi`, push
  - **Inbound** (manifest): AIFoto, AIMataAnggaran, AlihPeruntukan, AlurUnit, Awal, Bagi, BantuanAI, Cari, Draf, HitungKas, Keputusan, Kewajiban, Koreksi, Lainnya, Masuk, Memuat, Pemberitahuan, Pemulihan, Pengembalian, PermintaanDana, Persembahan, PersembahanBernama, Persetujuan, Sambungan, Tanggal. navigation.md 3.4 adds the links built in logic classes: BerandaJabatan, KotakMasuk, CariOrang, PetaLayar, Cakupan (30 in all); the Keadaan panel lists all 30.
- **Mock data**
  - Church "Jemaat Karunia"; current month "November 2026"; today 16/11/2026 ("16 November 2026" in sentences).
  - Kas/Bank (id → name → balance): `kas` "Kas" 8.420.000; `bni` "Bank BNI ··4821" 24.615.000; `bsg` "Bank SulutGo ··1107" 5.380.000. Total "Rp38.415.000".
  - Drafts: 2, "Rp800.000". Bulan ini: Pendapatan "Rp7.540.000", Belanja "Rp7.940.000", Surplus/Defisit "−Rp400.000".
  - Perlu tindakan: "Oktober 2026 belum ditutup" / "1 hambatan · bulan berikutnya untuk tutup buku"; "2 draf belum dibukukan" / "Belum masuk saldo"; "1 dokumen pendukung wajib, belum ada" / "BKU-2026-0143 · Rp600.000"; "1 Mata Anggaran belum dipilih" / "Draf · Honor pemusik". Untuk diketahui: "2 uang muka dengan sisa belum dipertanggungjawabkan".
  - Transactions (ramai), status · No. Bukti · date · Uraian · Kas/Bank · amount:
    1. Dibukukan · BKU-2026-0146 · 15/11/2026 · Persembahan Ibadah Minggu · Kas · "Rp3.450.000"
    2. Draf · "Belum ada No. Bukti" · 14/11/2026 · Fotokopi warta jemaat · Kas · "−Rp150.000"
    3. Dibukukan · BKU-2026-0144 · 12/11/2026 · Pembalikan BKU-2026-0139 · Kas · "Rp750.000"
    4. Dibalik · BKU-2026-0139 · 09/11/2026 · Konsumsi rapat majelis · Kas · "−Rp750.000" · "Dibalik oleh No. Bukti BKU-2026-0144"
    5. Draf · "Belum ada No. Bukti" · 08/11/2026 · Honor pemusik · Bank BNI ··4821 · "−Rp650.000"
  - Peruntukan: "Umum Jemaat", "Diakonia", "Pembangunan". Lingkup: "Jemaat", "Kolom 3", "BIPRA Pemuda", "Panitia Natal".
  - Mata Anggaran, version "2026.1". Belanja: 5.00.00.00 BELANJA OPERASIONAL (group); 5.01.02.00 Listrik, air dan telepon; 5.02.01.00 Alat tulis dan fotokopi; 5.03.03.00 Biaya administrasi bank; 4.00.00.00 BELANJA PELAYANAN (group); 4.03.03.00 Diakonia duka. Pendapatan: 1.3.53.00.00 PERSEMBAHAN (group); 1.3.53.07.00 Persembahan Ibadah Minggu; 1.3.53.09.00 Persembahan syukur; 1.4.10.00.00 SUMBANGAN (group); 1.4.10.02.00 Sumbangan donatur.
  - New transaction: No. Bukti "BKU-2026-0147"; recorded 10.39, document uploaded 10.41, posted 10.42 on 16/11/2026; file "nota-16-11.jpg".
  - People: "Meiske L." (Bendahara); "Yanti Sumual, Operator" when `jabatanKosong` is on.
- **Prototype-only** None of the four devices ("Dilihat sebagai", "Contoh:", 123456, "Di prototipe ini") is on this board. The Keadaan panel carries the tweaks `bulan` and `gagalSimpan`, the global `jabatanKosong`, "Semua layar", the inbound links and the canvas title "1 · Harian: catat sampai bukukan".
- **Acceptance checks**
  1. Default (`bulan` ramai): Beranda shows "Rp38.415.000", the dashed pill "Rp800.000 · 2 draf · belum masuk saldo", counter "4" next to "Perlu tindakan", and "−Rp400.000" for Surplus/Defisit.
  2. Switch `bulan` to sepi: the pill is gone, counter reads "1", the dashed "Belum ada transaksi di November." box shows, "Untuk diketahui" is gone, tiles read "Rp0"; Transaksi shows "Belum ada transaksi yang cocok di November 2026."
  3. Catat → Belanja, type "0012a500" in Jumlah: the field shows "12.500" and the header reads "Tersimpan" in `laut`.
  4. Catat → Belanja, press "Periksa dan bukukan" with nothing filled: seven rows in this order: five with the `bata` square icon ("Jumlah belum diisi", "Kas/Bank belum dipilih", "Peruntukan belum dipilih", "Lingkup belum dipilih", "Mata Anggaran belum dipilih"), one met "Persetujuan: tidak diperlukan", and the dashed-circle row "Dokumen pendukung: wajib, belum ada"; the footer reads "Tidak dapat dilakukan: 5 syarat belum terpenuhi. Tidak ada yang dibukukan." with "Ubah", and no "Bukukan".
  5. Belanja Rp150.000, Kas, Diakonia, Jemaat, 5.02.01.00, then Bukukan: the card is swept by ink, "No. Bukti BKU-2026-0147" stamps in tilted, the balance counts from "Rp8.420.000" to "Rp8.270.000" and ends by about 1.6 s, "Sebelumnya Rp8.420.000" shows. "Kembali ke Beranda" shows "Rp38.265.000", Belanja "Rp8.090.000", net "−Rp550.000"; Transaksi's first row is Dibukukan "BKU-2026-0147" "−Rp150.000".
  6. `gagalSimpan` on, Catat → Belanja, tap "Kas": header "Gagal disimpan" in `bata` and the banner "Gagal disimpan. Isian Anda masih ada di layar ini."; "Coba lagi" → "Mencoba menyimpan lagi…" for 1.1 s → "Tersimpan", banner gone; tapping "Diakonia" keeps "Tersimpan".
  7. "Lampirkan dokumen pendukung": "Sedang diunggah…" with a filling bar for 1.2 s, then "nota-16-11.jpg · Terlampir"; after Bukukan and "Lihat transaksi", "Verifikasi" turns the status into "Terverifikasi (oleh Meiske L.)" and the button disappears; with `jabatanKosong` on it reads "Terverifikasi (oleh Yanti Sumual, Operator)".
  8. "Simpan sebagai draf" from any form: Beranda with the toast "Draf tersimpan · belum masuk saldo" for 2.6 s, pill "… · 3 draf · belum masuk saldo", Perlu tindakan "3 draf belum dibukukan"; Transaksi's first row is a dashed Draf with "Belum masuk saldo".
  9. Pilih Mata Anggaran (Belanja), search "fotokopi": both group headings remain, only "Belanja 5.02.01.00 Alat tulis dan fotokopi" is pressable; pick it → the form shows it on a solid `garisTegas` line.
  10. Pindah antar Kas/Bank with "Kas" in both fields → Periksa shows unmet "Kas/Bank asal dan tujuan belum dipilih" / "Keduanya harus berbeda".
- **Notes**
  - The Bulan and Lainnya tabs use go: they are tab changes (CONVENTIONS, One route per board; navigation.md 1.1). `TutupBuku` draws no tab bar and no back control on its month list, so after the Bulan tab the way out is browser or system Back (on Android, go replaced the stack, so Back leaves the app; that is accepted in navigation.md 1.1). The two other links to `/TutupBuku` ("Oktober 2026 belum ditutup …", "Rekonsiliasi") are drill-ins and use push, so Back returns to Beranda.
  - The Periksa footer swaps "Bukukan" for a refusal and "Ubah" when checks fail. That differs from TombolBersyarat ("never swapped"), but the board wins: build it as drawn, using the Penolakan look, not TombolBersyarat.
  - The Jumlah input is mono 38 (`jumlahUtama` size), not `jumlahIsian` 30 as the IsianJumlah guideline says. Copy the board.
  - Off-token text: 17 px 700 ("Jemaat Karunia"), 15 px 400/600 (rows), mono 15, 18 600 (sheet signs "+", "−", "⇄"), 22 (Rp prefix), 26, 34, 14 (stamp), 17 (Detail title). Off-token radii: 10 ("Coba lagi" in the banner), 8 (No. Bukti stamp), 2 (handle, progress track). No 12 px text on this board.
  - The toast border is dashed `garisTegas`, not `putus`; the scrim is `tinta` at 45 % opacity (no new hex).
  - Two sentences are set in mono because they sit in a code slot: "Belum ada No. Bukti" (row meta) and "Draf boleh disimpan tanpa Mata Anggaran" (Mata Anggaran field). Copy the board.
  - Board quirks to reproduce, not fix: in sepi the draft count and Pendapatan/Belanja stay 0 even after saving or booking; a saved Pindah draft is positive but a booked Pindah row is negative; "Simpan sebagai draf" works while the save state is "Gagal disimpan"; Riwayat always lists "10.41 · Dokumen pendukung diunggah", even without a document; the same person can press "Verifikasi" on their own transaction (a prototype shortcut; the product rule says no one verifies their own submission); empty group headings stay visible during a search.
  - The manifest's timeout list ("1100", "1300", "2600", "3") misses the 750 ms count start and the 30 ms interval; "3" is not a timer. Build the count as `Hitung` (Interactions, "Bukukan"), not as timers; use the other values above.
  - The `cap` keyframe exists in three variants on the canvas; this board uses the rotated one (1.7 → 0.94 → 1 at 55 %, −9° → −3°), variant A in `motion.md` (`Kerangka.cap`). Do not use `capTegak` (B) or `capSegel` (C) here.
  - Animations the board gives no curve (both `pudar`, and every `muncul` except the toast) run on CSS `ease` (`motion.md`, `muncul` and `pudar` tables).
  - The tab bar, toast, "Catat apa?" sheet and PitaJabatanKosong span two routes (/Main and /Main/transaksi), so they live in `MainKendali`, above the nested navigator (Shell), not in each page as components.md 4.1 draws for a single-route board. That way the tab bar does not fade in with Transaksi's `pudar` page transition, the toast stays visible on Transaksi within its 2.6 s, and the sheet covers the tab bar over either view. Hiding the toast under Catat, Pilih Mata Anggaran, Periksa and Detail matches the board, where those opaque views are drawn after the toast.
  - Links the board leaves without `text-decoration: none` are `TautanTeks` (underlined, components.md): the Beranda and Transaksi link rows (`laut`), "2 uang muka dengan sisa belum dipertanggungjawabkan" (underlined in `tinta2`) and the date link "16 November 2026 Ubah" (underlined in `tinta`, "Ubah" in `laut`). The month pill, the "Oktober 2026 belum ditutup" row, the Bulan and Lainnya tabs, the "Catatan lain" chips and the "Bagi …" and "Koreksi …" buttons have no underline.

---

### TutupBuku — 2 · Akhir bulan: rekonsiliasi dan tutup buku

- **Source** `docs/design/handoff/canvas/boards/TutupBuku.dc.html` · page Ponsel (`ponsel`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/TutupBuku` (Bulan) plus child routes `/TutupBuku/cek` (Tutup buku Oktober 2026, readiness), `/TutupBuku/rekonsiliasi` (Bank BNI reconciliation), `/TutupBuku/konfirmasi` (permanent-close confirmation; also shows the in-place "proses" and "gagal" states), `/TutupBuku/ditutup` (sealed result) · **Widget** `TutupBukuScreen` in `lib/screens/ponsel/tutup_buku.dart`
- **Purpose** The Bendahara Jemaat's month end, journey step 4: see which month is next to close, check readiness for October 2026, clear the Bank BNI ··4821 reconciliation (mark a deposit in transit, create the bank-fee transaction from the statement line, confirm the reconciliation), then close October permanently by holding the button. Decisions shown: D08 (close confirmed by holding the button until full), D02 (documents are a close requirement: "dokumen pendukung wajib sudah terverifikasi atau dikecualikan"), D32 (a closed month is the dark `tinta` field; lightest in dark theme), R04 and PitaJabatanKosong (the confirmation names the Operator as the one closing), close wording "Tutup buku bersifat permanen" (`05-master-file-update.md` row 9), "Untuk diketahui" items plain. Gerak `kait` (match), `segelTahan` (hold) and `segel` (seal).
- **Shell** Board root: 390×844 column, `kertas`, `tinta`, sans 16 line-height 1.4. PitaJabatanKosong strip on top when `jabatanKosong` is on (same as Main, layout 0). No tab bar on any view. Phone header with back on Cek and Rekonsiliasi; none on Bulan, Konfirmasi, proses, gagal, Ditutup.
- **Layout**

  **0. PitaJabatanKosong strip.** Same as Main, layout 0: "**Menjalankan jabatan kosong** · Bendahara Jemaat".

  **A. Bulan (`/TutupBuku`).** Fades in (`pudar` 200 ms). Scroll, padding 24 20 28, column gap 14.
  1. "Bulan" `judulBesar`, margin-bottom 4.
  2. "Bulan ditutup satu per satu, mulai dari yang paling lama." `pendamping` `tinta2`, margin-bottom 4.
  3. November card: `permukaan`, 1 px `garis`, radius 16, padding 16, column gap 6. Top row space-between: "November 2026" 18 700; LencanaStatus "Belum ditutup" (13 700, 1.5 `tinta3` line, `tinta2` text, radius 6, padding 3 9). Text `pendamping` `tinta2`: "Bulan berjalan · menunggu Oktober ditutup" (after close: "Berikutnya untuk tutup buku · bulan berjalan"). Link button "Hitung kas · Kas belum dihitung": margin-top 6, min height 44, radius 12, 1.5 `tinta` border, 700 `tinta`, centred.
  4. October card, open (until closed): `permukaan`, 2 px `tinta` border, radius 16, padding 16, gap 6. "Oktober 2026" 18 700 + "Belum ditutup" badge. Text `pendamping` `tinta2`: "Berikutnya untuk tutup buku · {1 hambatan | 2 hambatan | tidak ada hambatan}". Primary button "Periksa kesiapan tutup buku": margin-top 8, min height 48, radius 12, `laut`, `diLaut` 700, centred.
  5. October card, closed (after close; replaces 4, enters with `cap` 500 ms, scale-only variant): line `ditutup` (`tinta` field), radius 16, padding 16, gap 6. "Oktober 2026" 18 700 `permukaan` + LencanaStatus "Sudah ditutup" (`permukaan` field, `tinta` text, radius 6, padding 4 10). "Periode laporan 1–31 Oktober 2026 · ditutup oleh Meiske L., 16/11/2026 11.05" `pendamping` `diTinta2`. "Laporan resmi · PDF · Excel" 14 600 `permukaan`, margin-top 4 (plain text, not links).
  6. September card (always closed): as 5, without animation: "September 2026", "Sudah ditutup", "Periode laporan 15–30 September 2026, sejak tanggal mulai pencatatan", "Laporan resmi · PDF · Excel".

  **B. Cek (`/TutupBuku/cek`).** `masuk` 280 ms. Column: header, scrolling body, optional footer.
  1. Header (padding 14 12 8, gap 8): back 44×44 "Kembali"; "Tutup buku Oktober 2026" `judulLayar`.
  2. Body padding 8 20 20, column gap 20:
     - Link row (margin −8 0, wrap, gap 0 22, 14 600, each 44×44): "Pernyataan kesiapan", "Bantuan AI", "Kejadian".
     - When there are blockers (ButirPerhatian Hambatan), column gap 10: heading row gap 8, "Hambatan" `judulBagian` + counter (`bata` field, `diBata` 13 700, radius 999, min width 22, height 22, centred, no side padding); "Tutup buku belum dapat dilakukan sampai semua hambatan selesai." `pendamping` `tinta2`; one card per blocker: `permukaan`, line `hambatan` (1.5 `bata`), radius 14, padding 14 16, column gap 4: title 15 700; text `pendamping` `tinta2`; button (margin-top 8, min height 44, radius 12, `tinta` field, `permukaan` 700, centred).
     - When there are none: box `lautLembut`, radius 14, padding 14 16, row gap 12, enters `muncul` 300 ms: check icon 26 (filled `laut` circle, `diLaut` tick) + "Tidak ada hambatan. Oktober 2026 siap ditutup." 15 700.
     - "Syarat wajib" `judulBagian` (margin-bottom 6), then eight rows in a column with gap 4; each row: icon–text gap 10, padding 5 0, aligned top, icon not shrinking: icon 20 (met: `laut` circle + tick, Semantics "Terpenuhi"; unmet: `bata` rounded square + "!", Semantics "Belum terpenuhi"), text 14: met `tinta` 500, unmet `bata` 700.
     - "Untuk diketahui" `judulBagian`; "Tidak menghalangi tutup buku." `keterangan` `tinta3`; items `pendamping` `tinta2`, padding 3 0. Plain, no frame.
  3. Footer (only when no blockers, enters `muncul` 300 ms): padding 12 20 22, `permukaan`, top border 1 px `garis`; primary full-width "Lanjut ke konfirmasi tutup buku" (min height 52, radius 14).

  **C. Rekonsiliasi (`/TutupBuku/rekonsiliasi`).** `masuk` 280 ms.
  1. Header (padding 14 12 8, gap 8): back 44×44 "Kembali"; title block: "Rekonsiliasi" `judulLayar` and "Bank BNI ··4821 · Oktober 2026" `keterangan` `tinta2`; LencanaStatus at the right (13 700, radius 6, padding 4 10, margin-right 8, border 1.5): "Sedang dikerjakan" (transparent, `tinta2` text, `tinta3` line) or "Sudah dipastikan" (`laut` field, `diLaut` text, `laut` line).
  2. Body padding 8 20 20, column gap 18:
     - Link row (margin −8 0): "Isi rekening koran", "Hitung kas".
     - Summary card: `permukaan`, 1 px `garis`, radius 16, padding 14 16, column gap 8. Rows space-between, 14 px, label `tinta2`, figure mono 500: "Saldo buku" {Rp24.615.000 | Rp24.600.000 after the fee}; "Saldo rekening koran" "Rp24.100.000"; when in transit (enters `muncul` 300 ms): "Setoran dalam perjalanan" "+ Rp500.000"; "Saldo pembanding" {Rp24.100.000 | Rp24.600.000 when in transit}. Total row: 1.5 `tinta` line above, padding-top 10, baseline aligned: "Selisih belum dijelaskan" 15 700; figure mono 24 600, `bata` while not zero, `laut` at Rp0, colour cross-fades 300 ms.
     - "Belum cocok" (while either item is open), `judulBagian`, column gap 10; cards `permukaan`, 1 px `garis`, radius 14, padding 14 16, gap 4:
       - In-transit candidate: "Transaksi · belum ada di rekening koran" `keterangan` `tinta3`; row "Setoran ke bank" 15 600 / "Rp500.000" mono 500; "<mono>BKU-2026-0131</mono> · 31/10/2026" `keterangan` `tinta3`; secondary button "Tandai dalam perjalanan" (margin-top 8, min height 44, radius 12, 1.5 `tinta`, `permukaan`, 700); caption "Dibawa ke bulan berikutnya" `keterangan` `tinta3` centred.
       - Bank line without a transaction: "Mutasi bank · belum ada transaksinya"; "BIAYA ADM" / "−Rp15.000"; "31/10/2026 · sisa belum dicocokkan: Rp15.000"; secondary button "Buat transaksi dari mutasi ini"; caption "Belanja 5.03.03.00 Biaya administrasi bank" centred.
     - "Dalam perjalanan" (when marked), `judulBagian`; card line `draf`, radius 14, padding 12 16, row gap 12, enters `muncul` 300 ms: "Setoran dalam perjalanan" 15 600 and "Rp500.000 · dibawa ke November 2026" `keterangan` `tinta3`; text button "Lepaskan" (min height 44, padding 0 12, `laut` 700).
     - "Cocok" `judulBagian` + " · {12|13} mutasi bank" 14 500 `tinta3`. When the fee is created, a matched pair (column gap 6, stacked): card A `permukaan`, 1.5 `laut` line, radius 14, padding 10 16, slides from the left (`dariKiri`): "Mutasi bank" `keterangan` `tinta3`; "BIAYA ADM" 15 600 / "−Rp15.000" mono 500. Card B same style, slides from the right (`dariKanan`): "Transaksi · Dibukukan · <mono>BKU-2026-0133</mono>"; "Biaya administrasi bank" / "−Rp15.000". Link badge centred over the gap: 32×32 `laut` circle, link icon 16 (`M9 15l6-6M10 6l1-1a5 5 0 0 1 7 7l-1 1M14 18l-1 1a5 5 0 0 1-7-7l1-1`, stroke 2.6 `diLaut`), pops in (`kait`). Then "12 mutasi bank lain sudah cocok dengan transaksinya." `pendamping` `tinta2`.
  3. Footer (padding 12 20 22, `permukaan`, top border 1 px `garis`, gap 8), one of:
     - Difference not zero: "Selisih belum dijelaskan harus Rp0 sebelum rekonsiliasi dapat dipastikan." `pendamping` `tinta2` (no button).
     - Zero and not confirmed: primary "Pastikan rekonsiliasi" (min height 52, radius 14), enters `muncul` 300 ms.
     - Confirmed: secondary "Kembali ke kesiapan tutup buku" (min height 52, radius 14, 1.5 `tinta`, `permukaan`).

  **D. Konfirmasi (`/TutupBuku/konfirmasi`).** `permukaan` background, `masuk` 280 ms.
  1. Body (scrolls), padding 28 20 20, column gap 18:
     - "Tutup buku bulan Oktober 2026?" 24 px 700 line-height 1.2, margin-bottom 6; "Mohon baca ringkasan di bawah ini sebelum menutup buku." 15 `tinta2`.
     - "Semua syarat wajib sudah terpenuhi:" 15 700, margin-bottom 6; eight rows (gap 10, padding 4 0): met icon 18 (margin-top 1) + text 14 `tinta`, the eight original requirement texts (Mock data).
     - Block `pendamping` `tinta2`: heading 700 `tinta`, margin-bottom 4, "Untuk diketahui (tidak menghalangi tutup buku). Tetap ditampilkan di laporan, dan yang masih tersisa dibawa ke bulan berikutnya:" then "2 uang muka dengan sisa belum dipertanggungjawabkan; 1 setoran dalam perjalanan (belum tercatat di rekening koran)".
     - Scope line `pendamping`, 1 px `garis` above and below, padding 12 0: "Laporan resmi mencakup **1–31 Oktober 2026** untuk seluruh Jemaat: semua peruntukan dan semua kas/bank. " + link "Lihat laporan sementara" (700, no wrap).
     - Permanent block, line `ditutup` (`tinta` field), radius 16, padding 18, column gap 10: "Tutup buku bersifat permanen." 18 700 `permukaan`; then five sentences `pendamping` `diTinta`:
       - "Buku bulan Oktober 2026 menjadi final untuk semua pengguna, siapa pun."
       - "Transaksi Oktober 2026 tidak dapat diubah, dibalik, atau dikoreksi, bahkan dari bulan-bulan sesudahnya."
       - "Laporan resmi Oktober 2026 dibekukan dan tidak akan berubah."
       - "Kesalahan atau transaksi terlewat yang ditemukan di kemudian hari hanya dapat dicatat sebagai kejadian setelah tutup buku. Kejadian itu tidak mengubah angka apa pun, tidak menghapus selisih, dan tidak menghilangkan hambatan tutup buku."
       - "Kesalahan seperti itu dapat menghalangi rekonsiliasi atau tutup buku bulan-bulan sesudahnya. Bulan yang tidak dapat ditutup juga menahan tutup buku semua bulan setelahnya, dan aplikasi ini tidak menyediakan cara untuk memperbaikinya."
     - "Yang masih dapat Anda lakukan:" (700 `tinta`), then three lines `pendamping` `tinta2`, gap 6:
       - "Mempertanggungjawabkan uang muka dan menyalurkan titipan yang masih tersisa, sebagai transaksi baru yang bertanggal di bulan sesudahnya."
       - "Mencocokkan setoran dalam perjalanan dengan rekening koran bulan sesudahnya."
       - "Melampirkan dokumen pendukung yang datang terlambat. Dokumen itu tetap disimpan, tetapi laporan resmi Oktober 2026 tidak berubah."
     - When `jabatanKosong` is on: box `permukaan`, 1.5 `tinta` line, radius 14, padding 12 14, 14: "Ditutup oleh **Yanti Sumual, Operator**, yang menjalankan jabatan kosong Bendahara Jemaat. Nama dan keadaan ini tercatat pada tutup buku."
     - Statement checkbox: the whole box is the target; row gap 12, aligned top, 1.5 `tinta` line, radius 14, padding 14; checkbox 24×24 (checked fill `laut`); text 14 600: "Saya sudah membaca ringkasan dan laporan sementara. Saya mengerti bahwa tutup buku ini bersifat permanen dan transaksi Oktober 2026 tidak dapat dikoreksi lagi."
  2. Footer (padding 12 20 22, `permukaan`, top border 1 px `garis`, column gap 6):
     - Hold button (Tombol permanen): min height 56, radius 14, clipped, centred label "Tutup buku Oktober 2026" 700. Unticked: disabled look, `garis` field, `tinta3` text. Ticked: `tinta` field, `permukaan` text. A `laut` fill layer from the left edge grows from width 0 to 100 % while held (linear 1600 ms) and shrinks back to 0 in 200 ms on release. Label stays above the fill.
     - Hint `keterangan` `tinta3` centred: "Centang pernyataan di atas untuk melanjutkan" (unticked) or "Tekan dan tahan tombol sampai penuh" (ticked).
     - Text button "Kembali" (min height 44, `tinta` 700).

  **E. Proses (in place on `/TutupBuku/konfirmasi`).** Full content area, `permukaan`, fades in (`pudar` 200 ms), centred column gap 18: spinner 56 (track circle r 24 stroke 4 `garis`; arc `M28 4a24 24 0 0 1 24 24` stroke 4 `tinta`, round cap) rotating (`putar` 1 s linear, endless); "Sedang menutup buku…" 17 px 700, `role="status"`.

  **F. Gagal (in place on `/TutupBuku/konfirmasi`).** Full content area, `permukaan`, `pudar` 200 ms, vertically centred column, padding 28 24, gap 14: LencanaStatus-like badge "Oktober 2026 · Belum ditutup" (13 700, 1.5 `tinta3`, `tinta2`, radius 6, padding 3 9, left); "Tutup buku tidak terjadi: ada perubahan sejak ringkasan ini ditampilkan." `judulBesar` line-height 1.25; "Bulan Oktober 2026 tetap belum ditutup. Mohon lihat hambatan yang baru muncul." 15 `tinta2`; button "Lihat hambatan" (margin-top 8, min height 52, radius 14, `tinta` field, `permukaan` 700).

  **G. Ditutup (`/TutupBuku/ditutup`, segel).** Full content area; background animates `kertas` → `tinta` (`gelap`) and stays `tinta`; text `permukaan`; column padding 56 24 24, gap 18.
  1. Seal 104×104, centred, Semantics "Buku sudah ditutup": circle r 46 stroke 3 `permukaan`, dash 290, starting at 12 o'clock (rotated −90°), drawn by `lingkar`; lock (rect x 35 y 48 34×26 rx 5 filled `permukaan`; shackle `M41 48v-8a11 11 0 0 1 22 0v8` stroke 4 round) set by `cap` around its centre (52, 52).
  2. Text block (column gap 8, `muncul` 400 ms after 1400 ms): "Buku bulan Oktober 2026 sudah ditutup." `judulBesar` line-height 1.25 centred; "Angka laporan resmi sudah dibekukan; file laporannya sedang disiapkan." 15 `diTinta2` centred; "Dikonfirmasi oleh Meiske L. · 16/11/2026 11.05" `keterangan` `diTinta2` centred.
  3. Files card (`permukaan` field, `tinta` text, radius 16, padding 4 16, `muncul` 400 ms after 1700 ms):
     - PDF row (min height 60, gap 12): "Laporan resmi · PDF" 15 600; status `keterangan` `tinta2` "Sedang disiapkan" → "Siap diunduh"; when ready, link button "Unduh PDF" (min height 44, padding 0 14, radius 12, `laut`, `diLaut` 700, `muncul` 300 ms).
     - Excel row (divider 1 px `garis`): "Laporan resmi · Excel" 15 600; status "Sedang disiapkan" (`tinta2` 400) → "File gagal dibuat" (`bata` 700) with button "Coba lagi" (min height 44, padding 0 14, radius 12, 1.5 `bata` line, `permukaan`, `bata` 700) → "Sedang disiapkan" → "Siap diunduh" with link button "Unduh Excel" (as Unduh PDF).
  4. "File yang gagal dibuat cukup dibuat lagi dari angka yang sama. Tutup buku tetap berlaku." `keterangan` `diTinta2` centred, `muncul` 400 ms after 1900 ms.
  5. Spacer, then button "Kembali ke Bulan" (min height 52, radius 14, 1.5 `permukaan` line, transparent, `permukaan` 700), `muncul` 400 ms after 1900 ms.
- **Components** PitaJabatanKosong (phone strip and the "Ditutup oleh …" box on Konfirmasi); LencanaStatus (Belum ditutup, Sudah ditutup, Sedang dikerjakan, Sudah dipastikan); ButirPerhatian (Hambatan cards with their fix button, Untuk diketahui list); Tombol (primary, secondary, text, the permanent hold button); GarisStatus (`ditutup` cards and permanent block, `terpilih`-like 2 px October card, `hambatan` cards, `draf` in-transit card); Gerak (`kait`, `segelTahan`, `segel`). Repeated patterns that are not components: the requirement row (met/unmet icon + text); the reconciliation summary card with a counting difference; the matched-pair cards with the link badge; the file-status row (status text + action); the full-screen progress state with spinner; the statement checkbox box.
- **Internal views and states**
  - Initial state (verbatim): `{ screen: 'bulan', perjalanan: false, biaya: false, pasti: false, selisih: 515000, centang: false, tahan: false, tutup: false, sudahGagal: false, drafBaru: false, pdf: 'siap0', xls: 'siap0' }`. One state object shared by `/TutupBuku` and its child routes, disposed (timers cancelled) when no `/TutupBuku…` route is left.
  - `screen` values → views: `bulan` → `/TutupBuku`; `cek` → `/TutupBuku/cek`; `rekon` → `/TutupBuku/rekonsiliasi`; `konfirmasi` → `/TutupBuku/konfirmasi`; `proses` and `gagal` → in-place states of `/TutupBuku/konfirmasi` (outcomes of the hold, not places to navigate to); `sudah` → `/TutupBuku/ditutup`.
  - Bulan: October open (`tutup` false) or closed (`tutup` true, with the November text changed).
  - Cek: blockers present (0, 1 or 2: reconciliation not confirmed; new October draft) or none (success box + footer).
  - Rekonsiliasi: four data combinations (in transit on/off × fee created on/off) × confirmed or not.
  - Konfirmasi: unticked / ticked / holding.
  - Proses (1500 ms), Gagal (only with `gagalDiCekTerakhir`), Ditutup with file states `pdf` siap0 → siap and `xls` siap0 → gagal → siap0 → siap.
  - Direct entry (URL typed or deep link, not the push that `tutupBuku()` makes, which has already started its own 3600 ms timer): `/TutupBuku/ditutup` sets `tutup` true and starts the 3600 ms file timer if `pdf` is still "siap0" and no file timer is pending; other child URLs render from the current state.
- **Tweaks** (Keadaan panel)
  - `jabatanKosong` (boolean, default false) → the global switch. On: PitaJabatanKosong strip on every view; the "Ditutup oleh Yanti Sumual, Operator …" box above the checkbox on Konfirmasi; "ditutup oleh Yanti Sumual, Operator (menjalankan jabatan kosong Bendahara Jemaat), 16/11/2026 11.05" on the closed October card; "Dikonfirmasi oleh Yanti Sumual, Operator (menjalankan jabatan kosong Bendahara Jemaat) · 16/11/2026 11.05" on Ditutup.
  - `gagalDiCekTerakhir` (boolean, default false). On: the first close attempt fails after the 1500 ms progress: Gagal view, a new blocker "1 transaksi Draf bertanggal Oktober 2026", requirement 6 unmet, the statement unticked. The next attempt succeeds (`sudahGagal`). Off: the close succeeds. Read when the hold completes.
- **Interactions**
  - "Pop to `/TutupBuku`" means pop every `/TutupBuku/…` route above `/TutupBuku` (or go `/TutupBuku` when it is not in the stack), as defined for Main.
  - `hitungSelisih(p)` = (24.615.000 − (fee created ? 15.000 : 0)) − (24.100.000 + (in transit ? 500.000 : 0)): neither 515.000; in transit only 15.000; fee only 500.000; both 0.
  - `rekon(patch)` (helper): sets `pasti` false and applies the patch, then counts the displayed difference from its current value to the new target in 22 steps of 30 ms (660 ms), ease-out cubic `k = 1 − (1 − i/22)^3`. The footer and blockers use the computed target at once, not the counting figure.
  - "Hitung kas · Kas belum dihitung" → push `/HitungKas`.
  - "Periksa kesiapan tutup buku" (`keCek`) → push `/TutupBuku/cek`; also releases any hold.
  - Cek back (`keBulan`) → pop to `/TutupBuku`.
  - Cek links: "Pernyataan kesiapan" → push `/Kesiapan`; "Bantuan AI" → push `/AIBulan`; "Kejadian" → push `/Kejadian`.
  - Blockers, in order:
    - When not confirmed: title "Bank BNI ··4821 belum direkonsiliasi"; text "Selisih belum dijelaskan {Rp…}" (computed target, e.g. "Rp515.000"), or "Selisih sudah Rp0, rekonsiliasi belum dipastikan" when the target is 0; button "Buka rekonsiliasi" → push `/TutupBuku/rekonsiliasi`.
    - When a new October draft exists: title "1 transaksi Draf bertanggal Oktober 2026"; text "Fotokopi liturgi · Rp85.000 · bukukan, pindah tanggal atau batalkan"; button "Buka draf" → removes the blocker in place (`drafBaru` false; stands in for fixing the draft).
  - Requirements (eight rows, texts in Mock data): row 2 unmet "2 dari 3 kas/bank sudah direkonsiliasi" while not confirmed; row 6 unmet "masih ada 1 transaksi Draf" while the new draft exists; all others met.
  - "Untuk diketahui" items: "2 uang muka dengan sisa belum dipertanggungjawabkan", plus "1 setoran dalam perjalanan (belum tercatat di rekening koran)" when in transit.
  - "Lanjut ke konfirmasi tutup buku" (`keKonfirmasi`) → push `/TutupBuku/konfirmasi`, statement unticked.
  - Rekonsiliasi back (`keCek`) → pop to `/TutupBuku/cek`.
  - "Isi rekening koran" → push `/RekonIsi`; "Hitung kas" → push `/HitungKas`.
  - "Tandai dalam perjalanan" (`tandaiPerjalanan`) → `rekon({perjalanan: true})`. "Lepaskan" (`lepasPerjalanan`) → `rekon({perjalanan: false})`. "Buat transaksi dari mutasi ini" (`buatBiaya`) → `rekon({biaya: true})`; the fee is not undoable.
  - "Pastikan rekonsiliasi" (`pastikan`) → `pasti` true: badge "Sudah dipastikan", footer "Kembali ke kesiapan tutup buku" (`keCek` → pop to `/TutupBuku/cek`). Any later `rekon` (e.g. "Lepaskan") un-confirms.
  - "Cocok" count: 12, or 13 once the fee exists.
  - Checkbox (`onCentang`) → `centang` = checked. The whole bordered box toggles it.
  - Hold button (D08):
    - Pointer down (`tahanMulai`): ignored while unticked; else `tahan` true (fill grows over 1600 ms) and a 1650 ms timer starts that calls `tutupBuku()`.
    - Pointer up, pointer cancel, or the pointer leaving the button (`tahanBatal`; in the browser a cancel is followed by `pointerleave`): if holding, cancel the timer and set `tahan` false (fill shrinks in 200 ms). Nothing is closed.
    - Keyboard or assistive activation (`tahanKlik`, the board's `e.detail === 0` click): when ticked, `tutupBuku()` at once. In Flutter: Enter/Space with focus (`ActivateIntent`) and the Semantics tap action close immediately; a pointer tap without holding does nothing.
    - Disabled semantics while unticked; the hint under the button gives the reason.
  - `tutupBuku()`: switch to Proses, release the hold; system Back is blocked while in Proses. After 1500 ms (fakes the server close):
    - if `gagalDiCekTerakhir` is on and the close has not failed before: Gagal, with `sudahGagal` true, `drafBaru` true, `centang` false;
    - else pop to `/TutupBuku` and push `/TutupBuku/ditutup` (Cek and Konfirmasi leave the stack so Back cannot return to them), `tutup` true, files "siap0"; 3600 ms later PDF "Siap diunduh" and Excel "File gagal dibuat" (fakes file generation).
  - "Lihat hambatan" (`keCek`) → pop to `/TutupBuku/cek`. System Back on Gagal does the same (Gagal is an in-place state of `/TutupBuku/konfirmasi`, so popping it lands on Cek).
  - Konfirmasi "Kembali" (`keCek`) → pop to `/TutupBuku/cek`.
  - "Lihat laporan sementara" → push `/Laporan`.
  - "Unduh PDF" → push `/A4F01`. "Unduh Excel" → push `/WebExcel`.
  - "Coba lagi" on Excel (`xlsCoba`) → "Sedang disiapkan"; after 1800 ms "Siap diunduh" with "Unduh Excel".
  - "Kembali ke Bulan" (`keBulan`) → pop to `/TutupBuku`; the closed October card plays `cap`. System Back on Ditutup does the same.
  - Unmount: cancel the count interval and the 1650, 1500, 3600 and 1800 ms timers.
- **Motion**
  - `pudar` 200 ms: Bulan view, Proses, Gagal.
  - `masuk` 280 ms `keluar` curve (`pindahLayar`): Cek, Rekonsiliasi, Konfirmasi.
  - `muncul` 300 ms: success box and footer on Cek; the in-transit summary row; the "Dalam perjalanan" card; "Pastikan rekonsiliasi"; "Unduh PDF" / "Unduh Excel" when they appear. `muncul` 400 ms on Ditutup: text block after 1400 ms, files card after 1700 ms, caption and "Kembali ke Bulan" after 1900 ms.
  - `kait` (Gerak `kait`) when the fee is created: card A `dariKiri` 400 ms `keluar` curve (opacity 0, translateX −40 → 0); card B `dariKanan` 400 ms (translateX +40 → 0); link badge `kait` 400 ms after 350 ms (0 %: opacity 0, scale 0; 70 %: opacity 1, scale 1.25; 100 %: scale 1). The difference counts down over 660 ms (timer-driven) and its colour cross-fades `bata` → `laut` in 300 ms at Rp0.
  - `segelTahan`: the hold fill, width 0 → 100 % linear 1600 ms; release 200 ms linear back to 0. The close fires at 1650 ms.
  - `putar` 1 s linear, endless: Proses spinner.
  - `segel` sequence on Ditutup: `gelap` 700 ms ease-out (background `kertas` → `tinta`); `lingkar` 900 ms ease-out after 300 ms (dash offset 290 → 0); `cap` 500 ms `keluar` curve after 1100 ms on the lock, scale-only variant (0 %: opacity 0, scale 1.8; 60 %: opacity 1, scale 0.92; 100 %: scale 1). Same `cap` 500 ms on the closed October card on Bulan.
  - Reduce motion: every keyframe completes instantly, the difference jumps to its target, the spinner stands still, the hold fill jumps to full while held. The 1650 ms hold itself, the 1500 ms progress and the file timers stay (they are the confirmation and fake work, not motion).
- **Links out**
  - "Hitung kas · Kas belum dihitung" → `/HitungKas`, push
  - "Pernyataan kesiapan" → `/Kesiapan`, push
  - "Bantuan AI" → `/AIBulan`, push
  - "Kejadian" → `/Kejadian`, push
  - "Isi rekening koran" → `/RekonIsi`, push
  - "Hitung kas" → `/HitungKas`, push
  - "Lihat laporan sementara" → `/Laporan`, push
  - "Unduh PDF" → `/A4F01`, push
  - "Unduh Excel" → `/WebExcel`, push
  - **Inbound** (manifest): AIBulan, HitungKas, Kejadian, Keputusan, Kesiapan, Lainnya, Main, RekonIsi, SelesaikanUnit. navigation.md 3.4 adds PetaLayar and Cakupan (11 in all); the Keadaan panel lists all 11.
- **Mock data**
  - Months: September 2026 closed, "Periode laporan 15–30 September 2026, sejak tanggal mulai pencatatan"; October 2026 being closed, report period "1–31 Oktober 2026"; November 2026 current month.
  - Close: 16/11/2026 11.05 by "Meiske L." (or "Yanti Sumual, Operator (menjalankan jabatan kosong Bendahara Jemaat)").
  - Bank BNI ··4821, October 2026: Saldo buku Rp24.615.000 (Rp24.600.000 after the fee); Saldo rekening koran Rp24.100.000; deposit "Setoran ke bank" Rp500.000, BKU-2026-0131, 31/10/2026, carried to November 2026; bank line "BIAYA ADM" −Rp15.000, 31/10/2026, matched to BKU-2026-0133 "Biaya administrasi bank" (Belanja 5.03.03.00); 12 other bank lines already matched; starting difference Rp515.000.
  - Kas/Bank count: 3 ("2 dari 3 kas/bank sudah direkonsiliasi"). Kas not yet counted ("Kas belum dihitung").
  - New October draft (failure path): "Fotokopi liturgi", Rp85.000.
  - Untuk diketahui: 2 advances with unsettled balance; 1 deposit in transit.
  - Requirements (verbatim): "bulan sebelumnya sudah ditutup"; "semua 3 kas/bank sudah direkonsiliasi"; "Mata Anggaran sudah dipilih untuk semua transaksi"; "persetujuan yang wajib sudah dicatat"; "dokumen pendukung wajib sudah terverifikasi atau dikecualikan"; "tidak ada transaksi Draf atau Sudah diperiksa"; "tidak ada baris impor yang tertunda"; "persetujuan format laporan sudah dicatat".
- **Prototype-only** None of the four devices is on this board. "Buka draf" removing the blocker in place is a prototype shortcut but stays as a screen button (it is drawn as the app's fix button). The Keadaan panel carries `gagalDiCekTerakhir`, the global `jabatanKosong`, "Semua layar", the inbound links and the canvas title "2 · Akhir bulan: rekonsiliasi dan tutup buku".
- **Acceptance checks**
  1. Initial: Bulan lists November ("Bulan berjalan · menunggu Oktober ditutup"), October with a 2 px border and "Berikutnya untuk tutup buku · 1 hambatan", September dark "Sudah ditutup".
  2. "Periksa kesiapan tutup buku": "Hambatan" with counter "1", card "Bank BNI ··4821 belum direkonsiliasi" / "Selisih belum dijelaskan Rp515.000"; requirement 2 reads "2 dari 3 kas/bank sudah direkonsiliasi" in bold `bata`; no footer.
  3. Rekonsiliasi, "Tandai dalam perjalanan": the difference counts from "Rp515.000" to "Rp15.000" in about 0.66 s and stays `bata`; "+ Rp500.000" and "Saldo pembanding Rp24.600.000" show; the "Dalam perjalanan" card appears.
  4. Then "Buat transaksi dari mutasi ini": "Saldo buku Rp24.600.000", difference counts to "Rp0" and turns `laut`, "Cocok · 13 mutasi bank", the two cards slide in from both sides and the link badge pops; "Pastikan rekonsiliasi" appears.
  5. "Pastikan rekonsiliasi" → badge "Sudah dipastikan"; "Kembali ke kesiapan tutup buku" → Cek shows "Tidak ada hambatan. Oktober 2026 siap ditutup." and "Lanjut ke konfirmasi tutup buku". Separately: after "Pastikan rekonsiliasi" and before leaving Rekonsiliasi, pressing "Lepaskan" returns the badge to "Sedang dikerjakan", the difference counts to "Rp500.000" in `bata`, and the footer goes back to "Selisih belum dijelaskan harus Rp0 sebelum rekonsiliasi dapat dipastikan." (Once Cek shows no blockers there is no button back to Rekonsiliasi; that is the board.)
  6. Konfirmasi unticked: hold button grey with "Centang pernyataan di atas untuk melanjutkan"; pressing and holding does nothing. Ticked: dark button, hint "Tekan dan tahan tombol sampai penuh"; release after 1 s → fill drains in 0.2 s, still on Konfirmasi.
  7. Hold ≥ 1.65 s: "Sedang menutup buku…" with the spinner; after 1.5 s the screen darkens, the circle draws, the lock stamps in, then the text and files card appear; 3.6 s after arrival PDF "Siap diunduh" + "Unduh PDF", Excel "File gagal dibuat" + "Coba lagi"; "Coba lagi" → "Sedang disiapkan" → after 1.8 s "Unduh Excel".
  8. `gagalDiCekTerakhir` on: the first completed hold shows "Tutup buku tidak terjadi: ada perubahan sejak ringkasan ini ditampilkan."; "Lihat hambatan" shows the blocker "1 transaksi Draf bertanggal Oktober 2026" and requirement 6 "masih ada 1 transaksi Draf"; "Buka draf" clears it; the second close succeeds.
  9. After closing, "Kembali ke Bulan": October is the dark card "Sudah ditutup", "Periode laporan 1–31 Oktober 2026 · ditutup oleh Meiske L., 16/11/2026 11.05"; November reads "Berikutnya untuk tutup buku · bulan berjalan".
  10. Keyboard: tick the statement, focus the hold button, press Enter → Proses starts at once.
- **Notes**
  - Child routes: Proses and Gagal are in-place states of `/TutupBuku/konfirmasi` because they are outcomes of the hold with no back control; Ditutup is a route pushed after popping to `/TutupBuku`, so Back lands on Bulan and can never return to the confirmation of a closed month, while whatever pushed `/TutupBuku` (for example Main's "Oktober 2026 belum ditutup" row or "Rekonsiliasi" link) stays beneath. After a go (Main's or Lainnya's Bulan tab) nothing is beneath `/TutupBuku`.
  - The hold reason ("Centang pernyataan …") sits below the button, not above as TombolBersyarat says, and is not written "Tidak dapat dilakukan: …". Copy the board; the reason is `tinta3` 13, which meets 4.5:1 on `permukaan`.
  - ButirPerhatian says a Hambatan carries the label "HAMBATAN"; the board's blocker cards have no such label. Copy the board.
  - Motion timings differ from the tokens: the match count runs 660 ms (token `kait` 450 ms), the seal runs about 2.3 s in all (token `segel` 900 ms). Copy the board's timeline; the hold is 1600 ms fill + close at 1650 ms (token `segelTahan` 1600 ms).
  - The `cap` keyframe here is the scale-only variant (1.8 → 0.92 at 60 % → 1), variant C in `motion.md` (`Kerangka.capSegel`), different from Main's rotated stamp (variant A). `gelap` starts from `kertas` here and from `permukaan` on WebTutupBuku.
  - Off-token text: 24 px (Konfirmasi title; mono 24 600 difference), 17 px 700 (Proses), 15 px 600/700 (card and row titles, "Selisih belum dijelaskan", "Semua syarat wajib sudah terpenuhi:"), 15 px 400 (Konfirmasi subtitle, Gagal and Ditutup sentences), mono 14 500 (summary figures). Radii 12, 14, 16, 6 and 999 are tokens; no 12 px text.
  - White on `tinta` maps to `permukaan` (titles, badges, buttons, the seal) and `diTinta`/`diTinta2` for sentences and supporting text, per CONVENTIONS.
  - The manifest's timeout list ("1650", "1800") misses the nested 1500 ms and 3600 ms timers and the 30 ms count interval.
  - "Unduh Excel" on the phone links to the laptop board `WebExcel`; keep it as drawn.
  - Underlined `TautanTeks` (components.md): the link rows on Cek and Rekonsiliasi and "Lihat laporan sementara". "Hitung kas · Kas belum dihitung", "Unduh PDF" and "Unduh Excel" are buttons without underline.
  - The Konfirmasi "Untuk diketahui" text is static and always lists the deposit in transit; it is only reachable with the deposit marked, so it is always true.

---

### WebTutupBuku — Web · Tutup buku

- **Source** `docs/design/handoff/canvas/boards/WebTutupBuku.dc.html` · page Web (`web`) · form Laptop page (preview 1440×1100, `expand: fill`) · interactive yes
- **Route** `/WebTutupBuku`, no child routes (the hambatan list, confirmation, progress and sealed result are panels inside the page; the side nav and month cards stay) · **Widget** `WebTutupBukuScreen` in `lib/screens/web/web_tutup_buku.dart`
- **Purpose** The Bendahara Jemaat's month close on a laptop (Q26: laptop layout for the desk posts), journey step 4: see September, October and November side by side, see October's blockers if any, read the summary, tick the statement and hold the button to close October permanently, then download the official report files. Decisions shown: D08 (hold to close), D29 (web side bar), D32 (closed month as the `tinta` field), R04 (Operator runs the vacant post from 16/11/2026 08.15), PitaJabatanKosong web banner and the closing confirmation naming the Operator, "Bulan tanpa transaksi tetap harus ditutup".
- **Shell** Web side nav, finance variant with seven items, in this order: "Beranda", "Transaksi", "Uang Muka dan Titipan", "Rekonsiliasi", "Bulan dan tutup buku" (active), "Laporan", "Pengaturan". Page root: min height 100 % of the window, row that wraps, `kertas`, `tinta`, sans 15 line-height 1.45 (`isiWeb`).
  - Side nav (`flex: 1 1 220px`, so about 220 px wide next to the content): `permukaan`, right border 1 px `garis`, padding 24 16, column gap 20.
    - Brand (padding 0 8, gap 10): logo mark 26 (as Main); "palakat" 18 700 line-height 1.1; "Jemaat Karunia" `keterangan` `tinta3`.
    - Items: min height 44, padding 0 12, radius 10, 600, no underline; active `tinta` field with `permukaan` text; others transparent with `tinta` text.
    - Footer (pushed to the bottom, padding 12 8 0, top border 1 px `garis`, `keterangan` `tinta2`): "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (two lines; name 700 `tinta`); with `jabatanKosong`: "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat".
    - At 860 px wide or less: the nav becomes a top bar spanning the full width (row, wrap, items centred, gap 0 12, padding 8 16, no right border, bottom border 1 px `garis`), showing the brand and a toggle at the right (min height 44, padding 0 16, radius 14, 1.5 `tinta` line, `permukaan`, 14 700) labelled "Menu"; when open it reads "Tutup menu" on a `tinta` field with `permukaan` text and the items (padding 8 0) and the footer (padding-bottom 8) appear full width below. The content takes the full width.
  - Content (`flex: 999 1 560px`, min width 0): padding 28 clamp(16, 3 % of window width, 40) 40, column gap 22.
- **Layout** (content column, top to bottom)
  1. PitaJabatanKosong web banner (when `jabatanKosong` on): `role="status"`, `tinta` field, radius 14, padding 12 16, 14: "**Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.**" (`permukaan` 700) + " Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." (`diTinta2`).
  2. Title block: "Bulan dan tutup buku" `judulHalaman` (26 700); "Bulan ditutup satu per satu, mulai dari yang paling lama. Bulan tanpa transaksi tetap harus ditutup." `pendamping` `tinta2`.
  3. Link row (margin-top −8, wrap, gap 0 22, 14 600, each 44×44): "Pernyataan kesiapan", "Bantuan AI", "Kejadian setelah tutup buku".
  4. Month cards grid: columns as CSS `repeat(auto-fit, minmax(min(240px, 100%), 1fr))`, gap 14 (three across at 1440 and 1280; columns = min(3, floor((width + 14) / 254)), at least 1). Each card radius 16, padding 16, column gap 4; top row space-between, gap 8: month 17 700 + badge (13 700, radius 6).
     - September: line `ditutup` (`tinta` field, `permukaan` text). Badge "Sudah ditutup" (`permukaan` field, `tinta` text, padding 4 10). "Periode laporan 15–30 September 2026" `keterangan` `diTinta2`. Link "Lihat laporan resmi" 14 700 `permukaan`, margin-top 4, min height 44.
     - October, open: `permukaan` field, `tinta` text, 2 px `tinta` border. Badge "Belum ditutup" (transparent, `tinta2` text, 1.5 `tinta3` line, padding 3 9). "Berikutnya untuk tutup buku · tidak ada hambatan" (or "· 2 hambatan" when `adaHambatan`) `keterangan` `tinta2`.
     - October, closed: `tinta` field, `permukaan` text, 2 px `tinta` border; field and text colours cross-fade over 600 ms. Badge "Sudah ditutup" (`permukaan` field, `tinta` text, 1.5 `permukaan` line, padding 3 9). "Periode laporan 1–31 Oktober 2026" `keterangan` `diTinta2`. No report link.
     - November: `permukaan`, 1 px `garis`. Badge "Belum ditutup" (1.5 `tinta3`, `tinta2`, padding 3 9). "Bulan berjalan · menunggu Oktober ditutup" (after close "Berikutnya untuk tutup buku · bulan berjalan") `keterangan` `tinta2`.
  5. Hambatan panel (when `adaHambatan` on and October not closed), column gap 12:
     - Heading row gap 8: "Hambatan tutup buku Oktober 2026" 18 700 + counter "2" (`bata` field, `diBata` 13 700, radius 999, min width 22, height 22).
     - Card grid `repeat(auto-fit, minmax(min(320px, 100%), 1fr))`, gap 14 (two across at 1440). Each card `permukaan`, line `hambatan` (1.5 `bata`), radius 14, padding 16, column gap 4: title 700; text `pendamping` `tinta2`; link button (margin-top 8, aligned left, min height 44, padding 0 16, radius 12, `tinta` field, `permukaan` 700).
       - "Bank BNI ··4821 belum direkonsiliasi" / "Selisih belum dijelaskan Rp515.000" / "Buka rekonsiliasi".
       - "1 dokumen pendukung belum diverifikasi" / "<mono>BKU-2026-0122</mono> · Diakonia sakit · Rp300.000 · Diunggah, belum diverifikasi" / "Buka dokumen pendukung".
     - "Untuk diketahui (tidak menghalangi tutup buku): 2 uang muka dengan sisa belum dipertanggungjawabkan." `pendamping` `tinta2`, plain.
  6. Konfirmasi panel (when `adaHambatan` off and the close has not started): `permukaan`, 1 px `garis`, radius 18, padding clamp(18, 2.4 % of window width, 32). Two columns as `repeat(auto-fit, minmax(min(380px, 100%), 1fr))`, gap 28, top-aligned (two columns when the inner width is at least 788, else one stacked column).
     - Left column (gap 16):
       - "Tutup buku bulan Oktober 2026?" 24 700 line-height 1.2, margin-bottom 4; "Mohon baca ringkasan di bawah ini sebelum menutup buku." `isiWeb` `tinta2`.
       - "Semua syarat wajib sudah terpenuhi:" 15 700, margin-bottom 6; eight rows, gap 10, padding 3 0: met icon 18 (margin-top 2) + text 14 (the eight requirement texts as TutupBuku).
       - "Untuk diketahui" block identical to TutupBuku Konfirmasi.
       - Scope line `pendamping`, 1 px `garis` above only, padding-top 12: "Laporan resmi mencakup **1–31 Oktober 2026** untuk seluruh Jemaat: semua peruntukan dan semua kas/bank. " + link "Lihat laporan sementara" (700).
       - "Yang masih dapat Anda lakukan:" block identical to TutupBuku.
     - Right column (gap 14):
       - Permanent block: same as TutupBuku Konfirmasi except padding 20 and the title "Tutup buku bersifat permanen." at 19 px 700.
       - `jabatanKosong` box, same copy and style as TutupBuku.
       - Statement checkbox box, same copy and style as TutupBuku.
       - Action row (wrap, gap 10, centred): hold button (grows from a 240 px basis, min height 54, radius 14, same colours and fill layer as TutupBuku), then link "Kembali" (min height 54, padding 0 20, 700 `tinta`, no underline).
       - Hint `keterangan` `tinta3`, left-aligned: "Centang pernyataan di atas untuk melanjutkan." or "Tekan dan tahan tombol sampai penuh." (with a final period, unlike the phone).
  7. Proses panel: `permukaan`, 1 px `garis`, radius 18, min height 320, centred column gap 16: spinner 52×52 (drawn in a 56 box, same paths as TutupBuku, `putar` 1 s); "Sedang menutup buku…" 17 700, `role="status"`.
  8. Ditutup panel: radius 18, padding clamp(20, 3 % of window width, 40), row that wraps, centred, gap 28, `permukaan` text; background animates `permukaan` → `tinta` (`gelap` 700 ms) and stays `tinta`.
     - Seal 104×104 (no shrink), same drawing and animation as TutupBuku.
     - Text block (grows from a 320 px basis, gap 6, `muncul` 400 ms after 1400 ms): "Buku bulan Oktober 2026 sudah ditutup." 24 700 line-height 1.2; "Angka laporan resmi sudah dibekukan; file laporannya sedang disiapkan." `isiWeb` `diTinta2`; "Dikonfirmasi oleh Meiske L. · 16/11/2026 11.05" `keterangan` `diTinta2`.
     - Files card (grows from a 320 px basis, `permukaan` field, `tinta` text, radius 14, padding 4 16, `muncul` 400 ms after 1700 ms): rows as TutupBuku (titles 15 600), except the Excel failure text reads "File gagal dibuat. Angka tetap beku; cukup buat filenya lagi." and the "Unduh PDF"/"Unduh Excel" buttons appear without their own `muncul`. No caption and no "Kembali ke Bulan" below.
- **Components** Web side nav (shell, finance variant); PitaJabatanKosong (web banner, nav footer, closing box); LencanaStatus (Sudah ditutup, Belum ditutup); ButirPerhatian (Hambatan cards with fix links, Untuk diketahui line); Tombol (permanent hold button, link-buttons); GarisStatus (`ditutup` cards and permanent block, `hambatan` cards); Gerak (`segelTahan`, `segel`). Repeated patterns that are not components: the auto-fit card grid; the requirement row; the files status card; the progress panel with spinner.
- **Internal views and states**
  - Initial state (verbatim): `{ tahap: 'konfirmasi', centang: false, tahan: false, pdf: 'siap0', xls: 'siap0' }`.
  - Panels by state: `adaHambatan` on and not closed → Hambatan panel; `adaHambatan` off and `tahap` konfirmasi → Konfirmasi panel (unticked / ticked / holding); `tahap` proses → Proses panel (1500 ms); `tahap` sudah → Ditutup panel with files siap0 → (PDF siap, Excel gagal) → Excel siap0 → siap.
  - Month cards follow `tahap` sudah (October and November texts change).
  - Below 860 px: nav collapsed (closed / open).
  - All in-page; the route never changes. Leaving and re-entering the page starts from the initial state.
- **Tweaks** (Keadaan panel)
  - `jabatanKosong` (boolean, default false) → the global switch. On: the web banner at the top of the content; nav footer "Yanti Sumual · Operator / Menjalankan jabatan kosong Bendahara Jemaat"; the "Ditutup oleh Yanti Sumual, Operator …" box above the checkbox; "Dikonfirmasi oleh Yanti Sumual, Operator (menjalankan jabatan kosong Bendahara Jemaat) · 16/11/2026 11.05".
  - `adaHambatan` (boolean, default false). On (before close): October text "Berikutnya untuk tutup buku · 2 hambatan", the Hambatan panel shows and the Konfirmasi panel is hidden. No effect once October is closed. Read live.
- **Interactions**
  - Side nav items → go to `/WebBeranda`, `/WebTransaksi`, `/WebKewajiban`, `/WebRekonsiliasi`, `/WebTutupBuku` (current page: a self link, `Tautan` does nothing, the page state is kept; navigation.md 3.1), `/WebPaketLaporan`, `/WebPengaturan`. The list is the shared `navKeuangan` (navigation.md 1.3).
  - "Menu" / "Tutup menu" (below 860 px) → toggles the nav drawer open/closed.
  - Link row: "Pernyataan kesiapan" → push `/WebKesiapan`; "Bantuan AI" → push `/WebAI`; "Kejadian setelah tutup buku" → push `/WebKejadian`.
  - "Lihat laporan resmi" (September) → push `/WebLaporan`.
  - "Buka rekonsiliasi" → push `/WebRekonsiliasi`. "Buka dokumen pendukung" → push `/WebDokumen`.
  - "Lihat laporan sementara" → push `/WebLaporan`.
  - Checkbox (`onCentang`) → `centang` = checked; the whole box toggles it.
  - Hold button: exactly as TutupBuku (`tahanMulai` 1650 ms timer while ticked; `tahanBatal` on pointer up or leave; `tahanKlik` keyboard/assistive activation closes at once).
  - `tutupBuku()`: `tahap` proses, hold released; after 1500 ms `tahap` sudah; 3600 ms later PDF "Siap diunduh", Excel "File gagal dibuat. Angka tetap beku; cukup buat filenya lagi." (no failure tweak on this board).
  - "Coba lagi" (`xlsCoba`) → "Sedang disiapkan"; after 1800 ms "Siap diunduh" with "Unduh Excel".
  - "Unduh PDF" → push `/A4F01`. "Unduh Excel" → push `/WebExcel`.
  - "Kembali" → go `/WebBeranda`.
  - Unmount: cancel the 1650, 1500, 3600 and 1800 ms timers.
- **Motion**
  - October card: field and text colour cross-fade 600 ms when the close completes.
  - `segelTahan`: hold fill 0 → 100 % linear 1600 ms, release 200 ms; close at 1650 ms.
  - `putar` 1 s linear endless: Proses spinner.
  - `segel` on the Ditutup panel: `gelap` 700 ms ease-out (`permukaan` → `tinta`); `lingkar` 900 ms after 300 ms; `cap` (scale-only variant) 500 ms after 1100 ms on the lock; `muncul` 400 ms after 1400 ms (text) and 1700 ms (files card).
  - Reduce motion: as TutupBuku.
- **Links out**
  - Side nav (go): "Beranda" → `/WebBeranda`; "Transaksi" → `/WebTransaksi`; "Uang Muka dan Titipan" → `/WebKewajiban`; "Rekonsiliasi" → `/WebRekonsiliasi`; "Bulan dan tutup buku" → `/WebTutupBuku`; "Laporan" → `/WebPaketLaporan`; "Pengaturan" → `/WebPengaturan`.
  - "Pernyataan kesiapan" → `/WebKesiapan`, push
  - "Bantuan AI" → `/WebAI`, push
  - "Kejadian setelah tutup buku" → `/WebKejadian`, push
  - "Lihat laporan resmi" → `/WebLaporan`, push
  - "Buka rekonsiliasi" → `/WebRekonsiliasi`, push
  - "Buka dokumen pendukung" → `/WebDokumen`, push
  - "Lihat laporan sementara" → `/WebLaporan`, push
  - "Kembali" → `/WebBeranda`, go
  - "Unduh PDF" → `/A4F01`, push
  - "Unduh Excel" → `/WebExcel`, push
  - **Inbound** (manifest): AIBulan, TabBeranda, TabCatat, TabTransaksi, WebAI, WebAIFoto, WebAIMataAnggaran, WebAlihPeruntukan, WebAwal, WebAwalIsian, WebBagi, WebBantuanAI, WebBeranda, WebBukti, WebCari, WebCatat, WebDokumen, WebDraf, WebEkspor, WebExcel, WebExcelTerbatas, WebFormatLaporan, WebHitungKas, WebImpor, WebKasus, WebKasusBaru, WebKejadian, WebKeluar, WebKesiapan, WebKewajiban, WebKoreksi, WebLaporan, WebLihatDokumen, WebLihatTransaksi, WebMataAnggaran, WebMemuat, WebPaketLaporan, WebPemberitahuan, WebPemeriksa, WebPengaturan, WebPengembalian, WebPersembahan, WebPersetujuan, WebPilihBulan, WebRekonIsi, WebRekonsiliasi, WebSambungan, WebSelesaikanUnit, WebSerahTerima, WebTanggal, WebTransaksi, WebUbahPengaturan, WebUnggah. AIBulan is listed only through its dead `jsLinks` (navigation.md 3.2: its side-nav list is never rendered), so it does not really link here; navigation.md 3.4 adds PetaLayar and Cakupan. The Keadaan panel lists navigation.md's 54 (manifest minus AIBulan, plus the two sheets).
- **Mock data**
  - Church "Jemaat Karunia"; user "Meiske L." · Bendahara, "Wewenang Bendahara aktif"; Operator "Yanti Sumual", running the vacant post since 16/11/2026 08.15.
  - Months: September 2026 "Periode laporan 15–30 September 2026" (closed); October 2026 "Periode laporan 1–31 Oktober 2026"; November 2026 current. Close confirmed 16/11/2026 11.05.
  - Blockers (tweak): Bank BNI ··4821 difference Rp515.000; document BKU-2026-0122 "Diakonia sakit" Rp300.000 uploaded, not verified. 2 advances with unsettled balance.
  - Requirements: the eight texts listed under TutupBuku, Mock data.
- **Prototype-only** None of the four devices is on this board. The Keadaan panel carries `adaHambatan`, the global `jabatanKosong`, "Semua layar", the inbound links and the canvas title "Web · Tutup buku".
- **Acceptance checks**
  1. At 1440 wide: side nav with seven items, "Bulan dan tutup buku" on a `tinta` field; three month cards in one row; October white with a 2 px border reading "Berikutnya untuk tutup buku · tidak ada hambatan"; the Konfirmasi panel in two columns.
  2. `adaHambatan` on: October reads "· 2 hambatan", the "Hambatan tutup buku Oktober 2026" heading with counter "2" and two `bata`-edged cards show; the Konfirmasi panel is gone.
  3. Unticked: hold button grey, hint "Centang pernyataan di atas untuk melanjutkan."; holding does nothing. Ticked and held 1 s then released: the fill drains, nothing else changes.
  4. Ticked and held ≥ 1.65 s: Proses panel "Sedang menutup buku…"; after 1.5 s the Ditutup panel darkens with the seal; the October card fades to `tinta` with "Sudah ditutup" and "Periode laporan 1–31 Oktober 2026"; November reads "Berikutnya untuk tutup buku · bulan berjalan".
  5. 3.6 s after the Ditutup panel appears: PDF "Siap diunduh" with "Unduh PDF" (→ `/A4F01`); Excel "File gagal dibuat. Angka tetap beku; cukup buat filenya lagi." with "Coba lagi"; after "Coba lagi" and 1.8 s, "Unduh Excel" (→ `/WebExcel`).
  6. At 860 wide: the nav is a top bar with "Menu"; pressing it shows "Tutup menu" and the seven items; the Konfirmasi panel is one column; no horizontal overflow.
  7. `jabatanKosong` on: banner "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15. …" on top, nav footer "Yanti Sumual · Operator", and the box "Ditutup oleh Yanti Sumual, Operator, …" above the checkbox.
  8. "Kembali" opens `/WebBeranda`; "Kejadian setelah tutup buku" pushes `/WebKejadian` and Back returns here.
- **Notes**
  - No 12 px text. Off-token sizes: 17 px (month titles, Proses), 19 px (permanent title), 24 px (panel titles); radii 10 (nav items) and 18 (panels), both listed as allowed off-token values in CONVENTIONS.
  - `gelap` here starts from `permukaan` (the board's web keyframe), not `kertas` as on the phone; it animates the panel, not the whole screen.
  - The hambatan counter "2" and the blocker texts are fixed copy; resolving them is done on other boards.
  - If `adaHambatan` is switched on during Proses, the board would show both panels; the Keadaan panel is the only way to do that, so no guard is needed, but do not crash.
  - Hint sentences end with a period on web and without one on the phone; keep each board's copy.
  - Underlined `TautanTeks` (components.md): the three links under the title, "Lihat laporan sementara", and "Lihat laporan resmi" (underlined in `permukaan` on the dark September card). Side-nav items, the two Hambatan buttons, "Kembali", "Unduh PDF" and "Unduh Excel" have no underline.
  - The manifest's timeout list ("1650", "1800") misses the nested 1500 ms and 3600 ms timers.
  - The `tukarJk` swap is on (`jk && true`) but no string in this board's values contains "Meiske L.", so the swap changes nothing visible; the name changes come from `plk2` and the nav footer.
