import 'package:flutter/widgets.dart';

import '../../mock/mock.dart';
import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/bertindak_sebagai.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';

/// Shared by BerandaJabatan and WebBerandaJabatan (spec 14): the `keadaan`
/// state, the two post-choice views and the small parts both boards draw.

/// The board's `O`: the `keadaan` options, in order.
const opsiKeadaan = [
  'Beberapa jabatan',
  'Bendahara Jemaat',
  'Sekretaris Jemaat',
  'Operator',
  'Anggota jemaat',
  'Jabatan dipilih otomatis',
  'Dua jabatan dapat bertindak',
];

const kalimatBeranda =
    'Semua pekerjaan dari semua jabatan Anda ada di sini. Hanya modul yang '
    'aktif yang tampil. Setiap tindakan mencatat jabatan yang dipakai.';

/// The board state `{ k: null }`; view = `k ?? keadaan`. A panel change of
/// `keadaan` resets `k`; every view change jumps the scroll to the top.
mixin KeadaanBeranda<T extends StatefulWidget> on State<T> {
  String get stem;
  final scroll = ScrollController();
  String? _k, _tweakLama;

  /// Option index of the view shown (the board's `ki`).
  int indeks(BuildContext context) {
    final t = context.tweak<String>(stem, 'keadaan');
    if (_tweakLama != null && t != _tweakLama) {
      _k = null;
      _keAtas();
    }
    _tweakLama = t;
    return opsiKeadaan.indexOf(_k ?? t).clamp(0, opsiKeadaan.length - 1);
  }

  /// `go0`.
  void go0() {
    setState(() => _k = opsiKeadaan[0]);
    _keAtas();
  }

  /// Self link (back arrow, breadcrumb, active nav item): what reloading
  /// the board does on the canvas.
  void ulang() {
    setState(() => _k = null);
    _keAtas();
  }

  void _keAtas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (scroll.hasClients) scroll.jumpTo(0);
  });

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }
}

/// Children with a gap between each.
List<Widget> bersela(List<Widget> anak, double jarak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: jarak),
    anak[i],
  ],
];

/// A row's badge (`LS[r[3] || 'garis']`), or null.
Widget? lencanaBaris(ItemKotak r) => r.label == null
    ? null
    : LencanaStatus(r.label!, bentuk: (r.gaya ?? GayaLabel.garis).bentuk);

/// Caption 13 `tinta3`.
class Keterangan extends StatelessWidget {
  const Keterangan(this.teks, {super.key});
  final String teks;

  @override
  Widget build(BuildContext context) =>
      Text(teks, style: TextStyle(fontSize: 13, color: context.warna.tinta3));
}

/// "Jabatan dipilih otomatis" (`k5`): case card, post-used box, caption,
/// buttons. Siblings of the page column.
List<Widget> isiOtomatis(BuildContext context, VoidCallback go0) {
  final c = context.warna;
  return [
    Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaKartu(
            judul: 'Verifikasi data · Peristiwa: Baptisan',
            ujung: LencanaStatus('Diajukan', bentuk: BentukLencana.garis),
          ),
          const SizedBox(height: 6),
          Text(
            'Gabriel Wenas · Keluarga Wenas-Lasut · Kolom 7',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          const SizedBox(height: 6),
          const BarisInfo('Diajukan oleh', 'Novita Wenas, 15/11/2026'),
        ],
      ),
    ),
    const BertindakSebagai.satu(
      jabatan: 'Penatua Kolom 7',
      kalimat:
          'Hanya jabatan ini yang berwenang memverifikasi data Kolom 7. '
          'Jabatan dipilih sendiri oleh aplikasi dan tampil sebelum Anda '
          'menyetujui.',
    ),
    const Keterangan(
      'Tercatat di Riwayat: Pnt. Hendrik Rumagit, Penatua Kolom 7.',
    ),
    BarisTombol(
      anak: [
        Tombol('Verifikasi data', onPressed: go0, jenis: JenisTombol.tinta),
        Tombol('Kembali', onPressed: go0, jenis: JenisTombol.teks),
      ],
    ),
  ];
}

/// "Dua jabatan dapat bertindak" (`k6`): case card, choice box with the two
/// outlined buttons, caption.
List<Widget> isiDuaJabatan(BuildContext context, VoidCallback go0) => [
  Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaKartu(
          judul: 'Setujui jadwal · Ibadah Kolom 7 bersama Komisi Diakonia',
          ujung: LencanaStatus('Draf', bentuk: BentukLencana.draf),
        ),
        const SizedBox(height: 6),
        Text(
          'Kamis, 19/11/2026 19.00 · rumah Kel. Wenas-Lasut',
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ],
    ),
  ),
  BertindakSebagai.pilih(
    jabatan: const ['Penatua Kolom 7', 'Ketua Komisi Diakonia'],
    kalimat:
        'Pilih salah satu. Jabatan yang Anda pilih tercatat di Riwayat dan '
        'tidak dapat diubah setelahnya.',
    onPilih: (_) => go0(),
  ),
  const Keterangan(
    'Aplikasi hanya memilih sendiri bila tepat satu jabatan yang berwenang. '
    'Jabatan Anda yang lain tidak membuka jalan menyetujui atau memverifikasi '
    'pengajuan Anda sendiri.',
  ),
];
