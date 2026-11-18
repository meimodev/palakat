# LencanaModul

Lencana keadaan modul dan jabatan.

Flutter: `Chip` atau `DecoratedBox`, sama seperti `LencanaStatus`.

**Pemakai memberi:** satu keadaan.

- Modul: Aktif (bidang `laut`), Tidak aktif (putus-putus `putus`), Hanya baca (garis `tinta3`).
- Modul yang Tidak aktif tidak tampil di navigasi, pencarian, pemberitahuan atau keadaan kosong; lencananya hanya ada di layar Modul.
- Menonaktifkan modul tidak menghapus apa pun: modul menjadi Hanya baca.
- Jabatan: Aktif, Berakhir, Jabatan kosong (garis `bata`, karena ada pekerjaan yang tidak berjalan).
