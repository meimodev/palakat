# BertindakSebagai

Cara satu orang dengan beberapa jabatan bekerja di satu Beranda, tanpa berganti jabatan.

Flutter: `Card` + `Chip`; pilihan jabatan dengan `OutlinedButton`.

**Pemakai memberi:** daftar jabatan aktif orang itu, dan untuk setiap tindakan, jabatan mana yang berwenang.

- Satu orang satu akun dan satu Beranda. Pekerjaan dari semua jabatannya tampil bersama; tidak ada tombol ganti jabatan.
- Setiap butir menyebut jabatannya di baris kedua: “Sebagai {jabatan} · …”. Orang dengan satu jabatan tidak perlu label itu.
- Bila tepat satu jabatan berwenang, aplikasi memakainya sendiri dan menyebutnya sebelum tindakan disetujui: “Anda bertindak sebagai {jabatan}”.
- Bila dua jabatan berwenang, aplikasi bertanya. Aplikasi tidak pernah menebak.
- Jabatan yang dipakai tercatat di Riwayat dan tidak dapat diubah setelahnya.
- Jabatan yang lain tidak membuka jalan menyetujui atau memverifikasi pengajuan sendiri.
