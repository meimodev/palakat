// P1 Home and inbox, finance part (README 8.3): each finance persona's
// "Perlu tindakan" rows come from real open items; finishing the item
// removes the row (booking the 2 church drafts removes "2 draf belum
// dibukukan"); no web home row links a phone-only screen. On the phone
// Meiske's home is the finance home (owner change 21/11): Main's summary,
// then the role-home rows it does not already show.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/bilah_ponsel.dart';
import 'package:palakat_prototype/providers/home_rows.dart';
import 'package:palakat_prototype/providers/keuangan/beranda.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';

import 'harness.dart';

const _honor = 'draf-honor-pemusik';
const _fotokopi = 'draf-fotokopi-warta';

bool _keuangan(HomeRow r) =>
    r.ke.modulLayar == ModulLayar.keuangan ||
    r.ke.modulLayar == ModulLayar.keuanganUnit;

void main() {
  group('P1 beranda keuangan', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        final tx = c.read(transactionRepositoryProvider);
        final ponsel = tata == Tata.ponsel;

        /// The rows the home draws as row cards: on the phone's finance
        /// home, those Main's summary does not show.
        List<HomeRow> tampil() =>
            ponsel && c.read(berandaKeuanganPonselProvider)
            ? c.read(barisBerandaKeuanganProvider)
            : c.read(homeRowsProvider);

        Future<void> keBeranda() async {
          c.read(routerProvider).go(Layar.beranda.lokasi());
          await tester.pumpAndSettle();
        }

        // Every persona: no web row links a phone-only screen; only the
        // finance personas get finance rows.
        for (final p in Persona.values) {
          await masukSebagai(tester, p);
          if (p == Persona.hendrik) {
            await tekan(tester, 'Sebagai Penatua Kolom 7');
          }
          final baris = c.read(homeRowsProvider);
          for (final r in baris) {
            expect(r.ke.adaUntuk(tata), isTrue, reason: '${p.name} ${r.judul}');
          }
          for (final r in tampil().where(_keuangan)) {
            expect(find.text(r.judul), findsOneWidget, reason: r.judul);
          }
          const keuangan = {
            Persona.meiske,
            Persona.jefry,
            Persona.deasy,
            Persona.olga,
            Persona.rivo,
          };
          if (!keuangan.contains(p)) {
            expect(baris.where(_keuangan), isEmpty, reason: p.name);
          }
          await keluar(tester);
        }

        // Unit treasurer and scoped preparers: rows from their open items.
        await masukSebagai(tester, Persona.deasy);
        final unit = tx.drafts().where((t) => t.unitScopeId == 'kolom-7');
        expect(unit, hasLength(2));
        expect(find.text('2 draf Kolom 7 belum dibukukan'), findsOneWidget);
        expect(
          find.text('Kesiapan peruntukan Kolom 7 · Oktober 2026'),
          findsOneWidget,
        );
        await keluar(tester);
        await masukSebagai(tester, Persona.olga);
        expect(
          find.text('Kesiapan peruntukan Diakonia · Oktober 2026'),
          findsOneWidget,
        );
        await keluar(tester);
        await masukSebagai(tester, Persona.rivo);
        expect(
          find.text('Kesiapan peruntukan Pembangunan · Oktober 2026'),
          findsOneWidget,
        );
        await keluar(tester);

        // Jefry: the drafts he may still check, open months only.
        await masukSebagai(tester, Persona.jefry);
        expect(find.text('4 draf menunggu pemeriksaan'), findsOneWidget);
        await keluar(tester);

        // Meiske: the Bendahara's rows; on the phone Main's summary holds
        // them and the dashed draft pill the sum.
        await masukSebagai(tester, Persona.meiske);
        final b = c.read(berandaKeuanganProvider);
        expect(b.drafJumlah, 2);
        expect(
          find.text('Keuangan: ${b.perluTindakan.length} hal perlu tindakan'),
          ponsel ? findsNothing : findsOneWidget,
        );
        expect(find.text('2 draf belum dibukukan'), findsOneWidget);
        expect(
          find.text(
            ponsel
                ? 'Rp800.000 · 2 draf · belum masuk saldo'
                : 'Belum masuk saldo · Rp800.000',
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            '${b.hambatan.where((h) => h.unitScopeId != null).length} '
            'hambatan dari unit',
          ),
          findsOneWidget,
        );

        // Each Meiske row opens its screen in this layout.
        for (final r in tampil()) {
          await tekan(tester, r.judul);
          expect(tester.takeException(), isNull, reason: r.judul);
          expect(find.text('Tidak berwenang'), findsNothing, reason: r.judul);
          await keBeranda();
        }

        // The music fee draft still lacks its Mata Anggaran: Meiske picks
        // Honorarium pelayan (the draft form is F2's), then Jefry checks
        // both drafts and Meiske books them from Draf.
        final honor = tx.get(_honor)!;
        final r = await tx.editDraft(
          c.read(actorProvider)!,
          _honor,
          TransactionPatch(
            allocations: [
              for (final a in honor.allocations)
                a.copyWith(masterCode: '5.07.01.00'),
            ],
          ),
          expectedRevision: honor.revision,
          idempotencyKey: 'p1-honor-${tata.name}',
        );
        expect(r.isOk, isTrue, reason: '${r.refusal}');
        await tester.pumpAndSettle();

        await periksaOlehJefry(tester, 'Honor pemusik');
        await periksaOlehJefry(tester, 'Fotokopi warta jemaat');

        await keluar(tester);
        await masukSebagai(tester, Persona.jefry);
        expect(find.text('2 draf menunggu pemeriksaan'), findsOneWidget);
        await keluar(tester);
        await masukSebagai(tester, Persona.meiske);

        Future<void> bukukan(String id) async {
          c.read(routerProvider).go(Layar.draf.lokasi(param: {'id': id}));
          await tester.pumpAndSettle();
          await tekan(tester, 'Periksa dan bukukan');
          expect(tx.get(id)!.isPosted, isTrue, reason: id);
          await keBeranda();
        }

        await bukukan(_honor);
        expect(find.text('1 draf belum dibukukan'), findsOneWidget);
        expect(
          find.text(
            ponsel
                ? 'Rp150.000 · 1 draf · belum masuk saldo'
                : 'Belum masuk saldo · Rp150.000',
          ),
          findsOneWidget,
        );
        await bukukan(_fotokopi);
        expect(find.textContaining('draf belum dibukukan'), findsNothing);
        expect(c.read(berandaKeuanganProvider).drafJumlah, 0);
        expect(
          find.text(
            'Keuangan: ${c.read(berandaKeuanganProvider).perluTindakan.length}'
            ' hal perlu tindakan',
          ),
          ponsel ? findsNothing : findsOneWidget,
        );
        expect(tx.get(_honor)!.finalizedBy, 'meiske');
        // The audit actors (AuditRepository).
        expect(
          jejakTransaksi(c, _honor, 'finance.txn.edit').personId,
          'meiske',
        );
        expect(
          jejakTransaksi(c, _honor, 'finance.txn.review').personId,
          'jefry',
        );
        expect(
          jejakTransaksi(c, _honor, 'finance.txn.finalize').personId,
          'meiske',
        );

        // A church draft dated in the month waiting to close is counted by
        // "N draf belum dibukukan" and listed where that row leads.
        final lalu = c.read(berandaKeuanganProvider).bulan.berikutDitutup!;
        final baru = await tx.createDraft(
          c.read(actorProvider)!,
          TransactionDraft(
            type: TransactionType.expense,
            effectiveDate: lalu.end,
            description: 'Sewa kursi bulan lalu',
            accountId: 'kas',
            allocations: const [
              Allocation(amount: 90000, fundId: 'umum', scopeId: 'jemaat'),
            ],
          ),
          idempotencyKey: 'p1-lalu-${tata.name}',
        );
        expect(baru.isOk, isTrue, reason: '${baru.refusal}');
        await keBeranda();
        expect(find.text('1 draf belum dibukukan'), findsOneWidget);
        await tekan(tester, '1 draf belum dibukukan');
        expect(find.text('Sewa kursi bulan lalu'), findsWidgets);
      });
    }
  });
}
