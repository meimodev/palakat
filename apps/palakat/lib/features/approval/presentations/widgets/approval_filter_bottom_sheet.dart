import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/approval/presentations/approval_state.dart';
import 'package:palakat_shared/core/constants/date_range_preset.dart';
import 'package:palakat_shared/extensions.dart';

class ApprovalFilterSheetResult {
  const ApprovalFilterSheetResult({
    required this.statusFilter,
    required this.datePreset,
    required this.startDate,
    required this.endDate,
  });

  final ApprovalFilterStatus statusFilter;
  final DateRangePreset datePreset;
  final DateTime? startDate;
  final DateTime? endDate;
}

Future<ApprovalFilterSheetResult?> showApprovalFilterBottomSheet({
  required BuildContext context,
  required ApprovalFilterStatus initialStatus,
  required DateRangePreset initialDatePreset,
  required DateTime? initialStartDate,
  required DateTime? initialEndDate,
}) {
  return showModalBottomSheet<ApprovalFilterSheetResult>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (dialogContext) => _ApprovalFilterBottomSheetContent(
      initialStatus: initialStatus,
      initialDatePreset: initialDatePreset,
      initialStartDate: initialStartDate,
      initialEndDate: initialEndDate,
    ),
  );
}

class _ApprovalFilterBottomSheetContent extends StatefulWidget {
  const _ApprovalFilterBottomSheetContent({
    required this.initialStatus,
    required this.initialDatePreset,
    required this.initialStartDate,
    required this.initialEndDate,
  });

  final ApprovalFilterStatus initialStatus;
  final DateRangePreset initialDatePreset;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  @override
  State<_ApprovalFilterBottomSheetContent> createState() =>
      _ApprovalFilterBottomSheetContentState();
}

class _ApprovalFilterBottomSheetContentState
    extends State<_ApprovalFilterBottomSheetContent> {
  late ApprovalFilterStatus _selectedStatus;
  late DateRangePreset _selectedDatePreset;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedDatePreset = widget.initialDatePreset;
    _selectedStartDate = widget.initialStartDate;
    _selectedEndDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shouldStackActions = MediaQuery.sizeOf(context).width < 420 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.1;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 16.0,
              bottom: 20.0 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.circular(999.0),
                      boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                    ),
                  ),
                ),
                Gap.h16,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.approval_filterSheetTitle,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _resetFilters,
                      child: Text(l10n.approval_filterReset),
                    ),
                  ],
                ),
                Gap.h16,
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SectionLabel(label: l10n.approval_filterSectionStatus),
                        Gap.h8,
                        ...ApprovalFilterStatus.values.map(
                          (status) => Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: _FilterOptionTile(
                              title: _statusLabel(context, status),
                              subtitle: null,
                              selected: _selectedStatus == status,
                              onTap: () {
                                setState(() {
                                  _selectedStatus = status;
                                });
                              },
                            ),
                          ),
                        ),
                        Gap.h8,
                        _SectionLabel(label: l10n.approval_filterSectionDate),
                        Gap.h8,
                        ...DateRangePreset.values.map(
                          (preset) => Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: _FilterOptionTile(
                              title: preset.displayName,
                              subtitle: _dateSubtitle(preset),
                              selected: _selectedDatePreset == preset,
                              onTap: () => _selectDatePreset(context, preset),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Gap.h12,
                if (shouldStackActions) ...[
                  ButtonWidget.outlined(
                    text: l10n.btn_cancel,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Gap.h12,
                  ButtonWidget.primary(
                    text: l10n.approval_filterApply,
                    onTap: _apply,
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: ButtonWidget.outlined(
                          text: l10n.btn_cancel,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: ButtonWidget.primary(
                          text: l10n.approval_filterApply,
                          onTap: _apply,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = ApprovalFilterStatus.all;
      _selectedDatePreset = DateRangePreset.allTime;
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
  }

  Future<void> _selectDatePreset(
    BuildContext context,
    DateRangePreset preset,
  ) async {
    if (preset == DateRangePreset.custom) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        locale: Localizations.localeOf(context),
        initialDateRange: _selectedStartDate != null && _selectedEndDate != null
            ? DateTimeRange(
                start: _selectedStartDate!,
                end: _selectedEndDate!,
              )
            : null,
      );
      if (picked == null) return;
      setState(() {
        _selectedDatePreset = preset;
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      return;
    }

    final range = preset.getDateRange();
    setState(() {
      _selectedDatePreset = preset;
      _selectedStartDate = range?.start;
      _selectedEndDate = range?.end;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      ApprovalFilterSheetResult(
        statusFilter: _selectedStatus,
        datePreset: _selectedDatePreset,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
      ),
    );
  }

  String _statusLabel(BuildContext context, ApprovalFilterStatus status) {
    final l10n = context.l10n;
    switch (status) {
      case ApprovalFilterStatus.all:
        return l10n.approval_filterAll;
      case ApprovalFilterStatus.pendingMyAction:
        return l10n.approval_filterMyAction;
      case ApprovalFilterStatus.pendingOthers:
        return l10n.approval_filterPendingOthers;
      case ApprovalFilterStatus.approved:
        return l10n.status_approved;
      case ApprovalFilterStatus.rejected:
        return l10n.status_rejected;
    }
  }

  String? _dateSubtitle(DateRangePreset preset) {
    if (preset == DateRangePreset.allTime) {
      return null;
    }

    final range = switch (preset) {
      DateRangePreset.custom when _selectedStartDate != null && _selectedEndDate != null =>
        DateTimeRange(start: _selectedStartDate!, end: _selectedEndDate!),
      _ => preset.getDateRange(),
    };

    if (range == null) {
      return null;
    }

    final start = range.start;
    final end = range.end;
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return start.slashDate;
    }
    return '${start.slashDate} • ${end.slashDate}';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  const _FilterOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.10)
          : AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: selected
                  ? colors.primary.withValues(alpha: 0.36)
                  : AppColors.outlineVariant,
            ),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      Gap.h4,
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Gap.w12,
              Container(
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? colors.primary
                      : AppColors.surfaceContainerLowest,
                  border: Border.all(
                    color: selected ? colors.primary : AppColors.outlineVariant,
                  ),
                ),
                child: selected
                    ? Icon(Icons.check, size: 14.0, color: colors.onPrimary)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
