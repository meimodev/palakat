// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:halo_hermina/core/datasources/datasources.dart';
// import 'package:halo_hermina/features/data.dart';
//
// class AccountRepository {
//   final HiveService _hiveService;
//   final AccountApi _accountApi;
//   final PushNotificationApi _pushNotificationApi;
//
//   AccountRepository(
//     this._hiveService,
//     this._accountApi,
//     this._pushNotificationApi,
//   );
//
//   AccountSettingData? getAccountSetting() {
//     return _hiveService.getAccountSetting();
//   }
//
//   Future setAccountSetting(AccountSettingData value) {
//     return _hiveService.setAccountSetting(value);
//   }
//
//   Future setEnableBiometric(bool value) async {
//     final accountSetting = getAccountSetting();
//
//     if (accountSetting != null) {
//       await setAccountSetting(accountSetting.copyWith(enableBiometric: value));
//     } else {
//       await setAccountSetting(AccountSettingData(enableBiometric: value));
//     }
//   }
//
//   Future setLocalLanguage(String value) async {
//     final accountSetting = getAccountSetting();
//
//     if (accountSetting != null) {
//       await setAccountSetting(accountSetting.copyWith(language: value));
//     } else {
//       await setAccountSetting(AccountSettingData(language: value));
//     }
//   }
//
//   Future setAuthenticatedPatientPortal(bool value) async {
//     final accountSetting = getAccountSetting();
//
//     if (accountSetting != null) {
//       await setAccountSetting(
//         accountSetting.copyWith(authenticatedPatientPortal: value),
//       );
//     } else {
//       await setAccountSetting(
//         AccountSettingData(authenticatedPatientPortal: value),
//       );
//     }
//   }
//
//   UserData? getLocalUser() {
//     return _hiveService.getUser();
//   }
//
//   Future deleteAccountSetting() {
//     return _hiveService.deleteAccountSetting();
//   }
//
//   Future saveLocalUser(UserData value) {
//     return _hiveService.saveUser(value);
//   }
//
//   Future deleteLocalUser() {
//     return _hiveService.deleteUser();
//   }
//
//   Future<Result<ProfileResponse>> profile({
//     Map<String, dynamic>? params,
//   }) {
//     // return Future.delayed(
//     //   const Duration(seconds: 1),
//     //   () => Result.success(
//     //     ProfileResponse.fromJson(
//     //       {
//     //         "serial": "string",
//     //         "firstName": "string",
//     //         "lastName": "string",
//     //         "email": "string",
//     //         "phone": "string",
//     //         "identityType": "KTP",
//     //         "identityNumber": "string",
//     //         "ktpNumber": "string",
//     //         "passportNumber": "string",
//     //         "placeOfBirth": "string",
//     //         "dateOfBirth": "2023-11-08T06:57:20.405Z",
//     //         "gender": {
//     //           "serial": "string",
//     //           "category": "string",
//     //           "value": "MALE",
//     //         },
//     //         "emptyPass": true,
//     //         "mustVerifiedEmail": false,
//     //         "mustChooseArticleTag": false,
//     //       },
//     //     ),
//     //   ),
//     // );
//
//     return _accountApi.profile(params: params);
//   }
//
//   Future<Result<ProfileResponse>> updateProfile(UpdateProfileRequest request) {
//     // return Future.delayed(
//     //   const Duration(seconds: 1),
//     //   () => Result.success(
//     //     ProfileResponse.fromJson(
//     //       {
//     //         "serial": "string",
//     //         "firstName": "string",
//     //         "lastName": "string",
//     //         "email": "string",
//     //         "phone": "string",
//     //         "identityType": "KTP",
//     //         "identityNumber": "string",
//     //         "ktpNumber": "string",
//     //         "passportNumber": "string",
//     //         "placeOfBirth": "string",
//     //         "dateOfBirth": "2023-11-08T06:57:20.405Z",
//     //         "gender": "MALE",
//     //         "emptyPass": true
//     //       },
//     //     ),
//     //   ),
//     // );
//
//     return _accountApi.updateProfile(request);
//   }
//
//   Future<Result<ProfileResponse>> changePassword(
//       ChangePasswordRequest request) {
//     // return Future.delayed(
//     //   const Duration(seconds: 1),
//     //   () => Result.success(
//     //     ProfileResponse.fromJson(
//     //       {
//     //         "serial": "string",
//     //         "firstName": "string",
//     //         "lastName": "string",
//     //         "email": "string",
//     //         "phone": "string",
//     //         "identityType": "KTP",
//     //         "identityNumber": "string",
//     //         "ktpNumber": "string",
//     //         "passportNumber": "string",
//     //         "placeOfBirth": "string",
//     //         "dateOfBirth": "2023-11-08T06:57:20.405Z",
//     //         "gender": "MALE",
//     //         "emptyPass": true
//     //       },
//     //     ),
//     //   ),
//     // );
//
//     return _accountApi.changePassword(request);
//   }
//
//   Future<Result<List<UserAddressResponse>>> userAddresses({
//     Map<String, dynamic>? params,
//   }) {
//     // return Future.delayed(
//     //   const Duration(seconds: 1),
//     //   () => Result.success(
//     //     List.from(
//     //       [
//     //         {
//     //           "serial": "1",
//     //           "label": "Rumah",
//     //           "name": "James Bond",
//     //           "phone": "089312412121",
//     //           "isPrimary": true,
//     //           "address": "Lorem duis sinta",
//     //         },
//     //         {
//     //           "serial": "12",
//     //           "label": "Rumah",
//     //           "name": "James Bond",
//     //           "phone": "089312412121",
//     //           "isPrimary": false,
//     //           "address": "Lorem duis sinta",
//     //         }
//     //       ].map((e) => UserAddressResponse.fromJson(e)),
//     //     ),
//     //   ),
//     // );
//
//     return _accountApi.userAddresses(params: params);
//   }
//
//   Future<Result<UserAddressResponse>> userAddressBySerial(
//       SerialRequest request) {
//     // return Future.delayed(
//     //   const Duration(seconds: 1),
//     //   () => Result.success(
//     //     UserAddressResponse.fromJson({
//     //       "serial": "string",
//     //       "userSerial": "string",
//     //       "label": "Rumah",
//     //       "name": "James Bond",
//     //       "firstName": "James",
//     //       "lastName": "Bond",
//     //       "phone": "089312412121",
//     //       "address": "Lorem duis sinta",
//     //       "note": "lorem duis sinta manusta",
//     //       "longitude": 106.6222804,
//     //       "latitude": -6.2546837,
//     //       "isPrimary": true,
//     //     }),
//     //   ),
//     // );
//
//     return _accountApi.userAddressBySerial(request);
//   }
//
//   Future<Result<UserAddressResponse>> createUserAddress(
//       CreateUserAddressRequest request) async {
//     // return Future.delayed(
//     //   const Duration(seconds: 1),
//     //   () => Result.success(
//     //     UserAddressResponse.fromJson({
//     //       "serial": "string James Bond New",
//     //       "userSerial": "string James Bond New",
//     //       "label": "Rumah",
//     //       "name": "James Bond New",
//     //       "firstName": "James",
//     //       "lastName": "Bond New",
//     //       "phone": "081212341234",
//     //       "address": "Lorem duis sinta",
//     //       "note": null,
//     //       "longitude": 80,
//     //       "latitude": 80,
//     //       "isPrimary": true,
//     //     }),
//     //   ),
//     // );
//
//     return _accountApi.createUserAddress(request);
//   }
//
//   Future<Result<UserAddressResponse>> updateUserAddress(
//       UpdateUserAddressRequest request) async {
//     // return Future.delayed(
//     //   const Duration(seconds: 1),
//     //   () => Result.success(
//     //     UserAddressResponse.fromJson({
//     //       "serial": "string",
//     //       "userSerial": "string",
//     //       "label": "Rumah",
//     //       "name": "James Bond",
//     //       "firstName": "James",
//     //       "lastName": "Bond",
//     //       "phone": "089312412121",
//     //       "address": "Lorem duis sinta",
//     //       "note": null,
//     //       "longitude": 80,
//     //       "latitude": 80,
//     //       "isPrimary": true,
//     //     }),
//     //   ),
//     // );
//
//     return _accountApi.updateUserAddress(request);
//   }
//
//   Future<Result<UserAddressResponse>> deleteUserAddress(
//       SerialRequest request) async {
//     // return Future.delayed(
//     //   const Duration(seconds: 1),
//     //   () => Result.success(
//     //     UserAddressResponse.fromJson({
//     //       "serial": "string",
//     //       "userSerial": "string",
//     //       "label": "Rumah",
//     //       "name": "James Bond",
//     //       "firstName": "James",
//     //       "lastName": "Bond",
//     //       "phone": "089312412121",
//     //       "address": "Lorem duis sinta",
//     //       "note": null,
//     //       "longitude": 80,
//     //       "latitude": 80,
//     //       "isPrimary": true,
//     //     }),
//     //   ),
//     // );
//
//     return _accountApi.deleteUserAddress(request);
//   }
//
//   Future<Result<DeviceTokenResponse>> updateDeviceToken(
//       UpdateDeviceTokenRequest request) async {
//     return _pushNotificationApi.updateDeviceToken(request);
//   }
//
//   Future<Result<DeviceTokenResponse>> deleteDeviceToken(
//       DeleteDeviceTokenRequest request) async {
//     return _pushNotificationApi.deleteDeviceToken(request);
//   }
// }
//
// final accountRepositoryProvider =
//     Provider.autoDispose<AccountRepository>((ref) {
//   return AccountRepository(
//     ref.read(hiveServiceProvider),
//     ref.read(accountApiProvider),
//     ref.read(pushNotificationApiProvider),
//   );
// });
