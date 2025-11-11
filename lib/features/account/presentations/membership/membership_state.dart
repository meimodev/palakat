import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/models/models.dart';

part 'membership_state.freezed.dart';

@freezed
abstract class MembershipState with _$MembershipState {
  const factory MembershipState({
    Membership? membership,
    Church? church,
    Column? column,
    bool? baptize,
    bool? sidi,
    String? errorChurch,
    String? errorColumn,
    String? errorBaptize,
    String? errorSidi,
    @Default(false) bool loading,
    @Default(false) bool isFormValid,
    final String? errorMessage,
  }) = _MembershipState;
}
