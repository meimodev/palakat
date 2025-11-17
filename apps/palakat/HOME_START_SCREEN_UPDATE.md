# Home Start Screen Update

## Change Made

Set `/home` as the start screen for all users, regardless of authentication status.

## Before

```dart
initialLocation: (isAuthenticated && hasValidToken)
    ? '/dashboard'
    : '/authentication',
```

**Behavior:**
- Authenticated users → Dashboard
- Unauthenticated users → Authentication

## After

```dart
initialLocation: '/home',
```

**Behavior:**
- All users → Home screen

## User Flow

```
App Start
    ↓
Home Screen (/home)
    ↓
User can navigate to:
    - Dashboard
    - Authentication
    - Other features
```

## Benefits

✅ **Consistent Experience**: All users see the same start screen
✅ **Simpler Logic**: No conditional routing on startup
✅ **Faster Load**: No need to check authentication on startup
✅ **User Control**: Users decide where to go from home

## Files Modified

- ✅ `lib/core/routing/app_routing.dart`
  - Removed authentication check
  - Set `initialLocation: '/home'`
  - Simplified router configuration

## Verification

```bash
flutter analyze --no-fatal-infos
# Result: ✅ No errors
```

---

**Status:** ✅ Complete
**Start Screen:** `/home` for all users
**Breaking Changes:** None
