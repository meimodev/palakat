import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../motion/ulang.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/pita_peran.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

const _namaAwal = 'Yohanis Tumbelaka';
const _sesiAwal = ['Ponsel ini', 'Chrome di laptop'];
const _subSesi = {
  'Ponsel ini': 'Sesi ini · aktif sekarang',
  'Chrome di laptop': 'Terakhir dipakai 14/11/2026 20.15',
};
const _isiNama = 'Isi nama yang ditunjuk.';

/// The board's state object, held above its child routes (spec 04, Bendahara).
class _Papan extends ChangeNotifier {
  String tahap = 'belum', nama = _namaAwal;
  List<String> sesi = [..._sesiAwal];
  Timer? _t;

  bool get aktif => tahap == 'aktif';
  bool get okNama => nama.trim().isNotEmpty;

  void ubah(VoidCallback f) {
    f();
    notifyListeners();
  }

  void kirim() {
    if (!okNama) return;
    tahap = 'tunggu';
    _t?.cancel();
    // Stands for the Petugas verifikasi checking the letter; runs on while
    // the Utama view is shown.
    _t = Timer(
      const Duration(milliseconds: 2800),
      () => ubah(() => tahap = 'aktif'),
    );
    notifyListeners();
  }

  void ulang() {
    _t?.cancel();
    tahap = 'belum';
    nama = _namaAwal;
    sesi = [..._sesiAwal];
    notifyListeners();
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }
}

class _Lingkup extends InheritedNotifier<_Papan> {
  const _Lingkup({required _Papan papan, required super.child})
    : super(notifier: papan);

  static _Papan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

class BendaharaKendali extends StatefulWidget {
  const BendaharaKendali({super.key, required this.child});
  final Widget child;
  @override
  State<BendaharaKendali> createState() => _BendaharaKendaliState();
}

class _BendaharaKendaliState extends State<BendaharaKendali> {
  final _papan = _Papan();

  @override
  void dispose() {
    _papan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    papan: _papan,
    child: LayarPonsel(child: widget.child),
  );
}

class BendaharaScreen extends StatelessWidget {
  const BendaharaScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) {
    final kosong =
        belumDipindah<String>('Bendahara aktif') != 'Bendahara aktif';
    return ColoredBox(
      color: context.warna.kertas,
      // CSS splits a line's leading evenly above and below the glyphs.
      child: DefaultTextHeightBehavior(
        textHeightBehavior: const TextHeightBehavior(
          leadingDistribution: TextLeadingDistribution.even,
        ),
        child: kosong
            ? const _Kosong()
            : anak == 'serah'
            ? const _Serah()
            : const _Utama(),
      ),
    );
  }
}

/// Max-content width of one line of [teks] in the phone's 16 px sans merged
/// with [gaya].
double _lebarTeks(BuildContext context, String teks, TextStyle gaya) {
  final tp = TextPainter(
    text: TextSpan(
      text: teks,
      style: const TextStyle(
        fontFamily: PalakatText.sans,
        fontSize: 16,
      ).merge(gaya),
    ),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final w = tp.width;
  tp.dispose();
  return w.ceilToDouble();
}

/// CSS `display: flex; justify-content: space-between; align-items: center`
/// with two `flex: 0 1 auto` items: when they do not fit, each shrinks in
/// proportion to its max-content [lebar] and its text wraps.
class _BarisSusut extends StatelessWidget {
  const _BarisSusut({
    required this.kiri,
    required this.lebarKiri,
    required this.kanan,
    required this.lebarKanan,
    this.jarak = 8,
  });

  final Widget kiri, kanan;
  final double lebarKiri, lebarKanan, jarak;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(flex: (lebarKiri * 10).round(), child: kiri),
      SizedBox(width: jarak),
      Flexible(flex: (lebarKanan * 10).round(), child: kanan),
    ],
  );
}

/// A badge that may wrap: 13/700, radius 6.
class _Lencana extends StatelessWidget {
  const _Lencana(
    this.teks, {
    required this.isi,
    required this.warnaTeks,
    this.garis,
  });

  final String teks;
  final Color? isi;
  final Color warnaTeks;

  /// null: no line, padding 4 10; else the 1.5 line, padding 3 9.
  final GarisBorder? garis;

  static const gaya = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);

  /// Max-content width including padding and line.
  static double lebar(BuildContext context, String teks) =>
      _lebarTeks(context, teks, gaya) + 20;

  @override
  Widget build(BuildContext context) => Container(
    padding: garis == null
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: ShapeDecoration(
      color: isi,
      shape:
          garis ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    child: Text(teks, style: gaya.copyWith(color: warnaTeks)),
  );
}

// ---------------------------------------------------------------- Kosong

class _Kosong extends StatelessWidget {
  const _Kosong();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    Widget baris(String label, Widget nilai, double lebarNilai, bool garis) {
      const gayaLabel = TextStyle(fontSize: 14);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: garis ? Border(top: BorderSide(color: c.garis)) : null,
        ),
        child: _BarisSusut(
          jarak: 16,
          kiri: Text(label, style: gayaLabel.copyWith(color: c.tinta2)),
          lebarKiri: _lebarTeks(context, label, gayaLabel),
          kanan: nilai,
          lebarKanan: lebarNilai,
        ),
      );
    }

    const gayaMono = TextStyle(
      fontFamily: PalakatText.mono,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    const gayaNilai = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PitaPeran(
            jenis: JenisPita.kunci,
            judul: 'Belum ada Bendahara aktif',
            kalimat: 'Wewenang Meiske Lumentut dicabut pada 16/11/2026 08.10 oleh Petugas verifikasi, atas permintaan BPMJ. Semua sesinya sudah diakhiri.',
            radius: 16,
            padding: const EdgeInsets.all(18),
            ukuranJudul: 19,
            jarak: 8,
            anak: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Yang perlu bertindak: BPMJ Jemaat Karunia.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.permukaan,
                      ),
                    ),
                    const TextSpan(
                      text: ' BPMJ menunjuk Bendahara baru dan mengirim surat penunjukannya untuk diverifikasi.',
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Sementara itu, Operator Jemaat dapat ',
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      // 44 px target drawn in the 19.6 px text line.
                      child: MarginNegatif(
                        bawah: 44 - 14 * 1.4,
                        child: Tautan(
                          ke: Layar.jabatanKosong,
                          child: TautanTeks(
                            'menjalankan jabatan kosong',
                            berat: FontWeight.w700,
                            warna: c.permukaan,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(
                      text: ' ini. Setiap tindakannya tercatat atas namanya.',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Semua data hanya dapat dilihat.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' Mencatat, membukukan, rekonsiliasi dan tutup buku tidak tersedia sampai ada Bendahara aktif.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: c.permukaan,
              border: Border.all(color: c.garis),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                baris(
                  'Saldo buku semua Kas/Bank',
                  const Text('Rp38.415.000', style: gayaMono),
                  _lebarTeks(context, 'Rp38.415.000', gayaMono),
                  false,
                ),
                baris(
                  'Draf yang tertinggal',
                  const Text('2 · belum masuk saldo', style: gayaNilai),
                  _lebarTeks(context, '2 · belum masuk saldo', gayaNilai),
                  true,
                ),
                baris(
                  'Bulan berikutnya untuk tutup buku',
                  const Text('Oktober 2026', style: gayaNilai),
                  _lebarTeks(context, 'Oktober 2026', gayaNilai),
                  true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Riwayat tetap mencatat Meiske Lumentut sebagai pelaku semua tindakannya. Bendahara baru tidak mewarisi persetujuan yang pernah dicatat.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- Utama

class _Utama extends StatelessWidget {
  const _Utama();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final aktif = p.aktif;
    final namaAktif = aktif ? p.nama : 'Meiske Lumentut';
    const gayaNama = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    const badge = 'Wewenang Bendahara aktif';
    final sesi = aktif
        ? [
            (
              n: 'Belum ada sesi',
              s: 'Semua sesi Meiske Lumentut diakhiri 16/11/2026',
              bisa: false,
            ),
          ]
        : [
            for (final n in p.sesi)
              (n: n, s: _subSesi[n]!, bisa: n != 'Ponsel ini'),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Bendahara dan sesi',
          kembaliKe: Layar.pengaturan,
          labelKembali: 'Kembali ke Lainnya',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    color: c.permukaan,
                    shape: GarisBorder.penuh(c.tinta, radius: 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BarisSusut(
                        kiri: Text(namaAktif, style: gayaNama),
                        lebarKiri: _lebarTeks(context, namaAktif, gayaNama),
                        kanan: _Lencana(
                          badge,
                          isi: c.laut,
                          warnaTeks: c.diLaut,
                        ),
                        lebarKanan: _Lencana.lebar(context, badge),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        aktif
                            ? 'Aktif sejak 16/11/2026 · SK-BPMJ-09-2026'
                            : 'Aktif sejak 15/09/2026 · SK-BPMJ-04-2026',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                      if (aktif) ...[
                        const SizedBox(height: 12),
                        GarisLurus(warna: c.garisTegas, gaya: GayaGaris.putus),
                        const SizedBox(height: 8),
                        Text(
                          'Sebelumnya: Meiske Lumentut · wewenang berakhir 16/11/2026. Riwayat tetap mencatatnya sebagai pelaku.',
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Semantics(
                  header: true,
                  child: const Text(
                    'Sesi yang sedang masuk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: c.permukaan,
                    border: Border.all(color: c.garis),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < sesi.length; i++)
                        Container(
                          constraints: const BoxConstraints(minHeight: 60),
                          decoration: BoxDecoration(
                            border: i > 0
                                ? Border(top: BorderSide(color: c.garis))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sesi[i].n,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      sesi[i].s,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: c.tinta3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (sesi[i].bisa) ...[
                                const SizedBox(width: 12),
                                Tekan(
                                  onTap: () {
                                    final n = sesi[i].n;
                                    p.ubah(
                                      () => p.sesi = [
                                        for (final x in p.sesi)
                                          if (x != n) x,
                                      ],
                                    );
                                  },
                                  radius: 10,
                                  child: RupaTombol(
                                    label: 'Akhiri sesi',
                                    isi: c.permukaan,
                                    garis: GarisBorder.penuh(
                                      c.garisTegas,
                                      radius: 10,
                                    ),
                                    warnaTeks: c.tinta,
                                    radius: 10,
                                    tinggi: 44,
                                    paddingH: 12,
                                    lebarPenuh: false,
                                    ukuranTeks: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (!aktif) ...[
                  const SizedBox(height: 18),
                  Tombol(
                    'Serah terima Bendahara',
                    onPressed: () =>
                        context.dorongKe(Layar.bendahara, anak: 'serah'),
                    jenis: JenisTombol.kedua,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pemulihan akun mengembalikan akses orang yang sama dan tidak memerlukan penunjukan baru. Mengganti orangnya selalu lewat serah terima.',
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- Serah

class _Serah extends StatefulWidget {
  const _Serah();

  @override
  State<_Serah> createState() => _SerahState();
}

class _SerahState extends State<_Serah> {
  late final TextEditingController _nama = TextEditingController(
    text: _Lingkup.of(context).nama,
  );

  @override
  void dispose() {
    _nama.dispose();
    super.dispose();
  }

  void _keUtama() => context.naikKe(Layar.bendahara);

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final aktif = p.aktif,
        tunggu = p.tahap == 'tunggu',
        belum = !aktif && !tunggu;
    const gayaNama = TextStyle(fontWeight: FontWeight.w700);
    const tebal = TextStyle(fontWeight: FontWeight.w700);

    final lamaTeks = aktif ? 'Wewenang berakhir' : 'Wewenang Bendahara aktif';
    final baruTeks = aktif
        ? 'Wewenang Bendahara aktif'
        : tunggu
        ? 'Menunggu verifikasi wewenang'
        : 'Belum dikirim';
    Widget lencanaLaut(String t) => _Lencana(
      t,
      isi: c.laut,
      warnaTeks: c.diLaut,
      garis: GarisBorder.penuh(c.laut, radius: 6),
    );

    final lama = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(aktif ? c.tinta3 : c.tinta, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BarisSusut(
            kiri: const Text('Meiske Lumentut', style: gayaNama),
            lebarKiri: _lebarTeks(context, 'Meiske Lumentut', gayaNama),
            kanan: aktif
                ? _Lencana(
                    lamaTeks,
                    isi: c.permukaan,
                    warnaTeks: c.tinta2,
                    garis: GarisBorder.penuh(c.tinta3, radius: 6),
                  )
                : lencanaLaut(lamaTeks),
            lebarKanan: _Lencana.lebar(context, lamaTeks) + 3,
          ),
          Text(
            aktif
                ? 'Berakhir 16/11/2026 · semua sesi diakhiri'
                : 'Tetap aktif sampai Bendahara baru diverifikasi',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    );

    final Widget isiBaru;
    if (belum) {
      isiBaru = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IsianTeks(
            controller: _nama,
            label: 'Nama yang ditunjuk',
            jarakLabel: 6,
            onChanged: (v) => p.ubah(() => p.nama = v),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Surat penunjukan baru: '),
                TextSpan(
                  // U+200B: Chrome also breaks after "09-"; Flutter (UAX 14)
                  // never breaks a hyphen before a digit.
                  text: 'SK-BPMJ-09-\u200B2026.pdf · Terlampir',
                  style: tebal.copyWith(color: c.tinta),
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ],
      );
    } else if (tunggu) {
      isiBaru = Row(
        children: [
          Putar(
            periode: const Duration(seconds: 6),
            child: SizedBox(
              width: 34,
              height: 34,
              child: CustomPaint(painter: _Lingkaran(c.tinta)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: p.nama, style: tebal),
                    const TextSpan(
                      text: ' · menunggu Petugas verifikasi memeriksa surat penunjukan.',
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      );
    } else {
      isiBaru = Gerak(
        Kerangka.muncul,
        key: const ValueKey('aktif'),
        lama: const Duration(milliseconds: 300),
        child: Semantics(
          liveRegion: true,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: p.nama, style: tebal),
                const TextSpan(
                  text: ' · aktif sejak 16/11/2026 · SK-BPMJ-09-2026',
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    final baru = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: aktif ? c.permukaan : null,
        shape: aktif
            ? GarisBorder.penuh(c.tinta, radius: 14)
            : GarisBorder.putus(c.putus, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BarisSusut(
            kiri: const Text('Bendahara baru', style: gayaNama),
            lebarKiri: _lebarTeks(context, 'Bendahara baru', gayaNama),
            kanan: aktif
                ? lencanaLaut(baruTeks)
                : _Lencana(
                    baruTeks,
                    isi: null,
                    warnaTeks: c.tinta2,
                    garis: GarisBorder.putus(c.putus, radius: 6),
                  ),
            lebarKanan: _Lencana.lebar(context, baruTeks) + 3,
          ),
          const SizedBox(height: 10),
          isiBaru,
        ],
      ),
    );

    final penjelas = Padding(
      padding: const EdgeInsets.only(top: 14),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 14, color: c.tinta2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, t) in const [
              'Yang terjadi saat wewenang berpindah',
              'Semua sesi Bendahara lama diakhiri saat itu juga.',
              'Bendahara baru tidak mewarisi persetujuan yang pernah dicatat Bendahara lama.',
              'Riwayat tetap mencatat Bendahara lama sebagai pelaku tindakannya.',
              'Sampai verifikasi selesai, Bendahara lama tetap aktif. Tidak pernah ada dua Bendahara aktif.',
            ].indexed) ...[
              if (i > 0) const SizedBox(height: 6),
              Text(
                t,
                style: i == 0
                    ? TextStyle(fontWeight: FontWeight.w700, color: c.tinta)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );

    final List<Widget> aksi = belum
        ? [
            if (!p.okNama) ...[
              Text(_isiNama, style: TextStyle(fontSize: 14, color: c.tinta2)),
              const SizedBox(height: 8),
            ],
            TombolBersyarat(
              label: 'Kirim untuk diverifikasi',
              tindakan: 'Kirim untuk diverifikasi',
              alasan: p.okNama ? '' : _isiNama,
              periksa: () => p.okNama ? '' : _isiNama,
              onPressed: p.kirim,
              // The board's own sentence sits above; no "Tidak dapat …" form.
              sudahMulai: false,
              warnaSiap: JenisTombol.utama,
              teksBelumRedup: true,
            ),
          ]
        : tunggu
        ? [
            Container(
              constraints: const BoxConstraints(minHeight: 52),
              alignment: Alignment.center,
              child: Text(
                'Menunggu verifikasi wewenang. Tidak ada yang perlu Anda lakukan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ),
          ]
        : [
            Gerak(
              Kerangka.muncul,
              key: const ValueKey('lihat'),
              lama: const Duration(milliseconds: 300),
              child: Tombol(
                'Lihat Bendahara dan sesi',
                onPressed: _keUtama,
                jenis: JenisTombol.kedua,
              ),
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(judul: 'Serah terima Bendahara', onKembali: _keUtama),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                lama,
                const SizedBox(height: 6),
                // RangkaianKoreksi "linked to": 2 × 22 tinta, 28 from the left.
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 2,
                      height: 22,
                      child: ColoredBox(color: c.tinta),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                baru,
                const SizedBox(height: 6),
                penjelas,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: aksi,
          ),
        ),
      ],
    );
  }
}

/// The waiting spinner: viewBox 88, circle r 38, stroke 6, dash 9 10.
class _Lingkaran extends CustomPainter {
  _Lingkaran(this.warna);
  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 88;
    final r = 38 * s;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    final pena = Paint()
      ..color = warna
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * s;
    final keliling = 2 * math.pi * 38;
    // SVG starts the dash at 3 o'clock and runs clockwise.
    for (var d = 0.0; d < keliling; d += 19) {
      final panjang = math.min(9.0, keliling - d);
      canvas.drawArc(rect, d / 38, panjang / 38, false, pena);
    }
  }

  @override
  bool shouldRepaint(_Lingkaran old) => old.warna != warna;
}
