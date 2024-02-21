import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/services/notification/local_notifcation_service.dart';
import 'package:halo_hermina/core/utils/device_info.dart';
import 'package:halo_hermina/core/utils/fcm.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AuthenticationService {
  final AuthenticationRepository _authenticationRepository;
  final AccountRepository _accountRepository;
  final LocalNotificationService _localNotificationService;

  AuthenticationService(
    this._authenticationRepository,
    this._accountRepository,
    this._localNotificationService,
  );

  bool get isLoggedIn =>
      _authenticationRepository.getLocalAuth().isNotNull() &&
      _accountRepository.getLocalUser().isNotNull();

  Future<Result<SuccessResponse>> checkUserWithEmail({
    required String email,
  }) {
    return _authenticationRepository.checkUserWithEmail(
      CheckUserWithEmailRequest(email: email),
    );
  }

  Future<Result<SuccessResponse>> checkUserWithPhone({
    required String phone,
  }) {
    return _authenticationRepository.checkUserWithPhone(
      CheckUserWithPhoneRequest(phone: phone),
    );
  }

  Future<Result<SuccessResponse>> register({
    required String type,
    required String firstName,
    required String lastName,
    required String placeOfBirth,
    DateTime? dateOfBirth,
    String? genderSerial,
    String? phone,
    String? email,
    String? password,
    String? otp,
  }) {
    return _authenticationRepository.register(
      RegisterRequest(
        type: type,
        firstName: firstName,
        lastName: lastName,
        placeOfBirth: placeOfBirth,
        dateOfBirth: dateOfBirth,
        genderSerial: genderSerial,
        phone: phone,
        email: email,
        password: password,
        otp: otp,
      ),
    );
  }

  Future<Result<SuccessResponse>> checkPhone({
    required String phone,
  }) {
    return _authenticationRepository.checkPhone(
      CheckPhoneRequest(phone: phone),
    );
  }

  Future<Result<LoginResponse>> login({
    required String username,
    required String password,
    required String type,
  }) async {
    final resultLogin = await _authenticationRepository.login(
      LoginRequest(
        username: username,
        password: password,
        type: type,
      ),
    );

    await resultLogin.whenOrNull(
      success: (data) async {
        await saveAuthAndUser(
          data.accessToken,
          data.refreshToken,
        );
      },
    );

    return resultLogin;
  }

  Future<Result<LoginResponse>> loginSocial({
    required LoginSocialType type,
    required String email,
  }) async {
    final resultLogin = await _authenticationRepository.loginSocial(
      LoginSocialRequest(
        type: type,
        email: email,
      ),
    );

    await resultLogin.whenOrNull(
      success: (data) async {
        await saveAuthAndUser(
          data.accessToken,
          data.refreshToken,
        );
      },
    );

    return resultLogin;
  }

  Future<Result<EmailResponse>> checkEmailSocialProvider({
    required LoginSocialType type,
    required String providerID,
  }) async {
    return _authenticationRepository.checkEmailSocialProvider(
      SocialProviderCheckEmailRequest(
        type: type,
        providerID: providerID,
      ),
    );
  }

  Future<Result<SuccessResponse>> saveSocialProvider({
    required LoginSocialType type,
    required String email,
    required String providerID,
  }) async {
    return _authenticationRepository.saveSocialProvider(
      SocialProviderRequest(
        type: type,
        email: email,
        providerID: providerID,
      ),
    );
  }

  Future saveAuthAndUser(
    String accessToken,
    String refreshToken,
  ) async {
    await _authenticationRepository.saveLocalAuth(
      AuthData(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );

    final profileRes = await _accountRepository.profile();

    await profileRes.whenOrNull(
      success: (data) async {
        await _accountRepository.saveLocalUser(
          UserData.fromJson(data.toJson()),
        );

        final token = await FCM.getToken();

        await updateDeviceToken(
          deviceID: await DeviceInfo.deviceIdentifier(),
          token: token,
        );

        Sentry.configureScope((scope) {
          scope.setUser(
            SentryUser(
              id: data.serial,
              name: "${data.firstName} ${data.lastName}",
              email: data.email,
            ),
          );
        });
      },
    );
  }

  Future<Result<SuccessResponse>> resendEmail({
    required String email,
  }) {
    return _authenticationRepository.resendEmail(
      ResendEmailRequest(email: email),
    );
  }

  Future<Result<SuccessResponse>> verifyEmail({
    required String email,
    required String token,
  }) {
    return _authenticationRepository.verifySignupEmail(
      VerifyEmailRequest(
        email: email,
        token: token,
      ),
    );
  }

  Future<Result<SuccessResponse>> forgotPassword({
    required String email,
    required String type,
  }) {
    return _authenticationRepository.forgotPassword(
      ForgotPasswordRequest(
        email: email,
        type: type,
      ),
    );
  }

  Future<Result<SuccessResponse>> resetPassword({
    required String userSerial,
    required String token,
    required String password,
  }) {
    return _authenticationRepository.resetPassword(
      ResetPasswordRequest(
        userSerial: userSerial,
        token: token,
        password: password,
      ),
    );
  }

  Future<void> logout() async {
    UserData? user = _accountRepository.getLocalUser();

    if (user?.serial != null) {
      deleteDeviceToken(
        deviceID: await DeviceInfo.deviceIdentifier(),
        userSerial: user?.serial ?? "",
      );
    }

    await _authenticationRepository.deleteLocalAuth();
    await _accountRepository.deleteLocalUser();
    await _accountRepository.deleteAccountSetting();
    await _accountRepository.setAuthenticatedPatientPortal(false);
    _localNotificationService.clearNotification();

    await Sentry.configureScope((scope) async {
      await scope.setUser(null);
    });
  }

  Future<Result<DeviceTokenResponse>> updateDeviceToken({
    required String deviceID,
    required String token,
  }) async {
    return _accountRepository.updateDeviceToken(
      UpdateDeviceTokenRequest(
        deviceID: deviceID,
        token: token,
      ),
    );
  }

  Future<Result<DeviceTokenResponse>> deleteDeviceToken({
    required String userSerial,
    required String deviceID,
  }) async {
    return _accountRepository.deleteDeviceToken(
      DeleteDeviceTokenRequest(userSerial: userSerial, deviceID: deviceID),
    );
  }
}

final authenticationServiceProvider = Provider<AuthenticationService>(
  (ref) {
    return AuthenticationService(
      ref.read(authenticationRepositoryProvider),
      ref.read(accountRepositoryProvider),
      ref.read(localNotificationServiceProvider),
    );
  },
);
