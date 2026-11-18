# IsianJumlah

Isian angka rupiah bulat dengan titik pemisah ribuan saat mengetik.

Flutter: `TextField` + `TextInputFormatter`, papan ketik angka. Gaya teks `jumlahIsian`.

**Pemakai memberi:** label (“Jumlah (Rp)”) dan nilai.

- Awalan “Rp” dengan `tinta3`; garis bawah 2 `tinta`.
- Kosong tampil “0” abu-abu sebagai petunjuk, bukan nilai. Belum diisi tidak sama dengan nol.
- Negatif ditulis −Rp15.000 dan tidak pernah dipotong ke nol.
