import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/enums.dart';
import '../models/report.dart';
import '../models/report_job.dart';
import '../models/result.dart';
import '../models/response/response.dart';
import '../services/file_transfer_progress_service.dart';
import '../services/socket_service.dart';
import '../utils/file_bytes_url.dart';

part 'report_repository.g.dart';

@riverpod
ReportRepository reportRepository(Ref ref) {
  ref.keepAlive();
  return ReportRepository(ref);
}

class ReportRepository {
  ReportRepository(this._ref);

  final Ref _ref;

  Future<Result<PaginationResponseWrapper<Report>, Failure>> fetchReports({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('report.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Report.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Fetches reports created by the currently logged-in user.
  /// Uses the `mine=true` query parameter to filter by current user.
  Future<Result<PaginationResponseWrapper<Report>, Failure>> fetchMyReports({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
        'mine': true,
      };

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('report.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Report.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  String _reportGenerateTypeToApi(ReportGenerateType type) {
    switch (type) {
      case ReportGenerateType.incomingDocument:
        return 'INCOMING_DOCUMENT';
      case ReportGenerateType.outcomingDocument:
        return 'OUTCOMING_DOCUMENT';
      case ReportGenerateType.congregation:
        return 'CONGREGATION';
      case ReportGenerateType.services:
        return 'SERVICES';
      case ReportGenerateType.activity:
        return 'ACTIVITY';
      case ReportGenerateType.financial:
        return 'FINANCIAL';
    }
  }

  String _reportFormatToApi(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return 'PDF';
      case ReportFormat.xlsx:
        return 'XLSX';
    }
  }

  String _documentInputToApi(DocumentInput input) {
    switch (input) {
      case DocumentInput.income:
        return 'INCOME';
      case DocumentInput.outcome:
        return 'OUTCOME';
    }
  }

  String _congregationReportSubtypeToApi(CongregationReportSubtype subtype) {
    switch (subtype) {
      case CongregationReportSubtype.wartaJemaat:
        return 'WARTA_JEMAAT';
      case CongregationReportSubtype.hutJemaat:
        return 'HUT_JEMAAT';
      case CongregationReportSubtype.keanggotaan:
        return 'KEANGGOTAAN';
    }
  }

  String _financialReportSubtypeToApi(FinancialReportSubtype subtype) {
    switch (subtype) {
      case FinancialReportSubtype.revenue:
        return 'REVENUE';
      case FinancialReportSubtype.expense:
        return 'EXPENSE';
      case FinancialReportSubtype.mutation:
        return 'MUTATION';
    }
  }

  Future<Result<ReportJob, Failure>> generateReportTyped({
    required ReportGenerateType type,
    ReportFormat? format,
    DocumentInput? input,
    CongregationReportSubtype? congregationSubtype,
    int? columnId,
    ActivityType? activityType,
    FinancialReportSubtype? financialSubtype,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return generateReport(
      data: {
        'type': _reportGenerateTypeToApi(type),
        if (input != null) 'input': _documentInputToApi(input),
        if (congregationSubtype != null)
          'congregationSubtype': _congregationReportSubtypeToApi(
            congregationSubtype,
          ),
        if (columnId != null) 'columnId': columnId,
        if (activityType != null)
          'activityType': activityType.name.toUpperCase(),
        if (financialSubtype != null)
          'financialSubtype': _financialReportSubtypeToApi(financialSubtype),
        if (format != null) 'format': _reportFormatToApi(format),
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
    );
  }

  Future<Result<Report, Failure>> fetchReport({required int reportId}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('report.get', {'id': reportId});
      final Map<String, dynamic> json =
          (data['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid report response payload'));
      }
      return Result.success(Report.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<ReportJob, Failure>> generateReport({
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('report.generate', data);
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid generate report response payload'),
        );
      }
      return Result.success(ReportJob.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<void, Failure>> deleteReport({required int reportId}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('report.delete', {'id': reportId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<String, Failure>> downloadReport({
    required int reportId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final progress = _ref.read(
        fileTransferProgressControllerProvider.notifier,
      );
      final body = await socket.rpc('report.get', {'id': reportId});
      final Map<String, dynamic> reportJson =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (reportJson.isEmpty) {
        return Result.failure(Failure('Invalid report response payload'));
      }

      final report = Report.fromJson(reportJson);
      final progressId = progress.start(
        direction: FileTransferDirection.download,
        totalBytes: 0,
        label: report.name,
      );

      final dl = await socket.downloadFileBytes(
        fileId: report.fileId,
        onProgress: (received, total) {
          progress.update(
            progressId,
            transferredBytes: received,
            totalBytes: total,
          );
        },
      );
      progress.complete(progressId);
      final url = await bytesToUrl(
        bytes: dl.bytes,
        filename: dl.originalName ?? report.name,
        contentType: dl.contentType,
      );
      return Result.success(url);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  // ========== Report Job Methods ==========

  /// Queue a report generation job
  Future<Result<ReportJob, Failure>> queueReportGeneration({
    required ReportGenerateType type,
    ReportFormat? format,
    DocumentInput? input,
    CongregationReportSubtype? congregationSubtype,
    int? columnId,
    ActivityType? activityType,
    FinancialReportSubtype? financialSubtype,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('report.generate', {
        'type': _reportGenerateTypeToApi(type),
        if (input != null) 'input': _documentInputToApi(input),
        if (congregationSubtype != null)
          'congregationSubtype': _congregationReportSubtypeToApi(
            congregationSubtype,
          ),
        if (columnId != null) 'columnId': columnId,
        if (activityType != null)
          'activityType': activityType.name.toUpperCase(),
        if (financialSubtype != null)
          'financialSubtype': _financialReportSubtypeToApi(financialSubtype),
        if (format != null) 'format': _reportFormatToApi(format),
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      });
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid queue report response payload'));
      }
      return Result.success(ReportJob.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Fetch list of user's report jobs
  Future<Result<PaginationResponseWrapper<ReportJob>, Failure>>
  fetchMyReportJobs({
    int page = 1,
    int pageSize = 10,
    ReportJobStatus? status,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
        if (status != null) 'status': status.name.toUpperCase(),
      };

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('reportJob.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => ReportJob.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Fetch single report job status
  Future<Result<ReportJob, Failure>> fetchReportJob({
    required int jobId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('reportJob.get', {'id': jobId});
      final Map<String, dynamic> json =
          (data['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid report job response payload'));
      }
      return Result.success(ReportJob.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Cancel a pending report job
  Future<Result<void, Failure>> cancelReportJob({required int jobId}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('reportJob.cancel', {'id': jobId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
