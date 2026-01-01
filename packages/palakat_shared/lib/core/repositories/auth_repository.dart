import 'package:palakat_shared/core/models/account.dart';
import 'package:palakat_shared/core/models/auth_credentials.dart';
import 'package:palakat_shared/core/models/auth_response.dart';
import 'package:palakat_shared/core/models/auth_tokens.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/services/local_storage_service.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:palakat_shared/core/services/socket_service.dart';
import 'package:palakat_shared/core/utils/error_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final SocketService _socket;
  final LocalStorageService _localStorageService;

  const AuthRepository(this._socket, this._localStorageService);

  Future<Result<AuthResponse, Failure>> signIn(
    AuthCredentials credentials,
  ) async {
    try {
      final auth = await _socket.signIn(
        identifier: credentials.identifier,
        password: credentials.password,
      );
      // Persist full auth payload (tokens + account) using Hive
      await _localStorageService.saveAuth(auth);
      return Result.success(auth);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<AuthResponse, Failure>> firebaseSignIn({
    required String firebaseIdToken,
  }) async {
    try {
      if (firebaseIdToken.trim().isEmpty) {
        return Result.failure(Failure('Firebase ID token is required'));
      }

      final res = await _socket.rpc('auth.firebaseSignIn', {
        'firebaseIdToken': firebaseIdToken,
      });
      final json = res['data'];
      if (json is! Map<String, dynamic> || json.isEmpty) {
        return Result.failure(Failure('Invalid auth response'));
      }

      final auth = AuthResponse.fromJson(json);
      await _localStorageService.saveAuth(auth);
      await _socket.rpc('auth.attach', {
        'accessToken': auth.tokens.accessToken,
      });

      return Result.success(auth);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<AuthResponse, Failure>> firebaseRegister({
    required String firebaseIdToken,
    required Map<String, dynamic> dto,
  }) async {
    try {
      if (firebaseIdToken.trim().isEmpty) {
        return Result.failure(Failure('Firebase ID token is required'));
      }

      final res = await _socket.rpc('auth.firebaseRegister', {
        'firebaseIdToken': firebaseIdToken,
        ...dto,
      });
      final json = res['data'];
      if (json is! Map<String, dynamic> || json.isEmpty) {
        return Result.failure(Failure('Invalid auth response'));
      }

      final auth = AuthResponse.fromJson(json);
      await _localStorageService.saveAuth(auth);
      await _socket.rpc('auth.attach', {
        'accessToken': auth.tokens.accessToken,
      });

      return Result.success(auth);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<AuthTokens, Failure>> refresh() async {
    try {
      final refreshToken = _localStorageService.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        return Result.failure(Failure('No refresh token available'));
      }
      final tokens = await _socket.refresh(refreshToken: refreshToken);
      await _localStorageService.saveTokens(tokens);
      return Result.success(tokens);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<void, Failure>> signOut() async {
    try {
      await _socket.rpc('auth.signOut');
    } catch (_) {
      // ignore network errors on logout
    } finally {
      await clearAuth();
    }
    // Always succeed after clearing local storage
    return Result.success(null);
  }

  /// Clears all authentication data from local storage
  /// This includes tokens, account data, membership, permission state,
  /// and notification settings
  Future<void> clearAuth() async {
    await _localStorageService.clearAllUserData();
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
      final res = await _socket.rpc('auth.validatePhone', {'phone': phone});
      final json = res['data'];

      if (json is! Map<String, dynamic> || json.isEmpty) {
        return Result.failure(Failure('Account not found', 404));
      }
      final auth = AuthResponse.fromJson(json);
      await _localStorageService.saveAuth(auth);

      return Result.success(auth);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
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

  Future<Result<void, Failure>> syncClaims({
    required String firebaseIdToken,
  }) async {
    try {
      if (firebaseIdToken.trim().isEmpty) {
        return Result.failure(Failure('Firebase ID token is required'));
      }

      await _socket.rpc('auth.syncClaims', {
        'firebaseIdToken': firebaseIdToken,
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final socket = ref.watch(socketServiceProvider);
  final auth = ref.watch(localStorageServiceProvider);
  return AuthRepository(socket, auth);
}
