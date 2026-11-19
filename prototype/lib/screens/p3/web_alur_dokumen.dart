import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'alur_dokumen_alur.dart';

/// Web · Alur · Menerbitkan dokumen. The three views replace each other in
/// place (`v`), under the same title block.
class WebAlurDokumenScreen extends StatefulWidget {
  const WebAlurDokumenScreen({super.key});
  @override
  State<WebAlurDokumenScreen> createState() => _WebAlurDokumenScreenState();
}

class _WebAlurDokumenScreenState extends State<WebAlurDokumenScreen> {
  final _a = AlurDokumenData();
  final _kunci = GlobalKey();
  var _v = 'daftar';

  @override
  void initState() {
    super.initState();
    _a.addListener(_keAtas);
  }

  /// A view change jumps to the top (CONVENTIONS, "Scroll on view change").
  void _keAtas() {
    if (_a.v == _v) return;
    _v = _a.v;
    final c = _kunci.currentContext;
    if (c != null) Scrollable.maybeOf(c)?.position.jumpTo(0);
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HalamanWeb(
    nav: const NavSamping(
      item: navPlatform,
      aktif: 2,
      pengguna: PenggunaNav(
        tebal: 'Olvie Pangemanan',
        biasa: ' · Sekretaris Jemaat',
      ),
    ),
    isi: [
      const _Judul(),
      Align(
        key: _kunci,
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ListenableBuilder(
            listenable: _a,
            builder: (context, _) => kolomAlur(_isi(context), 16),
          ),
        ),
      ),
    ],
  );

  List<Widget> _isi(BuildContext context) {
    final a = _a;
    switch (a.v) {
      case 'form':
        return [
          _duaKolom(
            isianTerbit(a),
            aksiTerbit(context, a, onTerbit: a.terbit, onBatal: a.batal),
          ),
        ];
      case 'ralat':
        return [
          _duaKolom(
            isianRalat(context, a),
            aksiRalat(context, a, onTerbit: a.terbitRev, onBatal: a.batal),
          ),
        ];
      default:
        return daftarAlurDokumen(
          context,
          a,
          onBaru: a.keForm,
          onRalat: a.keRalat,
        );
    }
  }

  /// `flex-wrap: wrap; gap: 20px 28px; align-items: flex-start`; left
  /// `flex: 1.3 1 420px`, right `flex: 1 1 340px`, each a column gap 12.
  Widget _duaKolom(List<Widget> kiri, List<Widget> kanan) => BarisLentur(
    jarak: 28,
    jarakBaris: 20,
    anak: [
      Lentur(dasar: 420, tumbuh: 1.3, child: kolomAlur(kiri, 12)),
      Lentur(dasar: 340, child: kolomAlur(kanan, 12)),
    ],
  );
}

/// Breadcrumb "Dokumen gereja" (up link), h1 26/700 margin-top 2, subtitle
/// 14 `tinta2`.
class _Judul extends StatelessWidget {
  const _Judul();

  @override
  Widget build(BuildContext context) {
    // The 44 target around a 14 × 1.45 line, without growing the line box.
    const lebih = (44 - 14 * 1.45) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const MarginNegatif(
          atas: lebih,
          bawah: lebih,
          child: Tautan(
            ke: 'WebDokumenGereja',
            cara: Cara.naik,
            child: SizedBox(
              height: 44,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: 1,
                child: TautanTeks('Dokumen gereja', ukuran: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: const Text(
            'Alur · Menerbitkan dokumen',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          'Dari mengisi sampai terbit, lalu ralat sebagai revisi',
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ],
    );
  }
}
