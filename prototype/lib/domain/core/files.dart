/// A reference to any record, across modules: `RecordRef('delegation', 'd1')`.
class RecordRef {
  const RecordRef(this.kind, this.id);

  /// 'transaction', 'assignment', 'document', …
  final String kind;
  final String id;

  @override
  bool operator ==(Object other) =>
      other is RecordRef && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => '$kind:$id';
}

/// A file as the demo knows it: a name plus a bundled sample image
/// (domain.md 5 point 8). No checksum.
class SampleFile {
  const SampleFile(this.name, {this.asset});

  /// 'nota-16-11.jpg', 'SK-BPMJ-09-….pdf'.
  final String name;

  /// A bundled asset path, when the screen shows the picture.
  final String? asset;
}

/// A file linked to a record (PMP 5 Files).
class FileRecord {
  const FileRecord({
    required this.id,
    required this.ref,
    required this.file,
    required this.attachedBy,
    required this.attachedAt,
  });

  final String id;
  final RecordRef ref;
  final SampleFile file;
  final String attachedBy;
  final DateTime attachedAt;
}

/// The church-owned export (F18): a manifest only, no file is written.
class ExportManifest {
  const ExportManifest({
    required this.fileName,
    required this.createdAt,
    required this.counts,
  });

  /// 'ekspor-jemaat-karunia-{yyyy-mm-dd}.zip'.
  final String fileName;
  final DateTime createdAt;

  /// Rows per table: {'orang': 23, 'transaksi': …}.
  final Map<String, int> counts;
}
