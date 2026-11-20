import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import 'pemeriksa_baris.dart';
import '../../app/belum_dipindah.dart';

enum _St { draf, periksa, buku }

typedef _Trx = ({
  String id,
  String tgl,
  String ur,
  int jm,
  String sub,
  String no,
});

const List<_Trx> _daftar = [
  (
    id: 'a',
    tgl: '16/11/2026',
    ur: 'Sewa kursi ibadah padang',
    jm: -900000,
    sub: 'Kas · Belanja 5.05.02.00 Sewa peralatan',
    no: 'BKU-2026-0151',
  ),
  (
    id: 'b',
    tgl: '15/11/2026',
    ur: 'Honor pemusik',
    jm: -650000,
    sub: 'Bank BNI ··4821 · Belanja 5.07.01.00 Honorarium pelayan',
    no: 'BKU-2026-0152',
  ),
  (
    id: 'c',
    tgl: '14/11/2026',
    ur: 'Fotokopi warta jemaat',
    jm: -150000,
    sub: 'Kas · Belanja 5.02.01.00 Alat tulis dan fotokopi',
    no: 'BKU-2026-0153',
  ),
];

/// Web · Wajib pemeriksa kedua: the queue of three transactions; pick one and
/// act on it per role (`masukSebagai`). "Ubah" returns to Draf at once.
class WebPemeriksaScreen extends StatefulWidget {
  const WebPemeriksaScreen({super.key});
  @override
  State<WebPemeriksaScreen> createState() => _WebPemeriksaScreenState();
}

class _WebPemeriksaScreenState extends State<WebPemeriksaScreen> {
  final Map<String, _St> _st = {'a': _St.draf, 'b': _St.draf, 'c': _St.periksa};
  String _pilih = 'a';

  static const _kolom = [140.0, 96.0, -1.0, 110.0, 120.0];

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final bend = belumDipindah<String>('Pemeriksa kedua') == 'Bendahara';
    final cur = _daftar.firstWhere((x) => x.id == _pilih);
    final k = _st[cur.id]!;
    VoidCallback set(_St v) =>
        () => setState(() => _st[_pilih] = v);

    var aksi = <Widget>[];
    var tolak = '', penjelasan = '';
    Widget tombol(
      String n,
      JenisTombol j, {
      VoidCallback? on,
      bool mati = false,
    }) => Tombol(
      n,
      onPressed: on ?? () {},
      jenis: j,
      ukuran: UkuranTombol.ringkas,
      paddingH: 18,
      ukuranTeks: 14,
      lebarPenuh: false,
      nonaktif: mati,
    );
    if (k == _St.draf && bend) {
      aksi = [
        tombol('Tandai sudah diperiksa', JenisTombol.utama, mati: true),
        tombol('Ubah', JenisTombol.kedua), // no handler on the board
      ];
      tolak = 'Anda yang mencatat transaksi ini. Pemeriksa kedua: Pnt. Jefry Wowor.';
      penjelasan =
          'Draf belum masuk saldo dan menjadi hambatan tutup buku bulannya.';
    } else if (k == _St.draf) {
      aksi = [
        tombol(
          'Tandai sudah diperiksa',
          JenisTombol.utama,
          on: set(_St.periksa),
        ),
      ];
      penjelasan = 'Menandai sudah diperiksa bukan persetujuan dan belum memasukkan transaksi ke saldo. Bendahara yang membukukan.';
    } else if (k == _St.periksa && bend) {
      aksi = [
        tombol('Bukukan', JenisTombol.utama, on: set(_St.buku)),
        tombol('Ubah · kembali ke Draf', JenisTombol.kedua, on: set(_St.draf)),
      ];
      penjelasan = 'Mengubah mengembalikan transaksi ke Draf. Tanda sudah diperiksa dan persetujuan yang dicatat hilang dan perlu diberikan lagi.';
    } else if (k == _St.periksa) {
      penjelasan = 'Sudah Anda tandai. Menunggu Bendahara membukukan; tidak ada yang perlu Anda lakukan.';
    } else {
      penjelasan = 'Sudah masuk saldo dan tidak dapat diubah lagi.';
    }

    LencanaStatus lencana(_St s, {bool panjang = false}) {
      final (label, bentuk) = switch (s) {
        _St.draf => ('Draf', BentukLencana.draf),
        _St.periksa => ('Sudah diperiksa', BentukLencana.lautGaris),
        _St.buku => ('Dibukukan', BentukLencana.tinta),
      };
      return LencanaStatus(
        panjang && s != _St.buku ? '$label · belum masuk saldo' : label,
        bentuk: bentuk,
      );
    }

    // grid-template-columns: 140px 96px minmax(0, 1fr) 110px 120px; gap 12.
    Widget kisi(List<Widget> sel) => Row(
      children: [
        for (var i = 0; i < sel.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          if (_kolom[i] < 0)
            Expanded(child: sel[i])
          else
            SizedBox(width: _kolom[i], child: sel[i]),
        ],
      ],
    );

    final tabel = Container(
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: LayoutBuilder(
          builder: (context, ruang) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(700, ruang.maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.tinta2,
                      ),
                      child: kisi(const [
                        Text('Status'),
                        Text('Tanggal'),
                        Text('Uraian'),
                        Text('Dicatat oleh'),
                        Text('Jumlah (Rp)', textAlign: TextAlign.right),
                      ]),
                    ),
                  ),
                  for (final x in _daftar) _baris(context, x, lencana, kisi),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final kartu = Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: k == _St.draf ? null : c.permukaan,
        shape: switch (k) {
          _St.buku => GarisBorder.penuh(c.tinta, radius: 16),
          _St.periksa => GarisBorder.penuh(c.laut, radius: 16),
          _St.draf => GarisBorder.putus(c.putus, radius: 16),
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: k == _St.buku ? 0 : 1,
                child: lencana(k, panjang: true),
              ),
              if (k == _St.buku) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Gerak(
                    Kerangka.muncul,
                    key: ValueKey('cap-${cur.id}'),
                    lama: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: c.laut, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No. Bukti ${cur.no}',
                        style: TextStyle(
                          fontFamily: PalakatText.mono,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.laut,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            rp(cur.jm),
            style: TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 32,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
              color: k == _St.buku ? c.tinta : c.tinta2,
            ),
          ),
          const SizedBox(height: 6),
          Text(cur.ur, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(cur.sub, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
      ),
    );

    final rincian = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const BarisRincian(
            'Dicatat oleh',
            'Meiske L.',
            atas: false,
            vertikal: 10,
          ),
          BarisRincian(
            'Diperiksa oleh',
            k == _St.draf ? 'Belum diperiksa' : 'Pnt. Jefry Wowor',
            warna: k == _St.draf ? c.bata : c.tinta,
            vertikal: 10,
          ),
          const BarisRincian(
            'Dokumen pendukung',
            'Diunggah, belum diverifikasi',
            vertikal: 10,
          ),
        ],
      ),
    );

    final samping = <Widget>[
      kartu,
      rincian,
      if (tolak.isNotEmpty)
        Semantics(
          container: true,
          liveRegion: true,
          child: Text(
            'Tidak dapat dilakukan: $tolak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.bata,
            ),
          ),
        ),
      Wrap(spacing: 8, runSpacing: 8, children: aksi),
      Text(penjelasan, style: TextStyle(fontSize: 13, color: c.tinta3)),
    ];

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: const NavSamping(item: navKeuangan, aktif: 1),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Transaksi '),
                      TextSpan(
                        text: '· menunggu diperiksa',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: c.tinta3,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Masuk sebagai '),
                    TextSpan(
                      text: bend
                          ? 'Meiske L., Bendahara'
                          : 'Pnt. Jefry Wowor, Pemeriksa kedua',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.tinta,
                      ),
                    ),
                    const TextSpan(text: ' · Wajib pemeriksa kedua: hidup'),
                  ],
                ),
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          BarisLentur(
            jarak: 24,
            anak: [
              Lentur(dasar: 520, tumbuh: 999, child: tabel),
              Lentur(
                dasar: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < samping.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      samping[i],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _baris(
    BuildContext context,
    _Trx x,
    LencanaStatus Function(_St, {bool panjang}) lencana,
    Widget Function(List<Widget>) kisi,
  ) {
    final c = context.warna;
    final on = x.id == _pilih;
    final kk = _st[x.id]!;
    return Tekan(
      onTap: () => setState(() => _pilih = x.id),
      dipilih: on,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: on ? c.lautLembut : (kk == _St.draf ? c.kertas : c.permukaan),
          border: Border(top: BorderSide(color: c.garis)),
        ),
        // box-shadow: inset 3px 0 0 laut; drawn over the fill, no layout.
        foregroundDecoration: on
            ? BoxDecoration(
                border: Border(left: BorderSide(color: c.laut, width: 3)),
              )
            : null,
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 14),
          child: kisi([
            Align(alignment: Alignment.centerLeft, child: lencana(kk)),
            Text(x.tgl, style: TextStyle(color: c.tinta2)),
            Text(x.ur, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('Meiske L.', style: TextStyle(color: c.tinta2)),
            Text(
              rp(x.jm),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontWeight: FontWeight.w500,
                color: kk == _St.buku ? c.tinta : c.tinta3,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
