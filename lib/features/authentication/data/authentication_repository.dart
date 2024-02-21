import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';

class AuthenticationRepository {
  final AuthenticationApi _authenticationApi;
  final HiveService _hiveService;

  AuthenticationRepository(this._authenticationApi, this._hiveService);

  Future<Result<SuccessResponse>> checkUserWithEmail(
    CheckUserWithEmailRequest request,
  ) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.checkUserWithEmail(request);
  }

  Future<Result<SuccessResponse>> checkUserWithPhone(
    CheckUserWithPhoneRequest request,
  ) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.checkUserWithPhone(request);
  }

  Future<Result<SuccessResponse>> register(
    RegisterRequest request,
  ) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.register(request);
  }

  Future<Result<SuccessResponse>> resendEmail(
    ResendEmailRequest request,
  ) {
    // print(request.toJson());
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.resendEmail(request);
  }

  Future<Result<SuccessResponse>> verifySignupEmail(
    VerifyEmailRequest request,
  ) {
    // print(request.toJson());
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.verifySignupEmail(request);
  }

  Future<Result<SuccessResponse>> checkPhone(
    CheckPhoneRequest request,
  ) {
    // print(request.toJson());
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.checkPhone(request);
  }

  Future<Result<LoginResponse>> login(
    LoginRequest request,
  ) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     LoginResponse.fromJson(
    //       {
    //         "accessToken":
    //             "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJiYWQyNTFmYS0wMDczLTQzMjctYjZiZi1hZWNiMzJmMWExZWEiLCJuYmYiOjE2OTkzMjc5MDcsInN1YiI6ImUzMzQ1M2U1LWM4NjUtNGYzNy1hZjlkLWJhOTc1ZjVkZmE3YSIsInNzIjp7InNlcmlhbCI6ImUzMzQ1M2U1LWM4NjUtNGYzNy1hZjlkLWJhOTc1ZjVkZmE3YSIsIm5hbWUiOiJKb2huIERvZSIsInR5cGUiOiJVU0VSIn0sImlhdCI6MTY5OTMyNzkwNywiZXhwIjoxNzAxOTE5OTA2LCJpc3MiOiJoZXJtaW5hIn0.WJzISUfunb9ueNYXJynP33uGgesYhMWbxb0yhyGCvwUtKqki8t2ciWw4dpebf8hETtLrYKXcB3zCWiZ4uNt4Qjb8AdPouH7Gbb_qi5FME_jyu7yuFewrtlb2UobrQdWO0xCUCUnAgPn1qVzvwMB3wtPsMYpXSRTqx5VytasTh8p5lgPnq03PP069ntMHXlM3gCCyJf9dOoVnayWw_8qrYTQQ4LDt_Q28fVhj20EJJRKXuuqp_Sp5GXWEv8zi7wUqqhGx6-aAMNvKAJvTh0tkni71EC32NGZgnBIbgQbQkXTn2W14PqwygDMcLlWWqUwKopBnKlhlELQ7jmELMgLx2AREjB_oJUzdDnBb8qmlA6-5rxWGUlYbHiD_otZeJgsV3pnBZc6_63km5O7oT7jbHJhNlu7f0zWiSlscIcIth6BZUby9e23DQ8jZbkbSbBl6XI88e4FpY9x9DfYI_7vMFrcE3oCQZ--AsKwWFdm9bLXPU03NRTXJVS92A-orXVkUhlhRgxgPXbaNulWXsrWo-HJFrmcZHZ5hmLE5t2eLk_gRqgCejHSo4Qn4JwUt-kmcWioO0FCQdydZgNKZvP99TWKn5Cqkk03W_rudWdYn0KE_bgTXzgVLf7_95kzDwEyxNTFaeNn6VAaSq4mXet_24vcFHO6khFESYg2Svoe9IVg",
    //         "refreshToken":
    //             "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJiYWQyNTFmYS0wMDczLTQzMjctYjZiZi1hZWNiMzJmMWExZWEiLCJuYmYiOjE2OTkzMjc5MDcsInN1YiI6ImUzMzQ1M2U1LWM4NjUtNGYzNy1hZjlkLWJhOTc1ZjVkZmE3YSIsImlhdCI6MTY5OTMyNzkwNywiZXhwIjoxNzMwOTUwMzA3LCJpc3MiOiJoZXJtaW5hIn0.frOahYYGZV0yi4BXeo9MtJlL3Lk8K7hlEk7UXKuC952szwFnu5U7eaMPaoMAyB52reM7NXhEXCF5JhC3EKbj_sSKEUbBy40pYPSsY6mpfAkgVhjVv-8gMtiEflLXm6xRIhP4nVpNvhRDSTcgPLDm9fsR8mSjWrbpIw84806AzyxA_J_-vS2DGsFbG1mRUQeOX6_CfwG518y1ZqihiyBlPYizYe-ZrdUwlnGrBAPKedBj3elvmStWsc5y8MiNJpe9tueAxd7ZVL9Gc6Z2Dc_mLtjb5aSRS0zXhq8SSTTik7UStaga0Z2iAmA7XLShK42NflzShCODfWZVv3m-z4AghYtLNuuxu5v0iSmahDg8rpxc2MhotATN20raICVOJmMSN2-5-QB2F9arzy-QusSDo6_XGzSMQ9xpOXy1CgLfEnR8ZgbReWM5LeyOHMoTDuQWeEa8Kd3IYtKwXKYkRS6h-8KTINYJ2ENnQ1FejcvT51W-cYVFsrCQkAncjEjLcv4_qryjLzCBbZkGUo0Nu-yNRkvSTRCuY0DcZU8R07Ffa5KGbeJrNgkeREmDbzVWtnjIBtDBMmbCCN-Me1wKWeDwdsI9wo2N63TEiXJWoDbRKZJOSmDcSTjBkgeym3Wl_Vfsh1U_8elfkplZxAVYGIe-3ehx3fjMVsEWmuSdV-cKM1w",
    //         "expiresIn": 1701919907
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.login(request);
  }

  Future<Result<LoginResponse>> loginSocial(
    LoginSocialRequest request,
  ) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     LoginResponse.fromJson(
    //       {
    //         "accessToken":
    //             "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJiYWQyNTFmYS0wMDczLTQzMjctYjZiZi1hZWNiMzJmMWExZWEiLCJuYmYiOjE2OTkzMjc5MDcsInN1YiI6ImUzMzQ1M2U1LWM4NjUtNGYzNy1hZjlkLWJhOTc1ZjVkZmE3YSIsInNzIjp7InNlcmlhbCI6ImUzMzQ1M2U1LWM4NjUtNGYzNy1hZjlkLWJhOTc1ZjVkZmE3YSIsIm5hbWUiOiJKb2huIERvZSIsInR5cGUiOiJVU0VSIn0sImlhdCI6MTY5OTMyNzkwNywiZXhwIjoxNzAxOTE5OTA2LCJpc3MiOiJoZXJtaW5hIn0.WJzISUfunb9ueNYXJynP33uGgesYhMWbxb0yhyGCvwUtKqki8t2ciWw4dpebf8hETtLrYKXcB3zCWiZ4uNt4Qjb8AdPouH7Gbb_qi5FME_jyu7yuFewrtlb2UobrQdWO0xCUCUnAgPn1qVzvwMB3wtPsMYpXSRTqx5VytasTh8p5lgPnq03PP069ntMHXlM3gCCyJf9dOoVnayWw_8qrYTQQ4LDt_Q28fVhj20EJJRKXuuqp_Sp5GXWEv8zi7wUqqhGx6-aAMNvKAJvTh0tkni71EC32NGZgnBIbgQbQkXTn2W14PqwygDMcLlWWqUwKopBnKlhlELQ7jmELMgLx2AREjB_oJUzdDnBb8qmlA6-5rxWGUlYbHiD_otZeJgsV3pnBZc6_63km5O7oT7jbHJhNlu7f0zWiSlscIcIth6BZUby9e23DQ8jZbkbSbBl6XI88e4FpY9x9DfYI_7vMFrcE3oCQZ--AsKwWFdm9bLXPU03NRTXJVS92A-orXVkUhlhRgxgPXbaNulWXsrWo-HJFrmcZHZ5hmLE5t2eLk_gRqgCejHSo4Qn4JwUt-kmcWioO0FCQdydZgNKZvP99TWKn5Cqkk03W_rudWdYn0KE_bgTXzgVLf7_95kzDwEyxNTFaeNn6VAaSq4mXet_24vcFHO6khFESYg2Svoe9IVg",
    //         "refreshToken":
    //             "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJiYWQyNTFmYS0wMDczLTQzMjctYjZiZi1hZWNiMzJmMWExZWEiLCJuYmYiOjE2OTkzMjc5MDcsInN1YiI6ImUzMzQ1M2U1LWM4NjUtNGYzNy1hZjlkLWJhOTc1ZjVkZmE3YSIsImlhdCI6MTY5OTMyNzkwNywiZXhwIjoxNzMwOTUwMzA3LCJpc3MiOiJoZXJtaW5hIn0.frOahYYGZV0yi4BXeo9MtJlL3Lk8K7hlEk7UXKuC952szwFnu5U7eaMPaoMAyB52reM7NXhEXCF5JhC3EKbj_sSKEUbBy40pYPSsY6mpfAkgVhjVv-8gMtiEflLXm6xRIhP4nVpNvhRDSTcgPLDm9fsR8mSjWrbpIw84806AzyxA_J_-vS2DGsFbG1mRUQeOX6_CfwG518y1ZqihiyBlPYizYe-ZrdUwlnGrBAPKedBj3elvmStWsc5y8MiNJpe9tueAxd7ZVL9Gc6Z2Dc_mLtjb5aSRS0zXhq8SSTTik7UStaga0Z2iAmA7XLShK42NflzShCODfWZVv3m-z4AghYtLNuuxu5v0iSmahDg8rpxc2MhotATN20raICVOJmMSN2-5-QB2F9arzy-QusSDo6_XGzSMQ9xpOXy1CgLfEnR8ZgbReWM5LeyOHMoTDuQWeEa8Kd3IYtKwXKYkRS6h-8KTINYJ2ENnQ1FejcvT51W-cYVFsrCQkAncjEjLcv4_qryjLzCBbZkGUo0Nu-yNRkvSTRCuY0DcZU8R07Ffa5KGbeJrNgkeREmDbzVWtnjIBtDBMmbCCN-Me1wKWeDwdsI9wo2N63TEiXJWoDbRKZJOSmDcSTjBkgeym3Wl_Vfsh1U_8elfkplZxAVYGIe-3ehx3fjMVsEWmuSdV-cKM1w",
    //         "expiresIn": 1701919907
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.loginSocial(request);
  }

  Future<Result<EmailResponse>> checkEmailSocialProvider(
    SocialProviderCheckEmailRequest request,
  ) {
    return _authenticationApi.checkEmailSocialProvider(request);
  }

  Future<Result<SuccessResponse>> saveSocialProvider(
    SocialProviderRequest request,
  ) {
    return _authenticationApi.saveSocialProvider(request);
  }

  Future<Result<LoginResponse>> refresh(
    LoginRefreshRequest request,
  ) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     LoginResponse.fromJson(
    //       {
    //         "accessToken":
    //             "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJiYWQyNTFmYS0wMDczLTQzMjctYjZiZi1hZWNiMzJmMWExZWEiLCJuYmYiOjE2OTkzMjc5MDcsInN1YiI6ImUzMzQ1M2U1LWM4NjUtNGYzNy1hZjlkLWJhOTc1ZjVkZmE3YSIsInNzIjp7InNlcmlhbCI6ImUzMzQ1M2U1LWM4NjUtNGYzNy1hZjlkLWJhOTc1ZjVkZmE3YSIsIm5hbWUiOiJKb2huIERvZSIsInR5cGUiOiJVU0VSIn0sImlhdCI6MTY5OTMyNzkwNywiZXhwIjoxNzAxOTE5OTA2LCJpc3MiOiJoZXJtaW5hIn0.WJzISUfunb9ueNYXJynP33uGgesYhMWbxb0yhyGCvwUtKqki8t2ciWw4dpebf8hETtLrYKXcB3zCWiZ4uNt4Qjb8AdPouH7Gbb_qi5FME_jyu7yuFewrtlb2UobrQdWO0xCUCUnAgPn1qVzvwMB3wtPsMYpXSRTqx5VytasTh8p5lgPnq03PP069ntMHXlM3gCCyJf9dOoVnayWw_8qrYTQQ4LDt_Q28fVhj20EJJRKXuuqp_Sp5GXWEv8zi7wUqqhGx6-aAMNvKAJvTh0tkni71EC32NGZgnBIbgQbQkXTn2W14PqwygDMcLlWWqUwKopBnKlhlELQ7jmELMgLx2AREjB_oJUzdDnBb8qmlA6-5rxWGUlYbHiD_otZeJgsV3pnBZc6_63km5O7oT7jbHJhNlu7f0zWiSlscIcIth6BZUby9e23DQ8jZbkbSbBl6XI88e4FpY9x9DfYI_7vMFrcE3oCQZ--AsKwWFdm9bLXPU03NRTXJVS92A-orXVkUhlhRgxgPXbaNulWXsrWo-HJFrmcZHZ5hmLE5t2eLk_gRqgCejHSo4Qn4JwUt-kmcWioO0FCQdydZgNKZvP99TWKn5Cqkk03W_rudWdYn0KE_bgTXzgVLf7_95kzDwEyxNTFaeNn6VAaSq4mXet_24vcFHO6khFESYg2Svoe9IVg",
    //         "refreshToken":
    //             "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJiYWQyNTFmYS0wMDczLTQzMjctYjZiZi1hZWNiMzJmMWExZWEiLCJuYmYiOjE2OTkzMjc5MDcsInN1YiI6ImUzMzQ1M2U1LWM4NjUtNGYzNy1hZjlkLWJhOTc1ZjVkZmE3YSIsImlhdCI6MTY5OTMyNzkwNywiZXhwIjoxNzMwOTUwMzA3LCJpc3MiOiJoZXJtaW5hIn0.frOahYYGZV0yi4BXeo9MtJlL3Lk8K7hlEk7UXKuC952szwFnu5U7eaMPaoMAyB52reM7NXhEXCF5JhC3EKbj_sSKEUbBy40pYPSsY6mpfAkgVhjVv-8gMtiEflLXm6xRIhP4nVpNvhRDSTcgPLDm9fsR8mSjWrbpIw84806AzyxA_J_-vS2DGsFbG1mRUQeOX6_CfwG518y1ZqihiyBlPYizYe-ZrdUwlnGrBAPKedBj3elvmStWsc5y8MiNJpe9tueAxd7ZVL9Gc6Z2Dc_mLtjb5aSRS0zXhq8SSTTik7UStaga0Z2iAmA7XLShK42NflzShCODfWZVv3m-z4AghYtLNuuxu5v0iSmahDg8rpxc2MhotATN20raICVOJmMSN2-5-QB2F9arzy-QusSDo6_XGzSMQ9xpOXy1CgLfEnR8ZgbReWM5LeyOHMoTDuQWeEa8Kd3IYtKwXKYkRS6h-8KTINYJ2ENnQ1FejcvT51W-cYVFsrCQkAncjEjLcv4_qryjLzCBbZkGUo0Nu-yNRkvSTRCuY0DcZU8R07Ffa5KGbeJrNgkeREmDbzVWtnjIBtDBMmbCCN-Me1wKWeDwdsI9wo2N63TEiXJWoDbRKZJOSmDcSTjBkgeym3Wl_Vfsh1U_8elfkplZxAVYGIe-3ehx3fjMVsEWmuSdV-cKM1w",
    //         "expiresIn": 1701919907
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.refresh(request);
  }

  Future<Result<SuccessResponse>> forgotPassword(
    ForgotPasswordRequest request,
  ) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.forgotPassword(request);
  }

  Future<Result<SuccessResponse>> resetPassword(
    ResetPasswordRequest request,
  ) {
    // print(request.toJson());
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _authenticationApi.resetPassword(request);
  }

  AuthData? getLocalAuth() {
    return _hiveService.getAuth();
  }

  Future saveLocalAuth(AuthData value) {
    return _hiveService.saveAuth(value);
  }

  Future deleteLocalAuth() {
    return _hiveService.deleteAuth();
  }
}

final authenticationRepositoryProvider =
    Provider.autoDispose<AuthenticationRepository>(
  (ref) {
    return AuthenticationRepository(
      ref.read(authenticationApiProvider),
      ref.read(hiveServiceProvider),
    );
  },
);
