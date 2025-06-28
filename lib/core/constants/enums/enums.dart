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

enum Reminder {
  tenMinutes("10 Minutes Before"),
  thirtyMinutes("30 Minutes Before"),
  oneHour("1 Hour Before"),
  twoHour("2 Hour Before");

  const Reminder(this.name);

  final String name;
}

enum MapOperationType {
  pinPoint,
  read,
}

enum SongPartType {
  @JsonValue("INTRO")
  intro,

  @JsonValue("OUTRO")
  outro,

  @JsonValue("VERSE")
  verse,

  @JsonValue("VERSE2")
  verse2,

  @JsonValue("VERSE4")
  verse3,

  @JsonValue("VERSE4")
  verse4,

  @JsonValue("VERSE5")
  verse5,

  @JsonValue("VERSE6")
  verse6,

  @JsonValue("VERSE7")
  verse7,

  @JsonValue("VERSE8")
  verse8,

  @JsonValue("REFRAIN")
  refrain,

  @JsonValue("PRECHORUS")
  preChorus,

  @JsonValue("CHORUS")
  chorus,

  @JsonValue("CHORUS2")
  chorus2,

  @JsonValue("CHORUS3")
  chorus3,

  @JsonValue("CHORUS4")
  chorus4,

  @JsonValue("BRIDGE")
  bridge,

  @JsonValue("HOOK")
  hook,
}
