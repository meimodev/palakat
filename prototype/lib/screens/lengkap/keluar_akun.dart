import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';

// Parts Keluar and WebKeluar draw alike (12-lihattransaksi.md, WebKeluar
// "exactly as Keluar 2a–2c"). Text sizes not written on the board inherit
// the root: 16 on the phone, 15 on the web.

/// Profile card; [ke] is the "Ganti nomor ponsel" target.
class KartuProfil extends StatelessWidget {
  const KartuProfil({super.key, required this.ke});
  final String ke;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
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
          _TautanSebaris(
            awal: 'Masuk dengan kode ke nomor ponsel · ',
            tautan: 'Ganti nomor ponsel',
            ke: ke,
          ),
        ],
      ),
    );
  }
}

/// A sentence ending in an inline link that wraps with the text, as the
/// board's `<a>` does.
// ponytail: the link is a TextSpan, so its target is the text's own line box
// (about 18 px tall), not 44 px; a taller target would change the card's
// line layout the board draws.
class _TautanSebaris extends StatefulWidget {
  const _TautanSebaris({
    required this.awal,
    required this.tautan,
    required this.ke,
  });
  final String awal, tautan, ke;

  @override
  State<_TautanSebaris> createState() => _TautanSebarisState();
}

class _TautanSebarisState extends State<_TautanSebaris> {
  late final _ketuk = TapGestureRecognizer()
    ..onTap = () => Tautan(
      ke: widget.ke,
      child: const SizedBox(),
    ).buka(GoRouter.of(context));
  bool _layang = false;

  @override
  void dispose() {
    _ketuk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final warna = _layang ? c.lautTua : c.laut;
    return Text.rich(
      TextSpan(
        text: widget.awal,
        children: [
          TextSpan(
            text: widget.tautan,
            recognizer: _ketuk,
            mouseCursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _layang = true),
            onExit: (_) => setState(() => _layang = false),
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
    );
  }
}

/// Sessions card; [ke] is the "Sesi di perangkat lain" target.
class KartuSesi extends StatelessWidget {
  const KartuSesi({super.key, required this.ke});
  final String ke;

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
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
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

/// "Anda sudah keluar", its sentence and "Masuk" ([ke], go).
class IsiSudahKeluar extends StatelessWidget {
  const IsiSudahKeluar({super.key, required this.ke});
  final String ke;

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
      Tombol('Masuk', onPressed: null, ke: ke, cara: Cara.ganti, paddingH: 20),
    ],
  );
}
