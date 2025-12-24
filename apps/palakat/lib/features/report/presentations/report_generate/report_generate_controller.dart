import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/core/constants/date_range_preset.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/column.dart' as model;
import 'package:palakat_shared/core/models/report.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/repositories.dart';
import 'package:palakat_shared/services.dart';

import 'package:palakat_shared/l10n/generated/app_localizations.dart';

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = localeName.split(RegExp('[_-]')).first;
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
}

class GeneratedReportDownload {
  final Report report;
  final String url;

  const GeneratedReportDownload({required this.report, required this.url});
}

@immutable
class ReportGenerateState {
  final ReportGenerateType reportType;
  final ReportFormat format;
  final DocumentInput documentInput;
  final CongregationReportSubtype congregationSubtype;
  final ActivityType? activityType;
  final FinancialReportSubtype financialSubtype;
  final DateRangePreset dateRangePreset;
  final DateTimeRange? customDateRange;
  final model.Column? selectedColumn;
  final int? churchId;
  final bool isGenerating;
  final String? errorMessage;
  final int cooldownRemainingSeconds;

  const ReportGenerateState({
    required this.reportType,
    required this.format,
    required this.documentInput,
    required this.congregationSubtype,
    required this.activityType,
    required this.financialSubtype,
    required this.dateRangePreset,
    required this.customDateRange,
    required this.selectedColumn,
    required this.churchId,
    required this.isGenerating,
    required this.errorMessage,
    required this.cooldownRemainingSeconds,
  });

  ReportGenerateState copyWith({
    ReportGenerateType? reportType,
    ReportFormat? format,
    DocumentInput? documentInput,
    CongregationReportSubtype? congregationSubtype,
    ActivityType? activityType,
    FinancialReportSubtype? financialSubtype,
    DateRangePreset? dateRangePreset,
    DateTimeRange? customDateRange,
    model.Column? selectedColumn,
    int? churchId,
    bool? isGenerating,
    String? errorMessage,
    int? cooldownRemainingSeconds,
    bool clearErrorMessage = false,
    bool clearSelectedColumn = false,
    bool clearActivityType = false,
    bool clearCustomDateRange = false,
  }) {
    return ReportGenerateState(
      reportType: reportType ?? this.reportType,
      format: format ?? this.format,
      documentInput: documentInput ?? this.documentInput,
      congregationSubtype: congregationSubtype ?? this.congregationSubtype,
      activityType: clearActivityType
          ? null
          : (activityType ?? this.activityType),
      financialSubtype: financialSubtype ?? this.financialSubtype,
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedColumn: clearSelectedColumn
          ? null
          : (selectedColumn ?? this.selectedColumn),
      churchId: churchId ?? this.churchId,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      cooldownRemainingSeconds:
          cooldownRemainingSeconds ?? this.cooldownRemainingSeconds,
    );
  }
}

final reportGenerateControllerProvider =
    NotifierProvider<ReportGenerateController, ReportGenerateState>(
      ReportGenerateController.new,
    );

class ReportGenerateController extends Notifier<ReportGenerateState> {
  static const _cooldownSeconds = 60;

  Timer? _cooldownTimer;

  @override
  ReportGenerateState build() {
    ref.onDispose(() {
      _cooldownTimer?.cancel();
      _cooldownTimer = null;
    });

    final localStorage = ref.read(localStorageServiceProvider);
    final lastAt = localStorage.lastReportGeneratedAt;
    final remaining = _cooldownRemainingSeconds(lastAt);

    final membership = localStorage.currentMembership;
    final churchId = membership?.church?.id;

    final initial = ReportGenerateState(
      reportType: ReportGenerateType.incomingDocument,
      format: ReportFormat.pdf,
      documentInput: DocumentInput.income,
      congregationSubtype: CongregationReportSubtype.wartaJemaat,
      activityType: null,
      financialSubtype: FinancialReportSubtype.revenue,
      dateRangePreset: DateRangePreset.today,
      customDateRange: null,
      selectedColumn: null,
      churchId: churchId,
      isGenerating: false,
      errorMessage: null,
      cooldownRemainingSeconds: remaining,
    );

    if (remaining > 0) {
      Future.microtask(_startCooldownTimer);
    }

    return initial;
  }

  int _cooldownRemainingSeconds(DateTime? lastAt) {
    if (lastAt == null) return 0;
    final local = lastAt.toLocal();
    final elapsed = DateTime.now().difference(local).inSeconds;
    return math.max(0, _cooldownSeconds - elapsed);
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _cooldownRemainingSeconds(
        ref.read(localStorageServiceProvider).lastReportGeneratedAt,
      );

      if (remaining <= 0) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
      }

      if (state.cooldownRemainingSeconds != remaining) {
        state = state.copyWith(cooldownRemainingSeconds: remaining);
      }
    });
  }

  DateTimeRange? getEffectiveDateRange() {
    if (state.dateRangePreset == DateRangePreset.custom) {
      return state.customDateRange;
    }

    return state.dateRangePreset.getDateRange();
  }

  void setReportType(ReportGenerateType type) {
    final usesColumn =
        type == ReportGenerateType.congregation ||
        type == ReportGenerateType.activity;
    final usesActivityType = type == ReportGenerateType.activity;

    final isDocumentReport =
        type == ReportGenerateType.incomingDocument ||
        type == ReportGenerateType.outcomingDocument;
    final wasDocumentReport =
        state.reportType == ReportGenerateType.incomingDocument ||
        state.reportType == ReportGenerateType.outcomingDocument;

    final nextDocumentInput = isDocumentReport && !wasDocumentReport
        ? (type == ReportGenerateType.outcomingDocument
              ? DocumentInput.outcome
              : DocumentInput.income)
        : null;

    state = state.copyWith(
      reportType: type,
      documentInput: nextDocumentInput,
      clearSelectedColumn: !usesColumn,
      clearActivityType: !usesActivityType,
      clearErrorMessage: true,
    );
  }

  void setFormat(ReportFormat format) {
    state = state.copyWith(format: format, clearErrorMessage: true);
  }

  void setDocumentInput(DocumentInput input) {
    state = state.copyWith(documentInput: input, clearErrorMessage: true);
  }

  void setCongregationSubtype(CongregationReportSubtype subtype) {
    state = state.copyWith(
      congregationSubtype: subtype,
      clearErrorMessage: true,
    );
  }

  void setActivityType(ActivityType? type) {
    state = state.copyWith(activityType: type, clearErrorMessage: true);
  }

  void setFinancialSubtype(FinancialReportSubtype subtype) {
    state = state.copyWith(financialSubtype: subtype, clearErrorMessage: true);
  }

  void setDateRangePreset(DateRangePreset preset) {
    state = state.copyWith(
      dateRangePreset: preset,
      clearCustomDateRange: preset != DateRangePreset.custom,
      clearErrorMessage: true,
    );
  }

  void setCustomDateRange(DateTimeRange? range) {
    state = state.copyWith(customDateRange: range, clearErrorMessage: true);
  }

  void setSelectedColumn(model.Column? column) {
    state = state.copyWith(selectedColumn: column, clearErrorMessage: true);
  }

  Future<void> startCooldown() async {
    await ref
        .read(localStorageServiceProvider)
        .saveLastReportGeneratedAt(DateTime.now());

    state = state.copyWith(cooldownRemainingSeconds: _cooldownSeconds);
    _startCooldownTimer();
  }

  Future<Report?> generateReport() async {
    if (state.isGenerating) return null;

    final remaining = _cooldownRemainingSeconds(
      ref.read(localStorageServiceProvider).lastReportGeneratedAt,
    );

    if (remaining > 0) {
      state = state.copyWith(cooldownRemainingSeconds: remaining);
      return null;
    }

    final effectiveRange = getEffectiveDateRange();
    if (effectiveRange == null) {
      state = state.copyWith(errorMessage: _l10n().validation_invalidRange);
      return null;
    }

    state = state.copyWith(isGenerating: true, clearErrorMessage: true);

    try {
      final repo = ref.read(reportRepositoryProvider);

      final includeColumn =
          state.reportType == ReportGenerateType.congregation ||
          state.reportType == ReportGenerateType.activity;

      final generateResult = await repo.generateReportTyped(
        type: state.reportType,
        format: state.format,
        input:
            state.reportType == ReportGenerateType.incomingDocument ||
                state.reportType == ReportGenerateType.outcomingDocument
            ? state.documentInput
            : null,
        congregationSubtype: state.reportType == ReportGenerateType.congregation
            ? state.congregationSubtype
            : null,
        columnId: includeColumn ? state.selectedColumn?.id : null,
        activityType: state.reportType == ReportGenerateType.activity
            ? state.activityType
            : null,
        financialSubtype: state.reportType == ReportGenerateType.financial
            ? state.financialSubtype
            : null,
        startDate: effectiveRange.start,
        endDate: effectiveRange.end,
      );

      Report? report;
      Failure? failure;

      generateResult.when(
        onSuccess: (r) {
          report = r;
          return null;
        },
        onFailure: (f) {
          failure = f;
        },
      );

      if (report == null) {
        state = state.copyWith(
          errorMessage: failure?.message ?? _l10n().msg_generateReportFailed,
        );
        return null;
      }

      if (report!.id == null) {
        state = state.copyWith(errorMessage: _l10n().msg_generateReportFailed);
        return null;
      }

      await startCooldown();
      return report;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<String?> resolveDownloadUrl({required int reportId}) async {
    try {
      final repo = ref.read(reportRepositoryProvider);
      final urlResult = await repo.downloadReport(reportId: reportId);

      String? url;
      Failure? failure;

      urlResult.when(
        onSuccess: (u) {
          url = u;
          return null;
        },
        onFailure: (f) {
          failure = f;
        },
      );

      if (url == null) {
        state = state.copyWith(
          errorMessage: failure?.message ?? _l10n().msg_cannotOpenReportFile,
        );
        return null;
      }

      return url;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<GeneratedReportDownload?> generateAndResolveDownloadUrl() async {
    final report = await generateReport();
    if (report?.id == null) return null;

    final url = await resolveDownloadUrl(reportId: report!.id!);
    if (url == null) return null;

    return GeneratedReportDownload(report: report, url: url);
  }
}
