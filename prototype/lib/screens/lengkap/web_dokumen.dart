import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/dokumen.dart';
import '../../widgets/penolakan.dart';
import 'dokumen.dart' show putuskanDokumen;

/// Web · Dokumen pendukung (docs/build/screens/06-bukti.md).
class WebDokumenScreen extends ConsumerStatefulWidget {
  const WebDokumenScreen({super.key});

  @override
  ConsumerState<WebDokumenScreen> createState() => _WebDokumenScreenState();
}

enum _Form { kecuali, tolak }

class _WebDokumenScreenState extends ConsumerState<WebDokumenScreen> {
  _Form? _form;
  Refusal? _pesan;
  final _alasan = TextEditingController();

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  Future<void> _putuskan(BarisDokumen b, String aksi, [String a = '']) async {
    final r = await putuskanDokumen(ref, b, aksi, a);
    if (!mounted) return;
    setState(() {
      _pesan = r;
      if (r == null) {
        _form = null;
        _alasan.clear();
      }
    });
  }

  void _bukaForm(_Form f) {
    _alasan.clear();
    setState(() {
      _form = f;
      _pesan = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final daftar = ref.watch(daftarDokumenProvider);
    final cur = ref.watch(dokumenTerpilihProvider);
    final tinta2 = TextStyle(fontSize: 14, color: c.tinta2);
    if (cur == null) {
      return HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 1),
        isi: [Text('Tidak ada dokumen yang perlu diputuskan.', style: tinta2)],
      );
    }
    final tutup = cur.tutup;
    final beres = cur.beres;
    final kec = _form == _Form.kecuali;
    final ok = _alasan.text.trim().isNotEmpty;
    final bulan = cur.bulan.split(' · ').first;
    void unggah() {
      ref.read(pilihanDokumenProvider.notifier).pilih(cur.id);
      context.dorongKe(Layar.fotoDokumen, anak: 'unggah');
    }

    final aksi = <Widget>[
      if (_form == null)
        ...switch (cur.status) {
          EvidenceStatus.requiredMissing => [
            _aksi('Lampirkan dokumen pendukung', true, unggah),
            _aksi('Catat pengecualian', false, () => _bukaForm(_Form.kecuali)),
          ],
          EvidenceStatus.uploaded => [
            _aksi('Verifikasi', true, () => _putuskan(cur, 'verif')),
            _aksi('Tolak dengan alasan', false, () => _bukaForm(_Form.tolak)),
            _aksi('Lepaskan file', false, () => _putuskan(cur, 'lepas')),
            if (!tutup)
              _aksi(
                'Catat pengecualian',
                false,
                () => _bukaForm(_Form.kecuali),
              ),
          ],
          EvidenceStatus.exceptionAccepted => [
            _aksi(
              tutup
                  ? 'Lampirkan dokumen susulan'
                  : 'Lampirkan dokumen pendukung',
              false,
              unggah,
            ),
          ],
          _ => const <Widget>[],
        },
    ];
    final catatan = tutup
        ? 'Dokumen susulan disimpan dan mengubah Status sekarang. Laporan resmi $bulan tidak berubah.'
        : switch (cur.status) {
            EvidenceStatus.notRequired =>
              'Aturan Jemaat tidak mewajibkan dokumen untuk transaksi ini.',
            _ when beres => 'Memenuhi syarat tutup buku $bulan.',
            _ =>
              'Menjadi hambatan tutup buku $bulan sampai terverifikasi atau dikecualikan.',
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
                    cur.no,
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: 13,
                      color: c.tinta2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  cur.jumlah,
                  style: const TextStyle(
                    fontFamily: PalakatText.mono,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              cur.transaksi.description,
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
            Text(
              cur.label,
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
                        kec ? 'Simpan pengecualian' : 'Tolak file ini',
                        onPressed: () {
                          final a = _alasan.text.trim();
                          if (a.isEmpty) return;
                          _putuskan(cur, kec ? 'kecuali' : 'tolak', a);
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
      if (_pesan case final r?)
        Penolakan(
          tindakan: r.action,
          sebab:
              r.because +
              (r.whoCanAct == null
                  ? ''
                  : ' Yang perlu bertindak: ${r.whoCanAct}.'),
          jalan: const [],
          ukuranTeks: 14,
        ),
      // Always present, even empty: the board's flex gap stays.
      Wrap(spacing: 8, runSpacing: 8, children: aksi),
      Wrap(
        spacing: 22,
        children: [
          if (cur.menunggu != null || cur.status == EvidenceStatus.verified)
            Tautan(
              ke: Layar.lihatDokumen,
              param: {'id': cur.id},
              child: _tautanFile('Lihat file'),
            ),
          Tekan(onTap: unggah, child: _tautanFile('Unggah file')),
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
          for (final (i, h) in cur.riwayat.indexed) ...[
            const SizedBox(height: 6),
            // Keyed from the oldest line: a new top line animates alone; a
            // new row animates all of its lines.
            Gerak(
              Kerangka.muncul,
              key: ValueKey('${cur.id}-${cur.riwayat.length - i}'),
              lama: const Duration(milliseconds: 300),
              child: Text(h, style: tinta2),
            ),
          ],
          if (cur.riwayat.isEmpty) ...[
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
                children: [for (final d in daftar) _baris(context, d, cur.id)],
              ),
            ),
          ),
        ),
      ),
    );

    return HalamanWeb(
      layarKeuangan: true,
      nav: const NavSamping(item: navKeuangan, aktif: 1),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline breadcrumb: a 44 px target without growing its line.
            MarginNegatif(
              atas: (44 - 21.75) / 2,
              bawah: (44 - 21.75) / 2,
              child: Tautan(
                ke: Layar.transaksi,
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

  Widget _baris(BuildContext context, BarisDokumen d, String pilih) {
    final c = context.warna;
    final on = d.id == pilih;
    final b = d.beres;
    return Tekan(
      onTap: () {
        ref.read(pilihanDokumenProvider.notifier).pilih(d.id);
        setState(() {
          _form = null;
          _pesan = null;
        });
      },
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
                  d.no,
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
                      // Chrome keeps "Kas/Bank" whole (390 wide).
                      d.transaksi.description.replaceAll(
                        'Kas/Bank',
                        'Kas/\u2060Bank',
                      ),
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
                  d.label,
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
                  d.jumlah,
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
