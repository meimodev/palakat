import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palakat_shared/core/models/notification_settings.dart';
import 'package:palakat_shared/services.dart';

/// Unit tests for notification settings
///
/// Tests settings persistence to Hive, retrieval from Hive, and default settings values.
///
/// Requirements: 9.5
void main() {
  late LocalStorageService storage;

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

  setUp(() async {
    storage = LocalStorageService();
  });

  tearDown(() async {
    await storage.clearNotificationSettings();
  });

  group('LocalStorageService - Notification Settings', () {
    test('should save and load notification settings', () async {
      // Arrange
      const settings = NotificationSettingsModel(
        activityUpdatesEnabled: false,
        approvalRequestsEnabled: true,
        generalAnnouncementsEnabled: false,
        soundEnabled: true,
        vibrationEnabled: false,
      );

      // Act
      await storage.saveNotificationSettings(settings);
      final loaded = await storage.loadNotificationSettings();

      // Assert
      expect(loaded.activityUpdatesEnabled, false);
      expect(loaded.approvalRequestsEnabled, true);
      expect(loaded.generalAnnouncementsEnabled, false);
      expect(loaded.soundEnabled, true);
      expect(loaded.vibrationEnabled, false);
    });

    test('should return default settings when none are saved', () async {
      // Act
      final settings = await storage.loadNotificationSettings();

      // Assert - Default values
      expect(settings.activityUpdatesEnabled, true);
      expect(settings.approvalRequestsEnabled, true);
      expect(settings.generalAnnouncementsEnabled, true);
      expect(settings.soundEnabled, true);
      expect(settings.vibrationEnabled, true);
    });

    test('should clear notification settings', () async {
      // Arrange
      const settings = NotificationSettingsModel(
        activityUpdatesEnabled: false,
        approvalRequestsEnabled: false,
        generalAnnouncementsEnabled: false,
        soundEnabled: false,
        vibrationEnabled: false,
      );
      await storage.saveNotificationSettings(settings);

      // Act
      await storage.clearNotificationSettings();
      final loaded = await storage.loadNotificationSettings();

      // Assert - Should return default settings
      expect(loaded.activityUpdatesEnabled, true);
      expect(loaded.approvalRequestsEnabled, true);
      expect(loaded.generalAnnouncementsEnabled, true);
      expect(loaded.soundEnabled, true);
      expect(loaded.vibrationEnabled, true);
    });

    test('should handle multiple save operations', () async {
      // Act
      await storage.saveNotificationSettings(
        const NotificationSettingsModel(activityUpdatesEnabled: false),
      );
      await storage.saveNotificationSettings(
        const NotificationSettingsModel(approvalRequestsEnabled: false),
      );
      await storage.saveNotificationSettings(
        const NotificationSettingsModel(soundEnabled: false),
      );

      final loaded = await storage.loadNotificationSettings();

      // Assert - Last save should win
      expect(loaded.activityUpdatesEnabled, true); // default
      expect(loaded.approvalRequestsEnabled, true); // default
      expect(loaded.generalAnnouncementsEnabled, true); // default
      expect(loaded.soundEnabled, false); // from last save
      expect(loaded.vibrationEnabled, true); // default
    });

    test('should persist activity updates preference', () async {
      // Arrange
      const settings = NotificationSettingsModel(activityUpdatesEnabled: false);

      // Act
      await storage.saveNotificationSettings(settings);
      final loaded = await storage.loadNotificationSettings();

      // Assert
      expect(loaded.activityUpdatesEnabled, false);
      expect(loaded.approvalRequestsEnabled, true); // default
      expect(loaded.generalAnnouncementsEnabled, true); // default
      expect(loaded.soundEnabled, true); // default
      expect(loaded.vibrationEnabled, true); // default
    });

    test('should persist approval requests preference', () async {
      // Arrange
      const settings = NotificationSettingsModel(
        approvalRequestsEnabled: false,
      );

      // Act
      await storage.saveNotificationSettings(settings);
      final loaded = await storage.loadNotificationSettings();

      // Assert
      expect(loaded.activityUpdatesEnabled, true); // default
      expect(loaded.approvalRequestsEnabled, false);
      expect(loaded.generalAnnouncementsEnabled, true); // default
      expect(loaded.soundEnabled, true); // default
      expect(loaded.vibrationEnabled, true); // default
    });

    test('should persist general announcements preference', () async {
      // Arrange
      const settings = NotificationSettingsModel(
        generalAnnouncementsEnabled: false,
      );

      // Act
      await storage.saveNotificationSettings(settings);
      final loaded = await storage.loadNotificationSettings();

      // Assert
      expect(loaded.activityUpdatesEnabled, true); // default
      expect(loaded.approvalRequestsEnabled, true); // default
      expect(loaded.generalAnnouncementsEnabled, false);
      expect(loaded.soundEnabled, true); // default
      expect(loaded.vibrationEnabled, true); // default
    });

    test('should persist sound preference', () async {
      // Arrange
      const settings = NotificationSettingsModel(soundEnabled: false);

      // Act
      await storage.saveNotificationSettings(settings);
      final loaded = await storage.loadNotificationSettings();

      // Assert
      expect(loaded.activityUpdatesEnabled, true); // default
      expect(loaded.approvalRequestsEnabled, true); // default
      expect(loaded.generalAnnouncementsEnabled, true); // default
      expect(loaded.soundEnabled, false);
      expect(loaded.vibrationEnabled, true); // default
    });

    test('should persist vibration preference', () async {
      // Arrange
      const settings = NotificationSettingsModel(vibrationEnabled: false);

      // Act
      await storage.saveNotificationSettings(settings);
      final loaded = await storage.loadNotificationSettings();

      // Assert
      expect(loaded.activityUpdatesEnabled, true); // default
      expect(loaded.approvalRequestsEnabled, true); // default
      expect(loaded.generalAnnouncementsEnabled, true); // default
      expect(loaded.soundEnabled, true); // default
      expect(loaded.vibrationEnabled, false);
    });

    test('should retrieve saved settings from Hive', () async {
      // Arrange
      const customSettings = NotificationSettingsModel(
        activityUpdatesEnabled: false,
        approvalRequestsEnabled: true,
        generalAnnouncementsEnabled: false,
        soundEnabled: false,
        vibrationEnabled: true,
      );
      await storage.saveNotificationSettings(customSettings);

      // Create a new storage instance to simulate app restart
      final newStorage = LocalStorageService();

      // Act
      final settings = await newStorage.loadNotificationSettings();

      // Assert
      expect(settings.activityUpdatesEnabled, false);
      expect(settings.approvalRequestsEnabled, true);
      expect(settings.generalAnnouncementsEnabled, false);
      expect(settings.soundEnabled, false);
      expect(settings.vibrationEnabled, true);
    });

    test('should maintain settings across storage instances', () async {
      // Arrange
      const settings = NotificationSettingsModel(
        activityUpdatesEnabled: false,
        approvalRequestsEnabled: false,
        soundEnabled: false,
      );

      // Act - Save with first instance
      await storage.saveNotificationSettings(settings);

      // Load with new instance (simulating app restart)
      final newStorage = LocalStorageService();
      final loaded = await newStorage.loadNotificationSettings();

      // Assert
      expect(loaded.activityUpdatesEnabled, false);
      expect(loaded.approvalRequestsEnabled, false);
      expect(loaded.soundEnabled, false);
      expect(loaded.generalAnnouncementsEnabled, true); // unchanged
      expect(loaded.vibrationEnabled, true); // unchanged
    });

    test('should handle all settings being disabled', () async {
      // Arrange
      const settings = NotificationSettingsModel(
        activityUpdatesEnabled: false,
        approvalRequestsEnabled: false,
        generalAnnouncementsEnabled: false,
        soundEnabled: false,
        vibrationEnabled: false,
      );

      // Act
      await storage.saveNotificationSettings(settings);
      final loaded = await storage.loadNotificationSettings();

      // Assert
      expect(loaded.activityUpdatesEnabled, false);
      expect(loaded.approvalRequestsEnabled, false);
      expect(loaded.generalAnnouncementsEnabled, false);
      expect(loaded.soundEnabled, false);
      expect(loaded.vibrationEnabled, false);
    });

    test('should handle all settings being enabled', () async {
      // Arrange
      const settings = NotificationSettingsModel(
        activityUpdatesEnabled: true,
        approvalRequestsEnabled: true,
        generalAnnouncementsEnabled: true,
        soundEnabled: true,
        vibrationEnabled: true,
      );

      // Act
      await storage.saveNotificationSettings(settings);
      final loaded = await storage.loadNotificationSettings();

      // Assert
      expect(loaded.activityUpdatesEnabled, true);
      expect(loaded.approvalRequestsEnabled, true);
      expect(loaded.generalAnnouncementsEnabled, true);
      expect(loaded.soundEnabled, true);
      expect(loaded.vibrationEnabled, true);
    });
  });
}
