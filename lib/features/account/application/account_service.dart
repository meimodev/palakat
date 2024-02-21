import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:halo_hermina/core/config/app_config.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/utils/device_info.dart';
import 'package:halo_hermina/core/utils/fcm.dart';
import 'package:halo_hermina/features/account/data/google_map_repository.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AccountService {
  final AccountRepository _accountRepository;
  final SharedRepository _sharedRepository;
  final GoogleMapRepository _gmapRepository;

  AccountService(
    this._accountRepository,
    this._sharedRepository,
    this._gmapRepository,
  );

  UserData? get user => _accountRepository.getLocalUser();

  bool get isEmptyPassword => user?.emptyPass ?? false;

  AccountSetting getAccountSetting() {
    return AccountMapper.mapToAccountSetting(
      _accountRepository.getAccountSetting(),
    );
  }

  Future setEnableBiometric(bool value) async {
    return _accountRepository.setEnableBiometric(value);
  }

  Future setLocalLanguage(String value) async {
    return _accountRepository.setLocalLanguage(value);
  }

  Future setAuthenticatedPatientPortal(bool value) async {
    return _accountRepository.setAuthenticatedPatientPortal(value);
  }

  Future<Result<ProfileResponse>> getProfile() async {
    final result = await _accountRepository.profile();

    await result.whenOrNull(
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

    return result;
  }

  Future<Result<ProfileResponse>> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    IdentityType? identityType,
    String? identityNumber,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    String? genderSerial,
    String? otp,
  }) {
    return _accountRepository.updateProfile(
      UpdateProfileRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        identityType: identityType,
        identityNumber: identityNumber,
        placeOfBirth: placeOfBirth,
        dateOfBirth: dateOfBirth,
        genderSerial: genderSerial,
        otp: otp,
      ),
    );
  }

  Future<Result<ProfileResponse>> changePassword({
    required String newPassword,
    String? oldPassword,
  }) {
    return _accountRepository.changePassword(
      ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
      ),
    );
  }

  Future<String?> updateLanguageByUserFeature(
    List<UserFeatureResponse> userFeatures,
  ) async {
    final languageFeature = userFeatures.firstWhereOrNull(
      (element) => element.key == UserFeatureKey.language,
    );

    if (languageFeature != null) {
      final accountSetting = getAccountSetting();

      if (accountSetting.language != languageFeature.value) {
        await setLocalLanguage(languageFeature.value);

        return languageFeature.value;
      }

      return accountSetting.language;
    }

    return null;
  }

  Future setUserLanguage(LanguageKey languageKey) {
    return updateUserFeature(
      key: UserFeatureKey.language,
      value: languageKey.name,
    );
  }

  Future<String?> getUserLanguage() async {
    final featureRes = await _sharedRepository.userFeature();

    final updateRes = await featureRes.whenOrNull(
      success: (data) async {
        return await updateLanguageByUserFeature(data);
      },
    );

    return updateRes;
  }

  Future saveLanguage(LanguageKey languageKey) async {
    if (user != null) {
      await setUserLanguage(languageKey);
      final featureRes = await _sharedRepository.userFeature();

      await featureRes.whenOrNull(
        success: (data) async {
          await updateLanguageByUserFeature(data);
        },
      );
    } else {
      await setLocalLanguage(languageKey.name);
    }
  }

  Future<Result<UserFeatureResponse>> updateUserFeature({
    required String key,
    required String value,
  }) {
    return _sharedRepository.updateUserFeature(
      UserFeatureRequest(
        key: key,
        value: value,
      ),
    );
  }

  Future<Result<List<UserAddressResponse>>> getAddresses() async {
    return _accountRepository.userAddresses();
  }

  Future<Result<UserAddressResponse>> getAddressBySerial(String serial) async {
    return _accountRepository.userAddressBySerial(
      SerialRequest(serial: serial),
    );
  }

  Future<Result<UserAddressResponse>> createAddress({
    required String label,
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool isPrimary,
    String? note,
  }) async {
    return _accountRepository.createUserAddress(
      CreateUserAddressRequest(
        label: label,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isPrimary: isPrimary,
        note: note,
      ),
    );
  }

  Future<Result<UserAddressResponse>> updateAddress({
    required String serial,
    required String label,
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool isPrimary,
    String? note,
  }) async {
    return _accountRepository.updateUserAddress(
      UpdateUserAddressRequest(
        serial: serial,
        label: label,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isPrimary: isPrimary,
        note: note,
      ),
    );
  }

  Future<Result<UserAddressResponse>> deleteAddress({
    required String serial,
  }) async {
    return _accountRepository.deleteUserAddress(
      SerialRequest(serial: serial),
    );
  }

  Future<Result<List<AutocompleteAddress>>> autocompleteAddress({
    required String input,
    String? locationbias,
  }) async {
    final result = await _gmapRepository.autocomplete(
      AutocompleteRequest(
        input: input,
        key: AppConfig.googleApiKey,
        components: "country:id",
        language: getAccountSetting().language,
        locationbias: locationbias,
      ),
    );

    return result.when(
      success: (data) => Result.success(
        data.map((e) => AccountMapper.mapToAutocompleteAddress(e)).toList(),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
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

final accountServiceProvider = Provider<AccountService>((ref) {
  final account = ref.read(accountRepositoryProvider);
  final shared = ref.read(sharedRepositoryProvider);
  final gmap = ref.read(googleMapRepositoryProvider);
  return AccountService(account, shared, gmap);
});
