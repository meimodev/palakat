import 'package:flutter/widgets.dart';

import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';

/// Shared by WartaArsip and WebWartaArsip (spec 18: "shared constants").
const opsiWartaArsip = [
  'Arsip edisi',
  'Edisi dengan ralat',
  'Dibaca anggota jemaat',
  'Belum ada edisi',
];

typedef EdisiWarta = ({String j, String s, String l, BentukLencana bentuk});

const List<EdisiWarta> edisiWarta = [
  (
    j: 'Edisi 15/11/2026',
    s: 'Diterbitkan 14/11/2026 17.00',
    l: 'Diterbitkan',
    bentuk: BentukLencana.tinta,
  ),
  (
    j: 'Edisi 08/11/2026',
    s: 'Diterbitkan 07/11/2026 · 1 ralat',
    l: 'Diterbitkan',
    bentuk: BentukLencana.tinta,
  ),
  (
    j: 'Edisi 01/11/2026',
    s: 'Diterbitkan 31/10/2026',
    l: 'Diarsipkan',
    bentuk: BentukLencana.abu,
  ),
  (
    j: 'Edisi 25/10/2026',
    s: 'Diterbitkan 24/10/2026',
    l: 'Diarsipkan',
    bentuk: BentukLencana.abu,
  ),
];

/// The boards' `state = { k: null }`; shown = `k ?? tweak keadaan`. A tweak
/// change resets `k` (spec 18 intro).
mixin KeadaanWartaArsip<T extends StatefulWidget> on State<T> {
  String? _k;
  String? _tweakLama;

  int keadaan(String stem) {
    final t = context.tweak<String>(stem, 'keadaan');
    if (t != _tweakLama) {
      _tweakLama = t;
      _k = null;
    }
    final i = opsiWartaArsip.indexOf(_k ?? t);
    return i < 0 ? 0 : i;
  }

  /// `go1`: "Unduh PDF" sets the state already shown (nothing is downloaded).
  void go1() => setState(() => _k = opsiWartaArsip[1]);
}

/// Button row with one button: `flex: 1 1 150px; max-width: 340px`. The
/// `<a>` buttons are content-box (340 + padding 2 × 16 = 372); a `<button>`
/// is border-box (340).
Widget tombolWarta(Widget tombol, {double maks = 372}) => Align(
  alignment: Alignment.centerLeft,
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maks),
    child: tombol,
  ),
);

/// The row chevron, 18 `tinta3`.
class ChevronWarta extends StatelessWidget {
  const ChevronWarta({super.key});
  @override
  Widget build(BuildContext context) =>
      PalakatIkon(Ikon.lanjut, ukuran: 18, warna: context.warna.tinta3);
}

/// The content column below the list for states k0–k3 (the list itself is
/// [daftar], drawn per form factor).
List<Widget> isiWartaArsip(
  BuildContext context, {
  required int ki,
  required Widget daftar,
  required Widget susun,
  required Widget susunPertama,
  required VoidCallback onUnduh,
}) {
  final c = context.warna;
  Widget kepala(String judul) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 16),
      const LencanaStatus('Diterbitkan', bentuk: BentukLencana.tinta),
    ],
  );
  Widget kolom(List<Widget> anak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) const SizedBox(height: 6),
        anak[i],
      ],
    ],
  );
  final t14 = TextStyle(fontSize: 14, color: c.tinta2);
  final t13 = TextStyle(fontSize: 13, color: c.tinta3);
  return [
    if (ki == 0 || ki == 2) daftar,
    if (ki == 0) susun,
    if (ki == 1) ...[
      Kartu(
        child: kolom([
          kepala('Edisi 08/11/2026'),
          Text('Diterbitkan 07/11/2026 17.00 · tidak diubah', style: t14),
          tombolWarta(
            Tombol(
              'Unduh PDF',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              onPressed: onUnduh,
            ),
            maks: 340,
          ),
        ]),
      ),
      Kartu(
        status: GarisStatus.draf,
        child: kolom([
          kepala('Ralat (revisi edisi 08/11/2026)'),
          Text(
            'Jadwal ibadah Kolom 5 dipindah ke Kamis 12/11/2026.',
            style: t14,
          ),
          Text(
            'Tertaut ke edisi asli, yang tetap tampil apa adanya. '
            'Diterbitkan 09/11/2026 08.30 oleh Olvie Pangemanan.',
            style: t13,
          ),
        ]),
      ),
    ],
    if (ki == 2)
      Text(
        'Anggota membaca edisi yang ditujukan untuknya. Nama tampil sesuai '
        'pilihan tiap anggota saat edisi itu diterbitkan; pindah Kolom atau '
        'mengubah pilihan kemudian tidak mengubah edisi lama.',
        style: t13,
      ),
    if (ki == 3) ...[
      Kartu(
        status: GarisStatus.draf,
        child: kolom([
          const Text(
            'Belum ada edisi yang diterbitkan',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            'Edisi pertama dapat disusun dari pengumuman yang sudah diterbitkan.',
            style: t14,
          ),
        ]),
      ),
      susunPertama,
    ],
  ];
}

/// Children with a fixed vertical gap.
Widget kolomWarta(List<Widget> anak, {double jarak = 16}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (var i = 0; i < anak.length; i++) ...[
      if (i > 0) SizedBox(height: jarak),
      anak[i],
    ],
  ],
);
