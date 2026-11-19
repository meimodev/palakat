import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/isian_jumlah.dart';
import '../../widgets/kecil.dart';
import '../../widgets/pemilih_mata_anggaran.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// The board's `CFG` per jenis.
typedef _Jenis = ({
  String n,
  String pohon,
  String akun,
  String per,
  String pihak,
  int tanda,
});

const Map<String, _Jenis> _cfg = {
  'pendapatan': (
    n: 'Pendapatan',
    pohon: 'Pendapatan',
    akun: 'Kas/Bank',
    per: 'Masuk ke peruntukan',
    pihak: 'Diterima dari (boleh tanpa nama)',
    tanda: 1,
  ),
  'belanja': (
    n: 'Belanja',
    pohon: 'Belanja',
    akun: 'Kas/Bank',
    per: 'Diambil dari peruntukan',
    pihak: 'Dibayar kepada',
    tanda: -1,
  ),
  'pindah': (
    n: 'Pindah antar Kas/Bank',
    pohon: '',
    akun: 'Dari Kas/Bank',
    per: '',
    pihak: '',
    tanda: 1,
  ),
};

const _akun = [
  (nilai: 'kas', teks: 'Kas'),
  (nilai: 'bni', teks: 'Bank BNI ··4821'),
  (nilai: 'bsg', teks: 'Bank SulutGo ··1107'),
];

List<({String nilai, String teks})> _sama(List<String> l) => [
  for (final v in l) (nilai: v, teks: v),
];

final _peruntukan = _sama(['Umum Jemaat', 'Diakonia', 'Pembangunan']);
final _lingkup = _sama(['Jemaat', 'Kolom 3', 'BIPRA Pemuda', 'Panitia Natal']);

const Map<String, List<BarisMataAnggaran>> _ma = {
  'Belanja': [
    BarisMataAnggaran('5.00.00.00', 'BELANJA OPERASIONAL', grup: true),
    BarisMataAnggaran('5.01.02.00', 'Listrik, air dan telepon'),
    BarisMataAnggaran('5.02.01.00', 'Alat tulis dan fotokopi'),
    BarisMataAnggaran('5.03.03.00', 'Biaya administrasi bank'),
    BarisMataAnggaran('4.00.00.00', 'BELANJA PELAYANAN', grup: true),
    BarisMataAnggaran('4.03.03.00', 'Diakonia duka'),
  ],
  'Pendapatan': [
    BarisMataAnggaran('1.3.53.00.00', 'PERSEMBAHAN', grup: true),
    BarisMataAnggaran('1.3.53.07.00', 'Persembahan Ibadah Minggu'),
    BarisMataAnggaran('1.3.53.09.00', 'Persembahan syukur'),
    BarisMataAnggaran('1.4.10.00.00', 'SUMBANGAN', grup: true),
    BarisMataAnggaran('1.4.10.02.00', 'Sumbangan donatur'),
  ],
};

const _tautan = [
  (teks: 'Bagi ke beberapa Mata Anggaran', ke: 'WebBagi'),
  (teks: 'Persembahan', ke: 'WebPersembahan'),
  (teks: 'Alih peruntukan', ke: 'WebAlihPeruntukan'),
  (teks: 'Dari foto nota', ke: 'WebAIFoto'),
  (teks: 'Ganti catatan persetujuan', ke: 'WebPersetujuan'),
  (teks: 'Tanggal transaksi', ke: 'WebTanggal'),
  (teks: 'Usulan Mata Anggaran', ke: 'WebAIMataAnggaran'),
  (teks: 'Dari kalimat', ke: 'WebBantuanAI'),
];

const _mono = TextStyle(
  fontFamily: PalakatText.mono,
  fontFeatures: [FontFeature.tabularFigures()],
);

/// One checklist line: met, unmet or "info" (never counted).
enum _Cek { ok, gagal, info }

/// Web · Catat transaksi (spec 08-cari.md, WebCatat).
class WebCatatScreen extends StatefulWidget {
  const WebCatatScreen({super.key});

  @override
  State<WebCatatScreen> createState() => _WebCatatScreenState();
}

class _WebCatatScreenState extends State<WebCatatScreen> {
  final _jmC = TextEditingController();
  final _pihakC = TextEditingController();
  final _urC = TextEditingController();
  final _cariC = TextEditingController();

  String _jenis = 'belanja';
  String _jm = '';
  String? _akunId, _ke, _per, _ling, _maKode;
  bool _dok = false, _posted = false;

  @override
  void dispose() {
    for (final c in [_jmC, _pihakC, _urC, _cariC]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Every board handler but `onCari`, `onPihak` and `onUr` does nothing once posted.
  void _ubah(VoidCallback f) {
    if (!_posted) setState(f);
  }

  String _nama(String? id) => _akun
      .firstWhere((a) => a.nilai == id, orElse: () => (nilai: '', teks: ''))
      .teks;

  void _lagi() {
    for (final c in [_jmC, _pihakC, _urC, _cariC]) {
      c.clear();
    }
    setState(() {
      _jm = '';
      _akunId = _ke = _per = _ling = _maKode = null;
      _dok = false;
      _posted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final l = _cfg[_jenis]!;
    final pindah = _jenis == 'pindah';
    final j = int.tryParse(_jm) ?? 0;

    final cek = <(_Cek, String)>[
      j > 0 ? (_Cek.ok, 'Jumlah ${rp(j)}') : (_Cek.gagal, 'Jumlah belum diisi'),
      if (pindah) ...[
        _akunId != null && _ke != null && _akunId != _ke
            ? (_Cek.ok, 'Dari ${_nama(_akunId)} ke ${_nama(_ke)}')
            : (
                _Cek.gagal,
                'Kas/Bank asal dan tujuan belum dipilih, dan harus berbeda',
              ),
        (_Cek.ok, 'Bukan Pendapatan dan bukan Belanja'),
      ] else ...[
        _akunId != null
            ? (_Cek.ok, 'Kas/Bank: ${_nama(_akunId)}')
            : (_Cek.gagal, 'Kas/Bank belum dipilih'),
        _per != null
            ? (_Cek.ok, '${l.per}: $_per')
            : (_Cek.gagal, 'Peruntukan belum dipilih'),
        _ling != null
            ? (_Cek.ok, 'Lingkup: $_ling')
            : (_Cek.gagal, 'Lingkup belum dipilih'),
        _maKode != null
            ? (_Cek.ok, 'Mata Anggaran sudah dipilih')
            : (
                _Cek.gagal,
                'Mata Anggaran belum dipilih · tetap bisa disimpan sebagai draf',
              ),
        (_Cek.ok, 'Persetujuan: tidak diperlukan (aturan: transaksi rutin)'),
      ],
      _dok
          ? (_Cek.ok, 'Dokumen pendukung: diunggah, belum diverifikasi')
          : (
              _Cek.info,
              'Dokumen pendukung: wajib, belum ada · menjadi hambatan tutup buku',
            ),
    ];
    final gagalN = cek.where((x) => x.$1 == _Cek.gagal).length;
    final alasan = gagalN > 0 ? '$gagalN syarat belum terpenuhi.' : '';

    final pihak = _pihakC.text, ur = _urC.text;
    final ringkas = pindah
        ? 'Dari ${_akunId == null ? '…' : _nama(_akunId)} '
              'ke ${_ke == null ? '…' : _nama(_ke)}'
        : (ur.isNotEmpty ? ur : (pihak.isNotEmpty ? pihak : l.n));

    // ---- main column ----------------------------------------------------
    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // An inline <a> on a 15 × 1.45 line: the 44 px target overlaps.
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
          child: Text(
            'Catat transaksi',
            style: PalakatText.judulHalaman.copyWith(
              color: c.tinta,
              height: 1.45,
            ),
          ),
        ),
      ],
    );

    final deret = DeretTautan(
      web: true,
      anak: [
        for (final t in _tautan)
          Tautan(
            ke: t.ke,
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              child: TautanTeks(t.teks),
            ),
          ),
      ],
    );

    final jenis = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final k in const ['pendapatan', 'belanja', 'pindah'])
          ChipSatu(
            teks: _cfg[k]!.n,
            dipilih: _jenis == k,
            onTap: () => _ubah(() {
              _jenis = k;
              _maKode = null;
              _ke = null;
              _cariC.clear();
            }),
          ),
      ],
    );

    // ---- form -----------------------------------------------------------
    final jumlah = IsianJumlah(
      label: 'Jumlah (Rp)',
      controller: _jmC,
      hanyaBaca: _posted,
      ukuran: UkuranJumlah.lebar,
      lebarMaks: 420,
      onChanged: (v) => _ubah(() => _jm = hanyaAngka(v, max: 12)),
    );

    final kisi = KisiOtomatis(
      minLebar: 260,
      jarak: 18,
      anak: [
        ChipPilihan<String>(
          label: l.akun,
          pilihan: _akun,
          terpilih: _akunId,
          onPilih: (v) => _ubah(() => _akunId = v),
        ),
        if (pindah)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChipPilihan<String>(
                label: 'Ke Kas/Bank',
                pilihan: _akun,
                terpilih: _ke,
                onPilih: (v) => _ubah(() => _ke = v),
              ),
              Text(
                'Bukan Pendapatan dan bukan Belanja. Biaya bank dicatat '
                'sebagai Belanja tersendiri.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          )
        else ...[
          ChipPilihan<String>(
            label: l.per,
            keterangan: '· uang siapa ini',
            pilihan: _peruntukan,
            terpilih: _per,
            onPilih: (v) => _ubah(() => _per = v),
          ),
          ChipPilihan<String>(
            label: 'Lingkup',
            pilihan: _lingkup,
            terpilih: _ling,
            onPilih: (v) => _ubah(() => _ling = v),
          ),
        ],
      ],
    );

    final pemilih = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: 'Mata Anggaran ',
                children: [
                  TextSpan(
                    text: '· untuk apa',
                    style: TextStyle(color: c.tinta3),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: c.tinta,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l.pohon,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.permukaan,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IsianTeks(
                gaya: _tanpaJarakHuruf,
                controller: _cariC,
                latar: c.kertas,
                minTinggi: 44,
                petunjuk: 'Cari nomor atau nama',
                labelSemantik: 'Cari Mata Anggaran',
                onChanged: (_) => setState(() {}),
              ),
              for (final r in PemilihMataAnggaran.saring(
                _ma[l.pohon] ?? const [],
                _cariC.text,
              ))
                r.grup
                    ? _Grup(r)
                    : _Baris(
                        r,
                        pohon: l.pohon,
                        dipilih: _maKode == r.kode,
                        onTap: () => _ubah(() => _maKode = r.kode),
                      ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Tombol(
                  'Simpan tanpa Mata Anggaran',
                  onPressed: () => _ubah(() => _maKode = null),
                  jenis: JenisTombol.putus,
                  ukuran: UkuranTombol.mini,
                  paddingH: 16,
                  lebarPenuh: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final teks = KisiOtomatis(
      minLebar: 260,
      jarak: 18,
      anak: [
        IsianTeks(
          gaya: _tanpaJarakHuruf,
          label: l.pihak,
          jarakLabel: 6,
          controller: _pihakC,
          onChanged: (_) => setState(() {}),
        ),
        IsianTeks(
          gaya: _tanpaJarakHuruf,
          label: 'Uraian',
          jarakLabel: 6,
          controller: _urC,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );

    final kaki = Container(
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Tanggal transaksi',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
                const TextSpan(text: ' '),
                const TextSpan(
                  text: '16 November 2026',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Tekan(
            onTap: () => _ubah(() => _dok = true),
            radius: 12,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: _dok ? c.permukaan : null,
                shape: _dok
                    ? GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 12)
                    : GarisBorder.putus(c.putus, radius: 12),
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  _dok
                      ? 'nota-16-11.jpg · Terlampir'
                      : 'Lampirkan dokumen pendukung',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _dok ? c.tinta : c.laut,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _jarak(18, [
        jumlah,
        kisi,
        if (!pindah) ...[pemilih, teks],
        kaki,
      ]),
    );

    // ---- aside ----------------------------------------------------------
    final kartu = Kartu(
      status: _posted ? GarisStatus.terpilih : GarisStatus.draf,
      radius: 16,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BarisLencana(posted: _posted),
          const SizedBox(height: 6),
          Text(
            rp(j * l.tanda),
            style: _mono.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
              color: _posted ? c.tinta : c.tinta2,
            ),
          ),
          const SizedBox(height: 6),
          Text(ringkas, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );

    final daftar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cek.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: i > 0 ? Border(top: BorderSide(color: c.garis)) : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PalakatIkon(
                    switch (cek[i].$1) {
                      _Cek.ok => Ikon.terpenuhi,
                      _Cek.gagal => Ikon.belumTerpenuhi,
                      _Cek.info => Ikon.untukDiketahui,
                    },
                    ukuran: 20,
                    label: switch (cek[i].$1) {
                      _Cek.ok => 'Terpenuhi',
                      _Cek.gagal => 'Belum terpenuhi',
                      _Cek.info => 'Untuk diketahui',
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cek[i].$2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    final aside = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _jarak(14, [
        kartu,
        if (!_posted) ...[
          daftar,
          if (gagalN > 0)
            Semantics(
              container: true,
              liveRegion: true,
              child: Text(
                'Tidak dapat dilakukan: $alasan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.bata,
                ),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              IntrinsicWidth(
                child: TombolBersyarat(
                  label: 'Periksa dan bukukan',
                  tindakan: 'Periksa dan bukukan',
                  alasan: alasan,
                  sudahMulai: false,
                  warnaSiap: JenisTombol.utama,
                  teksBelumRedup: true,
                  tinggi: 46,
                  radius: 12,
                  paddingH: 20,
                  onPressed: () => setState(() => _posted = true),
                ),
              ),
              const Tombol(
                'Simpan sebagai draf',
                onPressed: null,
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.ringkas,
                lebarPenuh: false,
                ke: 'WebTransaksi',
                cara: Cara.naik,
              ),
            ],
          ),
        ] else ...[
          Text(
            'Dibukukan pada 16/11/2026 10.42 · tidak dapat diubah lagi.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Tombol(
              'Catat lagi',
              onPressed: _lagi,
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.ringkas,
              lebarPenuh: false,
            ),
          ),
        ],
      ]),
    );

    return HalamanWeb(
      nav: NavSamping(
        item: navKeuangan,
        aktif: 1,
        pengguna: const PenggunaKeuangan(),
      ),
      jabatanKosong: true,
      isi: [
        judul,
        deret,
        jenis,
        BarisLentur(
          jarak: 28,
          anak: [
            Lentur(dasar: 480, tumbuh: 999, child: form),
            Lentur(dasar: 360, child: aside),
          ],
        ),
      ],
    );
  }
}

/// CSS column `gap`.
List<Widget> _jarak(double g, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: g),
    anak[i],
  ],
];

/// The card's top row (space-between, gap 16, centred): the status badge
/// and, once posted, the stamp. Both shrink as CSS flex items do (in
/// proportion to their widths, never below their longest word), so they sit
/// on one line whenever they fit, as on the board.
class _BarisLencana extends StatelessWidget {
  const _BarisLencana({required this.posted});

  final bool posted;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final lencana = posted ? 'Dibukukan' : 'Draf · belum masuk saldo';
    final gayaLencana = dasar.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: posted ? c.permukaan : c.tinta2,
    );
    const cap = 'No. Bukti BKU-2026-0147';
    final gayaCap = dasar.merge(
      _mono.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: c.laut),
    );
    final skala = MediaQuery.textScalerOf(context);
    // Padding + line, both sides: badge 9 + 1.5, stamp 10 + 2.
    const tepiL = 21.0, tepiC = 24.0;
    return LayoutBuilder(
      builder: (context, k) {
        final (a, aMin) = _ukur(lencana, gayaLencana, skala);
        var (wa, wb) = (math.min(a + tepiL, k.maxWidth), 0.0);
        var sebaris = false;
        if (posted) {
          final (b, bMin) = _ukur(cap, gayaCap, skala);
          // At 1440 the board fits both by a fraction of a pixel (Chrome
          // snaps text to layout units); our rounded-up widths overshoot by
          // up to 2 px, so treat that as fitting and keep the stamp on one line.
          final lebih = a + tepiL + b + tepiC + 16 - k.maxWidth;
          sebaris = lebih > 0 && lebih <= 2;
          (wa, wb) = sebaris
              ? (a + tepiL, b + tepiC - lebih)
              : _susut(
                  a + tepiL,
                  aMin + tepiL,
                  b + tepiC,
                  bMin + tepiC,
                  k.maxWidth,
                  16,
                );
        }
        return Row(
          children: [
            SizedBox(
              width: wa,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: ShapeDecoration(
                  color: posted ? c.tinta : null,
                  shape: posted
                      ? GarisBorder.penuh(c.tinta, radius: 6)
                      : GarisBorder.putus(c.putus, radius: 6),
                ),
                child: Text(lencana, style: gayaLencana),
              ),
            ),
            if (posted) ...[
              const Spacer(),
              SizedBox(
                width: wb,
                child: Gerak(
                  Kerangka.muncul,
                  key: const ValueKey('cap'),
                  lama: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: ShapeDecoration(
                      shape: GarisBorder.penuh(c.laut, tebal: 2, radius: 8),
                    ),
                    child: Text(cap, style: gayaCap, softWrap: !sebaris),
                  ),
                ),
              ),
            ],
          ],
        );
      },
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

/// Group heading, not pressable: padding 10 0 4, inline code, name, note.
class _Grup extends StatelessWidget {
  const _Grup(this.r);
  final BarisMataAnggaran r;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: r.kode,
              style: _mono.copyWith(fontSize: 13, color: c.tinta3),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: r.nama,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.tinta2,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: '· Judul kelompok, tidak dapat dibukukan',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
      ),
    );
  }
}

/// Postable row: margin-top 4, min 44, padding 8 12, radius 10, `permukaan`,
/// 1 px `garis` or 2 px `tinta` when chosen; "{pohon} {kode}" then the name.
class _Baris extends StatelessWidget {
  const _Baris(
    this.r, {
    required this.pohon,
    required this.dipilih,
    required this.onTap,
  });
  final BarisMataAnggaran r;
  final String pohon;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Tekan(
        onTap: onTap,
        dipilih: dipilih,
        radius: 10,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(
              dipilih ? c.tinta : c.garis,
              tebal: dipilih ? 2 : 1,
              radius: 10,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$pohon ${r.kode}',
                style: _mono.copyWith(fontSize: 13, color: c.tinta2),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  r.nama,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// TextField takes the theme's M3 letter spacing 0.5 unless the style sets
/// one; the boards' inputs inherit 'normal' (0).
const _tanpaJarakHuruf = TextStyle(letterSpacing: 0);
