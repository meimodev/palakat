import 'package:flutter/widgets.dart';

import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/alur_kit.dart' show KepalaKartu;
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// The `keadaan` options of BukaNama and WebBukaNama, in board order.
const _opsi = [
  'Mengisi alasan',
  'Alasan belum diisi',
  'Tercatat',
  'Bukan Sekretaris Jemaat',
];

const _alasan =
    'Persembahan khusus pembangunan diumumkan atas keputusan Sidang Majelis '
    'Jemaat 08/11/2026.';

/// The board body of BukaNama ([web] false: the phone scroll column) and
/// WebBukaNama ([web] true: the max-1120 container). Holds the board state
/// `{ k: null }`; a change of the `keadaan` tweak resets it.
class BukaNamaPapan extends StatefulWidget {
  const BukaNamaPapan({
    super.key,
    required this.stem,
    required this.ke,
    this.param = const {},
    this.anak,
    required this.web,
  });

  /// Board whose tweak is read.
  final String stem;

  /// Up link of "Batalkan" and "Kembali".
  final Layar ke;
  final Map<String, String> param;
  final String? anak;
  final bool web;

  @override
  State<BukaNamaPapan> createState() => _BukaNamaPapanState();
}

class _BukaNamaPapanState extends State<BukaNamaPapan> {
  String? _k;
  String? _tweak;

  Widget _kolom(double jarak, List<Widget> anak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) SizedBox(height: jarak),
        anak[i],
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final t = belumDipindah<String>('Mengisi alasan');
    if (t != _tweak) {
      _tweak = t;
      _k = null;
    }
    final ki = _opsi.indexOf(_k ?? t).clamp(0, 3);
    final form = ki < 2;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);

    final ringkasan = Kartu(
      child: _kolom(6, [
        const _BarisInfo('Edisi', 'Warta Jemaat 22/11/2026'),
        const _BarisInfo('Pilihan anggota', 'Tanpa nama'),
        const _BarisInfo('Akan diterbitkan sebagai', 'Kel. Mamahit — Kolom 4'),
        Text(
          'Tampilan nama pilihan anggota wajib diikuti. Pengecualian hanya '
          'untuk keperluan resmi, tata kelola, hukum atau '
          'pertanggungjawaban.',
          style: kecil,
        ),
      ]),
    );

    final isian = IsianTeks(
      key: ValueKey(ki),
      nilaiAwal: ki == 0 ? _alasan : '',
      label: 'Alasan · wajib',
      jarakLabel: 6,
      // letterSpacing 0: TextField otherwise keeps the M3 bodyLarge 0.5.
      gaya: TextStyle(fontSize: 14, color: c.tinta2, letterSpacing: 0),
      baris: 3,
      hanyaBaca: true,
    );

    final batalkan = Tombol(
      'Batalkan',
      onPressed: null,
      jenis: JenisTombol.teks,
      ke: widget.ke,
      param: widget.param,
      anak: widget.anak,
      cara: Cara.naik,
    );

    // The board's button row: `<button>` is border-box (basis 150, max 340),
    // `<a>` content-box, so its 0 16 padding comes on top (182, max 372).
    final tombol = BarisLentur(
      jarak: 8,
      rata: CrossAxisAlignment.center,
      anak: [
        if (ki == 0)
          Lentur(
            dasar: 150,
            maks: 340,
            child: Tombol(
              'Catat pengecualian',
              onPressed: () => setState(() => _k = 'Tercatat'),
              jenis: JenisTombol.tinta,
            ),
          )
        else
          // The board's `disabled` button: `garis` field, `tinta2` text,
          // neither pressable nor focusable.
          Lentur(
            dasar: 150,
            maks: 340,
            child: Semantics(
              button: true,
              enabled: false,
              child: RupaTombol(
                label: 'Catat pengecualian',
                isi: c.garis,
                warnaTeks: c.tinta2,
                radius: 14,
                tinggi: 52,
                paddingH: 16,
              ),
            ),
          ),
        Lentur(dasar: 182, maks: 372, child: batalkan),
      ],
    );

    final isiForm = [
      isian,
      tombol,
      if (ki == 1)
        Text('Tidak dapat dilakukan: alasan belum diisi.', style: kecil),
    ];

    final tercatat = [
      Kartu(
        child: _kolom(6, [
          const KepalaKartu(
            judul: 'Pengecualian tampilan nama',
            ujung: LencanaStatus('Tercatat', bentuk: BentukLencana.tinta),
          ),
          const _BarisInfo('Pilihan anggota', 'Tanpa nama'),
          const _BarisInfo('Diterbitkan sebagai', 'Kel. Mamahit — Kolom 4'),
          const _BarisInfo('Edisi', 'Warta Jemaat 22/11/2026'),
          Text(
            'Alasan: persembahan khusus pembangunan diumumkan atas keputusan '
            'Sidang Majelis Jemaat 08/11/2026.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          Text(
            'Oleh Olvie Pangemanan, Sekretaris Jemaat · 20/11/2026 13.50 · '
            'anggota sudah diberi tahu.',
            style: kecil,
          ),
        ]),
      ),
      Text(
        'Pilihan anggota di Data jemaat tidak berubah. Edisi berikutnya '
        'kembali memakai “Tanpa nama”.',
        style: kecil,
      ),
    ];

    final penolakan = Penolakan(
      tindakan: 'Tampilkan nama',
      sebab:
          'hanya Sekretaris Jemaat yang dapat mencatat pengecualian tampilan '
          'nama.',
      jalan: const [],
    );

    // "Kembali" is an `<a>`: content-box, so 48 + the 1.5 line twice, and
    // basis 182 / max 372 (it fills the 350 phone column).
    final kembali = BarisLentur(
      jarak: 8,
      anak: [
        Lentur(
          dasar: 182,
          maks: 372,
          child: Tautan(
            ke: widget.ke,
            param: widget.param,
            anak: widget.anak,
            cara: Cara.naik,
            radius: 14,
            child: RupaTombol(
              label: 'Kembali',
              isi: c.permukaan,
              garis: GarisBorder.penuh(c.tinta, radius: 14),
              warnaTeks: c.tinta,
              radius: 14,
              tinggi: 51,
              paddingH: 16,
            ),
          ),
        ),
      ],
    );

    final bawah = [
      if (ki == 2) ...tercatat,
      if (ki == 3) ...[penolakan, kembali],
    ];

    if (!widget.web) {
      return _kolom(16, [
        if (form) ...[ringkasan, ...isiForm],
        ...bawah,
      ]);
    }

    // The two-column row stays in the container (zero high) in k2 and k3.
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: _kolom(16, [
          BarisLentur(
            jarak: 28,
            jarakBaris: 20,
            anak: [
              Lentur(
                dasar: 420,
                tumbuh: 1.3,
                child: form ? ringkasan : const SizedBox.shrink(),
              ),
              Lentur(
                dasar: 340,
                child: form ? _kolom(12, isiForm) : const SizedBox.shrink(),
              ),
            ],
          ),
          ...bawah,
        ]),
      ),
    );
  }
}

/// Key–value row (BarisInfo's look) with the board's CSS flex-shrink: when
/// label and value do not fit side by side, both wrap, each shrinking in
/// proportion to its width ("Akan diterbitkan / sebagai" at 390).
class _BarisInfo extends StatelessWidget {
  const _BarisInfo(this.label, this.nilai);

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 14));
    final gayaLabel = dasar.copyWith(color: c.tinta2);
    final gayaNilai = dasar.copyWith(
      color: c.tinta,
      fontWeight: FontWeight.w600,
    );
    int lebar(String t, TextStyle g) {
      final p = TextPainter(
        text: TextSpan(text: t, style: g),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final w = p.width.ceil();
      p.dispose();
      return w;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: lebar(label, gayaLabel),
          child: Text(label, style: gayaLabel),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: lebar(nilai, gayaNilai),
          child: Text(nilai, textAlign: TextAlign.right, style: gayaNilai),
        ),
      ],
    );
  }
}
