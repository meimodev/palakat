import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/models.dart';

import '../data/operation_models.dart';

part 'operations_state.freezed.dart';

@freezed
abstract class OperationsState with _$OperationsState {
  const factory OperationsState({
    /// User's membership data containing positions
    Membership? membership,

    /// Whether the screen is currently loading
    @Default(true) bool loadingScreen,

    /// Error message if data fetch fails
    final String? errorMessage,

    /// List of operation categories (Publishing, Financial, Reports)
    @Default([]) List<OperationCategory> categories,

    /// Map tracking expansion state for each category by ID
    /// Key: category ID, Value: whether expanded
    @Default({}) Map<String, bool> categoryExpansionState,
  }) = _OperationsState;
}
