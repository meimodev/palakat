import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// The two guard views (README 3.6; the board's other four states are
/// dropped, D9), as direct items of the boards' gap-16 column. Body text
/// inherits 16 (phone) or 15 (web). [kembali] is the boards' link button,
/// built by each screen with its own target.
class IsiKeadaanUmum extends StatelessWidget {
  const IsiKeadaanUmum({
    super.key,
    required this.penjaga,
    required this.kembali,
  });

  final Penjaga penjaga;
  final Widget kembali;

  /// [tambah]: the board's link buttons are `<a>` (content-box), so their
  /// basis and max-width exclude padding 32 and the line.
  static Widget baris(Widget tombol, {double tambah = 0}) => BarisLentur(
    jarak: 8,
    anak: [Lentur(dasar: 150 + tambah, maks: 340 + tambah, child: tombol)],
  );

  /// The outline link's `min-height: 48` is content-box too: 48 + 2 × 1.5.
  static Widget barisKembali(Widget tombol) => baris(
    ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 51),
      child: tombol,
    ),
    tambah: 35,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const tebal = TextStyle(fontWeight: FontWeight.w700);
    Widget catatan(String t) =>
        Text(t, style: TextStyle(fontSize: 13, color: c.tinta3));
    final anak = switch (penjaga) {
      Penjaga.tidakBerwenang => [
        const Penolakan(
          tindakan: 'Buka halaman ini',
          sebab: 'jabatan Anda tidak melihat data ini.',
          jalan: [],
        ),
        catatan(
          'Bila ini keliru, hubungi Pimpinan Jemaat yang berwenang; '
          'penugasan jabatan tidak diubah dari sini.',
        ),
        barisKembali(kembali),
      ],
      Penjaga.modulTidakAktif => [
        Kartu(
          status: GarisStatus.draf,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Halaman ini tidak tersedia', style: tebal),
              const SizedBox(height: 6),
              Text(
                'Tautan yang Anda buka menuju bagian yang tidak dipakai '
                'Jemaat Karunia.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
        catatan(
          'Nama modulnya tidak disebut: modul yang tidak aktif tidak '
          'meninggalkan jejak.',
        ),
        barisKembali(kembali),
      ],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          anak[i],
        ],
      ],
    );
  }
}

/// 61 · Keadaan umum (spec 17-keadaanumum.md), as the phone guard view.
class KeadaanUmumScreen extends StatelessWidget {
  const KeadaanUmumScreen({super.key, required this.penjaga});

  /// The guard reason the router passes.
  final Penjaga penjaga;

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Keadaan umum',
          anakJudul: 'Satu pola untuk semua modul',
          kembaliKe: Layar.beranda,
          labelKembali: 'Kembali ke Beranda',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: IsiKeadaanUmum(
              penjaga: penjaga,
              kembali: Tombol(
                'Kembali ke Beranda',
                onPressed: null,
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                ke: Layar.beranda,
                cara: Cara.naik,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
