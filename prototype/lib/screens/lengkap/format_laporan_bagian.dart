import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/laporan.dart';
import '../../providers/repositories_keuangan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

/// Parts shared by FormatLaporan and WebFormatLaporan (the boards draw the
/// same form, record and cards; only the shell and two link targets differ).

/// The form state `{ nama, jabatan, cara }`, owned by the screen; whether
/// the format is accepted is ReportRepository's (RD03, DP11).
class DataFormatLaporan {
  final nama = TextEditingController();
  static const jabatanAwal = 'Ketua BPMJ';
  final jabatan = TextEditingController(text: jabatanAwal);

  /// The label is drawn by the screen (bold suffix), so a tap on it focuses
  /// the field through this node, as `<label for="en">` does.
  final fokusNama = FocusNode();
  String cara = 'notulen rapat';

  /// Recorded in this visit: the approver typed in the form is shown.
  bool dicatat = false;
  Refusal? tolak;

  void dispose() {
    nama.dispose();
    jabatan.dispose();
    fokusNama.dispose();
  }
}

const _wajib = 'Pemberi persetujuan · wajib';

/// The Belum form or the Ada record, as the column children of the board's
/// `sc-if` blocks (gap is the parent column's).
List<Widget> bagianPersetujuan(
  BuildContext context,
  WidgetRef ref,
  DataFormatLaporan d,
  void Function(VoidCallback) ubah,
) {
  final c = context.warna;
  final kecil = TextStyle(fontSize: 14, color: c.tinta2);
  final semua = ref.watch(reportRepositoryProvider).templates();
  final t = semua.where((t) => t.accepted).firstOrNull;
  if (t != null) {
    final oleh = ref.watch(peopleRepositoryProvider).person(t.acceptedBy!);
    return [
      Gerak(
        Kerangka.muncul,
        key: const ValueKey('ada'),
        lama: const Duration(milliseconds: 300),
        child: Kartu(
          status: GarisStatus.terpilih,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Persetujuan format: sudah dicatat',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              if (d.dicatat) ...[
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Pemberi persetujuan:',
                        style: TextStyle(color: c.tinta2),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: d.nama.text,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ', ${d.jabatan.text}'),
                    ],
                  ),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${t.name} · ${tgl(t.acceptedAt!)}'
                '${d.dicatat ? ' · cara: ${d.cara}' : ''}',
                style: kecil,
              ),
              const SizedBox(height: 4 + 8),
              GarisLurus(warna: c.garisTegas, gaya: GayaGaris.putus),
              const SizedBox(height: 8),
              Text(
                'Dicatat oleh ${oleh?.shortName ?? oleh?.name}, '
                '${tglJam(t.acceptedAt!)}. Persetujuan diberikan di luar '
                'aplikasi. Catatan yang keliru digantikan catatan baru, tidak '
                'diubah.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.lautLembut,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Syarat tutup buku “persetujuan format laporan sudah dicatat” '
          'terpenuhi.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ];
  }

  String alasan() =>
      d.nama.text.trim().isEmpty ? 'Pemberi persetujuan belum diisi.' : '';
  return [
    Kartu(
      status: GarisStatus.hambatan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Persetujuan format: belum dicatat',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            'Hambatan tutup buku sampai dicatat. Pimpinan Jemaat yang '
            'berwenang menyetujui format di luar aplikasi; Anda mencatatnya '
            'di sini.',
            style: kecil,
          ),
        ],
      ),
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: GestureDetector(
            onTap: d.fokusNama.requestFocus,
            child: Text.rich(
              TextSpan(
                text: 'Pemberi persetujuan ',
                children: [
                  TextSpan(
                    text: '· wajib',
                    style: TextStyle(
                      color: c.tinta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              style: kecil,
            ),
          ),
        ),
        const SizedBox(height: 6),
        IsianTeks(
          controller: d.nama,
          focusNode: d.fokusNama,
          labelSemantik: _wajib,
          petunjuk: 'Nama lengkap',
          onChanged: (_) => ubah(() {}),
        ),
      ],
    ),
    IsianTeks(
      controller: d.jabatan,
      label: 'Jabatan',
      jarakLabel: 6,
      onChanged: (_) => ubah(() {}),
    ),
    ChipPilihan<String>(
      label: 'Cara',
      pilihan: const [
        (nilai: 'surat', teks: 'surat'),
        (nilai: 'notulen rapat', teks: 'notulen rapat'),
        (nilai: 'pesan', teks: 'pesan'),
      ],
      terpilih: d.cara,
      onPilih: (v) => ubah(() => d.cara = v),
    ),
    Container(
      // CSS min-height 44 is the content box; the 1 px rule adds to it.
      constraints: const BoxConstraints(minHeight: 45),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Tanggal persetujuan', style: kecil)),
          const SizedBox(width: 16),
          Text(
            tglPanjang(ref.watch(hariIniProvider).awal),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
    TombolBersyarat(
      label: 'Catat persetujuan format',
      tindakan: 'Catat persetujuan format',
      alasan: alasan(),
      periksa: alasan,
      // Rule A02: the sentence the board lacks, once a field differs from its start.
      sudahMulai:
          d.nama.text.isNotEmpty ||
          d.jabatan.text != DataFormatLaporan.jabatanAwal,
      warnaSiap: JenisTombol.utama,
      teksBelumRedup: true,
      paddingH: 20,
      onPressed: () async {
        final p = semua.firstOrNull;
        if (p == null) return;
        final r = await perintah(
          ref,
          (a, k) => ref
              .read(reportRepositoryProvider)
              .acceptTemplate(
                a,
                p.id,
                expectedRevision: p.revision,
                idempotencyKey: k,
              ),
        );
        ubah(() {
          d.tolak = r?.refusal;
          d.dicatat = r is Ok<ReportTemplate>;
        });
      },
    ),
    if (d.tolak != null)
      Penolakan(
        tindakan: d.tolak!.action,
        sebab: d.tolak!.because,
        jalan: const [],
        ukuranTeks: 14,
      ),
  ];
}

/// Cards g, h, i. [tautan] are the two link-buttons of card g, built by the
/// screen (their targets differ per board).
List<Widget> kartuFormat(
  BuildContext context,
  WidgetRef ref,
  List<Widget> tautan,
) {
  final c = context.warna;
  final format = ref.watch(reportRepositoryProvider).templates().firstOrNull;
  final bendahara = ref.watch(namaBendaharaProvider);
  final kecil = TextStyle(fontSize: 14, color: c.tinta2);
  final catatan = TextStyle(fontSize: 13, color: c.tinta3);
  Widget kartu(double jarak, List<Widget> anak) => Kartu(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) SizedBox(height: jarak),
          anak[i],
        ],
      ],
    ),
  );
  const tebal = TextStyle(fontWeight: FontWeight.w700);
  return [
    kartu(6, [
      Text('Format laporan', style: kecil),
      Text(
        format?.name ?? 'Bawaan Palakat',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      Text(
        'Empat belas laporan, F01 sampai F14. Format ini buatan aplikasi dan '
        'tidak mengaku sama dengan formulir asli GMIM.',
        style: kecil,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(spacing: 8, runSpacing: 8, children: tautan),
      ),
      Text(
        'Contoh memuat angka negatif, Rp0 dan isian kosong supaya cara '
        'cetaknya ikut dinilai.',
        style: catatan,
      ),
    ]),
    kartu(4, [
      const Text('Lampiran F14', style: tebal),
      for (final (i, n) in const [
        'Uang Muka',
        'Rincian Pertanggungjawaban Uang Muka',
        'Penghitungan Persembahan',
        'Penggantian Biaya',
        'Pengecualian Dokumen Pendukung',
        'Pembalikan dan Koreksi',
        'Saldo Awal Pencatatan',
        'Hasil Pengecekan Otomatis',
      ].indexed)
        Text('${i + 1}. $n', style: kecil),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Lampiran tanpa isi dicetak sebagai “Nihil”.',
          style: catatan,
        ),
      ),
    ]),
    kartu(4, [
      const Text('Penanda tangan, dari pengaturan', style: tebal),
      Text('Bendahara · ${bendahara ?? 'belum ada'}', style: kecil),
      Text('Ketua BPMJ · [NAMA DARI PENGATURAN]', style: kecil),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Laporan mencetak nama dan garis kosong. Tidak ada tanda tangan '
          'tiruan.',
          style: catatan,
        ),
      ),
    ]),
  ];
}

/// "Lihat contoh PDF" / "Lihat contoh Excel": min height 46, padding 0 20,
/// radius 12, 1.5 `tinta` line, `permukaan`, 700.
Widget tombolContoh(
  String label, {
  required Layar ke,
  Map<String, String> param = const {},
}) => Tombol(
  label,
  onPressed: null,
  jenis: JenisTombol.kedua,
  ukuran: UkuranTombol.ringkas,
  lebarPenuh: false,
  ke: ke,
  param: param,
);
