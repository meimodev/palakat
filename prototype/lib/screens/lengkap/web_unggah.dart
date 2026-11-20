import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../providers/clock.dart';
import '../../providers/keuangan/dokumen.dart';
import '../../widgets/penolakan.dart';
import 'kamera.dart' show unggahDokumen;

/// Sample file sizes, in the board's order (`N`); names come from today.
const _ukuran = ['1,2 MB', '340 KB', '880 KB'];

const _lamaUnggah = Duration(milliseconds: 1500);

enum _St { unggah, lampir }

class _Berkas {
  _Berkas(this.n, this.u);
  final String n, u;
  _St st = _St.unggah;

  /// Bumped on "Coba lagi" so the progress bar restarts.
  int coba = 0;
}

class WebUnggahScreen extends ConsumerStatefulWidget {
  const WebUnggahScreen({super.key});

  @override
  ConsumerState<WebUnggahScreen> createState() => _WebUnggahState();
}

class _WebUnggahState extends ConsumerState<WebUnggahScreen> {
  final _files = <_Berkas>[];
  final _timer = <Timer>{};
  Refusal? _pesan;

  @override
  void dispose() {
    for (final t in _timer) {
      t.cancel();
    }
    super.dispose();
  }

  /// The upload command is issued at once; the timer only shows progress
  /// (README 3.7). A refusal leaves the file out.
  Future<void> _kirim(_Berkas f, int halaman) async {
    final r = await unggahDokumen(ref, halaman);
    if (!mounted) return;
    if (r != null) {
      setState(() {
        _files.remove(f);
        _pesan = r;
      });
      return;
    }
    late final Timer t;
    void selesai() {
      _timer.remove(t);
      if (mounted) setState(() => f.st = _St.lampir);
    }

    t = Timer(_lamaUnggah, selesai); // tiruan: unggah
    _timer.add(t);
  }

  void _tambah() {
    final i = _files.length;
    if (i >= _ukuran.length) return;
    final jam = ref.read(clockProvider).now();
    final f = _Berkas(namaNota(jam, i + 1), _ukuran[i]);
    setState(() => _files.add(f));
    _kirim(f, i + 1);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final lampir = _files.where((f) => f.st == _St.lampir).length;
    final penuh = _files.length >= _ukuran.length;
    final b = ref.watch(dokumenTerpilihProvider);
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
            Text(
              '${b?.no ?? ''} · ${b?.transaksi.description ?? ''} · '
              '${b == null ? '' : rp(b.transaksi.total)}',
              style: kecil,
            ),
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
                  if (_pesan case final r?) ...[
                    const SizedBox(height: 16),
                    Penolakan(
                      tindakan: r.action,
                      sebab: r.because,
                      jalan: const [],
                      ukuranTeks: 14,
                    ),
                  ],
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
                              id: b?.id ?? '',
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
                                ? (b?.label ?? 'Diunggah, belum diverifikasi')
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
    required this.id,
  });
  final _Berkas f;
  final bool garisAtas;

  /// The transaction, for "Lihat file".
  final String id;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (teks, warna, berat) = switch (f.st) {
      _St.unggah => ('Sedang diunggah…', c.tinta2, FontWeight.w500),
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
          if (f.st == _St.lampir) ...[
            const SizedBox(width: 14),
            Tautan(
              ke: Layar.lihatDokumen,
              param: {'id': id},
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
