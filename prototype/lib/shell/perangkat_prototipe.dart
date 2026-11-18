import 'package:flutter/widgets.dart';

import 'prototipe_state.dart';

/// Registers a board's prototype devices (components.md 4.9 item 4): the things
/// the handoff says never to build into a screen – "Dilihat sebagai" chips,
/// "Contoh: …" buttons, the accepted code "123456", "Di prototipe ini: …"
/// hints. The Keadaan panel shows them under "Alat prototipe" while this
/// board is the top page.
///
/// Wrap the screen and build [alat] from its own state in `build`, so the
/// devices follow that state:
///
/// ```dart
/// AlatPrototipe(
///   stem: 'AlurUnit',
///   alat: [
///     if (!dibukukan) Tekan(onTap: bukukan, child: const Text('Contoh: Rp250.000 dibukukan')),
///     const Text('Kode yang diterima: 123456'),
///   ],
///   child: LayarPonsel(...),
/// )
/// ```
///
/// [child] renders unchanged. Publishing happens after the frame, so it never
/// rebuilds the screen.
class AlatPrototipe extends StatefulWidget {
  const AlatPrototipe({
    super.key,
    required this.stem,
    required this.alat,
    required this.child,
  });
  final String stem;
  final List<Widget> alat;
  final Widget child;

  @override
  State<AlatPrototipe> createState() => _AlatPrototipeState();
}

class _AlatPrototipeState extends State<AlatPrototipe> {
  PrototypeState? _keadaan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _keadaan = PrototypeState.maybeOf(context, dengar: false);
  }

  @override
  void initState() {
    super.initState();
    _terbitkan();
  }

  @override
  void didUpdateWidget(AlatPrototipe old) {
    super.didUpdateWidget(old);
    _terbitkan();
  }

  void _terbitkan() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _keadaan?.pasangAlat(this, widget.stem, widget.alat);
  });

  @override
  void dispose() {
    final (k, stem) = (_keadaan, widget.stem);
    if (k != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => k.lepasAlat(this, stem),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
