import 'dart:developer' as developer;

import 'package:palakat_admin/core/services/pusher_beams_web_service.dart';
import 'package:palakat_admin/core/utils/interest_builder.dart';
import 'package:palakat_admin/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pusher_beams_controller.g.dart';

/// Provider for the PusherBeamsWebService singleton instance.
@Riverpod(keepAlive: true)
PusherBeamsWebService pusherBeamsWebService(Ref ref) {
  return PusherBeamsWebService();
}

/// State for the PusherBeamsController.
class PusherBeamsState {
  final bool isInitialized;
  final bool isRegistered;
  final List<String> subscribedInterests;

  const PusherBeamsState({
    this.isInitialized = false,
    this.isRegistered = false,
    this.subscribedInterests = const [],
  });

  PusherBeamsState copyWith({
    bool? isInitialized,
    bool? isRegistered,
    List<String>? subscribedInterests,
  }) {
    return PusherBeamsState(
      isInitialized: isInitialized ?? this.isInitialized,
      isRegistered: isRegistered ?? this.isRegistered,
      subscribedInterests: subscribedInterests ?? this.subscribedInterests,
    );
  }
}

/// Controller for managing Pusher Beams push notification registration.
///
/// This controller handles:
/// - Registering device interests based on user membership data
/// - Unregistering all interests on logout
/// - Logging each interest registration/unregistration
///
/// **Validates: Requirements 4.2, 4.3, 4.4**
@Riverpod(keepAlive: true)
class PusherBeamsController extends _$PusherBeamsController {
  static const String _tag = 'PusherBeamsController';

  @override
  PusherBeamsState build() {
    // Initialize the service asynchronously
    Future.microtask(() => _initialize());
    return const PusherBeamsState();
  }

  Future<void> _initialize() async {
    final service = ref.read(pusherBeamsWebServiceProvider);
    await service.initialize();
    state = state.copyWith(isInitialized: service.isInitialized);
  }

  /// Registers device interests based on the user's membership data.
  ///
  /// Subscribes to:
  /// - Global interest (palakat)
  /// - Church interest (church.{churchId})
  /// - BIPRA interest (church.{churchId}_bipra.{BIPRA})
  /// - Column interest (church.{churchId}_column.{columnId}) if applicable
  /// - Column BIPRA interest if applicable
  /// - Membership interest (membership.{membershipId})
  ///
  /// **Validates: Requirements 4.2, 4.3**
  Future<void> registerInterests(Membership membership) async {
    final service = ref.read(pusherBeamsWebServiceProvider);

    if (!service.isInitialized) {
      _log('Service not initialized. Attempting to initialize...');
      await service.initialize();
      if (!service.isInitialized) {
        _log('Failed to initialize service. Skipping interest registration.');
        return;
      }
      state = state.copyWith(isInitialized: true);
    }

    // Validate required membership data
    final membershipId = membership.id;
    final churchId = membership.church?.id;

    if (membershipId == null || churchId == null) {
      _log(
        'Missing required membership data. '
        'membershipId: $membershipId, churchId: $churchId',
      );
      return;
    }

    // Get BIPRA from membership positions
    // Default to 'PKB' if no position is found
    final bipra = _getBipraFromMembership(membership);
    final columnId = membership.column?.id;

    _log('Building interests for membership $membershipId');

    final interests = InterestBuilder.buildUserInterests(
      membershipId: membershipId,
      churchId: churchId,
      bipra: bipra,
      columnId: columnId,
    );

    _log('Registering ${interests.length} interests:');
    for (final interest in interests) {
      _log('  - $interest');
    }

    await service.subscribeToInterests(interests);
    state = state.copyWith(isRegistered: true, subscribedInterests: interests);

    _log('Interest registration complete');
  }

  /// Unregisters all device interests.
  ///
  /// This should be called when the user signs out.
  ///
  /// **Validates: Requirements 4.4**
  Future<void> unregisterAllInterests() async {
    final service = ref.read(pusherBeamsWebServiceProvider);

    if (!service.isInitialized) {
      _log('Service not initialized. Nothing to unregister.');
      return;
    }

    _log('Unregistering all interests');

    // Get current interests for logging
    final currentInterests = await service.getSubscribedInterests();
    for (final interest in currentInterests) {
      _log('  Unregistering: $interest');
    }

    await service.unsubscribeFromAllInterests();
    await service.clearAllState();

    state = state.copyWith(
      isInitialized: false,
      isRegistered: false,
      subscribedInterests: [],
    );

    _log('All interests unregistered and state cleared');
  }

  /// Extracts the BIPRA abbreviation from membership positions.
  ///
  /// Returns 'PKB' as default if no BIPRA-related position is found.
  String _getBipraFromMembership(Membership membership) {
    // The membership positions might contain BIPRA information
    // For now, we'll use a default value
    // This can be enhanced when the membership model includes BIPRA directly

    // Check if there's a position that matches a BIPRA abbreviation
    final positions = membership.membershipPositions;
    for (final position in positions) {
      final name = position.name.toUpperCase();
      if (['PKB', 'WKI', 'PMD', 'RMJ', 'ASM', 'ELD'].contains(name)) {
        return name;
      }
    }

    // Default to PKB if no BIPRA position found
    return 'PKB';
  }

  void _log(String message) {
    developer.log('[$_tag] $message', name: 'PusherBeams');
  }
}
