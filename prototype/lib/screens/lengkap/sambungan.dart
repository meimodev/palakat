import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';
import '../../providers/session.dart';

/// Session-ended variants of the `keadaan` tweak: (h1, caption, "Masuk lagi").
const _sesi = {
  'Sesi berakhir: lama tidak dipakai': (
    'Sesi Anda berakhir',
    'Aplikasi mengakhiri sesi yang lama tidak dipakai.',
    true,
  ),
  'Sesi berakhir: diakhiri dari perangkat lain': (
    'Sesi di perangkat ini diakhiri',
    'Diakhiri oleh Meiske L. dari perangkat lain, 16/11/2026 11.40.',
    true,
  ),
  'Sesi berakhir: wewenang berpindah': (
    'Sesi Anda berakhir',
    'Wewenang Bendahara berpindah pada 16/11/2026. Semua sesi Bendahara lama diakhiri saat itu juga.',
    false,
  ),
};

enum _St { putus, coba, simpan }

/// 38 · Sambungan terputus dan sesi berakhir
/// (docs/build/screens/10-aifoto.md, Sambungan).
class SambunganScreen extends StatefulWidget {
  const SambunganScreen({super.key});

  @override
  State<SambunganScreen> createState() => _SambunganScreenState();
}

class _SambunganScreenState extends State<SambunganScreen> {
  _St _st = _St.putus;
  int _n = 1;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _coba() {
    if (_st != _St.putus) return;
    // Read at press time, as the board's closure does.
    final pulih = belumDipindah(false);
    final n = _n;
    setState(() => _st = _St.coba);
    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        if (pulih) {
          _st = _St.simpan;
        } else {
          _st = _St.putus;
          _n = n + 1;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final keadaan = belumDipindah<String>('Tidak ada sambungan');
    final sesi = _sesi[keadaan];
    return LayarPonsel(
      child: sesi == null
          ? _form(context)
          : Gerak(
              Kerangka.pudar,
              lama: const Duration(milliseconds: 250),
              child: _Sesi(sesi),
            ),
    );
  }

  Widget _form(BuildContext context) {
    final c = context.warna;
    final simpan = _st == _St.simpan;
    final garisKartu = simpan ? c.tinta : c.putus;
    GarisBorder garis(Color w, double r) => simpan
        ? GarisBorder.penuh(w, radius: r)
        : GarisBorder.putus(w, radius: r);
    final lencana = switch (_st) {
      _St.simpan => 'Tersimpan',
      _St.coba => 'Mencoba menyimpan lagi…',
      _St.putus => 'Belum tersimpan',
    };

    final isi = <Widget>[
      if (_st == _St.putus)
        Semantics(
          container: true,
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: ShapeDecoration(
              color: c.bataLembut,
              shape: GarisBorder.penuh(c.bata, radius: 14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _sela(4, [
                Row(
                  children: [
                    PalakatIkon(Ikon.tanpaSambungan, warna: c.bata),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tidak ada sambungan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Palakat bekerja hanya saat tersambung. Isian di bawah belum tersimpan, dan tetap ada selama layar ini terbuka.',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
                if (_n > 1)
                  Text(
                    'Masih belum tersambung · percobaan ke-$_n',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.bata,
                    ),
                  ),
              ]),
            ),
          ),
        ),
      if (_st == _St.coba)
        Semantics(
          container: true,
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: ShapeDecoration(
              color: c.permukaan,
              shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _sela(10, [
                const Text(
                  'Mencoba menyimpan lagi…',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                BatangIsi(
                  key: ValueKey(_n),
                  lama: const Duration(milliseconds: 1600),
                ),
                Text(
                  'Percobaan ulang tidak membuat draf kedua dan tidak membuat No. Bukti.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ]),
            ),
          ),
        ),
      if (simpan)
        Gerak(
          Kerangka.muncul,
          lama: const Duration(milliseconds: 300),
          child: Semantics(
            container: true,
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: c.lautLembut,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tersambung lagi. Draf tersimpan.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Tersimpan satu kali. Tidak ada salinan ganda dari percobaan sebelumnya.',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                ],
              ),
            ),
          ),
        ),
      // `transition: border .3s`: the colour eases, the dash swaps at once.
      TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: garisKartu),
        duration: context.gerak(const Duration(milliseconds: 300)),
        curve: Curves.ease,
        builder: (context, w, child) => Container(
          padding: const EdgeInsets.all(18),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: garis(w ?? garisKartu, 16),
          ),
          child: child,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _sela(6, [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: ShapeDecoration(shape: garis(garisKartu, 6)),
              child: Text(
                '$lencana · Draf · belum masuk saldo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.tinta2,
                ),
              ),
            ),
            Text(
              rp(-85000),
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: c.tinta2,
              ),
            ),
            const Text(
              'Air minum untuk rapat',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Kas · diambil dari peruntukan Umum Jemaat · Lingkup Jemaat · 16 November 2026',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
            Text(
              'Belanja 5.04.01.00 Konsumsi rapat',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ]),
        ),
      ),
      if (!simpan)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _sela(6, [
            const Text(
              'Menunggu sambungan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            Text(
              'Simpan sebagai draf, Periksa dan bukukan, dan melampirkan dokumen pendukung. Semuanya berjalan di server, jadi tidak ada yang dibukukan dari perangkat ini saja.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ]),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Belanja',
          kembaliKe: Layar.keuangan,
          labelKembali: 'Kembali ke Beranda',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _sela(16, isi),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border(top: BorderSide(color: c.garis)),
          ),
          child: switch (_st) {
            _St.putus => Tombol(
              'Coba lagi',
              onPressed: _coba,
              jenis: JenisTombol.tinta,
              paddingH: 20,
            ),
            _St.coba => Tombol(
              'Mencoba menyimpan lagi…',
              onPressed: null,
              nonaktif: true,
              paddingH: 20,
            ),
            _St.simpan => Tombol(
              'Periksa dan bukukan',
              onPressed: null,
              ke: Layar.keuangan,
              paddingH: 20,
            ),
          },
        ),
      ],
    );
  }
}

/// The session-ended view: centred vertically, everything left-aligned.
class _Sesi extends StatelessWidget {
  const _Sesi(this.s);
  final (String, String, bool) s;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tebal = TextStyle(fontWeight: FontWeight.w700, color: c.tinta);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _sela(20, [
          const Align(
            alignment: Alignment.centerLeft,
            child: PalakatIkon(Ikon.sesiBerakhir, ukuran: 56),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  s.$1,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(s.$2, style: TextStyle(fontSize: 15, color: c.tinta2)),
            ],
          ),
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 14, color: c.tinta2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _sela(6, [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Tetap aman:', style: tebal),
                      const TextSpan(
                        text: ' semua yang sudah dibukukan dan draf yang sudah tersimpan.',
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Tidak ikut tersimpan:', style: tebal),
                      const TextSpan(
                        text: ' isian yang belum tersimpan di perangkat ini.',
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          if (s.$3)
            Tombol(
              'Masuk lagi',
              onPressed: () => keluarSesi(context),
              paddingH: 20,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: ShapeDecoration(
                shape: GarisBorder.putus(c.putus, radius: 14),
              ),
              child: const Text(
                'Anda tidak lagi memegang wewenang Bendahara Jemaat Karunia. Riwayat tetap mencatat tindakan Anda. Bila ini keliru, yang dapat membantu adalah BPMJ Jemaat Karunia.',
                style: TextStyle(fontSize: 14),
              ),
            ),
        ]),
      ),
    );
  }
}

/// CSS `gap`: [jarak] between the children.
List<Widget> _sela(double jarak, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: jarak),
    anak[i],
  ],
];
