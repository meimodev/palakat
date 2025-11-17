# Integration Tests for Firebase Phone Authentication

This directory contains integration tests for the complete Firebase Phone Authentication flow in the Palakat mobile app.

## Test Coverage

### Complete Authentication Flows

1. **Existing User Flow** (`phone input → OTP → validation → home`)
   - User enters phone number
   - Firebase sends OTP
   - User enters OTP
   - Backend validates and returns account data
   - User is navigated to home screen
   - Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.5

2. **New User Flow** (`phone input → OTP → validation → registration`)
   - User enters phone number
   - Firebase sends OTP
   - User enters OTP
   - Backend returns 404 or empty data
   - User is navigated to registration screen
   - Phone number is pre-filled and read-only
   - Requirements: 2.3, 7.1, 7.2

3. **Error Recovery Flow** (`invalid OTP → retry → success`)
   - User enters invalid OTP
   - Error message is displayed
   - User retries with correct OTP
   - Authentication succeeds
   - Requirements: 1.5, 5.1, 5.5

### State Management Tests

4. **Back Navigation**
   - User navigates from OTP screen back to phone input
   - Phone number is preserved
   - OTP state is cleared
   - Timer is cancelled
   - Requirements: 10.1, 10.2, 10.3, 10.5

5. **Session Persistence**
   - Auth tokens are stored in local storage
   - Account data is persisted
   - Tokens can be retrieved on app restart
   - Auth data can be cleared on logout
   - Requirements: 8.1, 8.2, 8.3, 8.4

### Validation Tests

6. **Phone Number Validation**
   - Valid phone numbers for different countries (Indonesia, Malaysia, Singapore, Philippines)
   - Invalid formats (too short, too long, all zeros, repeating digits)
   - Country code changes
   - Requirements: 6.1, 6.2, 6.3, 6.4

7. **OTP Validation**
   - Valid 6-digit OTP
   - Empty OTP
   - Too short/long OTP
   - Non-numeric characters
   - Requirements: 1.4, 6.3

8. **Timer Functionality**
   - 120-second countdown
   - Timer format (MM:SS)
   - Resend button enable/disable
   - Timer cancellation
   - Requirements: 4.1, 4.2, 4.3, 4.4

### Error Handling Tests

9. **Error Message Clearing**
   - Errors clear when user modifies phone input
   - Errors clear when user modifies OTP input
   - Explicit error clearing
   - Requirements: 5.5

10. **State Transitions**
    - Initial state
    - Phone input state
    - OTP screen state
    - Verification state
    - Success/error states
    - Requirements: 1.1, 1.2, 1.4, 2.1

### Edge Cases

11. **Edge Case Handling**
    - Empty phone number submission
    - Invalid phone formats (letters, special characters)
    - Network timeout scenarios
    - Concurrent state updates
    - Timer cleanup on navigation
    - Complete state reset
    - Requirements: 5.1, 5.2, 6.3, 6.4, 10.5

## Running the Tests

### Prerequisites

1. **Firebase Test Mode Configuration**
   - Configure test phone numbers in Firebase Console
   - Example test numbers:
     - `+62 812 3456 7890` → OTP: `123456`
     - `+62 813 9876 5432` → OTP: `654321`

2. **Environment Setup**
   - Ensure `.env` file is configured
   - Firebase is initialized in the app
   - Hive is set up for local storage

### Run All Integration Tests

```bash
# From the app directory
cd apps/palakat

# Run all integration tests
flutter test test/integration/

# Run with coverage
flutter test --coverage test/integration/

# Run specific test file
flutter test test/integration/authentication_flow_test.dart
```

### Run with Melos (from monorepo root)

```bash
# Run all tests in palakat app
melos run test --scope=palakat

# Run with specific pattern
melos exec --scope=palakat -- flutter test test/integration/
```

## Test Structure

```
test/integration/
├── README.md                           # This file
└── authentication_flow_test.dart       # Main integration tests
```

## Testing on Physical Devices

### Android Device Testing

1. **Connect Android device via USB**
   ```bash
   flutter devices
   ```

2. **Run tests on device**
   ```bash
   flutter test --device-id=<device-id> test/integration/
   ```

3. **Verify Firebase Phone Auth**
   - Ensure device can receive SMS
   - Check Firebase Console for verification logs
   - Monitor device logs: `adb logcat`

### iOS Device Testing

1. **Connect iOS device**
   ```bash
   flutter devices
   ```

2. **Run tests on device**
   ```bash
   flutter test --device-id=<device-id> test/integration/
   ```

3. **Verify Firebase Phone Auth**
   - Ensure device can receive SMS
   - Check Xcode console for logs
   - Verify Firebase configuration in `GoogleService-Info.plist`

## Manual Testing Checklist

While automated tests cover most scenarios, some flows require manual testing:

### Complete Flow Testing

- [ ] Enter valid phone number and receive OTP
- [ ] Enter OTP and verify successful authentication
- [ ] Existing user navigates to home screen
- [ ] New user navigates to registration screen
- [ ] Registration completes and user is signed in

### Error Scenarios

- [ ] Invalid phone number shows error
- [ ] Invalid OTP shows error
- [ ] Network error shows retry option
- [ ] Rate limiting shows appropriate message
- [ ] Backend errors are handled gracefully

### UI/UX Testing

- [ ] Loading states display correctly
- [ ] Error messages are clear and helpful
- [ ] Timer counts down properly
- [ ] Resend button enables at 0 seconds
- [ ] Back navigation preserves phone number
- [ ] Keyboard types are appropriate (numeric)
- [ ] Auto-focus works on OTP screen
- [ ] Auto-submit works when 6 digits entered

### Session Persistence

- [ ] Close and reopen app - user stays logged in
- [ ] Logout clears all auth data
- [ ] App checks for tokens on launch
- [ ] Invalid tokens trigger re-authentication

### Accessibility

- [ ] Screen reader announces state changes
- [ ] All buttons have semantic labels
- [ ] Contrast ratios meet WCAG standards
- [ ] Focus indicators are visible
- [ ] Keyboard navigation works

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `Firebase.initializeApp()` is called before tests
   - Check `firebase_options.dart` is generated

2. **Hive initialization fails**
   - Ensure `LocalStorageService.initHive()` is called
   - Check write permissions in test environment

3. **Tests timeout**
   - Increase timeout in test configuration
   - Check network connectivity
   - Verify Firebase Test Mode is enabled

4. **OTP not received**
   - Verify test phone numbers in Firebase Console
   - Check Firebase quota limits
   - Ensure device can receive SMS (for physical device tests)

### Debug Tips

```dart
// Enable verbose logging
debugPrint('Current state: ${controller.state}');

// Check Firebase Auth state
FirebaseAuth.instance.authStateChanges().listen((user) {
  debugPrint('Auth state changed: ${user?.phoneNumber}');
});

// Monitor local storage
final token = await LocalStorageService.getAccessToken();
debugPrint('Stored token: $token');
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.1'
      - run: flutter pub get
      - run: flutter test test/integration/
```

## Notes

- Integration tests may take longer than unit tests due to Firebase operations
- Some tests require network connectivity
- Physical device tests require actual SMS capability
- Test phone numbers should be configured in Firebase Test Mode to avoid SMS costs
- Always clean up test data after running tests

## Related Documentation

- [Firebase Phone Auth Setup](../../FIREBASE_SETUP.md)
- [Firebase Setup Status](../../FIREBASE_SETUP_STATUS.md)
- [Requirements Document](../../../.kiro/specs/firebase-phone-auth-redesign/requirements.md)
- [Design Document](../../../.kiro/specs/firebase-phone-auth-redesign/design.md)
- [Tasks Document](../../../.kiro/specs/firebase-phone-auth-redesign/tasks.md)
