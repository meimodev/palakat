import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/themes/size_constant.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/approval/presentations/approval_controller.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_card_widget.dart';

class ApprovalScreen extends ConsumerWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(approvalControllerProvider);

    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(title: "Approvals"),
          Gap.h16,
          // Filter input (uses shared InputWidget for consistent styling)
          InputWidget<_DateRangePreset>.dropdown(
            label: 'Filter by date',
            hint: _formatRange(state.filterStartDate, state.filterEndDate),
            currentInputValue: _detectPreset(state.filterStartDate, state.filterEndDate),
            options: _DateRangePreset.values,
            optionLabel: (p) => _labelForPreset(p),
            onChanged: (p) async {
              await _applyPreset(context, ref, p, state.filterStartDate, state.filterEndDate);
            },
            onPressedWithResult: () async {
              return await _pickPresetBottomSheet(
                context,
                current: _detectPreset(state.filterStartDate, state.filterEndDate),
                start: state.filterStartDate,
                end: state.filterEndDate,
              );
            },
          ),
          Gap.h12,
          // Render activities (migrated from approvals)
          ...state.filteredApprovals.map((approval) {
            final title = approval.title;

            return Padding(
              padding: EdgeInsets.only(bottom: BaseSize.h12),
              child: ApprovalCardWidget(
                approval: approval,
                currentMembershipId: state.membership?.id,
                onTap: () {
                  context.pushNamed(
                    AppRoute.approvalDetail,
                    extra: RouteParam(
                      params: {
                        'activityId': approval.id,
                        'currentMembershipId': state.membership?.id,
                      },
                    ),
                  );
                },
                onApprove: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Approved: $title')),
                  );
                },
                onReject: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rejected: $title')),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

String _formatRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) return 'All dates';
  final s = start ?? end!;
  final e = end ?? start!;
  final sStr = _fmt(s);
  final eStr = _fmt(e);
  return sStr == eStr ? sStr : '$sStr - $eStr';
}

String _fmt(DateTime d) {
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

enum _DateRangePreset { all, today, last7, last30, thisMonth, lastMonth, thisYear, custom }

_DateRangePreset _detectPreset(DateTime? start, DateTime? end) {
  if (start == null && end == null) return _DateRangePreset.all;
  if (start == null || end == null) return _DateRangePreset.custom;
  final now = DateTime.now();
  final s = _startOfDay(start);
  final e = _endOfDay(end);
  final todayS = _startOfDay(now);
  final todayE = _endOfDay(now);

  bool sameDay(DateTime aS, DateTime aE, DateTime bS, DateTime bE) => aS == bS && aE == bE;

  if (sameDay(s, e, todayS, todayE)) return _DateRangePreset.today;

  if (s == _startOfDay(now.subtract(const Duration(days: 6))) && e == todayE) {
    return _DateRangePreset.last7;
  }
  if (s == _startOfDay(now.subtract(const Duration(days: 29))) && e == todayE) {
    return _DateRangePreset.last30;
  }

  final thisMonthStart = DateTime(now.year, now.month, 1);
  final thisMonthEnd = _endOfDay(DateTime(now.year, now.month + 1, 0));
  if (s == thisMonthStart && e == thisMonthEnd) return _DateRangePreset.thisMonth;

  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final lastMonthEnd = _endOfDay(DateTime(now.year, now.month, 0));
  if (s == lastMonthStart && e == lastMonthEnd) return _DateRangePreset.lastMonth;

  final thisYearStart = DateTime(now.year, 1, 1);
  final thisYearEnd = _endOfDay(DateTime(now.year, 12, 31));
  if (s == thisYearStart && e == thisYearEnd) return _DateRangePreset.thisYear;

  return _DateRangePreset.custom;
}

String _labelForPreset(_DateRangePreset p) {
  switch (p) {
    case _DateRangePreset.all:
      return 'All dates';
    case _DateRangePreset.today:
      return 'Today';
    case _DateRangePreset.last7:
      return 'Last 7 days';
    case _DateRangePreset.last30:
      return 'Last 30 days';
    case _DateRangePreset.thisMonth:
      return 'This month';
    case _DateRangePreset.lastMonth:
      return 'Last month';
    case _DateRangePreset.thisYear:
      return 'This year';
    case _DateRangePreset.custom:
      return 'Custom range…';
  }
}

Future<void> _applyPreset(
  BuildContext context,
  WidgetRef ref,
  _DateRangePreset preset,
  DateTime? currentStart,
  DateTime? currentEnd,
) async {
  final notifier = ref.read(approvalControllerProvider.notifier);
  final now = DateTime.now();
  switch (preset) {
    case _DateRangePreset.all:
      notifier.clearDateFilter();
      break;
    case _DateRangePreset.today:
      notifier.setDateRange(start: _startOfDay(now), end: _endOfDay(now));
      break;
    case _DateRangePreset.last7:
      notifier.setDateRange(
        start: _startOfDay(now.subtract(const Duration(days: 6))),
        end: _endOfDay(now),
      );
      break;
    case _DateRangePreset.last30:
      notifier.setDateRange(
        start: _startOfDay(now.subtract(const Duration(days: 29))),
        end: _endOfDay(now),
      );
      break;
    case _DateRangePreset.thisMonth:
      notifier.setDateRange(
        start: DateTime(now.year, now.month, 1),
        end: _endOfDay(DateTime(now.year, now.month + 1, 0)),
      );
      break;
    case _DateRangePreset.lastMonth:
      notifier.setDateRange(
        start: DateTime(now.year, now.month - 1, 1),
        end: _endOfDay(DateTime(now.year, now.month, 0)),
      );
      break;
    case _DateRangePreset.thisYear:
      notifier.setDateRange(
        start: DateTime(now.year, 1, 1),
        end: _endOfDay(DateTime(now.year, 12, 31)),
      );
      break;
    case _DateRangePreset.custom:
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDateRange: (currentStart != null || currentEnd != null)
            ? DateTimeRange(
                start: currentStart ?? currentEnd!,
                end: currentEnd ?? currentStart!,
              )
            : null,
      );
      if (picked != null) {
        notifier.setDateRange(start: picked.start, end: picked.end);
      }
      break;
  }
}

Future<_DateRangePreset?> _pickPresetBottomSheet(
  BuildContext context, {
  required _DateRangePreset current,
  required DateTime? start,
  required DateTime? end,
}) async {
  return showModalBottomSheet<_DateRangePreset>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    shape: ContinuousRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(BaseSize.radiusXl)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._DateRangePreset.values.map((p) {
              final selected = p == current;
              return ListTile(
                title: Text(_labelForPreset(p)),
                trailing: selected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(p),
              );
            }),
          ],
        ),
      );
    },
  );
}

