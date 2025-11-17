# Implementation Plan

- [x] 1. Firebase Setup and Configuration
  - Add Firebase dependencies to pubspec.yaml (firebase_core, firebase_auth, intl_phone_number_input)
  - Configure Firebase for Android (update build.gradle, add google-services.json)
  - Configure Firebase for iOS (update Podfile, add GoogleService-Info.plist)
  - Initialize Firebase in main.dart before app runs
  - Enable Phone Authentication in Firebase Console
  - _Requirements: 1.1, 1.2_

- [x] 2. Create Phone Number Utilities
  - Create PhoneNumberFormatter class with format(), toE164(), and mask() methods
  - Create CountryCode model with code, name, flag, and dialCode fields
  - Create list of supported country codes (Indonesia, Malaysia, Singapore, Philippines)
  - Write unit tests for phone number formatting and E.164 conversion
  - _Requirements: 6.1, 6.2, 9.5_

- [x] 3. Implement Firebase Auth Repository
  - Create FirebaseAuthRepository class in features/authentication/data/
  - Implement verifyPhoneNumber() method with Firebase PhoneAuthProvider
  - Implement verifyOtp() method to verify SMS code
  - Implement resendOtp() method using resend token
  - Add error handling and convert Firebase exceptions to Failure objects
  - Return Result<T, Failure> for all methods
  - _Requirements: 1.2, 1.3, 1.4, 1.5_

- [x] 4. Update Authentication State Model
  - Update AuthenticationState with phoneNumber, countryCode, fullPhoneNumber fields
  - Add otp, showOtpScreen, verificationId, resendToken fields
  - Add loading state fields: isSendingOtp, isVerifyingOtp, isValidatingAccount
  - Add remainingSeconds and canResendOtp for timer functionality
  - Add account and tokens fields for successful authentication
  - Generate Freezed code with build_runner
  - _Requirements: 1.1, 2.1, 4.1, 8.1_

- [x] 5. Implement Authentication Controller Core Logic
  - Update AuthenticationController with phone input methods (onPhoneNumberChanged, onCountryCodeChanged)
  - Implement validatePhoneNumber() with format checking
  - Implement sendOtp() method that calls Firebase repository
  - Add error handling and state updates for phone input flow
  - Implement clearError() method
  - _Requirements: 1.1, 1.2, 6.3, 6.4, 5.1_

- [x] 6. Implement OTP Verification Logic
  - Implement onOtpChanged() method in controller
  - Implement validateOtp() method checking for 6 digits
  - Implement verifyOtp() method that calls Firebase repository
  - Add backend validation call to /auth/validate endpoint after Firebase success
  - Handle three scenarios: existing user (navigate home), new user (navigate registration), error (show message)
  - Update local storage with tokens and account data on success
  - _Requirements: 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5, 8.1, 8.2_

- [x] 7. Implement Timer Functionality
  - Implement startTimer() method with 120-second countdown
  - Implement stopTimer() method to cancel active timer
  - Update remainingSeconds state every second
  - Set canResendOtp to true when timer reaches 0
  - Implement formatTime() method to display MM:SS format
  - Implement resendOtp() method that restarts Firebase verification and timer
  - Clean up timer in controller's onDispose
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 8. Create Phone Input Screen UI
  - Create phone_input_screen.dart with SafeArea and Scaffold
  - Add background with padding using BaseSize.w12
  - Create Material card with BaseColor.cardBackground1, elevation 1, 16px border radius
  - Add phone icon in teal circle (BaseColor.teal[100] background, BaseColor.teal[700] icon)
  - Add "Sign In" title using BaseTypography.titleMedium.bold
  - Add country code selector using intl_phone_number_input package
  - Add phone number InputWidget.text with numeric keyboard
  - Add ButtonWidget.primary "Continue" button with loading state
  - Wire up controller methods (onPhoneNumberChanged, sendOtp)
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 6.1, 6.2, 9.1_

- [x] 9. Create OTP Verification Screen UI
  - Create otp_verification_screen.dart with SafeArea and Scaffold
  - Add back button in top-left that calls goBackToPhoneInput()
  - Create Material card matching phone input screen styling
  - Add security icon in teal circle
  - Add "Verify OTP" title using BaseTypography.titleMedium.bold
  - Display masked phone number using PhoneNumberFormatter.mask()
  - Add Pinput widget with 6-digit input, custom PinTheme styling
  - Add countdown timer display in MM:SS format
  - Add "Resend Code" button that enables when canResendOtp is true
  - Wire up controller methods (onOtpChanged, verifyOtp, resendOtp)
  - Auto-submit verification when 6 digits entered
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.1, 4.2, 4.3, 4.4, 9.2, 9.3, 9.5_

- [x] 10. Implement Error Handling UI
  - Create AuthErrorDisplay widget for showing errors
  - Add error icon in red circle (BaseColor.red[100] background, BaseColor.red[700] icon)
  - Display error message in BaseColor.red[800] text
  - Add optional retry button using ButtonWidget.outlined
  - Add error display to phone input screen below card
  - Add error display to OTP verification screen below card
  - Implement error clearing when user modifies input
  - Add Riverpod listener for errorMessage state changes
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 11. Implement Navigation Flow
  - Update app routing to include phone_input and otp_verification routes
  - Implement showOtpScreen() method that sets showOtpScreen state to true
  - Implement goBackToPhoneInput() method that resets to phone input state
  - Add navigation logic in controller: home screen for existing users, registration for new users
  - Preserve phone number when navigating back from OTP screen
  - Cancel timer when navigating back
  - Update splash screen to check for existing auth tokens before showing phone input
  - _Requirements: 2.5, 7.1, 7.2, 10.1, 10.2, 10.3, 10.4, 10.5_

- [x] 12. Implement Registration Flow Integration
  - Update registration screen to accept pre-filled phone number parameter
  - Add verified phone number to registration state when validation returns empty
  - Make phone number field read-only in registration screen
  - Pass verified phone to backend registration endpoint
  - Auto-sign in user after successful registration
  - Navigate to home screen after registration completes
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 13. Implement Session Persistence
  - Update AuthRepository to store tokens using Hive in validateAccountByPhone
  - Store complete account object in local storage
  - Add method to check for existing tokens on app launch
  - Update main.dart to check auth state before showing initial route
  - Implement auto-navigation to home if valid tokens exist
  - Implement clearAuth() method that removes all stored data on logout
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 14. Add Loading States and Visual Feedback
  - Add loading indicator to continue button during sendOtp
  - Add loading indicator during OTP verification
  - Disable phone input field while sending OTP
  - Disable OTP input field while verifying
  - Add subtle animation when transitioning between screens
  - Show success feedback before navigation (optional)
  - _Requirements: 3.5, 9.4_

- [x] 15. Implement Accessibility Features
  - Add semantic labels to all buttons and input fields
  - Set keyboard type to phone for phone input
  - Set keyboard type to number for OTP input
  - Auto-focus OTP input when screen appears
  - Add announcements for screen reader when OTP sent or errors occur
  - Ensure 4.5:1 contrast ratio for all text elements
  - Add focus indicators for keyboard navigation
  - _Requirements: 9.1, 9.2, 9.3, 9.4_

- [x] 16. Handle Edge Cases and Error Scenarios
  - Handle Firebase rate limiting with appropriate user message
  - Handle network errors with retry option
  - Handle OTP expiration with resend prompt
  - Handle backend 404 as new user scenario
  - Handle backend 500 errors with retry option
  - Add timeout handling for long-running operations
  - Test with invalid phone formats
  - Test with invalid OTP codes
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 6.4_

- [x] 17. Replace Existing Authentication Screen
  - Remove old authentication_screen.dart implementation
  - Update routing to use new phone_input_screen as entry point
  - Remove dummy OTP verification logic
  - Update any references to old authentication flow
  - Ensure backward compatibility during transition
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 18. Write Unit Tests
- [x] 18.1 Write tests for PhoneNumberFormatter utility methods
  - Test E.164 conversion for various country codes
  - Test display formatting with proper spacing
  - Test phone number masking
  - _Requirements: 6.2, 9.5_

- [x] 18.2 Write tests for AuthenticationController
  - Test phone number validation logic
  - Test OTP validation logic
  - Test timer countdown functionality
  - Test state transitions during auth flow
  - Test error handling scenarios
  - _Requirements: 1.1, 1.2, 1.4, 4.1, 5.5, 6.3, 6.4_

- [x] 18.3 Write tests for FirebaseAuthRepository
  - Mock Firebase Auth calls
  - Test verifyPhoneNumber with valid and invalid inputs
  - Test verifyOtp success and failure scenarios
  - Test resendOtp functionality
  - Test error conversion to Failure objects
  - _Requirements: 1.2, 1.3, 1.4, 1.5_

- [x] 19. Write Widget Tests
- [x] 19.1 Write tests for PhoneInputScreen
  - Test screen renders correctly
  - Test country code selector interaction
  - Test phone input accepts only numbers
  - Test continue button disabled state
  - Test error message display
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 6.3, 6.4_

- [x] 19.2 Write tests for OTPVerificationScreen
  - Test screen renders correctly
  - Test timer countdown display
  - Test resend button enable/disable
  - Test auto-submit on 6 digits
  - Test back navigation
  - Test masked phone number display
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 9.5, 10.1_

- [x] 20. Perform Integration Testing
  - Test complete flow: phone input → OTP → validation → home
  - Test new user flow: phone input → OTP → validation → registration
  - Test error recovery: invalid OTP → retry → success
  - Test back navigation preserves state
  - Test session persistence across app restarts
  - Test on physical Android device
  - Test on physical iOS device
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 7.1, 8.3, 8.4, 10.2, 10.3_

- [x] 21. Final Polish and Optimization
  - Review all UI elements for design system compliance
  - Optimize state rebuilds to minimize unnecessary renders
  - Add subtle animations for better UX
  - Test with different screen sizes and orientations
  - Verify all colors match design system
  - Ensure consistent spacing throughout
  - Test with slow network conditions
  - Add analytics events for auth flow tracking (optional)
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
