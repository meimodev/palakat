# Rules checklist

Every product and design rule the prototype's screens must obey, written as checks. Run it at the end of every milestone and in the M9 review.

Precedence: `CONVENTIONS.md` wins over this file. Where one board deliberately breaks a rule, the board is built as drawn and the exception is listed in section 4 and in that board's spec notes (`docs/build/screens/`); those exceptions are the allowlist of the automated checks below. A new exception found while building goes into section 4 first.

Source abbreviations: **01**–**05** = `docs/design/handoff/01-foundations.md` … `05-master-file-update.md`; **brief** = `docs/design/ui-ux-design-brief-v2.md`; **plan** = `docs/design/platform-module-plan-2026-11-17.md`; **CONV** = `docs/build/CONVENTIONS.md`. Decision refs (D01, P05, Q31, C04, RD04, EC07) are rows of `04-decision-log.md`; DL refs are rows of the plan's section 2.

## 0. How to run the checks

### Greps (G)

Run from `prototype/`. A check passes when it prints nothing, except the hits its comment allows. `lib/screens/sistem` (the maps and the decision sheet) quotes every term on purpose and is left out of the word checks.

```sh
FIN="lib/screens/ponsel lib/screens/web lib/screens/lanjut lib/screens/lengkap lib/screens/a4 lib/screens/a4s lib/screens/a4t"
PLAT="lib/screens/p2 lib/screens/p3 lib/screens/p4 lib/screens/p5"
SCR="$FIN $PLAT"

# G01 (L01) English words inside UI strings. Inspect any hit.
grep -rnE "['\"][^'\"]*\b(Save|Cancel|Delete|Submit|Edit|Error|Loading|Settings|Download|Upload)\b" $SCR lib/widgets lib/shell
# G02 (L02, P03) words the glossary bans. Allowed: "administrator sistem" in masuk.dart and web_masuk.dart, "Pratinjau halaman 1" in web_warta_editor.dart (section 4).
grep -rnwE "Approve|Dashboard|Notifikasi|Inbox|Posting|Finalisasi|Tutup bulan|Kasbon|Panjar|Nominal|Suspense|Kas opname|Terklasifikasi|Pemasukan|Konsep|Berhasil|Admin|Lowong|Penyetuju|Ganti jabatan|Absensi|Daftar hadir|Pratinjau|[Aa]dministrator" $SCR \
  | grep -vE "/(web_)?masuk\.dart:.*[Aa]dministrator sistem|/web_warta_editor\.dart:.*Pratinjau halaman"
# G03 (L03) the user is "Anda"
grep -rnwiE "kamu|engkau" $SCR
# G04 (L04) Terverifikasi is for a dokumen pendukung only
grep -rnw "Terverifikasi" $PLAT
# G05 (L05) Kejadian is the finance close incident; Peristiwa is a member's life event
grep -rnwi "kejadian" $PLAT
grep -rnwi "peristiwa" $FIN
# G06 (L06) Izin is consent to use personal data; never "Persetujuan" for it
grep -rnwi "izin" $FIN
grep -rniE "persetujuan (penggunaan )?data( pribadi)?" lib
# G07 (L07) Revisi is a correction to a publication; Versi is the Mata Anggaran list
grep -rnwi "revisi" $FIN
grep -rnwi "versi" lib/screens/p3
# G08 (L08, L09) no "Approve" anywhere; no Setujui or Disetujui on a finance screen
grep -rni "approv" lib
grep -rnwE "Setujui|Disetujui" $FIN
# G09 (F01, F02) rupiah: no comma thousands, no space, no decimals, no hyphen-minus
grep -rnE "Rp ?[0-9]{1,3},[0-9]{3}|Rp [0-9]|Rp[0-9.]+,[0-9]{2}|['\"]-Rp|'-' *\+ *rp\(" lib
# G10 (F03) ISO dates only inside IDs and file names
grep -rnE "\b20[0-9]{2}-[01][0-9]-[0-3][0-9]\b" lib/screens | grep -vE "SNP-20[0-9]{2}-|ekspor-"
# G11 (F04) time is 11.05, never 11:05
grep -rnE "['\" ][0-2][0-9]:[0-5][0-9]\b" lib/screens
# G12 (C01, C05) colours from tokens only; three illustration colours, all in lib/theme
grep -rnE "Color\(0x|Color\.from(ARGB|RGBO)|Colors\.[a-z]" lib --exclude-dir=theme | grep -vE "Colors\.transparent"
# G13 (C12) no card shadow or elevation. Allowed: the one widget that draws bayanganMelayang (floating document over a dark backdrop)
grep -rnE "BoxShadow|elevation: *[1-9]" lib/screens lib/widgets
# G14 (X01) no text below 13 px
grep -rnE "fontSize: *([0-9]|1[0-2])(\.[0-9]+)?\b" lib
# G15 (X11) no emoji; U+2713 ✓ is allowed on a completed step
python3 - <<'PY'
import pathlib, re
pat = re.compile('[\U0001F000-\U0001FAFF☀-⛿✀-✒✔-➿️]')
for p in pathlib.Path('lib').rglob('*.dart'):
    for i, l in enumerate(p.read_text(encoding='utf-8').splitlines(), 1):
        if pat.search(l): print(f'{p}:{i}: {l.strip()}')
PY
# G16 (A05) never reopen a month, never "contact the admin". "tidak dibuka lagi" (Pengembalian boards) states the rule and is allowed.
grep -rniE "buka(kan)? (kembali|lagi)|dibuka (kembali|lagi)|membuka (kembali|lagi)|hubungi admin" lib/screens | grep -v "tidak dibuka lagi"
# G17 (A03) TombolBersyarat never disables itself with a null handler
grep -rn "onPressed: null" lib/widgets | grep -i bersyarat
# G18 (I02) no "Lainnya" Mata Anggaran row in the seed data
grep -rnE "['\"]Lainnya['\"]" lib/mock
# G19 (Z01) prototype-device strings outside AlatPrototipe. Inspect any hit: a string inside an `AlatPrototipe(alat: [...])` list is allowed (that list may span lines). W7 is the binding check.
# "Contoh: …" placeholders and format hints ("Contoh: 081234567890") and AlurMasuk's `s.kode == '123456'` are app copy and logic, not devices: not grepped.
grep -rnE "['\"](Dilihat sebagai|Di prototipe ini|Ulangi contoh)" lib/screens | grep -v AlatPrototipe
# G20 (P20) nothing is stored on the device
grep -nE "shared_preferences|hive|sqflite|path_provider" pubspec.yaml
```

### Widget sweeps (W), in `test/rules_test.dart`

Each sweep pumps every board route at its frame size, in the light theme, at the default tweaks and then with each tweak option in turn (the same loop as `test/routes_test.dart`). Section 4's "As drawn" boards are allowlisted per rule.

| ID | What it asserts |
| --- | --- |
| W1 | Text sweep over every `RenderParagraph`: font size ≥ 13; colour is not `putus`, `garis` or `garisTegas`; no text reads `null`, `undefined`, `NaN` or `Instance of`; a text whose whole content is an amount (`^[−+]?Rp[0-9.]+$`), a No. Bukti (`^[A-Z]{3}-\d{4}-\d{4}$`), a No. MA (`^\d+(\.\d{2})+$`) or a report ID (`^SNP-`) uses IBM Plex Mono. |
| W2 | `await expectLater(tester, meetsGuideline(iOSTapTargetGuideline))`: every pressable target at least 44 × 44. |
| W3 | At most one primary-variant `Tombol` or `TombolBersyarat` is visible on the topmost surface (a bottom sheet or a web side panel is its own surface). |
| W4 | For each of the 69 boards whose `data-props` has `jabatanKosong`: switch on → exactly one `PitaJabatanKosong`; switch off → none. A board without the tweak never shows it. |
| W5 | `/Main/catat`, `/WebCatat`, `/TabCatat`, `/KasusBaru`, `/WebKasusBaru`, `/AlihPeruntukan`, `/WebAlihPeruntukan` open with nothing selected in Kas/Bank, peruntukan, Lingkup and Mata Anggaran; selecting one leaves the others unselected. |
| W6 | With `MediaQuery.disableAnimations` (and again with the panel's reduce-motion switch): fill /Main/catat, open /Main/periksa, press Bukukan: it shows the final balance and the No. Bukti after one `pump()`; on `/Memuat` (Sedang memuat) `tester.hasRunningAnimations` is false. |
| W7 | For every board and tweak: no `Text` under the `<Stem>Screen` subtree (`PanelKeadaan` excluded) starts with "Dilihat sebagai", "Di prototipe ini" or "Ulangi contoh", and no `Tekan` or `Tombol` there has a label (its `label` or a `Text` inside it) starting with "Contoh:". The accepted code 123456 is covered: the boards show it only in "Di prototipe ini kode yang benar adalah 123456." |

Component tests (M1, `test/widgets/`) are named in the rows below as "Component test".

## 1. Checklist

### 1.1 Language and glossary

| ID | Rule | Source | Check |
| --- | --- | --- | --- |
| L01 | The UI is Bahasa Indonesia only; every string is copied verbatim from its board, including `·`, `—`, `−`, `··4821` and curly quotes. | 01 Language; 04 Q2; CONV Behaviour | G01; manual diff of each screen against its board in M9 |
| L02 | One concept has one label on every screen, exactly as in section 3 (Bukukan, Draf, Dibukukan, Dibalik, Tutup buku, Kas/Bank, peruntukan, Lingkup, Mata Anggaran, No. Bukti …). | 01 Language; brief Glossary; 04 C05 | G02; manual against section 3 |
| L03 | The user is addressed as "Anda" ("Gagal disimpan. Isian Anda masih ada di layar ini."). | 01 Language | G03 |
| L04 | "Diverifikasi" is for member data, "Terverifikasi" for a supporting document; never swapped. | 01 Words not to swap; 05 §6 | G04; manual: `/Peristiwa` (Diverifikasi) shows "Diverifikasi oleh Pnt. Hendrik Rumagit, 17/11/2026"; `/Dokumen` verify shows "Terverifikasi oleh Meiske L." |
| L05 | "Peristiwa" is a member's life event, "Kejadian" an incident after month close; never swapped. | 01 Words not to swap; 05 §5, §6 | G05 |
| L06 | "Izin" is consent to use personal data ("Izin penggunaan data pribadi"), "Persetujuan" an approval; never swapped. The phone permission "Izinkan pemberitahuan" (AkunSaya) is neither and stays. | 01 Words not to swap; 05 §6 | G06 |
| L07 | "Revisi" is a linked correction to something published, "Versi" a version of the Mata Anggaran list; never swapped. | 01 Words not to swap; 05 §6 | G07 |
| L08 | The word "Approve" never appears; review is never approval, and no finance control says Setujui or Disetujui. | 01 Language; 02 LencanaStatus; brief Hard rules | G08 |
| L09 | "Disetujui oleh {nama}" is used only for an approval made in the app (Permintaan dana, Ibadah, Warta, Panitia) and names the signed-in approver. A finance approval is the Bendahara's recorded statement ("Persetujuan di luar aplikasi", "Catat persetujuan"); an old declaration is never relabelled as an in-app approval. | 01 Language; 05 §6; brief Hard rules | G08; manual: `/PermintaanDana` (Disetujui) "Disetujui oleh Pdt. Lidya Rondonuwu"; `/Persetujuan` shows "Catat persetujuan" |
| L10 | Captions are short and factual ("Hanya transaksi yang sudah dibukukan", "2 draf · belum masuk saldo"). | 01 Language | Manual in M9 |

### 1.2 Formats

| ID | Rule | Source | Check |
| --- | --- | --- | --- |
| F01 | Rupiah is `Rp1.250.000`: no space, dot thousands, whole rupiah, no decimals; every figure goes through `rp()`. | 01 Formats; 04 Q3 | `test/format_test.dart` `rp(1250000) == 'Rp1.250.000'`; G09 |
| F02 | A negative uses the minus sign U+2212 (`−Rp15.000`) and is never clipped to zero; a reversal prints as a negative in the original's column. | 01 Formats; 02 IsianJumlah; 04 D12 | `rp(-15000) == '−Rp15.000'`; G09; manual `/A4F14` annex 6 shows "−Rp750.000" under Pengeluaran |
| F03 | Dates are `06/10/2026` in tables and inputs, `6 Oktober 2026` in sentences and reports. Raw import values beside interpreted ones (`02/11/26` on Impor) are allowed. | 01 Formats; brief States (Import) | `format_test.dart`; G10 |
| F04 | Time is `11.05`. | 01 Formats | `format_test.dart`; G11 |
| F05 | Not yet known is `—`; missing is never shown as 0, blank or a placeholder value. Counted zero reads "Dihitung: Rp0"; not counted reads "Belum dihitung" (bank: "Rekening koran belum diisi"). | 01 Principles 4; brief Hard rules; brief Glossary | W1 (no null/NaN); manual `/HitungKas` (contohTerisi off) and `/RekonIsi` |
| F06 | Every money figure and every code (No. Bukti, No. MA, IDs) is IBM Plex Mono so digits align. | 01 Typography; CONV Theme | W1 |
| F07 | Amount input: whole rupiah, thousands dots while typing, numeric keyboard; empty shows a grey "0" hint, not a value. | 02 IsianJumlah | Component test; `/Main/catat` type "0012a500" → "12.500" |
| F08 | Dates are typed as hh/bb/tttt and checked while typing. | 02 TombolBersyarat | Component test of the date formatter |
| F09 | Codes and Mata Anggaran names appear exactly as stored, always with the tree name (Pendapatan or Belanja); codes and voucher numbers lay out at variable width. | 02 PemilihMataAnggaran; brief Hard rules | Manual `/Main/catat` Mata Anggaran search "fotokopi" |

### 1.3 Colour and line

| ID | Rule | Source | Check |
| --- | --- | --- | --- |
| C01 | Colours come from tokens via `context.warna`; no hex outside `lib/theme/` except the illustration colours #86B5B8 and #FBFAF6. | 01 Colour; CONV Theme | G12 |
| C02 | Background `kertas`; cards, inputs and sheets `permukaan`. | 01 Colour | Manual |
| C03 | `putus`, `garis` and `garisTegas` are never text. | 01 Colour | W1 |
| C04 | `laut` marks only the primary action and "condition met / matched" (Tersimpan, Sudah dipastikan, Cocok), plus the link, selection-line, AI-line and focus-ring uses the boards draw; never decoration. | 01 Colour, Principles 2 | Manual in M9 |
| C05 | Text and icons on a `laut` field are `diLaut`; on a `bata` field `diBata`; never a fixed white. | 01 Colour | G12; component tests: primary `Tombol`, LencanaStatus "Sudah dipastikan", "Coba lagi" button, blocker counter |
| C06 | `bata` is only for blockers and failures; a failure message sits on `bataLembut`. | 01 Colour; 02 ButirPerhatian | Manual; exceptions in section 4 |
| C07 | On a `tinta` field: badges and buttons `permukaan`, sentences `diTinta`, supporting text `diTinta2`. | 01 Colour | Component tests: PitaLaporan (official), PitaJabatanKosong, LencanaStatus Dibukukan |
| C08 | Colour never works alone: every status also differs by line shape, icon or word. | 01 Principles 3; 02 LencanaStatus | Component test: each LencanaStatus has its own word and line |
| C09 | Line language: draf 1.5 dashed `putus`; dibukukan 1 solid `garis`; terpilih 1.5 solid `tinta`; ditutup full `tinta` field; usulanAI 1.5 dotted `laut` with italic text; hambatan 1.5 solid `bata`. | 01 Line language; 02 GarisStatus | Component test of the shared painter and each card |
| C10 | Dashed = not counted and can change ("Belum masuk saldo"); solid = counted, has a No. Bukti, corrected only by a reversal; dark ink only for a closed month, an official report and a permanent statement. | 01 Line language | Manual `/Main` Transaksi: Draf row dashed with "Belum masuk saldo", booked row solid |
| C11 | The dotted `laut` line with italic `lautTua` text belongs only to AI; a suggestion never looks like a draft or a posted value. | 02 KartuUsulanAI; 04 D31 | Manual `/BantuanAI`, `/AIMataAnggaran` |
| C12 | Cards have no shadow; the only shadow is `bayanganMelayang` for a document floating over a dark backdrop. | 01 Shape | G13 |
| C13 | A selected web table row has a 3 px inner `laut` line on the left; a selected tab has it on the bottom. | 01 Shape | Manual `/WebLihatTransaksi`, `/WebTransaksi` |
| C14 | Dark theme: meaning stays, light and dark swap; a closed month becomes the lightest block; primary button is light `laut` with `diLaut` text. Dark must be legible; it is not compared with boards. | 01 Dark theme; 04 D32, C03; CONV Theme | Manual: panel Gelap on `/TutupBuku`, `/Main` |

### 1.4 Type, size, motion and accessibility

| ID | Rule | Source | Check |
| --- | --- | --- | --- |
| X01 | No text below 13 px (the boards' twelve 12 px places become 13). | 01 Typography; CONV Off-token sizes | G14; W1 |
| X02 | Weight 600 is emphasis inside a sentence; 700 for titles, badges and buttons. | 01 Typography | Component tests (badge, button weight 700) |
| X03 | Every pressable target is at least 44 × 44; the label of a checkbox or radio is part of its target. | 01 Shape; CONV Accessibility | W2 |
| X04 | Primary button 52 high, secondary 48, one-line input 48. | 01 Shape | Component tests |
| X05 | Keyboard focus on web is a solid 2 px `laut` outline with a 2 px offset. | 01 Colour; CONV Accessibility | Component test: Tab to a `Tombol` and a `Tautan`, find the outline |
| X06 | Under reduced motion (system or panel) every animation completes instantly and pulsing stops. | 01 Motion; 02 Gerak, Rangka; CONV Motion | W6; motion tests |
| X07 | Motion is used only when the status of money changes: sentuh 160, pindahLayar 280, kait 450, tinta 700, segelTahan 1600, segel 900 ms, curve `Cubic(0.2, 0.8, 0.2, 1)`. | 01 Motion; 02 Gerak | Motion tests of durations and curve |
| X08 | Upload, save and report generation always look in progress; success is never shown before it really happened. | 01 Motion; 02 Gerak; brief Hard rules | Manual `/Main/catat` "Lampirkan dokumen pendukung" (1.2 s), `/Memuat` (Bukukan tidak terjadi), `/Ekspor` |
| X09 | `aria-label` becomes a `Semantics` label; `role="status"`/`"alert"` become live regions; Rangka is announced "Memuat". | CONV Accessibility; 02 Rangka | Test: `/Memuat` (Sedang memuat) has a Semantics label "Memuat" |
| X10 | No emoji; the check mark ✓ only on a completed step. | 01 Logo and icons | G15 |
| X11 | Phone body `isi`, short choices in a bottom sheet (top corners 22, rises in 280 ms); web body `isiWeb`, and the same content is a side panel, never a sheet over the page. | 01 Phone and web; 02 LembarBawah | Component test of LembarBawah; manual `/Main/catat` sheet vs `/WebCatat` panel |
| X12 | Web below 860 px: the side nav becomes a drawer behind "Menu" and content takes the full width. | 01 Phone and web; CONV Form factors | `routes_test.dart` at 860 and 390; manual |

### 1.5 Actions and refusals

| ID | Rule | Source | Check |
| --- | --- | --- | --- |
| A01 | One primary button per screen, in `laut`; every other action is secondary (1.5 `tinta` line) or a text button. | 01 Principles 2; 02 Tombol | W3 |
| A02 | A disabled action always shows its reason, "Tidak dapat dilakukan: …", in full-contrast text next to it. Exempt: pager, zoom and month arrows at their limit, a button whose own label says it is in progress, and a whole screen locked by a banner that says why. | 01 Language; 02 Tombol; CONV Accessibility | Manual on the boards in section 4 (fixed list) |
| A03 | TombolBersyarat: one button, never swapped for another; looks disabled (`garis` field) while unmet; one sentence "Tidak dapat dilakukan: {tindakan}. {alasan}" directly above it with only the first unmet reason; no reason on an empty form; the condition is re-checked from the latest input when pressed, so the first press after typing works. | 02 TombolBersyarat | Component test (four cases); G17 |
| A04 | A refusal names the cause and offers a step that is really available: "Tidak dapat dilakukan: ‹tindakan›." in `bata`, the cause in `tinta`, then Pindah tanggal, Batalkan or Catat kejadian. | 01 Language; 02 Penolakan; brief Hard rules | Manual `/Draf`: "Tidak dapat dilakukan: Bukukan. September 2026 sudah ditutup, …" with Pindah tanggal and Batalkan; `/Koreksi` (bulanTransaksi Sudah ditutup) offers Catat kejadian |
| A05 | Never offer, suggest or hint at reopening a closed month, undo, an admin bypass or "contact the admin". | 01 Language; 02 Penolakan; brief Close wording notes | G16 |
| A06 | A reason is required for Batalkan, Pindah tanggal, a reversal, an exception, Bebaskan, and every other reason field (Tidak disetujui, Dikembalikan, name reveal, BIPRA correction, clearing a unit's blocker). Blank or spaces only is refused; one character is enough; no minimum length. | 01 Language; 02 IsianAlasan; 04 P12 | Manual `/Draf` Batalkan: " " → refused, "x" → allowed; same on `/Koreksi`, `/Dokumen`, `/Kesiapan`, `/BukaNama` |
| A07 | A permanent action (Tutup buku) is confirmed by pressing and holding 1600 ms until the button fills with `laut`; releasing early cancels. | 01 Motion; 02 Tombol; 04 D08 | Component test of the hold button; manual `/TutupBuku` |
| A08 | Offer only what the record's state allows: Hapus draf only on an empty draft; a Dibukukan record never edits amount, date, Kas/Bank, peruntukan, Lingkup or Mata Anggaran; "Koreksi dengan pembalikan" only while every affected month is Belum ditutup, otherwise Catat kejadian; Pindah tanggal lists only later months that are Belum ditutup; "Buat laporan sementara" only for a month Belum ditutup, "Lihat laporan resmi" for Sudah ditutup. | brief States (actions by state); brief Glossary | Manual `/Draf` (drafKosong on/off), `/Koreksi` (bulanTransaksi), `/Tanggal`, `/PilihBulan` |
| A09 | "Coba lagi" never creates a duplicate transaction or a second No. Bukti. | 02 StatusSimpan; brief Platform | Manual `/Memuat` (Bukukan tidak terjadi) → Coba lagi; `/Main` gagalSimpan |
| A10 | Button labels are glossary verbs (section 3): Bukukan, Simpan sebagai draf, Ubah, Pindah tanggal, Batalkan, Hapus draf, Buat pembalikan, Koreksi dengan pembalikan, Coba lagi, Unduh PDF, Unduh Excel. | 02 Tombol; brief Glossary | G02; manual |

### 1.6 Inputs and classification

| ID | Rule | Source | Check |
| --- | --- | --- | --- |
| I01 | Kas/Bank, peruntukan, Lingkup and Mata Anggaran are always four separate fields; never pre-filled, never guessed from one another, not even by AI ("Peruntukan dan Lingkup tidak diusulkan. Pilih sendiri."). | 01 Language; 02 ChipPilihan; 04 D01; brief Hard rules | W5; manual `/BantuanAI` |
| I02 | The Mata Anggaran picker has no "Lainnya" option; group headings show but cannot be chosen ("Judul kelompok, tidak dapat dibukukan"); "Simpan tanpa Mata Anggaran" only saves a draft, on a dashed line. | 02 PemilihMataAnggaran; brief Hard rules | G18; manual `/Main/catat` search "fotokopi" |
| I03 | A split's rows must add up to Jumlah; the remainder is calculated, never typed ("Total baris harus sama dengan Jumlah", "Sisa belum dibagi"). | 02 PemilihMataAnggaran, BatangPembagian; brief Hard rules | Manual `/Bagi`, `/WebBagi` |
| I04 | ChipPilihan: selected = `tinta` field with `permukaan` text; unselected = `garisTegas` line on `permukaan`; height 44. | 02 ChipPilihan | Component test |
| I05 | Amount input: "Rp" prefix in `tinta3`, 2 px `tinta` underline. | 02 IsianJumlah | Component test |
| I06 | Every settings change says from which month it applies ("Berlaku mulai {bulan}"): the following month; a No. Bukti series change from January 2027. A Sakelar is always accompanied by that sentence. | 02 Sakelar, Patterns; 04 D23, D24 | Manual `/Lainnya`, `/UbahPengaturan`, `/KasUnit` |
| I07 | PenghitungPecahan: plus darker than minus, both 44, figures mono, product calculated. | 02 PenghitungPecahan | Component test; manual `/HitungKas` |
| I08 | Six-digit code: digits only, six long; a wrong code clears the field and shows the attempts left ("kode tidak cocok. Sisa percobaan: …"); after three, "terlalu banyak percobaan. Minta kode baru." | 02 Patterns | Manual `/AlurMasuk`, `/AkunSaya` |
| I09 | Kategori BIPRA is calculated from birth date, sex and marital status and shown with its basis; never typed. A verified Pernikahan makes both spouses Bapa and Ibu from the wedding date. | 02 Patterns; 04 P10, P11 | Manual `/PermohonanAnggota`, `/AlurAnggota`, `/AlurPeristiwa` |

### 1.7 Status, cards and banners

| ID | Rule | Source | Check |
| --- | --- | --- | --- |
| S01 | LencanaStatus shape follows the status and is not chosen freely (Draf dashed `putus`/`tinta2`; Sudah diperiksa `laut` line; Dibukukan and Sudah ditutup `tinta` field; Dibalik, Belum ditutup, Sedang dikerjakan `tinta3` line; Dibatalkan `garis` field; Sudah dipastikan `laut` field; Perlu dipastikan lagi `bata` line). | 02 LencanaStatus | Component test per status |
| S02 | Dibalik always carries the link "Dibalik oleh No. Bukti …"; the reversed record stays visible, nothing is deleted. | 02 LencanaStatus, RangkaianKoreksi; 05 §5 | Manual `/Main`, `/Koreksi`, `/LihatTransaksi` (exceptions in section 4) |
| S03 | A Hambatan has a 1.5 `bata` line, the label "HAMBATAN", and always a button to its fix. | 02 ButirPerhatian | Manual `/WebTutupBuku` (adaHambatan), `/TutupBuku`, `/Kesiapan`, `/SelesaikanUnit`, `/FormatLaporan` |
| S04 | Perlu tindakan is an ordinary card with a chevron; Untuk diketahui is plain: no frame, no warning colour. | 01 Language; 02 ButirPerhatian; brief Close wording notes | Manual `/Main`, `/WebBeranda`, `/TutupBuku` (exceptions in section 4) |
| S05 | KartuPersetujuan: not recorded = dashed with "Catat persetujuan"; recorded = solid with "Dicatat oleh …. Pernyataan Bendahara, bukan persetujuan di dalam aplikasi."; not required written plainly with its rule. No approve button, no imitation signature; printed pages carry no signatures. | 01 Language; 02 KartuPersetujuan; 04 D14 | Manual `/Persetujuan`, `/Koreksi`, `/A4F01` |
| S06 | KartuUsulanAI offers Pakai · Ubah · Abaikan; unsure reads "AI kurang yakin, mohon dicek"; a stale suggestion reads "Usulan lama — draf sudah berubah." and cannot be used; AI never posts, verifies or closes (no close button in the month assistant). | 02 KartuUsulanAI; brief AI | Manual `/BantuanAI` (keadaanAI), `/AIMataAnggaran` (AI kurang yakin), `/AIBulan` |
| S07 | KartuKasus: remainder calculated, the unaccounted part dashed, past due in bold without the blocker colour. | 02 KartuKasus | Manual `/Kewajiban` |
| S08 | PanelDokumen: uploaded is not verified; close accepts only Terverifikasi or Dikecualikan; Gagal diunggah and Ditolak in `bata` with the next step; a file refused at upload is not stored and the document stays "Wajib, belum ada"; detaching returns it to "Wajib, belum ada"; an exception names its reason and who granted it; a file opens inside the app. | 02 PanelDokumen; 04 D02, D06, D07, EC07 | Manual `/Dokumen`, `/WebDokumen`, `/LihatDokumen` |
| S09 | PitaLaporan: provisional = dashed, "Bukan laporan resmi. Angka masih dapat berubah …"; official = `tinta` field, `diTinta2` support, the ID in mono; a restricted copy is titled TERBATAS. | 02 PitaLaporan | Manual `/Laporan`, `/A4Sementara`, `/A4F01`, `/A4Terbatas` |
| S10 | PitaPeran: solid `tinta` line for a role ("Akses terbatas: Peruntukan Diakonia"); `tinta` field for a locking state ("Belum ada Bendahara aktif"); dashed for something not yet certain. | 02 PitaPeran | Manual `/Terbatas`, `/WebPengaturan` |
| S11 | StatusSimpan: Tersimpan in `laut`; Belum tersimpan and "Mencoba menyimpan lagi…" in `tinta3`; Gagal disimpan on `bataLembut` with a `bata` line and Coba lagi, the input stays; a conflict asks to load the latest ("Sudah diubah sejak Anda membukanya", "Muat versi terbaru"). | 02 StatusSimpan | Manual `/Main` (gagalSimpan), `/Draf` (konflik) |
| S12 | Rangka shows the shape without content, never a provisional figure, name or status; on failure "Gagal memuat" with "Coba lagi", input kept. | 02 Rangka | Manual `/Memuat`, `/KeadaanUmum` |
| S13 | Tahapan: done steps filled `tinta`, steps not reached dashed `putus`. BatangPembagian: unfilled part dashed `putus`, an undivided remainder in `bata`. | 02 Tahapan, BatangPembagian | Component tests |

### 1.8 Finance decisions

| ID | Rule | Source | Check |
| --- | --- | --- | --- |
| D-a | Beranda opens with one combined Saldo buku for all Kas/Bank. | 04 D03 | Manual `/Main`, `/WebBeranda` |
| D-b | A missing supporting document blocks month close, not Bukukan (also for Uang Muka, Titipan, Penggantian biaya). | 04 D02, D20 | Manual `/Main/catat` book without a document; `/TutupBuku` lists it |
| D-c | An Alih peruntukan states the basis of the decision. | 04 D04 | Manual `/AlihPeruntukan` |
| D-d | A refund reduces Belanja in the month received; a return to a donor is negative Pendapatan in the month paid out; both on the same Mata Anggaran, linked to the original voucher; closed months are not reopened. | 04 D05, RD04 | Manual `/Pengembalian`, `/AlurPengembalian` |
| D-e | Cash count is entered per denomination and may be saved with a difference. | 04 D09, D10 | Manual `/HitungKas` |
| D-f | Resolving a Kejadian does not by itself remove the blocker on the following month. | 04 D11 | Manual `/Kejadian` (menghambatBulanBerikutnya) |
| D-g | Advance settlements are not in F02; they are listed in F12. Printed pages say "format bawaan aplikasi, bukan formulir resmi GMIM". | 04 D13; 05 #19 | Manual `/A4F02c`, `/A4F01` |
| D-h | The open cases list is "Uang yang masih berjalan"; spending beyond an advance is refused and recorded as Penggantian biaya; a claim is checked before it is paid. | 04 D15, D16, D17 | Manual `/Kewajiban` |
| D-i | An Uang Muka asks for no Mata Anggaran until accounted for; a Titipan asks for no peruntukan and offers only rows allowed for Titipan. | 04 D18, D19 | Manual `/KasusBaru` tabs |
| D-j | A handover is started by the active Bendahara; there are never two active Bendahara. | 04 D21 | Manual `/Bendahara` |
| D-k | Restricted access still sees Mata Anggaran and Lingkup; a TERBATAS copy holds F02, F03, F05, F07 and F12 only. | 04 D26, D27 | Manual `/Terbatas`, `/WebPaketLaporan`, `/A4Terbatas` |
| D-l | Phone: five bottom tabs with Catat in the centre (Beranda · Transaksi · Catat · Bulan · Lainnya). Web: a side bar. | 04 D29 | Manual `/Main` |
| D-m | Reports read on the phone as stacked cards. | 04 D30 | Manual `/Laporan` |
| D-n | A total in a search answer is computed from the records shown. | 04 D33 | Manual `/Cari` |
| D-o | Import words: Ditampung, Lolos pengecekan, Sudah diimpor, Tidak diimpor; nothing counts before Sudah diimpor. | 04 D34; brief States | Manual `/Impor` |
| D-p | Offline, input stays on the screen; nothing is stored to send later. | 04 D35; 01 Phone and web | G20; manual `/Sambungan` |
| D-q | F02 on the web screen puts Kas/Bank as a second line under Uraian; the printed A4 page and Excel keep it as a column. | 04 C01 | Manual `/WebPaketLaporan` F02 vs `/A4F02a`, `/WebExcel` |
| D-r | Report lines and titles as drawn: "Uang Muka diberikan", "Pengembalian sisa uang muka", F13 "Sentralisasi / Penyaluran", F14 "Lampiran Laporan Bulanan", an empty annex "Nihil". | 04 C04; 05 §5 | Manual `/A4F01`, `/A4F14`, `/Laporan` |
| D-s | Close confirmation names the coverage, the checks and the permanent consequence ("Tutup buku bersifat permanen."), is gated by its checkbox, then the hold; attention items are listed plainly. | brief Close wording; 04 D08 | Manual `/TutupBuku`, `/WebTutupBuku` |

### 1.9 Platform rules and decisions

| ID | Rule | Source | Check |
| --- | --- | --- | --- |
| P01 | A module that is Tidak aktif leaves no trace in navigation, search, notifications or empty states; its badge exists only on the Modul screen; turning it off deletes nothing (Hanya baca). | 01 Platform rules; 02 LencanaModul; plan §8 | Manual `/Modul` (Menonaktifkan Warta Jemaat), `/KeadaanUmum` (Modul tidak aktif), `/KotakMasuk` (Hanya modul Keuangan), `/LaporanLintas` (Modul tidak aktif), `/WartaEditor` (Hanya Pengumuman yang aktif) |
| P02 | Views follow posts: a Penatua Kolom sees only their Kolom; the Sekretaris Jemaat reads Data jemaat without changing it; the Operator sees everything but seeing gives no authority. | 01 Platform rules; plan DL23–DL25 | Manual `/DataAnggota` (each keadaan), `/CariOrang` |
| P03 | One person, one account, one combined Beranda; no post switcher. Items name their post ("Sebagai {jabatan} · …"); with exactly one post able to act the app says "Anda bertindak sebagai {jabatan}" before confirming; with two it asks; the post used is recorded and fixed. | 01 Platform rules; 02 BertindakSebagai; 04 Q31 | G02 ("Ganti jabatan"); manual `/BerandaJabatan` (Jabatan dipilih otomatis, Dua jabatan dapat bertindak) |
| P04 | An Operator running a vacant post is always visibly doing so: PitaJabatanKosong (`tinta` field, `permukaan` text, `diTinta2` support) above every screen of the module, one line on the phone ("Menjalankan jabatan kosong · Bendahara Jemaat"), a full banner on web; every action is recorded "oleh {nama}, Operator · menjalankan jabatan kosong {jabatan}"; the close confirmation names the Operator; it does not replace the second checker. | 01 Platform rules; 02 PitaJabatanKosong | W4; manual `/JabatanKosong` (each keadaan), `/TutupBuku` with the switch on, `/Main` Verifikasi reads "Terverifikasi (oleh Yanti Sumual, Operator)" |
| P05 | Filling in is not verifying: no one verifies their own or their family's submission; a requester never approves their own request; no one assigns a post to themselves. | 01 Platform rules; 04 P09; brief Hard rules | Manual `/PermintaanDana` (Menyetujui permintaan sendiri) → "Tidak dapat dilakukan: Setujui. permintaan ini Anda ajukan sendiri …"; `/Penugasan` (Menugaskan diri sendiri) |
| P06 | A giver's name is recorded only for a named envelope and is seen only by the giver and the Bendahara Jemaat. | 01 Platform rules; 04 Q32 | Manual `/PersembahanSaya` (each keadaan), `/PersembahanBernama` |
| P07 | Names in publications follow the member's Tampilan nama (seven forms); a more private personal choice beats the family default; "Masih mudah dikenali" warns when the form still points to one person; Belum dikonfirmasi never appears; only the Sekretaris Jemaat shows a name as an exception, with a reason and a Riwayat record; a change applies to the next publication. | 01 Platform rules; 02 TampilanNama; plan DL5, DL8 | Manual `/TampilanNama`, `/AlurNama`, `/BukaNama`, `/WartaEditor`, `/A4Warta`, `/DataAnggota` (Belum dikonfirmasi) |
| P08 | What has been published never changes silently; a correction is a linked revision (Ralat). After Sudah diperiksa or Disetujui a Warta edition is locked; changing it returns it to Draf. | 01 Platform rules; 04 P18 | Manual `/AlurDokumen`, `/Pengumuman` (Ralat sebagai revisi), `/WartaEditor` |
| P09 | Attendance is a count only: no names, no absence list, no per-person value; only Ditetapkan counts reach the Warta. | 01 Platform rules; brief Hard rules | Manual `/Kehadiran`, `/AlurIbadah`, `/WebWartaEditor` ("412 orang: Subuh 96 · Pagi 231 · Malam 85") |
| P10 | Every post signs in with a six-digit code sent to a phone number by WhatsApp or SMS, no password; a backup email is optional and used only for recovery; until verified a person sees only Warta Jemaat and announcements for all members. | 01 Platform rules; 04 P01–P03, P06 | Manual `/Masuk`, `/AlurMasuk` |
| P11 | A new phone number is proven by a code sent to it; the app never says whether a number belongs to another account. | 04 P04 | Manual `/AkunSaya` |
| P12 | Recovery without email needs the Operator and the Penatua Kolom, two different people; the Operator cannot recover their own account; the requester sees "menunggu {jabatan}" until the second person acts. | 02 Patterns; 04 P07 | Manual `/AlurPulihkan`, `/Pemulihan` |
| P13 | A push notification reads "{modul}: {jumlah} {jenis pekerjaan}" ("Data jemaat: 1 data menunggu verifikasi"): no person's name, family name, Kolom or amount; push settings only on the phone (on a laptop Akun saya says they are set from the phone); a refused permission is said once. | 01 Platform rules; 02 PratinjauLayarKunci; 04 P05 | Component test PratinjauLayarKunci: body matches `^[A-Z][\w ]+: \d+ \D+$`, has no "Rp" and no seed person name; manual `/AkunSaya`, `/WebAkunSaya` |
| P14 | Pemberitahuan is an in-app list grouped Perlu tindakan / Untuk diketahui; push is only a supplement. | 04 D28, C06 | Manual `/Pemberitahuan`, `/KotakMasuk` |
| P15 | A post assignment with a future start date is refused. | 04 P08 | Manual `/Penugasan` (Catat penugasan) |
| P16 | In-app approvals: the approver per unit type is set once by the Pimpinan Jemaat yang berwenang (the unit's head or the Ketua Jemaat); an approved Permintaan dana is booked as an Uang Muka; approval is not payment. | 04 P09, P13 | Manual `/PemberiPersetujuan`, `/PermintaanDana`, `/AlurDana` |
| P17 | A unit Kas/Bank is set by the Bendahara Jemaat from the next month, reads "Dikelola oleh {unit}", and cannot go to a unit without a unit treasurer; a unit treasurer's refusal names the rule and offers "Kirim ke Bendahara Jemaat untuk dibukukan"; the Bendahara Jemaat clears a unit's blocker only with a reason, and the unit is told. | 04 P14; plan DL26, DL32, DL33 | Manual `/KasUnit`, `/KeuanganUnit`, `/AlurUnit`, `/SelesaikanUnit` |
| P18 | Forming a Panitia needs a written decision in Dokumen gereja and three different people as Ketua, Sekretaris and Bendahara; it starts in Perencanaan and cannot book until Aktif; it closes once advances are accounted for and leftover money returned. | 04 P15, P16 | Manual `/AlurPanitiaBaru`, `/Panitia`, `/AlurPanitia` |
| P19 | Warta Jemaat is one fixed A4 template; the Sekretaris Jemaat picks published announcements per edition, with a caution for one not addressed to all members. | 04 Q27, P17 | Manual `/WartaEditor`, `/A4Warta` |
| P20 | Consent is an explicit tick on "Izin penggunaan data pribadi" with the text's version; the screens say the default text is not reviewed by counsel; withdrawing shows what is deleted and what stays; a paper deletion request is confirmed by the Penatua Kolom. | 04 Q28, P19; plan DL13 | Manual `/PermohonanAnggota` (Izin belum diberikan), `/CabutIzin`, `/AlurNama` |

### 1.10 Prototype-only devices

| ID | Rule | Source | Check |
| --- | --- | --- | --- |
| Z01 | "Dilihat sebagai" chips, buttons starting with "Contoh:", the accepted code 123456, "Di prototipe ini: …" hints and the "Ulangi contoh" replay button live only in the Keadaan panel, labelled; never inside a screen. | 03 Prototype devices; CONV Prototype chrome | W7; G19 |
| Z02 | The panel shows every board's tweaks with the exact names, options and defaults of its `data-props`; the screen shows only what the app would show. | CONV Prototype chrome | `test/registry_test.dart` |

## 2. Where the handoff (18/11/2026) supersedes brief v2

Build the handoff column.

| Topic | Brief v2 says | Handoff says | Ref |
| --- | --- | --- | --- |
| Status of decisions | Every open question and glossary row "Proposed"; a "Still open" glossary list | All decided 18/11/2026; every glossary term final; nothing marked "usulan" | 04 intro, C05; 05 §1, §5 |
| UI language | Not decided (Platform table); Indonesian proposed | Bahasa Indonesia only | 01 Language; 05 #2 |
| Rupiah format | Separator undecided; the brief itself writes "Rp150,000" | `Rp1.250.000`, minus U+2212 | 01 Formats; 05 #3 |
| Fund and Scope on a one-fund church | Pre-fill and collapse them (Q8) | Kas/Bank, peruntukan and Lingkup are never pre-filled | 04 D01; 05 #8 |
| AI on capture | AI may pre-fill a draft from a receipt or a sentence | Nothing is filled until Pakai; AI never proposes peruntukan or Lingkup | 04 D01, D31; boards BantuanAI, AIFoto |
| Close confirmation | Primary button disabled until the box is ticked; maybe also type the month | Checkbox, then hold the button 1600 ms until full | 04 D08; 05 #9 |
| No current Treasurer (Q12) | Read-only for everyone with a banner | Also: an Operator may run the vacant post, visibly, every action recorded | 04 R04; 05 #12; 02 PitaJabatanKosong |
| Several posts (Q31, round 2 "Home by post", glossary "Ganti jabatan") | One home per post; a post switcher in the header | One combined Beranda, no switcher; the post is chosen per action, asked when two can act | 04 Q31; 02 BertindakSebagai |
| Laptop layouts (Q26) | Secretary and Operators also on a laptop; others on phones | A laptop layout only for Bendahara Jemaat, Sekretaris Jemaat and Operator; other posts' screens open on web without one | 04 Q26 |
| Sign-in | Not specified (round-1 decision D25 was an email code) | Six-digit code to a phone number for every post; email only as optional recovery backup | 04 D25, P01, P06; 05 §2 |
| Notifications (Q16) | V1: Needs Attention only, no inbox, no push | In-app Pemberitahuan list is final in round 1; push in round 5 with the lock-screen rule "{modul}: {jumlah} {jenis pekerjaan}"; push settings only on the phone | 04 D28, C06, P05 |
| BIPRA (Q29, DL28, glossary) | Age limits are a church setting; labels "Pria/Kaum Bapa · Wanita/Kaum Ibu · Pemuda · Remaja · Anak" | Fixed from GMIM provisions, not editable; labels Anak, Remaja, Pemuda, Bapa, Ibu; marital status decides even under 18 | 04 Q29, P10, P11; 05 §3 |
| In-app approvals (DL29) | Defaults Ketua Jemaat / unit Ketua; below a church threshold no approval is needed | Approver per unit type set once by the Pimpinan Jemaat yang berwenang; no amount limits | 04 P09 |
| Warta format (Q27) | Ask the church; design team proposes a default | One fixed A4 template, PDF and in-app; no church-editable layout | 04 Q27 |
| Consent text (Q28) | Written by the church with counsel | Palakat ships one versioned default text, not reviewed by counsel, and the screens say so | 04 Q28, §7 |
| Member's own giving (Q32) | Not in round 4 | Only gifts recorded in their name (named envelope), visible to the giver and the Bendahara Jemaat | 04 Q32 |
| Evidence file rejected (EC07) | REJECTED file provisional, stays in history | A file refused at upload is not stored; the document stays "Wajib, belum ada" | 04 EC07; 02 PanelDokumen |
| Covering a vacant post | "Plt." still open | "Jabatan kosong", "Menjalankan jabatan kosong" | 05 §6 |
| Dark theme | Not covered | Confirmed; dark tokens in `PalakatColorsGelap` | 04 C03 |

## 3. Glossary

The labels below are final (04 C05). "Never" lists words a screen must not use for that concept; they feed G02.

### 3.1 One concept, one label

| Concept | Use | Never |
| --- | --- | --- |
| Account | Kas/Bank ("Kas/Bank: Bank BNI"); two accounts at one bank "Bank BNI ··4821" | Rekening (only "No. rekening" and "Rekening koran" may use it), Tempat uang |
| Fund | peruntukan ("Diambil dari peruntukan", "Masuk ke peruntukan") | Dana, Kantong, Pos, Pundi |
| Scope | Lingkup: Jemaat, Kolom, BIPRA, Komisi, Panitia | Cakupan, Unit pelayanan, Wadah |
| Classification | Mata Anggaran; "No. MA" is the only short form | Akun, Kategori, pagu, sisa anggaran, budget words |
| Unclassified | Mata Anggaran belum dipilih; action "Simpan tanpa Mata Anggaran" | Lainnya, Suspense |
| Split | Bagi ke beberapa Mata Anggaran | Pecah, Alokasi |
| Mata Anggaran list version | Versi Mata Anggaran; Terbitkan / Diterbitkan; Berlaku mulai {bulan} | Revisi, Edisi, Disahkan |
| Voucher number | No. Bukti (made by the system); an imported one "No. bukti asal" | Nomor voucher, bare "Bukti" |
| Evidence | Dokumen pendukung | Bukti, Lampiran, Berkas |
| Transaction states | Draf · Sudah diperiksa · Dibukukan ("Dibukukan pada {waktu}") · Dibalik ("Dibalik oleh No. Bukti …") · Dibatalkan | Konsep, Disetujui, Final, Dihapus |
| Not counted yet | Belum masuk saldo | Belum dihitung, Tidak resmi |
| Post a transaction | Bukukan; solo step "Periksa dan bukukan"; review "Tandai sudah diperiksa" | Setujui, Simpan, Posting, Kirim, Approve |
| Other actions | Simpan sebagai draf · Ubah · Pindah tanggal · Batalkan · Hapus draf (empty draft only) · Buat pembalikan · Koreksi dengan pembalikan · Coba lagi · Unduh PDF · Unduh Excel · Lihat transaksi · Nonaktifkan | Edit, Hapus (other than Hapus draf), Ulangi as retry, Download |
| Correction records | Pembalikan (own No. Bukti); Transaksi koreksi ("Koreksi dari No. Bukti …") | Penyesuaian, Pengganti |
| Reason | Alasan | Keterangan, Catatan |
| History | Riwayat | Log, Jejak audit |
| Save state | Tersimpan · Belum tersimpan · Mencoba menyimpan lagi… · Gagal disimpan · Gagal diunggah · File gagal dibuat | Berhasil, Error, bare Gagal |
| Conflict | Sudah diubah sejak Anda membukanya | Sudah diubah orang lain |
| Refusal | Tidak dapat dilakukan: {…} | |
| Month close | Tutup buku; Belum ditutup · Sudah ditutup; "Tutup buku bersifat permanen"; Konfirmasi tutup buku | Tutup bulan, Kunci, Final as a badge |
| Attention levels | Hambatan · Perlu tindakan · Untuk diketahui | Peringatan, Masalah, Error |
| Close incident | Kejadian setelah tutup buku (short: Kejadian); "Catat kejadian" | Temuan, Insiden, Peristiwa |
| External approval | Persetujuan di luar aplikasi; Catat persetujuan; Persetujuan belum dicatat / sudah dicatat; Pemberi persetujuan | Setujui, Disetujui, Approve |
| Evidence states | Wajib, belum ada · Sedang diunggah… · Diunggah, belum diverifikasi · Terlampir · Terverifikasi (oleh {nama}) · Dikecualikan · Tidak diperlukan (aturan: {aturan}) · Dilepas · Ditolak | Lengkap, Sah, Kosong |
| Exception | Catat pengecualian; Pemberi pengecualian | Terima, Bebaskan (that is the readiness waiver) |
| Reconciliation | Rekonsiliasi · Saldo buku · Rekening koran · Mutasi bank · Cocok · Sebagian cocok · Belum cocok · Cocokkan · Lepaskan · Selisih belum dijelaskan · Saldo pembanding · Dalam perjalanan · Sedang dikerjakan · Sudah dipastikan (Pastikan rekonsiliasi) · Perlu dipastikan lagi | "Sudah direkonsiliasi" while a difference remains |
| Cash count | Hitung kas · Hasil hitung kas · Dihitung: Rp0 · Belum dihitung | Kas opname, Rp0 for missing |
| Money in and out | Pendapatan · Belanja · Pindah antar Kas/Bank · Alih peruntukan · Surplus/Defisit bulan ini | Pemasukan, Pengeluaran (except the report column and F09), bare Transfer |
| Cases | Uang Muka · Titipan · Penggantian biaya; list "Uang yang masih berjalan"; Sisa belum dipertanggungjawabkan · Sisa belum disalurkan; Lewat jatuh tempo | Panjar, Kasbon, Dana titipan |
| Reports | Laporan sementara · Laporan resmi · Sedang disiapkan · Siap diunduh · Paket Laporan Bulanan GMIM · TERBATAS | Pratinjau (for a report), Cetak, Laporan final |
| Import | Ditampung · Lolos pengecekan · Sudah diimpor · Tidak diimpor | Valid, Ditolak |
| AI | Bantuan AI · Usulan AI · Pakai · Ubah · Abaikan · AI kurang yakin, mohon dicek · Usulan lama — draf sudah berubah · AI sedang tidak tersedia | Terima, Tolak, Asisten pintar |
| Posts | Jabatan; Bendahara Jemaat · Sekretaris Jemaat · Operator · Penatua Kolom {n} · Pemeriksa kedua · Petugas verifikasi · Pimpinan Jemaat yang berwenang · Pengelola teknis · Ketua Jemaat · Anggota jemaat | Admin, Peran, Role |
| Home, inbox, modules | Beranda · Pemberitahuan · Modul: Aktif · Tidak aktif · Hanya baca | Dashboard, Notifikasi, Inbox |
| Restricted view | Akses terbatas: Peruntukan {nama} | Tamu |
| Settings | Berlaku mulai {bulan} · Wajib pemeriksa kedua · Tanggal mulai pencatatan · Saldo awal pencatatan · Serah terima Bendahara · Belum ada Bendahara aktif · Menunggu verifikasi wewenang | Efektif, Onboarding |

### 3.2 Words that must not be swapped (01)

| Use | For | Not |
| --- | --- | --- |
| Diverifikasi | member data | Terverifikasi |
| Terverifikasi | a supporting document | Diverifikasi |
| Peristiwa | a member's life event | Kejadian |
| Kejadian | an incident after month close | Peristiwa |
| Izin | consent to use personal data | Persetujuan |
| Persetujuan | an approval | Izin |
| Revisi | a correction to something published | Versi |
| Versi | a version of the Mata Anggaran list | Revisi |

### 3.3 Labels made final in 05 §5

Peruntukan · Dibalik (always with "Dibalik oleh No. Bukti …") · "Tutup buku bersifat permanen" · Kejadian setelah tutup buku · Lingkup (Komisi is its fifth type) · Tanpa nama · QRIS; Lembar penghitungan persembahan · F13 Sentralisasi / Penyaluran · F14 Lampiran Laporan Bulanan, empty annex "Nihil" · F01 lines "Uang Muka diberikan", "Pengembalian sisa uang muka", "Dana Transit masuk", "Dana Transit keluar", "Posisi dan kesimpulan rekonsiliasi" · Pimpinan Jemaat yang berwenang · surat penunjukan (and "SK BPMJ" for the decision forming a Panitia) · Mutasi bank.

### 3.4 Terms added in 05 §6

| Term | Meaning |
| --- | --- |
| Pelayan dan pengurus | Audience label for items meant for officers only |
| Jabatan kosong | A post with no holder; an Operator may run it visibly |
| Pelimpahan tugas | A temporary delegation with an end date |
| Diverifikasi | Member data confirmed by the Penatua Kolom |
| Belum dikonfirmasi | A person imported from the paper book whose family has not confirmed; never in a publication |
| Peristiwa | A member's life event: Baptisan, Sidi, Pernikahan, Kematian, Pindah Kolom |
| Izin penggunaan data pribadi | Consent to use personal data |
| Tampilan nama | A member's chosen form for their name in publications |
| Kategori BIPRA | Anak, Remaja, Pemuda, Bapa, Ibu; calculated (P10) |
| Status pernikahan | "Belum pernah menikah" or "Sudah menikah"; an input of Kategori BIPRA |
| Revisi | A linked correction to something already published |
| Hanya baca | A module turned off: nothing new, everything old readable |
| Disetujui oleh {nama} | An approval made inside the app (rounds 2 to 5) |
| Pemberi persetujuan | The post that approves requests from a unit type, set once per church |
| Kas/Bank unit, "Dikelola oleh {unit}" | A Kas/Bank managed by a unit and its unit treasurer |
| Email cadangan | Optional backup email, used only for account recovery |
| Akun saya | The account screen: phone number, backup email, devices, push settings, sign-out |

## 4. Board breaches

Found by grepping all 199 boards on 19/11/2026. Policy: a breach of an accessibility rule that CONVENTIONS makes binding (text size, contrast of line tokens, touch target, disabled reason) is **fixed** in the prototype. A breach of copy, layout or colour use is built **as drawn** (the board wins on what the screen shows), listed in the board's spec notes, and allowlisted in the checks.

### 4.1 Fix in the prototype

| Board(s) | Breach | Rule | Do |
| --- | --- | --- | --- |
| `A4Warta` (1 place: the line "Diterbitkan 21/11/2026 oleh Sekretaris Jemaat · …"), `WebWartaEditor` (11 places: in the A4 page preview, the masthead "GMIM Jemaat Karunia · Minggu, 22 November 2026", the five uppercase section headings and their five body lines) | 12 px text | X01 | Set 13 px; check the WebWartaEditor page preview still fits its frame |
| `Tanggal`, `WebTanggal` | Unavailable day numbers drawn in #808D87 (`putus`) as text | C03 | Use `tinta3`; keep the transparent field and no border |
| `PetaLayar` | Board links 30 px high | X03 | Keep the drawn size; `Tautan` gives each a 44 px hit area |
| `FormatLaporan`, `WebFormatLaporan` ("Catat persetujuan format"); `WebSerahTerima` ("Kirim untuk diverifikasi"); `Masuk`, `WebMasuk` ("Kirim kode masuk", "Masuk"); `Kejadian`, `WebKejadian` ("Catat penyelesaian keuangan"); `Koreksi` ("Catat kejadian"); `Pemulihan`, `WebPemulihan` ("Kirim kode pemulihan", "Pulihkan akun"); `UbahPengaturan`, `WebUbahPengaturan` ("Simpan sebagai versi baru"); `RekonIsi`, `WebRekonIsi` ("Tambah") | Button disabled with no reason anywhere on screen | A02, A03 | Once the person has typed into that form and the condition is unmet, show one TombolBersyarat line above the button: "Tidak dapat dilakukan: {button label}. {first unmet field, named as on the board} belum diisi." Record the added sentence in the spec notes |
| `Sambungan`, `WebSambungan` | "Ulangi contoh" replay button inside the screen | Z01 | Move it to the Keadaan panel |

### 4.2 Build as drawn, log

| Board(s) | Breach | Rule |
| --- | --- | --- |
| `MataAnggaran`, `WebMataAnggaran` | Rows without "Boleh untuk" are marked in `bata` ("belum diisi" text; `bata` chip edges on web) though publishing is not blocked and the phone board says "Boleh dibiarkan kosong; baris itu tidak dapat menerima titipan." This also disagrees with D22 (filled in before publishing). | C06 |
| `BerandaJabatan`, `WebBerandaJabatan`, `KotakMasuk`, `WebKotakMasuk` | "Untuk diketahui" items are framed cards (`permukaan`, 1 px `garis`, chevron) like Perlu tindakan | S04 |
| `PilihBulan`, `WebPilihBulan` (month list row BKU-2026-0105), `A4F14` (annex 6 row; its reversal is the next row) | Dibalik without "Dibalik oleh No. Bukti …" | S02 |
| `Masuk`, `WebMasuk` (setelahMasuk "Administrator sistem") | "administrator sistem" where the glossary label is "Pengelola teknis" | L02 |
| `PermintaanDana` (keadaan "Di bawah batas") | "Tidak diperlukan (aturan: di bawah batas Rp250.000 yang ditetapkan Jemaat)." contradicts P09 "No amount limits". Keep the state: the registry test needs every tweak option | P16 |
| `Persembahan`, `WebPersembahan` | The sample opens with Kas/Bank already chosen for Tunai (Kas) and Transfer bank (Bank BNI). Excluded from W5 | I01 |
| Finance boards without the `jabatanKosong` tweak where a covering Operator would still be in the module: `Lainnya`, `WebPengaturan`, `UbahPengaturan`, `WebUbahPengaturan`, `TabBeranda`, `TabTransaksi`, `TabCatat`, `WebKoreksi` (its phone pair `Koreksi` has the tweak), `Kamera`, `Sambungan`, `WebSambungan`, `Memuat`, `WebMemuat`, `AlurPengembalian`, `WebAlurPengembalian` | No PitaJabatanKosong although the rule says "every screen of that module". CONVENTIONS scopes the global switch to boards that have the tweak: do not add it | P04 |

### 4.3 Checked and allowed (do not "fix")

- "Setujui …" on `AlurBeranda`, `BerandaJabatan`, `WebBerandaJabatan`, `AlurDana`, `PermintaanDana`, `AlurWarta`, `WebAlurWarta`, `WartaEditor`, `WebWartaEditor`, `Ibadah`, and "Disetujui oleh" on `Panitia`, `PermintaanDana`, `AlurDana`, `AlurIbadah`, `Ibadah`, `WartaEditor`, `WebWartaEditor`: in-app approvals of rounds 2 to 5. No finance board uses Setujui or Disetujui; no board uses "Approve".
- "Lainnya" is the fifth phone tab and its screen, never a Mata Anggaran option.
- "versi" for the consent text ("naskah versi 1"), settings ("Simpan sebagai versi baru") and a conflict ("Muat versi terbaru"): none is a correction to a publication. No Secretariat board uses "versi"; no finance board uses "Revisi".
- "Izinkan pemberitahuan" (`AkunSaya`) is the phone's notification permission.
- "Bulan yang sudah ditutup tidak dibuka lagi." (`Pengembalian`, `WebPengembalian`, `AlurPengembalian`, `WebAlurPengembalian`) states the rule and offers no reopening.
- "hubungi Pimpinan Jemaat yang berwenang" (`KeadaanUmum`, `WebKeadaanUmum`, Tidak berwenang) names a church officer, not an admin.
- "Kirim ulang kode" (`AlurMasuk`, `WebAlurMasuk`) sends a new code and "Ulangi" (`Kamera`) retakes a photo; neither is a retry of a failed save.
- "Pratinjau halaman 1" (`WebWartaEditor`): the brief bans "pratinjau" for the report preview only.
- Dates `2026-10-01` and `2026-11-16` appear only inside IDs and file names; `02/11/26` on `Impor`, `WebImpor` is a raw import value shown beside the interpreted date.
- Checkboxes and radios of 22–24 px sit in labels at least 44 high; the unlabelled checkbox on web boards is the hidden "Menu" drawer toggle.
- Disabled with no reason line but explained otherwise: page and zoom arrows (`LihatDokumen`, `WebLihatDokumen`), month arrows (`Tanggal`, `WebTanggal`), in progress ("Mencoba menyimpan lagi…" on `Sambungan`, `WebSambungan`; `Impor`, `WebImpor` while checking), locked by a banner or caption (`Draf`, `WebDraf` konflik; `MataAnggaran`, `WebMataAnggaran` after Terbitkan; `WebPengaturan` "Belum ada Bendahara aktif").
- `laut` and #86B5B8 as bar segments (`Awal`, `Bagi`, `WebBagi`, `AlihPeruntukan`, `WebAlihPeruntukan`) are data colours in a split bar, not a status.
- No emoji (✓ only on completed steps in `Awal`, `WebAwal`; →, ↔, ⇄, ▾ are glyphs), no hyphen-minus negatives, no comma thousands, no "Rp " with a space, no colon times, no line token used as CSS text colour, and every board hex maps to a token.

### 4.4 Source conflicts (the board wins)

- #C9DAD9: CONVENTIONS allows it for `A4Warta` and `WebWartaEditor`, but no board uses it. No literal is needed.
- #86B5B8 is used on `Awal`, `Bagi` and `WebBagi` as well as `AlihPeruntukan`/`WebAlihPeruntukan`; it is the same illustration colour (G12 allows it).
- TombolBersyarat guideline: unmet label `tinta2`. The boards draw `tinta3` (#5E6A66) on `garis` in 35 places (2 use `tinta2`). Build the board's colour; the 4.28:1 exception in 01 covers it, and the reason line carries full contrast.
- PemilihMataAnggaran guideline: an unbalanced split shows "kurang Rp…" in `bata`. `Bagi` and `WebBagi` say "Sisa belum dibagi". Build the board's copy.
- `Main`'s Periksa footer swaps Bukukan for a refusal, against "never swapped" (A03); already in `screens/01-main.md` notes.
- `Main` lets the same person press Verifikasi on their own transaction (a prototype shortcut against P05); already in `screens/01-main.md` notes.
