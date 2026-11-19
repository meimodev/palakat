import 'package:flutter/material.dart';

import '../../mock/mock.dart';
import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/rangkaian_koreksi.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

const _ma = ['5.02.01.00 Alat tulis dan fotokopi', '5.04.01.00 Konsumsi rapat'];
const _mono = TextStyle(fontFamily: PalakatText.mono);

/// Web · Koreksi dengan pembalikan (docs/build/screens/02-awal.md): the
/// original BKU-2026-0139 on the left, the reversal form, its result or the
/// closed-month refusal on the right.
class WebKoreksiScreen extends StatefulWidget {
  const WebKoreksiScreen({super.key});

  @override
  State<WebKoreksiScreen> createState() => _WebKoreksiScreenState();
}

class _WebKoreksiScreenState extends State<WebKoreksiScreen> {
  // Board state { ap, alasan, mode, ma, jadi }.
  bool _ap = false, _jadi = false;
  final _alasan = TextEditingController();
  bool _koreksi = true; // mode 'koreksi' | 'balik'
  int _maPilih = 1;

  bool get _ok => IsianAlasan.terisi(_alasan.text);

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  void _bukukan() {
    if (_ok) setState(() => _jadi = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tutup =
        context.tweak<String>('WebKoreksi', 'bulanTransaksi') ==
        'Sudah ditutup';
    final jk = context.prototipe.jabatanKosong;
    final bulan = tutup ? 'Oktober 2026' : 'November 2026';

    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _TautanSebaris(
          ke: 'WebTransaksi',
          tinggiBaris: 14 * 1.45,
          child: TautanTeks('Transaksi', ukuran: 14),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: Text(
            'BKU-2026-0139',
            style: _mono.copyWith(fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    final kiri = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _kartuAsal(c, tutup),
        if (tutup) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: c.tinta,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$bulan sudah ditutup.',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text:
                        ' Transaksi ini final dan laporan resminya dibekukan.',
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.permukaan),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _kartuPersetujuan(c, tutup, jk),
        const SizedBox(height: 14),
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dokumen pendukung',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              const Text(
                'Terverifikasi (oleh Meiske L.)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );

    final kanan = tutup
        ? _ditutup(c, bulan)
        : _jadi
        ? _hasil(c)
        : _form(c);

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        jabatanKosong: true,
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 1,
          pengguna: PenggunaKeuangan(),
        ),
        isi: [
          judul,
          BarisLentur(
            jarak: 28,
            anak: [
              Lentur(dasar: 400, child: kiri),
              Lentur(dasar: 480, tumbuh: 999, child: kanan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kartuAsal(PalakatWarna c, bool tutup) => Container(
    padding: const EdgeInsets.all(18),
    decoration: ShapeDecoration(
      color: c.permukaan,
      shape: GarisBorder.penuh(_jadi ? c.tinta3 : c.tinta, radius: 14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // space-between; when it does not fit, both shrink as CSS flex items
        // do, in proportion to their content width (badge ≈300 or ≈90,
        // number ≈101).
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: _jadi ? 300 : 90,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: ShapeDecoration(
                  color: _jadi ? c.permukaan : c.tinta,
                  shape: GarisBorder.penuh(
                    _jadi ? c.tinta3 : c.tinta,
                    radius: 6,
                  ),
                ),
                child: Text(
                  // U+200B: the browser may break after a hyphen; Flutter does not.
                  _jadi
                      ? 'Dibalik oleh No. Bukti BKU-\u200B2026-\u200B0144'
                      : 'Dibukukan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _jadi ? c.tinta2 : c.permukaan,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 101,
              child: Text(
                'BKU-\u200B2026-\u200B0139',
                semanticsLabel: 'BKU-2026-0139',
                style: _mono.copyWith(fontSize: 13, color: c.tinta2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // gap 4 + margin-top 4
        Text(
          rp(-750000),
          style: _mono.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Konsumsi rapat majelis',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Kas · diambil dari peruntukan Umum Jemaat · Lingkup Jemaat · '
          '${tutup ? '9 Oktober 2026' : '9 November 2026'}',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
        const SizedBox(height: 4),
        Text(koreksi.maAsal, style: TextStyle(fontSize: 13, color: c.tinta3)),
      ],
    ),
  );

  Widget _kartuPersetujuan(PalakatWarna c, bool tutup, bool jk) {
    final bisa = !_ap && !tutup && !_jadi;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: _ap ? c.permukaan : null,
        shape: _ap
            ? GarisBorder.penuh(c.garis, tebal: 1, radius: 14)
            : GarisBorder.putus(c.putus, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Persetujuan di luar aplikasi',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          const SizedBox(height: 4),
          Text(
            _ap ? 'Persetujuan sudah dicatat' : 'Persetujuan belum dicatat',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (_ap) ...[
            const SizedBox(height: 4),
            Gerak(
              Kerangka.muncul,
              lama: const Duration(milliseconds: 300),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Pemberi persetujuan:',
                      style: TextStyle(color: c.tinta2),
                    ),
                    const TextSpan(text: ' '),
                    const TextSpan(
                      text: 'Pdt. Lidya Rondonuwu',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(
                      text: ', Ketua BPMJ · 08/11/2026 · cara: notulen rapat',
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 10), // gap 4 + margin-top 6
            GarisLurus(warna: c.garisTegas, gaya: GayaGaris.putus),
            const SizedBox(height: 6),
            Text(
              'Dicatat oleh ${plk(jk)}, ${koreksi.dicatatPada}. '
              'Pernyataan Bendahara, bukan persetujuan di dalam aplikasi.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
          if (bisa) ...[
            const SizedBox(height: 10), // gap 4 + margin-top 6
            Align(
              alignment: Alignment.centerLeft,
              child: Tombol(
                'Catat persetujuan',
                onPressed: () => setState(() => _ap = true),
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.ringkas,
                lebarPenuh: false,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ditutup(PalakatWarna c, String bulan) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Penolakan(
        tindakan: 'koreksi dengan pembalikan',
        sebab: '$bulan sudah ditutup. Yang masih dapat Anda lakukan:',
        jalan: const [],
      ),
      const SizedBox(height: 10),
      const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Tombol(
            'Catat kejadian',
            onPressed: null,
            ke: 'WebKejadian',
            jenis: JenisTombol.tinta,
            ukuran: UkuranTombol.ringkas,
            lebarPenuh: false,
          ),
          Tombol(
            'Lampirkan dokumen pendukung',
            onPressed: null,
            ke: 'WebDokumen',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.ringkas,
            lebarPenuh: false,
          ),
        ],
      ),
      const SizedBox(height: 10),
      Text(
        'Dokumen susulan hanya mengubah Status sekarang, bukan laporan resmi.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ],
  );

  Widget _form(PalakatWarna c) {
    final ok = _ok;
    final label = _koreksi
        ? 'Bukukan pembalikan dan koreksi'
        : 'Bukukan pembalikan';
    final teks2 = TextStyle(fontSize: 14, color: c.tinta2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Koreksi dengan pembalikan',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Transaksi asal tetap tercatat. Sebuah pembalikan meniadakan '
          'pengaruhnya, lalu transaksi koreksi mencatat yang benar.',
          style: teks2,
        ),
        const SizedBox(height: 16),
        IsianAlasan(
          controller: _alasan,
          onChanged: (_) => setState(() {}),
          contoh: 'Contoh: Mata Anggaran keliru',
        ),
        const SizedBox(height: 20), // gap 16 + the inline textarea's 4 px

        ChipPilihan<bool>(
          label: 'Yang dibuat',
          pilihan: const [
            (nilai: true, teks: 'Pembalikan dan transaksi koreksi'),
            (nilai: false, teks: 'Pembalikan saja'),
          ],
          terpilih: _koreksi,
          onPilih: (v) => setState(() => _koreksi = v),
        ),
        if (_koreksi) ...[
          const SizedBox(height: 16),
          Text('Mata Anggaran pada transaksi koreksi', style: teks2),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, m) in _ma.indexed)
                  _ChipMA(
                    teks: 'Belanja $m${i == 0 ? ' · asal' : ''}',
                    dipilih: _maPilih == i,
                    onTap: () => setState(() => _maPilih = i),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Yang ikut terdampak',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              for (final t in const [
                'Bulan terdampak: November 2026 · Belum ditutup',
                'Persetujuan pada transaksi asal tidak ikut pindah ke '
                    'transaksi koreksi.',
                'Tidak ada uang muka, titipan atau pencocokan rekening koran '
                    'yang terkait.',
              ]) ...[const SizedBox(height: 4), Text(t, style: teks2)],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // The board's `disabled` button stays pressable and re-checks
            // (CONVENTIONS, TombolBersyarat).
            TekanAria(
              onTap: _bukukan,
              aktif: ok,
              petunjuk: ok ? null : 'Isi alasan untuk melanjutkan.',
              radius: 12,
              child: RupaTombol(
                label: label,
                isi: ok ? c.laut : c.garis,
                warnaTeks: ok ? c.diLaut : c.tinta3,
                radius: 12,
                tinggi: 46,
                paddingH: 20,
                lebarPenuh: false,
              ),
            ),
            if (!ok) Text('Isi alasan untuk melanjutkan.', style: teks2),
          ],
        ),
      ],
    );
  }

  Widget _hasil(PalakatWarna c) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Semantics(
        header: true,
        child: const Text(
          'Koreksi dibukukan',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
      Text(
        _koreksi
            ? 'Dua No. Bukti baru dibukukan bersama sebagai satu rangkaian. '
                  'Transaksi asal tetap tampil di daftar dan laporan.'
            : 'Satu No. Bukti baru dibukukan. Transaksi asal tetap tampil di '
                  'daftar dan laporan.',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
      const SizedBox(height: 16),
      RangkaianKoreksi(
        web: true,
        kartu: [
          const KartuRangkaian(
            noBukti: 'BKU-2026-0144',
            lencana: 'Dibukukan',
            judul: 'Pembalikan',
            jumlah: 'Rp750.000',
            keterangan:
                'Pembalikan dari No. Bukti BKU-2026-0139 · tidak dapat '
                'diubah atau dibalik',
            tundaMuncul: Duration(milliseconds: 200),
          ),
          if (_koreksi)
            KartuRangkaian(
              noBukti: 'BKU-2026-0145',
              lencana: 'Dibukukan',
              judul: 'Transaksi koreksi',
              jumlah: rp(-750000),
              keterangan:
                  'Koreksi dari No. Bukti BKU-2026-0139 · Belanja '
                  '${_ma[_maPilih]}',
              tundaMuncul: const Duration(milliseconds: 600),
            ),
        ],
      ),
      const SizedBox(height: 16),
      Gerak(
        Kerangka.muncul,
        lama: const Duration(milliseconds: 400),
        tunda: const Duration(milliseconds: 1000),
        child: Container(
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.tinta, width: 1.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Expanded(
                child: Text(
                  'Pengaruh pada Saldo buku Kas',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _koreksi ? 'Rp0' : '+Rp750.000',
                style: _mono.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Alasan: ${_alasan.text}',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ],
  );
}

/// A Mata Anggaran chip: [ChipSatu] with the board's later `border-radius:
/// 12px`.
class _ChipMA extends StatelessWidget {
  const _ChipMA({
    required this.teks,
    required this.dipilih,
    required this.onTap,
  });

  final String teks;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: 12,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih ? c.tinta : c.garisTegas,
            radius: 12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                teks,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: dipilih ? c.permukaan : c.tinta,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An inline text link with a 44 × 44 target that keeps its line height.
class _TautanSebaris extends StatelessWidget {
  const _TautanSebaris({
    required this.ke,
    required this.tinggiBaris,
    required this.child,
  });

  final String ke;
  final double tinggiBaris;
  final Widget child;

  @override
  Widget build(BuildContext context) => MarginNegatif(
    atas: (44 - tinggiBaris) / 2,
    bawah: (44 - tinggiBaris) / 2,
    child: Tautan(
      ke: ke,
      cara: Cara.naik,
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 1,
        child: child,
      ),
    ),
  );
}
