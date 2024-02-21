import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/features/domain.dart';

part 'hospital_select_state.freezed.dart';

@freezed
class HospitalSelectState with _$HospitalSelectState {
  const factory HospitalSelectState({
    @Default(SelectType.single) SelectType type,
    @Default(false) bool initScreen,
    @Default(true) bool isLoading,
    @Default(1) int page,
    String? doctorSerial,
    List<String>? serials,
    double? latitude,
    double? longitude,
    @Default(false) bool hasMore,
    @Default([]) List<Hospital> nearests,
    @Default([]) List<Hospital> data,
  }) = _HospitalSelectState;
}
