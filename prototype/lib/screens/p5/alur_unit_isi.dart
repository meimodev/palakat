import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// The state and handlers of AlurUnit / WebAlurUnit (one logic class on both
/// boards) and the content blocks they draw. Each screen adds its own shell.
mixin AlurUnitLogika<T extends StatefulWidget> on State<T> {
  static const _hari = '16/11/2026';
  static const _unit = 'Bendahara Kolom 7';
  static const _aktor = [_unit, 'Bendahara Jemaat'];

  String pesan = '';
  final riw = <String>[];
  String v = 'utama';
  String akt = _unit;
  String jenis = '';
  String kas = '';
  final buku = <(String, String, String)>[];
  String beres = '';
  final jml = TextEditingController();
  final ur = TextEditingController();
  final alasan = TextEditingController();

  /// Put on the first block inside the page's scrollable.
  final kunciAtas = GlobalKey();

  @override
  void dispose() {
    jml.dispose();
    ur.dispose();
    alasan.dispose();
    super.dispose();
  }

  String get _jml => jml.text.replaceAll('.', '');

  /// The board's `a`: first unmet reason of "Bukukan", '' when met.
  String get sebab {
    final n = int.tryParse(_jml) ?? 0;
    if (jenis.isEmpty) return 'jenis belum dipilih.';
    if (n <= 0) return 'jumlah belum diisi.';
    if (kas.isEmpty) return 'Kas/Bank belum dipilih.';
    if (kas != 'Kas Kolom 7') return 'Kas/Bank ini tidak dikelola Kolom 7.';
    if (ur.text.trim().isEmpty) return 'uraian belum diisi.';
    return '';
  }

  bool get _mulai =>
      jenis.isNotEmpty ||
      _jml.isNotEmpty ||
      kas.isNotEmpty ||
      ur.text.isNotEmpty;

  String get _sebab2 =>
      alasan.text.trim().isEmpty ? 'Alasan · wajib belum diisi' : '';

  // A change of view or actor scrolls the body back to the top (spec, shared).
  void _set(VoidCallback f) {
    final (v0, a0) = (v, akt);
    setState(f);
    if (v != v0 || akt != a0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = kunciAtas.currentContext;
        if (ctx != null) Scrollable.maybeOf(ctx)?.position.jumpTo(0);
      });
    }
  }

  void _catat(String t) => riw.insert(0, '$_hari · $t');

  void _bukukan() => _set(() {
    final u = ur.text.trim(), d = _jml;
    buku.insert(0, (
      u,
      '${jenis == 'Belanja' ? '−' : ''}${rpDigit(d)}',
      'No. Bukti baru · $_hari · Dibukukan · $jenis',
    ));
    _catat(
      'Dibukukan: $jenis ${rpDigit(d)} · $u · Deasy Tumbelaka, Bendahara Kolom 7',
    );
    jenis = kas = '';
    jml.clear();
    ur.clear();
    pesan = 'Dibukukan di peruntukan Kolom 7.';
  });

  void _pindah() => _set(() {
    final al = alasan.text.trim();
    v = 'utama';
    beres = al;
    alasan.clear();
    pesan = 'Deasy Tumbelaka diberi tahu lewat Pemberitahuan.';
    _catat(
      'Draf Konsumsi ibadah Kolom dipindah ke 02/11/2026 · Diselesaikan oleh '
      'Bendahara Jemaat (alasan: $al)',
    );
  });

  /// "Dilihat sebagai" in the Keadaan panel, never on screen.
  Widget alat(String stem, Widget child) => AlatPrototipe(
    stem: stem,
    alat: [
      DilihatSebagai(
        pilihan: _aktor,
        terpilih: akt,
        onPilih: (a) => _set(() {
          akt = a;
          pesan = '';
        }),
      ),
    ],
    child: child,
  );

  Widget _pil(
    String label,
    String nilai,
    List<String> a,
    ValueChanged<String> f,
  ) => ChipPilihan<String>(
    label: label,
    jarakLabel: 6,
    jarakBaris: 0,
    pilihan: [for (final n in a) (nilai: n, teks: n)],
    terpilih: nilai.isEmpty ? null : nilai,
    onPilih: (n) => _set(() {
      f(n);
      pesan = '';
    }),
  );

  static const _draf = LencanaStatus('Draf', bentuk: BentukLencana.draf);

  Widget _kartu(List<Widget> anak) => Kartu(child: _kolom(anak, 6));

  /// The content blocks after the header (phone) or title block (web), in
  /// order; the screen puts its column gap between them. [web] draws the
  /// Kolom 7 form as the two-column row.
  List<Widget> blok({required bool web}) {
    final c = context.warna;
    final unit = akt == _unit;
    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    final s = sebab;

    final kiri = <Widget>[
      _pil('Jenis', jenis, const ['Pendapatan', 'Belanja'], (n) => jenis = n),
      IsianAlur(
        label: 'Jumlah (Rp)',
        controller: jml,
        petunjuk: '0',
        keterangan: rpDigit(_jml),
        keyboard: TextInputType.number,
        formatter: const [RupiahInputFormatter(sisakanNol: true)],
        onChanged: (_) => setState(() {}),
      ),
      _pil('Kas/Bank', kas, const [
        'Kas Kolom 7',
        'Kas (dikelola Jemaat)',
      ], (n) => kas = n),
      IsianAlur(
        label: 'Uraian',
        controller: ur,
        petunjuk: 'Contoh: Persembahan Ibadah Kolom',
        onChanged: (_) => setState(() {}),
      ),
      if (_mulai && s.isNotEmpty)
        Penolakan(
          tindakan: 'Bukukan',
          sebab: s,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Bukukan',
            tindakan: 'Bukukan',
            alasan: s,
            periksa: () => sebab,
            sudahMulai: false,
            onPressed: _bukukan,
          ),
        ],
      ),
    ];
    final kanan = <Widget>[
      Semantics(
        header: true,
        child: const Text(
          'Peruntukan Kolom 7 · November 2026',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      for (final r in [
        (
          'Persembahan Ibadah Kolom',
          'Rp320.000',
          'BKU-2026-0151 · 12/11/2026 · Dibukukan',
        ),
        ...buku,
      ])
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: _kolom([
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.$1,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  r.$2,
                  style: const TextStyle(fontFamily: PalakatText.mono),
                ),
              ],
            ),
            Text(r.$3, style: ket),
          ], 2),
        ),
      Kartu(
        status: GarisStatus.draf,
        child: _kolom([
          const KepalaKartu(judul: 'Konsumsi ibadah Kolom', ujung: _draf),
          Text(
            beres.isNotEmpty
                ? 'Dipindah ke 02/11/2026 oleh Bendahara Jemaat · alasan: $beres'
                : '28/10/2026 · Rp185.000 · belum masuk saldo · menghalangi tutup buku Oktober 2026',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ], 6),
      ),
    ];

    return [
      if (pesan.isNotEmpty) Pesan(Text(pesan)),
      if (unit) ...[
        Kartu(
          status: GarisStatus.terpilih,
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Keuangan unit: Kolom 7.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ' Anda membukukan hanya di peruntukan Kolom 7, pada '
                      'Kas/Bank yang dikelola Kolom 7.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
        if (web)
          BarisLentur(
            jarak: 28,
            jarakBaris: 20,
            anak: [
              Lentur(dasar: 420, tumbuh: 1.3, child: _kolom(kiri, 12)),
              Lentur(dasar: 340, child: _kolom(kanan, 12)),
            ],
          )
        else ...[
          ...kiri,
          ...kanan,
        ],
      ] else if (beres.isNotEmpty) ...[
        _kartu([
          const KepalaKartu(judul: 'Konsumsi ibadah Kolom', ujung: _draf),
          Text(
            'Dipindah ke 02/11/2026',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          Text(
            'Diselesaikan oleh Bendahara Jemaat (alasan: $beres) · '
            'Meiske Lumentut, $_hari',
            style: ket,
          ),
        ]),
        const Pesan(
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Tidak ada hambatan dari unit.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' Oktober 2026 dapat diperiksa untuk tutup buku.',
                ),
              ],
            ),
          ),
          siaran: false,
        ),
      ] else if (v != 'alasan') ...[
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Tutup buku Oktober 2026 terhalang 1 hal dari Kolom 7.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ' Bendahara Jemaat dapat menyelesaikannya dengan alasan; '
                      'Bendahara Kolom 7 diberi tahu.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        _kartu([
          const KepalaKartu(judul: 'Konsumsi ibadah Kolom', ujung: _draf),
          const _BarisInfo('Tanggal transaksi', '28/10/2026'),
          const _BarisInfo(
            'Jumlah (Rp)',
            'Rp185.000',
            mono: true,
            berat: FontWeight.w500,
          ),
          const _BarisInfo(
            'Dicatat oleh',
            'Deasy Tumbelaka, Bendahara Kolom 7',
          ),
          Text(
            'Draf di bulan yang akan ditutup menghalangi tutup buku seluruh '
            'Jemaat.',
            style: ket,
          ),
        ]),
        BarisTombol(
          anak: [
            Tombol(
              'Pindah tanggal ke November',
              jenis: JenisTombol.tinta,
              onPressed: () => _set(() {
                v = 'alasan';
                pesan = '';
                alasan.clear();
              }),
            ),
          ],
        ),
      ] else ...[
        _kartu([
          const KepalaKartu(
            judul: 'Pindah tanggal · Konsumsi ibadah Kolom',
            ujung: _draf,
          ),
          const _BarisInfo('Tanggal transaksi baru', '02/11/2026'),
          Text(
            'Hanya bulan yang Belum ditutup. Draf tetap Draf; tidak ada yang '
            'dibukukan.',
            style: ket,
          ),
        ]),
        IsianAlur(
          label: 'Alasan · wajib',
          controller: alasan,
          baris: 3,
          onChanged: (_) => setState(() {}),
        ),
        // The board's "Pindah tanggal" refusal (`al && !al`) never shows.
        BarisTombol(
          anak: [
            TombolBersyarat(
              label: 'Pindah tanggal',
              tindakan: 'Pindah tanggal',
              alasan: _sebab2,
              periksa: () => _sebab2,
              sudahMulai: false,
              onPressed: _pindah,
            ),
            Tombol(
              'Kembali',
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.kecil,
              onPressed: () => _set(() {
                v = 'utama';
                pesan = '';
              }),
            ),
          ],
        ),
      ],
      if (riw.isNotEmpty) RiwayatAlur(baris: List.of(riw)),
    ];
  }

  static Widget _kolom(List<Widget> anak, double jarak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) SizedBox(height: jarak),
        anak[i],
      ],
    ],
  );
}

/// Blocks with a [jarak] gap between them (the boards' column `gap`).
// ponytail: letterSpacing 0 stops TextField taking the M3 bodyLarge 0.5
// spacing (the theme merges Typography defaults); drop once lib/theme sets it.
Widget kolomAlurUnit(List<Widget> anak, double jarak) => DefaultTextStyle.merge(
  style: const TextStyle(letterSpacing: 0),
  child: AlurUnitLogika._kolom(anak, jarak),
);

/// KitAlur's info row, but sized like the boards' flex row: both spans start
/// at their one-line width and, when they do not fit, shrink in proportion to
/// it (CSS `flex-shrink: 1`), so a long value also wraps the label
/// ('Dicatat oleh' on the phone). The shared BarisInfo never wraps the label.
class _BarisInfo extends StatelessWidget {
  const _BarisInfo(
    this.label,
    this.nilai, {
    this.mono = false,
    this.berat = FontWeight.w600,
  });

  final String label, nilai;
  final bool mono;
  final FontWeight berat;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 14));
    final gl = dasar.copyWith(color: c.tinta2);
    final gn = dasar.copyWith(
      color: c.tinta,
      fontWeight: berat,
      fontFamily: mono ? PalakatText.mono : null,
    );
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, TextStyle g) {
      final p = TextPainter(
        text: TextSpan(text: t, style: g),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = p.width;
      p.dispose();
      return w;
    }

    return LayoutBuilder(
      builder: (context, k) {
        final ruang = k.maxWidth - 16;
        final l = lebar(label, gl), n = lebar(nilai, gn);
        final lebih = l + n - ruang;
        final lebarLabel = lebih <= 0
            ? l
            : math.max(
                // min-content: the longest word.
                label.split(' ').map((w) => lebar(w, gl)).reduce(math.max),
                l - lebih * l / (l + n),
              );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: lebarLabel.ceilToDouble(),
              child: Text(label, style: gl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(nilai, textAlign: TextAlign.right, style: gn),
            ),
          ],
        );
      },
    );
  }
}
