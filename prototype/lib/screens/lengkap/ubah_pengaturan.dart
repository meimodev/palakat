import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

/// The board's logic class (shared with WebUbahPengaturan; each screen owns
/// its own instance). Initial state as on the board.
class DataUbahPengaturan {
  String tab = 'kas', jenis = 'Bank', nama = '', akhir = '';
  String mulai = 'Desember 2026', awalan = 'BKU', batas = '3000000';
  int digit = 4;

  /// Saved entry text per tab, in the order first saved (a Dart map literal
  /// keeps insertion order, and replacing a key keeps its place).
  final Map<String, String> jadi = {};

  int get _batas => int.tryParse(batas) ?? 0;

  bool get ok => switch (tab) {
    'kas' => nama.trim().isNotEmpty && (jenis == 'Kas' || akhir.length == 4),
    'seri' => RegExp(r'^[A-Z]{2,4}$').hasMatch(awalan),
    _ => _batas > 0,
  };

  /// Rule A02: a field of the open tab differs from its start value.
  bool get sudahMulai => switch (tab) {
    'kas' => nama.isNotEmpty || akhir.isNotEmpty,
    'seri' => awalan != 'BKU',
    _ => batas != '3000000',
  };

  /// The first unmet field of the open tab, as named on the board.
  String get alasan => ok
      ? ''
      : '${switch (tab) {
          'kas' when nama.trim().isEmpty => jenis == 'Kas' ? 'Tempat atau pemegang' : 'Nama bank',
          'kas' => 'Empat angka akhir No. rekening',
          'seri' => 'Awalan seri Biasa',
          _ => 'Wajib untuk Belanja mulai dari',
        }} belum diisi.';

  String get contoh => '$awalan-2027-${'0' * (digit - 1)}1';

  String get teks => switch (tab) {
    'kas' =>
      '${jenis == 'Kas' ? 'Kas ${nama.trim()}' : 'Bank ${nama.trim()} ··$akhir'} · berlaku mulai $mulai · belum dapat dipakai untuk transaksi sebelum itu',
    'seri' =>
      'Seri Biasa menjadi $contoh · berlaku mulai Januari 2027 · nomor yang sudah diberikan tidak berubah',
    _ =>
      'Persetujuan wajib untuk Belanja ${rp(_batas)} ke atas · berlaku mulai $mulai · transaksi sebelumnya tetap memakai Rp2.000.000',
  };

  void simpan() {
    if (ok) jadi[tab] = teks;
  }
}

const _tabs = [
  (nilai: 'kas', teks: 'Tambah Kas/Bank'),
  (nilai: 'seri', teks: 'Seri No. Bukti'),
  (nilai: 'aturan', teks: 'Aturan persetujuan'),
];

/// The parts both boards place in their own layout.
typedef BagianUbahPengaturan = ({
  Widget tab,
  Widget isi,
  Widget tombol,
  Widget judul,
  List<Widget> jadi,
  Widget catatan,
});

/// Holds the state and the fields; [tata] lays the parts out per board.
class IsiUbahPengaturan extends StatefulWidget {
  const IsiUbahPengaturan({super.key, required this.web, required this.tata});

  final bool web;
  final Widget Function(BagianUbahPengaturan b) tata;

  @override
  State<IsiUbahPengaturan> createState() => _IsiUbahPengaturanState();
}

class _IsiUbahPengaturanState extends State<IsiUbahPengaturan> {
  final d = DataUbahPengaturan();
  late final _nama = TextEditingController(text: d.nama);
  late final _akhir = TextEditingController(text: d.akhir);
  late final _awalan = TextEditingController(text: d.awalan);
  late final _batas = TextEditingController(text: titik(d.batas));
  final _fokusAkhir = FocusNode();
  final _fokusAwalan = FocusNode();

  @override
  void dispose() {
    for (final k in [_nama, _akhir, _awalan, _batas]) {
      k.dispose();
    }
    _fokusAkhir.dispose();
    _fokusAwalan.dispose();
    super.dispose();
  }

  void _ubah(VoidCallback f) => setState(f);

  void _onBatas(String v) => _ubah(() => d.batas = hanyaAngka(v, max: 10));

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final label = TextStyle(fontSize: 14, color: c.tinta2);
    const mono = TextStyle(fontFamily: PalakatText.mono);

    Widget pilih<T>(
      String judul,
      List<({T nilai, String teks})> p,
      T nilai,
      ValueChanged<T> f,
    ) => ChipPilihan<T>(
      label: judul,
      pilihan: p,
      terpilih: nilai,
      onPilih: (v) => _ubah(() => f(v)),
    );

    final mulai = pilih(
      'Berlaku mulai',
      const [
        (nilai: 'Desember 2026', teks: 'Desember 2026'),
        (nilai: 'Januari 2027', teks: 'Januari 2027'),
      ],
      d.mulai,
      (v) => d.mulai = v,
    );

    // `<label for>`: tapping the label focuses its field.
    Widget sempit(String judul, FocusNode fokus, Widget isian) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: fokus.requestFocus,
          // The field carries the label; no separate small tap node.
          excludeFromSemantics: true,
          child: Text(judul, style: label),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: isian,
        ),
      ],
    );

    Widget kini(Widget nilai) => Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sekarang, sejak September 2026', style: label),
          nilai,
        ],
      ),
    );

    final isi = switch (d.tab) {
      'kas' => [
        pilih(
          'Jenis',
          const [(nilai: 'Kas', teks: 'Kas'), (nilai: 'Bank', teks: 'Bank')],
          d.jenis,
          (v) => d.jenis = v,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IsianTeks(
              controller: _nama,
              label: d.jenis == 'Kas' ? 'Tempat atau pemegang' : 'Nama bank',
              jarakLabel: 6,
              petunjuk: d.jenis == 'Kas'
                  ? 'Misalnya: Panitia Natal'
                  : 'Misalnya: Mandiri',
              onChanged: (v) => _ubah(() => d.nama = v),
            ),
            const SizedBox(height: 4),
            Text(
              'Jangan memakai nama peruntukan atau Lingkup.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
        if (d.jenis == 'Bank')
          sempit(
            'Empat angka akhir No. rekening',
            _fokusAkhir,
            IsianTeks(
              controller: _akhir,
              focusNode: _fokusAkhir,
              labelSemantik: 'Empat angka akhir No. rekening',
              gaya: mono,
              keyboardType: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              onChanged: (v) => _ubah(() => d.akhir = v),
            ),
          ),
        mulai,
      ],
      'seri' => [
        kini(
          const Text(
            'BKU-2026-0151',
            style: TextStyle(
              fontFamily: PalakatText.mono,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        sempit(
          'Awalan seri Biasa · 2 sampai 4 huruf',
          _fokusAwalan,
          IsianTeks(
            controller: _awalan,
            focusNode: _fokusAwalan,
            labelSemantik: 'Awalan seri Biasa · 2 sampai 4 huruf',
            gaya: mono,
            formatters: const [_FormatAwalan()],
            onChanged: (v) => _ubah(() => d.awalan = v),
          ),
        ),
        pilih(
          'Jumlah angka',
          const [(nilai: 4, teks: '4 angka'), (nilai: 5, teks: '5 angka')],
          d.digit,
          (v) => d.digit = v,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nomor pertama tahun 2027', style: label),
            Text(
              d.contoh,
              style: const TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Satu seri Biasa per tahun kalender. Seri OPN dan ADJ tetap. Nomor selalu dibuat aplikasi.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
      ],
      _ => [
        kini(
          const Text(
            'Persetujuan wajib untuk Belanja Rp2.000.000 ke atas',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        _IsianBatas(controller: _batas, onChanged: _onBatas),
        mulai,
      ],
    };

    final tab = widget.web
        ? Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _tabs)
                ChipSatu(
                  teks: t.teks,
                  dipilih: d.tab == t.nilai,
                  onTap: () => _ubah(() => d.tab = t.nilai),
                ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in _tabs)
                  _ChipTab(
                    teks: t.teks,
                    dipilih: d.tab == t.nilai,
                    onTap: () => _ubah(() => d.tab = t.nilai),
                  ),
              ],
            ),
          );

    return widget.tata((
      tab: tab,
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < isi.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            isi[i],
          ],
        ],
      ),
      tombol: TombolBersyarat(
        label: 'Simpan sebagai versi baru',
        tindakan: 'Simpan sebagai versi baru',
        alasan: d.alasan,
        periksa: () => d.alasan,
        onPressed: () => _ubah(d.simpan),
        sudahMulai: d.sudahMulai,
        warnaSiap: JenisTombol.utama,
        teksBelumRedup: true,
        paddingH: 20,
      ),
      judul: const JudulBagian('Perubahan yang menunggu berlaku'),
      jadi: [
        for (final e in d.jadi.entries)
          Gerak(
            Kerangka.muncul,
            // Keyed by tab: replacing the text does not play it again.
            key: ValueKey(e.key),
            lama: const Duration(milliseconds: 300),
            child: Kartu(
              status: GarisStatus.draf,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                e.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
      catatan: Text(
        'Pengaturan tidak diubah di tempat. Versi lama tetap berlaku untuk bulan-bulan sebelumnya dan tidak mengubah transaksi yang sudah dibukukan. Yang sudah dipakai hanya dapat dinonaktifkan.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ));
  }
}

/// Prefix: upper case, letters A–Z only, at most 4 ("gk1a" → "GKA").
class _FormatAwalan extends TextInputFormatter {
  const _FormatAwalan();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var t = newValue.text.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    if (t.length > 4) t = t.substring(0, 4);
    if (t == newValue.text) return newValue;
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

/// The approval threshold: IsianJumlah's 26 px look, but at most 10 digits
/// and the figure centred in its 44 px box as the board's input is
/// (IsianJumlah sets `maks` 11 and draws the figure at the box top).
class _IsianBatas extends StatefulWidget {
  const _IsianBatas({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<_IsianBatas> createState() => _IsianBatasState();
}

class _IsianBatasState extends State<_IsianBatas> {
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(_ubah);
  }

  void _ubah() => setState(() {});

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final angka = dasar.copyWith(
      fontFamily: PalakatText.mono,
      fontSize: 26,
      fontWeight: FontWeight.w500,
    );
    const label = 'Wajib untuk Belanja mulai dari';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // An inline <label>: it sits on the parent's 16 px line box.
        ExcludeSemantics(
          child: GestureDetector(
            onTap: _fokus.requestFocus,
            child: Text(
              label,
              strutStyle: StrutStyle.fromTextStyle(dasar),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Container(
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
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: 18,
                      color: c.tinta3,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Semantics(
                    label: label,
                    child: CincinFokus(
                      tampil: _fokus.hasFocus,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          heightFactor: 1,
                          child: Material(
                            type: MaterialType.transparency,
                            child: TextField(
                              controller: widget.controller,
                              focusNode: _fokus,
                              onChanged: widget.onChanged,
                              keyboardType: TextInputType.number,
                              inputFormatters: const [
                                RupiahInputFormatter(maks: 10),
                              ],
                              style: angka,
                              cursorColor: c.laut,
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The phone's smaller tab chip: 13/600, padding 0 12 (ChipSatu is fixed
/// at 14 / 0 14).
class _ChipTab extends StatelessWidget {
  const _ChipTab({
    required this.teks,
    required this.dipilih,
    required this.onTap,
  });

  final String teks;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: 22,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih ? c.tinta : c.garisTegas,
            radius: PalakatRadius.chip,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              teks,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dipilih ? c.permukaan : c.tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UbahPengaturanScreen extends StatelessWidget {
  const UbahPengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: IsiUbahPengaturan(
      web: false,
      tata: (b) {
        final isi = [b.isi, b.tombol, b.judul, ...b.jadi, b.catatan];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Ubah pengaturan',
              anakJudul: 'Selalu sebagai versi baru',
              kembaliKe: Layar.pengaturan,
              labelKembali: 'Kembali ke Lainnya',
            ),
            b.tab,
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < isi.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      isi[i],
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
