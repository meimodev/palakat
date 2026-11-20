import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/layar.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'dokumen_gereja_form.dart';

/// The `dokumenGereja` shell on the phone (README 7.2, ch: `terbit`,
/// `ralat`): LayarPonsel around DokumenGereja and its publish form. It holds
/// no state; the form reads the document to revise from `?dokumen=`.
class AlurDokumenKendali extends StatelessWidget {
  const AlurDokumenKendali({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayarPonsel(child: child);
}

/// TerbitDokumen + AlurDokumen's `terbit` and `ralat` views (README 7.1):
/// [anak] 'terbit' publishes a new document, 'ralat' a revision.
class AlurDokumenScreen extends StatelessWidget {
  const AlurDokumenScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).uri.queryParameters['dokumen'];
    final ralat = anak == 'ralat' && id != null;
    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: ralat ? 'Ralat sebagai revisi' : 'Terbitkan dokumen',
            anakJudul: ralat
                ? 'Revisi baru; revisi lama tetap dapat dibuka'
                : 'Unggah salinan bertanda tangan, pilih untuk siapa',
            kembaliKe: Layar.dokumenGereja,
            labelKembali: 'Kembali ke Dokumen gereja',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: FormDokumen(web: false, dokumenId: ralat ? id : null),
            ),
          ),
        ],
      ),
    );
  }
}
