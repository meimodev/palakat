class HelpState {
  final String? selectedTag;

  const HelpState({
    this.selectedTag,
  });

  HelpState copyWith({
    String? selectedTag,
  }) {
    return HelpState(
      selectedTag: selectedTag ?? this.selectedTag,
    );
  }
}
