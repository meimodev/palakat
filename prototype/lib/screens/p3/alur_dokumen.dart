import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shell/kendali.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import 'alur_dokumen_alur.dart';

/// Owns the flow state shared by `/AlurDokumen`, `/terbit` and `/ralat`
/// (navigation.md 2.1), and LayarPonsel around the nested navigator.
class AlurDokumenKendali extends StatefulWidget {
  const AlurDokumenKendali({super.key, required this.child});
  final Widget child;
  @override
  State<AlurDokumenKendali> createState() => _AlurDokumenKendaliState();
}

class _AlurDokumenKendaliState extends State<AlurDokumenKendali> {
  final _a = AlurDokumenData();
  var _generasi = 0;

  @override
  void initState() {
    super.initState();
    ulangPapan['AlurDokumen'] = _ulang;
  }

  void _ulang() => setState(() {
    _a.ulang();
    _generasi++;
  });

  @override
  void dispose() {
    if (ulangPapan['AlurDokumen'] == _ulang) ulangPapan.remove('AlurDokumen');
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GenerasiPapan(
    generasi: _generasi,
    child: _Lingkup(
      notifier: _a,
      child: LayarPonsel(child: widget.child),
    ),
  );
}

class _Lingkup extends InheritedNotifier<AlurDokumenData> {
  const _Lingkup({required super.notifier, required super.child});

  static AlurDokumenData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

/// 69 · Alur · Menerbitkan dokumen. The route decides the view: `anak` null
/// is `daftar`, 'terbit' is `form`, 'ralat' is `ralat`.
class AlurDokumenScreen extends StatelessWidget {
  const AlurDokumenScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) {
    final a = _Lingkup.of(context);
    void ke(String sub) => GoRouter.of(context).push('/AlurDokumen/$sub');
    void kembali() => context.kembaliKe('/AlurDokumen');
    void batal() {
      a.batal();
      kembali();
    }

    final isi = switch (anak) {
      'terbit' => [
        ...isianTerbit(a),
        ...aksiTerbit(
          context,
          a,
          onTerbit: () {
            a.terbit();
            kembali();
          },
          onBatal: batal,
        ),
      ],
      'ralat' => [
        ...isianRalat(context, a),
        ...aksiRalat(
          context,
          a,
          onTerbit: () {
            a.terbitRev();
            kembali();
          },
          onBatal: batal,
        ),
      ],
      _ => daftarAlurDokumen(
        context,
        a,
        onBaru: () {
          a.keForm();
          ke('terbit');
        },
        onRalat: (i) {
          a.keRalat(i);
          ke('ralat');
        },
      ),
    };
    // System Back from a form needs no handler: `pesan` is already '' there
    // (opening a form clears it) and the route, not `v`, picks the view.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Alur · Menerbitkan dokumen',
          anakJudul: 'Dari mengisi sampai terbit, lalu ralat sebagai revisi',
          kembaliKe: 'DokumenGereja',
          labelKembali: 'Kembali ke Dokumen gereja',
        ),
        Expanded(
          child: SingleChildScrollView(
            // A publish returns to the list at the top, where its banner is.
            key: ValueKey(a.riw.length),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: kolomAlur(isi, 16),
          ),
        ),
      ],
    );
  }
}
