import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/repositories_keuangan.dart';
import '../../providers/repositories_kolaborasi.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'permintaan_dana_keadaan.dart';

/// 88 · Permintaan dana + AlurDana (spec 22, 23; README 7.1): a unit head
/// asks, the approver of the table decides (never their own request), the
/// Bendahara Jemaat records the payment as Uang Muka diberikan and books it
/// after the second check (DL29, DM 5.2).
class PermintaanDanaScreen extends ConsumerStatefulWidget {
  const PermintaanDanaScreen({super.key});

  @override
  ConsumerState<PermintaanDanaScreen> createState() => _PermintaanDanaState();
}

class _PermintaanDanaState extends ConsumerState<PermintaanDanaScreen> {
  final _gulir = ScrollController();
  final _perlu = TextEditingController();
  final _jml = TextEditingController();
  final _alasan = TextEditingController();
  final _jmlBaru = TextEditingController();
  String? _dana;
  String _pesan = '';

  /// The request whose refusal form is open.
  String? _formTolak;

  /// The own request whose "Ubah jumlah" form is open (DM 5.2).
  String? _formJumlah;

  /// The last refusal and the request it belongs to ('' for the form).
  (String, Refusal)? _tolak;

  @override
  void dispose() {
    for (final c in [_gulir, _perlu, _jml, _alasan, _jmlBaru]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _n => int.tryParse(hanyaAngka(_jml.text, simpanNol: true)) ?? 0;

  /// The first unmet reason of "Ajukan permintaan".
  String _sebab() => _perlu.text.trim().isEmpty
      ? 'keperluan belum diisi.'
      : _n <= 0
      ? 'jumlah belum diisi.'
      : _dana == null
      ? 'peruntukan belum dipilih.'
      : '';

  String _sebabTolak() =>
      _alasan.text.trim().isEmpty ? 'Alasan · wajib belum diisi' : '';

  void _ubah(VoidCallback f, {bool keAtas = false}) {
    setState(() {
      f();
      _tolak = null;
    });
    if (keAtas && _gulir.hasClients) _gulir.jumpTo(0);
  }

  /// Runs [jalan] for request [id] ('' for the form); keeps a refusal.
  Future<Result<T>?> _jalankan<T>(
    String id,
    Future<Result<T>> Function(Actor a, String k) jalan,
  ) async {
    final r = await perintah(ref, jalan);
    if (mounted && r?.refusal != null) {
      setState(() => _tolak = (id, r!.refusal!));
    }
    return r;
  }

  Future<void> _ajukan(String? lingkup) async {
    final r = await _jalankan(
      '',
      (a, k) => ref
          .read(fundRequestRepositoryProvider)
          .submit(
            a,
            FundRequestDraft(
              purpose: _perlu.text.trim(),
              amount: _n,
              fundId: _dana!,
              scopeId: lingkup,
            ),
            idempotencyKey: k,
          ),
    );
    if (!mounted || r is! Ok<FundRequest>) return;
    _ubah(() {
      _perlu.clear();
      _jml.clear();
      _dana = null;
      _pesan = r.value.approval == RequestApproval.pending
          ? '${r.value.approverTitle} diberi tahu lewat Pemberitahuan.'
          : 'Bendahara Jemaat diberi tahu lewat Pemberitahuan.';
    }, keAtas: true);
  }

  Future<void> _putus(FundRequest r, {String? alasan}) async {
    final repo = ref.read(fundRequestRepositoryProvider);
    final hasil = await _jalankan(
      r.id,
      (a, k) => alasan == null
          ? repo.approve(
              a,
              r.id,
              expectedRevision: r.revision,
              idempotencyKey: k,
            )
          : repo.refuse(
              a,
              r.id,
              reason: alasan,
              expectedRevision: r.revision,
              idempotencyKey: k,
            ),
    );
    if (mounted && hasil is Ok) {
      _ubah(() {
        _formTolak = null;
        _alasan.clear();
        _pesan = '';
      });
    }
  }

  Future<void> _ubahJumlah(FundRequest r) async {
    final hasil = await _jalankan(
      r.id,
      (a, k) => ref
          .read(fundRequestRepositoryProvider)
          .changeAmount(
            a,
            r.id,
            int.tryParse(hanyaAngka(_jmlBaru.text, simpanNol: true)) ?? 0,
            reason: _alasan.text.trim(),
            expectedRevision: r.revision,
            idempotencyKey: k,
          ),
    );
    if (mounted && hasil is Ok) {
      _ubah(() {
        _formJumlah = null;
        _alasan.clear();
        _jmlBaru.clear();
        _pesan = '';
      });
    }
  }

  Future<void> _bayar(FundRequest r) async {
    final hasil = await _jalankan(
      r.id,
      (a, k) => ref
          .read(fundRequestRepositoryProvider)
          .recordPayment(
            a,
            r.id,
            expectedRevision: r.revision,
            idempotencyKey: k,
          ),
    );
    if (mounted && hasil is Ok) _ubah(() => _pesan = '');
  }

  Future<void> _bukukan(FundRequest r) async {
    final tx = ref.read(transactionRepositoryProvider);
    final t = tx.get(r.paymentTransactionId ?? '');
    if (t == null) return;
    final hasil = await _jalankan(
      r.id,
      (a, k) =>
          tx.finalize(a, t.id, expectedRevision: t.revision, idempotencyKey: k),
    );
    if (mounted && hasil is Ok) _ubah(() => _pesan = '');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final a = ref.watch(actorProvider);
    final hari = ref.watch(hariIniProvider);
    final can = ref.watch(canProvider);
    final orang = ref.watch(peopleRepositoryProvider);
    final danaRepo = ref.watch(fundRepositoryProvider);
    final tx = ref.watch(transactionRepositoryProvider);
    final batas = ref.watch(approverTableRepositoryProvider).table().threshold;
    final saya = a?.personId ?? '';
    final grants = [
      for (final g in can.grantsOf(saya, at: hari))
        if (g.kind != GrantKind.member) g,
    ];
    bool persis(Capability c, String scopeId) =>
        grants.any((g) => g.scopeId == scopeId && g.capabilities.contains(c));
    final bendahara =
        a != null &&
        can.can(a, Capability.financeRecord, ScopeRef.jemaat, at: hari);
    final bolehSetuju = grants.any(
      (g) => g.capabilities.contains(Capability.requestsApprove),
    );
    final lingkupAju = {
      for (final g in grants)
        if (g.capabilities.contains(Capability.requestsSubmit)) g.scopeId,
    };
    final daftar = [
      for (final v in ref.watch(fundRequestRepositoryProvider).list())
        if (v.request.requestedBy == saya ||
            persis(Capability.requestsApprove, v.request.approverScopeId) ||
            bendahara)
          v,
    ];
    String nama(String id) => orang.person(id)?.name ?? '';
    final pilihanDana = lingkupAju.isEmpty
        ? const <Fund>[]
        : ref.watch(fundRequestRepositoryProvider).requestableFunds(saya);
    String namaDana(String id) =>
        danaRepo.fund(id)?.name ??
        pilihanDana.where((f) => f.id == id).firstOrNull?.name ??
        '';
    final dipilih = pilihanDana.where((f) => f.id == _dana).firstOrNull;
    final sebab = _sebab();

    Widget? penolakan(String id) => _tolak?.$1 == id
        ? Penolakan(
            tindakan: _tolak!.$2.action,
            sebab: _tolak!.$2.whoCanAct == null
                ? _tolak!.$2.because
                : '${_tolak!.$2.because} Yang perlu bertindak: '
                      '${_tolak!.$2.whoCanAct}.',
            jalan: const [],
            ukuranTeks: 14,
          )
        : null;

    List<Widget> kartu(FundRequestView v) {
      final r = v.request;
      final d = r.decision;
      final milikSaya = r.requestedBy == saya;
      final putus =
          !milikSaya && persis(Capability.requestsApprove, r.approverScopeId);
      final tunggu = v.state == FundRequestState.waiting;
      final lama = r.decisions.where((x) => x.superseded).lastOrNull;
      final bayar = tx.get(r.paymentTransactionId ?? '');
      final (label, bentuk) = switch (v.state) {
        FundRequestState.waiting => (
          'Menunggu persetujuan',
          BentukLencana.draf,
        ),
        FundRequestState.approved => (
          'Disetujui oleh ${nama(d?.by ?? '')}',
          BentukLencana.laut,
        ),
        FundRequestState.refused => ('Tidak disetujui', BentukLencana.bata),
        FundRequestState.noApprovalNeeded => (
          'Tidak diperlukan',
          BentukLencana.garis,
        ),
        FundRequestState.paymentRecorded => (
          'Pembayaran dicatat',
          BentukLencana.draf,
        ),
        FundRequestState.paid => ('Dibayar', BentukLencana.tinta),
      };
      return [
        KartuFakta(
          anak: [
            KepalaLencana(
              'Permintaan dana · ${r.purpose}',
              label,
              bentuk: bentuk,
            ),
            BarisFakta(
              'Jumlah (Rp)',
              rp(r.amount),
              mono: true,
              berat: FontWeight.w500,
            ),
            BarisFakta('Diambil dari peruntukan', namaDana(r.fundId)),
            BarisFakta(
              'Diajukan oleh',
              '${nama(r.requestedBy)}, ${r.requesterTitle}',
            ),
            ...switch (v.state) {
              FundRequestState.waiting => [
                Keterangan(
                  'Diajukan ${tgl(r.requestedAt)} · menunggu '
                  '${r.approverTitle}',
                ),
              ],
              FundRequestState.approved => [
                Keterangan(
                  'Disetujui di aplikasi oleh orang yang masuk sendiri, '
                  '${tgl(d!.at)}.',
                ),
              ],
              FundRequestState.refused => [
                BarisPolos('Alasan: ${d?.reason ?? ''}'),
                Keterangan('Oleh ${nama(d?.by ?? '')}, ${tgl(d!.at)}'),
              ],
              FundRequestState.noApprovalNeeded => [
                Keterangan(
                  'Tidak diperlukan (aturan: di bawah ${rp(batas)} tidak '
                  'perlu persetujuan).',
                ),
              ],
              FundRequestState.paymentRecorded => [
                const Keterangan(
                  'Uang Muka diberikan sudah dicatat. Dibukukan setelah '
                  'diperiksa Pemeriksa kedua.',
                ),
              ],
              FundRequestState.paid => [
                Keterangan(
                  'Dibukukan Bendahara Jemaat sebagai Uang Muka diberikan, '
                  '${bayar?.finalizedAt == null ? '' : tgl(bayar!.finalizedAt!)}. '
                  'Pertanggungjawabannya dicatat pada kasus Uang Muka.',
                ),
              ],
            },
            if (tunggu && lama != null)
              Keterangan(
                'Jumlah diubah dari ${rp(lama.amount)} menjadi '
                '${rp(r.amount)} setelah disetujui. Persetujuan lama tidak '
                'berlaku lagi dan tetap ada di Riwayat.',
              ),
          ],
        ),
        if (milikSaya && tunggu && bolehSetuju) ...[
          Penolakan(
            tindakan: 'Setujui',
            sebab:
                'permintaan ini Anda ajukan sendiri sebagai '
                '${r.requesterTitle}.',
            jalan: const [],
          ),
          const Keterangan(
            'Jabatan Anda yang lain tidak membuka jalan menyetujui '
            'permintaan sendiri.',
          ),
        ],
        if (putus && tunggu && _formTolak != r.id)
          BarisTombol(
            anak: [
              Tombol(
                'Setujui',
                jenis: JenisTombol.tinta,
                onPressed: () => _putus(r),
              ),
              Tombol(
                'Tidak disetujui',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                onPressed: () => _ubah(() {
                  _formTolak = r.id;
                  _alasan.clear();
                  _pesan = '';
                }),
              ),
            ],
          ),
        if (putus && tunggu && _formTolak == r.id) ...[
          IsianAlur(
            label: 'Alasan · wajib',
            controller: _alasan,
            baris: 3,
            onChanged: (_) => setState(() {}),
          ),
          BarisTombol(
            anak: [
              TombolBersyarat(
                label: 'Catat tidak disetujui',
                tindakan: 'Tidak disetujui',
                alasan: _sebabTolak(),
                periksa: _sebabTolak,
                sudahMulai: false,
                onPressed: () => _putus(r, alasan: _alasan.text.trim()),
              ),
              Tombol(
                'Kembali',
                jenis: JenisTombol.teks,
                ukuran: UkuranTombol.kecil,
                onPressed: () => _ubah(() => _formTolak = null),
              ),
            ],
          ),
        ],
        if (milikSaya &&
            r.paymentTransactionId == null &&
            v.state != FundRequestState.refused &&
            _formJumlah != r.id)
          BarisTombol(
            anak: [
              Tombol(
                'Ubah jumlah',
                jenis: JenisTombol.teks,
                ukuran: UkuranTombol.kecil,
                onPressed: () => _ubah(() {
                  _formJumlah = r.id;
                  _formTolak = null;
                  _alasan.clear();
                  _jmlBaru.clear();
                  _pesan = '';
                }),
              ),
            ],
          ),
        if (milikSaya && _formJumlah == r.id) ...[
          IsianAlur(
            label: 'Jumlah baru (Rp)',
            controller: _jmlBaru,
            petunjuk: '0',
            keterangan: rpDigit(hanyaAngka(_jmlBaru.text, simpanNol: true)),
            keyboard: TextInputType.number,
            formatter: const [RupiahInputFormatter(sisakanNol: true)],
            onChanged: (_) => _ubah(() {}),
          ),
          IsianAlur(
            label: 'Alasan · wajib',
            controller: _alasan,
            baris: 3,
            onChanged: (_) => _ubah(() {}),
          ),
          BarisTombol(
            anak: [
              Tombol(
                'Simpan jumlah',
                jenis: JenisTombol.tinta,
                onPressed: () => _ubahJumlah(r),
              ),
              Tombol(
                'Kembali',
                jenis: JenisTombol.teks,
                ukuran: UkuranTombol.kecil,
                onPressed: () => _ubah(() => _formJumlah = null),
              ),
            ],
          ),
        ],
        if (v.state == FundRequestState.approved)
          const Catatan(
            status: GarisStatus.draf,
            tebal: 'Disetujui bukan berarti sudah dibayar.',
            sisa:
                'Pembayarannya adalah Belanja tersendiri yang dibukukan '
                'Bendahara Jemaat.',
            redup: true,
          ),
        if (bendahara && v.payable && !milikSaya)
          BarisTombol(
            anak: [
              Tombol(
                'Catat pembayaran',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                onPressed: () => _bayar(r),
              ),
            ],
          ),
        if (bendahara && v.state == FundRequestState.paymentRecorded)
          BarisTombol(
            anak: [
              Tombol(
                'Bukukan sebagai Uang Muka',
                jenis: JenisTombol.tinta,
                onPressed: () => _bukukan(r),
              ),
            ],
          ),
        ?penolakan(r.id),
      ];
    }

    final ids = {for (final v in daftar) v.request.id};
    final riw = [
      for (final r
          in ref
              .watch(auditRepositoryProvider)
              .list(const AuditFilter(module: Module.inAppApprovals)))
        if (ids.contains(r.ref?.id))
          '${tgl(r.at)} · ${r.summary} · ${r.actorLine}',
    ];

    final isi = <Widget>[
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (lingkupAju.isNotEmpty) ...[
        IsianAlur(
          label: 'Keperluan',
          controller: _perlu,
          petunjuk: 'Contoh: Kunjungan diakonia Desember',
          onChanged: (_) => _ubah(() => _pesan = ''),
        ),
        IsianAlur(
          label: 'Jumlah (Rp)',
          controller: _jml,
          petunjuk: '0',
          keterangan: rpDigit(hanyaAngka(_jml.text, simpanNol: true)),
          keyboard: TextInputType.number,
          formatter: const [RupiahInputFormatter(sisakanNol: true)],
          onChanged: (_) => _ubah(() => _pesan = ''),
        ),
        ChipPilihan<String>(
          label: 'Diambil dari peruntukan',
          jarakLabel: 6,
          jarakBawah: 0,
          pilihan: [for (final f in pilihanDana) (nilai: f.id, teks: f.name)],
          terpilih: _dana,
          onPilih: (v) => _ubah(() {
            _dana = v;
            _pesan = '';
          }),
        ),
        if (penolakan('') case final p?)
          p
        else if ((_perlu.text.isNotEmpty || _jml.text.isNotEmpty) &&
            sebab.isNotEmpty)
          Penolakan(
            tindakan: 'Ajukan',
            sebab: sebab,
            jalan: const [],
            ukuranTeks: 14,
          ),
        BarisTombol(
          anak: [
            TombolBersyarat(
              label: 'Ajukan permintaan',
              tindakan: 'Ajukan',
              alasan: sebab,
              periksa: _sebab,
              sudahMulai: false,
              onPressed: () => _ajukan(
                lingkupAju.contains(dipilih?.ownerScopeId)
                    ? dipilih?.ownerScopeId
                    : null,
              ),
            ),
          ],
        ),
      ],
      // Keyed per request, so its actions are found under its card.
      for (final v in daftar)
        Column(
          key: ValueKey(v.request.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: kartu(v),
        ),
      if (daftar.isEmpty && bendahara)
        const KartuFakta(
          anak: [
            Text(
              'Belum ada yang perlu dibukukan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Keterangan('Permintaan dana muncul di sini setelah Disetujui.'),
          ],
        ),
      if (riw.isNotEmpty) RiwayatAlur(baris: riw),
    ];

    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Permintaan dana',
              anakJudul:
                  'Minta, periksa, setujui, bayar, verifikasi: lima tindakan '
                  'yang terpisah',
              kembaliKe: Layar.beranda,
              labelKembali: 'Kembali ke Beranda',
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _gulir,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                // ponytail: IsianTeks inherits the theme bodyLarge's 0.5
                // letterSpacing; drop this once IsianTeks sets 0 itself.
                child: DefaultTextStyle.merge(
                  style: const TextStyle(letterSpacing: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: isi,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
