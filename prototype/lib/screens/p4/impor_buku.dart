import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../../providers/actor.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../providers/repositories_jemaat.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'jemaat_bagian.dart';

/// 73 · Impor buku anggota + 84 · AlurKeluarga's import steps (spec 19, 21),
/// shared by ImporBuku and WebImporBuku: the Operator checks the staged
/// paper book, completes the dates the book left incomplete, decides the
/// possible duplicates in DataGanda, then imports. Imported people are
/// "Belum dikonfirmasi" until their family confirms (KonfirmasiKeluarga).
mixin ImporBukuLogika<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final _tanggal = <String, TextEditingController>{};
  bool _sentuh = false;
  Refusal? _tolakan;

  @override
  void dispose() {
    for (final c in _tanggal.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _isian(String rowId) =>
      _tanggal.putIfAbsent(rowId, TextEditingController.new);

  /// The book on the table: one still to import, else the latest imported.
  ImportBatch? buku() {
    final semua = ref.watch(memberImportRepositoryProvider).batches();
    return semua.where((b) => b.status != ImportStatus.imported).lastOrNull ??
        semua.lastOrNull;
  }

  Tanggal? _tgl(String s) {
    final n = bacaTgl(s);
    return n == null ? null : Tanggal(n ~/ 10000, n ~/ 100 % 100, n % 100);
  }

  int _diimpor(ImportBatch b) => b.rows
      .where(
        (r) => r.status == RowStatus.ok || r.status == RowStatus.incomplete,
      )
      .length;

  String _alasanImpor(ImportBatch b) {
    for (final r in b.rows.where((r) => r.status == RowStatus.incomplete)) {
      final s = _isian(r.id).text;
      if (s.trim().isEmpty) return 'tanggal lahir ${r.name} belum lengkap.';
      final t = _tgl(s);
      if (t == null) return 'tanggal lahir tidak dikenali.';
      if (!(t < ref.read(hariIniProvider))) {
        return 'tanggal lahir harus sebelum hari ini.';
      }
    }
    if (b.rows.any((r) => r.status == RowStatus.duplicate)) {
      return 'kemungkinan data ganda belum diputuskan.';
    }
    return '';
  }

  Future<void> _periksa(ImportBatch b) async {
    final r = await jalankanJemaat(
      ref,
      (a, k) => ref
          .read(memberImportRepositoryProvider)
          .check(a, b.id, expectedRevision: b.revision, idempotencyKey: k),
    );
    if (mounted && r != null) setState(() => _tolakan = r.refusal);
  }

  Future<void> _impor(ImportBatch b) async {
    final repo = ref.read(memberImportRepositoryProvider);
    for (final r in b.rows.where((r) => r.status == RowStatus.incomplete)) {
      final hasil = await jalankanJemaat(
        ref,
        (a, k) => repo.completeRow(
          a,
          b.id,
          r.id,
          _tgl(_isian(r.id).text)!,
          expectedRevision: b.revision,
          idempotencyKey: k,
        ),
      );
      if (hasil?.refusal != null) {
        if (mounted) setState(() => _tolakan = hasil!.refusal);
        return;
      }
    }
    final r = await jalankanJemaat(
      ref,
      (a, k) =>
          repo.commit(a, b.id, expectedRevision: b.revision, idempotencyKey: k),
    );
    if (mounted && r != null) setState(() => _tolakan = r.refusal);
  }

  /// The book and its rows (left column on the web).
  List<Widget> kiri(ImportBatch b) {
    final nama = ref.watch(namaJemaatProvider);
    final n = b.rows.length;
    String bagian(RowStatus s, String kata) {
      final x = b.rows.where((r) => r.status == s).length;
      return x == 0 ? '' : ' · $x $kata';
    }

    return [
      BarisInfo('Sumber', b.source),
      BarisInfo(
        'Baris',
        b.status == ImportStatus.imported
            ? '$n baris${bagian(RowStatus.imported, 'sudah diimpor')}'
                  '${bagian(RowStatus.duplicate, 'kemungkinan ganda')}'
                  '${bagian(RowStatus.merged, 'digabung')}'
                  '${bagian(RowStatus.refused, 'tidak diimpor')}'
            : '$n baris · belum ada yang diimpor',
      ),
      for (final r in b.rows) _kartu(b, r, nama),
    ];
  }

  Widget _kartu(ImportBatch b, ImportRow r, NamaJemaat nama) {
    final kolom = nama.kolom(r.kolomId);
    final tolak = r.birthDate == null && !r.yearMissing;
    final (st, bentuk) = switch (r.status) {
      _ when tolak => ('Tidak diimpor', BentukLencana.bata),
      RowStatus.incomplete => ('Perlu dilengkapi', BentukLencana.bata),
      _ when r.yearMissing => ('Ditampung', BentukLencana.draf),
      RowStatus.duplicate => ('Kemungkinan data ganda', BentukLencana.bata),
      RowStatus.merged => ('Digabung', BentukLencana.garis),
      RowStatus.imported => ('Sudah diimpor', BentukLencana.tinta),
      _ when b.status == ImportStatus.checked => (
        'Lolos pengecekan',
        BentukLencana.lautGaris,
      ),
      _ => ('Ditampung', BentukLencana.draf),
    };
    final baca = tolak
        ? 'Tanggal lahir tidak terbaca'
        : r.yearMissing
        ? '${r.name} · tahun tidak lengkap · $kolom'
        : '${r.name} · ${tgl(r.birthDate!.awal)} · $kolom';
    final catatan = tolak
        ? 'Tidak diimpor: tanggal lahir wajib. Dicatat dengan alasannya.'
        : r.note;
    return _KartuBaris(
      nama: r.name,
      asal: r.bookText,
      baca: baca,
      ket: catatan ?? '',
      lencana: (st, bentuk),
      putus: tolak || r.status == RowStatus.duplicate || r.yearMissing,
      isian: r.status == RowStatus.incomplete
          ? IsianAlur(
              label: 'Tanggal lahir',
              controller: _isian(r.id),
              onChanged: (_) => setState(() => _sentuh = true),
              petunjuk: 'hh/bb/tttt',
              keterangan: 'Ketik lengkap sesuai keterangan keluarga.',
            )
          : null,
    );
  }

  /// The actions of the book's state (right column on the web).
  List<Widget> kanan(ImportBatch b) {
    final c = context.warna;
    final catatan = TextStyle(fontSize: 13, color: c.tinta3);
    final tolakan = _tolakan == null ? null : penolakanDari(_tolakan!);
    switch (b.status) {
      case ImportStatus.staged:
        return [
          ?tolakan,
          BarisTombol(
            anak: [
              Tombol(
                'Jalankan pengecekan',
                jenis: JenisTombol.tinta,
                onPressed: () => _periksa(b),
              ),
            ],
          ),
          Text('Belum ada yang tersimpan sebagai data jemaat.', style: catatan),
          Text(
            'Tanggal lahir, jenis kelamin dan status pernikahan dibaca dari '
            'buku. Yang kosong dilengkapi keluarga saat mengonfirmasi; sampai '
            'itu Kategori BIPRA orangnya belum dihitung.',
            style: catatan,
          ),
        ];
      case ImportStatus.checked:
        final alasan = _alasanImpor(b);
        final ganda = ref
            .watch(memberImportRepositoryProvider)
            .duplicates()
            .where((d) => d.batchId == b.id && d.status == DuplicateStatus.open)
            .firstOrNull;
        return [
          Text(
            'Kemungkinan data ganda ditandai, tidak pernah digabung sendiri.',
            style: catatan,
          ),
          if (_sentuh && alasan.isNotEmpty)
            Penolakan(
              tindakan: 'Impor',
              sebab: alasan,
              jalan: const [],
              ukuranTeks: 14,
            ),
          ?tolakan,
          BarisTombol(
            anak: [
              TombolBersyarat(
                label: 'Impor ${_diimpor(b)} baris',
                tindakan: 'Impor',
                alasan: alasan,
                periksa: () => _alasanImpor(b),
                onPressed: () => _impor(b),
                sudahMulai: false,
              ),
            ],
          ),
          if (ganda != null)
            _TautanKedua(
              'Tinjau kemungkinan data ganda',
              onTap: () {
                ref.read(gandaDipilihProvider.notifier).pilih(ganda.id);
                context.dorongKe(Layar.dataGanda);
              },
            ),
        ];
      case ImportStatus.imported:
        final n = b.rows.where((r) => r.status == RowStatus.imported).length;
        final kolom = ref.watch(namaJemaatProvider).kolom(b.kolomId);
        final keluarga = ref.watch(memberRepositoryProvider);
        // A family to confirm; first one the book joined to people already
        // in Data jemaat.
        final belum = [
          for (final r in b.rows)
            if (r.householdKey != null &&
                keluarga.household(r.householdKey!)?.status !=
                    HouseholdStatus.active)
              keluarga.household(r.householdKey!)!,
        ];
        bool lama(Household h) => h.memberIds.any(
          (p) => keluarga.member(p)?.person.status == PersonStatus.active,
        );
        final pilih = (belum.where(lama).firstOrNull ?? belum.firstOrNull)?.id;
        return [
          Kartu(
            status: GarisStatus.draf,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$n orang masuk sebagai Belum dikonfirmasi.',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text:
                        'Hanya Penatua $kolom dan Operator yang dapat '
                        'melihatnya. Tidak ada yang tampil di publikasi sampai '
                        'keluarganya mengonfirmasi dan memberi izin.',
                    style: TextStyle(color: c.tinta2),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // KonfirmasiKeluarga is phone-only (README 7.1 rule 4).
          if (pilih != null && adaLayar(context, Layar.konfirmasiKeluarga))
            _TautanKedua(
              'Lihat konfirmasi keluarga',
              onTap: () {
                ref.read(keluargaDipilihProvider.notifier).pilih(pilih);
                context.dorongKe(Layar.konfirmasiKeluarga);
              },
            ),
        ];
    }
  }
}

/// Phone: the book, its rows and the actions in one column.
class ImporBukuScreen extends ConsumerStatefulWidget {
  const ImporBukuScreen({super.key});

  @override
  ConsumerState<ImporBukuScreen> createState() => _ImporBukuScreenState();
}

class _ImporBukuScreenState extends ConsumerState<ImporBukuScreen>
    with ImporBukuLogika {
  @override
  Widget build(BuildContext context) {
    final b = buku();
    return KerangkaJemaat(
      judul: 'Impor buku anggota',
      anakJudul:
          'Operator memasukkan buku anggota kertas; belum ada yang menjadi '
          'anggota aktif',
      tampilan: b?.status ?? '',
      blok: b == null
          ? [kotakKosong(context, 'Belum ada buku anggota yang ditampung.')]
          : [...kiri(b), ...kanan(b)],
    );
  }
}

/// Import row card: radius 14, padding 12 16, gap 4; solid or dashed.
class _KartuBaris extends StatelessWidget {
  const _KartuBaris({
    required this.nama,
    required this.asal,
    required this.baca,
    required this.ket,
    required this.lencana,
    required this.putus,
    this.isian,
  });

  final String nama, asal, baca, ket;
  final (String, BentukLencana) lencana;
  final bool putus;
  final Widget? isian;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    return Kartu(
      status: putus ? GarisStatus.draf : GarisStatus.dibukukan,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KepalaKartu, with the badge capped to the row: the test font
          // (Ahem) makes "Kemungkinan data ganda" wider than the card.
          LayoutBuilder(
            builder: (context, b) => Row(
              children: [
                Expanded(
                  child: Text(
                    nama,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: b.maxWidth - 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LencanaStatus(lencana.$1, bentuk: lencana.$2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Di buku: '),
                TextSpan(
                  text: asal,
                  style: const TextStyle(fontFamily: PalakatText.mono),
                ),
              ],
            ),
            style: kecil,
          ),
          const SizedBox(height: 4),
          Text('Dibaca sebagai: $baca', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          if (ket.isNotEmpty) Text(ket, style: kecil),
          if (isian != null) ...[const SizedBox(height: 8), isian!],
        ],
      ),
    );
  }
}

/// The board's `<a>` button (secondary look): content-box, 51 tall.
class _TautanKedua extends StatelessWidget {
  const _TautanKedua(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      radius: 14,
      peran: PeranTekan.tautan,
      child: RupaTombol(
        label: label,
        isi: c.permukaan,
        garis: GarisBorder.penuh(c.tinta, radius: 14),
        warnaTeks: c.tinta,
        radius: 14,
        tinggi: 51,
        paddingH: 16,
      ),
    );
  }
}
