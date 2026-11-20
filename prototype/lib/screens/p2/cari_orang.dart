import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// One search result of the board's `H` table: name, context line, badge
/// (empty = none) and its shape, phone target.
typedef HasilCari = ({String j, String s, String l, BentukLencana b, Layar ke});

/// The Operator's five results, in board order. Two "Novita Wenas" rows are
/// different records: key by index.
const List<HasilCari> hasilCariOrang = [
  (
    j: 'Novita Wenas',
    s: 'Data jemaat · Keluarga Wenas-Lasut · Kolom 7',
    l: 'Aktif',
    b: BentukLencana.laut,
    ke: Layar.dataAnggota,
  ),
  (
    j: 'Keluarga Wenas-Lasut',
    s: 'Data jemaat · 4 orang · Kolom 7',
    l: '',
    b: BentukLencana.garis,
    ke: Layar.dataAnggota,
  ),
  (
    j: 'Ferry Wenas',
    s: 'Data jemaat · Kolom 2',
    l: 'Belum dikonfirmasi',
    b: BentukLencana.draf,
    ke: Layar.konfirmasiKeluarga,
  ),
  (
    j: 'Novita Wenas',
    s: 'Dokumen gereja · Surat keterangan 15/11/2026',
    l: 'Diterbitkan',
    b: BentukLencana.tinta,
    ke: Layar.surat,
  ),
  (
    j: 'Kel. Wenas-Lasut',
    s: 'Keuangan · Sampul syukur 08/11/2026',
    l: 'Dibukukan',
    b: BentukLencana.tinta,
    ke: Layar.keuangan,
  ),
];

/// Tweak `keadaan` → 0 Dilihat Operator, 1 Dilihat Penatua Kolom 7, 2 Tidak
/// ada hasil. Rows shown: 5, 2, 0.
int indeksCariOrang(String keadaan) => const [
  'Dilihat Operator',
  'Dilihat Penatua Kolom 7',
  'Tidak ada hasil',
].indexOf(keadaan).clamp(0, 2);

int jumlahCariOrang(int ki) => const [5, 2, 0][ki];

/// Read-only search field, label wrapping the input (gap 6); the value
/// inherits the label's 14 `tinta2`.
class IsianCariOrang extends StatelessWidget {
  const IsianCariOrang(this.q, {super.key});
  final String q;

  @override
  Widget build(BuildContext context) => IsianTeks(
    key: ValueKey(q),
    label: 'Cari nama, keluarga atau Kolom',
    nilaiAwal: q,
    hanyaBaca: true,
    jarakLabel: 6,
    gaya: TextStyle(fontSize: 14, color: context.warna.tinta2),
  );
}

/// "Tidak ada hasil" box: draf line, radius 14, padding 14 16, gap 6. The
/// title inherits the board's body size (16 phone, 15 web).
class KosongCariOrang extends StatelessWidget {
  const KosongCariOrang({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(c.putus, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tidak ada hasil untuk “Rumengan”',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Periksa ejaan, atau cari dengan nama keluarga.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ],
      ),
    );
  }
}

/// The recovery text link: as wide as its text, min height 44, 14/700.
class TautanPulihkan extends StatelessWidget {
  const TautanPulihkan({super.key, required this.tautan});

  /// `Tautan(ke: …)` around [isi].
  final Widget Function(Widget isi) tautan;

  static const isi = SizedBox(
    height: 44,
    child: Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: TautanTeks(
        'Orangnya kehilangan nomor ponsel? Pulihkan akun',
        berat: FontWeight.w700,
        ukuran: 14,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) =>
      Align(alignment: Alignment.centerLeft, child: tautan(isi));
}

class CatatanCariOrang extends StatelessWidget {
  const CatatanCariOrang({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'Kecocokan nama tidak pernah membuka data yang tidak boleh Anda lihat, '
    'dan jumlah hasil tidak menyebut data di luar jangkauan Anda.',
    style: TextStyle(fontSize: 13, color: context.warna.tinta3),
  );
}

class CariOrangScreen extends StatelessWidget {
  const CariOrangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ki = indeksCariOrang(belumDipindah<String>('Dilihat Operator'));
    final hasil = hasilCariOrang.take(jumlahCariOrang(ki)).toList();

    final anak = <Widget>[
      IsianCariOrang(ki == 2 ? 'Rumengan' : 'Wenas'),
      if (ki != 2) ...[
        Text(
          '${hasil.length} hasil untuk “Wenas”',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        for (final r in hasil) _Baris(r),
      ],
      if (ki == 0)
        TautanPulihkan(
          tautan: (isi) => Tautan(ke: Layar.cariOrang, child: isi),
        ),
      if (ki == 2) const KosongCariOrang(),
      const CatatanCariOrang(),
    ];

    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Cari orang',
            anakJudul:
                'Hasil hanya dari modul aktif dan dari yang boleh Anda lihat',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < anak.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    anak[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A result card, one link: `permukaan`, 1 px `garis`, radius 14, padding
/// 12 16, content min height 44, row gap 12.
class _Baris extends StatelessWidget {
  const _Baris(this.r);
  final HasilCari r;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: r.ke,
      radius: 14,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44 + 24 + 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          color: c.permukaan,
          shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.j,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(r.s, style: TextStyle(fontSize: 13, color: c.tinta3)),
                ],
              ),
            ),
            if (r.l.isNotEmpty) ...[
              const SizedBox(width: 12),
              LencanaStatus(r.l, bentuk: r.b),
            ],
            const SizedBox(width: 12),
            PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
          ],
        ),
      ),
    );
  }
}
