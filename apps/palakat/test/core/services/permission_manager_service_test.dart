import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palakat/core/services/permission_manager_service.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:palakat_shared/core/services/local_storage_service.dart';

/// Unit tests for PermissionManagerService
///
/// Requirements: 4.1, 4.4, 4.5, 5.1, 5.4, 5.5, 6.1, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Hive for testing with a temporary path
    Hive.init('.hive_test');
    // Open the boxes that LocalStorageService uses
    await Hive.openBox('auth');
    await Hive.openBox('permission_state');
    await Hive.openBox('notification_settings');
  });

  tearDownAll(() async {
    // Clean up Hive after tests
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  group('PermissionManagerService Unit Tests', () {
    late LocalStorageService storage;
    late PermissionManagerService service;

    setUp(() async {
      storage = LocalStorageService();
      service = PermissionManagerServiceImpl(storage);
      await storage.clearPermissionState();
    });

    tearDown(() async {
      await storage.clearPermissionState();
    });

    group('storePermissionStatus', () {
      test('persists to Hive', () async {
        await service.storePermissionStatus(PermissionStatus.granted);

        final loadedState = await storage.loadPermissionState();
        expect(loadedState, isNotNull);
        expect(loadedState!.status, equals(PermissionStatus.granted));
      });

      test('sets lastCheckedAt timestamp', () async {
        final before = DateTime.now();
        await service.storePermissionStatus(PermissionStatus.granted);
        final after = DateTime.now();

        final loadedState = await storage.loadPermissionState();
        expect(loadedState!.lastCheckedAt, isNotNull);
        expect(
          loadedState.lastCheckedAt!.isAfter(before) ||
              loadedState.lastCheckedAt!.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          loadedState.lastCheckedAt!.isBefore(after) ||
              loadedState.lastCheckedAt!.isAtSameMomentAs(after),
          isTrue,
        );
      });

      test('increments denial count on denial', () async {
        await service.storePermissionStatus(PermissionStatus.denied);
        var state = await storage.loadPermissionState();
        expect(state!.denialCount, equals(1));

        await service.storePermissionStatus(PermissionStatus.denied);
        state = await storage.loadPermissionState();
        expect(state!.denialCount, equals(2));
      });

      test('sets deniedAt timestamp on denial', () async {
        final before = DateTime.now();
        await service.storePermissionStatus(PermissionStatus.denied);
        final after = DateTime.now();

        final state = await storage.loadPermissionState();
        expect(state!.deniedAt, isNotNull);
        expect(
          state.deniedAt!.isAfter(before) ||
              state.deniedAt!.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          state.deniedAt!.isBefore(after) ||
              state.deniedAt!.isAtSameMomentAs(after),
          isTrue,
        );
      });

      test('preserves denialCount when granting after denial', () async {
        await service.storePermissionStatus(PermissionStatus.denied);
        await service.storePermissionStatus(PermissionStatus.denied);

        await service.storePermissionStatus(PermissionStatus.granted);

        final state = await storage.loadPermissionState();
        expect(state!.denialCount, equals(2));
      });
    });

    group('shouldRetryAfterDenial', () {
      test('returns true for null deniedAt', () {
        expect(service.shouldRetryAfterDenial(null), isTrue);
      });

      test('returns true for denial 7 days ago', () {
        final deniedAt = DateTime.now().subtract(const Duration(days: 7));
        expect(service.shouldRetryAfterDenial(deniedAt), isTrue);
      });

      test('returns true for denial more than 7 days ago', () {
        final deniedAt = DateTime.now().subtract(const Duration(days: 10));
        expect(service.shouldRetryAfterDenial(deniedAt), isTrue);
      });

      test('returns false for denial less than 7 days ago', () {
        final deniedAt = DateTime.now().subtract(const Duration(days: 5));
        expect(service.shouldRetryAfterDenial(deniedAt), isFalse);
      });

      test('returns false for denial 6 days 23 hours ago', () {
        final deniedAt = DateTime.now().subtract(
          const Duration(days: 6, hours: 23),
        );
        expect(service.shouldRetryAfterDenial(deniedAt), isFalse);
      });

      test('returns true for denial exactly 168 hours (7 days) ago', () {
        final deniedAt = DateTime.now().subtract(const Duration(hours: 168));
        expect(service.shouldRetryAfterDenial(deniedAt), isTrue);
      });
    });

    // Note: openAppSettings requires platform implementation and cannot be tested
    // in unit tests. It will be tested in integration tests on real devices.

    // Note: Tests for getPermissionState, shouldShowRationale, syncPermissionStatus,
    // and requestPermissionsWithRationale require system permission checks
    // and cannot run in unit tests. These are tested in integration tests
    // on real devices.
  });
}
