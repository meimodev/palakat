# Engineering contracts EC01–EC08 — draft designs

Date: 7 November 2026
Status: **DRAFT — proposed by Claude at the user's request. Not approved by the implementation designer. EC01–EC08 stay OPEN in the readiness addendum.**
Owner: implementation designer (a role; no person is named yet)

This file proposes a design for each engineering contract listed in section 3 of [the readiness addendum](implementation-readiness-addendum-2026-10-27.md). It changes neither S nor P. When the designer approves an entry, move its rules into S (the named section) and mark the EC entry closed in the addendum. If review finds that a design needs a different product behavior, that question goes back to the product owner, as the addendum requires.

Common ground, taken from S and not repeated per entry: one application and one transactional database (S section 3); integer rupiah; drafts and staged data have no official effect (S 4.1 invariant 8); every command carries an idempotency key; locks are taken in ascending resource ID order so two commands cannot deadlock.

| EC | One-line design | Proposed home in S | Needs a decision from the designer |
|---|---|---|---|
| EC01 | Lock each consumed resource, recompute its effects in date order, require the running balance to stay at or above zero | 4.1, 5.4, 6.3 | Row locks or serializable isolation |
| EC02 | An accepted expense item with a supported amount; each use consumes part of it under lock | 3, 4.2 | Who sets the supported amount |
| EC03 | Money components and an allocation matrix with fixed sum rules | 3, 4.2 | None |
| EC04 | Synchronous durable commit; a close writes an external archive before it commits; recovery checks a hash chain behind a write fence | 6.4, 13 | Three choices, listed under EC04 |
| EC05 | Export run with a read cutoff, immutable file versions and a manifest; missing required files mean INCOMPLETE | 13 | Package format and export retention |
| EC06 | Assert per-Fund balance at commit; composite key ties allocations to the case's Fund | 3, 4.1 | Database-level backstop |
| EC07 | Add a `REJECTED` evidence decision and a status projection | 5.3 | Coverage when a requirement needs several items |
| EC08 | Reviewed price and rate table in each AI policy version; atomic reservation against the cap | 12 | None |

## EC01 — Atomic consumption, date order and combined validation

**Resources that are consumed:** an advance case's outstanding amount, a transit case's remaining payable, a statement line's or cash-movement group's unconsumed amount, and (EC02) an expense item's supported amount.

**Design**

1. A case balance is never a stored counter that commands update. It is derived from the case's posted effects (S 5.4).
2. A command that consumes a resource locks that resource row inside the posting transaction, then recomputes.
3. After adding the proposed effect to the resource's effects, scan them in `(effective_date, posting_sequence)` order. The running balance must be at least zero after every effect, and the final balance must be at least zero. This is what rejects a day-10 settlement against a day-20 issue, and it also rejects an insertion that would leave a later-dated settlement overdrawn.
4. A command that touches several resources locks them in ascending ID order, then validates each.
5. A correction bundle (reversal plus replacement, or several linked batches) is applied to an in-memory copy of every affected resource, validated as one combined result, and only then committed. A transient negative inside the bundle is not an error and is never visible outside the transaction.
6. For reconciliation, a match allocation locks the statement line or movement group, and `unconsumed = amount − sum(confirmed allocations)` must stay at or above zero.

**Acceptance**

- Two simultaneous settlements of 700 against a case that holds 1,000: exactly one commits, the other fails with no effect.
- A settlement dated day 10 against an issue dated day 20 is rejected.
- A case issued 1,000 and settled 700 (outstanding 300): a bundle that reverses the 1,000 issue and replaces it with a corrected 1,000 issue commits, although the reversal alone would leave the case at −700.
- Two commands that name cases A and B in opposite order complete without deadlock.

**Decision for the designer:** explicit row locks with recomputation (recommended, simple, easy to test) or serializable isolation with retry. Either satisfies the rules above.

## EC02 — Expense items and evidence allocation

**Design**

1. `ExpenseItem`: id, workspace, description, item date, `supported_amount`, and its evidence links. A human reviewer sets `supported_amount` when accepting the item; it cannot exceed the amount stated on the item.
2. `ItemConsumption`: item id, the consuming event (an advance-settlement allocation or a reimbursement payment), amount, transaction revision. It is created when that event is finalized, not at draft time.
3. Invariant, enforced under the item row lock (EC01): `sum(consumptions) ≤ supported_amount`.
4. Reversing a posting appends a negative consumption that releases the amount. A replacement consumes again. Both fall inside the bundle validation of EC01.
5. An item is derived `UNCONSUMED`, `PARTIAL` or `CONSUMED`. A partial reimbursement consumes part of the item.
6. Both an advance settlement and a reimbursement draw on the same item, so one receipt cannot be counted twice (S 4.2).
7. An evidence file linked as `SUPPORT_ONLY` consumes nothing. Only `SUPPORTS_ITEM_AMOUNT` links count toward an item's supported amount. Reusing a file as nonfinancial support never touches an item.
8. A draft shows the remaining amount as information. Finalization re-checks it atomically.

**Acceptance**

- Two 700 allocations against one supported 1,000 item: the second is rejected.
- A 600 and a 400 allocation against the same item both commit, and the item is `CONSUMED`.
- Reversing the 600 allocation frees 600.
- A file attached as `SUPPORT_ONLY` to a second transaction leaves the item's consumed amount unchanged.

**Decision for the designer and product owner:** `supported_amount` is entered by the reviewer and capped at the item's stated amount. If the church wants it derived from the evidence total instead, that is a product change.

## EC03 — Money components

**Design**

1. A transaction has a header total, zero or more `MoneyComponent` rows, and one or more allocations.
2. `MoneyComponent`: stable id (assigned at draft creation and kept through edits, so matching and corrections refer to the same component), ordinal, Account, direction `IN` or `OUT`, amount, payment reference.
3. `AllocationComponent(allocation, component, amount)` assigns allocation amounts to components. The common case is one row.
4. Sum rules, checked at review and again at finalization:
   - `sum(component amounts) = header total` for a receipt or payment;
   - `sum(allocation amounts) = header total`;
   - for each allocation, `sum(AllocationComponent amounts) = allocation amount`; for each component, the same sum equals the component amount;
   - OWNED, CUSTODY and SPLIT parts together equal the one physical collection (S round 4A).
5. Each component produces exactly one physical movement and one CashMovementGroup, whatever the number of allocations. Journal legs are `LIQUID(Account, Fund)` from the assignment matrix.
6. A noncash settlement (accepted advance spending) has no components and no physical movement. A Fund ownership transfer has no components and `physical_flow = false`. An Account transfer has an `OUT` and an `IN` component linked as one transfer. Each keeps its own recipe.

**Acceptance**

- A 600 cash plus 400 bank collection allocated 1,000 to one Fund: two components, two movements, allocated money 1,000.
- The same collection allocated 700 OWNED and 300 CUSTODY: still two movements; the legs add up per Fund.
- A header total of 1,000 with components of 600 and 300 is rejected.
- Editing a draft keeps both component ids.

## EC04 — Durable commit and recovery

**Aim:** acknowledged work survives failure, a retry never doubles an effect, and an acknowledged close is never lost. The approved targets stay: RPO 1 hour, RTO 8 hours, 7-day point-in-time recovery, 35 daily and 12 monthly snapshots. This design does not change them.

**What lives where**

- In the database, in one transaction with the journal: journals, vouchers, the posting sequence, idempotency records, audit rows, close manifests and the frozen snapshot datasets (S 4.1 invariant 2 and S 6.4 step 8). No cross-store atomicity is needed for them.
- In object storage: evidence files (irreplaceable) and rendered reports (re-renderable from the snapshot, S 5.5). Evidence is uploaded first, addressed by checksum and never overwritten. Commit verifies that every referenced object exists with the stated checksum.

**Design**

1. **Acknowledgement rule.** Return success only after the database reports the commit durable under its synchronous-durability setting, replicated to a standby in a second availability zone. Never acknowledge from a queue or an asynchronous path.
2. **Hash chain.** Each workspace keeps `chain_hash = H(previous chain_hash ‖ batch_hash)` per posted batch. Every acknowledgement returns a receipt: workspace, posting sequence, batch or close id, content hash. The close manifest records the chain head at the cutoff.
3. **Close writes an archive first.** A close runs: validate and lock, build the snapshot, write a *close archive* to write-once storage (the period's batches, legs, allocations, vouchers, the idempotency record, the snapshot datasets and manifest, with their hashes), then commit the database transaction, then acknowledge. An archive without a matching commit is harmless and is labeled uncommitted by its hash. A close is the only irreversible event (D07), so it is the one place where the acknowledgement may depend on a second store.
4. **Daily external copy.** Once a day, and at each close, copy every workspace's latest chain head to the same write-once storage. This is asynchronous and not in the acknowledgement path.
5. **Recovery with a write fence.** After any restore, every workspace stays read-only until these checks pass:
   a. Restore the base backup and replay archived logs as far forward as they go. Never stop at an older snapshot when later logs exist.
   b. Verify each workspace's hash chain end to end.
   c. Compare each workspace with its newest close archive and external chain head. If the restored database already holds that close, continue.
   d. If an acknowledged close is missing, re-apply it from its archive (rows, idempotency record and manifest) and verify the snapshot hash. The period is then CLOSED again with the same hashes. This restores a fact that already happened; it is not a reopen.
   e. If ordinary finalizations are missing (they were acknowledged inside the recovery gap), report them as a gap with the last known chain head. They are detected when a client presents a receipt the restored chain lacks, or when the external copy is ahead.
   f. Only then lift the fence.
6. **Retries.** The idempotency record is written in the same transaction as its effects, so it exists exactly when the effects exist. After a restore, a retry whose effects survived returns the original result. A retry whose effects were lost executes once.

**Limit to accept knowingly.** An ordinary finalization acknowledged in the last moments before a total loss of the database and its standby can be lost, up to the approved RPO of 1 hour, and is found only by the receipt or external-copy checks in step 5e. A close cannot be lost this way, because of step 3.

**Acceptance (restore drill)**

1. Close period P at time t1 and receive the acknowledgement.
2. Restore a base backup and logs that end before t1.
3. Run recovery. The workspace stays fenced, the check finds the close missing, and step 5d re-applies it.
4. The period is CLOSED with the identical snapshot hash, with no duplicate voucher, journal or sequence number.
5. Retrying the original close request with its idempotency key returns the original result and creates nothing new.
6. Repeat with an ordinary finalization acknowledged before the loss: the drill reports it as a gap and does not silently drop it.

**Decisions for the designer**

- Is a close allowed to depend on write-once storage being available (step 3)? Recommended yes: closes are rare, and a delayed close is acceptable.
- Standby replication in a second availability zone (recommended) or a single zone with continuous log archiving only. The latter widens the loss window.
- Hosting vendor and region layout for the standby and the write-once store. This draft names none.

## EC05 — Portable export

**Design**

1. `ExportRun`: id, workspace, requester, `cutoff_sequence`, `cutoff_time`, status `QUEUED → BUILDING → COMPLETE | INCOMPLETE | FAILED`, manifest id.
2. All structured data is read from one consistent snapshot at the cutoff. A posting after the cutoff is not included.
3. Files are enumerated from that same snapshot as `(file_id, version_id, checksum, size)`. Evidence file versions are immutable and a new upload is a new version, so a concurrent upload cannot change or break a reference.
4. The manifest holds the manifest id, run id, cutoff, schema version, entity counts, and every file with its package path, checksum and the records that own it. A hash of the manifest is stored with the run.
5. The package has two clearly labeled parts: `frozen` (snapshot datasets and evidence status as at each close) and `current` (accountability as of the export cutoff, including evidence added after a close).
6. A file that is removed, quarantined or missing appears in the manifest with `availability` and a reason. If any file required by a finalized event is unavailable, the run ends `INCOMPLETE` with the missing list, and nothing labeled complete or successful is produced.
7. A retry of a run reuses its cutoff and file list, so it packages the same population. A new request gets a new run and cutoff.

**Acceptance**

- An evidence upload during the build does not appear, and no reference in the package is broken.
- A posting during the build is absent from the package, and the package is internally consistent.
- Deleting a required file makes the run `INCOMPLETE`.
- Retrying a failed run produces a package with an identical manifest hash.
- Verification tool: every file in the manifest exists with the stated checksum, and every link target exists.

**Decisions for the designer:** package format (one archive or several parts) and how long finished exports are kept. S and P are silent on both.

## EC06 — Per-Fund balance (engineering design)

The product rule is decided and in S 4.1 (invariants 3 and 9). This entry is how to enforce it.

**Design**

1. A batch has an immutable `kind`. The exempt kinds are a closed set: `FUND_OWNERSHIP_TRANSFER` and `OPENING`. Every other kind is checked.
2. Before commit, in the same transaction, group the batch's legs by `fund_id`. For a checked kind, each Fund's debits must equal its credits. If not, roll back with `FUND_IMBALANCE`.
3. `AdvanceCase` and `TransitCase` carry `fund_id`. An allocation that links to a case is stored with `(case_id, fund_id)` as a composite foreign key to the case's `(id, fund_id)`, so a mismatched allocation cannot be stored at all. Report it as `CASE_FUND_MISMATCH`.
4. An advance issue with allocations in several Funds creates one case per Fund inside the posting transaction. The draft shows the planned split before review.
5. A reversal copies the original legs with inverted signs, so it balances per Fund whenever the original did.

**Acceptance:** arithmetic A05 and A06 and behavior B12–B14 in `test-vectors/`. Add a property test: for any accepted command sequence, every checked batch sums to zero per Fund.

**Decision for the designer:** also add a deferred database trigger that re-checks per-Fund sums at commit (recommended as a backstop), or rely on the application assertion alone.

## EC07 — Rejected evidence

**Design**

1. Evidence decisions: `UPLOADED`, `VERIFIED`, `EXCEPTION_ACCEPTED`, `REJECTED`. `REJECTED` needs a reason and records who and when. Decisions append and are never edited.
2. A requirement's status is derived from the latest decision on each of its links:
   - `VERIFIED` if any link is verified;
   - else `EXCEPTION_ACCEPTED` if an exception stands;
   - else `UPLOADED` if any link is uploaded and not rejected;
   - else `REQUIRED_MISSING`.
3. Rejecting the only valid link returns the requirement to `REQUIRED_MISSING`. The close blocker stays. The rejected file stays stored, and its decision, reason and history stay visible.
4. A new upload creates a new link and starts again at `UPLOADED`.
5. After a period closes, a rejection is recorded in current accountability but cannot change the frozen close or snapshot (S section 1, evidence rule).

**Acceptance:** rejecting a receipt records actor, time and reason; the close blocker remains; earlier `VERIFIED` history is intact; the frozen snapshot is unchanged.

**Decision for the designer:** when one requirement is covered by several items (EC02), does one verified link satisfy the whole requirement? This draft says yes. If coverage must be by amount, status needs the EC02 consumption data.

## EC08 — AI cost rate and reservation

**Design**

1. Each AI policy version holds a reviewed price table (provider currency per input and output token, per pinned model) and a reviewed rate (IDR per unit of provider currency), each with its date and the authorized officer who set it. S forbids inventing a price or a rate, so both come from this reviewed version. No live fetch.
2. Prices and the rate are stored as scaled integers (for example micro-units), so all cost arithmetic is integer. Round up to a whole rupiah.
3. Every usage record stores the policy version id, so the rate and price used are reproducible.
4. **Reservation.** Before sending a request, compute its maximum cost from its token limits and reserve it with one conditional update: add the estimate to `reserved` only if `spent + reserved + estimate ≤ cap` for the workspace and budget month. If the update changes no row, the request is not sent. After the response, set `spent += actual`, `reserved −= estimate`. On failure or timeout, release the reservation.
5. The 70%, 90% and 100% behavior (Rp105,000, Rp135,000, Rp150,000) is judged on `spent + reserved`. The budget month follows the workspace timezone.

**Acceptance**

- 100,000 remaining, two simultaneous requests estimated at 80,000 each: exactly one is sent.
- After the cheaper actual cost is recorded, the unused part returns to the allowance.
- Thresholds trigger at exactly 105,000, 135,000 and 150,000.
- A policy version with no rate set cannot be activated for AI use.

## What remains open after this draft

Everything above is a proposal. Each entry needs the designer's decision on the points listed, then S edits and a status change in the addendum. Decisions that look product-level are marked: EC02 (who sets the supported amount) and EC04's limit on ordinary finalizations.
