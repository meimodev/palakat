import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/pengaturan.dart';
import '../../widgets/penolakan.dart';
import '../p2/akun_saya.dart';

const _namaAwal = 'Yohanis Tumbelaka';
const _isiNama = 'Isi nama yang ditunjuk.';

/// The board's UI state, held above its child routes (spec 04, Bendahara):
/// the typed successor and a refusal. The handover itself is
/// RoleRepository's (DP39); the Petugas verifikasi timer is the
/// repository's.
class _Papan extends ChangeNotifier {
  String nama = _namaAwal;
  Refusal? tolak;

  bool get okNama => nama.trim().isNotEmpty;

  void ubah(VoidCallback f) {
    f();
    notifyListeners();
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

class BendaharaScreen extends ConsumerWidget {
  const BendaharaScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postBendaharaProvider);
    final kosong = post != null && post.holder == null && post.pending == null;
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

class _Kosong extends ConsumerWidget {
  const _Kosong();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final post = ref.watch(postBendaharaProvider);
    final akhir = post?.lastHolder;
    final nama =
        ref
            .watch(peopleRepositoryProvider)
            .person(akhir?.personId ?? '')
            ?.name ??
        '';
    final jemaat = ref.watch(workspaceRepositoryProvider).workspace().name;
    final beranda = ref.watch(berandaKeuanganProvider);
    final berikut = beranda.bulan.berikutDitutup;
    final saldo = rp(beranda.saldoBuku);
    final draf = '${beranda.drafJumlah} · belum masuk saldo';
    final bulan = berikut == null ? '—' : namaBulan(berikut);
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
            kalimat:
                'Wewenang $nama berakhir pada '
                '${akhir?.endedAt == null ? akhir?.end ?? '' : tglJam(akhir!.endedAt!)}. '
                'Semua sesinya sudah diakhiri.',
            radius: 16,
            padding: const EdgeInsets.all(18),
            ukuranJudul: 19,
            jarak: 8,
            anak: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Yang perlu bertindak: BPMJ $jemaat.',
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
                  Text(saldo, style: gayaMono),
                  _lebarTeks(context, saldo, gayaMono),
                  false,
                ),
                baris(
                  'Draf yang tertinggal',
                  Text(draf, style: gayaNilai),
                  _lebarTeks(context, draf, gayaNilai),
                  true,
                ),
                baris(
                  'Bulan berikutnya untuk tutup buku',
                  Text(bulan, style: gayaNilai),
                  _lebarTeks(context, bulan, gayaNilai),
                  true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Riwayat tetap mencatat $nama sebagai pelaku semua tindakannya. Bendahara baru tidak mewarisi persetujuan yang pernah dicatat.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- Utama

class _Utama extends ConsumerWidget {
  const _Utama();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final st = ref.watch(serahTerimaProvider);
    final aktif = st.tahap == 'aktif';
    final pegang = aktif ? st.baru : st.post?.holder;
    final namaAktif = aktif ? st.namaBaru : st.namaLama;
    const gayaNama = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    const badge = 'Wewenang Bendahara aktif';
    final saya = ref.watch(actorProvider);
    final perangkat = saya == null || pegang?.personId != saya.personId
        ? const <Device>[]
        : ref.watch(sessionRepositoryProvider).devices(saya.personId);
    final sesi = aktif
        ? [
            (
              n: 'Belum ada sesi',
              s: 'Semua sesi ${st.namaLama} diakhiri ${st.lama?.end ?? ''}',
              d: null as Device?,
            ),
          ]
        : [
            (n: 'Ponsel ini', s: 'Sesi ini · aktif sekarang', d: null),
            for (final d in perangkat) (n: d.name, s: barisPerangkat(d), d: d),
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
                        'Aktif sejak ${pegang?.start ?? ''} · '
                        '${pegang?.documentRef ?? ''}',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                      if (aktif) ...[
                        const SizedBox(height: 12),
                        GarisLurus(warna: c.garisTegas, gaya: GayaGaris.putus),
                        const SizedBox(height: 8),
                        Text(
                          'Sebelumnya: ${st.namaLama} · wewenang berakhir '
                          '${st.lama?.end ?? ''}. Riwayat tetap mencatatnya '
                          'sebagai pelaku.',
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
                              if (sesi[i].d case final d?) ...[
                                const SizedBox(width: 12),
                                Tekan(
                                  onTap: () async {
                                    final r = await keluarkanPerangkat(ref, d);
                                    p.ubah(() => p.tolak = r);
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

class _Serah extends ConsumerStatefulWidget {
  const _Serah();

  @override
  ConsumerState<_Serah> createState() => _SerahState();
}

class _SerahState extends ConsumerState<_Serah> {
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
    final st = ref.watch(serahTerimaProvider);
    final aktif = st.tahap == 'aktif',
        diajukan = st.tahap == 'diajukan',
        tunggu = st.tahap == 'tunggu' || diajukan,
        belum = !aktif && !tunggu;
    final namaBaru = belum ? p.nama : st.namaBaru;
    final dokumen = st.dokumenBaru ?? '';
    Future<void> kirim() async {
      final r = await siapkanSerahTerima(ref, p.nama);
      p.ubah(() => p.tolak = r);
    }

    const gayaNama = TextStyle(fontWeight: FontWeight.w700);
    const tebal = TextStyle(fontWeight: FontWeight.w700);

    final lamaTeks = aktif ? 'Wewenang berakhir' : 'Wewenang Bendahara aktif';
    final baruTeks = aktif
        ? 'Wewenang Bendahara aktif'
        : diajukan
        ? 'Menunggu dicatat'
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
            kiri: Text(st.namaLama, style: gayaNama),
            lebarKiri: _lebarTeks(context, st.namaLama, gayaNama),
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
                ? 'Berakhir ${st.lama?.end ?? ''} · semua sesi diakhiri'
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
                  text:
                      '${dokumen.replaceFirst('09-', '09-\u200B')}.pdf · '
                      'Terlampir',
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
          // The spinner stands for the Petugas verifikasi at work; while the
          // handover waits for a person to record it, nothing turns.
          if (!diajukan) ...[
            Putar(
              periode: const Duration(seconds: 6),
              child: SizedBox(
                width: 34,
                height: 34,
                child: CustomPaint(painter: _Lingkaran(c.tinta)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: namaBaru, style: tebal),
                    TextSpan(
                      text: diajukan
                          ? ' · menunggu Pimpinan Jemaat yang berwenang '
                                'mencatat penunjukan.'
                          : ' · menunggu Petugas verifikasi memeriksa surat '
                                'penunjukan.',
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
                TextSpan(text: namaBaru, style: tebal),
                TextSpan(
                  text: ' · aktif sejak ${st.baru?.start ?? ''} · $dokumen',
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
            if (p.tolak != null) ...[
              Penolakan(
                tindakan: p.tolak!.action,
                sebab: p.tolak!.because,
                jalan: const [],
              ),
              const SizedBox(height: 8),
            ],
            TombolBersyarat(
              label: 'Kirim untuk diverifikasi',
              tindakan: 'Kirim untuk diverifikasi',
              alasan: p.okNama ? '' : _isiNama,
              periksa: () => p.okNama ? '' : _isiNama,
              onPressed: kirim,
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
