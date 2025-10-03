import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/constants.dart';

part 'report.freezed.dart';
part 'report.g.dart';

@freezed
abstract class Report with _$Report {
  const factory Report({
    required String id,
    required String title,
    required ReportType type,
    required DateTime generatedDate,
    required Map<String, dynamic> data,
    String? description,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.income:
        return 'Income Report';
      case ReportType.expense:
        return 'Expense Report';
      case ReportType.inventory:
        return 'Inventory Report';
    }
  }

  String get description {
    switch (this) {
      case ReportType.income:
        return 'Generate detailed income and donation reports';
      case ReportType.expense:
        return 'Generate expense and spending reports';
      case ReportType.inventory:
        return 'Generate inventory and asset reports';
    }
  }
}

@freezed
abstract class IncomeReportData with _$IncomeReportData {
  const factory IncomeReportData({
    required double totalIncome,
    required double donations,
    required double tithes,
    required double offerings,
    required double otherIncome,
    required List<IncomeItem> items,
  }) = _IncomeReportData;

  factory IncomeReportData.fromJson(Map<String, dynamic> json) =>
      _$IncomeReportDataFromJson(json);
}

@freezed
abstract class ExpenseReportData with _$ExpenseReportData {
  const factory ExpenseReportData({
    required double totalExpense,
    required double utilities,
    required double maintenance,
    required double supplies,
    required double salaries,
    required double otherExpenses,
    required List<ExpenseItem> items,
  }) = _ExpenseReportData;

  factory ExpenseReportData.fromJson(Map<String, dynamic> json) =>
      _$ExpenseReportDataFromJson(json);
}

@freezed
abstract class InventoryReportData with _$InventoryReportData {
  const factory InventoryReportData({
    required int totalItems,
    required double totalValue,
    required List<InventoryItem> items,
    required Map<String, int> categoryCount,
  }) = _InventoryReportData;

  factory InventoryReportData.fromJson(Map<String, dynamic> json) =>
      _$InventoryReportDataFromJson(json);
}

@freezed
abstract class IncomeItem with _$IncomeItem {
  const factory IncomeItem({
    required String id,
    required String description,
    required double amount,
    required DateTime date,
    required String category,
    String? source,
  }) = _IncomeItem;

  factory IncomeItem.fromJson(Map<String, dynamic> json) =>
      _$IncomeItemFromJson(json);
}

@freezed
abstract class ExpenseItem with _$ExpenseItem {
  const factory ExpenseItem({
    required String id,
    required String description,
    required double amount,
    required DateTime date,
    required String category,
    String? vendor,
  }) = _ExpenseItem;

  factory ExpenseItem.fromJson(Map<String, dynamic> json) =>
      _$ExpenseItemFromJson(json);
}

@freezed
abstract class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    required String name,
    required String category,
    required int quantity,
    required double unitValue,
    required DateTime lastUpdated,
    String? location,
    String? condition,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}
