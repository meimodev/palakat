import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/approval/presentations/approval_detail_state.dart';

part 'approval_detail_controller.g.dart';

@riverpod
class ApprovalDetailController extends _$ApprovalDetailController {
  ActivityRepository get _activityRepository =>
      ref.read(activityRepositoryProvider);
  ApproverRepository get _approverRepository =>
      ref.read(approverRepositoryProvider);

  @override
  ApprovalDetailState build({required int activityId}) {
    final socket = ref.read(socketServiceProvider);
    var previousConnectionStatus = socket.connectionStatus;

    void onSocketStatusChanged() {
      final nextStatus = socket.connectionStatus;
      final didReconnect =
          previousConnectionStatus != SocketConnectionStatus.connected &&
          nextStatus == SocketConnectionStatus.connected;
      previousConnectionStatus = nextStatus;

      if (!didReconnect) {
        return;
      }

      Future.microtask(() => fetch(activityId));
    }

    socket.connectionStatusListenable.addListener(onSocketStatusChanged);
    ref.onDispose(() {
      socket.connectionStatusListenable.removeListener(onSocketStatusChanged);
    });

    ref.listen(realtimeEventProvider, (_, next) {
      final event = next.asData?.value;
      if (event == null) {
        return;
      }

      final eventActivityId = _extractActivityId(event);
      if (eventActivityId != activityId) {
        return;
      }

      if (event.name == 'activity.updated') {
        Future.microtask(() => fetch(activityId));
      }

      if (event.name == 'activity.deleted') {
        state = state.copyWith(
          activity: null,
          loadingScreen: false,
          isActionLoading: false,
          errorMessage: null,
        );
      }
    });

    // Schedule fetch after provider initialization completes
    Future.microtask(() => fetch(activityId));
    return const ApprovalDetailState();
  }

  int? _extractActivityId(RealtimeEvent event) {
    if (event.name != 'activity.updated' && event.name != 'activity.deleted') {
      return null;
    }

    final data = event.payload['data'];
    if (data is Map<String, dynamic>) {
      final value = data['activityId'];
      return value is int ? value : int.tryParse('$value');
    }

    if (data is Map) {
      final value = data['activityId'];
      return value is int ? value : int.tryParse('$value');
    }

    return null;
  }

  /// Fetch activity details from the API
  /// _Requirements: 3.8_
  Future<void> fetch(int id) async {
    state = state.copyWith(loadingScreen: true, errorMessage: null);

    final result = await _activityRepository.fetchActivity(activityId: id);

    result.when(
      onSuccess: (activity) {
        state = state.copyWith(activity: activity, loadingScreen: false);
      },
      onFailure: (failure) {
        state = state.copyWith(
          loadingScreen: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Approve the activity by updating the approver status
  /// Requirements: 5.1, 5.3, 5.5
  Future<bool> approveActivity(int approverId) async {
    state = state.copyWith(isActionLoading: true, errorMessage: null);

    final result = await _approverRepository.updateApprover(
      approverId: approverId,
      update: {'status': 'APPROVED'},
    );

    bool success = false;
    result.when(
      onSuccess: (_) {
        state = state.copyWith(isActionLoading: false);
        success = true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        );
        success = false;
      },
    );
    return success;
  }

  /// Reject the activity by updating the approver status
  /// Requirements: 5.1, 5.4, 5.5
  Future<bool> rejectActivity(int approverId) async {
    state = state.copyWith(isActionLoading: true, errorMessage: null);

    final result = await _approverRepository.updateApprover(
      approverId: approverId,
      update: {'status': 'REJECTED'},
    );

    bool success = false;
    result.when(
      onSuccess: (_) {
        state = state.copyWith(isActionLoading: false);
        success = true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        );
        success = false;
      },
    );
    return success;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }
}
