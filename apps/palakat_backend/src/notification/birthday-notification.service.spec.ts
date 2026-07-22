import { churchLocalDate } from './birthday-notification.service';

describe('churchLocalDate', () => {
  it('resolves the church-local day, not the server (UTC) day', () => {
    // 07:00 WITA on 2026-07-22 is 23:00 UTC on 2026-07-21 — the exact instant
    // the pinned cron fires, and the one the old getDate() got wrong.
    expect(churchLocalDate(new Date('2026-07-21T23:00:00Z'))).toMatchObject({
      year: 2026,
      month: 7,
      day: 22,
      dateKey: '2026-07-22',
    });
  });

  it('zero-pads the dateKey so dedupeKeys stay stable', () => {
    expect(churchLocalDate(new Date('2026-01-05T00:00:00Z')).dateKey).toBe(
      '2026-01-05',
    );
  });

  it('does not roll over before WITA midnight', () => {
    // 15:59 UTC is 23:59 WITA the same day.
    expect(churchLocalDate(new Date('2026-07-21T15:59:00Z')).day).toBe(21);
  });
});
