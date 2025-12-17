import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/config/app_config.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

import '../../../core/services/super_admin_auth_storage.dart';

final superAdminAuthStorageProvider = Provider<SuperAdminAuthStorage>((ref) {
  return SuperAdminAuthStorage();
});

final superAdminDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add logging interceptor in debug mode
  if (kDebugMode) {
    dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
        ),
      ),
    );
  }

  return dio;
});

final superAdminAuthedDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(superAdminAuthStorageProvider);
  final token = ref.watch(superAdminAuthControllerProvider).asData?.value;

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add logging interceptor in debug mode
  if (kDebugMode) {
    dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
        ),
      ),
    );
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final accessToken = token ?? storage.accessToken;
        if (accessToken != null && accessToken.trim().isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        if (status == 401) {
          await ref.read(superAdminAuthControllerProvider.notifier).signOut();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

final superAdminAuthControllerProvider =
    AsyncNotifierProvider<SuperAdminAuthController, String?>(
      SuperAdminAuthController.new,
    );

class SuperAdminAuthController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    await SuperAdminAuthStorage.ensureBoxOpen();
    return ref.read(superAdminAuthStorageProvider).accessToken;
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(superAdminDioProvider);
      final storage = ref.read(superAdminAuthStorageProvider);

      final trimmedUsername = username.trim();
      final trimmedPassword = password.trim();

      if (trimmedUsername.isEmpty || trimmedPassword.isEmpty) {
        throw StateError('Username and password are required');
      }

      final allowedUsername = dotenv.env['SUPER_ADMIN_USERNAME']?.trim() ?? '';
      final allowedPassword = dotenv.env['SUPER_ADMIN_PASSWORD']?.trim() ?? '';

      if (allowedUsername.isEmpty || allowedPassword.isEmpty) {
        throw StateError(
          'Missing required env var: SUPER_ADMIN_USERNAME, SUPER_ADMIN_PASSWORD',
        );
      }

      if (trimmedUsername != allowedUsername ||
          trimmedPassword != allowedPassword) {
        throw StateError('Invalid username/password');
      }

      final clientUsername = dotenv.env['APP_CLIENT_USERNAME']?.trim() ?? '';
      final clientPassword = dotenv.env['APP_CLIENT_PASSWORD']?.trim() ?? '';

      if (clientUsername.isEmpty || clientPassword.isEmpty) {
        throw StateError(
          'Missing required env var: APP_CLIENT_USERNAME, APP_CLIENT_PASSWORD',
        );
      }

      final res = await dio.get<Map<String, dynamic>>(
        'auth/signing',
        options: Options(
          headers: {'x-username': clientUsername, 'x-password': clientPassword},
        ),
      );

      final body = res.data ?? const {};
      final token = body['data'] as String?;
      if (token == null || token.trim().isEmpty) {
        throw StateError('Invalid signing response');
      }

      await storage.saveAccessToken(token);
      state = AsyncData(token);
    } on DioException catch (e, st) {
      final status = e.response?.statusCode;
      if (status == 401) {
        state = AsyncError(StateError('Failed to authenticate client'), st);
        return;
      }
      state = AsyncError(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    await ref.read(superAdminAuthStorageProvider).clear();
    state = const AsyncData(null);
  }
}
