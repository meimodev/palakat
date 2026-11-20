import '../../domain/core/core.dart';

/// One file store (README 4.1): a file is a name plus a bundled sample.
abstract interface class FileRepository {
  List<FileRecord> files(RecordRef ref);

  Future<Result<FileRecord>> attach(
    Actor actor,
    RecordRef ref,
    SampleFile file, {
    required String idempotencyKey,
  });
}
