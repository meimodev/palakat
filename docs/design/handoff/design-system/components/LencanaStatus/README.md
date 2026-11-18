# LencanaStatus

Lencana kecil yang menyebut status satu transaksi, satu bulan atau satu rekonsiliasi dengan kata dari glosarium.

Flutter: `Chip` atau `DecoratedBox`. Teks `keterangan` tebal 700, sudut `radius-lencana`.

**Pemakai memberi:** satu status. Bentuk mengikuti status, tidak dipilih bebas.

| Status | Bentuk |
| --- | --- |
| Draf | garis putus-putus `putus`, teks `tinta2` |
| Sudah diperiksa | garis penuh `laut`, teks `laut`, latar `permukaan` |
| Dibukukan, Sudah ditutup | bidang `tinta`, teks `permukaan` |
| Dibalik, Belum ditutup, Sedang dikerjakan | garis penuh `tinta3`, teks `tinta2` |
| Dibatalkan | bidang `garis`, teks `tinta2` |
| Sudah dipastikan | bidang `laut`, teks `diLaut` |
| Perlu dipastikan lagi | garis penuh `bata`, teks `bata` |

- Dibalik selalu disertai tautan “Dibalik oleh No. Bukti …”.
- Jangan membuat status baru dengan warna saja; status dibedakan lewat bentuk garis dan kata.
- Tidak ada status “Approve”: persetujuan terjadi di luar aplikasi dan hanya dicatat.
