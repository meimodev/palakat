import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import 'jangkar.dart';
import 'seed_store.dart';

/// Rivo's Panitia post as the seed story names it (O9); the picker's post line
/// reads it, so the year stays in the seed.
const bendaharaPanitiaNatal = 'Bendahara Panitia Natal 2026';

/// The core seed (README 5.2, 5.6, 5.7; mock-data 2.1–2.3, 2.16, 2.17,
/// 2.21): the church, people and parties, scopes, posts, assignments,
/// authority grants, delegations, the Kolom 2 cover, all 10 modules ACTIVE
/// (D21), other devices, core notifications and the audit lines behind them.
void seedInti(SeedStore store, Jangkar a) {
  final t = store.inti;
  t.workspace = Workspace(
    name: 'Jemaat Karunia',
    recordingStart: a.bln(-2, 15),
  );

  // ---------- People (mock-data 2.2; Deitje Kawengian is not seeded, DP20) ----------
  void orang(
    String id,
    String nama, {
    String? pendek,
    PersonStatus status = PersonStatus.active,
    Tanggal? lahir,
    Sex? jk,
    String? hp,
    String? email,
    bool sistem = false,
  }) => t.addPerson(
    Person(
      id: id,
      name: nama,
      shortName: pendek,
      status: status,
      birthDate: lahir,
      sex: jk,
      phone: hp,
      backupEmail: email,
      isSystem: sistem,
    ),
  );

  orang(
    'meiske',
    'Meiske Lumentut',
    pendek: 'Meiske L.',
    jk: Sex.female,
    hp: '081245503318',
    email: 'meiske@contoh.id',
  );
  orang(
    'olvie',
    'Olvie Pangemanan',
    jk: Sex.female,
    hp: '081355512204',
    email: 'olvie@contoh.id',
  );
  orang(
    'yanti',
    'Yanti Sumual',
    pendek: 'Yanti S.',
    jk: Sex.female,
    hp: '081340072215',
  );
  orang('lidya', 'Pdt. Lidya Rondonuwu', jk: Sex.female, hp: '081144028871');
  orang('jefry', 'Pnt. Jefry Wowor', jk: Sex.male, hp: '081356607142');
  orang('hendrik', 'Pnt. Hendrik Rumagit', jk: Sex.male, hp: '081234567890');
  orang('deasy', 'Deasy Tumbelaka', jk: Sex.female, hp: '085240913376');
  orang('stevi', 'Sdr. Stevi Lengkong', pendek: 'Stevi Lengkong', jk: Sex.male);
  orang(
    'natalia',
    'Sdri. Natalia Rumengan',
    pendek: 'Natalia Rumengan',
    jk: Sex.female,
  );
  orang(
    'rivo',
    'Sdr. Rivo Mandagi',
    pendek: 'Rivo Mandagi',
    jk: Sex.male,
    hp: '082193345120',
  );
  orang(
    'novita',
    'Novita Wenas',
    lahir: a.geser(1996, 3, 14),
    jk: Sex.female,
    hp: '081233447741',
  );
  orang(
    'agustina',
    'Agustina Lasut',
    lahir: a.geser(1974, 12, 12),
    jk: Sex.female,
  );
  orang(
    'ferry',
    'Ferry Wenas',
    status: PersonStatus.unconfirmed,
    lahir: a.geser(1971, 8, 3),
    jk: Sex.male,
  );
  orang('gabriel', 'Gabriel Wenas', jk: Sex.male);
  orang('olga', 'Dkn. Olga Tamba', jk: Sex.female, hp: '081340558820');
  orang(
    'greis',
    'Sym. Greis Mamahit',
    pendek: 'Greis M.',
    jk: Sex.female,
    hp: '085298114403',
  );
  orang('altje', 'Pnt. Altje Rompas', jk: Sex.female);
  // His death is a pending life event in the Kolom 2 queue, not yet verified (DP19).
  orang('yohanisR', 'Yohanis Rompas', lahir: a.geser(1948, 2, 3), jk: Sex.male);
  // The applicant (D22): not a member yet.
  orang(
    'kevin',
    'Kevin Rompas',
    status: PersonStatus.unconfirmed,
    jk: Sex.male,
  );
  orang('gabriela', 'Gabriela Rompas', jk: Sex.female);
  orang('selvie', 'Ibu Selvie Kalalo', pendek: 'Selvie Kalalo', jk: Sex.female);
  orang('yohanisT', 'Yohanis Tumbelaka', jk: Sex.male, hp: '081355019287');
  orang('petugas', 'Petugas verifikasi', sistem: true);
  // Penatua of the Kolom no board names (11 of 12 posts filled, mock-data 2.1).
  const penatuaLain = {
    1: 'Pnt. Frans Sondakh',
    3: 'Pnt. Herry Supit',
    4: 'Pnt. Marthen Kaunang',
    5: 'Pnt. Ronny Tangkau',
    6: 'Pnt. Welly Pangkey',
    8: 'Pnt. Nontje Rawung',
    9: 'Pnt. Stenly Mamuaja',
    10: 'Pnt. Ivonne Tumewu',
    11: 'Pnt. Debby Lontoh',
    12: 'Pnt. Jantje Lumingkewas',
  };
  for (final e in penatuaLain.entries) {
    orang('penatua-kolom-${e.key}-orang', e.value);
  }
  // Syamas Kolom 2: the Sumual change goes to her (AlurJabatanKosong).
  orang('syamas-kolom-2-orang', 'Sym. Ruth Lengkong', jk: Sex.female);

  t.personaIds.addAll(const [
    'meiske',
    'olvie',
    'yanti',
    'lidya',
    'jefry',
    'hendrik',
    'greis',
    'deasy',
    'olga',
    'rivo',
    'novita',
  ]);

  // ---------- Parties (mock-data 2.2, families and other parties) ----------
  for (final (id, nama, orangId) in [
    ('toko-sinar', 'TOKO SINAR', null),
    ('cv-nada-prima', 'CV NADA PRIMA', null),
    ('sinode', 'Sinode', null),
    ('wilayah', 'Wilayah', null),
    ('ibu-runtu', 'Ibu Runtu', null),
    ('kel-wenas-lasut', 'Kel. Wenas-Lasut', null),
    // Its head, Robby Mamahit, is seeded with the Kolom 4 families (M8).
    ('kel-mamahit', 'Kel. Mamahit', 'mamahit-1'),
    ('novita', 'Novita Wenas', 'novita'),
    ('selvie', 'Ibu Selvie Kalalo', 'selvie'),
    ('rivo', 'Sdr. Rivo Mandagi', 'rivo'),
    ('natalia', 'Sdri. Natalia Rumengan', 'natalia'),
    ('jefry', 'Pnt. Jefry Wowor', 'jefry'),
    // Not linked while Ferry is Belum dikonfirmasi (PersembahanBernama).
    ('ferry', 'Ferry Wenas', null),
  ]) {
    t.parties.add(Party(id: 'party-$id', displayName: nama, personId: orangId));
  }

  // ---------- Scopes (mock-data 2.1; DP12) ----------
  void lingkup(String id, ScopeType tipe, String nama, {bool aktif = true}) =>
      t.scopes.add(
        Scope(
          id: id,
          type: tipe,
          name: nama,
          parentId: id == ScopeRef.jemaatId ? null : ScopeRef.jemaatId,
          active: aktif,
        ),
      );
  lingkup(ScopeRef.jemaatId, ScopeType.jemaat, 'Jemaat Karunia');
  for (var k = 1; k <= 12; k++) {
    lingkup('kolom-$k', ScopeType.kolom, 'Kolom $k');
  }
  lingkup('bipra-pemuda', ScopeType.bipra, 'BIPRA Pemuda');
  lingkup('bipra-remaja', ScopeType.bipra, 'BIPRA Remaja');
  lingkup('komisi-diakonia', ScopeType.komisi, 'Komisi Diakonia');
  lingkup('komisi-pembangunan', ScopeType.komisi, 'Komisi Pembangunan');
  lingkup('panitia-natal', ScopeType.panitia, 'Panitia Natal 2026');
  lingkup('panitia-hut', ScopeType.panitia, 'Panitia HUT Jemaat', aktif: false);
  lingkup(
    'panitia-paskah',
    ScopeType.panitia,
    'Panitia Paskah 2026',
    aktif: false,
  );

  // ---------- Posts (mock-data 2.3, roles.md 1) ----------
  void jabatan(String id, Role peran, String lingkupId, String judul) =>
      t.posts.add(Post(id: id, role: peran, scopeId: lingkupId, title: judul));
  const j = ScopeRef.jemaatId;
  jabatan('bendahara-jemaat', Role.bendaharaJemaat, j, 'Bendahara Jemaat');
  jabatan('sekretaris-jemaat', Role.sekretarisJemaat, j, 'Sekretaris Jemaat');
  jabatan('ketua-jemaat', Role.ketuaJemaat, j, 'Ketua Jemaat');
  jabatan(
    'pimpinan-jemaat',
    Role.pimpinanJemaat,
    j,
    'Pimpinan Jemaat yang berwenang',
  );
  jabatan('wakil-ketua-bpmj', Role.wakilKetuaBpmj, j, 'Wakil Ketua BPMJ');
  jabatan('pemeriksa-kedua', Role.pemeriksaKedua, j, 'Pemeriksa kedua');
  jabatan('operator', Role.operator, j, 'Operator');
  for (var k = 1; k <= 12; k++) {
    jabatan(
      'penatua-kolom-$k',
      Role.penatuaKolom,
      'kolom-$k',
      'Penatua Kolom $k',
    );
  }
  jabatan(
    'ketua-komisi-diakonia',
    Role.ketuaUnit,
    'komisi-diakonia',
    'Ketua Komisi Diakonia',
  );
  jabatan('syamas-kolom-7', Role.syamasKolom, 'kolom-7', 'Syamas Kolom 7');
  jabatan('syamas-kolom-2', Role.syamasKolom, 'kolom-2', 'Syamas Kolom 2');
  jabatan('syamas-kolom-3', Role.syamasKolom, 'kolom-3', 'Syamas Kolom 3');
  jabatan(
    'bendahara-kolom-7',
    Role.bendaharaUnit,
    'kolom-7',
    'Bendahara Kolom 7',
  );
  jabatan(
    'bendahara-komisi-diakonia',
    Role.bendaharaUnit,
    'komisi-diakonia',
    'Bendahara Komisi Diakonia',
  );
  jabatan(
    'akses-terbatas-diakonia',
    Role.aksesTerbatas,
    'komisi-diakonia',
    'Akses terbatas: Peruntukan Diakonia',
  );
  jabatan(
    'bendahara-panitia-natal',
    Role.bendaharaUnit,
    'panitia-natal',
    bendaharaPanitiaNatal,
  );
  jabatan(
    'ketua-panitia-natal',
    Role.ketuaPanitia,
    'panitia-natal',
    'Ketua Panitia Natal 2026',
  );
  jabatan(
    'sekretaris-panitia-natal',
    Role.sekretarisPanitia,
    'panitia-natal',
    'Sekretaris Panitia Natal 2026',
  );
  jabatan('ketua-pemuda', Role.ketuaUnit, 'bipra-pemuda', 'Ketua Pemuda');

  // ---------- Assignments ----------
  final awalTahun = a.geser(2026, 1, 1);
  final mulaiCatat = a.bln(-2, 15);
  void tugas(
    String postId,
    String orangId,
    Tanggal mulai, {
    Tanggal? akhir,
    String? dokumen,
  }) => t.assignments.add(
    Assignment(
      id: 'tugas-$postId-$orangId',
      postId: postId,
      personId: orangId,
      start: mulai,
      end: akhir,
      status: akhir == null ? AssignmentStatus.active : AssignmentStatus.ended,
      documentRef: dokumen,
      recordedBy: 'lidya',
      recordedAt: a.jam(mulai, 9, 0),
    ),
  );
  tugas(
    'bendahara-jemaat',
    'meiske',
    mulaiCatat,
    dokumen: 'SK-BPMJ-04-${mulaiCatat.tahun}',
  );
  final mulaiOlvie = a.hariLalu(3);
  tugas(
    'sekretaris-jemaat',
    'olvie',
    mulaiOlvie,
    dokumen: 'SK BPMJ No. 12/${mulaiOlvie.tahun}',
  );
  tugas('ketua-jemaat', 'lidya', awalTahun);
  tugas('pimpinan-jemaat', 'lidya', awalTahun);
  tugas('wakil-ketua-bpmj', 'jefry', awalTahun);
  tugas('pemeriksa-kedua', 'jefry', mulaiCatat);
  tugas('ketua-komisi-diakonia', 'hendrik', a.geser(2026, 3, 1));
  tugas('operator', 'yanti', a.bln(0, 1));
  tugas('penatua-kolom-7', 'hendrik', awalTahun);
  // Altje's term ended at the end of M−1; Yanti covers from day 1 of M0 (DP19).
  tugas('penatua-kolom-2', 'altje', a.geser(2022, 1, 1), akhir: a.akhirBln(-1));
  for (final k in penatuaLain.keys) {
    tugas('penatua-kolom-$k', 'penatua-kolom-$k-orang', awalTahun);
  }
  tugas('syamas-kolom-7', 'greis', awalTahun);
  tugas('syamas-kolom-2', 'syamas-kolom-2-orang', awalTahun);
  tugas('bendahara-kolom-7', 'deasy', awalTahun);
  tugas('bendahara-komisi-diakonia', 'olga', awalTahun);
  tugas('akses-terbatas-diakonia', 'olga', mulaiCatat);
  final mulaiPanitia = a.bln(-1, 1);
  tugas('ketua-panitia-natal', 'stevi', mulaiPanitia);
  tugas('sekretaris-panitia-natal', 'natalia', mulaiPanitia);
  tugas('bendahara-panitia-natal', 'rivo', mulaiPanitia);
  tugas('ketua-pemuda', 'rivo', awalTahun);

  // ---------- Audit helper ----------
  void riwayat(
    DateTime saat,
    String orangId,
    String peran,
    String aksi,
    String ringkas, {
    Module? modul,
    RecordRef? ref,
    String? alasan,
    String? assignmentId,
    Via via = Via.direct,
    String? viaLabel,
  }) => t.audit.add(
    AuditRecord(
      id: store.newId('aud'),
      at: saat,
      personId: orangId,
      personName: t.person(orangId)!.name,
      actingRole: peran,
      assignmentId: assignmentId,
      scopeId: j,
      via: via,
      viaLabel: viaLabel,
      module: modul,
      action: aksi,
      summary: ringkas,
      reason: alasan,
      ref: ref,
    ),
  );

  // ---------- Authority grants (RD07, DL10) ----------
  void wewenang(String postId, String orangId, Role peran, DateTime saat) {
    final asg = 'tugas-$postId-$orangId';
    t.authorityGrants.add(
      AuthorityGrant(
        id: 'wewenang-$postId-$orangId',
        personId: orangId,
        assignmentId: asg,
        role: peran,
        status: GrantStatus.active,
        documentRef: t.assignment(asg)!.documentRef,
        recordedBy: 'lidya',
        recordedAt: a.jam(t.assignment(asg)!.start, 9, 0),
        verifiedBy: 'petugas',
        verifiedAt: saat,
      ),
    );
    riwayat(
      saat,
      'petugas',
      'Petugas verifikasi',
      'role.grant_activate',
      'Mengaktifkan wewenang ${peran.label} untuk ${t.person(orangId)!.name}',
      ref: RecordRef('assignment', asg),
    );
  }

  wewenang(
    'bendahara-jemaat',
    'meiske',
    Role.bendaharaJemaat,
    a.jam(mulaiCatat, 10, 15),
  );
  wewenang(
    'sekretaris-jemaat',
    'olvie',
    Role.sekretarisJemaat,
    a.jam(mulaiOlvie, 10, 30),
  );

  // ---------- Vacancy cover: Penatua Kolom 2 (5.6) ----------
  final mulaiCover = a.bln(0, 1);
  t.covers.add(
    VacancyCover(
      id: 'cover-penatua-kolom-2',
      postId: 'penatua-kolom-2',
      personId: 'yanti',
      operatorAssignmentId: 'tugas-operator-yanti',
      start: mulaiCover,
      startedAt: a.jam(mulaiCover, 8, 15),
      reason: 'Masa jabatan Penatua Kolom 2 berakhir.',
    ),
  );
  riwayat(
    a.jam(mulaiCover, 8, 15),
    'yanti',
    'Operator',
    'role.cover',
    'Menjalankan jabatan kosong Penatua Kolom 2',
    assignmentId: 'tugas-operator-yanti',
    ref: const RecordRef('post', 'penatua-kolom-2'),
  );

  // ---------- Delegations (mock-data 2.3 Pelimpahan) ----------
  t.delegations.add(
    Delegation(
      id: 'pelimpahan-hendrik-greis',
      fromPersonId: 'hendrik',
      fromAssignmentId: 'tugas-penatua-kolom-7-hendrik',
      toPersonId: 'greis',
      task: const DelegatedTask(
        capability: Capability.membershipVerify,
        scopeId: 'kolom-7',
        label: 'Verifikasi data Kolom 7',
      ),
      start: a.hariIni,
      end: a.hariIni.tambahHari(14),
      createdAt: a.jam(a.hariIni, 7, 40),
    ),
  );
  t.delegations.add(
    Delegation(
      id: 'pelimpahan-olvie-yanti',
      fromPersonId: 'olvie',
      fromAssignmentId: 'tugas-sekretaris-jemaat-olvie',
      toPersonId: 'yanti',
      task: const DelegatedTask(
        capability: Capability.announcementsDraft,
        scopeId: ScopeRef.jemaatId,
        label: 'Menyusun draf pengumuman',
      ),
      start: mulaiOlvie,
      end: a.hariLalu(10),
      createdAt: a.jam(mulaiOlvie, 11, 0),
    ),
  );
  riwayat(
    a.jam(mulaiOlvie, 11, 0),
    'olvie',
    'Sekretaris Jemaat',
    'role.delegate',
    'Melimpahkan "Menyusun draf pengumuman" kepada Yanti Sumual',
    assignmentId: 'tugas-sekretaris-jemaat-olvie',
    ref: const RecordRef('delegation', 'pelimpahan-olvie-yanti'),
  );
  riwayat(
    a.jam(a.hariIni, 7, 40),
    'hendrik',
    'Penatua Kolom 7',
    'role.delegate',
    'Melimpahkan "Verifikasi data Kolom 7" kepada Sym. Greis Mamahit',
    assignmentId: 'tugas-penatua-kolom-7-hendrik',
    ref: const RecordRef('delegation', 'pelimpahan-hendrik-greis'),
  );

  // ---------- Modules: all 10 ACTIVE (D21, DP26) ----------
  for (final m in Module.values) {
    final tgl = switch (m) {
      Module.finance => mulaiCatat,
      Module.churchDocuments ||
      Module.announcements ||
      Module.warta => mulaiOlvie,
      _ => a.bln(0, 1),
    };
    final saat = a.jam(tgl, 9, m.index);
    t.modules.add(
      ModuleState(
        module: m,
        status: ModuleStatus.active,
        changedBy: 'lidya',
        changedAt: saat,
      ),
    );
    riwayat(
      saat,
      'lidya',
      'Pimpinan Jemaat yang berwenang',
      'module.switch',
      'Modul ${m.label} aktif',
      assignmentId: 'tugas-pimpinan-jemaat-lidya',
    );
  }

  // ---------- Other devices (mock-data 2.18, 2.21) ----------
  void perangkat(String orangId, String nama, DateTime terakhir) =>
      t.devices.add(
        Device(
          id: store.newId('perangkat'),
          personId: orangId,
          name: nama,
          lastUsed: terakhir,
        ),
      );
  perangkat('meiske', 'Chrome di laptop', a.jam(a.hariLalu(14), 20, 15));
  perangkat('meiske', 'Ponsel Android', a.jam(a.hariIni, 10, 42));
  perangkat(
    'hendrik',
    'Ponsel lain · Samsung A15',
    a.jam(a.hariLalu(12), 19, 0),
  );

  // ---------- Core notifications ----------
  void kabar(
    String kepada,
    String judul,
    String isi,
    DateTime saat, {
    RecordRef? ref,
    bool dibaca = false,
  }) => t.notifications.add(
    AppNotification(
      id: store.newId('kabar'),
      recipientId: kepada,
      type: NotificationType.role,
      title: judul,
      body: isi,
      createdAt: saat,
      ref: ref,
      readAt: dibaca ? saat : null,
    ),
  );
  kabar(
    'yanti',
    'Anda menjalankan jabatan kosong Penatua Kolom 2',
    'Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual.',
    a.jam(mulaiCover, 8, 15),
    ref: const RecordRef('post', 'penatua-kolom-2'),
    dibaca: true,
  );
  kabar(
    'olvie',
    'Wewenang Sekretaris Jemaat aktif',
    'Diverifikasi Petugas verifikasi',
    a.jam(mulaiOlvie, 10, 30),
    ref: const RecordRef('assignment', 'tugas-sekretaris-jemaat-olvie'),
    dibaca: true,
  );
  kabar(
    'greis',
    'Pelimpahan baru: Verifikasi data Kolom 7',
    'Dari Pnt. Hendrik Rumagit, Penatua Kolom 7',
    a.jam(a.hariIni, 7, 40),
    ref: const RecordRef('delegation', 'pelimpahan-hendrik-greis'),
  );
}
