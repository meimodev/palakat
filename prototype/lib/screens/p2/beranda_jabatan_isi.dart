import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/home_rows.dart';
import '../../providers/session.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/bertindak_sebagai.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';

/// Shared by BerandaJabatan and WebBerandaJabatan (spec 14, merged with
/// AlurBeranda, README 7.1): who is signed in, their posts, their home rows,
/// and the "Sebagai …" choice while two posts can act (Q31).

const kalimatBeranda =
    'Semua pekerjaan dari semua jabatan Anda ada di sini. Hanya modul yang '
    'aktif yang tampil. Setiap tindakan mencatat jabatan yang dipakai.';

/// What both homes draw, read once per build.
class IsiBeranda {
  const IsiBeranda({
    required this.nama,
    required this.jabatan,
    required this.tindak,
    required this.tahu,
    required this.pilihan,
  });

  /// The person card: name and post chips.
  final String nama;
  final List<String> jabatan;

  /// "Perlu tindakan" and "Untuk diketahui" rows (homeRowsProvider).
  final List<HomeRow> tindak;
  final List<HomeRow> tahu;

  /// The posts to choose from ("Sebagai …"); empty once one acts.
  final List<Grant> pilihan;

  bool get perluMemilih => pilihan.length > 1;
}

/// Reads the signed-in person's home from the session, the gate and the
/// home rows. Call from `build`.
IsiBeranda bacaBeranda(WidgetRef ref) {
  final s = ref.watch(sessionProvider);
  final can = ref.watch(canProvider);
  final hari = ref.watch(hariIniProvider);
  final baris = ref.watch(homeRowsProvider);
  final id = s?.personId;
  return IsiBeranda(
    nama: id == null
        ? ''
        : ref.watch(peopleRepositoryProvider).person(id)?.name ?? '',
    jabatan: id == null ? const [] : jabatanAnda(can.grantsOf(id, at: hari)),
    tindak: [
      for (final r in baris)
        if (r.kelompok == KelompokBaris.tindak) r,
    ],
    tahu: [
      for (final r in baris)
        if (r.kelompok == KelompokBaris.tahu) r,
    ],
    pilihan: s != null && s.perluMemilih ? s.pilihan : const [],
  );
}

/// The person's post chips: every post, cover and delegation in force;
/// "Anggota jemaat" only when there is none (Q25, the base view).
List<String> jabatanAnda(List<Grant> grants) {
  final pos = [
    for (final g in grants)
      ?switch (g.kind) {
        GrantKind.assignment => g.title,
        GrantKind.cover => 'Menjalankan jabatan kosong: ${g.title}',
        // ponytail: not drawn; worded like the cover chip.
        GrantKind.delegation => 'Pelimpahan: ${g.title}',
        GrantKind.member => null,
      },
  ];
  if (pos.isNotEmpty) return pos;
  return [
    for (final g in grants)
      if (g.kind == GrantKind.member) g.title,
  ];
}

/// Children with a gap between each.
List<Widget> bersela(List<Widget> anak, double jarak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: jarak),
    anak[i],
  ],
];

/// A row's badge (`LS[r[3] || 'garis']`), or null.
Widget? lencanaBaris(HomeRow r) => r.label == null
    ? null
    : LencanaStatus(r.label!, bentuk: (r.gaya ?? GayaLabel.garis).bentuk);

/// Caption 13 `tinta3`.
class Keterangan extends StatelessWidget {
  const Keterangan(this.teks, {super.key});
  final String teks;

  @override
  Widget build(BuildContext context) =>
      Text(teks, style: TextStyle(fontSize: 13, color: context.warna.tinta3));
}

/// AlurBeranda's empty "Perlu tindakan": a dashed card.
class KartuKosong extends StatelessWidget {
  const KartuKosong({super.key});

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Tidak ada yang perlu tindakan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Pekerjaan dari semua jabatan Anda akan muncul di sini.',
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ],
    ),
  );
}

/// "Akun saya": underlined 14/700 link, a 44-high target the column's width.
class TautanAkunSaya extends StatelessWidget {
  const TautanAkunSaya({super.key});

  @override
  Widget build(BuildContext context) => const Tautan(
    ke: Layar.akun,
    child: SizedBox(
      height: 44,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TautanTeks('Akun saya', berat: FontWeight.w700, ukuran: 14),
      ),
    ),
  );
}

/// "Dua jabatan dapat bertindak" (AlurBeranda, Q31): the choice box with one
/// outlined "Sebagai {jabatan}" button per post, then the caption. The choice
/// is recorded on the session ([SessionNotifier.pilihSebagai]).
List<Widget> isiPilihJabatan(
  WidgetRef ref,
  List<Grant> pilihan, {
  double jarak = 16,
}) => [
  BertindakSebagai.pilih(
    jabatan: [for (final g in pilihan) g.title],
    kalimat:
        'Pilih salah satu. Jabatan yang Anda pilih tercatat di Riwayat dan '
        'tidak dapat diubah setelahnya.',
    jarak: jarak,
    onPilih: (j) => ref
        .read(sessionProvider.notifier)
        .pilihSebagai(pilihan.firstWhere((g) => g.title == j)),
  ),
  const Keterangan(
    'Aplikasi hanya memilih sendiri bila tepat satu jabatan yang berwenang. '
    'Jabatan Anda yang lain tidak membuka jalan menyetujui atau memverifikasi '
    'pengajuan Anda sendiri.',
  ),
];
