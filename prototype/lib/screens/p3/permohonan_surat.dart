import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/lencana_status.dart';
import 'permohonan_surat_bagian.dart';
import '../../app/layar.dart';

/// 64 · Permohonan surat (17-keadaanumum.md): letter requests at the
/// Sekretaris Jemaat's desk; five views switched by the `keadaan` tweak.
class PermohonanSuratScreen extends StatefulWidget {
  const PermohonanSuratScreen({super.key});

  @override
  State<PermohonanSuratScreen> createState() => _PermohonanSuratScreenState();
}

class _PermohonanSuratScreenState extends State<PermohonanSuratScreen>
    with KeadaanPermohonan {
  @override
  String get stem => 'PermohonanSurat';

  @override
  Widget build(BuildContext context) {
    void terbit() => pilih('Diterbitkan');
    final isi = switch (tampil) {
      'Menerbitkan surat' => [
        const KartuPermohonan(),
        KartuSalinan(onPilih: terbit),
        TombolBaris.teks(
          'Tidak diterbitkan',
          onPressed: () => pilih('Tidak diterbitkan'),
        ),
      ],
      'Data jemaat tidak aktif' => isiTidakAktif(context, terbit),
      'Diterbitkan' => [KartuDiterbitkan(onBuka: terbit)],
      'Tidak diterbitkan' => [const KartuDitolak()],
      _ => [
        for (final r in barisPermohonan) _Baris(r.$1, r.$2),
        const KeteranganDaftar(),
      ],
    };
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Permohonan surat',
            anakJudul: 'Atestasi dan surat keterangan untuk satu anggota',
            kembaliKe: Layar.dokumenGereja,
            labelKembali: 'Kembali ke Dokumen gereja',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: KolomJarak(key: kunciAtas, jarak: 16, anak: isi),
            ),
          ),
        ],
      ),
    );
  }
}

/// A request row card; the board links it to its own board (no-op).
class _Baris extends StatelessWidget {
  const _Baris(this.judul, this.keterangan);
  final String judul, keterangan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: Layar.surat,
      radius: 14,
      child: Container(
        constraints: const BoxConstraints(minHeight: 70),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          color: c.permukaan,
          shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    keterangan,
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const LencanaStatus('Diajukan', bentuk: BentukLencana.garis),
            const SizedBox(width: 12),
            PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
          ],
        ),
      ),
    );
  }
}
