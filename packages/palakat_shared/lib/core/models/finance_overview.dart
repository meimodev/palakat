class FinanceOverview {
  final int totalBalance;
  final int cashBalance;
  final int cashlessBalance;
  final int unconfirmedRevenueAmount;
  final int unconfirmedExpenseAmount;
  final DateTime? lastUpdatedAt;

  const FinanceOverview({
    required this.totalBalance,
    required this.cashBalance,
    required this.cashlessBalance,
    required this.unconfirmedRevenueAmount,
    required this.unconfirmedExpenseAmount,
    required this.lastUpdatedAt,
  });

  factory FinanceOverview.fromJson(Map<String, dynamic> json) {
    return FinanceOverview(
      totalBalance: (json['totalBalance'] as num?)?.toInt() ?? 0,
      cashBalance: (json['cashBalance'] as num?)?.toInt() ?? 0,
      cashlessBalance: (json['cashlessBalance'] as num?)?.toInt() ?? 0,
      unconfirmedRevenueAmount:
          (json['unconfirmedRevenueAmount'] as num?)?.toInt() ?? 0,
      unconfirmedExpenseAmount:
          (json['unconfirmedExpenseAmount'] as num?)?.toInt() ?? 0,
      lastUpdatedAt: json['lastUpdatedAt'] == null
          ? null
          : DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'cashBalance': cashBalance,
      'cashlessBalance': cashlessBalance,
      'unconfirmedRevenueAmount': unconfirmedRevenueAmount,
      'unconfirmedExpenseAmount': unconfirmedExpenseAmount,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }
}
