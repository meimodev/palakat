import 'package:firebase_auth/firebase_auth.dart';
import 'package:palakat_shared/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_auth_repository.g.dart';

/// Repository for Firebase Phone Authentication operations
@riverpod
FirebaseAuthRepository firebaseAuthRepository(Ref ref) {
  return FirebaseAuthRepository(FirebaseAuth.instance);
}

/// Handles Firebase Phone Authentication operations
class FirebaseAuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository(this._firebaseAuth);

  /// Verifies a phone number and sends an OTP via SMS
  ///
  /// Parameters:
  /// - [phoneNumber]: Phone number in E.164 format (e.g., "+6281234567890")
  /// - [onCodeSent]: Callback when OTP is sent successfully
  /// - [onVerificationCompleted]: Callback for automatic verification (Android)
  /// - [onVerificationFailed]: Callback when verification fails
  /// - [timeout]: Optional timeout duration (default: 60 seconds)
  ///
  /// Returns: Result with success or failure
  Future<Result<void, Failure>> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential)
    onVerificationCompleted,
    required void Function(Failure failure) onVerificationFailed,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          onVerificationFailed(_convertFirebaseException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout - no action needed
        },
        timeout: timeout,
      );

      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_convertFirebaseException(e));
    } catch (e) {
      // Handle network and other unexpected errors
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return Result.failure(
          Failure('Network error. Please check your connection', 503),
        );
      }
      return Result.failure(
        Failure('An unexpected error occurred. Please try again', 500),
      );
    }
  }

  /// Verifies the OTP code entered by the user
  ///
  /// Parameters:
  /// - [verificationId]: The verification ID received from codeSent callback
  /// - [smsCode]: The 6-digit OTP code entered by the user
  ///
  /// Returns: Result with UserCredential on success or Failure on error
  Future<Result<UserCredential, Failure>> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Create credential from verification ID and SMS code
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with the credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      return Result.success(userCredential);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_convertFirebaseException(e));
    } catch (e) {
      return Result.failure(Failure('Failed to verify OTP: $e'));
    }
  }

  /// Resends the OTP to the phone number
  ///
  /// Parameters:
  /// - [phoneNumber]: Phone number in E.164 format
  /// - [resendToken]: The resend token from the previous verification attempt
  /// - [onCodeSent]: Callback when OTP is sent successfully
  /// - [onVerificationCompleted]: Callback for automatic verification
  /// - [onVerificationFailed]: Callback when verification fails
  /// - [timeout]: Optional timeout duration (default: 60 seconds)
  ///
  /// Returns: Result with success or failure
  Future<Result<void, Failure>> resendOtp({
    required String phoneNumber,
    int? resendToken,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential)
    onVerificationCompleted,
    required void Function(Failure failure) onVerificationFailed,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          onVerificationFailed(_convertFirebaseException(e));
        },
        codeSent: (String verificationId, int? newResendToken) {
          onCodeSent(verificationId, newResendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout - no action needed
        },
        timeout: timeout,
        forceResendingToken: resendToken,
      );

      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_convertFirebaseException(e));
    } catch (e) {
      // Handle network and other unexpected errors
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return Result.failure(
          Failure('Network error. Please check your connection', 503),
        );
      }
      return Result.failure(
        Failure('Failed to resend OTP. Please try again', 500),
      );
    }
  }

  /// Signs out the current user from Firebase
  Future<Result<void, Failure>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure('Failed to sign out: $e'));
    }
  }

  /// Converts Firebase exceptions to Failure objects with user-friendly messages
  Failure _convertFirebaseException(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      // Phone number validation errors
      case 'invalid-phone-number':
        message =
            'The phone number format is invalid. Please check and try again';
        break;
      case 'missing-phone-number':
        message = 'Please enter a phone number';
        break;

      // OTP verification errors
      case 'invalid-verification-code':
        message = 'Invalid verification code. Please check and try again';
        break;
      case 'missing-verification-code':
        message = 'Please enter the verification code';
        break;
      case 'code-expired':
        message = 'Verification code expired. Please request a new one';
        break;

      // Session and verification ID errors
      case 'invalid-verification-id':
        message = 'Verification session expired. Please request a new code';
        break;
      case 'session-expired':
        message = 'Verification session expired. Please request a new code';
        break;

      // Rate limiting and quota errors
      case 'quota-exceeded':
        message = 'Too many attempts. Please try again in a few minutes';
        break;
      case 'too-many-requests':
        message = 'Too many requests. Please wait a moment before trying again';
        break;
      case 'app-not-authorized':
        message = 'App not authorized. Please contact support';
        break;

      // Network errors
      case 'network-request-failed':
        message =
            'Network error. Please check your internet connection and try again';
        break;
      case 'timeout':
        message =
            'Request timed out. Please check your connection and try again';
        break;

      // Account and credential errors
      case 'user-disabled':
        message = 'This account has been disabled. Please contact support';
        break;
      case 'credential-already-in-use':
        message =
            'This phone number is already associated with another account';
        break;
      case 'provider-already-linked':
        message = 'This phone number is already linked to your account';
        break;

      // Configuration errors
      case 'operation-not-allowed':
        message = 'Phone authentication is not enabled. Please contact support';
        break;
      case 'captcha-check-failed':
        message = 'Verification failed. Please try again';
        break;
      case 'web-context-cancelled':
        message = 'Verification cancelled. Please try again';
        break;

      // Generic errors
      case 'internal-error':
        message = 'An internal error occurred. Please try again';
        break;
      case 'unknown':
        message = 'An unexpected error occurred. Please try again';
        break;

      default:
        // Provide a user-friendly message for unknown errors
        message =
            e.message ?? 'An authentication error occurred. Please try again';
        // Check if the error message contains specific keywords
        if (e.message?.toLowerCase().contains('network') ?? false) {
          message = 'Network error. Please check your connection and try again';
        } else if (e.message?.toLowerCase().contains('timeout') ?? false) {
          message = 'Request timed out. Please try again';
        } else if (e.message?.toLowerCase().contains('rate') ?? false) {
          message = 'Too many attempts. Please wait before trying again';
        }
    }

    return Failure(message, _getErrorCode(e.code));
  }

  /// Maps Firebase error codes to numeric codes for easier handling
  int _getErrorCode(String code) {
    switch (code) {
      // Client errors (4xx)
      case 'invalid-phone-number':
      case 'missing-phone-number':
        return 400;
      case 'invalid-verification-code':
      case 'invalid-verification-id':
      case 'missing-verification-code':
      case 'credential-already-in-use':
        return 401;
      case 'user-disabled':
        return 403;
      case 'session-expired':
      case 'code-expired':
      case 'timeout':
        return 408;
      case 'quota-exceeded':
      case 'too-many-requests':
        return 429;

      // Server errors (5xx)
      case 'network-request-failed':
        return 503;
      case 'internal-error':
      case 'operation-not-allowed':
      case 'app-not-authorized':
        return 500;

      default:
        return 500;
    }
  }
}
