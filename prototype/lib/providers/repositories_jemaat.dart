import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/memory/memory_application_repository.dart';
import '../data/memory/memory_consent_repository.dart';
import '../data/memory/memory_jemaat.dart';
import '../data/memory/memory_masking_repository.dart';
import '../data/memory/memory_member_import_repository.dart';
import '../data/memory/memory_member_repository.dart';
import '../data/memory/memory_verification_repository.dart';
import '../data/repositories/application_repository.dart';
import '../data/repositories/consent_repository.dart';
import '../data/repositories/masking_repository.dart';
import '../data/repositories/member_import_repository.dart';
import '../data/repositories/member_repository.dart';
import '../data/repositories/verification_repository.dart';
import 'core_repositories.dart';

/// The shared base of the membership repositories.
final memoryJemaatProvider = Provider<MemoryJemaat>(
  (ref) => MemoryJemaat(ref.watch(memoryContextProvider)),
);

// The membership repositories (README 4.4). Overriding one with a Supabase
// implementation later is the seam (D1).

final memberRepositoryProvider = Provider<MemberRepository>(
  (ref) => MemoryMemberRepository(ref.watch(memoryJemaatProvider)),
);

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => MemoryVerificationRepository(ref.watch(memoryJemaatProvider)),
);

final applicationRepositoryProvider = Provider<ApplicationRepository>(
  (ref) => MemoryApplicationRepository(ref.watch(memoryJemaatProvider)),
);

final consentRepositoryProvider = Provider<ConsentRepository>(
  (ref) => MemoryConsentRepository(ref.watch(memoryJemaatProvider)),
);

final memberImportRepositoryProvider = Provider<MemberImportRepository>(
  (ref) => MemoryMemberImportRepository(ref.watch(memoryJemaatProvider)),
);

final maskingRepositoryProvider = Provider<MaskingRepository>(
  (ref) => MemoryMaskingRepository(ref.watch(memoryJemaatProvider)),
);
