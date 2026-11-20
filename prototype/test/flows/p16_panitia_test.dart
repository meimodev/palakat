// P16 Committees (README 8.3): a new Panitia needs a decision document from
// Dokumen gereja (P7) and three distinct officers; Panitia Natal closes once
// advance um1 is cleared: Meiske records the return of its unused Rp650.000
// into Umum Jemaat (CaseRepository.returnUnused, booked after
// periksaOlehJefry, DP27) and approves the leftover's destination, Umum
// Jemaat: Ditutup, then Diarsipkan.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/collaboration/collaboration.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/repositories_kolaborasi.dart';
import 'package:palakat_prototype/providers/session.dart';
import 'package:palakat_prototype/widgets/chip_pilihan.dart';

import 'harness.dart';

const _natal = 'panitia-natal';
const _kembali = 'Pengembalian sisa uang muka · Panitia Natal';

/// Taps chip [teks] of the ChipPilihan labelled [label].
Future<void> _pilih(WidgetTester tester, String label, String teks) async {
  final grup = find.ancestor(
    of: find.text(label),
    matching: find.byType(ChipPilihan<String>),
  );
  final f = find.descendant(of: grup.first, matching: find.text(teks)).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('P16 panitia', () {
    testWidgets('ponsel', (tester) async {
      final c = await bukaAplikasi(tester);
      final repo = c.read(panitiaRepositoryProvider);
      final hari = Tanggal.dari(jangkarA);
      final sk = 'SK BPMJ No. 15/${hari.tahun} · Panitia Paskah';
      final nama = 'Panitia Paskah ${hari.tahun + 1}';
      final natal = repo.get(_natal)!.name;
      Future<void> ke(Layar l) async {
        c.read(routerProvider).go(l.lokasi());
        await tester.pumpAndSettle();
      }

      // The decision is published in Dokumen gereja first (P7's screens).
      await masukSebagai(tester, Persona.olvie);
      await ke(Layar.dokumenGereja);
      await tekan(tester, 'Terbitkan dokumen');
      await tekan(tester, 'Keputusan dan surat edaran');
      await isi(tester, 'Judul', sk);
      await isi(tester, 'Tanggal dokumen', tgl(hari.awal));
      await tekan(tester, 'Pelayan dan pengurus');
      await tekan(tester, 'Pilih file');
      await tekan(tester, 'Terbitkan');
      await keluar(tester);

      // Lidya forms the Panitia: three distinct officers and the decision.
      await masukSebagai(tester, Persona.lidya);
      await ke(Layar.panitia);
      expect(find.text(natal), findsWidgets);
      await tekan(tester, 'Membentuk Panitia baru');
      await isi(tester, 'Nama Panitia', nama);
      await _pilih(tester, 'Ketua', 'Sdr. Stevi Lengkong');
      await _pilih(tester, 'Sekretaris', 'Sdr. Stevi Lengkong');
      expect(
        find.text(
          'Tidak dapat dilakukan: Bentuk Panitia. Ketua, Sekretaris dan '
          'Bendahara harus tiga orang yang berbeda.',
        ),
        findsOneWidget,
      );
      await _pilih(tester, 'Sekretaris', 'Sdri. Natalia Rumengan');
      await _pilih(tester, 'Bendahara', 'Sdr. Rivo Mandagi');
      await _pilih(tester, 'Keputusan gereja', 'Belum ada dokumen');
      await tekan(tester, 'Bentuk Panitia');
      expect(
        find.textContaining(
          'pembentukan Panitia memerlukan keputusan tertulis gereja di '
          'Dokumen gereja.',
        ),
        findsOneWidget,
      );
      expect(repo.list().where((p) => p.name == nama), isEmpty);
      // The repository holds the officer rule too.
      final sama = await repo.create(
        c.read(actorProvider)!,
        nama,
        'dokumen-sk-panitia-natal',
        const PanitiaOfficers(
          ketuaId: 'stevi',
          sekretarisId: 'stevi',
          bendaharaId: 'rivo',
        ),
        idempotencyKey: 'p16-sama',
      );
      expect(
        sama.refusal?.because,
        'Ketua, Sekretaris dan Bendahara harus tiga orang yang berbeda.',
      );
      await _pilih(tester, 'Keputusan gereja', sk);
      await tekan(tester, 'Bentuk Panitia');
      final baru = repo.list().singleWhere((p) => p.name == nama);
      expect(baru.stage, PanitiaStage.planning);
      expect(baru.officers!.bendaharaId, 'rivo');
      // Its officers hold its posts (DL26, DL29).
      expect(
        {
          for (final v
              in c.read(roleRepositoryProvider).posts(scopeId: baru.scopeId))
            v.post.title: v.holder?.personId,
        },
        {
          'Ketua $nama': 'stevi',
          'Sekretaris $nama': 'natalia',
          'Bendahara $nama': 'rivo',
        },
      );
      expect(find.text('$sk · Dokumen gereja'), findsOneWidget);
      await tekan(tester, 'Aktifkan Panitia');
      expect(repo.get(baru.id)!.stage, PanitiaStage.active);
      expect(repo.get(baru.id)!.fundId, isNotNull);
      expect(
        find.text(
          'Ketua, Sekretaris dan Bendahara Panitia diberi tahu lewat '
          'Pemberitahuan.',
        ),
        findsOneWidget,
      );

      // Panitia Natal to financial closing; closing is refused while um1
      // still has an unaccounted remainder.
      await _pilih(tester, 'Panitia', natal);
      await tekan(tester, 'Tandai acara selesai');
      await tekan(tester, 'Mulai penutupan keuangan');
      expect(repo.get(_natal)!.stage, PanitiaStage.financialClosing);
      expect(
        find.text(
          'Tidak dapat dilakukan: Bukukan. $natal sedang dalam '
          'Penutupan keuangan.',
        ),
        findsOneWidget,
      );
      await tekan(tester, 'Tutup Panitia');
      expect(
        find.textContaining(
          'masih ada Uang Muka yang belum dipertanggungjawabkan.',
        ),
        findsOneWidget,
      );
      expect(repo.get(_natal)!.stage, PanitiaStage.financialClosing);
      await keluar(tester);

      // Meiske records the return of the unused Rp650.000 into Umum.
      final dana = c.read(fundRepositoryProvider);
      final umum = dana.balance('umum');
      expect(repo.money(_natal).outstanding, 650000);
      await masukSebagai(tester, Persona.meiske);
      // The ledger holds the stage: no ordinary booking on its Fund.
      final biasa = await c
          .read(transactionRepositoryProvider)
          .createDraft(
            c.read(actorProvider)!,
            TransactionDraft(
              type: TransactionType.income,
              effectiveDate: c.read(hariIniProvider),
              description: 'Persembahan $natal',
              accountId: 'kas',
              allocations: [
                Allocation(amount: 100000, fundId: repo.get(_natal)!.fundId),
              ],
            ),
            idempotencyKey: 'p16-biasa',
          );
      expect(
        biasa.refusal?.because,
        contains('$natal sedang dalam Penutupan keuangan.'),
      );
      await tekan(tester, 'Sisa uang $natal');
      await _pilih(tester, 'Panitia', natal);
      expect(find.text(rp(650000)), findsWidgets);
      await tekan(tester, 'Catat pengembalian sisa ${rp(650000)}');
      expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);
      expect(repo.money(_natal).outstanding, 650000);
      await periksaOlehJefry(tester, _kembali);
      await ke(Layar.panitia);
      await _pilih(tester, 'Panitia', natal);
      await tekan(tester, 'Bukukan pengembalian');
      final m = repo.money(_natal);
      expect(m.outstanding, 0);
      expect(m.returned, 650000);
      expect(m.fundBalance, 0);
      expect(dana.balance('umum'), umum + 650000);
      final tx = c.read(transactionRepositoryProvider);
      final buku = tx.get(
        c
            .read(auditRepositoryProvider)
            .list(const AuditFilter(actionPrefix: 'finance.txn.finalize'))
            .first
            .ref!
            .id,
      )!;
      expect(buku.description, _kembali);
      expect(buku.finalizedBy, 'meiske');

      // ... and approves the leftover's destination.
      await _pilih(tester, 'Tujuan sisa uang', 'Umum Jemaat');
      await tekan(tester, 'Setujui tujuan sisa uang');
      final p = repo.get(_natal)!;
      expect(p.leftoverApproved, isTrue);
      expect(p.leftoverFundId, 'umum');
      expect(p.leftoverAmount, 650000);
      expect(find.text('Sisa uang ${rp(650000)}'), findsOneWidget);
      expect(find.text('Disetujui oleh Meiske Lumentut'), findsOneWidget);
      await ke(Layar.beranda);
      expect(find.text('Sisa uang $natal'), findsNothing);
      await keluar(tester);

      // Lidya closes and retires it.
      await masukSebagai(tester, Persona.lidya);
      await ke(Layar.panitia);
      await _pilih(tester, 'Panitia', natal);
      await tekan(tester, 'Tutup Panitia');
      expect(repo.get(_natal)!.stage, PanitiaStage.closed);
      expect(c.read(orgRepositoryProvider).scope(_natal)!.active, isFalse);
      expect(
        find.text(
          'Peruntukan Panitia Natal bersaldo Rp0 dan dinonaktifkan untuk '
          'transaksi baru.',
        ),
        findsOneWidget,
      );
      await tekan(tester, 'Arsipkan');
      expect(repo.get(_natal)!.stage, PanitiaStage.retired);
      expect(find.textContaining('Hanya baca.'), findsOneWidget);
      expect(c.read(sessionProvider)?.persona, Persona.lidya);
    });
  });
}
