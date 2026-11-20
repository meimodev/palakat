import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/butir_perhatian.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../lengkap/ai_bulan.dart';

typedef _Usul = UsulAi;

/// Web · Bantuan AI akhir bulan (06-bukti.md, WebAI).
class WebAIScreen extends ConsumerStatefulWidget {
  const WebAIScreen({super.key});
  @override
  ConsumerState<WebAIScreen> createState() => _WebAIScreenState();
}

class _WebAIScreenState extends ConsumerState<WebAIScreen> with UsulanAiBulan {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ai = ref.watch(aiBulanProvider);
    final pct = ai.budget.percent;
    final mati = ai.budget.usedUp;
    final berjalan = ref.watch(bulanBukuProvider).berjalan;
    final ringkasan = ai.ringkasan == null || usulan(ai, ai.ringkasan!) == null
        ? null
        : ai.ringkasan;
    final usul = [
      for (final u in ai.usul)
        if (usulan(ai, u.t) case final p?) (u, p),
    ];
    final biayaCat = mati
        ? 'Batas tercapai.'
        : pct >= 90
        ? 'Hampir habis. AI memakai cara yang lebih hemat sampai akhir bulan.'
        : pct >= 70
        ? 'Sudah melewati 70% dari batas bulan ini.'
        : '';
    final tinta2 = TextStyle(fontSize: 14, color: c.tinta2);
    final tb = ref.watch(tutupBukuProvider);
    final diketahui = untukDiketahuiTutup(tb);
    const h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

    final kiri = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Semantics(header: true, child: const Text('Hambatan', style: h2)),
            const SizedBox(width: 8),
            Hitungan(tb.hambatan.length, rapat: true),
          ],
        ),
        for (final h in tb.hambatan) ...[
          const SizedBox(height: 14),
          ButirPerhatian(
            tingkat: TingkatPerhatian.hambatan,
            web: true,
            judul: h.judul,
            keterangan: h.sub,
            perbaikan: Tombol(
              h.tombol,
              onPressed: null,
              ke: h.ke,
              param: h.param,
              anak: h.anak,
              jenis: JenisTombol.tinta,
              ukuran: UkuranTombol.kecil,
              lebarPenuh: false,
            ),
          ),
        ],
        const SizedBox(height: 14 + 8),
        Semantics(
          header: true,
          child: const Text('Untuk diketahui', style: h2),
        ),
        const SizedBox(height: 14),
        Text(diketahui.isEmpty ? 'Tidak ada.' : diketahui, style: tinta2),
        if (mati) ...[
          const SizedBox(height: 14),
          Text(
            'AI sedang tidak tersedia: batas biaya AI per bulan tercapai. Ini tidak menghalangi tutup buku.',
            style: tinta2,
          ),
        ],
        const SizedBox(height: 14),
        GarisLurus(warna: c.garis),
        const SizedBox(height: 12),
        Text(
          'Tutup buku hanya dilakukan di halaman Bulan dan tutup buku, oleh Bendahara. Panel bantuan tidak punya tombol untuk itu.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );

    Widget kartuAI(List<Widget> isi, double jarak) => Kartu(
      status: GarisStatus.usulanAI,
      radius: 12,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, w) in isi.indexed) ...[
            if (i > 0) SizedBox(height: jarak),
            w,
          ],
        ],
      ),
    );
    final miring = TextStyle(
      fontSize: 14,
      fontStyle: FontStyle.italic,
      color: c.lautTua,
    );

    final panel = <Widget>[
      _BarisSusut(
        kiri: (
          'BANTUAN AI · PILIHAN',
          TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: c.lautTua,
            letterSpacing: .3,
          ),
        ),
        kanan: (
          'Batas biaya AI per bulan · ${rp(ai.budget.spent)} dari '
              '${rp(ai.budget.cap)}',
          TextStyle(fontSize: 13, color: c.tinta),
        ),
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 8,
          color: c.permukaan,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (pct.clamp(0, 100)) / 100,
            heightFactor: 1,
            child: ColoredBox(color: c.laut),
          ),
        ),
      ),
      if (biayaCat.isNotEmpty)
        Text(
          biayaCat,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      if (!mati) ...[
        if (ringkasan != null)
          kartuAI([
            const LencanaStatus(
              'Usulan AI · ringkasan',
              bentuk: BentukLencana.usulanAI,
            ),
            Text(ringkasan, style: miring),
            Text(
              'Angka resmi tetap yang ada di halaman rekonsiliasi.',
              style: TextStyle(fontSize: 13, color: c.tinta2),
            ),
          ], 6),
        for (final (u, p) in usul) _kartuUsul(context, u, p, kartuAI, miring),
      ],
      if (mati)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.permukaan,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      'Bantuan AI berhenti sampai '
                      '${berjalan == null ? 'bulan depan' : bulanSesudah(berjalan)}.',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
                ),
                const TextSpan(
                  text: ' Rekonsiliasi, laporan dan tutup buku berjalan seperti biasa tanpa AI.',
                ),
              ],
            ),
            style: tinta2,
          ),
        ),
      Text(
        'AI hanya mengusulkan. AI tidak membukukan, memverifikasi, menutup buku, atau memberi angka resmi.',
        style: TextStyle(fontSize: 13, color: c.tinta2),
      ),
    ];

    final aside = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.lautLembut,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, w) in panel.indexed) ...[
            if (i > 0) const SizedBox(height: 14),
            w,
          ],
        ],
      ),
    );

    return HalamanWeb(
      layarKeuangan: true,
      nav: const NavSamping(item: navKeuangan, aktif: 4),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline link on a 15/1.45 line; its 44 target overlaps the h1 gap.
            MarginNegatif(
              atas: (44 - 15 * 1.45) / 2,
              bawah: (44 - 15 * 1.45) / 2,
              child: Tautan(
                ke: Layar.tutupBuku,
                cara: Cara.naik,
                child: const Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Bulan dan tutup buku', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: Text(
                'Persiapan tutup buku '
                '${ai.periode == null ? '' : namaBulan(ai.periode!)}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(dasar: 480, tumbuh: 999, child: kiri),
            // content-box basis: 400 plus the 18 padding on each side.
            Lentur(dasar: 400 + 2 * 18, child: aside),
          ],
        ),
      ],
    );
  }

  Widget _kartuUsul(
    BuildContext context,
    _Usul u,
    AiProposal p,
    Widget Function(List<Widget>, double) kartuAI,
    TextStyle miring,
  ) {
    final c = context.warna;
    final v = p.disposition;
    return kartuAI([
      LencanaStatus(u.label, bentuk: BentukLencana.usulanAI),
      Text(u.t, style: miring),
      if (u.ragu)
        const Text(
          'AI kurang yakin, mohon dicek',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      if (v == null)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Tombol(
              u.pakaiTeks,
              onPressed: () => putuskan(u, p, AiDisposition.accepted),
              ukuran: UkuranTombol.mini,
              paddingH: 16,
              ukuranTeks: 14,
              lebarPenuh: false,
            ),
            Tombol(
              'Abaikan',
              onPressed: () => putuskan(u, p, AiDisposition.rejected),
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.mini,
              paddingH: 16,
              ukuranTeks: 14,
              lebarPenuh: false,
            ),
            Text(u.cat, style: TextStyle(fontSize: 13, color: c.tinta2)),
          ],
        )
      else
        Semantics(
          container: true,
          liveRegion: true,
          child: Gerak(
            Kerangka.muncul,
            key: ValueKey(v),
            lama: const Duration(milliseconds: 300),
            child: Text(
              v == AiDisposition.rejected
                  ? 'Diabaikan. Tidak perlu alasan.'
                  : u.jadi,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.tinta,
              ),
            ),
          ),
        ),
    ], 8);
  }
}

/// Two texts in a `justify-content: space-between; gap: 12px` flex row: when
/// they do not fit, both shrink in proportion to their max-content width
/// (CSS `flex-shrink: 1`), so both may wrap.
class _BarisSusut extends StatelessWidget {
  const _BarisSusut({required this.kiri, required this.kanan});
  final (String, TextStyle) kiri, kanan;

  @override
  Widget build(BuildContext context) {
    final dasar = DefaultTextStyle.of(context).style;
    int lebar((String, TextStyle) t) {
      final tp = TextPainter(
        text: TextSpan(text: t.$1, style: dasar.merge(t.$2)),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final w = (tp.width * 100).ceil();
      tp.dispose();
      return w;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          flex: lebar(kiri),
          child: Text(kiri.$1, style: kiri.$2),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: lebar(kanan),
          child: Text(kanan.$1, style: kanan.$2),
        ),
      ],
    );
  }
}
