import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

const _keadaan = ['Ditampung', 'Lolos pengecekan', 'Sudah diimpor'];

/// The board's four rows: name, book text, read as, ket, kind
/// (0 plain, 1 possible duplicate, 2 not imported).
const _baris = [
  (
    'Ferry Wenas',
    'WENAS FERRY, lhr 3-8-71, Kol 7',
    'Ferry Wenas · 03/08/1971 · Kolom 7',
    '',
    0,
  ),
  (
    'Agustina Lasut',
    'LASUT AGUSTINA (istri), 12-12-74',
    'Agustina Lasut · 12/12/1974 · Kolom 7',
    '',
    0,
  ),
  (
    'Novita Wenas',
    'WENAS NOVITA, 14-3-96',
    'Novita Wenas · 14/03/1996 · Kolom 7',
    'Kemungkinan data ganda: sudah ada Novita Wenas, Aktif',
    1,
  ),
  (
    '—',
    'RUMAGIT H., tgl lhr tdk terbaca',
    'Tanggal lahir tidak terbaca',
    'Tidak diimpor: tanggal lahir wajib. Dicatat dengan alasannya.',
    2,
  ),
];

const _status = [
  ('Ditampung', BentukLencana.draf),
  ('Lolos pengecekan', BentukLencana.lautGaris),
  ('Sudah diimpor', BentukLencana.tinta),
];

/// Web · Impor buku anggota (spec 19, WebImporBuku). View = `k ?? keadaan`.
class WebImporBukuScreen extends StatefulWidget {
  const WebImporBukuScreen({super.key});

  @override
  State<WebImporBukuScreen> createState() => _WebImporBukuScreenState();
}

class _WebImporBukuScreenState extends State<WebImporBukuScreen> {
  String? _k;
  int? _kiLama;
  final _isi = GlobalKey();

  void _pilih(String k) => setState(() => _k = k);

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    // Board parity (CONVENTIONS): a panel change does not reset `k`.
    final tweak = belumDipindah<String>('Ditampung');
    final ki = _keadaan.indexOf(_k ?? tweak).clamp(0, 2);
    // Every view change jumps the page to the top (CONVENTIONS).
    if (_kiLama != null && _kiLama != ki) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _isi.currentContext;
        if (ctx != null) Scrollable.maybeOf(ctx)?.position.jumpTo(0);
      });
    }
    _kiLama = ki;

    final redup = TextStyle(fontSize: 13, color: c.tinta3);
    // `flex: 1 1 150px; max-width: 340px` on a border-box `<button>`; the
    // `<a>` links are content-box, so their outer basis and max add 16+16+1.5+1.5.
    Lentur tombol(Widget a) => Lentur(dasar: 150, maks: 340, child: a);
    Lentur tautan(Widget a) => Lentur(dasar: 185, maks: 375, child: a);
    Widget barisTombol(List<Lentur> anak) => BarisLentur(jarak: 8, anak: anak);
    Widget kolom(List<Widget> anak) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          anak[i],
        ],
      ],
    );

    Widget kartu((String, String, String, String, int) r) {
      final (nama, asal, baca, ket, jenis) = r;
      final (st, bentuk) = jenis == 2
          ? ('Tidak diimpor', BentukLencana.bata)
          : jenis == 1 && ki > 0
          ? ('Kemungkinan data ganda', BentukLencana.bata)
          : _status[ki];
      final tampilKet = ki > 0 || jenis == 2 ? ket : '';
      return Kartu(
        status: jenis > 0 ? GarisStatus.draf : GarisStatus.dibukukan,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    nama,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                LencanaStatus(st, bentuk: bentuk),
              ],
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Di buku: '),
                  TextSpan(
                    text: asal,
                    style: const TextStyle(fontFamily: PalakatText.mono),
                  ),
                ],
              ),
              style: redup,
            ),
            const SizedBox(height: 4),
            Text('Dibaca sebagai: $baca', style: const TextStyle(fontSize: 14)),
            // The empty ket div still takes its 4 gap on the board.
            const SizedBox(height: 4),
            if (tampilKet.isNotEmpty) Text(tampilKet, style: redup),
          ],
        ),
      );
    }

    final kiri = kolom([
      const BarisInfo('Sumber', 'Buku anggota Kolom 7 · 2019–2026'),
      BarisInfo(
        'Baris',
        ki == 2
            ? '28 baris · 26 sudah diimpor · 1 kemungkinan ganda · 1 tidak diimpor'
            : '28 baris · belum ada yang diimpor',
      ),
      for (final r in _baris) kartu(r),
    ]);

    final kanan = kolom(switch (ki) {
      0 => [
        barisTombol([
          tombol(
            Tombol(
              'Jalankan pengecekan',
              jenis: JenisTombol.tinta,
              onPressed: () => _pilih(_keadaan[1]),
            ),
          ),
        ]),
        Text('Belum ada yang tersimpan sebagai data jemaat.', style: redup),
        Text(
          'Tanggal lahir, jenis kelamin dan status pernikahan dibaca dari '
          'buku. Yang kosong dilengkapi keluarga saat mengonfirmasi; sampai '
          'itu Kategori BIPRA orangnya belum dihitung.',
          style: redup,
        ),
      ],
      1 => [
        Text(
          'Kemungkinan data ganda ditandai, tidak pernah digabung sendiri.',
          style: redup,
        ),
        barisTombol([
          tombol(
            Tombol(
              'Impor 26 baris',
              jenis: JenisTombol.tinta,
              onPressed: () => _pilih(_keadaan[2]),
            ),
          ),
          // 48 min on the board, stretched to the 52 primary beside it.
          tautan(
            const Tombol(
              'Tinjau kemungkinan data ganda',
              jenis: JenisTombol.kedua,
              onPressed: null,
              ke: Layar.dataGanda,
            ),
          ),
        ]),
      ],
      _ => [
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '26 orang masuk sebagai Belum dikonfirmasi.',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text:
                      'Hanya Penatua Kolom 7 dan Operator yang dapat '
                      'melihatnya. Tidak ada yang tampil di publikasi sampai '
                      'keluarganya mengonfirmasi dan memberi izin.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        // "Lihat konfirmasi keluarga" opens a phone-only screen: left out
        // on the web (README 7.1 rule 4).
      ],
    });

    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 5),
      // CSS splits line-height leading evenly; Flutter's default does not.
      isi: [
        for (final w in [
          Column(
            key: _isi,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The 44 target (child drawn at its top) overhangs the line,
              // which the div's 15 px strut makes 21.75 tall (not 14 × 1.45);
              // the 14 px text sits 1.1 down on that strut's baseline.
              const MarginNegatif(
                bawah: 44 - 21.75,
                child: Tautan(
                  ke: Layar.dataAnggota,
                  cara: Cara.naik,
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.1),
                    child: TautanTeks('Data jemaat', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Impor buku anggota',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              Text(
                'Operator memasukkan buku anggota kertas; belum ada yang '
                'menjadi anggota aktif',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: BarisLentur(
                jarak: 28,
                jarakBaris: 20,
                anak: [
                  Lentur(dasar: 420, tumbuh: 1.3, child: kiri),
                  Lentur(dasar: 340, child: kanan),
                ],
              ),
            ),
          ),
        ])
          DefaultTextStyle.merge(
            style: const TextStyle(
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: w,
          ),
      ],
    );
  }
}
