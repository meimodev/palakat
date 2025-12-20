import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/config/app_config.dart';
import 'package:palakat_shared/core/config/endpoint.dart';
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

  Future<void> signIn({required String phone, required String password}) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(superAdminDioProvider);
      final storage = ref.read(superAdminAuthStorageProvider);

      final trimmedPhone = phone.trim();
      final trimmedPassword = password.trim();

      if (trimmedPhone.isEmpty || trimmedPassword.isEmpty) {
        throw StateError('Phone and password are required');
      }

      final res = await dio.post<Map<String, dynamic>>(
        Endpoints.superAdminSignIn,
        data: {'phone': trimmedPhone, 'password': trimmedPassword},
      );

      final body = res.data ?? const {};
      final data = (body['data'] as Map<String, dynamic>?) ?? const {};
      final tokens = (data['tokens'] as Map<String, dynamic>?) ?? const {};
      final accessToken =
          (tokens['accessToken'] ?? tokens['access_token']) as String?;
      if (accessToken == null || accessToken.trim().isEmpty) {
        throw StateError('Invalid super admin sign-in response');
      }

      await storage.saveAccessToken(accessToken);
      state = AsyncData(accessToken);
    } on DioException catch (e, st) {
      final status = e.response?.statusCode;
      if (status == 401) {
        state = AsyncError(StateError('Invalid phone/password'), st);
        return;
      }
      if (status == 403) {
        state = AsyncError(StateError('Super admin account required'), st);
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
