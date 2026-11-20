import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/core_repositories.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';

// What the Secretariat screens share (README 4.3, 7.1): the actor, a fresh
// idempotency key, the gate, names, Riwayat from the audit, and the parts
// the boards repeat (the signed-copy slot, the refusal line).

/// The signed-in actor; every Secretariat screen sits behind the picker.
Actor aktorSek(WidgetRef ref) => ref.read(actorProvider)!;

/// A fresh idempotency key for one submission (README 3.4).
String kunciSek(WidgetRef ref) =>
    kunciBaru(ref.read(actorProvider)!.personId, ref.read(clockProvider));

/// Whether the signed-in actor may [c] in the Jemaat today (build only).
bool bolehSek(WidgetRef ref, Capability c) {
  final a = ref.watch(actorProvider);
  if (a == null) return false;
  return ref
      .watch(canProvider)
      .can(a, c, ScopeRef.jemaat, at: ref.watch(hariIniProvider));
}

/// Whether the signed-in person holds an Operator post today: an Operator
/// sees everything in every module (DL25).
bool operatorSek(WidgetRef ref) {
  final a = ref.watch(actorProvider);
  if (a == null) return false;
  final can = ref.watch(canProvider);
  return can
      .grantsOf(a.personId, at: ref.watch(hariIniProvider))
      .any(
        (g) =>
            g.postId != null &&
            can.facts.post(g.postId!)?.role == Role.operator,
      );
}

/// A person's name as recorded, or the id.
String namaSek(WidgetRef ref, String id) =>
    ref.watch(peopleRepositoryProvider).person(id)?.name ?? id;

/// Riwayat lines of [filter], newest first: 'dd/mm/yyyy · {what} · {who},
/// {post}' (RiwayatAlur).
List<String> riwayatSek(WidgetRef ref, AuditFilter filter) => [
  for (final r in ref.watch(auditRepositoryProvider).list(filter))
    '${tgl(r.at)} · ${r.summary} · ${r.personName}, ${r.actingRole}',
];

/// 'dd/mm/yyyy' typed by a person, or null.
Tanggal? bacaTanggal(String teks) {
  final n = bacaTgl(teks);
  return n == null ? null : Tanggal(n ~/ 10000, n ~/ 100 % 100, n % 100);
}

/// A column with the boards' fixed gap.
Widget kolomSek(List<Widget> anak, double jarak) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (final (i, w) in anak.indexed) ...[
      if (i > 0) SizedBox(height: jarak),
      w,
    ],
  ],
);

/// A repository refusal as the flow boards draw it (Penolakan 14).
Widget penolakanSek(Refusal r) => Penolakan(
  tindakan: r.action,
  sebab: r.because,
  jalan: const [],
  ukuranTeks: 14,
);

/// 13 `tinta3`.
Widget kecilSek(BuildContext context, String teks) =>
    Text(teks, style: TextStyle(fontSize: 13, color: context.warna.tinta3));

/// The dashed signed-copy slot of AlurDokumen and AlurSurat: "Wajib, belum
/// ada" with "Pilih file", then "Terlampir" with the file line. The upload
/// failure of the boards is a staged fault (D9).
class SlotSalinan extends StatelessWidget {
  const SlotSalinan({
    super.key,
    required this.nama,
    required this.ada,
    required this.onPilih,
  });

  final String nama;
  final bool ada;
  final VoidCallback onPilih;

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    child: kolomSek([
      KepalaKartu(
        judul: 'Salinan bertanda tangan',
        ujung: ada
            ? const LencanaStatus('Terlampir', bentuk: BentukLencana.garis)
            : const LencanaStatus(
                'Wajib, belum ada',
                bentuk: BentukLencana.bata,
              ),
      ),
      if (!ada) ...[
        kecilSek(
          context,
          'Tanda tangan ada di dokumennya. Tidak ada persetujuan di aplikasi '
          'untuk dokumen gereja.',
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Tombol(
            'Pilih file',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            lebarPenuh: false,
            onPressed: onPilih,
          ),
        ),
      ] else
        kecilSek(context, '$nama · 1 halaman'),
    ], 6),
  );
}

/// Two columns of the web flow boards: left `flex: 1.3 1 420px`, right
/// `flex: 1 1 340px`, gap 20 × 28, each a column gap 12.
Widget duaKolomSek(List<Widget> kiri, List<Widget> kanan) => LayoutBuilder(
  builder: (context, k) {
    if (k.maxWidth < 788) return kolomSek([...kiri, ...kanan], 12);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 13, child: kolomSek(kiri, 12)),
        const SizedBox(width: 28),
        Expanded(flex: 10, child: kolomSek(kanan, 12)),
      ],
    );
  },
);
