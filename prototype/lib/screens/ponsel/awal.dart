import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../providers/keuangan/pengaturan.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/logo.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// Awal (02-awal.md): the completed opening, read-only (D19). Every step is
/// done in the seed; the views show the cutover from the repositories.
class AwalKendali extends StatelessWidget {
  const AwalKendali({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayarPonsel(child: child);
}

class AwalScreen extends ConsumerWidget {
  const AwalScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final awal = ref.watch(awalProvider);
    return ColoredBox(
      color: context.warna.kertas,
      child: awal == null
          ? const SizedBox.shrink()
          : switch (anak) {
              'tunjuk' => _Tunjuk(awal),
              'saldo' => _Saldo(awal),
              _ => _Langkah(awal),
            },
    );
  }
}

// ── shared pieces ──────────────────────────────────────────────────────────

List<Widget> _jarak(double h, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: h),
    anak[i],
  ],
];

BoxDecoration _kartu(PalakatWarna c, double r) => BoxDecoration(
  color: c.permukaan,
  border: Border.all(color: c.garis),
  borderRadius: BorderRadius.circular(r),
);

Border? _garisAtas(PalakatWarna c, int i) =>
    i == 0 ? null : Border(top: BorderSide(color: c.garis));

/// Bottom action bar: `permukaan`, top 1 `garis`, padding 12 20 22.
Widget _bawah(PalakatWarna c, List<Widget> anak) => Container(
  padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
  decoration: BoxDecoration(
    color: c.permukaan,
    border: Border(top: BorderSide(color: c.garis)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: _jarak(8, anak),
  ),
);

const _muncul = Duration(milliseconds: 300);

// ── view langkah (/awal) ───────────────────────────────────────────────────

class _Langkah extends StatelessWidget {
  const _Langkah(this.awal);
  final Awal awal;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final selesai = langkahSelesai(awal);
    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _jarak(18, [
            const Row(
              children: [
                TandaPalakat(),
                SizedBox(width: 10),
                KataPalakat(ukuran: 17, tinggiBaris: 1.4),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: const Text(
                    'Pengaturan awal Jemaat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${awal.jemaat} · $selesai dari ${awal.langkah.length} '
                  'langkah selesai',
                  style: TextStyle(fontSize: 15, color: c.tinta2),
                ),
              ],
            ),
            // `display: flex` <a>: the target spans the column's width.
            const Tautan(
              ke: Layar.awalIsian,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TautanTeks(
                  'Lihat identitas, Kas/Bank, peruntukan dan Lingkup',
                  berat: FontWeight.w700,
                  ukuran: 15,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.tinta,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _jarak(10, [
                  Text(
                    'Jemaat siap mencatat.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.permukaan,
                    ),
                  ),
                  Text(
                    'Pencatatan dimulai ${tglPanjang(awal.mulai.awal)}.',
                    style: TextStyle(fontSize: 14, color: c.diTinta2),
                  ),
                  Tautan(
                    ke: Layar.keuangan,
                    cara: Cara.ganti,
                    radius: 12,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.permukaan,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Mulai mencatat',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.tinta,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _kartu(c, 16),
              child: Column(
                children: [
                  for (var i = 0; i < awal.langkah.length; i++)
                    _BarisLangkah(
                      nomor: i + 1,
                      l: (
                        awal.langkah[i].judul,
                        awal.langkah[i].sub,
                        awal.langkah[i].sub.contains('wajib sebelum')
                            ? 'nanti'
                            : 'ok',
                        awal.langkah[i].anak,
                      ),
                    ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _BarisLangkah extends StatelessWidget {
  const _BarisLangkah({required this.nomor, required this.l});
  final int nomor;
  final (String, String, String, String?) l;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (judul, sub, st, ke) = l;
    final bisa = ke != null && (st == 'kini' || st == 'tunggu' || st == 'ok');
    return Tekan(
      onTap: bisa ? () => context.dorongKe(Layar.awal, anak: ke) : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(border: _garisAtas(c, nomor - 1)),
        child: Row(
          children: [
            _Bulat(st: st, nomor: nomor, ukuran: 34, teks: 15),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: st == 'kunci' ? c.tinta3 : c.tinta,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 13,
                      color: st == 'kini' ? c.laut : c.tinta3,
                      fontWeight: st == 'kini'
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (bisa) ...[
              const SizedBox(width: 14),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ],
        ),
      ),
    );
  }
}

/// Step circle. `ok` laut "✓", `kini` tinta, `tunggu` dashed tinta,
/// `kunci`/`nanti` dashed putus. The dashed ones are content-box on the
/// board: [ukuran] + 2 × 1.5.
class _Bulat extends StatelessWidget {
  const _Bulat({
    required this.st,
    required this.nomor,
    required this.ukuran,
    required this.teks,
  });
  final String st;
  final int nomor;
  final double ukuran, teks;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (Color? isi, Color? garis, Color fg) = switch (st) {
      'ok' => (c.laut, null, c.diLaut),
      'kini' => (c.tinta, null, c.permukaan),
      'tunggu' => (null, c.tinta, c.tinta),
      _ => (null, c.putus, c.tinta3),
    };
    final sisi = garis == null ? ukuran : ukuran + 3;
    return Container(
      width: sisi,
      height: sisi,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: isi,
        shape: garis == null
            ? const CircleBorder()
            : GarisBorder.putus(garis, radius: sisi / 2),
      ),
      child: Text(
        st == 'ok' ? '✓' : '$nomor',
        style: TextStyle(
          fontFamily: PalakatText.mono,
          fontWeight: FontWeight.w600,
          fontSize: teks,
          color: fg,
        ),
      ),
    );
  }
}

// ── view tunjuk (/awal/tunjuk) ─────────────────────────────────────────────

class _Tunjuk extends StatelessWidget {
  const _Tunjuk(this.awal);
  final Awal awal;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final fakta = [
      ('Yang ditunjuk', awal.bendahara),
      ('Yang menunjuk', 'BPMJ ${awal.jemaat}'),
      ('Surat penunjukan', '${awal.dokumen}.pdf · Terlampir'),
      ('Diverifikasi oleh', awal.diverifikasi),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Penunjukan Bendahara',
          kembaliKe: Layar.awal,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _jarak(18, [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Column(
                    children: _jarak(12, [
                      const ExcludeSemantics(
                        child: LingkarSelesai(key: ValueKey('aktif')),
                      ),
                      const Text(
                        'Wewenang Bendahara aktif',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Bendahara dapat mencatat, membukukan dan menutup buku '
                        'untuk ${awal.jemaat}.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                    ]),
                  ),
                ),
                _KartuFakta(baris: fakta, padding: 12, nilaiMono: false),
                Text(
                  'Akses teknis ke aplikasi saja tidak memberi wewenang '
                  'Bendahara. Wewenang hanya berasal dari keputusan Jemaat '
                  'yang sudah diverifikasi.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ]),
            ),
          ),
        ),
        _bawah(c, [
          const Tombol(
            'Kembali ke pengaturan awal',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ke: Layar.awal,
            cara: Cara.naik,
          ),
        ]),
      ],
    );
  }
}

class _KartuFakta extends StatelessWidget {
  const _KartuFakta({
    required this.baris,
    required this.padding,
    required this.nilaiMono,
  });
  final List<(String, String)> baris;
  final double padding;
  final bool nilaiMono;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: _kartu(c, 14),
      child: Column(
        children: [
          for (var i = 0; i < baris.length; i++)
            Container(
              padding: EdgeInsets.symmetric(vertical: padding),
              decoration: BoxDecoration(border: _garisAtas(c, i)),
              child: _Susut(
                kiri: baris[i].$1,
                kanan: baris[i].$2,
                gayaKiri: TextStyle(fontSize: 14, color: c.tinta2),
                gayaKanan: nilaiMono
                    ? const TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )
                    : const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `display: flex; justify-content: space-between; gap: 16px` with two
/// texts: when both do not fit, each shrinks in proportion to its own
/// max-content width (CSS `flex-shrink: 1`).
class _Susut extends StatelessWidget {
  const _Susut({
    required this.kiri,
    required this.kanan,
    required this.gayaKiri,
    required this.gayaKanan,
  });
  final String kiri, kanan;
  final TextStyle gayaKiri, gayaKanan;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      final dasar = DefaultTextStyle.of(context).style;
      double ukur(String t, TextStyle g) => (TextPainter(
        text: TextSpan(text: t, style: dasar.merge(g)),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout()).width.ceilToDouble();
      var a = ukur(kiri, gayaKiri), b = ukur(kanan, gayaKanan);
      final lebih = a + b + 16 - k.maxWidth;
      if (lebih > 0) {
        final ka = lebih * a / (a + b);
        a -= ka;
        b -= lebih - ka;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: a,
            child: Text(kiri, style: gayaKiri),
          ),
          SizedBox(
            width: b,
            child: Text(kanan, textAlign: TextAlign.right, style: gayaKanan),
          ),
        ],
      );
    },
  );
}

// ── view saldo (/awal/saldo) ───────────────────────────────────────────────

class _Saldo extends StatelessWidget {
  const _Saldo(this.awal);
  final Awal awal;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Saldo awal pencatatan',
          anakJudul:
              'Per ${tglPanjang(awal.mulai.awal)}, tanggal mulai pencatatan',
          kembaliKe: Layar.awal,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _jarak(18, [
                KartuOpn(
                  awal: awal,
                  padding: 18,
                  ukuranAngka: 30,
                  jarakHuruf: 0,
                ),
                Gerak(
                  Kerangka.muncul,
                  lama: _muncul,
                  tunda: const Duration(milliseconds: 600),
                  child: _KartuFakta(
                    padding: 11,
                    nilaiMono: true,
                    baris: [
                      for (final x in awal.saldo) (x.akun.name, rp(x.jumlah)),
                    ],
                  ),
                ),
                DefaultTextStyle.merge(
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _jarak(4, [
                      for (final x in awal.saldo)
                        Text(
                          '${x.akun.name} · ${[for (final e in x.dana.entries) '${e.key} ${rp(e.value)}'].join(' · ')}',
                        ),
                      if (awal.sumber.isNotEmpty)
                        for (final x in awal.saldo)
                          if (awal.sumber[x.akun.id] case final s?)
                            Text(
                              '${x.akun.name} · $s',
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                    ]),
                  ),
                ),
                Text(
                  'Saldo awal bukan Pendapatan. Jumlah per peruntukan sama '
                  'persis dengan tiap Kas/Bank.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ]),
            ),
          ),
        ),
        _bawah(c, [
          const Tombol(
            'Kembali ke pengaturan awal',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ke: Layar.awal,
            cara: Cara.naik,
          ),
        ]),
      ],
    );
  }
}

class KartuOpn extends StatelessWidget {
  const KartuOpn({
    super.key,
    required this.awal,
    required this.padding,
    required this.ukuranAngka,
    required this.jarakHuruf,
  });
  final Awal awal;
  final double padding, ukuranAngka, jarakHuruf;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.tinta, radius: 16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.5),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _jarak(8, [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const LencanaStatus(
                        'Dibukukan',
                        bentuk: BentukLencana.tinta,
                        kepala: true,
                      ),
                      Flexible(
                        child: Gerak(
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
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Saldo awal pencatatan · semua Kas/Bank',
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                  ),
                  Text(
                    rp(awal.total),
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: ukuranAngka,
                      fontWeight: FontWeight.w500,
                      letterSpacing: jarakHuruf,
                    ),
                  ),
                  Text(
                    'Seri OPN · bukan Pendapatan · ${awal.bulanFinal}',
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ]),
              ),
            ),
            const SapuTinta(),
          ],
        ),
      ),
    );
  }
}
