/// "Journeys by role" of 03-screens-and-flows.md, as navigation.md 4.3 gives
/// them: role headings and step numbers as written, one entry per quoted title.
library;

/// One tap target: [jenis] 'Ponsel', 'Laptop' or 'A4', and the board stem.
typedef Tujuan = ({String jenis, String stem});

/// A quoted title (with its qualifier, if any) and the boards it opens.
/// No [ke]: a plain-text note.
typedef Entri = ({String judul, String? catatan, List<Tujuan> ke});

/// A role heading and its numbered steps (step n is `langkah[n - 1]`).
typedef Perjalanan = ({String peran, List<List<Entri>> langkah});

Tujuan _p(String s) => (jenis: 'Ponsel', stem: s);
Tujuan _l(String s) => (jenis: 'Laptop', stem: s);
Entri _e(String judul, List<Tujuan> ke, [String? catatan]) =>
    (judul: judul, catatan: catatan, ke: ke);

/// Phone board and its laptop twin.
Entri _d(String judul, String ponsel, String laptop, [String? catatan]) =>
    _e(judul, [_p(ponsel), _l(laptop)], catatan);

/// Phone only.
Entri _o(String judul, String ponsel, [String? catatan]) =>
    _e(judul, [_p(ponsel)], catatan);

final List<Perjalanan> perjalananJabatan = [
  (
    peran: 'Anyone, before a post applies',
    langkah: [
      [_d('Alur · Masuk dan menghubungkan akun', 'AlurMasuk', 'WebAlurMasuk')],
      [_d('Beranda', 'BerandaJabatan', 'WebBerandaJabatan', 'page Putaran 2')],
      [_d('Alur · Akun saya', 'AkunSaya', 'WebAkunSaya')],
      [_d('Keadaan umum', 'KeadaanUmum', 'WebKeadaanUmum')],
    ],
  ),
  (
    peran: 'Bendahara Jemaat (phone and laptop)',
    langkah: [
      [
        _d('3 · Pengaturan awal dan saldo awal', 'Awal', 'WebAwal'),
        _d(
          '24 · Pengaturan awal: identitas dan daftar',
          'AwalIsian',
          'WebAwalIsian',
        ),
        _d('8 · Terbitkan Mata Anggaran', 'MataAnggaran', 'WebMataAnggaran'),
      ],
      [
        _e('1 · Harian: catat sampai bukukan', [
          _p('Main'),
          _l('WebBeranda'),
          _l('WebTransaksi'),
          _l('WebCatat'),
        ]),
        _d('6 · Bagi ke beberapa Mata Anggaran', 'Bagi', 'WebBagi'),
        _d(
          '10 · Persembahan dengan beberapa bagian',
          'Persembahan',
          'WebPersembahan',
        ),
        _d(
          '11 · Uang Muka, Titipan, Penggantian biaya',
          'Kewajiban',
          'WebKewajiban',
        ),
        _d('19 · Dokumen pendukung', 'Dokumen', 'WebDokumen'),
        _d('20 · Draf', 'Draf', 'WebDraf'),
      ],
      [
        _d('4 · Koreksi, persetujuan, kejadian', 'Koreksi', 'WebKoreksi'),
        _d('25 · Pengembalian', 'Pengembalian', 'WebPengembalian'),
        _d('Alur · Pengembalian', 'AlurPengembalian', 'WebAlurPengembalian'),
        _d('31 · Alih peruntukan', 'AlihPeruntukan', 'WebAlihPeruntukan'),
      ],
      [
        _e('2 · Akhir bulan: rekonsiliasi dan tutup buku', [
          _p('TutupBuku'),
          _l('WebRekonsiliasi'),
          _l('WebTutupBuku'),
        ]),
        _d('5 · Hitung kas', 'HitungKas', 'WebHitungKas'),
        _d(
          '30 · Rekonsiliasi: isi rekening koran dan cocok sebagian',
          'RekonIsi',
          'WebRekonIsi',
        ),
      ],
      [
        _e('15 · Laporan', [
          _p('Laporan'),
          _l('WebLaporan'),
          _l('WebPaketLaporan'),
        ]),
        _e('the A4 pages', [
          for (final s in [
            'A4F01',
            'A4F02a',
            'A4F02b',
            'A4F02c',
            'A4F14',
            'A4Sementara',
            'A4Terbatas',
          ])
            (jenis: 'A4', stem: s),
        ]),
        _d('16 · Daftar Bukti Kas dan celah nomor', 'Bukti', 'WebBukti'),
        _d('18 · Ekspor data Jemaat', 'Ekspor', 'WebEkspor'),
      ],
      [
        _e('9 · Bendahara, sesi, serah terima', [
          _p('Bendahara'),
          _l('WebSerahTerima'),
        ]),
        _d('Alur · Kas/Bank unit', 'KasUnit', 'WebKasUnit'),
        _d('87 · Hambatan dari unit', 'SelesaikanUnit', 'WebSelesaikanUnit'),
      ],
    ],
  ),
  (
    peran: 'Sekretaris Jemaat (phone and laptop)',
    langkah: [
      [
        _d('Dokumen gereja', 'DokumenGereja', 'WebDokumenGereja'),
        _d('Terbitkan dokumen', 'TerbitDokumen', 'WebTerbitDokumen'),
        _d('Alur · Menerbitkan dokumen', 'AlurDokumen', 'WebAlurDokumen'),
      ],
      [
        _d('Permohonan surat', 'PermohonanSurat', 'WebPermohonanSurat'),
        _d('Alur · Permohonan surat', 'AlurSurat', 'WebAlurSurat'),
      ],
      [
        _d('Pengumuman', 'Pengumuman', 'WebPengumuman'),
        _d('Warta Jemaat · edisi 22/11/2026', 'WartaEditor', 'WebWartaEditor'),
        _d('Alur · Warta mingguan', 'AlurWarta', 'WebAlurWarta'),
        _e('A4 · Warta Jemaat edisi 22/11/2026', [
          (jenis: 'A4', stem: 'A4Warta'),
        ]),
      ],
      [_d('Tampilkan nama (pengecualian)', 'BukaNama', 'WebBukaNama')],
    ],
  ),
  (
    peran: 'Operator (phone and laptop)',
    langkah: [
      [
        _d('Impor buku anggota', 'ImporBuku', 'WebImporBuku'),
        _d('Alur · Buku anggota', 'AlurKeluarga', 'WebAlurKeluarga'),
        _d('Kemungkinan data ganda', 'DataGanda', 'WebDataGanda'),
      ],
      [
        _d('Menjalankan jabatan kosong', 'JabatanKosong', 'WebJabatanKosong'),
        _d(
          'Alur · Menjalankan jabatan kosong',
          'AlurJabatanKosong',
          'WebAlurJabatanKosong',
        ),
        _e(
          'on finance boards switch jabatanKosong on',
          const [],
          'the switch is in the Keadaan panel',
        ),
      ],
      [
        _d('Cari orang', 'CariOrang', 'WebCariOrang'),
        _d('Alur · Memulihkan akun anggota', 'AlurPulihkan', 'WebAlurPulihkan'),
      ],
    ],
  ),
  (
    peran: 'Pimpinan Jemaat yang berwenang (phone)',
    langkah: [
      [_o('Modul', 'Modul'), _o('Alur · Modul', 'AlurModul')],
      [
        _o('Penugasan jabatan', 'Penugasan'),
        _o('Alur · Penugasan jabatan', 'AlurPenugasan'),
        _o('Pelimpahan tugas', 'Pelimpahan'),
        _o('Alur · Pelimpahan tugas', 'AlurPelimpahan'),
      ],
      [
        _o('Alur · Pemberi persetujuan', 'PemberiPersetujuan'),
        _o('Alur · Membentuk Panitia', 'AlurPanitiaBaru'),
        _o('Permintaan dana', 'PermintaanDana', 'approving'),
      ],
    ],
  ),
  (
    peran: 'Penatua Kolom (phone)',
    langkah: [
      [
        _o('Verifikasi data', 'AntreanVerifikasi'),
        _o('Konfirmasi keluarga', 'KonfirmasiKeluarga'),
        _o('Data anggota dan keluarga', 'DataAnggota'),
      ],
      [
        _o('Peristiwa', 'Peristiwa'),
        _o('Alur · Peristiwa', 'AlurPeristiwa', 'verifier side'),
        _o('Alur · Menjadi anggota', 'AlurAnggota', 'verifier side'),
      ],
      [
        _o('Ibadah dan kegiatan', 'Ibadah'),
        _o('Jumlah kehadiran', 'Kehadiran'),
        _o('Alur · Ibadah dan kehadiran', 'AlurIbadah'),
      ],
      [
        _o(
          'Alur · Memulihkan akun anggota',
          'AlurPulihkan',
          'confirming identity',
        ),
      ],
    ],
  ),
  (
    peran: 'Bendahara unit and committee officers (phone)',
    langkah: [
      [
        _o('Keuangan Kolom 7', 'KeuanganUnit'),
        _o('Alur · Keuangan unit', 'AlurUnit'),
        _o('Pernyataan kesiapan per peruntukan', 'Kesiapan'),
      ],
      [
        _o('Permintaan dana', 'PermintaanDana'),
        _o('Alur · Permintaan dana', 'AlurDana'),
      ],
      [
        _o('Panitia Natal 2026', 'Panitia'),
        _o('Alur · Panitia', 'AlurPanitia'),
      ],
    ],
  ),
  (
    peran: 'Anggota jemaat (phone)',
    langkah: [
      [
        _o('Permohonan menjadi anggota', 'PermohonanAnggota'),
        _o('Alur · Menjadi anggota', 'AlurAnggota'),
      ],
      [
        _o('Tampilan nama saya di publikasi', 'TampilanNama'),
        _o('Alur · Data saya', 'AlurNama'),
        _o('Cabut izin dan hapus data saya', 'CabutIzin'),
      ],
      [
        _o('Peristiwa', 'Peristiwa'),
        _o('Permohonan surat', 'PermohonanSurat'),
        _o('Warta Jemaat', 'WartaArsip'),
        _o('Persembahan saya', 'PersembahanSaya'),
      ],
    ],
  ),
];
