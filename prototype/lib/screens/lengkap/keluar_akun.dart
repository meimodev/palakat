import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../providers/session.dart';

// Parts Keluar and WebKeluar draw alike (12-lihattransaksi.md, WebKeluar
// "exactly as Keluar 2a–2c"). Text sizes not written on the board inherit
// the root: 16 on the phone, 15 on the web.

/// Profile card; [ke] is the "Ganti nomor ponsel" target.
///
/// The link is a TextSpan so it wraps with its sentence, as the board's `<a>`
/// does; its 44 px target is a transparent [Tautan] laid over each of its line
/// boxes after layout, kept inside the card's 16 px padding.
class KartuProfil extends StatefulWidget {
  const KartuProfil({super.key, required this.ke});
  final Layar ke;

  @override
  State<KartuProfil> createState() => _KartuProfilState();
}

class _KartuProfilState extends State<KartuProfil> {
  static const _awal = 'Masuk dengan kode ke nomor ponsel · ';
  static const _tautan = 'Ganti nomor ponsel';
  final _teks = GlobalKey();
  List<Rect> _kotak = const [];
  bool _layang = false;

  void _layangi(bool v) {
    if (mounted) setState(() => _layang = v);
  }

  void _ukur() {
    if (!mounted) return;
    final p = _teks.currentContext?.findRenderObject();
    final kartu = context.findRenderObject();
    if (p is! RenderParagraph || kartu is! RenderBox || !p.hasSize) return;
    final asal = p.localToGlobal(Offset.zero, ancestor: kartu);
    final kotak = [
      for (final b in p.getBoxesForSelection(
        const TextSelection(
          baseOffset: _awal.length,
          extentOffset: _awal.length + _tautan.length,
        ),
      ))
        Rect.fromCenter(
          center: b.toRect().shift(asal).center,
          width: math.max(b.right - b.left, 44),
          height: math.max(b.bottom - b.top, 44),
        ),
    ];
    if (!listEquals(kotak, _kotak)) setState(() => _kotak = kotak);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final warna = _layang ? c.lautTua : c.laut;
    return LayoutBuilder(
      builder: (context, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _ukur());
        return Stack(
          children: [
            Kartu(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Meiske Lumentut',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bendahara · Jemaat Karunia · Wewenang Bendahara aktif',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    key: _teks,
                    TextSpan(
                      text: _awal,
                      children: [
                        TextSpan(
                          text: _tautan,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: warna,
                            decoration: TextDecoration.underline,
                            decorationColor: warna,
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ),
            // One focus stop and one semantics node for the whole link.
            for (final (i, r) in _kotak.indexed)
              Positioned.fromRect(
                rect: r,
                child: MouseRegion(
                  onEnter: (_) => _layangi(true),
                  onExit: (_) => _layangi(false),
                  child: ExcludeFocus(
                    excluding: i > 0,
                    child: ExcludeSemantics(
                      excluding: i > 0,
                      child: Tautan(
                        ke: widget.ke,
                        label: _tautan,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Sessions card; [ke] is the "Sesi di perangkat lain" target.
class KartuSesi extends StatelessWidget {
  const KartuSesi({
    super.key,
    required this.ke,
    this.param = const {},
    this.anak,
  });
  final Layar ke;
  final Map<String, String> param;
  final String? anak;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Perangkat ini',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Masuk sejak 16/11/2026 08.02',
                        style: TextStyle(fontSize: 13, color: c.tinta3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const LencanaStatus(
                  'Sedang dipakai',
                  bentuk: BentukLencana.peran,
                ),
              ],
            ),
          ),
          Tautan(
            ke: ke,
            param: param,
            anak: anak,
            child: Container(
              // min-height 52 is content-box on the board: plus the 1 px rule.
              constraints: const BoxConstraints(minHeight: 53),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.garis)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Sesi di perangkat lain',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 16),
                  PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The sentence under the cards.
class KalimatKeluar extends StatelessWidget {
  const KalimatKeluar({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'Keluar hanya mengakhiri sesi di perangkat ini. Wewenang Bendahara tidak berubah.',
    style: TextStyle(fontSize: 14, color: context.warna.tinta2),
  );
}

const judulTanya = 'Keluar dari perangkat ini?';
const kalimatTanya =
    'Yang sudah dibukukan dan draf yang sudah tersimpan tetap aman. Isian yang belum tersimpan akan hilang.';

/// The confirmation's two buttons: "Keluar" (`tinta` field, a plain press)
/// and the text button "Kembali" (`tinta`).
List<Widget> tombolTanya(
  BuildContext context, {
  required VoidCallback onKeluar,
  required VoidCallback onKembali,
}) => [
  Tombol('Keluar', onPressed: onKeluar, jenis: JenisTombol.tinta, paddingH: 20),
  Tombol(
    'Kembali',
    onPressed: onKembali,
    jenis: JenisTombol.teks,
    warnaTeks: context.warna.tinta,
  ),
];

/// "Anda sudah keluar", its sentence and "Masuk", which opens the picker.
class IsiSudahKeluar extends StatelessWidget {
  const IsiSudahKeluar({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        child: const Text(
          'Anda sudah keluar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Sesi di perangkat ini berakhir. Masuk lagi kapan saja dengan kode yang dikirim ke nomor ponsel Anda.',
        style: TextStyle(fontSize: 15, color: context.warna.tinta2),
      ),
      const SizedBox(height: 20),
      Tombol(
        'Masuk',
        onPressed: () => keluarSesi(context),
        paddingH: 20,
      ),
    ],
  );
}
