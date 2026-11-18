import 'package:flutter/widgets.dart';

/// stem → reset callback, registered by each mounted `<Stem>Kendali`
/// (navigation.md 2.1, "Reset"). An entry means the board is in the stack.
final Map<String, VoidCallback> ulangPapan = {};

/// Provided by a `<Stem>Kendali`; bumping [generasi] remounts the board's views.
class GenerasiPapan extends InheritedWidget {
  const GenerasiPapan({super.key, required this.generasi, required super.child});
  final int generasi;

  static int of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GenerasiPapan>()?.generasi ?? 0;

  @override
  bool updateShouldNotify(GenerasiPapan old) => old.generasi != generasi;
}

/// Wraps each route of a board with child routes so widget-local state remounts on reset.
class DenganGenerasi extends StatelessWidget {
  const DenganGenerasi({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => KeyedSubtree(key: ValueKey(GenerasiPapan.of(context)), child: child);
}
