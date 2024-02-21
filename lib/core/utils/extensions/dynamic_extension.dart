extension XDynamic on dynamic {
  bool isNotNull() {
    return this != null;
  }

  bool isNull() {
    return this == null;
  }
}

extension XListDynamic on List<dynamic>? {
  bool isNullOrEmpty() {
    return this == null || this!.isEmpty;
  }
}
