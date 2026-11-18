import 'package:flutter/widgets.dart';

import 'lencana_status.dart';

enum KeadaanModul { aktif, tidakAktif, hanyaBaca }

enum KeadaanJabatan { aktif, berakhir, jabatanKosong }

/// A module or post badge: a [LencanaStatus] with fixed words and shapes.
class LencanaModul extends StatelessWidget {
  /// Aktif → laut, Tidak aktif → draf, Hanya baca → garis.
  const LencanaModul.modul(KeadaanModul k, {super.key})
    : modul = k,
      jabatan = null;

  /// Aktif → laut, Berakhir → abu, Jabatan kosong → bata.
  const LencanaModul.jabatan(KeadaanJabatan k, {super.key})
    : jabatan = k,
      modul = null;

  final KeadaanModul? modul;
  final KeadaanJabatan? jabatan;

  @override
  Widget build(BuildContext context) {
    final (label, bentuk) = switch ((modul, jabatan)) {
      (KeadaanModul.aktif, _) => ('Aktif', BentukLencana.laut),
      (KeadaanModul.tidakAktif, _) => ('Tidak aktif', BentukLencana.draf),
      (KeadaanModul.hanyaBaca, _) => ('Hanya baca', BentukLencana.garis),
      (_, KeadaanJabatan.aktif) => ('Aktif', BentukLencana.laut),
      (_, KeadaanJabatan.berakhir) => ('Berakhir', BentukLencana.abu),
      _ => ('Jabatan kosong', BentukLencana.bata),
    };
    return LencanaStatus(label, bentuk: bentuk);
  }
}
