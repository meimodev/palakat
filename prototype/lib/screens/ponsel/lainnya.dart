import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/ponsel_tab_bar.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/sakelar.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/pengaturan.dart';
import '../../providers/repositories_keuangan.dart';
import '../../widgets/penolakan.dart';

/// Group card C: every row is a push link.
const _tautanC = [
  (
    judul: 'Laporan',
    ket: 'Paket Laporan Bulanan GMIM · F01 sampai F14',
    ke: Layar.laporan,
    param: <String, String>{},
  ),
  (
    judul: 'Daftar Bukti Kas',
    ket: 'Semua No. Bukti dan celah nomor',
    ke: Layar.bukti,
    param: <String, String>{},
  ),
  (
    judul: 'Uang Muka dan Titipan',
    ket: 'Uang yang masih berjalan',
    ke: Layar.kewajiban,
    param: <String, String>{},
  ),
  (
    judul: 'Impor',
    ket: 'Dari file Excel atau CSV',
    ke: Layar.impor,
    param: <String, String>{},
  ),
  (
    judul: 'Ekspor data Jemaat',
    ket: 'Salinan lengkap milik Jemaat',
    ke: Layar.ekspor,
    param: <String, String>{},
  ),
  (
    judul: 'Dokumen pendukung',
    ket: 'Verifikasi, pengecualian, dokumen susulan',
    ke: Layar.dokumen,
    param: <String, String>{},
  ),
  (
    judul: 'Pernyataan kesiapan',
    ket: 'Per peruntukan · setelah ada bendahara unit (Putaran 5)',
    ke: Layar.kesiapan,
    param: <String, String>{},
  ),
  (
    judul: 'Kejadian setelah tutup buku',
    ket: 'Catatan tentang bulan yang sudah ditutup',
    ke: Layar.kejadian,
    param: <String, String>{},
  ),
  (
    judul: 'Persetujuan format laporan',
    ket: '',
    ke: Layar.formatLaporan,
    param: <String, String>{},
  ),
  (
    judul: 'Cari',
    ket: 'Dengan kata sehari-hari',
    ke: Layar.cari,
    param: <String, String>{},
  ),
  (
    judul: 'Pemberitahuan',
    ket: 'Sementara',
    ke: Layar.pemberitahuan,
    param: <String, String>{},
  ),
  (
    judul: 'Tambah dan ubah pengaturan',
    ket: 'Kas/Bank, seri No. Bukti, aturan · berlaku mulai bulan tertentu',
    ke: Layar.ubahPengaturan,
    param: <String, String>{},
  ),
  (
    judul: 'Wajib pemeriksa kedua',
    ket: 'Aturan pilihan Jemaat',
    ke: Layar.pemeriksa,
    param: <String, String>{},
  ),
  (
    judul: 'Akun dan keluar',
    ket: '',
    ke: Layar.keluar,
    param: <String, String>{},
  ),
];

// ---------- Board state ----------

class _Keadaan extends ChangeNotifier {
  /// The account whose Nonaktifkan sheet is open.
  String? sheet;
  Tanggal? bulan;
  Refusal? tolak;

  void buka(String id) {
    sheet = id;
    bulan = null;
    tolak = null;
    notifyListeners();
  }

  void pick(Tanggal b) {
    bulan = b;
    notifyListeners();
  }

  void tutupSheet() {
    sheet = null;
    tolak = null;
    notifyListeners();
  }

  void tolakan(Refusal? r) {
    tolak = r;
    if (r == null) sheet = null;
    notifyListeners();
  }
}

class _Lingkup extends InheritedNotifier<_Keadaan> {
  const _Lingkup({required _Keadaan super.notifier, required super.child});
  static _Keadaan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
  static _Keadaan baca(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

/// Owns the board state and the phone root (strip, Nonaktifkan sheet) above
/// the child routes `/Lainnya/kas`, `/aturan`, `/riwayat`.
class LainnyaKendali extends StatefulWidget {
  const LainnyaKendali({super.key, required this.child});
  final Widget child;
  @override
  State<LainnyaKendali> createState() => _LainnyaKendaliState();
}

class _LainnyaKendaliState extends State<LainnyaKendali> {
  final _k = _Keadaan();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    notifier: _k,
    child: Material(
      type: MaterialType.transparency,
      child: ListenableBuilder(
        listenable: _k,
        builder: (context, _) => LayarPonsel(
          overlay: [if (_k.sheet != null) _LembarNonaktifkan(k: _k)],
          child: widget.child,
        ),
      ),
    ),
  );
}

class LainnyaScreen extends StatelessWidget {
  const LainnyaScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.warna.kertas,
    child: switch (anak) {
      'kas' => const _KasBank(),
      'aturan' => const _Aturan(),
      'riwayat' => const _Riwayat(),
      _ => const _Hub(),
    },
  );
}

// ---------- Shared pieces ----------

TextStyle _judulBaris() =>
    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15);

/// `keHub`: pop to `/Lainnya` (closes the sheet too).
void _keHub(BuildContext context) {
  _Lingkup.baca(context).tutupSheet();
  context.naikKe(Layar.pengaturan);
}

/// Inner view: header with back, then [isi] filling the rest.
class _Dalam extends StatelessWidget {
  const _Dalam({required this.judul, required this.isi});
  final String judul;
  final Widget isi;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      KepalaPonsel(judul: judul, onKembali: () => _keHub(context)),
      Expanded(child: isi),
    ],
  );
}

/// A static row of a group card: min height 60, centred column, rule above.
class _BarisTetap extends StatelessWidget {
  const _BarisTetap({required this.judul, required this.ket});
  final String judul;
  final InlineSpan ket;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GarisLurus(warna: c.garis),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul, style: _judulBaris()),
              Text.rich(ket, style: TextStyle(fontSize: 13, color: c.tinta3)),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _grup(List<Widget> baris) => Kartu(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Column(children: baris),
);

// ---------- Hub ----------

class _Hub extends ConsumerWidget {
  const _Hub();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = ref.watch(pengaturanProvider);
    final bendahara = ref.watch(postBendaharaProvider);
    final pemegang = bendahara?.holder;
    final orang = ref.watch(peopleRepositoryProvider);
    final format = ref
        .watch(reportRepositoryProvider)
        .templates()
        .where((t) => t.acceptedAt != null)
        .firstOrNull;
    final saya = ref.watch(actorProvider);
    const mono = TextStyle(fontFamily: PalakatText.mono);
    Tautan ruteMain(Widget isi) =>
        Tautan(ke: Layar.keuangan, cara: Cara.ganti, child: isi);

    final isi = <Widget>[
      Semantics(
        header: true,
        child: const Text(
          'Lainnya',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(
              p.jemaat,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            Text(
              'WITA · tahun buku mulai 1 Januari (tidak dapat diubah)',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Text(
              'Tanggal mulai pencatatan ${tglPanjang(p.mulai.awal)}',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
      ),
      Text(
        'Pengaturan tidak diubah di tempat. Setiap perubahan berlaku mulai '
        'bulan tertentu dan tidak mengubah transaksi yang sudah dibukukan.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      _grup([
        BarisDaftar(
          judul: 'Kas/Bank',
          keterangan: '${p.kasAktif} aktif · ${p.kasMati} nonaktif',
          pertama: true,
          onTap: () => context.dorongKe(Layar.pengaturan, anak: 'kas'),
        ),
        _BarisTetap(
          judul: 'Peruntukan',
          ket: TextSpan(text: p.peruntukan.join(' · ')),
        ),
        _BarisTetap(
          judul: 'Lingkup',
          ket: TextSpan(text: p.lingkup.join(' · ')),
        ),
        Tautan(
          ke: Layar.mataAnggaran,
          child: BarisDaftar(
            judul: 'Mata Anggaran',
            keterangan: p.teksMataAnggaran,
          ),
        ),
        _BarisTetap(
          judul: 'Seri No. Bukti',
          ket: TextSpan(
            children: [
              TextSpan(
                text: voucherCode(VoucherSeries.bku, p.hariIni.tahun, 1),
                style: mono,
              ),
              TextSpan(text: ' Biasa · '),
              TextSpan(text: 'OPN', style: mono),
              TextSpan(text: ' Saldo awal pencatatan · '),
              TextSpan(text: 'ADJ', style: mono),
              TextSpan(text: ' Penyesuaian'),
            ],
          ),
        ),
      ]),
      _grup([
        BarisDaftar(
          judul: 'Aturan persetujuan dan dokumen pendukung',
          keterangan: p.teksPemeriksa,
          pertama: true,
          onTap: () => context.dorongKe(Layar.pengaturan, anak: 'aturan'),
        ),
        _BarisTetap(
          judul: 'Format laporan',
          ket: TextSpan(
            text:
                'Bawaan Palakat v1 · Persetujuan format: '
                '${format == null ? 'belum dicatat' : 'sudah dicatat'}',
          ),
        ),
        Tautan(
          ke: Layar.bendahara,
          child: BarisDaftar(
            judul: 'Bendahara dan sesi',
            keterangan: pemegang == null
                ? 'Belum ada Bendahara aktif'
                : '${orang.person(pemegang.personId)?.name ?? ''} · '
                      'Wewenang Bendahara aktif',
          ),
        ),
        BarisDaftar(
          judul: 'Riwayat aktivitas',
          keterangan: 'Siapa melakukan apa, dan kapan',
          onTap: () => context.dorongKe(Layar.pengaturan, anak: 'riwayat'),
        ),
      ]),
      _grup([
        for (final (i, t) in _tautanC.indexed)
          Tautan(
            ke: t.ke,
            param: t.param,
            child: BarisDaftar(
              judul: t.judul,
              keterangan: switch (t.ke) {
                Layar.formatLaporan =>
                  format == null
                      ? 'Belum dicatat'
                      : 'Sudah dicatat · ${tgl(format.acceptedAt!)}',
                Layar.keluar =>
                  '${orang.person(saya?.personId ?? '')?.name ?? ''} · '
                      'perangkat ini',
                _ => t.ket,
              },
              pertama: i == 0,
            ),
          ),
      ]),
    ];

    return Stack(
      children: [
        Positioned.fill(
          bottom: 84,
          child: Gerak(
            Kerangka.pudar,
            lama: const Duration(milliseconds: 200),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 18,
                children: isi,
              ),
            ),
          ),
        ),
        PonselTabBar(
          aktif: TabPonsel.lainnya,
          diameterCatat: 66,
          beranda: ruteMain,
          transaksi: ruteMain,
          catat: (isi) => Tautan(
            ke: Layar.keuangan,
            cara: Cara.ganti,
            label: 'Catat transaksi',
            radius: 33,
            child: isi,
          ),
        ),
      ],
    );
  }
}

// ---------- Kas/Bank ----------

class _KasBank extends ConsumerWidget {
  const _KasBank();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    final p = ref.watch(pengaturanProvider);
    // An open sheet takes system Back first (navigation.md 5.1).
    return PopScope(
      canPop: k.sheet == null,
      onPopInvokedWithResult: (sudah, _) {
        if (!sudah) k.tutupSheet();
      },
      child: _Dalam(
        judul: 'Kas/Bank',
        isi: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              for (final x in p.kas) _kartuKas(context, k, x),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Kas/Bank yang sudah dipakai tidak dapat dihilangkan, hanya '
                  'dinonaktifkan. Yang nonaktif tetap tampil di transaksi dan '
                  'laporan lamanya.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kartuKas(BuildContext context, _Keadaan k, BarisKasBank x) {
    final c = context.warna;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Kartu(
        status: (x.mati || x.akanMati)
            ? GarisStatus.draf
            : GarisStatus.dibukukan,
        isi: x.mati ? null : c.permukaan,
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    x.akun.name,
                    style: _judulBaris().copyWith(
                      color: x.mati ? c.tinta2 : c.tinta,
                    ),
                  ),
                  Text(x.sub, style: TextStyle(fontSize: 13, color: c.tinta3)),
                ],
              ),
            ),
            if (x.bisaNonaktif)
              Tekan(
                onTap: () => k.buka(x.akun.id),
                radius: 10,
                child: RupaTombol(
                  label: 'Nonaktifkan',
                  isi: c.permukaan,
                  garis: GarisBorder.penuh(c.garisTegas, radius: 10),
                  warnaTeks: c.tinta,
                  radius: 10,
                  tinggi: 44,
                  paddingH: 12,
                  lebarPenuh: false,
                  ukuranTeks: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LembarNonaktifkan extends ConsumerWidget {
  const _LembarNonaktifkan({required this.k});
  final _Keadaan k;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = ref.watch(pengaturanProvider);
    final x = p.kas.where((x) => x.akun.id == k.sheet).firstOrNull;
    if (x == null) return const SizedBox.shrink();
    final bulan = k.bulan ?? p.bulanBerlaku.first;
    Future<void> nonaktifkan() async {
      final r = await jalankanPengaturan(
        ref,
        (a, kunci) => ref
            .read(accountRepositoryProvider)
            .deactivate(
              a,
              x.akun.id,
              bulan,
              reason: 'Tidak dipakai lagi',
              expectedRevision: x.akun.revision,
              idempotencyKey: kunci,
            ),
      );
      k.tolakan(r);
    }

    return LembarBawah(
      judul: 'Nonaktifkan ${x.akun.name}',
      anakJudul: 'Transaksi lama tidak berubah dan tetap tampil di laporannya.',
      labelTirai: 'Kembali ke daftar Kas/Bank',
      onTutup: k.tutupSheet,
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChipPilihan<Tanggal>(
              label: 'Berlaku mulai',
              pilihan: [
                for (final b in p.bulanBerlaku) (nilai: b, teks: bulanDari(b)),
              ],
              terpilih: bulan,
              onPilih: k.pick,
              jarakBaris: 0,
            ),
            const SizedBox(height: 8),
            Text(
              'Hanya bulan yang belum ditutup dan belum berjalan.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
        if (k.tolak != null)
          Penolakan(
            tindakan: k.tolak!.action,
            sebab: k.tolak!.because,
            jalan: const [],
          ),
        Tombol(
          'Nonaktifkan mulai ${bulanDari(bulan)}',
          jenis: JenisTombol.tinta,
          onPressed: nonaktifkan,
        ),
        Tombol(
          'Kembali',
          jenis: JenisTombol.teks,
          warnaTeks: c.tinta,
          onPressed: k.tutupSheet,
        ),
      ],
    );
  }
}

// ---------- Aturan ----------

/// The second-checker switch, shared with WebPengaturan: the value from M+1
/// (a scheduled change, else today's); switching it schedules the change
/// from the 1st of M+1 (D24).
class SakelarPemeriksa extends ConsumerStatefulWidget {
  const SakelarPemeriksa({super.key, this.nonaktif = false});
  final bool nonaktif;

  @override
  ConsumerState<SakelarPemeriksa> createState() => _SakelarPemeriksaState();
}

class _SakelarPemeriksaState extends ConsumerState<SakelarPemeriksa> {
  Refusal? _tolak;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = ref.watch(pengaturanProvider);
    final j = p.jadwalPemeriksa;
    final nanti = j?.on ?? p.pemeriksa;
    final berubah = j != null && j.on != p.pemeriksa;
    final mulai = j?.effectiveFrom ?? p.bulanBerlaku.first;
    final kini = bulanDari(mulai.tambahHari(-1));
    final sub = berubah
        ? '${nanti ? 'Hidup' : 'Mati'} mulai ${bulanDari(mulai)}'
        : nanti
        ? 'Hidup · Bukukan memerlukan orang kedua yang menandai sudah '
              'diperiksa'
        : 'Mati · Bendahara memeriksa dan membukukan sendiri';
    Future<void> ubah(bool v) async {
      final r = await jalankanPengaturan(
        ref,
        (a, kunci) => ref
            .read(settingsRepositoryProvider)
            .setRule(
              a,
              FinanceRule.secondChecker,
              v,
              p.bulanBerlaku.first,
              reason: '',
              expectedRevision: p.revisiPemeriksa,
              idempotencyKey: kunci,
            ),
      );
      if (mounted) setState(() => _tolak = r);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wajib pemeriksa kedua', style: _judulBaris()),
                  Text(sub, style: TextStyle(fontSize: 13, color: c.tinta3)),
                ],
              ),
            ),
            Sakelar(
              nilai: nanti,
              onUbah: ubah,
              nonaktif: widget.nonaktif,
              label: 'Wajib pemeriksa kedua',
            ),
          ],
        ),
        if (_tolak != null)
          Penolakan(
            tindakan: _tolak!.action,
            sebab: _tolak!.because,
            jalan: const [],
          ),
        if (berubah)
          Gerak(
            Kerangka.muncul,
            key: ValueKey(nanti),
            lama: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.garis)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Berlaku mulai ${bulanDari(mulai)}.',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: nanti
                              ? ' Sejak itu, Bukukan memerlukan orang kedua '
                                    'yang menandai sudah diperiksa. Pemeriksa '
                                    'kedua tidak boleh orang yang mencatat.'
                              : ' Sejak itu, Bendahara memeriksa dan '
                                    'membukukan sendiri. Sampai akhir $kini, '
                                    'Bukukan tetap memerlukan pemeriksa kedua.',
                        ),
                      ],
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Transaksi $kini dan sebelumnya tidak terpengaruh.',
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Aturan extends ConsumerWidget {
  const _Aturan();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = ref.watch(pengaturanProvider);
    Widget baris(String judul, String teks, {bool pertama = false}) =>
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: pertama
              ? null
              : BoxDecoration(
                  border: Border(top: BorderSide(color: c.garis)),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(judul, style: _judulBaris()),
              Text(teks, style: TextStyle(fontSize: 14, color: c.tinta2)),
            ],
          ),
        );

    return _Dalam(
      judul: 'Aturan',
      isi: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Kartu(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  baris(
                    'Persetujuan di luar aplikasi',
                    'Wajib untuk Belanja Rp2.000.000 ke atas · berlaku mulai '
                        '${bulanDari(p.mulai)}',
                    pertama: true,
                  ),
                  baris(
                    'Dokumen pendukung',
                    'Wajib untuk semua Belanja · Bendahara boleh memverifikasi '
                        'unggahannya sendiri',
                  ),
                  baris('Pemberi pengecualian', 'Ketua BPMJ'),
                ],
              ),
            ),
            const Kartu(child: SakelarPemeriksa()),
          ],
        ),
      ),
    );
  }
}

// ---------- Riwayat aktivitas ----------

class _Riwayat extends ConsumerWidget {
  const _Riwayat();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final riwayat = ref.watch(pengaturanProvider).riwayat.take(40).toList();
    return _Dalam(
      judul: 'Riwayat aktivitas',
      isi: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, r) in riwayat.map(barisRiwayat).indexed)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: i == 0
                    ? null
                    : BoxDecoration(
                        border: Border(top: BorderSide(color: c.garis)),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.judul, style: _judulBaris()),
                    Text(
                      r.waktu,
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
