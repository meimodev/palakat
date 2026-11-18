# TombolBersyarat

Tombol tindakan utama di formulir alur: tampak mati sampai syaratnya terpenuhi, dan selalu disertai alasan.

Flutter: `FilledButton` dengan `onPressed` yang memeriksa ulang syarat; jangan memakai `onPressed: null` bila alasan penolakan perlu dibacakan.

**Pemakai memberi:** label, tindakan, dan satu syarat yang dihitung dari isian.

- Satu tombol saja. Tampilannya berubah (bidang `garis`, teks `tinta2`) selama syarat belum terpenuhi; tombolnya tidak ditukar dengan tombol lain.
- Syarat diperiksa lagi saat ditekan, dari isian terakhir. Tekanan pertama setelah mengetik harus berhasil.
- Selama belum terpenuhi, satu kalimat “Tidak dapat dilakukan: {tindakan}. {alasan}” tampil tepat di atas tombol, dan hanya alasan pertama yang belum terpenuhi.
- Alasan baru tampil setelah orang mulai mengisi; formulir kosong tidak dibuka dengan penolakan.
- Tanggal diketik sebagai hh/bb/tttt dan diperiksa saat diketik.
