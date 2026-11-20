import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/layar.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'dokumen_gereja_form.dart';

/// WebTerbitDokumen + WebAlurDokumen's `form` and `ralat` views (README
/// 7.1): `/dokumen-gereja/terbit`, a revision with `?dokumen=`.
class WebTerbitDokumenScreen extends StatelessWidget {
  const WebTerbitDokumenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final id = GoRouterState.of(context).uri.queryParameters['dokumen'];
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: const NavSamping(item: navPlatform, aktif: 2),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inline breadcrumb in the 15 px page text (a 22 px line box):
              // the 44 px target overhangs it by 11 above and below.
              const MarginNegatif(
                atas: 11,
                bawah: 11,
                child: Tautan(
                  ke: Layar.dokumenGereja,
                  cara: Cara.naik,
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: TautanTeks('Dokumen gereja', ukuran: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: Text(
                  id == null ? 'Terbitkan dokumen' : 'Ralat sebagai revisi',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                id == null
                    ? 'Unggah salinan bertanda tangan, pilih untuk siapa'
                    : 'Revisi baru; revisi lama tetap dapat dibuka',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: FormDokumen(web: true, dokumenId: id),
            ),
          ),
        ],
      ),
    );
  }
}
