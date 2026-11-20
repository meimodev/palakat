// The flow-test harness (README 8.1). Every flow test starts the real app
// with bukaAplikasi, signs in through the picker and drives the UI.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/app.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/app/tata.dart';
import 'package:palakat_prototype/core/clock.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/clock.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/layout.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/repositories_sekretariat.dart';
import 'package:palakat_prototype/providers/revision.dart';
import 'package:palakat_prototype/providers/session.dart';
import 'package:palakat_prototype/widgets/kecil.dart';

export 'package:palakat_prototype/app/tata.dart' show Tata;
export 'package:palakat_prototype/providers/session.dart' show Persona;

/// The story date: 16/11/2026 12.05 WITA, where board and seed dates agree.
final jangkarA = DateTime.utc(2026, 11, 16, 12, 5);

/// Year boundary: 05/01/2027 10.00 WITA.
final jangkarB = DateTime.utc(2027, 1, 5, 10);

/// Short month before: 03/03/2027 09.00 WITA.
final jangkarC = DateTime.utc(2027, 3, 3, 9);

/// Day 1 of a month: 01/06/2027 08.00 WITA.
final jangkarD = DateTime.utc(2027, 6, 1, 8);

/// The test view size of each layout (README 3.2).
const ukuranTata = {
  Tata.ponsel: Size(390, 844),
  Tata.tablet: Size(834, 1112),
  Tata.web: Size(1440, 1000),
};

/// Pumps the app with a fixed clock at [saat] (default [jangkarA]) and the
/// layout [tata] at its view size, and returns the app's container so the test
/// can read end states. The picker shows.
Future<ProviderContainer> bukaAplikasi(
  WidgetTester tester, {
  Tata tata = Tata.ponsel,
  DateTime? saat,
}) async {
  tester.view.physicalSize = ukuranTata[tata]!;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(FixedClock(saat ?? jangkarA)),
        layoutProvider.overrideWithValue(tata),
      ],
      child: const PalakatApp(),
    ),
  );
  await tester.pumpAndSettle();
  return _wadah(tester);
}

ProviderContainer _wadah(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PalakatApp)));

/// Taps [p] on the picker; the role home opens.
Future<void> masukSebagai(WidgetTester tester, Persona p) async {
  expect(find.text('Masuk sebagai'), findsOneWidget, reason: 'picker');
  await tekan(tester, p.nama);
}

/// Signs out the way a person does: Akun, "Keluar", then "Keluar" again to
/// confirm. Back on the picker; every other state is kept.
Future<void> keluar(WidgetTester tester) async {
  _wadah(tester).read(routerProvider).go(Layar.akun.lokasi());
  await tester.pumpAndSettle();
  await tekan(tester, 'Keluar');
  expect(find.text('Keluar dari perangkat ini?'), findsOneWidget);
  await tekan(tester, 'Keluar');
  expect(find.text('Masuk sebagai'), findsOneWidget, reason: 'picker');
}

/// Taps the first widget showing [teks], scrolling it into view first.
Future<void> tekan(WidgetTester tester, String teks) async {
  final f = find.text(teks).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Types [nilai] into the field labelled [label].
Future<void> isi(WidgetTester tester, String label, String nilai) async {
  final kotak = find.ancestor(
    of: find.text(label),
    matching: find.byType(IsianTeks),
  );
  final f = find
      .descendant(of: kotak.first, matching: find.byType(EditableText))
      .first;
  await tester.ensureVisible(f);
  await tester.enterText(f, nilai);
  await tester.pumpAndSettle();
}

/// Holds a hold-to-confirm button ([teks]) until it fills (`segelTahan`
/// 1600 ms, plus a margin).
Future<void> tahan(WidgetTester tester, String teks) async {
  final f = find.text(teks).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  final g = await tester.startGesture(tester.getCenter(f));
  await tester.pump(const Duration(milliseconds: 1700));
  await g.up();
  await tester.pumpAndSettle();
}

/// Pumps past a board timer that fakes outside work (`// tiruan:`).
Future<void> tungguTiruan(WidgetTester tester, Duration d) async {
  await tester.pump(d);
  await tester.pumpAndSettle();
}

/// The location the router shows now.
String lokasiSekarang(WidgetTester tester) =>
    _wadah(tester)
        .read(routerProvider)
        .routerDelegate
        .currentConfiguration
        .uri
        .toString();

/// Moves the test's [FixedClock] forward by [d], bumps the store revision so
/// read models re-read the date, and pumps (README 8.1). The seed anchor
/// stays at launch.
Future<void> majukanJam(WidgetTester tester, Duration d) async {
  final wadah = _wadah(tester);
  (wadah.read(clockProvider) as FixedClock).majukan(d);
  wadah.read(revisionProvider.notifier).bump();
  await tester.pumpAndSettle();
}

/// The second check every booking needs while "Wajib pemeriksa kedua" is on
/// (D24, README 8.1): signs out, signs in as Jefry, opens Pemeriksa, taps
/// the draft whose description is [uraian] and "Tandai sudah diperiksa",
/// then signs out and back in as the persona signed in before.
///
/// Screen contract (Pemeriksa, WebPemeriksa): the queue lists each draft by
/// its description; tapping it selects or opens it, and then one enabled
/// "Tandai sudah diperiksa" acts on that draft.
Future<void> periksaOlehJefry(WidgetTester tester, String uraian) async {
  final wadah = _wadah(tester);
  final sebelum = wadah.read(sessionProvider)?.persona;
  await keluar(tester);
  await masukSebagai(tester, Persona.jefry);
  wadah.read(routerProvider).go(Layar.pemeriksa.lokasi());
  await tester.pumpAndSettle();
  await tekan(tester, uraian);
  await tekan(tester, 'Tandai sudah diperiksa');
  expect(
    wadah
        .read(transactionRepositoryProvider)
        .drafts()
        .any(
          (t) =>
              t.description == uraian && t.status == TransactionStatus.reviewed,
        ),
    isTrue,
    reason: 'draf "$uraian" belum ditandai sudah diperiksa',
  );
  await keluar(tester);
  if (sebelum != null && sebelum != Persona.jefry) {
    await masukSebagai(tester, sebelum);
  }
}

/// The newest audit line of [action] on transaction [id], read from
/// AuditRepository (README 8.1: the audit actor); fails when there is none.
AuditRecord jejakTransaksi(ProviderContainer c, String id, String action) {
  final r = c
      .read(auditRepositoryProvider)
      .list(AuditFilter(ref: RecordRef('transaction', id)))
      .where((x) => x.action == action)
      .firstOrNull;
  expect(r, isNotNull, reason: 'tidak ada $action pada $id');
  return r!;
}

/// The running month and the next month to close at each anchor (README
/// 8.1: the B and C runs assert these labels).
final bulanDiJangkar = {
  jangkarA: ('November 2026', 'Oktober 2026'),
  jangkarB: ('Januari 2027', 'Desember 2026'),
  jangkarC: ('Maret 2027', 'Februari 2027'),
};

const _namaBulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', //
  'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

/// Every date the screen shows (dd/mm/yyyy or "d Bulan yyyy") is not after
/// [hari].
void tidakAdaTanggalNanti(
  WidgetTester tester,
  Tanggal hari,
  String di, {
  Set<String> kecuali = const {},
}) {
  final angka = RegExp(r'\b(\d{2})/(\d{2})/(\d{4})\b');
  final kata = RegExp('\\b(\\d{1,2}) (${_namaBulan.join('|')}) (\\d{4})\\b');
  for (final w in tester.widgetList<RichText>(find.byType(RichText))) {
    final s = w.text.toPlainText();
    for (final m in angka.allMatches(s)) {
      if (kecuali.contains(m[0])) continue;
      final t = Tanggal(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!));
      expect(t <= hari, isTrue, reason: '$di: "$s" setelah $hari');
    }
    for (final m in kata.allMatches(s)) {
      final t = Tanggal(
        int.parse(m[3]!),
        _namaBulan.indexOf(m[2]!) + 1,
        int.parse(m[1]!),
      );
      expect(t <= hari, isTrue, reason: '$di: "$s" setelah $hari');
    }
  }
}

/// The newest audit line of [action], any record (README 8.1: the audit
/// actor of each command a flow runs); fails when there is none.
AuditRecord jejakTerakhir(ProviderContainer c, String action) {
  final r = c
      .read(auditRepositoryProvider)
      .list(AuditFilter(actionPrefix: action))
      .where((x) => x.action == action)
      .firstOrNull;
  expect(r, isNotNull, reason: 'tidak ada $action');
  return r!;
}

/// J1 (F4, P14): the signed-in Bendahara records a "Persembahan syukur"
/// income draft of [jumlah] with Uraian [uraian] through Catat, and
/// returns it. The giver is then named on PersembahanBernama.
Future<Transaction> catatSampul(
  WidgetTester tester,
  String uraian,
  int jumlah,
) async {
  final c = _wadah(tester);
  final ponsel = c.read(layoutProvider) == Tata.ponsel;
  c.read(routerProvider).go(Layar.keuangan.lokasi());
  await tester.pumpAndSettle();
  if (ponsel) {
    await tester.tap(find.bySemanticsLabel('Catat transaksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pendapatan').last);
    await tester.pumpAndSettle();
  } else {
    c.read(routerProvider).go(Layar.catat.lokasi());
    await tester.pumpAndSettle();
    await tekan(tester, 'Pendapatan');
  }
  await tester.enterText(find.byType(EditableText).first, '$jumlah');
  await tester.pumpAndSettle();
  await tekan(tester, 'Kas');
  await tekan(tester, 'Umum Jemaat');
  await tekan(tester, 'Jemaat');
  if (ponsel) await tekan(tester, 'Mata Anggaran belum dipilih');
  await tekan(tester, 'Persembahan syukur');
  await isi(tester, 'Uraian', uraian);
  await tekan(tester, 'Simpan sebagai draf');
  if (ponsel) await tungguTiruan(tester, const Duration(milliseconds: 2600));
  return c
      .read(transactionRepositoryProvider)
      .drafts()
      .singleWhere((t) => t.description == uraian);
}

/// On PersembahanBernama: "Catat nama pemberi", types [nama], "Simpan".
Future<void> namaiPemberi(WidgetTester tester, String nama) async {
  _wadah(tester).read(routerProvider).go(Layar.persembahanBernama.lokasi());
  await tester.pumpAndSettle();
  await tekan(tester, 'Catat nama pemberi');
  await isi(tester, 'Pemberi (anggota)', nama);
  await tekan(tester, 'Simpan');
}

/// Books the checked draft [id] from Draf ("Periksa dan bukukan").
Future<Transaction> bukukanDraf(WidgetTester tester, String id) async {
  final c = _wadah(tester);
  c.read(routerProvider).go(Layar.draf.lokasi(param: {'id': id}));
  await tester.pumpAndSettle();
  await tekan(tester, 'Periksa dan bukukan');
  final t = c.read(transactionRepositoryProvider).get(id)!;
  expect(t.isPosted, isTrue, reason: 'draf $id belum dibukukan');
  return t;
}

/// The seeded assignment decision Penugasan offers (Dokumen gereja, M6-R7).
String skPenugasan(ProviderContainer c) =>
    c.read(documentRepositoryProvider).get('dokumen-sk-penugasan')!.title;
