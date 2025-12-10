import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:palakat_shared/core/services/local_storage_service.dart';

/// **Feature: push-notification-ux-improvements, Property 4: Permission State Persistence**
///
/// *For any* permission status (granted, denied, permanently_denied),
/// when stored to local storage and then retrieved,
/// the retrieved status SHALL match the stored status.
///
/// **Validates: Requirements 7.1, 7.2, 7.3**
void main() {
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

  group('Property 4: Permission State Persistence', () {
    // Generator for permission status
    final permissionStatusArb = oneOf([
      constant(PermissionStatus.notDetermined),
      constant(PermissionStatus.granted),
      constant(PermissionStatus.denied),
      constant(PermissionStatus.permanentlyDenied),
    ]);

    // Generator for optional DateTime (for deniedAt)
    final optionalDateTimeArb = oneOf([
      constant(null),
      integer(
        min: 0,
        max: DateTime.now().millisecondsSinceEpoch,
      ).map((ms) => DateTime.fromMillisecondsSinceEpoch(ms)),
    ]);

    // Generator for denial count
    final denialCountArb = integer(min: 0, max: 10);

    // Generator for PermissionStateModel
    final permissionStateArb =
        combine4(
          permissionStatusArb,
          optionalDateTimeArb,
          denialCountArb,
          optionalDateTimeArb,
        ).map(
          (tuple) => PermissionStateModel(
            status: tuple.$1,
            deniedAt: tuple.$2,
            denialCount: tuple.$3,
            lastCheckedAt: tuple.$4,
          ),
        );

    // Property test: Permission state round-trips through storage
    property('permission state round-trips through storage', () {
      forAll(permissionStateArb, (originalState) async {
        final service = LocalStorageService();

        // Save the permission state
        await service.savePermissionState(originalState);

        // Load it back
        final loadedState = await service.loadPermissionState();

        // Verify it matches
        expect(loadedState, isNotNull);
        expect(loadedState!.status, equals(originalState.status));
        expect(loadedState.denialCount, equals(originalState.denialCount));

        // Compare timestamps (allowing for millisecond precision)
        if (originalState.deniedAt != null) {
          expect(loadedState.deniedAt, isNotNull);
          expect(
            loadedState.deniedAt!.millisecondsSinceEpoch,
            equals(originalState.deniedAt!.millisecondsSinceEpoch),
          );
        } else {
          expect(loadedState.deniedAt, isNull);
        }

        if (originalState.lastCheckedAt != null) {
          expect(loadedState.lastCheckedAt, isNotNull);
          expect(
            loadedState.lastCheckedAt!.millisecondsSinceEpoch,
            equals(originalState.lastCheckedAt!.millisecondsSinceEpoch),
          );
        } else {
          expect(loadedState.lastCheckedAt, isNull);
        }

        // Clean up
        await service.clearPermissionState();
      });
    });

    // Property test: All permission statuses can be persisted
    property('all permission statuses can be persisted', () {
      forAll(permissionStatusArb, (status) async {
        final service = LocalStorageService();
        final state = PermissionStateModel(status: status);

        await service.savePermissionState(state);
        final loadedState = await service.loadPermissionState();

        expect(loadedState, isNotNull);
        expect(loadedState!.status, equals(status));

        await service.clearPermissionState();
      });
    });

    // Property test: Denial count is preserved
    property('denial count is preserved through storage', () {
      forAll(denialCountArb, (count) async {
        final service = LocalStorageService();
        final state = PermissionStateModel(
          status: PermissionStatus.denied,
          denialCount: count,
        );

        await service.savePermissionState(state);
        final loadedState = await service.loadPermissionState();

        expect(loadedState, isNotNull);
        expect(loadedState!.denialCount, equals(count));

        await service.clearPermissionState();
      });
    });
  });

  // Integration tests for permission state persistence
  group('Permission State Persistence Integration Tests', () {
    late LocalStorageService service;

    setUp(() async {
      service = LocalStorageService();
    });

    tearDown(() async {
      await service.clearPermissionState();
    });

    test('loadPermissionState returns null when nothing saved', () async {
      final loadedState = await service.loadPermissionState();
      expect(loadedState, isNull);
    });

    test('currentPermissionState is null before saving', () {
      expect(service.currentPermissionState, isNull);
    });

    test('saving granted status persists correctly', () async {
      const state = PermissionStateModel(status: PermissionStatus.granted);

      await service.savePermissionState(state);

      final newService = LocalStorageService();
      final loadedState = await newService.loadPermissionState();

      expect(loadedState, isNotNull);
      expect(loadedState!.status, equals(PermissionStatus.granted));
    });

    test('saving denied status with timestamp persists correctly', () async {
      final deniedAt = DateTime.now();
      final state = PermissionStateModel(
        status: PermissionStatus.denied,
        deniedAt: deniedAt,
        denialCount: 1,
      );

      await service.savePermissionState(state);

      final newService = LocalStorageService();
      final loadedState = await newService.loadPermissionState();

      expect(loadedState, isNotNull);
      expect(loadedState!.status, equals(PermissionStatus.denied));
      expect(loadedState.denialCount, equals(1));
      expect(
        loadedState.deniedAt!.millisecondsSinceEpoch,
        equals(deniedAt.millisecondsSinceEpoch),
      );
    });

    test('saving permanently denied status persists correctly', () async {
      const state = PermissionStateModel(
        status: PermissionStatus.permanentlyDenied,
        denialCount: 3,
      );

      await service.savePermissionState(state);

      final newService = LocalStorageService();
      final loadedState = await newService.loadPermissionState();

      expect(loadedState, isNotNull);
      expect(loadedState!.status, equals(PermissionStatus.permanentlyDenied));
      expect(loadedState.denialCount, equals(3));
    });

    test('overwriting permission state persists new value', () async {
      const firstState = PermissionStateModel(status: PermissionStatus.denied);
      const secondState = PermissionStateModel(
        status: PermissionStatus.granted,
      );

      await service.savePermissionState(firstState);
      await service.savePermissionState(secondState);

      final newService = LocalStorageService();
      final loadedState = await newService.loadPermissionState();

      expect(loadedState, isNotNull);
      expect(loadedState!.status, equals(PermissionStatus.granted));
    });

    test('clearPermissionState removes persisted state', () async {
      const state = PermissionStateModel(status: PermissionStatus.granted);

      await service.savePermissionState(state);
      await service.clearPermissionState();

      expect(service.currentPermissionState, isNull);

      final newService = LocalStorageService();
      final loadedState = await newService.loadPermissionState();
      expect(loadedState, isNull);
    });

    test('currentPermissionState reflects saved state', () async {
      const state = PermissionStateModel(
        status: PermissionStatus.denied,
        denialCount: 2,
      );

      await service.savePermissionState(state);

      expect(service.currentPermissionState, isNotNull);
      expect(
        service.currentPermissionState!.status,
        equals(PermissionStatus.denied),
      );
      expect(service.currentPermissionState!.denialCount, equals(2));
    });
  });
}
