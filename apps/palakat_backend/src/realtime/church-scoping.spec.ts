import { ForbiddenException } from '@nestjs/common';
import { assertRowInChurch, scopeQueryToChurch } from './church-scoping';

describe('scopeQueryToChurch', () => {
  it('forces the requester’s church onto an unscoped query', () => {
    expect(scopeQueryToChurch({ skip: 0, take: 10 }, 3)).toEqual({
      skip: 0,
      take: 10,
      churchId: 3,
    });
  });

  it('accepts a query that already names the requester’s own church', () => {
    expect(scopeQueryToChurch({ churchId: 3 }, 3)).toEqual({ churchId: 3 });
  });

  it('rejects another church rather than quietly substituting your own', () => {
    // Overwriting would answer a question the caller did not ask and hide that
    // the real answer was "no".
    expect(() => scopeQueryToChurch({ churchId: 4 }, 3)).toThrow(
      ForbiddenException,
    );
  });

  it('does not mutate the caller’s query object', () => {
    const query = { churchId: undefined as number | undefined };
    scopeQueryToChurch(query, 3);
    expect(query.churchId).toBeUndefined();
  });
});

describe('assertRowInChurch', () => {
  it('allows a row in the requester’s church', () => {
    expect(() => assertRowInChurch(3, 3)).not.toThrow();
  });

  it('refuses a row belonging to another church — the leak this closes', () => {
    // Before this, `column.get`, `report.get`, `document.get`, `file.get`,
    // `activity.get` and `approver.get` returned any row whose id you could
    // guess, from any church.
    expect(() => assertRowInChurch(4, 3)).toThrow(ForbiddenException);
  });

  it.each([null, undefined, '3', NaN, {}])(
    'fails closed on an unscopeable row churchId (%p)',
    (rowChurchId) => {
      // Column, Membership and MembershipPosition all declare churchId
      // nullable, so this is reachable, not defensive padding.
      expect(() => assertRowInChurch(rowChurchId, 3)).toThrow(
        ForbiddenException,
      );
    },
  );
});
