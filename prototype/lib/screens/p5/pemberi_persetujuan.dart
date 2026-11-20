import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../providers/keuangan/akhir_bulan.dart' show perintah;
import '../../providers/repositories_kolaborasi.dart';
import '../../providers/revision.dart';
import '../p3/sekretariat_bersama.dart' show riwayatSek, penolakanSek;

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

/// Unit type → its row name, in board order (ApproverTable.unitTypes).
const _p = {
  ScopeType.kolom: 'Kolom',
  ScopeType.bipra: 'BIPRA',
  ScopeType.komisi: 'Komisi',
  ScopeType.panitia: 'Panitia',
};

/// 98 · Alur · Pemberi persetujuan: the approver table (23-alurunit.md,
/// DL29), saved through ApproverTableRepository one row per call.
class PemberiPersetujuanScreen extends ConsumerStatefulWidget {
  const PemberiPersetujuanScreen({super.key});

  @override
  ConsumerState<PemberiPersetujuanScreen> createState() =>
      _PemberiPersetujuanScreenState();
}

class _PemberiPersetujuanScreenState
    extends ConsumerState<PemberiPersetujuanScreen> {
  /// The choices on screen; starts from the saved table.
  late final _t = Map.of(
    ref.read(approverTableRepositoryProvider).table().rows,
  );
  var _simpan = false;
  var _pesan = '';
  Refusal? _tolak;

  List<String> get _kosong => [
    for (final MapEntry(key: k, value: n) in _p.entries)
      if (_t[k] == null) n,
  ];

  Future<void> _simpanTabel() async {
    final repo = ref.read(approverTableRepositoryProvider);
    for (final k in _p.keys) {
      final t = repo.table();
      final r = await perintah(
        ref,
        (a, kunci) => repo.set(
          a,
          k,
          _t[k]!,
          t.threshold,
          expectedRevision: t.revision,
          idempotencyKey: kunci,
        ),
      );
      if (!mounted) return;
      if (r?.refusal != null) {
        setState(() => _tolak = r!.refusal);
        return;
      }
    }
    setState(() {
      _simpan = true;
      _tolak = null;
      _pesan = 'Tabel pemberi persetujuan disimpan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final c = context.warna;
    final riw = riwayatSek(
      ref,
      const AuditFilter(actionPrefix: 'requests.set_table'),
    );
    final kosong = _kosong;
    final alasan = kosong.isEmpty
        ? ''
        : 'belum ada pemberi persetujuan untuk ${kosong.join(', ')}.';

    final isi = <Widget>[
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      Text(
        'Diisi sekali oleh Pimpinan Jemaat yang berwenang. Berlaku untuk Permintaan dana dan persetujuan lain di aplikasi.',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
      for (final MapEntry(key: k, value: n) in _p.entries)
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                'Permintaan dari $n',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              // The board's pills sit in a flex row with `gap: 8px` both ways,
              // not ChipPilihan's `margin: 0 8px 8px 0`.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in ApproverChoice.values)
                    ChipSatu(
                      teks: p.labelFor(k),
                      dipilih: _t[k] == p,
                      onTap: () => setState(() {
                        _t[k] = p;
                        _tolak = null;
                        _simpan = false;
                        _pesan = '';
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      Text(
        'Yang mengajukan tidak pernah menyetujui pengajuannya sendiri, walau jabatannya tercantum di sini. Bila jabatan pemberi persetujuan kosong, permintaan menunggu sampai ada pemegangnya.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      // The line shows only while one to three rows are unchosen.
      if (_tolak case final r?)
        penolakanSek(r)
      else if (alasan.isNotEmpty && kosong.length < 4)
        Penolakan(
          tindakan: 'Simpan tabel',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      TombolBersyarat(
        label: 'Simpan tabel',
        tindakan: 'Simpan tabel',
        alasan: alasan,
        onPressed: _simpanTabel,
        sudahMulai: false,
        warnaSiap: JenisTombol.tinta,
        baris: const [],
      ),
      // The board's link is an `<a>`, so content-box: its max-width 340 and
      // min-height 48 exclude padding and the 1.5 line, which makes it span
      // the whole 350 column and stand 51 high.
      if (_simpan)
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 51),
          child: const Tombol(
            'Aktifkan modul Persetujuan di aplikasi',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            ke: Layar.modul,
          ),
        ),
      if (riw.isNotEmpty) RiwayatAlur(baris: riw),
    ];

    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Alur · Pemberi persetujuan',
            anakJudul:
                'Jabatan mana yang menyetujui permintaan dari tiap jenis unit',
            kembaliKe: Layar.modul,
            labelKembali: 'Kembali ke Modul',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: isi,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
