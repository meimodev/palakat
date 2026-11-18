# Palakat design handoff

18 November 2026. Everything a builder needs to implement the Palakat design, and everything an editor needs to bring the master brief up to date.

Palakat is the church platform for a GMIM congregation, on phone and web. Finance for the Bendahara Jemaat is the first module; rounds 2 to 5 add the platform frame, the secretariat, member data and collaboration between units.

## What is in this package

| File | What it is | Read it when |
| --- | --- | --- |
| `01-foundations.md` | Principles, language rules, colour (light and dark), typography, shape, spacing, line language, motion, Flutter mapping, platform rules | Before building any screen |
| `02-components.md` | The 31 components: purpose, Flutter widget, inputs, rules | When building a widget |
| `03-screens-and-flows.md` | Inventory of all 199 boards with their states, how to read the canvas, journeys by role, sample data | When planning a screen or a flow |
| `04-decision-log.md` | Every decision the design rests on, with a reference code for each | When a rule is questioned |
| `05-master-file-update.md` | The exact changes to make in the master brief and the readiness addendum | When updating the master file |
| `tokens/palakat-tokens.json` | All tokens, source of truth | In the build |
| `tokens/palakat_tokens.dart` | The same tokens as Flutter classes, both themes | In the Flutter app |

## Live design

| Artifact | Link | Version at handoff |
| --- | --- | --- |
| Design canvas, 199 boards | https://claude.ai/artifact/J8KD2YST4nhJUNkSFrNZuF | 1794999127-9dfd |
| Design system, 31 components | https://claude.ai/artifact/RafvDdtf4aeZ2VJMotqaB2 | 1794997610-5b86 |

Both are private to the product owner until shared.

The canvas is the reference for layout and behaviour. The design system is the reference for components and tokens. Where this package and the canvas disagree, the canvas wins and this package should be corrected.

## Reading order

1. On the canvas, open the page "Peta dan keputusan" and read "Peta layar", "Peta layar · Putaran 2–5" and "Keputusan desain".
2. Read `01-foundations.md`.
3. Play the boards for your module, using the journeys in `03-screens-and-flows.md`.
4. Build with `02-components.md` and the tokens.
5. Keep `04-decision-log.md` open for the rules.

## What is final and what is not

Final, confirmed by the product owner on 18/11/2026:

- All open questions of the brief (1 to 32), the 35 numbered design decisions, and the platform decisions of rounds 2 to 5.
- All glossary labels and the report line names and titles that are drawn.
- Both themes, light and dark.

Not final:

| Item | State |
| --- | --- |
| Consent text for personal data | Default text, not reviewed by counsel |
| Mata Anggaran rows | Sample rows are invented; the church's own list replaces them |
| F01 lines for transfers and adjustments, treasury net position, accountability flags | Not drawn, so no confirmed Indonesian names |
| Icon library | None chosen; icons are drawn one by one |

## Known limits of the design files

- The screens are drawn in the light theme only. The dark theme is defined in the tokens and tested on the component previews, not on the screens.
- Laptop layouts exist only for Bendahara Jemaat, Sekretaris Jemaat and Operator.
- Two finance laptop pages (Rekonsiliasi and Hitung kas) are tight at phone width (390 px). Phone layouts exist for both, so this affects only a laptop page opened on a phone.
- Checkboxes and radio buttons are drawn at 22 to 24 px. Their labels are part of the touch target; build the target at 44 px.
- A4 pages are drawn for F01, F02 (three pages) and one page of F14, plus the restricted copy and a provisional F01. All fourteen forms, F01 to F14, are shown as on-screen sample views in "Web · Paket Laporan F01–F14" and in the sample Excel boards, but F03 to F13 have no A4 page.
- Typed flows were tested by typing on the live canvas for these boards: Pelimpahan tugas, Warta mingguan, Keuangan unit, Membentuk Panitia, Akun saya (phone number and backup email), Memulihkan akun anggota, and the donor path of Pengembalian up to its form. The other flows were tested with a local step-by-step runner only.

## Conventions

- UI text is Bahasa Indonesia. Token, component and file names are Indonesian and are used as they are.
- This package is written in English, to match the master brief.
- Dates in the samples are written dd/mm/yyyy. The "today" of the design is 16/11/2026.
