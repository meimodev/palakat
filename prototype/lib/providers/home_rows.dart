import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/layar.dart';
import '../domain/core/core.dart';
import '../widgets/lencana_status.dart' show GayaLabel;
import 'actor.dart';
import 'home_rows_inti.dart';
import 'home_rows_jemaat.dart';
import 'home_rows_keuangan.dart';
import 'home_rows_kolaborasi.dart';
import 'home_rows_sekretariat.dart';
import 'layout.dart';
import 'revision.dart';

/// The two lists of BerandaJabatan and KotakMasuk.
enum KelompokBaris {
  /// "Perlu tindakan".
  tindak,

  /// "Untuk diketahui".
  tahu,
}

/// One home row (BerandaJabatan, WebBerandaJabatan), drawn from a real open
/// item: title, second line ("Sebagai {jabatan} · …"), badge, target.
class HomeRow {
  const HomeRow({
    required this.kelompok,
    required this.judul,
    required this.sub,
    this.label,
    this.gaya,
    required this.ke,
    this.param = const {},
  });

  final KelompokBaris kelompok;
  final String judul;
  final String sub;

  /// 'Diajukan', 'Draf', 'Hambatan', … with its badge style.
  final String? label;
  final GayaLabel? gaya;
  final Layar ke;
  final Map<String, String> param;
}

/// A module's row source: the rows of [actor]'s open items in that module.
/// It may `ref.watch` the read models and repositories it needs.
typedef SumberBarisBeranda = List<HomeRow> Function(Ref ref, Actor actor);

/// The fixed list of row sources (README 9, M1 hooks): each module milestone
/// fills its own file (M2 keuangan, M6 inti, M7 sekretariat, M8 jemaat, M9
/// kolaborasi); nobody edits this list.
const sumberBarisBeranda = <SumberBarisBeranda>[
  barisKeuangan,
  barisInti,
  barisSekretariat,
  barisJemaat,
  barisKolaborasi,
];

/// The signed-in actor's home rows, in source order. Rows to a screen whose
/// module is not active, or that the current layout lacks (D13), are left
/// out.
final homeRowsProvider = Provider<List<HomeRow>>((ref) {
  ref.watch(revisionProvider);
  final actor = ref.watch(actorProvider);
  if (actor == null) return const [];
  final can = ref.watch(canProvider);
  final tata = ref.watch(layoutProvider);
  return [
    for (final sumber in sumberBarisBeranda)
      for (final r in sumber(ref, actor))
        if (r.ke.adaUntuk(tata) && can.moduleActive(r.ke.modulLayar.modul)) r,
  ];
});
