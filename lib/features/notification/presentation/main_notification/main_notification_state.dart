import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'main_notification_state.freezed.dart';

@freezed
class MainNotificationState with _$MainNotificationState {
  const factory MainNotificationState({
    @Default(1) int page,
    @Default([]) List<Notification> notifications,
    @Default(false) bool isLoading,
    @Default(false) bool hasMore,
  }) = _MainNotificationState;
}
