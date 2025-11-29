import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_shared/core/models/column.dart' as cm;

part 'church_state.freezed.dart';

@freezed
abstract class ChurchState with _$ChurchState {
  const factory ChurchState({
    @Default(AsyncValue.loading()) AsyncValue<Church> church,
    @Default(AsyncValue.loading()) AsyncValue<Location> location,
    @Default(AsyncValue.loading()) AsyncValue<List<cm.Column>> columns,
    @Default(AsyncValue.loading()) AsyncValue<List<MemberPosition>> positions,
  }) = _ChurchState;
}
