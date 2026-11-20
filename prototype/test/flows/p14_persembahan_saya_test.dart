// P14 My giving (README 8.3): Meiske records a sampul syukur, names Novita
// as its giver on PersembahanBernama (J1: the envelope's Party links to her
// Person) and books it after periksaOlehJefry. Novita's PersembahanSaya then
// lists that envelope and the seeded Wenas-Lasut sampul syukur at
// mingguLalu(3) (DP22), and nothing given in anyone else's name.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/data/seed/jangkar.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/keuangan/persembahan_bernama.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';

import 'harness.dart';

const _uraian = 'Sampul syukur, Ibadah Minggu Sore';
const _jumlah = 250000;

void main() {
  testWidgets('P14 persembahan saya', (tester) async {
    final c = await bukaAplikasi(tester);
    final tx = c.read(transactionRepositoryProvider);
    final hari = c.read(hariIniProvider);
    await masukSebagai(tester, Persona.meiske);
    final syukur = tx.list(null).singleWhere((t) => t.seedKey == '0132');
    expect(
      syukur.effectiveDate,
      Jangkar(hariIni: hari, sekarang: jangkarA).mingguLalu(3),
    );
    expect(syukur.allocations.single.partyId, 'party-novita');

    final d = await catatSampul(tester, _uraian, _jumlah);
    await namaiPemberi(tester, 'Novita Wenas');
    expect(tx.get(d.id)!.allocations.single.partyId, 'party-novita');
    expect(find.text('Novita Wenas'), findsOneWidget);
    await periksaOlehJefry(tester, _uraian);
    final t = await bukukanDraf(tester, d.id);

    await keluar(tester);
    await masukSebagai(tester, Persona.novita);
    c.read(routerProvider).go(Layar.persembahanSaya.lokasi());
    await tester.pumpAndSettle();

    // Exactly her two named gifts, newest first.
    final daftar = c.read(persembahanSayaProvider);
    expect([for (final s in daftar) s.t.id], [t.id, syukur.id]);
    for (final s in daftar) {
      expect(find.text(s.judul), findsWidgets);
      expect(find.text(rp(s.a.amount)), findsOneWidget);
      expect(
        find.text('${s.tanggal} · ${s.diterima} · Umum Jemaat'),
        findsOneWidget,
      );
    }
    expect(find.text(rp(_jumlah)), findsOneWidget);
    expect(find.text(rp(100000)), findsOneWidget);
    // Nobody else's: the seeded donation of Ibu Runtu and the Sunday
    // offerings are not listed.
    expect(find.text(rp(500000)), findsNothing);
    expect(find.textContaining('Persembahan Ibadah Minggu'), findsNothing);

    // Rincian of the new envelope shows its No. Bukti.
    await tekan(
      tester,
      '${tgl(t.effectiveDate.awal)} · Ibadah Minggu Sore · '
      'Umum Jemaat',
    );
    expect(find.text(t.voucher!), findsOneWidget);
    expect(find.text('Dibukukan'), findsOneWidget);
    tidakAdaTanggalNanti(tester, hari, 'PersembahanSaya');
    expect(tester.takeException(), isNull);
  });
}
