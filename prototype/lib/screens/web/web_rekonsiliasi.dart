import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/hitung.dart';
import '../../motion/kerangka.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/repositories_keuangan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../app/layar.dart';

/// One selectable row: a statement line, or a posted transaction (with its
/// No. Bukti).
typedef _Baris = ({String id, String n, String? no, String tgl, int jm});

/// Web · Rekonsiliasi (spec 03): the church bank of the next month to
/// close (`akunRekonProvider`), matched on ReconciliationRepository. A
/// selection of lines and transactions with the same sum is matched; with
/// nothing selected, "Cocokkan" takes the fixed suggestion (README 4.6
/// point 5).
class WebRekonsiliasiScreen extends ConsumerStatefulWidget {
  const WebRekonsiliasiScreen({super.key});
  @override
  ConsumerState<WebRekonsiliasiScreen> createState() => _WebRekonsiliasiState();
}

class _WebRekonsiliasiState extends ConsumerState<WebRekonsiliasiScreen> {
  Set<String> _selM = {}, _selT = {};
  Refusal? _tolak;

  void _hasil(Refusal? r) {
    if (!mounted) return;
    setState(() {
      _tolak = r;
      if (r == null) {
        _selM = {};
        _selT = {};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final id = ref.watch(akunRekonProvider);
    final r = id == null ? null : ref.watch(rekonAkunProvider(id));
    final p = ref.watch(bulanBukuProvider).berikutDitutup;
    final judulBulan = p == null ? '' : namaBulan(p);
    if (r == null || r.sesi == null) {
      return Material(
        type: MaterialType.transparency,
        child: HalamanWeb(
          layarKeuangan: true,
          nav: NavSamping(item: navKeuangan, aktif: 3),
          isi: [
            Text(
              'Rekonsiliasi · $judulBulan',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            Text(
              'Belum ada rekening koran untuk direkonsiliasi.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Tautan(
              ke: Layar.rekeningKoran,
              child: const Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: TautanTeks('Isi rekening koran'),
              ),
            ),
          ],
        ),
      );
    }
    final akunId = r.akun.id;
    final pasti = r.dipastikan;
    final berikut = bulanSesudah(r.periode);
    _Baris mutasiBaris(BarisMutasi m) => (
      id: m.baris.id,
      n: m.baris.description,
      no: null,
      tgl: '${m.baris.date}',
      jm: m.sisa,
    );
    _Baris txnBaris(Transaction t) => (
      id: t.id,
      n: t.description,
      no: t.voucher,
      tgl: '${t.effectiveDate}',
      jm: diAkun(t, akunId),
    );
    final mutasi = r.belumCocok;
    final transaksi = <Transaction>{
      for (final m in mutasi) ...m.calon,
      ...r.belumDiKoran,
    }.toList()..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));
    final selM = {..._selM.where((x) => mutasi.any((m) => m.baris.id == x))};
    final selT = {..._selT.where((x) => transaksi.any((t) => t.id == x))};

    final sm = mutasi
        .where((m) => selM.contains(m.baris.id))
        .fold(0, (a, m) => a + m.sisa);
    final st = transaksi
        .where((t) => selT.contains(t.id))
        .fold(0, (a, t) => a + diAkun(t, akunId));
    final ada = selM.isNotEmpty && selT.isNotEmpty;
    final sama = ada && sm == st;
    final saran = mutasi.where((m) => m.saran.isNotEmpty).firstOrNull;
    final pilihTeks = selM.isEmpty && selT.isEmpty
        ? (saran == null
              ? 'Pilih mutasi bank dan transaksi yang sama jumlahnya. Satu '
                    'mutasi boleh dicocokkan dengan beberapa transaksi, dan '
                    'sebaliknya.'
              : 'Saran: ${saran.baris.description} ↔ '
                    '${saran.saran.map((t) => t.voucher).join(' + ')} · '
                    'jumlah sama')
        : 'Mutasi bank dipilih ${rp(sm)} · transaksi dipilih ${rp(st)}'
              '${sama ? ' · jumlah sama' : (ada ? ' · sisa belum dicocokkan ${rp((sm - st).abs())}' : '')}';

    final nol = r.selisih == 0, habis = mutasi.isEmpty;
    final bisaPasti = r.alasanBelum == null && !pasti;
    final oleh = ref
        .watch(peopleRepositoryProvider)
        .person(r.sesi?.confirmedBy ?? '');
    final pastiAlasan = pasti
        ? 'Dipastikan oleh ${oleh?.shortName ?? oleh?.name}. Perubahan pada '
              'buku membuatnya perlu dipastikan lagi.'
        : (!nol
              ? 'Selisih belum dijelaskan harus Rp0.'
              : (!habis
                    ? 'Masih ada mutasi bank yang belum cocok.'
                    : r.alasanDiperiksa ??
                          'Selisih Rp0 dan semua mutasi bank sudah cocok.'));

    Future<void> cocokkan() async {
      if (sama) {
        _hasil(
          (await perintah(
            ref,
            (a, k) => ref
                .read(reconciliationRepositoryProvider)
                .match(
                  a,
                  r.sesi!.id,
                  selM.toList(),
                  [
                    for (final m in mutasi)
                      if (selM.contains(m.baris.id))
                        for (final t in m.cocok)
                          if (t.isPosted) t.id,
                    ...selT,
                  ],
                  expectedRevision: r.sesi!.revision,
                  idempotencyKey: k,
                ),
          ))?.refusal,
        );
      } else if (selM.isEmpty && selT.isEmpty && saran != null) {
        _hasil(await AksiRekon.cocokkan(ref, r, saran, saran.saran));
      }
    }

    _BarisPilih barisM(BarisMutasi m) {
      final draf = m.cocok.where((t) => !t.isPosted).firstOrNull;
      return _BarisPilih(
        baris: mutasiBaris(m),
        on: selM.contains(m.baris.id),
        onTap: () => setState(
          () => selM.contains(m.baris.id)
              ? _selM.remove(m.baris.id)
              : _selM.add(m.baris.id),
        ),
        aksi: draf != null
            ? 'Periksa dan bukukan'
            : m.calon.isEmpty && m.cocok.isEmpty
            ? 'Buat transaksi dari mutasi ini'
            : null,
        onAksi: draf != null
            ? () => context.dorongKe(Layar.draf, param: {'id': draf.id})
            : () async => _hasil(await AksiRekon.buatTransaksi(ref, r, m)),
      );
    }

    _BarisPilih barisT(Transaction t) => _BarisPilih(
      baris: txnBaris(t),
      on: selT.contains(t.id),
      onTap: () => setState(
        () => selT.contains(t.id) ? _selT.remove(t.id) : _selT.add(t.id),
      ),
      aksi: r.belumDiKoran.contains(t) ? 'Tandai dalam perjalanan' : null,
      onAksi: () async =>
          _hasil(await AksiRekon.dalamPerjalanan(ref, r, t, berikut)),
    );

    // Lines matched in the app (not at the statement import).
    final grup = [
      for (final m in r.mutasi)
        if (m.lunas && m.baris.revision > 1)
          _PasanganCocok(
            key: ValueKey(m.baris.id),
            m: m.baris.description,
            t: m.cocok
                .map((t) => '${t.description} · ${t.voucher}')
                .join(' + '),
            jenis: '${m.cocok.length} transaksi',
            rp: rp(m.baris.amount),
            lepas: () async =>
                _hasil(await AksiRekon.lepaskanMutasi(ref, r, m)),
          ),
    ];
    final akun = ref.watch(accountRepositoryProvider).accounts();

    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    Widget judul2(String a, String b) => Text.rich(
      TextSpan(
        children: [
          TextSpan(text: a),
          TextSpan(
            text: b,
            style: ket.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
    Widget kosong(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(t, style: TextStyle(fontSize: 14, color: c.tinta2)),
    );
    Widget kolom(List<Widget> anak) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          anak[i],
        ],
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        layarKeuangan: true,
        nav: NavSamping(item: navKeuangan, aktif: 3),
        isi: [
          // Title row.
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Rekonsiliasi '),
                      TextSpan(
                        text: '· $judulBulan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: c.tinta3,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                  // The h1's 26 px line box also holds a wrapped line of
                  // only the 15 px span (390 wide).
                  strutStyle: const StrutStyle(
                    fontFamily: PalakatText.sans,
                    fontSize: 26,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _Lencana(pasti: pasti, label: r.status),
            ],
          ),
          DeretTautan(
            web: true,
            anak: [
              Tautan(
                ke: Layar.rekeningKoran,
                child: const Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Isi rekening koran'),
                ),
              ),
              Tautan(
                ke: Layar.hitungKas,
                cara: Cara.ganti,
                child: const Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Hitung kas'),
                ),
              ),
            ],
          ),
          // Kas/Bank chips.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in akun)
                if (a.operatedByScopeId == null)
                  () {
                    final x = ref.watch(rekonAkunProvider(a.id));
                    final label = x?.dipastikan ?? false
                        ? '${a.name} · Sudah dipastikan'
                        : a.name;
                    if (a.id == akunId) {
                      return Semantics(
                        selected: true,
                        child: _Chip(
                          a.name,
                          isi: c.tinta,
                          garis: c.tinta,
                          teks: c.permukaan,
                        ),
                      );
                    }
                    return _Chip(
                      label,
                      isi: c.permukaan,
                      garis: c.garisTegas,
                      teks: c.tinta2,
                    );
                  }(),
            ],
          ),
          _KartuSaldo(
            buku: r.buku,
            pembanding: r.pembanding ?? 0,
            catatan:
                '· rekening koran ${r.amati == null ? kosong : rp(r.amati!)}'
                '${r.setor > 0 ? ' + dalam perjalanan ${rp(r.setor)}' : ''}'
                '${r.bayar > 0 ? ' − pembayaran dalam perjalanan ${rp(r.bayar)}' : ''}',
            perjalanan: r.setor > 0,
            target: r.selisih ?? 0,
            bisaPasti: bisaPasti,
            tombol: r.tombolPastikan,
            alasan: pastiAlasan,
            pastikan: () async {
              if (bisaPasti) _hasil(await AksiRekon.pastikan(ref, r));
            },
          ),
          if (_tolak != null)
            Penolakan(
              tindakan: _tolak!.action,
              sebab: _tolak!.because,
              jalan: const [],
            ),
          _BilahPilih(
            teks: pilihTeks,
            sama: sama || (selM.isEmpty && selT.isEmpty && saran != null),
            cocokkan: cocokkan,
          ),
          KisiOtomatis(
            minLebar: 440,
            jarak: 20,
            anak: [
              kolom([
                judul2('Mutasi bank ', '· belum cocok'),
                for (final m in mutasi) barisM(m),
                if (habis) kosong('Semua mutasi bank sudah cocok.'),
              ]),
              kolom([
                judul2('Transaksi ', '· sudah dibukukan, belum cocok'),
                for (final t in transaksi) barisT(t),
                if (transaksi.isEmpty)
                  kosong('Tidak ada transaksi yang belum cocok.'),
              ]),
            ],
          ),
          if (r.dalamPerjalanan.isNotEmpty)
            Gerak(
              Kerangka.muncul,
              key: const ValueKey('perjalanan'),
              lama: const Duration(milliseconds: 300),
              child: kolom([
                judul2('Dalam perjalanan ', '· dibawa ke bulan berikutnya'),
                for (final t in r.dalamPerjalanan)
                  _BarisPerjalanan(
                    t: t,
                    jumlah: diAkun(t, akunId),
                    lepas: () async => _hasil(
                      await AksiRekon.dalamPerjalanan(ref, r, t, berikut),
                    ),
                  ),
              ]),
            ),
          kolom([
            judul2('Cocok ', '· ${r.cocok} mutasi bank'),
            ...grup,
            Text(
              '${r.cocok - grup.length} mutasi bank lain sudah cocok dengan '
              'transaksinya.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ]),
        ],
      ),
    );
  }
}

/// Width of one line of text in the inherited style merged with [s].
double _lebar(BuildContext context, String teks, TextStyle s) {
  final p = TextPainter(
    text: TextSpan(
      text: teks,
      style: DefaultTextStyle.of(context).style.merge(s),
    ),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final w = p.width.ceilToDouble();
  p.dispose();
  return w;
}

/// Sedang dikerjakan / Sudah diperiksa / Sudah dipastikan, as this board
/// draws it: padding 4 10 inside a 1.5 line, transparent while not
/// confirmed.
class _Lencana extends StatelessWidget {
  const _Lencana({required this.pasti, required this.label});
  final bool pasti;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pasti ? c.laut : null,
        border: Border.all(color: pasti ? c.laut : c.tinta3, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: pasti ? c.diLaut : c.tinta2,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
    this.label, {
    required this.isi,
    required this.garis,
    required this.teks,
  });

  final String label;
  final Color isi, garis, teks;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 44),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: isi,
      border: Border.all(color: garis, width: 1.5),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Center(
      widthFactor: 1,
      heightFactor: 1,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: teks,
        ),
      ),
    ),
  );
}

/// A filled button that stays pressable; the handler re-checks its condition
/// (CONVENTIONS, TombolBersyarat deviation). Disabled look: `garis`/`tinta3`.
class _TombolIsi extends StatelessWidget {
  const _TombolIsi(
    this.teks, {
    required this.siap,
    required this.isi,
    required this.tinggi,
    required this.onTap,
  });
  final String teks;
  final bool siap;
  final Color isi;
  final double tinggi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      radius: 12,
      child: Container(
        constraints: BoxConstraints(minHeight: tinggi),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: siap ? isi : c.garis,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            teks,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: siap ? c.permukaan : c.tinta3,
            ),
          ),
        ),
      ),
    );
  }
}

/// "Lepaskan": a `laut` text button, min height 44.
class _Lepaskan extends StatelessWidget {
  const _Lepaskan({required this.onTap, this.ukuran, required this.padding});
  final VoidCallback onTap;
  final double? ukuran;
  final double padding;

  @override
  Widget build(BuildContext context) => Tekan(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          'Lepaskan',
          style: TextStyle(
            fontSize: ukuran,
            fontWeight: FontWeight.w700,
            color: context.warna.laut,
          ),
        ),
      ),
    ),
  );
}

/// Saldo buku − Saldo pembanding = Selisih belum dijelaskan, and Pastikan.
class _KartuSaldo extends StatelessWidget {
  const _KartuSaldo({
    required this.buku,
    required this.pembanding,
    required this.catatan,
    required this.perjalanan,
    required this.target,
    required this.bisaPasti,
    required this.tombol,
    required this.alasan,
    required this.pastikan,
  });
  final int buku, pembanding, target;
  final bool perjalanan, bisaPasti;
  final String tombol, alasan, catatan;
  final VoidCallback pastikan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final label = TextStyle(fontSize: 13, color: c.tinta2);
    const angka = TextStyle(
      fontFamily: PalakatText.mono,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );
    final tanda = angka.copyWith(fontWeight: FontWeight.w400, color: c.tinta3);
    final cat = catatan;
    double l(String t, TextStyle s) => _lebar(context, t, s);
    double maks(double a, double b) => a > b ? a : b;

    Widget pasangan(Widget atas, String nilai) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        atas,
        Text(nilai, style: angka),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarisLentur(
        jarak: 28,
        jarakBaris: 12,
        rata: CrossAxisAlignment.end,
        anak: [
          Lentur(
            dasar: maks(l('Saldo buku', label), l(rp(buku), angka)),
            tumbuh: 0,
            child: pasangan(Text('Saldo buku', style: label), rp(buku)),
          ),
          Lentur(
            dasar: l('−', tanda),
            tumbuh: 0,
            child: ExcludeSemantics(child: Text('−', style: tanda)),
          ),
          Lentur(
            dasar: maks(
              l('Saldo pembanding $cat', label),
              l(rp(pembanding), angka),
            ),
            tumbuh: 0,
            child: pasangan(
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Saldo pembanding '),
                    TextSpan(
                      text: cat,
                      style: TextStyle(color: c.tinta3),
                    ),
                  ],
                ),
                style: label,
              ),
              rp(pembanding),
            ),
          ),
          Lentur(
            dasar: l('=', tanda),
            tumbuh: 0,
            child: ExcludeSemantics(child: Text('=', style: tanda)),
          ),
          Lentur(
            dasar: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selisih belum dijelaskan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Hitung(
                  nilai: target,
                  builder: (ctx, tampil) => AnimatedDefaultTextStyle(
                    duration: ctx.gerak(const Duration(milliseconds: 300)),
                    curve: Curves.ease,
                    style: DefaultTextStyle.of(ctx).style.merge(
                      TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        color: tampil == 0 ? c.laut : c.bata,
                      ),
                    ),
                    child: Text(rp(tampil)),
                  ),
                ),
              ],
            ),
          ),
          Lentur(
            dasar: maks(
              l(tombol, const TextStyle(fontWeight: FontWeight.w700)) + 40,
              l(alasan, label) < 260 ? l(alasan, label) : 260,
            ),
            tumbuh: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TombolIsi(
                  tombol,
                  siap: bisaPasti,
                  isi: c.laut,
                  tinggi: 48,
                  onTap: pastikan,
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(alasan, style: label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The draf-line bar with the selection sentence and "Cocokkan".
class _BilahPilih extends StatelessWidget {
  const _BilahPilih({
    required this.teks,
    required this.sama,
    required this.cocokkan,
  });
  final String teks;
  final bool sama;
  final VoidCallback cocokkan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(c.putus, radius: 14),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Align(
          alignment: Alignment.centerLeft,
          child: BarisLentur(
            jarak: 12,
            rata: CrossAxisAlignment.center,
            anak: [
              Lentur(
                dasar: 320,
                child: Text(
                  teks,
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ),
              Lentur(
                dasar:
                    _lebar(
                      context,
                      'Cocokkan',
                      const TextStyle(fontWeight: FontWeight.w700),
                    ) +
                    40,
                tumbuh: 0,
                child: _TombolIsi(
                  'Cocokkan',
                  siap: sama,
                  isi: c.tinta,
                  tinggi: 44,
                  onTap: cocokkan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A mutation or transaction row with its checkbox; [aksi] is the side action.
class _BarisPilih extends StatelessWidget {
  const _BarisPilih({
    required this.baris,
    required this.on,
    required this.onTap,
    this.aksi,
    this.onAksi,
  });
  final _Baris baris;
  final bool on;
  final VoidCallback onTap;
  final String? aksi;
  final VoidCallback? onAksi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final r = baris;
    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: ShapeDecoration(
        color: on ? c.lautLembut : c.permukaan,
        shape: GarisBorder.penuh(
          on ? c.laut : c.garis,
          tebal: on ? 1.5 : 1,
          radius: 12,
        ),
      ),
      // The board's side action is `flex: none`; it is capped so the row
      // keeps room for the checkbox, the amount and 80 px of name (390 wide).
      child: LayoutBuilder(
        builder: (context, k) => _isi(
          context,
          k.maxWidth - 8 - 78 - _lebar(context, rp(r.jm), _angka) - 80,
          ket,
        ),
      ),
    );
  }

  static const _angka = TextStyle(
    fontFamily: PalakatText.mono,
    fontWeight: FontWeight.w500,
  );
  static const _aksi = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);

  Widget _isi(BuildContext context, double maksAksi, TextStyle ket) {
    final c = context.warna;
    final r = baris;
    // The board's row is `align-items: stretch`: the side action fills the
    // row height less its 8 px margins.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Tekan(
              onTap: onTap,
              radius: 12,
              peran: PeranTekan.sakelar,
              tercentang: on,
              child: Container(
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: on ? c.tinta : c.permukaan,
                        border: Border.all(color: c.tinta, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: PalakatIkon(
                        Ikon.centang,
                        ukuran: 14,
                        tebal: 3.4,
                        warna: c.permukaan,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.n,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          r.no == null
                              ? Text(r.tgl, style: ket)
                              : Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: r.no,
                                        style: const TextStyle(
                                          fontFamily: PalakatText.mono,
                                        ),
                                      ),
                                      TextSpan(text: ' · ${r.tgl}'),
                                    ],
                                  ),
                                  style: ket,
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(rp(r.jm), style: _angka),
                  ],
                ),
              ),
            ),
          ),
          if (aksi != null)
            Container(
              width:
                  8 +
                  math.min(
                    _lebar(context, aksi!, _aksi) + 27,
                    math.max(44, maksAksi),
                  ),
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              child: Tekan(
                onTap: onAksi,
                radius: 10,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: c.permukaan,
                    border: Border.all(color: c.tinta, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    // CSS half-leading, so a wrapped label (390 wide) stays
                    // off the bottom border.
                    child: Text(
                      aksi!,
                      style: _aksi,
                      textHeightBehavior: const TextHeightBehavior(
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The deposit in transit: a draf-line row with "Lepaskan".
class _BarisPerjalanan extends StatelessWidget {
  const _BarisPerjalanan({
    required this.t,
    required this.jumlah,
    required this.lepas,
  });
  final Transaction t;
  final int jumlah;
  final VoidCallback lepas;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(c.putus, radius: 12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: jumlah > 0
                          ? 'Setoran dalam perjalanan'
                          : 'Pembayaran dalam perjalanan',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                      children: [
                        const TextSpan(text: '· '),
                        TextSpan(
                          // Chrome breaks the code after its hyphens.
                          text: t.voucher?.replaceAll('-', '-\u200B'),
                          style: const TextStyle(fontFamily: PalakatText.mono),
                        ),
                        TextSpan(text: ' · ${t.effectiveDate}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              rp(jumlah.abs()),
              style: const TextStyle(
                fontFamily: PalakatText.mono,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            _Lepaskan(onTap: lepas, padding: 12),
          ],
        ),
      ),
    );
  }
}

/// A matched group: the bank card slides in from the left, the transaction
/// card from the right, and the link badge pops (`kait`) between them.
class _PasanganCocok extends StatelessWidget {
  const _PasanganCocok({
    super.key,
    required this.m,
    required this.t,
    required this.jenis,
    required this.rp,
    required this.lepas,
  });
  final String m, t, jenis, rp;
  final VoidCallback lepas;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    const nama = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    const angka = TextStyle(
      fontFamily: PalakatText.mono,
      fontWeight: FontWeight.w500,
    );
    Widget kartu(Widget child) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.laut, radius: 12),
      ),
      child: child,
    );
    Widget masuk(Bingkai k, Widget child) => Gerak(
      k,
      lama: PalakatMotion.kait,
      kurva: PalakatMotion.keluar,
      child: child,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: masuk(
                  Kerangka.dariKiri(60),
                  kartu(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mutasi bank', style: ket),
                        Text(m, style: nama),
                        Text(rp, style: angka),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: masuk(
                  Kerangka.dariKanan(60),
                  kartu(
                    // "Lepaskan" is capped as in [_BarisPilih]: 24 stay for
                    // the names.
                    LayoutBuilder(
                      builder: (context, k) => Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Transaksi · $jenis', style: ket),
                                Text(t, style: nama),
                                Text(rp, style: angka),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: k.maxWidth - 32 < 44
                                  ? 44
                                  : k.maxWidth - 32,
                            ),
                            child: _Lepaskan(
                              onTap: lepas,
                              ukuran: 14,
                              padding: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Gerak(
            Kerangka.kait,
            lama: const Duration(milliseconds: 400),
            tunda: const Duration(milliseconds: 400),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: c.laut, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: PalakatIkon(Ikon.kait, ukuran: 15, warna: c.diLaut),
            ),
          ),
        ],
      ),
    );
  }
}
