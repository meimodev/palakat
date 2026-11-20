import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/memory/memory_announcement_repository.dart';
import '../data/memory/memory_document_repository.dart';
import '../data/memory/memory_letter_repository.dart';
import '../data/memory/memory_warta_repository.dart';
import '../data/repositories/announcement_repository.dart';
import '../data/repositories/document_repository.dart';
import '../data/repositories/letter_repository.dart';
import '../data/repositories/warta_repository.dart';
import 'core_repositories.dart';
import 'repositories_jemaat.dart';
import 'repositories_keuangan.dart';
import 'repositories_kolaborasi.dart';

// The Secretariat repositories (README 4.3). Overriding one with a Supabase
// implementation later is the seam (D1).

final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => MemoryDocumentRepository(ref.watch(memoryContextProvider)),
);

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) => MemoryAnnouncementRepository(ref.watch(memoryContextProvider)),
);

final wartaRepositoryProvider = Provider<WartaRepository>(
  (ref) => MemoryWartaRepository(
    ref.watch(memoryContextProvider),
    masking: ref.watch(maskingRepositoryProvider),
    periods: ref.watch(periodRepositoryProvider),
    reports: ref.watch(reportRepositoryProvider),
    services: ref.watch(serviceRepositoryProvider),
    attendance: ref.watch(attendanceRepositoryProvider),
  ),
);

final letterRepositoryProvider = Provider<LetterRepository>(
  (ref) => MemoryLetterRepository(ref.watch(memoryContextProvider)),
);
