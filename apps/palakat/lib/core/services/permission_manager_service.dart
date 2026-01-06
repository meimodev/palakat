import 'dart:developer' as dev show log;
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:palakat_shared/core/services/local_storage_service.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Abstract interface for managing notification permission state and flows.
///
/// Requirements: 4.1, 4.4, 4.5, 5.1, 5.4, 5.5, 6.1, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5
abstract class PermissionManagerService {
  /// Get current permission state (from storage and system)
  Future<PermissionStateModel> getPermissionState();

  /// Check if we should show permission rationale
  Future<bool> shouldShowRationale();

  /// Request permissions with rationale flow
  Future<PermissionStatus> requestPermissionsWithRationale();

  /// Open system settings for app
  Future<void> openAppSettings();

  /// Store permission status
  Future<void> storePermissionStatus(PermissionStatus status);

  /// Check if enough time has passed since denial (7 days)
  bool shouldRetryAfterDenial(DateTime? deniedAt);

  /// Sync stored status with system status
  Future<void> syncPermissionStatus();
}

/// Concrete implementation of PermissionManagerService using permission_handler
/// and app_settings packages.
///
/// Requirements: 4.1, 4.4, 4.5, 5.1, 5.4, 5.5, 6.1, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5
class PermissionManagerServiceImpl implements PermissionManagerService {
  final LocalStorageService _storage;

  /// Duration to wait before re-requesting denied permissions (7 days)
  static const Duration _retryDuration = Duration(days: 7);

  PermissionManagerServiceImpl(this._storage);

  @override
  Future<PermissionStateModel> getPermissionState() async {
    // First, sync with system to ensure we have the latest state
    await syncPermissionStatus();

    // Load from storage
    final stored = await _storage.loadPermissionState();

    if (stored != null) {
      return stored;
    }

    // If no stored state, check system and create initial state
    final systemStatus = await _getSystemPermissionStatus();
    final initialState = PermissionStateModel(
      status: systemStatus,
      lastCheckedAt: DateTime.now(),
    );

    // Store the initial state
    await _storage.savePermissionState(initialState);

    return initialState;
  }

  @override
  Future<bool> shouldShowRationale() async {
    final state = await getPermissionState();

    // Show rationale if:
    // 1. Never asked before (notDetermined)
    // 2. Denied but enough time has passed (7 days)
    // 3. NOT permanently denied (can't request again on Android)

    if (state.status == PermissionStatus.permanentlyDenied) {
      return false; // Can't request again, must go to settings
    }

    if (state.status == PermissionStatus.notDetermined) {
      return true; // First time, show rationale
    }

    if (state.status == PermissionStatus.denied) {
      return shouldRetryAfterDenial(state.deniedAt);
    }

    return false; // Already granted
  }

  @override
  Future<PermissionStatus> requestPermissionsWithRationale() async {
    final state = await getPermissionState();

    // If permanently denied, can't request - must go to settings
    if (state.status == PermissionStatus.permanentlyDenied) {
      dev.log(
        'PermissionManagerService: Cannot request, permanently denied',
        name: 'PermissionManagerService',
      );
      return PermissionStatus.permanentlyDenied;
    }

    // Request system permission
    final result = await ph.Permission.notification.request();

    // Map system status to our status
    final newStatus = _mapSystemStatus(result);

    // Update stored state
    final updatedState = PermissionStateModel(
      status: newStatus,
      deniedAt: newStatus == PermissionStatus.denied ? DateTime.now() : null,
      denialCount: newStatus == PermissionStatus.denied
          ? state.denialCount + 1
          : state.denialCount,
      lastCheckedAt: DateTime.now(),
    );

    await _storage.savePermissionState(updatedState);

    dev.log(
      'PermissionManagerService: Permission request result: $newStatus',
      name: 'PermissionManagerService',
    );

    return newStatus;
  }

  @override
  Future<void> openAppSettings() async {
    try {
      if (Platform.isAndroid) {
        await AppSettings.openAppSettings(type: AppSettingsType.notification);
      } else if (Platform.isIOS) {
        await AppSettings.openAppSettings();
      }
      dev.log(
        'PermissionManagerService: Opened app settings',
        name: 'PermissionManagerService',
      );
    } catch (e) {
      dev.log(
        'PermissionManagerService: Failed to open app settings: $e',
        name: 'PermissionManagerService',
      );
      rethrow;
    }
  }

  @override
  Future<void> storePermissionStatus(PermissionStatus status) async {
    final current = await _storage.loadPermissionState();

    final updatedState = PermissionStateModel(
      status: status,
      deniedAt: status == PermissionStatus.denied
          ? DateTime.now()
          : current?.deniedAt,
      denialCount: status == PermissionStatus.denied
          ? (current?.denialCount ?? 0) + 1
          : current?.denialCount ?? 0,
      lastCheckedAt: DateTime.now(),
    );

    await _storage.savePermissionState(updatedState);

    dev.log(
      'PermissionManagerService: Stored permission status: $status',
      name: 'PermissionManagerService',
    );
  }

  @override
  bool shouldRetryAfterDenial(DateTime? deniedAt) {
    if (deniedAt == null) {
      return true; // No denial recorded, can retry
    }

    final now = DateTime.now();
    final timeSinceDenial = now.difference(deniedAt);

    return timeSinceDenial >= _retryDuration;
  }

  @override
  Future<void> syncPermissionStatus() async {
    final systemStatus = await _getSystemPermissionStatus();
    final stored = await _storage.loadPermissionState();

    // If no stored state, nothing to sync
    if (stored == null) {
      return;
    }

    // If system status differs from stored, update storage
    if (systemStatus != stored.status) {
      final updatedState = stored.copyWith(
        status: systemStatus,
        lastCheckedAt: DateTime.now(),
        // Clear deniedAt if permission was granted
        deniedAt: systemStatus == PermissionStatus.granted
            ? null
            : stored.deniedAt,
      );

      await _storage.savePermissionState(updatedState);

      dev.log(
        'PermissionManagerService: Synced permission status from $stored.status to $systemStatus',
        name: 'PermissionManagerService',
      );
    }
  }

  /// Get current system permission status
  Future<PermissionStatus> _getSystemPermissionStatus() async {
    final status = await ph.Permission.notification.status;
    return _mapSystemStatus(status);
  }

  /// Map permission_handler status to our PermissionStatus enum
  PermissionStatus _mapSystemStatus(ph.PermissionStatus status) {
    if (status.isGranted) {
      return PermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      return PermissionStatus.permanentlyDenied;
    } else if (status.isDenied) {
      return PermissionStatus.denied;
    } else {
      // isLimited, isRestricted, or isProvisional
      return PermissionStatus.notDetermined;
    }
  }
}
