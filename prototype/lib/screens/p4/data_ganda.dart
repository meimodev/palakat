import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../../providers/core_repositories.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../providers/repositories_jemaat.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'jemaat_bagian.dart';

/// 80 · Kemungkinan data ganda (spec 20): the phone frame around
/// [IsiDataGanda].
class DataGandaScreen extends ConsumerWidget {
  const DataGandaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => KerangkaJemaat(
    judul: 'Kemungkinan data ganda',
    anakJudul: 'Bandingkan dulu; tidak pernah digabung sendiri',
    tampilan: ref.watch(gandaDipilihProvider) ?? '',
    blok: const [IsiDataGanda()],
  );
}

/// DataGanda and WebDataGanda: the record already in Data jemaat beside the
/// book row that may be the same person; the Operator merges them or marks
/// them not the same (`MemberImportRepository.resolveDuplicate`).
class IsiDataGanda extends ConsumerStatefulWidget {
  const IsiDataGanda({super.key});

  @override
  ConsumerState<IsiDataGanda> createState() => _IsiDataGandaState();
}

class _IsiDataGandaState extends ConsumerState<IsiDataGanda> {
  Refusal? _tolakan;

  Future<void> _putuskan(DuplicateCase d, DuplicateDecision k) async {
    final r = await jalankanJemaat(
      ref,
      (a, kunci) => ref
          .read(memberImportRepositoryProvider)
          .resolveDuplicate(
            a,
            d.id,
            k,
            // The board draws no reason field: the decision is the reason.
            reason: k == DuplicateDecision.merge
                ? 'Gabungkan'
                : 'Bukan orang yang sama',
            expectedRevision: d.revision,
            idempotencyKey: kunci,
          ),
    );
    if (mounted && r != null) setState(() => _tolakan = r.refusal);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final nama = ref.watch(namaJemaatProvider);
    final impor = ref.watch(memberImportRepositoryProvider);
    final semua = impor.duplicates();
    final id = ref.watch(gandaDipilihProvider);
    final d =
        semua.where((x) => x.id == id).firstOrNull ??
        semua.where((x) => x.status == DuplicateStatus.open).firstOrNull ??
        semua.lastOrNull;
    if (d == null) {
      return kotakKosongGanda(context);
    }
    final b = impor.batches().firstWhere((x) => x.id == d.batchId);
    final r = b.rows.firstWhere((x) => x.id == d.rowId);
    final ada = ref.watch(memberRepositoryProvider).member(d.existingPersonId);
    final orang = ref
        .watch(peopleRepositoryProvider)
        .person(d.existingPersonId);
    Widget kartu(
      String judul,
      String st,
      String? lahir,
      String kolom,
      String asal,
    ) => kartuAlur([
      KepalaKartu(judul: judul, ujung: lencanaSt(st)),
      BarisInfo('Tanggal lahir', lahir ?? '—'),
      BarisInfo('Kolom', kolom),
      BarisInfo('Asal data', asal),
    ]);
    const tebal = TextStyle(fontWeight: FontWeight.w700);
    final oleh = d.decidedBy == null
        ? ''
        : 'Oleh ${_olehAudit(d)} · ${saatJemaat(d.decidedAt)}';
    return kolomJemaat([
      KisiOtomatis(
        minLebar: 300,
        jarak: 16,
        anak: [
          kartu(
            orang?.name ?? '',
            switch (orang?.status) {
              PersonStatus.unconfirmed => 'Belum dikonfirmasi',
              PersonStatus.deceased => 'Meninggal dunia',
              _ => 'Aktif',
            },
            orang?.birthDate == null ? null : tgl(orang!.birthDate!.awal),
            ada == null ? '' : nama.kolom(ada.kolomId),
            ada?.profile.importBatchId == null
                ? 'Data jemaat'
                : 'Buku anggota · baris ${ada!.profile.importLine}',
          ),
          kartu(
            r.name,
            'Belum dikonfirmasi',
            r.birthDate == null ? null : tgl(r.birthDate!.awal),
            nama.kolom(r.kolomId),
            'Buku anggota · baris ${r.line}',
          ),
        ],
      ),
      ?(_tolakan == null ? null : penolakanDari(_tolakan!)),
      ...switch (d.status) {
        DuplicateStatus.open => [
          BarisTombol(
            anak: [
              Tombol(
                'Gabungkan',
                onPressed: () => _putuskan(d, DuplicateDecision.merge),
                jenis: JenisTombol.tinta,
              ),
              Tombol(
                'Bukan orang yang sama',
                onPressed: () => _putuskan(d, DuplicateDecision.notSame),
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
              ),
            ],
          ),
        ],
        DuplicateStatus.merged => [
          const Pesan(
            siaran: false,
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Digabungkan menjadi satu orang.',
                    style: tebal,
                  ),
                  TextSpan(
                    text:
                        ' Riwayat keuangan, jabatan, keluarga, pelayanan dan '
                        'Riwayat aktivitas keduanya tetap ada.',
                  ),
                ],
              ),
            ),
          ),
          Text(oleh, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
        DuplicateStatus.notSame => [
          const Kartu(
            status: GarisStatus.terpilih,
            radius: 12,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Ditandai: bukan orang yang sama.',
                    style: tebal,
                  ),
                  TextSpan(
                    text:
                        ' Keduanya tetap sebagai dua orang dan tidak '
                        'ditawarkan lagi sebagai data ganda.',
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
          Text(oleh, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
      },
    ]);
  }

  /// "Yanti Sumual, Operator": the decision's audit actor.
  String _olehAudit(DuplicateCase d) {
    final r = ref
        .read(auditRepositoryProvider)
        .list(AuditFilter(ref: RecordRef('duplicate', d.id)))
        .firstOrNull;
    return r == null
        ? ref.read(namaJemaatProvider).orang(d.decidedBy!)
        : '${r.personName}, ${r.actingRole}';
  }
}

/// No possible duplicate yet: the book check flags them here.
Widget kotakKosongGanda(BuildContext context) => kartuAlur([
  const Text(
    'Tidak ada kemungkinan data ganda',
    style: TextStyle(fontWeight: FontWeight.w700),
  ),
  barisAlur(
    context,
    'Pengecekan buku anggota menandai data yang mungkin sama di sini.',
  ),
], status: GarisStatus.draf);
