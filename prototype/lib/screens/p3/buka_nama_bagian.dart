import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'sekretariat_bersama.dart';
import 'warta_arsip_bagian.dart';

/// The board body of BukaNama ([web] false: the phone scroll column) and
/// WebBukaNama ([web] true: the max-1120 container), for the edition of the
/// route's `:edisi` and its member who chose "Tanpa nama". The Sekretaris
/// Jemaat records the exception with a reason (`warta.reveal_identity`);
/// the guard keeps everyone else out ("Bukan Sekretaris Jemaat").
class BukaNamaPapan extends ConsumerStatefulWidget {
  const BukaNamaPapan({super.key, required this.web});

  final bool web;

  @override
  ConsumerState<BukaNamaPapan> createState() => _BukaNamaPapanState();
}

class _BukaNamaPapanState extends ConsumerState<BukaNamaPapan> {
  final _alasan = TextEditingController();
  Refusal? _tolak;

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  String _aN() => _alasan.text.trim().isEmpty ? 'alasan belum diisi.' : '';

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final c = context.warna;
    final id = edisiDariRute(context);
    final repo = ref.watch(wartaRepositoryProvider);
    final e = repo.edition(id);
    final v = repo
        .preview(id)
        ?.events
        .where((x) => x.reveal != null)
        .firstOrNull;
    if (e == null || v == null) {
      return kecilSek(context, 'Tidak ada nama yang perlu pengecualian.');
    }
    final x = e.exceptionFor(v.event.personId);
    final edisi = 'Warta Jemaat ${tgl(e.sunday.awal)}';
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    final param = {'edisi': e.id};

    if (x != null) {
      return _kolom(16, [
        Kartu(
          child: _kolom(6, [
            const KepalaKartu(
              judul: 'Pengecualian tampilan nama',
              ujung: LencanaStatus('Tercatat', bentuk: BentukLencana.tinta),
            ),
            const _BarisInfo('Pilihan anggota', 'Tanpa nama'),
            _BarisInfo('Diterbitkan sebagai', x.printedAs),
            _BarisInfo('Edisi', edisi),
            Text(
              'Alasan: ${x.reason}',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Text(
              'Oleh ${namaSek(ref, x.by)}, Sekretaris Jemaat · '
              '${tglJam(x.at)} · anggota sudah diberi tahu.',
              style: kecil,
            ),
          ]),
        ),
        Text(
          'Pilihan anggota di Data jemaat tidak berubah. Edisi berikutnya '
          'kembali memakai “Tanpa nama”.',
          style: kecil,
        ),
        Tombol(
          'Kembali',
          onPressed: null,
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.sedang,
          ke: Layar.wartaEdisi,
          param: param,
          cara: Cara.naik,
        ),
      ]);
    }

    final ringkasan = Kartu(
      child: _kolom(6, [
        _BarisInfo('Edisi', edisi),
        const _BarisInfo('Pilihan anggota', 'Tanpa nama'),
        _BarisInfo('Akan diterbitkan sebagai', v.reveal!),
        Text(
          'Tampilan nama pilihan anggota wajib diikuti. Pengecualian hanya '
          'untuk keperluan resmi, tata kelola, hukum atau '
          'pertanggungjawaban.',
          style: kecil,
        ),
      ]),
    );
    final isiForm = [
      IsianAlur(
        label: 'Alasan · wajib',
        controller: _alasan,
        onChanged: (_) => setState(() => _tolak = null),
        baris: 3,
      ),
      if (_tolak != null)
        penolakanSek(_tolak!)
      else if (_alasan.text.isNotEmpty && _aN().isNotEmpty)
        penolakanSek(Refusal(action: 'Catat pengecualian', because: _aN())),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Catat pengecualian',
            tindakan: 'Catat pengecualian',
            alasan: _aN(),
            periksa: _aN,
            sudahMulai: false,
            onPressed: () async {
              final r = await repo.revealIdentity(
                aktorSek(ref),
                e.id,
                v.event.personId,
                reason: _alasan.text,
                expectedRevision: e.revision,
                idempotencyKey: kunciSek(ref),
              );
              if (!mounted) return;
              if (r case Refused(:final refusal)) {
                setState(() => _tolak = refusal);
              }
            },
          ),
          Tombol(
            'Batalkan',
            onPressed: null,
            jenis: JenisTombol.teks,
            ke: Layar.wartaEdisi,
            param: param,
            cara: Cara.naik,
          ),
        ],
      ),
    ];
    if (!widget.web) return _kolom(16, [ringkasan, ...isiForm]);
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: duaKolomSek([ringkasan], isiForm),
      ),
    );
  }
}

Widget _kolom(double jarak, List<Widget> anak) => kolomSek(anak, jarak);

/// Key–value row (BarisInfo's look) with the board's CSS flex-shrink: when
/// label and value do not fit side by side, both wrap, each shrinking in
/// proportion to its width ("Akan diterbitkan / sebagai" at 390).
class _BarisInfo extends StatelessWidget {
  const _BarisInfo(this.label, this.nilai);

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 14));
    final gayaLabel = dasar.copyWith(color: c.tinta2);
    final gayaNilai = dasar.copyWith(
      color: c.tinta,
      fontWeight: FontWeight.w600,
    );
    int lebar(String t, TextStyle g) {
      final p = TextPainter(
        text: TextSpan(text: t, style: g),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final w = p.width.ceil();
      p.dispose();
      return w;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: lebar(label, gayaLabel),
          child: Text(label, style: gayaLabel),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: lebar(nilai, gayaNilai),
          child: Text(nilai, textAlign: TextAlign.right, style: gayaNilai),
        ),
      ],
    );
  }
}
