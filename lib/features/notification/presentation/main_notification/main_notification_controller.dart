import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/network/network.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/presentation.dart';

class MainNotificationController extends StateNotifier<MainNotificationState> {
  MainNotificationController(this.notificationService, this.authService)
      : super(const MainNotificationState());
  final NotificationService notificationService;
  final AuthenticationService authService;

  void init() {
    if (authService.isLoggedIn) {
      getData(isRefresh: true);
    }
  }

  Future handleRefresh() async {
    await getData(isRefresh: true, withLoading: false);
  }

  Future handleGetMore() async {
    if (state.hasMore) {
      state = state.copyWith(
        page: state.page + 1,
      );

      await getData(withLoading: false);
    }
  }

  void handleRead(String serial) async {
    final result = await notificationService.read(serial);

    result.when(
      success: (data) async {
        getData(isRefresh: true, withLoading: true);
      },
      failure: (error, _) {
        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }

  Future getData({
    bool isRefresh = false,
    bool withLoading = true,
  }) async {
    if (withLoading) {
      if (isRefresh) {
        state = state.copyWith(isLoading: true, page: 1);
      } else {
        state = state.copyWith(isLoading: true);
      }
    } else {
      if (isRefresh) {
        state = state.copyWith(page: 1);
      }
    }

    var result = await notificationService.getNotifications(
      NotificationListRequest(
        page: state.page,
        pageSize: Pagination.pageSize,
      ),
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          isLoading: false,
          notifications: isRefresh
              ? response.data
              : [...state.notifications, ...response.data],
          hasMore: response.totalPage > state.page,
        );

        return true;
      },
      failure: (error, _) {
        state = state.copyWith(
          isLoading: false,
        );
        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);

        return false;
      },
    );
  }
}

final mainNotificationControllerProvider = StateNotifierProvider.autoDispose<
    MainNotificationController, MainNotificationState>((ref) {
  return MainNotificationController(
    ref.read(notificationServiceProvider),
    ref.read(authenticationServiceProvider),
  );
});
