import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/keuangan/ai.dart';
import '../../providers/keuangan/isian.dart';
import '../../providers/keuangan/pemeriksa.dart';
import '../../providers/keuangan/transaksi.dart';
import '../../providers/repositories_keuangan.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../lanjut/bantuan_ai_bagian.dart' show KotakBatasAI;
import 'ai_bersama.dart';

/// Shared by AIMataAnggaran and WebAIMataAnggaran: the boards' logic
/// (`{ur, dasar, st, pilihan}`) over a real draft without a Mata Anggaran,
/// and regions 2a–2e of the spec. The AI proposal comes from
/// [AiKind.masterRow] (no delay); "Pakai" and "Pilih ini" write the chosen
/// rows into the draft.

/// One suggested or chosen line: code, label, amount ('' when unsure).
typedef _Baris = (String no, String label, String rp);

/// The board state, plus the draft it works on and the open proposal.
class KeadaanUsulanMA {
  String? ur, dasar;
  String st = 'ada';
  int? pilihan;
  final uraian = TextEditingController();

  /// The draft: the open Catat form's, else the newest open-month Belanja
  /// draft with no Mata Anggaran. Null when there is none.
  String? drafId;
  AiProposal? usulan;
  Refusal? tolak;
  bool _mulai = false;
}

/// The regions of one render, built from [k].
class IsiUsulanMA {
  IsiUsulanMA({
    required this.context,
    required this.ref,
    required this.k,
    required this.ubah,
    required this.keBagi,
  }) {
    if (!k._mulai) {
      k._mulai = true;
      k.drafId = _cariDraf();
      // A command, so after this frame (never during build).
      if (k.drafId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) _minta();
        });
      }
    }
    // `ur === null` shows the draft's description; keep the field in step.
    if (k.uraian.text != ur) k.uraian.text = ur;
  }

  final BuildContext context;
  final WidgetRef ref;
  final KeadaanUsulanMA k;

  /// setState of a mounted screen (a no-op once it is left).
  final void Function(VoidCallback) ubah;

  /// "Pilih sendiri": Bagi / WebBagi.
  final Layar keBagi;

  String? _cariDraf() {
    final tx = ref.read(transactionRepositoryProvider);
    final isian = ref.read(isianCatatProvider)?.drafId;
    if (isian != null && (tx.get(isian)?.isDraft ?? false)) return isian;
    return ref
        .read(antreanPemeriksaProvider)
        .where(
          (b) =>
              b.mataAnggaran == null &&
              b.transaksi.type == TransactionType.expense,
        )
        .firstOrNull
        ?.transaksi
        .id;
  }

  IsianDrafAi? get _draf =>
      k.drafId == null ? null : ref.watch(isianDrafAiProvider(k.drafId!));

  /// [_draf], [ur] and [basi] for callbacks (read, never watch).
  IsianDrafAi? get _drafBaca =>
      k.drafId == null ? null : ref.read(isianDrafAiProvider(k.drafId!));
  String get _urBaca => k.ur ?? _drafBaca?.transaksi.description ?? '';
  bool get _basiBaca => k.st == 'ada' && k.usulan != null && _urBaca != k.dasar;

  /// Shown text: what was typed, else the draft's description.
  String get ur => k.ur ?? _draf?.transaksi.description ?? '';
  bool get basi => k.st == 'ada' && k.usulan != null && ur != k.dasar;
  bool get ragu => k.usulan?.result?.unsure ?? false;

  List<_Baris> get _usul {
    final h = k.usulan?.result;
    final d = _draf;
    if (h == null || d == null) return const [];
    final master = ref.watch(masterRepositoryProvider);
    return [
      for (final l in h.lines)
        (
          l.masterCode,
          labelMataAnggaran(master, l.masterCode, d.tanggal),
          l.amount == null ? '' : rp(l.amount!),
        ),
    ];
  }

  /// Asks for a proposal for the current Uraian (masterRow: no delay).
  Future<void> _minta() async {
    final d = k.drafId == null
        ? null
        : ref.read(transactionRepositoryProvider).get(k.drafId!);
    if (d == null) return;
    final teks = _urBaca;
    final r = await mintaUsulan(
      ref,
      AiKind.masterRow,
      AiInput(text: teks, amount: d.total),
    );
    ubah(() {
      switch (r) {
        case Ok(:final value):
          k
            ..usulan = value
            ..dasar = teks
            ..tolak = null
            ..st = 'ada';
        case Refused(:final refusal):
          k
            ..usulan = null
            ..tolak = refusal;
      }
    });
  }

  /// Writes [baris] (code, amount) into the draft's parts, keeping its
  /// Kas/Bank, peruntukan and Lingkup.
  Future<void> _tulis(List<(String?, int)> baris, AiDisposition cara) async {
    final a = ref.read(actorProvider);
    final p = k.usulan;
    final tx = ref.read(transactionRepositoryProvider);
    final ai = ref.read(aiRepositoryProvider);
    final jam = ref.read(clockProvider);
    final ur = _urBaca;
    final t = k.drafId == null ? null : tx.get(k.drafId!);
    if (a == null || t == null) return;
    String kunci() => kunciBaru(a.personId, jam);
    if (p != null) {
      await ai.dispose(
        a,
        p.id,
        cara,
        expectedRevision: p.revision,
        idempotencyKey: kunci(),
      );
    }
    final pola = t.allocations.firstOrNull ?? const Allocation(amount: 0);
    final r = await tx.editDraft(
      a,
      t.id,
      TransactionPatch(
        description: ur == t.description ? null : ur,
        allocations: [
          for (final (kode, jumlah) in baris)
            Allocation(
              amount: jumlah,
              type: pola.type,
              accountId: pola.accountId,
              fundId: pola.fundId,
              scopeId: pola.scopeId,
              partyId: pola.partyId,
              masterCode: kode,
              caseId: pola.caseId,
            ),
        ],
      ),
      expectedRevision: t.revision,
      idempotencyKey: kunci(),
    );
    ubah(() {
      switch (r) {
        case Ok():
          k
            ..usulan = null
            ..tolak = null
            ..st = _adaKode(baris) ? 'pakai' : 'ada';
        case Refused(:final refusal):
          k.tolak = refusal;
      }
    });
  }

  static bool _adaKode(List<(String?, int)> baris) =>
      baris.any((b) => b.$1 != null);

  void _terima() {
    final h = k.usulan?.result;
    final d = _drafBaca;
    if (_basiBaca || ragu || h == null || d == null) return;
    // One line takes the whole payment; a split keeps the AI's amounts.
    _tulis([
      for (final l in h.lines)
        (l.masterCode, h.lines.length == 1 ? d.jumlah : l.amount ?? 0),
    ], AiDisposition.accepted);
  }

  void _pilih(int i) {
    final h = k.usulan?.result;
    final d = _drafBaca;
    if (_basiBaca || h == null || d == null) return;
    k.pilihan = i;
    _tulis([(h.lines[i].masterCode, d.jumlah)], AiDisposition.edited);
  }

  Future<void> _abaikan() async {
    final p = k.usulan;
    ubah(() => k.st = 'abai');
    if (p != null) await abaikanUsulan(ref, p);
  }

  /// "Buat usulan baru": a fresh proposal for the edited Uraian.
  void _baru() => _minta();

  /// "Ganti pilihan": the draft's parts lose their Mata Anggaran, and the AI
  /// proposes again.
  Future<void> _ulang() async {
    final d = _drafBaca;
    if (d == null) return;
    k.pilihan = null;
    await _tulis([
      for (final a in d.transaksi.allocations) (null, a.amount),
    ], AiDisposition.edited);
    if (context.mounted) await _minta();
  }

  /// "Pilih sendiri": Bagi works for this draft (the isian hand-off).
  void _pilihSendiri() {
    final d = _drafBaca;
    if (d != null) {
      ref
          .read(isianCatatProvider.notifier)
          .buka(
            IsianCatat(
              jenis: d.transaksi.type,
              jumlah: d.jumlah,
              uraian: d.transaksi.description,
              tanggal: d.tanggal,
              drafId: d.transaksi.id,
            ),
          );
    }
    context.dorongKe(keBagi);
  }

  /// Shown when there is no draft to work on.
  Widget? get kosong => k.drafId != null && _draf != null
      ? null
      : Text(
          'Tidak ada draf Belanja yang belum memiliki Mata Anggaran.',
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        );

  /// 2a: the draft card.
  Widget get draf {
    final c = context.warna;
    final d = _draf;
    return Kartu(
      status: GarisStatus.draf,
      radius: 16,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LencanaStatus(
            'Draf · belum masuk saldo',
            bentuk: BentukLencana.draf,
          ),
          const SizedBox(height: 6),
          Text(
            rp(-(d?.jumlah ?? 0)),
            style: TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: c.tinta2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (d != null) namaJenis(d.transaksi.type),
              if (d != null && d.pihak.isNotEmpty) d.pihak,
              if (d != null && d.kasBank.isNotEmpty) d.kasBank,
              if (d != null && d.peruntukan.isNotEmpty)
                'diambil dari peruntukan ${d.peruntukan}',
              if (d != null && d.lingkup.isNotEmpty) 'Lingkup ${d.lingkup}',
            ].join(' · '),
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    );
  }

  /// 2b: Uraian.
  Widget get uraian => IsianTeks(
    controller: k.uraian,
    label: 'Uraian',
    jarakLabel: 6,
    // TextField merges over the theme's bodyLarge (letter-spacing 0.5).
    gaya: const TextStyle(letterSpacing: 0),
    onChanged: (v) => ubah(() => k.ur = v),
  );

  /// 2c: the Mata Anggaran group.
  Widget get mataAnggaran {
    final c = context.warna;
    final d = _draf;
    final master = ref.watch(masterRepositoryProvider);
    final jadi = [
      if (d != null)
        for (final a in d.transaksi.allocations)
          if (a.masterCode != null)
            (labelMataAnggaran(master, a.masterCode!, d.tanggal), rp(a.amount)),
    ];
    final a = ref.watch(actorProvider);
    final cover = ref.watch(jabatanDijalankanProvider);
    final nama = a == null ? '' : ref.watch(namaPendekProvider(a.personId));
    final pelaku = cover != null
        ? '${cover.operator}, Operator.'
        : nama.endsWith('.')
        ? nama
        : '$nama.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Mata Anggaran', style: TextStyle(fontSize: 14, color: c.tinta2)),
        const SizedBox(height: 6),
        if (k.st != 'pakai')
          Kartu(
            status: GarisStatus.draf,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Mata Anggaran belum dipilih',
              style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
            ),
          )
        else ...[
          Gerak(
            Kerangka.muncul,
            key: const ValueKey('pakai'),
            lama: const Duration(milliseconds: 300),
            child: Kartu(
              status: GarisStatus.terpilih,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  for (final (i, j) in jadi.indexed)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: i == 0
                            ? null
                            : Border(top: BorderSide(color: c.garis)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              j.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            j.$2,
                            style: const TextStyle(
                              fontFamily: PalakatText.mono,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mata Anggaran sudah dipilih oleh $pelaku Usulan AI tidak tersimpan sebagai keputusan.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Tombol(
              'Ganti pilihan',
              onPressed: _ulang,
              jenis: JenisTombol.teks,
              lebarPenuh: false,
              paddingH: 0,
            ),
          ),
        ],
      ],
    );
  }

  /// 2d: the AI panel, only in state `ada`.
  Widget? get panel {
    if (k.st != 'ada' || k.drafId == null) return null;
    final c = context.warna;
    if (k.usulan == null) {
      if (ref.watch(anggaranAiProvider).usedUp) {
        return KotakBatasAI(sampai: ref.watch(bulanAiLanjutProvider));
      }
      final t = k.tolak;
      return t == null
          ? null
          : Penolakan(
              tindakan: t.action,
              sebab: t.because,
              jalan: const [],
              ukuranTeks: 14,
            );
    }
    final usul = _usul;
    final h = k.usulan!.result!;
    final jumlahBagi = h.lines.fold(0, (j, l) => j + (l.amount ?? 0));
    final sah = !basi;
    final adaCek =
        usul.length > 1 && !ragu && jumlahBagi == (_draf?.jumlah ?? -1);
    final label = ragu
        ? 'Usulan AI · kurang yakin, mohon dicek'
        : usul.length > 1
        ? 'Usulan AI · bagi ke ${usul.length} Mata Anggaran'
        : 'Usulan AI · Mata Anggaran';

    Widget barisUsul(int i, _Baris u) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GarisLurus(warna: c.garisTegas, gaya: GayaGaris.titik),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.$2,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: c.lautTua,
                      ),
                    ),
                    if (u.$3.isNotEmpty)
                      Text(
                        u.$3,
                        style: TextStyle(
                          fontFamily: PalakatText.mono,
                          fontSize: 13,
                          color: c.tinta2,
                        ),
                      ),
                  ],
                ),
              ),
              if (ragu) ...[
                const SizedBox(width: 10),
                Tombol(
                  'Pilih ini',
                  onPressed: () => _pilih(i),
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.mini,
                  lebarPenuh: false,
                  paddingH: 14,
                  ukuranTeks: 14,
                  // Board `disabled` while stale; its reason is the stale sentence.
                  nonaktif: basi,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    const jeda10 = SizedBox(height: 10);
    return Semantics(
      container: true,
      label: 'Usulan AI',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.lautLembut,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'BANTUAN AI · PILIHAN',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: c.lautTua,
                letterSpacing: 0.3,
              ),
            ),
            jeda10,
            Kartu(
              status: GarisStatus.usulanAI,
              radius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LencanaStatus(label, bentuk: BentukLencana.usulanAI),
                  ),
                  for (final (i, u) in usul.indexed) ...[
                    const SizedBox(height: 6),
                    barisUsul(i, u),
                  ],
                  if (adaCek) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${usul.map((u) => u.$3).join(' + ')} = ${rp(jumlahBagi)}, sama persis dengan jumlah pembayaran.',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ],
              ),
            ),
            jeda10,
            if (!sah) ...[
              Text(
                'Usulan lama — draf sudah berubah. Usulan ini tidak dapat dipakai.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.tinta,
                ),
              ),
              jeda10,
              Tombol(
                'Buat usulan baru',
                onPressed: _baru,
                jenis: JenisTombol.garisLaut,
                ukuran: UkuranTombol.kecil,
                warnaTeks: c.lautTua,
              ),
            ] else
              LayoutBuilder(
                builder: (_, kotak) {
                  // CSS flex 1 / 1.3 / 1 with basis 0: each item starts at its
                  // padding + border (button 12 + 0 or 15, link 3), the rest
                  // is shared by grow factor.
                  final aksi = [
                    if (!ragu)
                      (
                        12.0,
                        1.0,
                        Tombol(
                          'Pakai',
                          onPressed: _terima,
                          ukuran: UkuranTombol.ringkas,
                          paddingH: 6,
                        ),
                      ),
                    (
                      3.0,
                      1.3,
                      Tombol(
                        'Pilih sendiri',
                        onPressed: _pilihSendiri,
                        jenis: JenisTombol.kedua,
                        ukuran: UkuranTombol.ringkas,
                        paddingH: 0,
                        ukuranTeks: 15,
                      ),
                    ),
                    (
                      15.0,
                      1.0,
                      Tombol(
                        'Abaikan',
                        onPressed: _abaikan,
                        jenis: JenisTombol.kedua,
                        ukuran: UkuranTombol.ringkas,
                        paddingH: 6,
                      ),
                    ),
                  ];
                  final sisa =
                      kotak.maxWidth -
                      8 * (aksi.length - 1) -
                      aksi.fold(0.0, (j, a) => j + a.$1);
                  final tumbuh = aksi.fold(0.0, (j, a) => j + a.$2);
                  return Row(
                    children: [
                      for (final (i, a) in aksi.indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        SizedBox(
                          width: a.$1 + sisa * a.$2 / tumbuh,
                          child: a.$3,
                        ),
                      ],
                    ],
                  );
                },
              ),
            jeda10,
            Text(
              'AI hanya memilih dari baris yang dapat dibukukan dan boleh untuk uang milik sendiri. Memakai, mengganti atau mengabaikan usulan tidak perlu alasan.',
              style: TextStyle(fontSize: 13, color: c.tinta2),
            ),
          ],
        ),
      ),
    );
  }

  /// 2e: the ignored sentence, only in state `abai`.
  Widget? get abai => k.st != 'abai'
      ? null
      : Gerak(
          Kerangka.muncul,
          key: const ValueKey('abai'),
          lama: const Duration(milliseconds: 300),
          child: Text(
            'Usulan diabaikan. Draf boleh disimpan tanpa Mata Anggaran, tetapi belum dapat dibukukan.',
            style: TextStyle(fontSize: 14, color: context.warna.tinta2),
          ),
        );
}
