import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../mock/mock.dart';
import '../../motion/hitung.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/ponsel_tab_bar.dart';
import '../../shell/tautan.dart';
import '../../shell/toast.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/isian_jumlah.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/logo.dart';
import '../../widgets/status_simpan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

part 'main_catat.dart';
part 'main_periksa.dart';

// ---------- Board data (Main.dc.html logic class) ----------

const _akun = [
  (id: 'kas', n: 'Kas'),
  (id: 'bni', n: 'Bank BNI ··4821'),
  (id: 'bsg', n: 'Bank SulutGo ··1107'),
];

String _nama(String? id) {
  for (final a in _akun) {
    if (a.id == id) return a.n;
  }
  return '';
}

typedef _Cfg = ({
  String judul,
  String pohon,
  String akun,
  String per,
  String pihak,
  int tanda,
});

const Map<String, _Cfg> _cfg = {
  'belanja': (
    judul: 'Belanja',
    pohon: 'Belanja',
    akun: 'Kas/Bank',
    per: 'Diambil dari peruntukan',
    pihak: 'Dibayar kepada',
    tanda: -1,
  ),
  'pendapatan': (
    judul: 'Pendapatan',
    pohon: 'Pendapatan',
    akun: 'Kas/Bank',
    per: 'Masuk ke peruntukan',
    pihak: 'Diterima dari (boleh tanpa nama)',
    tanda: 1,
  ),
  'pindah': (
    // U+2060 keeps "Kas/Bank" whole: Chrome does not break after the slash.
    judul: 'Pindah antar Kas/\u2060Bank',
    pohon: '',
    akun: 'Dari Kas/Bank',
    per: '',
    pihak: '',
    tanda: 0,
  ),
};

/// A transaction row of the Transaksi list.
typedef _Baris = ({
  String st,
  String no,
  String tgl,
  String ur,
  String ak,
  int jm,
  String? link,
});

const List<_Baris> _dataRamai = [
  (
    st: 'Dibukukan',
    no: 'BKU-2026-0146',
    tgl: '15/11/2026',
    ur: 'Persembahan Ibadah Minggu',
    ak: 'Kas',
    jm: 3450000,
    link: null,
  ),
  (
    st: 'Draf',
    no: 'Belum ada No. Bukti',
    tgl: '14/11/2026',
    ur: 'Fotokopi warta jemaat',
    ak: 'Kas',
    jm: -150000,
    link: null,
  ),
  (
    st: 'Dibukukan',
    no: 'BKU-2026-0144',
    tgl: '12/11/2026',
    ur: 'Pembalikan BKU-2026-0139',
    ak: 'Kas',
    jm: 750000,
    link: null,
  ),
  (
    st: 'Dibalik',
    no: 'BKU-2026-0139',
    tgl: '09/11/2026',
    ur: 'Konsumsi rapat majelis',
    ak: 'Kas',
    jm: -750000,
    link: 'Dibalik oleh No. Bukti BKU-2026-0144',
  ),
  (
    st: 'Draf',
    no: 'Belum ada No. Bukti',
    tgl: '08/11/2026',
    ur: 'Honor pemusik',
    ak: 'Bank BNI ··4821',
    jm: -650000,
    link: null,
  ),
];

const _noBukti = 'BKU-2026-0147';

List<MataAnggaran> _pohonMA(String pohon) => [
  for (final k in switch (pohon) {
    'Belanja' => pilihanMABelanja,
    'Pendapatan' => pilihanMAPendapatan,
    _ => const <String>[],
  })
    mataAnggaran.firstWhere((m) => m.kode == k),
];

// ---------- Board state ----------

/// The board's one state object, shared by `/Main` and its child routes.
class _MainKeadaan extends ChangeNotifier {
  _MainKeadaan(this._gagalSimpan);

  /// The `gagalSimpan` tweak, read when a field changes.
  final bool Function() _gagalSimpan;

  bool sheet = false, toast = false;
  String filter = 'Semua';
  String jenis = 'belanja';
  String jumlah = '', pihak = '', uraian = '';
  String? akun, ke, per, ling;
  MataAnggaran? ma;
  String dok = 'kosong';
  bool verif = false, posted = false, sudahCoba = false;
  KeadaanSimpan simpan = KeadaanSimpan.belum;
  int saldoLama = 0;
  Map<String, int> saldo = {...saldoNovember};
  int pend = 7540000, bel = 7940000, drafN = 2, drafRp = 800000;
  _Baris? baru;

  // One cancellable timer per purpose: 1100 (Coba lagi), 1300 (upload),
  // 2600 (toast).
  Timer? _t2, _t3, _t4;

  void _batalWaktu() {
    _t2?.cancel();
    _t3?.cancel();
    _t4?.cancel();
  }

  /// Back to the board's initial state (navigation.md 2.1, Reset).
  void ulang() {
    _batalWaktu();
    sheet = toast = false;
    filter = 'Semua';
    jenis = 'belanja';
    jumlah = pihak = uraian = '';
    akun = ke = per = ling = null;
    ma = null;
    dok = 'kosong';
    verif = posted = sudahCoba = false;
    simpan = KeadaanSimpan.belum;
    saldoLama = 0;
    saldo = {...saldoNovember};
    pend = 7540000;
    bel = 7940000;
    drafN = 2;
    drafRp = 800000;
    baru = null;
    notifyListeners();
  }

  void _ganti(void Function() f) {
    f();
    notifyListeners();
  }

  _Cfg get cfg => _cfg[jenis]!;
  bool get pindah => jenis == 'pindah';
  int get j => int.tryParse(jumlah) ?? 0;

  /// Signed amount as the views show it.
  String get jumlahRp => rp(j * (cfg.tanda == 0 ? 1 : cfg.tanda));

  String get ringkas => pindah
      ? 'Dari ${_nama(akun).isEmpty ? '…' : _nama(akun)} ke '
            '${_nama(ke).isEmpty ? '…' : _nama(ke)}'
      : uraian.isNotEmpty
      ? uraian
      : pihak.isNotEmpty
      ? pihak
      : cfg.judul;

  /// `ubah(patch)`: applies the change and sets the honest save state.
  void ubah(void Function() f) => _ganti(() {
    f();
    simpan = _gagalSimpan() && !sudahCoba
        ? KeadaanSimpan.gagal
        : KeadaanSimpan.tersimpan;
  });

  void bukaSheet() => _ganti(() => sheet = true);
  void tutupSheet() => _ganti(() => sheet = false);
  void pilihFilter(String f) => _ganti(() => filter = f);

  /// A "Catat apa?" row: closes the sheet and resets the form.
  void mulai(String id, String ur) => _ganti(() {
    sheet = false;
    jenis = id;
    jumlah = pihak = '';
    uraian = ur;
    akun = ke = per = ling = null;
    ma = null;
    dok = 'kosong';
    verif = posted = sudahCoba = false;
    simpan = KeadaanSimpan.belum;
  });

  void cobaLagi() {
    _ganti(() {
      simpan = KeadaanSimpan.mencoba;
      sudahCoba = true;
    });
    _t2?.cancel();
    _t2 = Timer(
      const Duration(milliseconds: 1100),
      () => _ganti(() => simpan = KeadaanSimpan.tersimpan),
    );
  }

  void lampirkan() {
    _ganti(() => dok = 'unggah');
    _t3?.cancel();
    _t3 = Timer(
      const Duration(milliseconds: 1300),
      () => ubah(() => dok = 'terlampir'),
    );
  }

  void verifikasi() => _ganti(() => verif = true);

  void simpanDraf() {
    final r = ringkas, n = j;
    _ganti(() {
      toast = true;
      drafN += 1;
      drafRp += n;
      baru = (
        st: 'Draf',
        no: 'Belum ada No. Bukti',
        tgl: '16/11/2026',
        ur: r,
        ak: _nama(akun).isEmpty ? 'Kas/Bank belum dipilih' : _nama(akun),
        jm: n * (cfg.tanda == 0 ? 1 : cfg.tanda),
        link: null,
      );
    });
    _t4?.cancel();
    _t4 = Timer(
      const Duration(milliseconds: 2600),
      () => _ganti(() => toast = false),
    );
  }

  void bukukan() {
    final r = ringkas, n = j, lama = saldo[akun]!;
    _ganti(() {
      final s = {...saldo};
      if (pindah) {
        s[akun!] = s[akun]! - n;
        s[ke!] = s[ke]! + n;
      } else {
        s[akun!] = s[akun]! + cfg.tanda * n;
      }
      saldo = s;
      posted = true;
      saldoLama = lama;
      if (jenis == 'pendapatan') pend += n;
      if (jenis == 'belanja') bel += n;
      baru = (
        st: 'Dibukukan',
        no: _noBukti,
        tgl: '16/11/2026',
        ur: r,
        ak: _nama(akun),
        jm: n * (cfg.tanda == 0 ? -1 : cfg.tanda),
        link: null,
      );
    });
    // The board's count shares the Coba lagi slot: Bukukan cancels a retry.
    _t2?.cancel();
  }

  @override
  void dispose() {
    _batalWaktu();
    super.dispose();
  }
}

class _MainLingkup extends InheritedNotifier<_MainKeadaan> {
  const _MainLingkup({required _MainKeadaan keadaan, required super.child})
    : super(notifier: keadaan);

  static _MainKeadaan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MainLingkup>()!.notifier!;

  static _MainKeadaan baca(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_MainLingkup>()!.notifier!;
}

// ---------- Navigation inside the board ----------

final _akar = Layar.keuangan.jalur;

/// The Main page on top of Main's own pages.
String _atasMain(GoRouter r) {
  for (final l in tumpukanHalaman(r).reversed) {
    if (l == _akar || l.startsWith('$_akar/')) return l;
  }
  return _akar;
}

/// "Pop to /Main": pop every `/Main/…` page above `/Main`, or go `/Main`
/// when it is not in the stack.
void _keMain(GoRouter r) {
  var t = tumpukanHalaman(r);
  if (!t.contains(_akar)) {
    r.go(_akar);
    return;
  }
  while (t.length > 1 && t.last.startsWith('$_akar/')) {
    r.pop();
    final b = tumpukanHalaman(r);
    if (b.length >= t.length) break;
    t = b;
  }
}

/// Pop to /Main, then push a child view.
void _keAnak(GoRouter r, String anak) {
  _keMain(r);
  r.push('$_akar/$anak');
}

void _keBeranda(BuildContext context) {
  _MainLingkup.baca(context).tutupSheet();
  _keMain(GoRouter.of(context));
}

void _bukaDaftar(BuildContext context) {
  final r = GoRouter.of(context);
  if (_atasMain(r) == '$_akar/transaksi') return;
  _keAnak(r, 'transaksi');
}

// ---------- Kendali: state, LayarPonsel, overlays ----------

class MainKendali extends StatefulWidget {
  const MainKendali({super.key, required this.child});
  final Widget child;
  @override
  State<MainKendali> createState() => _MainKendaliState();
}

class _MainKendaliState extends State<MainKendali> {
  late final _MainKeadaan _m = _MainKeadaan(() => belumDipindah(false));

  @override
  void dispose() {
    _m.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final atas = _atasMain(GoRouter.of(context));
    final tab = atas == _akar || atas == '$_akar/transaksi';
    return _MainLingkup(
      keadaan: _m,
      child: ListenableBuilder(
        listenable: _m,
        builder: (context, child) => LayarPonsel(
          layarKeuangan: true,
          overlay: [
            if (tab)
              PonselTabBar(
                aktif: atas == '$_akar/transaksi'
                    ? TabPonsel.transaksi
                    : TabPonsel.beranda,
                beranda: (isi) =>
                    Tekan(onTap: () => _keBeranda(context), child: isi),
                transaksi: (isi) =>
                    Tekan(onTap: () => _bukaDaftar(context), child: isi),
                catat: (isi) => Tekan(
                  onTap: _m.bukaSheet,
                  label: 'Catat transaksi',
                  radius: 29,
                  child: isi,
                ),
              ),
            if (_m.toast && tab)
              const Toast('Draf tersimpan · belum masuk saldo'),
            if (_m.sheet) Positioned.fill(child: _rataCss(_LembarCatat(m: _m))),
          ],
          child: child!,
        ),
        child: widget.child,
      ),
    );
  }
}

// ---------- Screen: one view per route ----------

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // A deep link to detail before anything is booked has no transaction to show.
    if (widget.anak == 'detail') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_MainLingkup.baca(context).posted) {
          context.naikKe(Layar.keuangan);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final anak = widget.anak;
    final m = _MainLingkup.of(context);
    final c = context.warna;
    final Widget isi = switch (anak) {
      'transaksi' => const _Daftar(),
      'catat' => const _Catat(),
      'mata-anggaran' => const _PilihMa(),
      'periksa' => const _Periksa(),
      'detail' => const _Detail(),
      _ => const _Beranda(),
    };
    final tutupLembar = anak == null || anak == 'transaksi';
    return PopScope(
      // An open sheet closes first; a posted Periksa returns to Beranda.
      canPop: !(tutupLembar && m.sheet) && !(anak == 'periksa' && m.posted),
      onPopInvokedWithResult: (sudah, _) {
        if (sudah) return;
        if (tutupLembar && m.sheet) {
          m.tutupSheet();
        } else {
          _keBeranda(context);
        }
      },
      child: ColoredBox(
        color: anak == 'mata-anggaran' ? c.permukaan : c.kertas,
        child: _rataCss(isi),
      ),
    );
  }
}

// ---------- Shared bits ----------

/// CSS puts half the line-height leading above and half below the glyphs.
Widget _rataCss(Widget child) => DefaultTextStyle.merge(
  style: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
  child: child,
);

const _mono = PalakatText.mono;

/// Scroll area of Beranda and Transaksi: above the 84 px tab bar.
class _GulirTab extends StatelessWidget {
  const _GulirTab({required this.jarak, required this.anak});
  final double jarak;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 84),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: jarak,
        children: anak,
      ),
    ),
  );
}

/// Link text in a link row: text centred vertically in the 44 × 44 target.
Widget _teksTautan(String teks) => Align(
  alignment: Alignment.centerLeft,
  widthFactor: 1,
  heightFactor: 1,
  child: TautanTeks(teks),
);

Widget _kotakPutus(BuildContext context, Widget child, EdgeInsets padding) =>
    Container(
      padding: padding,
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(context.warna.putus, radius: 14),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        child: child,
      ),
    );

// ---------- A. Beranda ----------

class _Beranda extends StatelessWidget {
  const _Beranda();

  @override
  Widget build(BuildContext context) {
    final m = _MainLingkup.of(context);
    final c = context.warna;
    final sepi = belumDipindah<String>('ramai') == 'sepi';
    final drafN = sepi ? 0 : m.drafN;
    final pend = sepi ? 0 : m.pend, bel = sepi ? 0 : m.bel;
    final total = m.saldo.values.fold(0, (a, b) => a + b);
    final tindakan = sepi
        ? const <(String, String)>[]
        : [
            ('$drafN draf belum dibukukan', 'Belum masuk saldo'),
            (
              '1 dokumen pendukung wajib, belum ada',
              'BKU-2026-0143 · Rp600.000',
            ),
            ('1 Mata Anggaran belum dipilih', 'Draf · Honor pemusik'),
          ];
    final garis = GarisLurus(warna: c.garis);

    return _GulirTab(
      jarak: 22,
      anak: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TandaPalakat(),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Jemaat Karunia',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tautan(
              ke: Layar.pilihBulan,
              label: 'Pilih bulan, sekarang November 2026',
              radius: 22,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 999),
                ),
                child: Text(
                  'November 2026',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.tinta2,
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(
              'Saldo buku semua Kas/Bank',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Text(
              rp(total),
              style: const TextStyle(
                fontFamily: _mono,
                fontSize: 38,
                fontWeight: FontWeight.w500,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            Text(
              'Hanya transaksi yang sudah dibukukan',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
            if (drafN > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: ShapeDecoration(
                    shape: GarisBorder.putus(c.putus, radius: 999),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: rp(m.drafRp),
                          style: const TextStyle(fontFamily: _mono),
                        ),
                        TextSpan(text: ' · $drafN draf · belum masuk saldo'),
                      ],
                    ),
                    style: TextStyle(fontSize: 13, color: c.tinta2),
                  ),
                ),
              ),
          ],
        ),
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (final (i, a) in _akun.indexed) ...[
                if (i > 0) garis,
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 46),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(a.n, style: const TextStyle(fontSize: 15)),
                      ),
                      Text(
                        rp(m.saldo[a.id]!),
                        style: const TextStyle(
                          fontFamily: _mono,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: JudulBagian(
                'Perlu tindakan',
                hitungan: tindakan.length + 1,
              ),
            ),
            Kartu(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Tautan(
                    ke: Layar.tutupBuku,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 60),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Oktober 2026 belum ditutup',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  '1 hambatan · bulan berikutnya untuk tutup buku',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: c.bata,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
                        ],
                      ),
                    ),
                  ),
                  for (final t in tindakan)
                    BarisDaftar(
                      judul: t.$1,
                      keterangan: t.$2,
                      onTap: () => _bukaDaftar(context),
                    ),
                ],
              ),
            ),
            if (sepi)
              _kotakPutus(
                context,
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Belum ada transaksi di November.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.tinta,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' Bulan tanpa transaksi belum selesai: tiap Kas/Bank '
                            'tetap perlu hitung kas atau rekening koran, lalu '
                            'tutup buku.',
                      ),
                    ],
                  ),
                ),
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
          ],
        ),
        if (!sepi)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              const JudulBagian('Untuk diketahui'),
              Tautan(
                ke: Layar.kewajiban,
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks(
                    '2 uang muka dengan sisa belum dipertanggungjawabkan',
                    berat: FontWeight.w400,
                    ukuran: 14,
                    warna: c.tinta2,
                  ),
                ),
              ),
            ],
          ),
        DeretTautan(
          anak: [
            Tautan(ke: Layar.tutupBuku, child: _teksTautan('Rekonsiliasi')),
            Tautan(
              ke: Layar.laporan,
              child: _teksTautan('Buat laporan sementara'),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Semantics(
              header: true,
              child: Text.rich(
                TextSpan(
                  text: 'Bulan ini ',
                  children: [
                    TextSpan(
                      text: '· tanpa titipan, hanya yang sudah dibukukan',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: c.tinta3,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Row(
              spacing: 10,
              children: [
                for (final (l, n) in [('Pendapatan', pend), ('Belanja', bel)])
                  Expanded(
                    child: Kartu(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l,
                            style: TextStyle(fontSize: 13, color: c.tinta2),
                          ),
                          Text(
                            rp(n),
                            style: const TextStyle(
                              fontFamily: _mono,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Surplus/Defisit bulan ini',
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                  ),
                  Text(
                    rp(pend - bel),
                    style: const TextStyle(
                      fontFamily: _mono,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------- C. Transaksi ----------

class _Daftar extends StatelessWidget {
  const _Daftar();

  @override
  Widget build(BuildContext context) {
    final m = _MainLingkup.of(context);
    final c = context.warna;
    final sepi = belumDipindah<String>('ramai') == 'sepi';
    final data = [?m.baru, if (!sepi) ..._dataRamai];
    final rows = [
      for (final r in data)
        if (m.filter == 'Semua' || r.st == m.filter) r,
    ];

    return _GulirTab(
      jarak: 14,
      anak: [
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              text: 'Transaksi ',
              children: [
                TextSpan(
                  text: '· November 2026',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c.tinta3,
                  ),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        MarginNegatif(
          atas: 6,
          bawah: 6,
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            child: Wrap(
              spacing: 22,
              children: [
                Tautan(ke: Layar.pilihBulan, child: _teksTautan('Pilih bulan')),
                Tautan(
                  ke: Layar.draf,
                  param: {'id': belumDipindahId},
                  child: _teksTautan('1 draf di bulan yang sudah ditutup'),
                ),
                Tautan(ke: Layar.cari, child: _teksTautan('Cari')),
              ],
            ),
          ),
        ),
        ChipPilihan<String>(
          pilihan: const [
            (nilai: 'Semua', teks: 'Semua'),
            (nilai: 'Draf', teks: 'Draf'),
            (nilai: 'Dibukukan', teks: 'Dibukukan'),
          ],
          terpilih: m.filter,
          onPilih: m.pilihFilter,
          padding: 16,
          jarakBaris: 0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _KartuTransaksi(r),
              ),
            if (rows.isEmpty)
              _kotakPutus(
                context,
                const Text('Belum ada transaksi yang cocok di November 2026.'),
                const EdgeInsets.all(16),
              ),
          ],
        ),
      ],
    );
  }
}

class _KartuTransaksi extends StatelessWidget {
  const _KartuTransaksi(this.r);
  final _Baris r;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final draf = r.st == 'Draf';
    final link = r.link ?? (draf ? 'Belum masuk saldo' : null);
    return Kartu(
      status: draf ? GarisStatus.draf : GarisStatus.dibukukan,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8,
            children: [
              LencanaStatus.uang(switch (r.st) {
                'Draf' => StatusUang.draf,
                'Dibalik' => StatusUang.dibalik,
                _ => StatusUang.dibukukan,
              }, jarakHuruf: .3),
              Flexible(
                child: Text(
                  rp(r.jm),
                  style: TextStyle(
                    fontFamily: _mono,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: draf ? c.tinta3 : c.tinta,
                  ),
                ),
              ),
            ],
          ),
          Text(
            r.ur,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: r.no,
                  style: const TextStyle(fontFamily: _mono),
                ),
                TextSpan(text: ' · ${r.tgl} · ${r.ak}'),
              ],
            ),
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
          if (link != null)
            Text(link, style: TextStyle(fontSize: 13, color: c.tinta2)),
        ],
      ),
    );
  }
}

// ---------- E. Sheet "Catat apa?" ----------

class _LembarCatat extends StatelessWidget {
  const _LembarCatat({required this.m});
  final _MainKeadaan m;

  static const _jenis = [
    ('+', 'Pendapatan', 'Uang masuk milik Jemaat', 'pendapatan', ''),
    ('−', 'Belanja', 'Pembayaran langsung', 'belanja', ''),
    (
      '+',
      'Persembahan',
      'Persembahan ibadah, dicatat sebagai Pendapatan',
      'pendapatan',
      'Persembahan Ibadah Minggu',
    ),
    ('⇄', 'Pindah antar Kas/Bank', 'Termasuk setoran ke bank', 'pindah', ''),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final router = GoRouter.of(context);
    final garis = GarisLurus(warna: c.garis);
    return LembarBawah(
      judul: 'Catat apa?',
      onTutup: m.tutupSheet,
      labelTirai: 'Kembali ke Beranda',
      jarak: 0,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      isi: [
        for (final (tanda, n, s, id, ur) in _jenis)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              garis,
              Tekan(
                onTap: () {
                  m.mulai(id, ur);
                  _keAnak(router, 'catat');
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 63),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.lautLembut,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tanda,
                          style: TextStyle(
                            fontFamily: _mono,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: c.laut,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              s,
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        garis,
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Catatan lain',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ),
              Wrap(
                children: [
                  _ChipTautan(
                    m: m,
                    ke: Layar.persembahan,
                    teks: 'Persembahan beberapa bagian',
                  ),
                  _ChipTautan(
                    m: m,
                    ke: Layar.kasusBaru,
                    teks: 'Uang Muka, Titipan, klaim',
                  ),
                  _ChipTautan(
                    m: m,
                    ke: Layar.alihPeruntukan,
                    teks: 'Alih peruntukan',
                  ),
                  _ChipTautan(
                    m: m,
                    ke: Layar.pengembalian,
                    teks: 'Pengembalian',
                  ),
                  _ChipTautan(m: m, ke: Layar.aiFoto, teks: 'Dari foto nota'),
                  _ChipTautan(m: m, ke: Layar.bantuanAi, teks: 'Dari kalimat'),
                  _ChipTautan(
                    m: m,
                    ke: Layar.aiMataAnggaran,
                    teks: 'Usulan Mata Anggaran',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A "Catatan lain" link chip: closes the sheet, then opens the board.
class _ChipTautan extends StatelessWidget {
  const _ChipTautan({required this.m, required this.ke, required this.teks});
  final _MainKeadaan m;
  final Layar ke;
  final String teks;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, right: 8),
    child: Tekan(
      peran: PeranTekan.tautan,
      radius: 22,
      onTap: () {
        m.tutupSheet();
        Tautan(ke: ke, child: const SizedBox()).buka(context);
      },
      // An <a> chip is content-box: 44 inside the 1.5 line, 47 outside.
      child: SizedBox(
        height: 47,
        child: ChipSatu(teks: teks, dipilih: false, onTap: null),
      ),
    ),
  );
}
