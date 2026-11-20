import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/session.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../theme/palakat_tema.dart';
import 'sambungan.dart';

/// Web · Sambungan, cut to its session-ended view (DP34; 10-aifoto.md,
/// WebSambungan): a white card centred in `main`; the side nav stays. No
/// fade on web.
class WebSambunganScreen extends ConsumerWidget {
  const WebSambunganScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final t = teksSesiBerakhir(ref.watch(sessionProvider));
    return HalamanWeb(
      tengah: true,
      nav: const NavSamping(item: navKeuangan, aktif: 1),
      isi: [
        if (t != null)
          // The board's `flex: 1` box; HalamanWeb.tengah centres it in `main`.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.jepit(24, 4, 40)),
                  decoration: BoxDecoration(
                    color: c.permukaan,
                    border: Border.all(color: c.garis),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: isiSesiBerakhir(context, t),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
