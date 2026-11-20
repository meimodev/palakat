import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
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
import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../providers/keuangan/persembahan.dart';

/// One part of the offering: name, digits typed, owner, Kas/Bank ('' = none).
class _Bagian {
  _Bagian(this.id, this.n, this.v, this.milik, this.akun);
  final String id, n;
  String v, milik, akun;
}

/// The board's state object, held above both routes (navigation.md 2.1);
/// [p] gives the Kas/Bank, the Titipan case and the defaults.
class _Keadaan extends ChangeNotifier {
  _Keadaan(this.p) {
    _awal();
  }

  final PilihanPersembahan p;

  /// The voucher once Dibukukan; the saved draft and the last refusal.
  String? no, drafId;
  Refusal? pesan;
  late List<String> petugas;
  late List<_Bagian> bagian;

  bool get posted => no != null;

  void _awal() {
    no = null;
    drafId = null;
    pesan = null;
    petugas = p.petugas.take(1).toList();
    bagian = [
      _Bagian('tunai', 'Tunai', '2350000', 'sendiri', p.kas ?? ''),
      _Bagian('qris', 'QRIS', '800000', 'sendiri', ''),
      _Bagian(
        'tf',
        'Transfer bank',
        '450000',
        p.titipan == null ? 'sendiri' : 'titipan',
        p.titipan?.akun ?? '',
      ),
    ];
  }

  void ulang() {
    _awal();
    notifyListeners();
  }

  /// A saved draft locks the parts: book it, or leave.
  void ubah(VoidCallback f) {
    if (drafId != null && no == null) return;
    f();
    notifyListeners();
  }

  void simpan(String? id, String? voucher, Refusal? r) {
    drafId = id ?? drafId;
    no = voucher;
    pesan = r;
    notifyListeners();
  }

  List<({String nilai, String teks})> get milikPilihan => [
    (nilai: 'sendiri', teks: 'Milik sendiri'),
    if (p.titipan case final t?)
      (nilai: 'titipan', teks: 'Titipan untuk: ${t.pihak}'),
  ];

  static int _num(String d) => d.isEmpty ? 0 : int.parse(d);
  int _jumlah(String m) =>
      bagian.where((b) => b.milik == m).fold(0, (a, b) => a + _num(b.v));
  int get sendiri => _jumlah('sendiri');
  int get titipan => _jumlah('titipan');
  int get total => sendiri + titipan;
  int get bagianN => bagian.where((b) => _num(b.v) > 0).length;
  int get tunaiKas =>
      bagian.where((b) => b.akun == p.kas).fold(0, (a, b) => a + _num(b.v));

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

  List<BagianPersembahan> get untukBuku => [
    for (final b in bagian)
      (
        nama: b.n,
        jumlah: _num(b.v),
        titipan: b.milik == 'titipan',
        akun: b.akun,
      ),
  ];
}

class _Lingkup extends InheritedNotifier<_Keadaan> {
  const _Lingkup({required _Keadaan keadaan, required super.child})
    : super(notifier: keadaan);
  static _Keadaan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

class PersembahanKendali extends ConsumerStatefulWidget {
  const PersembahanKendali({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<PersembahanKendali> createState() => _PersembahanKendaliState();
}

class _PersembahanKendaliState extends ConsumerState<PersembahanKendali> {
  late final _keadaan = _Keadaan(ref.read(pilihanPersembahanProvider));

  @override
  void dispose() {
    _keadaan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    keadaan: _keadaan,
    // Material outside LayarPonsel: inside, its bodyMedium text style
    // would replace the phone's 16 / 1.4 body text.
    child: Material(
      type: MaterialType.transparency,
      child: LayarPonsel(layarKeuangan: true, child: widget.child),
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

class _Isi extends ConsumerStatefulWidget {
  const _Isi(this.k);
  final _Keadaan k;
  @override
  ConsumerState<_Isi> createState() => _IsiState();
}

class _IsiState extends ConsumerState<_Isi> {
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

  Future<void> _bukukan() async {
    final k = widget.k;
    final r = await bukukanPersembahan(
      ref,
      k.p,
      k.untukBuku,
      penghitung: k.petugas,
      drafId: k.drafId,
    );
    k.simpan(r.id, r.no, r.pesan);
    // Back from Hasil leaves the board, not to an editable form.
    if (r.no != null && mounted) {
      GoRouter.of(context).replace(Layar.persembahan.lokasi(anak: 'hasil'));
    }
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
                      // X03: the 44 px amount field is the target.
                      excludeFromSemantics: true,
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
                k.milikPilihan,
                k.bagian[i].milik,
                10,
                (v) => k.ubah(() => k.bagian[i].milik = v),
              ),
              const SizedBox(height: 10),
              pilihan(
                'Masuk ke Kas/Bank',
                [for (final a in k.p.kasBank) (nilai: a.id, teks: a.nama)],
                k.bagian[i].akun,
                PalakatRadius.chip,
                (v) => k.ubah(() => k.bagian[i].akun = v),
              ),
              const SizedBox(height: 10),
              Text(
                k.bagian[i].milik == 'sendiri' ? k.p.maSendiri : k.p.maTitipan,
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        ),
      const _Sampul(),
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
              for (final o in k.p.petugas)
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
                Text(
                  '${k.p.lembar} · Terlampir',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Lembar penghitungan persembahan · Diunggah, belum '
                  'diverifikasi',
                  style: ket13,
                ),
              ],
            ),
          ),
        ],
      ),
      if (k.pesan case final r?)
        Penolakan(
          tindakan: r.action,
          sebab:
              r.because +
              (r.whoCanAct == null
                  ? ''
                  : ' Yang perlu bertindak: ${r.whoCanAct}.'),
          jalan: const [],
          ukuranTeks: 14,
        ),
      if (k.drafId != null)
        Text(
          'Dicatat sebagai draf, belum masuk saldo.',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Persembahan',
          anakJudul: 'Ibadah Minggu · ${tglPanjang(k.p.minggu.awal)}',
          kembaliKe: Layar.keuangan,
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
  const _Sampul();
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
      Wrap(
        spacing: 16,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // The giver is recorded on PersembahanBernama, against Data
          // jemaat (J1); this screen books the parts only.
          Tautan(
            ke: Layar.persembahanBernama,
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
            ke: Layar.persembahanBernama,
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
      child: _BarisSusut(
        judul: (
          judul,
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        sub: (sub, ket13),
        nilai: (nilai, jumlah),
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
                            'No. Bukti ${k.no}',
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
                  'Titipan untuk: ${k.p.titipan?.pihak ?? ''}',
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
              // An `<a>`, content-box: min-height 44 plus the 1.5 line twice.
              Tautan(
                ke: Layar.keuangan,
                cara: Cara.ganti,
                radius: 12,
                child: RupaTombol(
                  label: 'Catat setoran ke bank',
                  isi: c.permukaan,
                  garis: GarisBorder.penuh(c.tinta, radius: 12),
                  warnaTeks: c.tinta,
                  radius: 12,
                  tinggi: 47,
                  paddingH: 0,
                ),
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

/// A Hasil row as the board's flex row (space-between, gap 12): both sides
/// keep their max-content width when they fit; otherwise both shrink in
/// proportion to it, neither below its longest word, so "+ Rp450.000"
/// breaks after "+" as on the board.
class _BarisSusut extends StatelessWidget {
  const _BarisSusut({
    required this.judul,
    required this.sub,
    required this.nilai,
  });
  final (String, TextStyle) judul, sub, nilai;

  @override
  Widget build(BuildContext context) {
    final dasar = DefaultTextStyle.of(context).style;
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, TextStyle g) {
      final tp = TextPainter(
        text: TextSpan(text: t, style: dasar.merge(g)),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = tp.width;
      tp.dispose();
      return w;
    }

    double kata((String, TextStyle) t) =>
        t.$1.split(' ').map((k) => lebar(k, t.$2)).reduce(math.max);

    final kiri = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(judul.$1, style: judul.$2),
        Text(sub.$1, style: sub.$2),
      ],
    );
    final kanan = Text(nilai.$1, style: nilai.$2);
    return LayoutBuilder(
      builder: (context, k) {
        const jarak = 12.0;
        final ada = k.maxWidth - jarak;
        final l = math.max(lebar(judul.$1, judul.$2), lebar(sub.$1, sub.$2));
        final r = lebar(nilai.$1, nilai.$2);
        if (l + r <= ada) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: kiri),
              const SizedBox(width: jarak),
              kanan,
            ],
          );
        }
        final lebih = l + r - ada;
        var rw = r - lebih * r / (l + r);
        final rMin = kata(nilai);
        final lMin = math.max(kata(judul), kata(sub));
        if (rw < rMin) rw = rMin;
        if (ada - rw < lMin) rw = ada - lMin;
        // + 0.5: room for sub-pixel rounding, so the longest word never splits.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: kiri),
            const SizedBox(width: jarak),
            SizedBox(width: rw + 0.5, child: kanan),
          ],
        );
      },
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
                // The field fills the 44 px box itself (X03), text centred.
                child: SizedBox(
                  height: 44,
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
                      textAlignVertical: TextAlignVertical.center,
                      expands: true,
                      maxLines: null,
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
        ],
      ),
    );
  }
}
