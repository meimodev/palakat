# Requirements Document

## Introduction

This specification defines the requirements for redesigning the Palakat mobile app authentication screens to properly implement Firebase Phone Authentication with backend validation. The redesign will align with the existing design system (Material 3 with teal color scheme) and implement a secure authentication flow that validates users against the backend after Firebase authentication succeeds.

## Glossary

- **Firebase Phone Auth**: Firebase Authentication service that verifies phone numbers via SMS OTP
- **Palakat Mobile App**: Flutter mobile application for church members (referred to as "the System")
- **Backend API**: NestJS REST API that manages user accounts and sessions
- **OTP**: One-Time Password sent via SMS for phone verification
- **Auth Flow**: The complete authentication process from phone input to successful login
- **Design System**: The established UI patterns using Material 3, teal color scheme, and OpenSans typography
- **Validation Endpoint**: The `/auth/validate` backend endpoint that checks if a phone number has an associated account
- **Registration Flow**: The process of creating a new account when validation returns empty/null data
- **Session Tokens**: Access and refresh tokens returned by the backend for authenticated sessions

## Requirements

### Requirement 1: Firebase Phone Authentication Integration

**User Story:** As a church member, I want to authenticate using my phone number with SMS verification, so that I can securely access the app without remembering passwords.

#### Acceptance Criteria

1. WHEN the user opens the authentication screen, THE Palakat Mobile App SHALL display a phone number input field with country code selector
2. WHEN the user enters a valid phone number and taps continue, THE Palakat Mobile App SHALL initiate Firebase Phone Authentication and send an SMS OTP to the provided number
3. WHEN Firebase sends the OTP, THE Palakat Mobile App SHALL display an OTP verification screen with a 6-digit input field
4. WHEN the user enters the complete 6-digit OTP, THE Palakat Mobile App SHALL verify the OTP with Firebase Authentication service
5. IF Firebase OTP verification fails, THEN THE Palakat Mobile App SHALL display an error message indicating invalid OTP and allow retry

### Requirement 2: Backend Account Validation

**User Story:** As a system administrator, I want the app to validate authenticated phone numbers against our backend database, so that only registered church members can access the system.

#### Acceptance Criteria

1. WHEN Firebase Phone Authentication succeeds, THE Palakat Mobile App SHALL call the `/auth/validate` endpoint with the verified phone number
2. WHEN the validation endpoint returns success with non-empty account data, THE Palakat Mobile App SHALL store the authentication tokens and account information locally
3. WHEN the validation endpoint returns success with empty or null account data, THE Palakat Mobile App SHALL navigate the user to the registration screen
4. IF the validation endpoint returns an error, THEN THE Palakat Mobile App SHALL display an appropriate error message to the user
5. WHEN authentication tokens are stored, THE Palakat Mobile App SHALL navigate the user to the home screen

### Requirement 3: Design System Compliance

**User Story:** As a user, I want the authentication screens to match the app's visual design, so that I have a consistent and professional experience.

#### Acceptance Criteria

1. THE Palakat Mobile App SHALL use the teal color scheme (BaseColor.teal) as the primary color throughout authentication screens
2. THE Palakat Mobile App SHALL use Material 3 design patterns with elevated cards, rounded corners (16px radius), and subtle shadows
3. THE Palakat Mobile App SHALL use OpenSans font family with appropriate weights (Regular 400, SemiBold 600, Bold 700)
4. THE Palakat Mobile App SHALL use BaseTypography styles (titleMedium, bodyMedium, bodySmall) for text elements
5. THE Palakat Mobile App SHALL display loading states using the existing ButtonWidget.primary loading indicator
6. THE Palakat Mobile App SHALL use BaseColor.cardBackground1 for card backgrounds and BaseColor.secondaryText for hint text

### Requirement 4: OTP Resend and Timer

**User Story:** As a user, I want to resend the OTP if I don't receive it, so that I can complete authentication even if the first SMS fails.

#### Acceptance Criteria

1. WHEN the OTP verification screen is displayed, THE Palakat Mobile App SHALL start a 120-second countdown timer
2. WHILE the countdown timer is active, THE Palakat Mobile App SHALL display the remaining time in MM:SS format
3. WHILE the countdown timer is active, THE Palakat Mobile App SHALL disable the resend OTP button
4. WHEN the countdown timer reaches zero, THE Palakat Mobile App SHALL enable the resend OTP button
5. WHEN the user taps the enabled resend button, THE Palakat Mobile App SHALL restart Firebase Phone Authentication and reset the countdown timer to 120 seconds

### Requirement 5: Error Handling and User Feedback

**User Story:** As a user, I want clear feedback when errors occur during authentication, so that I understand what went wrong and how to proceed.

#### Acceptance Criteria

1. WHEN a network error occurs during any authentication step, THE Palakat Mobile App SHALL display an error message with retry option
2. WHEN Firebase rate limiting is triggered, THE Palakat Mobile App SHALL display a message indicating too many attempts and suggest waiting
3. WHEN the backend validation fails with a 404 error, THE Palakat Mobile App SHALL treat this as a new user scenario and proceed to registration
4. WHEN any other backend error occurs, THE Palakat Mobile App SHALL display the error message returned by the backend
5. THE Palakat Mobile App SHALL clear error messages when the user modifies input fields or retries the action

### Requirement 6: Phone Number Input Validation

**User Story:** As a user, I want the app to validate my phone number format before sending OTP, so that I don't waste time with invalid numbers.

#### Acceptance Criteria

1. THE Palakat Mobile App SHALL display a country code selector defaulting to Indonesia (+62)
2. WHEN the user enters a phone number, THE Palakat Mobile App SHALL format the display with appropriate spacing
3. WHEN the user taps continue with an empty phone field, THE Palakat Mobile App SHALL display an error message "Please enter phone number"
4. WHEN the user taps continue with an invalid phone format, THE Palakat Mobile App SHALL display an error message "Please enter a valid phone number"
5. WHEN the phone number is valid, THE Palakat Mobile App SHALL enable the continue button with full opacity

### Requirement 7: Registration Flow Transition

**User Story:** As a new user, I want to seamlessly transition to registration after phone verification, so that I can complete my account setup.

#### Acceptance Criteria

1. WHEN the validation endpoint returns empty or null account data, THE Palakat Mobile App SHALL store the verified phone number in the registration state
2. WHEN navigating to registration, THE Palakat Mobile App SHALL pre-fill the phone number field with the verified number
3. THE Palakat Mobile App SHALL prevent the user from modifying the pre-filled phone number in the registration screen
4. WHEN the user completes registration, THE Palakat Mobile App SHALL call the backend registration endpoint with the verified phone number
5. WHEN registration succeeds, THE Palakat Mobile App SHALL automatically sign in the user and navigate to the home screen

### Requirement 8: Session Management

**User Story:** As a user, I want my authentication session to persist across app restarts, so that I don't have to sign in every time I open the app.

#### Acceptance Criteria

1. WHEN the backend returns authentication tokens, THE Palakat Mobile App SHALL store both access token and refresh token in local storage using Hive
2. WHEN the backend returns account data, THE Palakat Mobile App SHALL store the complete account object in local storage
3. WHEN the app launches, THE Palakat Mobile App SHALL check for stored authentication tokens before showing the authentication screen
4. IF valid tokens exist in local storage, THEN THE Palakat Mobile App SHALL navigate directly to the home screen
5. WHEN the user signs out, THE Palakat Mobile App SHALL clear all stored authentication data from local storage

### Requirement 9: Accessibility and Usability

**User Story:** As a user, I want the authentication screens to be easy to use and accessible, so that I can authenticate quickly and efficiently.

#### Acceptance Criteria

1. THE Palakat Mobile App SHALL display appropriate keyboard types (numeric for phone and OTP inputs)
2. THE Palakat Mobile App SHALL auto-focus the OTP input field when the verification screen appears
3. WHEN the user completes entering the 6-digit OTP, THE Palakat Mobile App SHALL automatically trigger verification without requiring a button tap
4. THE Palakat Mobile App SHALL provide visual feedback for loading states with disabled inputs during processing
5. THE Palakat Mobile App SHALL display the masked phone number (e.g., "+62 812 **** 5678") in the OTP verification screen for confirmation

### Requirement 10: Back Navigation and State Management

**User Story:** As a user, I want to navigate back from the OTP screen to correct my phone number, so that I can fix mistakes without restarting the app.

#### Acceptance Criteria

1. THE Palakat Mobile App SHALL display a back button on the OTP verification screen
2. WHEN the user taps the back button on OTP screen, THE Palakat Mobile App SHALL cancel the Firebase verification session and return to the phone input screen
3. WHEN returning to the phone input screen, THE Palakat Mobile App SHALL preserve the previously entered phone number
4. WHEN the user modifies the phone number after going back, THE Palakat Mobile App SHALL clear any previous error states
5. THE Palakat Mobile App SHALL cancel any active countdown timers when navigating back from the OTP screen
