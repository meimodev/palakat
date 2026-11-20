import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/actor.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'pengumuman_bagian.dart';
import 'sekretariat_bersama.dart';
import 'warta_arsip_bagian.dart';

/// 66 · WartaEditor + 71 · AlurWarta (README 7.1; specs 18, 19), phone.
class WartaEditorScreen extends ConsumerWidget {
  const WartaEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(revisionProvider);
    final id = edisiDariRute(context);
    final e = ref.watch(wartaRepositoryProvider).edition(id);
    return LayarPonsel(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: e == null
                  ? 'Warta Jemaat'
                  : 'Warta Jemaat · edisi ${tgl(e.sunday.awal)}',
              anakJudul:
                  'Disusun dari data yang sudah ada; tidak diketik ulang',
              kembaliKe: Layar.warta,
              labelKembali: 'Kembali ke Warta Jemaat',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: IsiWartaEditor(edisiId: id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The edition of the coming Sunday from Draf to Diterbitkan (AlurWarta):
/// the Sekretaris Jemaat picks published announcements (P17), may write a
/// new one, opens BukaNama for a name exception, and performs every step
/// herself, each recorded (rulebook 14.7). After review the content is
/// locked (P18); after publishing a correction is a linked ralat. Sections
/// of the Warta come from data already recorded (spec 18). The finance
/// excerpt joins in M10 (J3).
class IsiWartaEditor extends ConsumerStatefulWidget {
  const IsiWartaEditor({super.key, required this.edisiId});

  final String edisiId;

  @override
  ConsumerState<IsiWartaEditor> createState() => _IsiWartaEditorState();
}

enum _V { warta, umum, ralat }

class _IsiWartaEditorState extends ConsumerState<IsiWartaEditor> {
  var _v = _V.warta;
  var _pesan = '';
  Refusal? _tolak;
  final _ralat = TextEditingController();

  @override
  void dispose() {
    _ralat.dispose();
    super.dispose();
  }

  void _ke(_V v, [String pesan = '']) {
    setState(() {
      _v = v;
      _pesan = pesan;
      _tolak = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Scrollable.maybeOf(context)?.position.jumpTo(0);
    });
  }

  Future<void> _jalankan(Future<Result<void>> perintah, [String? pesan]) async {
    final r = await perintah;
    if (!mounted) return;
    switch (r) {
      case Ok():
        _ke(_V.warta, pesan ?? '');
      case Refused(:final refusal):
        setState(() => _tolak = refusal);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final repo = ref.watch(wartaRepositoryProvider);
    final e = repo.edition(widget.edisiId);
    if (e == null) return kecilSek(context, 'Edisi ini tidak ditemukan.');
    final isi = switch (_v) {
      _V.umum => [
        FormPengumuman(
          edisi: e,
          onSelesai: (p) => _ke(_V.warta, p),
          onBatal: () => _ke(_V.warta),
        ),
      ],
      _V.ralat => _viewRalat(e),
      _V.warta => _viewWarta(e, repo.preview(e.id)!),
    };
    return kolomSek(isi, 16);
  }

  // ---- parts ----

  TextStyle get _polos => TextStyle(fontSize: 14, color: context.warna.tinta2);

  Widget _kartu(List<Widget> anak) => Kartu(child: kolomSek(anak, 6));

  Widget _kepala(String judul, String ket) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
      kecilSek(context, ket),
    ],
  );

  Widget _teksAwal(String label, VoidCallback onTap) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Tombol(
      label,
      onPressed: onTap,
      jenis: JenisTombol.teks,
      ukuran: UkuranTombol.kecil,
      lebarPenuh: false,
    ),
  );

  Widget _kuat(String awal, String kuat) => Text.rich(
    TextSpan(
      children: [
        TextSpan(text: awal),
        TextSpan(
          text: kuat,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: context.warna.tinta,
          ),
        ),
      ],
    ),
    style: _polos,
  );

  Widget _barisUmum(WartaEdition e, Announcement u, bool draf) {
    final c = context.warna;
    final on = e.announcementIds.contains(u.id);
    final semua = u.audience == Audience.all;
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: BarisLentur(
        jarak: 12,
        jarakBaris: 6,
        rata: CrossAxisAlignment.center,
        anak: [
          Lentur(
            dasar: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                kecilSek(
                  context,
                  'Ditujukan untuk: ${u.audience.label}'
                  '${on && !semua ? ' · perhatikan: Warta dibaca semua anggota' : ''}',
                ),
              ],
            ),
          ),
          Lentur(
            dasar: 150,
            tumbuh: 0,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ChipSatu(
                teks: on ? 'Masuk edisi ini' : 'Tidak masuk',
                dipilih: on,
                onTap: draf
                    ? () => _jalankan(
                        ref
                            .read(wartaRepositoryProvider)
                            .pickAnnouncement(
                              aktorSek(ref),
                              e.id,
                              u.id,
                              !on,
                              expectedRevision: e.revision,
                              idempotencyKey: kunciSek(ref),
                            ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- views ----

  List<Widget> _viewWarta(WartaEdition e, WartaPreview p) {
    final repo = ref.read(wartaRepositoryProvider);
    final st = e.status;
    final draf = st == WartaStatus.draft;
    final hari = ref.watch(hariIniProvider);
    final edisi = tgl(e.sunday.awal);
    final umum = [
      for (final u in ref.watch(announcementRepositoryProvider).list())
        if (u.status != AnnouncementStatus.draft &&
            (e.announcementIds.contains(u.id) ||
                draf && u.statusAt(hari) == AnnouncementStatus.published))
          u,
    ];
    Future<void> langkah(
      Future<Result<void>> Function(
        Actor,
        String, {
        required int expectedRevision,
        required String idempotencyKey,
      })
      f,
    ) => _jalankan(
      f(
        aktorSek(ref),
        e.id,
        expectedRevision: e.revision,
        idempotencyKey: kunciSek(ref),
      ),
    );
    final keDraf = Tombol(
      'Kembali ke Draf',
      onPressed: () => langkah(repo.returnToDraft),
      jenis: JenisTombol.teks,
      ukuran: UkuranTombol.kecil,
    );
    final lihatPdf = Tombol(
      'Lihat PDF',
      onPressed: () => context.dorongKe(Layar.wartaPdf, param: {'edisi': e.id}),
      jenis: JenisTombol.kedua,
      ukuran: UkuranTombol.sedang,
    );
    final riwayat = riwayatSek(ref, AuditFilter(ref: RecordRef('warta', e.id)));
    final anonim = p.events.any(
      (x) =>
          x.event.anonymousAs != null &&
          x.event.personId != null &&
          e.exceptionFor(x.event.personId!) == null,
    );
    return [
      KepalaKartu(judul: 'Edisi $edisi', ujung: lencanaWarta(st)),
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (_tolak != null) penolakanSek(_tolak!),
      _kartu([
        _kepala(
          'Pengumuman',
          'Sekretaris Jemaat memilih dari pengumuman yang Diterbitkan',
        ),
        for (final u in umum) _barisUmum(e, u, draf),
        if (draf) _teksAwal('Tulis pengumuman', () => _ke(_V.umum)),
      ]),
      if (e.services != null)
        _kartu([
          _kepala('Ibadah minggu ini', 'dari Ibadah dan kegiatan'),
          Text('Minggu $edisi: ${e.services}', style: _polos),
        ]),
      if (e.attendance case final h?)
        _kartu([
          _kepala('Jumlah kehadiran', 'hanya yang Ditetapkan'),
          Text(
            'Minggu ${tgl(h.sunday.awal)}: ${h.total} orang (${h.parts})',
            style: _polos,
          ),
          kecilSek(context, 'Jumlah saja. Tidak ada nama.'),
        ]),
      if (p.events.isNotEmpty)
        _kartu([
          _kepala(
            'Peristiwa jemaat',
            'hanya yang Diverifikasi; nama mengikuti Tampilan nama',
          ),
          for (final x in p.events)
            _kuat(
              '${x.event.label}: ',
              x.printed == x.event.name && x.event.anonymousAs != null
                  ? '${x.printed} (pengecualian tercatat)'
                  : x.printed,
            ),
          if (draf && anonim)
            _teksAwal(
              'Tampilkan nama (pengecualian)',
              () => context.dorongKe(Layar.bukaNama, param: {'edisi': e.id}),
            ),
        ]),
      if (draf)
        BarisTombol(
          anak: [
            Tombol(
              'Tandai sudah diperiksa',
              onPressed: () => langkah(repo.submit),
              jenis: JenisTombol.tinta,
            ),
            lihatPdf,
          ],
        ),
      if (st == WartaStatus.review) ...[
        kecilSek(
          context,
          'Diperiksa oleh ${namaSek(ref, e.reviewedBy!)}, '
          '${tglJam(e.reviewedAt!)}.',
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Setujui untuk diterbitkan',
              onPressed: () => langkah(repo.approve),
              jenis: JenisTombol.tinta,
            ),
            keDraf,
          ],
        ),
      ],
      if (st == WartaStatus.approved) ...[
        Text(
          'Disetujui oleh ${namaSek(ref, e.approvedBy!)}, '
          '${tglJam(e.approvedAt!)}.',
          style: _polos,
        ),
        kecilSek(
          context,
          'Sekretaris Jemaat menjalankan setiap langkah sendiri; tiap langkah '
          'tetap dicatat.',
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Terbitkan',
              jenis: JenisTombol.utama,
              onPressed: () => langkah(repo.publish),
            ),
            keDraf,
          ],
        ),
      ],
      if (st == WartaStatus.published || st == WartaStatus.archived) ...[
        Text(
          'Diterbitkan ${tglJam(e.publishedAt!)} untuk semua anggota. Edisi '
          'ini tidak berubah lagi; ralat menjadi revisi yang tertaut.',
          style: _polos,
        ),
        BarisTombol(
          anak: [
            lihatPdf,
            if (st == WartaStatus.published)
              Tombol(
                'Buat ralat',
                onPressed: () => _ke(_V.ralat),
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
              ),
          ],
        ),
      ],
      if (st == WartaStatus.review || st == WartaStatus.approved)
        kecilSek(
          context,
          'Untuk mengubah isinya, kembalikan edisi ke Draf lebih dulu.',
        ),
      for (final r in e.ralats)
        _kartu([
          KepalaKartu(
            judul: 'Ralat (revisi edisi $edisi)',
            ujung: const LencanaStatus(
              'Diterbitkan',
              bentuk: BentukLencana.tinta,
            ),
          ),
          Text(r.text, style: _polos),
          kecilSek(
            context,
            'Tertaut ke edisi asli, yang tetap tampil apa adanya.',
          ),
        ]),
      if (riwayat.isNotEmpty) RiwayatAlur(baris: riwayat),
    ];
  }

  String _aR() => _ralat.text.trim().isEmpty ? 'yang diralat belum diisi.' : '';

  List<Widget> _viewRalat(WartaEdition e) => [
    _kartu([
      KepalaKartu(
        judul: 'Warta Jemaat · edisi ${tgl(e.sunday.awal)}',
        ujung: lencanaWarta(e.status),
      ),
      kecilSek(
        context,
        'Edisi asli tidak diubah. Ralat diterbitkan sebagai revisi yang '
        'tertaut.',
      ),
    ]),
    IsianAlur(
      label: 'Yang diralat · wajib',
      controller: _ralat,
      onChanged: (_) => setState(() => _tolak = null),
      baris: 3,
    ),
    if (_tolak != null)
      penolakanSek(_tolak!)
    else if (_ralat.text.isNotEmpty && _aR().isNotEmpty)
      penolakanSek(Refusal(action: 'Terbitkan ralat', because: _aR())),
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: 'Terbitkan ralat',
          tindakan: 'Terbitkan ralat',
          alasan: _aR(),
          periksa: _aR,
          sudahMulai: false,
          onPressed: () async {
            final teks = _ralat.text.trim();
            await _jalankan(
              ref
                  .read(wartaRepositoryProvider)
                  .ralat(
                    aktorSek(ref),
                    e.id,
                    reason: teks,
                    expectedRevision: e.revision,
                    idempotencyKey: kunciSek(ref),
                  ),
            );
            if (mounted) _ralat.clear();
          },
        ),
        Tombol(
          'Batalkan',
          onPressed: () => _ke(_V.warta),
          jenis: JenisTombol.teks,
          ukuran: UkuranTombol.kecil,
        ),
      ],
    ),
  ];
}
