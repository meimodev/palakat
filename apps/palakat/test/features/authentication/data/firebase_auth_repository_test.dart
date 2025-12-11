import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:palakat/features/authentication/data/firebase_auth_repository.dart';
import 'package:palakat_shared/models.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockPhoneAuthCredential extends Mock implements PhoneAuthCredential {}

class MockUser extends Mock implements User {}

// Fake classes for callbacks
class FakePhoneAuthCredential extends Fake implements PhoneAuthCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late FirebaseAuthRepository repository;

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 60));
    registerFallbackValue(FakePhoneAuthCredential());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    repository = FirebaseAuthRepository(mockFirebaseAuth);
  });

  group('FirebaseAuthRepository - verifyPhoneNumber', () {
    test('calls Firebase verifyPhoneNumber with correct parameters', () async {
      // Arrange
      const phoneNumber = '+6281234567890';
      var codeSentCalled = false;
      String? capturedVerificationId;
      int? capturedResendToken;

      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((invocation) async {
        // Simulate code sent callback
        final codeSent =
            invocation.namedArguments[const Symbol('codeSent')] as Function;
        codeSent('test-verification-id', 12345);
      });

      // Act
      await repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          codeSentCalled = true;
          capturedVerificationId = verificationId;
          capturedResendToken = resendToken;
        },
        onVerificationCompleted: (_) {},
        onVerificationFailed: (_) {},
      );

      // Assert
      verify(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: const Duration(seconds: 60),
        ),
      ).called(1);

      expect(codeSentCalled, true);
      expect(capturedVerificationId, 'test-verification-id');
      expect(capturedResendToken, 12345);
    });

    test('handles verification completed callback', () async {
      // Arrange
      const phoneNumber = '+6281234567890';
      var verificationCompletedCalled = false;
      final mockCredential = MockPhoneAuthCredential();

      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((invocation) async {
        // Simulate verification completed callback
        final verificationCompleted =
            invocation.namedArguments[const Symbol('verificationCompleted')]
                as Function;
        verificationCompleted(mockCredential);
      });

      // Act
      await repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (_, _) {},
        onVerificationCompleted: (credential) {
          verificationCompletedCalled = true;
        },
        onVerificationFailed: (_) {},
      );

      // Assert
      expect(verificationCompletedCalled, true);
    });

    test('handles verification failed with FirebaseAuthException', () async {
      // Arrange
      const phoneNumber = '+6281234567890';
      var verificationFailedCalled = false;
      Failure? capturedFailure;

      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((invocation) async {
        // Simulate verification failed callback
        final verificationFailed =
            invocation.namedArguments[const Symbol('verificationFailed')]
                as Function;
        verificationFailed(
          FirebaseAuthException(
            code: 'invalid-phone-number',
            message: 'Invalid phone number',
          ),
        );
      });

      // Act
      await repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (_, _) {},
        onVerificationCompleted: (_) {},
        onVerificationFailed: (failure) {
          verificationFailedCalled = true;
          capturedFailure = failure;
        },
      );

      // Assert
      expect(verificationFailedCalled, true);
      expect(capturedFailure, isNotNull);
      expect(capturedFailure!.message, contains('phone number'));
      expect(capturedFailure!.code, 400);
    });

    test('handles network errors', () async {
      // Arrange
      const phoneNumber = '+6281234567890';

      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Network error',
        ),
      );

      // Act
      final result = await repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (_, _) {},
        onVerificationCompleted: (_) {},
        onVerificationFailed: (_) {},
      );

      // Assert
      var failureCalled = false;
      result.when(
        onSuccess: (_) => fail('Should not succeed'),
        onFailure: (failure) {
          failureCalled = true;
          expect(failure.message, contains('Network'));
          expect(failure.code, 503);
        },
      );
      expect(failureCalled, true);
    });

    test('uses custom timeout when provided', () async {
      // Arrange
      const phoneNumber = '+6281234567890';
      const customTimeout = Duration(seconds: 30);

      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((invocation) async {
        final codeSent =
            invocation.namedArguments[const Symbol('codeSent')] as Function;
        codeSent('test-id', null);
      });

      // Act
      await repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: customTimeout,
        onCodeSent: (_, _) {},
        onVerificationCompleted: (_) {},
        onVerificationFailed: (_) {},
      );

      // Assert
      verify(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: customTimeout,
        ),
      ).called(1);
    });
  });

  group('FirebaseAuthRepository - verifyOtp', () {
    test('successfully verifies OTP and returns UserCredential', () async {
      // Arrange
      const verificationId = 'test-verification-id';
      const smsCode = '123456';
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(
        () => mockFirebaseAuth.signInWithCredential(any()),
      ).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await repository.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Assert
      var successCalled = false;
      result.when(
        onSuccess: (credential) {
          successCalled = true;
          expect(credential, mockUserCredential);
        },
        onFailure: (_) => fail('Should not fail'),
      );

      expect(successCalled, true);
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('handles invalid verification code error', () async {
      // Arrange
      const verificationId = 'test-verification-id';
      const smsCode = '123456';

      when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'Invalid code',
        ),
      );

      // Act
      final result = await repository.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Assert
      var failureCalled = false;
      result.when(
        onSuccess: (_) => fail('Should not succeed'),
        onFailure: (failure) {
          failureCalled = true;
          expect(failure.message, contains('Invalid verification code'));
          expect(failure.code, 401);
        },
      );
      expect(failureCalled, true);
    });

    test('handles expired verification code error', () async {
      // Arrange
      const verificationId = 'test-verification-id';
      const smsCode = '123456';

      when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'code-expired', message: 'Code expired'),
      );

      // Act
      final result = await repository.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Assert
      var failureCalled = false;
      result.when(
        onSuccess: (_) => fail('Should not succeed'),
        onFailure: (failure) {
          failureCalled = true;
          expect(failure.message, contains('expired'));
          expect(failure.code, 408);
        },
      );
      expect(failureCalled, true);
    });

    test('handles session expired error', () async {
      // Arrange
      const verificationId = 'test-verification-id';
      const smsCode = '123456';

      when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(
          code: 'session-expired',
          message: 'Session expired',
        ),
      );

      // Act
      final result = await repository.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Assert
      var failureCalled = false;
      result.when(
        onSuccess: (_) => fail('Should not succeed'),
        onFailure: (failure) {
          failureCalled = true;
          expect(failure.message, contains('session expired'));
          expect(failure.code, 408);
        },
      );
      expect(failureCalled, true);
    });

    test('handles too many requests error', () async {
      // Arrange
      const verificationId = 'test-verification-id';
      const smsCode = '123456';

      when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(
          code: 'too-many-requests',
          message: 'Too many requests',
        ),
      );

      // Act
      final result = await repository.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Assert
      var failureCalled = false;
      result.when(
        onSuccess: (_) => fail('Should not succeed'),
        onFailure: (failure) {
          failureCalled = true;
          expect(failure.message, contains('Too many'));
          expect(failure.code, 429);
        },
      );
      expect(failureCalled, true);
    });
  });

  group('FirebaseAuthRepository - resendOtp', () {
    test('calls Firebase verifyPhoneNumber with resend token', () async {
      // Arrange
      const phoneNumber = '+6281234567890';
      const resendToken = 12345;
      var codeSentCalled = false;

      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenAnswer((invocation) async {
        final codeSent =
            invocation.namedArguments[const Symbol('codeSent')] as Function;
        codeSent('new-verification-id', 67890);
      });

      // Act
      await repository.resendOtp(
        phoneNumber: phoneNumber,
        resendToken: resendToken,
        onCodeSent: (verificationId, newResendToken) {
          codeSentCalled = true;
        },
        onVerificationCompleted: (_) {},
        onVerificationFailed: (_) {},
      );

      // Assert
      verify(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: const Duration(seconds: 60),
          forceResendingToken: resendToken,
        ),
      ).called(1);

      expect(codeSentCalled, true);
    });

    test('handles resend without token', () async {
      // Arrange
      const phoneNumber = '+6281234567890';
      var codeSentCalled = false;

      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenAnswer((invocation) async {
        final codeSent =
            invocation.namedArguments[const Symbol('codeSent')] as Function;
        codeSent('new-verification-id', null);
      });

      // Act
      await repository.resendOtp(
        phoneNumber: phoneNumber,
        resendToken: null,
        onCodeSent: (_, _) {
          codeSentCalled = true;
        },
        onVerificationCompleted: (_) {},
        onVerificationFailed: (_) {},
      );

      // Assert
      verify(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: const Duration(seconds: 60),
          forceResendingToken: null,
        ),
      ).called(1);

      expect(codeSentCalled, true);
    });

    test('handles rate limiting error on resend', () async {
      // Arrange
      const phoneNumber = '+6281234567890';
      var failureCalled = false;
      Failure? capturedFailure;

      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenAnswer((invocation) async {
        final verificationFailed =
            invocation.namedArguments[const Symbol('verificationFailed')]
                as Function;
        verificationFailed(
          FirebaseAuthException(
            code: 'too-many-requests',
            message: 'Too many requests',
          ),
        );
      });

      // Act
      await repository.resendOtp(
        phoneNumber: phoneNumber,
        onCodeSent: (_, _) {},
        onVerificationCompleted: (_) {},
        onVerificationFailed: (failure) {
          failureCalled = true;
          capturedFailure = failure;
        },
      );

      // Assert
      expect(failureCalled, true);
      expect(capturedFailure, isNotNull);
      expect(capturedFailure!.code, 429);
    });
  });

  group('FirebaseAuthRepository - signOut', () {
    test('successfully signs out', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act
      final result = await repository.signOut();

      // Assert
      var successCalled = false;
      result.when(
        onSuccess: (_) {
          successCalled = true;
        },
        onFailure: (_) => fail('Should not fail'),
      );
      expect(successCalled, true);
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('handles sign out error', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signOut(),
      ).thenThrow(Exception('Sign out failed'));

      // Act
      final result = await repository.signOut();

      // Assert
      var failureCalled = false;
      result.when(
        onSuccess: (_) => fail('Should not succeed'),
        onFailure: (failure) {
          failureCalled = true;
          expect(failure.message, contains('Failed to sign out'));
        },
      );
      expect(failureCalled, true);
    });
  });

  group('FirebaseAuthRepository - Error Conversion', () {
    test('converts invalid-phone-number error correctly', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'invalid-phone-number'));

      // Act
      final result = await repository.verifyPhoneNumber(
        phoneNumber: '+123',
        onCodeSent: (_, _) {},
        onVerificationCompleted: (_) {},
        onVerificationFailed: (_) {},
      );

      // Assert
      result.when(
        onSuccess: (_) => fail('Should not succeed'),
        onFailure: (failure) {
          expect(failure.code, 400);
          expect(failure.message, contains('phone number'));
        },
      );
    });

    test('converts quota-exceeded error correctly', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithCredential(any()),
      ).thenThrow(FirebaseAuthException(code: 'quota-exceeded'));

      // Act
      final result = await repository.verifyOtp(
        verificationId: 'test-id',
        smsCode: '123456',
      );

      // Assert
      result.when(
        onSuccess: (_) => fail('Should not succeed'),
        onFailure: (failure) {
          expect(failure.code, 429);
          expect(failure.message, contains('Too many'));
        },
      );
    });

    test('converts user-disabled error correctly', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithCredential(any()),
      ).thenThrow(FirebaseAuthException(code: 'user-disabled'));

      // Act
      final result = await repository.verifyOtp(
        verificationId: 'test-id',
        smsCode: '123456',
      );

      // Assert
      result.when(
        onSuccess: (_) => fail('Should not succeed'),
        onFailure: (failure) {
          expect(failure.code, 403);
          expect(failure.message, contains('disabled'));
        },
      );
    });
  });
}
