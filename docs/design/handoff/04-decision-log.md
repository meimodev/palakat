# Decision log

Every decision the design rests on, in one place, as of 18 November 2026. This is the log to reference when updating the master file; `05-master-file-update.md` says which line of the brief each entry changes.

All entries are decided by the product owner. On 18/11/2026 the product owner also confirmed everything that was still marked proposed, so no entry below is a proposal.

Refs: `D01`–`D35` are the numbered design decisions on the canvas sheet "Keputusan desain". `Q25`–`Q32` are open questions of brief v2. `RD04`, `EC07` are readiness items. `P01` onward are platform decisions made while completing rounds 2 to 5.

This log supersedes the earlier standalone file `palakat-decision-log-2026-11-18.md`.

## 1. Design decisions, finance (decided 17/11/2026)

The "Board" column names the canvas board that shows the decision.

### Daily work

| Ref | Decision | Board |
| --- | --- | --- |
| D01 | Kas/Bank, peruntukan and Lingkup are never pre-filled. | 1 · Harian: catat sampai bukukan |
| D02 | A missing supporting document blocks month close, not Bukukan. | 19 · Dokumen pendukung |
| D03 | Beranda opens with one combined Saldo buku for all Kas/Bank. | 1 · Harian: catat sampai bukukan |
| D04 | An Alih peruntukan must state the basis of the decision. | 31 · Alih peruntukan |
| D05 | A refund reduces Belanja in the month the money is received. Set by RD04 on 18/11/2026; see section 4. | 25 · Pengembalian |
| D06 | Detaching a file returns the supporting document to "Wajib, belum ada". | 19 · Dokumen pendukung |
| D07 | A document file opens inside the app; it is not downloaded to the device. | 40 · Lihat file dokumen pendukung |

### Month end

| Ref | Decision | Board |
| --- | --- | --- |
| D08 | Month close is confirmed by holding the button until it is full. | 2 · Akhir bulan |
| D09 | The cash count is entered per denomination. | 5 · Hitung kas |
| D10 | A cash count may be saved even when there is a difference. | 5 · Hitung kas |
| D11 | Resolving a Kejadian does not by itself remove the blocker on the following month. | 22 · Kejadian setelah tutup buku |
| D12 | A reversal prints as a negative figure in the same column as the original transaction. | A4 · F02, halaman 2 dari 3 |
| D13 | Advance settlements are not in F02; they are listed in F12. | A4 · F02, halaman 3 dari 3 |
| D14 | Printed pages carry no signatures; only one line recording the approval of the report format. | A4 · F01 |

### Uang Muka, Titipan, Penggantian biaya

| Ref | Decision | Board |
| --- | --- | --- |
| D15 | The list is named "Uang yang masih berjalan". | 11 · Uang Muka, Titipan, Penggantian biaya |
| D16 | Spending beyond the advance is refused there and recorded as a Penggantian biaya. | 11 · Uang Muka, Titipan, Penggantian biaya |
| D17 | A claim must be checked before it can be paid. | 11 · Uang Muka, Titipan, Penggantian biaya |
| D18 | An Uang Muka does not ask for a Mata Anggaran until it is accounted for. | 37 · Kasus baru |
| D19 | A Titipan does not ask for a peruntukan; only Mata Anggaran rows allowed for Titipan can be chosen. | 37 · Kasus baru |
| D20 | All three must have a supporting document; a missing one blocks month close, not posting. | 37 · Kasus baru |

### Settings and access

| Ref | Decision | Board |
| --- | --- | --- |
| D21 | A handover is started by the Bendahara who is currently active. | 9 · Bendahara, sesi, serah terima |
| D22 | The Bendahara fills in "Boleh untuk" on each Mata Anggaran row before publishing a version. | 8 · Terbitkan Mata Anggaran |
| D23 | A settings change takes effect from the following month. | 32 · Pengaturan: tambah dan ubah |
| D24 | A change to the No. Bukti series takes effect from January 2027. | 32 · Pengaturan: tambah dan ubah |
| D25 | **Revised 18/11/2026.** Every post signs in with a code sent to a phone number (WhatsApp or SMS). Email is only a backup for recovery. The earlier decision was an email code. See P01. | 27 · Masuk dan menunggu verifikasi |
| D26 | Restricted access still sees Mata Anggaran and Lingkup. | 12 · Akses terbatas per peruntukan |
| D27 | A TERBATAS copy contains F02, F03, F05, F07 and F12. | Web · Paket Laporan F01–F14 |
| D28 | Notifications are in-app only in V1. Push arrives with round 5; see P05. | 26 · Pemberitahuan |

### Look and structure

| Ref | Decision | Board |
| --- | --- | --- |
| D29 | Phone: five bottom tabs with Catat in the centre. Web: a side bar. | Peta layar |
| D30 | Reports can be read on the phone as stacked cards. | 15 · Laporan |
| D31 | An AI suggestion has a dotted Laut edge and italic text. | 14 · Bantuan AI saat mencatat |
| D32 | In the dark theme a closed month is the lightest block. | Design system, dark theme |
| D33 | A total in a search answer is computed from the records shown. | 28 · Cari dan tanya |
| D34 | Import results use the words Ditampung, Lolos pengecekan, Sudah diimpor, Tidak diimpor. | 17 · Impor |
| D35 | Offline, input stays on the screen; nothing is stored on the device to send later. | 38 · Sambungan terputus dan sesi berakhir |

## 2. Brief v2, questions 25 to 32 (decided 18/11/2026)

The question wording here is summarised from design notes, not copied from the brief. Check each summary against the brief's own wording before pasting.

| Ref | Question | Decision |
| --- | --- | --- |
| Q25 | One app for officers and members, or two? | One app. What a person sees follows the posts they hold; "Anggota jemaat" is the base view. |
| Q26 | Which posts get a designed laptop layout? | Three desk posts only: Bendahara Jemaat, Sekretaris Jemaat, Operator. Every other post is designed for the phone; its screens still open on web without a laptop layout. |
| Q27 | Format of Warta Jemaat | One fixed A4 template published as a PDF, also readable in the app. No church-editable layout. |
| Q28 | Who writes the personal-data consent text? | Palakat ships one versioned default text. It has not been reviewed by counsel; see section 7. |
| Q29 | How are BIPRA categories set? | Fixed from GMIM's provisions, not editable by a church. See P10 for the rule. |
| Q30 | Audience label for officer-only items | "Pelayan dan pengurus". |
| Q31 | How does a person with several posts work? | One combined Beranda; no post switcher. The app picks the post per action when exactly one post has the authority, and asks when two do. The post used is recorded and cannot be changed afterwards. |
| Q32 | May a member see their own offerings? | Only gifts recorded in their name (a named envelope). Visible to the giver and the Bendahara Jemaat only. Offerings in the collection bag are never recorded per person. |

## 3. Roles and sample data (decided 18/11/2026)

| Ref | Topic | Decision |
| --- | --- | --- |
| R01 | Ketua Jemaat | The post is held by the Pendeta, who is also Ketua BPMJ and the approving "Pimpinan Jemaat yang berwenang". |
| R02 | Sample names | All names on the screens are invented, including "Pdt. Lidya Rondonuwu". |
| R03 | October sample, advance settlements | The two settlements (Rp400.000 and Rp300.000) are dated November 2026. The October pack prints Rp0 for them and attachment 2 reads "Nihil". Voucher numbers 0111 and 0124 appear as unused numbers on the voucher list. |
| R04 | Vacancy sample | The Bendahara's authority is revoked on 16/11/2026 at 08.10; the Operator runs the vacant post from 08.15. |

## 4. Readiness items (decided 18/11/2026)

| Ref | Question | Decision |
| --- | --- | --- |
| RD04 | Effect of a refund on Belanja and the reports | Money returned by a supplier reduces Belanja in the month it is received: a negative Belanja on the same Mata Anggaran, linked to the original voucher. Closed months are never reopened. |
| RD04, mirror | Money returned to a donor | Booked as negative Pendapatan on the same Mata Anggaran, in the month the money is paid out, linked to the original voucher. |
| EC07 | A file refused at upload | Refused with the reason in plain words; nothing is stored, and the supporting document stays "Wajib, belum ada". |

Two cautions carried from the earlier log: RD04 should be confirmed with the pilot treasurer against GMIM reporting practice, and EC07 was decided from the item's title only, so check it against the item's full text.

## 5. Platform decisions, rounds 2 to 5 (decided 18/11/2026)

### Account and access

| Ref | Topic | Decision |
| --- | --- | --- |
| P01 | Sign-in | Every post, including Bendahara Jemaat, signs in with a six-digit code sent to a phone number (WhatsApp or SMS). One person has one account. Replaces the email-code sign-in. |
| P02 | Linking an account to Data jemaat | The person enters name and birth date. If one record matches, the Penatua Kolom verifies it. No match leads to the membership request. |
| P03 | Unverified account | Until verified, the person sees only Warta Jemaat and announcements addressed to all members. |
| P04 | Changing a phone number | From Akun saya. The code goes to the new number, so the number is proven before it replaces the old one. Afterwards the old number no longer signs in and other devices are signed out. The app never says whether a number belongs to another account. |
| P05 | Push notifications | The lock screen shows only the module and the type of work, for example "Data jemaat: 1 data menunggu verifikasi". No names and no amounts. Push settings exist only on the phone. |
| P06 | Backup email | Optional for everyone. Added or changed from Akun saya, proven with a code sent to that email. Used only for account recovery. |
| P07 | Recovery without a backup email | The Operator requests it with the person's new number; the Penatua Kolom confirms the person's identity; only then is the new number set and old devices signed out. No one recovers an account alone, and the Operator cannot recover their own. Bendahara Jemaat is recovered through the Petugas verifikasi with BPMJ. |

### Posts and approvals

| Ref | Topic | Decision |
| --- | --- | --- |
| P08 | Post assignment | A start date in the future is refused; an assignment is recorded on or after its start date. |
| P09 | In-app approvals | The approver is set by post, once per church, by the Pimpinan Jemaat yang berwenang: one row each for Kolom, BIPRA, Komisi and Panitia, each offering that unit's own head or the Ketua Jemaat. No amount limits. A requester never approves their own request. |
| P10 | BIPRA categories | Anak: from birth until under 12. Remaja: 12 years to 17 years 364 days. Pemuda: 18 and over and never married. Bapa and Ibu: married. "Married" means ever married, so a widowed or divorced member stays Bapa or Ibu. A member who never marries stays Pemuda at any age. Marriage decides the category even under 18. The app calculates the category from birth date, sex and marital status. |
| P11 | BIPRA, consequences | Marital status is a field on the membership form, the member record and the paper-book import. A verified Pernikahan moves both spouses to Bapa and Ibu from the wedding date. The Penatua Kolom can correct one person's category with a recorded reason. |
| P12 | Reasons | Wherever a reason is required it must not be blank. There is no minimum length. |

### Money in units and committees

| Ref | Topic | Decision |
| --- | --- | --- |
| P13 | Fund request (Permintaan dana) | An approved request is always booked by the Bendahara Jemaat as an advance (Uang Muka diberikan). Approval is not payment. |
| P14 | Unit Kas/Bank | The Bendahara Jemaat sets which Kas/Bank a unit manages. The change takes effect from the next month. A unit without a unit treasurer cannot be given one. |
| P15 | Forming a Panitia | Needs a written church decision in Dokumen gereja, and three different people as Ketua, Sekretaris and Bendahara. It starts in Perencanaan and cannot book until activated. |
| P16 | Closing a Panitia | It can be closed once its advances are accounted for and leftover money is returned to the general fund. The asset handover record is attached when there are assets and does not block closing. |

### Publications and personal data

| Ref | Topic | Decision |
| --- | --- | --- |
| P17 | Warta, announcements | The Sekretaris Jemaat picks, per edition, which published announcements go in. An announcement not addressed to all members shows a caution when picked. |
| P18 | Warta, editing | After "Sudah diperiksa" or "Disetujui" the content is locked. To change it the edition returns to Draf and is reviewed again. |
| P19 | Paper request to delete data | Confirmed by the Penatua Kolom before it is carried out. |

## 6. Design choices and labels (confirmed 18/11/2026)

| Ref | Topic | Decision |
| --- | --- | --- |
| C01 | F02 Buku Kas Umum on screen | Kas/Bank is a second line under Uraian on the web screen. The printed A4 page and the Excel file keep it as its own column. |
| C02 | Border contrast | Input edges, unselected chip edges and the dashed draft line are at least 3:1 against their background in both themes. |
| C03 | Dark theme | Confirmed. Dark `garisTegas` is #5C726A. Dark values are in `palakat_tokens.dart` (`PalakatColorsGelap`) and `palakat-tokens.json` (`colorGelap`). |
| C04 | Report line names and titles | Final as drawn: the two advance lines on F01 ("Uang Muka diberikan", "Pengembalian sisa uang muka"), F14 "Lampiran Laporan Bulanan" and its attachment names, an empty attachment printed as "Nihil", and F13 "Sentralisasi / Penyaluran" in place of the source title "Sentralisasi / Settlement". |
| C05 | Glossary | Every term is final, including "Alih peruntukan". Nothing on the screens is marked "usulan" any more. |
| C06 | Pemberitahuan (round 1) | Final as an in-app list; no longer labelled provisional. |

## 7. Still open

These are not design proposals, so the confirmation of 18/11/2026 does not close them.

| Topic | State | Owner |
| --- | --- | --- |
| Consent text | The default text has not been reviewed by counsel. The screens say so. Needed before the first church outside the pilot. | Product owner, with counsel |
| Mata Anggaran rows in samples | The rows on the sample screens and files are invented. A church's own list replaces them at setup. | Church officer |

## 8. Screens added on 18/11/2026

Sign-in and account linking (phone and laptop); Akun saya with phone number change, backup email, devices and push settings (phone and laptop); recovery of a member's account by Operator and Penatua Kolom (phone and laptop); general states (loading, failed, offline, not authorised, module off, session ended); the refund flow for supplier and donor (phone and laptop); the approver table; unit Kas/Bank (phone and laptop); forming a Panitia; and the fixed A4 page of Warta Jemaat.
