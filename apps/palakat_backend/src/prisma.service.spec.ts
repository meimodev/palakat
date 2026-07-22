import { resolvePoolMax } from './prisma.service';

/**
 * Phase 0, §0.3. The pool was unbounded — `pg`'s default of 10 per process —
 * which is one container holding most of a Supabase Free connection budget
 * while scale-to-zero multiplies containers.
 *
 * The parsing is the part worth testing. `Number(process.env.X ?? 3)` looks
 * safe and is not: an unset variable is `NaN` and an empty one is `0`. A pool
 * of `NaN` or `0` fails in the same shape as the bugs this project keeps
 * finding — the service starts, accepts requests, and can never answer one.
 */
describe('resolvePoolMax', () => {
  it('takes an explicit setting', () => {
    expect(resolvePoolMax('5')).toBe(5);
  });

  it.each([
    ['unset', undefined],
    ['empty', ''],
    ['blank', '   '],
    ['not a number', 'three'],
    ['zero — a pool that can never serve a request', '0'],
    ['negative', '-1'],
    ['fractional', '2.5'],
  ])('falls back when the value is %s', (_label, raw) => {
    expect(resolvePoolMax(raw)).toBe(3);
  });
});
