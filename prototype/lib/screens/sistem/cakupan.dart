import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shell/halaman_lembar.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tekan.dart';

/// Cakupan keadaan (spec 08-cari.md): a fixed 1400 × 1660 sheet, every state
/// per finance object with links to the boards that draw it.
class CakupanScreen extends StatelessWidget {
  const CakupanScreen({super.key});

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
          ukuran: const Size(1400, 1660),
          isi: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cakupan keadaan',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tiap keadaan dari brief dan layar tempat ia digambar. Yang '
                  'belum digambar hidup ditandai apa adanya.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: c.permukaan,
                border: Border.all(color: c.garis),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: c.tinta2,
                      ),
                      child: const _Kolom([
                        Text('Objek'),
                        Text('Keadaan yang digambar'),
                        Text('Layar'),
                        Text('Belum digambar hidup'),
                      ]),
                    ),
                  ),
                  for (final r in _baris)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: c.garis)),
                      ),
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(fontSize: 13),
                        child: _Kolom([
                          Text(
                            r.objek,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(r.keadaan),
                          Wrap(
                            children: [
                              for (final l in r.layar)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 10,
                                    bottom: 2,
                                  ),
                                  child: _Tautan(ke: l.ke, n: l.n),
                                ),
                            ],
                          ),
                          // The board's bata branch for an undrawn state; every
                          // row is empty, so all read "Tidak ada".
                          r.belum.isEmpty
                              ? Text(
                                  'Tidak ada',
                                  style: TextStyle(color: c.tinta3),
                                )
                              : Text(
                                  r.belum,
                                  style: TextStyle(
                                    color: c.bata,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid columns 190 · 1.5fr · 1fr · 1fr, gap 16, aligned to the top.
class _Kolom extends StatelessWidget {
  const _Kolom(this.sel);
  final List<Widget> sel;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 190, child: sel[0]),
      const SizedBox(width: 16),
      Expanded(flex: 3, child: sel[1]),
      const SizedBox(width: 16),
      Expanded(flex: 2, child: sel[2]),
      const SizedBox(width: 16),
      Expanded(flex: 2, child: sel[3]),
    ],
  );
}

/// Inline board link: 13/600 `laut`, underlined, `lautTua` on hover. Drawn
/// size, below 44 px on purpose: a fixed-size sheet (spec notes).
class _Tautan extends StatefulWidget {
  const _Tautan({required this.ke, required this.n});
  final String ke;
  final String n;

  @override
  State<_Tautan> createState() => _TautanState();
}

class _TautanState extends State<_Tautan> {
  bool _sorot = false;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final warna = _sorot ? c.lautTua : c.laut;
    return MouseRegion(
      onEnter: (_) => setState(() => _sorot = true),
      onExit: (_) => setState(() => _sorot = false),
      child: Tekan(
        onTap: () => Tautan(
          ke: widget.ke,
          child: const SizedBox(),
        ).buka(GoRouter.of(context)),
        minLebar: 0,
        minTinggi: 0,
        peran: PeranTekan.tautan,
        child: Text(
          widget.n,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: warna,
            decoration: TextDecoration.underline,
            decorationColor: warna,
          ),
        ),
      ),
    );
  }
}

typedef _Baris = ({
  String objek,
  String keadaan,
  List<({String ke, String n})> layar,
  String belum,
});

const List<_Baris> _baris = [
  (
    objek: 'Transaksi',
    keadaan: 'Draf · Sudah diperiksa · Dibukukan · Dibalik · Dibatalkan',
    layar: [
      (ke: 'Main', n: 'Harian'),
      (ke: 'Pemeriksa', n: 'Pemeriksa kedua'),
      (ke: 'Koreksi', n: 'Koreksi'),
      (ke: 'Draf', n: 'Draf'),
    ],
    belum: '',
  ),
  (
    objek: 'Mata Anggaran pada transaksi',
    keadaan: 'Belum dipilih · sudah dipilih · dibagi ke beberapa baris',
    layar: [(ke: 'Main', n: 'Harian'), (ke: 'Bagi', n: 'Bagi')],
    belum: '',
  ),
  (
    objek: 'Persetujuan',
    keadaan:
        'Tidak diperlukan (dengan aturannya) · belum dicatat · sudah dicatat',
    layar: [
      (ke: 'Main', n: 'Harian'),
      (ke: 'Koreksi', n: 'Koreksi'),
      (ke: 'Persetujuan', n: 'Ganti catatan'),
    ],
    belum: '',
  ),
  (
    objek: 'Dokumen pendukung',
    keadaan:
        'Tidak diperlukan · Wajib, belum ada · Diunggah, belum diverifikasi · '
        'Terverifikasi · Dikecualikan · Status saat tutup buku',
    layar: [(ke: 'Dokumen', n: 'Dokumen pendukung')],
    belum: '',
  ),
  (
    objek: 'File dokumen',
    keadaan:
        'Sedang diunggah · Gagal diunggah · Terlampir · Dilepas · Ditahan · '
        'Ditolak',
    layar: [
      (ke: 'Main', n: 'Harian'),
      (ke: 'Dokumen', n: 'Dokumen pendukung'),
      (ke: 'Kamera', n: 'Kamera'),
      (ke: 'LihatDokumen', n: 'Lihat file'),
      (ke: 'WebUnggah', n: 'Unggah di web'),
    ],
    belum: '',
  ),
  (
    objek: 'Bulan',
    keadaan:
        'Belum ditutup · Sedang menutup buku · Sudah ditutup · tutup buku '
        'tidak terjadi',
    layar: [(ke: 'TutupBuku', n: 'Tutup buku'), (ke: 'WebTutupBuku', n: 'Web')],
    belum: '',
  ),
  (
    objek: 'Syarat tutup buku',
    keadaan: 'Hambatan dengan tautan perbaikan · Untuk diketahui',
    layar: [
      (ke: 'TutupBuku', n: 'Tutup buku'),
      (ke: 'Kejadian', n: 'Kejadian'),
    ],
    belum: '',
  ),
  (
    objek: 'Pernyataan kesiapan',
    keadaan:
        'Sudah dinyatakan · Perlu dinyatakan lagi · belum ada · Dibebaskan',
    layar: [(ke: 'Kesiapan', n: 'Pernyataan kesiapan')],
    belum: '',
  ),
  (
    objek: 'Rekonsiliasi',
    keadaan:
        'Rekening koran belum diisi · Sedang dikerjakan · Sudah diperiksa · '
        'Sudah dipastikan · Perlu dipastikan lagi',
    layar: [
      (ke: 'TutupBuku', n: 'Tutup buku'),
      (ke: 'WebRekonsiliasi', n: 'Web'),
      (ke: 'RekonIsi', n: 'Isi rekening koran'),
    ],
    belum: '',
  ),
  (
    objek: 'Mutasi bank',
    keadaan:
        'Belum cocok · Sebagian cocok dengan sisanya · Cocok · satu ke banyak',
    layar: [
      (ke: 'WebRekonsiliasi', n: 'Web'),
      (ke: 'RekonIsi', n: 'Isi rekening koran'),
    ],
    belum: '',
  ),
  (
    objek: 'Hitung kas',
    keadaan: 'Belum dihitung · Dihitung: Rp0 · hasil hitung',
    layar: [(ke: 'HitungKas', n: 'Hitung kas'), (ke: 'WebHitungKas', n: 'Web')],
    belum: '',
  ),
  (
    objek: 'Uang muka dan titipan',
    keadaan:
        'Belum · Sebagian · Sudah · Lewat jatuh tempo · lebih dari uang muka',
    layar: [
      (ke: 'Kewajiban', n: 'Ponsel'),
      (ke: 'WebKewajiban', n: 'Web'),
      (ke: 'KasusBaru', n: 'Kasus baru'),
    ],
    belum: '',
  ),
  (
    objek: 'Impor',
    keadaan:
        'Ditampung · Lolos pengecekan · Sudah diperiksa · Sudah diimpor · '
        'Tidak diimpor',
    layar: [(ke: 'Impor', n: 'Ponsel'), (ke: 'WebImpor', n: 'Web')],
    belum: '',
  ),
  (
    objek: 'Versi Mata Anggaran',
    keadaan: 'Draf · Sudah diperiksa · Diterbitkan',
    layar: [
      (ke: 'MataAnggaran', n: 'Ponsel'),
      (ke: 'WebMataAnggaran', n: 'Web'),
    ],
    belum: '',
  ),
  (
    objek: 'Laporan',
    keadaan:
        'Laporan sementara · Laporan resmi · Sedang disiapkan · Siap diunduh '
        '· File gagal dibuat',
    layar: [
      (ke: 'WebLaporan', n: 'F01'),
      (ke: 'TutupBuku', n: 'Tutup buku'),
      (ke: 'WebExcel', n: 'Excel'),
      (ke: 'A4F01', n: 'Halaman A4'),
      (ke: 'LihatTransaksi', n: 'Lihat transaksi'),
    ],
    belum: '',
  ),
  (
    objek: 'Simpan',
    keadaan:
        'Belum tersimpan · Tersimpan · Mencoba menyimpan lagi · Gagal '
        'disimpan · sudah diubah sejak dibuka',
    layar: [
      (ke: 'Main', n: 'Harian'),
      (ke: 'Draf', n: 'Draf'),
      (ke: 'Sambungan', n: 'Sambungan'),
    ],
    belum: '',
  ),
  (
    objek: 'Sambungan dan sesi',
    keadaan:
        'Tidak ada sambungan · tersambung lagi · sesi berakhir (lama tidak '
        'dipakai, diakhiri dari perangkat lain, wewenang berpindah)',
    layar: [
      (ke: 'Sambungan', n: 'Ponsel'),
      (ke: 'WebSambungan', n: 'Web'),
      (ke: 'Bendahara', n: 'Akhiri sesi'),
    ],
    belum: '',
  ),
  (
    objek: 'Memuat',
    keadaan: 'Sedang memuat · gagal memuat · Bukukan tidak terjadi · dimuat',
    layar: [(ke: 'Memuat', n: 'Ponsel'), (ke: 'WebMemuat', n: 'Web')],
    belum: '',
  ),
  (
    objek: 'Tanggal',
    keadaan:
        'Tanggal transaksi · tanggal dokumen · dicatat pada · dibukukan pada '
        '· bulan sudah ditutup · setelah hari ini',
    layar: [(ke: 'Tanggal', n: 'Ponsel'), (ke: 'WebTanggal', n: 'Web')],
    belum: '',
  ),
  (
    objek: 'Usulan AI',
    keadaan:
        'Belum dipakai · dipakai · diabaikan · kurang yakin · usulan lama '
        '(draf berubah) · AI tidak tersedia',
    layar: [
      (ke: 'BantuanAI', n: 'Dari kalimat'),
      (ke: 'AIFoto', n: 'Dari foto'),
      (ke: 'AIMataAnggaran', n: 'Mata Anggaran'),
      (ke: 'AIBulan', n: 'Akhir bulan'),
    ],
    belum: '',
  ),
  (
    objek: 'Wewenang Bendahara',
    keadaan:
        'Menunggu verifikasi · aktif · dicabut · belum ada Bendahara aktif',
    layar: [
      (ke: 'Awal', n: 'Pengaturan awal'),
      (ke: 'Bendahara', n: 'Bendahara'),
      (ke: 'WebVerifikasi', n: 'Petugas verifikasi'),
      (ke: 'Masuk', n: 'Masuk, termasuk administrator sistem'),
    ],
    belum: '',
  ),
];
