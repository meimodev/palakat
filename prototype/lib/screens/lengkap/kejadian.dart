import 'package:flutter/material.dart';

import '../../mock/mock.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';
import 'kejadian_bagian.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// 22 · Kejadian setelah tutup buku (07-kejadian.md). Owns the board state
/// shared by `/Kejadian` (list) and `/Kejadian/rinci` (detail).
class KejadianKendali extends StatefulWidget {
  const KejadianKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KejadianKendali> createState() => _KejadianKendaliState();
}

class _KejadianKendaliState extends State<KejadianKendali> {
  final _s = KeadaanKejadian();

  @override
  void dispose() {
    _s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    notifier: _s,
    child: LayarPonsel(layarKeuangan: true, child: widget.child),
  );
}

class _Lingkup extends InheritedNotifier<KeadaanKejadian> {
  const _Lingkup({required super.notifier, required super.child});

  static KeadaanKejadian of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

class KejadianScreen extends StatelessWidget {
  const KejadianScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) {
    final s = _Lingkup.of(context);
    final hambat = belumDipindah<bool>(true);
    return anak == 'rinci'
        ? _Rinci(s: s, hambat: hambat)
        : _Daftar(s: s, hambat: hambat);
  }
}

class _Daftar extends StatelessWidget {
  const _Daftar({required this.s, required this.hambat});
  final KeadaanKejadian s;
  final bool hambat;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    // The board unmounts the list while the detail is open; hide it under the
    // detail's `masuk` so it does not show through the fade.
    final atas = ModalRoute.of(context)?.isCurrent ?? true;
    return Visibility(
      visible: atas,
      maintainState: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Kejadian setelah tutup buku',
            kembaliKe: Layar.tutupBuku,
            labelKembali: 'Kembali ke Bulan',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: KolomCelah(
                celah: 12,
                anak: [
                  if (hambat) const PernyataanHambatan(),
                  for (final k in kejadian)
                    Tekan(
                      radius: 14,
                      onTap: () {
                        s.pick(k.no);
                        context.dorongKe(Layar.kejadian, anak: 'rinci');
                      },
                      child: Kartu(
                        child: IsiKartuKejadian(
                          k: k,
                          selesai: s.sel(k).isNotEmpty,
                        ),
                      ),
                    ),
                  Text(
                    'Kejadian dicatat dari transaksi di bulan yang sudah '
                    'ditutup, lewat “Catat kejadian”.',
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rinci extends StatelessWidget {
  const _Rinci({required this.s, required this.hambat});
  final KeadaanKejadian s;
  final bool hambat;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      KepalaPonsel(
        judul: 'Kejadian',
        // `tutupRinci`: back to the list view.
        onKembali: () => context.naikKe(Layar.kejadian),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: RinciKejadian(s: s, hambat: hambat),
        ),
      ),
    ],
  );
}
