# Push Notification System

## Overview

The Palakat mobile app uses Pusher Beams for push notifications. The system handles:
- Interest-based subscriptions (church, membership, column, BIPRA)
- Foreground notifications (in-app banners)
- Background/system notifications
- Proper cleanup on sign-out and re-initialization on sign-in

## Architecture

### Key Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `PusherBeamsController` | `apps/palakat/lib/features/notification/data/pusher_beams_controller.dart` | Riverpod controller managing interest registration/unregistration |
| `PusherBeamsMobileService` | `apps/palakat/lib/core/services/pusher_beams_mobile_service.dart` | Low-level service wrapping Pusher Beams SDK |
| `InAppNotificationService` | `apps/palakat/lib/core/services/in_app_notification_service.dart` | Displays in-app notification banners |
| `NotificationDisplayService` | `apps/palakat/lib/core/services/notification_display_service.dart` | Handles system notification display |

### Interest Types

The system subscribes to these interests based on user membership:

| Interest Pattern | Example | Purpose |
|-----------------|---------|---------|
| `palakat` | `palakat` | Global notifications |
| `debug-palakat` | `debug-palakat` | Debug/test notifications |
| `church.{id}` | `church.1` | Church-wide notifications |
| `church.{id}_bipra.{bipra}` | `church.1_bipra.ELD` | BIPRA-specific notifications |
| `membership.{id}` | `membership.1` | Personal notifications |
| `church.{id}_column.{columnId}` | `church.1_column.1` | Column-specific notifications |
| `church.{id}_column.{columnId}_bipra.{bipra}` | `church.1_column.1_bipra.ELD` | Column + BIPRA notifications |

## Critical Implementation Details

### 1. Controller Must Be `keepAlive`

```dart
@Riverpod(keepAlive: true)
class PusherBeamsController extends _$PusherBeamsController {
```

**Why:** The controller must persist across the app lifecycle. Without `keepAlive`, the controller gets disposed between sign-out and sign-in, losing its state and causing re-registration issues.

### 2. Account Parameter in `registerInterests`

```dart
Future<void> registerInterests(
  Membership membership, {
  Account? account,  // IMPORTANT: Must be passed explicitly
}) async {
  final effectiveAccount = account ?? membership.account;
  // ...
}
```

**Why:** The `membership` object from the backend doesn't have the `account` back-reference populated. The `account` must be passed explicitly from the caller.

### 3. Service Instance Reset on Sign-Out

```dart
Future<void> unregisterAllInterests() async {
  // ... unsubscribe logic ...
  
  // Reset service instance for fresh initialization on next sign-in
  _service = null;
  _inAppNotificationService = null;
  
  // Reset registration flags
  _hasRegisteredInterests = false;
  _registeredMembershipId = null;
}
```

**Why:** The Pusher Beams SDK is a singleton. Setting `_service = null` ensures a fresh service instance is created on the next sign-in, with proper re-initialization.

### 4. Registration Flow

**Sign-In (in `OtpVerificationScreen`):**
```dart
onAlreadyRegistered: (account) async {
  final membership = account.membership;
  if (membership != null && membership.id != null) {
    await pusherBeamsController.registerInterests(
      membership,
      account: account,  // Pass account explicitly!
    );
  }
}
```

**Sign-Out (in `SettingsController`):**
```dart
Future<void> signOut() async {
  final pusherBeamsController = ref.read(pusherBeamsControllerProvider.notifier);
  await pusherBeamsController.unregisterAllInterests();
  // ... rest of sign-out logic ...
}
```

### 5. Duplicate Registration Prevention

```dart
bool _hasRegisteredInterests = false;
int? _registeredMembershipId;

Future<void> registerInterests(...) async {
  if (_hasRegisteredInterests && _registeredMembershipId == membershipId) {
    return; // Skip if already registered for this membership
  }
  // ... registration logic ...
  _hasRegisteredInterests = true;
  _registeredMembershipId = membershipId;
}
```

**Why:** HomeScreen may call `registerInterests` multiple times during navigation. These flags prevent duplicate registrations.

### 6. Pusher Beams SDK Cleanup Sequence

```dart
// In clearAllState():
await PusherBeams.instance.clearAllState();  // Clear SDK state
await PusherBeams.instance.stop();           // Stop SDK
await FirebaseMessaging.instance.deleteToken(); // Delete FCM token
```

**Why:** The FCM token must be deleted to ensure a fresh token is obtained on re-sign-in. Without this, the old token may be invalid.

## Provider Dependencies

The `PusherBeamsController` uses `keepAlive` providers:

```dart
// This provider must also be keepAlive
@Riverpod(keepAlive: true)
NotificationDisplayService? notificationDisplayServiceSync(Ref ref) {
  return _sharedInstance;
}
```

**Rule:** If a provider is `keepAlive`, all providers it depends on must also be `keepAlive`.

## Testing Notifications

1. Sign in to the app
2. Verify logs show successful registration:
   ```
   ✅ Successfully registered all interests and handlers for membership X
   ```
3. Send a test notification to `debug-palakat` interest
4. Verify notification appears (in-app banner or system notification)

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "account is null" error | `account` not passed to `registerInterests` | Always pass `account` parameter explicitly |
| Notifications stop after re-sign-in | Service not reset on sign-out | Ensure `_service = null` in `unregisterAllInterests` |
| Duplicate registrations | Missing registration flags | Check `_hasRegisteredInterests` before registering |
| Provider disposed error | Controller not `keepAlive` | Use `@Riverpod(keepAlive: true)` |

## File References

- Controller: `apps/palakat/lib/features/notification/data/pusher_beams_controller.dart`
- Service: `apps/palakat/lib/core/services/pusher_beams_mobile_service.dart`
- Sign-in registration: `apps/palakat/lib/features/authentication/presentations/otp_verification_screen.dart`
- Sign-out cleanup: `apps/palakat/lib/features/settings/presentations/settings_controller.dart`
- HomeScreen fallback: `apps/palakat/lib/features/home/presentation/home_screen.dart`
