import 'package:flutter/material.dart';

import '../../shell/halaman_lembar.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';

/// Keputusan desain: the decisions sheet D01–D35, each row a link to the
/// board that draws it.
class KeputusanScreen extends StatelessWidget {
  const KeputusanScreen({super.key});

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: HalamanLembar(
      ukuran: const Size(1280, 1320),
      isi: [
        const _Kepala(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _kolom.length; i++) ...[
              if (i > 0) const SizedBox(width: 36),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = 0; j < _kolom[i].length; j++) ...[
                      if (j > 0) const SizedBox(height: 28),
                      _Kelompok(_kolom[i][j]),
                    ],
                    if (i == _kolom.length - 1) ...[
                      const SizedBox(height: 28),
                      const _KotakTerbuka(),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

typedef _Keputusan = ({int n, String teks, String? ke});
typedef _Grup = ({String judul, List<_Keputusan> baris});

const List<List<_Grup>> _kolom = [
  [
    (
      judul: 'Harian',
      baris: [
        (
          n: 1,
          teks: 'Kas/Bank, peruntukan dan Lingkup tidak pernah terisi lebih dulu.',
          ke: 'Main',
        ),
        (
          n: 2,
          teks: 'Dokumen pendukung yang belum ada menghalangi tutup buku, bukan Bukukan.',
          ke: 'Dokumen',
        ),
        (
          n: 3,
          teks:
              'Beranda dibuka dengan satu Saldo buku gabungan semua Kas/Bank.',
          ke: 'Main',
        ),
        (
          n: 4,
          teks: 'Alih peruntukan wajib menyebut dasar keputusan.',
          ke: 'AlihPeruntukan',
        ),
        (
          n: 5,
          teks: 'Pengembalian mengurangi Belanja di bulan uangnya diterima (RD04, 18/11/2026).',
          ke: 'Pengembalian',
        ),
        (
          n: 6,
          teks: 'File yang dilepas membuat dokumen pendukung kembali “Wajib, belum ada”.',
          ke: 'Dokumen',
        ),
        (
          n: 7,
          teks: 'File dokumen dibuka di dalam aplikasi, tidak diunduh ke perangkat.',
          ke: 'LihatDokumen',
        ),
      ],
    ),
    (
      judul: 'Akhir bulan',
      baris: [
        (
          n: 8,
          teks: 'Tutup buku dikonfirmasi dengan menahan tombol sampai penuh.',
          ke: 'TutupBuku',
        ),
        (n: 9, teks: 'Hitung kas diisi per pecahan uang.', ke: 'HitungKas'),
        (
          n: 10,
          teks: 'Hasil hitung kas boleh disimpan walau ada selisih.',
          ke: 'HitungKas',
        ),
        (
          n: 11,
          teks: 'Menyelesaikan Kejadian tidak dengan sendirinya membuka hambatan bulan berikutnya.',
          ke: 'Kejadian',
        ),
        (
          n: 12,
          teks: 'Pembalikan dicetak sebagai angka negatif di kolom yang sama dengan transaksi asalnya.',
          ke: 'A4F02b',
        ),
        (
          n: 13,
          teks: 'Pertanggungjawaban uang muka tidak masuk F02; ia terdaftar di F12.',
          ke: 'A4F02c',
        ),
        (
          n: 14,
          teks: 'Halaman cetak tanpa tanda tangan; hanya satu baris catatan persetujuan format.',
          ke: 'A4F01',
        ),
      ],
    ),
  ],
  [
    (
      judul: 'Uang Muka, Titipan, Penggantian biaya',
      baris: [
        (
          n: 15,
          teks: 'Daftarnya bernama “Uang yang masih berjalan”.',
          ke: 'Kewajiban',
        ),
        (
          n: 16,
          teks: 'Belanja melebihi uang muka ditolak dan dicatat sebagai Penggantian biaya.',
          ke: 'Kewajiban',
        ),
        (
          n: 17,
          teks: 'Klaim harus dicek sebelum dapat dibayar.',
          ke: 'Kewajiban',
        ),
        (
          n: 18,
          teks: 'Uang Muka tidak meminta Mata Anggaran sampai dipertanggungjawabkan.',
          ke: 'KasusBaru',
        ),
        (
          n: 19,
          teks: 'Titipan tidak meminta peruntukan; hanya Mata Anggaran yang boleh untuk Titipan.',
          ke: 'KasusBaru',
        ),
        (
          n: 20,
          teks: 'Ketiganya wajib punya dokumen pendukung; menghalangi tutup buku, bukan pembukuan.',
          ke: 'KasusBaru',
        ),
      ],
    ),
    (
      judul: 'Pengaturan dan akses',
      baris: [
        (
          n: 21,
          teks: 'Serah terima dimulai oleh Bendahara yang sedang aktif.',
          ke: 'Bendahara',
        ),
        (
          n: 22,
          teks: 'Bendahara mengisi “Boleh untuk” per baris Mata Anggaran sebelum menerbitkan.',
          ke: 'MataAnggaran',
        ),
        (
          n: 23,
          teks: 'Perubahan pengaturan berlaku mulai bulan berikutnya.',
          ke: 'UbahPengaturan',
        ),
        (
          n: 24,
          teks: 'Perubahan seri No. Bukti berlaku mulai Januari 2027.',
          ke: 'UbahPengaturan',
        ),
        (
          n: 25,
          teks: 'Semua jabatan masuk dengan kode yang dikirim ke nomor ponsel (WhatsApp atau SMS); email hanya cadangan untuk pemulihan akun (diputuskan 18/11/2026).',
          ke: 'Masuk',
        ),
        (
          n: 26,
          teks: 'Akses terbatas tetap melihat Mata Anggaran dan Lingkup.',
          ke: 'Terbatas',
        ),
        (
          n: 27,
          teks: 'Salinan TERBATAS berisi F02, F03, F05, F07 dan F12.',
          ke: 'WebPaketLaporan',
        ),
        (
          n: 28,
          teks: 'Pemberitahuan hanya di dalam aplikasi.',
          ke: 'Pemberitahuan',
        ),
      ],
    ),
  ],
  [
    (
      judul: 'Tampilan dan struktur',
      baris: [
        (
          n: 29,
          teks: 'Ponsel: lima tab bawah dengan Catat di tengah. Web: bilah samping.',
          ke: 'PetaLayar',
        ),
        (
          n: 30,
          teks: 'Laporan dapat dibaca di ponsel sebagai kartu bertumpuk.',
          ke: 'Laporan',
        ),
        (
          n: 31,
          teks: 'Usulan AI: tepi titik-titik warna Laut dan huruf miring.',
          ke: 'BantuanAI',
        ),
        // Row 32 is plain text, not a link; its suffix is drawn in tinta3.
        (
          n: 32,
          teks: 'Di tema gelap, bulan yang sudah ditutup adalah blok paling terang.',
          ke: null,
        ),
        (
          n: 33,
          teks: 'Jumlah pada jawaban pencarian dihitung dari catatan yang ditampilkan.',
          ke: 'Cari',
        ),
        (
          n: 34,
          teks: 'Hasil impor memakai kata Ditampung, Lolos pengecekan, Sudah diimpor, Tidak diimpor.',
          ke: 'Impor',
        ),
        (
          n: 35,
          teks: 'Tanpa sambungan, isian tetap di layar; tidak ada yang disimpan di perangkat untuk dikirim nanti.',
          ke: 'Sambungan',
        ),
      ],
    ),
  ],
];

class _Kepala extends StatelessWidget {
  const _Kepala();

  static const _pengantar =
      '35 pilihan yang semula belum dikonfirmasi. Tiap baris membuka layar tempat pilihan itu digambar. Fondasi, token dan komponen kini ada di sistem desain Palakat. Brief versi 2 (18/11/2026) menambah putaran 2–5; layarnya ada di halaman Putaran 2 sampai 5 ; pertanyaan 25–32 diputuskan 18/11/2026 (lihat Peta layar · Putaran 2–5). Naskah izin data pribadi memakai naskah bawaan yang belum ditinjau penasihat hukum. Diputuskan juga 18/11/2026: anggota dan pelayan lain masuk dengan kode ke nomor ponsel; akun dihubungkan ke Data jemaat lewat nama dan tanggal lahir yang diverifikasi Penatua Kolom; pemberitahuan dorong di layar kunci hanya menyebut modul dan jenis pekerjaan; pemberi persetujuan ditetapkan menurut jabatan, sekali per gereja; pengembalian kepada donatur mengurangi Pendapatan di bulan uangnya dibayarkan; Kategori BIPRA: Anak sampai sebelum 12 tahun, Remaja 12 tahun sampai 17 tahun 364 hari, Pemuda 18 tahun ke atas dan belum pernah menikah, Bapa dan Ibu sudah menikah (yang pernah menikah tetap Bapa atau Ibu; yang belum pernah menikah tetap Pemuda). Email cadangan tidak wajib; tanpa email, Operator memulihkan akun setelah Penatua Kolom memastikan identitas.';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Keputusan desain',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(_pengantar, style: TextStyle(color: c.tinta2)),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // GarisStatus "ditutup": final.
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            color: c.tinta,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Diputuskan pemilik produk · 17/11/2026',
            style: TextStyle(
              color: c.permukaan,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _Kelompok extends StatelessWidget {
  const _Kelompok(this.grup);

  final _Grup grup;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.warna.tinta, width: 1.5),
          ),
        ),
        child: Text(
          grup.judul,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      for (final b in grup.baris) _BarisKeputusan(b),
    ],
  );
}

class _BarisKeputusan extends StatelessWidget {
  const _BarisKeputusan(this.k);

  final _Keputusan k;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ke = k.ke;
    final isi = Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.garis)),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 14, color: c.tinta),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${k.n}',
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 13,
                  color: c.tinta2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ke == null
                  ? Text.rich(
                      TextSpan(
                        text: '${k.teks} ',
                        children: [
                          TextSpan(
                            text: 'Lihat sistem desain Palakat, tema Gelap.',
                            style: TextStyle(color: c.tinta3),
                          ),
                        ],
                      ),
                    )
                  : Text(k.teks),
            ),
          ],
        ),
      ),
    );
    return ke == null ? isi : Tautan(ke: ke, child: isi);
  }
}

/// Draf line (1.5 dashed putus): what is confirmed and what is still open.
class _KotakTerbuka extends StatelessWidget {
  const _KotakTerbuka();

  static const _baris = [
    'RD04 dan EC07 diputuskan 18/11/2026: pengembalian mengurangi Belanja di bulan diterima; file yang ditolak saat diunggah tidak disimpan.',
    'Nama baris dan judul laporan dipastikan seperti yang digambar.',
    'Label “Alih peruntukan” dan semua kata di glossary dipastikan. Tema gelap dipastikan.',
    'Baris Mata Anggaran di semua contoh masih karangan, belum dari sumber Jemaat.',
    'Cara Belanja dari pertanggungjawaban uang muka tampil di F01, F07 dan F09. Dua pertanggungjawaban di layar Uang Muka (Rp700.000) bertanggal November 2026, jadi laporan Oktober mencetak Rp0 dan lampiran 2 Nihil.',
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(c.putus, radius: 14),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dipastikan 18/11/2026, dan yang masih terbuka',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            for (final t in _baris) ...[
              const SizedBox(height: 6),
              Text(t, style: TextStyle(color: c.tinta2)),
            ],
          ],
        ),
      ),
    );
  }
}
