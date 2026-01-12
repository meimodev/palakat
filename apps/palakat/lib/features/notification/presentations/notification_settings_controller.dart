import 'package:palakat_shared/core/models/notification_settings.dart';
import 'package:palakat_shared/services.dart';
import 'package:palakat/features/notification/data/pusher_beams_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_settings_controller.g.dart';

/// Controller for notification settings
///
/// Manages loading and updating notification preferences including
/// channel toggles and sound/vibration settings.
///
/// Requirements: 9.5
@riverpod
class NotificationSettingsController extends _$NotificationSettingsController {
  @override
  Future<NotificationSettingsModel> build() async {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.loadNotificationSettings();
  }

  /// Update activity updates preference
  Future<void> updateActivityUpdates(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(activityUpdatesEnabled: enabled);
    await _saveSettings(updated);
  }

  /// Update approval requests preference
  Future<void> updateApprovalRequests(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(approvalRequestsEnabled: enabled);
    await _saveSettings(updated);
  }

  /// Update general announcements preference
  Future<void> updateGeneralAnnouncements(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(generalAnnouncementsEnabled: enabled);
    await _saveSettings(updated);
  }

  Future<void> updateBirthdayNotifications(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(birthdayNotificationsEnabled: enabled);
    await _saveSettings(updated);

    try {
      await ref
          .read(pusherBeamsControllerProvider.notifier)
          .setBirthdayNotificationsEnabled(enabled);
    } catch (_) {}
  }

  /// Update sound preference
  Future<void> updateSound(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(soundEnabled: enabled);
    await _saveSettings(updated);
  }

  /// Update vibration preference
  Future<void> updateVibration(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(vibrationEnabled: enabled);
    await _saveSettings(updated);
  }

  /// Save settings to storage and update state
  Future<void> _saveSettings(NotificationSettingsModel settings) async {
    if (!ref.mounted) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final storage = ref.read(localStorageServiceProvider);
      await storage.saveNotificationSettings(settings);
      return settings;
    });
  }
}
