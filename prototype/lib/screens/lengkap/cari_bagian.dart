import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/finance/finance.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/cari.dart';
import '../../providers/repositories_keuangan.dart';
import '../../motion/kerangka.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// Parts shared by Cari and WebCari (spec 08): the same state, handlers,
/// search, answer, rows and AI panel. The search runs over posted records
/// ([cariKeuanganProvider]); the answer is the sum of the rows listed (D33).

enum _Ai { belum, proses, ada }

enum _Narasi { belum, ada, pakai, abai }

/// The board's state `{ q, ai, narasi }` and its handlers.
mixin LogikaCari<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late final TextEditingController q;
  _Ai _ai = _Ai.belum;
  _Narasi _narasi = _Narasi.belum;
  Timer? _t;

  /// The month before the running one (M−1): the board's "Oktober".
  Period? get _bulanLalu {
    final b = ref.watch(bulanBukuProvider);
    final i = b.semua.indexWhere((p) => p.id == b.berjalan?.id);
    return i > 0 ? b.semua[i - 1] : b.berjalan;
  }

  @override
  void initState() {
    super.initState();
    final b = ref.read(bulanBukuProvider);
    final i = b.semua.indexWhere((p) => p.id == b.berjalan?.id);
    final p = i > 0 ? b.semua[i - 1] : b.berjalan;
    q = TextEditingController(
      text: [
        'persembahan Minggu pagi',
        if (p != null) 'bulan ${_namaBulanSaja(p)}',
      ].join(' '),
    );
  }

  HasilCari get _hasil => ref.watch(cariKeuanganProvider(q.text));
  bool get cocok => _hasil.cocok;

  // The board leaves the 1300 ms timer running here; cancelling it keeps an
  // explanation from appearing for rows no longer shown (spec 08 note).
  void onQ(String _) => setState(() {
    _t?.cancel();
    _ai = _Ai.belum;
  });

  void tanya() {
    setState(() => _ai = _Ai.proses);
    _t?.cancel();
    _t = Timer(_jeda, _ada); // tiruan: AI menyusun penjelasan
  }

  static const _jeda = Duration(milliseconds: 1300);
  void _ada() => setState(() => _ai = _Ai.ada);

  @override
  void dispose() {
    _t?.cancel();
    q.dispose();
    super.dispose();
  }

  /// Search field, answer and rows (or the empty box): Cari 2a–2d.
  List<Widget> hasil({required Layar ke}) {
    final h = _hasil;
    return [
      IsianTeks(
        controller: q,
        labelSemantik: 'Cari transaksi',
        petunjuk: 'Cari dengan kata sehari-hari',
        minTinggi: 52,
        // letterSpacing 0: the theme's M3 bodyLarge (0.5) leaks into TextField.
        gaya: const TextStyle(fontSize: 16, letterSpacing: 0),
        onChanged: onQ,
      ),
      if (h.cocok) ...[
        _Jawaban(h),
        _Baris(h, ke: ke),
      ] else
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tidak ada transaksi yang cocok di '
            '${ref.watch(workspaceRepositoryProvider).workspace().name}.',
            style: TextStyle(fontSize: 14, color: context.warna.tinta2),
          ),
        ),
    ];
  }

  /// The explanation of the rows shown: count, largest and smallest.
  String _penjelasan(HasilCari h) {
    final b = [...h.baris]..sort((x, y) => x.jumlah.compareTo(y.jumlah));
    String hari(BarisCari r) {
      final d = r.baris.transaksi.effectiveDate;
      return '${d.hari} ${_namaBulanSaja(d)}';
    }

    final n = b.length;
    if (n == 1) return 'Satu transaksi tercatat, pada ${hari(b.first)}.';
    return '${_kata(n)} transaksi tercatat, dengan jumlah terbesar pada '
        '${hari(b.last)}. Jumlah ${hari(b.first)} paling kecil.';
  }

  /// The monthly narrative of M−1 from its posted figures (DM 4.2).
  String _narasiBulan(Period p) {
    final r = ref.watch(ringkasanBulanProvider(p.id));
    final belanja = <String, int>{};
    for (final t in ref.watch(transactionRepositoryProvider).list(p.id)) {
      if (!t.isPosted) continue;
      for (final e in effectsOf(t)) {
        final k = e.allocation.masterCode;
        if (e.expense > 0 && k != null) {
          belanja[k] = (belanja[k] ?? 0) + e.expense;
        }
      }
    }
    final terbesar = belanja.entries.isEmpty
        ? null
        : belanja.entries.reduce((a, b) => b.value > a.value ? b : a).key;
    final nama = terbesar == null
        ? null
        : ref
              .watch(masterRepositoryProvider)
              .pickerRows(MasterKind.belanja, p.end)
              .where((m) => m.code == terbesar)
              .firstOrNull
              ?.name;
    return [
      'Pada ${namaBulan(p)} Pendapatan Jemaat ${rp(r?.pendapatan ?? 0)} dan '
          'Belanja ${rp(r?.belanja ?? 0)}.',
      if (nama != null) 'Belanja terbesar adalah ${nama.toLowerCase()}.',
      if (p.isClosed) 'Semua Kas/Bank sudah direkonsiliasi tanpa selisih.',
    ].join(' ');
  }

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
    final bulanLalu = _bulanLalu;
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
          if (_ai == _Ai.ada && cocok)
            _KartuAi(
              key: const ValueKey('penjelasan'),
              label: 'Usulan AI · penjelasan',
              jarak: 6,
              teks: _penjelasan(_hasil),
              ekor: Text(
                'Berdasarkan ${_hasil.baris.length} transaksi di atas saja. '
                'AI tidak melihat peruntukan atau Jemaat lain.',
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
              _ when bulanLalu == null => const SizedBox.shrink(),
              _Narasi.belum => tombolAi(
                'Buat usulan narasi bulanan ${_namaBulanSaja(bulanLalu)}',
                () => setState(() => _narasi = _Narasi.ada),
              ),
              _Narasi.ada => _KartuAi(
                key: const ValueKey('narasi'),
                label: 'Usulan AI · narasi bulanan',
                jarak: 8,
                teks: _narasiBulan(bulanLalu),
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

/// '{Bulan}' of a period or date (no year).
String _namaBulanSaja(Object d) => switch (d) {
  Period p => bulanTahun(p.year, p.month),
  Tanggal t => bulanTahun(t.tahun, t.bulan),
  _ => '',
}.split(' ').first;

/// 'Empat', 'Lima': counts up to ten in words.
String _kata(int n) => n >= 2 && n <= 10
    ? const [
        'Dua',
        'Tiga',
        'Empat',
        'Lima',
        'Enam',
        'Tujuh',
        'Delapan',
        'Sembilan',
        'Sepuluh',
      ][n - 2]
    : '$n';

class _Jawaban extends StatelessWidget {
  const _Jawaban(this.h);
  final HasilCari h;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (h.dibacaSebagai != null)
          Text(
            'Dibaca sebagai: ${h.dibacaSebagai}',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        // D33: the sum of the rows listed, computed by the app.
        Text(
          rp(h.jumlah),
          style: const TextStyle(
            fontFamily: PalakatText.mono,
            fontSize: 30,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        Text(
          'Jumlah dari ${h.baris.length} transaksi yang sudah dibukukan. '
          'Angka ini dihitung aplikasi dari catatan, bukan oleh AI.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris(this.h, {required this.ke});
  final HasilCari h;
  final Layar ke;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const mono = TextStyle(fontFamily: PalakatText.mono);
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final (i, r) in h.baris.indexed)
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
                          Text(
                            r.baris.transaksi.description,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: r.baris.nomor, style: mono),
                                TextSpan(
                                  text:
                                      ' · ${r.baris.tanggal} · '
                                      '${r.baris.kasBank}',
                                ),
                              ],
                            ),
                            style: TextStyle(fontSize: 13, color: c.tinta3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      rp(r.jumlah),
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
