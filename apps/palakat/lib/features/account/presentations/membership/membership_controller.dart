import 'package:palakat/features/presentation.dart';
import 'package:palakat_admin/core/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'membership_controller.g.dart';

@riverpod
class MembershipController extends _$MembershipController {
  @override
  MembershipState build() {
    return const MembershipState();
  }

  String? validateChurch(Church? value) {
    if (value == null) {
      return 'Church Number is required';
    }
    return null;
  }

  String? validateColumn(Column? value) {
    if (value == null) {
      return 'Column is required';
    }
    return null;
  }

  String? validateBaptize(bool? value) {
    if (value == null) {
      return 'Baptize is required';
    }
    return null;
  }

  String? validateSidi(bool? value) {
    if (value == null) {
      return 'Sidi is required';
    }
    return null;
  }

  void onChangedChurch(Church? value) {
    state = state.copyWith(church: value, errorChurch: null);
  }

  void onChangedColumn(Column value) {
    state = state.copyWith(column: value, errorColumn: null);
  }

  void onChangedBaptize(bool value) {
    state = state.copyWith(baptize: value, errorBaptize: null);
  }

  void onChangedSidi(bool value) {
    state = state.copyWith(sidi: value, errorSidi: null);
  }

  bool validateMembership() {
    return validateChurch(state.church) == null &&
        validateColumn(state.column) == null &&
        validateBaptize(state.baptize) == null &&
        validateSidi(state.sidi) == null;
  }

  Future<void> validateForm() async {
    state = state.copyWith(loading: true);
    final errorChurch = validateChurch(state.church);
    final errorColumn = validateColumn(state.column);
    final errorBaptize = validateBaptize(state.baptize);
    final errorSidi = validateSidi(state.sidi);

    final isValid =
        errorChurch == null &&
        errorColumn == null &&
        errorBaptize == null &&
        errorSidi == null;

    state = state.copyWith(
      errorChurch: errorChurch,
      errorColumn: errorColumn,
      errorBaptize: errorBaptize,
      errorSidi: errorSidi,
      isFormValid: isValid,
    );

    await Future.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(loading: false);
  }

  Future<bool> submit() async {
    await validateForm();
    return state.isFormValid;
  }

  void publish() {}
}
