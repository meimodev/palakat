import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'location.freezed.dart';
part 'location.g.dart';

@freezed
class Location with _$Location {
  const factory Location({
    @Default("") String serial,
    @Default("") String name,
    @Default([]) List<Hospital> hospitals,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}
