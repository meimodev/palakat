import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/laporan.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../app/layar.dart';

/// The figure's detail (both boards): heading, the transactions card, the
/// "sum equals report" line, the note and the link to [ke]. Sizes the boards
/// leave to inheritance (16 phone, 15 web) come from DefaultTextStyle.
class RinciAngkaLaporan extends ConsumerWidget {
  const RinciAngkaLaporan({super.key, required this.pilih, required this.ke});

  /// The Mata Anggaran code of the figure; the first figure when unknown.
  final String? pilih;

  /// The board stem of "Buka Transaksi {bulan}".
  final Layar ke;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final l = ref.watch(laporanBulanProvider);
    final semua = ref.watch(angkaLaporanProvider);
    if (l == null || semua.isEmpty) {
      return Text(
        'Belum ada angka laporan dari transaksi yang dibukukan.',
        style: TextStyle(color: c.tinta2),
      );
    }
    final d = semua.where((x) => x.id == pilih).firstOrNull ?? semua.first;
    final bulan = namaBulan(l.periode);
    final jumlah = d.rows.fold(0, (s, r) => s + r.jm);
    final mono = TextStyle(fontFamily: PalakatText.mono);
    final anak = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${d.lap} · $bulan · '
            '${l.resmi ? 'Laporan resmi' : 'Laporan sementara'}',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
          Text(d.n, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            rp(d.total),
            style: mono.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
      Kartu(
        status: GarisStatus.dibukukan,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < d.rows.length; i++)
              Gerak(
                Kerangka.muncul,
                key: ValueKey('${d.id}-$i'),
                lama: const Duration(milliseconds: 300),
                child: _Baris(d.rows[i], pertama: i == 0),
              ),
          ],
        ),
      ),
      Row(
        children: [
          PalakatIkon(Ikon.centang, ukuran: 20, warna: c.laut),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Jumlah ${d.rows.length} baris ${rp(jumlah)} · sama dengan '
              'angka di laporan',
              style: TextStyle(fontWeight: FontWeight.w700, color: c.laut),
            ),
          ),
        ],
      ),
      Text(
        'Hanya transaksi yang sudah dibukukan. Pembalikan tetap tampil sebagai '
        'angka negatif; transaksi asalnya tidak dihilangkan. Yang dibagi ke '
        'beberapa Mata Anggaran tampil dengan bagiannya saja.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      Tautan(
        ke: ke,
        child: Align(
          alignment: Alignment.centerLeft,
          heightFactor: 1,
          child: TautanTeks('Buka Transaksi $bulan', berat: FontWeight.w700),
        ),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          anak[i],
        ],
      ],
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris(this.r, {required this.pertama});

  final BarisLaporan r;
  final bool pertama;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: pertama ? null : Border(top: BorderSide(color: c.garis)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  '${r.no} · ${r.tgl}',
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 13,
                    color: c.tinta2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                rp(r.jm),
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            r.ur,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          if (r.cat.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LencanaStatus(r.cat, bentuk: BentukLencana.garis),
            ),
        ],
      ),
    );
  }
}
