import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../motion/kerangka.dart';
import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/rangka.dart';
import '../../widgets/tombol.dart';

/// The boards' secondary `<a>` buttons: content-box, so the 1.5 line adds 3 px
/// to the min height (48 → 51 phone, 46 → 49 web). Wrap in a `Tautan`.
Widget rupaTautanKedua(
  BuildContext context,
  String label, {
  required double tinggi,
  required double radius,
  double paddingH = 20,
  bool lebarPenuh = true,
}) {
  final c = context.warna;
  return RupaTombol(
    label: label,
    isi: c.permukaan,
    garis: GarisBorder.penuh(c.tinta, radius: radius),
    warnaTeks: c.tinta,
    radius: radius,
    tinggi: tinggi + 3,
    paddingH: paddingH,
    lebarPenuh: lebarPenuh,
  );
}

/// CSS half-leading (even), so text sits where the board's line boxes put it.
// ponytail: local until lib/theme sets it app-wide (reported as a shared need).
const cssLeading = TextHeightBehavior(
  leadingDistribution: TextLeadingDistribution.even,
);

/// Shared by Memuat and WebMemuat: their state logic and the blocks both
/// boards draw identically (text size is inherited: 16 phone, 15 web).

/// The board's `st`: Beranda view (muat, gagal, ada), Periksa view (aksi, buku).
enum KeadaanMemuat { muat, gagal, ada, aksi, buku }

const _dariTweak = {
  'Sedang memuat': KeadaanMemuat.muat,
  'Gagal memuat': KeadaanMemuat.gagal,
  'Bukukan tidak terjadi': KeadaanMemuat.aksi,
};

/// The logic class: `state = { st: null }`, `coba`, `cobaBuku`. As on the
/// canvas, a handler-set `st` overrides the `keadaan` tweak until the board
/// is reopened (CONVENTIONS board parity; the spec's reset is only advised).
mixin PengendaliMemuat<T extends StatefulWidget> on State<T> {
  String get stem;

  KeadaanMemuat? _st;
  Timer? _timer;

  KeadaanMemuat get st =>
      _st ?? _dariTweak[context.tweak<String>(stem, 'keadaan')]!;
  bool get beranda => st.index <= KeadaanMemuat.ada.index;

  void coba() {
    setState(() => _st = KeadaanMemuat.muat);
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _st = KeadaanMemuat.ada);
    });
  }

  void cobaBuku() => setState(() => _st = KeadaanMemuat.buku);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

List<Widget> _bergap(double gap, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: gap),
    anak[i],
  ],
];

/// `display: flex; flex-direction: column; gap`.
Widget kolom(double gap, List<Widget> anak) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  mainAxisSize: MainAxisSize.min,
  children: _bergap(gap, anak),
);

Widget _kartu(EdgeInsets padding, Widget child) =>
    Kartu(padding: padding, child: child);

/// Children of the Beranda content column for `muat`, `gagal` or `ada`.
/// [buka] is the board's "Buka Beranda" link button.
List<Widget> isiBeranda(
  BuildContext context,
  KeadaanMemuat st, {
  required VoidCallback onCoba,
  required Widget buka,
}) {
  final c = context.warna;
  switch (st) {
    case KeadaanMemuat.muat:
      Widget baris() => const Row(
        children: [
          Expanded(flex: 44, child: RangkaBalok(lebar: 1, tinggi: 16)),
          Spacer(flex: 30),
          Expanded(flex: 26, child: RangkaBalok(lebar: 1, tinggi: 16)),
        ],
      );
      Widget kecil() => _kartu(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        kolom(8, const [
          RangkaBalok(lebar: .58, tinggi: 14),
          RangkaBalok(lebar: .32, tinggi: 14),
        ]),
      );
      return [
        Rangka(
          keterangan: 'Memuat saldo dan transaksi…',
          balok: [
            const RangkaBalok(lebar: .62, tinggi: 44),
            _kartu(
              const EdgeInsets.all(16),
              kolom(14, [baris(), baris(), baris()]),
            ),
            kolom(10, [
              const RangkaBalok(lebar: .34, tinggi: 18),
              kecil(),
              kecil(),
            ]),
          ],
        ),
      ];
    case KeadaanMemuat.gagal:
      return [
        RangkaGagal(
          kalimat: 'Server tidak menjawab. Pembukuan Anda tidak berubah.',
          onCobaLagi: onCoba,
        ),
        Text(
          'Saldo tidak ditampilkan sampai data berhasil dimuat, supaya angka kosong tidak terbaca sebagai nol.',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ];
    default:
      final s = saldoNovember;
      final mono = TextStyle(fontFamily: PalakatText.mono);
      final baris = [
        ('Kas', s['kas']!),
        ('Bank BNI ··4821', s['bni']!),
        ('Bank SulutGo ··1107', s['bsg']!),
      ];
      return [
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('ada'),
          lama: const Duration(milliseconds: 300),
          child: kolom(16, [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo buku · semua Kas/Bank',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
                Text(
                  rp(s.values.reduce((a, b) => a + b)),
                  style: mono.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'Hanya transaksi yang sudah dibukukan',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
            _kartu(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              Column(
                children: [
                  for (var i = 0; i < baris.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: i == 0
                          ? null
                          : BoxDecoration(
                              border: Border(top: BorderSide(color: c.garis)),
                            ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: Text(baris[i].$1)),
                          const SizedBox(width: 16),
                          Text(rp(baris[i].$2), style: mono),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            buka,
          ]),
        ),
      ];
  }
}

/// `role="alert"` card: `bataLembut`, 1.5 `bata`, radius 14, padding 16, gap 6.
class _Peringatan extends StatelessWidget {
  const _Peringatan(this.judul, this.kalimat);
  final String judul, kalimat;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: c.bataLembut,
          shape: GarisBorder.penuh(c.bata, radius: 14),
        ),
        child: kolom(6, [
          Text(
            judul,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          Text(kalimat, style: TextStyle(fontSize: 14, color: c.tinta2)),
        ]),
      ),
    );
  }
}

/// Children of the Periksa content column for `aksi` or `buku`.
List<Widget> isiPeriksa(BuildContext context, KeadaanMemuat st) {
  final c = context.warna;
  final jumlah = TextStyle(
    fontFamily: PalakatText.mono,
    fontSize: 30,
    fontWeight: FontWeight.w500,
  );
  const uraian = Text(
    'Air minum untuk rapat',
    style: TextStyle(fontWeight: FontWeight.w600),
  );
  if (st == KeadaanMemuat.aksi) {
    return [
      const _Peringatan(
        'Bukukan tidak terjadi: server tidak menjawab.',
        'Transaksi ini masih Draf dan belum masuk saldo. Belum ada No. Bukti yang dipakai.',
      ),
      Kartu(
        status: GarisStatus.draf,
        radius: 16,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _bergap(6, [
            const LencanaStatus(
              'Draf · belum masuk saldo',
              bentuk: BentukLencana.draf,
            ),
            Text(rp(-85000), style: jumlah.copyWith(color: c.tinta2)),
            uraian,
            Text(
              'Kas · Belanja 5.04.01.00 Konsumsi rapat · 16 November 2026',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ]),
        ),
      ),
      Text(
        'Coba lagi aman: tidak membuat transaksi kedua dan tidak memakai dua No. Bukti.',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
    ];
  }
  return [
    Gerak(
      Kerangka.muncul,
      key: const ValueKey('buku'),
      lama: const Duration(milliseconds: 300),
      child: Kartu(
        status: GarisStatus.terpilih,
        radius: 16,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _bergap(6, [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // The board draws this badge without a line (padding 3 9).
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.tinta,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Dibukukan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.permukaan,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Gerak(
                    Kerangka.muncul,
                    lama: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        shape: GarisBorder.penuh(c.laut, tebal: 2, radius: 8),
                      ),
                      child: Text(
                        'No. Bukti BKU-2026-0155',
                        style: TextStyle(
                          fontFamily: PalakatText.mono,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.laut,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(rp(-85000), style: jumlah),
            uraian,
            Text(
              'Dibukukan pada 16/11/2026 11.52 · satu kali',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ]),
        ),
      ),
    ),
  ];
}
