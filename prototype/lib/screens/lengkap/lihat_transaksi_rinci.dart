import 'package:flutter/widgets.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';

/// One booked transaction behind a report figure.
typedef BarisLaporan = ({String no, String tgl, String ur, String cat, int jm});

/// One figure of the October 2026 report (the boards' `D` array), shared by
/// LihatTransaksi and WebLihatTransaksi.
typedef AngkaLaporan = ({
  String id,
  String pendek,
  String lap,
  String n,
  List<BarisLaporan> rows,
  int total,
});

const List<AngkaLaporan> angkaLaporanOktober = [
  (
    id: 'hon',
    pendek: 'Honorarium pelayan',
    lap: 'F07 · Realisasi Belanja Menurut Mata Anggaran',
    n: 'Belanja 5.07.01.00 Honorarium pelayan',
    rows: [
      (
        no: 'BKU-2026-0100',
        tgl: '05/10/2026',
        ur: 'Honorarium pelayan',
        cat: '',
        jm: 1820000,
      ),
      (
        no: 'BKU-2026-0120',
        tgl: '26/10/2026',
        ur: 'Honorarium pelayan',
        cat: '',
        jm: 1820000,
      ),
    ],
    total: 3640000,
  ),
  (
    id: 'atk',
    pendek: 'Alat tulis dan fotokopi',
    lap: 'F07 · Realisasi Belanja Menurut Mata Anggaran',
    n: 'Belanja 5.02.01.00 Alat tulis dan fotokopi',
    rows: [
      (
        no: 'BKU-2026-0101',
        tgl: '06/10/2026',
        ur: 'Toko Sinar: listrik dan alat tulis',
        cat: 'Bagian dari pembayaran Rp1.250.000',
        jm: 250000,
      ),
      (
        no: 'BKU-2026-0105',
        tgl: '09/10/2026',
        ur: 'Konsumsi rapat majelis',
        cat: 'Dibalik oleh BKU-2026-0109',
        jm: 750000,
      ),
      (
        no: 'BKU-2026-0109',
        tgl: '12/10/2026',
        ur: 'Pembalikan BKU-2026-0105',
        cat: 'Pembalikan',
        jm: -750000,
      ),
    ],
    total: 250000,
  ),
  (
    id: 'pim',
    pendek: 'Persembahan Ibadah Minggu',
    lap: 'F05 · Realisasi Pendapatan Menurut Mata Anggaran',
    n: 'Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu',
    rows: [
      (
        no: 'BKU-2026-0098',
        tgl: '04/10/2026',
        ur: 'Persembahan Ibadah Minggu dan Diakonia',
        cat: 'Bagian dari penerimaan Rp4.150.000',
        jm: 3200000,
      ),
      (
        no: 'BKU-2026-0107',
        tgl: '11/10/2026',
        ur: 'Persembahan Ibadah Minggu',
        cat: '',
        jm: 2650000,
      ),
      (
        no: 'BKU-2026-0114',
        tgl: '18/10/2026',
        ur: 'Persembahan Ibadah Minggu',
        cat: '',
        jm: 2400000,
      ),
      (
        no: 'BKU-2026-0123',
        tgl: '25/10/2026',
        ur: 'Persembahan Ibadah Minggu',
        cat: '',
        jm: 2700000,
      ),
    ],
    total: 10950000,
  ),
];

AngkaLaporan angkaLaporan(String id) =>
    angkaLaporanOktober.firstWhere((x) => x.id == id);

/// The figure's detail (both boards): heading, the transactions card, the
/// "sum equals report" line, the note and the link to [ke]. Sizes the boards
/// leave to inheritance (16 phone, 15 web) come from DefaultTextStyle.
class RinciAngkaLaporan extends StatelessWidget {
  const RinciAngkaLaporan({super.key, required this.pilih, required this.ke});

  final String pilih;

  /// The board stem of "Buka Transaksi Oktober 2026".
  final String ke;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final d = angkaLaporan(pilih);
    final jumlah = d.rows.fold(0, (s, r) => s + r.jm);
    final mono = TextStyle(fontFamily: PalakatText.mono);
    final anak = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${d.lap} · Oktober 2026 · Laporan resmi',
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
                key: ValueKey('$pilih-$i'),
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
        child: const Align(
          alignment: Alignment.centerLeft,
          heightFactor: 1,
          child: TautanTeks(
            'Buka Transaksi Oktober 2026',
            berat: FontWeight.w700,
          ),
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
