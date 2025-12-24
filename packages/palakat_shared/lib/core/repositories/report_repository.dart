import 'package:dio/dio.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/enums.dart';
import '../models/report.dart';
import '../models/result.dart';
import '../models/response/response.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'report_repository.g.dart';

@riverpod
ReportRepository reportRepository(Ref ref) => ReportRepository(ref);

class ReportRepository {
  ReportRepository(this._ref);

  final Ref _ref;

  Future<Result<PaginationResponseWrapper<Report>, Failure>> fetchReports({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.reports,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Report.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch reports');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch reports', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Fetches reports created by the currently logged-in user.
  /// Uses the `mine=true` query parameter to filter by current user.
  Future<Result<PaginationResponseWrapper<Report>, Failure>> fetchMyReports({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
        'mine': true,
      };

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.reports,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Report.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch my reports');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch my reports', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
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

  Future<Result<Report, Failure>> generateReportTyped({
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
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.report(reportId.toString()),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid report response payload'));
      }
      return Result.success(Report.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch report');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch report', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Report, Failure>> generateReport({
    required Map<String, dynamic> data,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.generateReport,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid generate report response payload'),
        );
      }
      return Result.success(Report.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to generate report');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to generate report', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<void, Failure>> deleteReport({required int reportId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.report(reportId.toString()));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete report');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete report', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<String, Failure>> downloadReport({
    required int reportId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final reportResponse = await http.get<Map<String, dynamic>>(
        Endpoints.report(reportId.toString()),
      );

      final reportBody = reportResponse.data;
      final Map<String, dynamic> reportJson = reportBody?['data'] ?? {};
      if (reportJson.isEmpty) {
        return Result.failure(Failure('Invalid report response payload'));
      }

      final report = Report.fromJson(reportJson);
      final fileId = report.fileId;

      final resolveResponse = await http.get<Map<String, dynamic>>(
        Endpoints.fileManagerResolveDownloadUrl(fileId.toString()),
      );

      final resolveBody = resolveResponse.data ?? {};
      final resolveData = resolveBody['data'];
      if (resolveData is! Map<String, dynamic>) {
        return Result.failure(Failure('Invalid resolve download url payload'));
      }
      final url = resolveData['url'];
      if (url is! String || url.trim().isEmpty) {
        return Result.failure(Failure('Invalid resolve download url response'));
      }
      return Result.success(url);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to download report');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to download report', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
