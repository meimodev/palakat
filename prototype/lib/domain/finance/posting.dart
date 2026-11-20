import 'transaction.dart';

/// One row of the posting sign table (README 4.6 point 1, DM 4.2): the
/// sign of each effect of a part of amount m. [account] is the part's Kas/Bank,
/// [toAccount] the transfer destination; [fund] the part's Fund, [toFund]
/// the fund transfer target; [income] I, [expense] E, [transitIn] Tin,
/// [transitOut] Tout; [kase] the outstanding amount of the part's case.
class PostingSign {
  const PostingSign({
    this.account = 0,
    this.toAccount = 0,
    this.fund = 0,
    this.toFund = 0,
    this.income = 0,
    this.expense = 0,
    this.transitIn = 0,
    this.transitOut = 0,
    this.kase = 0,
  });

  final int account, toAccount, fund, toFund;
  final int income, expense, transitIn, transitOut, kase;
}

/// The sign table. A transfer keeps the Fund (account −, toAccount +, each
/// leg in the part's Fund); a Fund transfer keeps the Account. Reversal is
/// not here: it is the original's effects times −1 ([effectsOf]).
const postingSigns = <TransactionType, PostingSign>{
  TransactionType.income: PostingSign(account: 1, fund: 1, income: 1),
  TransactionType.expense: PostingSign(account: -1, fund: -1, expense: 1),
  TransactionType.claimPayment: PostingSign(
    account: -1,
    fund: -1,
    expense: 1,
    kase: -1,
  ),
  TransactionType.advanceIssue: PostingSign(account: -1, fund: -1, kase: 1),
  TransactionType.advanceSpending: PostingSign(expense: 1, kase: -1),
  TransactionType.advanceReturn: PostingSign(account: 1, fund: 1, kase: -1),
  TransactionType.accountTransfer: PostingSign(account: -1, toAccount: 1),
  TransactionType.fundTransfer: PostingSign(fund: -1, toFund: 1),
  TransactionType.transitCollection: PostingSign(
    account: 1,
    fund: 1,
    transitIn: 1,
    kase: 1,
  ),
  TransactionType.transitRemittance: PostingSign(
    account: -1,
    fund: -1,
    transitOut: 1,
    kase: -1,
  ),
  TransactionType.opening: PostingSign(account: 1, fund: 1),
  TransactionType.supplierRefund: PostingSign(account: 1, fund: 1, expense: -1),
  TransactionType.donorReturn: PostingSign(account: -1, fund: -1, income: -1),
};

/// One liquid leg: rupiah in (positive) or out of [fundId]'s share of
/// [accountId]. Account balances, Fund balances and balances by Fund are
/// sums of legs, so account totals equal Fund totals when every leg has both.
class Leg {
  const Leg(this.accountId, this.fundId, this.amount);

  final String? accountId;
  final String? fundId;
  final int amount;
}

/// The effect of one part ([allocation], posted as [type]).
class Effect {
  const Effect({
    required this.type,
    required this.allocation,
    required this.legs,
    this.income = 0,
    this.expense = 0,
    this.transitIn = 0,
    this.transitOut = 0,
    this.caseDelta = 0,
  });

  final TransactionType type;
  final Allocation allocation;
  final List<Leg> legs;
  final int income, expense, transitIn, transitOut;

  /// The change of [Allocation.caseId]'s outstanding amount.
  final int caseDelta;

  /// The net Kas/Bank change of this part across all accounts.
  int get liquid => legs.fold(0, (s, l) => s + l.amount);
}

/// The effects of [t]'s parts by the sign table. A reversal copies its
/// original's parts and types (README 4.6) and takes the opposite sign.
/// Effects count only once [t] is finalized; drafts post nothing (DM 4.1.8).
List<Effect> effectsOf(Transaction t) {
  final f = t.type == TransactionType.reversal ? -1 : 1;
  return [for (final a in t.allocations) _effect(t, a, f)];
}

Effect _effect(Transaction t, Allocation a, int f) {
  final type = a.type ?? (t.type == TransactionType.reversal ? null : t.type);
  final s = postingSigns[type] ?? const PostingSign();
  final m = a.amount * f;
  final account = t.accountOf(a);
  return Effect(
    type: type ?? t.type,
    allocation: a,
    legs: [
      if (s.account != 0) Leg(account, a.fundId, s.account * m),
      if (s.toAccount != 0) Leg(t.toAccountId, a.fundId, s.toAccount * m),
      if (s.fund != 0 && s.account == 0) Leg(account, a.fundId, s.fund * m),
      if (s.toFund != 0) Leg(account, a.toFundId, s.toFund * m),
    ],
    income: s.income * m,
    expense: s.expense * m,
    transitIn: s.transitIn * m,
    transitOut: s.transitOut * m,
    caseDelta: s.kase * m,
  );
}

/// The signed Kas/Bank change of [t] as the lists print it ('−Rp750.000');
/// 0 for transfers.
int signedAmount(Transaction t) => effectsOf(t).fold(0, (s, e) => s + e.liquid);
