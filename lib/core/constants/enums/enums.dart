enum Gender {
  male,
  female,
}

enum MaritalStatus {
  single,
  married,
}

enum ActivityType {
  service,
  event,
  announcement,
  // articles,
}

enum Bipra {
  general("Jemaat","JMT"),
  fathers("Pria / Kaum Bapa","PKB"),
  mothers("Wanita / Kaum Ibu","WKI"),
  youths("Pemuda","PMD"),
  teens("Remaja","RMJ"),
  kids("Anak Sekolah Minggu","ASM"),;

  const Bipra(this.name, this.abv);

  final String name;
  final String abv;

}