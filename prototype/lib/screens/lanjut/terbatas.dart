import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../mock/mock.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/pita_peran.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import 'terbatas_data.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// Board state `{ cari }`, shared by the list and the transaction view (the
/// view itself, `buka`, is the route `/Terbatas/transaksi/:no`).
class _Cari extends InheritedNotifier<TextEditingController> {
  const _Cari({
    required TextEditingController super.notifier,
    required super.child,
  });

  static TextEditingController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Cari>()!.notifier!;
}

class TerbatasKendali extends StatefulWidget {
  const TerbatasKendali({super.key, required this.child});
  final Widget child;
  @override
  State<TerbatasKendali> createState() => _TerbatasKendaliState();
}

class _TerbatasKendaliState extends State<TerbatasKendali> {
  final _cari = TextEditingController();

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: LayarPonsel(
      child: _Cari(notifier: _cari, child: widget.child),
    ),
  );
}

class TerbatasScreen extends StatelessWidget {
  const TerbatasScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) =>
      anak == null ? const _Daftar() : _Rinci(no: param['no']);
}

class _Daftar extends StatelessWidget {
  const _Daftar();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final cari = _Cari.of(context);
    final rows = saringTerbatas(cari.text, (r) => '${r.no} ${r.ma} ${r.tgl}');
    final isi = <Widget>[
      const PitaPeran(
        jenis: JenisPita.peran,
        judul: 'Akses terbatas: Peruntukan Diakonia',
        kalimat: 'Anda hanya melihat bagian Diakonia. Bagian lain tidak ditampilkan dan tidak ikut dijumlahkan.',
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            terbatasSaldoDiakoniaNovember.$1,
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          Text(
            rp(terbatasSaldoDiakoniaNovember.$2),
            style: const TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 38,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          Text(
            'Hanya transaksi yang sudah dibukukan',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
      IsianTeks(
        controller: cari,
        labelSemantik: 'Cari transaksi Diakonia',
        petunjuk: 'Cari di peruntukan Diakonia',
      ),
      Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < rows.length; i++)
              _BarisDaftar(
                r: rows[i],
                pertama: i == 0,
                onTap: () => GoRouter.of(
                  context,
                ).push(Layar.terbatas.lokasi(anak: 'transaksi/${rows[i].no}')),
              ),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'Tidak ada transaksi peruntukan Diakonia yang cocok.',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ),
          ],
        ),
      ),
      Kartu(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Laporan resmi Oktober 2026',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'TERBATAS · Peruntukan Diakonia · dibuat khusus untuk akses ini',
                    style: TextStyle(fontSize: 13, color: c.tinta2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Tombol(
              'Unduh PDF',
              onPressed: null,
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.kecil,
              paddingH: 14,
              lebarPenuh: false,
              ke: Layar.laporanTerbatas,
              param: {'periode': belumDipindahId, 'bentuk': 'pdf'},
            ),
          ],
        ),
      ),
    ];
    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < isi.length; i++) ...[
              if (i > 0) const SizedBox(height: 18),
              isi[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _BarisDaftar extends StatelessWidget {
  const _BarisDaftar({
    required this.r,
    required this.pertama,
    required this.onTap,
  });
  final BarisTerbatas r;
  final bool pertama;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: pertama ? null : Border(top: BorderSide(color: c.garis)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${r.no} · ${r.tgl}',
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: 13,
                      color: c.tinta2,
                    ),
                  ),
                  Text(
                    r.ma,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rp(r.jm),
                  style: const TextStyle(
                    fontFamily: PalakatText.mono,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'bagian Diakonia',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Rinci extends StatelessWidget {
  const _Rinci({required this.no});
  final String? no;

  @override
  Widget build(BuildContext context) {
    final d = dataTerbatas.where((r) => r.no == no).firstOrNull;
    if (d == null) {
      // navigation.md 5.4: a `no` that names no transaction goes to the list.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.gantiKe(Layar.terbatas);
      });
      return const SizedBox.shrink();
    }
    final c = context.warna;
    const label = TextStyle(fontSize: 14);
    const nilai = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    Widget baris(String l, String v, {bool garis = true}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: garis ? Border(top: BorderSide(color: c.garis)) : null,
      ),
      child: _BarisSusut(
        kiri: Text(l, style: label.copyWith(color: c.tinta2)),
        kanan: Text(v, style: nilai, textAlign: TextAlign.right),
      ),
    );
    return ColoredBox(
      color: c.kertas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: d.no,
            judulMono: true,
            onKembali: () => context.naikKe(Layar.terbatas),
            ujung: LencanaStatus.uang(StatusUang.dibukukan, kepala: true),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bagian peruntukan Diakonia',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                      Text(
                        rp(d.jm),
                        style: const TextStyle(
                          fontFamily: PalakatText.mono,
                          fontSize: 34,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Kartu(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        baris('Tanggal transaksi', d.tgl, garis: false),
                        baris('Mata Anggaran', d.maPenuh),
                        baris('Lingkup', 'Jemaat'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: ShapeDecoration(
                      shape: GarisBorder.putus(c.putus, radius: 14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tidak ditampilkan untuk akses terbatas',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        for (final t in tidakTerbatas) ...[
                          const SizedBox(height: 6),
                          Text(
                            t,
                            style: TextStyle(fontSize: 14, color: c.tinta2),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          'Ini berlaku sama di layar, pencarian, PDF dan Excel. Bendahara dapat menjelaskan transaksi ini bila diperlukan.',
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CSS `display: flex; justify-content: space-between; gap: 16px` of two
/// texts: when they do not fit, both shrink in proportion to their content
/// width (flex-shrink 1 from an auto basis), so a long value wraps the label too.
class _BarisSusut extends StatelessWidget {
  const _BarisSusut({required this.kiri, required this.kanan});
  final Text kiri, kanan;

  double _lebar(BuildContext context, Text t) {
    final tp = TextPainter(
      text: TextSpan(
        text: t.data,
        style: DefaultTextStyle.of(context).style.merge(t.style),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final w = tp.width;
    tp.dispose();
    return w;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      final a = _lebar(context, kiri), b = _lebar(context, kanan);
      if (a + b + 16 <= k.maxWidth) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [kiri, kanan],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: (a * 100).round(), child: kiri),
          const SizedBox(width: 16),
          Expanded(flex: (b * 100).round(), child: kanan),
        ],
      );
    },
  );
}
