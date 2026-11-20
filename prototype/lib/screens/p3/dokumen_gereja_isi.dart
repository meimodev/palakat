import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/actor.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'sekretariat_bersama.dart';

/// Opens the publish form (a new document, or a revision of [dokumenId]) and
/// returns its message once published: phone `terbit`/`ralat` in the
/// DokumenGereja shell, web `terbit` (README 7.2).
Future<String?> bukaFormDokumen(
  BuildContext context, {
  required bool web,
  String? dokumenId,
}) {
  final anak = dokumenId == null || web ? 'terbit' : 'ralat';
  final q = dokumenId == null
      ? ''
      : '?dokumen=${Uri.encodeQueryComponent(dokumenId)}';
  return GoRouter.of(context)
      .push<String>('${Layar.dokumenGereja.lokasi(anak: anak)}$q');
}

/// '{jenis} · {tanggal} · {untuk}', as the rows print it, with
/// '· revisi {n} tetap dapat dibuka' once corrected (AlurDokumen).
String ketDokumen(ChurchDocument d) => [
  d.kind.label,
  if (d.documentDate != null) tgl(d.documentDate!.awal),
  d.audience.label,
  if (d.revisions.length > 1)
    'revisi ${d.current.number - 1} tetap dapat dibuka',
].join(' · ');

/// DokumenGereja and WebDokumenGereja (spec 17), merged with AlurDokumen
/// (README 7.1): the archive the Sekretaris Jemaat keeps. A publisher sees
/// every document; anyone else only those addressed to them. A row opens the
/// document in place with its revisions; each revision stays openable.
class IsiDokumenGereja extends ConsumerStatefulWidget {
  const IsiDokumenGereja({super.key, required this.web});

  final bool web;

  @override
  ConsumerState<IsiDokumenGereja> createState() => _IsiDokumenGerejaState();
}

class _IsiDokumenGerejaState extends ConsumerState<IsiDokumenGereja> {
  String? _pilih;
  String _pesan = '';

  /// Revision numbers whose signed copy is open.
  final _dibuka = <int>{};

  void _ke(String? id) => setState(() {
    _pilih = id;
    _dibuka.clear();
    _keAtas();
  });

  void _keAtas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) Scrollable.maybeOf(context)?.position.jumpTo(0);
  });

  Future<void> _terbit({String? dokumenId}) async {
    final p = await bukaFormDokumen(
      context,
      web: widget.web,
      dokumenId: dokumenId,
    );
    if (!mounted || p == null) return;
    setState(() => _pesan = p);
    _keAtas();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final repo = ref.watch(documentRepositoryProvider);
    final penerbit = bolehSek(ref, Capability.documentsPublish);
    final semua = penerbit || operatorSek(ref);
    final saya = ref.watch(actorProvider)?.personId;
    final dok = semua ? repo.list() : repo.list(audienceOf: saya);
    final riwayat = penerbit
        ? riwayatSek(
            ref,
            const AuditFilter(
              module: Module.churchDocuments,
              actionPrefix: 'document.',
            ),
          )
        : const <String>[];
    final d = _pilih == null
        ? null
        : dok.where((x) => x.id == _pilih).firstOrNull;
    final hari = ref.watch(hariIniProvider);
    final c = context.warna;
    final isi = <Widget>[
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (d != null)
        ..._rinci(context, d, penerbit)
      else if (dok.isEmpty) ...[
        Kartu(
          status: GarisStatus.draf,
          child: kolomSek([
            const Text(
              'Belum ada dokumen',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Mulai dengan menerbitkan satu dokumen: surat keputusan, notulen '
              'rapat, tata ibadah, atau surat untuk anggota.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ], 6),
        ),
        if (penerbit) _tombol('Terbitkan dokumen', _terbit, tinta: true),
      ] else ...[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            const _Chip('Semua jenis', dipilih: true),
            _Chip('Tahun ${hari.tahun}'),
            const _Chip('Ditujukan untuk: semua'),
          ],
        ),
        if (widget.web)
          _TabelWeb(dok: dok, onBuka: _ke)
        else
          for (final x in dok) _BarisPonsel(d: x, onBuka: _ke),
        if (penerbit) _tombol('Terbitkan dokumen', _terbit, tinta: true),
        const Tautan(
          ke: Layar.surat,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            child: TautanTeks('Permohonan surat', ukuran: 14),
          ),
        ),
        if (!semua)
          kecilSek(
            context,
            'Anggota hanya melihat dokumen yang ditujukan untuknya. Dokumen '
            'pendukung keuangan tidak disimpan di sini; itu ada pada '
            'transaksinya.',
          ),
        if (riwayat.isNotEmpty) RiwayatAlur(baris: riwayat),
      ],
    ];
    return kolomSek(isi, 16);
  }

  List<Widget> _rinci(BuildContext context, ChurchDocument d, bool penerbit) {
    final c = context.warna;
    final kini = d.current;
    Widget buka(DocumentRevision r) => _dibuka.contains(r.number)
        ? kecilSek(
            context,
            'Dibuka: ${r.signedCopy.name} · 1 halaman · revisi ${r.number}',
          )
        : _baris(
            Tombol(
              'Buka salinan bertanda tangan',
              onPressed: () => setState(() => _dibuka.add(r.number)),
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
            ),
            tepi: 0,
          );
    return [
      Kartu(
        child: kolomSek([
          _Atas(d.title, d.statusLabel, BentukLencana.tinta),
          Text(
            '${[d.kind.label, if (d.documentDate != null) tgl(d.documentDate!.awal)].join(' · ')} · '
            'Ditujukan untuk: ${d.audience.label}',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          if (kini.ralat != null)
            Text(
              'Yang diralat: ${kini.ralat}',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          kecilSek(
            context,
            '${d.revisions.length > 1 ? 'Revisi yang berlaku. ' : ''}'
            'Diterbitkan oleh ${namaSek(ref, kini.publishedBy)}, '
            '${tglJam(kini.publishedAt)}.',
          ),
          buka(kini),
        ], 6),
      ),
      for (final r in d.revisions.reversed.skip(1))
        Kartu(
          status: GarisStatus.draf,
          child: kolomSek([
            _Atas(
              'Revisi ${r.number}',
              'Digantikan oleh revisi ${r.number + 1}',
              BentukLencana.abu,
            ),
            Text(
              'Diterbitkan ${tglJam(r.publishedAt)}',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            kecilSek(
              context,
              'Tetap dapat dibuka. Dokumen yang sudah diterbitkan tidak pernah '
              'diubah diam-diam; ralat selalu menjadi revisi baru.',
            ),
            buka(r),
          ], 6),
        ),
      if (penerbit && d.kind != DocumentKind.memberLetter)
        _tombol(
          'Terbitkan revisi baru',
          () => _terbit(dokumenId: d.id),
          tinta: false,
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Tombol(
          'Semua dokumen',
          onPressed: () => _ke(null),
          jenis: JenisTombol.teks,
          ukuran: UkuranTombol.kecil,
          lebarPenuh: false,
        ),
      ),
    ];
  }

  Widget _tombol(String label, VoidCallback onTap, {required bool tinta}) =>
      _baris(
        Tombol(
          label,
          onPressed: onTap,
          jenis: tinta ? JenisTombol.tinta : JenisTombol.kedua,
        ),
      );
}

/// Button row: wrap, gap 8; one button `flex: 1 1 150px; max-width: 340px`.
Widget _baris(Widget tombol, {double tepi = 32}) => BarisLentur(
  jarak: 8,
  anak: [Lentur(dasar: 150 + tepi, maks: 340 + tepi, child: tombol)],
);

/// A static filter label (`<span>`, content-box: 44 plus its 1.5 line).
class _Chip extends StatelessWidget {
  const _Chip(this.teks, {this.dipilih = false});

  final String teks;
  final bool dipilih;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 47),
    child: ChipSatu(teks: teks, dipilih: dipilih, onTap: null),
  );
}

/// Revision card top row: title 700, badge at the end, gap 16.
class _Atas extends StatelessWidget {
  const _Atas(this.judul, this.label, this.bentuk);

  final String judul, label;
  final BentukLencana bentuk;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) => Row(
      children: [
        Expanded(
          child: Text(
            judul,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: math.max(0, k.maxWidth - 60)),
          child: LencanaStatus(label, bentuk: bentuk),
        ),
      ],
    ),
  );
}

/// Phone list row: its own card; opens the document in place.
class _BarisPonsel extends StatelessWidget {
  const _BarisPonsel({required this.d, required this.onBuka});

  final ChurchDocument d;
  final ValueChanged<String> onBuka;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: Layar.dokumenGereja,
      diSini: () => onBuka(d.id),
      radius: 14,
      child: Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ketDokumen(d),
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              LencanaStatus(d.statusLabel, bentuk: BentukLencana.tinta),
              const SizedBox(width: 12),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Web table: one card, rows with a top rule (none on the first).
class _TabelWeb extends StatelessWidget {
  const _TabelWeb({required this.dok, required this.onBuka});

  final List<ChurchDocument> dok;
  final ValueChanged<String> onBuka;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, d) in dok.indexed)
              Tautan(
                ke: Layar.dokumenGereja,
                diSini: () => onBuka(d.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: i == 0
                      ? null
                      : BoxDecoration(
                          border: Border(top: BorderSide(color: c.garis)),
                        ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Row(
                      children: [
                        Expanded(child: _SelWeb(d: d)),
                        const SizedBox(width: 16),
                        LencanaStatus(
                          d.statusLabel,
                          bentuk: BentukLencana.tinta,
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 20,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: PalakatIkon(
                              Ikon.lanjut,
                              ukuran: 18,
                              warna: c.tinta3,
                            ),
                          ),
                        ),
                      ],
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

/// Web cell 1: title `flex: 1 1 260px` and meta `flex: 1.4 1 300px` in a
/// wrapping, baseline-aligned row, gap 2 20.
class _SelWeb extends StatelessWidget {
  const _SelWeb({required this.d});

  final ChurchDocument d;

  @override
  Widget build(BuildContext context) {
    final judul = Text(
      d.title,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
    final meta = Text(
      ketDokumen(d),
      style: TextStyle(fontSize: 13, color: context.warna.tinta3),
    );
    const anak = [
      Lentur(dasar: 260, child: SizedBox()),
      Lentur(dasar: 300, tumbuh: 1.4, child: SizedBox()),
    ];
    return LayoutBuilder(
      builder: (context, k) {
        final b = BarisLentur.lebar(anak, 20, k.maxWidth);
        if (b.length == 1) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SizedBox(width: b[0][0], child: judul),
              const SizedBox(width: 20),
              SizedBox(width: b[0][1], child: meta),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [judul, const SizedBox(height: 2), meta],
        );
      },
    );
  }
}
