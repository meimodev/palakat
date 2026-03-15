import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
import 'package:palakat/features/report/presentations/report_generate/report_generate_controller.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/models/column.dart' as model;

class ReportGenerateScreen extends ConsumerStatefulWidget {
  const ReportGenerateScreen({super.key, this.initialReportType});

  final ReportGenerateType? initialReportType;

  @override
  ConsumerState<ReportGenerateScreen> createState() =>
      _ReportGenerateScreenState();
}

class _ReportGenerateScreenState extends ConsumerState<ReportGenerateScreen> {
  @override
  void initState() {
    super.initState();

    final initial = widget.initialReportType;
    if (initial == null) return;

    Future.microtask(() {
      ref
          .read(reportGenerateControllerProvider.notifier)
          .setReportType(initial);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(reportGenerateControllerProvider.notifier);
    final state = ref.watch(reportGenerateControllerProvider);

    final effectiveRange = state.dateRangePreset == DateRangePreset.custom
        ? state.customDateRange
        : state.dateRangePreset.getDateRange();

    final showDocumentInput =
        state.reportType == ReportGenerateType.incomingDocument ||
        state.reportType == ReportGenerateType.outcomingDocument;
    final showCongregationSubtype =
        state.reportType == ReportGenerateType.congregation;
    final showColumn =
        state.reportType == ReportGenerateType.congregation ||
        state.reportType == ReportGenerateType.activity ||
        state.reportType == ReportGenerateType.financial;
    final showActivityType = state.reportType == ReportGenerateType.activity;
    final showFinancialSubtype =
        state.reportType == ReportGenerateType.financial;
    final disableColumnSelection =
        (state.reportType == ReportGenerateType.financial &&
            state.financialSubtype == FinancialReportSubtype.mutation) ||
        (state.reportType == ReportGenerateType.congregation &&
            state.congregationSubtype == CongregationReportSubtype.wartaJemaat);

    return ScaffoldWidget(
      disableSingleChildScrollView: false,
      persistBottomWidget: OperationsReveal(
        delay: const Duration(milliseconds: 140),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: BaseSize.h24,
            left: BaseSize.w12,
            right: BaseSize.w12,
            top: BaseSize.h6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OperationsAnimatedPresence(
                visible: state.cooldownRemainingSeconds > 0,
                child: _CooldownBanner(
                  remainingSeconds: state.cooldownRemainingSeconds,
                ),
              ),
              if (state.cooldownRemainingSeconds > 0) Gap.h12,
              Text(
                l10n.msg_reportGenerationMayTakeAWhile,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.textSecondary,
                ),
              ),
              Gap.h12,
              ButtonWidget.primary(
                text: l10n.btn_generateReport,
                isLoading: state.isGenerating,
                onTap: state.cooldownRemainingSeconds > 0 || state.isGenerating
                    ? null
                    : () async {
                        final job = await controller.queueReport();

                        if (!context.mounted) return;

                        final next = ref.read(reportGenerateControllerProvider);

                        if (job == null) {
                          final remaining = next.cooldownRemainingSeconds;
                          final error = next.errorMessage;

                          if (remaining > 0) {
                            _showSnackBar(
                              context,
                              '${l10n.msg_slowDown}. ${l10n.msg_tryAgainLater}',
                            );
                            return;
                          }

                          if (error != null && error.trim().isNotEmpty) {
                            _showSnackBar(context, error);
                          }
                          return;
                        }

                        _showSnackBar(context, l10n.msg_reportQueued);

                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (context.mounted) {
                            context.pop();
                          }
                        });
                      },
              ),
            ],
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OperationsReveal(
            child: ScreenTitleWidget.primary(
              title: l10n.drawer_generateReport_title,
              leadIcon: AppIcons.back,
              leadIconColor: BaseColor.textPrimary,
              onPressedLeadIcon: context.pop,
            ),
          ),
          Gap.h16,
          OperationsAnimatedPresence(
            visible:
                state.errorMessage != null &&
                state.errorMessage!.trim().isNotEmpty,
            child: _ErrorBanner(message: state.errorMessage ?? ''),
          ),
          if (state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty)
            Gap.h16,

          OperationsReveal(
            delay: const Duration(milliseconds: 40),
            child: InputWidget<ReportGenerateType>.dropdown(
              label: l10n.lbl_reportType,
              hint: l10n.lbl_reportType,
              currentInputValue: state.reportType,
              options: const [
                ReportGenerateType.incomingDocument,
                ReportGenerateType.outcomingDocument,
                ReportGenerateType.congregation,
                ReportGenerateType.activity,
                ReportGenerateType.financial,
              ],
              optionLabel: (t) => _reportTypeLabel(context, t),
              onChanged: controller.setReportType,
              onPressedWithResult: () async {
                return await _showEnumBottomSheet<ReportGenerateType>(
                  context,
                  title: l10n.lbl_reportType,
                  options: const [
                    ReportGenerateType.incomingDocument,
                    ReportGenerateType.outcomingDocument,
                    ReportGenerateType.congregation,
                    ReportGenerateType.activity,
                    ReportGenerateType.financial,
                  ],
                  current: state.reportType,
                  optionLabel: (t) => _reportTypeLabel(context, t),
                );
              },
            ),
          ),

          Gap.h12,

          OperationsReveal(
            delay: const Duration(milliseconds: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showDocumentInput) ...[
                  InputWidget<DocumentInput>.binaryOption(
                    label: l10n.lbl_documentInput,
                    options: DocumentInput.values,
                    currentInputValue: state.documentInput,
                    onChanged: controller.setDocumentInput,
                    optionLabel: (v) => switch (v) {
                      DocumentInput.income => l10n.documentInput_income,
                      DocumentInput.outcome => l10n.documentInput_outcome,
                    },
                  ),
                  Gap.h12,
                ],
                if (showCongregationSubtype) ...[
                  InputWidget<CongregationReportSubtype>.dropdown(
                    label: l10n.lbl_congregationSubtype,
                    hint: l10n.lbl_congregationSubtype,
                    currentInputValue: state.congregationSubtype,
                    options: CongregationReportSubtype.values,
                    optionLabel: (s) => _congregationSubtypeLabel(context, s),
                    onChanged: controller.setCongregationSubtype,
                    onPressedWithResult: () async {
                      return await _showEnumBottomSheet<
                        CongregationReportSubtype
                      >(
                        context,
                        title: l10n.lbl_congregationSubtype,
                        options: CongregationReportSubtype.values,
                        current: state.congregationSubtype,
                        optionLabel: (s) =>
                            _congregationSubtypeLabel(context, s),
                      );
                    },
                  ),
                  Gap.h12,
                ],
                if (showFinancialSubtype) ...[
                  InputWidget<FinancialReportSubtype>.binaryOption(
                    label: l10n.lbl_financialSubtype,
                    options: FinancialReportSubtype.values,
                    currentInputValue: state.financialSubtype,
                    onChanged: controller.setFinancialSubtype,
                    optionLabel: (t) => t.displayName,
                  ),
                  Gap.h12,
                ],
                DateRangePresetInput(
                  label: l10n.lbl_dateRange,
                  preset: state.dateRangePreset,
                  start: effectiveRange?.start,
                  end: effectiveRange?.end,
                  allowedPresets: DateRangePreset.values
                      .where((p) => p != DateRangePreset.allTime)
                      .toList(),
                  onPresetChanged: controller.setDateRangePreset,
                  onCustomDateRangeSelected: controller.setCustomDateRange,
                  onChanged: (start, end) {},
                ),
              ],
            ),
          ),

          Gap.h12,

          OperationsReveal(
            delay: const Duration(milliseconds: 100),
            child: InputWidget<ReportFormat>.binaryOption(
              label: l10n.lbl_type,
              options: ReportFormat.values,
              currentInputValue: state.format,
              onChanged: controller.setFormat,
              optionLabel: (f) => f.name.toUpperCase(),
            ),
          ),

          Gap.h12,

          OperationsReveal(
            delay: const Duration(milliseconds: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showColumn) ...[
                  Opacity(
                    opacity: disableColumnSelection ? 0.6 : 1,
                    child: IgnorePointer(
                      ignoring: disableColumnSelection,
                      child: InputWidget<model.Column?>.dropdown(
                        label: l10n.lbl_selectColumn,
                        hint: l10n.approval_filterAll,
                        currentInputValue: state.selectedColumn,
                        options: const <model.Column?>[null],
                        optionLabel: (c) => c?.name ?? l10n.approval_filterAll,
                        onChanged: controller.setSelectedColumn,
                        onPressedWithResult: () async {
                          final churchId = state.churchId;
                          if (churchId == null) {
                            _showSnackBar(context, l10n.lbl_selectChurchFirst);
                            return null;
                          }
                          return await showDialogColumnPickerWidget(
                            context: context,
                            churchId: churchId,
                          );
                        },
                      ),
                    ),
                  ),
                  if (state.selectedColumn != null &&
                      !disableColumnSelection) ...[
                    Gap.h8,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ButtonWidget.text(
                        text: l10n.btn_clear,
                        onTap: () => controller.setSelectedColumn(null),
                      ),
                    ),
                  ],
                  Gap.h12,
                ],
                if (showActivityType) ...[
                  InputWidget<ActivityType?>.dropdown(
                    label: l10n.lbl_activityType,
                    hint: l10n.filter_activityType_allTitle,
                    currentInputValue: state.activityType,
                    options: <ActivityType?>[null, ...ActivityType.values],
                    optionLabel: (t) =>
                        t?.displayName ?? l10n.filter_activityType_allTitle,
                    onChanged: controller.setActivityType,
                    onPressedWithResult: () async {
                      return await _showEnumBottomSheet<ActivityType?>(
                        context,
                        title: l10n.lbl_activityType,
                        options: <ActivityType?>[null, ...ActivityType.values],
                        current: state.activityType,
                        optionLabel: (t) =>
                            t?.displayName ?? l10n.filter_activityType_allTitle,
                      );
                    },
                  ),
                  Gap.h12,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _reportTypeLabel(BuildContext context, ReportGenerateType t) {
    final l10n = context.l10n;
    switch (t) {
      case ReportGenerateType.incomingDocument:
        return l10n.reportType_incomingDocument;
      case ReportGenerateType.outcomingDocument:
        return l10n.reportType_outcomingDocument;
      case ReportGenerateType.congregation:
        return l10n.reportType_congregation;
      case ReportGenerateType.activity:
        return l10n.reportType_activity;
      case ReportGenerateType.financial:
        return l10n.reportType_financial;
      case ReportGenerateType.services:
        return l10n.reportType_services;
    }
  }

  static String _congregationSubtypeLabel(
    BuildContext context,
    CongregationReportSubtype s,
  ) {
    final l10n = context.l10n;
    switch (s) {
      case CongregationReportSubtype.wartaJemaat:
        return l10n.congregationSubtype_wartaJemaat;
      case CongregationReportSubtype.hutJemaat:
        return l10n.congregationSubtype_hutJemaat;
      case CongregationReportSubtype.keanggotaan:
        return l10n.congregationSubtype_keanggotaan;
    }
  }

  static Future<T?> _showEnumBottomSheet<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required T current,
    required String Function(T) optionLabel,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w16,
                  vertical: BaseSize.h8,
                ),
                child: Text(
                  title,
                  style: BaseTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...options.map(
                (o) => ListTile(
                  title: Text(optionLabel(o)),
                  trailing: o == current ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(context).pop<T>(o),
                ),
              ),
              SizedBox(height: BaseSize.h12),
            ],
          ),
        );
      },
    );
  }

  static void _showSnackBar(BuildContext context, String msg) {
    if (msg.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}

class _CooldownBanner extends StatelessWidget {
  const _CooldownBanner({required this.remainingSeconds});

  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Material(
      color: BaseColor.yellow.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        side: BorderSide(color: BaseColor.yellow.shade200),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldStack =
              constraints.maxWidth < 260 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.1;

          final icon = Container(
            width: BaseSize.w36,
            height: BaseSize.w36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BaseColor.yellow.shade100,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            ),
            child: Icon(
              AppIcons.pending,
              color: BaseColor.warning,
              size: BaseSize.w18,
            ),
          );

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.msg_slowDown,
                style: BaseTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BaseColor.warning,
                ),
                maxLines: shouldStack ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap.h4,
              Text(
                '${l10n.msg_tryAgainLater} ($minutes:$seconds)',
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.textSecondary,
                ),
                maxLines: shouldStack ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

          return Padding(
            padding: EdgeInsets.all(BaseSize.w12),
            child: shouldStack
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [icon, Gap.h12, content],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      icon,
                      Gap.w12,
                      Expanded(child: content),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(message: message, padding: EdgeInsets.zero);
  }
}
