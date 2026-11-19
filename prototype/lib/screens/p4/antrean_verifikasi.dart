import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';

const _stem = 'AntreanVerifikasi';
const _k0 = 'Antrean',
    _k1 = 'Kembalikan dengan alasan',
    _k2 = 'Milik keluarga sendiri',
    _k3 = 'Jabatan kosong',
    _k4 = 'Tidak ada yang menunggu';

/// 75 · Verifikasi data (spec 20). View = `k ?? keadaan`; `k` resets when the
/// panel's `keadaan` changes.
class AntreanVerifikasiScreen extends StatefulWidget {
  const AntreanVerifikasiScreen({super.key});

  @override
  State<AntreanVerifikasiScreen> createState() => _State();
}

class _State extends State<AntreanVerifikasiScreen> {
  String? _k;
  String? _keadaan;

  /// Bumped by the self link: the canvas reloads the board (scroll to top).
  int _muat = 0;

  void _ke(String k) => setState(() => _k = k);

  @override
  Widget build(BuildContext context) {
    final keadaan = context.tweak<String>(_stem, 'keadaan');
    if (_keadaan != null && keadaan != _keadaan) _k = null;
    _keadaan = keadaan;
    final view = _k ?? keadaan;
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Verifikasi data',
            anakJudul:
                'Hanya data Kolom 7; milik keluarga sendiri pergi ke Syamas',
            kembaliKe: 'DataAnggota',
            labelKembali: 'Kembali ke Data jemaat',
          ),
          Expanded(
            // A new key per view: the scroll area jumps to the top.
            child: SingleChildScrollView(
              key: ValueKey((view, _muat)),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: _isi(view),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _isi(String view) {
    final c = context.warna;
    final keterangan = TextStyle(fontSize: 13, color: c.tinta3);
    const diajukan = LencanaStatus('Diajukan', bentuk: BentukLencana.garis);
    return switch (view) {
      _k1 => [
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              const KepalaKartu(
                judul: 'Peristiwa: Baptisan · Gabriel Wenas',
                ujung: diajukan,
              ),
              Text(
                'Diajukan Novita Wenas, 15/11/2026',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              const BarisInfo('Tanggal baptisan', '08/11/2026'),
              const BarisInfo('Lampiran', 'surat-baptis.jpg'),
            ],
          ),
        ),
        IsianTeks(
          nilaiAwal: 'Nama di surat baptis “Gabriel J. Wenas”; mohon samakan.',
          label: 'Alasan · wajib',
          jarakLabel: 6,
          // letterSpacing 0: TextField otherwise keeps the M3 bodyLarge 0.5.
          gaya: TextStyle(fontSize: 14, color: c.tinta2, letterSpacing: 0),
          baris: 3,
          hanyaBaca: true,
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Kembalikan',
              onPressed: () => _ke(_k0),
              jenis: JenisTombol.tinta,
            ),
            Tombol(
              'Verifikasi data',
              onPressed: () => _ke(_k0),
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
            ),
            Tombol(
              'Tidak diterima',
              onPressed: () => _ke(_k0),
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.sedang,
            ),
          ],
        ),
      ],
      _k2 => [
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              const KepalaKartu(
                judul: 'Perubahan data · Keluarga Rumagit',
                ujung: diajukan,
              ),
              Text(
                'Diajukan Pnt. Hendrik Rumagit, 14/11/2026',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
        const Penolakan(
          tindakan: 'Verifikasi data',
          sebab: 'ini data keluarga Anda sendiri.',
          jalan: [],
        ),
        Text(
          'Diteruskan kepada Sym. Greis Mamahit, Syamas Kolom 7. Mengisi '
          'sendiri bukan berarti memverifikasi sendiri.',
          style: keterangan,
        ),
      ],
      _k3 => [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.tinta,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Penatua Kolom 2: jabatan kosong.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ' Verifikasi Kolom 2 dijalankan Operator Yanti Sumual '
                      'sampai ada pemegang jabatan.',
                  style: TextStyle(color: c.diTinta2),
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.permukaan),
          ),
        ),
        const _Baris(
          'Permohonan menjadi anggota · Kevin Rompas',
          'Kolom 2 · diajukan 15/11/2026',
          diajukan,
          ke: 'PermohonanAnggota',
        ),
        const _Baris(
          'Peristiwa: Kematian · Yohanis Rompas',
          'Kolom 2 · diajukan keluarga 16/11/2026',
          diajukan,
          ke: 'Peristiwa',
        ),
      ],
      _k4 => [
        Kartu(
          status: GarisStatus.draf,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              const Text(
                'Tidak ada data yang menunggu verifikasi',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Permohonan, perubahan data dan peristiwa dari Kolom 7 akan '
                'muncul di sini.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
      ],
      _ => [
        const _Baris(
          'Permohonan menjadi anggota · Novita Wenas',
          'Diajukan 16/11/2026 · izin data pribadi diberikan',
          diajukan,
          ke: 'PermohonanAnggota',
        ),
        const _Baris(
          'Konfirmasi keluarga · Wenas-Lasut',
          '4 orang dari buku anggota',
          diajukan,
          ke: 'KonfirmasiKeluarga',
        ),
        const _Baris(
          'Peristiwa: Baptisan · Gabriel Wenas',
          'Diajukan 15/11/2026',
          diajukan,
          ke: 'Peristiwa',
        ),
        const _Baris(
          'Peristiwa: Pindah Kolom · Keluarga Lasut',
          'Dari Kolom 4 ke Kolom 7 · berlaku 01/12/2026',
          diajukan,
          ke: 'Peristiwa',
        ),
        // Self link: the canvas reloads the board, so `k` resets and the
        // panel's view shows (board parity; CONVENTIONS "Settled conflicts").
        _Baris(
          'Perubahan data · Keluarga Rumagit',
          'Milik keluarga Anda sendiri · diteruskan ke Syamas Kolom 7',
          const LencanaStatus('Ke Syamas', bentuk: BentukLencana.abu),
          ke: 'AntreanVerifikasi',
          diSini: () => setState(() {
            _k = null;
            _muat++;
          }),
        ),
        Text(
          'Anda melihat data lengkap hanya untuk anggota dan keluarga Kolom '
          '7, serta permohonan pindah ke Kolom 7.',
          style: keterangan,
        ),
      ],
    };
  }
}

/// Row card: a full-width link, title 16/600, caption 13 `tinta3`, badge,
/// chevron 18.
class _Baris extends StatelessWidget {
  const _Baris(
    this.judul,
    this.keterangan,
    this.lencana, {
    required this.ke,
    this.diSini,
  });

  final String judul, keterangan;
  final Widget lencana;
  final String ke;
  final VoidCallback? diSini;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: ke,
      radius: 14,
      diSini: diSini,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.permukaan,
          border: Border.all(color: c.garis),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    keterangan,
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ),
            lencana,
            PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
          ],
        ),
      ),
    );
  }
}
