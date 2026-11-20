import 'dart:async';

import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// Web · Serah terima Bendahara (spec 10-aifoto.md, WebSerahTerima).
class WebSerahTerimaScreen extends StatefulWidget {
  const WebSerahTerimaScreen({super.key});

  @override
  State<WebSerahTerimaScreen> createState() => _WebSerahTerimaScreenState();
}

const _subSesi = {
  'Ponsel ini': 'Sesi ini · aktif sekarang',
  'Chrome di laptop': 'Terakhir dipakai 14/11/2026 20.15',
};

class _WebSerahTerimaScreenState extends State<WebSerahTerimaScreen> {
  String _tahap = 'belum';
  static const _namaAwal = 'Yohanis Tumbelaka';
  String _nama = _namaAwal;
  List<String> _sesi = const ['Ponsel ini', 'Chrome di laptop'];
  late final _isian = TextEditingController(text: _nama);
  Timer? _t;

  bool get _okNama => _nama.trim().isNotEmpty;
  String _alasan() => _okNama ? '' : 'Nama yang ditunjuk belum diisi.';

  void _kirim() {
    if (!_okNama) return;
    setState(() => _tahap = 'tunggu');
    _t?.cancel();
    _t = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _tahap = 'aktif');
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _isian.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kosong =
        belumDipindah<String>('Bendahara aktif') != 'Bendahara aktif';
    final aktif = _tahap == 'aktif', tunggu = _tahap == 'tunggu';
    const tebal = TextStyle(fontWeight: FontWeight.w700);

    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The board's inline link sits in a 15/1.45 line box (21.75 high).
        MarginNegatif(
          atas: 11.125,
          bawah: 11.125,
          child: Tautan(
            ke: Layar.pengaturan,
            cara: Cara.naik,
            child: const Center(
              widthFactor: 1,
              heightFactor: 1,
              child: TautanTeks('Pengaturan', ukuran: 14),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: const Text(
            'Serah terima Bendahara',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    final pita = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: c.tinta,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 14, color: c.diTinta),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Belum ada Bendahara aktif',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: c.permukaan,
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                text:
                    'Wewenang Meiske Lumentut dicabut pada 16/11/2026 08.10 '
                    'oleh Petugas verifikasi. Semua data hanya dapat dilihat. ',
                children: [
                  TextSpan(
                    text: 'Yang perlu bertindak: BPMJ Jemaat Karunia.',
                    style: tebal.copyWith(color: c.permukaan),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                text: 'Sementara itu, Operator Jemaat dapat ',
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: MarginNegatif(
                      atas: 11.85,
                      bawah: 11.85,
                      child: Tautan(
                        ke: Layar.jabatanKosong,
                        child: Center(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: TautanTeks(
                            'menjalankan jabatan kosong',
                            berat: FontWeight.w700,
                            ukuran: 14,
                            warna: c.permukaan,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                    text: ' ini. Setiap tindakannya tercatat atas namanya.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Handover chain: old card, connector, new card.
    final lama = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(aktif ? c.tinta3 : c.tinta, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _JudulLencana(
            judul: 'Meiske Lumentut',
            lencana: aktif
                ? _Lencana(
                    'Wewenang berakhir',
                    isi: c.permukaan,
                    teks: c.tinta2,
                    garis: GarisBorder.penuh(c.tinta3, radius: 6),
                  )
                : _Lencana(
                    'Wewenang Bendahara aktif',
                    isi: c.laut,
                    teks: c.diLaut,
                    garis: GarisBorder.penuh(c.laut, radius: 6),
                  ),
          ),
          Text(
            aktif
                ? 'Berakhir 16/11/2026 · semua sesi diakhiri'
                : 'Tetap aktif sampai Bendahara baru diverifikasi',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    );

    final baru = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: aktif ? c.permukaan : null,
        shape: aktif
            ? GarisBorder.penuh(c.tinta, radius: 14)
            : GarisBorder.putus(c.putus, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _JudulLencana(
            judul: 'Bendahara baru',
            lencana: aktif
                ? _Lencana(
                    'Wewenang Bendahara aktif',
                    isi: c.laut,
                    teks: c.diLaut,
                    garis: GarisBorder.penuh(c.laut, radius: 6),
                  )
                : _Lencana(
                    tunggu ? 'Menunggu verifikasi wewenang' : 'Belum dikirim',
                    teks: c.tinta2,
                    garis: GarisBorder.putus(c.putus, radius: 6),
                  ),
          ),
          const SizedBox(height: 10),
          if (_tahap == 'belum') ...[
            IsianTeks(
              controller: _isian,
              label: 'Nama yang ditunjuk',
              jarakLabel: 6,
              onChanged: (v) => setState(() => _nama = v),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: 'Surat penunjukan baru: ',
                children: [
                  TextSpan(
                    text: 'SK-BPMJ-09-2026.pdf · Terlampir',
                    style: tebal.copyWith(color: c.tinta),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            const SizedBox(height: 10),
            // Rule A02: the sentence the board lacks, once the name is
            // edited; drawn here so the hugged button keeps its width.
            if (_nama != _namaAwal && !_okNama) ...[
              Penolakan(
                tindakan: 'Kirim untuk diverifikasi',
                sebab: _alasan(),
                jalan: const [],
                ukuranTeks: 14,
              ),
              const SizedBox(height: 8),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: TombolBersyarat(
                  label: 'Kirim untuk diverifikasi',
                  tindakan: 'Kirim untuk diverifikasi',
                  alasan: _alasan(),
                  periksa: _alasan,
                  onPressed: _kirim,
                  sudahMulai: false,
                  warnaSiap: JenisTombol.utama,
                  teksBelumRedup: true,
                  tinggi: 46,
                  radius: 12,
                  paddingH: 20,
                ),
              ),
            ),
          ],
          if (tunggu)
            Semantics(
              liveRegion: true,
              container: true,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: _nama, style: tebal),
                    const TextSpan(
                      text:
                          ' · menunggu Petugas verifikasi memeriksa surat '
                          'penunjukan.',
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          if (aktif)
            Gerak(
              Kerangka.muncul,
              key: const ValueKey('aktif'),
              lama: const Duration(milliseconds: 300),
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: _nama, style: tebal),
                      const TextSpan(
                        text: ' · aktif sejak 16/11/2026 · SK-BPMJ-09-2026',
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );

    final rantai = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        lama,
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 2,
            height: 22,
            margin: const EdgeInsets.only(left: 28),
            color: c.tinta,
          ),
        ),
        const SizedBox(height: 6),
        baru,
      ],
    );

    final judulSedang = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: c.tinta,
    );
    final sesi = aktif
        ? const [
            (
              n: 'Belum ada sesi',
              s: 'Semua sesi Meiske Lumentut diakhiri 16/11/2026',
              bisa: false,
            ),
          ]
        : [
            for (final n in _sesi)
              (n: n, s: _subSesi[n]!, bisa: n != 'Ponsel ini'),
          ];

    final aturan = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 14, color: c.tinta2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, t) in [
                'Yang terjadi saat wewenang berpindah',
                'Semua sesi Bendahara lama diakhiri saat itu juga.',
                'Bendahara baru tidak mewarisi persetujuan yang pernah '
                    'dicatat Bendahara lama.',
                'Riwayat tetap mencatat Bendahara lama sebagai pelaku '
                    'tindakannya.',
                'Sampai verifikasi selesai, Bendahara lama tetap aktif. '
                    'Tidak pernah ada dua Bendahara aktif.',
              ].indexed) ...[
                if (i > 0) const SizedBox(height: 6),
                Text(t, style: i == 0 ? judulSedang : null),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sesi yang sedang masuk · ${aktif ? _nama : 'Meiske Lumentut'}',
          style: judulSedang,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
          ),
          child: Column(
            children: [
              for (final (i, x) in sesi.indexed)
                Container(
                  // CSS content-box: min-height 56 plus the 1 px rule.
                  constraints: BoxConstraints(minHeight: i > 0 ? 57 : 56),
                  decoration: BoxDecoration(
                    border: i > 0
                        ? Border(top: BorderSide(color: c.garis))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              x.n,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              x.s,
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                          ],
                        ),
                      ),
                      if (x.bisa) ...[
                        const SizedBox(width: 12),
                        Tekan(
                          onTap: () => setState(
                            () => _sesi = [
                              for (final s in _sesi)
                                if (s != x.n) s,
                            ],
                          ),
                          radius: 10,
                          child: RupaTombol(
                            label: 'Akhiri sesi',
                            isi: c.permukaan,
                            garis: GarisBorder.penuh(c.garisTegas, radius: 10),
                            warnaTeks: c.tinta,
                            radius: 10,
                            tinggi: 44,
                            paddingH: 12,
                            lebarPenuh: false,
                            ukuranTeks: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Pemulihan akun mengembalikan akses orang yang sama dan tidak '
          'memerlukan penunjukan baru.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );

    return HalamanWeb(
      nav: NavSamping(item: navKeuangan, aktif: 6),
      isi: [
        judul,
        if (kosong) pita,
        BarisLentur(
          jarak: 28,
          anak: [
            Lentur(dasar: 380, child: rantai),
            Lentur(dasar: 420, tumbuh: 999, child: aturan),
          ],
        ),
      ],
    );
  }
}

/// Post badge: 13/700, radius 6, padding 3 9, 1.5 line.
/// The board's `justify-content: space-between` row of a bold title and a
/// badge, gap 16: when both do not fit, CSS shrinks each in proportion to
/// its width (never below its longest word), so both may wrap.
class _JudulLencana extends StatelessWidget {
  const _JudulLencana({required this.judul, required this.lencana});

  final String judul;
  final _Lencana lencana;

  static const _gayaJudul = TextStyle(fontWeight: FontWeight.w700);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      final dasar = DefaultTextStyle.of(context).style;
      final skala = MediaQuery.textScalerOf(context);
      double lebar(String t, TextStyle g) {
        final tp = TextPainter(
          text: TextSpan(text: t, style: dasar.merge(g)),
          textDirection: TextDirection.ltr,
          textScaler: skala,
        )..layout();
        final w = tp.width;
        tp.dispose();
        return w;
      }

      double kata(String t, TextStyle g) =>
          t.split(' ').map((s) => lebar(s, g)).reduce((a, b) => a > b ? a : b);
      const tepi = 9 * 2 + 1.5 * 2;
      final a = lebar(judul, _gayaJudul);
      final b = lebar(lencana.label, _Lencana.gaya) + tepi;
      final ruang = k.maxWidth - 16;
      final pas = a + b <= ruang;
      var (wa, wb) = (a, b);
      if (!pas) {
        final lebih = a + b - ruang;
        final minA = kata(judul, _gayaJudul);
        final minB = kata(lencana.label, _Lencana.gaya) + tepi;
        wa = a - lebih * a / (a + b);
        wb = b - lebih * b / (a + b);
        if (wa < minA) (wa, wb) = (minA, ruang - minA);
        if (wb < minB) (wb, wa) = (minB, ruang - minB);
        wa = wa < minA ? minA : wa;
        wb = wb < minB ? minB : wb;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // At natural size nothing is pinned, so rounding cannot wrap.
          SizedBox(
            width: pas ? null : wa,
            child: Text(judul, style: _gayaJudul),
          ),
          const SizedBox(width: 16),
          SizedBox(width: pas ? null : wb, child: lencana),
        ],
      );
    },
  );
}

class _Lencana extends StatelessWidget {
  const _Lencana(
    this.label, {
    this.isi,
    required this.teks,
    required this.garis,
  });

  final String label;
  final Color? isi;
  final Color teks;
  final GarisBorder garis;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: ShapeDecoration(color: isi, shape: garis),
    child: Text(label, style: gaya.copyWith(color: teks)),
  );

  static const gaya = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);
}
