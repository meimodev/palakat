import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/church_letterhead.dart';
import '../models/result.dart';
import '../services/local_storage_service_provider.dart';
import '../services/file_transfer_progress_service.dart';
import '../services/socket_service.dart';

part 'church_letterhead_repository.g.dart';

@riverpod
ChurchLetterheadRepository churchLetterheadRepository(Ref ref) {
  // ignore: deprecated_member_use
  ref.keepAlive();
  return ChurchLetterheadRepository(ref);
}

class ChurchLetterheadRepository {
  ChurchLetterheadRepository(this._ref);

  final Ref _ref;

  Future<Result<ChurchLetterhead?, Failure>> fetchMyLetterhead() async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('churchLetterhead.getMe');
      final data = body['data'];
      if (data == null) {
        return Result.success(null);
      }
      if (data is! Map<String, dynamic>) {
        return Result.failure(Failure('Invalid church letterhead payload'));
      }
      return Result.success(ChurchLetterhead.fromJson(data));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<ChurchLetterhead, Failure>> updateMyLetterhead({
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('churchLetterhead.updateMe', data);
      final json = body['data'];
      if (json is! Map<String, dynamic>) {
        return Result.failure(Failure('Invalid update letterhead payload'));
      }

      return Result.success(ChurchLetterhead.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<ChurchLetterhead, Failure>> uploadLogo({
    required List<int> bytes,
    required String filename,
  }) async {
    try {
      final localStorage = _ref.read(localStorageServiceProvider);
      final churchId =
          localStorage.currentMembership?.church?.id ??
          localStorage.currentAuth?.account.membership?.church?.id;

      if (churchId == null) {
        return Result.failure(Failure('Invalid church context'));
      }

      final socket = _ref.read(socketServiceProvider);
      final progress = _ref.read(
        fileTransferProgressControllerProvider.notifier,
      );
      final progressId = progress.start(
        direction: FileTransferDirection.upload,
        totalBytes: bytes.length,
        label: filename,
      );

      final uploaded = await socket.uploadFileBytes(
        churchId: churchId,
        bytes: Uint8List.fromList(bytes),
        originalName: filename,
        contentType: 'image/png',
        onProgress: (sent, total) {
          progress.update(
            progressId,
            transferredBytes: sent,
            totalBytes: total,
          );
        },
      );
      progress.complete(progressId);

      final data = uploaded['data'];
      if (data is! Map<String, dynamic>) {
        progress.fail(
          progressId,
          errorMessage: 'Invalid upload response payload',
        );
        return Result.failure(Failure('Invalid upload response payload'));
      }

      final fileId = data['id'];
      if (fileId is! int) {
        progress.fail(
          progressId,
          errorMessage: 'Invalid upload response payload',
        );
        return Result.failure(Failure('Invalid upload response payload'));
      }

      final linked = await socket.rpc('churchLetterhead.setLogo', {
        'logoFileId': fileId,
      });

      final json = linked['data'];
      if (json is! Map<String, dynamic>) {
        return Result.failure(Failure('Invalid set logo response payload'));
      }

      return Result.success(ChurchLetterhead.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
