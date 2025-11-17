# Firebase Setup Instructions

This document outlines the manual steps required to complete Firebase Phone Authentication setup for the Palakat mobile app.

## Prerequisites

- Firebase project created at [Firebase Console](https://console.firebase.google.com/)
- Flutter CLI installed
- FlutterFire CLI installed: `dart pub global activate flutterfire_cli`

## Setup Steps

### 1. Configure Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project or create a new one
3. Navigate to **Authentication** → **Sign-in method**
4. Enable **Phone** authentication provider
5. Add test phone numbers for development (optional but recommended):
   - Example: +62 812 3456 7890 → OTP: 123456

### 2. Add Firebase Configuration Files

#### Option A: Using FlutterFire CLI (Recommended)

Run the following command from the `apps/palakat` directory:

```bash
flutterfire configure
```

This will:
- Generate `firebase_options.dart` with your project configuration
- Download `google-services.json` for Android
- Download `GoogleService-Info.plist` for iOS

#### Option B: Manual Configuration

**Android:**
1. Download `google-services.json` from Firebase Console
2. Place it in `apps/palakat/android/app/google-services.json`

**iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `apps/palakat/ios/Runner/GoogleService-Info.plist`
3. Add it to Xcode project:
   - Open `apps/palakat/ios/Runner.xcworkspace` in Xcode
   - Right-click on `Runner` folder
   - Select "Add Files to Runner"
   - Select `GoogleService-Info.plist`
   - Ensure "Copy items if needed" is checked

**Update firebase_options.dart:**
Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration values from the Firebase Console.

### 3. Configure Android SHA Fingerprints

Firebase Phone Authentication requires SHA-1 and SHA-256 fingerprints for Android.

**Get Debug Fingerprints:**
```bash
cd apps/palakat/android
./gradlew signingReport
```

**Get Release Fingerprints:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Add these fingerprints to your Firebase project:
1. Go to Firebase Console → Project Settings
2. Select your Android app
3. Add SHA-1 and SHA-256 fingerprints

### 4. Install Dependencies

From the `apps/palakat` directory:

```bash
flutter pub get
```

For iOS, also run:
```bash
cd ios
pod install
cd ..
```

### 5. Verify Setup

Run the app to verify Firebase initialization:

```bash
flutter run
```

Check the console for Firebase initialization messages. There should be no errors.

### 6. Test Phone Authentication

Once the authentication screens are implemented, test with:

**Test Phone Numbers** (configured in Firebase Console):
- Use the test numbers you configured in step 1
- These bypass actual SMS sending during development

**Real Phone Numbers:**
- Ensure your Firebase project has billing enabled
- SMS charges may apply

## Troubleshooting

### Android Build Errors

**Error: "google-services.json not found"**
- Ensure `google-services.json` is in `android/app/` directory
- Run `flutter clean` and rebuild

**Error: "SHA-1 fingerprint not configured"**
- Add SHA-1 and SHA-256 fingerprints to Firebase Console
- Rebuild the app

### iOS Build Errors

**Error: "GoogleService-Info.plist not found"**
- Ensure the file is added to Xcode project
- Check that it's included in the Runner target

**Error: "Firebase/Core module not found"**
- Run `pod install` in the `ios` directory
- Clean build folder in Xcode (Cmd+Shift+K)

### Runtime Errors

**Error: "Firebase not initialized"**
- Check that `Firebase.initializeApp()` is called in `main.dart`
- Verify `firebase_options.dart` has correct configuration

**Error: "Phone authentication not enabled"**
- Enable Phone authentication in Firebase Console
- Wait a few minutes for changes to propagate

## Security Considerations

### Production Setup

1. **Enable App Check** (recommended):
   - Prevents abuse of Firebase services
   - Configure in Firebase Console → App Check

2. **Configure reCAPTCHA** (for web):
   - Required for web platform
   - Configure in Firebase Console

3. **Rate Limiting**:
   - Implement backend rate limiting
   - Monitor authentication attempts

4. **Test Phone Numbers**:
   - Remove test phone numbers in production
   - Only use for development/staging

## Environment Variables

Add Firebase configuration to `.env` file (optional):

```env
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
```

Note: The current implementation uses `firebase_options.dart` directly, but you can modify it to read from environment variables if needed.

## Next Steps

After completing this setup:

1. Implement the authentication screens (Tasks 2-17)
2. Test the complete authentication flow
3. Configure backend validation endpoint
4. Test on physical devices (Android and iOS)
5. Deploy to staging environment for testing

## Resources

- [Firebase Phone Authentication Documentation](https://firebase.google.com/docs/auth/flutter/phone-auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
