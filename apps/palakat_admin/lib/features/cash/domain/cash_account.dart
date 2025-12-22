class CashAccount {
  final int? id;
  final String name;
  final String currency;
  final int openingBalance;
  final int? balance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CashAccount({
    this.id,
    required this.name,
    required this.currency,
    required this.openingBalance,
    this.balance,
    this.createdAt,
    this.updatedAt,
  });

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _asDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory CashAccount.fromJson(Map<String, dynamic> json) {
    return CashAccount(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      currency: (json['currency'] ?? 'IDR').toString(),
      openingBalance: _asInt(json['openingBalance']) ?? 0,
      balance: _asInt(json['balance']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'currency': currency,
      'openingBalance': openingBalance,
      if (balance != null) 'balance': balance,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
