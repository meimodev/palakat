/// Abstract interface for Pusher Beams push notification service.
///
/// This interface defines the contract for push notification functionality
/// across different platforms (mobile and web).
abstract class PusherBeamsService {
  /// Initialize the Pusher Beams SDK with the given instance ID.
  ///
  /// This should be called once during app initialization.
  /// [instanceId] is the Pusher Beams instance ID from the dashboard.
  Future<void> initialize(String instanceId);

  /// Subscribe to a list of device interests.
  ///
  /// Interests are topic-based subscriptions that allow targeting
  /// specific groups of devices. Examples:
  /// - 'palakat' (global)
  /// - 'church.123' (church-wide)
  /// - 'membership.456' (individual user)
  ///
  /// [interests] is the list of interest names to subscribe to.
  Future<void> subscribeToInterests(List<String> interests);

  /// Unsubscribe from all device interests.
  ///
  /// This should be called during logout to stop receiving notifications.
  Future<void> unsubscribeFromAllInterests();

  /// Clear all Pusher Beams state.
  ///
  /// This removes all local state and should be called after unsubscribing.
  Future<void> clearAllState();
}
