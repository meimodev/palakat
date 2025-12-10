import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission_state.freezed.dart';

part 'permission_state.g.dart';

/// Permission status for notification permissions
enum PermissionStatus {
  /// Never asked for permission
  notDetermined,

  /// User granted permission
  granted,

  /// User denied permission (can ask again)
  denied,

  /// User permanently denied permission (selected "Don't ask again" on Android)
  permanentlyDenied,
}

/// Model representing the state of notification permission
@freezed
abstract class PermissionStateModel with _$PermissionStateModel {
  const factory PermissionStateModel({
    required PermissionStatus status,
    DateTime? deniedAt,
    @Default(0) int denialCount,
    DateTime? lastCheckedAt,
  }) = _PermissionStateModel;

  factory PermissionStateModel.fromJson(Map<String, dynamic> json) =>
      _$PermissionStateModelFromJson(json);
}
