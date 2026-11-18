# PitaJabatanKosong

Pita yang selalu tampil selama seorang Operator menjalankan jabatan yang belum ada pemegangnya.

Flutter: `MaterialBanner`, tetap di atas setiap layar modul itu.

**Pemakai memberi:** jabatan, unit, tanggal mulai, dan nama Operator.

- Bidang `tinta`, teks `permukaan`, pendamping `diTinta2`: keadaan yang mengunci, sama seperti “Belum ada Bendahara aktif”.
- Tampil di setiap layar selama jabatan dijalankan, dan hilang begitu pemegang jabatan ditugaskan.
- Setiap tindakan yang dijalankan mencatatnya di Riwayat: “oleh {nama}, Operator · menjalankan jabatan kosong {jabatan}”.
- Saat menutup buku, konfirmasi menyebut Operator sebagai yang menutup.
- Menjalankan jabatan kosong tidak menggantikan orang kedua bila Wajib pemeriksa kedua aktif.
