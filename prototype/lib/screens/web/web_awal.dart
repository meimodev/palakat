import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../providers/keuangan/pengaturan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// WebAwal (02-awal.md): the completed opening, read-only (D19).
class WebAwalScreen extends ConsumerWidget {
  const WebAwalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final awal = ref.watch(awalProvider);
    if (awal == null) return const SizedBox.shrink();
    final langkah = [
      for (final l in awal.langkah)
        (
          l.judul,
          // U+200B: the browser may break after a hyphen; Flutter does not.
          l.sub.replaceAll('-', '-​'),
          l.sub.contains('wajib sebelum') ? 'nanti' : 'ok',
        ),
    ];
    final selesai = langkahSelesai(awal);
    return HalamanWeb(
      nav: const NavSamping(item: navKeuangan, aktif: 6),
      jarak: 22,
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Pengaturan awal Jemaat',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${awal.jemaat} · $selesai dari ${awal.langkah.length} langkah '
              'selesai',
              style: TextStyle(fontSize: 15, color: c.tinta2),
            ),
            Text(
              'Jemaat siap mencatat. Per ${tglPanjang(awal.mulai.awal)}, '
              'tanggal mulai pencatatan · bulan pertama pencatatan: '
              '${bulanDari(awal.mulai)}',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        const MarginNegatif(
          atas: 8,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tautan(
              ke: Layar.awalIsian,
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: TautanTeks('Identitas Jemaat dan daftar', ukuran: 14),
              ),
            ),
          ),
        ),
        _Kisi(
          anak: [
            for (var i = 0; i < langkah.length; i++)
              _KartuLangkah(i + 1, langkah[i]),
          ],
        ),
        _kartuOpn(c, awal),
        _tabelSaldo(c, awal),
      ],
    );
  }
}

/// The opening per Kas/Bank and peruntukan, read-only.
Widget _tabelSaldo(PalakatWarna c, Awal awal) => Kartu(
  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (i, x) in awal.saldo.indexed)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: i == 0 ? null : Border(top: BorderSide(color: c.garis)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      x.akun.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      [
                        for (final e in x.dana.entries)
                          '${e.key} ${rp(e.value)}',
                      ].join(' · '),
                      style: TextStyle(fontSize: 13, color: c.tinta2),
                    ),
                    if (awal.sumber[x.akun.id] case final s?)
                      Text(s, style: TextStyle(fontSize: 13, color: c.tinta3)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                rp(x.jumlah),
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
    ],
  ),
);

Widget _kartuOpn(PalakatWarna c, Awal awal) => LayoutBuilder(
  builder: (context, k) => Align(
    alignment: Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: BoxConstraints(minWidth: math.min(520, k.maxWidth)),
      child: IntrinsicWidth(
        child: Container(
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(c.tinta, radius: 16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.5),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const LencanaStatus(
                            'Dibukukan',
                            bentuk: BentukLencana.tinta,
                            kepala: true,
                          ),
                          const SizedBox(width: 12),
                          Gerak(
                            Kerangka.cap,
                            lama: const Duration(milliseconds: 550),
                            tunda: const Duration(milliseconds: 350),
                            kurva: PalakatMotion.keluar,
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
                                'No. Bukti ${awal.voucher}',
                                style: TextStyle(
                                  fontFamily: PalakatText.mono,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: c.laut,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Saldo awal pencatatan · semua Kas/Bank',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rp(awal.total),
                        style: const TextStyle(
                          fontFamily: PalakatText.mono,
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seri OPN · bukan Pendapatan · ${awal.bulanFinal}',
                        style: TextStyle(fontSize: 13, color: c.tinta3),
                      ),
                      const SizedBox(height: 18),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Gerak(
                          Kerangka.muncul,
                          lama: Duration(milliseconds: 300),
                          tunda: Duration(milliseconds: 800),
                          child: Tombol(
                            'Mulai mencatat',
                            onPressed: null,
                            ke: Layar.keuangan,
                            cara: Cara.ganti,
                            ukuran: UkuranTombol.ringkas,
                            lebarPenuh: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SapuTinta(),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);

/// The steps grid `repeat(auto-fit, minmax(min(150px, 100%), 1fr))`, gap 10;
/// a row's cards stretch to the tallest.
class _Kisi extends StatelessWidget {
  const _Kisi({required this.anak});
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      final n = KisiOtomatis.kolom(k.maxWidth, 150, 10, anak.length);
      final lebar = (k.maxWidth - 10 * (n - 1)) / n;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i += n) ...[
            if (i > 0) const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = i; j < math.min(i + n, anak.length); j++) ...[
                    if (j > i) const SizedBox(width: 10),
                    SizedBox(width: lebar, child: anak[j]),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}

class _KartuLangkah extends StatelessWidget {
  const _KartuLangkah(this.nomor, this.l);
  final int nomor;
  final (String, String, String) l;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (judul, sub, st) = l;
    final kini = st == 'kini';
    final (Color? isi, Color fg) = switch (st) {
      'ok' => (c.laut, c.diLaut),
      'kini' => (c.tinta, c.permukaan),
      _ => (null, c.tinta3),
    };
    // The dashed circle is content-box on the board: 30 + 2 × 1.5.
    final sisi = isi == null ? 33.0 : 30.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: kini ? c.permukaan : null,
        shape: kini
            ? GarisBorder.penuh(c.tinta, radius: 12)
            : GarisBorder.penuh(c.garis, tebal: 1, radius: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: sisi,
            height: sisi,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: isi,
              shape: isi == null
                  ? GarisBorder.putus(c.putus, radius: sisi / 2)
                  : const CircleBorder(),
            ),
            child: Text(
              st == 'ok' ? '✓' : '$nomor',
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: fg,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            judul,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(sub, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
      ),
    );
  }
}
