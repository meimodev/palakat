# PratinjauLayarKunci

Contoh pemberitahuan dorong seperti yang terlihat di layar kunci, dipakai di Akun saya.

Flutter: `Container` biasa sebagai contoh; pemberitahuan aslinya dikirim lewat Firebase Cloud Messaging.

**Pemakai memberi:** nama modul dan jenis pekerjaan dengan jumlahnya.

- Isi pemberitahuan dorong selalu “{modul}: {jumlah} {jenis pekerjaan}”. Tidak ada nama orang, nama keluarga, Kolom, atau jumlah uang.
- Rinciannya baru terlihat setelah aplikasi dibuka dan orangnya masuk.
- Pemberitahuan dorong hanya pelengkap: pekerjaan yang sama selalu ada di Beranda dan di Pemberitahuan.
- Bila izin pemberitahuan ditolak di ponsel, aplikasi mengatakannya sekali dan tidak meminta lagi di setiap layar.
