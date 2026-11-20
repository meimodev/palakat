part of 'main.dart';

// ---------- H. Periksa dan bukukan ----------

enum _Cek { ok, gagal, info }

/// The board's `cek` rows, in order.
List<(_Cek, String, String?)> _cek(_MainKeadaan m) {
  final cfg = m.cfg, j = m.j;
  return [
    j > 0
        ? (_Cek.ok, 'Jumlah ${rp(j)}', null)
        : (_Cek.gagal, 'Jumlah belum diisi', null),
    if (m.pindah) ...[
      m.akun != null && m.ke != null && m.akun != m.ke
          ? (_Cek.ok, 'Dari ${_nama(m.akun)} ke ${_nama(m.ke)}', null)
          : (
              _Cek.gagal,
              'Kas/Bank asal dan tujuan belum dipilih',
              'Keduanya harus berbeda',
            ),
      (
        _Cek.ok,
        'Bukan Pendapatan dan bukan Belanja',
        'Tidak memerlukan Mata Anggaran',
      ),
    ] else ...[
      m.akun != null
          ? (_Cek.ok, 'Kas/Bank: ${_nama(m.akun)}', null)
          : (_Cek.gagal, 'Kas/Bank belum dipilih', null),
      m.per != null
          ? (_Cek.ok, '${cfg.per}: ${m.per}', null)
          : (_Cek.gagal, 'Peruntukan belum dipilih', null),
      m.ling != null
          ? (_Cek.ok, 'Lingkup: ${m.ling}', null)
          : (_Cek.gagal, 'Lingkup belum dipilih', null),
      m.ma != null
          ? (
              _Cek.ok,
              'Mata Anggaran sudah dipilih',
              '${cfg.pohon} ${m.ma!.kode} · ${m.ma!.nama}',
            )
          : (
              _Cek.gagal,
              'Mata Anggaran belum dipilih',
              'Tetap bisa disimpan sebagai draf',
            ),
      (
        _Cek.ok,
        'Persetujuan: tidak diperlukan',
        'Aturan: transaksi rutin di bawah batas Jemaat',
      ),
    ],
    m.dok == 'terlampir'
        ? (
            _Cek.ok,
            'Dokumen pendukung: diunggah, belum diverifikasi',
            'Wajib terverifikasi sebelum tutup buku',
          )
        : (
            _Cek.info,
            'Dokumen pendukung: wajib, belum ada',
            'Boleh dibukukan, tetapi menjadi hambatan tutup buku',
          ),
  ];
}

class _Periksa extends StatelessWidget {
  const _Periksa();

  @override
  Widget build(BuildContext context) {
    final m = _MainLingkup.of(context);
    final c = context.warna;
    final cek = _cek(m);
    final gagalN = cek.where((x) => x.$1 == _Cek.gagal).length;
    void keForm() => context.naikKe(Layar.catat);
    final kartuBaris = Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (k, t, s)) in cek.indexed)
            Gerak(
              Kerangka.muncul,
              lama: const Duration(milliseconds: 300),
              tunda: Duration(milliseconds: i * 90),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: i == 0
                    ? null
                    : BoxDecoration(
                        border: Border(top: BorderSide(color: c.garis)),
                      ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    switch (k) {
                      _Cek.ok => const PalakatIkon(
                        Ikon.terpenuhi,
                        label: 'Terpenuhi',
                      ),
                      _Cek.gagal => const PalakatIkon(
                        Ikon.belumTerpenuhi,
                        label: 'Belum terpenuhi',
                      ),
                      _Cek.info => const PalakatIkon(
                        Ikon.untukDiketahui,
                        label: 'Untuk diketahui',
                      ),
                    },
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (s != null)
                            Text(
                              s,
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: m.posted ? 'Sudah dibukukan' : 'Periksa dan bukukan',
          onKembali: m.posted ? null : keForm,
          jarakJudul: 8,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 18,
              children: m.posted
                  ? [const _KartuDibukukan(), const _KartuSaldo()]
                  : [
                      Kartu(
                        status: GarisStatus.draf,
                        radius: 16,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            const LencanaStatus(
                              'Draf · belum masuk saldo',
                              bentuk: BentukLencana.draf,
                            ),
                            Text(
                              m.jumlahRp,
                              style: TextStyle(
                                fontFamily: _mono,
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                color: c.tinta2,
                              ),
                            ),
                            Text(
                              m.ringkas,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              m.pindah
                                  ? 'Pindah antar Kas/Bank · 16 November 2026'
                                  : '${_nama(m.akun).isEmpty ? 'Kas/Bank belum dipilih' : _nama(m.akun)} · 16 November 2026',
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                          ],
                        ),
                      ),
                      kartuBaris,
                    ],
            ),
          ),
        ),
        if (!m.posted)
          _kaki(context, [
            if (gagalN == 0)
              Tombol('Bukukan', onPressed: m.bukukan)
            else ...[
              Semantics(
                container: true,
                liveRegion: true,
                child: Text(
                  'Tidak dapat dilakukan: $gagalN syarat belum terpenuhi. '
                  'Tidak ada yang dibukukan.',
                  style: TextStyle(
                    fontSize: 14,
                    color: c.bata,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Tombol('Ubah', jenis: JenisTombol.kedua, onPressed: keForm),
            ],
          ], jarak: 8)
        else
          Gerak(
            Kerangka.muncul,
            lama: const Duration(milliseconds: 300),
            tunda: const Duration(milliseconds: 800),
            child: _kaki(context, [
              Tombol(
                'Lihat transaksi',
                onPressed: () =>
                    _keAnak(GoRouter.of(context), 'detail/$belumDipindahId'),
              ),
              Tombol(
                'Kembali ke Beranda',
                jenis: JenisTombol.teks,
                onPressed: () => _keBeranda(context),
              ),
            ]),
          ),
      ],
    );
  }
}

/// The booked card: ink sweep (`sapu`) and the tilted No. Bukti stamp (`cap` A).
class _KartuDibukukan extends StatelessWidget {
  const _KartuDibukukan();

  @override
  Widget build(BuildContext context) {
    final m = _MainLingkup.of(context);
    final c = context.warna;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: ShapeDecoration(
              color: c.permukaan,
              shape: GarisBorder.penuh(c.tinta, radius: 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LencanaStatus.uang(StatusUang.dibukukan, kepala: true),
                    Flexible(
                      child: Gerak(
                        Kerangka.cap,
                        lama: const Duration(milliseconds: 550),
                        tunda: const Duration(milliseconds: 350),
                        kurva: PalakatMotion.keluar,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: c.laut, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'No. Bukti $_noBukti',
                            style: TextStyle(
                              fontFamily: _mono,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: c.laut,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    m.jumlahRp,
                    style: const TextStyle(
                      fontFamily: _mono,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  m.ringkas,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Dibukukan pada 16/11/2026 10.42 · tidak dapat diubah lagi',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
          const SapuTinta(),
        ],
      ),
    );
  }
}

/// The source account's balance, counting from the old to the new figure.
class _KartuSaldo extends StatelessWidget {
  const _KartuSaldo();

  @override
  Widget build(BuildContext context) {
    final m = _MainLingkup.of(context);
    final c = context.warna;
    return Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 300),
      tunda: const Duration(milliseconds: 500),
      child: Kartu(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo buku ${_nama(m.akun)}',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              Hitung(
                dari: m.saldoLama,
                nilai: m.saldo[m.akun] ?? 0,
                lama: const Duration(milliseconds: 780),
                tunda: const Duration(milliseconds: 750),
                builder: (_, n) => Text(
                  rp(n),
                  style: const TextStyle(
                    fontFamily: _mono,
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'Sebelumnya ${rp(m.saldoLama)}',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- I. Detail ----------

class _Detail extends StatelessWidget {
  const _Detail();

  @override
  Widget build(BuildContext context) {
    final m = _MainLingkup.of(context);
    final c = context.warna;
    final jk = belumDipindah(false);
    final cfg = m.cfg;
    final rinci = [
      if (m.pindah) ...[
        ('Dari Kas/Bank', _nama(m.akun)),
        ('Ke Kas/Bank', _nama(m.ke)),
      ] else ...[
        ('Kas/Bank', _nama(m.akun)),
        (cfg.per, m.per ?? ''),
        ('Lingkup', m.ling ?? ''),
        (
          'Mata Anggaran',
          m.ma == null ? '' : '${cfg.pohon} ${m.ma!.kode} ${m.ma!.nama}',
        ),
        ('Versi Mata Anggaran', '2026.1'),
        ('Persetujuan', 'Tidak diperlukan (aturan: transaksi rutin)'),
      ],
      ('Tanggal transaksi', '16/11/2026'),
      ('Dicatat pada', '16/11/2026 10.39'),
      ('Dibukukan pada', '16/11/2026 10.42'),
    ];
    final dokStatus = m.verif
        ? 'Terverifikasi (oleh Meiske L.)'
        : m.dok == 'terlampir'
        ? 'Diunggah, belum diverifikasi'
        : 'Wajib, belum ada';
    final oleh = plk(jk);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: _noBukti,
          judulMono: true,
          onKembali: () => _keBeranda(context),
          labelKembali: 'Kembali ke Beranda',
          ujung: LencanaStatus.uang(StatusUang.dibukukan, kepala: true),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.jumlahRp,
                      style: const TextStyle(
                        fontFamily: _mono,
                        fontSize: 34,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      m.ringkas,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Kartu(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      for (final (i, (k, v)) in rinci.indexed)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: i == 0
                              ? null
                              : BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: c.garis),
                                  ),
                                ),
                          child: _BarisRinci(
                            k,
                            v,
                            gayaK: TextStyle(fontSize: 14, color: c.tinta2),
                            gayaV: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Kartu(
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dokumen pendukung',
                              style: TextStyle(fontSize: 14, color: c.tinta2),
                            ),
                            Text(
                              dokStatus,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (m.dok == 'terlampir' && !m.verif)
                        Tombol(
                          'Verifikasi',
                          jenis: JenisTombol.garisLaut,
                          ukuran: UkuranTombol.kecil,
                          lebarPenuh: false,
                          onPressed: m.verifikasi,
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: const Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DefaultTextStyle.merge(
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text('10.42 · Dibukukan oleh $oleh'),
                          const Text('10.41 · Dokumen pendukung diunggah'),
                          Text('10.39 · Draf dicatat oleh $oleh'),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata '
                  'Anggaran tidak dapat diubah. Selama bulannya belum ditutup, '
                  'kesalahan dikoreksi dengan pembalikan.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
                const Tombol(
                  'Koreksi dengan pembalikan',
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                  onPressed: null,
                  ke: Layar.koreksi,
                  param: {'id': belumDipindahId},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A key–value row as CSS `display: flex; justify-content: space-between;
/// gap: 16px`: when both texts do not fit, each shrinks in proportion to its
/// own width (flex-shrink 1), so a long value also wraps the key.
class _BarisRinci extends StatelessWidget {
  const _BarisRinci(this.k, this.v, {required this.gayaK, required this.gayaV});
  final String k, v;
  final TextStyle gayaK, gayaV;

  @override
  Widget build(BuildContext context) {
    final dasar = DefaultTextStyle.of(context).style;
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, TextStyle g) {
      final p = TextPainter(
        text: TextSpan(text: t, style: dasar.merge(g)),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = p.width;
      p.dispose();
      return w;
    }

    return LayoutBuilder(
      builder: (context, ruang) {
        // min-content: the longest word (CSS `min-width: auto`).
        double kata(String t, TextStyle g) =>
            t.split(' ').map((w) => lebar(w, g)).fold(0.0, math.max);
        final kw = lebar(k, gayaK), vw = lebar(v, gayaV);
        final ada = ruang.maxWidth - 16, lebih = kw + vw - ada;
        var kk = lebih > 0 ? kw - lebih * kw / (kw + vw) : kw;
        kk = math.max(kk, kata(k, gayaK));
        kk = math.min(kk, math.max(ada - kata(v, gayaV), 0));
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: kk.ceilToDouble(),
              child: Text(k, style: gayaK),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(v, textAlign: TextAlign.right, style: gayaV),
            ),
          ],
        );
      },
    );
  }
}
