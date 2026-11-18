# Rangka

Keadaan memuat untuk semua modul: bentuk isi tanpa isi.

Flutter: `Container` dengan warna `garis`; boleh diberi denyut pelan, dan diam bila gerak dikurangi.

**Pemakai memberi:** jumlah dan tinggi balok yang mendekati isi sebenarnya.

- Tidak pernah menampilkan angka, nama atau status sementara.
- Diberi `role="status"` dan label “Memuat” untuk pembaca layar.
- Bila gagal, diganti pita “Gagal memuat” dengan tombol “Coba lagi”; isian orang tetap di layar.
- Tanpa sambungan: yang sudah tampil tetap bisa dibaca, dan tidak ada yang disimpan di perangkat untuk dikirim nanti.
