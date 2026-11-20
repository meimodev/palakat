import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/keuangan/catat.dart';
import '../../providers/keuangan/isian.dart';
import '../../providers/repositories_keuangan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/isian_jumlah.dart';
import '../../widgets/kecil.dart';
import '../../widgets/pemilih_mata_anggaran.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

/// The board's `CFG` per jenis.
typedef _Jenis = ({
  String n,
  String pohon,
  String akun,
  String per,
  String pihak,
  int tanda,
});

const Map<TransactionType, _Jenis> _cfg = {
  TransactionType.income: (
    n: 'Pendapatan',
    pohon: 'Pendapatan',
    akun: 'Kas/Bank',
    per: 'Masuk ke peruntukan',
    pihak: 'Diterima dari (boleh tanpa nama)',
    tanda: 1,
  ),
  TransactionType.expense: (
    n: 'Belanja',
    pohon: 'Belanja',
    akun: 'Kas/Bank',
    per: 'Diambil dari peruntukan',
    pihak: 'Dibayar kepada',
    tanda: -1,
  ),
  TransactionType.accountTransfer: (
    n: 'Pindah antar Kas/Bank',
    pohon: '',
    akun: 'Dari Kas/Bank',
    per: '',
    pihak: '',
    tanda: 1,
  ),
};

List<({String nilai, String teks})> _chip(List<PilihanChip> l) => [
  for (final x in l) (nilai: x.id, teks: x.nama),
];

const _tautan = [
  (teks: 'Bagi ke beberapa Mata Anggaran', ke: Layar.bagi),
  (teks: 'Persembahan', ke: Layar.persembahan),
  (teks: 'Alih peruntukan', ke: Layar.alihPeruntukan),
  (teks: 'Dari foto nota', ke: Layar.aiFoto),
  (teks: 'Ganti catatan persetujuan', ke: Layar.persetujuan),
  (teks: 'Tanggal transaksi', ke: Layar.tanggal),
  (teks: 'Usulan Mata Anggaran', ke: Layar.aiMataAnggaran),
  (teks: 'Dari kalimat', ke: Layar.bantuanAi),
];

const _mono = TextStyle(
  fontFamily: PalakatText.mono,
  fontFeatures: [FontFeature.tabularFigures()],
);

/// One checklist line: met, unmet or "info" (never counted).
enum _Cek { ok, gagal, info }

/// Web · Catat transaksi (spec 08-cari.md, WebCatat; tablet: TabCatat).
/// The form is local; "Simpan sebagai draf" saves a DRAFT and "Periksa dan
/// bukukan" saves then finalizes it through TransactionRepository (a
/// refusal, e.g. the second checker, keeps the draft). [isianCatatProvider]
/// carries the form to Tanggal and Bagi and brings a draft in from
/// Transaksi's "Ubah".
class WebCatatScreen extends ConsumerStatefulWidget {
  const WebCatatScreen({super.key});

  @override
  ConsumerState<WebCatatScreen> createState() => _WebCatatScreenState();
}

class _WebCatatScreenState extends ConsumerState<WebCatatScreen> {
  final _jmC = TextEditingController();
  final _pihakC = TextEditingController();
  final _urC = TextEditingController();
  final _cariC = TextEditingController();
  late final IsianCatatNotifier _isian;

  TransactionType _jenis = TransactionType.expense;
  String _jm = '';
  String? _akunId, _ke, _per, _ling, _maKode;

  /// The chosen document's file name.
  String? _dok;
  bool _terunggah = false;

  /// The saved draft, the form's material fields at its last save, and the
  /// parts of a split made in Bagi (kept as they are).
  String? _drafId;
  Object? _tersimpan;
  List<Allocation>? _bagian;
  Tanggal? _tanggal;

  String? _voucher;
  DateTime? _dibukukanPada;
  Refusal? _tolak;
  bool _sibuk = false;

  bool get _posted => _voucher != null;

  @override
  void initState() {
    super.initState();
    _isian = ref.read(isianCatatProvider.notifier);
    final i = ref.read(isianCatatProvider);
    if (i?.drafId != null) {
      _muat(i!.drafId!);
    } else if (i != null && _cfg.containsKey(i.jenis)) {
      _jenis = i.jenis;
      _tanggal = i.tanggal;
    }
    // The hand-off must hold this form before Tanggal or Bagi opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sinkron();
    });
  }

  @override
  void dispose() {
    for (final c in [_jmC, _pihakC, _urC, _cariC]) {
      c.dispose();
    }
    // After the frame: no provider change while the tree finalizes. The app
    // may be gone by then (its container disposed): nothing to clear.
    unawaited(
      Future.microtask(() {
        try {
          _isian.selesai();
        } catch (_) {}
      }),
    );
    super.dispose();
  }

  /// Loads draft [id] into the form.
  void _muat(String id) {
    final t = ref.read(transactionRepositoryProvider).get(id);
    if (t == null) return;
    final a = t.allocations.firstOrNull;
    _jenis = _cfg.containsKey(t.type) ? t.type : TransactionType.expense;
    _jm = t.total > 0 ? '${t.total}' : '';
    _jmC.text = _jm.isEmpty ? '' : titik(_jm);
    _akunId = t.accountId ?? a?.accountId;
    _ke = t.toAccountId;
    _per = a?.fundId;
    _ling = a?.scopeId;
    _maKode = t.allocations.length > 1 ? null : a?.masterCode;
    _bagian = t.allocations.length > 1 ? t.allocations : null;
    _pihakC.text = t.payee ?? '';
    _urC.text = t.description;
    _tanggal = t.effectiveDate;
    _drafId = t.id;
    _tersimpan = _materi;
  }

  /// Keeps the hand-off ([isianCatatProvider]) on this form.
  void _sinkron() => _isian.buka(
    IsianCatat(
      jenis: _jenis,
      jumlah: int.tryParse(_jm) ?? 0,
      uraian: _ringkas,
      tanggal: ref.read(isianCatatProvider)?.tanggal ?? _tanggal,
      drafId: _drafId,
    ),
  );

  /// Every board handler but `onCari` does nothing once posted.
  void _ubah(VoidCallback f) {
    if (_posted) return;
    setState(() {
      f();
      _tolak = null;
    });
    _sinkron();
  }

  String _nama(String? id) =>
      ref.read(pilihanCatatProvider(_hari)).namaKasBank(id);

  Tanggal get _hari =>
      ref.read(isianCatatProvider)?.tanggal ??
      _tanggal ??
      ref.read(hariIniProvider);

  String get _ringkas {
    final pindah = _jenis == TransactionType.accountTransfer;
    final pihak = _pihakC.text.trim(), ur = _urC.text.trim();
    return pindah
        ? 'Dari ${_akunId == null ? '…' : _nama(_akunId)} '
              'ke ${_ke == null ? '…' : _nama(_ke)}'
        : (ur.isNotEmpty ? ur : (pihak.isNotEmpty ? pihak : _cfg[_jenis]!.n));
  }

  Object get _materi =>
      (_jenis, _jm, _akunId, _ke, _per, _ling, _maKode, _hari);

  String _kunci(Actor a) => kunciBaru(a.personId, ref.read(clockProvider));

  /// Creates the DRAFT, or edits it when the form changed since the last
  /// save (an unchanged form keeps its check). Null when refused.
  Future<Transaction?> _simpan() async {
    final actor = ref.read(actorProvider);
    if (actor == null) return null;
    final repo = ref.read(transactionRepositoryProvider);
    final pindah = _jenis == TransactionType.accountTransfer;
    final p = ref.read(pilihanCatatProvider(_hari));
    final dana = pindah ? p.umum : _per;
    final bagian = [
      for (final a
          in _bagian ??
              [
                Allocation(
                  amount: int.tryParse(_jm) ?? 0,
                  masterCode: pindah ? null : _maKode,
                ),
              ])
        a.copyWith(fundId: dana, scopeId: pindah ? null : _ling),
    ];
    final pihak = _pihakC.text.trim();
    final lama = _drafId == null ? null : repo.get(_drafId!);
    final Result<Transaction> r;
    if (lama == null) {
      r = await repo.createDraft(
        actor,
        TransactionDraft(
          type: _jenis,
          effectiveDate: _hari,
          description: _ringkas,
          allocations: bagian,
          accountId: _akunId,
          toAccountId: pindah ? _ke : null,
          payee: pindah || pihak.isEmpty ? null : pihak,
          approvalRule: 'transaksi rutin',
        ),
        idempotencyKey: _kunci(actor),
      );
    } else if (_materi == _tersimpan &&
        lama.description == _ringkas &&
        (lama.payee ?? '') == (pindah ? '' : pihak)) {
      r = Ok(lama);
    } else {
      final m = _materi != _tersimpan;
      r = await repo.editDraft(
        actor,
        lama.id,
        TransactionPatch(
          type: m ? _jenis : null,
          effectiveDate: m ? _hari : null,
          allocations: m ? bagian : null,
          accountId: m ? _akunId : null,
          toAccountId: m && pindah ? _ke : null,
          description: _ringkas,
          payee: pindah ? null : pihak,
        ),
        expectedRevision: lama.revision,
        idempotencyKey: _kunci(actor),
      );
    }
    if (!mounted) return null;
    switch (r) {
      case Refused(:final refusal):
        setState(() => _tolak = refusal);
        return null;
      case Ok(value: final t):
        _drafId = t.id;
        _tersimpan = _materi;
        _sinkron();
        return _unggah(actor, t);
    }
  }

  /// The chosen document goes up once the draft exists (D02: it never
  /// blocks Bukukan; a refused upload clears the choice and says why).
  Future<Transaction?> _unggah(Actor actor, Transaction t) async {
    if (_dok == null || _terunggah) return t;
    final r = await ref
        .read(evidenceRepositoryProvider)
        .upload(
          actor,
          t.id,
          SampleFile(_dok!),
          expectedRevision: t.revision,
          idempotencyKey: _kunci(actor),
        );
    if (!mounted) return null;
    if (r.isOk) {
      _terunggah = true;
      return t;
    }
    setState(() {
      _dok = null;
      _tolak = r.refusal;
    });
    return null;
  }

  Future<void> _bukukan() async {
    if (_sibuk) return;
    setState(() => _sibuk = true);
    try {
      final t = await _simpan();
      final actor = ref.read(actorProvider);
      if (t == null || actor == null || !mounted) return;
      final repo = ref.read(transactionRepositoryProvider);
      final r = await repo.finalize(
        actor,
        t.id,
        expectedRevision: repo.get(t.id)?.revision ?? t.revision,
        idempotencyKey: _kunci(actor),
      );
      if (!mounted) return;
      setState(() {
        switch (r) {
          case Ok(:final value):
            _voucher = value;
            _dibukukanPada = repo.get(t.id)?.finalizedAt;
            _tolak = null;
          case Refused(:final refusal):
            _tolak = refusal;
        }
      });
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  Future<void> _simpanDraf() async {
    if (_sibuk) return;
    _sibuk = true;
    final t = await _simpan();
    _sibuk = false;
    if (t != null && mounted) context.naikKe(Layar.transaksi);
  }

  void _lagi() {
    for (final c in [_jmC, _pihakC, _urC, _cariC]) {
      c.clear();
    }
    setState(() {
      _jm = '';
      _akunId = _ke = _per = _ling = _maKode = _dok = null;
      _drafId = _tersimpan = _bagian = _tanggal = null;
      _voucher = _dibukukanPada = _tolak = null;
      _terunggah = false;
    });
    _isian.buka(IsianCatat(jenis: _jenis));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    // Bagi saved the split into a draft while this form waited below it.
    ref.listen(isianCatatProvider, (_, n) {
      final id = n?.drafId;
      if (id != null && id != _drafId) setState(() => _muat(id));
    });
    final isian = ref.watch(isianCatatProvider);
    final Tanggal hari =
        isian?.tanggal ?? _tanggal ?? ref.watch(hariIniProvider);
    final p = ref.watch(pilihanCatatProvider(hari));
    final l = _cfg[_jenis]!;
    final pindah = _jenis == TransactionType.accountTransfer;
    final j = int.tryParse(_jm) ?? 0;
    String nama(String? id) => p.namaKasBank(id);

    final cek = <(_Cek, String)>[
      j > 0 ? (_Cek.ok, 'Jumlah ${rp(j)}') : (_Cek.gagal, 'Jumlah belum diisi'),
      if (pindah) ...[
        _akunId != null && _ke != null && _akunId != _ke
            ? (_Cek.ok, 'Dari ${nama(_akunId)} ke ${nama(_ke)}')
            : (
                _Cek.gagal,
                'Kas/Bank asal dan tujuan belum dipilih, dan harus berbeda',
              ),
        (_Cek.ok, 'Bukan Pendapatan dan bukan Belanja'),
      ] else ...[
        _akunId != null
            ? (_Cek.ok, 'Kas/Bank: ${nama(_akunId)}')
            : (_Cek.gagal, 'Kas/Bank belum dipilih'),
        _per != null
            ? (_Cek.ok, '${l.per}: ${p.namaPeruntukan(_per)}')
            : (_Cek.gagal, 'Peruntukan belum dipilih'),
        _ling != null
            ? (_Cek.ok, 'Lingkup: ${p.namaLingkup(_ling)}')
            : (_Cek.gagal, 'Lingkup belum dipilih'),
        _bagian != null
            ? (
                _Cek.ok,
                'Mata Anggaran sudah dipilih · dibagi ke ${_bagian!.length} baris',
              )
            : _maKode != null
            ? (_Cek.ok, 'Mata Anggaran sudah dipilih')
            : (
                _Cek.gagal,
                'Mata Anggaran belum dipilih · tetap bisa disimpan sebagai draf',
              ),
        (_Cek.ok, 'Persetujuan: tidak diperlukan (aturan: transaksi rutin)'),
      ],
      _dok != null
          ? (_Cek.ok, 'Dokumen pendukung: diunggah, belum diverifikasi')
          : (
              _Cek.info,
              'Dokumen pendukung: wajib, belum ada · menjadi hambatan tutup buku',
            ),
    ];
    final gagalN = cek.where((x) => x.$1 == _Cek.gagal).length;
    final alasan = gagalN > 0 ? '$gagalN syarat belum terpenuhi.' : '';
    final ringkas = _ringkas;

    // ---- main column ----------------------------------------------------
    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // An inline <a> on a 15 × 1.45 line: the 44 px target overlaps.
        MarginNegatif(
          atas: (44 - 15 * 1.45) / 2,
          bawah: (44 - 15 * 1.45) / 2,
          child: Tautan(
            ke: Layar.transaksi,
            cara: Cara.naik,
            child: const Align(
              widthFactor: 1,
              heightFactor: 1,
              child: TautanTeks('Transaksi', ukuran: 14),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: Text(
            'Catat transaksi',
            style: PalakatText.judulHalaman.copyWith(
              color: c.tinta,
              height: 1.45,
            ),
          ),
        ),
      ],
    );

    final deret = DeretTautan(
      web: true,
      anak: [
        for (final t in _tautan)
          // Persetujuan is about a saved draft.
          if (t.ke != Layar.persetujuan || _drafId != null)
            Tautan(
              ke: t.ke,
              param: t.ke == Layar.persetujuan ? {'id': _drafId!} : const {},
              child: Align(
                widthFactor: 1,
                heightFactor: 1,
                child: TautanTeks(t.teks),
              ),
            ),
      ],
    );

    final jenis = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final k in _cfg.keys)
          ChipSatu(
            teks: _cfg[k]!.n,
            dipilih: _jenis == k,
            onTap: () => _ubah(() {
              _jenis = k;
              _maKode = null;
              _bagian = null;
              _ke = null;
              _cariC.clear();
            }),
          ),
      ],
    );

    // ---- form -----------------------------------------------------------
    final jumlah = IsianJumlah(
      label: 'Jumlah (Rp)',
      controller: _jmC,
      hanyaBaca: _posted || _bagian != null,
      ukuran: UkuranJumlah.lebar,
      maks: 12,
      lebarMaks: 420,
      onChanged: (v) => _ubah(() => _jm = hanyaAngka(v, max: 12)),
    );

    final kisi = KisiOtomatis(
      minLebar: 260,
      jarak: 18,
      anak: [
        ChipPilihan<String>(
          label: l.akun,
          pilihan: _chip(p.kasBank),
          terpilih: _akunId,
          onPilih: (v) => _ubah(() => _akunId = v),
        ),
        if (pindah)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChipPilihan<String>(
                label: 'Ke Kas/Bank',
                pilihan: _chip(p.kasBank),
                terpilih: _ke,
                onPilih: (v) => _ubah(() => _ke = v),
              ),
              Text(
                'Bukan Pendapatan dan bukan Belanja. Biaya bank dicatat '
                'sebagai Belanja tersendiri.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          )
        else ...[
          ChipPilihan<String>(
            label: l.per,
            keterangan: '· uang siapa ini',
            pilihan: _chip(p.peruntukan),
            terpilih: _per,
            onPilih: (v) => _ubah(() => _per = v),
          ),
          ChipPilihan<String>(
            label: 'Lingkup',
            pilihan: _chip(p.lingkup),
            terpilih: _ling,
            onPilih: (v) => _ubah(() => _ling = v),
          ),
        ],
      ],
    );

    final pemilih = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: 'Mata Anggaran ',
                children: [
                  TextSpan(
                    text: '· untuk apa',
                    style: TextStyle(color: c.tinta3),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: c.tinta,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l.pohon,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.permukaan,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IsianTeks(
                gaya: _tanpaJarakHuruf,
                controller: _cariC,
                latar: c.kertas,
                minTinggi: 44,
                petunjuk: 'Cari nomor atau nama',
                labelSemantik: 'Cari Mata Anggaran',
                onChanged: (_) => setState(() {}),
              ),
              for (final r in PemilihMataAnggaran.saring([
                for (final m
                    in _jenis == TransactionType.income
                        ? p.pendapatan
                        : p.belanja)
                  BarisMataAnggaran(m.code, m.name, grup: !m.postable),
              ], _cariC.text))
                r.grup
                    ? _Grup(r)
                    : _Baris(
                        r,
                        pohon: l.pohon,
                        dipilih: _maKode == r.kode,
                        onTap: () => _ubah(() {
                          _maKode = r.kode;
                          _bagian = null;
                        }),
                      ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Tombol(
                  'Simpan tanpa Mata Anggaran',
                  onPressed: () => _ubah(() {
                    _maKode = null;
                    _bagian = null;
                  }),
                  jenis: JenisTombol.putus,
                  ukuran: UkuranTombol.mini,
                  paddingH: 16,
                  lebarPenuh: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final teks = KisiOtomatis(
      minLebar: 260,
      jarak: 18,
      anak: [
        IsianTeks(
          gaya: _tanpaJarakHuruf,
          label: l.pihak,
          jarakLabel: 6,
          controller: _pihakC,
          hanyaBaca: _posted,
          onChanged: (_) => _ubah(() {}),
        ),
        IsianTeks(
          gaya: _tanpaJarakHuruf,
          label: 'Uraian',
          jarakLabel: 6,
          controller: _urC,
          hanyaBaca: _posted,
          onChanged: (_) => _ubah(() {}),
        ),
      ],
    );

    final kaki = Container(
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Tanggal transaksi',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: tglPanjang(hari.awal),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Tekan(
            onTap: () => _ubah(
              () => _dok ??=
                  'nota-${hari.toString().substring(0, 5).replaceAll('/', '-')}.jpg',
            ),
            radius: 12,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: _dok != null ? c.permukaan : null,
                shape: _dok != null
                    ? GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 12)
                    : GarisBorder.putus(c.putus, radius: 12),
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  _dok != null
                      ? '$_dok · Terlampir'
                      : 'Lampirkan dokumen pendukung',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _dok != null ? c.tinta : c.laut,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _jarak(18, [
        jumlah,
        kisi,
        if (!pindah) ...[pemilih, teks],
        kaki,
      ]),
    );

    // ---- aside ----------------------------------------------------------
    final kartu = Kartu(
      status: _posted ? GarisStatus.terpilih : GarisStatus.draf,
      radius: 16,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BarisLencana(voucher: _voucher),
          const SizedBox(height: 6),
          Text(
            rp(j * l.tanda),
            style: _mono.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
              color: _posted ? c.tinta : c.tinta2,
            ),
          ),
          const SizedBox(height: 6),
          Text(ringkas, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );

    final daftar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cek.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: i > 0 ? Border(top: BorderSide(color: c.garis)) : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PalakatIkon(
                    switch (cek[i].$1) {
                      _Cek.ok => Ikon.terpenuhi,
                      _Cek.gagal => Ikon.belumTerpenuhi,
                      _Cek.info => Ikon.untukDiketahui,
                    },
                    ukuran: 20,
                    label: switch (cek[i].$1) {
                      _Cek.ok => 'Terpenuhi',
                      _Cek.gagal => 'Belum terpenuhi',
                      _Cek.info => 'Untuk diketahui',
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cek[i].$2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    final aside = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _jarak(14, [
        kartu,
        if (!_posted) ...[
          daftar,
          if (_tolak case final t?)
            Penolakan(
              tindakan: t.action,
              sebab: t.whoCanAct == null
                  ? t.because
                  : '${t.because} Yang perlu bertindak: ${t.whoCanAct}.',
              jalan: const [],
              ukuranTeks: 14,
            )
          else if (gagalN > 0)
            Semantics(
              container: true,
              liveRegion: true,
              child: Text(
                'Tidak dapat dilakukan: $alasan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.bata,
                ),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              IntrinsicWidth(
                child: TombolBersyarat(
                  label: 'Periksa dan bukukan',
                  tindakan: 'Periksa dan bukukan',
                  alasan: alasan,
                  sudahMulai: false,
                  warnaSiap: JenisTombol.utama,
                  teksBelumRedup: true,
                  tinggi: 46,
                  radius: 12,
                  paddingH: 20,
                  onPressed: _bukukan,
                ),
              ),
              Tombol(
                'Simpan sebagai draf',
                onPressed: _simpanDraf,
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.ringkas,
                lebarPenuh: false,
              ),
            ],
          ),
        ] else ...[
          Text(
            'Dibukukan pada '
            '${_dibukukanPada == null ? '' : tglJam(_dibukukanPada!)} · '
            'tidak dapat diubah lagi.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Tombol(
              'Catat lagi',
              onPressed: _lagi,
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.ringkas,
              lebarPenuh: false,
            ),
          ),
        ],
      ]),
    );

    return HalamanWeb(
      nav: NavSamping(item: navKeuangan, aktif: 1),
      layarKeuangan: true,
      isi: [
        judul,
        deret,
        jenis,
        BarisLentur(
          jarak: 28,
          anak: [
            Lentur(dasar: 480, tumbuh: 999, child: form),
            Lentur(dasar: 360, child: aside),
          ],
        ),
      ],
    );
  }
}

/// CSS column `gap`.
List<Widget> _jarak(double g, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: g),
    anak[i],
  ],
];

/// The card's top row (space-between, gap 16, centred): the status badge
/// and, once posted, the stamp. Both shrink as CSS flex items do (in
/// proportion to their widths, never below their longest word), so they sit
/// on one line whenever they fit, as on the board.
class _BarisLencana extends StatelessWidget {
  const _BarisLencana({required this.voucher});

  /// The booked number; null while a draft.
  final String? voucher;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final posted = voucher != null;
    final dasar = DefaultTextStyle.of(context).style;
    final lencana = posted ? 'Dibukukan' : 'Draf · belum masuk saldo';
    final gayaLencana = dasar.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: posted ? c.permukaan : c.tinta2,
    );
    // Zero-width spaces: Chrome may break after a hyphen before digits, the
    // Flutter breaker may not (narrow windows wrap "…BKU-yyyy-" / "nnnn").
    final cap = 'No. Bukti ${voucher ?? ''}'.replaceAll('-', '-\u200B');
    final gayaCap = dasar.merge(
      _mono.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: c.laut),
    );
    final skala = MediaQuery.textScalerOf(context);
    // Padding + line, both sides: badge 9 + 1.5, stamp 10 + 2.
    const tepiL = 21.0, tepiC = 24.0;
    return LayoutBuilder(
      builder: (context, k) {
        final (a, aMin) = _ukur(lencana, gayaLencana, skala);
        var (wa, wb) = (math.min(a + tepiL, k.maxWidth), 0.0);
        var sebaris = false;
        if (posted) {
          final (b, bMin) = _ukur(cap, gayaCap, skala);
          // At 1440 the board fits both by a fraction of a pixel (Chrome
          // snaps text to layout units); our rounded-up widths overshoot by
          // up to 2 px, so treat that as fitting and keep the stamp on one line.
          final lebih = a + tepiL + b + tepiC + 16 - k.maxWidth;
          sebaris = lebih > 0 && lebih <= 2;
          (wa, wb) = sebaris
              ? (a + tepiL, b + tepiC - lebih)
              : _susut(
                  a + tepiL,
                  aMin + tepiL,
                  b + tepiC,
                  bMin + tepiC,
                  k.maxWidth,
                  16,
                );
        }
        return Row(
          children: [
            SizedBox(
              width: wa,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: ShapeDecoration(
                  color: posted ? c.tinta : null,
                  shape: posted
                      ? GarisBorder.penuh(c.tinta, radius: 6)
                      : GarisBorder.putus(c.putus, radius: 6),
                ),
                child: Text(lencana, style: gayaLencana),
              ),
            ),
            if (posted) ...[
              const Spacer(),
              SizedBox(
                width: wb,
                child: Gerak(
                  Kerangka.muncul,
                  key: const ValueKey('cap'),
                  lama: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: ShapeDecoration(
                      shape: GarisBorder.penuh(c.laut, tebal: 2, radius: 8),
                    ),
                    child: Text(cap, style: gayaCap, softWrap: !sebaris),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// (max-content, min-content) widths of [teks], rounded up.
(double, double) _ukur(String teks, TextStyle gaya, TextScaler skala) {
  double lebar(String s) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: gaya),
      textDirection: TextDirection.ltr,
      textScaler: skala,
    )..layout();
    final w = tp.width.ceilToDouble();
    tp.dispose();
    return w;
  }

  return (lebar(teks), teks.split(' ').map(lebar).reduce(math.max));
}

/// CSS `flex-shrink: 1` for two items of widths [a] and [b] in [w] with [gap].
(double, double) _susut(
  double a,
  double aMin,
  double b,
  double bMin,
  double w,
  double gap,
) {
  final lebih = a + b + gap - w;
  if (lebih <= 0) return (a, b);
  var x = a - lebih * a / (a + b);
  var y = b - lebih * b / (a + b);
  if (x < aMin) {
    x = aMin;
    y = w - gap - x;
  } else if (y < bMin) {
    y = bMin;
    x = w - gap - y;
  }
  return (math.max(0, x), math.max(0, y));
}

/// Group heading, not pressable: padding 10 0 4, inline code, name, note.
class _Grup extends StatelessWidget {
  const _Grup(this.r);
  final BarisMataAnggaran r;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: r.kode,
              style: _mono.copyWith(fontSize: 13, color: c.tinta3),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: r.nama,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.tinta2,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: '· Judul kelompok, tidak dapat dibukukan',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
      ),
    );
  }
}

/// Postable row: margin-top 4, min 44, padding 8 12, radius 10, `permukaan`,
/// 1 px `garis` or 2 px `tinta` when chosen; "{pohon} {kode}" then the name.
class _Baris extends StatelessWidget {
  const _Baris(
    this.r, {
    required this.pohon,
    required this.dipilih,
    required this.onTap,
  });
  final BarisMataAnggaran r;
  final String pohon;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kode = _mono.copyWith(fontSize: 13, color: c.tinta2);
    const nama = TextStyle(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Tekan(
        onTap: onTap,
        dipilih: dipilih,
        radius: 10,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(
              dipilih ? c.tinta : c.garis,
              tebal: dipilih ? 2 : 1,
              radius: 10,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Both spans flex-shrink 1: when they do not fit, each gives
              // way in proportion to its max-content width (narrow windows).
              Flexible(
                flex: _lebar(context, '$pohon ${r.kode}', kode),
                child: Text('$pohon ${r.kode}', style: kode),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: _lebar(context, r.nama, nama),
                child: Text(r.nama, style: nama),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Max-content width of [t] (×100, as a flex factor): loose `Flexible`s with
/// these factors share the row as CSS `flex-shrink: 1` does when it overflows.
int _lebar(BuildContext c, String t, TextStyle g) {
  final tp = TextPainter(
    text: TextSpan(text: t, style: DefaultTextStyle.of(c).style.merge(g)),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(c),
  )..layout();
  final w = (tp.width * 100).ceil();
  tp.dispose();
  return w < 1 ? 1 : w;
}

/// TextField takes the theme's M3 letter spacing 0.5 unless the style sets
/// one; the boards' inputs inherit 'normal' (0).
const _tanpaJarakHuruf = TextStyle(letterSpacing: 0);
