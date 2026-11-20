import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/actor.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/repositories_keuangan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

typedef _Usul = UsulAi;

/// The month-end proposals of AIBulan and WebAI as AiRepository records
/// (README 3.7, 4.2): each text the panel shows is asked once for the month
/// (AiKind.monthEnd, its cost added to the budget), keyed by the month and
/// the text, so a revisit reads the same proposal and its "Pakai" or
/// "Abaikan" back instead of asking again.
mixin UsulanAiBulan<W extends ConsumerStatefulWidget> on ConsumerState<W> {
  final _usulan = <String, AiProposal>{};
  final _diminta = <String>{};

  /// The READY proposal behind [teks] of [ai]'s month, or null while it is
  /// asked (or refused: no right to ask, or the budget is used up).
  AiProposal? usulan(AiBulan ai, String teks) {
    final kunci = 'ai-bulan|${ai.periode?.id}|$teks';
    if (_diminta.add(kunci)) {
      // Asked after the frame: a command never runs during build.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final a = ref.read(actorProvider);
        if (!mounted || a == null) return;
        final r = await ref
            .read(aiRepositoryProvider)
            .propose(
              a,
              AiKind.monthEnd,
              AiInput(text: teks),
              idempotencyKey: kunci,
            );
        if (mounted && r.isOk) setState(() => _usulan[kunci] = r.value);
      });
    }
    final p = _usulan[kunci];
    return p == null || p.status == AiProposalStatus.pending ? null : p;
  }

  /// "Pakai" (accepted) or "Abaikan" (rejected); "Buka untuk dicocokkan"
  /// then opens the reconciliation it names.
  Future<void> putuskan(UsulAi u, AiProposal p, AiDisposition d) async {
    final r = await perintah(
      ref,
      (a, k) => ref
          .read(aiRepositoryProvider)
          .dispose(a, p.id, d, expectedRevision: p.revision, idempotencyKey: k),
    );
    if (!mounted) return;
    setState(() {});
    if ((r?.isOk ?? false) && d == AiDisposition.accepted && u.id == 'cocok') {
      context.gantiKe(Layar.tutupBuku, anak: 'rekonsiliasi');
    }
  }
}

/// 36 · Bantuan AI akhir bulan (spec 10-aifoto.md, AIBulan).
class AIBulanScreen extends ConsumerStatefulWidget {
  const AIBulanScreen({super.key});

  @override
  ConsumerState<AIBulanScreen> createState() => _AIBulanScreenState();
}

class _AIBulanScreenState extends ConsumerState<AIBulanScreen>
    with UsulanAiBulan {
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

    final biaya = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Batas biaya AI per bulan · ${rp(ai.budget.spent)} '
          'dari ${rp(ai.budget.cap)}',
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.permukaan,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (pct.clamp(0, 100)) / 100,
            heightFactor: 1,
            child: ColoredBox(color: c.laut),
          ),
        ),
        if (biayaCat.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            biayaCat,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );

    final panel = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.lautLembut,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _jarak(12, [
          Text(
            'BANTUAN AI · PILIHAN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.lautTua,
              letterSpacing: .3,
            ),
          ),
          biaya,
          if (!mati) ...[
            if (ringkasan != null)
              _KartuAI(
                label: 'Usulan AI · ringkasan',
                jarak: 6,
                anak: [
                  Text(
                    ringkasan,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: c.lautTua,
                    ),
                  ),
                  Text(
                    'Angka resmi tetap yang ada di halaman rekonsiliasi.',
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            for (final (u, p) in usul) _kartuUsul(u, p),
            if (ringkasan == null && usul.isEmpty)
              Text(
                'Tidak ada usulan untuk bulan ini.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
          ],
          if (mati)
            Container(
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
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.tinta,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' Rekonsiliasi, laporan dan tutup buku berjalan '
                          'seperti biasa. Ini tidak menghalangi tutup buku.',
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ),
          Text(
            'AI hanya mengusulkan. Panel ini tidak punya tombol tutup buku.',
            style: TextStyle(fontSize: 13, color: c.tinta2),
          ),
        ]),
      ),
    );

    return LayarPonsel(
      layarKeuangan: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Bantuan AI',
            anakJudul: ai.periode == null
                ? null
                : 'Persiapan tutup buku ${namaBulan(ai.periode!)}',
            kembaliKe: Layar.tutupBuku,
            labelKembali: 'Kembali ke Bulan',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  panel,
                  const SizedBox(height: 16),
                  const Tombol(
                    'Kembali ke kesiapan tutup buku',
                    onPressed: null,
                    ke: Layar.tutupBuku,
                    cara: Cara.naik,
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuUsul(_Usul u, AiProposal p) {
    final c = context.warna;
    final v = p.disposition;
    return _KartuAI(
      label: u.label,
      jarak: 8,
      anak: [
        Text(
          u.t,
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: c.lautTua,
          ),
        ),
        if (u.ragu)
          const Text(
            'AI kurang yakin, mohon dicek',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        if (v == null) ...[
          Row(
            children: [
              Expanded(
                child: Tombol(
                  u.pakaiTeks,
                  onPressed: () => putuskan(u, p, AiDisposition.accepted),
                  ukuran: UkuranTombol.mini,
                  ukuranTeks: 14,
                ),
              ),
              const SizedBox(width: 8),
              Tombol(
                'Abaikan',
                onPressed: () => putuskan(u, p, AiDisposition.rejected),
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.mini,
                ukuranTeks: 14,
                lebarPenuh: false,
                paddingH: 16,
              ),
            ],
          ),
          Text(u.cat, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ] else
          Gerak(
            Kerangka.muncul,
            key: ValueKey('${u.id}-$v'),
            lama: const Duration(milliseconds: 300),
            child: Semantics(
              container: true,
              liveRegion: true,
              child: Text(
                v == AiDisposition.rejected
                    ? 'Diabaikan. Tidak perlu alasan.'
                    : u.jadi,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The board's dotted card: `permukaan`, 1.5 dotted `laut`, radius 12,
/// padding 14, the `usulanAI` tag, then [anak] with gap [jarak].
class _KartuAI extends StatelessWidget {
  const _KartuAI({
    required this.label,
    required this.jarak,
    required this.anak,
  });

  final String label;
  final double jarak;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.usulanAI,
    radius: 12,
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _jarak(jarak, [
        Align(
          alignment: Alignment.centerLeft,
          child: LencanaStatus(label, bentuk: BentukLencana.usulanAI),
        ),
        ...anak,
      ]),
    ),
  );
}

/// CSS column `gap`.
List<Widget> _jarak(double g, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: g),
    anak[i],
  ],
];
