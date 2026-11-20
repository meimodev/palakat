import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../mock/mock.dart';
import '../../motion/kerangka.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tablet.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/isian_jumlah.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/pemilih_mata_anggaran.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// The board's `CFG` per kind.
typedef _Jenis = ({
  String n,
  String pohon,
  String akun,
  String per,
  String pihak,
  int tanda,
});

const Map<String, _Jenis> _cfg = {
  'pendapatan': (
    n: 'Pendapatan',
    pohon: 'Pendapatan',
    akun: 'Kas/Bank',
    per: 'Masuk ke peruntukan',
    pihak: 'Diterima dari (boleh tanpa nama)',
    tanda: 1,
  ),
  'belanja': (
    n: 'Belanja',
    pohon: 'Belanja',
    akun: 'Kas/Bank',
    per: 'Diambil dari peruntukan',
    pihak: 'Dibayar kepada',
    tanda: -1,
  ),
  'pindah': (
    n: 'Pindah antar Kas/Bank',
    pohon: '',
    akun: 'Dari Kas/Bank',
    per: '',
    pihak: '',
    tanda: 1,
  ),
};

List<BarisMataAnggaran> _daftarMA(List<String> kode) => [
  for (final k in kode)
    for (final m in mataAnggaran)
      if (m.kode == k) BarisMataAnggaran(m.kode, m.nama, grup: m.judulKelompok),
];

final _ma = {
  'Belanja': _daftarMA(pilihanMABelanja),
  'Pendapatan': _daftarMA(pilihanMAPendapatan),
};

/// Link row under the title (push).
const _tautanAtas = [
  (
    ke: Layar.bagi,
    teks: 'Bagi ke beberapa Mata Anggaran',
    param: <String, String>{},
  ),
  (ke: Layar.persembahan, teks: 'Persembahan', param: <String, String>{}),
  (
    ke: Layar.alihPeruntukan,
    teks: 'Alih peruntukan',
    param: <String, String>{},
  ),
  (ke: Layar.aiFoto, teks: 'Dari foto nota', param: <String, String>{}),
  (
    ke: Layar.persetujuan,
    param: {'id': belumDipindahId},
    teks: 'Ganti catatan persetujuan',
  ),
  (ke: Layar.tanggal, teks: 'Tanggal transaksi', param: <String, String>{}),
  (
    ke: Layar.aiMataAnggaran,
    teks: 'Usulan Mata Anggaran',
    param: <String, String>{},
  ),
  (ke: Layar.bantuanAi, teks: 'Dari kalimat', param: <String, String>{}),
];

enum _Cek { ok, gagal, info }

/// TextField merges the theme's bodyLarge (letter spacing 0.5) under
/// IsianTeks's style; the board's inputs inherit 0.
const _isian = TextStyle(letterSpacing: 0);

/// Tablet · Catat transaksi (spec 13-tabberanda.md, TabCatat).
class TabCatatScreen extends StatefulWidget {
  const TabCatatScreen({super.key});

  @override
  State<TabCatatScreen> createState() => _TabCatatScreenState();
}

class _TabCatatScreenState extends State<TabCatatScreen> {
  String _jenis = 'belanja';
  String _jm = '';
  String? _akun, _ke, _per, _ling, _maPilih;
  bool _dok = false, _posted = false;
  final _jmC = TextEditingController();
  final _pihakC = TextEditingController();
  final _urC = TextEditingController();
  final _cariC = TextEditingController();

  @override
  void dispose() {
    for (final c in [_jmC, _pihakC, _urC, _cariC]) {
      c.dispose();
    }
    super.dispose();
  }

  String _nama(String? id) {
    for (final k in kasBankJemaat) {
      if (k.id == id) return k.nama;
    }
    return '';
  }

  int get _j => int.tryParse(_jm) ?? 0;

  List<({_Cek s, String t})> _cek(_Jenis l) {
    final j = _j;
    final cek = <({_Cek s, String t})>[
      j > 0
          ? (s: _Cek.ok, t: 'Jumlah ${rp(j)}')
          : (s: _Cek.gagal, t: 'Jumlah belum diisi'),
    ];
    if (_jenis == 'pindah') {
      final okP = _akun != null && _ke != null && _akun != _ke;
      cek.add(
        okP
            ? (s: _Cek.ok, t: 'Dari ${_nama(_akun)} ke ${_nama(_ke)}')
            : (
                s: _Cek.gagal,
                t: 'Kas/Bank asal dan tujuan belum dipilih, dan harus berbeda',
              ),
      );
      cek.add((s: _Cek.ok, t: 'Bukan Pendapatan dan bukan Belanja'));
    } else {
      cek.addAll([
        _akun != null
            ? (s: _Cek.ok, t: 'Kas/Bank: ${_nama(_akun)}')
            : (s: _Cek.gagal, t: 'Kas/Bank belum dipilih'),
        _per != null
            ? (s: _Cek.ok, t: '${l.per}: $_per')
            : (s: _Cek.gagal, t: 'Peruntukan belum dipilih'),
        _ling != null
            ? (s: _Cek.ok, t: 'Lingkup: $_ling')
            : (s: _Cek.gagal, t: 'Lingkup belum dipilih'),
        _maPilih != null
            ? (s: _Cek.ok, t: 'Mata Anggaran sudah dipilih')
            : (
                s: _Cek.gagal,
                t: 'Mata Anggaran belum dipilih · tetap bisa disimpan sebagai draf',
              ),
        (
          s: _Cek.ok,
          t: 'Persetujuan: tidak diperlukan (aturan: transaksi rutin)',
        ),
      ]);
    }
    cek.add(
      _dok
          ? (s: _Cek.ok, t: 'Dokumen pendukung: diunggah, belum diverifikasi')
          : (
              s: _Cek.info,
              t: 'Dokumen pendukung: wajib, belum ada · menjadi hambatan tutup buku',
            ),
    );
    return cek;
  }

  /// Every handler but Pihak, Uraian and search is a no-op once posted.
  void _ubah(VoidCallback f) {
    if (!_posted) setState(f);
  }

  void _bukukan() {
    final gagalN = _cek(_cfg[_jenis]!).where((c) => c.s == _Cek.gagal).length;
    if (gagalN == 0) setState(() => _posted = true);
  }

  void _lagi() => setState(() {
    _jm = '';
    _akun = _ke = _per = _ling = _maPilih = null;
    _dok = _posted = false;
    for (final c in [_jmC, _pihakC, _urC, _cariC]) {
      c.clear();
    }
  });

  Widget _pilih(
    String label,
    List<({String nilai, String teks})> pilihan,
    String? terpilih,
    ValueChanged<String> onPilih, {
    String? keterangan,
  }) => ChipPilihan<String>(
    label: label,
    keterangan: keterangan,
    pilihan: pilihan,
    terpilih: terpilih,
    onPilih: (v) => _ubah(() => onPilih(v)),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final l = _cfg[_jenis]!;
    final pindah = _jenis == 'pindah';
    final cek = _cek(l);
    final gagalN = cek.where((x) => x.s == _Cek.gagal).length;
    final akun = [for (final k in kasBankJemaat) (nilai: k.id, teks: k.nama)];
    final kecil = TextStyle(fontSize: 14, color: c.tinta2);
    final mono = TextStyle(fontFamily: PalakatText.mono, fontSize: 13);

    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inline breadcrumb in a 21.75 line box; the target stays 44 high.
        MarginNegatif(
          atas: 11,
          bawah: 11,
          child: Tautan(
            ke: Layar.transaksi,
            cara: Cara.naik,
            child: const Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: TautanTeks('Transaksi', ukuran: 14),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: Text(
            'Catat transaksi',
            style: PalakatText.judulHalaman.copyWith(
              color: context.warna.tinta,
            ),
          ),
        ),
      ],
    );

    final deret = DeretTautan(
      web: true,
      anak: [
        for (final t in _tautanAtas)
          Tautan(
            ke: t.ke,
            param: t.param,
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: TautanTeks(t.teks),
            ),
          ),
      ],
    );

    final jenisChips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final k in const ['pendapatan', 'belanja', 'pindah'])
          ChipSatu(
            teks: _cfg[k]!.n,
            dipilih: _jenis == k,
            onTap: () => _ubah(() {
              _jenis = k;
              _maPilih = null;
              _ke = null;
              _cariC.clear();
            }),
          ),
      ],
    );

    final jumlah = IsianJumlah(
      label: 'Jumlah (Rp)',
      controller: _jmC,
      ukuran: UkuranJumlah.lebar,
      maks: 12,
      lebarMaks: 420,
      hanyaBaca: _posted,
      onChanged: (v) => _ubah(() => _jm = hanyaAngka(v, max: 12)),
    );

    final medan = KisiOtomatis(
      minLebar: 260,
      jarak: 18,
      anak: [
        _pilih(l.akun, akun, _akun, (v) => _akun = v),
        if (pindah)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pilih('Ke Kas/Bank', akun, _ke, (v) => _ke = v),
              Text(
                'Bukan Pendapatan dan bukan Belanja. Biaya bank dicatat sebagai Belanja tersendiri.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        if (!pindah) ...[
          _pilih(
            l.per,
            [for (final p in semuaPeruntukan) (nilai: p.nama, teks: p.nama)],
            _per,
            (v) => _per = v,
            keterangan: '· uang siapa ini',
          ),
          _pilih(
            'Lingkup',
            [for (final p in semuaLingkup) (nilai: p.nama, teks: p.nama)],
            _ling,
            (v) => _ling = v,
          ),
        ],
      ],
    );

    final lencanaPohon = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: c.tinta,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        l.pohon,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: c.permukaan,
        ),
      ),
    );

    final pemilih = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: 'Mata Anggaran ',
                children: [
                  TextSpan(
                    text: '· untuk apa',
                    style: TextStyle(color: c.tinta3),
                  ),
                ],
              ),
              style: kecil,
            ),
            lencanaPohon,
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border.all(color: c.garis),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IsianTeks(
                controller: _cariC,
                labelSemantik: 'Cari Mata Anggaran',
                petunjuk: 'Cari nomor atau nama',
                latar: c.kertas,
                minTinggi: 44,
                gaya: _isian,
                onChanged: (_) => setState(() {}),
              ),
              for (final r in PemilihMataAnggaran.saring(
                _ma[l.pohon] ?? const [],
                _cariC.text,
              ))
                if (r.grup)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 4),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: r.kode,
                            style: mono.copyWith(color: c.tinta3),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: r.nama,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.tinta2,
                            ),
                          ),
                          TextSpan(
                            text: ' · Judul kelompok, tidak dapat dibukukan',
                            style: TextStyle(fontSize: 13, color: c.tinta3),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Tekan(
                      onTap: () => _ubah(() => _maPilih = r.kode),
                      dipilih: _maPilih == r.kode,
                      radius: 10,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: ShapeDecoration(
                          color: c.permukaan,
                          shape: _maPilih == r.kode
                              ? GarisBorder.penuh(c.tinta, tebal: 2, radius: 10)
                              : GarisBorder.penuh(
                                  c.garis,
                                  tebal: 1,
                                  radius: 10,
                                ),
                        ),
                        child: Builder(
                          builder: (context) {
                            final kode = '${l.pohon} ${r.kode}';
                            final gayaKode = mono.copyWith(color: c.tinta2);
                            const gayaNama = TextStyle(
                              fontWeight: FontWeight.w600,
                            );
                            // Two `flex: 0 1 auto` spans: when they do not
                            // fit, CSS shrinks each in proportion to its
                            // max-content width, so the code wraps too.
                            // ponytail: no min-content floor; add one if a
                            // longer name ever squeezes a word apart.
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Flexible(
                                  flex: (_lebar(context, kode, gayaKode) * 10)
                                      .round(),
                                  child: Text(kode, style: gayaKode),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  flex: (_lebar(context, r.nama, gayaNama) * 10)
                                      .round(),
                                  child: Text(r.nama, style: gayaNama),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Tombol(
                  'Simpan tanpa Mata Anggaran',
                  jenis: JenisTombol.putus,
                  ukuran: UkuranTombol.mini,
                  paddingH: 16,
                  lebarPenuh: false,
                  onPressed: () => _ubah(() => _maPilih = null),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final pihakUraian = KisiOtomatis(
      minLebar: 260,
      jarak: 18,
      anak: [
        IsianTeks(
          label: l.pihak,
          controller: _pihakC,
          jarakLabel: 6,
          gaya: _isian,
          onChanged: (_) => setState(() {}),
        ),
        IsianTeks(
          label: 'Uraian',
          controller: _urC,
          jarakLabel: 6,
          gaya: _isian,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );

    final kaki = Container(
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Tanggal transaksi', style: kecil),
                const TextSpan(text: ' '),
                TextSpan(
                  text: catatPosting.tanggalPanjang,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Tekan(
            onTap: () => _ubah(() => _dok = true),
            radius: 12,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: _dok ? c.permukaan : null,
                shape: _dok
                    ? GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 12)
                    : GarisBorder.putus(c.putus, radius: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _dok
                          ? '${catatPosting.file} · Terlampir'
                          : 'Lampirkan dokumen pendukung',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _dok ? c.tinta : c.laut,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _jarak(18, [
        Align(alignment: Alignment.centerLeft, child: jumlah),
        medan,
        if (!pindah) ...[pemilih, pihakUraian],
        kaki,
      ]),
    );

    final ringkas = pindah
        ? 'Dari ${_akun == null ? '…' : _nama(_akun)} ke ${_ke == null ? '…' : _nama(_ke)}'
        : _urC.text.isNotEmpty
        ? _urC.text
        : _pihakC.text.isNotEmpty
        ? _pihakC.text
        : l.n;

    final kartu = Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: _posted ? c.permukaan : null,
        shape: _posted
            ? GarisBorder.penuh(c.tinta, radius: 16)
            : GarisBorder.putus(c.putus, radius: 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_posted)
            const LencanaStatus(
              'Draf · belum masuk saldo',
              bentuk: BentukLencana.draf,
            )
          else
            LayoutBuilder(
              builder: (context, k) {
                // Chrome breaks after these hyphens; ICU does not.
                final no = 'No. Bukti ${catatPosting.noBukti}'.replaceAll(
                  '-',
                  '-​',
                );
                final gayaNo = TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.laut,
                );
                // Two `flex: 0 1 auto` spans and a 16 gap: an overflow is
                // taken from each in proportion to its text width (the
                // badge has 9 + 1.5 a side around it, the stamp 10 + 2).
                final a = _lebar(
                  context,
                  'Dibukukan',
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                );
                final b = _lebar(context, no, gayaNo);
                final lebih = a + 21 + b + 24 + 16 - k.maxWidth;
                final kurang = lebih > 0 ? lebih / (a + b) : 0.0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: a + 21 - a * kurang,
                      child: const LencanaStatus(
                        'Dibukukan',
                        bentuk: BentukLencana.tinta,
                      ),
                    ),
                    SizedBox(
                      width: b + 24 - b * kurang,
                      child: Gerak(
                        Kerangka.muncul,
                        lama: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: c.laut, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(no, style: gayaNo),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 6),
          Text(
            rp(_j * l.tanda),
            style: TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 32,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
              color: _posted ? c.tinta : c.tinta2,
            ),
          ),
          const SizedBox(height: 6),
          Text(ringkas, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );

    Widget ikonCek(_Cek s) => switch (s) {
      _Cek.ok => const PalakatIkon(
        Ikon.terpenuhi,
        ukuran: 20,
        label: 'Terpenuhi',
      ),
      _Cek.gagal => const PalakatIkon(
        Ikon.belumTerpenuhi,
        ukuran: 20,
        label: 'Belum terpenuhi',
      ),
      _Cek.info => const PalakatIkon(
        Ikon.untukDiketahui,
        ukuran: 20,
        label: 'Untuk diketahui',
      ),
    };

    final aside = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _jarak(14, [
        kartu,
        if (!_posted) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: c.permukaan,
              border: Border.all(color: c.garis),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cek.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: i == 0
                        ? null
                        : BoxDecoration(
                            border: Border(top: BorderSide(color: c.garis)),
                          ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ikonCek(cek[i].s),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cek[i].t,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (gagalN > 0)
            Text(
              'Tidak dapat dilakukan: $gagalN syarat belum terpenuhi.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.bata,
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Drawn disabled while unmet, but each press re-checks.
              TekanAria(
                onTap: _bukukan,
                aktif: gagalN == 0,
                radius: 12,
                child: RupaTombol(
                  label: 'Periksa dan bukukan',
                  isi: gagalN > 0 ? c.garis : c.laut,
                  warnaTeks: gagalN > 0 ? c.tinta3 : c.diLaut,
                  radius: 12,
                  tinggi: 46,
                  paddingH: 20,
                  lebarPenuh: false,
                ),
              ),
              const Tombol(
                'Simpan sebagai draf',
                ke: Layar.transaksi,
                cara: Cara.ganti,
                onPressed: null,
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.ringkas,
                lebarPenuh: false,
              ),
            ],
          ),
        ],
        if (_posted) ...[
          Text(
            '${catatPosting.dibukukanPada} · tidak dapat diubah lagi.',
            style: kecil,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Tombol(
              'Catat lagi',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.ringkas,
              lebarPenuh: false,
              onPressed: _lagi,
            ),
          ),
        ],
      ]),
    );

    return Material(
      type: MaterialType.transparency,
      child: HalamanTablet(
        nav: const NavSamping(item: navKeuangan, aktif: 1),
        isi: [
          judul,
          deret,
          jenisChips,
          BarisLentur(
            jarak: 28,
            anak: [
              Lentur(dasar: 480, tumbuh: 999, child: form),
              Lentur(dasar: 360, child: aside),
            ],
          ),
        ],
      ),
    );
  }
}

/// A CSS column `gap`.
List<Widget> _jarak(double g, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: g),
    anak[i],
  ],
];

/// Max-content width of [teks] in [gaya] (CSS flex base size).
double _lebar(BuildContext context, String teks, TextStyle gaya) {
  final p = TextPainter(
    text: TextSpan(
      text: teks,
      style: DefaultTextStyle.of(context).style.merge(gaya),
    ),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final lebar = p.width;
  p.dispose();
  return lebar;
}
