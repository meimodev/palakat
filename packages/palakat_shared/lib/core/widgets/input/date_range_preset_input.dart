import 'package:flutter/material.dart';
import 'package:palakat_shared/core/constants/date_range_preset.dart';
import 'package:palakat_shared/core/extension/extension.dart';

import 'input_widget.dart';

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
    this.hint,
    required this.start,
    required this.end,
    required this.onChanged,
    this.showYear = true,
    this.preset,
    this.onPresetChanged,
    this.onCustomDateRangeSelected,
    this.allowedPresets = const [
      DateRangePreset.allTime,
      DateRangePreset.today,
      DateRangePreset.thisWeek,
      DateRangePreset.thisMonth,
      DateRangePreset.lastWeek,
      DateRangePreset.lastMonth,
      DateRangePreset.custom,
    ],
  });

  /// Field label
  final String label;

  final String? hint;

  /// Currently selected start date (nullable)
  final DateTime? start;

  /// Currently selected end date (nullable)
  final DateTime? end;

  /// Callback invoked when the user selects a preset or custom range.
  final void Function(DateTime? start, DateTime? end) onChanged;

  final bool showYear;

  final DateRangePreset? preset;
  final ValueChanged<DateRangePreset>? onPresetChanged;
  final ValueChanged<DateTimeRange?>? onCustomDateRangeSelected;

  final List<DateRangePreset> allowedPresets;

  @override
  Widget build(BuildContext context) {
    final currentPreset = preset ?? _detectPreset(start, end, allowedPresets);

    return InputWidget<DateRangePreset>.dropdown(
      label: label,
      hint:
          hint ?? (label.isEmpty ? DateRangePreset.allTime.displayName : label),
      currentInputValue: currentPreset,
      options: allowedPresets,
      optionLabel: (p) => p.displayName,
      customDisplayBuilder: (_) => _buildCustomDisplay(context, currentPreset),
      onPressedWithResult: () async {
        final selected = await _pickPresetBottomSheet(
          context,
          current: currentPreset,
          allowedPresets: allowedPresets,
          start: start,
          end: end,
        );

        if (selected == null) return null;

        if (!context.mounted) return null;

        final applied = await _applyPreset(context, selected, start, end);
        if (!applied) return null;

        return selected;
      },
      onChanged: (_) {},
    );
  }

  /// Builds custom display widget showing preset label on top and date range below
  Widget _buildCustomDisplay(BuildContext context, DateRangePreset preset) {
    final theme = Theme.of(context);
    final dateRange = _formatRangeDateOnly(start, end, showYear: showYear);

    // For "All dates", just show single line
    if (preset == DateRangePreset.allTime) {
      return Text(
        preset.displayName,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // For custom range, show just the date range
    if (preset == DateRangePreset.custom) {
      return Text(
        (start == null && end == null) ? preset.displayName : dateRange,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
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
          preset.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          dateRange,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Formats date range without time - used for subtitles in bottom sheet
  String _formatRangeDateOnly(
    DateTime? start,
    DateTime? end, {
    required bool showYear,
  }) {
    if (start == null && end == null) {
      return DateRangePreset.allTime.displayName;
    }
    final s = start ?? end!;
    final e = end ?? start!;
    final sStr = showYear ? s.ddMmmmYyyy : s.ddMmmm;
    final eStr = showYear ? e.ddMmmmYyyy : e.ddMmmm;

    return sStr == eStr ? sStr : '$sStr - $eStr';
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  DateRangePreset _detectPreset(
    DateTime? start,
    DateTime? end,
    List<DateRangePreset> presets,
  ) {
    if (presets.isEmpty) return DateRangePreset.custom;

    if (start == null && end == null) {
      return presets.contains(DateRangePreset.allTime)
          ? DateRangePreset.allTime
          : presets.first;
    }

    if (start == null || end == null) {
      return presets.contains(DateRangePreset.custom)
          ? DateRangePreset.custom
          : presets.first;
    }

    final s = _startOfDay(start);
    final e = _endOfDay(end);

    for (final preset in presets) {
      if (preset == DateRangePreset.custom ||
          preset == DateRangePreset.allTime) {
        continue;
      }
      final range = preset.getDateRange();
      if (range == null) continue;

      if (_startOfDay(range.start) == s && _endOfDay(range.end) == e) {
        return preset;
      }
    }

    return presets.contains(DateRangePreset.custom)
        ? DateRangePreset.custom
        : presets.first;
  }

  Future<bool> _applyPreset(
    BuildContext context,
    DateRangePreset preset,
    DateTime? currentStart,
    DateTime? currentEnd,
  ) async {
    switch (preset) {
      case DateRangePreset.allTime:
        onPresetChanged?.call(DateRangePreset.allTime);
        onChanged(null, null);
        return true;
      case DateRangePreset.custom:
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
        if (picked == null) return false;
        onCustomDateRangeSelected?.call(picked);
        onPresetChanged?.call(DateRangePreset.custom);
        onChanged(picked.start, picked.end);
        return true;
      case DateRangePreset.today:
      case DateRangePreset.thisWeek:
      case DateRangePreset.thisMonth:
      case DateRangePreset.lastWeek:
      case DateRangePreset.lastMonth:
        final range = preset.getDateRange();
        if (range == null) return false;
        onPresetChanged?.call(preset);
        onChanged(range.start, range.end);
        return true;
    }
  }

  Future<DateRangePreset?> _pickPresetBottomSheet(
    BuildContext context, {
    required DateRangePreset current,
    required List<DateRangePreset> allowedPresets,
    required DateTime? start,
    required DateTime? end,
  }) async {
    final theme = Theme.of(context);

    return showModalBottomSheet<DateRangePreset>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        final customSubtitle = (start != null && end != null)
            ? _formatRangeDateOnly(start, end, showYear: showYear)
            : null;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...allowedPresets.map((p) {
                final selected = p == current;
                final range = p.getDateRange();
                final showSubtitle =
                    p != DateRangePreset.custom &&
                    p != DateRangePreset.allTime &&
                    range != null;
                return ListTile(
                  title: Text(p.displayName),
                  subtitle: showSubtitle
                      ? Text(
                          _formatRangeDateOnly(
                            range.start,
                            range.end,
                            showYear: showYear,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : (p == DateRangePreset.custom && customSubtitle != null)
                      ? Text(
                          customSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
