import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/batang_pembagian.dart';
import '../../widgets/garis.dart';
import '../../widgets/input_format.dart';
import '../../widgets/isian_jumlah.dart';
import '../../widgets/kartu_kasus.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/keuangan/kasus.dart';
import '../../providers/repositories_keuangan.dart';
import '../../widgets/penolakan.dart';

typedef _Label = ({
  String tab,
  String pihak,
  String awal,
  String sisa,
  String cat,
  List<String> st,
  String kaki,
});

const Map<String, _Label> _lbl = {
  'um': (
    tab: 'Uang Muka',
    pihak: 'Diberikan kepada',
    awal: 'Uang Muka diberikan',
    sisa: 'Sisa belum dipertanggungjawabkan',
    cat: 'Uang muka bukan Belanja saat diberikan.',
    st: [
      'Belum dipertanggungjawabkan',
      'Sebagian dipertanggungjawabkan',
      'Sudah dipertanggungjawabkan',
    ],
    kaki:
        'Pertanggungjawaban yang diterima menjadi Belanja. Pengembalian sisa '
        'kembali ke Kas dan bukan Pendapatan.',
  ),
  'tt': (
    tab: 'Titipan',
    pihak: 'Titipan untuk',
    awal: 'Terkumpul',
    sisa: 'Sisa belum disalurkan',
    cat: 'Uang titipan untuk pihak lain, bukan Pendapatan dan bukan Belanja.',
    st: ['Belum disalurkan', 'Sebagian disalurkan', 'Sudah disalurkan'],
    kaki:
        'Sentralisasi dari uang milik sendiri dicatat sebagai Belanja biasa, '
        'tidak di sini.',
  ),
  'pb': (
    tab: 'Penggantian biaya',
    pihak: 'Dibayar kepada',
    awal: 'Klaim',
    sisa: 'Belum dibayar',
    cat: 'Klaim belum masuk saldo sampai dibayar.',
    st: ['Belum dibayar', 'Belum dibayar', 'Sudah dibayar'],
    kaki:
        'Mengecek klaim tidak mengubah saldo. Pembayarannya mencatat Belanja '
        'satu kali.',
  ),
};

typedef _Aksi = ({
  String id,
  String n,
  String cat,
  String entri,
  String ecat,
  String tombol,
  String lebih,
  bool utama,
  bool kunci,
  bool cek,
});

const Map<String, List<_Aksi>> _aksi = {
  'um': [
    (
      id: 'tj',
      n: 'Catat pertanggungjawaban',
      cat: 'Belanja dari uang muka, dengan nota.',
      entri: 'Pertanggungjawaban uang muka',
      ecat: 'menjadi Belanja',
      tombol: 'Bukukan pertanggungjawaban',
      lebih: 'Kelebihan belanja dicatat sebagai Penggantian biaya.',
      utama: true,
      kunci: false,
      cek: false,
    ),
    (
      id: 'kb',
      n: 'Catat pengembalian sisa',
      cat: 'Uang kembali ke Kas. Bukan Pendapatan.',
      entri: 'Pengembalian sisa uang muka',
      ecat: 'kembali ke Kas',
      tombol: 'Bukukan pengembalian',
      lebih: '',
      utama: false,
      kunci: false,
      cek: false,
    ),
  ],
  'tt': [
    (
      id: 'sl',
      n: 'Salurkan',
      cat: 'Menyerahkan titipan kepada yang berhak. Bukan Belanja.',
      entri: 'Penyaluran',
      ecat: 'bukan Belanja',
      tombol: 'Bukukan penyaluran',
      lebih: '',
      utama: true,
      kunci: false,
      cek: false,
    ),
  ],
  'pb': [
    (
      id: 'ck',
      n: 'Cek klaim',
      cat: '',
      entri: '',
      ecat: '',
      tombol: '',
      lebih: '',
      utama: false,
      kunci: false,
      cek: true,
    ),
    (
      id: 'by',
      n: 'Bayar penggantian biaya',
      cat: 'Membayar klaim penuh dan mencatat Belanja satu kali.',
      entri: 'Penggantian biaya dibayar',
      ecat: 'Belanja, dicatat satu kali',
      tombol: 'Bukukan pembayaran',
      lebih: '',
      utama: true,
      kunci: true,
      cek: false,
    ),
  ],
};

/// The board's UI state, shared by the list and the case view for as long
/// as the board is on the stack. The cases themselves are read from
/// [daftarKasusProvider] (domain data lives in repositories).
class _Papan extends ChangeNotifier {
  String tab = 'um';
  String? buka, sheet;

  /// Claims checked on this board ("Cek klaim"): the check changes no
  /// balance and CaseRepository has no command for it.
  Set<String> cek = {};

  /// The last refusal of a command, shown under the history.
  Refusal? pesan;
  final isi = TextEditingController();

  _Label get lbl => _lbl[tab]!;

  _Aksi? aksiDari(BarisKasus? k) => k == null
      ? null
      : _aksi[k.jenis]!.where((a) => a.id == sheet).firstOrNull;

  int get angka => angkaDari(isi.text) ?? 0;

  /// First unmet reason of the book button, from the latest text.
  String alasan(BarisKasus? c) {
    final a = aksiDari(c);
    if (c == null || a == null) return 'tidak ada kasus';
    final n = angka;
    if (n > c.sisa) return 'melebihi sisa ${rp(c.sisa)}. ${a.lebih}'.trim();
    if (n <= 0) return 'jumlah belum diisi';
    return '';
  }

  void ubah() => notifyListeners();

  void pilihTab(String t) {
    tab = t;
    notifyListeners();
  }

  /// Card press, or a deep link (also sets [tab] so Back lands right).
  void bukaKasus(BarisKasus k, {bool beritahu = true}) {
    buka = k.id;
    tab = k.jenis;
    pesan = null;
    if (beritahu) notifyListeners();
  }

  void keDaftar() {
    buka = null;
    sheet = null;
    pesan = null;
    notifyListeners();
  }

  void tekanAksi(BarisKasus c, _Aksi a) {
    if (a.cek) {
      cek = {...cek, c.id};
    } else {
      sheet = a.id;
      pesan = null;
      isi.text = titik('${c.sisa}');
    }
    notifyListeners();
  }

  void tutupSheet() {
    sheet = null;
    notifyListeners();
  }

  @override
  void dispose() {
    isi.dispose();
    super.dispose();
  }
}

/// The church's own cash account: where a returned remainder goes and a
/// claim is paid from ("kembali ke Kas").
String? kasGereja(WidgetRef ref) => ref
    .read(accountRepositoryProvider)
    .accounts()
    .where((a) => a.type == AccountType.cash && a.operatedByScopeId == null)
    .firstOrNull
    ?.id;

/// Runs the board action [aksiId] ('tj', 'kb', 'sl', 'by') on [k] for
/// [jumlah]: the case command drafts the linked transaction, then Bukukan is
/// tried at once. Returns the refusal to show, or null when it was booked.
/// With the second checker in force (D24) the draft waits for the check.
Future<Refusal?> catatPadaKasus(
  WidgetRef ref,
  BarisKasus k,
  String aksiId,
  int jumlah,
) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  final repo = ref.read(caseRepositoryProvider);
  final kunci = kunciBaru(a.personId, ref.read(clockProvider));
  final kas = kasGereja(ref);
  final r = await switch (aksiId) {
    'tj' => repo.settle(
      a,
      k.id,
      CaseEntryDraft(amount: jumlah),
      expectedRevision: k.revisi,
      idempotencyKey: kunci,
    ),
    'kb' => repo.returnUnused(
      a,
      k.id,
      CaseEntryDraft(amount: jumlah, accountId: k.view.kase.accountId ?? kas),
      expectedRevision: k.revisi,
      idempotencyKey: kunci,
    ),
    'sl' => repo.remit(
      a,
      k.id,
      CaseEntryDraft(amount: jumlah),
      expectedRevision: k.revisi,
      idempotencyKey: kunci,
    ),
    _ => repo.payClaim(
      a,
      k.id,
      CaseEntryDraft(amount: jumlah, accountId: kas),
      expectedRevision: k.revisi,
      idempotencyKey: kunci,
    ),
  };
  if (r case Refused(:final refusal)) return refusal;
  return bukukanDrafKasus(ref, r.value);
}

/// "Periksa dan bukukan" of a case's draft: the refusal, or null.
Future<Refusal?> bukukanDrafKasus(WidgetRef ref, String transaksiId) async {
  final a = ref.read(actorProvider);
  final tx = ref.read(transactionRepositoryProvider);
  final t = tx.get(transaksiId);
  if (a == null || t == null) return null;
  final r = await tx.finalize(
    a,
    t.id,
    expectedRevision: t.revision,
    idempotencyKey: kunciBaru(a.personId, ref.read(clockProvider)),
  );
  return r.refusal;
}

/// The refusal sentence as the boards print it after "Tidak dapat
/// dilakukan: {action}.".
String sebabPenolakan(Refusal r) =>
    r.because +
    (r.whoCanAct == null ? '' : ' Yang perlu bertindak: ${r.whoCanAct}.');

/// The status word of [k] on its kind's labels.
String statusKasus(BarisKasus k) {
  final l = _lbl[k.jenis]!.st;
  if (k.awalDraf) return 'Draf · belum masuk saldo';
  return k.sisa <= 0 && k.awal > 0 ? l[2] : (k.terpakai > 0 ? l[1] : l[0]);
}

class _Lingkup extends InheritedNotifier<_Papan> {
  const _Lingkup({required _Papan papan, required super.child})
    : super(notifier: papan);

  static _Papan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;

  /// Without a dependency (initState).
  static _Papan baca(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

class KewajibanKendali extends StatefulWidget {
  const KewajibanKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KewajibanKendali> createState() => _KewajibanKendaliState();
}

class _KewajibanKendaliState extends State<KewajibanKendali> {
  final _papan = _Papan();

  @override
  void dispose() {
    _papan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    papan: _papan,
    child: Material(
      type: MaterialType.transparency,
      // CSS splits line-height leading evenly above and below the glyphs.
      child: DefaultTextHeightBehavior(
        textHeightBehavior: _leadingRata,
        child: ListenableBuilder(
          listenable: _papan,
          builder: (context, navigator) => LayarPonsel(
            layarKeuangan: true,
            overlay: [if (_papan.sheet != null) _Lembar(papan: _papan)],
            child: navigator!,
          ),
          child: widget.child,
        ),
      ),
    ),
  );
}

const _leadingRata = TextHeightBehavior(
  leadingDistribution: TextLeadingDistribution.even,
);

class KewajibanScreen extends StatelessWidget {
  const KewajibanScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) =>
      anak == null ? const _Daftar() : _Rinci(id: param['id'] ?? '');
}

// List view.

class _Daftar extends ConsumerWidget {
  const _Daftar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final lb = p.lbl;
    final list = ref
        .watch(daftarKasusProvider)
        .where((k) => k.jenis == p.tab)
        .toList();
    final buka = list.where((k) => k.sisa > 0).toList();
    final total = buka.fold(0, (a, k) => a + k.sisa);
    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: ColoredBox(
        color: c.kertas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: 'Uang yang masih berjalan',
              kembaliKe: Layar.keuangan,
              labelKembali: 'Kembali ke Beranda',
              ujung: Tautan(
                ke: Layar.kasusBaru,
                radius: 12,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: c.laut,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+ Kasus baru',
                    style: TextStyle(
                      color: c.diLaut,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Wrap(
                spacing: 6,
                children: [
                  for (final t in const ['um', 'tt', 'pb'])
                    _Chip(
                      teks: _lbl[t]!.tab,
                      dipilih: p.tab == t,
                      onTap: () => p.pilihTab(t),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${lb.sisa} · ${buka.length} kasus',
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                        Text(
                          rp(total),
                          style: const TextStyle(
                            fontFamily: PalakatText.mono,
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          lb.cat,
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ),
                    for (final k in list) ...[
                      const SizedBox(height: 12),
                      KartuKasus(
                        nama: k.judul,
                        labelPihak: lb.pihak,
                        pihak: k.pihak,
                        awal: k.awal,
                        dipertanggungjawabkan: k.terpakai,
                        status: _statusBaris(k),
                        lewatTempo: k.lewat,
                        onTap: () {
                          p.bukaKasus(k);
                          context.dorongKe(
                            Layar.kewajiban,
                            anak: 'kasus/${k.id}',
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _statusBaris(BarisKasus k) {
    final beres = k.sisa <= 0 && !k.awalDraf;
    final akhir = k.tempo.isNotEmpty && !beres
        ? (k.lewat
              ? ' · Lewat jatuh tempo (jatuh tempo: ${k.tempo})'
              : ' · jatuh tempo ${k.tempo}')
        : '';
    return statusKasus(k) + akhir;
  }
}

/// The board's 13 px kind chip (padding 0 13): ChipSatu is fixed at 14.
class _Chip extends StatelessWidget {
  const _Chip({required this.teks, required this.dipilih, required this.onTap});
  final String teks;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: 22,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih ? c.tinta : c.garisTegas,
            radius: PalakatRadius.chip,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              teks,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dipilih ? c.permukaan : c.tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Case view (child route /Kewajiban/kasus/:id).

class _Rinci extends ConsumerStatefulWidget {
  const _Rinci({required this.id});
  final String id;
  @override
  ConsumerState<_Rinci> createState() => _RinciState();
}

class _RinciState extends ConsumerState<_Rinci> {
  @override
  void initState() {
    super.initState();
    _pastikan();
  }

  @override
  void didUpdateWidget(_Rinci old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) _pastikan();
  }

  BarisKasus? _kasus() =>
      ref.read(daftarKasusProvider).where((k) => k.id == widget.id).firstOrNull;

  void _pastikan() {
    final p = _Lingkup.baca(context);
    final k = _kasus();
    if (k == null) {
      // Unknown id: back to the board's root route (navigation.md 5.4).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.gantiKe(Layar.kewajiban);
      });
    } else if (p.buka != widget.id) {
      // Deep link: open the case without a card press.
      p.bukaKasus(k, beritahu: false);
      WidgetsBinding.instance.addPostFrameCallback((_) => p.ubah());
    }
  }

  Future<void> _bukukanDraf(_Papan p, String id) async {
    p.pesan = await bukukanDrafKasus(ref, id);
    p.ubah();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final cur = ref
        .watch(daftarKasusProvider)
        .where((k) => k.id == widget.id)
        .firstOrNull;
    if (cur == null) return const SizedBox.shrink();
    final lb = p.lbl;
    final csisa = cur.sisa;
    final beres = csisa <= 0 && !cur.awalDraf;
    final sudahCek = cur.dicek || p.cek.contains(cur.id);
    final aksi = beres || cur.awalDraf
        ? const <_Aksi>[]
        : _aksi[cur.jenis]!
              .where(
                (a) => !(a.cek && sudahCek) && !(a.id == 'by' && !sudahCek),
              )
              .toList();
    final tempo = cur.tempo.isNotEmpty && !beres
        ? (cur.lewat
              ? 'Lewat jatuh tempo (jatuh tempo: ${cur.tempo})'
              : 'Jatuh tempo ${cur.tempo}')
        : '';
    const mono = TextStyle(
      fontFamily: PalakatText.mono,
      fontWeight: FontWeight.w500,
    );

    Widget baris(String judul, InlineSpan ket, String jumlah, bool garis) =>
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: garis
              ? BoxDecoration(
                  border: Border(top: BorderSide(color: c.garis)),
                )
              : null,
          child: _BarisRiwayat(judul: judul, ket: ket, jumlah: jumlah),
        );

    final kecil = TextStyle(fontSize: 13, color: c.tinta3);

    return PopScope(
      canPop: p.sheet == null,
      onPopInvokedWithResult: (sudah, _) =>
          sudah ? p.keDaftar() : p.tutupSheet(),
      child: ColoredBox(
        color: c.kertas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: cur.judul,
              anakJudul: '${lb.pihak}: ${cur.pihak}',
              labelKembali: 'Kembali',
              onKembali: () {
                p.keDaftar();
                context.pop();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lb.sisa,
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                        Text(
                          rp(csisa),
                          style: mono.copyWith(
                            fontSize: 36,
                            letterSpacing: -1,
                            height: 1.15,
                          ),
                        ),
                        Text(
                          'Dihitung dari catatan di bawah. Tidak ada isian '
                          'untuk mengubahnya.',
                          style: kecil,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BatangPembagian(
                      // The board's width is a whole percentage.
                      total: 100,
                      tinggi: 14,
                      durasi: const Duration(milliseconds: 500),
                      bagian: [
                        BagianBatang(
                          cur.awal == 0
                              ? 0
                              : (cur.terpakai / cur.awal * 100).round(),
                          c.tinta,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: ShapeDecoration(
                            color: beres ? c.laut : null,
                            shape: GarisBorder.penuh(
                              beres ? c.laut : c.tinta3,
                              radius: 6,
                            ),
                          ),
                          child: Text(
                            statusKasus(cur),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: beres ? c.diLaut : c.tinta2,
                            ),
                          ),
                        ),
                        if (tempo.isNotEmpty)
                          Text(
                            tempo,
                            style: TextStyle(
                              fontSize: 13,
                              color: c.tinta,
                              fontWeight: cur.lewat
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: c.permukaan,
                        border: Border.all(color: c.garis),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          baris(
                            lb.awal,
                            TextSpan(
                              text:
                                  cur.awalCat +
                                  (cur.jenis == 'pb' && sudahCek && !beres
                                      ? ' · klaim sudah dicek'
                                      : ''),
                            ),
                            rp(cur.awal),
                            false,
                          ),
                          for (final (i, e) in cur.entri.indexed)
                            Gerak(
                              Kerangka.muncul,
                              key: ValueKey(i),
                              lama: const Duration(milliseconds: 300),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  baris(
                                    e.nama,
                                    TextSpan(
                                      children: [
                                        if (e.draf)
                                          TextSpan(
                                            text: e.diperiksa
                                                ? 'Sudah diperiksa · '
                                                      'belum masuk saldo'
                                                : 'Draf · belum masuk saldo',
                                          )
                                        else
                                          TextSpan(
                                            text: e.no,
                                            style: const TextStyle(
                                              fontFamily: PalakatText.mono,
                                            ),
                                          ),
                                        TextSpan(
                                          text: ' · ${e.tgl} · ${e.cat}',
                                        ),
                                      ],
                                    ),
                                    '− ${rp(e.jumlah)}',
                                    true,
                                  ),
                                  if (e.draf)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Tombol(
                                        'Periksa dan bukukan',
                                        jenis: JenisTombol.kedua,
                                        ukuran: UkuranTombol.ringkas,
                                        onPressed: () =>
                                            _bukukanDraf(p, e.transaksiId),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (p.pesan case final r?) ...[
                      const SizedBox(height: 16),
                      Penolakan(
                        tindakan: r.action,
                        sebab: sebabPenolakan(r),
                        jalan: const [],
                        ukuranTeks: 14,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(lb.kaki, style: kecil),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              decoration: BoxDecoration(
                color: c.permukaan,
                border: Border(top: BorderSide(color: c.garis)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, a) in aksi.indexed) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _TombolAksi(
                      label: a.cek ? 'Cek klaim · tidak mengubah saldo' : a.n,
                      utama:
                          a.utama && !(cur.jenis == 'pb' && !sudahCek) ||
                          (a.cek && !sudahCek),
                      onTap: () => p.tekanAksi(cur, a),
                    ),
                  ],
                  if (beres)
                    Gerak(
                      Kerangka.muncul,
                      lama: const Duration(milliseconds: 300),
                      child: Semantics(
                        container: true,
                        liveRegion: true,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 50),
                          child: Center(
                            child: Text(
                              '${statusKasus(cur)} · tidak ada sisa',
                              style: TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Action bar button: min height 50, radius 14, 700, centred.
class _TombolAksi extends StatelessWidget {
  const _TombolAksi({
    required this.label,
    required this.utama,
    required this.onTap,
  });
  final String label;
  final bool utama;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      radius: 14,
      child: RupaTombol(
        label: label,
        isi: utama ? c.laut : c.permukaan,
        garis: utama ? null : GarisBorder.penuh(c.tinta, radius: 14),
        warnaTeks: utama ? c.diLaut : c.tinta,
        radius: 14,
        tinggi: 50,
        paddingH: 6,
      ),
    );
  }
}

// Amount sheet (an overlay of the Kendali, over the case view).

class _Lembar extends ConsumerWidget {
  const _Lembar({required this.papan});
  final _Papan papan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = papan;
    final cur = ref
        .watch(daftarKasusProvider)
        .where((k) => k.id == p.buka)
        .firstOrNull;
    final a = p.aksiDari(cur);
    if (cur == null || a == null) return const SizedBox.shrink();
    final alasan = p.alasan(cur);
    return LembarBawah(
      judul: a.n,
      anakJudul: a.cat,
      onTutup: p.tutupSheet,
      labelTirai: 'Kembali ke kasus',
      isi: [
        IsianJumlah(
          label: 'Jumlah (Rp)',
          controller: p.isi,
          onChanged: (_) => p.ubah(),
          ukuran: UkuranJumlah.besar,
          ukuranRp: 20,
          ukuranAngka: 32,
          hanyaBaca: a.kunci,
        ),
        TombolBersyarat(
          label: a.tombol,
          tindakan: a.tombol,
          alasan: alasan,
          periksa: () => p.alasan(cur),
          // Only the over-remainder case is worded on the board.
          sudahMulai: p.angka > cur.sisa,
          gayaAlasan: GayaAlasan.kalimatBata,
          warnaSiap: JenisTombol.utama,
          teksBelumRedup: true,
          jarak: 14,
          paddingH: 6,
          onPressed: () async {
            final n = p.angka;
            p.tutupSheet();
            p.pesan = await catatPadaKasus(ref, cur, a.id, n);
            p.ubah();
          },
        ),
        Tombol(
          'Kembali',
          jenis: JenisTombol.teks,
          warnaTeks: c.tinta,
          onPressed: p.tutupSheet,
        ),
      ],
    );
  }
}

/// A history row: label over caption, amount right. Lays out like the
/// board's `display: flex; justify-content: space-between; gap: 12px`: both
/// sides shrink in proportion to their natural width, the amount no
/// narrower than its longest word, so "− Rp850.000" can break after "−".
class _BarisRiwayat extends StatelessWidget {
  const _BarisRiwayat({
    required this.judul,
    required this.ket,
    required this.jumlah,
  });
  final String judul, jumlah;
  final InlineSpan ket;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final gJudul = dasar.merge(
      const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
    final gKet = dasar.merge(TextStyle(fontSize: 13, color: c.tinta3));
    final gJumlah = dasar.merge(
      const TextStyle(
        fontFamily: PalakatText.mono,
        fontWeight: FontWeight.w500,
      ),
    );
    final scaler = MediaQuery.textScalerOf(context);
    double lebar(InlineSpan t, {bool min = false}) {
      final tp = TextPainter(
        text: t,
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      final w = min ? tp.minIntrinsicWidth : tp.maxIntrinsicWidth;
      tp.dispose();
      return w;
    }

    return LayoutBuilder(
      builder: (context, k) {
        final kiri = [
          lebar(TextSpan(text: judul, style: gJudul)),
          lebar(TextSpan(children: [ket], style: gKet)),
        ].reduce((a, b) => a > b ? a : b);
        final span = TextSpan(text: jumlah, style: gJumlah);
        final kanan = lebar(span);
        final ruang = k.maxWidth - 12;
        var wKanan = kanan;
        final lebih = kiri + kanan - ruang;
        if (lebih > 0) {
          final minKanan = lebar(span, min: true);
          wKanan = (kanan - lebih * kanan / (kiri + kanan)).clamp(
            minKanan,
            kanan,
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(judul, style: gJudul),
                  Text.rich(TextSpan(children: [ket]), style: gKet),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: wKanan.ceilToDouble(),
              child: Text(jumlah, style: gJumlah),
            ),
          ],
        );
      },
    );
  }
}
