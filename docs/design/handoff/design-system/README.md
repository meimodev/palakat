Palakat adalah buku kas Bendahara Jemaat GMIM, di ponsel dan web. Tampilannya tenang seperti buku besar: bentuk garis menyatakan status uang, warna dipakai hemat, angka selalu sejajar.

## Prinsip

- **Garis adalah status.** Putus-putus belum masuk saldo. Garis penuh sudah dibukukan. Tinta gelap sudah ditutup. Lihat `GarisStatus` sebelum membuat kartu, lencana atau pita baru.
- **Satu tombol utama per layar**, dengan `laut`. Tindakan lain memakai tombol kedua atau tombol teks.
- **Warna tidak pernah bekerja sendiri.** Status juga dibedakan lewat bentuk garis, ikon dan kata.
- **Belum ada bukan nol.** Yang belum diisi atau belum diketahui ditulis `—`.

## Bahasa dan isi

- Tulis dalam Bahasa Indonesia dengan kata dari glosarium. Satu konsep, satu label, di semua layar: Bukukan, Draf, Dibukukan, Dibalik, Tutup buku, Kas/Bank, peruntukan, Lingkup, Mata Anggaran, No. Bukti.
- Sapa pengguna dengan “Anda”: “Gagal disimpan. Isian Anda masih ada di layar ini.”
- Keterangan pendek dan faktual: “Hanya transaksi yang sudah dibukukan”, “2 draf · belum masuk saldo”.
- Penolakan menyebut sebab dan jalan keluar: “Tidak dapat dilakukan: Bukukan. September 2026 sudah ditutup.” lalu Pindah tanggal atau Batalkan. Jangan pernah menawarkan membuka bulan lagi.
- Tombol nonaktif selalu ditemani alasannya: “Tidak dapat dilakukan: Mata Anggaran belum dipilih.”
- Jangan memakai kata “Approve”. Persetujuan terjadi di luar aplikasi dan hanya dicatat sebagai pernyataan Bendahara. Jangan menggambar tanda tangan tiruan.
- Alasan wajib untuk Batalkan, Pindah tanggal, pembalikan, pengecualian dan Bebaskan.
- “Untuk diketahui” ditulis polos, tanpa bingkai dan tanpa warna peringatan.
- Kas/Bank, peruntukan, Lingkup dan Mata Anggaran selalu empat isian terpisah. Jangan menebak satu dari yang lain.

### Format angka dan tanggal

| Hal | Tulis |
| --- | --- |
| Rupiah | `Rp1.250.000` |
| Negatif, tidak pernah dipotong ke nol | `−Rp15.000` |
| Tanggal di tabel | `06/10/2026` |
| Tanggal di kalimat dan laporan | `6 Oktober 2026` |
| Jam | `11.05` |
| Belum ada, bukan nol | `—` |

## Warna

- Latar aplikasi `kertas`; kartu, isian dan lembar `permukaan`.
- Teks utama `tinta`, pendamping `tinta2`, keterangan dan ikon `tinta3`. Jangan memakai `putus`, `garis` atau `garisTegas` untuk teks.
- `laut` hanya untuk tindakan utama dan syarat terpenuhi atau cocok. Teks di atasnya `diLaut`, bukan putih tetap.
- `bata` hanya untuk hambatan dan kegagalan. Teks di atasnya `diBata`; latar pesan gagal `bataLembut`.
- `lautLembut` untuk yang terpilih, siap, dan latar Usulan AI.
- Di atas bidang `tinta`: lencana dan tombol memakai `permukaan`, kalimat `diTinta`, pendamping `diTinta2`.
- Fokus papan ketik: garis penuh 2px `laut` dengan jarak 2px.

## Tipografi

- Antarmuka memakai keluarga `sans` (Plus Jakarta Sans). Semua angka uang dan kode memakai keluarga `mono` (IBM Plex Mono), supaya digit sejajar dan kode tetap terbaca.
- Judul halaman web `judulHalaman`; judul layar utama ponsel `judulBesar`; judul layar dan lembar `judulLayar`; judul bagian `judulBagian`.
- Isi di ponsel `isi`, di web `isiWeb`; pendamping dan chip `pendamping`.
- `keterangan` adalah ukuran terkecil. Tidak ada teks di bawah 13.
- Saldo buku di Beranda `jumlahUtama`; isian jumlah `jumlahIsian`; jumlah di baris `jumlah`; No. Bukti dan No. MA `kode`.
- Tebal 600 untuk penekanan di dalam kalimat, 700 untuk judul, lencana dan tombol.

## Bentuk dan jarak

- Sudut: lencana `radius-lencana`, isian `radius-isian`, kartu `radius-kartu`, kartu besar `radius-kartuBesar`, sudut atas lembar bawah `radius-lembar`, chip `radius-chip`.
- Jarak kelipatan 4: `s4`, `s8`, `s12`, `s16`, `s20`, `s24`, `s40`.
- Sasaran sentuh paling kecil `size-sentuhMin`. Tombol utama setinggi `size-tombolUtama`, tombol kedua `size-tombolKedua`, isian `size-isian`.
- Kartu tidak memakai bayangan; kedalaman dinyatakan dengan garis dan bidang. Satu-satunya bayangan adalah `bayanganMelayang`, untuk dokumen yang melayang di atas latar gelap (penampil dokumen, kamera).
- Baris terpilih di tabel web ditandai garis dalam 3px `laut` di tepi kiri; tab terpilih di tepi bawah.

## Garis

| Nama | Garis | Arti |
| --- | --- | --- |
| draf | 1,5 putus-putus `putus` | Belum masuk saldo: Draf, laporan sementara, dalam perjalanan |
| dibukukan | 1 penuh `garis` | Masuk saldo dan laporan |
| terpilih | 1,5 penuh `tinta` | Kartu yang sedang dikerjakan |
| ditutup | bidang penuh `tinta` | Bulan sudah ditutup, laporan resmi |
| usulanAI | 1,5 titik-titik `laut` | Usulan AI, selalu dengan huruf miring |
| hambatan | 1,5 penuh `bata` | Hambatan dan kegagalan |

## Gerak

Gerak hanya dipakai saat status uang berubah. Semua gerak mati bila perangkat meminta gerak dikurangi.

| Nama | Lama | Dipakai untuk |
| --- | --- | --- |
| sentuh | 160 ms | Umpan balik sentuh |
| pindahLayar | 280 ms | Pindah layar, lembar bawah naik |
| kait | 450 ms | Cocokkan: dua sisi terkait |
| tinta | 700 ms | Bukukan: tinta menyapu kartu, No. Bukti dicap |
| segelTahan | 1600 ms | Tutup buku: tombol ditahan sampai penuh |
| segel | 900 ms | Tutup buku: segel terpasang |

Kurva keluar `cubic-bezier(.2, .8, .2, 1)`. Unggah, simpan dan pembuatan file laporan selalu tampak sedang berjalan; berhasil tidak pernah ditampilkan sebelum benar-benar berhasil.

## Logo dan ikon

- Tanda: `assets/Logo/palakat-mark.svg` (tinta `laut`, untuk latar terang) dan `assets/Logo/palakat-mark-terang.svg` (untuk latar gelap). Setengah putus-putus, setengah terisi: draf yang menjadi buku.
- Tanda kata: `palakat`, huruf kecil semua, keluarga `sans` tebal 700, jarak huruf rapat. Di dalam kalimat tulis “Palakat”.
- Ikon digambar garis 2px dengan ujung bulat pada kotak 24, berwarna `tinta3` atau mengikuti teksnya. Belum ada pustaka ikon yang dipilih; ikon di layar digambar satu per satu.
- Tanpa emoji. Tanda centang ✓ dipakai sebagai glif pada langkah yang sudah selesai.

## Tema gelap

Tema `gelap` dipastikan 18/11/2026. Layar di kanvas digambar dalam tema `terang`; setiap pratinjau komponen diuji di kedua tema. Maknanya tetap, hanya terang dan gelapnya yang bertukar: “sudah ditutup” menjadi bidang terang, tombol utama memakai `laut` terang dengan teks gelap (`diLaut`). Tepi isian dan garis draf paling sedikit 3:1 di kedua tema.

## Flutter

Komponen hanya menyebut peran warna, tidak pernah nilai heksanya. Warna menjadi `ColorScheme` (satu untuk tiap tema), tipografi menjadi `TextTheme`, bentuk menjadi `ShapeBorder` pada tema Material 3. Widget padanan tiap komponen ada di pedomannya.

| Token | Peran di ColorScheme |
| --- | --- |
| `kertas` | surface |
| `permukaan` | surfaceContainerLowest |
| `tinta` | onSurface |
| `tinta2` | onSurfaceVariant |
| `tinta3` | outline (teks) |
| `putus` | outline |
| `garis` | outlineVariant |
| `laut` | primary |
| `diLaut` | onPrimary |
| `lautLembut` | primaryContainer |
| `bata` | error |
| `diBata` | onError |
| `bataLembut` | errorContainer |
| `diTinta` | onInverseSurface |

Kelas token: `PalakatColors`, `PalakatText`, `PalakatRadius`, `PalakatSpace`, `PalakatMotion`. Nama di sini sama dengan nama di kode, kecuali dua awalan: `radius-lencana` adalah `PalakatRadius.lencana`, dan `size-sentuhMin` adalah `PalakatSpace.sentuhMin`.

## Platform

Keuangan adalah modul pertama. Modul lain (Dokumen gereja, Pengumuman, Warta Jemaat, Data jemaat, Ibadah dan kegiatan, Jumlah kehadiran, Panitia, Keuangan unit, Persetujuan di aplikasi) memakai sistem yang sama.

- Rancang setiap modul supaya boleh tidak ada. Modul yang Tidak aktif tidak meninggalkan jejak di navigasi, pencarian, pemberitahuan atau keadaan kosong. Lihat `LencanaModul`.
- Yang tampil mengikuti jabatan: Penatua Kolom hanya melihat Kolomnya; Sekretaris Jemaat membaca Data jemaat tanpa mengubahnya; Operator melihat semuanya tetapi melihat tidak memberi wewenang. Satu orang punya satu Beranda untuk semua jabatannya; jabatan dipilih per tindakan. Lihat `BertindakSebagai`.
- Operator yang menjalankan jabatan kosong selalu tampak sedang menjalankannya. Pakai `PitaJabatanKosong` di setiap layar modul itu. Di ponsel bentuknya satu baris di atas setiap layar; di web pita penuh di atas isi.
- Mengisi sendiri bukan memverifikasi sendiri: tidak ada yang memverifikasi pengajuannya atau pengajuan keluarganya.
- Nama pemberi persembahan dicatat hanya bila sampulnya bernama, dan hanya dilihat pemberinya dan Bendahara Jemaat.
- Nama di publikasi mengikuti `TampilanNama`. Yang Belum dikonfirmasi tidak pernah tampil di publikasi.
- Yang sudah diterbitkan (Warta Jemaat, pengumuman, dokumen) tidak berubah diam-diam; ralat adalah revisi yang tertaut.
- Jumlah kehadiran adalah jumlah saja: tanpa nama, tanpa daftar yang tidak hadir, tanpa nilai per orang.
- Semua jabatan masuk dengan kode ke nomor ponsel (WhatsApp atau SMS); email hanya cadangan untuk pemulihan akun. Akun dihubungkan ke Data jemaat lewat nama dan tanggal lahir yang diverifikasi Penatua Kolom.
- Pemberitahuan dorong hanya menyebut modul dan jenis pekerjaan. Lihat `PratinjauLayarKunci`. Keadaan memuat memakai `Rangka`.
- Pemberi persetujuan ditetapkan menurut jabatan, sekali per gereja; yang mengajukan tidak pernah menyetujui pengajuannya sendiri.
- Kategori BIPRA dihitung sendiri dari tanggal lahir, jenis kelamin dan status pernikahan: Anak sampai sebelum 12 tahun; Remaja 12 tahun sampai 17 tahun 364 hari; Pemuda 18 tahun ke atas dan belum pernah menikah; Bapa dan Ibu sudah menikah. Yang pernah menikah tetap Bapa atau Ibu.
- Email cadangan tidak wajib. Tanpa email, Operator memulihkan akun setelah Penatua Kolom memastikan identitas; tidak ada yang memulihkan akun seorang diri.
- Persetujuan yang dibuat di aplikasi ditulis “Disetujui oleh {nama}”. Persetujuan di luar aplikasi tetap pernyataan dan tidak pernah diubah labelnya.

Kata yang tidak boleh tertukar: data anggota **Diverifikasi**, dokumen pendukung **Terverifikasi**; peristiwa anggota adalah **Peristiwa**, **Kejadian** hanya untuk kejadian setelah tutup buku; izin data pribadi adalah **Izin**, **Persetujuan** hanya untuk persetujuan di luar aplikasi; ralat publikasi adalah **Revisi**, **Versi** hanya untuk Mata Anggaran.

## Alur

Setiap putaran punya artboard alur: satu perjalanan dari awal sampai akhir, dengan isian yang bisa diketik.

- Tindakan utama memakai `TombolBersyarat`; yang baru dijalankan tampil di `RiwayatAlur`.
- Alur dua sisi (pemohon dan Penatua, bendahara unit dan Bendahara Jemaat) punya pilihan “Dilihat sebagai” di atasnya. Itu alat prototipe untuk melihat kedua orang di satu artboard, bukan bagian aplikasi.
- Yang mengisi tidak memverifikasi isiannya sendiri; penolakannya tampil sebagai kalimat “Tidak dapat dilakukan”.

## Pratinjau di sini

Pratinjau komponen adalah HTML biasa yang memakai token; tidak ada pustaka komponen web. `components/bundle.js` hanya memuat `Palakat.rp(n)`, pemformat rupiah: `Palakat.rp(-15000)` menghasilkan `−Rp15.000`.

## Ponsel dan web

- Ponsel: isi `isi`; pilihan singkat di `LembarBawah`.
- Tata letak laptop hanya dirancang untuk tiga jabatan meja: Bendahara, Sekretaris Jemaat dan Operator. Layar jabatan lain dirancang untuk ponsel; di web tetap terbuka, tanpa tata letak khusus.
- Web: isi `isiWeb`; isi lembar bawah tampil sebagai panel di samping, bukan lembar yang menutupi halaman.
- Web di bawah 860px: navigasi samping menjadi laci di balik tombol “Menu” (`Drawer`); isi mendapat lebar penuh.
