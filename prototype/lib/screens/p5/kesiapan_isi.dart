import 'package:flutter/widgets.dart';

import '../../motion/kerangka.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../app/belum_dipindah.dart';

/// Board `F`: id, peruntukan, person (Umum Jemaat carries its statement date).
const _peruntukan = [
  ('umum', 'Umum Jemaat', 'Pnt. Jefry Wowor · 02/11/2026'),
  ('diak', 'Diakonia', 'Dkn. Olga Tamba'),
  ('bang', 'Pembangunan', 'Sdr. Rivo Mandagi'),
];

const _muncul = Duration(milliseconds: 300);

/// The board state and handlers shared by Kesiapan and WebKesiapan.
mixin KesiapanLogika<T extends StatefulWidget> on State<T> {
  /// Board stem, for the `masukSebagai` tweak.
  String get stem;

  final Map<String, String> _f = {
    'umum': 'ada',
    'diak': 'lagi',
    'bang': 'belum',
  };
  final Map<String, String> _als = {};
  String? _form;
  final _alasan = TextEditingController();
  final _fokus = FocusNode();

  @override
  void dispose() {
    _alasan.dispose();
    _fokus.dispose();
    super.dispose();
  }

  /// Reads the tweak. A switch keeps all state, the open form included, as
  /// on the board (CONVENTIONS: board parity over the spec's recommendation).
  bool bendahara(BuildContext context) =>
      belumDipindah<String>('Bendahara') == 'Bendahara';

  bool get _ok => _alasan.text.trim().isNotEmpty;
  bool _perlu(String id) => _f[id] == 'lagi' || _f[id] == 'belum';
  int get _kurang => _peruntukan.where((x) => _perlu(x.$1)).length;

  void _set(String id, String v) => setState(() {
    _f[id] = v;
    _form = null;
    _alasan.clear();
  });

  /// Hambatan card, or the done card with `muncul` (Bendahara only).
  Widget kartuKeadaan(BuildContext context) {
    final c = context.warna;
    if (_kurang > 0) {
      return Kartu(
        status: GarisStatus.hambatan,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hambatan tutup buku Oktober 2026',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '$_kurang peruntukan belum punya pernyataan kesiapan yang berlaku. Minta bendahara unitnya menyatakan siap, atau bebaskan dengan alasan.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
      );
    }
    final bebasN = _peruntukan.where((x) => _f[x.$1] == 'bebas').length;
    return Gerak(
      Kerangka.muncul,
      lama: _muncul,
      child: Kartu(
        status: GarisStatus.ditutup,
        isi: c.lautLembut,
        child: Text(
          'Pernyataan kesiapan semua peruntukan sudah ada'
          '${bebasN > 0 ? ' · $bebasN dibebaskan, tercatat sebagai pengecualian di konfirmasi tutup buku' : ''}.',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Unit treasurer intro line.
  Widget introPenyiap(BuildContext context) => Text(
    'Anda menyatakan bahwa catatan peruntukan Diakonia untuk Oktober 2026 sudah lengkap menurut Anda. Ini bukan persetujuan dan tidak menutup buku; tutup buku tetap dilakukan Bendahara.',
    style: TextStyle(fontSize: 14, color: context.warna.tinta2),
  );

  /// The row list: each card has margin-bottom 12.
  Widget daftarBaris(BuildContext context, bool bend) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final x in _peruntukan)
        if (bend || x.$1 == 'diak') ...[
          _baris(context, bend, x),
          const SizedBox(height: 12),
        ],
    ],
  );

  Widget _baris(BuildContext context, bool bend, (String, String, String) x) {
    final c = context.warna;
    final (id, nama, orang) = x;
    final st = _f[id]!;
    final perlu = _perlu(id);
    final (label, bentuk) = switch (st) {
      'ada' => ('Sudah dinyatakan siap', BentukLencana.laut),
      'lagi' => ('Perlu dinyatakan lagi', BentukLencana.bata),
      'belum' => ('Pernyataan kesiapan belum ada', BentukLencana.bata),
      _ => ('Dibebaskan', BentukLencana.peran),
    };
    final cat = switch (st) {
      'ada' => 'Oleh ${id == 'umum' ? orang : '$orang · 16/11/2026'}',
      'lagi' => 'Dinyatakan 01/11/2026, lalu ada transaksi Oktober yang berubah. Pernyataan lama tidak berlaku lagi.',
      'belum' => 'Bendahara unit: $orang',
      _ => 'Oleh Bendahara · alasan: ${_als[id] ?? ''}',
    };
    return Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Peruntukan $nama',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              LencanaStatus(label, bentuk: bentuk),
            ],
          ),
          const SizedBox(height: 8),
          Text(cat, style: TextStyle(fontSize: 14, color: c.tinta2)),
          if (bend && perlu && _form != id) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Tombol(
                'Bebaskan',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                paddingH: 18,
                lebarPenuh: false,
                onPressed: () => setState(() {
                  _form = id;
                  _alasan.clear();
                }),
              ),
            ),
          ],
          if (!bend && perlu) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Tombol(
                'Nyatakan siap',
                paddingH: 18,
                lebarPenuh: false,
                onPressed: () => _set(id, 'ada'),
              ),
            ),
          ],
          if (_form == id) ...[
            const SizedBox(height: 8),
            Gerak(
              Kerangka.muncul,
              key: ValueKey('form-$id'),
              lama: _muncul,
              child: _formBebas(context, id),
            ),
          ],
        ],
      ),
    );
  }

  Widget _formBebas(BuildContext context, String id) {
    final c = context.warna;
    final ok = _ok;
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: GestureDetector(
              onTap: _fokus.requestFocus,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Alasan membebaskan '),
                    TextSpan(
                      text: '· wajib',
                      style: TextStyle(
                        color: c.tinta,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          IsianTeks(
            controller: _alasan,
            focusNode: _fokus,
            labelSemantik: 'Alasan membebaskan · wajib',
            baris: 2,
            minTinggi: 0,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Tombol(
                'Bebaskan dengan alasan ini',
                jenis: JenisTombol.tinta,
                ukuran: UkuranTombol.ringkas,
                lebarPenuh: false,
                nonaktif: !ok,
                onPressed: () {
                  if (!_ok) return;
                  _als[id] = _alasan.text.trim();
                  _set(id, 'bebas');
                },
              ),
              Tombol(
                'Kembali',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.ringkas,
                lebarPenuh: false,
                onPressed: () => setState(() => _form = null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// `siapa` of the subtitle.
String siapaKesiapan(bool bend) => bend
    ? 'Meiske L., Bendahara'
    : 'Dkn. Olga Tamba, Bendahara Komisi Diakonia';
