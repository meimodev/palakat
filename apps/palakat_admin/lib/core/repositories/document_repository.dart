import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/services/http_service.dart';
import 'package:palakat_admin/core/models/document.dart';
import 'package:palakat_admin/core/models/app_error.dart';
import 'package:palakat_admin/core/models/result.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:palakat_admin/core/models/response/response.dart';
import 'package:palakat_admin/core/utils/error_mapper.dart';
import 'package:palakat_admin/core/config/endpoint.dart';
import 'package:palakat_admin/core/repositories/church_repository.dart';
import 'package:palakat_admin/core/services/local_storage_service_provider.dart';

part 'document_repository.g.dart';

@riverpod
DocumentRepository documentRepository(Ref ref) => DocumentRepository(ref);

class DocumentRepository {
  final Ref _ref;
  DocumentRepository(this._ref);

  Future<Result<PaginationResponseWrapper<Document>, Failure>> fetchDocuments({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.documents,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Document.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch documents');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch documents', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<DocumentSettings, Failure>> getSettings() async {
    try {
      // Get churchId from authenticated user
      final auth = _ref.read(localStorageServiceProvider).currentAuth;
      final churchId = auth?.account.membership?.church?.id;

      if (churchId == null) {
        return Result.failure(Failure('Church ID not found in authenticated user'));
      }

      // Fetch church detail
      final churchRepo = _ref.read(churchRepositoryProvider);
      final churchResult = await churchRepo.fetchChurchProfile(churchId);

      final result = churchResult.when<Result<DocumentSettings, Failure>>(
        onSuccess: (church) {
          // Extract documentAccountNumber
          final documentAccountNumber = church.documentAccountNumber;
          if (documentAccountNumber == null || documentAccountNumber.isEmpty) {
            return Result.failure(Failure('Document account number not found in church profile'));
          }
          return Result.success(DocumentSettings(identityNumberTemplate: documentAccountNumber));
        },
        onFailure: (failure) => Result.failure(failure),
      );
      return result!;
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch document settings');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch document settings', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<DocumentSettings, Failure>> updateIdentityTemplate(String newTemplate) async {
    try {
      // Get churchId from authenticated user
      final auth = _ref.read(localStorageServiceProvider).currentAuth;
      final churchId = auth?.account.membership?.church?.id;

      if (churchId == null) {
        return Result.failure(Failure('Church ID not found in authenticated user'));
      }

      // Update church documentAccountNumber
      final churchRepo = _ref.read(churchRepositoryProvider);
      final updateResult = await churchRepo.updateChurchProfile(
        churchId: churchId,
        update: {'documentAccountNumber': newTemplate},
      );

      final result = updateResult.when<Result<DocumentSettings, Failure>>(
        onSuccess: (updatedChurch) {
          // Return updated document settings
          final documentAccountNumber = updatedChurch.documentAccountNumber;
          if (documentAccountNumber == null || documentAccountNumber.isEmpty) {
            return Result.failure(Failure('Document account number not found after update'));
          }
          return Result.success(DocumentSettings(identityNumberTemplate: documentAccountNumber));
        },
        onFailure: (failure) => Result.failure(failure),
      );
      return result!;
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update identity template');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update identity template', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}


@riverpod
Future<DocumentSettings?> documentSettings(Ref ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  final result = await repo.getSettings();
  return result.when(
    onSuccess: (settings) => settings,
    onFailure: (failure) {
      throw AppError.serverError(failure.message, statusCode: failure.code);
    },
  );
}
