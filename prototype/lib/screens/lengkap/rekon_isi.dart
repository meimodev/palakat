import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/repositories_keuangan.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tahapan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// 30 · Rekonsiliasi: isi rekening koran dan cocok sebagian (spec 09).
class RekonIsiScreen extends ConsumerStatefulWidget {
  const RekonIsiScreen({super.key});
  @override
  ConsumerState<RekonIsiScreen> createState() => _RekonIsiState();
}

class _RekonIsiState extends ConsumerState<RekonIsiScreen> with RekonIsiLogika {
  @override
  Widget build(BuildContext context) {
    final b = bagian(context);
    return LayarPonsel(
      layarKeuangan: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Rekonsiliasi',
            anakJudul: judulAkun,
            kembaliKe: Layar.tutupBuku,
            labelKembali: 'Kembali ke Bulan',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: kolomRekon([
                b.isian,
                b.daftar,
                b.tahap,
                b.sisa,
                ...b.akhir,
              ], 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// Column with a CSS `gap`.
Widget kolomRekon(
  List<Widget> anak,
  double jarak, {
  CrossAxisAlignment rata = CrossAxisAlignment.stretch,
}) => Column(
  crossAxisAlignment: rata,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (var i = 0; i < anak.length; i++) ...[
      if (i > 0) SizedBox(height: jarak),
      anak[i],
    ],
  ],
);

/// The parts both boards place: RekonIsi stacks them, WebRekonIsi splits
/// them into two columns.
typedef BagianRekon = ({
  Widget isian,
  Widget daftar,
  Widget tahap,
  Widget sisa,
  List<Widget> akhir,
});

/// The logic shared by RekonIsi and WebRekonIsi: the bank statement of the
/// church bank that still lacks one for the next month to close
/// (`akunRekeningKoranProvider`), its lines and matches from
/// ReconciliationRepository, and the parts. Each screen owns its instance.
mixin RekonIsiLogika<W extends ConsumerStatefulWidget> on ConsumerState<W> {
  final _saldo = TextEditingController();
  final _fu = TextEditingController();
  final _fj = TextEditingController();
  Refusal? _tolak;
  String? _akunAwal;

  @override
  void dispose() {
    _saldo.dispose();
    _fu.dispose();
    _fj.dispose();
    super.dispose();
  }

  /// The account chosen when the screen opened (it stays while it works).
  RekonAkun? get _r {
    _akunAwal ??= ref.read(akunRekeningKoranProvider);
    final id = _akunAwal;
    return id == null ? null : ref.watch(rekonAkunProvider(id));
  }

  String get judulAkun {
    final r = _r;
    return r == null ? '' : '${r.akun.name} · ${namaBulan(r.periode)}';
  }

  int? get _saldoKetik => angkaDari(_saldo.text);

  bool get _okF => _fu.text.trim().isNotEmpty && (angkaDari(_fj.text) ?? 0) > 0;

  /// Rule A02: the first unmet field, named by its label on the board.
  String get _alasanF => _fu.text.trim().isEmpty
      ? 'Uraian mutasi belum diisi.'
      : _okF
      ? ''
      : 'Jumlah mutasi belum diisi.';

  Future<void> _hasil(Result<Object?>? r) async {
    if (mounted) setState(() => _tolak = r?.refusal);
  }

  /// Sets the closing and adds [contoh]'s lines.
  Future<Result<ReconSession>?> _impor(RekonAkun r, SampleStatement contoh) =>
      perintah(
        ref,
        (a, k) => ref
            .read(reconciliationRepositoryProvider)
            .importStatement(
              a,
              r.akun.id,
              r.periode.id,
              contoh,
              idempotencyKey: k,
            ),
      );

  Future<void> _unggah(RekonAkun r) async {
    final saldo = _saldoKetik;
    if (saldo == null) {
      setState(
        () => _tolak = const Refusal(
          action: 'Unggah mutasi',
          because: 'Saldo rekening koran belum diisi.',
        ),
      );
      return;
    }
    await _hasil(await _impor(r, sampelRekeningKoran(r, saldo)));
  }

  Future<void> _tambahMutasi(RekonAkun r) async {
    final saldo = _saldoKetik;
    if (!_okF) return;
    if (saldo == null) {
      setState(
        () => _tolak = const Refusal(
          action: 'Tambah',
          because: 'Saldo rekening koran belum diisi.',
        ),
      );
      return;
    }
    final hasil = await _impor(
      r,
      SampleStatement(
        fileName: '',
        closing: saldo,
        lines: [
          (
            date: r.periode.end,
            description: _fu.text.trim(),
            amount: angkaDari(_fj.text)!,
          ),
        ],
      ),
    );
    if (hasil?.isOk ?? false) {
      _fu.clear();
      _fj.clear();
    }
    await _hasil(hasil);
  }

  Future<void> _cocokkan(RekonAkun r, BarisMutasi m, Transaction t) async =>
      _hasil(
        await perintah(
          ref,
          (a, k) => ref
              .read(reconciliationRepositoryProvider)
              .match(
                a,
                r.sesi!.id,
                [m.baris.id],
                [
                  for (final x in m.cocok)
                    if (x.isPosted) x.id,
                  t.id,
                ],
                expectedRevision: r.sesi!.revision,
                idempotencyKey: k,
              ),
        ),
      );

  Future<void> _lepaskan(RekonAkun r, BarisMutasi m) async => _hasil(
    await perintah(
      ref,
      (a, k) => ref
          .read(reconciliationRepositoryProvider)
          .match(
            a,
            r.sesi!.id,
            [m.baris.id],
            const [],
            expectedRevision: r.sesi!.revision,
            idempotencyKey: k,
          ),
    ),
  );

  /// "Pastikan rekonsiliasi" (or, with the second checker, "Tandai sudah
  /// diperiksa"): the typed closing first when it changed.
  Future<void> _pastikan(RekonAkun r) async {
    final saldo = _saldoKetik;
    var x = r;
    if (saldo != null && saldo != r.amati) {
      final h = await _impor(
        r,
        SampleStatement(fileName: '', closing: saldo, lines: const []),
      );
      if (h == null || !h.isOk) return _hasil(h);
      x = ref.read(rekonAkunProvider(r.akun.id))!;
    }
    final tolak = await AksiRekon.pastikan(ref, x);
    if (mounted) setState(() => _tolak = tolak);
  }

  BagianRekon bagian(BuildContext context) {
    final c = context.warna;
    final r = _r;
    const t14 = TextStyle(fontSize: 14);
    if (r == null) {
      final kosong = Text(
        'Tidak ada rekening bank yang perlu diisi rekening korannya.',
        style: t14.copyWith(color: c.tinta2),
      );
      return (
        isian: kosong,
        daftar: const SizedBox.shrink(),
        tahap: const SizedBox.shrink(),
        sisa: const SizedBox.shrink(),
        akhir: const [],
      );
    }
    if (_saldo.text.isEmpty && r.amati != null) {
      _saldo.text = titik('${r.amati}');
    }
    final s = r.sesi;
    final pasti = r.dipastikan;
    final basi =
        pasti &&
        ref
            .watch(periodRepositoryProvider)
            .blockers(r.periode.id)
            .any(
              (b) =>
                  b.kind == BlockerKind.notReconciled &&
                  b.accountId == r.akun.id,
            );
    // The Pemeriksa kedua reads and marks; only the Bendahara types.
    final kerja =
        ref.watch(bisaMencocokkanProvider) &&
        ((!pasti && !r.diperiksa) || basi);
    final daftar = r.mutasi;
    final sisaTotal = daftar.fold(0, (a, m) => a + m.sisa.abs());
    final okSaldo = _saldo.text.isNotEmpty;
    final siap = okSaldo && daftar.isNotEmpty && r.belumCocok.isEmpty;
    final alasan = !okSaldo
        ? 'Saldo rekening koran belum diisi.'
        : daftar.isEmpty
        ? 'Belum ada mutasi bank.'
        : r.belumCocok.isNotEmpty
        ? 'Masih ada mutasi bank yang belum cocok seluruhnya.'
        : r.alasanDiperiksa ??
              'Semua mutasi bank cocok dan selisih belum dijelaskan Rp0.';
    final file = s?.statementFile;
    final cocok = daftar.where((m) => m.lunas).length;

    final isian = Kartu(
      padding: const EdgeInsets.all(16),
      child: kolomRekon([
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IsianSaldo(
              controller: _saldo,
              onChanged: (_) => setState(() {}),
              hanyaBaca: !kerja,
            ),
            const SizedBox(height: 4),
            Text(
              okSaldo
                  ? 'Saldo rekening koran per ${r.periode.end}'
                  : 'Rekening koran belum diisi. Kosong bukan Rp0.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: okSaldo ? c.tinta2 : c.bata,
              ),
            ),
          ],
        ),
        if (file == null && kerja)
          Tombol(
            'Unggah mutasi dari file CSV',
            onPressed: () => _unggah(r),
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
          ),
        if (file != null)
          Gerak(
            Kerangka.muncul,
            lama: const Duration(milliseconds: 300),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: file,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.tinta,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' · ${daftar.length} mutasi dibaca. '
                        '${cocok == 0 ? 'Belum ada yang dicocokkan.' : '$cocok sudah cocok.'}',
                  ),
                ],
              ),
              style: t14.copyWith(color: c.tinta2),
            ),
          ),
        if (_tolak != null)
          Penolakan(
            tindakan: _tolak!.action,
            sebab: _tolak!.because,
            jalan: const [],
            ukuranTeks: 14,
          ),
        if (kerja)
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            ),
            child: kolomRekon([
              Text(
                'Atau ketik satu mutasi',
                style: t14.copyWith(color: c.tinta2),
              ),
              IsianTeks(
                controller: _fu,
                petunjuk: 'Uraian di rekening koran',
                labelSemantik: 'Uraian mutasi',
                onChanged: (_) => setState(() {}),
              ),
              // Rule A02: the TombolBersyarat sentence the board lacks, above
              // the row (the outlined button and its row are the board's).
              if (_alasanF.isNotEmpty &&
                  (_fu.text.isNotEmpty || _fj.text.isNotEmpty))
                Penolakan(
                  tindakan: 'Tambah',
                  sebab: _alasanF,
                  jalan: const [],
                  ukuranTeks: 14,
                ),
              Row(
                children: [
                  Expanded(
                    child: IsianTeks(
                      controller: _fj,
                      petunjuk: 'Jumlah masuk',
                      labelSemantik: 'Jumlah mutasi',
                      keyboardType: TextInputType.number,
                      formatters: const [RupiahInputFormatter()],
                      gaya: const TextStyle(fontFamily: PalakatText.mono),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TekanAria(
                    onTap: () => _tambahMutasi(r),
                    aktif: _okF,
                    petunjuk: _okF ? null : _alasanF,
                    radius: 12,
                    child: RupaTombol(
                      label: 'Tambah',
                      isi: c.permukaan,
                      garis: GarisBorder.penuh(c.tinta, radius: 12),
                      warnaTeks: c.tinta,
                      radius: 12,
                      tinggi: 48,
                      paddingH: 16,
                      lebarPenuh: false,
                    ),
                  ),
                ],
              ),
            ], 8),
          ),
      ], 12),
    );

    final Widget daftarW = daftar.isEmpty
        ? Container(
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              shape: GarisBorder.putus(c.putus, radius: 14),
            ),
            child: Text(
              'Belum ada mutasi bank. Unggah file CSV dari bank, atau ketik satu per satu.',
              style: t14.copyWith(color: c.tinta2),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final m in daftar)
                Padding(
                  key: ValueKey(m.baris.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _kartuMutasi(c, r, m, kerja),
                ),
            ],
          );

    final tahap = Tahapan(
      langkah: r.tahapan,
      selesai: basi ? r.tahapan.length - 1 : r.tahapSelesai,
    );

    final sisa = Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.tinta, width: 1.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Expanded(
            child: Text(
              'Sisa belum dicocokkan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            rp(sisaTotal),
            style: TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: sisaTotal == 0 && daftar.isNotEmpty ? c.laut : c.bata,
            ),
          ),
        ],
      ),
    );

    const muncul = Duration(milliseconds: 300);
    final oleh = ref
        .watch(peopleRepositoryProvider)
        .person(s?.confirmedBy ?? '');
    final akhir = <Widget>[
      if (basi)
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('invalid'),
          lama: muncul,
          child: Kartu(
            status: GarisStatus.hambatan,
            child: kolomRekon(
              [
                Text(
                  'Perlu dipastikan lagi',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
                ),
                Text(
                  'Buku ${namaBulan(r.periode)} berubah setelah rekonsiliasi dipastikan. Pencocokan tetap tersimpan; hanya kepastiannya yang tidak berlaku lagi, dan ini menjadi hambatan tutup buku.',
                  style: t14.copyWith(color: c.tinta2),
                ),
                Tombol(
                  'Pastikan lagi',
                  onPressed: () => _pastikan(r),
                  ukuran: UkuranTombol.ringkas,
                  lebarPenuh: false,
                ),
              ],
              8,
              rata: CrossAxisAlignment.start,
            ),
          ),
        ),
      if (pasti && !basi)
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('pasti'),
          lama: muncul,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: c.lautLembut,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Sudah dipastikan oleh ${oleh?.shortName ?? oleh?.name}, '
              '${s?.confirmedAt == null ? '' : tgl(s!.confirmedAt!)}. '
              'Perubahan pada buku ${namaBulan(r.periode)} membuatnya perlu '
              'dipastikan lagi.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      if (!pasti) ...[
        Text(alasan, style: t14.copyWith(color: c.tinta2)),
        TekanAria(
          onTap: () {
            if (siap) _pastikan(r);
          },
          aktif: siap,
          radius: 14,
          child: RupaTombol(
            label: r.tombolPastikan,
            isi: siap ? c.laut : c.garis,
            warnaTeks: siap ? c.diLaut : c.tinta3,
            radius: 14,
            tinggi: 52,
            paddingH: 20,
          ),
        ),
      ],
    ];

    return (
      isian: isian,
      daftar: daftarW,
      tahap: tahap,
      sisa: sisa,
      akhir: akhir,
    );
  }

  Widget _kartuMutasi(PalakatWarna c, RekonAkun r, BarisMutasi m, bool kerja) {
    final p = m.cocok;
    final sisa = m.sisa;
    final cocok = sisa == 0;
    final (lencana, isi, teks, garis) = cocok
        ? ('Cocok', c.laut, c.diLaut, c.laut)
        : p.isNotEmpty
        ? ('Sebagian cocok', c.permukaan, c.tinta, c.tinta)
        : ('Belum cocok', c.permukaan, c.tinta2, c.tinta3);
    final calon = kerja ? m.calon : const <Transaction>[];
    const t13 = TextStyle(fontSize: 13);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: cocok
            ? GarisBorder.penuh(c.laut, radius: 14)
            : GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: kolomRekon([
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: ShapeDecoration(
                  color: isi,
                  shape: GarisBorder.penuh(garis, radius: 6),
                ),
                child: Text(
                  lencana,
                  style: t13.copyWith(fontWeight: FontWeight.w700, color: teks),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              rp(m.baris.amount),
              style: const TextStyle(
                fontFamily: PalakatText.mono,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${m.baris.description} '),
              TextSpan(
                text: '· ${m.baris.date}',
                style: t13.copyWith(
                  color: c.tinta3,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        if (sisa != 0 && p.isNotEmpty)
          Text(
            'sisa belum dicocokkan: ${rp(sisa.abs())}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        for (final t in p)
          Gerak(
            Kerangka.muncul,
            key: ValueKey(t.id),
            lama: const Duration(milliseconds: 300),
            child: Text(
              '↔ ${t.voucher ?? 'Draf'} · ${t.description} · ${rp(diAkun(t, r.akun.id) == 0 ? signedAmount(t) : diAkun(t, r.akun.id))}',
              style: t13.copyWith(
                fontFamily: PalakatText.mono,
                color: c.tinta2,
              ),
            ),
          ),
        // The action wrapper is always there, so it always adds one gap.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final t in calon)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 8),
                child: Tekan(
                  onTap: () => _cocokkan(r, m, t),
                  radius: 10,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: ShapeDecoration(
                      color: c.permukaan,
                      shape: GarisBorder.penuh(c.tinta, radius: 10),
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: _IsiCocokkan(
                        '${t.voucher} · ${rp(diAkun(t, r.akun.id))}',
                      ),
                    ),
                  ),
                ),
              ),
            if (p.isNotEmpty && kerja)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Tekan(
                  onTap: () => _lepaskan(r, m),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Text(
                        'Lepaskan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: c.laut,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (p.isEmpty && m.calon.isEmpty)
          Text(
            'Belum ada transaksinya. Buat transaksi dari mutasi ini, atau periksa lagi rekening korannya.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
      ], 6),
    );
  }
}

/// The inside of a "Cocokkan · …" button. The board's button is inline-flex,
/// so "Cocokkan ·" and the mono span are two flex items that shrink in
/// proportion to their own widths and wrap separately.
class _IsiCocokkan extends StatelessWidget {
  const _IsiCocokkan(this.kode);
  final String kode;

  @override
  Widget build(BuildContext context) {
    final gaya = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 13, fontWeight: FontWeight.w700));
    final mono = gaya.copyWith(fontFamily: PalakatText.mono);
    final skala = MediaQuery.textScalerOf(context);
    int lebar(String t, TextStyle s) {
      final tp = TextPainter(
        text: TextSpan(text: t, style: s),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = (tp.width * 100).ceil();
      tp.dispose();
      return w;
    }

    const awal = 'Cocokkan ·';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: lebar(awal, gaya),
          child: Text(awal, style: gaya),
        ),
        const SizedBox(width: 4),
        Flexible(
          flex: lebar(kode, mono),
          child: Text(kode, style: mono),
        ),
      ],
    );
  }
}

/// The saldo field: IsianJumlah at 26 px, but the board keeps 12 digits
/// (`slice(0, 12)`) and IsianJumlah's formatter stops at 11.
// ponytail: drop for IsianJumlah(ukuran: sedang, petunjuk: '—') once it takes `maks`.
class _IsianSaldo extends StatefulWidget {
  const _IsianSaldo({
    required this.controller,
    required this.onChanged,
    required this.hanyaBaca,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hanyaBaca;

  @override
  State<_IsianSaldo> createState() => _IsianSaldoState();
}

class _IsianSaldoState extends State<_IsianSaldo> {
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(_ubah);
  }

  void _ubah() => setState(() {});

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final angka = dasar.copyWith(
      fontFamily: PalakatText.mono,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: 26,
      fontWeight: FontWeight.w500,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: GestureDetector(
            onTap: _fokus.requestFocus,
            child: Text(
              'Saldo rekening koran',
              strutStyle: StrutStyle.fromTextStyle(dasar),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ExcludeSemantics(
                child: Text(
                  'Rp',
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 18,
                    color: c.tinta3,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Semantics(
                  label: 'Saldo rekening koran',
                  child: CincinFokus(
                    tampil: _fokus.hasFocus,
                    // Rule X03: the field measured 43.6; the 0.4 goes below
                    // the top-aligned line, so the figure stays put.
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Material(
                        type: MaterialType.transparency,
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _fokus,
                          onChanged: widget.onChanged,
                          readOnly: widget.hanyaBaca,
                          keyboardType: TextInputType.number,
                          inputFormatters: const [
                            RupiahInputFormatter(maks: 12),
                          ],
                          textAlignVertical: TextAlignVertical.top,
                          style: angka,
                          cursorColor: c.laut,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            // min-height 44 with the line centred, as in Chrome.
                            contentPadding: EdgeInsets.symmetric(
                              vertical: ((44 - 26 * (dasar.height ?? 1.4)) / 2)
                                  .clamp(0, 22),
                            ),
                            hintText: '—',
                            hintStyle: angka.copyWith(color: c.tinta3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
