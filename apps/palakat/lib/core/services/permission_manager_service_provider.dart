import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'permission_manager_service.dart';

part 'permission_manager_service_provider.g.dart';

/// Provider for PermissionManagerService
@riverpod
PermissionManagerService permissionManagerService(Ref ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return PermissionManagerServiceImpl(storage);
}

/// Provider for current permission state
///
/// This provider watches the permission state and updates when it changes.
/// Requirements: 6.2, 6.3
@riverpod
class PermissionState extends _$PermissionState {
  @override
  Future<PermissionStateModel> build() async {
    final service = ref.watch(permissionManagerServiceProvider);
    return service.getPermissionState();
  }

  /// Refresh the permission state
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final service = ref.read(permissionManagerServiceProvider);
      return service.getPermissionState();
    });
    // Check if provider is still mounted before setting state
    if (!ref.mounted) return;
    state = result;
  }

  /// Request permissions with rationale
  Future<PermissionStatus> requestPermissions() async {
    final service = ref.read(permissionManagerServiceProvider);
    final result = await service.requestPermissionsWithRationale();
    await refresh();
    return result;
  }

  /// Open app settings
  Future<void> openSettings() async {
    final service = ref.read(permissionManagerServiceProvider);
    await service.openAppSettings();
  }
}
