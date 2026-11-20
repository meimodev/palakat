import 'dart:async';

import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// Sample files, in the board's order (`N`).
const _contoh = [
  ('nota-sewa-sound.jpg', '1,2 MB'),
  ('kuitansi-cv-nada-prima.pdf', '340 KB'),
  ('tanda-terima.jpg', '880 KB'),
];

enum _St { unggah, gagal, lampir }

class _Berkas {
  _Berkas(this.n, this.u);
  final String n, u;
  _St st = _St.unggah;

  /// Bumped on "Coba lagi" so the progress bar restarts.
  int coba = 0;
}

class WebUnggahScreen extends StatefulWidget {
  const WebUnggahScreen({super.key});

  @override
  State<WebUnggahScreen> createState() => _WebUnggahState();
}

class _WebUnggahState extends State<WebUnggahScreen> {
  final _files = <_Berkas>[];
  bool _sudahGagal = false;
  final _timer = <Timer>{};

  @override
  void dispose() {
    for (final t in _timer) {
      t.cancel();
    }
    super.dispose();
  }

  /// Fakes the upload: 1500 ms, then attached or (once, with the tweak on)
  /// failed. The tweak is read when the upload starts, as on the board.
  void _kirim(_Berkas f, bool bolehGagal) {
    final gagal = bolehGagal && belumDipindah<bool>(false);
    late final Timer t;
    t = Timer(const Duration(milliseconds: 1500), () {
      _timer.remove(t);
      setState(() {
        final g = gagal && !_sudahGagal;
        if (g) _sudahGagal = true;
        f.st = g ? _St.gagal : _St.lampir;
      });
    });
    _timer.add(t);
  }

  void _tambah() {
    final i = _files.length;
    if (i >= _contoh.length) return;
    final f = _Berkas(_contoh[i].$1, _contoh[i].$2);
    setState(() => _files.add(f));
    _kirim(f, true);
  }

  void _cobaLagi(_Berkas f) {
    setState(() {
      f.st = _St.unggah;
      f.coba++;
    });
    _kirim(f, false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final lampir = _files.where((f) => f.st == _St.lampir).length;
    final penuh = _files.length >= _contoh.length;
    final kecil = TextStyle(fontSize: 14, color: c.tinta2);

    return HalamanWeb(
      layarKeuangan: true,
      nav: NavSamping(item: navKeuangan, aktif: 1),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarginNegatif(
              atas: 11.125,
              bawah: 11.125,
              child: Tautan(
                ke: Layar.dokumen,
                cara: Cara.naik,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Dokumen pendukung', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Unggah dokumen pendukung',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text('BKU-2026-0143 · Sewa sound system · Rp600.000', style: kecil),
          ],
        ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(
              dasar: 460,
              tumbuh: 999,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 32,
                    ),
                    decoration: ShapeDecoration(
                      shape: GarisBorder.putus(c.putus, radius: 16),
                    ),
                    child: Column(
                      children: [
                        PalakatIkon(Ikon.unggah, ukuran: 36, warna: c.tinta2),
                        const SizedBox(height: 10),
                        const Text(
                          'Tarik file ke sini',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Foto nota, tangkapan layar bukti transfer, atau PDF.',
                          textAlign: TextAlign.center,
                          style: kecil,
                        ),
                        if (!penuh) ...[
                          const SizedBox(height: 10),
                          Tombol(
                            'Pilih file',
                            onPressed: _tambah,
                            jenis: JenisTombol.tinta,
                            ukuran: UkuranTombol.ringkas,
                            lebarPenuh: false,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_files.isEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada file. Dokumen pendukung transaksi ini masih '
                      '“Wajib, belum ada”.',
                      style: kecil,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Drawn even with no files (an empty bordered strip), as
                  // on the board.
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: c.permukaan,
                      border: Border.all(color: c.garis),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < _files.length; i++)
                          Gerak(
                            Kerangka.muncul,
                            key: ValueKey(_files[i].n),
                            lama: const Duration(milliseconds: 300),
                            child: _BarisBerkas(
                              f: _files[i],
                              garisAtas: i > 0,
                              onCoba: () => _cobaLagi(_files[i]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Lentur(
              dasar: 382, // flex-basis 340 is the content box: + padding 20 and line 1 each side
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.permukaan,
                  border: Border.all(color: c.garis),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      container: true,
                      liveRegion: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Dokumen pendukung · '
                            '${lampir > 0 ? '$lampir file terlampir' : 'belum ada file terlampir'}',
                            style: kecil,
                          ),
                          Text(
                            lampir > 0
                                ? 'Diunggah, belum diverifikasi'
                                : 'Wajib, belum ada',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: c.bata,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Terlampir bukan terverifikasi. Tutup buku menunggu '
                      'Terverifikasi atau Dikecualikan.',
                      style: kecil,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'File yang gagal diunggah tidak pernah terbaca sebagai '
                      'terlampir. Coba lagi tidak membuat salinan ganda.',
                      style: kecil,
                    ),
                    if (lampir > 0) ...[
                      const SizedBox(height: 10),
                      Gerak(
                        Kerangka.muncul,
                        lama: const Duration(milliseconds: 300),
                        child: Tombol(
                          'Lanjut ke verifikasi',
                          onPressed: null,
                          ke: Layar.dokumen,
                          cara: Cara.naik,
                          ukuran: UkuranTombol.ringkas,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BarisBerkas extends StatelessWidget {
  const _BarisBerkas({
    required this.f,
    required this.garisAtas,
    required this.onCoba,
  });
  final _Berkas f;
  final bool garisAtas;
  final VoidCallback onCoba;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (teks, warna, berat) = switch (f.st) {
      _St.unggah => ('Sedang diunggah…', c.tinta2, FontWeight.w500),
      _St.gagal => (
        'Gagal diunggah · belum terlampir',
        c.bata,
        FontWeight.w700,
      ),
      _St.lampir => ('Terlampir', c.tinta, FontWeight.w600),
    };
    Widget bar(Color w, {double lebar = 1, bool kanan = false}) => Align(
      alignment: kanan ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: lebar,
        child: SizedBox(height: 2, child: ColoredBox(color: w)),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: garisAtas ? Border(top: BorderSide(color: c.garis)) : null,
      ),
      child: Row(
        children: [
          // Document thumbnail (illustration paper).
          Container(
            width: 44,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              color: PalakatIlustrasi.kertasNota,
              border: Border.all(color: c.garisTegas),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                bar(c.tinta),
                const SizedBox(height: 4),
                bar(c.putus),
                const SizedBox(height: 4),
                bar(c.putus, lebar: .7),
                const SizedBox(height: 4),
                bar(c.tinta, lebar: .5, kanan: true),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  f.n,
                  style: const TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Semantics(
                  container: true,
                  liveRegion: true,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '$teks '),
                        TextSpan(
                          text: '· ${f.u}',
                          style: TextStyle(
                            color: c.tinta3,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: warna,
                      fontWeight: berat,
                    ),
                  ),
                ),
                if (f.st == _St.unggah)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: BatangIsi(
                      key: ValueKey(f.coba),
                      lama: const Duration(milliseconds: 1500),
                    ),
                  ),
              ],
            ),
          ),
          if (f.st == _St.gagal) ...[
            const SizedBox(width: 14),
            Tombol(
              'Coba lagi',
              onPressed: onCoba,
              jenis: JenisTombol.garisBata,
              ukuran: UkuranTombol.kecil,
              paddingH: 14,
              lebarPenuh: false,
            ),
          ],
          if (f.st == _St.lampir) ...[
            const SizedBox(width: 14),
            Tautan(
              ke: Layar.lihatDokumen,
              param: {'id': belumDipindahId},
              child: const Align(
                widthFactor: 1,
                heightFactor: 1,
                child: TautanTeks('Lihat file', berat: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
