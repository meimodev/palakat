import 'package:flutter/material.dart';

import '../../mock/jabatan_kosong.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/status_simpan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// 20 · Draf: pindah tanggal, batalkan, hapus (docs/build/screens/06-bukti.md).
class DrafScreen extends StatefulWidget {
  const DrafScreen({super.key});

  @override
  State<DrafScreen> createState() => _DrafScreenState();
}

enum _St { draf, batal, hapus }

enum _Lembar { pindah, batal }

const _bulanTutup = 'September 2026';
const _bulanBuka = ['Oktober 2026', 'November 2026'];

class _DrafScreenState extends State<DrafScreen> {
  var _st = _St.draf;
  var _bulan = _bulanTutup;
  var _tgl = '28 September 2026';
  _Lembar? _lembar;
  var _ke = 'November 2026';
  var _muat = false;
  var _alasanAkhir = '';
  final _hist = ['28/09/2026 16.10 · Draf dicatat oleh Meiske L.'];
  final _alasan = TextEditingController();

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  void _buka(_Lembar l, bool konflik) {
    if (konflik) return;
    _alasan.clear();
    setState(() => _lembar = l);
  }

  void _simpan() {
    final a = _alasan.text.trim();
    if (a.isEmpty) return;
    setState(() {
      if (_lembar == _Lembar.pindah) {
        _bulan = _ke;
        _tgl = _ke == 'November 2026' ? '16 November 2026' : '31 Oktober 2026';
        _hist.insert(
          0,
          '16/11/2026 11.20 · Pindah tanggal ke $_ke · alasan: $a · oleh Meiske L.',
        );
      } else {
        _st = _St.batal;
        _alasanAkhir = a;
        _hist.insert(
          0,
          '16/11/2026 11.20 · Dibatalkan · alasan: $a · oleh Meiske L.',
        );
      }
      _lembar = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final jk = belumDipindah(false);
    final konflik = belumDipindah(false) && !_muat;
    final kosong = belumDipindah(false);
    String t(String s) => s;
    final tutup = _bulan == _bulanTutup;
    final draf = _st == _St.draf;
    final pindah = _lembar == _Lembar.pindah;
    final redup = TextStyle(fontSize: 13, color: c.tinta3);

    final isi = <Widget>[
      if (konflik && draf)
        PitaDiubahOrangLain(
          oleh: plk(jk),
          jam: '16/11/2026 10.58',
          onMuat: () => setState(() => _muat = true),
        ),
      if (draf) ...[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: ShapeDecoration(
            shape: GarisBorder.putus(c.putus, radius: 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LencanaStatus(
                'Draf · belum masuk saldo',
                bentuk: BentukLencana.draf,
              ),
              const SizedBox(height: 6),
              Text(
                kosong ? '—' : '−Rp650.000',
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: c.tinta2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                kosong ? 'Draf kosong' : 'Honor pemusik',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                t(
                  kosong
                      ? 'Belum ada isian · dibuat 16/11/2026 11.02'
                      : 'Bank BNI ··4821 · tanggal transaksi $_tgl',
                ),
                style: redup,
              ),
              const SizedBox(height: 6),
              Text(
                '$_bulan${tutup ? ' · Sudah ditutup' : ' · Belum ditutup'}',
                style: redup,
              ),
            ],
          ),
        ),
        if (tutup && !kosong)
          const Penolakan(
            tindakan: 'Bukukan',
            sebab:
                'September 2026 sudah ditutup, dan draf ini tidak pernah '
                'masuk laporannya. Yang masih dapat Anda lakukan: pindah '
                'tanggal ke bulan yang belum ditutup, atau batalkan.',
            jalan: [],
          ),
      ],
      if (_st == _St.batal)
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('batal'),
          lama: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.permukaan,
              border: Border.all(color: c.garis),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.garis,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Dibatalkan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.tinta2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '−Rp650.000',
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: c.tinta3,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: c.tinta3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Honor pemusik',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  t('Alasan: $_alasanAkhir'),
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dibatalkan oleh ${plk(jk)}, 16/11/2026 11.20 · tidak '
                  'pernah punya No. Bukti · hanya dapat dilihat',
                  style: redup,
                ),
              ],
            ),
          ),
        ),
      if (_st == _St.hapus)
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('hapus'),
          lama: const Duration(milliseconds: 300),
          child: Semantics(
            container: true,
            liveRegion: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: ShapeDecoration(
                shape: GarisBorder.putus(c.putus, radius: 14),
              ),
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Draf kosong dihapus.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text:
                          ' Hanya draf tanpa isian yang dapat dihapus; yang '
                          'lain dibatalkan dengan alasan.',
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: const Text(
              'Riwayat',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          for (final h in _hist) ...[
            const SizedBox(height: 6),
            Text(t(h), style: TextStyle(fontSize: 14, color: c.tinta2)),
          ],
        ],
      ),
    ];

    Widget kedua(String label, VoidCallback onTap, {bool kunci = false}) {
      final tombol = Tombol(
        label,
        onPressed: onTap,
        jenis: JenisTombol.kedua,
        ukuran: UkuranTombol.sedang,
        paddingH: 20,
      );
      // Board `disabled` with its full look kept: announced as disabled, the
      // conflict card above is the reason.
      return kunci
          ? Semantics(
              button: true,
              enabled: false,
              label: label,
              child: ExcludeSemantics(child: tombol),
            )
          : tombol;
    }

    final bawah = Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, w) in [
            if (!tutup && !kosong)
              const Tombol(
                'Periksa dan bukukan',
                onPressed: null,
                ke: Layar.keuangan,
                cara: Cara.ganti,
                paddingH: 20,
              ),
            if (!kosong) ...[
              kedua(
                'Pindah tanggal',
                () => _buka(_Lembar.pindah, konflik),
                kunci: konflik,
              ),
              kedua(
                'Batalkan',
                () => _buka(_Lembar.batal, konflik),
                kunci: konflik,
              ),
            ],
            if (kosong)
              kedua('Hapus draf', () => setState(() => _st = _St.hapus)),
          ].indexed) ...[if (i > 0) const SizedBox(height: 8), w],
        ],
      ),
    );

    final lembar = _lembar == null
        ? null
        : LembarBawah(
            judul: pindah ? 'Pindah tanggal' : 'Batalkan draf',
            anakJudul: pindah
                ? 'Hanya bulan sesudahnya yang belum ditutup. Draf tetap '
                      'Draf, dan tanda sudah diperiksa atau persetujuan yang '
                      'ada akan hilang.'
                : 'Draf yang dibatalkan tidak pernah punya No. Bukti dan '
                      'tetap dapat dilihat bersama alasannya.',
            onTutup: () => setState(() => _lembar = null),
            pegangan: false,
            masuk: Kerangka.muncul,
            labelTirai: 'Kembali ke draf',
            isi: [
              if (pindah)
                ChipPilihan<String>(
                  label: 'Pindah ke bulan',
                  pilihan: [
                    for (final b in _bulanBuka)
                      (nilai: b, teks: '$b · Belum ditutup'),
                  ],
                  terpilih: _ke,
                  onPilih: (b) => setState(() => _ke = b),
                ),
              // The board's textarea is inline in a div: the line box adds
              // about 5 px below it.
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: IsianAlasan(
                  controller: _alasan,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Tombol(
                pindah ? 'Pindah tanggal ke $_ke' : 'Batalkan draf',
                onPressed: _simpan,
                jenis: JenisTombol.tinta,
                paddingH: 20,
                nonaktif: !IsianAlasan.terisi(_alasan.text),
              ),
              Tombol(
                'Kembali',
                onPressed: () => setState(() => _lembar = null),
                jenis: JenisTombol.teks,
                warnaTeks: c.tinta,
                paddingH: 6,
              ),
            ],
          );

    return LayarPonsel(
      layarKeuangan: true,
      overlay: [if (lembar != null) Positioned.fill(child: lembar)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Draf',
            kembaliKe: Layar.keuangan,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in isi.indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    w,
                  ],
                ],
              ),
            ),
          ),
          if (draf) bawah,
        ],
      ),
    );
  }
}
