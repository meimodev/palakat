import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/features/church/church.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' as cm show Column;
import 'package:palakat_admin/widgets.dart';

class ReportGenerateDrawer extends ConsumerStatefulWidget {
  final String reportType;
  final VoidCallback onClose;
  final Future<void> Function(
    DateTimeRange? range,
    ReportFormat format,
    DocumentInput? input,
    CongregationReportSubtype? congregationSubtype,
    int? columnId,
    ActivityType? activityType,
    FinancialReportSubtype? financialSubtype,
  )?
  onGenerate;

  const ReportGenerateDrawer({
    super.key,
    required this.reportType,
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
  DocumentInput _documentInput = DocumentInput.income;
  CongregationReportSubtype _congregationSubtype =
      CongregationReportSubtype.wartaJemaat;
  ActivityType? _activityType;
  FinancialReportSubtype _financialSubtype = FinancialReportSubtype.revenue;
  cm.Column? _selectedColumn;
  bool _generating = false;
  String? _errorMessage;
  String? _emptyResultMessage;

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

  bool _isNoMatchMessage(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('no ') &&
        normalized.contains('matched') &&
        normalized.contains('report configuration');
  }

  String _resolveErrorMessage(Object error) {
    final text = error.toString().trim();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length).trim();
    }
    return text.isEmpty ? context.l10n.msg_generateReportFailed : text;
  }

  Future<void> _generateReport() async {
    final effectiveRange = _getEffectiveDateRange();
    if (effectiveRange == null) {
      setState(() {
        _errorMessage = context.l10n.validation_invalidRange;
      });
      return;
    }

    setState(() {
      _generating = true;
      _errorMessage = null;
      _emptyResultMessage = null;
    });

    try {
      if (widget.onGenerate != null) {
        final includeColumn =
            (widget.reportType == 'CONGREGATION' ||
                widget.reportType == 'ACTIVITY' ||
                widget.reportType == 'FINANCIAL') &&
            (widget.reportType != 'FINANCIAL' ||
                _financialSubtype != FinancialReportSubtype.mutation) &&
            (widget.reportType != 'CONGREGATION' ||
                _congregationSubtype != CongregationReportSubtype.wartaJemaat);
        await widget.onGenerate!(
          effectiveRange,
          _format,
          widget.reportType == 'DOCUMENT' ? _documentInput : null,
          widget.reportType == 'CONGREGATION' ? _congregationSubtype : null,
          includeColumn ? _selectedColumn?.id : null,
          widget.reportType == 'ACTIVITY' ? _activityType : null,
          widget.reportType == 'FINANCIAL' ? _financialSubtype : null,
        );
      }
      if (!mounted) return;

      // Close immediately without resetting state - let the close happen first
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      final message = _resolveErrorMessage(e);
      setState(() {
        if (_isNoMatchMessage(message)) {
          _emptyResultMessage = message;
          _errorMessage = null;
        } else {
          _errorMessage = message;
          _emptyResultMessage = null;
        }
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

    final churchState = ref.watch(churchControllerProvider);
    final availableColumns = churchState.columns.value ?? const <cm.Column>[];

    final showDocumentInput = widget.reportType == 'DOCUMENT';
    final showCongregationSubtype = widget.reportType == 'CONGREGATION';
    final showColumnDropdown =
        widget.reportType == 'CONGREGATION' ||
        widget.reportType == 'ACTIVITY' ||
        widget.reportType == 'FINANCIAL';
    final showActivityType = widget.reportType == 'ACTIVITY';
    final showFinancialSubtype = widget.reportType == 'FINANCIAL';
    final enableColumnDropdown =
        (widget.reportType != 'FINANCIAL' ||
            _financialSubtype != FinancialReportSubtype.mutation) &&
        (widget.reportType != 'CONGREGATION' ||
            _congregationSubtype != CongregationReportSubtype.wartaJemaat);

    return SideDrawer(
      title: l10n.drawer_generateReport_title,
      subtitle: l10n.drawer_generateReport_subtitle,
      onClose: widget.onClose,
      isLoading: _generating,
      loadingMessage: l10n.loading_please_wait,
      errorMessage: _emptyResultMessage == null ? _errorMessage : null,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_emptyResultMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.msg_reportNoMatchInfoTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.msg_reportNoMatchInfoSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (showColumnDropdown) ...[
            LabeledField(
              label: l10n.lbl_selectColumn,
              child: DropdownButtonFormField<cm.Column?>(
                initialValue: _selectedColumn,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(Icons.view_column_outlined, size: 18),
                ),
                items: [
                  DropdownMenuItem<cm.Column?>(
                    value: null,
                    child: Text(l10n.approval_filterAll),
                  ),
                  ...availableColumns.map(
                    (c) => DropdownMenuItem<cm.Column?>(
                      value: c,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: enableColumnDropdown
                    ? (value) {
                        setState(() => _selectedColumn = value);
                      }
                    : null,
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (showDocumentInput) ...[
            LabeledField(
              label: l10n.lbl_documentInput,
              child: DropdownButtonFormField<DocumentInput>(
                initialValue: _documentInput,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(Icons.swap_horiz, size: 18),
                ),
                items: [
                  DropdownMenuItem(
                    value: DocumentInput.income,
                    child: Text(l10n.documentInput_income),
                  ),
                  DropdownMenuItem(
                    value: DocumentInput.outcome,
                    child: Text(l10n.documentInput_outcome),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _documentInput = value);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (showCongregationSubtype) ...[
            LabeledField(
              label: l10n.lbl_congregationSubtype,
              child: DropdownButtonFormField<CongregationReportSubtype>(
                initialValue: _congregationSubtype,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(Icons.list_alt_outlined, size: 18),
                ),
                items: [
                  DropdownMenuItem(
                    value: CongregationReportSubtype.wartaJemaat,
                    child: Text(l10n.congregationSubtype_wartaJemaat),
                  ),
                  DropdownMenuItem(
                    value: CongregationReportSubtype.hutJemaat,
                    child: Text(l10n.congregationSubtype_hutJemaat),
                  ),
                  DropdownMenuItem(
                    value: CongregationReportSubtype.keanggotaan,
                    child: Text(l10n.congregationSubtype_keanggotaan),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _congregationSubtype = value;
                    if (value == CongregationReportSubtype.wartaJemaat) {
                      _selectedColumn = null;
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (showActivityType) ...[
            LabeledField(
              label: l10n.lbl_activityType,
              child: DropdownButtonFormField<ActivityType?>(
                initialValue: _activityType,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(Icons.category_outlined, size: 18),
                ),
                items: [
                  DropdownMenuItem<ActivityType?>(
                    value: null,
                    child: Text(l10n.filter_activityType_allTitle),
                  ),
                  ...ActivityType.values.map(
                    (t) => DropdownMenuItem<ActivityType?>(
                      value: t,
                      child: Text(t.displayName),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _activityType = value);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (showFinancialSubtype) ...[
            LabeledField(
              label: l10n.lbl_financialSubtype,
              child: DropdownButtonFormField<FinancialReportSubtype>(
                initialValue: _financialSubtype,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 18,
                  ),
                ),
                items: FinancialReportSubtype.values
                    .map(
                      (t) => DropdownMenuItem<FinancialReportSubtype>(
                        value: t,
                        child: Text(t.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _financialSubtype = value;
                    if (value == FinancialReportSubtype.mutation) {
                      _selectedColumn = null;
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          LabeledField(
            label: l10n.lbl_dateRange,
            child: Builder(
              builder: (context) {
                final effective = _getEffectiveDateRange();
                return DateRangePresetInput(
                  label: '',
                  hint: l10n.lbl_dateRange,
                  preset: _dateRangePreset,
                  start: effective?.start,
                  end: effective?.end,
                  allowedPresets: DateRangePreset.values
                      .where((p) => p != DateRangePreset.allTime)
                      .toList(),
                  onCustomDateRangeSelected: (range) {
                    setState(() => _customDateRange = range);
                  },
                  onPresetChanged: (preset) {
                    setState(() {
                      _dateRangePreset = preset;
                      if (preset != DateRangePreset.custom) {
                        _customDateRange = null;
                      }
                    });
                  },
                  onChanged: (start, end) {},
                );
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
                          l10n.validation_invalidRange,
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
          const SizedBox(height: 12),
          LabeledField(
            label: l10n.lbl_format,
            child: DropdownButtonFormField<ReportFormat>(
              initialValue: _format,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
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

          const SizedBox(height: 24),

          InfoBoxWidget(message: l10n.msg_reportGenerationMayTakeAWhile),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: _generateReport,
            icon: const Icon(Icons.assessment),
            label: Text(l10n.btn_generateReport),
          ),
        ],
      ),
    );
  }
}
