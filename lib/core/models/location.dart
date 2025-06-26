import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

@freezed
abstract class Location with _$Location {
  const factory Location({
    @Default(0) double latitude ,
    @Default(0) double longitude ,
    @Default("") String name ,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> data) => _$LocationFromJson(data);



}
