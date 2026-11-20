import '../../domain/finance/finance.dart';

/// The cutover (README 4.2, D19): seeded complete, read-only.
abstract interface class OpeningRepository {
  OpeningBatch? opening();
}
