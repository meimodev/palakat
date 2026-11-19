import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/kendali.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// One part of the offering: name, digits typed, owner, Kas/Bank ('' = none).
class _Bagian {
  _Bagian(this.id, this.n, this.v, this.milik, this.akun);
  final String id, n;
  String v, milik, akun;
}

const _petugasSemua = ['Dkn. Olga Tamba', 'Pnt. Jefry Wowor', 'Meiske L.'];
const _contohSampul = [('Novita Wenas', 100000), ('Agustina Lasut', 250000)];
const _milikPilihan = [
  (nilai: 'sendiri', teks: 'Milik sendiri'),
  (nilai: 'titipan', teks: 'Titipan untuk: Sinode'),
];
const _akunPilihan = [
  (nilai: 'kas', teks: 'Kas'),
  (nilai: 'bni', teks: 'Bank BNI ··4821'),
  (nilai: 'bsg', teks: 'Bank SulutGo ··1107'),
];

/// The board's state object, held above both routes (navigation.md 2.1).
class _Keadaan extends ChangeNotifier {
  _Keadaan() {
    _awal();
  }

  late bool posted;
  late List<String> petugas;
  late List<_Bagian> bagian;
  late List<(String, int)> sampul;

  void _awal() {
    posted = false;
    petugas = ['Dkn. Olga Tamba'];
    bagian = [
      _Bagian('tunai', 'Tunai', '2350000', 'sendiri', 'kas'),
      _Bagian('qris', 'QRIS', '800000', 'sendiri', ''),
      _Bagian('tf', 'Transfer bank', '450000', 'titipan', 'bni'),
    ];
    sampul = [];
  }

  void ulang() {
    _awal();
    notifyListeners();
  }

  void ubah(VoidCallback f) {
    f();
    notifyListeners();
  }

  static int _num(String d) => d.isEmpty ? 0 : int.parse(d);
  int _jumlah(String m) =>
      bagian.where((b) => b.milik == m).fold(0, (a, b) => a + _num(b.v));
  int get sendiri => _jumlah('sendiri');
  int get titipan => _jumlah('titipan');
  int get total => sendiri + titipan;
  int get bagianN => bagian.where((b) => _num(b.v) > 0).length;
  int get tunaiKas =>
      bagian.where((b) => b.akun == 'kas').fold(0, (a, b) => a + _num(b.v));
  bool get sampulLebih => sampul.fold(0, (a, x) => a + x.$2) > total;

  /// First unmet reason, '' when "Periksa dan bukukan" may run.
  String get alasan {
    if (total == 0) return 'semua bagian masih kosong.';
    for (final b in bagian) {
      if (_num(b.v) > 0 && b.akun.isEmpty) {
        return 'Kas/Bank untuk bagian ${b.n} belum dipilih.';
      }
    }
    if (petugas.isEmpty) return 'petugas penghitung belum dipilih.';
    return '';
  }
}

class _Lingkup extends InheritedNotifier<_Keadaan> {
  const _Lingkup({required _Keadaan keadaan, required super.child})
    : super(notifier: keadaan);
  static _Keadaan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

class PersembahanKendali extends StatefulWidget {
  const PersembahanKendali({super.key, required this.child});
  final Widget child;
  @override
  State<PersembahanKendali> createState() => _PersembahanKendaliState();
}

class _PersembahanKendaliState extends State<PersembahanKendali> {
  final _keadaan = _Keadaan();
  int _generasi = 0;

  @override
  void initState() {
    super.initState();
    ulangPapan['Persembahan'] = _ulang;
  }

  void _ulang() {
    if (!mounted) return;
    _keadaan.ulang();
    setState(() => _generasi++);
  }

  @override
  void dispose() {
    if (ulangPapan['Persembahan'] == _ulang) ulangPapan.remove('Persembahan');
    _keadaan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    keadaan: _keadaan,
    child: GenerasiPapan(
      generasi: _generasi,
      child: LayarPonsel(
        jabatanKosong: true,
        child: Material(type: MaterialType.transparency, child: widget.child),
      ),
    ),
  );
}

/// 10 · Persembahan dengan beberapa bagian (04-lainnya.md). `/Persembahan`
/// is the form (Isi), `/Persembahan/hasil` the posted result (Hasil).
class PersembahanScreen extends StatelessWidget {
  const PersembahanScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) {
    final k = _Lingkup.of(context);
    // The board has no way back from Hasil to Isi (`isIsi` is `!posted`).
    final hasil = anak == 'hasil' || k.posted;
    return ColoredBox(
      color: context.warna.kertas,
      child: hasil
          ? const _Hasil()
          : Gerak(
              Kerangka.pudar,
              lama: const Duration(milliseconds: 200),
              child: _Isi(k),
            ),
    );
  }
}

class _Isi extends StatefulWidget {
  const _Isi(this.k);
  final _Keadaan k;
  @override
  State<_Isi> createState() => _IsiState();
}

class _IsiState extends State<_Isi> {
  late final _isian = [
    for (final b in widget.k.bagian) TextEditingController(text: titik(b.v)),
  ];
  late final _fokus = [for (final _ in widget.k.bagian) FocusNode()];

  @override
  void dispose() {
    for (final c in _isian) {
      c.dispose();
    }
    for (final f in _fokus) {
      f.dispose();
    }
    super.dispose();
  }

  void _bukukan() {
    widget.k.ubah(() => widget.k.posted = true);
    // Back from Hasil leaves the board, not to an editable form.
    GoRouter.of(context).replace('/Persembahan/hasil');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    final ket13 = TextStyle(fontSize: 13, color: c.tinta2);
    final mono = TextStyle(fontFamily: PalakatText.mono, color: c.tinta2);

    Widget pilihan(
      String label,
      List<({String nilai, String teks})> daftar,
      String terpilih,
      double radius,
      ValueChanged<String> onPilih,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label, style: ket13),
        ),
        Wrap(
          children: [
            for (final p in daftar)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _Chip(
                  p.teks,
                  dipilih: p.nilai == terpilih,
                  radius: radius,
                  onTap: () => onPilih(p.nilai),
                ),
              ),
          ],
        ),
      ],
    );

    final isi = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jumlah (Rp) · semua bagian',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          Text(
            rp(k.total),
            style: const TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 36,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
              height: 1.15,
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Milik sendiri '),
                TextSpan(text: rp(k.sendiri), style: mono),
                const TextSpan(text: ' · Titipan '),
                TextSpan(text: rp(k.titipan), style: mono),
              ],
            ),
            style: ket13,
          ),
        ],
      ),
      for (var i = 0; i < k.bagian.length; i++)
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _fokus[i].requestFocus,
                      child: ExcludeSemantics(
                        child: Text(
                          k.bagian[i].n,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _IsianBagian(
                    label: k.bagian[i].n,
                    controller: _isian[i],
                    fokus: _fokus[i],
                    onChanged: (t) => k.ubah(
                      () => k.bagian[i].v = hanyaAngka(t, simpanNol: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              pilihan(
                'Uang siapa',
                _milikPilihan,
                k.bagian[i].milik,
                10,
                (v) => k.ubah(() => k.bagian[i].milik = v),
              ),
              const SizedBox(height: 10),
              pilihan(
                'Masuk ke Kas/Bank',
                _akunPilihan,
                k.bagian[i].akun,
                PalakatRadius.chip,
                (v) => k.ubah(() => k.bagian[i].akun = v),
              ),
              const SizedBox(height: 10),
              Text(
                k.bagian[i].milik == 'sendiri'
                    ? 'Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu'
                    : 'Pendapatan 2.1.01.02.00 DANA TRANSIT Sentralisasi Sinode',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        ),
      _Sampul(k),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Petugas penghitung',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
          Wrap(
            children: [
              for (final o in _petugasSemua)
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: ChipSatu(
                    teks: o,
                    dipilih: k.petugas.contains(o),
                    onTap: () => k.ubah(
                      () => k.petugas.contains(o)
                          ? k.petugas.remove(o)
                          : k.petugas.add(o),
                    ),
                  ),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: c.permukaan,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.garisTegas),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'lembar-penghitungan-15-11.jpg · Terlampir',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Lembar penghitungan persembahan · Diunggah, belum diverifikasi',
                  style: ket13,
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Persembahan',
          anakJudul: 'Ibadah Minggu · 15 November 2026',
          kembaliKe: 'Main',
          labelKembali: 'Kembali ke Beranda',
        ),
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
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border(top: BorderSide(color: c.garis)),
          ),
          child: TombolBersyarat(
            label: 'Periksa dan bukukan',
            tindakan: 'Periksa dan bukukan',
            alasan: k.alasan,
            periksa: () => k.alasan,
            warnaSiap: JenisTombol.utama,
            teksBelumRedup: true,
            gayaAlasan: GayaAlasan.kalimatBata,
            onPressed: _bukukan,
          ),
        ),
      ],
    );
  }
}

/// Owner and Kas/Bank chips: min 44, padding 0 12, 1.5 line, 13/600.
class _Chip extends StatelessWidget {
  const _Chip(
    this.teks, {
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
      radius: radius,
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

/// "Sampul bernama": named envelopes inside the total.
class _Sampul extends StatelessWidget {
  const _Sampul(this.k);
  final _Keadaan k;
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final anak = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sampul bernama',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(
            'Bagian dari jumlah di atas; tidak menambah total. Nama hanya dilihat pemberinya dan Bendahara Jemaat.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
      for (var i = 0; i < k.sampul.length; i++)
        Container(
          padding: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.garis)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  k.sampul[i].$1,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                rp(k.sampul[i].$2),
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              Tekan(
                onTap: () => k.ubah(() => k.sampul.removeAt(i)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Text(
                      'Lepas nama',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.laut,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      if (k.sampulLebih)
        const Penolakan(
          tindakan: 'Periksa dan bukukan',
          sebab: 'Jumlah sampul bernama melebihi jumlah persembahan.',
          jalan: [],
          ukuranTeks: 14,
        ),
      Wrap(
        spacing: 16,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (k.sampul.length < 2)
            Tekan(
              radius: 14,
              // By count, as the board does: after "Lepas nama" on the first,
              // the next press adds the second sample again.
              onTap: () =>
                  k.ubah(() => k.sampul.add(_contohSampul[k.sampul.length])),
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
            ke: 'PersembahanBernama',
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: TautanTeks(
                'Aturan nama pemberi',
                berat: FontWeight.w700,
                ukuran: 14,
              ),
            ),
          ),
        ],
      ),
    ];
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            anak[i],
          ],
        ],
      ),
    );
  }
}

/// Hasil: "Sudah dibukukan", with the `tinta` sequence.
class _Hasil extends StatelessWidget {
  const _Hasil();
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    const muncul = Duration(milliseconds: 300);
    final ket13 = TextStyle(fontSize: 13, color: c.tinta3);
    const jumlah = TextStyle(
      fontFamily: PalakatText.mono,
      fontWeight: FontWeight.w500,
    );

    Widget baris(String judul, String sub, String nilai) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(sub, style: ket13),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(nilai, style: jumlah),
        ],
      ),
    );

    final kartuBuku = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Kartu(
            status: GarisStatus.terpilih,
            radius: 16,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LencanaStatus.uang(StatusUang.dibukukan, kepala: true),
                    Flexible(
                      child: Gerak(
                        Kerangka.cap,
                        lama: const Duration(milliseconds: 550),
                        tunda: const Duration(milliseconds: 350),
                        kurva: PalakatMotion.keluar,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: c.laut, width: 2),
                          ),
                          child: Text(
                            'No. Bukti BKU-2026-0148',
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontFamily: PalakatText.mono,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: c.laut,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(rp(k.total), style: jumlah.copyWith(fontSize: 30)),
                const SizedBox(height: 6),
                const Text(
                  'Persembahan Ibadah Minggu',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SapuTinta(),
        ],
      ),
    );

    final isi = <Widget>[
      kartuBuku,
      Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gerak(
              Kerangka.muncul,
              lama: muncul,
              tunda: const Duration(milliseconds: 500),
              child: baris(
                'Pendapatan bulan ini',
                'Bagian milik sendiri',
                '+ ${rp(k.sendiri)}',
              ),
            ),
            Gerak(
              Kerangka.muncul,
              lama: muncul,
              tunda: const Duration(milliseconds: 700),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: c.garis)),
                ),
                child: baris(
                  'Titipan untuk: Sinode',
                  'Uang titipan untuk pihak lain, bukan Pendapatan',
                  '+ ${rp(k.titipan)}',
                ),
              ),
            ),
          ],
        ),
      ),
      Gerak(
        Kerangka.muncul,
        lama: muncul,
        tunda: const Duration(milliseconds: 900),
        child: Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${rp(k.tunaiKas)} tunai sekarang ada di Kas.',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(
                      text: ' Bila disetor, catat sebagai Pindah antar Kas/Bank. Setoran ke bank bukan Pendapatan baru.',
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Tombol(
                'Catat setoran ke bank',
                onPressed: null,
                ke: 'Main',
                cara: Cara.ganti,
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.kecil,
              ),
            ],
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: const Text(
                  'Sudah dibukukan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Satu persembahan, satu No. Bukti, ${k.bagianN} bagian.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
  }
}

/// A part's amount field: 160 wide on a 1.5 `tinta` underline, "Rp" 14
/// `tinta3` and the mono 18/500 figure right-aligned on one baseline, the
/// typed text centred in its 44 px input box (board `min-height: 44px`).
// ponytail: IsianJumlah(ukuran: baris) draws the figure at the top of its
// 44 px box; use it again once that is fixed (sharedNeeds).
class _IsianBagian extends StatelessWidget {
  const _IsianBagian({
    required this.label,
    required this.controller,
    required this.fokus,
    required this.onChanged,
  });
  final String label;
  final TextEditingController controller;
  final FocusNode fokus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final gaya = DefaultTextStyle.of(context).style.copyWith(
      fontFamily: PalakatText.mono,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );
    return Container(
      width: 160,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.tinta, width: 1.5)),
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
                fontSize: 14,
                color: c.tinta3,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ListenableBuilder(
              listenable: fokus,
              builder: (context, _) => CincinFokus(
                tampil: fokus.hasFocus,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: fokus.requestFocus,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Center(
                      heightFactor: 1,
                      child: Semantics(
                        label: label,
                        child: TextField(
                          controller: controller,
                          focusNode: fokus,
                          onChanged: onChanged,
                          keyboardType: TextInputType.number,
                          inputFormatters: const [
                            RupiahInputFormatter(sisakanNol: true),
                          ],
                          textAlign: TextAlign.right,
                          style: gaya,
                          cursorColor: c.laut,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: '—',
                            hintStyle: gaya.copyWith(color: c.tinta3),
                          ),
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
    );
  }
}
