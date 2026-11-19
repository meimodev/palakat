import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// The `keadaan` options of TerbitDokumen and WebTerbitDokumen, in order.
const pilihanTerbitDokumen = [
  'Mengisi',
  'Sedang diunggah',
  'Gagal diunggah',
  'Diterbitkan',
  'Ralat sebagai revisi',
];

/// Board state `{ k: null }` (view = `k ?? keadaan`), shared by both boards:
/// a tweak change resets `k`; every view change jumps the scroll to the top.
mixin KeadaanTerbitDokumen<T extends StatefulWidget> on State<T> {
  String get stemTerbit;
  final gulir = ScrollController();
  int? _k;
  String? _tweak;

  /// Index of the view shown now (an unknown tweak value falls back to 0).
  int tampilan(BuildContext context) {
    final t = context.tweak<String>(stemTerbit, 'keadaan');
    if (t != _tweak) {
      if (_tweak != null) _keAtas();
      _tweak = t;
      _k = null;
    }
    return _k ?? pilihanTerbitDokumen.indexOf(t).clamp(0, 4);
  }

  void ke(int i) {
    setState(() => _k = i);
    _keAtas();
  }

  void _keAtas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (gulir.hasClients) gulir.jumpTo(0);
  });

  @override
  void dispose() {
    gulir.dispose();
    super.dispose();
  }
}

class TerbitDokumenScreen extends StatefulWidget {
  const TerbitDokumenScreen({super.key});

  @override
  State<TerbitDokumenScreen> createState() => _TerbitDokumenScreenState();
}

class _TerbitDokumenScreenState extends State<TerbitDokumenScreen>
    with KeadaanTerbitDokumen {
  @override
  String get stemTerbit => 'TerbitDokumen';

  @override
  Widget build(BuildContext context) {
    final ki = tampilan(context);
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Terbitkan dokumen',
              anakJudul: 'Unggah salinan bertanda tangan, pilih untuk siapa',
              kembaliKe: 'DokumenGereja',
              labelKembali: 'Kembali ke Dokumen gereja',
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: gulir,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: IsiTerbitDokumen(ki: ki, ke: ke, induk: 'DokumenGereja'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The five views of the form column (`sc-if k0…k4`), column gap 16. Sizes
/// not set by the board (card titles, buttons) inherit 16 phone / 15 web.
class IsiTerbitDokumen extends StatelessWidget {
  const IsiTerbitDokumen({
    super.key,
    required this.ki,
    required this.ke,
    required this.induk,
  });

  final int ki;
  final ValueChanged<int> ke;

  /// Up target of "Lihat di Dokumen gereja" and "Terbitkan revisi 2".
  final String induk;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    final anak = switch (ki) {
      0 => [
        const _KartuIsian(),
        Kartu(
          status: GarisStatus.draf,
          child: _kolom(6, [
            const KepalaKartu(
              judul: 'Salinan bertanda tangan',
              ujung: LencanaStatus(
                'Wajib, belum ada',
                bentuk: BentukLencana.bata,
              ),
            ),
            Text(
              'Tanda tangan ada di dokumennya. Tidak ada persetujuan di aplikasi untuk dokumen gereja.',
              style: kecil,
            ),
            BarisTombol(
              anak: [
                Tombol(
                  'Pilih file',
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                  onPressed: () => ke(1),
                ),
              ],
            ),
          ]),
        ),
        // Never attached in this view: drawn unmet, a press changes nothing.
        TombolBersyarat(
          label: 'Terbitkan',
          tindakan: 'Terbitkan',
          alasan: 'salinan bertanda tangan belum dilampirkan.',
          onPressed: () {},
          sudahMulai: false,
          baris: const [],
        ),
        Text(
          'Tidak dapat dilakukan: salinan bertanda tangan belum dilampirkan.',
          style: kecil,
        ),
      ],
      1 => [
        const _KartuIsian(),
        Kartu(
          child: _kolom(6, [
            const KepalaKartu(
              judul: 'surat-edaran-natal-2026.pdf',
              ujung: LencanaStatus(
                'Sedang diunggah…',
                bentuk: BentukLencana.garis,
              ),
            ),
            Container(
              height: 8,
              decoration: ShapeDecoration(
                shape: GarisBorder.putus(c.putus, radius: 4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.5),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: .62,
                  child: ColoredBox(color: c.laut),
                ),
              ),
            ),
            Text('Belum terlampir sampai unggahan selesai.', style: kecil),
          ]),
        ),
      ],
      2 => [
        const _KartuIsian(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: ShapeDecoration(
            color: c.bataLembut,
            shape: GarisBorder.penuh(c.bata, tebal: 1, radius: 12),
          ),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Gagal diunggah.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' Isian Anda masih ada di layar ini; file belum terlampir.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Coba lagi',
              jenis: JenisTombol.tinta,
              onPressed: () => ke(1),
            ),
          ],
        ),
      ],
      3 => [
        Kartu(
          child: _kolom(6, [
            const KepalaKartu(
              judul: 'Surat edaran jadwal ibadah Natal 2026',
              ujung: LencanaStatus('Diterbitkan', bentuk: BentukLencana.tinta),
            ),
            Text(
              'Ditujukan untuk: Semua anggota · 12/11/2026',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Text(
              'Diterbitkan oleh Olvie Pangemanan, 12/11/2026 16.40. Anggota yang dituju menerima pemberitahuan.',
              style: kecil,
            ),
          ]),
        ),
        _BarisTautan(
          garis: 3,
          anak: [
            // Content-box `<a>`: min-height 48 plus its 1.5 line top and bottom.
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 51),
              child: Tombol(
                'Lihat di Dokumen gereja',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                onPressed: null,
                ke: induk,
                cara: Cara.naik,
              ),
            ),
            Tombol(
              'Terbitkan revisi baru',
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.sedang,
              onPressed: () => ke(4),
            ),
          ],
        ),
      ],
      _ => [
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Ralat menjadi Revisi 2.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'Revisi 1 tetap tampil sebagai “Digantikan oleh revisi 2”.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const _KartuIsian(),
        const _Isian(
          'Yang diralat · wajib',
          'Jam ibadah malam Natal: 19.00, bukan 18.00.',
          baris: 3,
        ),
        _BarisTautan(
          anak: [
            Tombol(
              'Terbitkan revisi 2',
              jenis: JenisTombol.tinta,
              onPressed: null,
              ke: induk,
              cara: Cara.naik,
            ),
            Tombol(
              'Batalkan',
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.sedang,
              onPressed: () => ke(3),
            ),
          ],
        ),
      ],
    };
    return _kolom(16, anak);
  }
}

/// A K9 button row whose first button is an `<a>`: links are content-box,
/// so its basis and max-width carry the 0 16 padding and its line [garis]
/// (182 / 372 plus the line), where a `<button>` is border-box (150 / 340).
/// Items on one line stretch to the tallest.
class _BarisTautan extends StatelessWidget {
  const _BarisTautan({required this.anak, this.garis = 0});

  final List<Widget> anak;

  /// Both widths of the link's line (3 for the 1.5 outline, 0 for ink).
  final double garis;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, ruang) {
      final lebar = BarisLentur.lebar(
        [
          for (final (i, a) in anak.indexed)
            Lentur(
              dasar: i == 0 ? 182 + garis : 150,
              maks: i == 0 ? 372 + garis : 340,
              child: a,
            ),
        ],
        8,
        ruang.maxWidth,
      );
      var i = 0;
      return _kolom(8, [
        for (final b in lebar)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (k, w) in b.indexed) ...[
                  if (k > 0) const SizedBox(width: 8),
                  SizedBox(width: w, child: anak[i++]),
                ],
              ],
            ),
          ),
      ], rata: CrossAxisAlignment.start);
    },
  );
}

Widget _kolom(
  double jarak,
  List<Widget> anak, {
  CrossAxisAlignment rata = CrossAxisAlignment.stretch,
}) => Column(
  crossAxisAlignment: rata,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (var i = 0; i < anak.length; i++) ...[
      if (i > 0) SizedBox(height: jarak),
      anak[i],
    ],
  ],
);

/// Read-only field: label 14 `tinta2`, gap 6; the value inherits the label's
/// style (`input{font:inherit;color:inherit}`).
class _Isian extends StatelessWidget {
  const _Isian(this.label, this.nilai, {this.baris = 1});

  final String label, nilai;
  final int baris;

  @override
  Widget build(BuildContext context) => IsianTeks(
    label: label,
    nilaiAwal: nilai,
    jarakLabel: 6,
    gaya: TextStyle(fontSize: 14, color: context.warna.tinta2),
    baris: baris,
    hanyaBaca: true,
  );
}

/// The document form card (Mengisi, Sedang diunggah, Gagal diunggah, Ralat).
class _KartuIsian extends StatelessWidget {
  const _KartuIsian();

  @override
  Widget build(BuildContext context) => Kartu(
    child: _kolom(12, [
      const _Isian('Jenis dokumen', 'Keputusan dan surat edaran'),
      const _Isian('Judul', 'Surat edaran jadwal ibadah Natal 2026'),
      KisiOtomatis(
        minLebar: 300,
        jarak: 16,
        anak: [
          const _Isian('Tanggal dokumen', '12/11/2026'),
          _kolom(6, [
            const _Isian('Ditujukan untuk', 'Semua anggota'),
            Text(
              'Semua anggota · Pelayan dan pengurus · satu Kolom, BIPRA atau Komisi',
              style: TextStyle(fontSize: 13, color: context.warna.tinta3),
            ),
          ]),
        ],
      ),
    ]),
  );
}
