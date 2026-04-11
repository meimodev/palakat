import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';

class ApprovalItem {
  const ApprovalItem._({
    required this.subjectType,
    this.activity,
    this.financeEntry,
  });

  factory ApprovalItem.activity(Activity activity) {
    return ApprovalItem._(
      subjectType: ApprovalSubjectType.activity,
      activity: activity,
    );
  }

  factory ApprovalItem.finance(FinanceEntry financeEntry) {
    return ApprovalItem._(
      subjectType: financeEntry.type == FinanceEntryType.revenue
          ? ApprovalSubjectType.revenue
          : ApprovalSubjectType.expense,
      financeEntry: financeEntry,
    );
  }

  final ApprovalSubjectType subjectType;
  final Activity? activity;
  final FinanceEntry? financeEntry;

  bool get isActivity => subjectType == ApprovalSubjectType.activity;
  bool get isFinance => !isActivity;
  bool get isRevenue => subjectType == ApprovalSubjectType.revenue;
  bool get isExpense => subjectType == ApprovalSubjectType.expense;

  int? get id => isActivity ? activity?.id : financeEntry?.id;

  String get uniqueKey => '${subjectType.name}-${id ?? 0}';

  List<Approver> get approvers => isActivity
      ? (activity?.approvers ?? const <Approver>[])
      : (financeEntry?.approvers ?? const <Approver>[]);

  Activity? get linkedActivity =>
      isActivity ? activity : financeEntry?.activity;

  int? get linkedActivityId => linkedActivity?.id;

  String get title {
    if (isActivity) {
      return activity?.title ?? '';
    }

    final linkedTitle = financeEntry?.activity?.title.trim();
    if (linkedTitle != null && linkedTitle.isNotEmpty) {
      return linkedTitle;
    }

    final accountNumber = financeEntry?.accountNumber.trim();
    if (accountNumber != null && accountNumber.isNotEmpty) {
      return accountNumber;
    }

    return isRevenue ? 'Revenue' : 'Expense';
  }

  String? get subtitle {
    if (isActivity) {
      return activity?.supervisor.account?.name;
    }

    final supervisorName = financeEntry?.activity?.supervisor.account?.name
        .trim();
    if (supervisorName != null && supervisorName.isNotEmpty) {
      return supervisorName;
    }

    final accountNumber = financeEntry?.accountNumber.trim();
    if (accountNumber != null && accountNumber.isNotEmpty) {
      return accountNumber;
    }

    return null;
  }

  DateTime? get displayDate {
    if (isActivity) {
      return activity?.date;
    }

    return financeEntry?.createdAt ?? financeEntry?.updatedAt;
  }

  DateTime? get createdAtValue =>
      isActivity ? activity?.createdAt : financeEntry?.createdAt;

  DateTime? get updatedAtValue =>
      isActivity ? activity?.updatedAt : financeEntry?.updatedAt;

  ActivityType? get activityType => isActivity
      ? activity?.activityType
      : financeEntry?.activity?.activityType;

  bool get hasRevenueAttachments =>
      isActivity &&
      ((activity?.revenues.isNotEmpty ?? false) ||
          (activity?.hasRevenue ?? false));

  bool get hasExpenseAttachments =>
      isActivity &&
      ((activity?.expenses.isNotEmpty ?? false) ||
          (activity?.hasExpense ?? false));

  int get revenueCount => isActivity ? (activity?.revenues.length ?? 0) : 0;

  int get expenseCount => isActivity ? (activity?.expenses.length ?? 0) : 0;

  int? get amount => isActivity ? null : financeEntry?.amount;

  String? get accountNumber => isActivity ? null : financeEntry?.accountNumber;

  PaymentMethod? get paymentMethod =>
      isFinance ? financeEntry?.paymentMethod : null;
}

enum ApprovalSubjectType { activity, revenue, expense }
