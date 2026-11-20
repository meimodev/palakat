import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

const _stem = 'WebSambungan';
const _tanpaSesi = 'Tidak ada sambungan';

/// keadaan → (h1, caption, "Masuk lagi" shown).
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

/// Web · Sambungan terputus dan sesi berakhir (10-aifoto.md, WebSambungan).
class WebSambunganScreen extends StatefulWidget {
  const WebSambunganScreen({super.key});
  @override
  State<WebSambunganScreen> createState() => _WebSambunganScreenState();
}

class _WebSambunganScreenState extends State<WebSambunganScreen> {
  _St _st = _St.putus;
  int _n = 1;
  Timer? _waktu;

  @override
  void dispose() {
    _waktu?.cancel();
    super.dispose();
  }

  void _coba() {
    if (_st != _St.putus) return;
    final pulih = context.tweak<bool>(_stem, 'sambunganKembali');
    final n = _n;
    setState(() => _st = _St.coba);
    // Fakes the reconnect-and-save attempt.
    _waktu = Timer(const Duration(milliseconds: 1600), () {
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

  void _ulang() {
    _waktu?.cancel();
    setState(() {
      _st = _St.putus;
      _n = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keadaan = context.tweak<String>(_stem, 'keadaan');
    final sesi = keadaan == _tanpaSesi ? null : _sesi[keadaan];
    return AlatPrototipe(
      stem: _stem,
      alat: [
        Tombol(
          'Ulangi contoh',
          jenis: JenisTombol.teks,
          lebarPenuh: false,
          onPressed: _ulang,
        ),
      ],
      child: HalamanWeb(
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 1,
          pengguna: PenggunaKeuangan(ikutJabatanKosong: false),
        ),
        isi: sesi == null
            ? [const _Judul(), _formulir(context)]
            : [
                _SesiBerakhir(
                  judul: sesi.$1,
                  catatan: sesi.$2,
                  bisaMasuk: sesi.$3,
                ),
              ],
      ),
    );
  }

  Widget _formulir(BuildContext context) {
    final c = context.warna;
    final simpan = _st == _St.simpan;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            if (_st == _St.putus) _PitaPutus(key: ValueKey('putus$_n'), n: _n),
            if (_st == _St.coba) _KartuCoba(key: ValueKey('coba$_n')),
            if (simpan) const _PitaTersimpan(key: ValueKey('simpan')),
            _KartuDraf(st: _st),
            if (!simpan)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  const Text(
                    'Menunggu sambungan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Simpan sebagai draf, Periksa dan bukukan, dan melampirkan dokumen pendukung. Semuanya berjalan di server, jadi tidak ada yang dibukukan dari perangkat ini saja.',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                ],
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                switch (_st) {
                  _St.putus => Tombol(
                    'Coba lagi',
                    jenis: JenisTombol.tinta,
                    lebarPenuh: false,
                    paddingH: 20,
                    onPressed: _coba,
                  ),
                  _St.coba => const Tombol(
                    'Mencoba menyimpan lagi…',
                    nonaktif: true,
                    lebarPenuh: false,
                    paddingH: 20,
                    onPressed: null,
                  ),
                  _St.simpan => const Tombol(
                    'Periksa dan bukukan',
                    ke: 'WebCatat',
                    lebarPenuh: false,
                    paddingH: 20,
                    onPressed: null,
                  ),
                },
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Breadcrumb "Transaksi" (up) above h1 "Catat transaksi".
class _Judul extends StatelessWidget {
  const _Judul();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // An inline 14 px link on a 15 / 1.45 line: the 44 px target overhangs.
      MarginNegatif(
        atas: (44 - 15 * 1.45) / 2,
        bawah: (44 - 15 * 1.45) / 2,
        child: Tautan(
          ke: 'WebTransaksi',
          cara: Cara.naik,
          child: const Align(
            widthFactor: 1,
            heightFactor: 1,
            child: TautanTeks('Transaksi', ukuran: 14),
          ),
        ),
      ),
      const SizedBox(height: 2),
      Semantics(
        header: true,
        child: const Text(
          'Catat transaksi',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

/// Offline banner (role=alert).
class _PitaPutus extends StatelessWidget {
  const _PitaPutus({super.key, required this.n});
  final int n;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: c.bataLembut,
          shape: GarisBorder.penuh(c.bata, radius: 14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              spacing: 10,
              children: [
                PalakatIkon(Ikon.tanpaSambungan, warna: c.bata),
                const Flexible(
                  child: Text(
                    'Tidak ada sambungan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            Text(
              'Palakat bekerja hanya saat tersambung. Isian di bawah belum tersimpan, dan tetap ada selama layar ini terbuka.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            if (n > 1)
              Text(
                'Masih belum tersambung · percobaan ke-$n',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.bata,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "Mencoba menyimpan lagi…" card with the 1.6 s bar (role=status).
class _KartuCoba extends StatelessWidget {
  const _KartuCoba({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.permukaan,
          border: Border.all(color: c.garis),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            const Text(
              'Mencoba menyimpan lagi…',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const BatangIsi(lama: Duration(milliseconds: 1600)),
            Text(
              'Percobaan ulang tidak membuat draf kedua dan tidak membuat No. Bukti.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Tersambung lagi. Draf tersimpan." (role=status), rises in with `muncul`.
class _PitaTersimpan extends StatelessWidget {
  const _PitaTersimpan({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Gerak(
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}

/// The draft card: dashed `putus` until saved, then solid `tinta`. The line
/// colour animates 300 ms; the dash pattern and the badge line swap at once.
class _KartuDraf extends StatelessWidget {
  const _KartuDraf({required this.st});
  final _St st;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final simpan = st == _St.simpan;
    final gaya = simpan ? GayaGaris.penuh : GayaGaris.putus;
    final warna = simpan ? c.tinta : c.putus;
    final lencana = switch (st) {
      _St.simpan => 'Tersimpan',
      _St.coba => 'Mencoba menyimpan lagi…',
      _St.putus => 'Belum tersimpan',
    };
    final keterangan = TextStyle(fontSize: 13, color: c.tinta3);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: warna),
      duration: PalakatMotion.atau(context, const Duration(milliseconds: 300)),
      curve: Curves.ease,
      builder: (context, garis, child) => Container(
        padding: const EdgeInsets.all(18),
        decoration: ShapeDecoration(
          color: c.permukaan,
          shape: GarisBorder(
            warna: garis ?? warna,
            gaya: gaya,
            radius: BorderRadius.circular(16),
          ),
        ),
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: ShapeDecoration(
              shape: GarisBorder(
                warna: warna,
                gaya: gaya,
                radius: BorderRadius.circular(6),
              ),
            ),
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
            style: keterangan,
          ),
          Text('Belanja 5.04.01.00 Konsumsi rapat', style: keterangan),
        ],
      ),
    );
  }
}

/// Session ended: a white card centred in `main`; the side nav stays.
class _SesiBerakhir extends StatelessWidget {
  const _SesiBerakhir({
    required this.judul,
    required this.catatan,
    required this.bisaMasuk,
  });
  final String judul, catatan;
  final bool bisaMasuk;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    // `flex: 1` of a 100vh main: window height less main's 28 + 40 padding.
    // Below 860 nav and main are separate wrapped lines that share the spare
    // height; the shared narrow page gives the nav its half and keeps main at
    // its content height, so the box does not grow there.
    final tinggi = navSempit(context)
        ? 0.0
        : MediaQuery.sizeOf(context).height - 68;
    final tebal = TextStyle(fontWeight: FontWeight.w700, color: c.tinta);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: tinggi < 0 ? 0 : tinggi),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.jepit(24, 4, 40)),
              decoration: BoxDecoration(
                color: c.permukaan,
                border: Border.all(color: c.garis),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  const PalakatIkon(Ikon.sesiBerakhir, ukuran: 56),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          judul,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        catatan,
                        style: TextStyle(fontSize: 15, color: c.tinta2),
                      ),
                    ],
                  ),
                  DefaultTextStyle.merge(
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
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
                              TextSpan(
                                text: 'Tidak ikut tersimpan:',
                                style: tebal,
                              ),
                              const TextSpan(
                                text: ' isian yang belum tersimpan di perangkat ini.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (bisaMasuk)
                    const Tombol(
                      'Masuk lagi',
                      ke: 'WebMasuk',
                      cara: Cara.ganti,
                      paddingH: 20,
                      onPressed: null,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: ShapeDecoration(
                        shape: GarisBorder.putus(c.putus, radius: 14),
                      ),
                      child: const Text(
                        'Anda tidak lagi memegang wewenang Bendahara Jemaat Karunia. Riwayat tetap mencatat tindakan Anda. Bila ini keliru, yang dapat membantu adalah BPMJ Jemaat Karunia.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
