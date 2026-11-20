import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderTable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/repositories_keuangan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/butir_perhatian.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// Web · Beranda (docs/build/screens/02-awal.md): the Bendahara's laptop
/// home, read from [berandaKeuanganProvider] (the same read model as Main;
/// tablet shows it as TabBeranda). An empty running month shows the board's
/// `sepi` box.
class WebBerandaScreen extends ConsumerWidget {
  const WebBerandaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final b = ref.watch(berandaKeuanganProvider);
    final berjalan = b.bulan.berjalan;
    final ini = b.bulanIni;
    final sepi = ini == null || ini.dibukukan + ini.draf == 0;
    final namaIni = berjalan == null ? '' : namaBulan(berjalan);
    const mono = TextStyle(fontFamily: PalakatText.mono);
    final tindakan = b.perluTindakan;

    final bulan = Tautan(
      ke: Layar.pilihBulan,
      radius: 22,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: ShapeDecoration(
          color: c.permukaan,
          shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 22),
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            berjalan == null
                ? 'Pilih bulan'
                : '$namaIni · ${berjalan.isClosed ? 'Sudah ditutup' : 'Belum ditutup'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
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

    Widget tautanTeks(String teks, {required Layar ke}) => Tautan(
      ke: ke,
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 1,
        child: TautanTeks(teks),
      ),
    );

    Widget aksi(
      String label, {
      required Layar ke,
      String? anak,
      bool utama = true,
    }) => Tombol(
      label,
      onPressed: null,
      ke: ke,
      anak: anak,
      cara: ke == Layar.laporan ? Cara.dorong : Cara.ganti,
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
          rp(b.saldoBuku),
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
        if (b.drafJumlah > 0) ...[
          const SizedBox(height: 14), // gap 6 + margin-top 8
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: ShapeDecoration(
              shape: GarisBorder.putus(c.putus, radius: 999),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: rp(b.drafRp), style: mono),
                  TextSpan(text: ' · ${b.drafJumlah} draf · belum masuk saldo'),
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
            rp(v),
            // CSS has no break point inside the figure: it overflows the
            // narrow tile instead of splitting.
            softWrap: false,
            overflow: TextOverflow.visible,
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
        if (tindakan.isNotEmpty) ...[
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
                    judul: t.judul,
                    keterangan: t.sub,
                    ke: t.ke,
                    param: t.param,
                    cara: Cara.ganti,
                    warnaKeterangan: t.penting ? c.bata : null,
                    pertama: i == 0,
                    web: true,
                  ),
              ],
            ),
          ),
        ],
        if (sepi) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: ShapeDecoration(
              shape: GarisBorder.putus(c.putus, radius: 14),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    // The month word alone, as drawn ("di November.").
                    text:
                        'Belum ada transaksi di '
                        '${berjalan == null ? 'bulan ini' : namaIni.split(' ').first}.',
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
          ),
        ],
        for (final (i, t) in b.untukDiketahui.indexed)
          // Not ButirPerhatian: its 44 px link box would push the line
          // 12 px lower than the board's inline link.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (i == 0) ...[
                const SizedBox(height: 20), // gap 12 + margin-top 8
                const JudulBagian('Untuk diketahui', web: true),
              ],
              const SizedBox(height: 6),
              _TautanSebaris(
                ke: t.ke,
                param: t.param,
                cara: Cara.ganti,
                tinggiBaris: 14 * 1.45,
                child: TautanTeks(
                  '${t.judul} · ${t.sub}',
                  berat: FontWeight.w400,
                  ukuran: 14,
                  warna: c.tinta2,
                ),
              ),
            ],
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
                  text: '· $namaIni',
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
        _TabelKasBank(kasBank: b.kasBank, periodeId: berjalan?.id),
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
        layarKeuangan: true,
        jarak: 24,
        nav: const NavSamping(item: navKeuangan, aktif: 0),
        isi: [
          kepala,
          DeretTautan(
            web: true,
            anak: [
              tautanTeks('Pemberitahuan', ke: Layar.pemberitahuan),
              tautanTeks('Cari dan tanya', ke: Layar.cari),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              aksi('+ Pendapatan', ke: Layar.transaksi),
              aksi('− Belanja', ke: Layar.transaksi),
              aksi('+ Persembahan', ke: Layar.transaksi),
              aksi(
                'Rekonsiliasi',
                ke: Layar.tutupBuku,
                anak: 'rekonsiliasi',
                utama: false,
              ),
              aksi('Buat laporan sementara', ke: Layar.laporan, utama: false),
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
                    ini?.pendapatan ?? 0,
                    'tanpa titipan',
                  ),
                  petak(
                    'Belanja bulan ini',
                    ini?.belanja ?? 0,
                    'tanpa titipan',
                  ),
                  petak(
                    'Surplus/Defisit bulan ini',
                    ini?.surplus ?? 0,
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
/// Each active Kas/Bank: its book balance, the running month's cash count
/// (Kas) and statement closing (Bank), "—" while not known.
class _TabelKasBank extends ConsumerWidget {
  const _TabelKasBank({required this.kasBank, required this.periodeId});

  final List<SaldoAkun> kasBank;
  final String? periodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final rekon = ref.watch(reconciliationRepositoryProvider);
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
    // Body rows carry a 1 px top border that takes layout space on the board;
    // a TableRow decoration does not, so the cell pads it.
    Widget sel(Widget isi) =>
        Padding(padding: pad.copyWith(top: 13), child: isi);
    Widget nama(String t) =>
        sel(Text(t, style: const TextStyle(fontWeight: FontWeight.w600)));
    Widget angka(int n) =>
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
    final belumHitung = sel(
      DefaultTextStyle.merge(
        style: abu,
        child: const Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '— '),
                  TextSpan(text: 'Belum dihitung', style: kecil),
                  TextSpan(text: ' · '),
                ],
              ),
              textAlign: TextAlign.right,
            ),
            _hitung,
          ],
        ),
      ),
    );

    Table tabel(double lebar) => Table(
      defaultColumnWidth: _LebarOtomatis(lebar),
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
        for (final (:akun, :saldo) in kasBank)
          TableRow(
            decoration: garisAtas,
            children: [
              nama(akun.name),
              angka(saldo),
              if (akun.type == AccountType.cash) ...[
                switch (rekon
                    .cashCounts(akun.id)
                    .where((h) => h.periodId == periodeId)
                    .lastOrNull) {
                  final h? => angka(h.total),
                  null => belumHitung,
                },
                kosong,
              ] else ...[
                kosong,
                switch (periodeId == null
                    ? null
                    : rekon.session(akun.id, periodeId!)?.statementClosing) {
                  final n? => angka(n),
                  null => belumIsi(),
                },
              ],
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
                child: tabel(lebar),
              ),
            ),
          );
        },
      ),
    );
  }
}

const _hitung = _TautanSebaris(
  ke: Layar.hitungKas,
  tinggiBaris: 14 * 1.45, // the cell's 14 px line box
  child: TautanTeks('Hitung kas', berat: FontWeight.w700, ukuran: 13),
);

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

/// CSS `table-layout: auto` (Chrome): a table narrower than the sum of the
/// columns' max-content widths gives each column its min-content width plus
/// the same share of its (max − min); a wider one scales max-content up.
/// Every column is given its final width here, because [RenderTable]'s own
/// shrinking is not proportional.
class _LebarOtomatis extends TableColumnWidth {
  const _LebarOtomatis(this.lebar);

  /// The table's width (its card, at least 520).
  final double lebar;

  static double _terlebar(Iterable<RenderBox> sel, {required bool min}) =>
      sel.fold(0.0, (m, c) {
        final w = min
            ? c.getMinIntrinsicWidth(double.infinity)
            : c.getMaxIntrinsicWidth(double.infinity);
        return w > m ? w : m;
      });

  double _lebarKolom(Iterable<RenderBox> cells) {
    final tabel = cells.first.parent! as RenderTable;
    final kolom = [for (var x = 0; x < tabel.columns; x++) tabel.column(x)];
    final mins = [for (final k in kolom) _terlebar(k, min: true)];
    final maks = [for (final k in kolom) _terlebar(k, min: false)];
    final i = kolom.indexWhere((k) => k.first == cells.first);
    final sMin = mins.fold(0.0, (a, b) => a + b);
    final sMaks = maks.fold(0.0, (a, b) => a + b);
    if (lebar >= sMaks) return maks[i] * lebar / sMaks;
    if (lebar <= sMin) return mins[i];
    return mins[i] + (maks[i] - mins[i]) * (lebar - sMin) / (sMaks - sMin);
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      _lebarKolom(cells);

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      _lebarKolom(cells);
}

/// An inline text link with a 44 px high target that keeps its line
/// height, also when it wraps.
class _TautanSebaris extends StatelessWidget {
  const _TautanSebaris({
    required this.ke,
    required this.tinggiBaris,
    required this.child,
    this.param = const {},
    this.cara = Cara.dorong,
  });

  final Layar ke;
  final Map<String, String> param;
  final Cara cara;
  final double tinggiBaris;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sisa = (44 - tinggiBaris) / 2;
    return MarginNegatif(
      atas: sisa,
      bawah: sisa,
      child: Tautan(
        ke: ke,
        param: param,
        cara: cara,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: sisa),
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: child,
          ),
        ),
      ),
    );
  }
}
