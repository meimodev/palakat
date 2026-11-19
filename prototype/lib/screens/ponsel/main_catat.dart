part of 'main.dart';

// ---------- F. Catat form ----------

/// Label above a form block: 14 `tinta2`, margin-bottom 8.
Widget _labelIsian(BuildContext context, String teks, [String? tambahan]) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: teks,
          children: [
            if (tambahan != null)
              TextSpan(
                text: ' $tambahan',
                style: TextStyle(color: context.warna.tinta3),
              ),
          ],
        ),
        style: TextStyle(fontSize: 14, color: context.warna.tinta2),
      ),
    );

/// Footer of the full views: padding 12 20 22, top line `garis`.
Widget _kaki(
  BuildContext context,
  List<Widget> anak, {
  double jarak = 6,
  bool latar = true,
}) => Container(
  padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
  decoration: BoxDecoration(
    color: latar ? context.warna.permukaan : null,
    border: Border(top: BorderSide(color: context.warna.garis)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: jarak,
    children: anak,
  ),
);

class _Catat extends StatefulWidget {
  const _Catat();
  @override
  State<_Catat> createState() => _CatatState();
}

class _CatatState extends State<_Catat> {
  late final _MainKeadaan _m = _MainLingkup.baca(context);
  late final _jumlah = TextEditingController(text: titik(_m.jumlah));
  late final _pihak = TextEditingController(text: _m.pihak);
  late final _uraian = TextEditingController(text: _m.uraian);

  @override
  void dispose() {
    _jumlah.dispose();
    _pihak.dispose();
    _uraian.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _MainLingkup.of(context);
    final c = context.warna;
    final cfg = m.cfg;
    final (simpanTeks, simpanWarna) = switch (m.simpan) {
      KeadaanSimpan.belum => ('Belum tersimpan', c.tinta3),
      KeadaanSimpan.tersimpan => ('Tersimpan', c.laut),
      KeadaanSimpan.gagal => ('Gagal disimpan', c.bata),
      KeadaanSimpan.mencoba => ('Mencoba menyimpan lagi…', c.tinta3),
    };
    List<({String nilai, String teks})> daftar(List<String> l) => [
      for (final x in l) (nilai: x, teks: x),
    ];
    final akunPilihan = [for (final a in _akun) (nilai: a.id, teks: a.n)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: cfg.judul,
          onKembali: () => _keBeranda(context),
          // StatusSimpan pads 8 itself; KepalaPonsel already gives 8.
          ujung: Text(
            simpanTeks,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: simpanWarna,
            ),
          ),
        ),
        if (m.simpan == KeadaanSimpan.gagal)
          PitaGagalSimpan(onCobaLagi: m.cobaLagi),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 18,
              children: [
                IsianJumlah(
                  label: 'Jumlah (Rp)',
                  controller: _jumlah,
                  ukuran: UkuranJumlah.besar,
                  onChanged: (v) =>
                      m.ubah(() => m.jumlah = hanyaAngka(v, max: 12)),
                ),
                ChipPilihan<String>(
                  label: cfg.akun,
                  pilihan: akunPilihan,
                  terpilih: m.akun,
                  onPilih: (v) => m.ubah(() => m.akun = v),
                ),
                if (m.pindah)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ChipPilihan<String>(
                        label: 'Ke Kas/Bank',
                        pilihan: akunPilihan,
                        terpilih: m.ke,
                        onPilih: (v) => m.ubah(() => m.ke = v),
                      ),
                      Text(
                        'Pindah antar Kas/Bank bukan Pendapatan dan bukan '
                        'Belanja. Biaya bank dicatat sebagai Belanja tersendiri.',
                        style: TextStyle(fontSize: 13, color: c.tinta3),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 18,
                    children: [
                      ChipPilihan<String>(
                        label: cfg.per,
                        keterangan: '· uang siapa ini',
                        pilihan: daftar([
                          for (final p in semuaPeruntukan) p.nama,
                        ]),
                        terpilih: m.per,
                        onPilih: (v) => m.ubah(() => m.per = v),
                      ),
                      ChipPilihan<String>(
                        label: 'Lingkup',
                        pilihan: daftar([for (final l in semuaLingkup) l.nama]),
                        terpilih: m.ling,
                        onPilih: (v) => m.ubah(() => m.ling = v),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _labelIsian(context, 'Mata Anggaran', '· untuk apa'),
                          _TombolMa(m: m),
                        ],
                      ),
                      IsianTeks(
                        label: cfg.pihak,
                        controller: _pihak,
                        onChanged: (v) => m.ubah(() => m.pihak = v),
                      ),
                    ],
                  ),
                IsianTeks(
                  label: 'Uraian',
                  controller: _uraian,
                  onChanged: (v) => m.ubah(() => m.uraian = v),
                ),
                Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(color: c.garis),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Tanggal transaksi',
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                      ),
                      Tautan(
                        ke: 'Tanggal',
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: c.tinta,
                            decoration: TextDecoration.underline,
                            decorationColor: c.tinta,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 6,
                            children: [
                              const Text('16 November 2026'),
                              Text(
                                'Ubah',
                                style: TextStyle(
                                  color: c.laut,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _labelIsian(context, 'Dokumen pendukung'),
                    _Dokumen(m: m),
                  ],
                ),
              ],
            ),
          ),
        ),
        _kaki(context, [
          Tombol(
            'Periksa dan bukukan',
            onPressed: () => GoRouter.of(context).push('/Main/periksa'),
          ),
          Tombol(
            'Simpan sebagai draf',
            jenis: JenisTombol.teks,
            onPressed: () {
              m.simpanDraf();
              _keMain(GoRouter.of(context));
            },
          ),
        ]),
      ],
    );
  }
}

/// The Mata Anggaran field button (PemilihMataAnggaran field, board form).
class _TombolMa extends StatelessWidget {
  const _TombolMa({required this.m});
  final _MainKeadaan m;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ma = m.ma;
    return Tekan(
      radius: 12,
      onTap: () => GoRouter.of(context).push('/Main/mata-anggaran'),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: ShapeDecoration(
          color: ma == null ? null : c.permukaan,
          shape: ma == null
              ? GarisBorder.putus(c.putus, radius: 12)
              : GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 12),
        ),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ma == null
                        ? 'Draf boleh disimpan tanpa Mata Anggaran'
                        : '${m.cfg.pohon} ${ma.kode}',
                    style: TextStyle(
                      fontFamily: _mono,
                      fontSize: 13,
                      color: c.tinta2,
                    ),
                  ),
                  Text(
                    ma == null ? 'Mata Anggaran belum dipilih' : ma.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
          ],
        ),
      ),
    );
  }
}

class _Dokumen extends StatelessWidget {
  const _Dokumen({required this.m});
  final _MainKeadaan m;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kotak = ShapeDecoration(
      color: c.permukaan,
      shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 12),
    );
    const pad = EdgeInsets.symmetric(horizontal: 14, vertical: 12);
    return switch (m.dok) {
      'unggah' => Container(
        padding: pad,
        decoration: kotak,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sedang diunggah…',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            BatangIsi(lama: Duration(milliseconds: 1200), tinggi: 4),
          ],
        ),
      ),
      'terlampir' => Gerak(
        Kerangka.muncul,
        lama: PalakatMotion.pindahLayar,
        child: Container(
          padding: pad,
          decoration: kotak,
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 48,
                decoration: ShapeDecoration(
                  color: c.lautLembut,
                  shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 6),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'nota-16-11.jpg · Terlampir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Diunggah, belum diverifikasi',
                      style: TextStyle(fontSize: 13, color: c.tinta2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      _ => Tekan(
        radius: 12,
        onTap: m.lampirkan,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          decoration: ShapeDecoration(
            shape: GarisBorder.putus(c.putus, radius: 12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              PalakatIkon(Ikon.kamera, ukuran: 20, warna: c.laut),
              Flexible(
                child: Text(
                  'Lampirkan dokumen pendukung',
                  style: TextStyle(fontWeight: FontWeight.w600, color: c.laut),
                ),
              ),
            ],
          ),
        ),
      ),
    };
  }
}

// ---------- G. Pilih Mata Anggaran ----------

class _PilihMa extends StatefulWidget {
  const _PilihMa();
  @override
  State<_PilihMa> createState() => _PilihMaState();
}

class _PilihMaState extends State<_PilihMa> {
  // bukaMa clears the search: each visit starts empty.
  final _cari = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _MainLingkup.of(context);
    final c = context.warna;
    final pohon = m.cfg.pohon;
    final q = _q.toLowerCase();
    final rows = [
      for (final r in _pohonMA(pohon))
        if (q.isEmpty ||
            r.judulKelompok ||
            '${r.kode} ${r.nama}'.toLowerCase().contains(q))
          r,
    ];
    void keForm() => context.kembaliKe('/Main/catat');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Pilih Mata Anggaran',
          onKembali: keForm,
          ujung: pohon.isEmpty
              ? null
              : LencanaStatus(pohon, bentuk: BentukLencana.tinta, kepala: true),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: IsianTeks(
            controller: _cari,
            petunjuk: 'Cari nomor atau nama',
            labelSemantik: 'Cari Mata Anggaran',
            latar: c.kertas,
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final r in rows)
                if (r.judulKelompok)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.kode,
                          style: TextStyle(
                            fontFamily: _mono,
                            fontSize: 13,
                            color: c.tinta3,
                          ),
                        ),
                        Text(
                          r.nama,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.tinta2,
                          ),
                        ),
                        Text(
                          'Judul kelompok, tidak dapat dibukukan',
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ),
                  )
                else
                  Tekan(
                    onTap: () {
                      m.ubah(() => m.ma = r);
                      keForm();
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 60),
                      padding: const EdgeInsets.fromLTRB(14, 6, 0, 6),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: c.garis)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$pohon ${r.kode}',
                            style: TextStyle(
                              fontFamily: _mono,
                              fontSize: 13,
                              color: c.tinta2,
                            ),
                          ),
                          Text(
                            r.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        _kaki(
          context,
          [
            const Tombol(
              'Bagi ke beberapa Mata Anggaran',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              onPressed: null,
              ke: 'Bagi',
            ),
            Tombol(
              'Simpan tanpa Mata Anggaran',
              jenis: JenisTombol.putus,
              ukuran: UkuranTombol.sedang,
              onPressed: () {
                m.ubah(() => m.ma = null);
                keForm();
              },
            ),
          ],
          jarak: 8,
          latar: false,
        ),
      ],
    );
  }
}
