import {
  generateRows,
  definedPermissions,
  analyse,
} from '../../scripts/generate-parity-table';

/**
 * These numbers are the hand-built parity table's, derived independently by a
 * human read (`docs/palakat-backend-rpc-rest-parity-table.md`). The generator
 * reproducing them is the evidence for ADR-0009's claim that a program
 * transcribes without drift — and the first version of the generator did *not*
 * reproduce them, which is how the strongest-guard bug below was caught.
 */
describe('parity table generator', () => {
  const rows = generateRows();
  const summary = analyse(rows, definedPermissions());

  it('finds every RPC action', () => {
    expect(rows).toHaveLength(166);
  });

  it('tracks the authorization posture, hand-table baseline in the margin', () => {
    const byGuard = rows.reduce<Record<string, number>>((acc, r) => {
      acc[r.guard] = (acc[r.guard] ?? 0) + 1;
      return acc;
    }, {});

    // Baselines are the hand-built table's. Phase 1.5 moves them on purpose;
    // anything else moving them is a security-posture change that should fail
    // here rather than land quietly.
    expect(rows.filter((r) => !r.unguarded)).toHaveLength(43); // was 38, +5 approvalRule.*
    expect(byGuard.requireUserId).toBe(89); // was 94, −5 approvalRule.*
    expect(byGuard.requireSuperAdminOrClient).toBe(12); // 👑 super-admin
    expect(byGuard.requireAuthAny).toBe(7); // 🔓 any-audience
    expect(byGuard.none).toBe(15); // ⚪ public (14) + service-scoped (1)
  });

  it('separates inline-guarded cases from genuinely unguarded ones', () => {
    // The nine admin.* actions authorize with a hand-written role check. Before
    // the generator knew that, they read as holes and a redundant "fix" for all
    // nine was written. trulyUnguarded is the number Phase 1.5 works against.
    for (const action of [
      'admin.membershipInvitation.approve',
      'admin.songDb.upload.init',
    ]) {
      expect(rows.find((r) => r.action === action)!.inlineGuard).toBe(true);
    }
    expect(summary.trulyUnguarded).toBeLessThan(summary.unguarded);
  });

  it('takes the strongest guard when a case calls several', () => {
    // `requireUserId` first, then `requireSuperAdminOrClient` — sequential and
    // ANDed. Reading "first wins" reported these two as merely authenticated.
    for (const action of [
      'admin.churchRequest.approve',
      'admin.churchRequest.reject',
    ]) {
      const row = rows.find((r) => r.action === action)!;
      expect(row.guards).toContain('requireUserId');
      expect(row.guard).toBe('requireSuperAdminOrClient');
    }
  });

  it('carries the exact allow-list, not a normalised one', () => {
    const row = rows.find((r) => r.action === 'finance.get')!;
    expect(row.permissions).toEqual([
      'ops.finance.revenue.create',
      'ops.finance.expense.create',
      'ops.approval.finance',
    ]);
  });

  it('finds the phantom permission, and shows the unchecked one is now checked', () => {
    // ops.approval.finance is still a dead clause — correcting it to
    // .override would *widen* finance read access, so it waits for a yes.
    expect(summary.phantom).toEqual(['ops.approval.finance']);
    // ops.approvalRule.manage was "defined and never checked". Phase 1.5
    // resolved which horn: the approval-rule actions were under-guarded.
    expect(summary.unchecked).toEqual([]);
  });

  it('groups fall-through cases under the guard of the body they reach', () => {
    const attach = rows.find((r) => r.action === 'auth.attach')!;
    const signIn = rows.find((r) => r.action === 'auth.signIn')!;
    expect(attach.guard).toBe(signIn.guard);
  });
});
