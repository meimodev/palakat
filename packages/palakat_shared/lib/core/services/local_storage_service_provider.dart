import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/services/local_storage_service.dart';

part 'local_storage_service_provider.g.dart';

@riverpod
LocalStorageService localStorageService(Ref ref) {
  // Ensure this provider is kept alive to avoid creating multiple AuthService instances
  // which could lead to losing the cached _auth between reads.
  // This prevents auto-disposal when not listened to.
  // ignore: deprecated_member_use
  ref.keepAlive();
  final service = LocalStorageService();
  // Load cache synchronously (Hive box is opened in main), then fire-and-forget init
  service.loadFromCacheSync();
  service.init();
  return service;
}
