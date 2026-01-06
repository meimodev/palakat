import 'package:package_info_plus/package_info_plus.dart';
import 'package:palakat/features/dashboard/presentations/dashboard_controller.dart';
import 'package:palakat/features/home/presentation/home_controller.dart';
import 'package:palakat/features/notification/data/pusher_beams_controller.dart';
import 'package:palakat/features/settings/presentations/settings_state.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

/// Controller for managing settings screen state and actions.
///
/// Handles:
/// - Loading account and membership data
/// - Retrieving app version information
/// - Sign out flow with push notification cleanup
///
/// Requirements: 2.2, 3.2, 5.3, 6.3
@riverpod
class SettingsController extends _$SettingsController {
  @override
  SettingsState build() {
    // Initialize and load settings data
    Future.microtask(() => loadSettings());
    return const SettingsState();
  }

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  /// Whether the current user has a membership
  bool hasMembership() => state.membership != null;

  /// Loads settings data including account, membership, and app version.
  ///
  /// Requirements: 2.1, 3.1, 6.1, 6.3
  Future<void> loadSettings() async {
    try {
      // Load account data
      final result = await _authRepository.getSignedInAccount();
      result.when(
        onSuccess: (account) {
          state = state.copyWith(
            account: account,
            membership: account?.membership,
          );
        },
        onFailure: (failure) {
          state = state.copyWith(errorMessage: failure.message);
        },
      );

      // Load app version info
      await _loadVersionInfo();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load settings: $e');
    }
  }

  /// Loads app version and build number from package info.
  ///
  /// Requirements: 6.1, 6.2, 6.3
  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      state = state.copyWith(
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      );
    } catch (e) {
      // Set "unknown" values on error (Requirement 6.3)
      state = state.copyWith(appVersion: 'unknown', buildNumber: 'unknown');
    }
  }

  /// Signs out the user and clears all locally saved data.
  ///
  /// This method:
  /// 1. Unregisters all push notification interests
  /// 2. Signs out from Firebase
  /// 3. Clears local storage (auth, membership, permissions, notification settings)
  /// 4. Invalidates related providers to reset UI state
  ///
  /// Requirements: 5.3
  Future<void> signOut() async {
    state = state.copyWith(isSigningOut: true, errorMessage: null);

    // Unregister push notification interests before signing out
    try {
      final pusherBeamsController = ref.read(
        pusherBeamsControllerProvider.notifier,
      );
      await pusherBeamsController.unregisterAllInterests();
    } catch (e) {
      // Continue sign out even if push unregister fails
    }

    // Proceed with sign out
    final result = await _authRepository.signOut();
    result.when(
      onSuccess: (_) {
        state = state.copyWith(isSigningOut: false);
        // Invalidate related providers to reset UI state
        _invalidateRelatedProviders();
      },
      onFailure: (failure) {
        // Still mark as not signing out even on network error
        // (Repository already cleared local storage)
        state = state.copyWith(
          isSigningOut: false,
          errorMessage: failure.message,
        );
        // Still invalidate providers since local storage was cleared
        _invalidateRelatedProviders();
      },
    );
  }

  /// Invalidates related providers to ensure UI state is reset after logout.
  void _invalidateRelatedProviders() {
    // Invalidate dashboard controller to reset its state
    ref.invalidate(dashboardControllerProvider);
    // Invalidate home controller to reset navigation state
    ref.invalidate(homeControllerProvider);
    // Note: pusherBeamsControllerProvider is keepAlive and handles its own
    // state reset in unregisterAllInterests(), so we don't invalidate it here
  }

  /// Clears any error message in the state.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
