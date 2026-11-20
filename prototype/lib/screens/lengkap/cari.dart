import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/core_repositories.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'cari_bagian.dart';
import '../../app/layar.dart';

/// 28 · Cari dan tanya (spec 08, Cari).
class CariScreen extends ConsumerStatefulWidget {
  const CariScreen({super.key});

  @override
  ConsumerState<CariScreen> createState() => _CariScreenState();
}

class _CariScreenState extends ConsumerState<CariScreen> with LogikaCari {
  @override
  Widget build(BuildContext context) => LayarPonsel(
    layarKeuangan: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Cari',
          anakJudul: ref.watch(workspaceRepositoryProvider).workspace().name,
          kembaliKe: Layar.keuangan,
          labelKembali: 'Kembali ke Beranda',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, w) in [
                  ...hasil(ke: Layar.keuangan),
                  panelAi(),
                ].indexed) ...[if (i > 0) const SizedBox(height: 16), w],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
