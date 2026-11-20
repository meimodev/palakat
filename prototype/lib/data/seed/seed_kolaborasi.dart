import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import 'jangkar.dart';
import 'seed_store.dart';

/// The Collaboration seed (README 5.6, 5.7; mock-data 2.20; DP25, DP27,
/// DP28): Panitia Natal (Aktif) with its SK, Panitia Paskah (retired) and
/// HUT (closed); the last Sunday's count Ditetapkan at 231, Adven I
/// scheduled, Ibadah Kolom 7 of the next Thursday waiting for its approver;
/// two fund requests waiting for the Ketua Jemaat. The approver table keeps
/// its defaults (threshold Rp250.000, DL29). Unit finance rows are all in the
/// finance seed (DP14–DP16). Drawn later states are actions in flows.
void seedKolaborasi(SeedStore store, Jangkar a) {
  final t = store.kolaborasi;
  final inti = store.inti;
  String nama(String scopeId) => inti.scope(scopeId)!.name;

  // ---------- Panitia (DL27, DP27) ----------
  // The SK of Panitia Natal (Panitia: "SK BPMJ No. 11/{year} · Dokumen
  // gereja"); its number takes the year of its date (README 5.5).
  final mulaiNatal = a.bln(-1, 1);
  final sk = ChurchDocument(
    id: 'dokumen-sk-panitia-natal',
    kind: DocumentKind.decision,
    title: 'SK BPMJ No. 11/${mulaiNatal.tahun}',
    documentDate: mulaiNatal,
    audience: Audience.servants,
    revisions: [
      DocumentRevision(
        number: 1,
        signedCopy: const SampleFile('sk-panitia-natal.pdf'),
        publishedAt: a.jam(mulaiNatal, 9, 0),
        publishedBy: 'olvie',
      ),
    ],
  );
  store.sekretariat.documents.add(sk);
  final dibentuk = a.jam(mulaiNatal, 9, 30);
  t.panitia.add(
    Panitia(
      id: 'panitia-natal',
      scopeId: 'panitia-natal',
      name: nama('panitia-natal'),
      stage: PanitiaStage.active,
      skDocumentId: sk.id,
      officers: const PanitiaOfficers(
        ketuaId: 'stevi',
        sekretarisId: 'natalia',
        bendaharaId: 'rivo',
      ),
      fundId: 'natal',
      createdBy: 'lidya',
      createdAt: dibentuk,
      history: [
        PanitiaStageChange(
          stage: PanitiaStage.planning,
          by: 'lidya',
          at: dibentuk,
        ),
        PanitiaStageChange(
          stage: PanitiaStage.active,
          by: 'lidya',
          at: a.jam(mulaiNatal, 11, 0),
        ),
      ],
    ),
  );
  // Recorded before the app: no SK or officers on file. Paskah's asset
  // handover is in Dokumen gereja; HUT's Kas closed at the end of M−1.
  final serahTerima = store.sekretariat.documents
      .firstWhere((d) => d.id == 'dokumen-serah-terima-paskah')
      .revisions
      .first
      .publishedAt;
  final paskahMulai = serahTerima.subtract(const Duration(days: 90));
  t.panitia.add(
    Panitia(
      id: 'panitia-paskah',
      scopeId: 'panitia-paskah',
      name: nama('panitia-paskah'),
      stage: PanitiaStage.retired,
      createdBy: 'lidya',
      createdAt: paskahMulai,
      history: [
        PanitiaStageChange(
          stage: PanitiaStage.planning,
          by: 'lidya',
          at: paskahMulai,
        ),
        PanitiaStageChange(
          stage: PanitiaStage.retired,
          by: 'lidya',
          at: serahTerima,
        ),
      ],
    ),
  );
  final hutMulai = a.jam(a.bln(-2, 1), 9, 0);
  final hutTutup = a.jam(a.akhirBln(-1), 16, 44);
  t.panitia.add(
    Panitia(
      id: 'panitia-hut',
      scopeId: 'panitia-hut',
      name: nama('panitia-hut'),
      stage: PanitiaStage.closed,
      createdBy: 'lidya',
      createdAt: hutMulai,
      history: [
        PanitiaStageChange(
          stage: PanitiaStage.planning,
          by: 'lidya',
          at: hutMulai,
        ),
        PanitiaStageChange(
          stage: PanitiaStage.closed,
          by: 'lidya',
          at: hutTutup,
        ),
      ],
    ),
  );

  // ---------- Services and attendance (DP25, DP28) ----------
  // The last Sunday's morning service: Ditetapkan at 231 by Pdt. Lidya, who
  // approved it (DL11, DL30). The correction to 236 is a live action.
  final minggu = a.mingguLalu(1);
  final disetujui = a.jam(minggu.tambahHari(-4), 10, 0);
  final ditetapkan = a.jam(minggu, 11, 20);
  t.services.add(
    Service(
      id: 'ibadah-minggu-pagi',
      title: 'Ibadah Minggu pagi',
      kind: ServiceKind.minggu,
      scopeId: ScopeRef.jemaatId,
      date: minggu,
      draftedBy: 'lidya',
      createdAt: disetujui,
      status: ServiceStatus.closed,
      approvedBy: 'lidya',
      approverTitle: 'Ketua Jemaat',
      approvedAt: disetujui,
    )..closedAt = ditetapkan,
  );
  t.attendance['ibadah-minggu-pagi'] =
      AttendanceCount(
          serviceId: 'ibadah-minggu-pagi',
          posts: [
            CounterPost(post: 'Pintu depan', personId: 'yanti', count: 142),
            CounterPost(post: 'Pintu samping', personId: 'greis', count: 89),
          ],
          status: AttendanceStatus.finalized,
        )
        ..reviewedBy = 'lidya'
        ..reviewedAt = a.jam(minggu, 11, 10)
        ..finalizedBy = 'lidya'
        ..finalizedAt = ditetapkan;

  // Minggu Adven I, approved by Pdt. Lidya; its counters assigned.
  final adven = a.hariCerita(29);
  final advenSetuju = a.jam(a.hariLalu(15), 10, 0);
  t.services.add(
    Service(
      id: 'ibadah-adven-1',
      title: 'Ibadah Minggu Adven I',
      kind: ServiceKind.minggu,
      scopeId: ScopeRef.jemaatId,
      date: adven,
      sessions: 'Subuh, Pagi, Malam',
      draftedBy: 'lidya',
      createdAt: advenSetuju,
      status: ServiceStatus.scheduled,
      approvedBy: 'lidya',
      approverTitle: 'Ketua Jemaat',
      approvedAt: advenSetuju,
    ),
  );
  t.attendance['ibadah-adven-1'] = AttendanceCount(
    serviceId: 'ibadah-adven-1',
    posts: [
      CounterPost(post: 'Pintu depan', personId: 'jefry'),
      CounterPost(post: 'Pintu samping', personId: 'olga'),
    ],
  );

  // Ibadah Kolom 7 on the next Thursday: Draf, for Pnt. Hendrik or Sym.
  // Greis to approve (P15).
  t.services.add(
    Service(
      id: 'ibadah-kolom-7',
      title: 'Ibadah Kolom 7',
      kind: ServiceKind.kolom,
      scopeId: 'kolom-7',
      date: a.hariCerita(19),
      time: '19.00',
      place: 'Kel. Wenas-Lasut',
      draftedBy: 'yanti',
      createdAt: a.jam(a.hariLalu(16), 8, 30),
    ),
  );

  // ---------- Fund requests (5.6; mock-data 2.20) ----------
  // Both wait for the Ketua Jemaat: Hendrik heads Komisi Diakonia, so its
  // own head cannot approve (DL29, no self-approval); Umum Jemaat is the
  // Church Fund.
  FundRequest minta(
    String id,
    String keperluan,
    int jumlah,
    String fundId,
    String scopeId,
    String oleh,
    String sebagai,
    DateTime pada,
  ) => FundRequest(
    id: id,
    purpose: keperluan,
    amount: jumlah,
    fundId: fundId,
    scopeId: scopeId,
    requestedBy: oleh,
    requesterTitle: sebagai,
    requestedAt: pada,
    approval: RequestApproval.pending,
    approverScopeId: ScopeRef.jemaatId,
    approverTitle: 'Ketua Jemaat',
  );
  t.fundRequests.addAll([
    minta(
      'permintaan-dana-natal-pemuda',
      'Konsumsi Natal Pemuda',
      1500000,
      'umum',
      'bipra-pemuda',
      'rivo',
      'Ketua Pemuda',
      a.jam(a.hariLalu(15), 19, 0),
    ),
    minta(
      'permintaan-dana-diakonia',
      'Kunjungan diakonia',
      750000,
      'diak',
      'komisi-diakonia',
      'hendrik',
      'Ketua Komisi Diakonia',
      a.jam(a.hariLalu(16), 9, 30),
    ),
  ]);
  assert(_tidakSetelah(store, a.sekarang), 'waktu kolaborasi setelah sekarang');
}

/// README 5.4: no seeded collaboration time is after now.
bool _tidakSetelah(SeedStore s, DateTime now) {
  final t = s.kolaborasi;
  return [
    for (final p in t.panitia) ...[
      p.createdAt,
      for (final h in p.history) h.at,
    ],
    for (final x in t.services) ...[x.createdAt, x.approvedAt, x.closedAt],
    for (final c in t.attendance.values) ...[c.reviewedAt, c.finalizedAt],
    for (final r in t.fundRequests) r.requestedAt,
  ].every((d) => d == null || !d.isAfter(now));
}
