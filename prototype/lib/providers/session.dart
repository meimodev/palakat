import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/session_repository.dart';
import '../domain/core/core.dart';
import 'actor.dart';
import 'clock.dart';
import 'core_repositories.dart';
import 'revision.dart';

export 'actor.dart' show vacancyCoverProvider;

/// The 11 personas the picker offers (README 5.2, D17), in picker order:
/// the picker's copy (name, post line, web footer). Each is a seed person
/// ([personId]); SessionRepository.personas() lists the same people.
enum Persona {
  meiske(
    'Meiske Lumentut',
    'Bendahara Jemaat',
    kaki: ('Meiske L.', ' · Bendahara', 'Wewenang Bendahara aktif'),
  ),
  olvie(
    'Olvie Pangemanan',
    'Sekretaris Jemaat',
    kaki: ('Olvie Pangemanan', ' · Sekretaris Jemaat', null),
  ),
  yanti(
    'Yanti Sumual',
    'Operator · menjalankan Penatua Kolom 2',
    kaki: ('Yanti Sumual', ' · Operator', null),
  ),
  lidya(
    'Pdt. Lidya Rondonuwu',
    'Ketua Jemaat · Pimpinan Jemaat yang berwenang',
    kaki: (
      'Pdt. Lidya Rondonuwu',
      ' · Ketua Jemaat',
      'Pimpinan Jemaat yang berwenang',
    ),
  ),
  jefry(
    'Pnt. Jefry Wowor',
    'Pemeriksa kedua · Wakil Ketua BPMJ',
    kaki: (null, 'Jemaat Karunia', 'Wajib pemeriksa kedua: hidup'),
  ),
  hendrik(
    'Pnt. Hendrik Rumagit',
    'Penatua Kolom 7 · Ketua Komisi Diakonia',
    kaki: ('Pnt. Hendrik Rumagit', ' · Penatua Kolom 7', null),
  ),
  greis('Sym. Greis Mamahit', 'Syamas Kolom 7 · menerima pelimpahan'),
  deasy('Deasy Tumbelaka', 'Bendahara Kolom 7'),
  olga(
    'Dkn. Olga Tamba',
    'Bendahara Komisi Diakonia · Akses terbatas Diakonia',
    kaki: ('Dkn. Olga Tamba', '', 'Akses terbatas: Peruntukan Diakonia'),
  ),
  rivo('Sdr. Rivo Mandagi', 'Bendahara Panitia Natal 2026 · Ketua Pemuda'),
  novita('Novita Wenas', 'Anggota jemaat · Kolom 7');

  const Persona(this.nama, this.jabatan, {this.kaki});

  /// The seed person behind the persona.
  String get personId => name;

  final String nama;

  /// The post line under the name on the picker.
  final String jabatan;

  /// The web side-nav footer (navigation.md 1.3): bold part, plain part, second
  /// line. Without one the footer is the name and the post line.
  final (String?, String, String?)? kaki;
}

/// The picker's role headings, copied from the journeys of the deleted
/// launcher (`shell/perjalanan.dart`), with the personas under each.
const kelompokPersona = <(String, List<Persona>)>[
  ('Bendahara Jemaat', [Persona.meiske]),
  ('Sekretaris Jemaat', [Persona.olvie]),
  ('Operator', [Persona.yanti]),
  ('Pimpinan Jemaat yang berwenang', [Persona.lidya, Persona.jefry]),
  ('Penatua Kolom', [Persona.hendrik, Persona.greis]),
  (
    'Bendahara unit and committee officers',
    [Persona.deasy, Persona.olga, Persona.rivo],
  ),
  ('Anggota jemaat', [Persona.novita]),
];

/// Who is signed in (README 3.3): the persona, its session record, and the
/// post it acts in. [revisi] snapshots the record's revision, so a change to
/// the record makes a new state.
class Session {
  Session._(this.persona, this.record, this.revisi);

  final Persona persona;
  final SessionRecord record;
  final int revisi;

  String get personId => record.personId;

  /// The assignment it acted in ended: the router shows `/sesi-berakhir`.
  bool get berakhir => record.ended;

  /// The acting post; null while [perluMemilih], and never for a member
  /// without a post (that is the "Anggota jemaat" grant).
  Grant? get bertindak => record.acting;

  /// "Sebagai …" (Q31, AlurBeranda "Dua jabatan dapat bertindak"): two
  /// posts can act and none is chosen yet. Choose with
  /// `SessionNotifier.pilihSebagai`.
  bool get perluMemilih => record.acting == null && record.choices.length > 1;

  /// The posts to choose from while [perluMemilih].
  List<Grant> get pilihan => record.choices;
}

/// The signed-in persona, or null while the picker shows (D7), backed by
/// SessionRepository. It follows the store: when the assignment the session
/// acts in ends, [Session.berakhir] turns true. Signing out keeps every other
/// provider's state, so two-sided flows work on one device.
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() {
    ref.listen(revisionProvider, (_, _) => _segarkan());
    return _baca();
  }

  SessionRepository get _repo => ref.read(sessionRepositoryProvider);

  Session? _baca() {
    final r = _repo.current();
    if (r == null) return null;
    return Session._(Persona.values.byName(r.personId), r, r.revision);
  }

  void _segarkan() {
    final r = _repo.current();
    final s = state;
    if (r?.id == s?.record.id && r?.revision == s?.revisi) return;
    state = _baca();
  }

  /// Signs [p] in; the router then opens the role home.
  Future<void> masuk(Persona p) async {
    await _repo.signIn(p.personId);
    _segarkan();
  }

  /// Signs out; the router then shows the picker.
  Future<void> keluar() async {
    await _repo.signOut();
    _segarkan();
  }

  /// Records the post chosen for "Sebagai …" ([Session.pilihan]).
  Future<Result<SessionRecord>> pilihSebagai(Grant g) async {
    final r = await _repo.actAs(
      g.toActor(),
      idempotencyKey: kunciBaru(g.personId, ref.read(clockProvider)),
    );
    _segarkan();
    return r;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);

/// Signs out from a widget callback (never during build): the router then
/// shows the picker.
void keluarSesi(BuildContext context) => ProviderScope.containerOf(
  context,
  listen: false,
).read(sessionProvider.notifier).keluar();
