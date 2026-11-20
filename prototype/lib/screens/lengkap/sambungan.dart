import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../providers/session.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/tombol.dart';

/// The session-ended copy of Sambungan and WebSambungan, "Sesi berakhir:
/// wewenang berpindah" (DP34): (caption, authority box). The post comes from
/// the assignment the session acted in, the date from when it ended.
(String, String)? teksSesiBerakhir(Session? s) {
  final selesai = s?.record.endedAt;
  if (s == null || selesai == null) return null;
  final jabatan = s.record.acting?.title ?? 'Bendahara Jemaat';
  final pendek = jabatan.split(' ').first;
  return (
    'Wewenang $pendek berpindah pada ${tgl(selesai)}. Semua sesi $pendek '
        'lama diakhiri saat itu juga.',
    'Anda tidak lagi memegang wewenang $jabatan Karunia. Riwayat tetap '
        'mencatat tindakan Anda. Bila ini keliru, yang dapat membantu adalah '
        'BPMJ Jemaat Karunia.',
  );
}

/// The shared body of the session-ended view (Sambungan session view 1–4),
/// left-aligned, gap 20. "Masuk lagi" signs out, so the router opens the
/// picker (D19).
List<Widget> isiSesiBerakhir(BuildContext context, (String, String) t) {
  final c = context.warna;
  final tebal = TextStyle(fontWeight: FontWeight.w700, color: c.tinta);
  return [
    const PalakatIkon(Ikon.sesiBerakhir, ukuran: 56),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Sesi Anda berakhir',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(t.$1, style: TextStyle(fontSize: 15, color: c.tinta2)),
      ],
    ),
    DefaultTextStyle.merge(
      style: TextStyle(fontSize: 14, color: c.tinta2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Tetap aman:', style: tebal),
                const TextSpan(
                  text:
                      ' semua yang sudah dibukukan dan draf yang sudah '
                      'tersimpan.',
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Tidak ikut tersimpan:', style: tebal),
                const TextSpan(
                  text: ' isian yang belum tersimpan di perangkat ini.',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(c.putus, radius: 14),
      ),
      child: Text(t.$2, style: const TextStyle(fontSize: 14)),
    ),
    Tombol('Masuk lagi', onPressed: () => keluarSesi(context), paddingH: 20),
  ];
}

/// 38 · Sambungan, cut to its session-ended view (DP34; 10-aifoto.md,
/// Sambungan): the assignment the session acted in ended (F20).
class SambunganScreen extends ConsumerWidget {
  const SambunganScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = teksSesiBerakhir(ref.watch(sessionProvider));
    return LayarPonsel(
      child: t == null
          ? const SizedBox.expand()
          : Gerak(
              Kerangka.pudar,
              lama: const Duration(milliseconds: 250),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: isiSesiBerakhir(context, t),
                ),
              ),
            ),
    );
  }
}
