import 'package:freezed_annotation/freezed_annotation.dart';

enum Gender {
  @JsonValue("MALE")
  male,
  @JsonValue("FEMALE")
  female,
}

enum MaritalStatus {
  @JsonValue("SINGLE")
  single,
  @JsonValue("MARRIED")
  married,
}

enum ActivityType {
  @JsonValue("SERVICE")
  service,
  @JsonValue("EVENT")
  event,
  @JsonValue("ANNOUNCEMENT")
  announcement,
  // articles,
}

@JsonEnum(valueField: 'abv')
enum Bipra {
  general("Jemaat", "JMT"),
  fathers("Pria / Kaum Bapa", "PKB"),
  mothers("Wanita / Kaum Ibu", "WKI"),
  youths("Pemuda", "PMD"),
  teens("Remaja", "RMJ"),
  kids("Anak Sekolah Minggu", "ASM");

  const Bipra(this.name, this.abv);

  final String name;
  final String abv;
}

enum MapOperationType {
  pinPoint,
  read,
}
