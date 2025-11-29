import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/input/input_widget.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// A reusable date range preset input that shows a dropdown field. Tapping it
/// opens a bottom sheet with common presets (Today, Last 7 days, etc.) and an
/// option to pick a custom range.
///
/// It renders the currently selected range as the hint. On selection, it calls
/// [onChanged] with the computed start and end dates. Passing `null` for both
/// means "All dates" (no filter).
class DateRangePresetInput extends StatelessWidget {
  const DateRangePresetInput({
    super.key,
    required this.label,
    required this.start,
    required this.end,
    required this.onChanged,
  });

  /// Field label
  final String label;

  /// Currently selected start date (nullable)
  final DateTime? start;

  /// Currently selected end date (nullable)
  final DateTime? end;

  /// Callback invoked when the user selects a preset or custom range.
  final void Function(DateTime? start, DateTime? end) onChanged;

  @override
  Widget build(BuildContext context) {
    final currentPreset = _detectPreset(start, end);

    return InputWidget<_DateRangePreset>.dropdown(
      label: label,
      hint: 'Select date range',
      currentInputValue: currentPreset,
      options: _DateRangePreset.values,
      optionLabel: (_) => _formatRange(start, end),
      customDisplayBuilder: (_) => _buildCustomDisplay(),
      onChanged: (p) async {
        await _applyPreset(context, p, start, end);
      },
      onPressedWithResult: () async {
        return await _pickPresetBottomSheet(
          context,
          current: currentPreset,
          start: start,
          end: end,
        );
      },
    );
  }

  /// Builds custom display widget showing preset label on top and date range below
  Widget _buildCustomDisplay() {
    final preset = _detectPreset(start, end);
    final dateRange = _formatRangeDateOnly(start, end);

    // For "All dates", just show single line
    if (preset == _DateRangePreset.all) {
      return Text(
        'All dates',
        style: BaseTypography.titleMedium.copyWith(
          color: BaseColor.black,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // For custom range, show just the date range
    if (preset == _DateRangePreset.custom) {
      return Text(
        dateRange,
        style: BaseTypography.titleMedium.copyWith(
          color: BaseColor.black,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // For presets, show label on top and date range below
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _labelForPreset(preset),
          style: BaseTypography.titleMedium.copyWith(
            color: BaseColor.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          dateRange,
          style: BaseTypography.bodySmall.copyWith(
            color: BaseColor.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'All dates';

    // Check if it matches a preset and return label + date range
    final preset = _detectPreset(start, end);
    final dateRange = _formatRangeDateOnly(start, end);

    if (preset != _DateRangePreset.custom && preset != _DateRangePreset.all) {
      return '${_labelForPreset(preset)} ($dateRange)';
    }

    // For custom range, show date only
    return dateRange;
  }

  /// Formats date range without time - used for subtitles in bottom sheet
  String _formatRangeDateOnly(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'All dates';
    final s = start ?? end!;
    final e = end ?? start!;
    final sStr = s.ddMmmmYyyy;
    final eStr = e.ddMmmmYyyy;

    return sStr == eStr ? sStr : '$sStr - $eStr';
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  _DateRangePreset _detectPreset(DateTime? start, DateTime? end) {
    if (start == null && end == null) return _DateRangePreset.all;
    if (start == null || end == null) return _DateRangePreset.custom;
    final now = DateTime.now();
    final s = _startOfDay(start);
    final e = _endOfDay(end);
    final todayS = _startOfDay(now);
    final todayE = _endOfDay(now);

    bool sameDay(DateTime aS, DateTime aE, DateTime bS, DateTime bE) =>
        aS == bS && aE == bE;

    if (sameDay(s, e, todayS, todayE)) return _DateRangePreset.today;

    if (s == _startOfDay(now.subtract(const Duration(days: 6))) &&
        e == todayE) {
      return _DateRangePreset.last7;
    }
    if (s == _startOfDay(now.subtract(const Duration(days: 29))) &&
        e == todayE) {
      return _DateRangePreset.last30;
    }

    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = _endOfDay(DateTime(now.year, now.month + 1, 0));
    if (s == thisMonthStart && e == thisMonthEnd)
      return _DateRangePreset.thisMonth;

    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = _endOfDay(DateTime(now.year, now.month, 0));
    if (s == lastMonthStart && e == lastMonthEnd)
      return _DateRangePreset.lastMonth;

    final thisYearStart = DateTime(now.year, 1, 1);
    final thisYearEnd = _endOfDay(DateTime(now.year, 12, 31));
    if (s == thisYearStart && e == thisYearEnd)
      return _DateRangePreset.thisYear;

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

  DateTimeRange? _rangeForPreset(_DateRangePreset preset, DateTime now) {
    switch (preset) {
      case _DateRangePreset.all:
        return null;
      case _DateRangePreset.today:
        return DateTimeRange(start: _startOfDay(now), end: _endOfDay(now));
      case _DateRangePreset.last7:
        return DateTimeRange(
          start: _startOfDay(now.subtract(const Duration(days: 6))),
          end: _endOfDay(now),
        );
      case _DateRangePreset.last30:
        return DateTimeRange(
          start: _startOfDay(now.subtract(const Duration(days: 29))),
          end: _endOfDay(now),
        );
      case _DateRangePreset.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: _endOfDay(DateTime(now.year, now.month + 1, 0)),
        );
      case _DateRangePreset.lastMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: _endOfDay(DateTime(now.year, now.month, 0)),
        );
      case _DateRangePreset.thisYear:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: _endOfDay(DateTime(now.year, 12, 31)),
        );
      case _DateRangePreset.custom:
        return null;
    }
  }

  Future<void> _applyPreset(
    BuildContext context,
    _DateRangePreset preset,
    DateTime? currentStart,
    DateTime? currentEnd,
  ) async {
    final now = DateTime.now();
    switch (preset) {
      case _DateRangePreset.all:
        onChanged(null, null);
        break;
      case _DateRangePreset.today:
        onChanged(_startOfDay(now), _endOfDay(now));
        break;
      case _DateRangePreset.last7:
        onChanged(
          _startOfDay(now.subtract(const Duration(days: 6))),
          _endOfDay(now),
        );
        break;
      case _DateRangePreset.last30:
        onChanged(
          _startOfDay(now.subtract(const Duration(days: 29))),
          _endOfDay(now),
        );
        break;
      case _DateRangePreset.thisMonth:
        onChanged(
          DateTime(now.year, now.month, 1),
          _endOfDay(DateTime(now.year, now.month + 1, 0)),
        );
        break;
      case _DateRangePreset.lastMonth:
        onChanged(
          DateTime(now.year, now.month - 1, 1),
          _endOfDay(DateTime(now.year, now.month, 0)),
        );
        break;
      case _DateRangePreset.thisYear:
        onChanged(
          DateTime(now.year, 1, 1),
          _endOfDay(DateTime(now.year, 12, 31)),
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
          onChanged(picked.start, picked.end);
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BaseSize.radiusXl),
        ),
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
                final now = DateTime.now();
                final range = _rangeForPreset(p, now);
                final showSubtitle =
                    p != _DateRangePreset.custom &&
                    p != _DateRangePreset.all &&
                    range != null;
                return ListTile(
                  title: Text(_labelForPreset(p)),
                  subtitle: showSubtitle
                      ? Text(
                          _formatRangeDateOnly(range.start, range.end),
                          style: BaseTypography.bodySmall.toSecondary,
                        )
                      : null,
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
}

enum _DateRangePreset {
  all,
  today,
  last7,
  last30,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}
