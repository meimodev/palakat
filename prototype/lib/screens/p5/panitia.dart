import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart' show perintah;
import '../../providers/repositories_keuangan.dart';
import '../../providers/repositories_kolaborasi.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tahapan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'permintaan_dana_keadaan.dart';

/// "Belum ada dokumen" in the decision chips.
const _tanpaDokumen = '';

/// 89 · Panitia + AlurPanitia + AlurPanitiaBaru (spec 22, 23; README 7.1):
/// the authorized church officer forms a Panitia from a written decision
/// with three distinct officers and moves its stages; the church Bendahara
/// takes back the unused advance and approves where the leftover goes; it
/// then closes and is retired, read-only (DL27, DP27).
class PanitiaScreen extends ConsumerStatefulWidget {
  const PanitiaScreen({super.key});

  @override
  ConsumerState<PanitiaScreen> createState() => _PanitiaState();
}

class _PanitiaState extends ConsumerState<PanitiaScreen> {
  final _gulir = ScrollController();
  final _nama = TextEditingController();
  String? _pilih, _ketua, _sek, _bend, _dok, _tujuan;
  bool _baru = false;
  String _pesan = '';
  Refusal? _tolak;

  @override
  void dispose() {
    _gulir.dispose();
    _nama.dispose();
    super.dispose();
  }

  /// AlurPanitiaBaru's `a`: the first unmet reason of "Bentuk Panitia".
  String _alasan() {
    const beda =
        'Ketua, Sekretaris dan Bendahara harus tiga orang yang berbeda.';
    if (_nama.text.trim().isEmpty) return 'nama Panitia belum diisi.';
    if (_ketua == null) return 'Ketua belum dipilih.';
    if (_sek == null) return 'Sekretaris belum dipilih.';
    if (_sek == _ketua) return beda;
    if (_bend == null) return 'Bendahara belum dipilih.';
    if (_bend == _ketua || _sek == _bend) return beda;
    if (_dok == null) return 'keputusan gereja belum dipilih.';
    return '';
  }

  Future<Result<T>?> _jalankan<T>(
    Future<Result<T>> Function(Actor a, String k) jalan,
  ) async {
    final r = await perintah(ref, jalan);
    if (mounted) setState(() => _tolak = r?.refusal);
    return r;
  }

  void _keAtas() {
    if (_gulir.hasClients) _gulir.jumpTo(0);
  }

  Future<void> _bentuk() async {
    final r = await _jalankan(
      (a, k) => ref
          .read(panitiaRepositoryProvider)
          .create(
            a,
            _nama.text,
            _dok!,
            PanitiaOfficers(
              ketuaId: _ketua!,
              sekretarisId: _sek!,
              bendaharaId: _bend!,
            ),
            idempotencyKey: k,
          ),
    );
    if (r is! Ok<Panitia> || !mounted) return;
    setState(() {
      _pilih = r.value.id;
      _baru = false;
      _pesan = '';
      _nama.clear();
      _ketua = _sek = _bend = _dok = null;
    });
    _keAtas();
  }

  Future<void> _tahap(Panitia p) async {
    final r = await _jalankan(
      (a, k) => ref
          .read(panitiaRepositoryProvider)
          .advanceStage(
            a,
            p.id,
            expectedRevision: p.revision,
            idempotencyKey: k,
          ),
    );
    if (r is Ok<Panitia> && mounted) {
      setState(
        () => _pesan = r.value.stage == PanitiaStage.active
            ? 'Ketua, Sekretaris dan Bendahara Panitia diberi tahu lewat '
                  'Pemberitahuan.'
            : '',
      );
    }
  }

  /// "Catat pengembalian sisa": the advance's remainder back to its Kas,
  /// then Bukukan at once (refused until checked, D24).
  Future<void> _kembalikan(CaseView v) async {
    final r = await _jalankan(
      (a, k) => ref
          .read(caseRepositoryProvider)
          .returnUnused(
            a,
            v.kase.id,
            CaseEntryDraft(amount: v.outstanding, accountId: v.kase.accountId),
            expectedRevision: v.kase.revision,
            idempotencyKey: k,
          ),
    );
    if (r is Ok<String>) await _bukukan(r.value);
  }

  Future<void> _bukukan(String txId) async {
    final t = ref.read(transactionRepositoryProvider).get(txId);
    if (t == null) return;
    await _jalankan(
      (a, k) => ref
          .read(transactionRepositoryProvider)
          .finalize(a, t.id, expectedRevision: t.revision, idempotencyKey: k),
    );
  }

  Future<void> _setujuiSisa(Panitia p) => _jalankan(
    (a, k) => ref
        .read(panitiaRepositoryProvider)
        .approveLeftover(
          a,
          p.id,
          _tujuan ?? '',
          expectedRevision: p.revision,
          idempotencyKey: k,
        ),
  );

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final a = ref.watch(actorProvider);
    final hari = ref.watch(hariIniProvider);
    final can = ref.watch(canProvider);
    final repo = ref.watch(panitiaRepositoryProvider);
    final orang = ref.watch(peopleRepositoryProvider);
    String nama(String? id) => orang.person(id ?? '')?.name ?? '';
    bool boleh(Capability k) =>
        a != null && can.can(a, k, ScopeRef.jemaat, at: hari);
    final daftar = repo.list();
    final p =
        daftar.where((x) => x.id == _pilih).firstOrNull ??
        daftar
            .where((x) => x.stage.index < PanitiaStage.closed.index)
            .lastOrNull ??
        daftar.firstOrNull;

    final isi = <Widget>[
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (daftar.length > 1 && !_baru)
        ChipPilihan<String>(
          label: 'Panitia',
          jarakLabel: 6,
          jarakBawah: 0,
          pilihan: [for (final x in daftar) (nilai: x.id, teks: x.name)],
          terpilih: p?.id,
          onPilih: (v) => setState(() {
            _pilih = v;
            _tolak = null;
            _pesan = '';
          }),
        ),
      if (_baru) ..._formBaru() else if (p != null) ..._panitia(p, nama, boleh),
      if (_tolak case final r?) penolakanDari(r),
      if (!_baru && boleh(Capability.panitiaCreate))
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Tombol(
            'Membentuk Panitia baru',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            lebarPenuh: false,
            onPressed: () {
              setState(() {
                _baru = true;
                _tolak = null;
                _pesan = '';
              });
              _keAtas();
            },
          ),
        ),
      if (!_baru && p != null) ?_riwayat(p),
    ];

    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: _baru ? 'Membentuk Panitia' : p?.name ?? 'Panitia',
              anakJudul: _baru
                  ? 'Dari keputusan gereja sampai Panitia Aktif'
                  : 'Unit sementara dengan peruntukannya sendiri',
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

  /// One Panitia: stage row, committee card, its money and the next step.
  List<Widget> _panitia(
    Panitia p,
    String Function(String?) nama,
    bool Function(Capability) boleh,
  ) {
    final m = ref.watch(panitiaRepositoryProvider).money(p.id);
    final dana = ref.watch(fundRepositoryProvider);
    final kasus = ref.watch(caseRepositoryProvider);
    final tx = ref.watch(transactionRepositoryProvider);
    final sk = ref.watch(documentRepositoryProvider).get(p.skDocumentId ?? '');
    final namaDana = p.fundId == null ? null : dana.fund(p.fundId!)?.name;
    final o = p.officers;
    final judulUm = [
      for (final id in m.advanceIds) ?kasus.caseById(id)?.kase.title,
    ].join(', ');
    final terbuka = [
      for (final id in m.advanceIds)
        if (kasus.caseById(id) case final v? when v.outstanding > 0) v,
    ];
    final drafKembali = [
      for (final t in tx.drafts())
        if (t.type == TransactionType.advanceReturn &&
            t.allocations.any((x) => m.advanceIds.contains(x.caseId)))
          t,
    ];
    final bendahara = boleh(Capability.panitiaApproveLeftover);
    final tujuanDana = [
      for (final f in dana.funds())
        if (f.ownerScopeId == ScopeRef.jemaatId && f.id != p.fundId) f,
    ];
    final tombolTahap = switch (p.stage.next) {
      PanitiaStage.active => 'Aktifkan Panitia',
      PanitiaStage.eventCompleted => 'Tandai acara selesai',
      PanitiaStage.financialClosing => 'Mulai penutupan keuangan',
      PanitiaStage.closed => 'Tutup Panitia',
      PanitiaStage.retired => 'Arsipkan',
      _ => null,
    };

    Widget kepalaUang(String judul, int n) => KepalaKartu(
      judul: judul,
      ujung: Text(
        rp(n),
        style: const TextStyle(
          fontFamily: PalakatText.mono,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    final uangMuka = m.advanceIds.isEmpty
        ? null
        : KartuFakta(
            anak: [
              KepalaLencana(
                'Uang Muka · $judulUm',
                m.outstanding > 0
                    ? 'Belum dipertanggungjawabkan'
                    : 'Sudah dipertanggungjawabkan',
                bentuk: m.outstanding > 0
                    ? BentukLencana.bata
                    : BentukLencana.laut,
              ),
              BarisFakta('Diberikan', rp(m.advanced), mono: true),
              BarisFakta('Dipertanggungjawabkan', rp(m.settled), mono: true),
              BarisFakta('Dikembalikan', rp(m.returned), mono: true),
              BarisFakta(
                'Belum dipertanggungjawabkan',
                rp(m.outstanding),
                mono: true,
              ),
            ],
          );

    return [
      Tahapan(
        langkah: [for (final s in PanitiaStage.values) s.label],
        selesai: p.stage.index + 1,
      ),
      if (o != null)
        KartuFakta(
          anak: [
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            BarisFakta('Ketua', nama(o.ketuaId)),
            BarisFakta('Sekretaris', nama(o.sekretarisId)),
            BarisFakta('Bendahara', nama(o.bendaharaId)),
            if (namaDana != null) BarisFakta('Peruntukan', namaDana),
            if (sk != null) BarisFakta('Dasar', '${sk.title} · Dokumen gereja'),
          ],
        ),
      ...switch (p.stage) {
        PanitiaStage.planning => [
          const Keterangan(
            'Dibuat oleh Pimpinan Jemaat yang berwenang dari SK-nya. Hanya '
            'ia yang memindahkan tahap.',
          ),
          const Keterangan(
            'Selama Perencanaan, Panitia belum dapat membukukan. '
            'Peruntukannya dibuat saat diaktifkan.',
          ),
        ],
        PanitiaStage.active || PanitiaStage.eventCompleted => [
          KartuFakta(
            anak: [
              kepalaUang(
                'Saldo buku peruntukan ${namaDana ?? p.name}',
                m.fundBalance,
              ),
              const Keterangan(
                'Bendahara Panitia membukukan di peruntukan ini.',
              ),
            ],
          ),
          ?uangMuka,
        ],
        PanitiaStage.financialClosing => [
          KartuFakta(
            anak: [
              kepalaUang(
                'Sisa uang',
                m.fundBalance + m.returned + m.outstanding,
              ),
              BarisFakta(
                'Uang Muka belum dipertanggungjawabkan',
                rp(m.outstanding),
                mono: true,
                berat: FontWeight.w500,
              ),
            ],
          ),
          ?uangMuka,
          Penolakan(
            tindakan: 'Bukukan',
            sebab: '${p.name} sedang dalam Penutupan keuangan.',
            jalan: const [],
            ukuranTeks: 15,
          ),
          const Keterangan(
            'Sejak tahap ini Bendahara Panitia tidak membukukan transaksi '
            'biasa. Sisa uang dan aset harus punya tujuan yang disetujui.',
          ),
          if (bendahara) ...[
            for (final v in terbuka)
              BarisTombol(
                anak: [
                  Tombol(
                    'Catat pengembalian sisa ${rp(v.outstanding)}',
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                    onPressed: () => _kembalikan(v),
                  ),
                ],
              ),
            for (final t in drafKembali) ...[
              KartuFakta(
                anak: [
                  KepalaLencana(
                    t.description,
                    t.status == TransactionStatus.reviewed
                        ? 'Sudah diperiksa'
                        : 'Draf',
                    bentuk: BentukLencana.draf,
                  ),
                  BarisFakta('Jumlah', rp(t.total), mono: true),
                  const Keterangan('Uang kembali ke Kas. Bukan Pendapatan.'),
                ],
              ),
              BarisTombol(
                anak: [
                  Tombol(
                    'Bukukan pengembalian',
                    jenis: JenisTombol.tinta,
                    onPressed: () => _bukukan(t.id),
                  ),
                ],
              ),
            ],
            if (terbuka.isEmpty &&
                drafKembali.isEmpty &&
                !p.leftoverApproved) ...[
              ChipPilihan<String>(
                label: 'Tujuan sisa uang',
                jarakLabel: 6,
                jarakBawah: 0,
                pilihan: [
                  for (final f in tujuanDana) (nilai: f.id, teks: f.name),
                ],
                terpilih: _tujuan,
                onPilih: (v) => setState(() {
                  _tujuan = v;
                  _tolak = null;
                }),
              ),
              BarisTombol(
                anak: [
                  Tombol(
                    'Setujui tujuan sisa uang',
                    jenis: JenisTombol.tinta,
                    onPressed: () => _setujuiSisa(p),
                  ),
                ],
              ),
            ],
          ],
          if (p.leftoverApproved)
            KartuFakta(
              anak: [
                // One sans 700 string on the board (spec 22 Notes), not mono.
                KepalaLencana(
                  'Sisa uang ${rp(p.leftoverAmount ?? 0)}',
                  'Disetujui oleh ${nama(p.leftoverApprovedBy)}',
                  bentuk: BentukLencana.laut,
                ),
                BarisFakta(
                  'Tujuan',
                  dana.fund(p.leftoverFundId ?? '')?.name ?? '',
                ),
                Keterangan(
                  'Tujuan sisa uang disetujui Bendahara Jemaat, '
                  '${tgl(p.leftoverApprovedAt!)}.',
                ),
              ],
            ),
        ],
        PanitiaStage.closed => [
          if (namaDana != null)
            Keterangan(
              'Peruntukan $namaDana bersaldo ${rp(m.fundBalance)} dan '
              'dinonaktifkan untuk transaksi baru.',
            ),
          const Keterangan(
            'Panitia yang Ditutup tidak dapat membukukan lagi. Riwayat dan '
            'laporannya tetap dapat dibaca.',
          ),
        ],
        PanitiaStage.retired => [
          const Catatan(
            status: GarisStatus.terpilih,
            tebal: 'Hanya baca.',
            sisa:
                'Panitia yang sudah diarsipkan tidak dihapus; riwayat '
                'keuangan dan dokumennya tetap dapat dibuka.',
          ),
        ],
      },
      if (tombolTahap != null && boleh(Capability.panitiaStage))
        BarisTombol(
          anak: [
            Tombol(
              tombolTahap,
              jenis: p.stage == PanitiaStage.closed
                  ? JenisTombol.kedua
                  : JenisTombol.tinta,
              onPressed: () => _tahap(p),
            ),
          ],
        ),
    ];
  }

  Widget? _riwayat(Panitia p) {
    final baris = [
      for (final r
          in ref
              .watch(auditRepositoryProvider)
              .list(AuditFilter(ref: RecordRef('panitia', p.id))))
        '${tgl(r.at)} · ${r.summary} · ${r.actorLine}',
    ];
    return baris.isEmpty ? null : RiwayatAlur(baris: baris);
  }

  /// AlurPanitiaBaru: name, three officers and a church decision.
  List<Widget> _formBaru() {
    final orang = ref.watch(peopleRepositoryProvider);
    final org = ref.watch(orgRepositoryProvider);
    // The people serving a unit or a Panitia (BIPRA, Komisi, Panitia posts).
    final calon = {
      for (final v in ref.watch(roleRepositoryProvider).posts())
        if (const {
          ScopeType.bipra,
          ScopeType.komisi,
          ScopeType.panitia,
        }.contains(org.scope(v.post.scopeId)?.type))
          ?v.holder?.personId,
    }.toList();
    final dok = [
      for (final d in ref.watch(documentRepositoryProvider).list())
        if (d.kind == DocumentKind.decision) d,
    ];
    final a = _alasan();
    final mulai =
        _nama.text.isNotEmpty ||
        _ketua != null ||
        _sek != null ||
        _bend != null ||
        _dok != null;

    Widget pil(String label, String? nilai, ValueChanged<String> set) =>
        ChipPilihan<String>(
          label: label,
          jarakLabel: 6,
          jarakBawah: 0,
          pilihan: [
            for (final id in calon)
              (nilai: id, teks: orang.person(id)?.name ?? id),
          ],
          terpilih: nilai,
          onPilih: (v) => setState(() {
            set(v);
            _tolak = null;
          }),
        );

    return [
      IsianAlur(
        label: 'Nama Panitia',
        controller: _nama,
        petunjuk: 'Contoh: Panitia Paskah',
        onChanged: (_) => setState(() => _tolak = null),
      ),
      pil('Ketua', _ketua, (v) => _ketua = v),
      pil('Sekretaris', _sek, (v) => _sek = v),
      pil('Bendahara', _bend, (v) => _bend = v),
      ChipPilihan<String>(
        label: 'Keputusan gereja',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [
          for (final d in dok) (nilai: d.id, teks: d.title),
          (nilai: _tanpaDokumen, teks: 'Belum ada dokumen'),
        ],
        terpilih: _dok,
        onPilih: (v) => setState(() {
          _dok = v;
          _tolak = null;
        }),
      ),
      if (mulai && a.isNotEmpty && _tolak == null)
        Penolakan(
          tindakan: 'Bentuk Panitia',
          sebab: a,
          jalan: const [],
          ukuranTeks: 14,
        ),
      TombolBersyarat(
        label: 'Bentuk Panitia',
        tindakan: 'Bentuk Panitia',
        alasan: a,
        periksa: _alasan,
        onPressed: _bentuk,
        sudahMulai: false,
        baris: [
          Tombol(
            'Kembali',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => setState(() {
              _baru = false;
              _tolak = null;
            }),
          ),
        ],
      ),
    ];
  }
}
