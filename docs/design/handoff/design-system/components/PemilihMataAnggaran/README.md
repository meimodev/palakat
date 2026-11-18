# PemilihMataAnggaran

Daftar Mata Anggaran yang dapat dicari, dengan judul kelompok yang tidak dapat dipilih, dan pembagian ke beberapa baris.

Flutter: `SearchAnchor` + `ListTile`.

**Pemakai memberi:** versi Mata Anggaran yang diterbitkan, pohonnya (Pendapatan atau Belanja), dan jumlah transaksi bila dibagi.

- Nomor dan nama tampil persis seperti tersimpan, selalu dengan nama pohonnya.
- Judul kelompok tampil tetapi tidak dapat dibukukan.
- Tidak ada pilihan “Lainnya”.
- “Simpan tanpa Mata Anggaran” hanya menyimpan draf; garisnya putus-putus.
- Saat dibagi, total baris harus sama dengan Jumlah; selisihnya ditulis “kurang Rp…” dengan `bata`.
