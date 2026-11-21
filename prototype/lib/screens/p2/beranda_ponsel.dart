import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/bilah_ponsel.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/ponsel_tab_bar.dart';
import '../../widgets/bertindak_sebagai.dart';
import '../../widgets/kecil.dart';
import '../ponsel/main.dart';
import 'beranda_jabatan_isi.dart';

/// The phone home `/` (owner change 21/11, README 7.3), inside Main's
/// Kendali: Main's Beranda (with the other modules' rows) for a persona who
/// can act as the church's Bendahara, else BerandaJabatan's content. Both
/// carry a bottom bar, and Back on either signs out to the picker.
class BerandaPonselScreen extends ConsumerWidget {
  const BerandaPonselScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(berandaKeuanganPonselProvider)
      ? const MainScreen()
      : const BerandaJabatanPonsel();
}

/// 46 · Beranda + 56 · Alur · Beranda gabungan as the phone home of every
/// persona whose home is not the finance home: the person card with its
/// post chips, the "Sebagai …" choice when two posts can act, "Perlu
/// tindakan", "Untuk diketahui" and "Akun saya", under the title "Beranda"
/// with no back arrow, above the bar of [BilahBeranda].
class BerandaJabatanPonsel extends ConsumerWidget {
  const BerandaJabatanPonsel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = bacaBeranda(ref);
    return KeluarSaatKembali(
      child: Stack(
        children: [
          Positioned.fill(
            bottom: 84,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const KepalaPonsel(
                  judul: 'Beranda',
                  anakJudul: 'Satu Beranda untuk semua jabatan Anda',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: bersela([
                        DaftarJabatan(nama: b.nama, jabatan: b.jabatan),
                        if (b.perluMemilih)
                          ...isiPilihJabatan(ref, b.pilihan)
                        else ...[
                          if (b.tindak.isEmpty)
                            const KartuKosong()
                          else ...[
                            const JudulBagian('Perlu tindakan'),
                            for (final r in b.tindak) KartuBaris(r),
                          ],
                          if (b.tahu.isNotEmpty) ...[
                            const JudulBagian('Untuk diketahui'),
                            for (final r in b.tahu) KartuBaris(r),
                          ],
                          const Keterangan(kalimatBeranda),
                          const TautanAkunSaya(),
                        ],
                      ], 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const BilahBeranda(aktif: TabBeranda.beranda),
        ],
      ),
    );
  }
}
