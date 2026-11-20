import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/core_repositories.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import 'a4_warta.dart';
import 'warta_arsip_bagian.dart';
import 'warta_editor.dart';

/// Web · WartaEditor + WebAlurWarta (README 7.1): the editor beside the
/// "Pratinjau halaman 1" miniature, rendered from the same preview as the
/// PDF.
class WebWartaEditorScreen extends ConsumerWidget {
  const WebWartaEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(revisionProvider);
    final c = context.warna;
    final id = edisiDariRute(context);
    final p = ref.watch(wartaRepositoryProvider).preview(id);
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: const NavSamping(item: navPlatform, aktif: 4),
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
                  ke: Layar.warta,
                  cara: Cara.naik,
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: TautanTeks('Warta Jemaat', ukuran: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: Text(
                  p == null
                      ? 'Warta Jemaat'
                      : 'Warta Jemaat · edisi ${tgl(p.edition.sunday.awal)}',
                  style: PalakatText.judulHalaman.copyWith(color: c.tinta),
                ),
              ),
              Text(
                'Disusun dari data yang sudah ada; tidak diketik ulang',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          BarisLentur(
            jarak: 24,
            anak: [
              Lentur(dasar: 520, maks: 880, child: IsiWartaEditor(edisiId: id)),
              if (p != null)
                Lentur(dasar: 300, maks: 480, child: _Pratinjau(p)),
            ],
          ),
        ],
      ),
    );
  }
}

/// The aside: "Pratinjau halaman 1", the miniature A4 page, the caption.
class _Pratinjau extends ConsumerWidget {
  const _Pratinjau(this.p);

  final WartaPreview p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final e = p.edition;
    final gereja = ref.watch(workspaceRepositoryProvider).workspace().name;
    final terbit =
        e.status == WartaStatus.published || e.status == WartaStatus.archived;
    Widget bagian(BagianWarta b) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 2),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.tinta)),
          ),
          child: Text(
            b.judul.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
            ),
          ),
        ),
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 13, color: c.tinta),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: b.baris,
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: const Text(
                  'Pratinjau halaman 1',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 16),
            terbit
                ? const LencanaStatus(
                    'Diterbitkan',
                    bentuk: BentukLencana.tinta,
                  )
                : const LencanaStatus(
                    'Belum diterbitkan',
                    bentuk: BentukLencana.draf,
                  ),
          ],
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 210 / 297,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.permukaan,
              border: Border.all(color: c.garisTegas),
            ),
            // overflow: hidden; the page clips, it never grows.
            child: ClipRect(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 27,
                  vertical: 29,
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: c.tinta),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'WARTA JEMAAT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                        ),
                      ),
                      Text(
                        'GMIM $gereja · Minggu, ${tglPanjang(e.sunday.awal)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                      for (final b in bagianWarta(p)) ...[
                        const SizedBox(height: 14),
                        bagian(b),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Yang tampil di sini sama dengan PDF: bagian dari modul yang tidak '
          'aktif tidak dicetak, dan nama mengikuti Tampilan nama.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }
}
