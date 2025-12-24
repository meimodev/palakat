class FinanceOverview {
  final int totalBalance;
  final int cashBalance;
  final int cashlessBalance;
  final DateTime? lastUpdatedAt;

  const FinanceOverview({
    required this.totalBalance,
    required this.cashBalance,
    required this.cashlessBalance,
    required this.lastUpdatedAt,
  });

  factory FinanceOverview.fromJson(Map<String, dynamic> json) {
    return FinanceOverview(
      totalBalance: (json['totalBalance'] as num?)?.toInt() ?? 0,
      cashBalance: (json['cashBalance'] as num?)?.toInt() ?? 0,
      cashlessBalance: (json['cashlessBalance'] as num?)?.toInt() ?? 0,
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
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }
}
