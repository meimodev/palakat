import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/actor.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'sekretariat_bersama.dart';

const _jenisPil = [
  DocumentKind.decision,
  DocumentKind.minutes,
  DocumentKind.liturgy,
];
const _untukPil = [
  Audience.all,
  Audience.servants,
  Audience.scope('kolom-7', 'Kolom 7'),
];

/// The publish form of TerbitDokumen/AlurDokumen (README 7.1: behaviour from
/// the Alur board): a new document, or a revision of [dokumenId] ("Ralat").
/// A signed copy is required; there is no approval in the app. A new
/// document ends on TerbitDokumen's "Diterbitkan" card ("Lihat di Dokumen
/// gereja", "Terbitkan revisi baru"); a revision closes with the board's
/// message for the list. On the web, WebTerbitDokumen's "Yang dilihat
/// penerima" sits beside the form.
class FormDokumen extends ConsumerStatefulWidget {
  const FormDokumen({super.key, required this.web, this.dokumenId});

  final bool web;
  final String? dokumenId;

  @override
  ConsumerState<FormDokumen> createState() => _FormDokumenState();
}

class _FormDokumenState extends ConsumerState<FormDokumen> {
  final _judul = TextEditingController(), _tgl = TextEditingController();
  final _ralat = TextEditingController();
  DocumentKind? _jenis;
  Audience? _untuk;
  var _file = false;
  Refusal? _tolak;

  /// The document being revised: the route's, or the one just published
  /// after "Terbitkan revisi baru".
  late String? _revisiId = widget.dokumenId;

  /// The document just published and its message for the list.
  ChurchDocument? _hasil;
  var _pesanHasil = '';

  @override
  void dispose() {
    _judul.dispose();
    _tgl.dispose();
    _ralat.dispose();
    super.dispose();
  }

  void _ubah([Object? _]) => setState(() => _tolak = null);

  ChurchDocument? get _dok => _revisiId == null
      ? null
      : ref.read(documentRepositoryProvider).get(_revisiId!);

  String get _namaFile => _dok == null
      ? 'salinan-bertanda-tangan.pdf'
      : 'salinan-bertanda-tangan-revisi-${_dok!.current.number + 1}.pdf';

  /// First unmet condition of "Terbitkan", '' when met (AlurDokumen `ok`).
  String _alasan() {
    final hari = ref.read(hariIniProvider);
    final t = bacaTanggal(_tgl.text);
    if (_jenis == null) return 'jenis dokumen belum dipilih.';
    if (_judul.text.trim().isEmpty) return 'judul belum diisi.';
    if (t == null) {
      return 'tanggal dokumen tidak dikenali. Contoh: ${tgl(hari.awal)}.';
    }
    if (t > hari) return 'tanggal dokumen belum tiba.';
    if (_untuk == null) return 'penerima belum dipilih.';
    if (!_file) return 'salinan bertanda tangan belum terlampir.';
    return '';
  }

  /// First unmet condition of "Terbitkan revisi".
  String _alasanRalat() {
    if (_ralat.text.trim().isEmpty) return 'yang diralat belum diisi.';
    if (!_file) return 'salinan bertanda tangan revisi belum terlampir.';
    return '';
  }

  void _selesai(String pesan) {
    final r = GoRouter.of(context);
    if (r.canPop()) {
      r.pop(pesan);
    } else {
      r.go(Layar.dokumenGereja.lokasi());
    }
  }

  void _batal() => context.naikKe(Layar.dokumenGereja);

  Future<void> _terbit() async {
    final judul = _judul.text.trim(), untuk = _untuk!;
    final r = await ref
        .read(documentRepositoryProvider)
        .publish(
          aktorSek(ref),
          DocumentDraft(
            kind: _jenis!,
            title: judul,
            documentDate: bacaTanggal(_tgl.text),
          ),
          SampleFile(_namaFile),
          untuk,
          idempotencyKey: kunciSek(ref),
        );
    if (!mounted) return;
    switch (r) {
      case Ok(:final value):
        setState(() {
          _hasil = value;
          _pesanHasil = '$judul diterbitkan untuk ${untuk.label}.';
        });
      case Refused(:final refusal):
        setState(() => _tolak = refusal);
    }
  }

  Future<void> _terbitRalat(ChurchDocument d) async {
    final ralat = _ralat.text.trim();
    final r = await ref
        .read(documentRepositoryProvider)
        .revise(
          aktorSek(ref),
          d.id,
          ralat,
          SampleFile(_namaFile),
          expectedRevision: d.revision,
          idempotencyKey: kunciSek(ref),
        );
    if (!mounted) return;
    switch (r) {
      case Ok(:final value):
        _selesai(
          '${value.title}: revisi ${value.current.number} diterbitkan. '
          'Yang diralat: $ralat',
        );
      case Refused(:final refusal):
        setState(() => _tolak = refusal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = _hasil;
    if (h != null) {
      final kartu = [_diterbitkan(h)];
      return widget.web
          ? duaKolomSek(kartu, _penerima(terbit: true))
          : kolomSek(kartu, 16);
    }
    final d = _dok;
    if (_revisiId != null && d == null) {
      return kecilSek(context, 'Dokumen tidak ditemukan.');
    }
    final (kiri, kanan) = d == null ? _baru() : _revisi(d);
    if (widget.web) {
      return duaKolomSek(kiri, [
        ...kanan,
        if (d == null) ..._penerima(terbit: false),
      ]);
    }
    return kolomSek([...kiri, ...kanan], 16);
  }

  /// TerbitDokumen's confirmation card.
  Widget _diterbitkan(ChurchDocument d) {
    final kini = d.current;
    return Kartu(
      child: kolomSek([
        KepalaKartu(
          judul: d.title,
          ujung: const LencanaStatus(
            'Diterbitkan',
            bentuk: BentukLencana.tinta,
          ),
        ),
        Text(
          'Ditujukan untuk: ${d.audience.label}'
          '${d.documentDate == null ? '' : ' · ${tgl(d.documentDate!.awal)}'}',
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
        kecilSek(
          context,
          'Diterbitkan oleh ${namaSek(ref, kini.publishedBy)}, '
          '${tglJam(kini.publishedAt)}. Anggota yang dituju menerima '
          'pemberitahuan.',
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Lihat di Dokumen gereja',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              onPressed: () => _selesai(_pesanHasil),
            ),
            Tombol(
              'Terbitkan revisi baru',
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.sedang,
              onPressed: () => setState(() {
                _revisiId = d.id;
                _hasil = null;
                _file = false;
                _tolak = null;
                _ralat.clear();
              }),
            ),
          ],
        ),
      ], 6),
    );
  }

  /// WebTerbitDokumen's aside "Yang dilihat penerima": what the addressees
  /// will see, from the form as filled (or the published document).
  List<Widget> _penerima({required bool terbit}) {
    final d = _hasil;
    final judul = d?.title ?? _judul.text.trim();
    final jenis = d?.kind ?? _jenis;
    final t = d?.documentDate ?? bacaTanggal(_tgl.text);
    final untuk = d?.audience ?? _untuk;
    return [
      const JudulBagian('Yang dilihat penerima'),
      Kartu(
        child: kolomSek([
          KepalaKartu(
            judul: judul.isEmpty ? 'Judul dokumen' : judul,
            ujung: terbit
                ? const LencanaStatus(
                    'Diterbitkan',
                    bentuk: BentukLencana.tinta,
                  )
                : const LencanaStatus(
                    'Belum diterbitkan',
                    bentuk: BentukLencana.draf,
                  ),
          ),
          kecilSek(
            context,
            [
              jenis?.label ?? 'Jenis dokumen',
              if (t != null) tgl(t.awal),
            ].join(' · '),
          ),
          BarisInfo('Ditujukan untuk', untuk?.label ?? '—'),
          BarisInfo(
            'Lampiran',
            terbit || _file ? 'Salinan bertanda tangan (PDF)' : '—',
          ),
        ], 6),
      ),
      kecilSek(
        context,
        'Penerima melihat judul, tanggal dan salinan bertanda tangan. Mereka '
        'tidak melihat draf, unggahan yang gagal, atau dokumen yang ditujukan '
        'untuk orang lain.',
      ),
    ];
  }

  Widget _chip<T>(
    String label,
    List<T> pil,
    String Function(T) teks,
    T? nilai,
    ValueChanged<T> pilih,
  ) => ChipPilihan<T>(
    label: label,
    jarakLabel: 6,
    jarakBawah: 0,
    pilihan: [for (final p in pil) (nilai: p, teks: teks(p))],
    terpilih: nilai,
    onPilih: (v) => setState(() {
      pilih(v);
      _tolak = null;
    }),
  );

  (List<Widget>, List<Widget>) _baru() {
    final alasan = _alasan();
    final mulai =
        _jenis != null ||
        _judul.text.isNotEmpty ||
        _tgl.text.isNotEmpty ||
        _untuk != null ||
        _file;
    return (
      [
        _chip<DocumentKind>(
          'Jenis dokumen',
          _jenisPil,
          (k) => k.label,
          _jenis,
          (v) => _jenis = v,
        ),
        IsianAlur(
          label: 'Judul',
          controller: _judul,
          onChanged: _ubah,
          petunjuk: 'Judul dokumen',
        ),
        IsianAlur(
          label: 'Tanggal dokumen',
          controller: _tgl,
          onChanged: _ubah,
          petunjuk: 'hh/bb/tttt',
          keterangan: 'Tanggal yang tertulis di dokumennya.',
          keyboard: TextInputType.datetime,
        ),
        _chip<Audience>(
          'Ditujukan untuk',
          _untukPil,
          (a) => a.label,
          _untuk,
          (v) => _untuk = v,
        ),
      ],
      [
        SlotSalinan(
          nama: _namaFile,
          ada: _file,
          onPilih: () => setState(() => _file = true),
        ),
        ..._aksi('Terbitkan', alasan, mulai, _alasan, _terbit),
      ],
    );
  }

  (List<Widget>, List<Widget>) _revisi(ChurchDocument d) {
    final alasan = _alasanRalat();
    return (
      [
        Kartu(
          child: kolomSek([
            KepalaKartu(
              judul: d.title,
              ujung: LencanaStatus(d.statusLabel, bentuk: BentukLencana.tinta),
            ),
            kecilSek(
              context,
              'Revisi yang sekarang tetap dapat dibuka dan diberi tanda '
              '“Digantikan”.',
            ),
          ], 6),
        ),
        IsianAlur(
          label: 'Yang diralat · wajib',
          controller: _ralat,
          onChanged: _ubah,
          baris: 3,
        ),
      ],
      [
        SlotSalinan(
          nama: _namaFile,
          ada: _file,
          onPilih: () => setState(() => _file = true),
        ),
        ..._aksi(
          'Terbitkan revisi',
          alasan,
          _ralat.text.isNotEmpty || _file,
          _alasanRalat,
          () => _terbitRalat(d),
        ),
      ],
    );
  }

  List<Widget> _aksi(
    String label,
    String alasan,
    bool mulai,
    String Function() periksa,
    VoidCallback onTerbit,
  ) => [
    if (_tolak != null)
      penolakanSek(_tolak!)
    else if (mulai && alasan.isNotEmpty)
      penolakanSek(Refusal(action: label, because: alasan)),
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: label,
          tindakan: label,
          alasan: alasan,
          periksa: periksa,
          sudahMulai: false,
          onPressed: onTerbit,
        ),
        Tombol(
          'Batalkan',
          jenis: JenisTombol.teks,
          ukuran: UkuranTombol.kecil,
          onPressed: _batal,
        ),
      ],
    ),
  ];
}
