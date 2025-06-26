import 'package:freezed_annotation/freezed_annotation.dart';

part 'church.freezed.dart';
part 'church.g.dart';

@freezed
abstract class Church with _$Church {
  const factory Church({
    required int id,
    required String name,
    required String latitude,
    required String longitude,
    required String address,
  }) = _Church;

  factory Church.fromJson(Map<String, dynamic> data) => _$ChurchFromJson(data);
}
