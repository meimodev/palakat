import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/config/endpoint.dart';
import 'package:palakat_admin/core/models/auth_credentials.dart';
import 'package:palakat_admin/core/models/auth_response.dart';
import 'package:palakat_admin/core/models/auth_tokens.dart';
import 'package:palakat_admin/core/models/result.dart';
import 'package:palakat_admin/core/services/local_storage_service.dart';
import 'package:palakat_admin/core/services/local_storage_service_provider.dart';
import 'package:palakat_admin/core/services/http_service.dart';
import 'package:palakat_admin/core/utils/error_mapper.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  const AuthRepository(this._dio, this._localStorageService);

  Future<Result<AuthResponse, Failure>> signIn(
    AuthCredentials credentials,
  ) async {
    try {
      final body = {
        'identifier': credentials.identifier,
        'password': credentials.password,
      };
      final res = await _dio.post<Map<String, dynamic>>(
        Endpoints.signIn,
        data: body,
      );
      final auth = AuthResponse.fromJson(res.data?["data"] ?? const {});
      // Persist full auth payload (tokens + account) using Hive
      await _localStorageService.saveAuth(auth);
      return Result.success(auth);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to sign in');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to sign in', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<AuthTokens, Failure>> refresh() async {
    try {
      final refreshToken = _localStorageService.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        return Result.failure(Failure('No refresh token available'));
      }
      final res = await _dio.post<Map<String, dynamic>>(
        Endpoints.refresh,
        data: {'refresh_token': refreshToken},
      );
      // some APIs return tokens directly; others nest in data
      final data = res.data ?? const {};
      final tokens = AuthTokens.fromJson(data["data"]);
      await _localStorageService.saveTokens(tokens);
      return Result.success(tokens);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to refresh tokens');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to refresh tokens', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<void, Failure>> signOut() async {
    try {
      await _dio.post(Endpoints.signOut);
    } catch (_) {
      // ignore network errors on logout
    } finally {
      await _localStorageService.clear();
    }
    // Always succeed after clearing local storage
    return Result.success(null);
  }

  Future<Result<Account?, Failure>> getSignedInAccount() async {
    try {
      final result = _localStorageService.currentAuth;
      return Result.success(result?.account);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Validates if an account exists by phone number
  Future<Result<AuthResponse, Failure>> validateAccountByPhone(
    String phone,
  ) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        Endpoints.validatePhone,
        queryParameters: {'phone': phone},
      );

      final data = res.data ?? {};
      final json = data['data'];

      if (json == null || json.isEmpty) {
        return Result.failure(Failure('Account not found', 404));
      }
      final auth = AuthResponse.fromJson(json);
      await _localStorageService.saveAuth(auth);

      return Result.success(auth);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to validate account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to validate account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<AuthResponse?, Failure>> updateLocallySavedAuth(
      AuthResponse auth,
      ) async {
    try {
      await _localStorageService.saveAuth(auth);
      return Result.success(auth);
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to update locally saved auth',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioInstanceProvider);
  final auth = ref.watch(localStorageServiceProvider);
  return AuthRepository(dio, auth);
}
