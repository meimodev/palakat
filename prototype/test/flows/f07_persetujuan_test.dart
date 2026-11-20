// F7 External approval (README 8.3): a Belanja draft that needs approval
// shows "Persetujuan belum dicatat"; "Catat persetujuan" makes the card solid
// with giver, date and method; "Ganti" keeps the old record in Riwayat as
// "Digantikan"; changing the amount voids it ("Persetujuan belum dicatat").

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/keuangan/persetujuan.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';

import 'harness.dart';

const _uraian = 'Perbaikan sound system';

void main() {
  group('F7 persetujuan', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final w = await bukaAplikasi(tester, tata: tata);
        final tx = w.read(transactionRepositoryProvider);
        final setuju = w.read(approvalRepositoryProvider);
        await masukSebagai(tester, Persona.meiske);

        final hari = w.read(hariIniProvider);
        final baru = await tx.createDraft(
          w.read(actorProvider)!,
          TransactionDraft(
            type: TransactionType.expense,
            effectiveDate: hari,
            description: _uraian,
            accountId: 'bni',
            approvalMode: ApprovalMode.external,
            approvalRule: 'Belanja Rp2.000.000 ke atas',
            allocations: const [
              Allocation(
                amount: 2500000,
                fundId: 'umum',
                scopeId: 'jemaat',
                masterCode: '5.08.02.00',
              ),
            ],
          ),
          idempotencyKey: 'f7-${tata.name}',
        );
        expect(baru.isOk, isTrue, reason: '${baru.refusal}');
        final id = baru.value.id;
        List<ApprovalRecord> rekam(ApprovalStatus s) => [
          for (final a in setuju.forTransaction(id))
            if (a.status == s) a,
        ];

        w.read(routerProvider).go(Layar.persetujuan.lokasi(param: {'id': id}));
        await tester.pumpAndSettle();
        expect(find.text(_uraian), findsOneWidget);
        expect(find.text('Persetujuan belum dicatat'), findsOneWidget);

        Future<void> ketik(int i, String teks) async {
          final f = find.byType(EditableText).at(i);
          await tester.ensureVisible(f);
          await tester.enterText(f, teks);
          await tester.pumpAndSettle();
        }

        Future<void> kirim(String label) async {
          final f = find.text(label).last;
          await tester.ensureVisible(f);
          await tester.pumpAndSettle();
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        // Catat: the card turns solid with giver, date and method.
        await tekan(tester, 'Catat persetujuan');
        await ketik(0, 'Pdt. Lidya Rondonuwu');
        await kirim('Catat persetujuan');
        expect(rekam(ApprovalStatus.recorded), hasLength(1));
        expect(find.text('Persetujuan sudah dicatat'), findsOneWidget);
        expect(find.textContaining('Pdt. Lidya Rondonuwu'), findsWidgets);
        expect(find.textContaining(tgl(hari.awal)), findsWidgets);
        expect(find.textContaining('notulen rapat'), findsWidgets);
        expect(find.textContaining('Meiske L.'), findsWidgets);

        // Ganti: a reason is required; the old one stays as "Digantikan".
        await tekan(tester, 'Ganti catatan persetujuan');
        await ketik(0, 'Pnt. Jefry Wowor');
        await kirim('Ganti catatan persetujuan');
        expect(rekam(ApprovalStatus.superseded), isEmpty);
        await ketik(2, 'nama pemberi persetujuan keliru');
        await kirim('Ganti catatan persetujuan');
        expect(rekam(ApprovalStatus.superseded), hasLength(1));
        expect(
          rekam(ApprovalStatus.recorded).single.declaration.approverName,
          'Pnt. Jefry Wowor',
        );
        expect(find.text('Riwayat persetujuan'), findsOneWidget);
        expect(
          find.textContaining('alasan: nama pemberi persetujuan keliru'),
          findsOneWidget,
        );
        expect(find.textContaining('Digantikan '), findsOneWidget);

        // Changing the amount voids it.
        await tekan(tester, 'Ubah jumlah');
        await tekan(tester, 'Ubah menjadi ${rp(jumlahUbahan(2500000))}');
        expect(tx.get(id)!.total, jumlahUbahan(2500000));
        expect(rekam(ApprovalStatus.recorded), isEmpty);
        expect(rekam(ApprovalStatus.voided), hasLength(1));
        expect(find.text('Persetujuan belum dicatat'), findsOneWidget);
        expect(find.textContaining('Tidak berlaku lagi sejak'), findsOneWidget);
        expect(find.textContaining('Digantikan '), findsOneWidget);
      });
    }
  });
}
