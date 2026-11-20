import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// One part of the offering: board `bagian[i]` (`v` lives in the controller).
class _Bagian {
  _Bagian(this.n, String v, this.milik, this.akun)
    : ctrl = TextEditingController(text: titik(v));
  final String n;
  final TextEditingController ctrl;
  String milik, akun;
  int get nilai => angkaDari(ctrl.text) ?? 0;
}

const _milik = [
  ('sendiri', 'Milik sendiri'),
  ('titipan', 'Titipan untuk: Sinode'),
];
const _akun = [
  ('kas', 'Kas'),
  ('bni', 'Bank BNI ··4821'),
  ('bsg', 'Bank SulutGo ··1107'),
];
const _contohSampul = [('Novita Wenas', 100000), ('Agustina Lasut', 250000)];

/// Web · Persembahan (spec 04-lainnya.md): parts as cards, a summary aside
/// that turns from draft to posted in place.
class WebPersembahanScreen extends StatefulWidget {
  const WebPersembahanScreen({super.key});

  @override
  State<WebPersembahanScreen> createState() => _WebPersembahanScreenState();
}

class _WebPersembahanScreenState extends State<WebPersembahanScreen> {
  bool _posted = false;
  final _bagian = [
    _Bagian('Tunai', '2350000', 'sendiri', 'kas'),
    _Bagian('QRIS', '800000', 'sendiri', ''),
    _Bagian('Transfer bank', '450000', 'titipan', 'bni'),
  ];
  final List<(String, int)> _sampul = [];

  @override
  void dispose() {
    for (final b in _bagian) {
      b.ctrl.dispose();
    }
    super.dispose();
  }

  // Board `set()`: locked once posted.
  void _set(VoidCallback f) {
    if (!_posted) setState(f);
  }

  int _jumlah(String m) =>
      _bagian.where((b) => b.milik == m).fold(0, (a, b) => a + b.nilai);

  String get _alasan {
    if (_jumlah('sendiri') + _jumlah('titipan') == 0) {
      return 'semua bagian masih kosong.';
    }
    for (final b in _bagian) {
      if (b.nilai > 0 && b.akun.isEmpty) {
        return 'Kas/Bank untuk bagian ${b.n} belum dipilih.';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final sendiri = _jumlah('sendiri'), titipan = _jumlah('titipan');
    final total = sendiri + titipan;
    final tunaiKas = _bagian
        .where((b) => b.akun == 'kas')
        .fold(0, (a, b) => a + b.nilai);
    final mono = TextStyle(fontFamily: PalakatText.mono);

    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The 44 target overhangs the 21.75 line box (15 / 1.45).
        MarginNegatif(
          atas: 11.125,
          bawah: 11.125,
          child: Tautan(
            ke: 'WebTransaksi',
            cara: Cara.naik,
            child: const Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: TautanTeks('Transaksi', ukuran: 14),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              text: 'Persembahan ',
              children: [
                TextSpan(
                  text: '· Ibadah Minggu · 15 November 2026',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: c.tinta3,
                  ),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            // The h1's 26 px line box also holds a wrapped line of only the
            // 15 px span (390 wide).
            strutStyle: const StrutStyle(
              fontFamily: PalakatText.sans,
              fontSize: 26,
              height: 1.45,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        ),
      ],
    );

    Widget barisJumlah(String label, int n) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label, style: TextStyle(color: c.tinta2)),
        ),
        Text(rp(n), style: mono),
      ],
    );

    final ringkasan = Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: _posted ? c.permukaan : null,
        shape: _posted
            ? GarisBorder.penuh(c.tinta, radius: 16)
            : GarisBorder.putus(c.putus, radius: 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // A one-word badge keeps its width (CSS min-content); the stamp wraps.
              if (_posted)
                const LencanaStatus('Dibukukan', bentuk: BentukLencana.tinta)
              else
                const Flexible(
                  child: LencanaStatus(
                    'Draf · belum masuk saldo',
                    bentuk: BentukLencana.draf,
                  ),
                ),
              if (_posted) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Gerak(
                    Kerangka.muncul,
                    lama: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: c.laut, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        // U+200B: Chrome breaks after the hyphens; Flutter does not.
                        'No. Bukti BKU-\u200B2026-\u200B0148',
                        style: mono.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.laut,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rp(total),
            style: mono.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                barisJumlah('Milik sendiri · menjadi Pendapatan', sendiri),
                const SizedBox(height: 8),
                barisJumlah(
                  'Titipan untuk: Sinode · bukan Pendapatan',
                  titipan,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final jumlahSampul = _sampul.fold(0, (a, x) => a + x.$2);
    final sampul = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sampul bernama',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(
            'Bagian dari jumlah di atas; tidak menambah total. Nama hanya '
            'dilihat pemberinya dan Bendahara Jemaat.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
          for (var i = 0; i < _sampul.length; i++) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.garis)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _sampul[i].$1,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(rp(_sampul[i].$2), style: mono.copyWith(fontSize: 15)),
                  const SizedBox(width: 12),
                  Tombol(
                    'Lepas nama',
                    onPressed: () => setState(() => _sampul.removeAt(i)),
                    jenis: JenisTombol.teks,
                    ukuran: UkuranTombol.mini,
                    paddingH: 10,
                    ukuranTeks: 14,
                    lebarPenuh: false,
                  ),
                ],
              ),
            ),
          ],
          if (jumlahSampul > total) ...[
            const SizedBox(height: 8),
            const Penolakan(
              tindakan: 'Periksa dan bukukan',
              sebab: 'Jumlah sampul bernama melebihi jumlah persembahan.',
              jalan: [],
              ukuranTeks: 14,
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (_sampul.length < 2)
                Tekan(
                  // Board `tambahSampul`: the next sample by count.
                  onTap: () => setState(
                    () => _sampul.add(_contohSampul[_sampul.length]),
                  ),
                  radius: 14,
                  child: RupaTombol(
                    label: 'Catat nama pemberi',
                    isi: c.permukaan,
                    garis: GarisBorder.penuh(c.tinta, radius: 14),
                    warnaTeks: c.tinta,
                    radius: 14,
                    tinggi: 44,
                    paddingH: 16,
                    lebarPenuh: false,
                    ukuranTeks: 14,
                  ),
                ),
              const Tautan(
                ke: 'WebPersembahanBernama',
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: TautanTeks(
                    'Aturan nama pemberi',
                    berat: FontWeight.w700,
                    ukuran: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final lembar = Kartu(
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lembar penghitungan persembahan · Terlampir',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Petugas penghitung: Dkn. Olga Tamba, Pnt. Jefry Wowor',
              style: TextStyle(color: c.tinta2),
            ),
          ],
        ),
      ),
    );

    final catatan = Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          shape: GarisBorder.putus(c.putus, radius: 14),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${rp(tunaiKas)} tunai sekarang ada di Kas.',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(
                text:
                    ' Setoran ke bank dicatat sebagai Pindah antar Kas/Bank, '
                    'bukan Pendapatan baru.',
              ),
            ],
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );

    final samping = [
      ringkasan,
      sampul,
      lembar,
      if (_posted)
        catatan
      else
        TombolBersyarat(
          label: 'Periksa dan bukukan',
          tindakan: 'Periksa dan bukukan',
          alasan: _alasan,
          periksa: () => _alasan,
          onPressed: () => setState(() => _posted = true),
          warnaSiap: JenisTombol.utama,
          teksBelumRedup: true,
          gayaAlasan: GayaAlasan.kalimatBata,
          tinggi: 50,
          radius: 12,
          jarak: 14,
        ),
    ];

    return HalamanWeb(
      jabatanKosong: true,
      nav: NavSamping(
        item: navKeuangan,
        aktif: 1,
        pengguna: const PenggunaKeuangan(),
      ),
      isi: [
        judul,
        BarisLentur(
          anak: [
            Lentur(
              dasar: 560,
              tumbuh: 999,
              child: KisiOtomatis(
                minLebar: 250,
                jarak: 16,
                anak: [
                  for (final b in _bagian)
                    _KartuBagian(
                      bagian: b,
                      terkunci: _posted,
                      onUbah: () => _set(() {}),
                      onMilik: (m) => _set(() => b.milik = m),
                      onAkun: (a) => _set(() => b.akun = a),
                    ),
                ],
              ),
            ),
            Lentur(
              dasar: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < samping.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    samping[i],
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One part card: label, amount row, owner and Kas/Bank chips, MA line.
class _KartuBagian extends StatefulWidget {
  const _KartuBagian({
    required this.bagian,
    required this.terkunci,
    required this.onUbah,
    required this.onMilik,
    required this.onAkun,
  });

  final _Bagian bagian;
  final bool terkunci;
  final VoidCallback onUbah;
  final ValueChanged<String> onMilik, onAkun;

  @override
  State<_KartuBagian> createState() => _KartuBagianState();
}

class _KartuBagianState extends State<_KartuBagian> {
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final b = widget.bagian;
    final mono = TextStyle(
      fontFamily: PalakatText.mono,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final gayaAngka = DefaultTextStyle.of(context).style
        .merge(mono.copyWith(fontSize: 26, fontWeight: FontWeight.w500));

    Widget pilihan(
      String judul,
      List<(String, String)> daftar,
      String terpilih,
      double radius,
      ValueChanged<String> onPilih,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(judul, style: TextStyle(fontSize: 13, color: c.tinta2)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (k, teks) in daftar)
              _Chip(
                teks: teks,
                dipilih: k == terpilih,
                radius: radius,
                onTap: () => onPilih(k),
              ),
          ],
        ),
      ],
    );

    final (kode, nama) = b.milik == 'sendiri'
        ? ('1.3.53.07.00', ' Persembahan Ibadah Minggu')
        : ('2.1.01.02.00', ' DANA TRANSIT Sentralisasi Sinode');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // <label for>: a tap focuses the field; the field carries the name.
          ExcludeSemantics(
            child: GestureDetector(
              onTap: _fokus.requestFocus,
              child: Text(
                b.n,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                ExcludeSemantics(
                  child: Text(
                    'Rp',
                    style: mono.copyWith(fontSize: 16, color: c.tinta3),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Semantics(
                    label: b.n,
                    child: CincinFokus(
                      tampil: _fokus.hasFocus,
                      child: Material(
                        type: MaterialType.transparency,
                        child: TextField(
                          controller: b.ctrl,
                          focusNode: _fokus,
                          readOnly: widget.terkunci,
                          onChanged: (_) => widget.onUbah(),
                          keyboardType: TextInputType.number,
                          inputFormatters: const [
                            RupiahInputFormatter(sisakanNol: true),
                          ],
                          textAlignVertical: TextAlignVertical.center,
                          style: gayaAngka,
                          cursorColor: c.laut,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            // min-height 44 with the figure centred, as the
                            // <input> draws it (a minHeight alone kept the
                            // line at the top).
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: (44 - 26 * 1.45) / 2,
                            ),
                            hintText: '—',
                            hintStyle: gayaAngka.copyWith(color: c.tinta3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          pilihan('Uang siapa', _milik, b.milik, 10, widget.onMilik),
          const SizedBox(height: 12),
          pilihan('Masuk ke Kas/Bank', _akun, b.akun, 999, widget.onAkun),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              text: 'Pendapatan ',
              children: [
                TextSpan(text: kode, style: mono),
                TextSpan(text: nama),
              ],
            ),
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    );
  }
}

/// Board chip: min 44, padding 0 12, 1.5 line, 13/600; radius 10 (owner) or
/// pill (Kas/Bank). [ChipSatu] is 14 px and always a pill.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.teks,
    required this.dipilih,
    required this.radius,
    required this.onTap,
  });

  final String teks;
  final bool dipilih;
  final double radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: radius == 999 ? 22 : radius,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih ? c.tinta : c.garisTegas,
            radius: radius,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                teks,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: dipilih ? c.permukaan : c.tinta,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
