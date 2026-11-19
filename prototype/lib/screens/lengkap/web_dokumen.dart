import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

/// Web · Dokumen pendukung (docs/build/screens/06-bukti.md).
class WebDokumenScreen extends StatefulWidget {
  const WebDokumenScreen({super.key});

  @override
  State<WebDokumenScreen> createState() => _WebDokumenScreenState();
}

enum _St { kosong, unggah, verif, kecuali, gagal, tahan, tidak }

enum _Form { kecuali, tolak }

const _label = {
  _St.kosong: 'Wajib, belum ada',
  _St.unggah: 'Diunggah, belum diverifikasi',
  _St.verif: 'Terverifikasi (oleh Meiske L.)',
  _St.kecuali: 'Dikecualikan',
  _St.gagal: 'Gagal diunggah',
  _St.tahan: 'Ditahan (alasan keamanan)',
  _St.tidak: 'Tidak diperlukan (aturan: Pindah antar Kas/Bank)',
};

bool _beres(_St s) => s == _St.verif || s == _St.kecuali || s == _St.tidak;

const _awal = <String, (_St, List<String>)>{
  'a': (
    _St.unggah,
    ['16/11/2026 10.41 · nota-16-11.jpg diunggah oleh Meiske L.'],
  ),
  'b': (_St.kosong, []),
  'c': (
    _St.kecuali,
    ['22/10/2026 · Dikecualikan · alasan: kuitansi menyusul · oleh Ketua BPMJ'],
  ),
  'd': (
    _St.gagal,
    ['16/11/2026 11.05 · nota-sewa.jpg gagal diunggah · belum terlampir'],
  ),
  'e': (
    _St.tahan,
    ['15/11/2026 16.20 · scan-kuitansi.pdf ditahan (alasan keamanan)'],
  ),
  'f': (_St.tidak, []),
};

class _WebDokumenScreenState extends State<WebDokumenScreen> {
  var _pilih = 'a';
  _Form? _form;
  final _it = {
    for (final e in _awal.entries) e.key: (e.value.$1, [...e.value.$2]),
  };
  final _alasan = TextEditingController();

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  void _set(_St st, String baris) => setState(() {
    final h = _it[_pilih]!.$2..insert(0, baris);
    _it[_pilih] = (st, h);
    _form = null;
    _alasan.clear();
  });

  void _bukaForm(_Form f) {
    _alasan.clear();
    setState(() => _form = f);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final jk = PrototypeState.of(context).jabatanKosong;
    String t(String s) => tukarJkPapan('WebDokumen', jk, s);
    final cur = dokumenPendukung.firstWhere((d) => d.id == _pilih);
    final (st, hist) = _it[_pilih]!;
    final tutup = cur.id == 'c';
    final beres = _beres(st);
    final kec = _form == _Form.kecuali;
    final ok = _alasan.text.trim().isNotEmpty;
    final tinta2 = TextStyle(fontSize: 14, color: c.tinta2);

    final aksi = <Widget>[
      if (_form == null)
        ...switch (st) {
          _St.kosong => [
            _aksi(
              'Lampirkan dokumen pendukung',
              true,
              () => _set(
                _St.unggah,
                '16/11/2026 11.30 · nota baru diunggah oleh Meiske L.',
              ),
            ),
            _aksi('Catat pengecualian', false, () => _bukaForm(_Form.kecuali)),
          ],
          _St.unggah => [
            _aksi(
              'Verifikasi',
              true,
              () => _set(
                _St.verif,
                '16/11/2026 11.32 · Terverifikasi oleh Meiske L.',
              ),
            ),
            _aksi('Tolak dengan alasan', false, () => _bukaForm(_Form.tolak)),
            _aksi(
              'Lepaskan file',
              false,
              () => _set(
                _St.kosong,
                '16/11/2026 11.33 · File dilepas oleh Meiske L. · tetap di Riwayat',
              ),
            ),
          ],
          _St.gagal => [
            _aksi(
              'Coba lagi',
              true,
              () => _set(
                _St.unggah,
                '16/11/2026 11.31 · nota-sewa.jpg diunggah oleh Meiske L.',
              ),
            ),
          ],
          _St.tahan => [
            _aksi(
              'Lampirkan file lain',
              true,
              () => _set(
                _St.unggah,
                '16/11/2026 11.31 · kuitansi-foto.jpg diunggah oleh Meiske L.',
              ),
            ),
          ],
          _St.kecuali => [
            _aksi(
              tutup
                  ? 'Lampirkan dokumen susulan'
                  : 'Lampirkan dokumen pendukung',
              false,
              () => _set(
                _St.unggah,
                '16/11/2026 11.30 · ${tutup ? 'dokumen susulan' : 'nota'} '
                'diunggah oleh Meiske L.',
              ),
            ),
          ],
          _St.verif || _St.tidak => const <Widget>[],
        },
    ];

    final catatan = tutup
        ? 'Dokumen susulan disimpan dan mengubah Status sekarang. Laporan resmi Oktober 2026 tidak berubah.'
        : switch (st) {
            _St.tidak =>
              'Aturan Jemaat tidak mewajibkan dokumen untuk transaksi ini.',
            _St.gagal =>
              'File belum terlampir. Coba lagi tidak membuat salinan ganda.',
            _St.tahan => 'File ini tidak dapat dibuka dan tidak dihitung sebagai dokumen pendukung. Tetap menjadi hambatan tutup buku.',
            _ when beres => 'Memenuhi syarat tutup buku November 2026.',
            _ => 'Menjadi hambatan tutup buku November 2026 sampai terverifikasi atau dikecualikan.',
          };

    final panel = <Widget>[
      // Transaction card terpilih: 1.5 tinta.
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.permukaan,
          border: Border.all(color: c.tinta, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    cur.noBukti,
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: 13,
                      color: c.tinta2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  rp(cur.jumlah),
                  style: const TextStyle(
                    fontFamily: PalakatText.mono,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              cur.uraian,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(cur.bulan, style: TextStyle(fontSize: 13, color: c.tinta3)),
          ],
        ),
      ),
      // Status block.
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, w) in [
            Text('Dokumen pendukung', style: tinta2),
            if (tutup) ...[
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Status saat tutup buku: '),
                    TextSpan(
                      text: 'Dikecualikan (alasan: kuitansi menyusul, oleh Ketua BPMJ)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 14),
              ),
              const Text('Status sekarang:', style: TextStyle(fontSize: 14)),
            ],
            Text(
              t(_label[st]!),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: beres ? c.tinta : c.bata,
              ),
            ),
            Text(catatan, style: tinta2),
          ].indexed) ...[if (i > 0) const SizedBox(height: 4), w],
        ],
      ),
      if (_form != null)
        Gerak(
          Kerangka.muncul,
          key: ValueKey(_form),
          lama: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.permukaan,
              border: Border.all(color: c.garis),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, w) in [
                  Text(
                    kec ? 'Catat pengecualian' : 'Tolak dengan alasan',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    kec
                        ? 'Pemberi pengecualian: Ketua BPMJ, sesuai pengaturan Jemaat. Anda mencatat keputusannya.'
                        : 'Sementara (draf EC07). File yang ditolak tetap ada di Riwayat, dan statusnya dihitung lagi.',
                    style: tinta2,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Alasan '),
                        TextSpan(
                          text: '· wajib',
                          style: TextStyle(
                            color: c.tinta,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    style: tinta2,
                  ),
                  IsianTeks(
                    controller: _alasan,
                    onChanged: (_) => setState(() {}),
                    labelSemantik: 'Alasan · wajib',
                    baris: 2,
                    minTinggi: 0,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Tombol(
                        kec ? 'Catat pengecualian' : 'Tolak file ini',
                        onPressed: () {
                          final a = _alasan.text.trim();
                          if (a.isEmpty) return;
                          kec
                              ? _set(
                                  _St.kecuali,
                                  '16/11/2026 11.35 · Dikecualikan · alasan: $a · oleh Ketua BPMJ · dicatat Meiske L.',
                                )
                              : _set(
                                  _St.kosong,
                                  '16/11/2026 11.35 · File ditolak · alasan: $a · oleh Meiske L.',
                                );
                        },
                        jenis: JenisTombol.tinta,
                        ukuran: UkuranTombol.ringkas,
                        lebarPenuh: false,
                        nonaktif: !ok,
                      ),
                      Tombol(
                        'Kembali',
                        onPressed: () => setState(() => _form = null),
                        jenis: JenisTombol.kedua,
                        ukuran: UkuranTombol.ringkas,
                        lebarPenuh: false,
                      ),
                    ],
                  ),
                ].indexed) ...[if (i > 0) const SizedBox(height: 10), w],
              ],
            ),
          ),
        ),
      // Always present, even empty: the board's flex gap stays.
      Wrap(spacing: 8, runSpacing: 8, children: aksi),
      Wrap(
        spacing: 22,
        children: [
          Tautan(ke: 'WebLihatDokumen', child: _tautanFile('Lihat file')),
          Tautan(ke: 'WebUnggah', child: _tautanFile('Unggah file')),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: const Text(
              'Riwayat keputusan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          for (final (i, h) in hist.indexed) ...[
            const SizedBox(height: 6),
            // Keyed from the oldest line: a new top line animates alone; a
            // new row animates all of its lines.
            Gerak(
              Kerangka.muncul,
              key: ValueKey('$_pilih-${hist.length - i}'),
              lama: const Duration(milliseconds: 300),
              child: Text(t(h), style: tinta2),
            ),
          ],
          if (hist.isEmpty) ...[
            const SizedBox(height: 6),
            Text('Belum ada file dan belum ada keputusan.', style: tinta2),
          ],
        ],
      ),
    ];

    final tabel = Container(
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: LayoutBuilder(
          builder: (context, k) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(600, k.maxWidth),
              child: Column(
                children: [
                  for (final d in dokumenPendukung) _baris(context, d, t),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return HalamanWeb(
      jabatanKosong: true,
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 1,
        pengguna: PenggunaKeuangan(),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline breadcrumb: a 44 px target without growing its line.
            MarginNegatif(
              atas: (44 - 21.75) / 2,
              bawah: (44 - 21.75) / 2,
              child: Tautan(
                ke: 'WebTransaksi',
                cara: Cara.naik,
                child: const SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    child: TautanTeks('Transaksi', ukuran: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Dokumen pendukung',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Yang perlu diputuskan. Diunggah bukan terverifikasi; tutup buku hanya menerima Terverifikasi atau Dikecualikan.',
              style: tinta2,
            ),
          ],
        ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(dasar: 480, tumbuh: 999, child: tabel),
            Lentur(
              dasar: 380,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in panel.indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    w,
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _baris(
    BuildContext context,
    DokumenPendukung d,
    String Function(String) t,
  ) {
    final c = context.warna;
    final on = d.id == _pilih;
    final st = _it[d.id]!.$1;
    final b = _beres(st);
    return Tekan(
      onTap: () => setState(() {
        _pilih = d.id;
        _form = null;
      }),
      dipilih: on,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: on ? c.lautLembut : c.permukaan,
          border: Border(top: BorderSide(color: c.garis)),
        ),
        foregroundDecoration: on
            ? BoxDecoration(
                border: Border(left: BorderSide(color: c.laut, width: 3)),
              )
            : null,
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 14),
          child: Row(
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  d.noBukti,
                  style: const TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.uraian,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      d.bulan,
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  t(_label[st]!),
                  style: TextStyle(
                    color: b ? c.tinta : c.bata,
                    fontWeight: b ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 130,
                child: Text(
                  rp(d.jumlah),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: PalakatText.mono),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Lihat file" / "Unggah file": 14/700, inline-flex min height 44.
  Widget _tautanFile(String teks) => SizedBox(
    height: 44,
    child: Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: TautanTeks(teks, berat: FontWeight.w700, ukuran: 14),
    ),
  );

  /// Action button: min height 48, padding 0 18, radius 12, 700. Primary:
  /// `laut`/`diLaut`; outline: `permukaan`, 1.5 `tinta`.
  Widget _aksi(String label, bool utama, VoidCallback onTap) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      radius: 12,
      child: RupaTombol(
        label: label,
        isi: utama ? c.laut : c.permukaan,
        garis: utama ? null : GarisBorder.penuh(c.tinta, radius: 12),
        warnaTeks: utama ? c.diLaut : c.tinta,
        radius: 12,
        tinggi: 48,
        paddingH: 18,
        lebarPenuh: false,
      ),
    );
  }
}
