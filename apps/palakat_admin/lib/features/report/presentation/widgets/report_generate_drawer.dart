import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/widgets.dart';

class ReportGenerateDrawer extends ConsumerStatefulWidget {
  final String reportTitle;
  final String description;
  final VoidCallback onClose;
  final Future<void> Function(DateTimeRange? range, ReportFormat format)?
  onGenerate;

  const ReportGenerateDrawer({
    super.key,
    required this.reportTitle,
    required this.description,
    required this.onClose,
    this.onGenerate,
  });

  @override
  ConsumerState<ReportGenerateDrawer> createState() =>
      _ReportGenerateDrawerState();
}

class _ReportGenerateDrawerState extends ConsumerState<ReportGenerateDrawer> {
  DateRangePreset _dateRangePreset = DateRangePreset.today;
  DateTimeRange? _customDateRange;
  ReportFormat _format = ReportFormat.pdf;
  bool _generating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default to today to avoid accidentally querying all data
  }

  DateTimeRange? _getEffectiveDateRange() {
    if (_dateRangePreset == DateRangePreset.custom &&
        _customDateRange != null) {
      return _customDateRange;
    }
    return _dateRangePreset.getDateRange();
  }

  Future<void> _generateReport() async {
    setState(() {
      _generating = true;
      _errorMessage = null;
    });

    try {
      if (widget.onGenerate != null) {
        await widget.onGenerate!(_getEffectiveDateRange(), _format);
      }
      if (!mounted) return;

      // Close immediately without resetting state - let the close happen first
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = context.l10n.msg_generateReportFailed;
        _generating = false;
      });
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SideDrawer(
      title: l10n.drawer_generateReport_title,
      subtitle: l10n.drawer_generateReport_subtitle,
      onClose: widget.onClose,
      isLoading: _generating,
      loadingMessage: l10n.loading_please_wait,
      errorMessage: _errorMessage,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoSection(
            title: l10n.section_reportDetails,
            children: [
              LabeledField(
                label: l10n.lbl_reportType,
                child: Text(
                  widget.reportTitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: l10n.lbl_description,
                child: Text(
                  widget.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: l10n.lbl_dateRange,
                child: DropdownButtonFormField<DateRangePreset>(
                  value: _dateRangePreset,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    prefixIcon: Icon(Icons.date_range, size: 18),
                  ),
                  items: DateRangePreset.values
                      .where((preset) => preset != DateRangePreset.allTime)
                      .map(
                        (preset) => DropdownMenuItem<DateRangePreset>(
                          value: preset,
                          child: Text(
                            preset.displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (preset) async {
                    if (preset == null) return;

                    if (preset == DateRangePreset.custom) {
                      // Open date picker for custom range
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDateRange:
                            _customDateRange ?? _getEffectiveDateRange(),
                      );
                      if (picked != null) {
                        setState(() {
                          _customDateRange = picked;
                          _dateRangePreset = preset;
                        });
                      }
                    } else {
                      // Use preset date range
                      setState(() {
                        _dateRangePreset = preset;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Format',
                child: DropdownButtonFormField<ReportFormat>(
                  value: _format,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    prefixIcon: Icon(Icons.description_outlined, size: 18),
                  ),
                  items: ReportFormat.values
                      .map(
                        (f) => DropdownMenuItem<ReportFormat>(
                          value: f,
                          child: Text(
                            f.name.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (format) {
                    if (format == null) return;
                    setState(() {
                      _format = format;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final effectiveRange = _getEffectiveDateRange();
                          if (effectiveRange == null) {
                            return Text(
                              l10n.lbl_allTime,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            );
                          }
                          final format = DateFormat.yMMMMEEEEd();
                          return Text(
                            l10n.lbl_dateRangeStartEnd(
                              format.format(effectiveRange.start),
                              format.format(effectiveRange.end),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.msg_reportGenerationMayTakeAWhile,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _generateReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            icon: const Icon(Icons.assessment),
            label: Text(l10n.btn_generateReport),
          ),
        ],
      ),
    );
  }
}
