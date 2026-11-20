import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../mock/mock.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/batang_pembagian.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/isian_jumlah.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

/// Saldo buku of Bank BNI ··4821 on 16/11/2026: it never changes here.
final int _saldoBni = saldoNovember['bni']!;

/// State and derived values of the board's logic class, shared by
/// AlihPeruntukan and WebAlihPeruntukan (each screen owns its own instance).
class AlihPeruntukanLogika {
  String? dari, ke;

  /// Amount digits, as the board's `jm`.
  String jm = '';
  String dasar = '';
  bool posted = false;

  int get _j => int.tryParse(jm) ?? 0;

  /// The first unmet reason, '' when the move can be posted.
  String get alasan {
    if (dari == null || ke == null) return 'pilih peruntukan asal dan tujuan.';
    if (dari == ke) return 'peruntukan asal dan tujuan harus berbeda.';
    if (_j <= 0) return 'jumlah belum diisi.';
    if (_j > bniPerPeruntukanNovember[dari]!) {
      final nama = semuaPeruntukan.firstWhere((p) => p.id == dari).nama;
      return 'melebihi saldo peruntukan $nama di Bank BNI ··4821.';
    }
    if (dasar.trim().isEmpty) return 'dasar keputusan belum diisi.';
    return '';
  }

  bool get ok => alasan.isEmpty;

  /// Change of one peruntukan: shown while ready or after posting.
  int ubah(String id) =>
      ok || posted ? (id == dari ? -_j : (id == ke ? _j : 0)) : 0;

  int nilai(String id) => bniPerPeruntukanNovember[id]! + ubah(id);

  /// The board's `Math.round(v / 24615000 * 100) + '%'`.
  int persen(String id) => (nilai(id) / _saldoBni * 100).round();
}

/// The parts both boards draw, in their own columns.
mixin AlihPeruntukanIsi<T extends StatefulWidget> on State<T> {
  final logika = AlihPeruntukanLogika();
  final _jumlah = TextEditingController();
  final _dasar = TextEditingController();

  @override
  void dispose() {
    _jumlah.dispose();
    _dasar.dispose();
    super.dispose();
  }

  void _pilih(void Function() ubah) {
    if (logika.posted) return;
    setState(ubah);
  }

  /// Intro, Kas/Bank, Dari, Ke, amount and basis (phone 3a–3f).
  List<Widget> isian() {
    final c = context.warna;
    final l = logika;
    final pilihan = [
      for (final p in semuaPeruntukan) (nilai: p.id, teks: p.nama),
    ];
    return [
      Kartu(
        status: GarisStatus.draf,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Alih peruntukan.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text:
                    'Uang tetap di Kas/Bank yang sama; hanya pemiliknya yang '
                    'berpindah. Bukan Pendapatan dan bukan Belanja.',
                style: TextStyle(color: c.tinta2),
              ),
            ],
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Kas/Bank', style: TextStyle(fontSize: 14, color: c.tinta2)),
          const SizedBox(width: 16),
          const Flexible(
            child: Text(
              'Bank BNI ··4821',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      ChipPilihan<String>(
        label: 'Dari peruntukan',
        pilihan: pilihan,
        terpilih: l.dari,
        onPilih: (v) => _pilih(() => l.dari = v),
      ),
      ChipPilihan<String>(
        label: 'Ke peruntukan',
        pilihan: pilihan,
        terpilih: l.ke,
        onPilih: (v) => _pilih(() => l.ke = v),
      ),
      IsianJumlah(
        label: 'Jumlah (Rp)',
        controller: _jumlah,
        hanyaBaca: l.posted,
        onChanged: (v) => _pilih(() => l.jm = hanyaAngka(v)),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Text.rich(
              TextSpan(
                text: 'Dasar keputusan ',
                children: [
                  TextSpan(
                    text: '· wajib',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.tinta,
                    ),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
          const SizedBox(height: 6),
          IsianTeks(
            controller: _dasar,
            labelSemantik: 'Dasar keputusan · wajib',
            petunjuk: 'Contoh: keputusan BPMJ 09/11/2026',
            // The theme's M3 bodyLarge would add 0.5 letter spacing to the hint.
            gaya: const TextStyle(letterSpacing: 0),
            hanyaBaca: l.posted,
            onChanged: (v) => _pilih(() => l.dasar = v),
          ),
        ],
      ),
    ];
  }

  /// The balance card (terpilih line) with the split bar and legend (3g).
  Widget kartuSaldo() {
    final c = context.warna;
    final l = logika;
    final warna = BatangPembagian.warnaBagian(c);
    return Kartu(
      status: GarisStatus.terpilih,
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          _BarisSaldo(posted: l.posted),
          Text(
            'Tidak berubah. Yang berubah hanya pembagiannya per peruntukan:',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
          // Rounded percentages of the bar: a gap at 99, squeezed at 101.
          BatangPembagian(
            total: 100,
            garisPutus: false,
            durasi: const Duration(milliseconds: 500),
            bagian: [
              for (var i = 0; i < semuaPeruntukan.length; i++)
                BagianBatang(l.persen(semuaPeruntukan[i].id), warna[i]),
            ],
          ),
          for (var i = 0; i < semuaPeruntukan.length; i++)
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: i == 0
                  ? null
                  : BoxDecoration(
                      border: Border(top: BorderSide(color: c.garis)),
                    ),
              child: _BarisLegenda(
                warna: warna[i],
                nama: semuaPeruntukan[i].nama,
                ubah: switch (l.ubah(semuaPeruntukan[i].id)) {
                  0 => '',
                  final d => rpBeda(d),
                },
                nilai: rp(l.nilai(semuaPeruntukan[i].id)),
              ),
            ),
        ],
      ),
    );
  }

  /// The reason and the button before posting, the posted line after (3h, 3i).
  List<Widget> aksi() {
    final c = context.warna;
    final l = logika;
    if (l.posted) {
      return [
        Gerak(
          Kerangka.muncul,
          lama: const Duration(milliseconds: 300),
          child: Text(
            'Dibukukan pada 16/11/2026 11.55. Tidak muncul di Pendapatan, '
            'Belanja, atau rekening koran.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ),
      ];
    }
    return [
      if (!l.ok)
        Text(
          'Tidak dapat dibukukan: ${l.alasan}',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      // The board's own reason line is above; the component's is off.
      TombolBersyarat(
        label: 'Periksa dan bukukan',
        tindakan: 'Periksa dan bukukan',
        alasan: l.alasan,
        periksa: () => logika.alasan,
        sudahMulai: false,
        warnaSiap: JenisTombol.utama,
        teksBelumRedup: true,
        paddingH: 20,
        onPressed: () => setState(() => logika.posted = true),
      ),
    ];
  }
}

class AlihPeruntukanScreen extends StatefulWidget {
  const AlihPeruntukanScreen({super.key});

  @override
  State<AlihPeruntukanScreen> createState() => _AlihPeruntukanScreenState();
}

class _AlihPeruntukanScreenState extends State<AlihPeruntukanScreen>
    with AlihPeruntukanIsi {
  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: LayarPonsel(
      layarKeuangan: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Alih peruntukan',
            anakJudul: 'Dalam satu Kas/Bank',
            kembaliKe: Layar.keuangan,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [...isian(), kartuSaldo(), ...aksi()],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Width of [teks] in the inherited style merged with [gaya].
double _lebarTeks(BuildContext context, String teks, TextStyle gaya) =>
    _ukuranTeks(context, teks, gaya).width;

Size _ukuranTeks(BuildContext context, String teks, TextStyle gaya) {
  final tp = TextPainter(
    text: TextSpan(
      text: teks,
      style: DefaultTextStyle.of(context).style.merge(gaya),
    ),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final s = tp.size;
  tp.dispose();
  return s;
}

/// Min-content: the widest piece between break opportunities.
double _lebarMin(BuildContext context, String teks, TextStyle gaya) => teks
    .split(RegExp('[ ​]'))
    .map((s) => _lebarTeks(context, s, gaya))
    .fold(0.0, (a, b) => a > b ? a : b);

/// CSS flex shrinking (`flex: 0 1 auto`, `min-width: auto`) of items with
/// widths [dasar] and min-content widths [min] into [tersedia]. The result
/// can still exceed [tersedia]; the board's row then overflows.
List<double> _susut(List<double> dasar, List<double> min, double tersedia) {
  final n = dasar.length;
  final w = [...dasar];
  final beku = List.filled(n, false);
  while (true) {
    var bebas = tersedia, skala = 0.0;
    for (var i = 0; i < n; i++) {
      if (beku[i]) {
        bebas -= w[i];
      } else {
        bebas -= dasar[i];
        skala += dasar[i];
      }
    }
    if (bebas >= 0 || skala == 0) {
      for (var i = 0; i < n; i++) {
        if (!beku[i]) w[i] = dasar[i];
      }
      return w;
    }
    var langgar = false;
    for (var i = 0; i < n; i++) {
      if (beku[i]) continue;
      w[i] = dasar[i] + bebas * dasar[i] / skala;
      if (w[i] < min[i]) {
        w[i] = min[i];
        beku[i] = true;
        langgar = true;
      }
    }
    if (!langgar) return w;
  }
}

/// The card's top row: the saldo, and after posting the No. Bukti stamp,
/// shrunk like the board's flex items (the stamp wraps, the figure never).
class _BarisSaldo extends StatelessWidget {
  const _BarisSaldo({required this.posted});
  final bool posted;

  // Zero-width spaces: Chrome breaks after these hyphens, Flutter does not.
  static const _stempel = 'No. Bukti BKU-​2026-​0152';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const mono = TextStyle(fontFamily: PalakatText.mono);
    final gayaLabel = TextStyle(fontSize: 14, color: c.tinta2);
    final gayaSaldo = mono.copyWith(fontSize: 24, fontWeight: FontWeight.w500);
    final gayaStempel = mono.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: c.laut,
    );
    const label = 'Saldo buku Bank BNI ··4821';
    final saldo = rp(_saldoBni);
    final kiri = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: gayaLabel),
        Text(saldo, style: gayaSaldo),
      ],
    );
    if (!posted) return Align(alignment: Alignment.centerLeft, child: kiri);
    return LayoutBuilder(
      builder: (context, k) {
        final lebarSaldo = _lebarTeks(context, saldo, gayaSaldo);
        final w = _susut(
          [
            [
              _lebarTeks(context, label, gayaLabel),
              lebarSaldo,
            ].reduce((a, b) => a > b ? a : b),
            _lebarTeks(context, _stempel, gayaStempel) + 24,
          ],
          [lebarSaldo, _lebarMin(context, _stempel, gayaStempel) + 24],
          k.maxWidth - 16,
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: w[0], child: kiri),
            SizedBox(
              width: w[1],
              child: Gerak(
                Kerangka.muncul,
                lama: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: c.laut, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Semantics(
                    label: 'No. Bukti BKU-2026-0152',
                    child: ExcludeSemantics(
                      child: Text(_stempel, style: gayaStempel),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One legend row: swatch, name (`flex: 1`), change, value, gap 10, laid
/// out as the board's flex row: the name never breaks inside a word; when
/// it does not fit, the change wraps and the row may overflow the card's
/// padding, as on the board (Pembangunan "+ Rp500.000" at 390 wide).
class _BarisLegenda extends StatelessWidget {
  const _BarisLegenda({
    required this.warna,
    required this.nama,
    required this.ubah,
    required this.nilai,
  });

  final Color warna;
  final String nama, ubah, nilai;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const gayaNama = TextStyle(fontWeight: FontWeight.w600);
    const mono = TextStyle(fontFamily: PalakatText.mono);
    final gayaUbah = mono.copyWith(fontSize: 13, color: c.tinta2);
    final gayaNilai = mono.copyWith(fontWeight: FontWeight.w500);
    final kotak = Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(3),
      ),
    );
    return LayoutBuilder(
      builder: (context, k) {
        final tersedia = k.maxWidth - 12 - 30;
        final namaMin = _lebarMin(context, nama, gayaNama);
        final u = _lebarTeks(context, ubah, gayaUbah);
        final v = _lebarTeks(context, nilai, gayaNilai);
        if (namaMin + u + v <= tersedia) {
          return Row(
            spacing: 10,
            children: [
              kotak,
              Expanded(child: Text(nama, style: gayaNama)),
              Text(ubah, style: gayaUbah),
              Text(nilai, style: gayaNilai),
            ],
          );
        }
        final w = _susut(
          [namaMin, u, v],
          [namaMin, _lebarMin(context, ubah, gayaUbah), v],
          // Flutter measures these runs up to ~2 px wider than Chrome, which
          // fits Diakonia "+ Rp1.000.000" exactly at 390; overhang instead.
          tersedia + 2,
        );
        // The value keeps its width and runs past the row's end, unclipped.
        return Row(
          spacing: 10,
          children: [
            kotak,
            SizedBox(
              width: w[0],
              child: Text(nama, style: gayaNama),
            ),
            SizedBox(
              width: w[1],
              child: Text(ubah, style: gayaUbah),
            ),
            Expanded(
              child: SizedBox(
                height: _ukuranTeks(context, nilai, gayaNilai).height,
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  maxWidth: double.infinity,
                  child: Text(nilai, style: gayaNilai, softWrap: false),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
