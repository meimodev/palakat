import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FileTransferDirection { upload, download }

enum FileTransferStatus { inProgress, completed, failed }

class FileTransferProgress {
  const FileTransferProgress({
    required this.id,
    required this.direction,
    required this.transferredBytes,
    required this.totalBytes,
    required this.status,
    this.label,
    this.errorMessage,
  });

  final String id;
  final FileTransferDirection direction;
  final String? label;

  final int transferredBytes;
  final int totalBytes;

  final FileTransferStatus status;
  final String? errorMessage;

  double? get fraction {
    if (totalBytes <= 0) return null;
    final f = transferredBytes / totalBytes;
    if (f < 0) return 0;
    if (f > 1) return 1;
    return f;
  }

  FileTransferProgress copyWith({
    String? id,
    FileTransferDirection? direction,
    String? label,
    int? transferredBytes,
    int? totalBytes,
    FileTransferStatus? status,
    String? errorMessage,
  }) {
    return FileTransferProgress(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      label: label ?? this.label,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FileTransferProgressController
    extends Notifier<List<FileTransferProgress>> {
  int _seq = 0;

  @override
  List<FileTransferProgress> build() {
    return const [];
  }

  String start({
    required FileTransferDirection direction,
    required int totalBytes,
    String? label,
  }) {
    final id = '${DateTime.now().microsecondsSinceEpoch}_${_seq++}';
    state = [
      ...state,
      FileTransferProgress(
        id: id,
        direction: direction,
        transferredBytes: 0,
        totalBytes: totalBytes,
        status: FileTransferStatus.inProgress,
        label: label,
      ),
    ];
    return id;
  }

  void update(
    String id, {
    required int transferredBytes,
    required int totalBytes,
  }) {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx < 0) return;

    final current = state[idx];
    if (current.status != FileTransferStatus.inProgress) return;

    final updated = current.copyWith(
      transferredBytes: transferredBytes,
      totalBytes: totalBytes,
    );

    final next = [...state];
    next[idx] = updated;
    state = next;
  }

  void complete(String id) {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx < 0) return;

    final current = state[idx];
    final updated = current.copyWith(
      transferredBytes: current.totalBytes,
      status: FileTransferStatus.completed,
    );

    final next = [...state];
    next[idx] = updated;
    state = next;

    _removeLater(id, const Duration(seconds: 2));
  }

  void fail(String id, {String? errorMessage}) {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx < 0) return;

    final current = state[idx];
    final updated = current.copyWith(
      status: FileTransferStatus.failed,
      errorMessage: errorMessage,
    );

    final next = [...state];
    next[idx] = updated;
    state = next;

    _removeLater(id, const Duration(seconds: 5));
  }

  void clear(String id) {
    state = state.where((t) => t.id != id).toList(growable: false);
  }

  void clearAll() {
    state = const [];
  }

  void _removeLater(String id, [Duration delay = const Duration(seconds: 2)]) {
    Future<void>.delayed(delay, () {
      clear(id);
    });
  }
}

final fileTransferProgressControllerProvider =
    NotifierProvider<
      FileTransferProgressController,
      List<FileTransferProgress>
    >(FileTransferProgressController.new);
