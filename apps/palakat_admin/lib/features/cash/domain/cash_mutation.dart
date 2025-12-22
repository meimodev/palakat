import 'cash_account.dart';

enum CashMutationType { in_, out, transfer, adjustment }

extension CashMutationTypeApi on CashMutationType {
  String get apiValue {
    switch (this) {
      case CashMutationType.in_:
        return 'IN';
      case CashMutationType.out:
        return 'OUT';
      case CashMutationType.transfer:
        return 'TRANSFER';
      case CashMutationType.adjustment:
        return 'ADJUSTMENT';
    }
  }

  static CashMutationType? fromApiValue(String? value) {
    switch (value) {
      case 'IN':
        return CashMutationType.in_;
      case 'OUT':
        return CashMutationType.out;
      case 'TRANSFER':
        return CashMutationType.transfer;
      case 'ADJUSTMENT':
        return CashMutationType.adjustment;
      default:
        return null;
    }
  }
}

class CashMutationCreatedBy {
  final int? id;
  final String? name;

  const CashMutationCreatedBy({this.id, this.name});

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory CashMutationCreatedBy.fromJson(Map<String, dynamic> json) {
    return CashMutationCreatedBy(
      id: _asInt(json['id']),
      name: json['name']?.toString(),
    );
  }
}

class CashMutation {
  final int? id;
  final CashMutationType type;
  final int amount;
  final int? fromAccountId;
  final int? toAccountId;
  final DateTime happenedAt;
  final String? note;
  final DateTime? createdAt;

  final CashAccount? fromAccount;
  final CashAccount? toAccount;
  final CashMutationCreatedBy? createdBy;

  const CashMutation({
    this.id,
    required this.type,
    required this.amount,
    this.fromAccountId,
    this.toAccountId,
    required this.happenedAt,
    this.note,
    this.createdAt,
    this.fromAccount,
    this.toAccount,
    this.createdBy,
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

  factory CashMutation.fromJson(Map<String, dynamic> json) {
    final type = CashMutationTypeApi.fromApiValue(json['type']?.toString());
    return CashMutation(
      id: _asInt(json['id']),
      type: type ?? CashMutationType.adjustment,
      amount: _asInt(json['amount']) ?? 0,
      fromAccountId: _asInt(json['fromAccountId']),
      toAccountId: _asInt(json['toAccountId']),
      happenedAt:
          _asDateTime(json['happenedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      note: json['note']?.toString(),
      createdAt: _asDateTime(json['createdAt']),
      fromAccount: json['fromAccount'] is Map<String, dynamic>
          ? CashAccount.fromJson(json['fromAccount'] as Map<String, dynamic>)
          : null,
      toAccount: json['toAccount'] is Map<String, dynamic>
          ? CashAccount.fromJson(json['toAccount'] as Map<String, dynamic>)
          : null,
      createdBy: json['createdBy'] is Map<String, dynamic>
          ? CashMutationCreatedBy.fromJson(
              json['createdBy'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
