# Sign-In Navigation Fix

## Problem
After successful sign-in (OTP verification), the app was not properly navigating to the home screen (`/home`). The navigation was using `context.popUntilNamedWithResult()` which tried to pop back to a home route that might not exist in the navigation stack.

## Root Cause
The authentication flow was using `popUntilNamedWithResult` to navigate back to home:

```dart
// ❌ Before (Broken)
controller.verifyOtp(
  onAlreadyRegistered: (account) {
    context.popUntilNamedWithResult(
      targetRouteName: AppRoute.home,
      result: account,
    );
  },
);
```

**Issues with this approach:**
1. If the user started at the authentication screen (not from home), there's no home route in the stack to pop back to
2. The `popUntilNamedWithResult` method would fail silently or not navigate anywhere
3. Users would be stuck on the OTP verification screen after successful login

## Solution
Changed the navigation to use `context.goNamed()` which directly navigates to the home route, replacing the current navigation stack:

```dart
// ✅ After (Fixed)
controller.verifyOtp(
  onAlreadyRegistered: (account) {
    context.goNamed(AppRoute.home);
  },
);
```

## Changes Made

### File: `apps/palakat/lib/features/authentication/presentations/otp_verification_screen.dart`

#### 1. Main OTP Completion Handler (Line ~210)
```dart
_OtpInput(
  onCompleted: (otp) {
    controller.verifyOtp(
      onAlreadyRegistered: (account) {
        // Navigate to home screen for existing users
        context.goNamed(AppRoute.home);  // ✅ Changed from popUntilNamedWithResult
      },
      onNotRegistered: () {
        // Navigate to registration for new users
        context.goNamed(AppRoute.account, extra: {...});
      },
    );
  },
)
```

#### 2. Retry Button Handler (Line ~264)
```dart
AuthErrorDisplay(
  onRetry: () {
    controller.verifyOtp(
      onAlreadyRegistered: (account) {
        context.goNamed(AppRoute.home);  // ✅ Changed from popUntilNamedWithResult
      },
      onNotRegistered: () {
        context.goNamed(AppRoute.account, extra: {...});
      },
    );
  },
)
```

## How It Works Now

### Authentication Flow

1. **User enters phone number** → Phone Input Screen
2. **User receives OTP** → OTP Verification Screen
3. **User enters correct OTP** → Firebase verification succeeds
4. **Backend validates account**:
   - **If registered**: `onAlreadyRegistered` callback → `context.goNamed(AppRoute.home)` → Home Screen ✅
   - **If not registered**: `onNotRegistered` callback → `context.goNamed(AppRoute.account)` → Account Registration Screen

### Navigation Behavior

**Using `context.goNamed(AppRoute.home)`:**
- Directly navigates to `/home` route
- Replaces the current navigation stack
- Works regardless of where the user came from
- Clean navigation history (user can't go back to OTP screen)

**Previous `popUntilNamedWithResult`:**
- Tried to pop back through the stack until finding home route
- Failed if home wasn't in the stack
- Left users stuck on OTP screen

## Route Configuration

The home route is defined in `apps/palakat/lib/core/routing/app_routing.dart`:

```dart
@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/home',  // Default starting point
    routes: [
      GoRoute(
        path: '/home',
        name: AppRoute.home,
        builder: (context, state) => const HomeScreen(),
      ),
      authenticationRouting,
      dashboardRouting,
      // ... other routes
    ],
  );
}
```

## Testing

### Test Scenarios

1. **New User Sign-In**:
   - Open app → Authentication screen
   - Enter phone → Enter OTP
   - ✅ Should navigate to Account Registration screen

2. **Existing User Sign-In**:
   - Open app → Authentication screen
   - Enter phone → Enter OTP
   - ✅ Should navigate to Home screen with bottom navigation

3. **Retry After Error**:
   - Enter wrong OTP → See error
   - Click retry → Enter correct OTP
   - ✅ Should navigate to Home screen

4. **Back Navigation**:
   - After successful sign-in at Home screen
   - Press back button
   - ✅ Should NOT go back to OTP screen (clean navigation)

## Benefits

1. **Reliable Navigation**: Always navigates to home, regardless of navigation stack state
2. **Clean History**: Users can't accidentally go back to authentication screens after signing in
3. **Consistent Behavior**: Same navigation pattern for both initial completion and retry
4. **Better UX**: Users immediately see the home screen after successful authentication

## Related Files

- `apps/palakat/lib/features/authentication/presentations/otp_verification_screen.dart` - Fixed navigation
- `apps/palakat/lib/core/routing/app_routing.dart` - Route definitions
- `apps/palakat/lib/features/home/presentation/home_screen.dart` - Home screen destination
- `packages/palakat_shared/lib/core/extension/build_context_extension.dart` - Navigation extensions

## Future Improvements

Consider adding:
1. **Auth Guard**: Redirect unauthenticated users to login automatically
2. **Deep Linking**: Handle navigation from push notifications
3. **Session Persistence**: Remember user's last screen and restore on app restart
4. **Splash Screen**: Check authentication status before showing initial route
