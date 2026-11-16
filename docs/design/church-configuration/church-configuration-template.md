# Church configuration — template

Date of template: 16 November 2026
Status of every value: **NOT YET RECORDED.** This is a blank form. Nothing in it is a production default.
For: the authorized church officer, with the implementation team.
Covers: section 4 of [the readiness addendum](../implementation-readiness-addendum-2026-10-27.md), with the fields from S section 3 that each value needs.

## How to use this form

1. Copy this file and `production-master-r1.csv`. Fill the copies, not these originals.
2. **Do not commit a filled copy to this repository.** A filled copy holds bank details, names and church decisions. Keep it in the church's controlled storage. The implementation team turns it into a reviewed deployment configuration, where each value gets an activation actor, time and version ID (addendum section 4).
3. For each value, record where it came from (a resolution, a letter, a statement), who filled it and who reviewed it. A value without a source is not recorded.
4. Leave a field empty rather than guessing. An empty field blocks only the action that depends on it. For example, a missing approval rule for expenses blocks finalizing expenses, not receipts (fixture B55).
5. Amounts are whole rupiah. Dates are `YYYY-MM-DD`. Do not round.

Each section ends with a sign-off line:

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

---

## 1. Church identity and calendar

Blocks: activating the workspace.

| Field | Value | Notes |
|---|---|---|
| Official church name | | As on the church's own documents |
| Name shown in the app and on reports | | |
| Timezone | | Indonesia has three: `Asia/Jakarta` (WIB), `Asia/Makassar` (WITA), `Asia/Jayapura` (WIT). Used for the monthly AI budget and day boundaries |
| Currency | IDR | Fixed in V1. No foreign currency |
| Fiscal year begins on 1 January | ☐ Yes ☐ No, it begins on: ______ | V1 requires 1 January (RD13). If the answer is No, stop: D08 has to change before go-live |
| First production month | | `YYYY-MM`. The first published master is effective from the first day of this month |
| Cutover date | | Opening balances are the position at the **start** of this date. Ordinary transactions start on or after it (S 6.1) |
| If cutover is not the 1st: we accept that the first report covers only cutover date to month end | ☐ Yes | RD05. Reports never claim earlier coverage |

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 2. Authority: who may make the first Treasurer

Blocks: granting financial capability to anyone (RD07). Technical access alone grants nothing.

| Field | Value | Notes |
|---|---|---|
| Church authorization source | | The body or role whose written decision appoints the Treasurer. The product names none; the church does |
| Nominee (first Treasurer) | | Full name and role |
| Authorizing person or role | | Who signed the authorization |
| Authorization document | | Reference number, date, where the original is kept |
| Onboarding reviewer | | The human who checks the document before access is granted. Not the infrastructure administrator |
| How a replacement is authorized | | Same source, or another. Replacement needs a new authorization; the old Treasurer's access is revoked |

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 3. Scopes

Blocks: Funds and permissions. A Scope is an organizational unit: the Jemaat, a Kolom, a BIPRA unit or a Panitia (S 3).

| Scope ID (your label) | Type | Name | Parent Scope ID | Effective from |
|---|---|---|---|---|
| | | | — (root) | |
| | | | | |

The hierarchy must not loop. Add rows as needed.

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 4. Funds

Blocks: posting. Each Fund is owned by one Scope, and the owner governs approvals for that Fund (S 3).

| Fund ID (your label) | Name | Owner Scope ID | Restriction (what the money may be used for) | Governance or approval policy reference | Active from |
|---|---|---|---|---|---|
| | | | | | |
| | | | | | |

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 5. Physical Accounts

Blocks: opening and every posting. One row per cash box or bank account.

| Account ID (your label) | Name | Type | Bank and branch | Account reference | Active from |
|---|---|---|---|---|---|
| | | ☐ CASH ☐ BANK | | | |
| | | ☐ CASH ☐ BANK | | | |

For the account reference, give only what identifies the account to the Treasurer, such as the last four digits. The full number goes only into the deployment configuration, never into chat, email or this repository.

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 6. Opening schedules at the cutover date

Blocks: opening approval and the first ordinary posting (RD05). V1 supports balance-only cutover. Earlier history does not become journals.

**6a. Money on hand, by Account and Fund.** Every Account's verified balance, split across Funds exactly once. Include zero positions.

| Account ID | Fund ID | Amount (Rp) | Verified against (statement, cash count) | Verified by |
|---|---|---|---|---|
| | | | | |

Check: for each Account, the Fund amounts add up to its verified balance.

**6b. Outstanding advances.** Money given to someone that they have not yet accounted for. One case belongs to one Fund (EC06).

| Recipient | Fund ID | Responsible Scope | Amount outstanding (Rp) | Issued on | Due date (if policy has one) | Supporting document |
|---|---|---|---|---|---|---|
| | | | | | | |

**6c. Money held for others (transit).** Money collected for a beneficiary, such as the Sinode, and not yet passed on.

| Beneficiary | Fund ID | Governing policy | Amount still payable (Rp) | Supporting document |
|---|---|---|---|---|
| | | | | |

**6d. Control.** Opening equity = total of 6a + total of 6b − total of 6c.

| Total 6a | Total 6b | Total 6c | Opening equity |
|---|---|---|---|
| | | | |

Opening approval follows the church's controlled-migration policy. Name the approver: ________

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 7. Mata Anggaran: production master and effect eligibility

Blocks: classified posting, and CUSTODY posting on each row (RD10).

The approved derivation is already done: `production-master-r1.csv` holds all 289 rows (131 Pendapatan, 158 Belanja), with 237 postable leaves, 52 non-postable parents and the approved B113 correction (`2.3.08.02` becomes `2.3.02.02` under `2.3.02.00`). It was generated by `derive_master.py` from S Appendix B. Do not edit codes, names or postability. A change to any of them is a new derivation decision, not configuration.

What the church fills in, in the CSV copy:

| Column | Allowed values | Meaning |
|---|---|---|
| `allowed_effect_kinds` | `ECONOMIC`, `TRANSIT`, `BOTH` or empty | `ECONOMIC`: the church's own income or spending. `TRANSIT`: money only passing through for a beneficiary. `BOTH`: the row is used for either. Empty is treated as `ECONOMIC` only, so CUSTODY posting on that row is blocked |
| `church_note` | free text | Why, if the choice is not obvious |

Rules to keep in mind:

- The system never guesses this from the code. A `6.x` code does not make a row TRANSIT (E011). Every value is a human decision.
- **Set it before the first publication.** Published rows cannot change (D11). A later change needs a new master version, which starts at a period boundary. A church that wants to record custody collections in its first month must set the values now.
- Rows to look at first: the 12 postable rows under `6.0.00.00 DANA TRANSIT`, six in each catalog (Pundi Extra, Kartu Partisipasi / Mapalus, Dana-Dana Kegiatan Sinodal). Also look at any other row the church uses for money it passes on, for example centralization to the Sinode. Whether those are TRANSIT is the church's decision.
- Only postable rows (`postable = true`) need a value. Leave parent rows empty.

| Field | Value |
|---|---|
| Rows with a value set | ____ of 237 postable rows |
| Person authorized to publish the master | |
| Effective from (first day of the first production month, section 1) | |

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 8. Voucher numbering

Blocks: the first finalization in each series (D08, RD13). Numbers are allocated when a transaction is finalized, one series per workspace and calendar year.

| Series | Prefix | Number padding (digits) | Example as it would print |
|---|---|---|---|
| Ordinary transactions | | | |
| Opening batch (`OPN`) | | | |
| Controlled adjustments (`ADJ`) | | | |

The year comes from the transaction's effective date and is not configurable. The format is versioned before first use and cannot change mid-year.

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 9. Approval policy

Blocks: reviewing and finalizing the transaction types it covers (S 5.2). There is no built-in threshold. If the church has no rule for a type, write "no approval required" explicitly; an empty cell blocks that type.

| Transaction type | Mode | Applies from amount (Rp), if any | Who must approve (role) | Permitted methods (signed memo, meeting minutes, …) | Proof required | Funds or Scopes it applies to |
|---|---|---|---|---|---|---|
| Direct expense | ☐ Not required ☐ External | | | | ☐ Yes ☐ No | |
| Advance issue | ☐ Not required ☐ External | | | | ☐ Yes ☐ No | |
| Reimbursement | ☐ Not required ☐ External | | | | ☐ Yes ☐ No | |
| Transit remittance | ☐ Not required ☐ External | | | | ☐ Yes ☐ No | |
| Account transfer | ☐ Not required ☐ External | | | | ☐ Yes ☐ No | |
| Fund ownership transfer | ☐ Not required ☐ External | | | | ☐ Yes ☐ No | |
| Other: ______ | ☐ Not required ☐ External | | | | ☐ Yes ☐ No | |

"External" means the Treasurer records an approval given outside the app. The app never claims the approver logged in. In-app approval is a later feature.

| Setting | Value | Notes |
|---|---|---|
| Maker/checker (preparer and reviewer must be different people) | ☐ On ☐ Off | Off by default for a solo Treasurer |
| A solo Treasurer may review and finalize in one action | ☐ Yes ☐ No | Both steps are still recorded |
| Who may accept an exception, and for what | | |

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 10. Evidence policy

Blocks: close, and finalization if the church wants evidence earlier (S 5.3).

Required by default before close: direct spending, paid reimbursements, accepted advance spending, transit remittances.

| Question | Answer |
|---|---|
| Keep the default list above | ☐ Yes ☐ Change: ______ |
| Other types that also need evidence | |
| Must evidence be complete **before** finalization (stricter than the default)? For which types? | |
| May a solo Treasurer verify their own evidence? | ☐ Yes ☐ No |
| Who may verify evidence | |
| Who may accept an evidence exception (for example, a lost receipt) | |

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 11. Advances and transit

Blocks: the affected cases and their close checks. Leave a row empty only if the church really has no such rule.

| Question | Answer |
|---|---|
| Advances: due period, if any (for example 30 days) | |
| Does an overdue advance block close? | ☐ Yes ☐ No, show it only |
| Transit beneficiaries (Sinode, Wilayah, …), one per line | |
| Allocation formula for each beneficiary, if collections are split | |
| Rounding rule for splits | |
| Remittance due dates, and whether a late one blocks close | |

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 12. Reports

Blocks: activating the report template and the first production close (RD03).

| Question | Answer |
|---|---|
| Template | ☐ Reviewed default template (F01–F14) ☐ Church's original forms |
| If original forms: blank and example files supplied | Files: ______ |
| F14 annexes: all eight defaults (advances, advance settlement items, offering counts, reimbursements, evidence exceptions, corrections, opening and cutover, control checks) | ☐ Yes ☐ Change: ______ |
| People and roles who sign the reports | |
| Officer who checked the sample PDF and Excel output (totals, negative, zero and empty values) | Name: ______ Date: ______ |

No output will claim to match an original church form unless the original forms were supplied and mapped.

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 13. AI assistance (optional)

Blocks: AI features only. Manual work never depends on this section.

| Question | Answer |
|---|---|
| Turn on AI assistance | ☐ Yes ☐ No |
| Monthly cap | Rp150,000, fixed by policy |
| Reviewed price per model (provider currency per token) | |
| Reviewed exchange rate (Rp per unit of provider currency) | |
| Date of the rate, and the officer who set it | |

The rate is never fetched live (EC08 draft). Without it, AI cannot be switched on.

> Filled by: ________ Reviewed by: ________ Date: ________ Source documents: ________

## 14. Conditions before real church data goes in

These are not configuration values, but go-live waits on them (S 15, open product conditions). Record each one when it is met.

| Condition | Who | Met on | Reference |
|---|---|---|---|
| Counsel's view on the personal data law (UU PDP) and the retention rule for generated PDF and Excel files | Counsel | | |
| The pilot Treasurer accepts that a close cannot be undone, and that some later discoveries may block a later reconciliation or close | Pilot Treasurer | | |
| The fiscal year start is confirmed (section 1) | Church officer | | |
| The authorization source is named (section 2) | Church officer | | |
| The report template is accepted (section 12) | Church officer | | |
| A paid hosting plan with point-in-time recovery is active, and the first restore drill has passed | Product owner | | |
| The refund and donor-return event table (RD04) is approved, if the church needs refunds at go-live | Product owner | | |
