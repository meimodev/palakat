import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The 11 personas the picker offers (README 5.2, D17), in picker order.
/// M1 replaces this fixed list with the seed's people and posts.
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

/// Who is signed in. M1 adds the post they act in.
class Session {
  const Session(this.persona);
  final Persona persona;
}

/// The signed-in persona, or null while the picker shows (D7). Signing out
/// keeps every other provider's state, so two-sided flows work on one device.
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  void masuk(Persona p) => state = Session(p);

  void keluar() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);

/// True while the actor acts by vacancy cover of the Bendahara post (D18):
/// the phone strip, the web band and the web footer read it. M1 derives it
/// from the actor; until then nobody covers the post.
final vacancyCoverProvider = Provider<bool>((ref) => false);

/// Signs out from a widget callback (never during build): the router then
/// shows the picker.
void keluarSesi(BuildContext context) => ProviderScope.containerOf(
  context,
  listen: false,
).read(sessionProvider.notifier).keluar();
