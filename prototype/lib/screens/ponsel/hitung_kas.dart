import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/kendali.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

const _mono = TextStyle(fontFamily: PalakatText.mono);
const _tanggal = '16/11/2026 11.30';

/// Board state `{ n, nol, petugas, dok, tersimpan }`; `screen` is the route.
class _Hitung extends ChangeNotifier {
  List<int>? n;
  bool nol = false, dok = false, tersimpan = false;
  List<String> petugas = [];
  bool _mati = false;

  void _ubah(VoidCallback f) {
    if (_mati) return;
    f();
    notifyListeners();
  }

  void ulang() => _ubah(() {
    n = null;
    nol = dok = tersimpan = false;
    petugas = [];
  });

  void lembar(List<int> sekarang, int i, int v) => _ubah(() {
    n = [...sekarang]..[i] = v;
    nol = false;
    tersimpan = false;
  });

  void kosong() => _ubah(() {
    n = List.filled(7, 0);
    nol = true;
    tersimpan = false;
  });

  void pilih(String o) => _ubah(() {
    petugas = petugas.contains(o)
        ? [...petugas.where((p) => p != o)]
        : [...petugas, o];
  });

  void lampirkan() => _ubah(() => dok = true);
  void keHitung() => _ubah(() => tersimpan = false);
  void simpan() => _ubah(() => tersimpan = true);

  @override
  void dispose() {
    _mati = true;
    super.dispose();
  }
}

class _Lingkup extends InheritedNotifier<_Hitung> {
  const _Lingkup({required _Hitung super.notifier, required super.child});
}

/// What `rv0()` derives from the state and the `contohTerisi` tweak.
class _Nilai {
  _Nilai(BuildContext context)
    : k = context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier! {
    n =
        k.n ??
        (context.tweak<bool>('HitungKas', 'contohTerisi')
                ? hitungKasTerisi
                : hitungKasKosong)
            .lembar;
    total = HitungKas(lembar: n, petugas: const []).jumlah;
    dihitung = total > 0 || k.nol;
    bisa = dihitung && k.petugas.isNotEmpty;
    selisih = hitungKasSaldoBuku - total;
  }

  final _Hitung k;
  late final List<int> n;
  late final int total, selisih;
  late final bool dihitung, bisa;

  String get hasil => dihitung ? rp(total) : kosong;
  String get alasan => !dihitung
      ? 'Isi hasil hitung, atau catat Rp0 bila kas memang kosong.'
      : 'Pilih petugas penghitung.';
}

class HitungKasKendali extends StatefulWidget {
  const HitungKasKendali({super.key, required this.child});
  final Widget child;
  @override
  State<HitungKasKendali> createState() => _HitungKasKendaliState();
}

class _HitungKasKendaliState extends State<HitungKasKendali> {
  final _k = _Hitung();
  int _generasi = 0;

  void _ulang() => setState(() {
    _k.ulang();
    _generasi++;
  });

  @override
  void initState() {
    super.initState();
    ulangPapan['HitungKas'] = _ulang;
  }

  @override
  void dispose() {
    if (ulangPapan['HitungKas'] == _ulang) ulangPapan.remove('HitungKas');
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayarPonsel(
    jabatanKosong: true,
    child: _Lingkup(
      notifier: _k,
      child: GenerasiPapan(generasi: _generasi, child: widget.child),
    ),
  );
}

class HitungKasScreen extends StatelessWidget {
  const HitungKasScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.warna.kertas,
    child: anak == 'banding' ? const _Banding() : const _Hitungan(),
  );
}

/// The white footer bar: padding 12 20 22, top 1 `garis`.
class _Kaki extends StatelessWidget {
  const _Kaki({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: child,
    );
  }
}

/// Scroll body: padding 8 20 20, gap 18.
class _Isi extends StatelessWidget {
  const _Isi({required this.anak});
  final List<Widget> anak;
  @override
  Widget build(BuildContext context) => Expanded(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            anak[i],
          ],
        ],
      ),
    ),
  );
}

/// A dashed full-width button (Kas kosong, Lampirkan).
class _TombolPutus extends StatelessWidget {
  const _TombolPutus(
    this.label, {
    required this.onTap,
    required this.tinggi,
    required this.warna,
    this.berat = FontWeight.w700,
  });
  final String label;
  final VoidCallback onTap;
  final double tinggi;
  final Color warna;
  final FontWeight berat;

  @override
  Widget build(BuildContext context) => Tekan(
    onTap: onTap,
    radius: 12,
    child: Container(
      constraints: BoxConstraints(minHeight: tinggi),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(context.warna.putus, radius: 12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: berat, color: warna),
      ),
    ),
  );
}

/// Count view (`/HitungKas`), `pudar .2s` on mount.
class _Hitungan extends StatelessWidget {
  const _Hitungan();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final v = _Nilai(context);
    final k = v.k;
    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Hitung kas',
            anakJudul: hitungKasJudul,
            kembaliKe: 'TutupBuku',
            labelKembali: 'Kembali ke Bulan',
          ),
          _Isi(
            anak: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hasil hitung kas',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  Text(
                    v.hasil,
                    style: _mono.copyWith(
                      fontSize: 38,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1,
                      height: 1.15,
                      color: v.dihitung ? c.tinta : c.tinta3,
                    ),
                  ),
                  Text(
                    v.dihitung
                        ? (v.total == 0
                              ? 'Dihitung: Rp0'
                              : 'Dihitung per pecahan')
                        : hitungKasKosongTeks,
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
              Kartu(
                padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
                child: Column(
                  children: [
                    for (var i = 0; i < 7; i++)
                      _BarisPecahan(
                        pecahan: HitungKas.pecahan[i],
                        lembar: v.n[i],
                        garisAtas: i > 0,
                        onUbah: (b) => k.lembar(v.n, i, b),
                      ),
                  ],
                ),
              ),
              _TombolPutus(
                'Kas kosong: catat Rp0',
                onTap: k.kosong,
                tinggi: 48,
                warna: c.tinta2,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Petugas penghitung ',
                      children: [
                        TextSpan(
                          text: '· paling sedikit satu',
                          style: TextStyle(color: c.tinta3),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final o in hitungKasPetugas)
                          ChipSatu(
                            teks: o,
                            dipilih: k.petugas.contains(o),
                            onTap: () => k.pilih(o),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dokumen pendukung',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  const SizedBox(height: 8),
                  if (!k.dok)
                    _TombolPutus(
                      'Lampirkan lembar hitung kas',
                      onTap: k.lampirkan,
                      tinggi: 52,
                      warna: c.laut,
                      berat: FontWeight.w600,
                    )
                  else
                    Gerak(
                      Kerangka.muncul,
                      lama: const Duration(milliseconds: 280),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: ShapeDecoration(
                          color: c.permukaan,
                          shape: GarisBorder.penuh(
                            c.garisTegas,
                            tebal: 1,
                            radius: 12,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '$hitungKasFile · Terlampir',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Diunggah, belum diverifikasi',
                              style: TextStyle(fontSize: 13, color: c.tinta2),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          _Kaki(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!v.bisa) ...[
                  Semantics(
                    container: true,
                    liveRegion: true,
                    child: Text(
                      v.alasan,
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                TekanAria(
                  // TombolBersyarat: re-checks on press.
                  onTap: () {
                    if (_Nilai(context).bisa) {
                      GoRouter.of(context).push('/HitungKas/banding');
                    }
                  },
                  aktif: v.bisa,
                  petunjuk: v.bisa ? null : v.alasan,
                  radius: 14,
                  child: RupaTombol(
                    label: 'Bandingkan dengan Saldo buku',
                    isi: v.bisa ? c.laut : c.garis,
                    warnaTeks: v.bisa ? c.diLaut : c.tinta3,
                    radius: 14,
                    tinggi: 52,
                    paddingH: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Comparison view (`/HitungKas/banding`); the route plays `masuk`.
class _Banding extends StatefulWidget {
  const _Banding();
  @override
  State<_Banding> createState() => _BandingState();
}

class _BandingState extends State<_Banding> {
  @override
  void initState() {
    super.initState();
    // Opened directly while the count cannot be compared: back to the count.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_Nilai(context).bisa) context.kembaliKe('/HitungKas');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final v = _Nilai(context);
    final k = v.k;
    const muncul = Duration(milliseconds: 300);
    Widget baris(String a, String b) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(a, style: TextStyle(color: c.tinta2)),
        ),
        Text(b, style: _mono.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) k.keHitung();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Kas · hitung kas dan buku',
            onKembali: () => context.kembaliKe('/HitungKas'),
          ),
          _Isi(
            anak: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: c.permukaan,
                  shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 16),
                ),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(fontSize: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      baris('Saldo buku', rp(hitungKasSaldoBuku)),
                      const SizedBox(height: 10),
                      Gerak(
                        Kerangka.muncul,
                        lama: muncul,
                        tunda: const Duration(milliseconds: 150),
                        child: baris('Hasil hitung kas', v.hasil),
                      ),
                      const SizedBox(height: 10),
                      Gerak(
                        Kerangka.muncul,
                        lama: muncul,
                        tunda: const Duration(milliseconds: 350),
                        child: Container(
                          padding: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: c.tinta, width: 1.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Selisih belum dijelaskan',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                rp(v.selisih.abs()),
                                style: _mono.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: v.selisih == 0 ? c.laut : c.bata,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (v.selisih != 0)
                Gerak(
                  Kerangka.muncul,
                  lama: muncul,
                  tunda: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: v.selisih > 0
                                  ? 'Uang di kas kurang ${rp(v.selisih)} dari buku.'
                                  : 'Uang di kas lebih ${rp(-v.selisih)} dari buku.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  ' Hasil hitung disimpan apa adanya; tidak '
                                  'ada tindakan untuk menyamakan angka.',
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Selisih hilang hanya dengan mencatat transaksi yang '
                        'terlewat, atau menghitung lagi. Bila masih ada saat '
                        'akhir bulan, selisih menjadi hambatan tutup buku.',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                      const SizedBox(height: 10),
                      // `<a>` is content-box: min-height 48 plus the 1.5 line.
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 51),
                        child: const Tombol(
                          'Catat transaksi yang terlewat',
                          onPressed: null,
                          jenis: JenisTombol.kedua,
                          ukuran: UkuranTombol.sedang,
                          ke: 'Main',
                          cara: Cara.ganti,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Tombol(
                        'Hitung lagi',
                        onPressed: () => context.kembaliKe('/HitungKas'),
                        jenis: JenisTombol.kedua,
                        ukuran: UkuranTombol.sedang,
                      ),
                    ],
                  ),
                )
              else
                Gerak(
                  Kerangka.muncul,
                  lama: muncul,
                  tunda: const Duration(milliseconds: 500),
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.lautLembut,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: const Text(
                      'Hasil hitung kas sama dengan Saldo buku.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (k.tersimpan)
                Gerak(
                  Kerangka.muncul,
                  key: const ValueKey('tersimpan'),
                  lama: muncul,
                  child: Row(
                    children: [
                      const LingkarSelesai(ukuran: 56),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Semantics(
                          container: true,
                          liveRegion: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hitung kas tersimpan',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Dihitung oleh ${k.petugas.join(' dan ')} · $_tanggal',
                                style: TextStyle(fontSize: 14, color: c.tinta2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          _Kaki(
            child: k.tersimpan
                ? ConstrainedBox(
                    // `<a>`: content-box, 52 plus the 1.5 line.
                    constraints: const BoxConstraints(minHeight: 55),
                    child: const Tombol(
                      'Kembali ke Bulan',
                      onPressed: null,
                      jenis: JenisTombol.kedua,
                      ke: 'TutupBuku',
                      cara: Cara.naik,
                    ),
                  )
                : Tombol('Simpan hitung kas', onPressed: k.simpan),
          ),
        ],
      ),
    );
  }
}

/// PenghitungPecahan as the board lays it out: the row is a CSS flex row, so
/// when the product (`flex: 1`, never broken) needs more than its share, the
/// denomination (basis 92) and the count (basis 36) shrink in proportion to
/// their basis, down to their own text width.
class _BarisPecahan extends StatelessWidget {
  const _BarisPecahan({
    required this.pecahan,
    required this.lembar,
    required this.onUbah,
    required this.garisAtas,
  });

  final int pecahan, lembar;
  final ValueChanged<int> onUbah;
  final bool garisAtas;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final gLabel = dasar.merge(
      _mono.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
    );
    final gHitung = dasar.merge(
      _mono.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
    );
    final gProduk = dasar.merge(
      _mono.copyWith(fontSize: 14, color: lembar > 0 ? c.tinta : c.tinta3),
    );
    final label = titik('$pecahan');
    final produk = lembar > 0 ? rp(lembar * pecahan) : kosong;
    double lebar(String s, TextStyle g) {
      final t = TextPainter(
        text: TextSpan(text: s, style: g),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final w = t.width;
      t.dispose();
      return w;
    }

    return Container(
      // content-box: min-height 56 plus the 1 px top rule.
      constraints: BoxConstraints(minHeight: garisAtas ? 57 : 56),
      decoration: BoxDecoration(
        border: garisAtas ? Border(top: BorderSide(color: c.garis)) : null,
      ),
      child: LayoutBuilder(
        builder: (context, k) {
          var wLabel = 92.0, wHitung = 36.0;
          final butuh =
              wLabel + wHitung + 44 * 2 + 8 * 4 + lebar(produk, gProduk);
          final kurang = butuh - k.maxWidth;
          if (kurang > 0) {
            wLabel = math.max(lebar(label, gLabel), 92 - kurang * 92 / 128);
            wHitung = math.max(
              lebar('$lembar', gHitung),
              36 - kurang * 36 / 128,
            );
          }
          return Row(
            children: [
              SizedBox(
                width: wLabel,
                child: Text(label, style: gLabel),
              ),
              const SizedBox(width: 8),
              _TombolHitung(
                tanda: '−',
                label: 'Kurangi satu lembar ${rp(pecahan)}',
                gelap: false,
                onTap: () => onUbah(lembar > 0 ? lembar - 1 : 0),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: wHitung,
                child: Text(
                  '$lembar',
                  textAlign: TextAlign.center,
                  style: gHitung,
                ),
              ),
              const SizedBox(width: 8),
              _TombolHitung(
                tanda: '+',
                label: 'Tambah satu lembar ${rp(pecahan)}',
                gelap: true,
                onTap: () => onUbah(lembar + 1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  produk,
                  textAlign: TextAlign.right,
                  softWrap: false,
                  style: gProduk,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// − (1.5 `garisTegas` on `permukaan`) and + (`tinta` fill): 44 × 44,
/// radius 12, sign 22/600, line height 1.
class _TombolHitung extends StatelessWidget {
  const _TombolHitung({
    required this.tanda,
    required this.label,
    required this.gelap,
    required this.onTap,
  });

  final String tanda, label;
  final bool gelap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      label: label,
      radius: 12,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: gelap ? c.tinta : c.permukaan,
          shape: gelap
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              : GarisBorder.penuh(c.garisTegas, radius: 12),
        ),
        child: Text(
          tanda,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1,
            color: gelap ? c.permukaan : c.tinta,
          ),
        ),
      ),
    );
  }
}
