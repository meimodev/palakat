import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/repositories_keuangan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';

const _muncul = Duration(milliseconds: 300);

/// '{nama}, {jabatan}' of the signed-in actor, for "masuk sebagai".
String siapaSaya(WidgetRef ref) {
  final a = ref.watch(actorProvider);
  if (a == null) return '';
  final g = ref
      .watch(canProvider)
      .grantsOf(a.personId, at: ref.watch(hariIniProvider));
  final saya = g.where((x) => x.toActor() == a).firstOrNull ?? g.firstOrNull;
  final nama = ref.watch(peopleRepositoryProvider).person(a.personId)?.name;
  return saya == null ? '$nama' : '$nama, ${saya.title}';
}

/// The readiness rows of the next month to close (RD12, DP37), shared by
/// Kesiapan and WebKesiapan: the preparer states readiness ("Nyatakan
/// siap"), the Bendahara waives one with a reason ("Bebaskan").
mixin KesiapanLogika<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String? _form;
  Refusal? _tolak;
  final _alasan = TextEditingController();
  final _fokus = FocusNode();

  @override
  void dispose() {
    _alasan.dispose();
    _fokus.dispose();
    super.dispose();
  }

  /// The signed-in person may waive (the church Bendahara, DL33).
  bool bendahara(BuildContext context) {
    final a = ref.watch(actorProvider);
    return a != null &&
        ref
                .watch(canProvider)
                .grantFor(
                  a,
                  Capability.financeClearUnitBlocker,
                  ScopeRef.jemaat,
                  at: ref.watch(hariIniProvider),
                ) !=
            null;
  }

  Period? get bulan => ref.watch(bulanBukuProvider).berikutDitutup;
  String get namaBulanIni => bulan == null ? '' : namaBulan(bulan!);
  List<BarisKesiapan> get _baris => ref.watch(kesiapanProvider);

  bool get _ok => _alasan.text.trim().isNotEmpty;
  bool _perlu(BarisKesiapan b) =>
      b.lihat.state == ReadinessState.missing ||
      b.lihat.state == ReadinessState.invalidated;
  int get _kurang => _baris.where(_perlu).length;

  Future<void> _nyatakan(BarisKesiapan b) async {
    final p = bulan;
    if (p == null) return;
    final r = await perintah(
      ref,
      (a, k) => ref
          .read(periodRepositoryProvider)
          .attest(a, b.dana.id, p.id, idempotencyKey: k),
    );
    if (mounted) setState(() => _tolak = r?.refusal);
  }

  Future<void> _bebaskan(BarisKesiapan b) async {
    final p = bulan;
    if (p == null || !_ok) return;
    final r = await perintah(
      ref,
      (a, k) => ref
          .read(periodRepositoryProvider)
          .waive(
            a,
            b.dana.id,
            p.id,
            reason: _alasan.text.trim(),
            expectedRevision: p.revision,
            idempotencyKey: k,
          ),
    );
    if (!mounted) return;
    setState(() {
      _tolak = r?.refusal;
      if (r?.isOk ?? false) {
        _form = null;
        _alasan.clear();
      }
    });
  }

  /// Hambatan card, or the done card with `muncul` (Bendahara only).
  Widget kartuKeadaan(BuildContext context) {
    final c = context.warna;
    if (_kurang > 0) {
      return Kartu(
        status: GarisStatus.hambatan,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hambatan tutup buku $namaBulanIni',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '$_kurang peruntukan belum punya pernyataan kesiapan yang berlaku. Minta bendahara unitnya menyatakan siap, atau bebaskan dengan alasan.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
      );
    }
    final bebasN = _baris
        .where((x) => x.lihat.state == ReadinessState.waived)
        .length;
    return Gerak(
      Kerangka.muncul,
      lama: _muncul,
      child: Kartu(
        status: GarisStatus.ditutup,
        isi: c.lautLembut,
        child: Text(
          'Pernyataan kesiapan semua peruntukan sudah ada'
          '${bebasN > 0 ? ' · $bebasN dibebaskan, tercatat sebagai pengecualian di konfirmasi tutup buku' : ''}.',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Unit treasurer intro line.
  Widget introPenyiap(BuildContext context) {
    final milik = [
      for (final b in _baris)
        if (b.milikSaya) b.dana.name,
    ];
    return Text(
      milik.isEmpty
          ? 'Tidak ada peruntukan yang Anda siapkan untuk $namaBulanIni.'
          : 'Anda menyatakan bahwa catatan peruntukan ${milik.join(' dan ')} untuk $namaBulanIni sudah lengkap menurut Anda. Ini bukan persetujuan dan tidak menutup buku; tutup buku tetap dilakukan Bendahara.',
      style: TextStyle(fontSize: 14, color: context.warna.tinta2),
    );
  }

  /// The row list: each card has margin-bottom 12.
  Widget daftarBaris(BuildContext context, bool bend) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_tolak != null) ...[
        Penolakan(
          tindakan: _tolak!.action,
          sebab: _tolak!.because,
          jalan: const [],
          ukuranTeks: 14,
        ),
        const SizedBox(height: 12),
      ],
      for (final x in _baris)
        if (bend || x.milikSaya) ...[
          _barisKartu(context, bend, x),
          const SizedBox(height: 12),
        ],
    ],
  );

  String _nama(String? id) {
    final o = ref.watch(peopleRepositoryProvider).person(id ?? '');
    return o?.shortName ?? o?.name ?? '';
  }

  Widget _barisKartu(BuildContext context, bool bend, BarisKesiapan b) {
    final c = context.warna;
    final id = b.dana.id;
    final at = b.lihat.attestation;
    final perlu = _perlu(b);
    final (label, bentuk) = switch (b.lihat.state) {
      ReadinessState.current => ('Sudah dinyatakan siap', BentukLencana.laut),
      ReadinessState.invalidated => (
        'Perlu dinyatakan lagi',
        BentukLencana.bata,
      ),
      ReadinessState.missing => (
        'Pernyataan kesiapan belum ada',
        BentukLencana.bata,
      ),
      ReadinessState.waived => ('Dibebaskan', BentukLencana.peran),
    };
    final cat = switch (b.lihat.state) {
      ReadinessState.current =>
        'Oleh ${b.penyiap} · ${tglJam(at!.attestedAt!)}',
      ReadinessState.invalidated =>
        'Dinyatakan ${tgl(at!.attestedAt!)}, lalu ada transaksi $namaBulanIni yang berubah. Pernyataan lama tidak berlaku lagi.',
      ReadinessState.missing => 'Bendahara unit: ${b.penyiap}',
      ReadinessState.waived =>
        'Oleh ${_nama(at!.waivedBy)} · alasan: ${at.waiverReason ?? ''}',
    };
    return Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Peruntukan ${b.dana.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              LencanaStatus(label, bentuk: bentuk),
            ],
          ),
          const SizedBox(height: 8),
          Text(cat, style: TextStyle(fontSize: 14, color: c.tinta2)),
          if (bend && perlu && _form != id && !b.milikSaya) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Tombol(
                'Bebaskan',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                paddingH: 18,
                lebarPenuh: false,
                onPressed: () => setState(() {
                  _form = id;
                  _tolak = null;
                  _alasan.clear();
                }),
              ),
            ),
          ],
          if (b.milikSaya && perlu) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Tombol(
                'Nyatakan siap',
                paddingH: 18,
                lebarPenuh: false,
                onPressed: () => _nyatakan(b),
              ),
            ),
          ],
          if (_form == id) ...[
            const SizedBox(height: 8),
            Gerak(
              Kerangka.muncul,
              key: ValueKey('form-$id'),
              lama: _muncul,
              child: _formBebas(context, b),
            ),
          ],
        ],
      ),
    );
  }

  Widget _formBebas(BuildContext context, BarisKesiapan b) {
    final c = context.warna;
    final ok = _ok;
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: GestureDetector(
              onTap: _fokus.requestFocus,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Alasan membebaskan '),
                    TextSpan(
                      text: '· wajib',
                      style: TextStyle(
                        color: c.tinta,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          IsianTeks(
            controller: _alasan,
            focusNode: _fokus,
            labelSemantik: 'Alasan membebaskan · wajib',
            baris: 2,
            minTinggi: 0,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Tombol(
                'Bebaskan dengan alasan ini',
                jenis: JenisTombol.tinta,
                ukuran: UkuranTombol.ringkas,
                lebarPenuh: false,
                nonaktif: !ok,
                onPressed: () => _bebaskan(b),
              ),
              Tombol(
                'Kembali',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.ringkas,
                lebarPenuh: false,
                onPressed: () => setState(() => _form = null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
