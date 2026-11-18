# Gerak

Gerak hanya dipakai saat status uang berubah.

Flutter: `PalakatMotion`. Kurva keluar `Cubic(0.2, 0.8, 0.2, 1)`.

| Nama | Lama | Dipakai untuk |
| --- | --- | --- |
| sentuh | 160 ms | Umpan balik sentuh |
| pindahLayar | 280 ms | Pindah layar, lembar bawah naik |
| kait | 450 ms | Cocokkan: dua sisi bertemu dan terkait; selisih berhitung turun ke Rp0 |
| tinta | 700 ms | Bukukan: tinta menyapu kartu, No. Bukti dicap, saldo berhitung ke angka baru |
| segelTahan | 1600 ms | Tutup buku: tombol ditahan sampai penuh |
| segel | 900 ms | Tutup buku: layar menggelap, lingkaran menutup, gembok terpasang |

- Semua gerak mati bila perangkat meminta gerak dikurangi.
- Unggah, simpan dan pembuatan file laporan selalu tampak sedang berjalan. Berhasil tidak pernah ditampilkan sebelum benar-benar berhasil.
