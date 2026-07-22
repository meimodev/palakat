import { canJoinRoom, RoomScope } from './room-authorization';

const member: RoomScope = {
  accountId: 7,
  membershipId: 70,
  churchId: 3,
  columnId: 12,
};
const stranger: RoomScope = {
  accountId: 8,
  membershipId: 80,
  churchId: 4,
  columnId: 40,
};
const unaffiliated: RoomScope = {
  accountId: 9,
  membershipId: null,
  churchId: null,
  columnId: null,
};

describe('canJoinRoom', () => {
  it('lets a member into their own church, column and personal rooms', () => {
    for (const room of [
      'palakat',
      'account.7',
      'membership.70',
      'membership.70.birthday',
      'church.3',
      'church.3_bipra.PKB',
      'church.3_column.12',
      'church.3_column.12_bipra.REMAJA',
    ]) {
      expect(canJoinRoom(room, member)).toBe(true);
    }
  });

  it('keeps a stranger out of another church — the leak this closes', () => {
    // Before this guard, sub.join called client.join(payload.room) with no
    // check, so any authenticated user received church 3's activity, finance
    // and approval events, content included.
    for (const room of [
      'church.3',
      'church.3_bipra.PKB',
      'church.3_column.12',
      'church.3_column.12_bipra.REMAJA',
      'membership.70',
      'membership.70.birthday',
      'account.7',
    ]) {
      expect(canJoinRoom(room, stranger)).toBe(false);
    }
  });

  it('refuses a column of the right church that is not the caller’s', () => {
    expect(canJoinRoom('church.3_column.99', member)).toBe(false);
  });

  it('refuses anything outside the known grammar', () => {
    for (const room of [
      'church',
      'church.',
      'church.3x',
      'church.03abc',
      '../church.3',
      'CHURCH.3',
      'church.3 ',
      'admin',
      '*',
    ]) {
      expect(canJoinRoom(room, member)).toBe(false);
    }
  });

  it('still allows an unaffiliated account its own room and the global one', () => {
    expect(canJoinRoom('palakat', unaffiliated)).toBe(true);
    expect(canJoinRoom('account.9', unaffiliated)).toBe(true);
    // null ids must never match a room that names an id
    expect(canJoinRoom('church.3', unaffiliated)).toBe(false);
    expect(canJoinRoom('membership.70', unaffiliated)).toBe(false);
  });
});
