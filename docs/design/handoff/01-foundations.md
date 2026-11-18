# Foundations

Palakat is the church platform for a GMIM congregation, on phone and web; finance for the Bendahara Jemaat is its first module. The look is a calm ledger: the shape of a line states the status of money, colour is used sparingly, and figures always align.

Source of truth for every value in this file: `tokens/palakat-tokens.json` and `tokens/palakat_tokens.dart`. The live design system is at https://claude.ai/artifact/RafvDdtf4aeZ2VJMotqaB2.

Token names are Indonesian and are the names used in code. Do not rename them.

## Principles

1. **The line is the status.** Dashed means not yet in the balance. A solid line means posted. Dark ink means closed. Check the line language below before making a new card, badge or banner.
2. **One primary button per screen**, in `laut`. Other actions use a secondary or text button.
3. **Colour never works alone.** A status is also told apart by line shape, icon and word.
4. **Not yet known is not zero.** Anything not filled in or not yet known is written `—`.

## Language and content

- The UI is Bahasa Indonesia only, with the words of the glossary. One concept has one label on every screen: Bukukan, Draf, Dibukukan, Dibalik, Tutup buku, Kas/Bank, peruntukan, Lingkup, Mata Anggaran, No. Bukti.
- Address the user as "Anda": "Gagal disimpan. Isian Anda masih ada di layar ini."
- Captions are short and factual: "Hanya transaksi yang sudah dibukukan", "2 draf · belum masuk saldo".
- A refusal names the cause and a way forward: "Tidak dapat dilakukan: Bukukan. September 2026 sudah ditutup." followed by Pindah tanggal or Batalkan. Never offer to reopen a month.
- A disabled button is always accompanied by its reason: "Tidak dapat dilakukan: Mata Anggaran belum dipilih."
- Never use the word "Approve" for finance. Approval of a finance record happens outside the app and is recorded as the Bendahara's statement. Never draw an imitation signature. An approval made in the app (Permintaan dana and similar, rounds 2 to 5) is written "Disetujui oleh {nama}".
- A reason is required for Batalkan, Pindah tanggal, a reversal, an exception and Bebaskan. It must not be blank; there is no minimum length.
- "Untuk diketahui" items are plain: no frame and no warning colour.
- Kas/Bank, peruntukan, Lingkup and Mata Anggaran are always four separate fields. Never guess one from another, and never pre-fill them.

Words that must not be swapped:

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

### Number and date formats

| Item | Write |
| --- | --- |
| Rupiah | `Rp1.250.000` |
| Negative, never clipped to zero | `−Rp15.000` (minus sign U+2212) |
| Date in tables and inputs | `06/10/2026` |
| Date in sentences and reports | `6 Oktober 2026` |
| Time | `11.05` |
| Not yet known | `—` |

## Colour

Seventeen role tokens, each with a light and a dark value. Components name the role, never the hex value.

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `kertas` | #F3F5F1 | #0E1513 | App background |
| `permukaan` | #FFFFFF | #17201D | Cards, inputs, sheets. Also the text colour of badges and buttons on `tinta` |
| `tinta` | #13201C | #EAF0EC | Main text; solid line of a posted transaction; full field for a closed month and an official report |
| `tinta2` | #43514C | #B4C0BA | Supporting text |
| `tinta3` | #5E6A66 | #93A19B | Captions and icons |
| `putus` | #808D87 | #5F6F69 | Dashed draft line. Lines only, never text |
| `garis` | #DDE2DB | #2A3632 | Dividers and card edges; background of a disabled button and the Dibatalkan badge |
| `garisTegas` | #7F8C86 | #5C726A | Edge of inputs and unselected chips |
| `laut` | #0E5A63 | #6CC3CB | Primary action, condition met, matched |
| `lautTua` | #0A4249 | #9BDCE2 | Link when pressed; AI suggestion text |
| `lautLembut` | #E1EEED | #1B3B3A | Selected, ready, AI suggestion background |
| `bata` | #A63C1C | #F09A7A | Blockers and failures only |
| `bataLembut` | #F8E8E0 | #3B2018 | Background of a failure message |
| `diTinta` | #EAF0EC | #13201C | Sentences on a `tinta` field |
| `diTinta2` | #D5DDD8 | #43514C | Supporting text on a `tinta` field |
| `diLaut` | #FFFFFF | #0E1513 | Text and icons on a `laut` field (primary button, Sudah dipastikan badge) |
| `diBata` | #FFFFFF | #0E1513 | Text on a `bata` field (Coba lagi button, blocker counter) |

Rules of use:

- Background `kertas`; cards, inputs and sheets `permukaan`.
- Never use `putus`, `garis` or `garisTegas` for text.
- `laut` is only for the primary action and for "condition met" or "matched". Text on it is `diLaut`, not a fixed white.
- `bata` is only for blockers and failures. Text on it is `diBata`; the failure message background is `bataLembut`.
- On a `tinta` field: badges and buttons use `permukaan`, sentences `diTinta`, supporting text `diTinta2`.
- Keyboard focus: a solid 2 px `laut` outline with a 2 px offset.

### Contrast, measured

Ratios against `kertas` / `permukaan`. Text needs 4.5:1; lines and control edges need 3:1.

| Token | Light | Dark | Needs |
| --- | --- | --- | --- |
| `tinta` | 15.30 / 16.79 | 16.01 / 14.41 | 4.5 |
| `tinta2` | 7.60 / 8.33 | 9.86 / 8.88 | 4.5 |
| `tinta3` | 5.13 / 5.63 | 6.88 / 6.20 | 4.5 |
| `laut` | 7.19 / 7.89 | 9.08 / 8.17 | 4.5 |
| `bata` | 5.83 / 6.39 | 8.46 / 7.62 | 4.5 |
| `putus` | 3.15 / 3.46 | 3.49 / 3.14 | 3 |
| `garisTegas` | 3.19 / 3.50 | 3.58 / 3.23 | 3 |

`diLaut` on `laut` is 7.89 (light) and 9.08 (dark). `diBata` on `bata` is 6.39 and 8.46.

One known exception, kept as it is: the label of a disabled button (`tinta3` on `garis`) is 4.28:1 in the light theme. A disabled button always has its reason written next to it in full-contrast text.

### Dark theme

The dark theme is confirmed (18/11/2026). The canvas screens are drawn in the light theme; every component preview in the design system is tested in both. The meaning stays and only light and dark swap: "closed" becomes the lightest field, and the primary button uses the light `laut` with dark text (`diLaut`).

## Typography

Two families. The interface uses `sans` (Plus Jakarta Sans). Every money figure and every code uses `mono` (IBM Plex Mono), so digits align and codes stay readable.

| Style | Family | Size | Weight | Line height | Use |
| --- | --- | --- | --- | --- | --- |
| `judulHalaman` | sans | 26 | 700 | | Web page title |
| `judulBesar` | sans | 22 | 700 | | Title of a main phone screen |
| `judulLayar` | sans | 18 | 700 | | Screen and sheet title |
| `judulBagian` | sans | 16 | 700 | | Section title |
| `isi` | sans | 16 | 400 | 1.4 | Body on phone |
| `isiWeb` | sans | 15 | 400 | 1.45 | Body on web |
| `pendamping` | sans | 14 | 400 | | Supporting text, chips |
| `keterangan` | sans | 13 | 400 | | Captions, badges. The smallest size: no text below 13 |
| `jumlahUtama` | mono | 38 | 500 | 1.1 | Book balance on Beranda (letter spacing −1 px) |
| `jumlahIsian` | mono | 30 | 500 | | Amount input |
| `jumlah` | mono | 16 | 500 | | Amount in a row |
| `kode` | mono | 13 | 400 | | No. Bukti, No. MA |

Weight 600 is for emphasis inside a sentence; 700 for titles, badges and buttons.

## Shape, spacing and size

| Token | Value | Use |
| --- | --- | --- |
| `radius-lencana` | 6 | Status badge |
| `radius-isian` | 12 | Input, small button, selected row |
| `radius-kartu` | 14 | Card, primary button, banner |
| `radius-kartuBesar` | 16 | Large card, panel |
| `radius-lembar` | 22 | Top corners of a bottom sheet |
| `radius-chip` | 999 | Choice chip, step chip |

| Token | Value | Use |
| --- | --- | --- |
| `s4` | 4 | Smallest gap: icon to text, caption row |
| `s8` | 8 | Between chips and between buttons |
| `s12` | 12 | Inside a row; small card content |
| `s16` | 16 | Card content; phone screen edge |
| `s20` | 20 | Between sections on phone |
| `s24` | 24 | Between groups; web panel edge |
| `s40` | 40 | Between large sections on web |

| Token | Value | Use |
| --- | --- | --- |
| `size-sentuhMin` | 44 | Smallest touch target for anything that can be pressed |
| `size-tombolUtama` | 52 | Height of the primary button |
| `size-tombolKedua` | 48 | Height of a secondary button |
| `size-isian` | 48 | Height of a one-line input |

- Cards have no shadow; depth is shown with lines and fields. The only shadow is `bayanganMelayang` (`0 12px 32px rgba(0,0,0,.4)`), for a document floating over a dark backdrop (document viewer, camera).
- A selected row in a web table has a 3 px inner `laut` line on the left edge; a selected tab has it on the bottom edge.

## Line language

| Name | Line | Meaning |
| --- | --- | --- |
| `draf` | 1.5 dashed `putus` | Not in the balance: Draf, provisional report, in transit |
| `dibukukan` | 1 solid `garis` | In the balance and the reports |
| `terpilih` | 1.5 solid `tinta` | The card being worked on |
| `ditutup` | full field `tinta` | Month closed, official report |
| `usulanAI` | 1.5 dotted `laut` | AI suggestion, always with italic text |
| `hambatan` | 1.5 solid `bata` | Blocker or failure |

- Dashed: not counted yet, can still change.
- Solid: in the balance and the reports, has a No. Bukti, corrected only by a reversal.
- Dark ink: final and frozen. Used only for a closed month, an official report and a permanent statement.

## Motion

Motion is used only when the status of money changes. All motion is off when the device asks for reduced motion.

| Name | Duration | Used for |
| --- | --- | --- |
| `sentuh` | 160 ms | Touch feedback |
| `pindahLayar` | 280 ms | Screen change, bottom sheet rising |
| `kait` | 450 ms | Match: two sides meet and link; the difference counts down to Rp0 |
| `tinta` | 700 ms | Bukukan: ink sweeps the card, the No. Bukti is stamped, the balance counts to the new figure |
| `segelTahan` | 1600 ms | Tutup buku: the button is held until full |
| `segel` | 900 ms | Tutup buku: the screen darkens, the circle closes, the lock is set |

Easing: `cubic-bezier(.2, .8, .2, 1)`. Upload, save and report generation always look in progress; success is never shown before it has really happened.

## Logo and icons

- Mark: `palakat-mark.svg` (`laut` ink, for light backgrounds) and `palakat-mark-terang.svg` (for dark backgrounds), in the design system's Logo assets. Half dashed, half filled: a draft becoming a book.
- Word mark: `palakat`, all lower case, `sans` weight 700, tight letter spacing. Inside a sentence write "Palakat".
- Icons are drawn as 2 px lines with round ends on a 24 box, coloured `tinta3` or following their text. No icon library has been chosen; the icons on the screens are drawn one by one.
- No emoji. The check mark ✓ is used as a glyph on a completed step.

## Phone and web

- Phone: body style `isi`; short choices go in a bottom sheet.
- Web: body style `isiWeb`; what is a bottom sheet on the phone is a side panel on web, not a sheet covering the page.
- Web below 860 px: the side navigation becomes a drawer behind a "Menu" button and the content takes the full width.
- A laptop layout is designed only for the three desk posts: Bendahara Jemaat, Sekretaris Jemaat and Operator.
- Online only: without a connection, what is already shown stays readable and input stays on the screen; nothing is stored on the device to send later.

## Flutter mapping

Colour becomes a `ColorScheme` (one per theme), typography a `TextTheme`, shape a `ShapeBorder` on the Material 3 theme.

| Token | ColorScheme role |
| --- | --- |
| `kertas` | surface |
| `permukaan` | surfaceContainerLowest |
| `tinta` | onSurface |
| `tinta2` | onSurfaceVariant |
| `tinta3` | outline (text) |
| `putus` | outline |
| `garis` | outlineVariant |
| `laut` | primary |
| `diLaut` | onPrimary |
| `lautLembut` | primaryContainer |
| `bata` | error |
| `diBata` | onError |
| `bataLembut` | errorContainer |
| `diTinta` | onInverseSurface |

Token classes in `palakat_tokens.dart`: `PalakatColors` (light), `PalakatColorsGelap` (dark), `PalakatText`, `PalakatRadius`, `PalakatSpace`, `PalakatMotion`. Names match this file except two prefixes: `radius-lencana` is `PalakatRadius.lencana`, and `size-sentuhMin` is `PalakatSpace.sentuhMin`. In `palakat-tokens.json` the light colours are under `color` and the dark colours under `colorGelap`.

Fonts to add to `pubspec.yaml`: Plus Jakarta Sans (400, 500, 600, 700) and IBM Plex Mono (400, 500, 600).

## Platform rules every module follows

Finance is the first module. The others (Dokumen gereja, Pengumuman, Warta Jemaat, Data jemaat, Ibadah dan kegiatan, Jumlah kehadiran, Panitia, Keuangan unit, Persetujuan di aplikasi) use the same system.

- Design every module so that it may be absent. A module that is Tidak aktif leaves no trace in navigation, search, notifications or empty states.
- What a person sees follows the posts they hold. A Penatua Kolom sees only their Kolom. The Sekretaris Jemaat reads Data jemaat without changing it. The Operator sees everything, but seeing gives no authority.
- One person has one account and one Beranda for all their posts. The post is chosen per action: automatically when exactly one post has the authority, by asking when two do.
- An Operator running a vacant post is always visibly doing so, with a banner on every screen of that module.
- Filling in is not verifying: no one verifies their own submission or their own family's.
- A giver's name is recorded only when the envelope is named, and is seen only by the giver and the Bendahara Jemaat.
- Names in publications follow the member's chosen display name. Anyone Belum dikonfirmasi never appears in a publication.
- What has been published (Warta Jemaat, an announcement, a document) never changes silently; a correction is a linked revision.
- Attendance is a count only: no names, no list of who was absent, no per-person value.
- Every post signs in with a code sent to a phone number. A backup email is optional and is used only for account recovery.
- A push notification names only the module and the type of work. No names of people and no amounts of money.
