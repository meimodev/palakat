import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../providers/home_rows.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/bertindak_sebagai.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import 'beranda_jabatan_isi.dart';

/// 46 · Beranda + 56 · Alur · Beranda gabungan: the role home, one combined
/// Beranda for every post a person holds (README 7.1, D20).
class BerandaJabatanScreen extends ConsumerStatefulWidget {
  const BerandaJabatanScreen({super.key});

  @override
  ConsumerState<BerandaJabatanScreen> createState() =>
      _BerandaJabatanScreenState();
}

class _BerandaJabatanScreenState extends ConsumerState<BerandaJabatanScreen> {
  final _scroll = ScrollController();

  /// The back arrow links to this same screen: it scrolls to the top.
  void _keAtas() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = bacaBeranda(ref);
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Beranda',
            anakJudul: 'Satu Beranda untuk semua jabatan Anda',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
            diSini: _keAtas,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
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
                      for (final r in b.tindak) _KartuBaris(r),
                    ],
                    if (b.tahu.isNotEmpty) ...[
                      const JudulBagian('Untuk diketahui'),
                      for (final r in b.tahu) _KartuBaris(r),
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
    );
  }
}

/// The row card (shared look with KotakMasuk): a full-width link.
class _KartuBaris extends StatelessWidget {
  const _KartuBaris(this.r);
  final HomeRow r;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final lencana = lencanaBaris(r);
    return Tautan(
      ke: r.ke,
      param: r.param,
      radius: 14,
      child: Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.judul,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.sub,
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
              if (lencana != null) ...[const SizedBox(width: 12), lencana],
              const SizedBox(width: 12),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ),
        ),
      ),
    );
  }
}
