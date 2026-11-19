import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tablet.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/butir_perhatian.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'tab_beranda_kit.dart';

/// Tablet · Beranda (spec 13): WebBeranda at 834 wide, no vacancy tweak.
/// Content follows the `bulan` tweak only.
class TabBerandaScreen extends StatelessWidget {
  const TabBerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final sepi = context.tweak<String>('TabBeranda', 'bulan') == 'sepi';
    final tindakan = sepi
        ? berandaPerluTindakan.take(1).toList()
        : berandaPerluTindakan;
    const tujuan = [
      (ke: 'WebTutupBuku'),
      (ke: 'WebTransaksi'),
      (ke: 'WebTransaksi'),
      (ke: 'WebTransaksi'),
    ];
    final angka = [
      ('Pendapatan bulan ini', berandaNovember.pendapatan, 'tanpa titipan'),
      ('Belanja bulan ini', berandaNovember.belanja, 'tanpa titipan'),
      (
        'Surplus/Defisit bulan ini',
        berandaNovember.surplus,
        'hanya yang sudah dibukukan',
      ),
    ];

    Widget aksi(String teks, {required String ke, bool utama = true}) => Tombol(
      teks,
      onPressed: null,
      ke: ke,
      cara: ke == 'WebLaporan' ? Cara.dorong : Cara.ganti,
      jenis: utama ? JenisTombol.utama : JenisTombol.kedua,
      ukuran: UkuranTombol.kecil,
      paddingH: 18,
      lebarPenuh: false,
    );

    final saldo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saldo buku semua Kas/Bank',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        const SizedBox(height: 6),
        Text(
          rp(totalSaldoNovember),
          style: TextStyle(
            fontFamily: PalakatText.mono,
            fontSize: context.jepit(34, 4.4, 56),
            fontWeight: FontWeight.w500,
            letterSpacing: -1.5,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hanya transaksi yang sudah dibukukan',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
        if (!sepi) ...[
          const SizedBox(height: 14), // gap 6 + margin-top 8
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: ShapeDecoration(
              shape: GarisBorder.putus(c.putus, radius: 999),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: rp(berandaNovember.drafJumlah),
                    style: const TextStyle(fontFamily: PalakatText.mono),
                  ),
                  const TextSpan(text: ' · 2 draf · belum masuk saldo'),
                ],
              ),
              style: TextStyle(fontSize: 13, color: c.tinta2),
            ),
          ),
        ],
      ],
    );

    final ubin = KisiOtomatis(
      minLebar: 150,
      jarak: 12,
      anak: [
        for (final (k, v, s) in angka)
          Kartu(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k, style: TextStyle(fontSize: 13, color: c.tinta2)),
                const SizedBox(height: 2),
                Text(
                  rp(sepi ? 0 : v),
                  style: const TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(s, style: TextStyle(fontSize: 13, color: c.tinta3)),
              ],
            ),
          ),
      ],
    );

    final perlu = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: JudulBagian(
            'Perlu tindakan',
            web: true,
            hitungan: tindakan.length,
          ),
        ),
        const SizedBox(height: 12),
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < tindakan.length; i++)
                ButirPerhatian(
                  tingkat: TingkatPerhatian.perluTindakan,
                  judul: tindakan[i].$1,
                  keterangan: tindakan[i].$2,
                  warnaKeterangan: i == 0 ? c.bata : null,
                  pertama: i == 0,
                  web: true,
                  ke: tujuan[i].ke,
                  cara: Cara.ganti,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (sepi)
          Kartu(
            status: GarisStatus.draf,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Belum ada transaksi di November.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.tinta,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' Bulan tanpa transaksi belum selesai: tiap Kas/Bank '
                        'tetap perlu hitung kas atau rekening koran, lalu '
                        'tutup buku.',
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          )
        else
          ButirPerhatian(
            tingkat: TingkatPerhatian.untukDiketahui,
            judul: berandaUntukDiketahui,
            web: true,
            ke: 'WebKewajiban',
            cara: Cara.ganti,
          ),
      ],
    );

    final posisi = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              text: 'Posisi Kas & Bank ',
              children: [
                TextSpan(
                  text: '· November 2026',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: c.tinta3,
                  ),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        const _TabelKas(),
        const SizedBox(height: 12),
        Text(
          'Hasil hitung kas dan saldo rekening koran tidak pernah dijumlahkan. '
          'Yang belum ada ditampilkan sebagai “—”, bukan Rp0.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );

    return HalamanTablet(
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 0,
        pengguna: PenggunaKeuangan(ikutJabatanKosong: false),
      ),
      jarak: 24,
      isi: [
        const KepalaTab(
          'Beranda',
          ujung: [Tautan(ke: 'WebPilihBulan', radius: 999, child: PilBulan())],
        ),
        const DeretTautan(
          web: true,
          anak: [
            TautanTab('Pemberitahuan', ke: 'WebPemberitahuan'),
            TautanTab('Cari dan tanya', ke: 'WebCari'),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            aksi('+ Pendapatan', ke: 'WebTransaksi'),
            aksi('− Belanja', ke: 'WebTransaksi'),
            aksi('+ Persembahan', ke: 'WebTransaksi'),
            aksi('Rekonsiliasi', ke: 'WebRekonsiliasi', utama: false),
            aksi('Buat laporan sementara', ke: 'WebLaporan', utama: false),
          ],
        ),
        KisiOtomatis(minLebar: 360, jarak: 24, anak: [saldo, ubin]),
        KisiOtomatis(minLebar: 360, jarak: 24, anak: [perlu, posisi]),
      ],
    );
  }
}

/// The Kas & Bank table: min width 520, scrolls sideways inside its card.
class _TabelKas extends StatelessWidget {
  const _TabelKas();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const pad = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final garis = BoxDecoration(
      border: Border(top: BorderSide(color: c.garis)),
    );
    final kepala = TextStyle(fontWeight: FontWeight.w600, color: c.tinta2);
    const mono = TextStyle(fontFamily: PalakatText.mono);

    Widget sel(Widget anak, {bool kanan = true}) => Padding(
      padding: pad,
      child: Align(
        alignment: kanan ? Alignment.centerRight : Alignment.centerLeft,
        child: anak,
      ),
    );
    Widget belum(String teks) => Text.rich(
      TextSpan(
        text: '— ',
        children: [TextSpan(text: teks, style: const TextStyle(fontSize: 13))],
      ),
      textAlign: TextAlign.right,
      style: TextStyle(color: c.tinta2),
    );
    TableRow baris(String nama, int saldo, Widget hitung, Widget koran) =>
        TableRow(
          decoration: garis,
          children: [
            sel(
              Text(nama, style: const TextStyle(fontWeight: FontWeight.w600)),
              kanan: false,
            ),
            sel(Text(rp(saldo), style: mono, textAlign: TextAlign.right)),
            sel(hitung),
            sel(koran),
          ],
        );

    return Container(
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: LayoutBuilder(
          builder: (context, k) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: k.maxWidth < 520 ? 520 : k.maxWidth,
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 14),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: _lebarKolom,
                  children: [
                    TableRow(
                      children: [
                        sel(Text('Kas/Bank', style: kepala), kanan: false),
                        sel(
                          Text(
                            'Saldo buku',
                            style: kepala,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        sel(
                          Text(
                            'Hasil hitung kas',
                            style: kepala,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        sel(
                          Text(
                            'Saldo rekening koran',
                            style: kepala,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    baris(
                      'Kas',
                      saldoNovember['kas']!,
                      Text.rich(
                        TextSpan(
                          text: '— ',
                          children: [
                            const TextSpan(
                              text: 'Belum dihitung',
                              style: TextStyle(fontSize: 13),
                            ),
                            const TextSpan(text: ' · '),
                            // The 44-high target reaches into the cell padding.
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: MarginNegatif(
                                atas: 12,
                                bawah: 12,
                                child: TautanTab(
                                  'Hitung kas',
                                  ke: 'WebHitungKas',
                                  ukuran: 13,
                                  berat: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.right,
                        style: TextStyle(color: c.tinta2),
                      ),
                      const SizedBox.shrink(),
                    ),
                    baris(
                      'Bank BNI ··4821',
                      saldoNovember['bni']!,
                      const SizedBox.shrink(),
                      belum('Rekening koran belum diisi'),
                    ),
                    baris(
                      'Bank SulutGo ··1107',
                      saldoNovember['bsg']!,
                      const SizedBox.shrink(),
                      belum('Rekening koran belum diisi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// The HTML auto table layout at its 520 minimum, measured off the board at
// 834 (121.9 · 132.8 · 130.9 · 134.4); cols 2 and 4 get .6 and .4 from col 1
// so "Rp24.615.000" (100.8 px mono) and "koran belum diisi" (102.3 px) still
// fit on one line in Flutter.
// ponytail: fixed proportions; columns do not re-balance by content when the
// card is wider than 520.
const _lebarKolom = {
  0: FlexColumnWidth(121.3),
  1: FlexColumnWidth(133.4),
  2: FlexColumnWidth(130.9),
  3: FlexColumnWidth(134.8),
};
