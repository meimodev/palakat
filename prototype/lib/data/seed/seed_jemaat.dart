import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import 'jangkar.dart';
import 'seed_store.dart';

/// The Membership seed (README 5.1, 5.6, 5.7; mock-data 2.18): member
/// profiles of the named people and of plain bulk members per Kolom to the
/// drawn counts, households, consent, the open verification items, the
/// staged Kolom 7 member book, earlier imports and Novita's name choice.
void seedJemaat(SeedStore store, Jangkar a) {
  final t = store.jemaat;
  final inti = store.inti;
  t.consentTextDate = a.hariLalu(12);

  // ---------- Named members ----------
  void profil(
    String id,
    int kolom, {
    String? keluarga,
    MaritalStatus? nikah,
    Tanggal? sejak,
    List<KolomStint>? riwayat,
    Tanggal? lahir,
  }) {
    final o = inti.person(id)!;
    if (lahir != null) o.birthDate = lahir;
    t.profiles[id] = MemberProfile(
      personId: id,
      kolom: riwayat ?? [KolomStint(kolomId: 'kolom-$kolom')],
      householdId: keluarga,
      marital: nikah,
      memberSince: sejak,
    );
  }

  void keluarga(
    String id,
    String nama,
    int kolom,
    List<String> anggota, {
    NameForm bawaan = NameForm.familyName,
  }) {
    t.households[id] = Household(
      id: id,
      name: nama,
      kolomId: 'kolom-$kolom',
      memberIds: [...anggota],
      representativeId: anggota.first,
      defaultNameForm: bawaan,
    );
    for (final p in anggota) {
      t.profiles[p]?.householdId = id;
    }
  }

  const n = MaritalStatus.never, m = MaritalStatus.married;
  profil(
    'novita',
    7,
    nikah: n,
    sejak: a.sejarah(2021, 6, 1),
    riwayat: [
      KolomStint(
        kolomId: 'kolom-4',
        start: a.sejarah(2009, 2, 12),
        end: a.sejarah(2021, 5, 31),
      ),
      KolomStint(kolomId: 'kolom-7', start: a.sejarah(2021, 6, 1)),
    ],
  );
  profil('agustina', 7, nikah: m);
  profil('gabriel', 7, nikah: n, lahir: a.geser(2019, 9, 2));
  // Ferry came from the Kolom 7 member book and is still unconfirmed, so his
  // family waits for its confirmation (DP21; KonfirmasiKeluarga).
  profil('ferry', 7, nikah: m);
  keluarga('wenas-lasut', 'Wenas-Lasut', 7, [
    'ferry',
    'agustina',
    'novita',
    'gabriel',
  ]);
  t.households['wenas-lasut']!
    ..representativeId = 'agustina'
    ..status = HouseholdStatus.unconfirmed;
  profil('hendrik', 7, nikah: m, lahir: a.geser(1969, 5, 21));
  keluarga('rumagit', 'Rumagit', 7, ['hendrik']);
  profil('greis', 7, nikah: m, lahir: a.geser(1979, 10, 4));
  profil('deasy', 7, nikah: m, lahir: a.geser(1983, 1, 17));
  profil('yanti', 2, nikah: m, lahir: a.geser(1981, 6, 9));
  keluarga('sumual', 'Sumual', 2, ['yanti']);
  profil('yohanisR', 2, nikah: m);
  profil('syamas-kolom-2-orang', 2, nikah: m);
  profil('altje', 2, nikah: m, lahir: a.geser(1952, 8, 30));
  profil('gabriela', 2, nikah: n, lahir: a.geser(2010, 6, 15));
  // Altje's term and the Rompas family's death are unrelated (DP19).
  keluarga('rompas', 'Rompas', 2, ['yohanisR', 'gabriela']);
  for (final (id, k) in const [
    ('meiske', 1),
    ('olvie', 3),
    ('lidya', 5),
    ('jefry', 6),
    ('olga', 8),
    ('rivo', 9),
    ('stevi', 9),
    ('natalia', 10),
    ('selvie', 11),
    ('yohanisT', 12),
  ]) {
    profil(id, k);
  }
  for (final k in const [1, 3, 4, 5, 6, 8, 9, 10, 11, 12]) {
    profil('penatua-kolom-$k-orang', k);
  }

  // Families drawn without named people (seed.md: Lasut, Mamahit).
  void orangBaru(String id, String nama, Sex jk, Tanggal lahir) =>
      inti.addPerson(Person(id: id, name: nama, sex: jk, birthDate: lahir));
  orangBaru('lasut-1', 'Johny Lasut', Sex.male, a.geser(1970, 2, 11));
  orangBaru('lasut-2', 'Lenny Lasut', Sex.female, a.geser(1973, 7, 3));
  orangBaru('lasut-3', 'Rio Lasut', Sex.male, a.geser(2004, 12, 20));
  profil('lasut-1', 4, nikah: m);
  profil('lasut-2', 4, nikah: m);
  profil('lasut-3', 4, nikah: n);
  keluarga('lasut', 'Lasut', 4, ['lasut-1', 'lasut-2', 'lasut-3']);
  orangBaru('mamahit-1', 'Robby Mamahit', Sex.male, a.geser(1965, 4, 8));
  orangBaru('mamahit-2', 'Olly Mamahit', Sex.female, a.geser(1967, 9, 14));
  profil('mamahit-1', 4, nikah: m);
  profil('mamahit-2', 4, nikah: m);
  keluarga('mamahit', 'Mamahit', 4, ['mamahit-1', 'mamahit-2']);

  // ---------- Bulk members (D10): plain rows to the drawn counts ----------
  final pabrik = _Pabrik(store, a);
  // Kolom 7: 96 members, 31 families; the other 11 share the rest of 1.284
  // members and 412 families.
  for (var k = 1; k <= 12; k++) {
    final kolom = 'kolom-$k';
    final aktif = k == 7 ? 96 : 108;
    final rumah = k == 7 ? 31 : (k <= 8 ? 35 : 34);
    final adaOrang = t.profiles.values
        .where(
          (p) =>
              p.kolom.last.kolomId == kolom &&
              inti.person(p.personId)!.status == PersonStatus.active,
        )
        .length;
    final adaRumah = t.households.values
        .where((h) => h.kolomId == kolom && h.status == HouseholdStatus.active)
        .length;
    pabrik.keluarga(kolom, aktif - adaOrang, rumah - adaRumah);
  }

  // Earlier paper books (318 rows; 241 people still unconfirmed, 12 of them
  // in Kolom 7, Ferry among them): the 7 first bulk members of each other
  // Kolom came from them.
  for (var k = 1; k <= 12; k++) {
    final kolom = 'kolom-$k';
    final belum = k == 7 ? 11 : (k <= 10 ? 21 : 20);
    final dariBuku = k == 7 ? 0 : 7;
    final rows = <ImportRow>[];
    final b = ImportBatch(
      id: 'buku-lama-$k',
      source: k == 7
          ? 'Buku anggota Kolom 7 · 2009–2018'
          : 'Buku anggota Kolom $k',
      kolomId: kolom,
      rows: rows,
      status: ImportStatus.imported,
      importedAt: k == 7
          ? a.jam(a.hariLalu(12), 10, 0)
          : a.jam(a.bln(-1, 2 + k), 10, 0),
      importedBy: 'yanti',
    );
    t.batches.add(b);
    void baris(String id) {
      final o = inti.person(id)!;
      final r = ImportRow(
        id: store.newId('baris'),
        line: rows.length + 1,
        bookText: _diBuku(o),
        name: o.name,
        kolomId: kolom,
        birthDate: o.birthDate,
        sex: o.sex,
        personId: id,
      )..status = RowStatus.imported;
      rows.add(r);
      t.profiles[id]!
        ..importBatchId = b.id
        ..importLine = r.line
        ..importedAt = b.importedAt;
    }

    for (final id in pabrik.dibuat[kolom]!.take(dariBuku)) {
      baris(id);
    }
    for (final id in pabrik.keluargaBelum(kolom, belum, b.importedAt!)) {
      baris(id);
    }
    if (k == 7) {
      baris('ferry');
      t.households['wenas-lasut']!.importedAt = b.importedAt;
    }
  }

  // ---------- The Kolom 7 member book, staged (ImporBuku, AlurKeluarga) ----------
  final ferry = inti.person('ferry')!;
  final agustina = inti.person('agustina')!;
  final novita = inti.person('novita')!;
  String pendek(Tanggal d) => '${d.hari}-${d.bulan}-${d.tahun % 100}';
  final bukuBaris = <ImportRow>[
    ImportRow(
      id: 'buku7-ferry',
      line: 4,
      bookText: 'WENAS FERRY, lhr ${pendek(ferry.birthDate!)}, Kol 7',
      name: ferry.name,
      kolomId: 'kolom-7',
      birthDate: ferry.birthDate,
      sex: Sex.male,
      marital: m,
      personId: 'ferry',
      householdKey: 'wenas-lasut',
    ),
    ImportRow(
      id: 'buku7-agustina',
      line: 5,
      bookText: 'LASUT AGUSTINA (istri), ${pendek(agustina.birthDate!)}',
      name: agustina.name,
      kolomId: 'kolom-7',
      sex: Sex.female,
      marital: m,
      personId: 'agustina',
      householdKey: 'wenas-lasut',
      yearMissing: true,
    ),
    ImportRow(
      id: 'buku7-novita',
      line: 23,
      bookText: 'WENAS NOVITA, ${pendek(novita.birthDate!)}',
      name: novita.name,
      kolomId: 'kolom-7',
      birthDate: novita.birthDate,
      sex: Sex.female,
      marital: n,
      householdKey: 'wenas-lasut',
    ),
    ImportRow(
      id: 'buku7-rumagit',
      line: 27,
      bookText: 'RUMAGIT H., tgl lhr tdk terbaca',
      name: '—',
      kolomId: 'kolom-7',
      sex: Sex.male,
    ),
  ];
  var baris = 0;
  for (final r in pabrik.barisBuku('kolom-7', 24)) {
    while (const [4, 5, 23, 27].contains(++baris)) {}
    bukuBaris.add(
      ImportRow(
        id: 'buku7-$baris',
        line: baris,
        bookText: r.teks,
        name: r.nama,
        kolomId: 'kolom-7',
        birthDate: r.lahir,
        sex: r.jk,
        marital: r.nikah,
        householdKey: r.keluarga,
      ),
    );
  }
  bukuBaris.sort((x, y) => x.line.compareTo(y.line));
  t.batches.add(
    ImportBatch(
      id: 'buku-kolom-7',
      source: 'Buku anggota Kolom 7 · 2019–2026',
      kolomId: 'kolom-7',
      rows: bukuBaris,
    ),
  );

  // ---------- Consent of every active member (naskah versi 1) ----------
  for (final p in t.profiles.values) {
    if (inti.person(p.personId)!.status != PersonStatus.active) continue;
    t.consents.add(
      Consent(
        id: store.newId('izin'),
        personId: p.personId,
        version: consentVersion,
        at: a.jam(a.hariLalu(12), 9, 0),
        channel: ConsentChannel.app,
        givenBy: p.personId,
      ),
    );
  }

  // ---------- Life events already verified (DataAnggota) ----------
  void riwayat(String id, LifeEventKind jenis, String orang, Tanggal tgl) =>
      t.items.add(
        VerificationItem(
          id: id,
          kind: ItemKind.lifeEvent,
          scopeId: 'kolom-7',
          submittedBy: orang,
          submittedAt: tgl.awal,
          status: ItemStatus.verified,
          event: LifeEventDraft(kind: jenis, personIds: [orang], date: tgl),
        )..decidedAt = tgl.awal,
      );
  riwayat(
    'peristiwa-baptis-novita',
    LifeEventKind.baptism,
    'novita',
    a.sejarah(1996, 5, 19),
  );
  riwayat(
    'peristiwa-sidi-novita',
    LifeEventKind.sidi,
    'novita',
    a.sejarah(2014, 4, 13),
  );

  // ---------- Open items (5.6, DP19, DP21, DP36) ----------
  void kabar(
    String kepada,
    String judul,
    String isi,
    DateTime saat,
    String id,
  ) => inti.notifications.add(
    AppNotification(
      id: store.newId('kabar'),
      recipientId: kepada,
      type: NotificationType.action,
      module: Module.membership,
      title: judul,
      body: isi,
      createdAt: saat,
      ref: RecordRef('membership_item', id),
    ),
  );

  final kevin = VerificationItem(
    id: 'permohonan-kevin',
    kind: ItemKind.application,
    scopeId: 'kolom-2',
    submittedBy: 'kevin',
    submittedAt: a.jam(a.hariLalu(15), 10, 12),
    subjectPersonId: 'kevin',
    householdId: 'rompas',
    application: ApplicationForm(
      name: 'Kevin Rompas',
      birthDate: a.geser(2001, 7, 21),
      sex: Sex.male,
      marital: n,
      kolomId: 'kolom-2',
      householdId: 'rompas',
    ),
    consentVersion: consentVersion,
  );
  final kematian = VerificationItem(
    id: 'peristiwa-kematian-rompas',
    kind: ItemKind.lifeEvent,
    scopeId: 'kolom-2',
    submittedBy: 'gabriela',
    submittedAt: a.jam(a.hariLalu(16), 7, 30),
    event: LifeEventDraft(
      kind: LifeEventKind.death,
      personIds: const ['yohanisR'],
      date: a.hariLalu(14),
    ),
    attachment: 'surat-kematian.jpg',
  );
  final sidi = VerificationItem(
    id: 'peristiwa-sidi-gabriela',
    kind: ItemKind.lifeEvent,
    scopeId: 'kolom-2',
    submittedBy: 'gabriela',
    submittedAt: a.jam(a.hariLalu(12), 9, 0),
    event: LifeEventDraft(
      kind: LifeEventKind.sidi,
      personIds: const ['gabriela'],
      date: a.hariLalu(1),
    ),
    attachment: 'piagam-sidi.jpg',
  );
  final sumual = VerificationItem(
    id: 'perubahan-sumual',
    kind: ItemKind.dataChange,
    scopeId: 'kolom-2',
    submittedBy: 'yanti',
    submittedAt: a.jam(a.hariLalu(15), 16, 0),
    subjectPersonId: 'yanti',
    householdId: 'sumual',
    change: 'Alamat rumah keluarga diperbarui',
  );
  final rumagit = VerificationItem(
    id: 'perubahan-rumagit',
    kind: ItemKind.dataChange,
    scopeId: 'kolom-7',
    submittedBy: 'hendrik',
    submittedAt: a.jam(a.hariLalu(14), 20, 0),
    subjectPersonId: 'hendrik',
    householdId: 'rumagit',
    change: 'Nomor telepon keluarga diperbarui',
  );
  final pindah = VerificationItem(
    id: 'peristiwa-pindah-lasut',
    kind: ItemKind.lifeEvent,
    scopeId: 'kolom-7',
    submittedBy: 'lasut-1',
    submittedAt: a.jam(a.hariLalu(13), 11, 0),
    householdId: 'lasut',
    event: LifeEventDraft(
      kind: LifeEventKind.kolomMove,
      personIds: const ['lasut-1', 'lasut-2', 'lasut-3'],
      date: a.hariLalu(13),
      fromKolomId: 'kolom-4',
      toKolomId: 'kolom-7',
      effective: a.bln(1, 1),
      householdId: 'lasut',
    ),
  );
  final baptis =
      VerificationItem(
          id: 'peristiwa-baptis-gabriel',
          kind: ItemKind.lifeEvent,
          scopeId: 'kolom-7',
          submittedBy: 'novita',
          submittedAt: a.jam(a.hariLalu(15), 19, 0),
          status: ItemStatus.returned,
          event: LifeEventDraft(
            kind: LifeEventKind.baptism,
            personIds: const ['gabriel'],
            date: a.hariLalu(8),
          ),
          attachment: 'surat-baptis.jpg',
        )
        ..decidedBy = 'hendrik'
        ..decidedAt = a.jam(a.hariLalu(16), 8, 40)
        ..reason = 'nama di surat baptis “Gabriel J. Wenas”; mohon samakan.';
  t.items.addAll([kevin, kematian, sidi, sumual, rumagit, pindah, baptis]);

  for (final (kepada, i, judul) in [
    ('yanti', kevin, 'Permohonan menjadi anggota · Kevin Rompas'),
    ('yanti', kematian, 'Peristiwa: Kematian · Yohanis Rompas'),
    ('yanti', sidi, 'Peristiwa: Sidi · Gabriela Rompas'),
    ('greis', rumagit, 'Perubahan data · Keluarga Rumagit'),
    ('hendrik', pindah, 'Peristiwa: Pindah Kolom · Keluarga Lasut'),
    ('greis', pindah, 'Peristiwa: Pindah Kolom · Keluarga Lasut'),
  ]) {
    kabar(
      kepada,
      judul,
      'Menunggu verifikasi · ${inti.scope(i.scopeId)!.name}',
      i.submittedAt,
      i.id,
    );
  }
  inti.notifications.add(
    AppNotification(
      id: store.newId('kabar'),
      recipientId: 'novita',
      type: NotificationType.role,
      module: Module.membership,
      title: 'Peristiwa: Baptisan · Gabriel Wenas dikembalikan',
      body: 'Alasan: ${baptis.reason}',
      createdAt: baptis.decidedAt!,
      ref: RecordRef('membership_item', baptis.id),
    ),
  );

  // ---------- Name forms (DP23: Novita's own choice from TampilanNama) ----------
  t.masking['novita'] = MaskingPreference(
    personId: 'novita',
    form: NameForm.familyKolom,
  );
  // The Sampul syukur of the coming Warta prints "Tanpa nama, Kolom 4"
  // (AlurWarta, BukaNama).
  t.masking['mamahit-1'] = MaskingPreference(
    personId: 'mamahit-1',
    form: NameForm.none,
  );

  assert(() {
    final aktif = t.profiles.values
        .where((p) => inti.person(p.personId)!.status == PersonStatus.active)
        .length;
    final belum = t.profiles.values.length - aktif;
    final rumah = t.households.values
        .where((h) => h.status == HouseholdStatus.active)
        .length;
    final baris = t.batches
        .where((b) => b.status == ImportStatus.imported)
        .fold(0, (s, b) => s + b.rows.length);
    return aktif == 1284 && belum == 241 && rumah == 412 && baris == 318;
  }(), 'jumlah Data jemaat tidak sesuai 5.1');
}

/// How a paper book writes a person: 'KARUNDENG ALBERT, 5-4-80'.
String _diBuku(Person o) {
  final d = o.birthDate!;
  final kata = o.name.split(' ');
  return '${kata.last.toUpperCase()} ${kata.first.toUpperCase()}, '
      '${d.hari}-${d.bulan}-${d.tahun % 100}';
}

/// The deterministic bulk generator: plain Minahasa names whose surnames
/// avoid every story surname (D10).
class _Pabrik {
  _Pabrik(this.store, this.a);
  final SeedStore store;
  final Jangkar a;
  var _i = 0, _rumah = 0;

  /// Bulk members created per Kolom, in order.
  final dibuat = <String, List<String>>{};

  static const _marga = [
    'Assa', 'Gerung', 'Kalangi', 'Karundeng', 'Kawatu', 'Kojongian', //
    'Korompis', 'Kumaat', 'Lapian', 'Lumanauw', 'Mangindaan', 'Mantiri',
    'Moningka', 'Najoan', 'Palar', 'Paat', 'Pinontoan', 'Polii', 'Pongoh',
    'Posumah', 'Rorimpandey', 'Ruata', 'Rumbayan', 'Runtukahu', 'Sagay',
    'Sengkey', 'Sigar', 'Sumampouw', 'Sumarauw', 'Tambuwun', 'Tampi',
    'Tangel', 'Tendean', 'Tewu', 'Tumiwa', 'Turangan', 'Umboh', 'Waworuntu',
    'Walewangko', 'Warouw', 'Wuisan', 'Wullur',
  ];
  static const _pria = [
    'Albert', 'Arnold', 'Benny', 'Daniel', 'Deddy', 'Frangky', 'Hendra', //
    'Jacky', 'Jemmy', 'Johan', 'Max', 'Nico', 'Ronald', 'Rudy', 'Steven',
    'Tommy', 'Vecky', 'Willem', 'Yosua', 'Fernando', 'Glenn', 'Jerry',
    'Marlon', 'Alfrets', 'Christian', 'Kenny',
  ];
  static const _wanita = [
    'Agnes', 'Ester', 'Fany', 'Grace', 'Ivon', 'Jenny', 'Maria', 'Meity', //
    'Mira', 'Nancy', 'Ria', 'Sherly', 'Sintje', 'Tineke', 'Vera', 'Vivi',
    'Winda', 'Yuli', 'Feibe', 'Christie', 'Juwita', 'Lisye', 'Marlin',
    'Stella', 'Anneke',
  ];

  Tanggal _lahir(int umur, int k) =>
      a.geser(2026 - umur, 1 + (k * 5) % 12, 1 + (k * 11) % 28);

  /// One person with a profile in [kolom].
  String _orang(
    String kolom,
    String marga,
    Sex jk,
    int umur,
    MaritalStatus nikah, {
    PersonStatus status = PersonStatus.active,
  }) {
    final k = _i++;
    final id = 'anggota-${k + 1}';
    final depan = jk == Sex.male
        ? _pria[(k * 7) % _pria.length]
        : _wanita[(k * 5) % _wanita.length];
    store.inti.addPerson(
      Person(
        id: id,
        name: '$depan $marga',
        status: status,
        birthDate: _lahir(umur, k),
        sex: jk,
      ),
    );
    store.jemaat.profiles[id] = MemberProfile(
      personId: id,
      kolom: [KolomStint(kolomId: kolom)],
      marital: nikah,
    );
    (dibuat[kolom] ??= []).add(id);
    return id;
  }

  /// [jumlah] people of one family: a couple and children, or one adult.
  List<String> _satuKeluarga(
    String kolom,
    int jumlah, {
    PersonStatus status = PersonStatus.active,
  }) {
    final r = _rumah++;
    final marga = _marga[r % _marga.length];
    final kepala = 35 + (r * 7) % 35;
    if (jumlah == 1) {
      return [
        _orang(
          kolom,
          marga,
          r.isEven ? Sex.male : Sex.female,
          20 + (r * 3) % 50,
          MaritalStatus.never,
          status: status,
        ),
      ];
    }
    return [
      _orang(
        kolom,
        marga,
        Sex.male,
        kepala,
        MaritalStatus.married,
        status: status,
      ),
      _orang(
        kolom,
        marga,
        Sex.female,
        kepala - 3,
        MaritalStatus.married,
        status: status,
      ),
      for (var c = 0; c < jumlah - 2; c++)
        _orang(
          kolom,
          marga,
          c.isEven ? Sex.female : Sex.male,
          2 + (r + c * 5) % 23,
          MaritalStatus.never,
          status: status,
        ),
    ];
  }

  void _rumahTangga(
    String kolom,
    List<String> anggota, {
    HouseholdStatus status = HouseholdStatus.active,
    DateTime? diimpor,
  }) {
    final id = 'keluarga-${store.jemaat.households.length + 1}';
    store.jemaat.households[id] = Household(
      id: id,
      name: store.inti.person(anggota.first)!.name.split(' ').last,
      kolomId: kolom,
      memberIds: anggota,
      representativeId: anggota.first,
      status: status,
      importedAt: diimpor,
    );
    for (final p in anggota) {
      store.jemaat.profiles[p]!.householdId = id;
    }
  }

  /// [orang] active members in [rumah] families in [kolom].
  void keluarga(String kolom, int orang, int rumah) {
    assert(orang >= rumah && rumah > 0, '$kolom: $orang orang, $rumah rumah');
    for (var h = 0; h < rumah; h++) {
      final ukuran = orang ~/ rumah + (h < orang % rumah ? 1 : 0);
      _rumahTangga(kolom, _satuKeluarga(kolom, ukuran));
    }
  }

  /// [jumlah] unconfirmed people from a paper book, families of three.
  List<String> keluargaBelum(String kolom, int jumlah, DateTime diimpor) {
    final semua = <String>[];
    while (semua.length < jumlah) {
      final ukuran = jumlah - semua.length >= 3 ? 3 : jumlah - semua.length;
      final anggota = _satuKeluarga(
        kolom,
        ukuran,
        status: PersonStatus.unconfirmed,
      );
      _rumahTangga(
        kolom,
        anggota,
        status: HouseholdStatus.unconfirmed,
        diimpor: diimpor,
      );
      semua.addAll(anggota);
    }
    return semua;
  }

  /// [jumlah] book rows for people not yet in Data jemaat, families of three.
  List<
    ({
      String nama,
      String teks,
      Tanggal lahir,
      Sex jk,
      MaritalStatus nikah,
      String keluarga,
    })
  >
  barisBuku(String kolom, int jumlah) {
    final hasil =
        <
          ({
            String nama,
            String teks,
            Tanggal lahir,
            Sex jk,
            MaritalStatus nikah,
            String keluarga,
          })
        >[];
    while (hasil.length < jumlah) {
      final r = _rumah++;
      final marga = _marga[(r * 3) % _marga.length];
      final kepala = 35 + (r * 7) % 35;
      for (var c = 0; c < 3 && hasil.length < jumlah; c++) {
        final k = _i++;
        final jk = c == 1 ? Sex.female : Sex.male;
        final depan = jk == Sex.male
            ? _pria[(k * 7) % _pria.length]
            : _wanita[(k * 5) % _wanita.length];
        final lahir = _lahir(c < 2 ? kepala - c * 3 : 2 + r % 20, k);
        hasil.add((
          nama: '$depan $marga',
          teks:
              '${marga.toUpperCase()} ${depan.toUpperCase()}, '
              '${lahir.hari}-${lahir.bulan}-${lahir.tahun % 100}',
          lahir: lahir,
          jk: jk,
          nikah: c < 2 ? MaritalStatus.married : MaritalStatus.never,
          keluarga: 'buku7-keluarga-${r + 1}',
        ));
      }
    }
    return hasil;
  }
}
