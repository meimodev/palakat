import 'package:flutter/widgets.dart';

import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../app/belum_dipindah.dart';

/// Shared by PermohonanSurat and WebPermohonanSurat: the five views of the
/// `keadaan` tweak and the cards they draw (17-keadaanumum.md).
const pilihanPermohonan = [
  'Diajukan',
  'Menerbitkan surat',
  'Data jemaat tidak aktif',
  'Diterbitkan',
  'Tidak diterbitkan',
];

/// The board rows: title, caption.
const barisPermohonan = [
  (
    'Surat keterangan · Novita Wenas',
    'Diajukan anggota 14/11/2026 · untuk melamar pekerjaan',
  ),
  ('Atestasi · Keluarga Lasut', 'Dicatat Operator Yanti Sumual 15/11/2026'),
  ('Atestasi · Ferry Wenas', 'Diajukan 13/11/2026'),
];

const keteranganDaftar =
    'Permohonan datang dari anggota, atau dicatat Operator di kantor untuk anggota tanpa ponsel.';

/// Board state `{ k: null }`; the view is `k ?? keadaan`. A tweak change
/// resets `k`; every view change jumps the scroll area to the top.
mixin KeadaanPermohonan<T extends StatefulWidget> on State<T> {
  String get stem;
  final kunciAtas = GlobalKey();
  String? _k, _t;

  String get tampil {
    final v = _k ?? _t ?? pilihanPermohonan.first;
    return pilihanPermohonan.contains(v) ? v : pilihanPermohonan.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = belumDipindah<String>('Diajukan');
    if (t != _t) {
      if (_t != null) _keAtas();
      _t = t;
      _k = null;
    }
  }

  void pilih(String v) {
    if (v == tampil) return;
    setState(() => _k = v);
    _keAtas();
  }

  void _keAtas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = kunciAtas.currentContext;
    if (ctx != null) Scrollable.maybeOf(ctx)?.position.jumpTo(0);
  });
}

/// Column with a fixed gap.
class KolomJarak extends StatelessWidget {
  const KolomJarak({super.key, required this.jarak, required this.anak});
  final double jarak;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) SizedBox(height: jarak),
        anak[i],
      ],
    ],
  );
}

/// Card top row: 700 title, badge right, gap 16.
class _Atas extends StatelessWidget {
  const _Atas(this.judul, this.lencana, this.bentuk);
  final String judul, lencana;
  final BentukLencana bentuk;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 16),
      LencanaStatus(lencana, bentuk: bentuk),
    ],
  );
}

class _Pasangan extends StatelessWidget {
  const _Pasangan(this.label, this.nilai);
  final String label, nilai;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: const TextStyle(fontSize: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.warna.tinta2)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            nilai,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

Widget _teks(BuildContext context, String s, {double ukuran = 13}) => Text(
  s,
  style: TextStyle(
    fontSize: ukuran,
    color: ukuran == 13 ? context.warna.tinta3 : context.warna.tinta2,
  ),
);

/// `flex: 1 1 150px; max-width: 340px` in a wrapping button row.
class TombolBaris extends StatelessWidget {
  const TombolBaris(this.label, {super.key, required this.onPressed})
    : teks = false;
  const TombolBaris.teks(this.label, {super.key, required this.onPressed})
    : teks = true;
  final String label;
  final VoidCallback onPressed;
  final bool teks;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Tombol(
        label,
        onPressed: onPressed,
        jenis: teks ? JenisTombol.teks : JenisTombol.kedua,
        ukuran: UkuranTombol.sedang,
      ),
    ),
  );
}

/// Menerbitkan surat: the request card.
class KartuPermohonan extends StatelessWidget {
  const KartuPermohonan({super.key});

  @override
  Widget build(BuildContext context) => Kartu(
    child: KolomJarak(
      jarak: 6,
      anak: [
        const _Atas(
          'Surat keterangan · Novita Wenas',
          'Diajukan',
          BentukLencana.garis,
        ),
        const _Pasangan('Nama', 'Novita Wenas'),
        const _Pasangan('Keluarga · Kolom', 'Wenas-Lasut · Kolom 7'),
        const _Pasangan('Status', 'Aktif · sidi 2014'),
        _teks(
          context,
          'Diambil dari Data jemaat yang sudah diverifikasi Penatua Kolom 7. Sekretaris membaca, tidak mengubah.',
        ),
      ],
    ),
  );
}

/// Menerbitkan surat: the dashed signed-copy card.
class KartuSalinan extends StatelessWidget {
  const KartuSalinan({super.key, required this.onPilih});
  final VoidCallback onPilih;

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    child: KolomJarak(
      jarak: 6,
      anak: [
        const _Atas(
          'Salinan bertanda tangan',
          'Wajib, belum ada',
          BentukLencana.bata,
        ),
        TombolBaris('Pilih file', onPressed: onPilih),
      ],
    ),
  );
}

/// Data jemaat tidak aktif: banner, read-only form, button.
List<Widget> isiTidakAktif(BuildContext context, VoidCallback onPilih) {
  final c = context.warna;
  Widget isian(String label, String nilai) => IsianTeks(
    label: label,
    nilaiAwal: nilai,
    hanyaBaca: true,
    jarakLabel: 6,
    gaya: TextStyle(fontSize: 14, color: c.tinta2),
  );
  return [
    Kartu(
      status: GarisStatus.draf,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'Modul Data jemaat belum aktif.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: 'Data anggota diketik di sini dan hanya dipakai untuk surat ini.',
              style: TextStyle(color: c.tinta2),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 14),
      ),
    ),
    Kartu(
      child: KolomJarak(
        jarak: 12,
        anak: [
          isian('Nama', 'Novita Wenas'),
          isian('Keluarga · Kolom', 'Wenas-Lasut · Kolom 7'),
          isian('Keperluan', 'Melamar pekerjaan'),
        ],
      ),
    ),
    TombolBaris('Pilih file salinan bertanda tangan', onPressed: onPilih),
  ];
}

/// Diterbitkan: the published letter.
class KartuDiterbitkan extends StatelessWidget {
  const KartuDiterbitkan({super.key, required this.onBuka});
  final VoidCallback onBuka;

  @override
  Widget build(BuildContext context) => Kartu(
    child: KolomJarak(
      jarak: 6,
      anak: [
        const _Atas(
          'Surat keterangan · Novita Wenas',
          'Diterbitkan',
          BentukLencana.tinta,
        ),
        _teks(context, 'No. 027/SKet/XI/2026 · 15/11/2026', ukuran: 14),
        _teks(
          context,
          'Diterbitkan oleh Olvie Pangemanan. Hanya anggota, keluarganya dan pelayan yang menaunginya yang dapat melihat.',
        ),
        TombolBaris('Buka salinan bertanda tangan', onPressed: onBuka),
      ],
    ),
  );
}

/// Tidak diterbitkan: the refusal (the board's Ferry Wenas sample).
class KartuDitolak extends StatelessWidget {
  const KartuDitolak({super.key});

  @override
  Widget build(BuildContext context) => Kartu(
    child: KolomJarak(
      jarak: 6,
      anak: [
        const _Atas(
          'Atestasi · Ferry Wenas',
          'Tidak diterbitkan',
          BentukLencana.bata,
        ),
        _teks(
          context,
          'Alasan: anggota belum dikonfirmasi; data masih dari buku anggota.',
          ukuran: 14,
        ),
        _teks(
          context,
          'Dicatat oleh Olvie Pangemanan, 16/11/2026. Pemohon menerima pemberitahuan beserta alasannya.',
        ),
      ],
    ),
  );
}

/// The caption under the list.
class KeteranganDaftar extends StatelessWidget {
  const KeteranganDaftar({super.key});

  @override
  Widget build(BuildContext context) => _teks(context, keteranganDaftar);
}
