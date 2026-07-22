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

  it('reproduces the hand-built table bucket for bucket', () => {
    const byGuard = rows.reduce<Record<string, number>>((acc, r) => {
      acc[r.guard] = (acc[r.guard] ?? 0) + 1;
      return acc;
    }, {});

    expect(rows.filter((r) => !r.unguarded)).toHaveLength(38); // 🔐 permission
    expect(byGuard.requireUserId).toBe(94); // 🔑 authenticated, no authorization
    expect(byGuard.requireSuperAdminOrClient).toBe(12); // 👑 super-admin
    expect(byGuard.requireAuthAny).toBe(7); // 🔓 any-audience
    expect(byGuard.none).toBe(15); // ⚪ public (14) + service-scoped (1)
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

  it('finds the phantom and unchecked permissions the plan names', () => {
    expect(summary.phantom).toEqual(['ops.approval.finance']);
    expect(summary.unchecked).toEqual(['ops.approvalRule.manage']);
  });

  it('groups fall-through cases under the guard of the body they reach', () => {
    const attach = rows.find((r) => r.action === 'auth.attach')!;
    const signIn = rows.find((r) => r.action === 'auth.signIn')!;
    expect(attach.guard).toBe(signIn.guard);
  });
});
