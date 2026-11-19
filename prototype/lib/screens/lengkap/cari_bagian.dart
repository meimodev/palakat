import 'dart:async';

import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../motion/kerangka.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';

/// Parts shared by Cari and WebCari (spec 08): the same state, handlers,
/// search, answer, rows and AI panel.

/// Board rows `R`: the dates are the board's, the figures `cariJawaban`.
const _tanggal = ['04/10/2026', '11/10/2026', '18/10/2026', '25/10/2026'];

enum _Ai { belum, proses, ada }

enum _Narasi { belum, ada, pakai, abai }

/// The board's state `{ q, ai, narasi }` and its handlers.
mixin LogikaCari<T extends StatefulWidget> on State<T> {
  final q = TextEditingController(text: cariPertanyaan);
  _Ai _ai = _Ai.belum;
  _Narasi _narasi = _Narasi.belum;
  Timer? _t;

  bool get cocok => RegExp(
    'persembahan|minggu|oktober',
    caseSensitive: false,
  ).hasMatch(q.text);

  // Board parity: the 1300 ms timer of `tanya` is not cancelled here (spec
  // note "timer race"; the recommendation is in the review log).
  void onQ(String _) => setState(() => _ai = _Ai.belum);

  void tanya() {
    setState(() => _ai = _Ai.proses);
    _t?.cancel();
    _t = Timer(
      const Duration(milliseconds: 1300),
      () => setState(() => _ai = _Ai.ada),
    );
  }

  @override
  void dispose() {
    _t?.cancel();
    q.dispose();
    super.dispose();
  }

  /// Search field, answer and rows (or the empty box): Cari 2a–2d.
  List<Widget> hasil({required String ke}) => [
    IsianTeks(
      controller: q,
      labelSemantik: 'Cari transaksi',
      petunjuk: 'Cari dengan kata sehari-hari',
      minTinggi: 52,
      gaya: const TextStyle(fontSize: 16),
      onChanged: onQ,
    ),
    if (cocok) ...[
      const _Jawaban(),
      _Baris(ke: ke),
    ] else
      Kartu(
        status: GarisStatus.draf,
        padding: const EdgeInsets.all(16),
        child: Text(
          'Tidak ada transaksi yang cocok di Jemaat Karunia.',
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ),
  ];

  /// "BANTUAN AI · PILIHAN": Cari 2e.
  Widget panelAi() {
    final c = context.warna;
    Widget tombolAi(String t, VoidCallback f) => Tombol(
      t,
      onPressed: f,
      jenis: JenisTombol.garisLaut,
      ukuran: UkuranTombol.kecil,
      warnaTeks: c.lautTua,
    );
    Widget status(String t, Color w) => Semantics(
      container: true,
      liveRegion: true,
      child: Text(
        t,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: w),
      ),
    );
    final aksi = [
      for (final (t, j, f) in [
        ('Pakai', JenisTombol.utama, _pakai),
        ('Ubah', JenisTombol.kedua, _pakai),
        ('Abaikan', JenisTombol.kedua, _abai),
      ])
        Tombol(
          t,
          onPressed: f,
          jenis: j,
          ukuran: UkuranTombol.mini,
          paddingH: 16,
          lebarPenuh: false,
        ),
    ];
    final gelap = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.lautLembut,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _jarak(10, [
          Text(
            'BANTUAN AI · PILIHAN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.lautTua,
              letterSpacing: 0.3,
            ),
          ),
          if (_ai == _Ai.belum && cocok) tombolAi('Jelaskan hasil ini', tanya),
          if (_ai == _Ai.proses)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Align(
                alignment: Alignment.centerLeft,
                child: status('Menyusun penjelasan…', c.lautTua),
              ),
            ),
          if (_ai == _Ai.ada)
            _KartuAi(
              key: const ValueKey('penjelasan'),
              label: 'Usulan AI · penjelasan',
              jarak: 6,
              teks:
                  'Empat ibadah Minggu pagi di Oktober tercatat, dengan '
                  'persembahan terbesar pada 4 Oktober. Persembahan 18 Oktober '
                  'paling kecil; itu bertepatan dengan ibadah padang.',
              ekor: Text(
                'Berdasarkan 4 transaksi di atas saja. AI tidak melihat '
                'peruntukan atau Jemaat lain.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: gelap ? c.garis : PalakatIlustrasi.garisJawaban,
                ),
              ),
            ),
            child: switch (_narasi) {
              _Narasi.belum => tombolAi(
                'Buat usulan narasi bulanan Oktober',
                () => setState(() => _narasi = _Narasi.ada),
              ),
              _Narasi.ada => _KartuAi(
                key: const ValueKey('narasi'),
                label: 'Usulan AI · narasi bulanan',
                jarak: 8,
                teks:
                    'Pada Oktober 2026 Pendapatan Jemaat Rp14.820.000 dan '
                    'Belanja Rp11.455.000. Belanja terbesar adalah pemeliharaan '
                    'gedung. Semua Kas/Bank sudah direkonsiliasi tanpa selisih.',
                ekor: Wrap(spacing: 8, runSpacing: 8, children: aksi),
              ),
              _Narasi.pakai => status(
                'Narasi disalin ke catatan pengantar laporan dan dapat Anda '
                'ubah. Angka di laporan resmi tetap dari catatan.',
                c.tinta,
              ),
              _Narasi.abai => status('Diabaikan. Tidak perlu alasan.', c.tinta),
            },
          ),
          Text(
            'AI hanya mengusulkan dan tidak memberi angka resmi.',
            style: TextStyle(fontSize: 13, color: c.tinta2),
          ),
        ]),
      ),
    );
  }

  void _pakai() => setState(() => _narasi = _Narasi.pakai);
  void _abai() => setState(() => _narasi = _Narasi.abai);
}

List<Widget> _jarak(double g, List<Widget> w) => [
  for (var i = 0; i < w.length; i++) ...[if (i > 0) SizedBox(height: g), w[i]],
];

class _Jawaban extends StatelessWidget {
  const _Jawaban();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dibaca sebagai: Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu · '
          'Oktober 2026 · ibadah pagi',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        // D33: computed from the rows shown, not hard-coded.
        Text(
          rp(cariJawaban.fold(0, (s, r) => s + r.$2)),
          style: const TextStyle(
            fontFamily: PalakatText.mono,
            fontSize: 30,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        Text(
          'Jumlah dari ${cariJawaban.length} transaksi yang sudah dibukukan. '
          'Angka ini dihitung aplikasi dari catatan, bukan oleh AI.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris({required this.ke});
  final String ke;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const mono = TextStyle(fontFamily: PalakatText.mono);
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final (i, (no, n)) in cariJawaban.indexed)
            Tautan(
              ke: ke,
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                decoration: BoxDecoration(
                  border: i == 0
                      ? null
                      : Border(top: BorderSide(color: c.garis)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Persembahan Ibadah Minggu',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: no, style: mono),
                                TextSpan(text: ' · ${_tanggal[i]} · Kas'),
                              ],
                            ),
                            style: TextStyle(fontSize: 13, color: c.tinta3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      rp(n),
                      style: mono.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The AI card: `permukaan`, 1.5 dotted `laut`, radius 12, padding 14,
/// entering with `muncul` 300 ms; the tag, then 14 italic `lautTua`.
class _KartuAi extends StatelessWidget {
  const _KartuAi({
    super.key,
    required this.label,
    required this.jarak,
    required this.teks,
    required this.ekor,
  });
  final String label, teks;
  final double jarak;

  /// Caption or action row, not italic.
  final Widget ekor;

  @override
  Widget build(BuildContext context) => Gerak(
    Kerangka.muncul,
    lama: const Duration(milliseconds: 300),
    child: Kartu(
      status: GarisStatus.usulanAI,
      radius: 12,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _jarak(jarak, [
          LencanaStatus(label, bentuk: BentukLencana.usulanAI),
          Text(
            teks,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: context.warna.lautTua,
            ),
          ),
          ekor,
        ]),
      ),
    ),
  );
}
