# Tombol

Tombol utama, kedua, teks, dan tombol tahan untuk tindakan permanen.

Flutter: `FilledButton`, `OutlinedButton`, `TextButton`; tombol tahan memakai `GestureDetector` + `AnimatedContainer`.

**Pemakai memberi:** label berupa kata kerja dari glosarium (Bukukan, Ubah, Simpan sebagai draf) dan, bila nonaktif, alasannya.

- Satu tombol utama (`laut`, teks `diLaut`, tinggi `size-tombolUtama`) per layar.
- Tombol kedua: garis 1,5 `tinta` di atas `permukaan`.
- Tombol permanen (Tutup buku): bidang `tinta`, ditekan dan ditahan 1600 ms sampai terisi `laut`.
- Tombol nonaktif (`garis` dengan teks `tinta3`) selalu ditemani kalimat “Tidak dapat dilakukan: …” yang menyebut sebabnya.
- Sasaran sentuh paling kecil `size-sentuhMin`.
