import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'location_select_state.freezed.dart';

@freezed
class LocationSelectState with _$LocationSelectState {
  const factory LocationSelectState({
    @Default(false) bool initScreen,
    @Default(true) bool isLoading,
    @Default(1) int page,
    double? latitude,
    double? longitude,
    @Default(false) bool hasMore,
    @Default([]) List<Location> nearests,
    @Default([]) List<Location> data,
  }) = _LocationSelectState;
}
