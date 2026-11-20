import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../mock/mock.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/pita_peran.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import 'terbatas_data.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

class WebTerbatasScreen extends StatefulWidget {
  const WebTerbatasScreen({super.key});
  @override
  State<WebTerbatasScreen> createState() => _WebTerbatasScreenState();
}

class _WebTerbatasScreenState extends State<WebTerbatasScreen> {
  final _cari = TextEditingController();
  String _pilih = 'BKU-2026-0141';

  @override
  void initState() {
    super.initState();
    _cari.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final rows = saringTerbatas(
      _cari.text,
      (r) => '${r.no} ${r.maPenuh} ${r.tgl}',
    );
    final d = dataTerbatas.firstWhere((r) => r.no == _pilih);

    final saldo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          terbatasSaldoDiakoniaNovember.$1,
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        Text(
          rp(terbatasSaldoDiakoniaNovember.$2),
          softWrap: false,
          style: const TextStyle(
            fontFamily: PalakatText.mono,
            fontSize: 44,
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
    );

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: const NavSamping(item: navTerbatas, aktif: 0),
        isi: [
          const PitaPeran(
            jenis: JenisPita.peran,
            sebaris: true,
            judul: 'Akses terbatas: Peruntukan Diakonia',
            kalimat: 'Anda hanya melihat bagian Diakonia. Bagian lain tidak ditampilkan dan tidak ikut dijumlahkan.',
          ),
          BarisLentur(
            jarak: 40,
            jarakBaris: 16,
            rata: CrossAxisAlignment.end,
            anak: [
              // ponytail: the block's content width (11 mono glyphs at 44 px,
              // −1 spacing ≈ 279.4) as a fixed basis; measure if the figure changes.
              Lentur(dasar: 280, tumbuh: 0, child: saldo),
              Lentur(
                dasar: 280,
                child: IsianTeks(
                  controller: _cari,
                  labelSemantik: 'Cari transaksi Diakonia',
                  petunjuk: 'Cari di peruntukan Diakonia',
                ),
              ),
            ],
          ),
          BarisLentur(
            anak: [
              Lentur(
                dasar: 520,
                tumbuh: 999,
                child: _Tabel(
                  rows: rows,
                  pilih: _pilih,
                  onPilih: (no) => setState(() => _pilih = no),
                ),
              ),
              Lentur(dasar: 340, child: _Samping(d: d)),
            ],
          ),
        ],
      ),
    );
  }
}

const _kolom = [130.0, 100.0, null, 150.0];

/// `grid-template-columns: 130px 100px minmax(0, 1fr) 150px; gap: 14px`.
Widget _kisi(List<Widget> sel) => Row(
  children: [
    for (var i = 0; i < sel.length; i++) ...[
      if (i > 0) const SizedBox(width: 14),
      _kolom[i] == null
          ? Expanded(child: sel[i])
          : SizedBox(width: _kolom[i], child: sel[i]),
    ],
  ],
);

class _Tabel extends StatelessWidget {
  const _Tabel({
    required this.rows,
    required this.pilih,
    required this.onPilih,
  });
  final List<BarisTerbatas> rows;
  final String pilih;
  final ValueChanged<String> onPilih;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final atas = Border(top: BorderSide(color: c.garis));
    return Container(
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: LayoutBuilder(
          builder: (context, k) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: k.maxWidth < 600 ? 600 : k.maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.tinta2,
                      ),
                      child: _kisi(const [
                        Text('No. Bukti'),
                        Text('Tanggal'),
                        Text('Mata Anggaran'),
                        Text('Bagian Diakonia', textAlign: TextAlign.right),
                      ]),
                    ),
                  ),
                  for (final r in rows)
                    Tekan(
                      onTap: () => onPilih(r.no),
                      dipilih: r.no == pilih,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 56),
                        decoration: BoxDecoration(
                          color: r.no == pilih ? c.lautLembut : c.permukaan,
                          border: atas,
                        ),
                        child: Stack(
                          alignment: AlignmentDirectional.centerStart,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              child: DefaultTextStyle.merge(
                                style: const TextStyle(fontSize: 14),
                                child: _kisi([
                                  Text(
                                    r.no,
                                    style: const TextStyle(
                                      fontFamily: PalakatText.mono,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    r.tgl,
                                    style: TextStyle(color: c.tinta2),
                                  ),
                                  Text(
                                    r.maPenuh,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    rp(r.jm),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontFamily: PalakatText.mono,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                            // `box-shadow: inset 3px 0 0 laut` on the selected row.
                            if (r.no == pilih)
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: 3,
                                child: ColoredBox(color: c.laut),
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (rows.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(border: atas),
                      child: Text(
                        'Tidak ada transaksi peruntukan Diakonia yang cocok.',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Samping extends StatelessWidget {
  const _Samping({required this.d});
  final BarisTerbatas d;

  /// Content width of a secondary link button (`padding: 0 14px`, 1.5 line).
  static double _lebarTombol(BuildContext context, String teks) {
    final tp = TextPainter(
      text: TextSpan(
        text: teks,
        style: DefaultTextStyle.of(context).style
            .copyWith(fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final w = tp.width + 28 + 3;
    tp.dispose();
    return w.ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 14, color: c.tinta2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Kartu(
          status: GarisStatus.terpilih,
          radius: 16,
          padding: const EdgeInsets.all(18),
          isi: c.permukaan,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LencanaStatus.uang(StatusUang.dibukukan, kepala: true),
                  Flexible(
                    child: Text(
                      d.no,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 14,
                        color: c.tinta2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('Bagian peruntukan Diakonia', style: kecil),
              const SizedBox(height: 4),
              Text(
                rp(d.jm),
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text('${d.maPenuh} · ${d.tgl} · Lingkup Jemaat', style: kecil),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: ShapeDecoration(
            shape: GarisBorder.putus(c.putus, radius: 14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tidak ditampilkan untuk akses terbatas',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              for (final t in tidakTerbatas) ...[
                const SizedBox(height: 6),
                Text(t, style: kecil),
              ],
              const SizedBox(height: 10),
              Text(
                'Berlaku sama di layar, pencarian, PDF dan Excel.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Kartu(
          child: BarisLentur(
            jarak: 10,
            rata: CrossAxisAlignment.center,
            anak: [
              Lentur(
                dasar: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laporan resmi Oktober 2026',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'TERBATAS · Peruntukan Diakonia',
                      style: TextStyle(fontSize: 13, color: c.tinta2),
                    ),
                  ],
                ),
              ),
              Lentur(
                dasar: _lebarTombol(context, 'Unduh PDF'),
                tumbuh: 0,
                child: const Tombol(
                  'Unduh PDF',
                  onPressed: null,
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.kecil,
                  paddingH: 14,
                  lebarPenuh: false,
                  ke: Layar.laporanTerbatas,
                  param: {'periode': belumDipindahId, 'bentuk': 'pdf'},
                ),
              ),
              Lentur(
                dasar: _lebarTombol(context, 'Unduh Excel'),
                tumbuh: 0,
                child: const Tombol(
                  'Unduh Excel',
                  onPressed: null,
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.kecil,
                  paddingH: 14,
                  lebarPenuh: false,
                  ke: Layar.laporanTerbatas,
                  param: {'periode': belumDipindahId, 'bentuk': 'excel'},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
