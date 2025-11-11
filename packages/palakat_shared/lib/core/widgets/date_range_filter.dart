import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilter extends StatelessWidget {
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange> onChanged;
  final VoidCallback onClear;
  final String label;

  const DateRangeFilter({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onClear,
    this.label = 'Date range',
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? label
        : '${DateFormat('y-MM-dd').format(value!.start)} - ${DateFormat('y-MM-dd').format(value!.end)}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            final now = DateTime.now();
            final initial = value ?? DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000, 1, 1),
              lastDate: DateTime(2100, 12, 31),
              initialDateRange: initial,
            );
            if (picked != null) onChanged(picked);
          },
          icon: const Icon(Icons.date_range),
          label: Text(text),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<_Preset>(
          tooltip: 'Quick ranges',
          onSelected: (p) {
            final range = _computePreset(p);
            onChanged(range);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: _Preset.thisWeek, child: Text('This week')),
            PopupMenuItem(value: _Preset.lastWeek, child: Text('Last week')),
            PopupMenuItem(value: _Preset.thisMonth, child: Text('This month')),
            PopupMenuItem(value: _Preset.lastMonth, child: Text('Last month')),
          ],
          icon: const Icon(Icons.expand_more),
        ),
        if (value != null) ...[
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Clear date range',
            onPressed: onClear,
            icon: const Icon(Icons.clear),
          ),
        ],
      ],
    );
  }
}

enum _Preset { thisWeek, lastWeek, thisMonth, lastMonth }

DateTimeRange _computePreset(_Preset preset) {
  final now = DateTime.now();
  DateTime start;
  DateTime end;
  switch (preset) {
    case _Preset.thisWeek:
      final weekday = now.weekday; // Mon=1...Sun=7
      start = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
      end = start.add(const Duration(days: 6));
      break;
    case _Preset.lastWeek:
      final weekday = now.weekday;
      final thisWeekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
      start = thisWeekStart.subtract(const Duration(days: 7));
      end = thisWeekStart.subtract(const Duration(days: 1));
      break;
    case _Preset.thisMonth:
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0);
      break;
    case _Preset.lastMonth:
      final thisMonthStart = DateTime(now.year, now.month, 1);
      start = DateTime(thisMonthStart.year, thisMonthStart.month - 1, 1);
      end = DateTime(thisMonthStart.year, thisMonthStart.month, 0);
      break;
  }
  return DateTimeRange(start: start, end: end);
}
