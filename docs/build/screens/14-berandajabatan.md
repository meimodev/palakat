# Screens 14: BerandaJabatan, WebBerandaJabatan, Modul, Penugasan, WebPenugasan, JabatanKosong, WebJabatanKosong, Pelimpahan, KotakMasuk, WebKotakMasuk

These ten boards are the platform frame of the canvas page "Putaran 2 · Kerangka platform" (`p2`), titles 46 to 51 and their laptop pairs. BerandaJabatan/WebBerandaJabatan are the one combined Beranda for every post a person holds (Q31, BertindakSebagai): the `keadaan` tweak picks whose Beranda is shown (Pnt. Hendrik Rumagit with two posts, Meiske Lumentut, Olvie Pangemanan, Yanti Sumual, Novita Wenas) or one of two post-choice moments (the app picks the post itself; two posts can act and the person must choose). Each Beranda row drills into the board that holds that work, so this pair is the hub of the platform boards. Modul is the module list and the turn-on/turn-off confirmations of the Pimpinan Jemaat yang berwenang. Penugasan/WebPenugasan list post assignments and show the assignment form, the self-assignment refusal and the authority check. JabatanKosong/WebJabatanKosong show the Operator Yanti Sumual running the vacant Bendahara Jemaat post (banner, close confirmation, Riwayat, second-checker refusal, post filled again; R04). Pelimpahan lists task delegations, the delegation form and a delegation that has ended. KotakMasuk/WebKotakMasuk are the single notification box for all active modules (D28, C06). Every phone board here has the same header with a back arrow to `/BerandaJabatan` and no tab bar. Every laptop board uses the platform side nav (specified once under WebBerandaJabatan) with its own active item and footer, and a "Beranda" breadcrumb to `/WebBerandaJabatan`. Phone boards are reached from PetaPlatform, their Alur boards and a few other boards (see each Inbound list); among them only JabatanKosong is also a BerandaJabatan row target. WebBerandaJabatan, WebPenugasan and WebKotakMasuk are reached from every platform web board's side nav; WebJabatanKosong is not in the side nav (it is reached from the WebBerandaJabatan "Operator" row, WebAlurJabatanKosong, WebSerahTerima and PetaPlatform). Common rules for all ten: the board state is only `{ k: null }`. The view shown is `k ?? keadaan` (the panel's tweak value). In-board buttons set `k` to one of the tweak's options and do not move the panel's value. Changing `keadaan` in the Keadaan panel, or leaving the route, resets `k` to null. No board here has typed input, timers, sheets or toasts: every field is read-only, as drawn. Views change in place under the same header, so there are no child routes, and on every view change the scroll area jumps to the top (see Notes). "Up link" means the phone back arrow, the web "Beranda" breadcrumb and the "Kembali ke Beranda" buttons: it pops when its target is the route directly beneath, otherwise it does `go` to the target. Drill-ins into other boards are `push`; side-nav items are `go`. None of these boards has the `jabatanKosong` tweak, so the global switch changes nothing here. Today is 16/11/2026 on every board.

---

### BerandaJabatan — 46 · Beranda
- **Source** `docs/design/handoff/canvas/boards/BerandaJabatan.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 · interactive yes
- **Route** `/BerandaJabatan`, no child routes (every `keadaan` view changes in place under the same header) · **Widget** `BerandaJabatanScreen` in `lib/screens/p2/beranda_jabatan.dart`
- **Purpose** Anyone with an account, journey "Anyone, before a post applies", step 2 ("Beranda (page Putaran 2): one combined home for all posts a person holds"). Shows Q31 (one combined Beranda, no post switcher; the app picks the post when exactly one has the authority and asks when two do; the post used is recorded and cannot be changed), Q25 ("Anggota jemaat" is the base view), the BertindakSebagai rules ("Sebagai {jabatan} · …" on the second line; "Anda bertindak sebagai {jabatan}"; another post never opens a way to approve one's own submission) and the platform rule that a module that is not active leaves no trace ("Hanya modul yang aktif yang tampil").
- **Shell** Phone header with back, no tab bar. This header is shared by all six phone boards in this file:
  - Root: 390×844, `kertas` field, `tinta` text, `isi` 16/1.4, column: header, then a scroll area filling the rest.
  - Header row: padding 14 top, 12 sides, 8 bottom; gap 8; centred vertically. Back target 44×44 with a chevron (path `M15 6l-6 6 6 6`, 24 viewBox drawn at 22 px, stroke 2, round caps, `tinta`), semantics "Kembali ke Beranda", built as `KepalaPonsel(kembaliKe: 'BerandaJabatan', labelKembali: 'Kembali ke Beranda')` (an up link; on BerandaJabatan itself the target is the current board, so it also passes `diSini`, see its Interactions). Title column (flex 1): h1 in `judulLayar` 18/700, margin 0; subtitle 13 `tinta2` (the source writes `font-size: 14px; … font-size: 13px`; 13 wins).
  - Scroll area: vertical scroll, padding 8 top, 20 sides, 20 bottom. It holds one column with gap **16** between every direct item (headings, cards, rows, captions and button rows are all siblings).
- **Layout**
  - Header: title "Beranda", subtitle "Satu Beranda untuk semua jabatan Anda".
  - **List view** (`keadaan` = "Beberapa jabatan", "Bendahara Jemaat", "Sekretaris Jemaat", "Operator" or "Anggota jemaat"; the data set is in Mock data):
    1. Person card: `permukaan`, 1 px `garis` (dibukukan), radius 14, padding 12/14, column gap 8. Top: name 16/700 (`tinta`) over "Jabatan Anda" 13 `tinta3` (no gap). Below: a wrapping row of post chips, gap 6. Post chip: 13/700, radius 6, padding 3/9, 1.5 solid `tinta` line (terpilih), `permukaan` field, `tinta` text, e.g. "Penatua Kolom 7", "Ketua Komisi Diakonia".
    2. (when the person has any) Heading "Perlu tindakan" (`judulBagian` 16/700, margin 0), then one **row card** per item.
    3. (when the person has any) Heading "Untuk diketahui" (16/700), then its row cards.
    4. Caption 13 `tinta3`: "Semua pekerjaan dari semua jabatan Anda ada di sini. Hanya modul yang aktif yang tampil. Setiap tindakan mencatat jabatan yang dipakai."
    5. Link "Akun saya": text link (no `text-decoration: none`, so underlined), 14/700 `laut`, `lautTua` while hovered or pressed, min-height 44, text vertically centred and left-aligned; the target spans the column width (an inline-flex item stretched by the flex column).
    - **Row card** (shared with KotakMasuk): a full-width pressable link. `permukaan`, 1 px `garis`, radius 14, padding 12/16, min-height 44, row centred, gap 12. Text column (flex 1, may shrink, gap 2): title 16/600 `tinta`, subtitle 13 `tinta3` (both wrap). Optional status badge (does not shrink). Then a chevron (path `M9 6l6 6-6 6`, drawn at 18 px, stroke `tinta3` 2, round caps). No underline.
  - **"Jabatan dipilih otomatis" view** (no person card, no lists, no caption, no "Akun saya"):
    1. Case card: `permukaan`, 1 px `garis`, radius 14, padding 14/16, column gap 6. Row (space-between, gap 16, centred): "Verifikasi data · Peristiwa: Baptisan" 16/700, badge "Diajukan" (style `garis`). Then 14 `tinta2`: "Gabriel Wenas · Keluarga Wenas-Lasut · Kolom 7". Then a key/value row (space-between, gap 16, 14): "Diajukan oleh" `tinta2` | "Novita Wenas, 15/11/2026" 600 `tinta`, right-aligned.
    2. Post-used box (BertindakSebagai, single post): `lautLembut` field, no line, radius 12, padding 12/14, 14: "**Anda bertindak sebagai Penatua Kolom 7.**" (700 `tinta`), a space, then `tinta2`: "Hanya jabatan ini yang berwenang memverifikasi data Kolom 7. Jabatan dipilih sendiri oleh aplikasi dan tampil sebelum Anda menyetujui."
    3. Caption 13 `tinta3`: "Tercatat di Riwayat: Pnt. Hendrik Rumagit, Penatua Kolom 7."
    4. Button row: primary "Verifikasi data" and text button "Kembali" (button set below).
  - **"Dua jabatan dapat bertindak" view**:
    1. Case card as above: "Setujui jadwal · Ibadah Kolom 7 bersama Komisi Diakonia" 16/700 with badge "Draf" (style `draf`), then 14 `tinta2` "Kamis, 19/11/2026 19.00 · rumah Kel. Wenas-Lasut". No key/value row.
    2. Choice box (terpilih): 1.5 solid `tinta` line, `permukaan`, radius 12, padding 12/14, 14 `tinta`: "**Dua jabatan Anda dapat menyetujui ini.** Pilih salah satu. Jabatan yang Anda pilih tercatat di Riwayat dan tidak dapat diubah setelahnya."
    3. Button row: two secondary buttons "Sebagai Penatua Kolom 7" and "Sebagai Ketua Komisi Diakonia". At 350 px they share one row at about 171 px each (about 136 px for text after padding and line); both labels are wider than that at 16/700, so each wraps to two centred lines inside its button (the buttons grow taller than 48).
    4. Caption 13 `tinta3`: "Aplikasi hanya memilih sendiri bila tepat satu jabatan yang berwenang. Jabatan Anda yang lain tidak membuka jalan menyetujui atau memverifikasi pengajuan Anda sendiri."
  - **Button set** (used by every board in this file; text inherits the body size: 16 on phone, 15 on web; weight 700, centred, horizontal padding 16):
    - Primary: min-height 52, radius 14, no line, `tinta` field, `permukaan` text.
    - Secondary: min-height 48, radius 14, 1.5 `tinta` line, `permukaan` field, `tinta` text.
    - Text: min-height 44, no line, no field, `laut` text.
    - Disabled (JabatanKosong only): min-height 52, radius 14, no line, `garis` field, `tinta2` text.
    - Button row: wrap, gap 8 both ways. Each button starts at 150 wide, grows equally to fill its line, never wider than 340. On the phone (350 px): two buttons share a line at about 171 each; a lone button is 340 wide and left-aligned.
  - **Badge styles** (the board's `LS` table; every badge 13/700, radius 6, padding 3/9, 1.5 line). `draf`: dashed `putus` line, no field, `tinta2` text. `garis`: solid `tinta3` line, `permukaan` field, `tinta2` text. `tinta`: `tinta` field and line, `permukaan` text. `laut`: `laut` field and line, `diLaut` text. `bata`: solid `bata` line, `permukaan` field, `bata` text. `abu`: `garis` field and line, `tinta2` text. (`lautg` exists in the table but is unused in this file.)
- **Components** LencanaStatus / LencanaModul (badges, shapes from the `LS` table above), BertindakSebagai (post chips on the person card, "Sebagai {jabatan} · …" subtitles, the "Anda bertindak sebagai" box, the two-post choice with outlined buttons), Tombol (primary, secondary, text), GarisStatus (dibukukan cards, terpilih choice box, draf badge). Repeated patterns that are not components: the row card, the case card with key/value rows, the button set.
- **Internal views and states** Initial state `{ k: null }`. View = `k ?? keadaan`. "Beberapa jabatan" … "Anggota jemaat" (option index 0–4): the list view with that person's data (`daftar` true). "Jabatan dipilih otomatis" (index 5): auto-picked post view. "Dua jabatan dapat bertindak" (index 6): post choice view. A list with no items hides its heading (`adaTindak`, `adaTahu`); every person in the data has at least one item in both lists. No sheets, toasts, banners or empty states.
- **Tweaks**
  - `keadaan` (enum, default "Beberapa jabatan") — Keadaan panel. Options and effect:
    - "Beberapa jabatan": Pnt. Hendrik Rumagit, two chips, 3 "Perlu tindakan" rows, 1 "Untuk diketahui" row.
    - "Bendahara Jemaat": Meiske Lumentut, one chip, 2 + 1 rows.
    - "Sekretaris Jemaat": Olvie Pangemanan, one chip, 3 + 1 rows.
    - "Operator": Yanti Sumual, chips "Operator" and "Menjalankan jabatan kosong: Penatua Kolom 2", 3 + 1 rows.
    - "Anggota jemaat": Novita Wenas, chip "Anggota jemaat", 1 + 3 rows.
    - "Jabatan dipilih otomatis": the auto-picked post view.
    - "Dua jabatan dapat bertindak": the two-post choice view.
  - Global `jabatanKosong`: no effect on this board.
- **Interactions**
  - Every row card → push its target board (Links out). No state change.
  - "Verifikasi data", "Kembali" (auto-picked view) and "Sebagai Penatua Kolom 7", "Sebagai Ketua Komisi Diakonia" (choice view) all run `go0`: `k = "Beberapa jabatan"` → Pnt. Hendrik Rumagit's list view shows at once; the panel still reads the old tweak value. Nothing is recorded or counted down ("5 data menunggu verifikasi" stays 5). Scroll jumps to top.
  - Header back arrow → `KepalaPonsel(kembaliKe: 'BerandaJabatan', labelKembali: 'Kembali ke Beranda', diSini: _ulang)`, a link to this same board (as the source). The back `Tautan` does not navigate; it calls `diSini` (components.md 1.6). `_ulang`: `setState(() => k = null)` and jump the scroll area to the top, so the board stays on `/BerandaJabatan` with the panel's view (what reloading the board does on the canvas). Do not pop to another board.
  - "Akun saya" → push `/AkunSaya`.
- **Motion** None. The board declares `masuk`, `pudar`, `muncul` and `isi` but no element uses them; view swaps are instant. Route transitions in and out use the app default (motion.md). Focus ring per CONVENTIONS.
- **Links out** Header back arrow (no label, "Kembali ke Beranda") → `/BerandaJabatan`, self (see Interactions). "Akun saya" → `/AkunSaya`, push. Row cards (built in the logic class; push):
  - Beberapa jabatan: "5 data menunggu verifikasi" → `/AntreanVerifikasi`; "Ibadah Kolom 7, 19/11/2026" → `/Ibadah`; "Permintaan dana Komisi Diakonia" → `/PermintaanDana`; "12 anggota Kolom 7 belum dikonfirmasi" → `/KonfirmasiKeluarga`.
  - Bendahara Jemaat: "Keuangan: 4 hal perlu tindakan" → `/Main`; "1 hambatan dari unit" → `/SelesaikanUnit`; "2 uang muka dengan sisa belum dipertanggungjawabkan" → `/Main`.
  - Sekretaris Jemaat: "2 pengumuman masih Draf" → `/Pengumuman`; "3 permohonan surat" → `/PermohonanSurat`; "Warta Jemaat edisi 22/11/2026" → `/WartaEditor`; "1 pengumuman berakhir pada 20/11/2026" → `/Pengumuman`.
  - Operator: "4 formulir kertas belum dimasukkan" → `/KonfirmasiKeluarga`; "2 permohonan surat dicatat di kantor" → `/PermohonanSurat`; "3 data Kolom 2 menunggu verifikasi" → `/JabatanKosong`; "Buku anggota: 318 baris sudah diimpor" → `/ImporBuku`.
  - Anggota jemaat: "Permohonan surat keterangan" → `/PermohonanSurat`; "Warta Jemaat edisi 15/11/2026" → `/WartaArsip`; "2 pengumuman untuk Kolom 7" → `/Pengumuman`; "Persembahan saya" → `/PersembahanSaya`.
  - **Inbound** AkunSaya, AlurBeranda, AlurMasuk, CariOrang, DataAnggota, DokumenGereja, Ibadah, JabatanKosong, KeadaanUmum, KotakMasuk, LaporanLintas, Modul, Panitia, Pelimpahan, Pengumuman, Penugasan, PersembahanSaya, PetaPlatform, WartaArsip.
- **Mock data** (rows as title · subtitle · badge (style) · target)
  - Pnt. Hendrik Rumagit · posts "Penatua Kolom 7", "Ketua Komisi Diakonia". Perlu tindakan: "5 data menunggu verifikasi" · "Sebagai Penatua Kolom 7 · 2 permohonan · 2 peristiwa · 1 perubahan data" · "Diajukan" (garis); "Ibadah Kolom 7, 19/11/2026" · "Sebagai Penatua Kolom 7 · menunggu persetujuan Anda" · "Draf" (draf); "Permintaan dana Komisi Diakonia" · "Sebagai Ketua Komisi Diakonia · menunggu persetujuan" · "Diajukan" (garis). Untuk diketahui: "12 anggota Kolom 7 belum dikonfirmasi" · "Sebagai Penatua Kolom 7 · belum tampil di publikasi apa pun" · no badge.
  - Meiske Lumentut · "Bendahara Jemaat". Perlu tindakan: "Keuangan: 4 hal perlu tindakan" · "Saldo buku Rp38.415.000 · Oktober 2026 belum ditutup" · no badge; "1 hambatan dari unit" · "Kolom 7 · menghalangi tutup buku Oktober 2026" · "Hambatan" (bata). Untuk diketahui: "2 uang muka dengan sisa belum dipertanggungjawabkan" · "Tidak menghalangi tutup buku" · no badge.
  - Olvie Pangemanan · "Sekretaris Jemaat". Perlu tindakan: "2 pengumuman masih Draf" · "Belum diterbitkan" · "Draf" (draf); "3 permohonan surat" · "Diajukan anggota dan dicatat Operator" · "Diajukan" (garis); "Warta Jemaat edisi 22/11/2026" · "Belum diterbitkan" · "Draf" (draf). Untuk diketahui: "1 pengumuman berakhir pada 20/11/2026" · "Setelah itu diarsipkan sendiri" · no badge.
  - Yanti Sumual · "Operator", "Menjalankan jabatan kosong: Penatua Kolom 2". Perlu tindakan: "4 formulir kertas belum dimasukkan" · "Sebagai Operator · dari anggota tanpa ponsel" · no badge; "2 permohonan surat dicatat di kantor" · "Sebagai Operator · menunggu Sekretaris Jemaat" · "Diajukan" (garis); "3 data Kolom 2 menunggu verifikasi" · "Menjalankan jabatan kosong Penatua Kolom 2 sejak 01/11/2026" · "Jabatan kosong" (bata). Untuk diketahui: "Buku anggota: 318 baris sudah diimpor" · "241 belum dikonfirmasi" · no badge.
  - Novita Wenas · "Anggota jemaat". Perlu tindakan: "Permohonan surat keterangan" · "Diajukan 14/11/2026" · "Diajukan" (garis). Untuk diketahui: "Warta Jemaat edisi 15/11/2026" · "Diterbitkan untuk semua anggota" · "Diterbitkan" (tinta); "2 pengumuman untuk Kolom 7" · "Ditujukan untuk: Kolom 7" · no badge; "Persembahan saya" · "Hanya yang dicatat atas nama Anda" · no badge.
  - Auto-picked case: Peristiwa Baptisan of Gabriel Wenas, Keluarga Wenas-Lasut, Kolom 7, submitted by Novita Wenas on 15/11/2026; actor Pnt. Hendrik Rumagit as Penatua Kolom 7.
  - Two-post case: Ibadah Kolom 7 bersama Komisi Diakonia, Kamis 19/11/2026 19.00, rumah Kel. Wenas-Lasut.
  - Keep all of this as one `berandaJabatan` table in `lib/mock/` shared with WebBerandaJabatan (same figures; only the targets differ).
- **Prototype-only** none on the board. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/BerandaJabatan` with defaults → header "Beranda" / "Satu Beranda untuk semua jabatan Anda"; card "Pnt. Hendrik Rumagit", "Jabatan Anda", chips "Penatua Kolom 7" and "Ketua Komisi Diakonia" with a 1.5 `tinta` edge.
  2. Same state → "Perlu tindakan" shows 3 row cards: the first has an outlined `tinta3` badge "Diajukan", the second a dashed badge "Draf"; "Untuk diketahui" shows "12 anggota Kolom 7 belum dikonfirmasi" with no badge.
  3. Tap "5 data menunggu verifikasi" → `/AntreanVerifikasi` opens (push); system Back returns to this Beranda with the same view.
  4. Panel `keadaan` = "Bendahara Jemaat" → name "Meiske Lumentut", one chip; row "1 hambatan dari unit" has a `bata` outlined badge "Hambatan"; tapping "Keuangan: 4 hal perlu tindakan" opens `/Main`.
  5. Panel "Operator" → second chip reads "Menjalankan jabatan kosong: Penatua Kolom 2"; row "3 data Kolom 2 menunggu verifikasi" (badge "Jabatan kosong") opens `/JabatanKosong`.
  6. Panel "Anggota jemaat" → "Untuk diketahui" has 3 rows; "Warta Jemaat edisi 15/11/2026" carries a `tinta`-filled badge "Diterbitkan"; "Persembahan saya" opens `/PersembahanSaya`.
  7. Panel "Jabatan dipilih otomatis" → no person card and no "Akun saya"; a `lautLembut` box starting "Anda bertindak sebagai Penatua Kolom 7."; press "Verifikasi data" → Pnt. Hendrik Rumagit's list view appears instantly.
  8. Panel "Dua jabatan dapat bertindak" → two outlined buttons side by side; press "Sebagai Ketua Komisi Diakonia" → list view. Then set the panel to "Sekretaris Jemaat" → Olvie Pangemanan's view (k was reset).
  9. Header back arrow → still `/BerandaJabatan`, view returns to the panel's value; "Akun saya" opens `/AkunSaya`.
- **Notes** The primary "Verifikasi data" uses a `tinta` field, not the `laut` primary of Tombol; keep the board. The header back arrow links to this same board; that is the source's choice (every Putaran 2 phone board points its back arrow at BerandaJabatan, this one included), so keep the arrow and make it a self-link that resets the view. The row links are built in the logic class (`hal()`), so `board-manifest.json` lists only AkunSaya and BerandaJabatan for this board; `navigation.md` 3.3 adds the row targets as computed links (read by `gen_boards.py`), so the link test checks them too: wire every row with `Tautan(ke: …)` exactly as listed. The manifest's `hasSideNav: true` is a false positive (the class merely checks `navVals`); the phone board has no side nav. `rp()` is defined and unused. The post chips use the terpilih line even for "Menjalankan jabatan kosong: Penatua Kolom 2", where LencanaModul would use a `bata` line for a vacant post; keep the board (these are the person's posts, not post-state badges). The `go0` buttons do not record anything or change counts; no feedback was drawn, so add none. Scroll on view change (applies to every board in this file): the canvas keeps the old scroll offset, clamped to the new content, which can leave the reader at the bottom of a shorter view (for example after "Catat penugasan" below ten post cards). The recommended choice is to jump the scroll area to the top whenever `k` or `keadaan` changes the view.

### WebBerandaJabatan — Web · Beranda
- **Source** `docs/design/handoff/canvas/boards/WebBerandaJabatan.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebBerandaJabatan`, no child routes · **Widget** `WebBerandaJabatanScreen` in `lib/screens/p2/web_beranda_jabatan.dart`
- **Purpose** Same as BerandaJabatan on the laptop: the combined Beranda for desk posts (Q26: Bendahara Jemaat, Sekretaris Jemaat, Operator), though the tweak also shows the phone-only persons. Q31, Q25, BertindakSebagai. It is the home of every platform web board (their breadcrumb and first side-nav item point here).
- **Shell** Web side nav, **platform variant** (specified once here; WebPenugasan, WebJabatanKosong and WebKotakMasuk use it with their own active item and footer):
  - Page: `kertas`, `tinta` text, `isiWeb` 15/1.45, min-height the window, a wrapping row of nav and main.
  - Nav column: flex basis 220 (grows 1, practically stays 220), padding 24/16, `permukaan`, 1 px `garis` right border, column gap 20.
  - Brand row (padding 0 8, gap 10): Palakat mark 26×26 (rect x2 y2 w20 h20 rx6, 2 px `laut` stroke dashed 3 3, no fill; plus the filled right half, path `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z`, `laut`) beside "palakat" 18/700 line-height 1.1 over "Jemaat Karunia" 13 `tinta3`.
  - Items, exactly, in this order: Beranda → `/WebBerandaJabatan`, Keuangan → `/WebBeranda`, Dokumen gereja → `/WebDokumenGereja`, Pengumuman → `/WebPengumuman`, Warta Jemaat → `/WebWartaArsip`, Data jemaat → `/WebDataAnggota`, Ibadah dan kegiatan → `/Ibadah`, Panitia → `/Panitia`, Pemberitahuan → `/WebKotakMasuk`, Pengaturan → `/WebPenugasan`. Each item: min-height 44, padding 0 12, radius 10 (off-token), weight 600, no underline, no gap between items. Active: `tinta` field, `permukaan` text; others transparent, `tinta` text (no hover colour change). All `go`, except an active item that links to its own board (Beranda here, Pengaturan on WebPenugasan, Pemberitahuan on WebKotakMasuk; `navigation.md` kind self): it stays on the page and, as reloading the board does on the canvas, resets `k` to null and scrolls to top. The screen passes that effect as `NavSamping(…, diSini: _ulang)`; the item's `Tautan` calls it instead of navigating (components.md 1.6, 4.3). "Ibadah dan kegiatan" and "Panitia" open phone boards (they have no laptop layout).
  - Footer: margin-top auto (bottom of the nav), padding 12 top / 8 sides / 0 bottom, 1 px `garis` top rule, 13 `tinta2`, the name in 700 `tinta`. On this board: "**Jemaat Karunia** · satu akun, semua jabatan".
  - Active item on this board: **Beranda**.
  - At 860 px and narrower (the board's `@media (max-width:860px)`, so 860 itself is collapsed): the nav becomes a full-width top bar (row, wrap, centred, column gap 12, padding 8/16, no right border, 1 px `garis` bottom border). A toggle sits at the right end: min-height 44, padding 0 16, radius 14, 1.5 `tinta` line, `permukaan`, 14/700, label "Menu", semantics "Menu". Open: `tinta` field, `permukaan` text, label "Tutup menu", and the item list (padding 8 0) and the footer (margin-top 0, padding-bottom 8) appear full-width under the brand row. Closed: items and footer hidden.
  - Main column: flex 999 1 560, min-width 0, padding 28 top, clamp(16, 3 vw, 40) sides, 40 bottom, column gap 20.
- **Layout** (main column, top to bottom)
  1. Title block: breadcrumb link "Beranda" (14/600 `laut`, underlined text link, hover `lautTua`), h1 "Beranda" (`judulHalaman` 26/700, margin-top 2), subtitle 14 `tinta2` "Satu Beranda untuk semua jabatan Anda".
  2. Content column: max-width 1120, left-aligned, column gap 16.
     - **List view** (first five options):
       a. Person card exactly as BerandaJabatan list 1, except the name is 15/700 (web body size).
       b. Two-column row: wrap, row gap 20, column gap 28, top-aligned. Left column flex 1.3 1 420, right flex 1 1 340, each a column with gap 12. Left: heading "Perlu tindakan" (16/700) then a **list box**. Right: heading "Untuk diketahui" then a list box. At 1440 the columns are about 608 and 484 wide; at 860 (nav collapsed to the top bar, content about 808) about 431 and 349; when the content column is narrower than 788 (420 + 340 + 28) they stack (also between about 861 and 1070 wide, where the side nav takes 220).
       c. Caption 13 `tinta3`: "Semua pekerjaan dari semua jabatan Anda ada di sini. Hanya modul yang aktif yang tampil. Setiap tindakan mencatat jabatan yang dipakai."
       d. Link "Akun saya" (underlined text link, 14/700 `laut`, hover `lautTua`, min-height 44, full-width target, text left).
       - **List box** (shared with WebKotakMasuk): `permukaan`, 1 px `garis`, radius 14, clipped. Rows are separated by 1 px `garis` rules; no rule above the first row (the source hides it with margin-top −1). Each row is a link: three columns [flexible | badge, as wide as needed | 20 px], gap 16, centred vertically, min-height 52, padding 8/18, no underline. Cell 1: title 15/600 `tinta` (basis 260, grow 1) and subtitle 13 `tinta3` (basis 300, grow 1.4) side by side on one baseline when the cell is at least 580 wide (gap 20), otherwise the subtitle wraps under the title (row gap 2). At the drawn widths the cell is always narrower than 580, so the subtitle sits under the title. Cell 2: the badge, right-aligned, or empty. Cell 3: chevron `M9 6l6 6-6 6` 18 px, stroke `tinta3` 2.
     - **"Jabatan dipilih otomatis" view**: as BerandaJabatan (case card, `lautLembut` box, caption, buttons), full content width; card titles 15/700; buttons 15/700, 340 wide each, left-aligned in one row.
     - **"Dua jabatan dapat bertindak" view**: as BerandaJabatan, same width rules.
- **Components** As BerandaJabatan: LencanaStatus / LencanaModul, BertindakSebagai, Tombol, GarisStatus. Plus the platform side nav (shell). Patterns: list box with rows, case card, button set.
- **Internal views and states** Initial state `{ k: null }`; views as BerandaJabatan (list for options 0–4, auto-picked post, two-post choice). Nav drawer open/closed (at 860 px and narrower only) is local UI state, closed on load.
- **Tweaks** `keadaan` (enum, same seven options, default "Beberapa jabatan") — Keadaan panel; effects as BerandaJabatan. Global `jabatanKosong`: no effect.
- **Interactions** As BerandaJabatan: rows push their targets; the four `go0` buttons set `k = "Beberapa jabatan"`. Breadcrumb "Beranda" is a link to this same board, built as `Tautan(ke: 'WebBerandaJabatan', diSini: _ulang)`: it stays and calls `_ulang` (`setState(() => k = null)` and scroll the page to the top). "Akun saya" → push `/WebAkunSaya`. Side-nav items → `go`; the active "Beranda" item is a self link and does what the breadcrumb does: `NavSamping(item: navPlatform, aktif: 0, pengguna: …, diSini: _ulang)`. Menu toggle (at 860 px and narrower) → open/close the drawer.
- **Motion** None. Declared and unused: `muncul`, `isi`, `titik`. Drawer opens instantly (the source is a CSS checkbox swap, no transition).
- **Links out** Breadcrumb "Beranda" → `/WebBerandaJabatan` (self). "Akun saya" → `/WebAkunSaya`, push. Side nav (go): Beranda → `/WebBerandaJabatan`, Keuangan → `/WebBeranda`, Dokumen gereja → `/WebDokumenGereja`, Pengumuman → `/WebPengumuman`, Warta Jemaat → `/WebWartaArsip`, Data jemaat → `/WebDataAnggota`, Ibadah dan kegiatan → `/Ibadah`, Panitia → `/Panitia`, Pemberitahuan → `/WebKotakMasuk`, Pengaturan → `/WebPenugasan`. Rows (push; the source's `hal()` keeps a phone board when it is in its phone-only list, maps `Main` to `WebBeranda`, otherwise prefixes `Web`):
  - Beberapa jabatan: "5 data menunggu verifikasi" → `/AntreanVerifikasi`; "Ibadah Kolom 7, 19/11/2026" → `/Ibadah`; "Permintaan dana Komisi Diakonia" → `/PermintaanDana`; "12 anggota Kolom 7 belum dikonfirmasi" → `/KonfirmasiKeluarga`.
  - Bendahara Jemaat: "Keuangan: 4 hal perlu tindakan" → `/WebBeranda`; "1 hambatan dari unit" → `/WebSelesaikanUnit`; "2 uang muka dengan sisa belum dipertanggungjawabkan" → `/WebBeranda`.
  - Sekretaris Jemaat: "2 pengumuman masih Draf" → `/WebPengumuman`; "3 permohonan surat" → `/WebPermohonanSurat`; "Warta Jemaat edisi 22/11/2026" → `/WebWartaEditor`; "1 pengumuman berakhir pada 20/11/2026" → `/WebPengumuman`.
  - Operator: "4 formulir kertas belum dimasukkan" → `/KonfirmasiKeluarga`; "2 permohonan surat dicatat di kantor" → `/WebPermohonanSurat`; "3 data Kolom 2 menunggu verifikasi" → `/WebJabatanKosong`; "Buku anggota: 318 baris sudah diimpor" → `/WebImporBuku`.
  - Anggota jemaat: "Permohonan surat keterangan" → `/WebPermohonanSurat`; "Warta Jemaat edisi 15/11/2026" → `/WebWartaArsip`; "2 pengumuman untuk Kolom 7" → `/WebPengumuman`; "Persembahan saya" → `/PersembahanSaya`.
  - **Inbound** PetaPlatform, WebAkunSaya, WebAlurDokumen, WebAlurJabatanKosong, WebAlurKeluarga, WebAlurMasuk, WebAlurPengembalian, WebAlurPulihkan, WebAlurSurat, WebAlurUnit, WebAlurWarta, WebBukaNama, WebCariOrang, WebDataAnggota, WebDataGanda, WebDokumenGereja, WebImporBuku, WebJabatanKosong, WebKasUnit, WebKeadaanUmum, WebKotakMasuk, WebLaporanLintas, WebPengumuman, WebPenugasan, WebPermohonanSurat, WebPersembahanBernama, WebSelesaikanUnit, WebTerbitDokumen, WebWartaArsip, WebWartaEditor.
- **Mock data** Identical to BerandaJabatan (same persons, posts, rows, badges, case texts); only row targets differ as listed.
- **Prototype-only** none on the board. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/WebBerandaJabatan` at 1440 → side nav with "Beranda" filled `tinta`, footer "Jemaat Karunia · satu akun, semua jabatan"; h1 "Beranda".
  2. Defaults → "Perlu tindakan" box (3 rows, rules between rows, none above the first) on the left and "Untuk diketahui" box (1 row) on the right, side by side.
  3. Panel "Bendahara Jemaat" → tap "Keuangan: 4 hal perlu tindakan" → `/WebBeranda` (push); Back returns.
  4. Panel "Operator" → "3 data Kolom 2 menunggu verifikasi" opens `/WebJabatanKosong`; "4 formulir kertas belum dimasukkan" opens the phone board `/KonfirmasiKeluarga`.
  5. Panel "Jabatan dipilih otomatis" → press "Kembali" → list view of Pnt. Hendrik Rumagit.
  6. Side nav "Pemberitahuan" → `/WebKotakMasuk` (go); "Pengaturan" → `/WebPenugasan`; "Ibadah dan kegiatan" → `/Ibadah`.
  7. Resize to 861 → side nav, columns stacked. Resize to 860 → nav becomes a top bar with "Menu" and the two columns sit side by side (about 431 / 349); tap "Menu" → "Tutup menu" on a `tinta` field and the ten items and the footer appear. Resize to 700 → columns stack.
  8. "Akun saya" → `/WebAkunSaya`.
- **Notes** Row links and side-nav links are built in the logic class; the manifest's `jsLinks` holds the nav targets but none of the row targets. `navigation.md` 3.3 adds the row targets as computed links, so the link test checks them: wire every row from this spec. Web buttons inherit 15 px (phone 16). Primary "Verifikasi data" is `tinta`, not `laut`; keep. The breadcrumb "Beranda" on Beranda itself is a self-link; keep it as on the source. Nav radius 10 is off-token; copy.

### Modul — 47 · Modul
- **Source** `docs/design/handoff/canvas/boards/Modul.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 · interactive yes
- **Route** `/Modul`, no child routes (the confirmations replace the list in place under the same header) · **Widget** `ModulScreen` in `lib/screens/p2/modul.dart`
- **Purpose** Pimpinan Jemaat yang berwenang (Pdt. Lidya Rondonuwu), journey "Pimpinan Jemaat yang berwenang", step 1 ("Modul"). Shows the platform rule that a module may be absent and leaves no trace when Tidak aktif. Also shows the LencanaModul rules: Aktif / Tidak aktif / Hanya baca, and turning off deletes nothing (the module becomes Hanya baca). Module prerequisites ("Perlu: …"). Q29/P10: BIPRA categories are fixed by GMIM, with the rule. Q28: the default, versioned consent text. P12: a required reason ("Alasan · wajib"). P09 and P14 are linked: the approver table and unit Kas/Bank.
- **Shell** Phone header with back (as BerandaJabatan): title "Modul", subtitle "Pimpinan Jemaat yang berwenang mengaktifkan modul saat orangnya siap". Back → `/BerandaJabatan`.
- **Layout** (scroll area column, gap 16)
  - **"Daftar modul" view**:
    1. Module grid: columns of min 300 that fill the width, gap 16, top-aligned. At 350 px this is one column of 10 module cards. Module card: `permukaan`, 1 px `garis`, radius 14, padding 12/16, column gap 4. Row (space-between, gap 16, centred): module name 16/700, badge (LencanaModul: Aktif = style `laut`, Tidak aktif = style `draf`, Hanya baca = style `garis`). Under it the note 13 `tinta3`. Ten rows in Mock data.
    2. Button row: secondary "Aktifkan modul" go1 and secondary "Nonaktifkan modul" go2 (about 171 px each, about 136 px for text; "Nonaktifkan modul" at 16/700 is close to that width: if it does not fit, let it wrap to two centred lines, never clip).
    3. Caption 13 `tinta3`: "Modul yang tidak aktif tidak tampil di navigasi, pencarian, pemberitahuan atau keadaan kosong mana pun."
    4. Link "Tabel pemberi persetujuan" (underlined text link, 14/700 `laut`, `lautTua` while hovered or pressed, min-height 44, full-width target, text left).
    5. Link "Kas/Bank yang dikelola unit" (same style).
  - **"Mengaktifkan Data jemaat" view**:
    1. Card (padding 14/16, column gap 6, `permukaan`, 1 `garis`, radius 14): row "Aktifkan modul: Data jemaat" 16/700 + badge "Tidak aktif" (draf). Then 14 `tinta2` "Yang harus ada lebih dulu:". Then three key/value rows (space-between, gap 16, 14; key `tinta2`; value 600 `tinta`, right-aligned, wraps): "Aturan Kategori BIPRA" | "Ketentuan GMIM · tidak dapat diubah gereja"; "Naskah Izin penggunaan data pribadi" | "Naskah bawaan · versi 1 · 12/11/2026"; "Penatua Kolom untuk setiap Kolom" | "11 dari 12 terisi". Then 13 `tinta3`: "Kolom 2 belum punya Penatua. Operator dapat menjalankan jabatan kosong itu."
    2. Card (same style): "Kategori BIPRA" 16/700. Key/value rows: "Anak" | "sampai sebelum 12 tahun"; "Remaja" | "12 tahun sampai 17 tahun 364 hari"; "Pemuda" | "18 tahun ke atas, belum pernah menikah"; "Bapa · Ibu" | "sudah menikah". Then two captions 13 `tinta3`: "Yang pernah menikah tetap Bapa atau Ibu, termasuk yang ditinggal pasangannya. Yang belum pernah menikah tetap Pemuda, berapa pun umurnya. Yang menikah sebelum 18 tahun menjadi Bapa atau Ibu." and "Dihitung sendiri dari tanggal lahir, jenis kelamin dan status pernikahan. Bila GMIM mengubah ketentuannya, Palakat memperbaruinya dengan tanggal berlaku."
    3. Caption 13 `tinta3` (outside the cards): "Setelah aktif, anggota dan keluarga diminta mengonfirmasi datanya dan memberi izin. Yang Belum dikonfirmasi tidak tampil di publikasi apa pun."
    4. Button row: primary "Aktifkan modul", text "Kembali".
  - **"Menonaktifkan Warta Jemaat" view**:
    1. Card (padding 14/16, column gap 6): row "Nonaktifkan modul: Warta Jemaat" 16/700 + badge "Aktif" (laut). Then 14 `tinta2`: "Menonaktifkan tidak menghapus apa pun. Modul menjadi **Hanya baca**: 46 edisi yang sudah diterbitkan tetap dapat dibaca, tetapi tidak ada edisi baru." ("Hanya baca" bold, same `tinta2`). Then the reason field: label column gap 6, 14 `tinta2`, label "Alasan · wajib"; a read-only 3-row text area, full width, padding 12/14, radius 12, 1 px `garisTegas`, `permukaan`, min-height 96, no resize, text 14 `tinta2`, value "Sekretaris Jemaat sedang berganti; diaktifkan lagi setelah penugasan baru."
    2. Button row: primary "Nonaktifkan modul", text "Kembali".
  - **"Dilihat jabatan lain" view**:
    1. Notice box (terpilih): 1.5 `tinta` line, `permukaan`, radius 12, padding 12/14, 14: "**Hanya Pimpinan Jemaat yang berwenang** yang mengaktifkan atau menonaktifkan modul. Anda dapat melihat daftarnya."
    2. The same module grid with the same ten cards. No buttons, no caption, no links.
- **Components** LencanaModul (module badges), Tombol (secondary pair, primary, text), IsianAlasan (the "Alasan · wajib" field, drawn 3 rows high and read-only), PitaPeran-like notice (terpilih box for the role notice), GarisStatus. Patterns: module card, key/value rows, button set (BerandaJabatan).
- **Internal views and states** Initial state `{ k: null }`; view = `k ?? keadaan`: "Daftar modul", "Mengaktifkan Data jemaat", "Menonaktifkan Warta Jemaat", "Dilihat jabatan lain". Nothing in the module list changes after the confirmations (Data jemaat stays Tidak aktif, Warta Jemaat stays Aktif).
- **Tweaks** `keadaan` (enum "Daftar modul" · "Mengaktifkan Data jemaat" · "Menonaktifkan Warta Jemaat" · "Dilihat jabatan lain", default "Daftar modul") — Keadaan panel. Each option shows the view of the same name above. Global `jabatanKosong`: no effect.
- **Interactions**
  - "Aktifkan modul" (list, secondary) → `go1`: `k = "Mengaktifkan Data jemaat"`.
  - "Nonaktifkan modul" (list, secondary) → `go2`: `k = "Menonaktifkan Warta Jemaat"`.
  - "Aktifkan modul" (primary) and "Kembali" in the Data jemaat view → `go0`: back to the list, unchanged.
  - "Nonaktifkan modul" (primary) and "Kembali" in the Warta Jemaat view → `go0`: back to the list, unchanged.
  - Reason field: read-only, as drawn. It can take focus and be selected, but not edited. The primary is never disabled (the reason is already filled).
  - Every view change jumps the scroll to top.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`.
- **Links out** Header back arrow ("Kembali ke Beranda") → `/BerandaJabatan`, up link. "Tabel pemberi persetujuan" → `/PemberiPersetujuan`, push. "Kas/Bank yang dikelola unit" → `/KasUnit`, push. **Inbound** AlurModul, PemberiPersetujuan, PetaPlatform.
- **Mock data** Modules (name · badge · note):
  1. Keuangan · Aktif · "Diaktifkan 15/09/2026 oleh Pdt. Lidya Rondonuwu"
  2. Dokumen gereja · Aktif · "Diaktifkan 03/11/2026"
  3. Pengumuman · Aktif · "Diaktifkan 03/11/2026"
  4. Warta Jemaat · Aktif · "Perlu: Pengumuman aktif"
  5. Data jemaat · Tidak aktif · "Siap diaktifkan · Kategori BIPRA mengikuti ketentuan GMIM"
  6. Ibadah dan kegiatan · Tidak aktif · "Perlu: Data jemaat aktif"
  7. Jumlah kehadiran · Tidak aktif · "Perlu: Ibadah dan kegiatan aktif"
  8. Panitia · Hanya baca · "Dinonaktifkan 01/11/2026; riwayat tetap dapat dibaca"
  9. Keuangan unit · Tidak aktif · "Perlu: Keuangan aktif dan Kas/Bank yang dikelola unit"
  10. Persetujuan di aplikasi · Tidak aktif · "Perlu: tabel pemberi persetujuan Jemaat"
  - Data jemaat prerequisites: consent text "Naskah bawaan · versi 1 · 12/11/2026"; Penatua Kolom "11 dari 12 terisi" (Kolom 2 empty). Warta Jemaat: 46 published editions. Reason "Sekretaris Jemaat sedang berganti; diaktifkan lagi setelah penugasan baru." BIPRA rule as above.
- **Prototype-only** none on the board. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/Modul` → ten module cards in one column; "Keuangan" has a `laut`-filled badge "Aktif", "Data jemaat" a dashed badge "Tidak aktif", "Panitia" an outlined `tinta3` badge "Hanya baca".
  2. Press "Aktifkan modul" → view "Aktifkan modul: Data jemaat" with row "Penatua Kolom untuk setiap Kolom" | "11 dari 12 terisi" and the "Kategori BIPRA" card (row "Remaja" | "12 tahun sampai 17 tahun 364 hari"); scroll is at top.
  3. In that view press "Aktifkan modul" (primary, `tinta`) → back to the list; "Data jemaat" still shows "Tidak aktif".
  4. Press "Nonaktifkan modul" → card "Nonaktifkan modul: Warta Jemaat" with badge "Aktif", label "Alasan · wajib" and the filled text "Sekretaris Jemaat sedang berganti; diaktifkan lagi setelah penugasan baru."; typing into it changes nothing; "Kembali" returns to the list.
  5. Panel `keadaan` = "Dilihat jabatan lain" → boxed notice starting "Hanya Pimpinan Jemaat yang berwenang" above the ten cards; no buttons and no links.
  6. "Tabel pemberi persetujuan" → `/PemberiPersetujuan` (push); "Kas/Bank yang dikelola unit" → `/KasUnit`.
  7. Header back arrow → `/BerandaJabatan`.
- **Notes** "Aktifkan modul" and "Nonaktifkan modul" on the list are generic buttons that open the two worked examples (Data jemaat, Warta Jemaat); in the app one would press a module card. Keep them as drawn: module cards are not pressable. The confirmations' primary buttons only return to the list; there is no success feedback, and none should be added (the typed flow is AlurModul). The reason field is three rows and read-only, where IsianAlasan is two lines; keep the board. Primaries are `tinta`, not `laut`; keep. The manifest's `hasSideNav: true` is a false positive. `baris()` and `rp()` are defined and unused.

### Penugasan — 48 · Penugasan jabatan
- **Source** `docs/design/handoff/canvas/boards/Penugasan.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 · interactive yes
- **Route** `/Penugasan`, no child routes (the form and refusal replace the list in place under the same header) · **Widget** `PenugasanScreen` in `lib/screens/p2/penugasan.dart`
- **Purpose** Pimpinan Jemaat yang berwenang (Pdt. Lidya Rondonuwu), journey "Pimpinan Jemaat yang berwenang", step 2 ("Penugasan jabatan"). Shows the post states of LencanaModul (Aktif, Berakhir, Jabatan kosong with a `bata` line), the rule that no one assigns a post to themselves (Penolakan), R01 (the Ketua Jemaat, Pdt. Lidya Rondonuwu, is also Ketua BPMJ and the Pimpinan Jemaat yang berwenang; the board adds that her own assignment is recorded by the Tim pengembang at setup), the rule that an assignment is not an in-app approval (the decision is a church document), the Petugas verifikasi check for Bendahara Jemaat and Sekretaris Jemaat (technical access alone gives no authority), and P08 (assignment dates).
- **Shell** Phone header with back (as BerandaJabatan): title "Penugasan jabatan", subtitle "Siapa memegang jabatan apa, di unit mana, sejak kapan". Back → `/BerandaJabatan`.
- **Layout** (scroll area column, gap 16)
  - **"Daftar jabatan" view**:
    1. Post grid (columns of min 300, gap 16, top-aligned; one column at 350 px), ten post cards. Post card: radius 14, padding 12/16, column gap 2. Filled post: `permukaan` field, 1 px `garis` line. Vacant post (`Jabatan kosong`): 1.5 dashed `putus` line, **no field** (the `kertas` page shows through). Row (space-between, gap 16, centred): post name 16/700, badge. Then the holder 14 `tinta` ("—" when vacant). Then the note 13 `tinta3`.
    2. Button row: one primary "Catat penugasan", 340 wide, left-aligned.
  - **"Catat penugasan" view**:
    1. Form card: `permukaan`, 1 `garis`, radius 14, padding 14/16, column gap 12. Read-only fields, each a label column (gap 6, 14 `tinta2`): label text, then a one-line field: full width, min-height 48, horizontal padding 14, radius 12, 1 px `garisTegas`, `permukaan`, value 14 `tinta2`, vertically centred. Fields in order: "Orang" = "Sym. Greis Mamahit"; "Jabatan" = "Syamas"; "Unit" = "Kolom 3"; then a date grid (columns of min 300, gap **16**, one column at this width): "Mulai" = "18/11/2026"; "Berakhir" = "—" with the hint 13 `tinta3` "Kosong: sampai dicatat berakhir" under the field (inside the label column, gap 6); then "Keputusan gereja" = "SK BPMJ No. 14/2026 · Dokumen gereja" with the hint "Dilampirkan dari Dokumen gereja".
    2. Caption 13 `tinta3`: "Dicatat oleh Pdt. Lidya Rondonuwu, Pimpinan Jemaat yang berwenang. Penugasan bukan persetujuan di aplikasi; keputusannya ada di dokumen."
    3. Button row: primary "Catat penugasan", text "Batalkan".
  - **"Menugaskan diri sendiri" view**:
    1. Form card (as above) with three read-only fields: "Orang" = "Pdt. Lidya Rondonuwu"; "Jabatan" = "Ketua Komisi"; "Unit" = "Komisi Diakonia".
    2. Refusal (Penolakan), 15 px: "**Tidak dapat dilakukan: Catat penugasan.**" (700 `bata`), a space, then "Anda tidak dapat menugaskan jabatan kepada diri sendiri." (`tinta`).
    3. Caption 13 `tinta3`: "Penugasan Pimpinan Jemaat yang berwenang dicatat oleh Tim pengembang saat pengaturan awal."
    4. Button row: secondary "Pilih orang lain", text "Batalkan".
  - **"Menunggu verifikasi wewenang" view**:
    1. Card (`permukaan`, 1 `garis`, radius 14, padding 14/16, column gap 6): row "Sekretaris Jemaat" 16/700 + badge "Menunggu verifikasi wewenang" (draf). 14 `tinta2` "Olvie Pangemanan · dicatat 03/11/2026". 13 `tinta3` "Penunjukan Bendahara Jemaat dan Sekretaris Jemaat diperiksa Petugas verifikasi terhadap keputusan tertulis gereja sebelum wewenangnya aktif. Akses teknis saja tidak memberi wewenang."
    2. Card (same): row "Operator" 16/700 + badge "Aktif" (laut). 14 `tinta2` "Yanti Sumual · sejak 01/11/2026". 13 `tinta3` "Penugasan Operator tidak melewati Petugas verifikasi."
    3. No buttons.
- **Components** LencanaModul (post badges Aktif / Jabatan kosong / Berakhir, and "Menunggu verifikasi wewenang" in the draf shape), Penolakan (self-assignment refusal), Tombol (primary, secondary, text), GarisStatus (dibukukan cards, draf dashed vacant cards). Patterns: post card, read-only field with label and hint, button set.
- **Internal views and states** Initial state `{ k: null }`; view = `k ?? keadaan`: "Daftar jabatan", "Catat penugasan", "Menugaskan diri sendiri", "Menunggu verifikasi wewenang". The list never changes (recording does not add a card).
- **Tweaks** `keadaan` (enum "Daftar jabatan" · "Catat penugasan" · "Menugaskan diri sendiri" · "Menunggu verifikasi wewenang", default "Daftar jabatan") — Keadaan panel. Each option shows the view of the same name. Global `jabatanKosong`: no effect.
- **Interactions**
  - "Catat penugasan" (list) → `go1`: form view.
  - "Catat penugasan" (form, primary) and "Batalkan" (form) → `go0`: list view, unchanged. No validation: all fields are read-only and filled.
  - "Pilih orang lain" (self-assignment view) → `go1`: the form view with "Sym. Greis Mamahit".
  - "Batalkan" (self-assignment view) → `go0`: list view.
  - Fields: read-only; focusable and selectable, not editable.
  - Every view change jumps the scroll to top.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`.
- **Links out** Header back arrow ("Kembali ke Beranda") → `/BerandaJabatan`, up link. **Inbound** AlurPenugasan, Peristiwa, PetaPlatform.
- **Mock data** Posts (post · badge (style) · holder · note; "dashed" marks a vacant card):
  1. Bendahara Jemaat · Aktif (laut) · Meiske Lumentut · "Sejak 15/09/2026 · wewenang sudah diverifikasi"
  2. Penatua Kolom 2 · Jabatan kosong (bata) · — · "Dijalankan Operator Yanti Sumual sejak 01/11/2026" · dashed
  3. Sekretaris Jemaat · Aktif · Olvie Pangemanan · "Sejak 03/11/2026 · SK BPMJ No. 12/2026"
  4. Ketua Jemaat · Aktif · Pdt. Lidya Rondonuwu · "Sejak 01/01/2026 · Ketua BPMJ"
  5. Wakil Ketua BPMJ · Aktif · Pnt. Jefry Wowor · "Sejak 01/01/2026"
  6. Ketua Komisi Diakonia · Aktif · Pnt. Hendrik Rumagit · "Sejak 01/03/2026"
  7. Operator · Aktif · Yanti Sumual · "Sejak 01/11/2026"
  8. Penatua Kolom 7 · Aktif · Pnt. Hendrik Rumagit · "Sejak 01/01/2026"
  9. Syamas Kolom 3 · Jabatan kosong (bata) · — · "Belum ada yang menjalankan" · dashed
  10. Penatua Kolom 2 · Berakhir (abu) · Pnt. Altje Rompas · "01/01/2022 – 31/10/2026"
  - Form: Sym. Greis Mamahit, Syamas, Kolom 3, Mulai 18/11/2026, Berakhir —, SK BPMJ No. 14/2026. Self-assignment: Pdt. Lidya Rondonuwu, Ketua Komisi, Komisi Diakonia. Authority check: Olvie Pangemanan, recorded 03/11/2026; Yanti Sumual since 01/11/2026. Share this table with WebPenugasan.
- **Prototype-only** none on the board. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/Penugasan` → ten post cards; "Penatua Kolom 2" (second) and "Syamas Kolom 3" have a dashed `putus` edge, no white field, a `bata` outlined badge "Jabatan kosong" and holder "—"; the last card has a `garis`-filled badge "Berakhir" and "01/01/2022 – 31/10/2026".
  2. Press "Catat penugasan" → form with "Orang" "Sym. Greis Mamahit", "Mulai" "18/11/2026", "Berakhir" "—" and hint "Kosong: sampai dicatat berakhir"; scroll at top.
  3. Press "Batalkan" → list; press "Catat penugasan" then the primary "Catat penugasan" → list, still ten cards.
  4. Panel `keadaan` = "Menugaskan diri sendiri" → fields "Pdt. Lidya Rondonuwu", "Ketua Komisi", "Komisi Diakonia" and the sentence with "Tidak dapat dilakukan: Catat penugasan." in `bata`; press "Pilih orang lain" → the form with "Sym. Greis Mamahit".
  5. Panel "Menunggu verifikasi wewenang" → card "Sekretaris Jemaat" with a dashed badge "Menunggu verifikasi wewenang" and card "Operator" with `laut` badge "Aktif"; no buttons; nothing overflows the card at 390 wide.
  6. Header back arrow → `/BerandaJabatan`.
- **Notes** "Mulai 18/11/2026" is two days after the design's today (16/11/2026), and P08 says a future start date is refused; the board was drawn on 18/11/2026 (JabatanKosong also says "sejak 18/11/2026"). Keep the value; flag to design. The badge "Menunggu verifikasi wewenang" (about 225 px) plus "Sekretaris Jemaat" at 16/700 may not fit the 318 px card row on one line: let the title wrap first, and if it still does not fit, let the badge text wrap to a second line (max width about 60 % of the row) rather than overflow. The vacant cards have no field on purpose (draf line on `kertas`); keep. Primaries are `tinta`; keep. Codes such as "SK BPMJ No. 14/2026" are document references inside a field value, not No. Bukti; keep them sans.

### WebPenugasan — Web · Penugasan jabatan
- **Source** `docs/design/handoff/canvas/boards/WebPenugasan.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Laptop page (preview 1440×1100) · interactive yes
- **Route** `/WebPenugasan`, no child routes · **Widget** `WebPenugasanScreen` in `lib/screens/p2/web_penugasan.dart`
- **Purpose** Same as Penugasan on the laptop. It is the "Pengaturan" page of the platform web nav. Same decisions (LencanaModul post states, no self-assignment, Petugas verifikasi check, P08, R01).
- **Shell** Platform web side nav (WebBerandaJabatan). Active item: **Pengaturan**. Footer: "**Pdt. Lidya Rondonuwu** · Ketua Jemaat" on the first line, "Pimpinan Jemaat yang berwenang" on the second (a line break, same 13 `tinta2`).
- **Layout** (main column)
  1. Title block: breadcrumb "Beranda" (14/600 `laut`, underlined text link, hover `lautTua`) → `/WebBerandaJabatan`; h1 "Penugasan jabatan" (26/700, margin-top 2); subtitle 14 `tinta2` "Siapa memegang jabatan apa, di unit mana, sejak kapan".
  2. Content column, max-width 1120, gap 16:
     - **"Daftar jabatan"**: the post grid as Penugasan (columns of min 300, gap 16, top-aligned): three columns of about 363 at 1440 (10 cards in rows of 3, 3, 3, 1), two at 860. Card text at web size (post name 15/700; holder 14; note 13). Then one primary "Catat penugasan" (340 wide, left).
     - **"Catat penugasan"**: a two-column row (wrap, row gap 20, column gap 28, top-aligned). Left (flex 1.3 1 420, column gap 12): the form card exactly as Penugasan (same fields, values and hints; the Mulai/Berakhir grid stays one column at about 574 px inner width at 1440, and becomes two columns only when the card's inner width reaches 616). Right (flex 1 1 340, column gap 12): the caption "Dicatat oleh Pdt. Lidya Rondonuwu, Pimpinan Jemaat yang berwenang. Penugasan bukan persetujuan di aplikasi; keputusannya ada di dokumen." then the button row (primary "Catat penugasan", text "Batalkan", side by side at about 238 each).
     - **"Menugaskan diri sendiri"**: same as Penugasan (card with three fields at full content width, refusal sentence 15 px, caption, buttons "Pilih orang lain" and "Batalkan" at 340 each, left).
     - **"Menunggu verifikasi wewenang"**: same as Penugasan, cards at full content width.
- **Components** As Penugasan: LencanaModul, Penolakan, Tombol, GarisStatus. Plus the platform side nav.
- **Internal views and states** As Penugasan. Initial state `{ k: null }`. Drawer state at 860 px and narrower.
- **Tweaks** `keadaan` (same four options, default "Daftar jabatan") — Keadaan panel; same effects. Global `jabatanKosong`: no effect.
- **Interactions** As Penugasan (`go1` from "Catat penugasan" on the list and from "Pilih orang lain"; `go0` from the form's two buttons and from "Batalkan" on the refusal). Breadcrumb → up link to `/WebBerandaJabatan`. Side nav → `go`. Menu toggle at 860 px and narrower.
- **Motion** None. Declared and unused: `muncul`, `isi`, `titik`.
- **Links out** Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link. Side nav as WebBerandaJabatan (go), "Pengaturan" (self, active) → `/WebPenugasan`. **Inbound** PetaPlatform, WebAkunSaya, WebAlurDokumen, WebAlurJabatanKosong, WebAlurKeluarga, WebAlurMasuk, WebAlurPengembalian, WebAlurPulihkan, WebAlurSurat, WebAlurUnit, WebAlurWarta, WebBerandaJabatan, WebBukaNama, WebCariOrang, WebDataAnggota, WebDataGanda, WebDokumenGereja, WebImporBuku, WebJabatanKosong, WebKasUnit, WebKeadaanUmum, WebKotakMasuk, WebLaporanLintas, WebPengumuman, WebPermohonanSurat, WebPersembahanBernama, WebSelesaikanUnit, WebTerbitDokumen, WebWartaArsip, WebWartaEditor.
- **Mock data** Same as Penugasan. Footer persona: Pdt. Lidya Rondonuwu, Ketua Jemaat.
- **Prototype-only** none on the board. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/WebPenugasan` at 1440 → side nav "Pengaturan" filled `tinta`; footer "Pdt. Lidya Rondonuwu · Ketua Jemaat" / "Pimpinan Jemaat yang berwenang"; post grid in three columns.
  2. Press "Catat penugasan" → form card on the left, caption and the two buttons on the right.
  3. Press "Batalkan" → list.
  4. Panel `keadaan` = "Menugaskan diri sendiri" → refusal "Tidak dapat dilakukan: Catat penugasan." in `bata` followed by "Anda tidak dapat menugaskan jabatan kepada diri sendiri."; "Pilih orang lain" opens the form.
  5. At 860 (nav collapsed to the top bar with "Menu") → grid in two columns of about 396; the form view keeps its two columns (431 / 349).
  6. Breadcrumb "Beranda" → `/WebBerandaJabatan`.
- **Notes** Same notes as Penugasan (Mulai 18/11/2026 vs P08; vacant cards without a field; `tinta` primaries). The footer persona differs from WebBerandaJabatan's; each web board keeps its own.

### JabatanKosong — 49 · Menjalankan jabatan kosong
- **Source** `docs/design/handoff/canvas/boards/JabatanKosong.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 · interactive yes
- **Route** `/JabatanKosong`, no child routes · **Widget** `JabatanKosongScreen` in `lib/screens/p2/jabatan_kosong.dart`
- **Purpose** Operator Yanti Sumual, journey "Operator", step 2 ("Menjalankan jabatan kosong"). Shows R04 (the Operator runs the vacant Bendahara post from 16/11/2026 08.15), the PitaJabatanKosong rules (`tinta` banner on every Keuangan screen while the post is run; every action recorded "oleh {nama}, Operator · menjalankan jabatan kosong {jabatan}"; the close confirmation names the Operator; running a vacant post does not replace the second person when Wajib pemeriksa kedua is on; the banner goes as soon as a holder is assigned), D03 (one combined Saldo buku) and the refusal form of Penolakan.
- **Shell** Phone header with back (as BerandaJabatan): title "Menjalankan jabatan kosong", subtitle "Contoh keadaan: jabatan Bendahara Jemaat belum ada pemegangnya". Back → `/BerandaJabatan`.
- **Layout** (scroll area column, gap 16)
  - **Vacancy banner** (used in three views; PitaJabatanKosong, full form): `tinta` field, `permukaan` text, radius 14, padding 12/14, 14 px; the board gives it no `role`, so it is plain text, not a live region: "**Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.**" then a space and, in `diTinta2`, "Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual."
  - **"Pita di setiap layar" view**:
    1. Vacancy banner.
    2. Balance card (`permukaan`, 1 `garis`, radius 14, padding 14/16, column gap 6): row (space-between, gap 16, centred) "Saldo buku semua Kas/Bank" 16/700 | "Rp38.415.000" mono 16/500 (`jumlah`). Under it 13 `tinta3` "Hanya transaksi yang sudah dibukukan".
    3. Work card (same style): row "Perlu tindakan" 16/700 | badge "4" (bata). Under it 14 `tinta2` "Oktober 2026 belum ditutup · 2 draf belum dibukukan".
    4. Caption 13 `tinta3`: "Pita ini tampil di setiap layar Keuangan selama jabatan dijalankan: Beranda, Transaksi, Rekonsiliasi, Tutup buku, Laporan."
    5. Button row: secondary "Lihat konfirmasi tutup buku" (340 wide, left).
  - **"Konfirmasi tutup buku" view**:
    1. Vacancy banner.
    2. Confirmation card (padding 14/16, column gap 6): "Tutup buku bulan Oktober 2026?" (`judulLayar` 18/700). 14 `tinta2`: "Ditutup oleh **Yanti Sumual, Operator**, yang menjalankan jabatan kosong Bendahara Jemaat. Nama dan keadaan ini tercatat pada tutup buku." (bold part `tinta`). Then a checkbox row: the whole row is the target, min-height 44, gap 12, top-aligned, 14 `tinta`: checkbox 24×24 (2 px top offset) then "Saya sudah membaca ringkasan dan laporan sementara. Saya mengerti bahwa tutup buku ini bersifat permanen dan transaksi Oktober 2026 tidak dapat dikoreksi lagi."
    3. Button row: disabled "Tutup buku Oktober 2026" (Disabled style: 52, `garis` field, `tinta2` text), text "Kembali".
    4. Caption 13 `tinta3`: "Tombol aktif setelah pernyataan di atas dicentang."
  - **"Tercatat di Riwayat" view** (no banner):
    1. Record card (padding 14/16, gap 6): row "BKU-2026-0146" (see Notes: mono 16/600) | badge "Dibukukan" (tinta). 14 `tinta2` "Dibukukan pada 16/11/2026 11.42". 13 `tinta3` "Oleh Yanti Sumual, Operator · menjalankan jabatan kosong Bendahara Jemaat".
    2. Record card: row "Rekonsiliasi Kas · Oktober 2026" 16/700 | badge "Sudah dipastikan" (laut). 13 `tinta3` "Oleh Yanti Sumual, Operator · menjalankan jabatan kosong Bendahara Jemaat · 16/11/2026 10.20".
    3. Caption 13 `tinta3`: "Riwayat menyimpan orang yang bertindak dan jabatan yang dijalankannya. Bendahara baru nanti tidak mewarisi tindakan ini sebagai miliknya."
  - **"Wajib pemeriksa kedua" view**:
    1. Vacancy banner.
    2. Refusal 15 px: "**Tidak dapat dilakukan: Bukukan.**" (700 `bata`) then "Wajib pemeriksa kedua aktif, dan draf ini Anda catat sendiri." (`tinta`).
    3. Caption 13 `tinta3`: "Menjalankan jabatan kosong tidak menggantikan orang kedua. Yang dapat memeriksa: Pnt. Jefry Wowor."
    4. Button row: secondary "Biarkan sebagai draf" (340, left).
  - **"Jabatan sudah terisi" view** (no banner):
    1. Notice box (terpilih): 1.5 `tinta` line, `permukaan`, radius 12, padding 12/14, 14: "**Bendahara Jemaat sudah terisi:** Deitje Kawengian, wewenang aktif sejak 18/11/2026."
    2. Refusal 15 px: "**Tidak dapat dilakukan: Bukukan.**" then "Anda tidak lagi menjalankan jabatan Bendahara Jemaat."
    3. Caption 13 `tinta3`: "Draf yang Anda siapkan tetap ada dan dapat dibukukan oleh Bendahara Jemaat."
    4. Link styled as a secondary button: "Kembali ke Beranda" (min-height 48, radius 14, 1.5 `tinta` line, `permukaan`, `tinta` 700, centred, 340 wide, left).
- **Components** PitaJabatanKosong (banner), LencanaStatus ("Dibukukan" `tinta` field, "Sudah dipastikan" `laut` field, the bata count badge "4"), Penolakan (two refusals), Tombol (secondary, text, disabled), TombolBersyarat look for the disabled close button, GarisStatus (ditutup banner, dibukukan cards, terpilih notice). Pattern: checkbox row with full-row target.
- **Internal views and states** Initial state `{ k: null }`; view = `k ?? keadaan`: "Pita di setiap layar", "Konfirmasi tutup buku", "Tercatat di Riwayat", "Wajib pemeriksa kedua", "Jabatan sudah terisi". Inside "Konfirmasi tutup buku": the checkbox's own tick (`centang`, false on entry, reset whenever the view is entered); it changes only the box.
- **Tweaks** `keadaan` (enum "Pita di setiap layar" · "Konfirmasi tutup buku" · "Tercatat di Riwayat" · "Wajib pemeriksa kedua" · "Jabatan sudah terisi", default "Pita di setiap layar") — Keadaan panel. Each option shows the view of the same name. Global `jabatanKosong`: no effect (this board shows the vacancy itself).
- **Interactions**
  - "Lihat konfirmasi tutup buku" → `go1`: confirmation view.
  - Checkbox row → toggles the tick. The button "Tutup buku Oktober 2026" stays disabled whether ticked or not (the source sets `disabled` statically and has no handler); pressing it does nothing.
  - "Kembali" (confirmation) → `go0`: banner view.
  - "Biarkan sebagai draf" → `go0`: banner view.
  - "Kembali ke Beranda" → up link to `/BerandaJabatan`.
  - Every view change jumps the scroll to top.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`. The close is not performed here, so there is no `segelTahan`/`segel`.
- **Links out** Header back arrow ("Kembali ke Beranda") → `/BerandaJabatan`, up link. "Kembali ke Beranda" (Jabatan sudah terisi) → `/BerandaJabatan`, up link. **Inbound** AlurJabatanKosong, Bendahara, PetaPlatform, plus the BerandaJabatan "Operator" row "3 data Kolom 2 menunggu verifikasi" (built in the logic class, not in the manifest).
- **Mock data** Operator Yanti Sumual runs Bendahara Jemaat since 16/11/2026 08.15. Saldo buku semua Kas/Bank Rp38.415.000 (the shared Beranda figure). Perlu tindakan 4: "Oktober 2026 belum ditutup · 2 draf belum dibukukan". BKU-2026-0146 Dibukukan 16/11/2026 11.42. Rekonsiliasi Kas · Oktober 2026 Sudah dipastikan 16/11/2026 10.20. Second checker Pnt. Jefry Wowor. New Bendahara Jemaat Deitje Kawengian, authority active from 18/11/2026. Share with WebJabatanKosong.
- **Prototype-only** The subtitle starts "Contoh keadaan:" but is a header subtitle, not one of the four listed devices; keep it on screen. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/JabatanKosong` → dark `tinta` banner "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15." with the second sentence in `diTinta2`; card "Saldo buku semua Kas/Bank" with mono "Rp38.415.000"; card "Perlu tindakan" with `bata` badge "4".
  2. Press "Lihat konfirmasi tutup buku" → "Tutup buku bulan Oktober 2026?" with "Yanti Sumual, Operator" in bold; the button "Tutup buku Oktober 2026" is `garis`/`tinta2`.
  3. Tap the checkbox text → the box is ticked; the button stays disabled and pressing it changes nothing; "Kembali" returns to the banner view.
  4. Panel `keadaan` = "Tercatat di Riwayat" → no banner; card "BKU-2026-0146" (mono) with `tinta`-filled badge "Dibukukan"; card "Rekonsiliasi Kas · Oktober 2026" with `laut` badge "Sudah dipastikan".
  5. Panel "Wajib pemeriksa kedua" → banner, then "Tidak dapat dilakukan: Bukukan." in `bata` and "Yang dapat memeriksa: Pnt. Jefry Wowor."; "Biarkan sebagai draf" → banner view.
  6. Panel "Jabatan sudah terisi" → no banner; boxed "Bendahara Jemaat sudah terisi: Deitje Kawengian, wewenang aktif sejak 18/11/2026."; "Kembali ke Beranda" → `/BerandaJabatan`.
  7. Header back arrow → `/BerandaJabatan`.
- **Notes** The close button is disabled for good on the board, although the caption says it activates once ticked. The board wins: the tick works, the button stays disabled. The real hold-to-close with the Operator named is TutupBuku with `jabatanKosong` on. Flag to design. The disabled button has no "Tidak dapat dilakukan: …" sentence in full contrast, only the 13 `tinta3` caption; keep the board and give the button a semantics hint "Tombol aktif setelah pernyataan di atas dicentang.". On the phone PitaJabatanKosong is meant to be one line above every screen; this board shows the full banner inside the content to illustrate it. Keep the board. "Tercatat di Riwayat" has no banner even though the post is still being run; keep (it shows records). "BKU-2026-0146" is sans 700 on the board; CONVENTIONS says every No. Bukti is mono, so render it mono 16/600 (Plex Mono has no 700). The checkbox look is the shared `KotakCentang` primitive at 24×24 (components.md); the board's input has no `accent-color`, so its checked look comes from the primitive, not the board. The strip shows without a `jabatanKosong` tweak: running the vacant post is the subject of this board, so it follows `keadaan` (rules-checklist 4.3; W4 allows at most one; also WebJabatanKosong).

### WebJabatanKosong — Web · Menjalankan jabatan kosong
- **Source** `docs/design/handoff/canvas/boards/WebJabatanKosong.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebJabatanKosong`, no child routes · **Widget** `WebJabatanKosongScreen` in `lib/screens/p2/web_jabatan_kosong.dart`
- **Purpose** Same as JabatanKosong on the laptop (the Operator is a desk post, Q26). R04, PitaJabatanKosong rules, Penolakan.
- **Shell** Platform web side nav (WebBerandaJabatan). Active item: **Keuangan**. Footer: "**Yanti Sumual** · Operator".
- **Layout** (main column)
  1. Title block: breadcrumb "Beranda" (14/600 `laut`, underlined text link, hover `lautTua`) → `/WebBerandaJabatan`; h1 "Menjalankan jabatan kosong" (26/700); subtitle 14 `tinta2` "Contoh keadaan: jabatan Bendahara Jemaat belum ada pemegangnya".
  2. Content column, max-width 1120, gap 16. Same as JabatanKosong except:
     - **"Pita di setiap layar"**: banner (full content width), then a two-column row (wrap, gaps 20/28, top-aligned): left (flex 1.3 1 420) the balance card, right (flex 1 1 340) the "Perlu tindakan" card; then the caption; then "Lihat konfirmasi tutup buku" (340, left).
     - The other four views are the phone views at content width (banner, confirmation card, record cards, refusals, notice box, buttons at max 340, left-aligned). Card titles at 15/700 (the confirmation title stays 18/700; "BKU-2026-0146" mono 15/600, see JabatanKosong Notes); the balance figure "Rp38.415.000" is mono 15/500 (the board sets no size, so it inherits the web body 15; use `jumlah` with fontSize 15, not 16); buttons 15/700.
     - "Kembali ke Beranda" (Jabatan sudah terisi) → `/WebBerandaJabatan`.
- **Components** As JabatanKosong. Plus the platform side nav.
- **Internal views and states** As JabatanKosong, including the confirmation checkbox tick. Drawer state at 860 px and narrower.
- **Tweaks** `keadaan` (same five options, default "Pita di setiap layar") — Keadaan panel; same effects. Global `jabatanKosong`: no effect.
- **Interactions** As JabatanKosong (`go1` "Lihat konfirmasi tutup buku"; `go0` "Kembali" and "Biarkan sebagai draf"; checkbox toggles only itself; disabled close button inert). Breadcrumb and "Kembali ke Beranda" → up link to `/WebBerandaJabatan`. Side nav → `go`.
- **Motion** None. Declared and unused: `muncul`, `isi`, `titik`.
- **Links out** Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link. "Kembali ke Beranda" → `/WebBerandaJabatan`, up link. Side nav as WebBerandaJabatan (go); "Keuangan" is active and links to `/WebBeranda` (a real `go`, not a self link: the active item here is another board). **Inbound** PetaPlatform, WebAlurJabatanKosong, WebSerahTerima, plus the WebBerandaJabatan "Operator" row "3 data Kolom 2 menunggu verifikasi" (built in the logic class).
- **Mock data** Same as JabatanKosong. Footer persona Yanti Sumual, Operator.
- **Prototype-only** As JabatanKosong (subtitle kept). Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/WebJabatanKosong` at 1440 → side nav "Keuangan" filled `tinta`, footer "Yanti Sumual · Operator"; the dark banner spans the content width; the balance and "Perlu tindakan" cards sit side by side.
  2. Press "Lihat konfirmasi tutup buku" → confirmation card; ticking the box leaves "Tutup buku Oktober 2026" disabled.
  3. Panel "Wajib pemeriksa kedua" → refusal "Tidak dapat dilakukan: Bukukan." and "Biarkan sebagai draf"; pressing it shows the banner view.
  4. Panel "Jabatan sudah terisi" → "Kembali ke Beranda" opens `/WebBerandaJabatan`.
  5. Side nav "Keuangan" → `/WebBeranda`.
  6. At 700 wide → top bar with "Menu"; the two cards stack.
- **Notes** Same as JabatanKosong (static disabled close button; "BKU-2026-0146" in mono). The active nav item is "Keuangan" because the vacancy is a Keuangan post; keep.

### Pelimpahan — 50 · Pelimpahan tugas
- **Source** `docs/design/handoff/canvas/boards/Pelimpahan.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 · interactive yes
- **Route** `/Pelimpahan`, no child routes · **Widget** `PelimpahanScreen` in `lib/screens/p2/pelimpahan.dart`
- **Purpose** Pimpinan Jemaat yang berwenang and post holders (here Pnt. Hendrik Rumagit), journey "Pimpinan Jemaat yang berwenang", step 2 ("Pelimpahan tugas"). Shows that a delegation of administrative tasks is dated, limited to one unit and ends by itself; that it does not transfer authority (approving worship stays with the Penatua); that every action records actor, post run, unit, on whose behalf and time; and the refusal after a delegation has ended (Penolakan).
- **Shell** Phone header with back (as BerandaJabatan): title "Pelimpahan tugas", subtitle "Bertanggal, terbatas pada satu unit, berakhir sendiri". Back → `/BerandaJabatan`.
- **Layout** (scroll area column, gap 16)
  - **"Daftar pelimpahan" view**:
    1. Delegation card (`permukaan`, 1 `garis`, radius 14, padding 14/16, column gap 6): row "Penatua Kolom 7 → Sym. Greis Mamahit" 16/700 | badge "Aktif" (laut). 14 `tinta2` "Verifikasi data Kolom 7 · 16/11/2026 sampai 30/11/2026". 13 `tinta3` "Dilimpahkan oleh Pnt. Hendrik Rumagit. Tidak memindahkan wewenang persetujuan ibadah."
    2. Delegation card: row "Sekretaris Jemaat → Yanti Sumual" | badge "Berakhir" (abu). 14 `tinta2` "Menyusun draf pengumuman · 03/11/2026 sampai 10/11/2026". 13 `tinta3` "Berakhir sendiri pada tanggalnya."
    3. Button row: primary "Buat pelimpahan" (340, left).
  - **"Buat pelimpahan" view**:
    1. Form card (as Penugasan: column gap 12, read-only fields with label 14 `tinta2`, field min-height 48, radius 12, 1 `garisTegas`, value 14 `tinta2`): "Yang melimpahkan" = "Pnt. Hendrik Rumagit · Penatua Kolom 7"; "Kepada" = "Sym. Greis Mamahit"; "Tugas" = "Verifikasi data anggota"; "Unit" = "Kolom 7"; date grid (min 300 columns, gap 16, one column here): "Mulai" = "16/11/2026"; "Sampai" = "30/11/2026" with hint 13 `tinta3` "Wajib: pelimpahan selalu punya tanggal akhir".
    2. Caption 13 `tinta3`: "Pelimpahan tugas administrasi tidak memindahkan wewenang. Setiap tindakan mencatat pelaku, jabatan yang dijalankan, unit, atas nama siapa dan waktunya."
    3. Button row: primary "Simpan pelimpahan", text "Batalkan".
  - **"Berakhir sendiri" view**:
    1. Ended box (draf): 1.5 dashed `putus` line, no field, radius 14, padding 12/14, 14: "**Pelimpahan berakhir 30/11/2026.**" (700 `tinta`) then, in `tinta2`, " Verifikasi data Kolom 7 kembali hanya kepada Pnt. Hendrik Rumagit."
    2. Refusal 15 px: "**Tidak dapat dilakukan: Verifikasi data.**" (700 `bata`) then "Pelimpahan tugas Anda untuk Kolom 7 sudah berakhir." (`tinta`).
    3. Link styled as a secondary button "Kembali ke Beranda" (48, 1.5 `tinta`, radius 14, 340, left).
- **Components** LencanaModul ("Aktif" laut, "Berakhir" abu), Penolakan, Tombol (primary, text, secondary-styled link), GarisStatus (dibukukan cards, draf ended box). Patterns: read-only field with hint, button set.
- **Internal views and states** Initial state `{ k: null }`; view = `k ?? keadaan`: "Daftar pelimpahan", "Buat pelimpahan", "Berakhir sendiri". Saving does not add a card.
- **Tweaks** `keadaan` (enum "Daftar pelimpahan" · "Buat pelimpahan" · "Berakhir sendiri", default "Daftar pelimpahan") — Keadaan panel. Each option shows the view of the same name. Global `jabatanKosong`: no effect.
- **Interactions**
  - "Buat pelimpahan" → `go1`: form view.
  - "Simpan pelimpahan" and "Batalkan" → `go0`: list view, unchanged. No validation (all fields read-only and filled).
  - "Kembali ke Beranda" → up link to `/BerandaJabatan`.
  - Every view change jumps the scroll to top.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`.
- **Links out** Header back arrow ("Kembali ke Beranda") → `/BerandaJabatan`, up link. "Kembali ke Beranda" (Berakhir sendiri) → `/BerandaJabatan`, up link. **Inbound** AlurPelimpahan, PetaPlatform.
- **Mock data** Delegation 1: Penatua Kolom 7 (Pnt. Hendrik Rumagit) → Sym. Greis Mamahit, Verifikasi data Kolom 7, 16/11/2026 to 30/11/2026, Aktif. Delegation 2: Sekretaris Jemaat → Yanti Sumual, Menyusun draf pengumuman, 03/11/2026 to 10/11/2026, Berakhir. Form: task "Verifikasi data anggota", unit Kolom 7, 16/11/2026 to 30/11/2026.
- **Prototype-only** none on the board. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/Pelimpahan` → two cards: "Penatua Kolom 7 → Sym. Greis Mamahit" with `laut` badge "Aktif", and "Sekretaris Jemaat → Yanti Sumual" with a `garis`-filled badge "Berakhir".
  2. Press "Buat pelimpahan" → form with "Yang melimpahkan" "Pnt. Hendrik Rumagit · Penatua Kolom 7", "Sampai" "30/11/2026" and hint "Wajib: pelimpahan selalu punya tanggal akhir".
  3. Press "Simpan pelimpahan" → list with the same two cards.
  4. Panel `keadaan` = "Berakhir sendiri" → dashed box "Pelimpahan berakhir 30/11/2026." and refusal "Tidak dapat dilakukan: Verifikasi data." in `bata`; "Kembali ke Beranda" → `/BerandaJabatan`.
  5. Header back arrow → `/BerandaJabatan`.
- **Notes** The arrow "→" in card titles is U+2192; copy it. Primaries are `tinta`; keep. No laptop board exists for Pelimpahan (phone-only post).

### KotakMasuk — 51 · Pemberitahuan
- **Source** `docs/design/handoff/canvas/boards/KotakMasuk.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 · interactive yes
- **Route** `/KotakMasuk`, no child routes · **Widget** `KotakMasukScreen` in `lib/screens/p2/kotak_masuk.dart`
- **Purpose** Any post holder (the data is the Sekretaris Jemaat's, Olvie Pangemanan). It is the one notification box for all active modules. Shows D28 (in-app list; push comes later, see P05), C06 (final, not provisional) and the board's own rule that push is only a supplement: "Bila pemberitahuan dorong gagal terkirim, pekerjaan di aplikasi tetap berjalan" (P05 itself is about what a push shows on the lock screen, which this board does not draw). A notification finishes by itself when its work is done. A module that is off leaves no notifications ("Hanya modul Keuangan"). A notification is not an approval and not a supporting document.
- **Shell** Phone header with back (as BerandaJabatan): title "Pemberitahuan", subtitle "Satu kotak untuk semua modul yang aktif". Back → `/BerandaJabatan`.
- **Layout** (scroll area column, gap 16)
  - **List** (`keadaan` "Ada pemberitahuan" or "Hanya modul Keuangan"):
    1. Heading "Perlu tindakan" (16/700), then row cards (BerandaJabatan row card).
    2. Heading "Untuk diketahui", then row cards.
  - **Empty** (`keadaan` "Semua sudah selesai"): box (draf) with 1.5 dashed `putus` line, no field, radius 14, padding 14/16, column gap 6: "Tidak ada yang perlu tindakan" 16/700; 14 `tinta2` "Pemberitahuan selesai sendiri ketika pekerjaannya selesai." No headings.
  - Always last: caption 13 `tinta3` "Pemberitahuan bukan persetujuan dan bukan dokumen pendukung. Bila pemberitahuan dorong gagal terkirim, pekerjaan di aplikasi tetap berjalan."
- **Components** LencanaStatus-shaped read-state badges ("Belum dibaca" `tinta` field, "Dibaca" `garis` style, "Selesai" `abu`), GarisStatus (draf empty box). Pattern: row card (BerandaJabatan).
- **Internal views and states** Initial state `{ k: null }` (no control on the board changes it). Views: list with set A, list with set K1, empty. Read state does not change when a row is opened.
- **Tweaks** `keadaan` (enum "Ada pemberitahuan" · "Semua sudah selesai" · "Hanya modul Keuangan", default "Ada pemberitahuan") — Keadaan panel. "Ada pemberitahuan": set A (Dokumen gereja, Warta Jemaat, Pengumuman items). "Semua sudah selesai": the dashed empty box only. "Hanya modul Keuangan": set K1 (only Keuangan items; the other modules are off). Global `jabatanKosong`: no effect.
- **Interactions** Row cards → push their targets. No buttons, no handlers.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`.
- **Links out** Header back arrow ("Kembali ke Beranda") → `/BerandaJabatan`, up link. Rows (push):
  - Ada pemberitahuan: "3 permohonan surat" → `/PermohonanSurat`; "Warta edisi 22/11/2026 belum diterbitkan" → `/WartaEditor`; "Pengumuman “Kerja bakti” berakhir 20/11/2026" → `/Pengumuman`; "Surat keterangan Novita Wenas diterbitkan" → `/PermohonanSurat`.
  - Hanya modul Keuangan: "2 draf belum dibukukan" → `/Main`; "Rekonsiliasi Bank BNI ··4821 belum dipastikan" → `/Main`; "2 uang muka lewat jatuh tempo" → `/Main`.
  - **Inbound** PetaPlatform only (open it from the launcher; the phone Beranda has no link to it).
- **Mock data** (title · subtitle · badge (style))
  - Set A, Perlu tindakan: "3 permohonan surat" · "Dokumen gereja · belum dibaca" · "Belum dibaca" (tinta); "Warta edisi 22/11/2026 belum diterbitkan" · "Warta Jemaat · dibaca 16/11/2026" · "Dibaca" (garis). Untuk diketahui: "Pengumuman “Kerja bakti” berakhir 20/11/2026" · "Pengumuman" · no badge; "Surat keterangan Novita Wenas diterbitkan" · "Sudah ditindaklanjuti 15/11/2026" · "Selesai" (abu).
  - Set K1, Perlu tindakan: "2 draf belum dibukukan" · "Keuangan · Oktober 2026" · "Belum dibaca" (tinta); "Rekonsiliasi Bank BNI ··4821 belum dipastikan" · "Keuangan" · "Dibaca" (garis). Untuk diketahui: "2 uang muka lewat jatuh tempo" · "Keuangan" · no badge.
  - Share both sets with WebKotakMasuk.
- **Prototype-only** none on the board. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/KotakMasuk` → "Perlu tindakan" with "3 permohonan surat" (`tinta`-filled badge "Belum dibaca") and "Warta edisi 22/11/2026 belum diterbitkan" (outlined badge "Dibaca"); "Untuk diketahui" with the "Kerja bakti" row (curly quotes) and "Selesai" on a `garis` field.
  2. Tap "3 permohonan surat" → `/PermohonanSurat` (push); Back returns.
  3. Panel `keadaan` = "Semua sudah selesai" → no headings; dashed box "Tidak ada yang perlu tindakan"; the caption stays.
  4. Panel "Hanya modul Keuangan" → three Keuangan rows; "Rekonsiliasi Bank BNI ··4821 belum dipastikan" opens `/Main`.
  5. Header back arrow → `/BerandaJabatan`.
- **Notes** Row targets are built in the logic class; the manifest lists only BerandaJabatan, and `navigation.md` 3.3 adds the row targets as computed links (so the link test checks them): wire the rows from this spec. "··4821" is U+00B7 twice; copy it, and keep it sans (it is inside a sentence). The "Hanya modul Keuangan" set shows Bendahara work while the web twin's footer persona is the Sekretaris Jemaat; that is how the board illustrates a single active module. Keep it.

### WebKotakMasuk — Web · Pemberitahuan
- **Source** `docs/design/handoff/canvas/boards/WebKotakMasuk.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebKotakMasuk`, no child routes · **Widget** `WebKotakMasukScreen` in `lib/screens/p2/web_kotak_masuk.dart`
- **Purpose** Same as KotakMasuk on the laptop: the notification box of the platform web nav. D28, C06, P05.
- **Shell** Platform web side nav (WebBerandaJabatan). Active item: **Pemberitahuan**. Footer: "**Olvie Pangemanan** · Sekretaris Jemaat".
- **Layout** (main column)
  1. Title block: breadcrumb "Beranda" (14/600 `laut`, underlined text link, hover `lautTua`) → `/WebBerandaJabatan`; h1 "Pemberitahuan" (26/700); subtitle 14 `tinta2` "Satu kotak untuk semua modul yang aktif".
  2. Content column, max-width 1120, gap 16:
     - **List** ("Ada pemberitahuan" or "Hanya modul Keuangan"): two-column row (wrap, gaps 20/28, top-aligned). Left (flex 1.3 1 420, column gap 12): heading "Perlu tindakan" (16/700) and a list box (WebBerandaJabatan list box: rows min-height 52, padding 8/18, rules between rows, title 15/600, subtitle 13 `tinta3` under it, badge right, chevron). Right (flex 1 1 340, gap 12): heading "Untuk diketahui" and its list box. Unlike WebBerandaJabatan the headings are always shown.
     - **Empty** ("Semua sudah selesai"): the dashed box of KotakMasuk at content width (title 15/700, text 14 `tinta2`).
     - Always last: the caption of KotakMasuk.
- **Components** As KotakMasuk. Plus the platform side nav and the list box pattern.
- **Internal views and states** As KotakMasuk. Initial state `{ k: null }`. Drawer state at 860 px and narrower.
- **Tweaks** `keadaan` (same three options, default "Ada pemberitahuan") — Keadaan panel; same effects. Global `jabatanKosong`: no effect.
- **Interactions** Rows → push their targets. Breadcrumb → up link. Side nav → `go`. Menu toggle at 860 px and narrower.
- **Motion** None. Declared and unused: `muncul`, `isi`, `titik`.
- **Links out** Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link. Side nav as WebBerandaJabatan (go); "Pemberitahuan" (self, active) → `/WebKotakMasuk`. Rows (push):
  - Ada pemberitahuan: "3 permohonan surat" → `/WebPermohonanSurat`; "Warta edisi 22/11/2026 belum diterbitkan" → `/WebWartaEditor`; "Pengumuman “Kerja bakti” berakhir 20/11/2026" → `/WebPengumuman`; "Surat keterangan Novita Wenas diterbitkan" → `/WebPermohonanSurat`.
  - Hanya modul Keuangan: all three rows → `/WebBeranda`.
  - **Inbound** PetaPlatform, WebAkunSaya, WebAlurDokumen, WebAlurJabatanKosong, WebAlurKeluarga, WebAlurMasuk, WebAlurPengembalian, WebAlurPulihkan, WebAlurSurat, WebAlurUnit, WebAlurWarta, WebBerandaJabatan, WebBukaNama, WebCariOrang, WebDataAnggota, WebDataGanda, WebDokumenGereja, WebImporBuku, WebJabatanKosong, WebKasUnit, WebKeadaanUmum, WebLaporanLintas, WebPengumuman, WebPenugasan, WebPermohonanSurat, WebPersembahanBernama, WebSelesaikanUnit, WebTerbitDokumen, WebWartaArsip, WebWartaEditor.
- **Mock data** Same sets as KotakMasuk. Footer persona Olvie Pangemanan, Sekretaris Jemaat.
- **Prototype-only** none on the board. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/WebKotakMasuk` at 1440 → side nav "Pemberitahuan" filled `tinta`, footer "Olvie Pangemanan · Sekretaris Jemaat"; "Perlu tindakan" box (2 rows) left, "Untuk diketahui" box (2 rows) right.
  2. Tap "Warta edisi 22/11/2026 belum diterbitkan" → `/WebWartaEditor` (push).
  3. Panel `keadaan` = "Semua sudah selesai" → only the dashed box "Tidak ada yang perlu tindakan" and the caption.
  4. Panel "Hanya modul Keuangan" → "2 draf belum dibukukan" opens `/WebBeranda`.
  5. Breadcrumb "Beranda" → `/WebBerandaJabatan`; at 700 wide the nav collapses behind "Menu" and the two boxes stack.
- **Notes** Row targets are not in the manifest's `jsLinks` (only the nav is); `navigation.md` 3.3 adds them as computed links (so the link test checks them): wire them from this spec. Same remarks as KotakMasuk.
