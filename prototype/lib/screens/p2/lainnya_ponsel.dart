import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../providers/bilah_ponsel.dart';
import '../../providers/session.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/ponsel_tab_bar.dart';
import '../../shell/tautan.dart';
import '../../widgets/kecil.dart';

/// The phone Lainnya hub of a persona whose home is not the finance home
/// (owner change 21/11, README 7.3; no board): every screen they may open on
/// the phone, grouped by module ([hubLainnyaProvider]), then "Akun saya" and
/// "Keluar", above the bar of [BilahBeranda]. Laid out like the finance
/// Lainnya hub.
class LainnyaPonselScreen extends ConsumerWidget {
  const LainnyaPonselScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => LayarPonsel(
    overlay: const [BilahBeranda(aktif: TabBeranda.lainnya)],
    child: Padding(
      padding: const EdgeInsets.only(bottom: 84),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 18,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Lainnya',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            for (final (grup, daftar) in ref.watch(hubLainnyaProvider))
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: JudulBagian(grup),
                  ),
                  KartuTautanHub(daftar),
                ],
              ),
            Kartu(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Tautan(
                    ke: Layar.akun,
                    child: BarisDaftar(judul: 'Akun saya', pertama: true),
                  ),
                  // Signs out to the picker, as the Keluar screen does.
                  BarisDaftar(
                    judul: 'Keluar',
                    onTap: () => keluarSesi(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A group card of hub links: one push row per screen.
class KartuTautanHub extends StatelessWidget {
  const KartuTautanHub(this.daftar, {super.key, this.akunSaya = false});

  final List<TautanHub> daftar;

  /// Ends with "Akun saya" (the finance Lainnya's "Jabatan dan modul lain").
  final bool akunSaya;

  @override
  Widget build(BuildContext context) => Kartu(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        for (final (i, t) in daftar.indexed)
          Tautan(
            ke: t.ke,
            child: BarisDaftar(judul: t.judul, pertama: i == 0),
          ),
        if (akunSaya)
          Tautan(
            ke: Layar.akun,
            child: BarisDaftar(judul: 'Akun saya', pertama: daftar.isEmpty),
          ),
      ],
    ),
  );
}
