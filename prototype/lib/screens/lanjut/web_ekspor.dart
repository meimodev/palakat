import 'dart:async';

import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// The five contents of the export: name, description, bar duration (ms).
const _isi = [
  ('Buku', 'Semua transaksi, termasuk yang dibalik dan dibatalkan', 1100),
  (
    'Versi',
    'Mata Anggaran 2026.1 dan 2026.2, pengaturan dan aturan per bulan',
    1500,
  ),
  ('Dokumen pendukung', '214 file, masing-masing dengan checksum', 2400),
  ('Laporan', 'Laporan resmi September dan Oktober 2026, PDF dan Excel', 1900),
  ('Daftar isi', 'Apa saja yang ada di ekspor ini, dan apa yang tidak', 2600),
];

enum _St { belum, jalan, selesai }

/// Web · Ekspor data Jemaat (spec 06-bukti.md).
class WebEksporScreen extends StatefulWidget {
  const WebEksporScreen({super.key});

  @override
  State<WebEksporScreen> createState() => _WebEksporScreenState();
}

class _WebEksporScreenState extends State<WebEksporScreen> {
  _St _st = _St.belum;
  bool _diunduh = false;
  Timer? _t;

  void _buat() {
    setState(() => _st = _St.jalan);
    _t?.cancel();
    _t = Timer(
      const Duration(milliseconds: 2800),
      () => setState(() => _st = _St.selesai),
    );
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final s14 = TextStyle(fontSize: 14, color: c.tinta2);

    final kanan = <Widget>[
      if (_st == _St.belum) ...[
        _TombolWeb(
          'Buat ekspor',
          onTap: _buat,
          tinggi: 52,
          isi: c.laut,
          teks: c.diLaut,
          paddingH: 6,
        ),
        Text(
          'Mencakup 15 September 2026 sampai hari ini. Bulan yang belum '
          'ditutup diekspor sebagai keadaan saat ini dan ditandai Belum '
          'ditutup.',
          style: s14,
        ),
      ],
      if (_st == _St.jalan) ...[
        Semantics(
          liveRegion: true,
          child: const Text(
            'Sedang disiapkan…',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          'Anda boleh meninggalkan halaman ini. Ekspor tidak mengubah data '
          'apa pun.',
          style: s14,
        ),
      ],
      if (_st == _St.selesai) ...[
        Gerak(
          Kerangka.muncul,
          lama: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: c.permukaan,
              border: Border.all(color: c.bata, width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ekspor belum lengkap',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  '3 dari 214 dokumen pendukung tidak ikut:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  // Chrome breaks the code after 2026- (390 wide).
                  '2 file Ditahan (alasan keamanan) · BKU-2026-\u200B0117, '
                  'BKU-2026-\u200B0130',
                  style: s14,
                ),
                const SizedBox(height: 6),
                Text('1 file gagal dibaca · BKU-2026-0102', style: s14),
                const SizedBox(height: 10),
                Text(
                  'Daftar isi mencatat ketiganya sebagai tidak disertakan, '
                  'lengkap dengan alasannya.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _TombolWeb(
              _diunduh
                  ? 'Diunduh · ekspor-jemaat-karunia-2026-11-16.zip'
                  : 'Unduh ekspor (belum lengkap)',
              onTap: () => setState(() => _diunduh = true),
              tinggi: 48,
              isi: c.laut,
              teks: c.diLaut,
              paddingH: 20,
              lebarPenuh: false,
            ),
            _TombolWeb(
              'Coba lagi',
              onTap: _buat,
              tinggi: 48,
              isi: c.permukaan,
              teks: c.tinta,
              garis: GarisBorder.penuh(c.tinta, radius: 12),
              paddingH: 20,
              lebarPenuh: false,
            ),
          ],
        ),
      ],
    ];

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 6),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 44 target in the 21.75 px line box of the 15/1.45 parent div.
              MarginNegatif(
                atas: 11.125,
                bawah: 11.125,
                child: Tautan(
                  ke: Layar.pengaturan,
                  cara: Cara.naik,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    child: TautanTeks('Pengaturan', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Ekspor data Jemaat',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Salinan lengkap milik Jemaat: buku, versi pengaturan, '
                'dokumen pendukung, laporan, dan daftar isinya.',
                style: s14,
              ),
            ],
          ),
          KisiOtomatis(
            minLebar: 420,
            jarak: 24,
            anak: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: c.permukaan,
                  border: Border.all(color: c.garis),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < _isi.length; i++) _Butir(i: i, st: _st),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < kanan.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    kanan[i],
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The board's buttons with radius 12 at heights 52 and 48, which
/// [UkuranTombol] does not pair.
class _TombolWeb extends StatelessWidget {
  const _TombolWeb(
    this.label, {
    required this.onTap,
    required this.tinggi,
    required this.isi,
    required this.teks,
    required this.paddingH,
    this.garis,
    this.lebarPenuh = true,
  });

  final String label;
  final VoidCallback onTap;
  final double tinggi, paddingH;
  final Color isi, teks;
  final GarisBorder? garis;
  final bool lebarPenuh;

  @override
  Widget build(BuildContext context) => Tekan(
    onTap: onTap,
    radius: 12,
    child: RupaTombol(
      label: label,
      isi: isi,
      garis: garis,
      warnaTeks: teks,
      radius: 12,
      tinggi: tinggi,
      paddingH: paddingH,
      lebarPenuh: lebarPenuh,
    ),
  );
}

/// One contents row: name, description and bar on the left, badge right.
class _Butir extends StatelessWidget {
  const _Butir({required this.i, required this.st});
  final int i;
  final _St st;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (n, s, lama) = _isi[i];
    final kurang = st == _St.selesai && i == 2;
    final lencana = switch (st) {
      _St.belum => const LencanaStatus(
        'Akan disertakan',
        bentuk: BentukLencana.draf,
      ),
      _St.jalan => const LencanaStatus(
        'Sedang disiapkan',
        bentuk: BentukLencana.draf,
      ),
      _St.selesai =>
        kurang
            ? const LencanaStatus('Belum lengkap', bentuk: BentukLencana.bata)
            : const LencanaStatus('Disertakan', bentuk: BentukLencana.laut),
    };
    return Container(
      // CSS content-box: min-height 64 plus padding 8 0 plus the top rule.
      constraints: BoxConstraints(minHeight: i == 0 ? 80 : 81),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: i == 0
          ? null
          : BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(n, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  kurang ? '211 dari 214 file disertakan' : s,
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
                if (st == _St.jalan) ...[
                  const SizedBox(height: 8),
                  BatangIsi(lama: Duration(milliseconds: lama), tinggi: 4),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          lencana,
        ],
      ),
    );
  }
}
