// Sanity checks on lib/mock/: the totals mock-data.md says add up do add up,
// and the vacancy swap behaves as the boards' tukarJk.
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/boards.dart';
import 'package:palakat_prototype/mock/mock.dart';

/// 'Rp1.234.000' / '−Rp750.000' / '12.170.000' / '0' → signed int.
int angka(String s) {
  final n = int.parse(s.replaceAll(RegExp(r'[^0-9]'), ''));
  return s.contains('−') ? -n : n;
}

int jumlahNilai(Map<String, int> m) => m.values.fold(0, (a, b) => a + b);

void main() {
  group('Kas/Bank balances', () {
    test('totals of the Jemaat Kas/Bank', () {
      expect(jumlahNilai(saldoPembukaan), totalSaldoPembukaan);
      expect(jumlahNilai(saldo1Oktober), totalSaldo1Oktober);
      expect(jumlahNilai(saldo31Oktober), totalSaldo31Oktober);
      expect(jumlahNilai(saldoNovember), totalSaldoNovember);
    });

    test('opening Kas split and BNI by peruntukan', () {
      expect(
        jumlahNilai(kasPembukaanPerPeruntukan) +
            kasPembukaanPembangunanPenyeimbang,
        saldoPembukaan['kas'],
      );
      expect(jumlahNilai(bniPerPeruntukanNovember), saldoNovember['bni']);
    });
  });

  group('F02 Buku Kas Umum, October', () {
    test('31 rows, totals and closing balance', () {
      expect(f02Oktober.length, 31);
      expect(f02SaldoSetelah.length, 31);
      final masuk = f02Oktober.fold(0, (a, t) => a + t.masuk);
      final keluar = f02Oktober.fold(0, (a, t) => a + t.keluar);
      expect(masuk, f02Jumlah.masuk);
      expect(keluar, f02Jumlah.keluar);
      expect(f02SaldoAwal + masuk - keluar, f02Jumlah.saldo);
      expect(f02SaldoAwal, totalSaldo1Oktober);
      expect(f02Jumlah.saldo, totalSaldo31Oktober);
    });

    test('running balance matches every printed saldo', () {
      var saldo = f02SaldoAwal;
      for (var i = 0; i < f02Oktober.length; i++) {
        saldo += f02Oktober[i].masuk - f02Oktober[i].keluar;
        expect(saldo, f02SaldoSetelah[i], reason: f02Oktober[i].noBukti);
      }
    });

    test('page subtotals', () {
      (int, int) sampai(String noBukti) {
        final n = f02Oktober.indexWhere((t) => t.noBukti == noBukti) + 1;
        final r = f02Oktober.take(n);
        return (
          r.fold(0, (a, t) => a + t.masuk),
          r.fold(0, (a, t) => a + t.keluar),
        );
      }

      expect(sampai('BKU-2026-0108'), (f02Halaman1.masuk, f02Halaman1.keluar));
      expect(sampai('BKU-2026-0125'), (f02Halaman2.masuk, f02Halaman2.keluar));
    });

    test('split rows add up to their amount', () {
      for (final t in f02Oktober.where((t) => t.bagian.isNotEmpty)) {
        final b = t.bagian.fold(0, (a, p) => a + p.jumlah);
        expect(b, t.masuk + t.keluar, reason: t.noBukti);
      }
    });
  });

  group('October report tables', () {
    test('F01: saldo awal plus movements is saldo akhir', () {
      final v = f01Oktober.map((r) => angka(r[1])).toList();
      expect(v.sublist(0, 7).fold(0, (a, b) => a + b), v[7]);
      expect(v.first, totalSaldo1Oktober);
      expect(v.last, totalSaldo31Oktober);
    });

    test('F05 and F07 headings and totals', () {
      int f(List<List<String>> t, String n) =>
          angka(t.firstWhere((r) => r[0] == n)[1]);
      expect(
        f(f05Oktober, 'Persembahan Ibadah Minggu') +
            f(f05Oktober, 'Persembahan syukur') +
            f(f05Oktober, 'Persembahan Diakonia'),
        f(f05Oktober, 'PERSEMBAHAN'),
      );
      expect(
        f(f05Oktober, 'PERSEMBAHAN') + f(f05Oktober, 'SUMBANGAN'),
        f(f05Oktober, 'Jumlah Pendapatan'),
      );
      final operasional = f07Oktober
          .sublist(1, 8)
          .fold(0, (a, r) => a + angka(r[1]));
      expect(operasional, f(f07Oktober, 'BELANJA OPERASIONAL'));
      expect(
        f(f07Oktober, 'BELANJA OPERASIONAL') +
            f(f07Oktober, 'BELANJA PELAYANAN'),
        f(f07Oktober, 'Jumlah Belanja'),
      );
      expect(f(f05Oktober, 'Jumlah Pendapatan'), angka(f01Oktober[1][1]));
      expect(-f(f07Oktober, 'Jumlah Belanja'), angka(f01Oktober[2][1]));
    });

    test('F08 and F09: rows, columns and F02 totals', () {
      for (final (tabel, jumlahF02) in [
        (f08Oktober, f02Jumlah.masuk),
        (f09Oktober, f02Jumlah.keluar),
      ]) {
        for (final r in tabel) {
          final v = r.skip(1).map(angka).toList();
          expect(v.sublist(0, 4).fold(0, (a, b) => a + b), v[4], reason: r[0]);
        }
        for (var c = 1; c < 6; c++) {
          final kolom = tabel.take(3).fold(0, (a, r) => a + angka(r[c]));
          expect(kolom, angka(tabel[3][c]));
        }
        expect(angka(tabel[3][5]), jumlahF02);
      }
    });

    test('F10 and F11 reconcile to zero', () {
      for (var c = 1; c < 4; c++) {
        int b(int r) => angka(f11Oktober[r][c]);
        expect(b(0) + b(1) - b(2), b(3));
        expect(b(3) - b(4), b(5));
      }
      final buku = f10Oktober.take(3).fold(0, (a, r) => a + angka(r[1]));
      expect(buku, angka(f10Oktober[3][1]));
      expect(buku, totalSaldo31Oktober);
    });

    test('Cari answer and TERBATAS Diakonia', () {
      expect(cariJawaban.fold(0, (a, r) => a + r.$2), cariJumlah);
      expect(cariJumlah, angka(f05Oktober[1][1]));
      expect(
        angka(f03Terbatas[0][1]) +
            angka(f03Terbatas[1][1]) -
            angka(f03Terbatas[2][1]),
        angka(f03TerbatasSaldoDiakonia.akhir),
      );
    });
  });

  group('Month end', () {
    test('BNI reconciliation', () {
      final r = rekonBniOktober;
      expect(r.saldoBuku - r.saldoRekeningKoran, rekonSelisihAwal);
      expect(r.saldoBuku - trx0133.keluar, rekonSaldoBukuSetelahBiaya);
      expect(
        r.saldoRekeningKoran + r.dalamPerjalanan,
        rekonSaldoBukuSetelahBiaya,
      );
      expect(rekonSaldoBukuSetelahBiaya, saldo31Oktober['bni']);
      // m1 matches t1 + t2, m2 matches t3, t4 is the deposit in transit.
      final t = r.belumCocok.map((x) => x.jumlah).toList();
      expect(t, [500000, 500000, -2000000, 500000]);
      expect(r.mutasi[0].jumlah, t[0] + t[1]);
      expect(r.mutasi[1].jumlah, t[2]);
      expect(t[3], r.dalamPerjalanan);
      expect(r.mutasi[2].jumlah, trx0133.jumlah);
      // RekonIsi: t4 is the fee, already matched to BIAYA ADM.
      expect(rekonIsiBni.belumCocok[3].jumlah, r.mutasi[2].jumlah);
    });

    test('hitung kas', () {
      expect(hitungKasTerisi.jumlah, 8370000);
      expect(hitungKasSaldoBuku - hitungKasTerisi.jumlah, 50000);
      expect(hitungKasSaldoBuku, saldoNovember['kas']);
      expect(hitungKasKosong.jumlah, 0);
    });
  });

  group('November', () {
    test('Beranda figures', () {
      expect(
        berandaNovember.pendapatan - berandaNovember.belanja,
        berandaNovember.surplus,
      );
      final drafs = transaksiNovember.where(
        (t) => t.status == StatusTransaksi.draf,
      );
      expect(drafs.length, 2);
      expect(
        -drafs.fold(0, (a, t) => a + t.jumlah),
        berandaNovember.drafJumlah,
      );
    });

    test('advances, deposits, claims', () {
      final sisa = {for (final k in semuaKasus) k.id: k.sisa};
      expect(sisa, {
        'um1': 650000,
        'um2': 500000,
        'um3': 0,
        'tt1': 1400000,
        'tt2': 450000,
        'pb1': 185000,
        'pb2': 0,
      });
      // "2 uang muka dengan sisa … Rp1.150.000"
      final um = semuaKasus.where(
        (k) => k.jenis == JenisKasus.uangMuka && k.sisa > 0,
      );
      expect(um.length, 2);
      expect(um.fold(0, (a, k) => a + k.sisa), 1150000);
    });

    test('multi-part offering', () {
      final b = persembahanBagian.map((p) => p.jumlah).toList();
      expect(b.fold(0, (a, n) => a + n), persembahanJumlah);
      expect(b[0] + b[1], persembahanMilikSendiri);
      expect(b[2], persembahanTitipan);
    });

    test('attendance', () {
      expect(
        kehadiranPagi.perPos.values.fold(0, (a, n) => a + n),
        kehadiranJumlah,
      );
      expect(96 + kehadiranJumlah + 85, 412); // Warta: Subuh · Pagi · Malam
    });
  });

  group('Vacancy scenario', () {
    test('tukarJk swaps only undated or 16/11/2026 strings', () {
      expect(
        tukarJk('Terverifikasi (oleh Meiske L.)'),
        'Terverifikasi (oleh Yanti Sumual, Operator)',
      );
      expect(
        tukarJk('16/11/2026 10.42 · Dibukukan oleh Meiske L.'),
        '16/11/2026 10.42 · Dibukukan oleh Yanti Sumual, Operator',
      );
      const lama = 'Dicatat oleh Meiske L., 03/10/2026 11.40';
      expect(tukarJk(lama), lama);
      const campur = 'Meiske L. 16/11/2026 dan 15/11/2026';
      expect(tukarJk(campur), campur);
      expect(tukarJk('Tanpa nama'), 'Tanpa nama');
    });

    test('only on boards that enable it, and only with the switch on', () {
      const s = 'Terverifikasi (oleh Meiske L.)';
      expect(tukarJkPapan('Main', true, s), tukarJk(s));
      expect(tukarJkPapan('Main', false, s), s);
      expect(tukarJkPapan('WebTransaksi', true, s), s);
      for (final stem in papanTukarJk) {
        expect(papanMenurutStem.containsKey(stem), isTrue, reason: stem);
      }
    });

    test('nested walk', () {
      expect(
        tukarJkDalam({
          'a': 'oleh Meiske L.',
          'b': [
            'Meiske L.',
            {'c': 'Meiske L., 03/10/2026'},
          ],
          'n': 3,
        }),
        {
          'a': 'oleh Yanti Sumual, Operator',
          'b': [
            'Yanti Sumual, Operator',
            {'c': 'Meiske L., 03/10/2026'},
          ],
          'n': 3,
        },
      );
    });

    test('nested walk stops below depth 6, as the board', () {
      Object? bersarang(int n) => n == 0 ? 'Meiske L.' : [bersarang(n - 1)];
      Object? dasar(Object? o) => o is List ? dasar(o.first) : o;
      expect(dasar(tukarJkDalam(bersarang(6))), 'Yanti Sumual, Operator');
      expect(dasar(tukarJkDalam(bersarang(7))), 'Meiske L.');
    });

    test('plk names and close text', () {
      expect(plk(false), 'Meiske L.');
      expect(plk(true), 'Yanti Sumual, Operator');
      expect(plk2(false), 'Meiske L.');
      expect(
        plk2(true),
        'Yanti Sumual, Operator (menjalankan jabatan kosong Bendahara Jemaat)',
      );
      expect(jkDitutupOleh, startsWith('Ditutup oleh ${plk(true)}, yang '));
    });
  });

  test('keWeb maps phone targets as the platform boards do', () {
    expect(keWeb('Main'), 'WebBeranda');
    expect(keWeb('Ibadah'), 'Ibadah');
    expect(keWeb('PermohonanSurat'), 'WebPermohonanSurat');
    final targets = [
      for (final o in berandaJabatan) ...[...o.tindak, ...o.tahu],
      ...kotakMasukAda.tindak,
      ...kotakMasukAda.tahu,
      ...kotakMasukKeuangan.tindak,
      ...kotakMasukKeuangan.tahu,
      ...antreanKolom7,
      ...antreanKolom2,
      ...cariOrangHasil,
    ].map((i) => i.ke);
    for (final ke in targets) {
      expect(papanMenurutStem.containsKey(ke), isTrue, reason: ke);
      expect(papanMenurutStem.containsKey(keWeb(ke)), isTrue, reason: ke);
    }
  });
}
