import 'package:palakat_shared/core/models/home_dashboard.dart';
import 'package:palakat_shared/core/models/request/get_home_dashboard_request.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/services/socket_service.dart';
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
      return Result.success(HomeDashboardResponse.fromJson(body));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
