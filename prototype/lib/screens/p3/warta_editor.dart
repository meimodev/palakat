import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../mock/mock.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

/// The `keadaan` options of WartaEditor and WebWartaEditor (board `O`).
const opsiWarta = [
  'Draf',
  'Sudah diperiksa',
  'Disetujui',
  'Diterbitkan',
  'Hanya Pengumuman yang aktif',
];

/// Board state `{ k: null }` shared by the phone and web editor: the shown
/// state is `k ?? tweak`, and a tweak change resets `k` (spec intro).
mixin KeadaanWarta<T extends StatefulWidget> on State<T> {
  String? _k;
  Object? _tweakLalu;
  final kunciIsi = GlobalKey();

  /// Index of the shown state (unknown values fall back to the first).
  int ki(String stem) {
    final t = context.tweak<String>(stem, 'keadaan');
    if (t != _tweakLalu) {
      _tweakLalu = t;
      _k = null;
    }
    return math.max(0, opsiWarta.indexOf(_k ?? t));
  }

  /// `go0`…`go3`: set `k`; the view jumps to the top (CONVENTIONS).
  void pilih(int i) {
    setState(() => _k = opsiWarta[i]);
    final ctx = kunciIsi.currentContext;
    if (ctx != null) Scrollable.maybeOf(ctx)?.position.jumpTo(0);
  }
}

class WartaEditorScreen extends StatefulWidget {
  const WartaEditorScreen({super.key});

  @override
  State<WartaEditorScreen> createState() => _WartaEditorScreenState();
}

class _WartaEditorScreenState extends State<WartaEditorScreen>
    with KeadaanWarta {
  @override
  Widget build(BuildContext context) {
    final i = ki('WartaEditor');
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Warta Jemaat · edisi 22/11/2026',
            anakJudul: 'Disusun dari data yang sudah ada; tidak diketik ulang',
            kembaliKe: 'WartaArsip',
            labelKembali: 'Kembali ke Warta Jemaat',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: IsiWartaEditor(
                key: kunciIsi,
                ki: i,
                pilih: pilih,
                lihatPdf: const Tombol(
                  'Lihat PDF',
                  onPressed: null,
                  ke: 'A4Warta',
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                ),
                buatRalat: const Tombol(
                  'Buat ralat',
                  onPressed: null,
                  ke: 'WartaArsip',
                  cara: Cara.naik,
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                ),
                tampilkanNama: const Tautan(
                  ke: 'BukaNama',
                  child: TautanTampilkanNama(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The text link "Tampilkan nama (pengecualian)": 14/700 `laut`, min height
/// 44, stretched to the card width. The screen wraps it in its [Tautan].
class TautanTampilkanNama extends StatelessWidget {
  const TautanTampilkanNama({super.key});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 44),
    alignment: Alignment.centerLeft,
    child: const TautanTeks(
      'Tampilkan nama (pengecualian)',
      berat: FontWeight.w700,
      ukuran: 14,
    ),
  );
}

/// The five state views of the editor (WartaEditor scroll column, the left
/// column of WebWartaEditor). Sizes not set here inherit the body size (16
/// phone, 15 web). Each screen passes its own link controls.
class IsiWartaEditor extends StatelessWidget {
  const IsiWartaEditor({
    super.key,
    required this.ki,
    required this.pilih,
    required this.lihatPdf,
    required this.buatRalat,
    required this.tampilkanNama,
  });

  final int ki;
  final ValueChanged<int> pilih;

  final Widget lihatPdf;
  final Widget buatRalat;
  final Widget tampilkanNama;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    final sedang = TextStyle(fontSize: 14, color: c.tinta2);

    Widget edisi(String label, BentukLencana bentuk) => Row(
      children: [
        const Expanded(
          child: Text(
            'Edisi 22/11/2026',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 16),
        LencanaStatus(label, bentuk: bentuk),
      ],
    );

    Widget kartu(String judul, String sumber, List<Widget> isi) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(sumber, style: kecil),
            ],
          ),
          for (final w in isi) ...[const SizedBox(height: 6), w],
        ],
      ),
    );

    Widget tebal(String awal, String kuat, [String akhir = '']) => Text.rich(
      TextSpan(
        style: sedang,
        children: [
          TextSpan(text: awal),
          TextSpan(
            text: kuat,
            style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
          ),
          TextSpan(text: akhir),
        ],
      ),
    );

    Widget nilai(String label, String jumlah) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: sedang)),
        const SizedBox(width: 16),
        Text(
          jumlah,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 14,
            fontFamily: PalakatText.mono,
            fontWeight: FontWeight.w600,
            color: c.tinta,
          ),
        ),
      ],
    );

    final pengumuman = kartu('Pengumuman', 'dari Pengumuman', [
      Text(warta22November.pengumuman, style: sedang),
    ]);
    final semuaKartu = [
      pengumuman,
      kartu('Ibadah minggu ini', 'dari Ibadah dan kegiatan', [
        Text('Minggu 22/11/2026: ${warta22November.ibadah}', style: sedang),
      ]),
      kartu('Jumlah kehadiran', 'hanya yang Ditetapkan', [
        Text('Minggu 15/11/2026: ${warta22November.kehadiran}', style: sedang),
        Text('Jumlah saja. Tidak ada nama.', style: kecil),
      ]),
      kartu('Peristiwa jemaat', 'nama mengikuti Tampilan nama', [
        tebal('Syukur HUT pernikahan: ', 'Keluarga Wenas-Lasut — Kolom 7'),
        tebal('Sampul syukur: ', 'Tanpa nama', ', Kolom 4'),
        tampilkanNama,
      ]),
      kartu('Ringkasan keuangan', 'dari bulan yang Sudah ditutup', [
        nilai('Pendapatan Oktober 2026', 'Rp14.820.000'),
        nilai('Belanja Oktober 2026', 'Rp11.455.000'),
        Text(
          'Dari laporan resmi Oktober 2026, ditutup 16/11/2026. Bulan yang '
          'belum ditutup tidak dapat dimasukkan.',
          style: kecil,
        ),
      ]),
    ];

    // Board flex row (wrap, gap 8, align stretch). `<button>`s are
    // border-box (basis 150, max 340); the `<a>` buttons are content-box, so
    // their outer basis is 185, max 375 and min height 51.
    Widget tombol(List<(Widget, bool)> anak) => LayoutBuilder(
      builder: (context, k) {
        final lentur = [
          for (final (w, a) in anak)
            a
                ? Lentur(
                    dasar: 185,
                    maks: 375,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 51),
                      child: w,
                    ),
                  )
                : Lentur(dasar: 150, maks: 340, child: w),
        ];
        final baris = <Widget>[];
        var i = 0;
        for (final b in BarisLentur.lebar(lentur, 8, k.maxWidth)) {
          if (baris.isNotEmpty) baris.add(const SizedBox(height: 8));
          final isi = <Widget>[];
          for (final w in b) {
            if (isi.isNotEmpty) isi.add(const SizedBox(width: 8));
            isi.add(SizedBox(width: w, child: lentur[i++].child));
          }
          baris.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: isi,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: baris,
        );
      },
    );
    Widget aksi(
      String label,
      int ke, {
      JenisTombol jenis = JenisTombol.tinta,
    }) => Tombol(label, onPressed: () => pilih(ke), jenis: jenis);
    final keDraf = aksi('Kembali ke Draf', 0, jenis: JenisTombol.teks);

    final anak = switch (ki) {
      1 => [
        edisi('Sudah diperiksa', BentukLencana.lautGaris),
        ...semuaKartu,
        Text('Diperiksa oleh ${warta22November.diperiksa}.', style: kecil),
        tombol([
          (aksi('Setujui untuk diterbitkan', 2), false),
          (keDraf, false),
        ]),
      ],
      2 => [
        edisi('Disetujui', BentukLencana.laut),
        Text(
          'Disetujui oleh Olvie Pangemanan, ${warta22November.disetujui}.',
          style: sedang,
        ),
        Text(
          'Sekretaris Jemaat menjalankan setiap langkah sendiri; tiap langkah '
          'tetap dicatat.',
          style: kecil,
        ),
        tombol([
          (aksi('Terbitkan', 3, jenis: JenisTombol.utama), false),
          (keDraf, false),
        ]),
      ],
      3 => [
        edisi('Diterbitkan', BentukLencana.tinta),
        Text(
          'Diterbitkan ${warta22November.diterbitkan} untuk semua anggota. '
          'Edisi ini tidak berubah lagi; ralat menjadi revisi yang tertaut.',
          style: sedang,
        ),
        tombol([(lihatPdf, true), (buatRalat, true)]),
      ],
      4 => [
        edisi('Draf', BentukLencana.draf),
        pengumuman,
        Text(
          'Bagian dari modul yang tidak aktif tidak tampil dan tidak '
          'meninggalkan tempat kosong.',
          style: kecil,
        ),
        tombol([(aksi('Tandai sudah diperiksa', 1), false)]),
      ],
      _ => [
        edisi('Draf', BentukLencana.draf),
        ...semuaKartu,
        tombol([(aksi('Tandai sudah diperiksa', 1), false), (lihatPdf, true)]),
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var j = 0; j < anak.length; j++) ...[
          if (j > 0) const SizedBox(height: 16),
          anak[j],
        ],
      ],
    );
  }
}
