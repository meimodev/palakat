import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/repositories_jemaat.dart';
import '../../providers/repositories_keuangan.dart';
import '../../providers/repositories_kolaborasi.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../app/layar.dart';

/// 92 · Laporan (spec 22): reports across modules, every figure computed
/// from the repositories and cut to the reach of the post the viewer acts
/// in (Q25): the whole church for a Jemaat post, its Kolom for a Penatua,
/// its Fund for a unit, its money for a Panitia officer (DP27). Only
/// Ditetapkan attendance and booked money count.
class LaporanLintasScreen extends StatelessWidget {
  const LaporanLintasScreen({super.key});

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Laporan',
          anakJudul:
              'Dari data yang sah, disaring menurut jangkauan tiap jabatan',
          kembaliKe: Layar.beranda,
          labelKembali: 'Kembali ke Beranda',
        ),
        const Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: IsiLaporanLintas(),
          ),
        ),
      ],
    ),
  );
}

const _dimensi = [
  'Jemaat',
  'Kolom',
  'BIPRA',
  'Komisi',
  'Panitia',
  'Peruntukan',
  'Kas/Bank',
];

/// The content column shared with WebLaporanLintas: chips, the stats and
/// money of each reach, the module-off note and the footer caption, gap 16.
/// Body size is inherited (16 on the phone, 15 on the web).
class IsiLaporanLintas extends ConsumerWidget {
  const IsiLaporanLintas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(revisionProvider);
    final c = context.warna;
    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    final a = ref.watch(actorProvider);
    final hari = ref.watch(hariIniProvider);
    final can = ref.watch(canProvider);
    final org = ref.watch(orgRepositoryProvider);
    final dana = ref.watch(fundRepositoryProvider);
    final anggota = ref.watch(memberRepositoryProvider);
    final verifikasi = ref.watch(verificationRepositoryProvider);
    final ibadah = ref.watch(serviceRepositoryProvider);
    final hadir = ref.watch(attendanceRepositoryProvider);
    final panitia = ref.watch(panitiaRepositoryProvider);
    final kasus = ref.watch(caseRepositoryProvider);

    // The reach: the post the viewer acts in, or every post until chosen.
    final semua = [
      for (final g in can.grantsOf(a?.personId ?? '', at: hari))
        if (g.kind != GrantKind.member) g,
    ];
    final bertindak = semua
        .where(
          (g) => a?.assignmentId != null && g.assignmentId == a!.assignmentId,
        )
        .toList();
    final jangkau = {
      for (final g in bertindak.isEmpty ? semua : bertindak) g.scopeId,
    };
    final jemaat = jangkau.contains(ScopeRef.jemaatId);
    ScopeType? jenis(String id) => org.scope(id)?.type;
    final kolom = [
      if (!jemaat)
        for (final s in jangkau)
          if (jenis(s) == ScopeType.kolom) s,
    ];
    final unit = [
      if (!jemaat)
        for (final s in jangkau)
          if (const {ScopeType.bipra, ScopeType.komisi}.contains(jenis(s))) s,
    ];
    final pan = [
      if (!jemaat)
        for (final p in panitia.list())
          if (jangkau.contains(p.scopeId)) p,
    ];
    final mati = [
      for (final m in [Module.membership, Module.attendance])
        if (!can.moduleActive(m)) m.label,
    ];

    Widget stat(String label, String nilai, String sub) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ket),
          const SizedBox(height: 6),
          Text(
            nilai,
            style: const TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(sub, style: ket),
        ],
      ),
    );

    Widget uang(String judul, int n, String keterangan) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  judul,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                rp(n),
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(keterangan, style: ket),
        ],
      ),
    );

    /// Stats of the whole church ([k] null) or one Kolom.
    Widget statistik(String? k) {
      final n = anggota.counts(kolom: k);
      final bulan = [
        for (final i in verifikasi.verifiedEvents(scopeId: k))
          if (i.decidedAt case final d?
              when d.year == hari.tahun && d.month == hari.bulan)
            i.event!.kind,
      ];
      final rincian = [
        for (final j in LifeEventKind.values)
          if (bulan.where((x) => x == j).length case final m when m > 0)
            '$m ${j.label.toLowerCase()}',
      ];
      final ditetapkan = [
        for (final s in ibadah.list(scopeId: k ?? ScopeRef.jemaatId))
          if (hadir.count(s.id) case final h?
              when h.status == AttendanceStatus.finalized)
            (s, h),
      ].lastOrNull;
      final kolomN = org.scopes(type: ScopeType.kolom).length;
      return KisiOtomatis(
        minLebar: 300,
        jarak: 16,
        anak: [
          if (can.moduleActive(Module.membership)) ...[
            stat(
              'Anggota aktif',
              titik('${n.active}'),
              k == null ? 'di $kolomN Kolom' : '${org.scope(k)?.name} saja',
            ),
            stat('Keluarga', titik('${n.households}'), 'dengan riwayat Kolom'),
            stat(
              'Peristiwa diverifikasi · ${bulanTahun(hari.tahun, hari.bulan)}',
              '${bulan.length}',
              rincian.isEmpty ? 'belum ada' : rincian.join(' · '),
            ),
          ],
          if (can.moduleActive(Module.attendance) && ditetapkan != null)
            stat(
              'Jumlah kehadiran ${ditetapkan.$1.title} ${ditetapkan.$1.date}',
              titik('${ditetapkan.$2.total}'),
              'hanya yang Ditetapkan',
            ),
        ],
      );
    }

    final anak = <Widget>[
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final d in _dimensi) _Chip(d)],
      ),
      if (jemaat) ...[
        statistik(null),
        uang(
          'Saldo buku semua Kas/\u2060Bank',
          dana.ownedBalance(null),
          'Keuangan · hanya yang sudah dibukukan',
        ),
      ],
      for (final k in kolom) ...[
        statistik(k),
        uang(
          'Saldo buku peruntukan ${org.scope(k)?.name ?? ''}',
          dana.ownedBalance(k),
          'Keuangan unit · hanya yang sudah dibukukan',
        ),
      ],
      for (final u in unit)
        uang(
          'Saldo buku peruntukan ${org.scope(u)?.name ?? ''}',
          dana.ownedBalance(u),
          'Keuangan unit · hanya yang sudah dibukukan',
        ),
      for (final p in pan) ...[
        uang(
          'Saldo buku peruntukan ${p.name}',
          panitia.money(p.id).fundBalance,
          'Panitia · tahap ${p.stage.label}',
        ),
        _uangMuka(panitia.money(p.id), [
          for (final id in panitia.money(p.id).advanceIds)
            ?kasus.caseById(id)?.kase.title,
        ]),
      ],
      if (mati.isNotEmpty && (jemaat || kolom.isNotEmpty))
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                TextSpan(
                  text: '${mati.join(' dan ')} belum aktif.',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'Laporannya tidak tampil. Laporan keuangan tetap tersedia.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
          ),
        ),
      Text(
        'Tidak ada penyusun laporan bebas. Laporan tidak pernah memuat '
        'kehadiran per orang atau gabungan kehadiran dengan persembahan.',
        style: ket,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          anak[i],
        ],
      ],
    );
  }

  /// A Panitia's advance (DP27): given, accounted for, returned, the rest.
  Widget _uangMuka(PanitiaMoney m, List<String> judul) => m.advanceIds.isEmpty
      ? const SizedBox.shrink()
      : Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              Text(
                'Uang Muka · ${judul.join(', ')}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              for (final (l, n) in [
                ('Diberikan', m.advanced),
                ('Dipertanggungjawabkan', m.settled),
                ('Dikembalikan', m.returned),
                ('Belum dipertanggungjawabkan', m.outstanding),
              ])
                Row(
                  children: [
                    Expanded(
                      child: Text(l, style: const TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      rp(n),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: PalakatText.mono,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
}

/// A static dimension chip (a `<span>`, not pressable): unselected
/// ChipPilihan look, min height 44 plus the 1.5 border (content-box).
class _Chip extends StatelessWidget {
  const _Chip(this.teks);
  final String teks;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      constraints: const BoxConstraints(minHeight: 47),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garisTegas, radius: 999),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            teks,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
