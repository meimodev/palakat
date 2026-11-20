import 'package:flutter/material.dart';

import '../../shell/halaman_lembar.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';

/// Peta layar (spec 08-cari.md): a fixed 1760 × 1860 sheet mapping every
/// finance screen, phone and web, with its tier. Every row opens its board.
class PetaLayarScreen extends StatelessWidget {
  const PetaLayarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      type: MaterialType.transparency,
      // CSS splits line-height leading evenly above and below the text.
      child: DefaultTextHeightBehavior(
        textHeightBehavior: const TextHeightBehavior(
          leadingDistribution: TextLeadingDistribution.even,
        ),
        child: HalamanLembar(
          ukuran: const Size(1760, 1860),
          isi: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Peta layar',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Di mana tiap layar berada dalam navigasi. Saat diputar, '
                        'tiap nama membuka artboard-nya.',
                        style: TextStyle(color: c.tinta2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // A flex row: its items stretch, so the borderless T1 badge
                // is as tall as the outlined ones.
                IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Tanda('T1 jalur pertama', 1, legenda: true),
                      const SizedBox(width: 8),
                      _Tanda('T2 dan T3', 2, legenda: true),
                      const SizedBox(width: 8),
                      _Tanda('Sementara', 0, legenda: true),
                    ],
                  ),
                ),
              ],
            ),
            for (final p in _platform) _Platform(p),
            Text(
              'Ponsel memakai lima tab bawah dengan tombol Catat di tengah. Web '
              'memakai bilah samping dengan tujuh tujuan; Rekonsiliasi dan '
              'Laporan berdiri sendiri di web karena dikerjakan di layar lebar. '
              '“Peran lain” adalah tampilan untuk orang selain Bendahara.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tier badge: 1 = T1 (filled), 2/3 = T2/T3 (solid line), 0 = Sem. (dashed).
/// The legend's badges are larger (radius 6, padding 3 9) and its T1 badge
/// has no border; the row tags are radius 5, padding 1 6.
class _Tanda extends StatelessWidget {
  const _Tanda(this.teks, this.tingkat, {this.legenda = false});

  final String teks;
  final int tingkat;
  final bool legenda;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final penuh = tingkat == 1;
    final sem = tingkat == 0;
    final radius = legenda ? 6.0 : 5.0;
    final ShapeBorder bentuk = sem
        ? GarisBorder.putus(c.putus, radius: radius)
        : penuh && legenda
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))
        : GarisBorder.penuh(c.tinta, radius: radius);
    return Container(
      padding: legenda
          ? const EdgeInsets.symmetric(vertical: 3, horizontal: 9)
          : const EdgeInsets.symmetric(vertical: 1, horizontal: 6),
      decoration: ShapeDecoration(color: penuh ? c.tinta : null, shape: bentuk),
      child: Text(
        teks,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: penuh
              ? c.permukaan
              : sem
              ? c.tinta2
              : c.tinta,
        ),
      ),
    );
  }
}

class _Platform extends StatelessWidget {
  const _Platform(this.p);
  final _Plat p;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              p.n,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 12),
            Text(p.cat, style: TextStyle(fontSize: 14, color: c.tinta2)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < p.kolom; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(
                child: i < p.grup.length ? _Grup(p.grup[i]) : const SizedBox(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Grup extends StatelessWidget {
  const _Grup(this.g);
  final _Kelompok g;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 6),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.tinta, width: 1.5)),
            ),
            child: Text(
              g.n,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          for (final l in g.layar) ...[const SizedBox(height: 2), _Baris(l)],
        ],
      ),
    );
  }
}

/// A screen row: name left, tier tag right, min-height 30. Below the 44 px
/// target on purpose: this is a fixed-size map sheet (spec notes).
class _Baris extends StatelessWidget {
  const _Baris(this.l);
  final _Layar l;

  @override
  Widget build(BuildContext context) => Tautan(
    ke: l.ke,
    minLebar: 0,
    minTinggi: 30,
    child: Row(
      children: [
        Expanded(
          child: Text(
            l.n,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 6),
        _Tanda(_labelTingkat[l.t]!, l.t),
      ],
    ),
  );
}

const _labelTingkat = {1: 'T1', 2: 'T2', 3: 'T3', 0: 'Sem.'};

typedef _Layar = ({String ke, String n, int t});
typedef _Kelompok = ({String n, List<_Layar> layar});
typedef _Plat = ({String n, String cat, int kolom, List<_Kelompok> grup});

const List<_Plat> _platform = [
  (
    n: 'Ponsel',
    cat: 'Tab bawah: Beranda · Transaksi · Catat · Bulan · Lainnya',
    kolom: 6,
    grup: [
      (
        n: 'Beranda',
        layar: [
          (ke: 'Main', n: 'Beranda dan catat', t: 1),
          (ke: 'Cari', n: 'Cari dan tanya', t: 3),
          (ke: 'Pemberitahuan', n: 'Pemberitahuan', t: 0),
          (ke: 'Masuk', n: 'Masuk', t: 1),
          (ke: 'Pemulihan', n: 'Pemulihan akun', t: 1),
          (ke: 'Sambungan', n: 'Sambungan dan sesi', t: 1),
          (ke: 'Memuat', n: 'Memuat dan gagal', t: 1),
        ],
      ),
      (
        n: 'Transaksi',
        layar: [
          (ke: 'Main', n: 'Daftar dan rincian', t: 1),
          (ke: 'PilihBulan', n: 'Pemilih bulan', t: 1),
          (ke: 'Persetujuan', n: 'Ganti persetujuan', t: 1),
          (ke: 'AlihPeruntukan', n: 'Alih peruntukan', t: 1),
          (ke: 'AIFoto', n: 'AI dari foto nota', t: 3),
          (ke: 'Draf', n: 'Pindah tanggal, batalkan', t: 1),
          (ke: 'Koreksi', n: 'Koreksi dan persetujuan', t: 1),
          (ke: 'Dokumen', n: 'Dokumen pendukung', t: 1),
          (ke: 'Bagi', n: 'Bagi Mata Anggaran', t: 1),
          (ke: 'Persembahan', n: 'Persembahan', t: 2),
          (ke: 'Pemeriksa', n: 'Pemeriksa kedua', t: 1),
          (ke: 'Pengembalian', n: 'Pengembalian', t: 0),
          (ke: 'BantuanAI', n: 'Bantuan AI', t: 3),
          (ke: 'Kamera', n: 'Foto dokumen', t: 1),
          (ke: 'Tanggal', n: 'Tanggal transaksi', t: 1),
          (ke: 'AIMataAnggaran', n: 'AI: Mata Anggaran', t: 3),
          (ke: 'LihatDokumen', n: 'Lihat file', t: 1),
        ],
      ),
      (
        n: 'Bulan',
        layar: [
          (ke: 'TutupBuku', n: 'Rekonsiliasi dan tutup buku', t: 1),
          (ke: 'HitungKas', n: 'Hitung kas', t: 1),
          (ke: 'Kesiapan', n: 'Pernyataan kesiapan', t: 2),
          (ke: 'Kejadian', n: 'Kejadian', t: 1),
          (ke: 'Laporan', n: 'Laporan', t: 1),
          (ke: 'RekonIsi', n: 'Isi rekening koran', t: 1),
          (ke: 'AIBulan', n: 'AI akhir bulan', t: 3),
          (ke: 'LihatTransaksi', n: 'Lihat transaksi', t: 2),
        ],
      ),
      (
        n: 'Lainnya',
        layar: [
          (ke: 'Lainnya', n: 'Pengaturan', t: 1),
          (ke: 'UbahPengaturan', n: 'Tambah dan ubah', t: 1),
          (ke: 'MataAnggaran', n: 'Mata Anggaran', t: 1),
          (ke: 'Bendahara', n: 'Bendahara dan sesi', t: 1),
          (ke: 'FormatLaporan', n: 'Format laporan', t: 1),
          (ke: 'Kewajiban', n: 'Uang Muka dan Titipan', t: 2),
          (ke: 'KasusBaru', n: 'Kasus baru', t: 2),
          (ke: 'Bukti', n: 'Daftar Bukti Kas', t: 2),
          (ke: 'Impor', n: 'Impor', t: 2),
          (ke: 'Ekspor', n: 'Ekspor', t: 3),
          (ke: 'Keluar', n: 'Akun dan keluar', t: 1),
        ],
      ),
      (
        n: 'Pertama kali',
        layar: [
          (ke: 'Awal', n: 'Langkah dan saldo awal', t: 1),
          (ke: 'AwalIsian', n: 'Identitas dan daftar', t: 1),
        ],
      ),
      (n: 'Peran lain', layar: [(ke: 'Terbatas', n: 'Akses terbatas', t: 2)]),
    ],
  ),
  (
    n: 'Web',
    cat: 'Bilah samping',
    kolom: 8,
    grup: [
      (
        n: 'Beranda',
        layar: [
          (ke: 'WebBeranda', n: 'Beranda', t: 1),
          (ke: 'WebCari', n: 'Cari dan tanya', t: 3),
          (ke: 'WebPemberitahuan', n: 'Pemberitahuan', t: 0),
          (ke: 'WebMasuk', n: 'Masuk', t: 1),
          (ke: 'WebPemulihan', n: 'Pemulihan akun', t: 1),
          (ke: 'WebSambungan', n: 'Sambungan dan sesi', t: 1),
          (ke: 'WebMemuat', n: 'Memuat dan gagal', t: 1),
          (ke: 'TabBeranda', n: 'Lebar tablet', t: 1),
        ],
      ),
      (
        n: 'Transaksi',
        layar: [
          (ke: 'WebTransaksi', n: 'Daftar dan rincian', t: 1),
          (ke: 'WebPilihBulan', n: 'Pemilih bulan', t: 1),
          (ke: 'WebBagi', n: 'Bagi Mata Anggaran', t: 1),
          (ke: 'WebPersetujuan', n: 'Ganti persetujuan', t: 1),
          (ke: 'WebAlihPeruntukan', n: 'Alih peruntukan', t: 1),
          (ke: 'WebAIFoto', n: 'AI dari foto nota', t: 3),
          (ke: 'WebCatat', n: 'Catat transaksi', t: 1),
          (ke: 'WebDraf', n: 'Pindah tanggal, batalkan', t: 1),
          (ke: 'WebKoreksi', n: 'Koreksi dan persetujuan', t: 1),
          (ke: 'WebDokumen', n: 'Dokumen pendukung', t: 1),
          (ke: 'WebPersembahan', n: 'Persembahan', t: 2),
          (ke: 'WebPemeriksa', n: 'Pemeriksa kedua', t: 1),
          (ke: 'WebImpor', n: 'Impor', t: 2),
          (ke: 'WebPengembalian', n: 'Pengembalian', t: 0),
          (ke: 'WebLihatDokumen', n: 'Lihat file', t: 1),
          (ke: 'WebUnggah', n: 'Unggah dokumen', t: 1),
          (ke: 'WebTanggal', n: 'Tanggal transaksi', t: 1),
          (ke: 'WebBantuanAI', n: 'AI dari kalimat', t: 3),
          (ke: 'WebAIMataAnggaran', n: 'AI: Mata Anggaran', t: 3),
        ],
      ),
      (
        n: 'Uang Muka dan Titipan',
        layar: [
          (ke: 'WebKewajiban', n: 'Kasus dan sisa', t: 2),
          (ke: 'WebKasus', n: 'Catat pada kasus', t: 2),
          (ke: 'WebKasusBaru', n: 'Kasus baru', t: 2),
        ],
      ),
      (
        n: 'Rekonsiliasi',
        layar: [
          (ke: 'WebRekonsiliasi', n: 'Rekening koran', t: 1),
          (ke: 'WebHitungKas', n: 'Hitung kas', t: 1),
          (ke: 'WebRekonIsi', n: 'Isi rekening koran', t: 1),
        ],
      ),
      (
        n: 'Bulan dan tutup buku',
        layar: [
          (ke: 'WebTutupBuku', n: 'Tutup buku', t: 1),
          (ke: 'WebKesiapan', n: 'Pernyataan kesiapan', t: 2),
          (ke: 'WebKejadian', n: 'Kejadian', t: 1),
          (ke: 'WebAI', n: 'Bantuan AI akhir bulan', t: 3),
        ],
      ),
      (
        n: 'Laporan',
        layar: [
          (ke: 'WebLaporan', n: 'F01', t: 1),
          (ke: 'WebPaketLaporan', n: 'F01 sampai F14', t: 2),
          (ke: 'WebExcel', n: 'Contoh Excel', t: 2),
          (ke: 'WebBukti', n: 'Daftar Bukti Kas', t: 2),
          (ke: 'WebFormatLaporan', n: 'Format laporan', t: 1),
          (ke: 'A4F01', n: 'Halaman A4', t: 1),
          (ke: 'WebLihatTransaksi', n: 'Lihat transaksi', t: 2),
        ],
      ),
      (
        n: 'Pengaturan',
        layar: [
          (ke: 'WebPengaturan', n: 'Pengaturan', t: 1),
          (ke: 'WebUbahPengaturan', n: 'Tambah dan ubah', t: 1),
          (ke: 'WebSerahTerima', n: 'Serah terima', t: 1),
          (ke: 'WebAwal', n: 'Saldo awal', t: 1),
          (ke: 'WebAwalIsian', n: 'Identitas dan daftar', t: 1),
          (ke: 'WebMataAnggaran', n: 'Mata Anggaran', t: 1),
          (ke: 'WebEkspor', n: 'Ekspor', t: 3),
          (ke: 'WebKeluar', n: 'Akun dan keluar', t: 1),
        ],
      ),
      (
        n: 'Peran lain',
        layar: [
          (ke: 'WebTerbatas', n: 'Akses terbatas', t: 2),
          (ke: 'WebExcelTerbatas', n: 'Excel TERBATAS', t: 2),
          (ke: 'WebVerifikasi', n: 'Petugas verifikasi', t: 1),
        ],
      ),
    ],
  ),
];
