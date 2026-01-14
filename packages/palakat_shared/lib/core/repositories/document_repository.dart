import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_shared/core/models/document.dart';
import 'package:palakat_shared/core/models/app_error.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:palakat_shared/core/models/response/response.dart';
import 'package:palakat_shared/core/repositories/church_repository.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:palakat_shared/core/services/socket_service.dart';

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
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('document.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Document.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<({Document document, String? verificationUrl}), Failure>>
  generateSignedDocument({
    required int documentId,
    bool regenerate = true,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('document.generate', {
        'id': documentId,
        'regenerate': regenerate,
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid generate document response payload'),
        );
      }

      final verificationUrl = body['verificationUrl']?.toString();
      return Result.success((
        document: Document.fromJson(json),
        verificationUrl: verificationUrl,
      ));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<DocumentSettings, Failure>> getSettings() async {
    try {
      // Get churchId from authenticated user
      final auth = _ref.read(localStorageServiceProvider).currentAuth;
      final churchId = auth?.account.membership?.church?.id;

      if (churchId == null) {
        return Result.failure(
          Failure('Church ID not found in authenticated user'),
        );
      }

      // Fetch church detail
      final churchRepo = _ref.read(churchRepositoryProvider);
      final churchResult = await churchRepo.fetchChurchProfile(churchId);

      final result = churchResult.when<Result<DocumentSettings, Failure>>(
        onSuccess: (church) {
          // Extract documentAccountNumber
          final documentAccountNumber = church.documentAccountNumber;
          if (documentAccountNumber == null || documentAccountNumber.isEmpty) {
            return Result.failure(
              Failure('Document account number not found in church profile'),
            );
          }
          return Result.success(
            DocumentSettings(identityNumberTemplate: documentAccountNumber),
          );
        },
        onFailure: (failure) => Result.failure(failure),
      );
      return result!;
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<DocumentSettings, Failure>> updateIdentityTemplate(
    String newTemplate,
  ) async {
    try {
      // Get churchId from authenticated user
      final auth = _ref.read(localStorageServiceProvider).currentAuth;
      final churchId = auth?.account.membership?.church?.id;

      if (churchId == null) {
        return Result.failure(
          Failure('Church ID not found in authenticated user'),
        );
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
            return Result.failure(
              Failure('Document account number not found after update'),
            );
          }
          return Result.success(
            DocumentSettings(identityNumberTemplate: documentAccountNumber),
          );
        },
        onFailure: (failure) => Result.failure(failure),
      );
      return result!;
    } catch (e) {
      return Result.failure(Failure.fromException(e));
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
