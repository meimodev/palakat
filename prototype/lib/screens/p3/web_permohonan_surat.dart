import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import 'permohonan_surat_bagian.dart';

/// Web · Permohonan surat (17-keadaanumum.md): PermohonanSurat at the desk.
class WebPermohonanSuratScreen extends StatefulWidget {
  const WebPermohonanSuratScreen({super.key});

  @override
  State<WebPermohonanSuratScreen> createState() =>
      _WebPermohonanSuratScreenState();
}

class _WebPermohonanSuratScreenState extends State<WebPermohonanSuratScreen>
    with KeadaanPermohonan {
  @override
  String get stem => 'WebPermohonanSurat';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    void terbit() => pilih('Diterbitkan');
    final isi = switch (tampil) {
      'Menerbitkan surat' => [
        BarisLentur(
          jarak: 28,
          jarakBaris: 20,
          anak: [
            const Lentur(dasar: 420, tumbuh: 1.3, child: KartuPermohonan()),
            Lentur(
              dasar: 340,
              child: KolomJarak(
                jarak: 12,
                anak: [
                  KartuSalinan(onPilih: terbit),
                  TombolBaris.teks(
                    'Tidak diterbitkan',
                    onPressed: () => pilih('Tidak diterbitkan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      'Data jemaat tidak aktif' => isiTidakAktif(context, terbit),
      'Diterbitkan' => [KartuDiterbitkan(onBuka: terbit)],
      'Tidak diterbitkan' => [const KartuDitolak()],
      _ => [
        Kartu(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < barisPermohonan.length; i++) ...[
                if (i > 0) GarisLurus(warna: c.garis),
                _Baris(barisPermohonan[i].$1, barisPermohonan[i].$2),
              ],
            ],
          ),
        ),
        const KeteranganDaftar(),
      ],
    };
    return HalamanWeb(
      nav: const NavSamping(
        item: navPlatform,
        aktif: 2,
        pengguna: PenggunaNav(
          tebal: 'Olvie Pangemanan',
          biasa: ' · Sekretaris Jemaat',
        ),
      ),
      isi: [
        Column(
          key: kunciAtas,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MarginNegatif(
              atas: 12,
              bawah: 12,
              child: Tautan(
                ke: 'WebDokumenGereja',
                cara: Cara.naik,
                child: Center(
                  widthFactor: 1,
                  child: TautanTeks('Dokumen gereja', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Permohonan surat',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Atestasi dan surat keterangan untuk satu anggota',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: KolomJarak(jarak: 16, anak: isi),
          ),
        ),
      ],
    );
  }
}

/// A table row; the board links it to its own board (no-op).
class _Baris extends StatelessWidget {
  const _Baris(this.judul, this.keterangan);
  final String judul, keterangan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: 'WebPermohonanSurat',
      child: Container(
        constraints: const BoxConstraints(minHeight: 68),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: BarisLentur(
                jarak: 20,
                jarakBaris: 2,
                anak: [
                  Lentur(
                    dasar: 260,
                    child: Text(
                      judul,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Lentur(
                    dasar: 300,
                    tumbuh: 1.4,
                    // baseline-aligned with the 15 px title in the board
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        keterangan,
                        style: TextStyle(fontSize: 13, color: c.tinta3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const LencanaStatus('Diajukan', bentuk: BentukLencana.garis),
            const SizedBox(width: 16),
            SizedBox(
              width: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
