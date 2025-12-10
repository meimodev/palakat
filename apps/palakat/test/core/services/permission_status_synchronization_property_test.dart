import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/services/permission_manager_service.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:palakat_shared/core/services/local_storage_service.dart';

/// **Feature: push-notification-ux-improvements, Property 6: Permission Status Synchronization**
///
/// *For any* stored permission status and system permission status,
/// when syncPermissionStatus is called, the stored status SHALL be updated
/// to match the system status if they differ.
///
/// **Validates: Requirements 7.4, 7.5**
///
/// Note: Since we cannot control actual system permissions in unit tests,
/// these property tests focus on the storage synchronization logic and
/// timestamp updates that occur during sync operations.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  KiriCheck.verbosity = Verbosity.verbose;

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

  group('Property 6: Permission Status Synchronization', () {
    late LocalStorageService storage;

    setUp(() async {
      storage = LocalStorageService();
      // Clear any existing state
      await storage.clearPermissionState();
    });

    tearDown(() async {
      await storage.clearPermissionState();
    });

    // Generator for permission status
    final permissionStatusArb = oneOf([
      constant(PermissionStatus.notDetermined),
      constant(PermissionStatus.granted),
      constant(PermissionStatus.denied),
      constant(PermissionStatus.permanentlyDenied),
    ]);

    // Property test: Storage preserves denial count across save/load cycles
    property('storage preserves denial count across save/load', () {
      forAll(combine2(permissionStatusArb, integer(min: 0, max: 10)), (
        tuple,
      ) async {
        final status = tuple.$1;
        final denialCount = tuple.$2;

        final initialState = PermissionStateModel(
          status: status,
          denialCount: denialCount,
        );

        await storage.savePermissionState(initialState);
        final loadedState = await storage.loadPermissionState();

        expect(loadedState, isNotNull);
        // Denial count should be preserved
        expect(
          loadedState!.denialCount,
          equals(denialCount),
          reason: 'Denial count should be preserved in storage',
        );
      });
    });

    // Property test: Timestamps are preserved across storage operations
    property('timestamps are preserved across storage operations', () {
      forAll(permissionStatusArb, (status) async {
        final timestamp = DateTime.now().subtract(const Duration(hours: 2));
        final initialState = PermissionStateModel(
          status: status,
          lastCheckedAt: timestamp,
        );

        await storage.savePermissionState(initialState);
        final loadedState = await storage.loadPermissionState();

        expect(loadedState, isNotNull);
        expect(loadedState!.lastCheckedAt, isNotNull);
        expect(
          loadedState.lastCheckedAt!.millisecondsSinceEpoch,
          equals(timestamp.millisecondsSinceEpoch),
          reason: 'Timestamp should be preserved exactly',
        );
      });
    });

    // Property test: deniedAt timestamp is preserved for denied status
    property('deniedAt is preserved for denied status', () {
      forAll(constant(null), (_) async {
        final deniedAt = DateTime.now().subtract(const Duration(days: 3));
        final initialState = PermissionStateModel(
          status: PermissionStatus.denied,
          deniedAt: deniedAt,
          denialCount: 2,
        );

        await storage.savePermissionState(initialState);
        final loadedState = await storage.loadPermissionState();

        expect(loadedState, isNotNull);
        expect(loadedState!.deniedAt, isNotNull);
        expect(
          loadedState.deniedAt!.millisecondsSinceEpoch,
          equals(deniedAt.millisecondsSinceEpoch),
          reason: 'deniedAt timestamp should be preserved',
        );
      });
    });
  });

  // Integration tests for permission status synchronization logic
  group('Permission Status Synchronization Integration Tests', () {
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

    test('storePermissionStatus saves to storage correctly', () async {
      await service.storePermissionStatus(PermissionStatus.granted);

      final loadedState = await storage.loadPermissionState();
      expect(loadedState, isNotNull);
      expect(loadedState!.status, equals(PermissionStatus.granted));
      expect(loadedState.lastCheckedAt, isNotNull);
    });

    test('storePermissionStatus updates denial count on denial', () async {
      // First denial
      await service.storePermissionStatus(PermissionStatus.denied);
      var loadedState = await storage.loadPermissionState();
      expect(loadedState!.denialCount, equals(1));
      expect(loadedState.deniedAt, isNotNull);

      // Second denial
      await service.storePermissionStatus(PermissionStatus.denied);
      loadedState = await storage.loadPermissionState();
      expect(loadedState!.denialCount, equals(2));
    });

    test('storePermissionStatus preserves denialCount for granted', () async {
      // Start with denied
      await service.storePermissionStatus(PermissionStatus.denied);
      var loadedState = await storage.loadPermissionState();
      expect(loadedState!.denialCount, equals(1));

      // Grant permission
      await service.storePermissionStatus(PermissionStatus.granted);
      loadedState = await storage.loadPermissionState();
      expect(loadedState!.status, equals(PermissionStatus.granted));
      expect(loadedState.denialCount, equals(1)); // Preserved
    });

    // Note: Tests that call getPermissionState() or shouldShowRationale()
    // require system permission checks and cannot run in unit tests.
    // These will be tested in integration tests on real devices.
  });
}
