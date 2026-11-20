import '../../domain/finance/finance.dart';
import '../repositories/opening_repository.dart';
import 'memory_finance.dart';

/// The seeded cutover (D19); read-only.
class MemoryOpeningRepository implements OpeningRepository {
  MemoryOpeningRepository(this.f);
  final MemoryFinance f;

  @override
  OpeningBatch? opening() => f.k.opening;
}
