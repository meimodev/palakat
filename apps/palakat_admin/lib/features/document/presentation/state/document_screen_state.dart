import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/models.dart';

part 'document_screen_state.freezed.dart';

@freezed
abstract class DocumentScreenState with _$DocumentScreenState {
  const factory DocumentScreenState({
    @Default(AsyncValue.loading()) AsyncValue<PaginationResponseWrapper<Document>> documents,
    @Default(100) int pageSize,
    @Default(1) int currentPage,
  }) = _DocumentScreenState;
}
