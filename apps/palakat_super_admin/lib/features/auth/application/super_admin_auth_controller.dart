import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/config/app_config.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/services/socket_service.dart';

import '../../../core/services/super_admin_auth_storage.dart';

final superAdminAuthStorageProvider = Provider<SuperAdminAuthStorage>((ref) {
  return SuperAdminAuthStorage();
});

final superAdminSocketServiceProvider = Provider<SocketService>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(superAdminAuthStorageProvider);
  final token = ref.watch(superAdminAuthControllerProvider).asData?.value;

  final api = Uri.parse(config.apiBaseUrl);
  final wsBase =
      '${api.scheme}://${api.host}${api.hasPort ? ':${api.port}' : ''}';

  return SocketService(
    url: wsBase,
    accessTokenProvider: () => token ?? storage.accessToken ?? '',
    refreshTokens: () async {
      throw Failure('No refresh token available');
    },
    onUnauthorized: () async {
      await ref.read(superAdminAuthControllerProvider.notifier).signOut();
    },
  );
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
      final socket = ref.read(superAdminSocketServiceProvider);
      final storage = ref.read(superAdminAuthStorageProvider);

      final trimmedPhone = phone.trim();
      final trimmedPassword = password.trim();

      if (trimmedPhone.isEmpty || trimmedPassword.isEmpty) {
        throw StateError('Phone and password are required');
      }

      final body = await socket.rpc('auth.superAdminSignIn', {
        'phone': trimmedPhone,
        'password': trimmedPassword,
      });

      final data = (body['data'] as Map<String, dynamic>?) ?? const {};
      final tokens = (data['tokens'] as Map<String, dynamic>?) ?? const {};
      final accessToken =
          (tokens['accessToken'] ?? tokens['access_token']) as String?;
      if (accessToken == null || accessToken.trim().isEmpty) {
        throw StateError('Invalid super admin sign-in response');
      }

      await storage.saveAccessToken(accessToken);
      state = AsyncData(accessToken);
    } catch (e, st) {
      if (e is Failure) {
        final msg = e.message.toLowerCase();
        if (msg.contains('invalid credentials')) {
          state = AsyncError(StateError('Invalid phone/password'), st);
          return;
        }
        if (msg.contains('super admin') || msg.contains('forbidden')) {
          state = AsyncError(StateError('Super admin account required'), st);
          return;
        }
      }
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    await ref.read(superAdminAuthStorageProvider).clear();
    state = const AsyncData(null);
  }
}
