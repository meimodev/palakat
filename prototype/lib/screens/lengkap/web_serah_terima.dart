import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/pengaturan.dart';
import '../p2/akun_saya.dart';

/// Web · Serah terima Bendahara (spec 10-aifoto.md, WebSerahTerima): the
/// holder prepares the handover through RoleRepository.proposeHandover
/// (DP39); the stages after it follow the post's real state.
class WebSerahTerimaScreen extends ConsumerStatefulWidget {
  const WebSerahTerimaScreen({super.key});

  @override
  ConsumerState<WebSerahTerimaScreen> createState() =>
      _WebSerahTerimaScreenState();
}

class _WebSerahTerimaScreenState extends ConsumerState<WebSerahTerimaScreen> {
  static const _namaAwal = 'Yohanis Tumbelaka';
  String _nama = _namaAwal;
  late final _isian = TextEditingController(text: _nama);
  Refusal? _tolak;

  bool get _okNama => _nama.trim().isNotEmpty;
  String _alasan() => _okNama ? '' : 'Nama yang ditunjuk belum diisi.';

  Future<void> _kirim() async {
    if (!_okNama) return;
    final r = await siapkanSerahTerima(ref, _nama);
    if (mounted) setState(() => _tolak = r);
  }

  @override
  void dispose() {
    _isian.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final st = ref.watch(serahTerimaProvider);
    final post = st.post;
    final kosong = post != null && post.holder == null && post.pending == null;
    final aktif = st.tahap == 'aktif',
        diajukan = st.tahap == 'diajukan',
        tunggu = st.tahap == 'tunggu' || diajukan;
    final namaBaru = st.tahap == 'belum' ? _nama : st.namaBaru;
    final dokumen = st.dokumenBaru ?? '';
    final akhir = post?.lastHolder;
    final orang = ref.watch(peopleRepositoryProvider);
    final namaAkhir = orang.person(akhir?.personId ?? '')?.name ?? '';
    final jemaat = ref.watch(workspaceRepositoryProvider).workspace().name;
    final pegang = aktif ? st.baru : post?.holder;
    final saya = ref.watch(actorProvider);
    final perangkat = saya == null || pegang?.personId != saya.personId
        ? const <Device>[]
        : ref.watch(sessionRepositoryProvider).devices(saya.personId);
    const tebal = TextStyle(fontWeight: FontWeight.w700);

    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The board's inline link sits in a 15/1.45 line box (21.75 high).
        MarginNegatif(
          atas: 11.125,
          bawah: 11.125,
          child: Tautan(
            ke: Layar.pengaturan,
            cara: Cara.naik,
            child: const Center(
              widthFactor: 1,
              heightFactor: 1,
              child: TautanTeks('Pengaturan', ukuran: 14),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: const Text(
            'Serah terima Bendahara',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    final pita = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: c.tinta,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 14, color: c.diTinta),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Belum ada Bendahara aktif',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: c.permukaan,
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                text:
                    'Wewenang $namaAkhir berakhir pada '
                    '${akhir?.endedAt == null ? akhir?.end ?? '' : tglJam(akhir!.endedAt!)}. '
                    'Semua data hanya dapat dilihat. ',
                children: [
                  TextSpan(
                    text: 'Yang perlu bertindak: BPMJ $jemaat.',
                    style: tebal.copyWith(color: c.permukaan),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                text: 'Sementara itu, Operator Jemaat dapat ',
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: MarginNegatif(
                      atas: 11.85,
                      bawah: 11.85,
                      child: Tautan(
                        ke: Layar.jabatanKosong,
                        child: Center(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: TautanTeks(
                            'menjalankan jabatan kosong',
                            berat: FontWeight.w700,
                            ukuran: 14,
                            warna: c.permukaan,
                          ),
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
      ),
    );

    // Handover chain: old card, connector, new card.
    final lama = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(aktif ? c.tinta3 : c.tinta, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _JudulLencana(
            judul: st.namaLama,
            lencana: aktif
                ? _Lencana(
                    'Wewenang berakhir',
                    isi: c.permukaan,
                    teks: c.tinta2,
                    garis: GarisBorder.penuh(c.tinta3, radius: 6),
                  )
                : _Lencana(
                    'Wewenang Bendahara aktif',
                    isi: c.laut,
                    teks: c.diLaut,
                    garis: GarisBorder.penuh(c.laut, radius: 6),
                  ),
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
          _JudulLencana(
            judul: 'Bendahara baru',
            lencana: aktif
                ? _Lencana(
                    'Wewenang Bendahara aktif',
                    isi: c.laut,
                    teks: c.diLaut,
                    garis: GarisBorder.penuh(c.laut, radius: 6),
                  )
                : _Lencana(
                    diajukan
                        ? 'Menunggu dicatat'
                        : tunggu
                        ? 'Menunggu verifikasi wewenang'
                        : 'Belum dikirim',
                    teks: c.tinta2,
                    garis: GarisBorder.putus(c.putus, radius: 6),
                  ),
          ),
          const SizedBox(height: 10),
          if (st.tahap == 'belum') ...[
            IsianTeks(
              controller: _isian,
              label: 'Nama yang ditunjuk',
              jarakLabel: 6,
              onChanged: (v) => setState(() => _nama = v),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: 'Surat penunjukan baru: ',
                children: [
                  TextSpan(
                    text: '$dokumen.pdf · Terlampir',
                    style: tebal.copyWith(color: c.tinta),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            const SizedBox(height: 10),
            // Rule A02: the sentence the board lacks, once the name is
            // edited; drawn here so the hugged button keeps its width.
            if (_tolak != null || (_nama != _namaAwal && !_okNama)) ...[
              Penolakan(
                tindakan: _tolak?.action ?? 'Kirim untuk diverifikasi',
                sebab: _tolak?.because ?? _alasan(),
                jalan: const [],
                ukuranTeks: 14,
              ),
              const SizedBox(height: 8),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: TombolBersyarat(
                  label: 'Kirim untuk diverifikasi',
                  tindakan: 'Kirim untuk diverifikasi',
                  alasan: _alasan(),
                  periksa: _alasan,
                  onPressed: _kirim,
                  sudahMulai: false,
                  warnaSiap: JenisTombol.utama,
                  teksBelumRedup: true,
                  tinggi: 46,
                  radius: 12,
                  paddingH: 20,
                ),
              ),
            ),
          ],
          if (tunggu)
            Semantics(
              liveRegion: true,
              container: true,
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
          if (aktif)
            Gerak(
              Kerangka.muncul,
              key: const ValueKey('aktif'),
              lama: const Duration(milliseconds: 300),
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: namaBaru, style: tebal),
                      TextSpan(
                        text:
                            ' · aktif sejak ${st.baru?.start ?? ''} · '
                            '$dokumen',
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );

    final rantai = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        lama,
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 2,
            height: 22,
            margin: const EdgeInsets.only(left: 28),
            color: c.tinta,
          ),
        ),
        const SizedBox(height: 6),
        baru,
      ],
    );

    final judulSedang = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: c.tinta,
    );
    final sesi = aktif
        ? [
            (
              n: 'Belum ada sesi',
              s: 'Semua sesi ${st.namaLama} diakhiri ${st.lama?.end ?? ''}',
              d: null as Device?,
            ),
          ]
        : [
            (n: 'Browser ini', s: 'Sesi ini · aktif sekarang', d: null),
            for (final d in perangkat) (n: d.name, s: barisPerangkat(d), d: d),
          ];

    final aturan = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 14, color: c.tinta2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, t) in [
                'Yang terjadi saat wewenang berpindah',
                'Semua sesi Bendahara lama diakhiri saat itu juga.',
                'Bendahara baru tidak mewarisi persetujuan yang pernah '
                    'dicatat Bendahara lama.',
                'Riwayat tetap mencatat Bendahara lama sebagai pelaku '
                    'tindakannya.',
                'Sampai verifikasi selesai, Bendahara lama tetap aktif. '
                    'Tidak pernah ada dua Bendahara aktif.',
              ].indexed) ...[
                if (i > 0) const SizedBox(height: 6),
                Text(t, style: i == 0 ? judulSedang : null),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sesi yang sedang masuk · ${aktif ? st.namaBaru : st.namaLama}',
          style: judulSedang,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
          ),
          child: Column(
            children: [
              for (final (i, x) in sesi.indexed)
                Container(
                  // CSS content-box: min-height 56 plus the 1 px rule.
                  constraints: BoxConstraints(minHeight: i > 0 ? 57 : 56),
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
                              x.n,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              x.s,
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                          ],
                        ),
                      ),
                      if (x.d case final d?) ...[
                        const SizedBox(width: 12),
                        Tekan(
                          onTap: () async {
                            final r = await keluarkanPerangkat(ref, d);
                            if (mounted) setState(() => _tolak = r);
                          },
                          radius: 10,
                          child: RupaTombol(
                            label: 'Akhiri sesi',
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
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Pemulihan akun mengembalikan akses orang yang sama dan tidak '
          'memerlukan penunjukan baru.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );

    return HalamanWeb(
      nav: NavSamping(item: navKeuangan, aktif: 6),
      isi: [
        judul,
        if (kosong) pita,
        BarisLentur(
          jarak: 28,
          anak: [
            Lentur(dasar: 380, child: rantai),
            Lentur(dasar: 420, tumbuh: 999, child: aturan),
          ],
        ),
      ],
    );
  }
}

/// Post badge: 13/700, radius 6, padding 3 9, 1.5 line.
/// The board's `justify-content: space-between` row of a bold title and a
/// badge, gap 16: when both do not fit, CSS shrinks each in proportion to
/// its width (never below its longest word), so both may wrap.
class _JudulLencana extends StatelessWidget {
  const _JudulLencana({required this.judul, required this.lencana});

  final String judul;
  final _Lencana lencana;

  static const _gayaJudul = TextStyle(fontWeight: FontWeight.w700);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
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

      double kata(String t, TextStyle g) =>
          t.split(' ').map((s) => lebar(s, g)).reduce((a, b) => a > b ? a : b);
      const tepi = 9 * 2 + 1.5 * 2;
      final a = lebar(judul, _gayaJudul);
      final b = lebar(lencana.label, _Lencana.gaya) + tepi;
      final ruang = k.maxWidth - 16;
      final pas = a + b <= ruang;
      var (wa, wb) = (a, b);
      if (!pas) {
        final lebih = a + b - ruang;
        final minA = kata(judul, _gayaJudul);
        final minB = kata(lencana.label, _Lencana.gaya) + tepi;
        wa = a - lebih * a / (a + b);
        wb = b - lebih * b / (a + b);
        if (wa < minA) (wa, wb) = (minA, ruang - minA);
        if (wb < minB) (wb, wa) = (minB, ruang - minB);
        wa = wa < minA ? minA : wa;
        wb = wb < minB ? minB : wb;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // At natural size nothing is pinned, so rounding cannot wrap.
          SizedBox(
            width: pas ? null : wa,
            child: Text(judul, style: _gayaJudul),
          ),
          const SizedBox(width: 16),
          SizedBox(width: pas ? null : wb, child: lencana),
        ],
      );
    },
  );
}

class _Lencana extends StatelessWidget {
  const _Lencana(
    this.label, {
    this.isi,
    required this.teks,
    required this.garis,
  });

  final String label;
  final Color? isi;
  final Color teks;
  final GarisBorder garis;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: ShapeDecoration(color: isi, shape: garis),
    child: Text(label, style: gaya.copyWith(color: teks)),
  );

  static const gaya = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);
}
