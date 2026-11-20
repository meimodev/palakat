import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import 'jangkar.dart';
import 'seed_store.dart';

/// The Secretariat seed (README 5.6, 5.7; mock-data 2.19): church documents,
/// announcements, the Warta editions of the last four Sundays and the draft
/// of the next one, and the open letter requests (Novita's and two
/// Atestasi). Drawn later states (the SK of Syamas Kolom 3, Novita's issued
/// letter, the 22/11 edition's review and publishing) are actions in flows
/// (DP28).
void seedSekretariat(SeedStore store, Jangkar a) {
  final t = store.sekretariat;
  final hari = a.hariIni;

  // ---------- Households and Kolom read by the Secretariat (mock-data 2.18) ----------
  for (final id in ['novita', 'agustina', 'ferry', 'gabriel']) {
    t.households[id] = 'Wenas-Lasut · Kolom 7';
    t.memberScopes[id] = 'kolom-7';
  }
  for (final (id, rumah, kolom) in [
    ('hendrik', 'Rumagit · Kolom 7', 'kolom-7'),
    ('greis', 'Mamahit · Kolom 7', 'kolom-7'),
    ('deasy', 'Tumbelaka · Kolom 7', 'kolom-7'),
    ('yanti', 'Sumual · Kolom 2', 'kolom-2'),
    ('kevin', 'Rompas · Kolom 2', 'kolom-2'),
  ]) {
    t.households[id] = rumah;
    t.memberScopes[id] = kolom;
  }
  // ponytail: Keluarga Lasut (Kolom 4 → Kolom 7 from M+1) has no person in
  // the core seed, so its Atestasi is filed under the household; nobody is
  // notified of the decision until seed_inti gains its head (request R4).
  t.households[_lasut] = 'Lasut · Kolom 4';
  t.memberScopes[_lasut] = 'kolom-4';

  // ---------- Church documents (DokumenGereja, TerbitDokumen) ----------
  DocumentRevision rev(int n, String file, DateTime at, {String? ralat}) =>
      DocumentRevision(
        number: n,
        signedCopy: SampleFile(file),
        publishedAt: at,
        publishedBy: 'olvie',
        ralat: ralat,
      );
  final paskah = a.sejarah(2026, 4, 30);
  final notulen = a.hariLalu(8);
  // A record's year follows its date (README 5.5).
  final edaran = a.hariLalu(12);
  t.documents.addAll([
    ChurchDocument(
      id: 'dokumen-serah-terima-paskah',
      kind: DocumentKind.assetHandover,
      title: 'Serah terima aset Panitia Paskah 2026',
      documentDate: paskah,
      audience: Audience.servants,
      revisions: [
        rev(
          1,
          'serah-terima-aset-paskah.pdf',
          a.jam(paskah.tambahHari(2), 10, 0),
        ),
      ],
    ),
    ChurchDocument(
      id: 'dokumen-tata-ibadah-adven',
      kind: DocumentKind.liturgy,
      title: 'Tata ibadah Minggu Adven I',
      audience: Audience.all,
      revisions: [
        rev(1, 'tata-ibadah-adven-1.pdf', a.jam(a.hariLalu(7), 11, 0)),
      ],
    ),
    ChurchDocument(
      id: 'dokumen-notulen-bpmj',
      kind: DocumentKind.minutes,
      title: 'Notulen rapat BPMJ ${tgl(notulen.awal)}',
      audience: Audience.servants,
      revisions: [
        rev(1, 'notulen-rapat-bpmj.pdf', a.jam(a.hariLalu(9), 10, 0)),
      ],
    ),
    ChurchDocument(
      id: 'dokumen-surat-edaran-natal',
      kind: DocumentKind.decision,
      title: 'Surat edaran jadwal ibadah Natal ${edaran.tahun}',
      documentDate: edaran,
      audience: Audience.all,
      revision: 2,
      revisions: [
        rev(1, 'surat-edaran-jadwal-natal.pdf', a.jam(edaran, 16, 40)),
        rev(
          2,
          'surat-edaran-jadwal-natal-revisi-2.pdf',
          a.jam(a.hariLalu(14), 9, 10),
          ralat: 'Jam ibadah malam Natal: 19.00, bukan 18.00.',
        ),
      ],
    ),
  ]);

  // ---------- Announcements (Pengumuman; drafted by the Operator) ----------
  Announcement umum(
    String id,
    String judul,
    String isi,
    Audience untuk, {
    Tanggal? akhir,
    required DateTime draf,
    DateTime? terbit,
  }) => Announcement(
    id: id,
    title: judul,
    body: isi,
    audience: untuk,
    endsOn: akhir,
    draftedBy: 'yanti',
    draftedAt: draf,
    status: terbit == null
        ? AnnouncementStatus.draft
        : AnnouncementStatus.published,
    publishedBy: terbit == null ? null : 'olvie',
    publishedAt: terbit,
  );
  final kerjaBakti = umum(
    'pengumuman-kerja-bakti',
    'Kerja bakti halaman gereja',
    'Sabtu, ${tglPanjang(a.hariCerita(21).awal)} pukul 07.00. Membawa alat '
        'kebersihan masing-masing.',
    Audience.all,
    akhir: a.hariCerita(20),
    draf: a.jam(a.hariLalu(15), 14, 0),
    terbit: a.jam(a.hariLalu(16), 8, 15),
  );
  t.announcements.addAll([
    umum(
      'pengumuman-latihan-kolom-7',
      'Latihan paduan suara Kolom 7',
      'Setiap Kamis pukul 19.00 di rumah Keluarga Rumagit.',
      const Audience.scope('kolom-7', 'Kolom 7'),
      akhir: a.hariLalu(15),
      draf: a.jam(a.hariLalu(4), 9, 0),
      terbit: a.jam(a.hariLalu(5), 8, 0),
    ),
    umum(
      'pengumuman-rapat-pelayan',
      'Rapat pelayan khusus',
      'Rabu, ${tglPanjang(a.hariCerita(25).awal)} pukul 19.00 di ruang '
          'konsistori.',
      Audience.servants,
      akhir: a.hariCerita(25),
      draf: a.jam(a.hariLalu(15), 10, 0),
    ),
    umum(
      'pengumuman-katekisasi',
      'Pendaftaran katekisasi sidi 2027',
      'Dibuka sampai ${tglPanjang(Tanggal(hari.tahun, 12, 31).awal)} di '
          'Sekretariat Jemaat.',
      Audience.all,
      draf: a.jam(a.hariLalu(15), 11, 0),
    ),
    kerjaBakti,
  ]);

  // ---------- Warta editions (WartaArsip, WartaEditor) ----------
  // The k-th Sunday on or before T, unclamped: an edition is a record
  // outside the ledger (README 5.3, hariLalu).
  Tanggal minggu(int k) =>
      hari.tambahHari(-(hari.awal.weekday % 7) - 7 * (k - 1));
  const ibadah = 'Subuh 05.00 · Pagi 09.00 · Malam 18.00';
  WartaEdition terbit(int k, WartaStatus status) {
    final m = minggu(k);
    final sabtu = m.tambahHari(-1);
    return WartaEdition(
        id: _id(m),
        sunday: m,
        status: status,
        services: ibadah,
        publishedAt: a.jam(sabtu, 17, 0),
        publishedBy: 'olvie',
      )
      ..reviewedAt = a.jam(sabtu.tambahHari(-1), 14, 5)
      ..reviewedBy = 'olvie'
      ..approvedAt = a.jam(sabtu.tambahHari(-1), 14, 20)
      ..approvedBy = 'olvie';
  }

  final ralat = terbit(2, WartaStatus.published);
  ralat.ralats.add(
    WartaRalat(
      text:
          'Jadwal ibadah Kolom 5 dipindah ke Kamis '
          '${tgl(minggu(2).tambahHari(4).awal)}.',
      at: a.jam(minggu(2).tambahHari(1), 8, 30),
      by: 'olvie',
    ),
  );
  final depan = hari.tambahHari(7 - hari.awal.weekday % 7);
  t.editions.addAll([
    terbit(4, WartaStatus.archived),
    terbit(3, WartaStatus.archived),
    ralat,
    terbit(1, WartaStatus.published),
    WartaEdition(
      id: _id(depan),
      sunday: depan,
      services: ibadah,
      attendance: (
        sunday: minggu(1),
        total: 412,
        parts: 'Subuh 96 · Pagi 231 · Malam 85',
      ),
      events: const [
        WartaEvent(
          label: 'Syukur HUT pernikahan',
          name: 'Keluarga Wenas-Lasut — Kolom 7',
          personId: 'novita',
        ),
        WartaEvent(
          label: 'Sampul syukur',
          name: 'Kel. Mamahit — Kolom 4',
          personId: 'kel-mamahit',
          anonymousAs: 'Tanpa nama, Kolom 4',
        ),
      ],
      announcementIds: {kerjaBakti.id},
    ),
  ]);

  // ---------- Letter requests (PermohonanSurat, AlurSurat) ----------
  // The outgoing-letter book keeps the drawn pace: 26 letters by the story's
  // day 320 of the year (16 November, so the next is the drawn 027); a
  // launch early in January starts near 001.
  final hariKe = hari.awal.difference(Tanggal(hari.tahun, 1, 1).awal).inDays;
  t.letterCounters[hari.tahun] = 26 * (hariKe + 1) ~/ 320;
  t.letters.addAll([
    LetterRequest(
      id: 'surat-novita',
      type: LetterType.certificate,
      forPersonId: 'novita',
      forName: 'Novita Wenas',
      requestedBy: 'novita',
      requestedAt: a.jam(a.hariLalu(14), 19, 20),
      purpose: 'untuk melamar pekerjaan',
      household: 'Wenas-Lasut · Kolom 7',
    ),
    LetterRequest(
      id: 'surat-keluarga-lasut',
      type: LetterType.attestation,
      forPersonId: _lasut,
      forName: 'Keluarga Lasut',
      requestedBy: 'yanti',
      requestedAt: a.jam(a.hariLalu(15), 10, 30),
      purpose: 'pindah ke Jemaat lain',
      atOffice: true,
      household: 'Lasut · Kolom 4',
    ),
    LetterRequest(
      id: 'surat-ferry',
      type: LetterType.attestation,
      forPersonId: 'ferry',
      forName: 'Ferry Wenas',
      requestedBy: 'ferry',
      requestedAt: a.jam(a.hariLalu(13), 16, 0),
      purpose: 'pindah ke Jemaat lain',
      household: 'Wenas-Lasut · Kolom 7',
    ),
  ]);

  // ---------- Olvie's inbox at launch (KotakMasuk round 2; README 3.4) ----------
  // The rows the live commands write for the seeded records (request,
  // record at the office, announcement draft), and the two reminders.
  void kabar(
    String judul,
    String isi,
    DateTime saat,
    Module modul,
    RecordRef ref, {
    String jenis = NotificationType.action,
    bool dibaca = false,
  }) => store.inti.notifications.add(
    AppNotification(
      id: store.newId('kabar'),
      recipientId: 'olvie',
      type: jenis,
      module: modul,
      title: judul,
      body: isi,
      createdAt: saat,
      ref: ref,
      readAt: dibaca ? saat : null,
    ),
  );
  String nama(String id) => store.inti.person(id)?.name ?? id;
  for (final r in t.letters) {
    kabar(
      'Permohonan ${r.title}',
      r.atOffice
          ? 'Dicatat ${nama(r.requestedBy)} di kantor'
          : 'Diajukan ${tgl(r.requestedAt)}',
      r.requestedAt,
      Module.churchDocuments,
      RecordRef('letter', r.id),
    );
  }
  for (final u in t.announcements) {
    if (u.status == AnnouncementStatus.draft) {
      kabar(
        'Pengumuman “${u.title}” menunggu diterbitkan',
        'Draf oleh ${nama(u.draftedBy)}',
        u.draftedAt,
        Module.announcements,
        RecordRef('announcement', u.id),
      );
    }
  }
  kabar(
    'Warta edisi ${tgl(depan.awal)} belum diterbitkan',
    'Warta Jemaat · Draf',
    a.jam(a.hariLalu(16), 7, 0),
    Module.warta,
    RecordRef('warta', _id(depan)),
    dibaca: true,
  );
  kabar(
    'Pengumuman “${kerjaBakti.title}” berakhir '
        '${tgl(kerjaBakti.endsOn!.awal)}',
    'Setelah itu diarsipkan sendiri',
    a.jam(a.hariLalu(16), 7, 5),
    Module.announcements,
    RecordRef('announcement', kerjaBakti.id),
    jenis: NotificationType.role,
  );
}

/// The household the Keluarga Lasut Atestasi is filed under.
const _lasut = 'keluarga-lasut';

/// The edition id, as `MemoryWartaRepository.idFor`: 'warta-yyyy-mm-dd'.
String _id(Tanggal t) =>
    'warta-${t.tahun}-${t.bulan.toString().padLeft(2, '0')}-'
    '${t.hari.toString().padLeft(2, '0')}';
