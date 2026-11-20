import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart' show perintah;
import '../../providers/repositories_kolaborasi.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'permintaan_dana_keadaan.dart';

/// The board's two doors; a post already counted is offered too.
const _posBaku = ['Pintu depan', 'Pintu samping'];

/// 91 · Jumlah kehadiran + the counting steps of AlurIbadah (spec 22, 23;
/// README 7.1): people are counted, never named. The counter counts and
/// sends for review; whoever approved the service assigns counters, sets
/// (Tetapkan) and corrects the count with a reason (DL30, DP35).
class KehadiranScreen extends ConsumerStatefulWidget {
  const KehadiranScreen({super.key, required this.ibadahId});

  final String ibadahId;

  @override
  ConsumerState<KehadiranScreen> createState() => _KehadiranState();
}

class _KehadiranState extends ConsumerState<KehadiranScreen> {
  final _kor = TextEditingController();
  final _alasan = TextEditingController();
  String? _pos, _petugas;
  bool _koreksi = false;
  Refusal? _tolak;

  @override
  void dispose() {
    _kor.dispose();
    _alasan.dispose();
    super.dispose();
  }

  int get _nKor => int.tryParse(hanyaAngka(_kor.text, simpanNol: true)) ?? 0;

  String _sebabKoreksi() => _nKor <= 0
      ? 'jumlah yang benar belum diisi.'
      : (_alasan.text.trim().isEmpty ? 'alasan belum diisi.' : '');

  /// Runs one attendance command on the count's current revision.
  Future<bool> _jalankan(
    Future<Result<AttendanceCount>> Function(
      AttendanceRepository r,
      Actor a,
      int rev,
      String k,
    )
    jalan,
  ) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final rev = repo.count(widget.ibadahId)?.revision ?? 0;
    final r = await perintah(ref, (a, k) => jalan(repo, a, rev, k));
    if (!mounted) return false;
    setState(() => _tolak = r?.refusal);
    return r is Ok;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final c = context.warna;
    final saya = ref.watch(actorProvider)?.personId ?? '';
    final orang = ref.watch(peopleRepositoryProvider);
    final s = ref.watch(serviceRepositoryProvider).get(widget.ibadahId);
    final hitung = ref
        .watch(attendanceRepositoryProvider)
        .count(widget.ibadahId);
    String nama(String? id) => orang.person(id ?? '')?.name ?? '';
    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    final penyetuju = s?.approvedBy == saya;
    final penghitung = hitung?.isCounter(saya) ?? false;

    final isi = <Widget>[
      if (s == null || hitung == null)
        Text('Jumlah kehadiran dibuka setelah ibadah disetujui.', style: ket)
      else if (_koreksi)
        ..._formKoreksi(hitung, ket)
      else ...[
        _kartuJumlah(s, hitung, ket, nama),
        if (hitung.corrections.isNotEmpty)
          _kartuKoreksi(hitung.corrections.last, nama, ket),
        if (penghitung && !penyetuju)
          const Catatan(
            status: GarisStatus.terpilih,
            tebal: 'Petugas penghitung kehadiran',
            sisa:
                'untuk ibadah ini saja. Anda dapat menghitung; memeriksa dan '
                'menetapkan dilakukan yang menyetujui ibadah.',
          ),
        ...switch (hitung.status) {
          AttendanceStatus.live => [
            for (final p in hitung.posts)
              if (p.personId == saya) _penghitung(c, p),
            if (penyetuju) ..._formTugas(s, hitung),
            if (penghitung || penyetuju)
              BarisTombol(
                anak: [
                  Tombol(
                    'Kirim untuk diperiksa',
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                    onPressed: () => _jalankan(
                      (r, a, rev, k) => r.submitForReview(
                        a,
                        s.id,
                        expectedRevision: rev,
                        idempotencyKey: k,
                      ),
                    ),
                  ),
                ],
              ),
          ],
          AttendanceStatus.review => [
            Text(
              'Diperiksa oleh ${nama(s.approvedBy)}, yang menyetujui ibadah '
              'ini.',
              style: ket,
            ),
            if (penghitung || penyetuju)
              BarisTombol(
                anak: [
                  Tombol(
                    'Tetapkan',
                    jenis: JenisTombol.tinta,
                    onPressed: () => _jalankan(
                      (r, a, rev, k) => r.finalize(
                        a,
                        s.id,
                        expectedRevision: rev,
                        idempotencyKey: k,
                      ),
                    ),
                  ),
                  if (penyetuju)
                    Tombol(
                      'Kembalikan ke penghitung',
                      jenis: JenisTombol.teks,
                      ukuran: UkuranTombol.sedang,
                      onPressed: () => _jalankan(
                        (r, a, rev, k) => r.returnToCounter(
                          a,
                          s.id,
                          reason: '',
                          expectedRevision: rev,
                          idempotencyKey: k,
                        ),
                      ),
                    ),
                ],
              ),
          ],
          AttendanceStatus.finalized => [
            Text(
              'Ditetapkan oleh ${nama(hitung.finalizedBy)}, '
              '${hitung.finalizedAt == null ? '' : tglJam(hitung.finalizedAt!)}. '
              'Hanya jumlah yang Ditetapkan masuk ke Warta Jemaat dan '
              'laporan.',
              style: ket,
            ),
            if (penyetuju)
              BarisTombol(
                anak: [
                  Tombol(
                    'Koreksi',
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                    onPressed: () => setState(() {
                      _koreksi = true;
                      _tolak = null;
                      _kor.clear();
                      _alasan.clear();
                    }),
                  ),
                ],
              ),
          ],
        },
      ],
      if (_tolak case final r?) penolakanDari(r),
      Text(
        'Tidak ada daftar hadir bernama, daftar yang tidak hadir, atau nilai '
        'kehadiran per orang.',
        style: ket,
      ),
    ];

    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Jumlah kehadiran',
              anakJudul: 'Menghitung orang, tidak pernah mencatat nama',
              kembaliKe: Layar.ibadah,
              labelKembali: 'Kembali ke Ibadah dan kegiatan',
            ),
            Expanded(
              child: SingleChildScrollView(
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

  /// The count card: chip per step, one row per post, the total under a
  /// `tinta` rule.
  Widget _kartuJumlah(
    Service s,
    AttendanceCount h,
    TextStyle ket,
    String Function(String?) nama,
  ) {
    final c = context.warna;
    final lencana = switch (h.status) {
      AttendanceStatus.live => BentukLencana.laut,
      AttendanceStatus.review => BentukLencana.lautGaris,
      AttendanceStatus.finalized => BentukLencana.tinta,
    };
    String singkat(String id) {
      final p = ref.read(peopleRepositoryProvider).person(id);
      final k = (p?.name ?? '').split(' ').where((w) => !w.endsWith('.'));
      if (k.length < 2) return p?.short ?? '';
      return '${k.first} ${k.last[0]}.';
    }

    return Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          KepalaKartu(
            judul: '${s.title} · ${s.date}',
            ujung: LencanaStatus(h.status.label, bentuk: lencana),
          ),
          for (final p in h.posts)
            _BarisAngka('${p.post} · ${singkat(p.personId)}', '${p.count}'),
          if (h.posts.isEmpty)
            Text('Belum ada petugas penghitung.', style: ket),
          Container(
            padding: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.tinta, width: 1.5)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Jumlah',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${h.counted}',
                  style: const TextStyle(
                    fontFamily: PalakatText.mono,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Jumlah per pos tetap terpisah di dalam; yang dipakai laporan '
            'hanya jumlahnya.',
            style: ket,
          ),
        ],
      ),
    );
  }

  Widget _kartuKoreksi(
    AttendanceCorrection k,
    String Function(String?) nama,
    TextStyle ket,
  ) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        const KepalaKartu(
          judul: 'Koreksi jumlah',
          ujung: LencanaStatus('Ditetapkan', bentuk: BentukLencana.tinta),
        ),
        _BarisAngka('Jumlah semula', '${k.from}'),
        _BarisAngka('Jumlah koreksi', '${k.to}'),
        Text(
          'Alasan: ${k.reason}',
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
        Text(
          'Oleh ${nama(k.by)}, ${tglJam(k.at)}. Kedua nilai disimpan.',
          style: ket,
        ),
      ],
    ),
  );

  /// The approver gives a post to a counter: the people holding a post in
  /// the service's audience, and those already counting.
  List<Widget> _formTugas(Service s, AttendanceCount h) {
    final orang = ref.read(peopleRepositoryProvider);
    final calon = {
      for (final v
          in ref.watch(roleRepositoryProvider).posts(scopeId: s.scopeId))
        ?v.holder?.personId,
      for (final p in h.posts) p.personId,
    }.toList();
    final pos = {..._posBaku, for (final p in h.posts) p.post}.toList();
    return [
      ChipPilihan<String>(
        label: 'Pos',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [for (final p in pos) (nilai: p, teks: p)],
        terpilih: _pos,
        onPilih: (v) => setState(() => _pos = v),
      ),
      ChipPilihan<String>(
        label: 'Petugas penghitung',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [
          for (final id in calon)
            (nilai: id, teks: orang.person(id)?.name ?? id),
        ],
        terpilih: _petugas,
        onPilih: (v) => setState(() => _petugas = v),
      ),
      BarisTombol(
        anak: [
          Tombol(
            'Tugaskan',
            jenis: JenisTombol.tinta,
            onPressed: () async {
              final ok = await _jalankan(
                (r, a, rev, k) => r.assignCounter(
                  a,
                  s.id,
                  _petugas ?? '',
                  _pos ?? '',
                  expectedRevision: rev,
                  idempotencyKey: k,
                ),
              );
              if (ok && mounted) {
                setState(() {
                  _pos = null;
                  _petugas = null;
                });
              }
            },
          ),
        ],
      ),
    ];
  }

  /// The AlurIbadah correction form: the right figure and a reason.
  List<Widget> _formKoreksi(AttendanceCount h, TextStyle ket) {
    final sebab = _sebabKoreksi();
    return [
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            const KepalaKartu(
              judul: 'Koreksi jumlah kehadiran',
              ujung: LencanaStatus('Ditetapkan', bentuk: BentukLencana.tinta),
            ),
            BarisInfo('Angka sekarang', '${h.total}', mono: true),
          ],
        ),
      ),
      IsianAlur(
        label: 'Jumlah yang benar',
        controller: _kor,
        petunjuk: '0',
        keyboard: TextInputType.number,
        formatter: const [RupiahInputFormatter(sisakanNol: true)],
        onChanged: (_) => setState(() {}),
      ),
      IsianAlur(
        label: 'Alasan · wajib',
        controller: _alasan,
        baris: 3,
        onChanged: (_) => setState(() {}),
      ),
      Text(
        'Angka yang Ditetapkan tidak diubah; perbaikan dicatat sebagai '
        'koreksi dengan alasan.',
        style: ket,
      ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Catat koreksi',
            tindakan: 'Catat koreksi',
            alasan: sebab,
            periksa: _sebabKoreksi,
            sudahMulai: false,
            onPressed: () async {
              final ok = await _jalankan(
                (r, a, rev, k) => r.correct(
                  a,
                  widget.ibadahId,
                  _nKor,
                  reason: _alasan.text.trim(),
                  expectedRevision: rev,
                  idempotencyKey: k,
                ),
              );
              if (ok && mounted) setState(() => _koreksi = false);
            },
          ),
          Tombol(
            'Batal',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => setState(() {
              _koreksi = false;
              _tolak = null;
            }),
          ),
        ],
      ),
    ];
  }

  /// The stepper of the counter's own post: name, −, the count, +.
  Widget _penghitung(PalakatWarna c, CounterPost p) {
    Future<void> ubah(int n) => _jalankan(
      (r, a, rev, k) => r.increment(
        a,
        widget.ibadahId,
        p.post,
        n,
        expectedRevision: rev,
        idempotencyKey: k,
      ),
    );
    Widget tombol(String t, String label, VoidCallback onTap, bool isi) =>
        Tekan(
          onTap: onTap,
          label: label,
          radius: 12,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: isi ? c.tinta : c.permukaan,
              shape: isi
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  : GarisBorder.penuh(c.garisTegas, radius: 12),
            ),
            child: ExcludeSemantics(
              child: Text(
                t,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isi ? c.permukaan : c.tinta,
                ),
              ),
            ),
          ),
        );
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Text(
              p.post,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          tombol('−', 'Kurangi satu', () => ubah(-1), false),
          Semantics(
            liveRegion: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48),
              child: Text(
                '${math.max(0, p.count)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          tombol('+', 'Tambah satu', () => ubah(1), true),
        ],
      ),
    );
  }
}

/// A count row: label `tinta2`, mono 500 value. Unlike `BarisInfo` the label
/// may shrink and wrap (CSS flex-shrink), so a long label never overflows.
class _BarisAngka extends StatelessWidget {
  const _BarisAngka(this.label, this.nilai);

  final String label, nilai;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Text(
          label,
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ),
      const SizedBox(width: 16),
      Text(
        nilai,
        textAlign: TextAlign.right,
        // The board's mono span sits inline on a sans line box (20.6 tall).
        strutStyle: const StrutStyle(
          fontFamily: PalakatText.sans,
          fontSize: 14,
          height: 1.4,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        style: const TextStyle(
          fontSize: 14,
          fontFamily: PalakatText.mono,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
