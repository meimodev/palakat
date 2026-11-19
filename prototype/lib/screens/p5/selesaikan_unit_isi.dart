import 'package:flutter/widgets.dart';

import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

/// The five views of SelesaikanUnit and WebSelesaikanUnit (spec 21): the
/// board's `O` list, in tweak order.
const opsiSelesaikan = [
  'Hambatan',
  'Mengisi alasan',
  'Alasan belum diisi',
  'Diselesaikan',
  'Ada selisih',
];

const _alasan =
    'Bendahara Kolom 7 sedang di luar kota; nota baru diterima November.';

/// The board state `{ k: null }`; the view is `k ?? keadaan`. A tweak change
/// in the Keadaan panel resets `k`; every view change jumps to the top.
mixin KeadaanSelesaikan<T extends StatefulWidget> on State<T> {
  String get stem;

  String? _k;
  Object? _tweak;

  /// Sits inside the scrolling body, to find its Scrollable.
  final kunciIsi = GlobalKey();
  final alasan = TextEditingController(text: _alasan);
  final kosong = TextEditingController();

  int get ki => switch (opsiSelesaikan.indexOf(
    _k ?? _tweak as String? ?? opsiSelesaikan.first,
  )) {
    < 0 => 0,
    final i => i,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = context.tweak<String>(stem, 'keadaan');
    if (t == _tweak) return;
    if (_tweak != null) {
      _k = null;
      _keAtas();
    }
    _tweak = t;
  }

  /// The board's `go<i>`.
  void pergi(int i) {
    setState(() => _k = opsiSelesaikan[i]);
    _keAtas();
  }

  void _keAtas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final c = kunciIsi.currentContext;
    if (c != null) Scrollable.maybeOf(c)?.position.jumpTo(0);
  });

  @override
  void dispose() {
    alasan.dispose();
    kosong.dispose();
    super.dispose();
  }
}

/// The body blocks of the current view (gap 16 between them, set by the
/// caller). [web] puts "Mengisi alasan" in the two-column row.
List<Widget> blokSelesaikan(
  BuildContext context,
  KeadaanSelesaikan s, {
  required bool web,
}) {
  final c = context.warna;
  Text kecil(String t) =>
      Text(t, style: TextStyle(fontSize: 13, color: c.tinta3));
  const draf = LencanaStatus('Draf', bentuk: BentukLencana.draf);
  const dikerjakan = LencanaStatus(
    'Sedang dikerjakan',
    bentuk: BentukLencana.garis,
  );
  const rekon = 'Rekonsiliasi Kas Kolom 7 · Oktober 2026';
  Widget kedua(String t) => Tombol(
    t,
    onPressed: () => s.pergi(1),
    jenis: JenisTombol.kedua,
    ukuran: UkuranTombol.sedang,
  );
  final kembali = Tombol(
    'Kembali',
    onPressed: () => s.pergi(0),
    jenis: JenisTombol.teks,
  );
  Widget isian(TextEditingController t) => IsianAlur(
    label: 'Alasan · wajib',
    controller: t,
    baris: 3,
    hanyaBaca: true,
  );

  switch (s.ki) {
    case 0:
      return [
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Tutup buku Oktober 2026 terhalang 2 hal dari Kolom 7.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text:
                      'Bendahara Jemaat dapat menyelesaikannya dengan alasan; '
                      'Bendahara Kolom 7 diberi tahu.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        _KartuUnit(
          judul: 'Draf · Konsumsi ibadah Kolom',
          lencana: draf,
          anak: [
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'Kolom 7 · bertanggal 28/10/2026 · '),
                  TextSpan(
                    text: '−Rp150.000',
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            kecil(
              'Dicatat Deasy Tumbelaka, Bendahara Kolom 7. Menghalangi tutup '
              'buku Oktober 2026.',
            ),
            BarisTombol(anak: [kedua('Pindah tanggal'), kedua('Batalkan')]),
          ],
        ),
        _KartuUnit(
          judul: rekon,
          lencana: dikerjakan,
          anak: [
            const _Info('Saldo buku', 'Rp920.000'),
            const _Info(
              'Hasil hitung kas (dicatat unit 31/10/2026)',
              'Rp920.000',
            ),
            kecil('Bendahara Kolom 7 belum memastikan.'),
            BarisTombol(anak: [kedua('Pastikan dari hitung kas unit')]),
          ],
        ),
      ];
    case 1:
      final kartu = _KartuUnit(
        judul: 'Pindah tanggal · Konsumsi ibadah Kolom',
        lencana: draf,
        anak: [
          const _Info('Tanggal transaksi baru', '02/11/2026', mono: false),
          kecil(
            'Hanya bulan yang Belum ditutup. Draf tetap Draf; tidak ada yang '
            'dibukukan.',
          ),
        ],
      );
      final tombol = BarisTombol(
        anak: [
          Tombol(
            'Pindah tanggal',
            onPressed: () => s.pergi(3),
            jenis: JenisTombol.tinta,
          ),
          kembali,
        ],
      );
      if (!web) return [kartu, isian(s.alasan), tombol];
      return [
        BarisLentur(
          jarak: 28,
          jarakBaris: 20,
          anak: [
            Lentur(dasar: 420, tumbuh: 1.3, child: kartu),
            Lentur(
              dasar: 340,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [isian(s.alasan), const SizedBox(height: 12), tombol],
              ),
            ),
          ],
        ),
      ];
    case 2:
      return [
        isian(s.kosong),
        BarisTombol(
          anak: [
            // HTML `disabled`: pressable no-op, reason in the line below.
            Tombol(
              'Pindah tanggal',
              onPressed: null,
              jenis: JenisTombol.tinta,
              nonaktif: true,
              warnaTeks: c.tinta2,
            ),
            kembali,
          ],
        ),
        kecil('Tidak dapat dilakukan: alasan belum diisi.'),
      ];
    case 3:
      return [
        _KartuUnit(
          judul: 'Konsumsi ibadah Kolom',
          lencana: draf,
          anak: [
            Text(
              'Dipindah ke 02/11/2026',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            kecil(
              'Diselesaikan oleh Bendahara Jemaat (alasan: Bendahara Kolom 7 '
              'sedang di luar kota; nota baru diterima November) · Meiske '
              'Lumentut, 16/11/2026 10.40',
            ),
          ],
        ),
        _KartuUnit(
          judul: rekon,
          lencana: const LencanaStatus(
            'Sudah dipastikan',
            bentuk: BentukLencana.laut,
          ),
          anak: [
            kecil(
              'Dipastikan dari hitung kas yang dicatat unit. Diselesaikan oleh '
              'Bendahara Jemaat (alasan: sama) · 16/11/2026 10.42',
            ),
          ],
        ),
        kecil(
          'Pemberitahuan terkirim ke Deasy Tumbelaka. Keduanya tampil di '
          'konfirmasi tutup buku di bawah pengecualian, beserta alasannya.',
        ),
      ];
    default:
      return [
        _KartuUnit(
          judul: rekon,
          lencana: dikerjakan,
          anak: [
            const _Info('Saldo buku', 'Rp920.000'),
            const _Info('Hasil hitung kas', 'Rp870.000'),
            _Info(
              'Selisih belum dijelaskan',
              'Rp50.000',
              berat: FontWeight.w600,
              warna: c.bata,
            ),
          ],
        ),
        const Penolakan(
          tindakan: 'Pastikan rekonsiliasi',
          sebab: 'selisih belum dijelaskan Rp50.000.',
          jalan: [],
        ),
        kecil(
          'Menyelesaikan untuk unit tidak pernah menyembunyikan selisih. '
          'Selisih tetap menjadi Hambatan sampai dijelaskan.',
        ),
      ];
  }
}

/// The board's card: `permukaan`, 1 `garis`, radius 14, padding 14 16,
/// column gap 6, head row title 700 + badge.
class _KartuUnit extends StatelessWidget {
  const _KartuUnit({
    required this.judul,
    required this.lencana,
    required this.anak,
  });

  final String judul;
  final Widget lencana;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaKartu(judul: judul, ujung: lencana),
        for (final a in anak) ...[const SizedBox(height: 6), a],
      ],
    ),
  );
}

/// Info row: 14, label `tinta2` (wraps), value right-aligned; amounts mono
/// 500 inside the 600 value. Unlike `BarisInfo` the label may wrap.
class _Info extends StatelessWidget {
  const _Info(
    this.label,
    this.nilai, {
    this.mono = true,
    this.berat,
    this.warna,
  });

  final String label;
  final String nilai;
  final bool mono;
  final FontWeight? berat;
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label, style: TextStyle(color: c.tinta2)),
          ),
          const SizedBox(width: 16),
          Text(
            nilai,
            textAlign: TextAlign.right,
            // The CSS line box keeps the parent's sans strut around the
            // mono span, which makes these rows a little taller.
            strutStyle: mono
                ? StrutStyle(
                    fontFamily: PalakatText.sans,
                    fontSize: 14,
                    height: DefaultTextStyle.of(context).style.height,
                  )
                : null,
            style: TextStyle(
              color: warna ?? c.tinta,
              fontFamily: mono ? PalakatText.mono : null,
              fontWeight: berat ?? (mono ? FontWeight.w500 : FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
