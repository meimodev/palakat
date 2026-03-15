import 'package:palakat_shared/core/models/home_dashboard.dart';
import 'package:palakat_shared/core/models/request/get_home_dashboard_request.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/services/socket_service.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) => HomeRepository(ref);

class HomeRepository {
  HomeRepository(this._ref);

  final Ref _ref;

  Future<Result<HomeDashboardResponse, Failure>> getHomeDashboard({
    GetHomeDashboardRequest? request,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('app.home.get', request?.toJson());

      // Save to offline cache on success
      try {
        await _ref.read(localStorageServiceProvider).saveDashboardCache(body);
      } catch (_) {}

      return Result.success(HomeDashboardResponse.fromJson(body));
    } catch (e) {
      // Attempt to load from offline cache on failure
      try {
        final cache = _ref
            .read(localStorageServiceProvider)
            .getDashboardCache();
        if (cache != null) {
          return Result.success(HomeDashboardResponse.fromJson(cache));
        }
      } catch (_) {}

      return Result.failure(Failure.fromException(e));
    }
  }
}
