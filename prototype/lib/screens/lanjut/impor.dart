import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

const _nama = [
  'Ditampung',
  'Lolos pengecekan',
  'Sudah diperiksa',
  'Sudah diimpor',
];

enum _Jenis { ok, ganda, tolak }

/// kas-november.xlsx as the phone board reads it (06-bukti.md, Impor).
const _baris = <({String asli, String ur, String baca, String ma, _Jenis j})>[
  (
    asli: '02/11/26 · Persembahan Mgg · 3.100.000',
    ur: 'Persembahan Ibadah Minggu',
    baca: '02/11/2026 · Kas · Rp3.100.000 masuk',
    ma: 'Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu',
    j: _Jenis.ok,
  ),
  (
    asli: '04/11/26 · Bayar PLN · -1250000',
    ur: 'Bayar PLN',
    baca: '04/11/2026 · Bank BNI ··4821 · Rp1.250.000 keluar',
    ma: 'Belanja 5.01.02.00 Listrik, air dan telepon',
    j: _Jenis.ok,
  ),
  (
    asli: '4 Nop · PLN nov · 1.250.000,-',
    ur: 'PLN nov',
    baca: '04/11/2026 · Bank BNI ··4821 · Rp1.250.000 keluar',
    ma: 'Belanja 5.01.02.00 Listrik, air dan telepon',
    j: _Jenis.ganda,
  ),
  (
    asli: '08/11/26 · Honor pemusik · 650rb',
    ur: 'Honor pemusik',
    baca: '08/11/2026 · Kas · Rp650.000 keluar',
    ma: '',
    j: _Jenis.ok,
  ),
  (
    asli: '31/11/26 · ATK · 85.000',
    ur: 'ATK',
    baca: 'tanggal tidak terbaca · Kas · Rp85.000 keluar',
    ma: 'Belanja 5.02.01.00 Alat tulis dan fotokopi',
    j: _Jenis.tolak,
  ),
];

class ImporScreen extends StatefulWidget {
  const ImporScreen({super.key});

  @override
  State<ImporScreen> createState() => _ImporScreenState();
}

class _ImporScreenState extends State<ImporScreen> {
  int _st = 0;

  /// '' | 'tetap' | 'tidak'.
  String _ganda = '';

  bool get _tunggu => _st == 1 && _ganda.isEmpty;

  String get _ket => switch (_st) {
    0 => 'Belum ada yang masuk saldo.',
    1 =>
      _tunggu
          ? 'Putuskan dulu baris yang mungkin ganda.'
          : 'Pengecekan selesai. Baca sekali lagi.',
    2 => 'Siap diimpor.',
    _ =>
      _ganda == 'tetap'
          ? '4 baris sudah diimpor · 1 tidak diimpor.'
          : '3 baris sudah diimpor · 2 tidak diimpor.',
  };

  void _maju() {
    if (!_tunggu) setState(() => _st = (_st + 1).clamp(0, 3));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        jabatanKosong: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Impor',
              anakJudul: 'kas-november.xlsx · 5 baris',
              kembaliKe: 'Lainnya',
              labelKembali: 'Kembali ke Lainnya',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: i <= _st
                            ? BoxDecoration(
                                color: c.tinta,
                                borderRadius: BorderRadius.circular(3),
                              )
                            : ShapeDecoration(
                                shape: GarisBorder.putus(c.putus, radius: 3),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_st + 1} dari 4 · ${_nama[_st]}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(_ket, style: TextStyle(fontSize: 14, color: c.tinta2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < _baris.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _kartu(context, i),
                      ),
                  ],
                ),
              ),
            ),
            if (_st < 3)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                decoration: BoxDecoration(
                  color: c.permukaan,
                  border: Border(top: BorderSide(color: c.garis)),
                ),
                child: TombolBersyarat(
                  label: const [
                    'Jalankan pengecekan',
                    'Tandai sudah diperiksa',
                    'Impor',
                  ][_st],
                  tindakan: 'Tandai sudah diperiksa',
                  alasan: _tunggu
                      ? 'Putuskan dulu baris yang mungkin ganda.'
                      : '',
                  onPressed: _maju,
                  // The board's reason is the step caption above the list.
                  sudahMulai: false,
                  warnaSiap: _st == 2 ? JenisTombol.utama : JenisTombol.tinta,
                  teksBelumRedup: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _kartu(BuildContext context, int i) {
    final c = context.warna;
    final d = _baris[i];
    final st = _st;
    var hasil = _nama[st];
    var bentuk = st == 3
        ? BentukLencana.tinta
        : st == 0
        ? BentukLencana.draf
        : BentukLencana.garis;
    var cat = '';
    var pilih = false;
    if (st >= 1 && d.j == _Jenis.tolak) {
      (hasil, bentuk, cat) = (
        'Tidak diimpor',
        BentukLencana.bata,
        'Alasan: tanggal 31/11 tidak ada.',
      );
    }
    if (st >= 1 && d.j == _Jenis.ganda && _ganda == 'tidak') {
      (hasil, bentuk, cat) = (
        'Tidak diimpor',
        BentukLencana.garis,
        'Alasan: sama dengan baris 2.',
      );
    }
    if (st >= 1 && d.j == _Jenis.ganda && _ganda.isEmpty) {
      (hasil, bentuk, cat, pilih) = (
        'Mungkin ganda',
        BentukLencana.peran,
        'Tanggal, Kas/Bank dan jumlah sama dengan baris 2.',
        true,
      );
    }
    final kecil = TextStyle(fontSize: 13, color: c.tinta2);
    Widget keputusan(String label, String nilai) => Expanded(
      child: Tekan(
        onTap: () => setState(() => _ganda = nilai),
        radius: 10,
        child: RupaTombol(
          label: label,
          isi: c.permukaan,
          garis: GarisBorder.penuh(c.tinta, radius: 10),
          warnaTeks: c.tinta,
          radius: 10,
          tinggi: 44,
          paddingH: 0,
          ukuranTeks: 14,
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ShapeDecoration(
        color: st == 0 ? null : c.permukaan,
        shape: st == 0
            ? GarisBorder.putus(c.putus, radius: 14)
            : GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Baris ${i + 1}', style: kecil)),
              const SizedBox(width: 8),
              LencanaStatus(hasil, bentuk: bentuk),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Di file: ${d.asli}',
            style: kecil.copyWith(fontFamily: PalakatText.mono),
          ),
          const SizedBox(height: 6),
          Text(
            d.ur,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text('Dibaca sebagai: ${d.baca}', style: kecil),
          Text(
            d.ma.isEmpty ? 'Mata Anggaran belum dipilih' : d.ma,
            style: kecil.copyWith(color: d.ma.isEmpty ? c.bata : c.tinta2),
          ),
          if (cat.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(cat, style: TextStyle(fontSize: 13, color: c.tinta)),
          ],
          if (pilih) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                keputusan('Tetap impor', 'tetap'),
                const SizedBox(width: 8),
                keputusan('Tidak diimpor', 'tidak'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
