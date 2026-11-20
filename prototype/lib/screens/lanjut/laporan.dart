import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/kerangka.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/laporan.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/pita_laporan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'laporan_tabel.dart';
import '../../app/layar.dart';

/// Owns LayarPonsel, so the jabatanKosong line stays put while the detail
/// slides in (navigation.md 2.1). The board state `buka` is the route.
class LaporanKendali extends StatefulWidget {
  const LaporanKendali({super.key, required this.child});
  final Widget child;
  @override
  State<LaporanKendali> createState() => _LaporanKendaliState();
}

class _LaporanKendaliState extends State<LaporanKendali> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LayarPonsel(layarKeuangan: true, child: widget.child);
}

/// Laporan (phone): the report of `laporanBulanProvider`, provisional
/// before the close and official after it.
class LaporanScreen extends ConsumerWidget {
  const LaporanScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(laporanBulanProvider);
    if (l == null) return const SizedBox.shrink();
    return anak == null ? _Daftar(l: l) : _Rinci(id: param['f'], l: l);
  }
}

class _Daftar extends StatelessWidget {
  const _Daftar({required this.l});
  final LaporanBulan l;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final resmi = l.resmi;
    final bulan = namaBulan(l.periode);
    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Laporan',
            anakJudul: '$bulan · Paket Laporan Bulanan GMIM',
            kembaliKe: Layar.pengaturan,
            labelKembali: 'Kembali ke Lainnya',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MarginNegatif(
                    atas: 6,
                    bawah: 6,
                    child: Tautan(
                      ke: Layar.lihatTransaksi,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        alignment: Alignment.centerLeft,
                        child: const TautanTeks(
                          'Lihat transaksi di balik sebuah angka',
                          berat: FontWeight.w700,
                          ukuran: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (resmi) ...[
                    PitaLaporan.resmi(
                      dibekukan: dibekukan(l.snapshot!),
                      idSalinan: l.snapshot!.id,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Tombol(
                            'Unduh PDF',
                            onPressed: null,
                            ke: Layar.laporanResmi,
                            param: {'periode': l.periode.id, 'bentuk': 'f01'},
                            ukuran: UkuranTombol.sedang,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Tombol(
                            'Unduh Excel',
                            onPressed: null,
                            ke: Layar.laporanResmi,
                            param: {'periode': l.periode.id, 'bentuk': 'excel'},
                            jenis: JenisTombol.kedua,
                            ukuran: UkuranTombol.sedang,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    PitaLaporan.sementara(
                      kalimat:
                          'Bukan laporan resmi. Angka masih dapat berubah '
                          'sampai $bulan ditutup; file resmi dibuat setelah '
                          'tutup buku.',
                    ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: c.permukaan,
                      border: Border.all(color: c.garis),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, (id, n)) in laporanDaftar.indexed)
                          _BarisForm(id: id, nama: n, pertama: i == 0),
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

class _BarisForm extends StatelessWidget {
  const _BarisForm({
    required this.id,
    required this.nama,
    required this.pertama,
  });
  final String id, nama;
  final bool pertama;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: Layar.laporan,
      anak: 'rinci/$id',
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: pertama ? null : Border(top: BorderSide(color: c.garis)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                id,
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 13,
                  color: c.tinta2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                nama,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
          ],
        ),
      ),
    );
  }
}

/// One stacked card (board `kartu`).
typedef _Kartu = ({
  String judul,
  String kode,
  List<(String, String)> angka,
  bool tebal,
});

final _kode = RegExp(r'^(BKU|OPN|ADJ)-|^\d\.\d|^\d\d/\d\d/\d{4}$');

List<_Kartu> _kartu(LaporanTabel l) => [
  for (final r in l.rows)
    () {
      final t = r.last is int;
      final sel = t ? r.sublist(0, r.length - 1) : r;
      final teks = <String>[], kode = <String>[], angka = <(String, String)>[];
      for (final (i, v) in sel.cast<String>().indexed) {
        if (v.isEmpty) continue;
        if (l.kanan.contains(i)) {
          angka.add((l.cols[i], v));
        } else if (_kode.hasMatch(v)) {
          kode.add(v);
        } else {
          teks.add(v);
        }
      }
      final judul = teks.isNotEmpty
          ? teks.join(' · ')
          : kode.isNotEmpty
          ? kode.removeAt(0)
          : '';
      return (judul: judul, kode: kode.join(' · '), angka: angka, tebal: t);
    }(),
];

class _Rinci extends StatelessWidget {
  const _Rinci({required this.id, required this.l});
  final String? id;
  final LaporanBulan l;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final resmi = l.resmi;
    final p = laporanDaftar.firstWhere(
      (f) => f.$1 == id,
      orElse: () => laporanDaftar.first,
    );
    final tabel = tabelLaporan(l, formLaporan(p.$1));
    final kecil3 = TextStyle(fontSize: 13, color: c.tinta3);
    return ColoredBox(
      color: c.permukaan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
            child: Row(
              children: [
                const Tautan(
                  ke: Layar.laporan,
                  cara: Cara.naik,
                  label: 'Kembali',
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(child: PalakatIkon(Ikon.kembali, ukuran: 22)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${p.$1} · ${resmi ? 'LAPORAN RESMI' : 'LAPORAN SEMENTARA · BUKAN LAPORAN RESMI'}',
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: 13,
                      color: c.tinta2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: c.tinta, width: 2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.$2,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        Text(
                          'Jemaat Karunia · Periode laporan '
                          '${rentangPeriode(l.periode)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(tabel.sub, style: kecil3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final k in _kartu(tabel)) _KartuLaporan(k),
                  const SizedBox(height: 12),
                  Text(tabel.kaki, style: kecil3),
                  const SizedBox(height: 12),
                  Text(
                    'Di ponsel tiap baris laporan ditumpuk; kolom dan angkanya sama dengan PDF dan Excel.',
                    style: kecil3,
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

class _KartuLaporan extends StatelessWidget {
  const _KartuLaporan(this.k);
  final _Kartu k;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final berat = k.tebal ? FontWeight.w700 : FontWeight.w500;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: k.tebal
              ? BorderSide(color: c.tinta, width: 1.5)
              : BorderSide(color: c.garis),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(k.judul, style: TextStyle(fontSize: 15, fontWeight: berat)),
          if (k.kode.isNotEmpty)
            Text(
              k.kode,
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 13,
                color: c.tinta2,
              ),
            ),
          for (final (label, nilai) in k.angka)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 13, color: c.tinta2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    nilai,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: 15,
                      fontWeight: berat,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
