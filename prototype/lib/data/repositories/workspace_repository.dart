import '../../domain/core/core.dart';

/// The church and its module registry (README 4.1, PMP 8).
abstract interface class WorkspaceRepository {
  Workspace workspace();

  /// Every module, in the Modul board's order.
  List<ModuleState> modules();

  /// Switching on needs the module it depends on active; switching off
  /// (OFF or READ_ONLY) needs a reason. [expectedRevision] is the module's.
  Future<Result<ModuleState>> setModuleStatus(
    Actor actor,
    Module module,
    ModuleStatus status, {
    String? reason,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
