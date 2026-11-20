import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';

/// How names print in publications (README 4.4, TampilanNama).
abstract interface class MaskingRepository {
  /// The member's own choice, else the family default, else the full name.
  NameForm preference(String personId);

  /// The member's own choice, or null while the family default applies.
  MaskingPreference? ownChoice(String personId);

  String printedName(String personId, PrintContext context);

  /// The printed name [personId] would get with [form].
  String nameWith(String personId, NameForm form);

  Future<Result<void>> set(
    Actor actor,
    String personId,
    NameForm preference, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
