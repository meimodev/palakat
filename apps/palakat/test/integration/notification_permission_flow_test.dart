import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palakat/core/services/permission_manager_service.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:palakat_shared/services.dart';

/// Integration tests for the notification permission flow
///
/// These tests cover:
/// - First-time permission request logic
/// - Permission state persistence
/// - 7-day re-request logic
/// - Permission status synchronization
///
/// Requirements: 4.1, 4.4, 4.5, 5.1, 5.4, 5.5, 6.1, 6.5
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Permission Flow Integration Tests', () {
    late PermissionManagerService permissionManager;

    setUp(() async {
      // Initialize Hive for testing with a temporary directory
      final testDir = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(testDir.path);

      // Initialize Hive boxes
      await LocalStorageService.initHive();

      // Create permission manager with real storage
      permissionManager = PermissionManagerServiceImpl(LocalStorageService());
    });

    tearDown(() async {
      // Close all Hive boxes
      await Hive.close();
    });

    test('First-time permission request should show rationale', () async {
      // Requirements: 4.1

      // Clear any existing permission state
      await LocalStorageService().clearPermissionState();

      // Check if should show rationale for first time
      final shouldShow = await permissionManager.shouldShowRationale();

      // Should show rationale for first-time users
      expect(shouldShow, true);
    });

    test('Permission state persistence', () async {
      // Requirements: 7.1, 7.2, 7.3

      // Store granted status
      await permissionManager.storePermissionStatus(PermissionStatus.granted);

      // Retrieve and verify
      final state1 = await permissionManager.getPermissionState();
      expect(state1.status, PermissionStatus.granted);
      expect(state1.deniedAt, null);

      // Store denied status
      await permissionManager.storePermissionStatus(PermissionStatus.denied);

      // Retrieve and verify
      final state2 = await permissionManager.getPermissionState();
      expect(state2.status, PermissionStatus.denied);
      expect(state2.deniedAt, isNotNull);
      expect(state2.denialCount, greaterThan(0));

      // Store permanently denied status
      await permissionManager.storePermissionStatus(
        PermissionStatus.permanentlyDenied,
      );

      // Retrieve and verify
      final state3 = await permissionManager.getPermissionState();
      expect(state3.status, PermissionStatus.permanentlyDenied);
    });

    test('7-day re-request logic', () {
      // Requirements: 6.1

      // Test: Should retry after 7 days
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      expect(permissionManager.shouldRetryAfterDenial(sevenDaysAgo), true);

      // Test: Should retry after more than 7 days
      final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
      expect(permissionManager.shouldRetryAfterDenial(eightDaysAgo), true);

      // Test: Should NOT retry before 7 days
      final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6));
      expect(permissionManager.shouldRetryAfterDenial(sixDaysAgo), false);

      // Test: Should NOT retry on same day
      final today = DateTime.now();
      expect(permissionManager.shouldRetryAfterDenial(today), false);

      // Test: Should retry if no denial date (null)
      expect(permissionManager.shouldRetryAfterDenial(null), true);
    });

    test('Should not show rationale when permanently denied', () async {
      // Requirements: 6.4

      // Store permanently denied status
      await permissionManager.storePermissionStatus(
        PermissionStatus.permanentlyDenied,
      );

      // Check if should show rationale
      final shouldShow = await permissionManager.shouldShowRationale();

      // Should NOT show rationale when permanently denied
      expect(shouldShow, false);
    });

    test('Should not show rationale when already granted', () async {
      // Requirements: 4.1

      // Store granted status
      await permissionManager.storePermissionStatus(PermissionStatus.granted);

      // Check if should show rationale
      final shouldShow = await permissionManager.shouldShowRationale();

      // Should NOT show rationale when already granted
      expect(shouldShow, false);
    });

    test('Should show rationale after 7 days from denial', () async {
      // Requirements: 6.1

      // Create a permission state with denial 8 days ago
      final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
      final state = PermissionStateModel(
        status: PermissionStatus.denied,
        deniedAt: eightDaysAgo,
        denialCount: 1,
      );

      await LocalStorageService().savePermissionState(state);

      // Check if should show rationale
      final shouldShow = await permissionManager.shouldShowRationale();

      // Should show rationale after 7 days
      expect(shouldShow, true);
    });

    test('Should not show rationale before 7 days from denial', () async {
      // Requirements: 6.1

      // Create a permission state with denial 5 days ago
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
      final state = PermissionStateModel(
        status: PermissionStatus.denied,
        deniedAt: fiveDaysAgo,
        denialCount: 1,
      );

      await LocalStorageService().savePermissionState(state);

      // Check if should show rationale
      final shouldShow = await permissionManager.shouldShowRationale();

      // Should NOT show rationale before 7 days
      expect(shouldShow, false);
    });

    test('Permission status synchronization updates storage', () async {
      // Requirements: 7.4, 7.5

      // Store a denied status
      await permissionManager.storePermissionStatus(PermissionStatus.denied);

      // Verify it's stored
      final stateBefore = await permissionManager.getPermissionState();
      expect(stateBefore.status, PermissionStatus.denied);

      // Sync permission status (this will check system status)
      // Note: In a real test, the system status would be mocked
      await permissionManager.syncPermissionStatus();

      // Verify lastCheckedAt was updated
      final stateAfter = await permissionManager.getPermissionState();
      expect(stateAfter.lastCheckedAt, isNotNull);
    });

    test('Denial count increments on repeated denials', () async {
      // Requirements: 7.2

      // Clear state
      await LocalStorageService().clearPermissionState();

      // First denial
      await permissionManager.storePermissionStatus(PermissionStatus.denied);
      final state1 = await permissionManager.getPermissionState();
      expect(state1.denialCount, 1);

      // Second denial
      await permissionManager.storePermissionStatus(PermissionStatus.denied);
      final state2 = await permissionManager.getPermissionState();
      expect(state2.denialCount, 2);

      // Third denial
      await permissionManager.storePermissionStatus(PermissionStatus.denied);
      final state3 = await permissionManager.getPermissionState();
      expect(state3.denialCount, 3);
    });
  });
}
