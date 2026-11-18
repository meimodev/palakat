# Components

The 31 components of the Palakat design system, with what each is for, the Flutter widget it maps to, what the caller supplies, and the rules that are not optional. Component names are Indonesian and are the names used in the design system; keep them in code.

Each component has a live preview in both themes at https://claude.ai/artifact/RafvDdtf4aeZ2VJMotqaB2. Token names (`laut`, `putus`, `radius-kartu`) are defined in `01-foundations.md`.

There is no web component library. The previews are plain HTML that uses the tokens; the only shared script is a rupiah formatter (`Palakat.rp(-15000)` gives `−Rp15.000`).

| Group | Components |
| --- | --- |
| Foundations | GarisStatus, Gerak |
| Status | LencanaStatus, LencanaModul, Tahapan, BatangPembagian, Rangka |
| Actions | Tombol, TombolBersyarat, Penolakan |
| Inputs | IsianJumlah, IsianAlasan, ChipPilihan, PemilihMataAnggaran, Sakelar, PenghitungPecahan |
| Cards | ButirPerhatian, PanelDokumen, KartuPersetujuan, KartuUsulanAI, KartuKasus, RangkaianKoreksi |
| Banners | PitaLaporan, PitaPeran, PitaJabatanKosong, StatusSimpan |
| Containers | LembarBawah |
| Platform | BertindakSebagai, TampilanNama, RiwayatAlur, PratinjauLayarKunci |

## Foundations

### GarisStatus

The line language: the shape of a line is the status of money. This is a rule, not a widget; every card, badge and banner follows it.

| Name | Line | Meaning |
| --- | --- | --- |
| draf | 1.5 dashed `putus` | Not in the balance: Draf, provisional report, in transit |
| dibukukan | 1 solid `garis` | In the balance and the reports |
| terpilih | 1.5 solid `tinta` | The card being worked on |
| ditutup | full field `tinta` | Month closed, official report |
| usulanAI | 1.5 dotted `laut` | AI suggestion, always italic |
| hambatan | 1.5 solid `bata` | Blocker or failure |

- Dashed: not counted yet, can still change.
- Solid: counted, has a No. Bukti, corrected only by a reversal.
- Dark ink: final and frozen. Only for a closed month, an official report and a permanent statement.
- In the dark theme "closed" becomes a light field; the meaning is the same.

### Gerak

Motion, used only when the status of money changes. Flutter: `PalakatMotion`, curve `Cubic(0.2, 0.8, 0.2, 1)`.

| Name | Duration | Used for |
| --- | --- | --- |
| sentuh | 160 ms | Touch feedback |
| pindahLayar | 280 ms | Screen change, bottom sheet rising |
| kait | 450 ms | Match: two sides meet and link; the difference counts down to Rp0 |
| tinta | 700 ms | Bukukan: ink sweeps the card, the No. Bukti is stamped, the balance counts up |
| segelTahan | 1600 ms | Tutup buku: the button is held until full |
| segel | 900 ms | Tutup buku: the screen darkens, the circle closes, the lock is set |

- All motion is off when the device asks for reduced motion.
- Upload, save and report generation always look in progress. Success is never shown before it has really happened.

## Status

### LencanaStatus

A small badge naming the status of one transaction, one month or one reconciliation, in glossary words. Flutter: `Chip` or `DecoratedBox`; text `keterangan` weight 700; corner `radius-lencana`.

The caller supplies one status. The shape follows the status and is not chosen freely.

| Status | Shape |
| --- | --- |
| Draf | dashed `putus` line, `tinta2` text |
| Sudah diperiksa | solid `laut` line, `laut` text, `permukaan` background |
| Dibukukan, Sudah ditutup | `tinta` field, `permukaan` text |
| Dibalik, Belum ditutup, Sedang dikerjakan | solid `tinta3` line, `tinta2` text |
| Dibatalkan | `garis` field, `tinta2` text |
| Sudah dipastikan | `laut` field, `diLaut` text |
| Perlu dipastikan lagi | solid `bata` line, `bata` text |

- Dibalik always carries the link "Dibalik oleh No. Bukti …".
- Never make a new status by colour alone.
- There is no "Approve" status for finance records.

### LencanaModul

Badge for the state of a module and of a post. Flutter: same as LencanaStatus.

- Module: Aktif (`laut` field), Tidak aktif (dashed `putus`), Hanya baca (`tinta3` line).
- A module that is Tidak aktif does not appear in navigation, search, notifications or empty states; its badge exists only on the Modul screen.
- Turning a module off deletes nothing: the module becomes Hanya baca.
- Post: Aktif, Berakhir, Jabatan kosong (`bata` line, because work is not being done).

### Tahapan

A row of numbered chips showing which steps are done. Flutter: `Row` of `Chip`; height 30; corner `radius-chip`; text `keterangan` weight 700.

The caller supplies the ordered steps and the current one.

- Done steps are filled `tinta`; steps not yet reached use a dashed `putus` line.
- Used for Mata Anggaran versions, import, the second checker and the stages of a Panitia.

### BatangPembagian

A bar showing how much of an amount has been divided and how much is left. Flutter: `Row` + `Flexible` + `AnimatedContainer`.

The caller supplies the total and the parts. The remainder is calculated, never typed.

- The part not yet filled stays dashed `putus`.
- An undivided remainder is written in `bata`.
- Used for opening balances, splitting across Mata Anggaran and the remainder of a case.

### Rangka

The loading state for every module: the shape of the content without the content. Flutter: `Container` in `garis`; a slow pulse is allowed and stops under reduced motion.

The caller supplies a number and height of blocks close to the real content.

- Never shows a provisional figure, name or status.
- Announced to screen readers as "Memuat".
- On failure it is replaced by a "Gagal memuat" banner with "Coba lagi"; the person's input stays on the screen.
- Offline: what is already shown stays readable, and nothing is stored on the device to send later.

## Actions

### Tombol

Primary, secondary and text buttons, and the hold button for a permanent action. Flutter: `FilledButton`, `OutlinedButton`, `TextButton`; the hold button uses `GestureDetector` + `AnimatedContainer`.

The caller supplies a verb from the glossary as the label (Bukukan, Ubah, Simpan sebagai draf) and, when disabled, the reason.

- One primary button per screen: `laut`, text `diLaut`, height `size-tombolUtama`.
- Secondary: 1.5 `tinta` line on `permukaan`.
- Permanent (Tutup buku): `tinta` field, pressed and held for 1600 ms until it fills with `laut`.
- Disabled (`garis` with `tinta3` text) is always accompanied by "Tidak dapat dilakukan: …" naming the cause.
- Smallest touch target `size-sentuhMin`.

### TombolBersyarat

The primary action of a form: it looks disabled until its condition is met and always shows the reason. Flutter: `FilledButton` whose `onPressed` re-checks the condition. Do not use `onPressed: null` when the reason must be read out.

The caller supplies the label, the action and one condition computed from the inputs.

- One button only. Its look changes (`garis` field, `tinta2` text) while the condition is unmet; it is never swapped for a different button.
- The condition is checked again when pressed, from the latest input. The first press after typing must work.
- While unmet, one sentence "Tidak dapat dilakukan: {tindakan}. {alasan}" sits directly above the button, showing only the first unmet reason.
- The reason appears only after the person starts filling in; an empty form does not open with a refusal.
- Dates are typed as hh/bb/tttt and checked while typing.

### Penolakan

A refusal sentence that names the cause and offers a step that is really available. Flutter: `Text` + `FilledButton` or `OutlinedButton`.

The caller supplies the refused action, the cause and the available ways forward.

- Form: "Tidak dapat dilakukan: ‹tindakan›." in `bata`, then the cause in `tinta`.
- Every refusal offers an available step (Pindah tanggal, Batalkan).
- Never mentions reopening a month: a closed month is not reopened.

## Inputs

### IsianJumlah

Whole-rupiah amount input with thousands separators while typing. Flutter: `TextField` + `TextInputFormatter`, numeric keyboard; text style `jumlahIsian`.

The caller supplies the label ("Jumlah (Rp)") and the value.

- "Rp" prefix in `tinta3`; 2 px `tinta` underline.
- Empty shows a grey "0" as a hint, not a value. Not filled in is not zero.
- A negative is written −Rp15.000 and is never clipped to zero.

### IsianAlasan

A two-line text input for a reason that is required before certain actions. Flutter: `TextField` (maxLines 2).

The caller supplies a sample reason as the hint and the action button it guards.

- Required for Batalkan, Pindah tanggal, a reversal, an exception and Bebaskan.
- Its button is disabled until the reason is filled in. Blank is refused; there is no minimum length.

### ChipPilihan

Chips for choosing one of a few options that are all visible. Flutter: `ChoiceChip`; height `size-sentuhMin`; corner `radius-chip`.

The caller supplies the field label and the options.

- Selected: `tinta` field, `permukaan` text. Unselected: `garisTegas` line on `permukaan`.
- Kas/Bank, peruntukan, Lingkup and Mata Anggaran are always four separate fields. None is guessed from another.

### PemilihMataAnggaran

A searchable Mata Anggaran list with group headings that cannot be chosen, and a split across several rows. Flutter: `SearchAnchor` + `ListTile`.

The caller supplies the published Mata Anggaran version, its tree (Pendapatan or Belanja) and the transaction amount when split.

- Number and name appear exactly as stored, always with the tree name.
- Group headings are shown but cannot be posted to.
- There is no "Lainnya" option.
- "Simpan tanpa Mata Anggaran" only saves a draft; its line is dashed.
- When split, the rows must add up to Jumlah; the difference is written "kurang Rp…" in `bata`.

### Sakelar

An on/off switch for a setting. Flutter: `Switch`.

The caller supplies the label and a sentence saying from which month the change applies.

- On: `tinta` field. Off: `tinta` line on `permukaan`.
- Always accompanied by the sentence naming the month the change takes effect.

### PenghitungPecahan

A cash-count row: denomination, minus and plus buttons, number of notes, and the product. Flutter: `IconButton` + `Text`.

The caller supplies the denomination and the count. The product is calculated.

- The plus button is darker than the minus button, because counting almost always adds.
- Both buttons are `size-sentuhMin`.
- Figures use the mono family so digits align.

## Cards

### ButirPerhatian

Three levels of attention: Hambatan, Perlu tindakan and Untuk diketahui. Flutter: `Card` + `ListTile`.

The caller supplies the level, a title, one line of explanation and, for a Hambatan, the button to its fix.

- Hambatan: 1.5 `bata` line, label "HAMBATAN", always carries a button to the fix.
- Perlu tindakan: an ordinary card with a chevron.
- Untuk diketahui is plain: no frame, no warning colour.
- `bata` is used for nothing other than blockers and failures.

### PanelDokumen

The supporting documents of one transaction, with the status of each. Flutter: `ListTile` + `LinearProgressIndicator`.

The caller supplies the documents with status, file name, who and when.

- Uploaded is not verified. Month close accepts only Terverifikasi or Dikecualikan.
- Gagal diunggah and Ditolak use `bata` and always offer the next step.
- A file refused at upload is not stored; the person uploads another file (EC07).
- An exception always names the reason and who granted it.

### KartuPersetujuan

A card recording an approval that happened outside the app. Flutter: `Card`.

The caller supplies who approved and their post, the date, the means (for example meeting minutes) and who recorded it.

- Not recorded yet: dashed line with the button "Catat persetujuan".
- Recorded: solid line with "Dicatat oleh …. Pernyataan Bendahara, bukan persetujuan di dalam aplikasi."
- Not required is written plainly with its rule.
- No "Approve" button and no imitation signature.

### KartuUsulanAI

A card for an AI suggestion, which is no value at all until the Bendahara uses it. Flutter: `Card` + `DottedBorder` (package).

The caller supplies the suggestion, the confidence level and three actions: Pakai, Ubah, Abaikan.

- The dotted `laut` line and italic `lautTua` text belong only to AI: a suggestion never looks like a draft or a posted value.
- When the AI is unsure, write "AI kurang yakin, mohon dicek".

### KartuKasus

A card for one case of Uang Muka, Titipan or Penggantian biaya, with the remainder still running. Flutter: `Card` + `LinearProgressIndicator`.

The caller supplies the case name, the party, the opening amount, the amount accounted for and the due date.

- The remainder is always calculated, never typed.
- The part not yet accounted for stays dashed.
- Past due is shown in bold, without the blocker colour.

### RangkaianKoreksi

Three linked cards: the reversed transaction, its reversal, and the correcting transaction. Flutter: `Column` + `Card` + `VerticalDivider`.

The caller supplies the No. Bukti of the three transactions and their statuses.

- A vertical 2 px `tinta` line means "linked to".
- The reversed transaction stays visible with a Dibalik badge; nothing is deleted.
- Also used for refunds and for the Bendahara handover.

## Banners

### PitaLaporan

The banner above a report saying whether it is provisional or official. Flutter: `MaterialBanner`.

The caller supplies the report type and, for an official report, the close time and the copy ID.

- Provisional: dashed line, "Bukan laporan resmi. Angka masih dapat berubah."
- Official: `tinta` field, `permukaan` text, `diTinta2` supporting text, the ID in mono.
- A restricted copy is titled TERBATAS.

### PitaPeran

A banner naming the user's role or a state that locks the screen. Flutter: `MaterialBanner`.

The caller supplies one short sentence.

- Solid `tinta` line for a role (Akses terbatas: Peruntukan Diakonia).
- `tinta` field for a locking state (Belum ada Bendahara aktif).
- Dashed for something not yet certain.

### PitaJabatanKosong

A banner that is always shown while an Operator runs a post that has no holder. Flutter: `MaterialBanner`, pinned above every screen of that module.

The caller supplies the post, the unit, the start date and the Operator's name.

- `tinta` field, `permukaan` text, `diTinta2` supporting text: a locking state, like "Belum ada Bendahara aktif".
- On the phone it is one line above every screen; on web a full banner above the content.
- Shown on every screen while the post is being run, and gone as soon as a holder is assigned.
- Every action records it in Riwayat: "oleh {nama}, Operator · menjalankan jabatan kosong {jabatan}".
- When closing a month, the confirmation names the Operator as the one closing.
- Running a vacant post does not replace the second person when "Wajib pemeriksa kedua" is on.

### StatusSimpan

Text and a banner that are always honest about whether input has been saved. Flutter: `Text` + `MaterialBanner`.

The caller supplies the current save state.

- Tersimpan in `laut`; Belum tersimpan and "Mencoba menyimpan lagi…" in `tinta3`.
- Gagal disimpan: `bataLembut` background, `bata` line, with Coba lagi. The input stays on the screen.
- Coba lagi never creates a duplicate transaction or a second No. Bukti.
- If someone else changed the data, ask to load the latest version before continuing.

## Containers

### LembarBawah

A sheet that rises from the bottom of the phone screen for a short choice or input. Flutter: `showModalBottomSheet`; top corners `radius-lembar`; rises in 280 ms.

The caller supplies a title (`judulLayar`) and the content.

- On web the same content is a side panel, not a sheet covering the page.

## Platform

### BertindakSebagai

How one person with several posts works on one Beranda, without switching posts. Flutter: `Card` + `Chip`; the post choice uses `OutlinedButton`.

The caller supplies the person's active posts and, for each action, which post has the authority.

- One person, one account, one Beranda. Work from all their posts appears together; there is no post switcher.
- Each item names its post on the second line: "Sebagai {jabatan} · …". A person with one post does not need the label.
- When exactly one post has the authority, the app uses it and says so before the action is confirmed: "Anda bertindak sebagai {jabatan}".
- When two posts have the authority, the app asks. It never guesses.
- The post used is recorded in Riwayat and cannot be changed afterwards.
- Another post never opens a way to approve or verify one's own submission.

### TampilanNama

A member's choice of how their name appears in publications, with a preview. Flutter: `RadioListTile` + `Card`.

The caller supplies the member's own choice, the family default and a sample sentence for the preview.

- Seven forms: Nama lengkap, Nama keluarga, Keluarga + Kolom, Kolom, BIPRA, BIPRA + Kolom, Tanpa nama.
- The member's choice must be followed in Warta Jemaat and every other publication; no format or editor can weaken it.
- A more private personal choice beats the family default.
- Warn "Masih mudah dikenali" when the chosen form still points to one person.
- Only the Sekretaris Jemaat can show a name as an exception, with a reason and a record in Riwayat.
- A change applies to the next publication; old editions do not change.

### RiwayatAlur

A short list of the actions just taken, newest first. Flutter: `ListView` inside a `Card`, no actions.

The caller supplies history rows from the same record as the Riwayat tab of that item.

- Each row has the date, what was done, who, and the post used.
- A typed reason is recorded exactly as typed.
- An action run by an Operator for a vacant post says so in its row.
- History cannot be changed or deleted from here.

### PratinjauLayarKunci

A sample of a push notification as it appears on the lock screen, used in Akun saya. Flutter: a plain `Container` as the sample; the real notification is sent through Firebase Cloud Messaging.

The caller supplies the module name and the type of work with its count.

- The content of a push notification is always "{modul}: {jumlah} {jenis pekerjaan}", for example "Data jemaat: 1 data menunggu verifikasi". No person's name, family name, Kolom or amount of money.
- The detail is visible only after the app is opened and the person is signed in.
- Push is only a supplement: the same work is always on Beranda and in Pemberitahuan.
- If the phone refuses the notification permission, the app says so once and does not ask again on every screen.
- Push settings exist only on the phone. On a laptop, Akun saya says they are set from the phone.

## Patterns that are not yet components

These recur on the screens and are specified by the boards themselves.

| Pattern | Where to see it | Rule |
| --- | --- | --- |
| Six-digit code entry | "Alur · Masuk dan menghubungkan akun", "Alur · Akun saya" | Digits only, six long. After a wrong code the field clears and the remaining attempts are shown; after three wrong codes a new code must be requested. |
| Two-person step | "Alur · Memulihkan akun anggota", "Alur · Menjadi anggota" | The requester and the confirmer are different people. The requester sees "menunggu {jabatan}"; nothing changes until the second person acts. |
| Calculated category | "Alur · Menjadi anggota" | The BIPRA category is shown as soon as birth date, sex and marital status are filled in, with the basis written under it. It is never typed. |
| Effective-from sentence | "Alur · Kas/Bank unit", settings | Every settings change states the month it takes effect. |
