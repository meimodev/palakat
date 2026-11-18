# Master file update

What to change in the master brief so it matches the design as confirmed on 18 November 2026. Each change cites the entry in `04-decision-log.md` that justifies it.

Target files, as named in the project: `docs/design/ui-ux-design-brief-v2.md` and the readiness addendum.

## Read this first

This guide was written without access to the repository. Two limits follow from that.

- **Questions 1 to 24** are quoted from brief v1 (16 November 2026), which was available. If v2 reworded or renumbered them, match by topic.
- **Questions 25 to 32** and the items RD04, EC07, DL12, DL17, DL20 and DL26 were known only from design notes. Their summaries here are not the brief's wording. Paste the decision, keep the brief's own question text.

Where the design differs from a proposed answer, the row says so under "Differs". Those rows need a rewrite of the answer, not only a status change.

## 1. Header and name

| Change | Reference |
| --- | --- |
| If the title still reads "GMIM Treasurer", note that the product name used across the design, the tokens and the design system is "Palakat". | Design system, tokens |
| Replace the sentence "every row below still reads Proposed" in the Open questions section with: "All rows were decided by the product owner on 18 November 2026. See the decision log." | Log, introduction |
| Add the two artifact links: canvas https://claude.ai/artifact/J8KD2YST4nhJUNkSFrNZuF and design system https://claude.ai/artifact/RafvDdtf4aeZ2VJMotqaB2. | README |

## 2. Open questions 1 to 24

Set Status to **Decided 18/11/2026** on every row. Keep the proposed answer as the decision unless the row below says "Differs".

| # | Topic | Decision to record | Differs from the proposal? | Reference |
| --- | --- | --- | --- | --- |
| 1 | Timeline, team, implementation designer | As proposed. The name itself is not recorded in the design files; add it to the brief. | No | |
| 2 | UI language | Bahasa Indonesia only for V1. | No | Foundations, Language |
| 3 | Rupiah, date, negatives | `Rp1.250.000`; `06/10/2026` in tables, `6 Oktober 2026` in reports; a minus sign, never clipped to zero. | No | Foundations, formats |
| 4 | Web or phone, camera | Phone first, web for laptop work; camera capture included (board 39). | No | D29 |
| 5 | Offline drafts | No. Online only; input stays on the screen and nothing is stored on the device. | No | D35 |
| 6 | Basic report | F01 Laporan Perbendaharaan Bulanan. F02 is also drawn as A4 pages. | No | A4 boards |
| 7 | Separate review step | One combined step, "Periksa dan bukukan". A separate check only when "Wajib pemeriksa kedua" is on (board 13). | No | |
| 8 | Pre-fill or hide Fund and Scope | **Kas/Bank, peruntukan and Lingkup are never pre-filled.** The proposal said to pre-fill and collapse them for a church with one Fund and one Scope. | **Yes** | D01 |
| 9 | Close wording | Accepted as drawn: "Tutup buku bersifat permanen", confirmed by holding the button until full. | No | D08 |
| 10 | Close incident | As proposed. Add: resolving a Kejadian does not by itself unblock the following month. | Adds a rule | D11 |
| 11 | Onboarding reviewer | As proposed: an internal page outside the Treasurer app ("Verifikasi wewenang (halaman internal)"). | No | |
| 12 | No current Treasurer | Read-only with the banner "Belum ada Bendahara aktif", **and** the Operator may run the vacant post, visibly, with every action recorded in the Operator's name. | **Yes**, extended by brief v2 (DL12) | PitaJabatanKosong; R04 |
| 13 | Recording template acceptance | As proposed: the Treasurer records it (board 23). | No | D14 |
| 14 | Capture before the opening is approved | As proposed. No board was checked specifically for this rule. | No | |
| 15 | Scoped preparers at launch | No. The readiness statement ("Pernyataan kesiapan per peruntukan") is drawn in round 5. | No | |
| 16 | Notifications, audit log, sessions | V1: in-app only. Push arrives in round 5 and shows only the module and type of work on the lock screen. | Adds the round-5 rule | D28, P05 |
| 17 | Needs Attention triggers | As proposed. | No | |
| 18 | Solo verification, exceptions | As proposed. | No | |
| 19 | Original GMIM forms | The default template is built; every printed page says "format bawaan aplikasi, bukan formulir resmi GMIM". | No | C04 |
| 20 | Statement lines | As proposed. Typed entry is drawn on board 30. | No | |
| 21 | Report rendering | As proposed: a generic "Sedang disiapkan" state is drawn. | No | |
| 22 | Wording for Fund-only viewers | Restricted access still sees Mata Anggaran and Lingkup (board 12). | No | D26 |
| 23 | AI confidence and wording | "AI kurang yakin, mohon dicek". No model name is shown. | No | D31 |
| 24 | Personal data | Still needs counsel. Status: **Decided to proceed with the default consent text; legal review open.** | Stays open | Log section 7 |

One decision has no question in v1 and should be added as a new row or a note under question 16:

| Topic | Decision | Reference |
| --- | --- | --- |
| Sign-in method | Every post signs in with a six-digit code sent to a phone number (WhatsApp or SMS). This **replaces** the earlier email code. A backup email is optional and used only for recovery. | D25, P01, P06 |

## 3. Open questions 25 to 32

Set Status to **Decided 18/11/2026** and paste the decision from section 2 of the log (Q25 to Q32). Two rows need more than a status:

| # | What to add | Reference |
| --- | --- | --- |
| 28 | Keep an explicit note that the default consent text has not been reviewed by counsel. | Log section 7 |
| 29 | Replace any mention of "age limits" with the full rule: the category depends on birth date, sex **and marital status**. Add the three edge cases (ever married stays Bapa or Ibu; never married stays Pemuda at any age; marriage decides even under 18). | P10, P11 |

## 4. Readiness addendum

| Item | Change | Reference |
| --- | --- | --- |
| RD04 | Status Decided. Supplier refund reduces Belanja in the month received; a return to a donor reduces Pendapatan in the month paid out. Both are negative entries on the same Mata Anggaran, linked to the original voucher. Keep the caution to confirm with the pilot treasurer. | Log section 4 |
| EC07 | Status Decided. A file refused at upload is not stored. Keep the caution that this was decided from the item's title. | Log section 4 |

## 5. Glossary, section "Still open"

Every row is now decided. Move the rows out of "Still open" and record the chosen label.

| Concept | Final label | Note |
| --- | --- | --- |
| Fund label | Peruntukan | |
| REVERSED badge | Dibalik | Always with the link "Dibalik oleh No. Bukti …" |
| Close irreversibility phrase | "Tutup buku bersifat permanen" | |
| Close incident label | Kejadian setelah tutup buku | "Kejadian" is reserved for this; a member's life event is "Peristiwa" |
| Scope label | Lingkup | Komisi is a fifth type of Lingkup (brief v2, DL17) |
| Anonymous donor wording | Tanpa nama | |
| Offering parts and counting sheet | QRIS; Lembar penghitungan persembahan | |
| F13 title | Sentralisasi / Penyaluran | Replaces the source title "Sentralisasi / Settlement" |
| F14 title and empty annex | Lampiran Laporan Bulanan; "Nihil" | |
| F01 lines named only in English | "Uang Muka diberikan", "Pengembalian sisa uang muka", "Dana Transit masuk", "Dana Transit keluar", "Posisi dan kesimpulan rekonsiliasi" | See the gap below |
| Church officer title | Pimpinan Jemaat yang berwenang | Held by the Pendeta as Ketua Jemaat |
| Treasurer appointment document | surat penunjukan | The screens use "SK BPMJ" for the decision that forms a Panitia |
| Statement line | Mutasi bank | |

**Gap to close in the brief.** The v1 row for F01 also asked for Indonesian names for transfers and adjustments, the treasury net position, and the accountability flags. Those lines are not on the F01 sample page that was drawn, so the design gives no confirmed name for them. They need names before the full template (F01 to F14) is built.

## 6. Glossary, terms to add

Add these with the meanings given; they are used across rounds 2 to 5.

| Term | Meaning |
| --- | --- |
| Pelayan dan pengurus | Audience label for items meant for officers only |
| Jabatan kosong | A post with no holder; an Operator may run it visibly |
| Pelimpahan tugas | A temporary delegation with an end date |
| Diverifikasi | Status of member data confirmed by the Penatua Kolom. Not "Terverifikasi", which is for supporting documents |
| Belum dikonfirmasi | A person imported from the paper book whose family has not yet confirmed; never shown in a publication |
| Peristiwa | A member's life event: Baptisan, Sidi, Pernikahan, Kematian, Pindah Kolom |
| Izin penggunaan data pribadi | Consent to use personal data. "Izin", never "Persetujuan" |
| Tampilan nama | A member's chosen form for their name in publications |
| Kategori BIPRA | Anak, Remaja, Pemuda, Bapa, Ibu; calculated, see P10 |
| Status pernikahan | "Belum pernah menikah" or "Sudah menikah"; one of the three inputs of Kategori BIPRA |
| Revisi | A linked correction to something already published. "Versi" stays reserved for the Mata Anggaran list |
| Hanya baca | State of a module that was turned off: nothing new, everything old still readable |
| Disetujui oleh {nama} | An approval made inside the app (rounds 2 to 5). Approvals of finance records remain statements recorded by the Bendahara |
| Pemberi persetujuan | The post that approves requests from a unit type, set once per church |
| Kas/Bank unit, "Dikelola oleh {unit}" | A Kas/Bank managed by a unit and its unit treasurer |
| Email cadangan | Optional backup email, used only for account recovery |
| Akun saya | The account screen: phone number, backup email, devices, push settings, sign-out |

## 7. Sections to add to the brief

The brief has no home yet for the following. Each line is a rule the screens already follow.

| Section | Content | Reference |
| --- | --- | --- |
| Sign-in and account | Phone code for every post; one person, one account; account linked to Data jemaat by name and birth date, verified by the Penatua Kolom; unverified accounts see only Warta Jemaat and announcements for all members | P01, P02, P03 |
| Account changes and recovery | Phone number change proven on the new number; optional backup email; recovery without email needs Operator and Penatua Kolom together; the app never reveals whether a number is registered | P04, P06, P07 |
| Notifications | In-app in V1; push in round 5 with the lock-screen rule | D28, P05 |
| Posts | Combined Beranda, post chosen per action; no start date in the future; vacancy cover by the Operator | Q31, P08, R04 |
| Approvals in the app | Approver table by post; no amount limits; no self-approval; approved fund requests are booked as an advance | P09, P13 |
| BIPRA | The rule and its consequences | P10, P11 |
| Units and committees | Unit Kas/Bank; forming and closing a Panitia | P14, P15, P16 |
| Publications | Warta Jemaat fixed A4; announcements picked per edition; locking after review; revisions | Q27, P17, P18 |
| Visual system | Light and dark themes both confirmed; tokens in `tokens/` | C02, C03 |

## 8. What must stay marked open

Do not mark these decided.

| Item | Why |
| --- | --- |
| Legal review of the consent text (question 24 and question 28) | A legal check, not a design choice |
| The church's own Mata Anggaran list | Sample rows are invented |
| Indonesian names for the F01 lines listed in section 5 | Not drawn, so not confirmed |
| Name of the implementation designer, timeline and review dates (question 1) | Not recorded in the design files |

## 9. Suggested changelog entry

> **18 November 2026.** All open questions (1 to 32) decided by the product owner; statuses changed from Proposed to Decided. Question 8 decided against the proposal: Kas/Bank, peruntukan and Lingkup are never pre-filled. Question 12 extended: an Operator may run a vacant post. Sign-in changed from an email code to a phone-number code for every post. BIPRA categories defined by age and marital status. RD04 and EC07 decided. Glossary "Still open" emptied; platform terms added. Dark theme confirmed. Still open: legal review of the consent text, the church's Mata Anggaran list, and Indonesian names for the remaining F01 lines. Source: Palakat design handoff, decision log.
