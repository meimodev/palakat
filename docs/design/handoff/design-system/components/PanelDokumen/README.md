# PanelDokumen

Daftar dokumen pendukung satu transaksi dengan status tiap dokumen.

Flutter: `ListTile` + `LinearProgressIndicator`.

**Pemakai memberi:** daftar dokumen dengan statusnya, nama file, siapa dan kapan.

- Diunggah bukan terverifikasi. Tutup buku hanya menerima Terverifikasi atau Dikecualikan.
- Gagal diunggah dan Ditolak memakai `bata` dan selalu menawarkan langkah berikutnya.
- File yang ditolak saat diunggah tidak disimpan; orangnya mengunggah file lain (EC07).
- Pengecualian selalu menyebut alasan dan pemberinya.
