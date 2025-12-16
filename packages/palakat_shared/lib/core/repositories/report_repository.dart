import 'package:dio/dio.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
