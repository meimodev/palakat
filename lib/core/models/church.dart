import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/models.dart';

part 'church.freezed.dart';
part 'church.g.dart';

@freezed
class Church with _$Church {
  const factory Church({
    @Default("") String serial,
    @Default("") String name,
    Location? location,
  }) = _Church;

  factory Church.fromJson(Map<String, dynamic> data) => _$ChurchFromJson(data);
}
