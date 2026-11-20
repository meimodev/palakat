import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

/// One action of the detail panel: a link (push) to [ke], or, with [ke]
/// empty, the in-board "Periksa dan bukukan" button.
typedef _Aksi = ({String n, String ke, bool utama});

/// One fact row: key, value, value in `bata`.
typedef _Fakta = (String, String, bool);

typedef _Trx = ({
  String st,
  String no,
  String tgl,
  String ur,
  String ak,
  int jm,
  String cat,
  List<_Fakta> rinci,
  List<_Aksi> aksi,
  String catatan,
});

const _filter = ['Semua', 'Draf', 'Dibukukan', 'Dibalik', 'Dibatalkan'];
const _bukukan = 'Periksa dan bukukan';

/// CSS half-leading for the two large texts (h1 26, amount 32), where
/// Flutter's proportional default sits 2–4 px lower than Chrome. ponytail:
/// small text keeps the default because Chrome's rounded line boxes match it
/// better; HalamanWeb could set this for all text (sharedNeeds).
const _rata = TextLeadingDistribution.even;

/// The board's `data` (rows in board order, not by date). Row 0 changes once
/// booked ([buku]).
List<_Trx> _data(bool buku) => [
  (
    st: buku ? 'Dibukukan' : 'Draf',
    no: buku ? 'BKU-2026-0147' : '',
    tgl: '16/11/2026',
    ur: 'Fotokopi warta jemaat',
    ak: 'Kas',
    jm: -150000,
    cat: buku ? '' : 'Belum masuk saldo',
    rinci: [
      ('Diambil dari peruntukan', 'Umum Jemaat', false),
      ('Lingkup', 'Jemaat', false),
      ('Mata Anggaran', 'Belanja 5.02.01.00 Alat tulis dan fotokopi', false),
      ('Persetujuan', 'Tidak diperlukan (aturan: transaksi rutin)', false),
      ('Dokumen pendukung', 'Diunggah, belum diverifikasi', false),
      if (buku) ('Dibukukan pada', '16/11/2026 10.42', false),
    ],
    aksi: buku
        ? [
            (n: 'Verifikasi', ke: 'WebLihatDokumen', utama: true),
            (n: 'Lampirkan dokumen pendukung', ke: 'WebUnggah', utama: false),
            (n: 'Koreksi dengan pembalikan', ke: 'WebKoreksi', utama: false),
          ]
        : [
            (n: _bukukan, ke: '', utama: true),
            (n: 'Ubah', ke: 'WebCatat', utama: false),
            (n: 'Pindah tanggal', ke: 'WebDraf', utama: false),
            (n: 'Batalkan', ke: 'WebDraf', utama: false),
          ],
    catatan: buku
        ? 'Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata Anggaran tidak dapat diubah lagi.'
        : 'Semua syarat terpenuhi. Pindah tanggal dan Batalkan memerlukan alasan.',
  ),
  (
    st: 'Draf',
    no: '',
    tgl: '08/11/2026',
    ur: 'Honor pemusik',
    ak: 'Bank BNI ··4821',
    jm: -650000,
    cat: 'Belum masuk saldo · Mata Anggaran belum dipilih',
    rinci: const [
      ('Diambil dari peruntukan', 'Umum Jemaat', false),
      ('Lingkup', 'Jemaat', false),
      ('Mata Anggaran', 'Mata Anggaran belum dipilih', true),
      ('Persetujuan', 'Persetujuan belum dicatat', true),
      ('Dokumen pendukung', 'Wajib, belum ada', true),
    ],
    aksi: const [
      (n: 'Pilih Mata Anggaran', ke: 'WebCatat', utama: true),
      (n: 'Catat persetujuan', ke: 'WebPersetujuan', utama: false),
      (n: 'Lampirkan dokumen pendukung', ke: 'WebUnggah', utama: false),
      (n: 'Ubah', ke: 'WebCatat', utama: false),
      (n: 'Batalkan', ke: 'WebDraf', utama: false),
    ],
    catatan: 'Tidak dapat dilakukan: Bukukan. Mata Anggaran belum dipilih dan persetujuan belum dicatat.',
  ),
  (
    st: 'Dibukukan',
    no: 'BKU-2026-0146',
    tgl: '15/11/2026',
    ur: 'Persembahan Ibadah Minggu',
    ak: 'Kas',
    jm: 3450000,
    cat: '',
    rinci: const [
      ('Masuk ke peruntukan', 'Umum Jemaat', false),
      ('Lingkup', 'Jemaat', false),
      (
        'Mata Anggaran',
        'Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu',
        false,
      ),
      ('Versi Mata Anggaran', '2026.1', false),
      ('Dokumen pendukung', 'Terverifikasi (oleh Meiske L.)', false),
      ('Dibukukan pada', '15/11/2026 12.20', false),
    ],
    aksi: const [
      (n: 'Lampirkan dokumen pendukung', ke: 'WebUnggah', utama: false),
      (n: 'Koreksi dengan pembalikan', ke: 'WebKoreksi', utama: false),
    ],
    catatan:
        'Koreksi hanya lewat pembalikan, selama November 2026 belum ditutup.',
  ),
  (
    st: 'Dibukukan',
    no: 'BKU-2026-0143',
    tgl: '11/11/2026',
    ur: 'Sewa sound system',
    ak: 'Kas',
    jm: -600000,
    cat: 'Dokumen pendukung wajib, belum ada',
    rinci: const [
      ('Diambil dari peruntukan', 'Umum Jemaat', false),
      ('Lingkup', 'Panitia Natal', false),
      ('Mata Anggaran', 'Belanja 5.05.02.00 Sewa peralatan', false),
      ('Dokumen pendukung', 'Wajib, belum ada', true),
      ('Dibukukan pada', '11/11/2026 16.05', false),
    ],
    aksi: const [
      (n: 'Lampirkan dokumen pendukung', ke: 'WebUnggah', utama: true),
      (n: 'Catat pengecualian', ke: 'WebDokumen', utama: false),
      (n: 'Koreksi dengan pembalikan', ke: 'WebKoreksi', utama: false),
    ],
    catatan: 'Menjadi hambatan tutup buku sampai dokumen terverifikasi atau dikecualikan dengan alasan.',
  ),
  (
    st: 'Dibukukan',
    no: 'BKU-2026-0144',
    tgl: '12/11/2026',
    ur: 'Pembalikan BKU-2026-0139',
    ak: 'Kas',
    jm: 750000,
    cat: 'Pembalikan',
    rinci: const [
      ('Pembalikan dari', 'No. Bukti BKU-2026-0139', false),
      ('Alasan', 'Mata Anggaran keliru', false),
      ('Dibukukan pada', '12/11/2026 09.31', false),
    ],
    aksi: const [(n: 'Lihat transaksi asal', ke: 'WebKoreksi', utama: false)],
    catatan: 'Pembalikan tidak dapat diubah atau dibalik.',
  ),
  (
    st: 'Dibalik',
    no: 'BKU-2026-0139',
    tgl: '09/11/2026',
    ur: 'Konsumsi rapat majelis',
    ak: 'Kas',
    jm: -750000,
    cat: 'Dibalik oleh No. Bukti BKU-2026-0144',
    rinci: const [
      ('Dibalik oleh', 'No. Bukti BKU-2026-0144', false),
      ('Transaksi koreksi', 'No. Bukti BKU-2026-0145', false),
      ('Mata Anggaran', 'Belanja 5.02.01.00 Alat tulis dan fotokopi', false),
      ('Dibukukan pada', '09/11/2026 14.12', false),
    ],
    aksi: const [
      (n: 'Lihat pembalikan', ke: 'WebKoreksi', utama: false),
      (n: 'Lihat transaksi koreksi', ke: 'WebKoreksi', utama: false),
    ],
    catatan: 'Transaksi asal tetap tampil di daftar dan laporan.',
  ),
  (
    st: 'Dibatalkan',
    no: '',
    tgl: '05/11/2026',
    ur: 'Pembelian bunga altar',
    ak: 'Kas',
    jm: -200000,
    cat: 'Tidak pernah dibukukan',
    rinci: const [
      ('Alasan', 'Tercatat dua kali', false),
      ('Dibatalkan oleh', 'Meiske L.', false),
      ('Dibatalkan pada', '06/11/2026 08.02', false),
    ],
    aksi: const [],
    catatan: 'Hanya dapat dilihat. Transaksi ini tidak pernah punya No. Bukti.',
  ),
];

/// Web · Transaksi dan koreksi (spec 02-awal.md, WebTransaksi).
class WebTransaksiScreen extends StatefulWidget {
  const WebTransaksiScreen({super.key});

  @override
  State<WebTransaksiScreen> createState() => _WebTransaksiScreenState();
}

class _WebTransaksiScreenState extends State<WebTransaksiScreen> {
  String _f = 'Semua';
  int _pilih = 0;
  bool _buku = false;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final data = _data(_buku);
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        jabatanKosong: true,
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 1,
          pengguna: PenggunaKeuangan(),
        ),
        isi: [
          const _Kepala(),
          DeretTautan(
            web: true,
            anak: [
              for (final (:t, :ke) in const [
                (t: 'Daftar Bukti Kas', ke: 'WebBukti'),
                (t: 'Koreksi dengan pembalikan', ke: 'WebKoreksi'),
                (t: 'Draf di bulan yang sudah ditutup', ke: 'WebDraf'),
                (t: 'Pengembalian', ke: 'WebPengembalian'),
                (t: 'Cari', ke: 'WebCari'),
              ])
                Tautan(
                  ke: ke,
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: TautanTeks(t),
                    ),
                  ),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in _filter)
                ChipSatu(
                  teks: f,
                  dipilih: _f == f,
                  padding: 16,
                  onTap: () => setState(() => _f = f),
                ),
            ],
          ),
          BarisLentur(
            jarak: 24,
            anak: [
              Lentur(dasar: 520, tumbuh: 999, child: _tabel(c, data)),
              Lentur(
                dasar: 360,
                child: _Panel(
                  p: data[_pilih],
                  baru: _pilih == 0 && _buku,
                  onBukukan: () => setState(() => _buku = true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabel(PalakatWarna c, List<_Trx> data) {
    Widget baris({
      required Widget status,
      required Widget tgl,
      required Widget ur,
      required Widget jm,
    }) => Row(
      children: [
        SizedBox(width: 104, child: status),
        const SizedBox(width: 12),
        SizedBox(width: 88, child: tgl),
        const SizedBox(width: 12),
        Expanded(child: ur),
        const SizedBox(width: 12),
        SizedBox(width: 124, child: jm),
      ],
    );

    final isi = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.tinta2,
            ),
            child: baris(
              status: const Text('Status'),
              tgl: const Text('Tanggal'),
              ur: const Text('Uraian · No. Bukti · Kas/\u2060Bank'),
              jm: const Text('Jumlah (Rp)', textAlign: TextAlign.right),
            ),
          ),
        ),
        for (var i = 0; i < data.length; i++)
          if (_f == 'Semua' || data[i].st == _f)
            () {
              final r = data[i];
              final on = _pilih == i;
              final draf = r.st == 'Draf', batal = r.st == 'Dibatalkan';
              return Tekan(
                onTap: () => setState(() => _pilih = i),
                dipilih: on,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: on
                        ? c.lautLembut
                        : draf
                        ? c.kertas
                        : c.permukaan,
                    border: Border(top: BorderSide(color: c.garis)),
                  ),
                  // box-shadow: inset 3px 0 0 laut
                  foregroundDecoration: on
                      ? BoxDecoration(
                          border: Border(
                            left: BorderSide(color: c.laut, width: 3),
                          ),
                        )
                      : null,
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 14),
                    child: baris(
                      status: Align(
                        alignment: Alignment.centerLeft,
                        child: _Lencana(r.st, r.st),
                      ),
                      tgl: Text(r.tgl, style: TextStyle(color: c.tinta2)),
                      ur: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.ur,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: r.no.isEmpty ? '—' : _putusKode(r.no),
                                  style: const TextStyle(
                                    fontFamily: PalakatText.mono,
                                  ),
                                ),
                                TextSpan(text: ' · ${r.ak}'),
                              ],
                            ),
                            style: TextStyle(fontSize: 13, color: c.tinta2),
                          ),
                          if (r.cat.isNotEmpty)
                            Text(
                              _putusKode(r.cat),
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                        ],
                      ),
                      jm: Text(
                        rp(r.jm),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: PalakatText.mono,
                          fontWeight: FontWeight.w500,
                          color: draf || batal ? c.tinta3 : c.tinta,
                          decoration: batal ? TextDecoration.lineThrough : null,
                          decorationColor: c.tinta3,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }(),
      ],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, k) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: k.maxWidth < 470 ? 470 : k.maxWidth,
            child: isi,
          ),
        ),
      ),
    );
  }
}

/// The board's `B` badge map (13/700, padding 3 9, radius 6, 1.5 line). It
/// wraps when squeezed, as the panel's long Draf label does. Dibatalkan is a
/// `kertas` field and edge here (LencanaStatus `abu` uses `garis`; board wins).
class _Lencana extends StatelessWidget {
  const _Lencana(this.st, this.label);
  final String st, label;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (GarisBorder garis, Color? isi, Color teks) = switch (st) {
      'Draf' => (GarisBorder.putus(c.putus, radius: 6), null, c.tinta2),
      'Dibukukan' => (
        GarisBorder.penuh(c.tinta, radius: 6),
        c.tinta,
        c.permukaan,
      ),
      'Dibalik' => (
        GarisBorder.penuh(c.tinta3, radius: 6),
        c.permukaan,
        c.tinta2,
      ),
      _ => (GarisBorder.penuh(c.kertas, radius: 6), c.kertas, c.tinta2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: ShapeDecoration(color: isi, shape: garis),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: teks,
        ),
      ),
    );
  }
}

/// Max-content and min-content (widest word) width of [t] in [g].
(double, double) _ukurTeks(BuildContext context, String t, TextStyle g) {
  final skala = MediaQuery.textScalerOf(context);
  double w(String x) {
    final tp = TextPainter(
      text: TextSpan(text: x, style: g),
      textDirection: TextDirection.ltr,
      textScaler: skala,
    )..layout();
    final h = tp.width.ceilToDouble();
    tp.dispose();
    return h;
  }

  return (w(t), t.split(' ').map(w).reduce((a, b) => a > b ? a : b));
}

/// CSS `flex: 0 1 auto` items ((max, min) content widths) in a row [w] wide
/// with [jarak] gaps: they shrink in proportion to their width, never below
/// their min-content.
List<double> _susut(List<(double, double)> u, double jarak, double w) {
  final ukuran = [for (final x in u) x.$1];
  final beku = List.filled(u.length, false);
  while (true) {
    var tetap = jarak * (u.length - 1), dasar = 0.0;
    for (var i = 0; i < u.length; i++) {
      if (beku[i]) {
        tetap += ukuran[i];
      } else {
        dasar += u[i].$1;
      }
    }
    final kurang = tetap + dasar - w;
    if (kurang <= 0 || dasar == 0) return ukuran;
    var langgar = false;
    for (var i = 0; i < u.length; i++) {
      if (beku[i]) continue;
      ukuran[i] = u[i].$1 - kurang * u[i].$1 / dasar;
      if (ukuran[i] < u[i].$2) {
        ukuran[i] = u[i].$2;
        beku[i] = true;
        langgar = true;
      }
    }
    if (!langgar) return ukuran;
  }
}

/// h1, month pill, Impor, + Catat transaksi: `flex-wrap`, the h1
/// `flex: 1 1 200px`, the links at their own width.
class _Kepala extends StatelessWidget {
  const _Kepala();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, FontWeight b, double tepi) {
      final tp = TextPainter(
        text: TextSpan(
          text: t,
          style: dasar.copyWith(fontWeight: b),
        ),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = tp.width;
      tp.dispose();
      return (w + tepi).ceilToDouble();
    }

    const bulan = 'November 2026 · Belum ditutup';
    return BarisLentur(
      jarak: 12,
      rata: CrossAxisAlignment.center,
      anak: [
        const Lentur(
          dasar: 200,
          child: Text(
            'Transaksi',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              leadingDistribution: _rata,
            ),
          ),
        ),
        Lentur(
          dasar: lebar(bulan, FontWeight.w600, 34),
          tumbuh: 0,
          child: Tautan(
            ke: 'WebPilihBulan',
            radius: 999,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: c.permukaan,
                border: Border.all(color: c.garisTegas),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                bulan,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        Lentur(
          dasar: lebar('Impor', FontWeight.w700, 35),
          tumbuh: 0,
          child: const Tombol(
            'Impor',
            onPressed: null,
            ke: 'WebImpor',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.kecil,
          ),
        ),
        Lentur(
          dasar: lebar('+ Catat transaksi', FontWeight.w700, 36),
          tumbuh: 0,
          child: const Tombol(
            '+ Catat transaksi',
            onPressed: null,
            ke: 'WebCatat',
            ukuran: UkuranTombol.kecil,
            paddingH: 18,
          ),
        ),
      ],
    );
  }
}

/// The `aside`: booking card, facts, actions, Riwayat for row [p].
class _Panel extends StatelessWidget {
  const _Panel({required this.p, required this.baru, required this.onBukukan});

  final _Trx p;

  /// Row 0 just booked and selected: the sweep and the stamp.
  final bool baru;
  final VoidCallback onBukukan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final draf = p.st == 'Draf';
    final bk = [
      for (final f in p.rinci)
        if (f.$1 == 'Dibukukan pada') f.$2,
    ].firstOrNull;
    final rw = draf
        ? ['${p.tgl} · Draf dicatat oleh Meiske L.']
        : [
            '${bk != null ? '$bk · ' : ''}Dibukukan oleh Meiske L.',
            '${p.tgl} · Draf dicatat oleh Meiske L.',
          ];
    const h2 = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    const mono = PalakatText.mono;

    final kartu = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: draf ? null : c.permukaan,
        shape: draf
            ? GarisBorder.putus(c.putus, radius: 16)
            : GarisBorder.penuh(c.tinta, radius: 16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, k) {
                    final label = draf ? 'Draf · belum masuk saldo' : p.st;
                    final kanan = baru
                        ? 'No. Bukti ${p.no}'
                        : p.no.isEmpty
                        ? 'Belum ada No. Bukti'
                        : p.no;
                    final gKanan = TextStyle(
                      fontFamily: mono,
                      fontSize: 14,
                      fontWeight: baru ? FontWeight.w600 : FontWeight.w400,
                      color: baru ? c.laut : c.tinta2,
                    );
                    final dasar = DefaultTextStyle.of(context).style;
                    final (bMaks, bMin) = _ukurTeks(
                      context,
                      label,
                      dasar.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                    );
                    final (kMaks, kMin) = _ukurTeks(
                      context,
                      kanan,
                      dasar.merge(gKanan),
                    );
                    // badge: padding 18 + line 3; stamp: padding 20 + line 4
                    final tepi = baru ? 24.0 : 0.0;
                    final w = _susut(
                      [(bMaks + 21, bMin + 21), (kMaks + tepi, kMin + tepi)],
                      8,
                      k.maxWidth,
                    );
                    final teksKanan = Text(kanan, style: gKanan);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: w[0],
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _Lencana(p.st, label),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: w[1],
                          child: baru
                              ? Gerak(
                                  Kerangka.cap,
                                  lama: const Duration(milliseconds: 550),
                                  tunda: const Duration(milliseconds: 350),
                                  kurva: PalakatMotion.keluar,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: c.laut,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: teksKanan,
                                  ),
                                )
                              : teksKanan,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  rp(p.jm),
                  style: TextStyle(
                    fontFamily: mono,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1,
                    leadingDistribution: _rata,
                    color: draf || p.st == 'Dibatalkan' ? c.tinta2 : c.tinta,
                  ),
                ),
                const SizedBox(height: 6),
                Text(p.ur, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  '${p.ak} · tanggal transaksi ${p.tgl}',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
          if (baru) const SapuTinta(),
        ],
      ),
    );

    final fakta = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < p.rinci.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: i == 0
                  ? null
                  : BoxDecoration(
                      border: Border(top: BorderSide(color: c.garis)),
                    ),
              child: _BarisFakta(p.rinci[i]),
            ),
        ],
      ),
    );

    final tindakan = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Yang dapat dilakukan', style: h2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in p.aksi)
              Tombol(
                a.n,
                onPressed: a.ke.isEmpty ? onBukukan : null,
                ke: a.ke.isEmpty ? null : a.ke,
                jenis: a.utama ? JenisTombol.utama : JenisTombol.kedua,
                ukuran: UkuranTombol.kecil,
                lebarPenuh: false,
                ukuranTeks: 14,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(p.catatan, style: TextStyle(fontSize: 13, color: c.tinta3)),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Riwayat', style: h2),
        ),
        for (final t in rw) ...[
          const SizedBox(height: 4),
          Text(t, style: TextStyle(fontSize: 14, color: c.tinta2)),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        kartu,
        const SizedBox(height: 14),
        fakta,
        const SizedBox(height: 14),
        tindakan,
      ],
    );
  }
}

/// Key and value, `justify-content: space-between; gap: 16px`. Both shrink
/// as CSS flex items do ([_susut]).
class _BarisFakta extends StatelessWidget {
  const _BarisFakta(this.f);
  final _Fakta f;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
    final gk = dasar.copyWith(color: c.tinta2);
    final gv = dasar.copyWith(
      fontWeight: FontWeight.w600,
      color: f.$3 ? c.bata : c.tinta,
    );
    return LayoutBuilder(
      builder: (context, k) {
        final [wk, wv] = _susut(
          [_ukurTeks(context, f.$1, gk), _ukurTeks(context, f.$2, gv)],
          16,
          k.maxWidth,
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: wk,
              child: Text(f.$1, style: gk),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: wv,
              child: Text(f.$2, style: gv, textAlign: TextAlign.right),
            ),
          ],
        );
      },
    );
  }
}

/// Chrome breaks a code like BKU-2026-0146 only after a hyphen that follows a
/// digit; Flutter breaks it elsewhere. Mark those places, and keep the rest.
String _putusKode(String s) => s
    .replaceAllMapped(RegExp(r'([A-Z])-'), (m) => '${m[1]}\u2060-')
    .replaceAllMapped(RegExp(r'(\d)-'), (m) => '${m[1]}-\u200B');
