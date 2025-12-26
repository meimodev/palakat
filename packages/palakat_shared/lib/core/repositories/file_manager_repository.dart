import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../models/file_manager.dart';
import '../models/result.dart';
import '../services/file_transfer_progress_service.dart';
import '../services/socket_service.dart';
import '../utils/file_bytes_url.dart';

part 'file_manager_repository.g.dart';

@riverpod
FileManagerRepository fileManagerRepository(Ref ref) =>
    FileManagerRepository(ref);

class FileManagerRepository {
  FileManagerRepository(this._ref);

  final Ref _ref;

  Future<Result<FileManager, Failure>> finalize({
    required int churchId,
    required String path,
    required double sizeInKB,
    String? bucket,
    String? contentType,
    String? originalName,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('file.finalize', {
        'churchId': churchId,
        if (bucket != null) 'bucket': bucket,
        'path': path,
        'sizeInKB': sizeInKB,
        if (contentType != null) 'contentType': contentType,
        if (originalName != null) 'originalName': originalName,
      });

      final json = body['data'];
      if (json is! Map<String, dynamic>) {
        return Result.failure(
          Failure('Invalid finalize file response payload'),
        );
      }
      return Result.success(FileManager.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<String, Failure>> resolveDownloadUrl({
    required int fileId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);

      final progress = _ref.read(
        fileTransferProgressControllerProvider.notifier,
      );
      final progressId = progress.start(
        direction: FileTransferDirection.download,
        totalBytes: 0,
        label: 'file#$fileId',
      );

      final dl = await socket.downloadFileBytes(
        fileId: fileId,
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
        filename: dl.originalName ?? 'file',
        contentType: dl.contentType,
      );
      return Result.success(url);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Returns the proxy URL for a file that can be used directly in Image.network
  /// This avoids CORS issues on Flutter Web by proxying through the backend
  String getProxyUrl(int fileId) {
    final config = _ref.read(appConfigProvider);
    final baseUrl = config.apiBaseUrl.endsWith('/')
        ? config.apiBaseUrl.substring(0, config.apiBaseUrl.length - 1)
        : config.apiBaseUrl;
    return '$baseUrl/file-manager/$fileId/proxy';
  }

  /// Fetches file bytes through the proxy endpoint (handles auth automatically)
  /// Use this for displaying images on Flutter Web to avoid CORS issues
  Future<Result<Uint8List, Failure>> fetchFileBytes({
    required int fileId,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);

      final progress = _ref.read(
        fileTransferProgressControllerProvider.notifier,
      );
      final progressId = progress.start(
        direction: FileTransferDirection.download,
        totalBytes: 0,
        label: 'file#$fileId',
      );

      final dl = await socket.downloadFileBytes(
        fileId: fileId,
        onProgress: (received, total) {
          progress.update(
            progressId,
            transferredBytes: received,
            totalBytes: total,
          );
        },
      );
      progress.complete(progressId);
      if (dl.bytes.isEmpty) {
        progress.fail(progressId, errorMessage: 'Empty file response');
        return Result.failure(Failure('Empty file response'));
      }
      return Result.success(dl.bytes);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
