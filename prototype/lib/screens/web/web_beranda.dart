import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/butir_perhatian.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

/// Web · Beranda (docs/build/screens/02-awal.md): the Bendahara's laptop
/// home. No state of its own; the `bulan` tweak (ramai / sepi) and the
/// global `jabatanKosong` switch decide what shows.
class WebBerandaScreen extends StatelessWidget {
  const WebBerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final sepi = context.tweak<String>('WebBeranda', 'bulan') == 'sepi';
    const mono = TextStyle(fontFamily: PalakatText.mono);
    final tindakan = sepi
        ? berandaPerluTindakan.sublist(0, 1)
        : berandaPerluTindakan;

    final bulan = Tautan(
      ke: 'WebPilihBulan',
      radius: 22,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: ShapeDecoration(
          color: c.permukaan,
          shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 22),
        ),
        child: const Center(
          widthFactor: 1,
          child: Text(
            'November 2026 · Belum ditutup',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
    const judul = Text(
      'Beranda',
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
    );
    // h1 `flex: 1 1 200px` beside the pill (about 250 wide), gap 12, wrapping.
    final kepala = LayoutBuilder(
      builder: (context, k) => k.maxWidth >= 200 + 12 + 250
          ? Row(
              children: [
                const Expanded(child: judul),
                const SizedBox(width: 12),
                bulan,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [judul, const SizedBox(height: 12), bulan],
            ),
    );

    Widget tautanTeks(String teks, {required String ke}) => Tautan(
      ke: ke,
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 1,
        child: TautanTeks(teks),
      ),
    );

    Widget aksi(String label, {required String ke, bool utama = true}) =>
        Tombol(
          label,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Saldo buku semua Kas/Bank',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        const SizedBox(height: 6),
        Text(
          rp(totalSaldoNovember),
          style: mono.copyWith(
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
                  TextSpan(text: rp(berandaNovember.drafJumlah), style: mono),
                  const TextSpan(text: ' · 2 draf · belum masuk saldo'),
                ],
              ),
              style: TextStyle(fontSize: 13, color: c.tinta2),
            ),
          ),
        ],
      ],
    );

    Widget petak(String k, int v, String s) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(k, style: TextStyle(fontSize: 13, color: c.tinta2)),
          const SizedBox(height: 2),
          Text(
            rp(sepi ? 0 : v),
            style: mono.copyWith(fontSize: 19, fontWeight: FontWeight.w500),
          ),
          Text(s, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
      ),
    );

    final perlu = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, t) in tindakan.indexed)
                ButirPerhatian(
                  tingkat: TingkatPerhatian.perluTindakan,
                  judul: t.$1,
                  keterangan: t.$2,
                  ke: i == 0 ? 'WebTutupBuku' : 'WebTransaksi',
                  cara: Cara.ganti,
                  warnaKeterangan: i == 0 ? c.bata : null,
                  pertama: i == 0,
                  web: true,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (sepi)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: ShapeDecoration(
              shape: GarisBorder.putus(c.putus, radius: 14),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Belum ada transaksi di November.',
                    style: TextStyle(
                      color: c.tinta,
                      fontWeight: FontWeight.w700,
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
          const ButirPerhatian(
            tingkat: TingkatPerhatian.untukDiketahui,
            judul: berandaUntukDiketahui,
            ke: 'WebKewajiban',
            cara: Cara.ganti,
            web: true,
          ),
      ],
    );

    final posisi = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Posisi Kas & Bank '),
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
        const _TabelKasBank(),
        const SizedBox(height: 12),
        Text(
          'Hasil hitung kas dan saldo rekening koran tidak pernah '
          'dijumlahkan. Yang belum ada ditampilkan sebagai “—”, bukan Rp0.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        jabatanKosong: true,
        jarak: 24,
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 0,
          pengguna: PenggunaKeuangan(),
        ),
        isi: [
          kepala,
          DeretTautan(
            web: true,
            anak: [
              tautanTeks('Pemberitahuan', ke: 'WebPemberitahuan'),
              tautanTeks('Cari dan tanya', ke: 'WebCari'),
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
          KisiOtomatis(
            minLebar: 360,
            jarak: 24,
            anak: [
              saldo,
              _KisiSama(
                anak: [
                  petak(
                    'Pendapatan bulan ini',
                    berandaNovember.pendapatan,
                    'tanpa titipan',
                  ),
                  petak(
                    'Belanja bulan ini',
                    berandaNovember.belanja,
                    'tanpa titipan',
                  ),
                  petak(
                    'Surplus/Defisit bulan ini',
                    berandaNovember.surplus,
                    'hanya yang sudah dibukukan',
                  ),
                ],
              ),
            ],
          ),
          KisiOtomatis(minLebar: 360, jarak: 24, anak: [perlu, posisi]),
        ],
      ),
    );
  }
}

/// The Kas & Bank position table: min width 520, scrolls inside its card.
class _TabelKasBank extends StatelessWidget {
  const _TabelKasBank();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const mono = TextStyle(fontFamily: PalakatText.mono);
    const pad = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final garisAtas = BoxDecoration(
      border: Border(top: BorderSide(color: c.garis)),
    );
    final abu = TextStyle(color: c.tinta2);
    const kecil = TextStyle(fontSize: 13);

    Widget kepala(String t, {bool kanan = true}) => Padding(
      padding: pad,
      child: Text(
        t,
        textAlign: kanan ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.w600, color: c.tinta2),
      ),
    );
    Widget sel(Widget isi) => Padding(padding: pad, child: isi);
    Widget nama(String t) =>
        sel(Text(t, style: const TextStyle(fontWeight: FontWeight.w600)));
    Widget saldo(int n) =>
        sel(Text(rp(n), textAlign: TextAlign.right, style: mono));
    Widget belumIsi() => sel(
      Text.rich(
        const TextSpan(
          children: [
            TextSpan(text: '— '),
            TextSpan(text: 'Rekening koran belum diisi', style: kecil),
          ],
        ),
        textAlign: TextAlign.right,
        style: abu,
      ),
    );
    final kosong = sel(const SizedBox.shrink());

    // Inline link: a 44 × 44 target that keeps the line's height.
    const tinggiBaris = 13 * 1.45;
    final hitung = MarginNegatif(
      atas: (44 - tinggiBaris) / 2,
      bawah: (44 - tinggiBaris) / 2,
      child: Tautan(
        ke: 'WebHitungKas',
        child: const Align(
          widthFactor: 1,
          child: TautanTeks('Hitung kas', berat: FontWeight.w700, ukuran: 13),
        ),
      ),
    );

    final tabel = Table(
      defaultColumnWidth: const _LebarOtomatis(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            kepala('Kas/Bank', kanan: false),
            kepala('Saldo buku'),
            kepala('Hasil hitung kas'),
            kepala('Saldo rekening koran'),
          ],
        ),
        TableRow(
          decoration: garisAtas,
          children: [
            nama('Kas'),
            saldo(saldoNovember['kas']!),
            sel(
              DefaultTextStyle.merge(
                style: abu,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '— '),
                          TextSpan(text: 'Belum dihitung', style: kecil),
                          TextSpan(text: ' · '),
                        ],
                      ),
                    ),
                    hitung,
                  ],
                ),
              ),
            ),
            kosong,
          ],
        ),
        TableRow(
          decoration: garisAtas,
          children: [
            nama('Bank BNI ··4821'),
            saldo(saldoNovember['bni']!),
            kosong,
            belumIsi(),
          ],
        ),
        TableRow(
          decoration: garisAtas,
          children: [
            nama('Bank SulutGo ··1107'),
            saldo(saldoNovember['bsg']!),
            kosong,
            belumIsi(),
          ],
        ),
      ],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: LayoutBuilder(
        builder: (context, k) {
          final lebar = k.maxWidth < 520 ? 520.0 : k.maxWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: lebar,
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 14),
                child: tabel,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The figure tiles: `repeat(auto-fit, minmax(min(150px, 100%), 1fr))`, gap
/// 12, rows stretched to the tallest tile (grid default `align-items`).
class _KisiSama extends StatelessWidget {
  const _KisiSama({required this.anak});
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      final n = KisiOtomatis.kolom(k.maxWidth, 150, 12, anak.length);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < anak.length; i += n) ...[
            if (i > 0) const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = i; j < i + n; j++) ...[
                    if (j > i) const SizedBox(width: 12),
                    Expanded(
                      child: j < anak.length ? anak[j] : const SizedBox(),
                    ),
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

/// CSS `table-layout: auto`, roughly: columns start at their max-content
/// width, and a shortfall or surplus is shared in proportion to it, never
/// below min-content.
class _LebarOtomatis extends TableColumnWidth {
  const _LebarOtomatis();

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      cells.fold(0.0, (m, c) {
        final w = c.getMinIntrinsicWidth(double.infinity);
        return w > m ? w : m;
      });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      cells.fold(0.0, (m, c) {
        final w = c.getMaxIntrinsicWidth(double.infinity);
        return w > m ? w : m;
      });

  @override
  double? flex(Iterable<RenderBox> cells) => maxIntrinsicWidth(cells, 0);
}
