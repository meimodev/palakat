import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

enum _St { antre, aktif, kembali, dicabut }

const _cekTeks = [
  'Nama yang ditunjuk sama dengan nama di akun',
  'Surat ditandatangani oleh BPMJ yang berwenang',
  'Tanggal dan nomor surat terbaca',
];

const _muncul = Duration(milliseconds: 300);

/// Web · Verifikasi wewenang, the internal page of the Petugas verifikasi
/// (spec 08-cari.md, WebVerifikasi).
class WebVerifikasiScreen extends StatefulWidget {
  const WebVerifikasiScreen({super.key});

  @override
  State<WebVerifikasiScreen> createState() => _WebVerifikasiScreenState();
}

class _WebVerifikasiScreenState extends State<WebVerifikasiScreen> {
  /// The return form and the emergency section share this one value.
  final _alasan = TextEditingController();
  _St _st = _St.antre;
  final _cek = [false, false, false];
  bool _form = false;
  String _alasanAkhir = '';

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  bool get _lengkap => _cek.every((c) => c);
  bool get _ok => _alasan.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;

    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Verifikasi wewenang',
            style: PalakatText.judulHalaman.copyWith(
              color: c.tinta,
              height: 1.45,
            ),
          ),
        ),
        Text(
          'Halaman internal untuk Petugas verifikasi, di luar aplikasi '
          'Bendahara. Dari sini tidak ada yang dapat dicatat, dibukukan atau '
          'ditutup.',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ],
    );

    final (stTeks, stIsi, stTeksW, stGaris) = switch (_st) {
      _St.antre => (
        'Menunggu verifikasi wewenang',
        null,
        c.tinta2,
        GarisBorder.putus(c.putus, radius: 6),
      ),
      _St.aktif => (
        'Wewenang Bendahara aktif',
        c.laut,
        c.diLaut,
        GarisBorder.penuh(c.laut, radius: 6),
      ),
      _St.kembali => (
        'Dikembalikan',
        c.permukaan,
        c.tinta2,
        GarisBorder.penuh(c.tinta3, radius: 6),
      ),
      _St.dicabut => (
        'Wewenang dicabut',
        c.tinta,
        c.permukaan,
        GarisBorder.penuh(c.tinta, radius: 6),
      ),
    };

    final antrean = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: ShapeDecoration(
          color: c.permukaan,
          shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              color: c.lautLembut,
              // box-shadow: inset 3px 0 0 laut — drawn over, no layout shift.
              foregroundDecoration: BoxDecoration(
                border: Border(left: BorderSide(color: c.laut, width: 3)),
              ),
              child: _BarisAntre(
                nama: 'Jemaat Karunia',
                lencana: stTeks,
                isi: stIsi,
                warnaTeks: stTeksW,
                garis: stGaris,
                perihal: 'Penunjukan Bendahara · Meiske Lumentut',
                dikirim: 'Dikirim 14/09/2026 15.20',
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.garis)),
              ),
              child: _BarisAntre(
                nama: 'Jemaat Contoh Dua',
                lencana: 'Menunggu verifikasi wewenang',
                isi: null,
                warnaTeks: c.tinta2,
                garis: GarisBorder.putus(c.putus, radius: 6),
                perihal: 'Serah terima Bendahara · [NAMA]',
                dikirim: 'Dikirim 13/09/2026 09.05',
              ),
            ),
          ],
        ),
      ),
    );

    final fakta = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (l, v)) in const [
            ('Yang ditunjuk', 'Meiske Lumentut · meiske@contoh.id'),
            (
              'Yang menunjuk',
              'BPMJ Jemaat Karunia · Pdt. Lidya Rondonuwu, Ketua',
            ),
            ('Surat penunjukan', 'SK-BPMJ-04-2026.pdf · 2 halaman'),
          ].indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: i > 0 ? Border(top: BorderSide(color: c.garis)) : null,
              ),
              // Both sides flex-shrink as CSS does: on a narrow window the
              // label wraps too, not only the value.
              child: LayoutBuilder(
                builder: (context, k) {
                  final dasar = DefaultTextStyle.of(context).style;
                  final gl = dasar.copyWith(fontSize: 14, color: c.tinta2);
                  final gv = dasar.copyWith(fontWeight: FontWeight.w600);
                  final skala = MediaQuery.textScalerOf(context);
                  final (a, aMin) = _ukur(l, gl, skala);
                  final (b, bMin) = _ukur(v, gv, skala);
                  final (wa, wb) = _susut(a, aMin, b, bMin, k.maxWidth, 16);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: wa,
                        child: Text(l, style: gl),
                      ),
                      SizedBox(
                        width: wb,
                        child: Text(v, textAlign: TextAlign.right, style: gv),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );

    final surat = Container(
      // min-height 120 on a content-box div, plus the 1.5 lines.
      constraints: const BoxConstraints(minHeight: 123),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(c.putus, radius: 14),
      ),
      child: Text(
        '[Isi surat penunjukan]',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
    );

    Widget label(String teks) => ExcludeSemantics(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$teks '),
            TextSpan(
              text: '· wajib',
              style: TextStyle(color: c.tinta, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
    );

    Widget isian(String teks) => IsianTeks(
      gaya: _tanpaJarakHuruf,
      controller: _alasan,
      labelSemantik: '$teks · wajib',
      baris: 2,
      minTinggi: 0,
      onChanged: (_) => setState(() {}),
    );

    Widget bersyarat(
      String teks, {
      required bool siap,
      required String sebab,
      required JenisTombol warna,
      required VoidCallback onPressed,
    }) => IntrinsicWidth(
      child: TombolBersyarat(
        label: teks,
        tindakan: teks,
        alasan: siap ? '' : sebab,
        sudahMulai: false,
        warnaSiap: warna,
        teksBelumRedup: true,
        tinggi: 46,
        radius: 12,
        paddingH: 20,
        onPressed: onPressed,
      ),
    );

    Widget kedua(String teks, VoidCallback onPressed) => Tombol(
      teks,
      onPressed: onPressed,
      jenis: JenisTombol.kedua,
      ukuran: UkuranTombol.ringkas,
      lebarPenuh: false,
    );

    const sebabAlasan = 'Alasan belum diisi';

    final kanan = <Widget>[
      fakta,
      surat,
      if (_st == _St.antre) ...[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Yang diperiksa',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            for (var i = 0; i < _cek.length; i++) ...[
              const SizedBox(height: 4),
              _BarisCentang(
                teks: _cekTeks[i],
                nilai: _cek[i],
                onUbah: () => setState(() => _cek[i] = !_cek[i]),
              ),
            ],
          ],
        ),
        if (_form)
          Gerak(
            Kerangka.muncul,
            key: const ValueKey('form'),
            lama: _muncul,
            child: Kartu(
              status: GarisStatus.dibukukan,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  label('Alasan dikembalikan'),
                  const SizedBox(height: 10),
                  isian('Alasan dikembalikan'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      bersyarat(
                        'Kembalikan ke BPMJ',
                        siap: _ok,
                        sebab: sebabAlasan,
                        warna: JenisTombol.tinta,
                        onPressed: () => setState(() {
                          _st = _St.kembali;
                          _alasanAkhir = _alasan.text.trim();
                          _form = false;
                        }),
                      ),
                      kedua('Kembali', () => setState(() => _form = false)),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            key: const ValueKey('aksi'),
            spacing: 8,
            runSpacing: 8,
            children: [
              bersyarat(
                'Verifikasi dan aktifkan wewenang',
                siap: _lengkap,
                sebab: 'Ketiga pemeriksaan belum dicentang',
                warna: JenisTombol.utama,
                onPressed: () => setState(() {
                  _st = _St.aktif;
                  _alasan.clear();
                }),
              ),
              kedua(
                'Kembalikan dengan alasan',
                () => setState(() {
                  _form = true;
                  _alasan.clear();
                }),
              ),
            ],
          ),
      ],
      if (_st == _St.aktif) ...[
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('aktif'),
          lama: _muncul,
          child: Kartu(
            status: GarisStatus.terpilih,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Wewenang Bendahara aktif',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Meiske Lumentut · Jemaat Karunia · diverifikasi oleh '
                  'Petugas verifikasi, 15/09/2026 10.15 · tercatat di Riwayat '
                  'aktivitas Jemaat.',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 14),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.garis)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: const Text(
                  'Keadaan darurat',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mencabut wewenang berlaku saat itu juga, mengakhiri semua '
                'sesi, dan dapat membuat Jemaat tanpa Bendahara aktif sampai '
                'BPMJ menunjuk yang baru.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              const SizedBox(height: 8),
              label('Alasan pencabutan'),
              const SizedBox(height: 8),
              isian('Alasan pencabutan'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: bersyarat(
                  'Cabut wewenang',
                  siap: _ok,
                  sebab: sebabAlasan,
                  warna: JenisTombol.tinta,
                  onPressed: () => setState(() {
                    _st = _St.dicabut;
                    _alasanAkhir = _alasan.text.trim();
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
      if (_st == _St.kembali)
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('kembali'),
          lama: _muncul,
          child: Kartu(
            status: GarisStatus.terpilih,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Dikembalikan ke BPMJ',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Alasan: $_alasanAkhir',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
                Text(
                  'Meiske Lumentut tetap masuk tanpa wewenang keuangan dan '
                  'melihat “Menunggu verifikasi wewenang” beserta alasannya.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
        ),
      if (_st == _St.dicabut)
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('dicabut'),
          lama: _muncul,
          child: Kartu(
            status: GarisStatus.ditutup,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Wewenang dicabut · Belum ada Bendahara aktif di Jemaat '
                  'Karunia',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: c.permukaan,
                  ),
                ),
                Text(
                  'Semua sesi Meiske Lumentut diakhiri. Data Jemaat hanya '
                  'dapat dilihat. Alasan: $_alasanAkhir',
                  style: TextStyle(fontSize: 14, color: c.diTinta),
                ),
              ],
            ),
          ),
        ),
    ];

    return HalamanWeb(
      nav: const NavSamping(
        item: navVerifikasi,
        aktif: 0,
        pengguna: PenggunaNav(
          tebal: 'Petugas verifikasi',
          baris2: 'Tim Palakat · halaman internal',
        ),
      ),
      isi: [
        judul,
        BarisLentur(
          jarak: 28,
          anak: [
            Lentur(dasar: 322, child: antrean),
            Lentur(
              dasar: 520,
              tumbuh: 999,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < kanan.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    kanan[i],
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A queue row: the name and the badge share one flex line (gap 16) and both
/// shrink as CSS does (in proportion to their widths, never below their
/// longest word), then the subject (14) and the sent time (13 `tinta3`).
class _BarisAntre extends StatelessWidget {
  const _BarisAntre({
    required this.nama,
    required this.lencana,
    required this.isi,
    required this.warnaTeks,
    required this.garis,
    required this.perihal,
    required this.dikirim,
  });

  final String nama, lencana, perihal, dikirim;
  final Color? isi;
  final Color warnaTeks;
  final GarisBorder garis;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final gNama = dasar.copyWith(fontWeight: FontWeight.w700);
    final gLencana = dasar.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: warnaTeks,
    );
    final skala = MediaQuery.textScalerOf(context);
    // Badge padding 9 + line 1.5, each side.
    const tepi = 21.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, k) {
            final (a, aMin) = _ukur(nama, gNama, skala);
            final (b0, bMin0) = _ukur(lencana, gLencana, skala);
            final (wa, wb) = _susut(
              a,
              aMin,
              b0 + tepi,
              bMin0 + tepi,
              k.maxWidth,
              16,
            );
            return Row(
              children: [
                SizedBox(
                  width: wa,
                  child: Text(nama, style: gNama),
                ),
                const Spacer(),
                SizedBox(
                  width: wb,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: ShapeDecoration(color: isi, shape: garis),
                    child: Text(lencana, style: gLencana),
                  ),
                ),
              ],
            );
          },
        ),
        Text(perihal, style: const TextStyle(fontSize: 14)),
        Text(dikirim, style: TextStyle(fontSize: 13, color: c.tinta3)),
      ],
    );
  }
}

/// (max-content, min-content) widths of [teks], rounded up.
(double, double) _ukur(String teks, TextStyle gaya, TextScaler skala) {
  double lebar(String s) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: gaya),
      textDirection: TextDirection.ltr,
      textScaler: skala,
    )..layout();
    final w = tp.width.ceilToDouble();
    tp.dispose();
    return w;
  }

  return (lebar(teks), teks.split(' ').map(lebar).reduce(math.max));
}

/// CSS `flex-shrink: 1` for two items of widths [a] and [b] in [w] with [gap].
(double, double) _susut(
  double a,
  double aMin,
  double b,
  double bMin,
  double w,
  double gap,
) {
  final lebih = a + b + gap - w;
  if (lebih <= 0) return (a, b);
  var x = a - lebih * a / (a + b);
  var y = b - lebih * b / (a + b);
  if (x < aMin) {
    x = aMin;
    y = w - gap - x;
  } else if (y < bMin) {
    y = bMin;
    x = w - gap - y;
  }
  return (math.max(0, x), math.max(0, y));
}

/// `<label>` wrapping a native 22 × 22 checkbox (`accent-color` laut) and
/// its text: gap 12, centred, min height 44, the whole row pressable.
class _BarisCentang extends StatelessWidget {
  const _BarisCentang({
    required this.teks,
    required this.nilai,
    required this.onUbah,
  });

  final String teks;
  final bool nilai;
  final VoidCallback onUbah;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onUbah,
      tercentang: nilai,
      radius: 4,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 22,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: nilai ? c.laut : c.permukaan,
                shape: nilai
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      )
                    : GarisBorder.penuh(c.garisTegas, radius: 4),
              ),
              child: nilai
                  ? Center(
                      child: PalakatIkon(
                        Ikon.centang,
                        ukuran: 22,
                        warna: c.diLaut,
                        tebal: 3.6,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(teks)),
        ],
      ),
    );
  }
}

/// TextField takes the theme's M3 letter spacing 0.5 unless the style sets
/// one; the boards' inputs inherit 'normal' (0).
const _tanpaJarakHuruf = TextStyle(letterSpacing: 0);
