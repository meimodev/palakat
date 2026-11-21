import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/hitung.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../providers/actor.dart';
import '../../providers/bilah_ponsel.dart';
import '../../providers/clock.dart';
import '../../providers/core_repositories.dart';
import '../../providers/home_rows.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/catat.dart';
import '../../providers/keuangan/isian.dart';
import '../../providers/keuangan/transaksi.dart';
import '../../providers/repositories_keuangan.dart';
import '../../providers/revision.dart';
import '../../providers/session.dart';
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
import '../../widgets/penolakan.dart';
import '../../widgets/status_simpan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../p2/beranda_jabatan_isi.dart';

part 'main_catat.dart';
part 'main_periksa.dart';

// ---------- Board copy (Main.dc.html logic class) ----------

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

const _jenisTipe = {
  'belanja': TransactionType.expense,
  'pendapatan': TransactionType.income,
  'pindah': TransactionType.accountTransfer,
};

// ---------- Board state (UI only; the records live in repositories) ----------

/// The board's one UI state object, shared by `/keuangan` and its child
/// routes: the sheet, the toast, the filter, the Catat form and the id of
/// the draft it saved. Commands go through the repositories (README 3.3).
class _MainKeadaan extends ChangeNotifier {
  _MainKeadaan(this._c);

  final ProviderContainer _c;

  bool sheet = false, toast = false;
  SaringTransaksi filter = SaringTransaksi.semua;
  String jenis = 'belanja';
  String jumlah = '', pihak = '', uraian = '';
  String? akun, ke, per, ling;
  MasterRow? ma;

  /// The document panel: 'kosong', 'unggah' (progress), 'terlampir'.
  String dok = 'kosong';
  String? berkas;

  /// The draft this form saved, its revision, and what was saved (material
  /// fields, text fields), so a save sends only what changed.
  String? drafId;
  int _rev = 0;
  String? _pokok, _teks;

  /// The last command's refusal, shown on the form or on Periksa.
  Refusal? tolak;
  bool sibuk = false;

  /// After Bukukan: the voucher, when and the source balance before/after.
  bool posted = false;
  String? voucher;
  DateTime? dibukukanPada;
  int saldoLama = 0, saldoBaru = 0;

  // One cancellable timer per purpose: 1300 (upload), 2600 (toast).
  Timer? _tUnggah, _tToast;

  void _ganti(void Function() f) {
    f();
    notifyListeners();
  }

  _Cfg get cfg => _cfg[jenis]!;
  bool get pindah => jenis == 'pindah';
  int get j => int.tryParse(jumlah) ?? 0;
  Tanggal get tanggal =>
      _c.read(isianCatatProvider)?.tanggal ?? _c.read(hariIniProvider);
  PilihanCatat get pilihan => _c.read(pilihanCatatProvider(tanggal));

  /// The split Bagi wrote into the form's draft (isian.dart): its parts,
  /// else null. The form keeps choosing Kas/Bank, peruntukan and Lingkup.
  List<Allocation>? get bagian {
    final id = _c.read(isianCatatProvider)?.drafId;
    final t = id == null
        ? null
        : _c.read(transactionRepositoryProvider).get(id);
    return t != null && t.isDraft && t.allocations.length > 1 && !pindah
        ? t.allocations
        : null;
  }

  /// "Bagi ke beberapa Mata Anggaran": hands Bagi this form (isian.dart).
  void bukaBagi(BuildContext context) {
    _c
        .read(isianCatatProvider.notifier)
        .buka(
          IsianCatat(
            jenis: _jenisTipe[jenis]!,
            jumlah: j,
            uraian: ringkas,
            tanggal: _c.read(isianCatatProvider)?.tanggal,
            drafId: drafId,
          ),
        );
    // From the picker: Bagi's "Kembali ke transaksi" lands on the form.
    final r = GoRouter.of(context);
    if (_atasMain(r).endsWith('/mata-anggaran')) context.naikKe(Layar.catat);
    r.push(Layar.bagi.lokasi());
  }

  /// Signed amount as the views show it.
  String get jumlahRp => rp(j * (cfg.tanda == 0 ? 1 : cfg.tanda));

  String get ringkas {
    final p = pilihan;
    String nama(String? id) {
      final n = p.namaKasBank(id);
      return n.isEmpty ? '…' : n;
    }

    return pindah
        ? 'Dari ${nama(akun)} ke ${nama(ke)}'
        : uraian.isNotEmpty
        ? uraian
        : pihak.isNotEmpty
        ? pihak
        : cfg.judul;
  }

  String get _jejakPokok =>
      '$jenis|$tanggal|$j|$akun|${pindah ? ke : ''}|$per|$ling|${ma?.code}'
      '|${bagian?.map((a) => '${a.masterCode}:${a.amount}').join(',')}';
  String get _jejakTeks => '$ringkas|$pihak';

  /// The form matches its saved draft.
  bool get tersimpan =>
      drafId != null && _pokok == _jejakPokok && _teks == _jejakTeks;

  /// Honest save state (StatusSimpan): saved only when the repository holds
  /// what the form shows.
  KeadaanSimpan get simpan =>
      tersimpan ? KeadaanSimpan.tersimpan : KeadaanSimpan.belum;

  /// A field change.
  void ubah(void Function() f) => _ganti(() {
    f();
    tolak = null;
  });

  void bukaSheet() => _ganti(() => sheet = true);
  void tutupSheet() => _ganti(() => sheet = false);
  void pilihFilter(SaringTransaksi f) => _ganti(() => filter = f);
  void lupakanTolak() => _ganti(() => tolak = null);

  void _kosongkan() {
    _tUnggah?.cancel();
    jumlah = pihak = uraian = '';
    akun = ke = per = ling = null;
    ma = null;
    dok = 'kosong';
    berkas = drafId = _pokok = _teks = voucher = null;
    tolak = dibukukanPada = null;
    posted = sibuk = false;
  }

  /// A "Catat apa?" row: closes the sheet and resets the form and its date.
  void mulai(String id, String ur) {
    // The shared form state Tanggal writes its date into (isian.dart).
    _c
        .read(isianCatatProvider.notifier)
        .buka(IsianCatat(jenis: _jenisTipe[id]!));
    _ganti(() {
      sheet = false;
      _kosongkan();
      jenis = id;
      uraian = ur;
    });
  }

  /// A draft the simple form can hold: one part of Pendapatan, Belanja or
  /// Pindah antar Kas/Bank, no case.
  static bool bisaDimuat(Transaction t) =>
      _jenisTipe.containsValue(t.type) &&
      t.allocations.length == 1 &&
      t.allocations.single.type == null &&
      t.allocations.single.caseId == null;

  /// Opens draft [t] in the form (Transaksi card).
  void muat(Transaction t) {
    _c
        .read(isianCatatProvider.notifier)
        .buka(
          IsianCatat(jenis: t.type, tanggal: t.effectiveDate, drafId: t.id),
        );
    final a = t.allocations.single;
    final bukti = _c.read(evidenceRepositoryProvider).forTransaction(t.id);
    _ganti(() {
      _kosongkan();
      jenis = _jenisTipe.entries.firstWhere((e) => e.value == t.type).key;
      jumlah = '${a.amount}';
      akun = t.accountOf(a);
      ke = t.toAccountId;
      per = pindah ? null : a.fundId;
      ling = pindah ? null : a.scopeId;
      final rows = cfg.pohon == 'Belanja'
          ? pilihan.belanja
          : pilihan.pendapatan;
      ma = rows.where((r) => r.code == a.masterCode).firstOrNull;
      pihak = t.payee ?? '';
      uraian = t.description;
      final berkasAda = bukti.where((e) => e.file != null).lastOrNull;
      if (berkasAda != null) {
        dok = 'terlampir';
        berkas = berkasAda.file!.name;
      }
      drafId = t.id;
      _rev = t.revision;
      _pokok = _jejakPokok;
      _teks = _jejakTeks;
    });
  }

  TransactionDraft _draf() {
    final p = pilihan;
    return TransactionDraft(
      type: _jenisTipe[jenis]!,
      effectiveDate: tanggal,
      description: ringkas,
      accountId: akun,
      toAccountId: pindah ? ke : null,
      payee: pindah || pihak.isEmpty ? null : pihak,
      allocations: [
        // ponytail: the split's amounts win over the form's Jumlah if it
        // was changed after Bagi; Bagi re-checks the sum when used again.
        for (final b in bagian ?? const <Allocation>[])
          Allocation(
            amount: b.amount,
            fundId: per,
            scopeId: ling,
            masterCode: b.masterCode,
            masterVersionId: b.masterVersionId,
          ),
        if (bagian == null)
          Allocation(
            amount: j,
            // ponytail: a Pindah moves the Umum Jemaat share (as the seed's
            // transfers do); a Fund chooser when a board draws one.
            fundId: pindah ? p.umum : per,
            scopeId: pindah ? ScopeRef.jemaatId : ling,
            masterCode: pindah ? null : ma?.code,
            masterVersionId: pindah ? null : ma?.versionId,
          ),
      ],
    );
  }

  Actor? get _aktor => _c.read(actorProvider);
  String _kunci(Actor a) => kunciBaru(a.personId, _c.read(clockProvider));

  /// Saves the form as a draft: creates it, or sends what changed.
  Future<Result<Transaction>> _simpan(Actor a) async {
    final tx = _c.read(transactionRepositoryProvider);
    // Bagi saved the split into a draft (a new one, or this one at a new
    // revision): save into that draft, not a second one.
    final dariBagi = _c.read(isianCatatProvider)?.drafId;
    final b = dariBagi == null || bagian == null ? null : tx.get(dariBagi);
    if (b != null && (b.id != drafId || b.revision != _rev)) {
      drafId = b.id;
      _rev = b.revision;
      _pokok = null;
    }
    if (tersimpan) return Ok(tx.get(drafId!)!);
    final d = _draf(), pokok = _jejakPokok, teks = _jejakTeks;
    final Result<Transaction> r;
    if (drafId == null) {
      r = await tx.createDraft(a, d, idempotencyKey: _kunci(a));
    } else {
      final ubahPokok = pokok != _pokok;
      r = await tx.editDraft(
        a,
        drafId!,
        TransactionPatch(
          description: d.description,
          payee: d.payee ?? '',
          type: ubahPokok ? d.type : null,
          effectiveDate: ubahPokok ? d.effectiveDate : null,
          allocations: ubahPokok ? d.allocations : null,
          accountId: ubahPokok ? d.accountId : null,
          toAccountId: ubahPokok ? d.toAccountId : null,
        ),
        expectedRevision: _rev,
        idempotencyKey: _kunci(a),
      );
    }
    if (r case Ok(:final value)) {
      drafId = value.id;
      _rev = value.revision;
      _pokok = pokok;
      _teks = teks;
    }
    return r;
  }

  /// Runs [kerja] with the signed-in actor; a refusal lands in [tolak].
  Future<bool> _jalankan(Future<Refusal?> Function(Actor a) kerja) async {
    final a = _aktor;
    if (a == null || sibuk) return false;
    _ganti(() => sibuk = true);
    final r = await kerja(a);
    _ganti(() {
      sibuk = false;
      tolak = r;
    });
    return r == null;
  }

  /// "Simpan sebagai draf": true when saved (the caller pops to Beranda).
  Future<bool> simpanDraf() async {
    final ok = await _jalankan((a) async => (await _simpan(a)).refusal);
    if (ok) {
      _ganti(() => toast = true);
      _tToast?.cancel();
      _tToast = Timer(_lamaToast, _tutupToast); // tiruan: toast display time
    }
    return ok;
  }

  void _tutupToast() => _ganti(() => toast = false);

  /// "Lampirkan dokumen pendukung": saves the draft, then uploads the file
  /// at once; the bar only shows progress.
  Future<void> lampirkan() async {
    final ok = await _jalankan((a) async {
      final r = await _simpan(a);
      if (r.refusal != null) return r.refusal;
      final h = _c.read(hariIniProvider);
      final nama = 'nota-${_dua(h.hari)}-${_dua(h.bulan)}.jpg';
      final u = await _c
          .read(evidenceRepositoryProvider)
          .upload(
            a,
            drafId!,
            SampleFile(nama),
            expectedRevision: _rev,
            idempotencyKey: _kunci(a),
          );
      if (u.refusal != null) return u.refusal;
      _rev = _c.read(transactionRepositoryProvider).get(drafId!)!.revision;
      berkas = nama;
      return null;
    });
    if (!ok) return;
    _ganti(() => dok = 'unggah');
    _tUnggah?.cancel();
    _tUnggah = Timer(_lamaUnggah, _terlampir); // tiruan: upload progress
  }

  void _terlampir() => _ganti(() => dok = 'terlampir');

  /// "Bukukan": saves the draft, then finalizes it. With the second-checker
  /// rule in force the repository refuses an unchecked draft.
  Future<void> bukukan() async {
    await _jalankan((a) async {
      final r = await _simpan(a);
      if (r.refusal != null) return r.refusal;
      final akunRepo = _c.read(accountRepositoryProvider);
      final tx = _c.read(transactionRepositoryProvider);
      final lama = akun == null ? 0 : akunRepo.balance(akun!);
      final f = await tx.finalize(
        a,
        drafId!,
        expectedRevision: r.value.revision,
        idempotencyKey: _kunci(a),
      );
      if (f.refusal != null) {
        _rev = tx.get(drafId!)?.revision ?? _rev;
        return f.refusal;
      }
      final t = tx.get(drafId!)!;
      posted = true;
      voucher = f.value;
      dibukukanPada = t.finalizedAt;
      saldoLama = lama;
      saldoBaru = akunRepo.balance(akun!);
      return null;
    });
  }

  @override
  void dispose() {
    _tUnggah?.cancel();
    _tToast?.cancel();
    super.dispose();
  }
}

const _lamaToast = Duration(milliseconds: 2600);
const _lamaUnggah = Duration(milliseconds: 1300);

String _dua(int n) => n.toString().padLeft(2, '0');

class _MainLingkup extends InheritedNotifier<_MainKeadaan> {
  const _MainLingkup({required _MainKeadaan keadaan, required super.child})
    : super(notifier: keadaan);

  static _MainKeadaan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MainLingkup>()!.notifier!;

  static _MainKeadaan baca(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_MainLingkup>()!.notifier!;
}

// ---------- Navigation inside the board ----------

/// Main's Beranda (owner change 21/11): the phone home `/` for a persona
/// whose home is the finance home, else the page `/keuangan` above their own
/// home. Main's child routes keep their paths under `/keuangan`.
String _akar(bool keuangan) =>
    keuangan ? Layar.beranda.jalur : Layar.keuangan.jalur;
final _anakMain = '${Layar.keuangan.jalur}/';

String _akarDari(BuildContext context) => _akar(
  ProviderScope.containerOf(
    context,
    listen: false,
  ).read(berandaKeuanganPonselProvider),
);

/// The Main page on top of Main's own pages.
String _atasMain(GoRouter r) {
  for (final l in tumpukanHalaman(r).reversed) {
    if (l == Layar.beranda.jalur ||
        l == Layar.keuangan.jalur ||
        l.startsWith(_anakMain)) {
      return l;
    }
  }
  return Layar.beranda.jalur;
}

/// "Pop to /Main": pop every Main child page above Main's Beranda [akar],
/// or go there when another page sits between them.
void _keMain(GoRouter r, String akar) {
  var t = tumpukanHalaman(r);
  final i = t.lastIndexWhere((l) => !l.startsWith(_anakMain));
  if (i < 0 || t[i] != akar) {
    r.go(akar);
    return;
  }
  while (t.length > 1 && t.last.startsWith(_anakMain)) {
    r.pop();
    final b = tumpukanHalaman(r);
    if (b.length >= t.length) break;
    t = b;
  }
}

/// Pop to /Main, then push a child view.
void _keAnak(BuildContext context, String anak) {
  final r = GoRouter.of(context);
  _keMain(r, _akarDari(context));
  r.push('$_anakMain$anak');
}

void _keBeranda(BuildContext context) {
  _MainLingkup.baca(context).tutupSheet();
  _keMain(GoRouter.of(context), _akarDari(context));
}

void _bukaDaftar(BuildContext context) {
  if (_atasMain(GoRouter.of(context)) == '${_anakMain}transaksi') return;
  _keAnak(context, 'transaksi');
}

// ---------- Kendali: state, LayarPonsel, overlays ----------

/// Main's Kendali, the phone home's shell (owner change 21/11): it hosts `/`
/// for every persona and draws the finance tab bar, toast and Catat sheet
/// only for a persona whose home is the finance home.
class MainKendali extends ConsumerStatefulWidget {
  const MainKendali({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<MainKendali> createState() => _MainKendaliState();
}

class _MainKendaliState extends ConsumerState<MainKendali> {
  late final _m = _MainKeadaan(
    ProviderScope.containerOf(context, listen: false),
  );

  @override
  void dispose() {
    _m.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final atas = _atasMain(GoRouter.of(context));
    // On a non-finance home `/` the home draws its own bar.
    final tab =
        atas == _akar(ref.watch(berandaKeuanganPonselProvider)) ||
        atas == '${_anakMain}transaksi';
    return _MainLingkup(
      keadaan: _m,
      child: ListenableBuilder(
        listenable: _m,
        builder: (context, child) => LayarPonsel(
          layarKeuangan: true,
          overlay: [
            if (tab)
              PonselTabBar(
                aktif: atas == '${_anakMain}transaksi'
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

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key, this.anak, this.param = const {}});

  /// The child route ('transaksi', 'catat', 'detail/:id', …), null on
  /// Beranda.
  final String? anak;
  final Map<String, String> param;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  String? get _id => widget.param['id'];

  @override
  void initState() {
    super.initState();
    // A link to a transaction that does not exist has nothing to show.
    if (widget.anak == 'detail/:id') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            ref.read(transactionRepositoryProvider).get(_id ?? '') == null) {
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
      'detail/:id' => _Detail(_id ?? ''),
      _ => const _Beranda(),
    };
    final tutupLembar = anak == null || anak == 'transaksi';
    // Main's Beranda is the phone home of a finance persona (owner 21/11).
    final rumah = anak == null && ref.watch(berandaKeuanganPonselProvider);
    return PopScope(
      // An open sheet closes first; a posted Periksa returns to Beranda;
      // Back on the phone home signs out (KeluarSaatKembali).
      canPop:
          !rumah &&
          !(tutupLembar && m.sheet) &&
          !(anak == 'periksa' && m.posted),
      onPopInvokedWithResult: (sudah, _) {
        if (sudah) return;
        if (tutupLembar && m.sheet) {
          m.tutupSheet();
        } else if (rumah) {
          keluarSesi(context);
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

/// A command's refusal as the boards draw it (README 3.4).
Widget _penolakan(Refusal r) => Penolakan(
  tindakan: r.action,
  sebab: r.whoCanAct == null
      ? r.because
      : '${r.because} Yang perlu bertindak: ${r.whoCanAct}.',
  jalan: const [],
  ukuranTeks: 14,
);

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

class _Beranda extends ConsumerWidget {
  const _Beranda();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(berandaKeuanganProvider);
    final c = context.warna;
    final berjalan = b.bulan.berjalan;
    final bulan = berjalan == null ? '' : namaBulan(berjalan);
    final ini = b.bulanIni;
    final pend = ini?.pendapatan ?? 0, bel = ini?.belanja ?? 0;
    // An empty month: nothing booked and no draft in it.
    final sepi = ini == null || ini.dibukukan + ini.draf == 0;
    final tutup = b.perluTindakan.where((x) => x.ke == Layar.tutupBuku);
    final tindakan = [
      for (final x in b.perluTindakan)
        if (x.ke != Layar.tutupBuku) x,
    ];
    final garis = GarisLurus(warna: c.garis);
    // The other modules' rows only on the finance home `/` (owner 21/11).
    final lain = ref.watch(berandaKeuanganPonselProvider)
        ? ref.watch(barisBerandaKeuanganProvider)
        : const <HomeRow>[];

    return _GulirTab(
      jarak: 22,
      anak: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TandaPalakat(),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      ref.watch(workspaceRepositoryProvider).workspace().name,
                      style: const TextStyle(
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
              label: 'Pilih bulan, sekarang $bulan',
              radius: 22,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 999),
                ),
                child: Text(
                  bulan,
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
              rp(b.saldoBuku),
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
            if (b.drafJumlah > 0)
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
                          text: rp(b.drafRp),
                          style: const TextStyle(fontFamily: _mono),
                        ),
                        TextSpan(
                          text: ' · ${b.drafJumlah} draf · belum masuk saldo',
                        ),
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
              for (final (i, a) in b.kasBank.indexed) ...[
                if (i > 0) garis,
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 46),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          a.akun.name,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      Text(
                        rp(a.saldo),
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
                hitungan: b.perluTindakan.isEmpty
                    ? null
                    : b.perluTindakan.length,
              ),
            ),
            if (b.perluTindakan.isNotEmpty)
              Kartu(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final x in tutup)
                      Tautan(
                        ke: x.ke,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 60),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      x.judul,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      x.sub,
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
                              PalakatIkon(
                                Ikon.lanjut,
                                ukuran: 18,
                                warna: c.tinta3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    for (final (i, t) in tindakan.indexed)
                      BarisDaftar(
                        judul: t.judul,
                        keterangan: t.sub,
                        pertama: i == 0 && tutup.isEmpty,
                        onTap: () => t.ke == Layar.transaksi
                            ? _bukaDaftar(context)
                            : Tautan(
                                ke: t.ke,
                                param: t.param,
                                child: const SizedBox(),
                              ).buka(context),
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
                        text:
                            'Belum ada transaksi di '
                            '${bulan.split(' ').first}.',
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
        if (b.untukDiketahui.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              const JudulBagian('Untuk diketahui'),
              for (final x in b.untukDiketahui)
                Tautan(
                  ke: x.ke,
                  param: x.param,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    heightFactor: 1,
                    child: TautanTeks(
                      x.judul,
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
        // The phone home (owner change 21/11): the role-home rows of the
        // other modules after Main's summary, without those it shows.
        ...[
          for (final (judul, k) in [
            ('Perlu tindakan', KelompokBaris.tindak),
            ('Untuk diketahui', KelompokBaris.tahu),
          ])
            if (lain.where((r) => r.kelompok == k).toList() case final baris
                when baris.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: JudulBagian(judul),
                  ),
                  for (final r in baris) KartuBaris(r),
                ],
              ),
        ],
      ],
    );
  }
}

// ---------- C. Transaksi ----------

class _Daftar extends ConsumerWidget {
  const _Daftar();

  static const _chip = [
    (nilai: SaringTransaksi.semua, teks: 'Semua'),
    (nilai: SaringTransaksi.draf, teks: 'Draf'),
    (nilai: SaringTransaksi.dibukukan, teks: 'Dibukukan'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = _MainLingkup.of(context);
    final c = context.warna;
    final b = ref.watch(berandaKeuanganProvider);
    final berjalan = b.bulan.berjalan;
    final bulan = berjalan == null ? '' : namaBulan(berjalan);
    final rows = [
      if (berjalan != null)
        ...ref.watch(
          daftarTransaksiProvider((
            periodId: berjalan.id,
            saring: m.filter,
            accountId: null,
            fundId: null,
          )),
        ),
      if (m.filter != SaringTransaksi.dibukukan)
        ...ref.watch(drafBulanLaluProvider),
    ];
    final tutup = b.drafBulanTutup;

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
                  text: '· $bulan',
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
                if (tutup.isNotEmpty)
                  Tautan(
                    ke: Layar.draf,
                    param: {'id': tutup.first.id},
                    child: _teksTautan(
                      '${tutup.length} draf di bulan yang sudah ditutup',
                    ),
                  ),
                Tautan(ke: Layar.cari, child: _teksTautan('Cari')),
              ],
            ),
          ),
        ),
        ChipPilihan<SaringTransaksi>(
          pilihan: _chip,
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
                Text('Belum ada transaksi yang cocok di $bulan.'),
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
  final BarisTransaksi r;

  /// A posted row opens its detail; a draft the form can hold opens in the
  /// form; any other draft opens on Draf. A cancelled row does not open.
  VoidCallback? _buka(BuildContext context) {
    final t = r.transaksi;
    if (t.isPosted) {
      return () => _keAnak(context, 'detail/${t.id}');
    }
    if (!t.isDraft) return null;
    if (_MainKeadaan.bisaDimuat(t)) {
      return () {
        _MainLingkup.baca(context).muat(t);
        _keAnak(context, 'catat');
      };
    }
    return () => context.dorongKe(Layar.draf, param: {'id': t.id});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final t = r.transaksi;
    final garis = t.isDraft || t.status == TransactionStatus.cancelled;
    final buka = _buka(context);
    final kartu = Kartu(
      status: garis ? GarisStatus.draf : GarisStatus.dibukukan,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8,
            children: [
              LencanaStatus.uang(switch (t.status) {
                TransactionStatus.draft => StatusUang.draf,
                TransactionStatus.reviewed => StatusUang.sudahDiperiksa,
                TransactionStatus.cancelled => StatusUang.dibatalkan,
                TransactionStatus.finalized =>
                  t.isReversed ? StatusUang.dibalik : StatusUang.dibukukan,
              }, jarakHuruf: .3),
              Flexible(
                child: Text(
                  rp(r.jumlah),
                  style: TextStyle(
                    fontFamily: _mono,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: garis ? c.tinta3 : c.tinta,
                  ),
                ),
              ),
            ],
          ),
          Text(
            t.description,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: r.nomor,
                  style: const TextStyle(fontFamily: _mono),
                ),
                TextSpan(text: ' · ${r.tanggal} · ${r.kasBank}'),
              ],
            ),
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
          if (r.catatan != null)
            Text(r.catatan!, style: TextStyle(fontSize: 13, color: c.tinta2)),
        ],
      ),
    );
    return buka == null ? kartu : Tekan(onTap: buka, radius: 14, child: kartu);
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
                  _keAnak(context, 'catat');
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
