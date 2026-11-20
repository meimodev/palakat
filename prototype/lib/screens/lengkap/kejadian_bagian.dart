import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/actor.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/repositories_keuangan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// Parts shared by Kejadian and WebKejadian (07-kejadian.md): the view
/// state, the badge, the blocker statement, a card's lines, the detail and
/// the "Catat kejadian" form. Incidents come from PeriodRepository
/// (`kejadianProvider`); recording one never changes the closed month.

/// The view state: the chosen incident, the open form and its fields.
class KeadaanKejadian extends ChangeNotifier {
  String? pilih;
  bool membuka = false, masuk = true;
  Refusal? tolak;
  final judul = TextEditingController(),
      fakta = TextEditingController(),
      dampak = TextEditingController(),
      pj = TextEditingController(),
      jumlah = TextEditingController();

  /// The chosen incident, else the newest.
  ButirKejadian? cur(DaftarKejadian d) =>
      d.butir.where((b) => b.kejadian.id == pilih).firstOrNull ??
      d.butir.firstOrNull;

  void pick(String id) {
    pilih = id;
    membuka = false;
    notifyListeners();
  }

  void buka() {
    membuka = true;
    tolak = null;
    notifyListeners();
  }

  void tutup() {
    membuka = false;
    notifyListeners();
  }

  void arah(bool m) {
    masuk = m;
    notifyListeners();
  }

  /// "Catat kejadian": PeriodRepository.recordIncident on the last closed
  /// month, with the settlement as a draft in the open month when an amount
  /// is given. Returns the new incident's id.
  Future<String?> catat(WidgetRef ref, DaftarKejadian d) async {
    final p = d.ditutup;
    if (p == null) return null;
    final n = int.tryParse(jumlah.text.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final kas = ref
        .read(accountRepositoryProvider)
        .accounts()
        .where(
          (a) =>
              a.type == AccountType.cash &&
              a.operatorAt(ref.read(hariIniProvider)) == null,
        )
        .firstOrNull;
    final r = await perintah(
      ref,
      (a, k) => ref
          .read(periodRepositoryProvider)
          .recordIncident(
            a,
            p.id,
            IncidentExplanation(
              title: judul.text.trim(),
              facts: fakta.text.trim(),
              impact: dampak.text.trim(),
              responsible: pj.text.trim(),
            ),
            n == 0 || kas == null
                ? null
                : drafPenyelesaian(
                    akunId: kas.id,
                    jumlah: masuk ? n : -n,
                    judul: judul.text.trim(),
                    hari: ref.read(hariIniProvider),
                  ),
            idempotencyKey: k,
          ),
    );
    tolak = r?.refusal;
    if (r is Ok<CloseIncident>) {
      pilih = r.value.id;
      membuka = false;
      for (final c in [judul, fakta, dampak, pj, jumlah]) {
        c.clear();
      }
    }
    notifyListeners();
    return r is Ok<CloseIncident> ? r.value.id : null;
  }

  @override
  void dispose() {
    for (final c in [judul, fakta, dampak, pj, jumlah]) {
      c.dispose();
    }
    super.dispose();
  }
}

/// "Belum / Sudah ditindaklanjuti".
class LencanaKejadian extends StatelessWidget {
  const LencanaKejadian(this.selesai, {super.key});
  final bool selesai;

  @override
  Widget build(BuildContext context) => LencanaStatus(
    selesai ? 'Sudah ditindaklanjuti' : 'Belum ditindaklanjuti',
    bentuk: selesai ? BentukLencana.laut : BentukLencana.garis,
  );
}

/// Column with CSS `gap`.
class KolomCelah extends StatelessWidget {
  const KolomCelah({super.key, required this.celah, required this.anak});
  final double celah;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) SizedBox(height: celah),
        anak[i],
      ],
    ],
  );
}

/// The dark statement: the next month still has blockers, and an incident
/// does not clear them.
class PernyataanHambatan extends StatelessWidget {
  const PernyataanHambatan({super.key, required this.d});
  final DaftarKejadian d;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 14, color: c.diTinta);
    final b = d.berikut!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GarisStatus.ditutup.gaya(c).isi,
        borderRadius: BorderRadius.circular(14),
      ),
      child: KolomCelah(
        celah: 6,
        anak: [
          Text(
            '${namaBulan(b)} belum dapat ditutup',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.permukaan,
            ),
          ),
          Text(
            'Masih ada ${d.hambatan} hambatan tutup buku. Kejadian tidak '
            'menghilangkan hambatan; hambatan diselesaikan di Bulan dan tutup '
            'buku.',
            style: kecil,
          ),
        ],
      ),
    );
  }
}

/// A card's three lines: code + badge, title 15/600, period.
class IsiKartuKejadian extends StatelessWidget {
  const IsiKartuKejadian({super.key, required this.b});
  final ButirKejadian b;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return KolomCelah(
      celah: 4,
      anak: [
        Row(
          children: [
            Expanded(
              child: Text(
                b.kejadian.code,
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 13,
                  color: c.tinta2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            LencanaKejadian(b.selesai),
          ],
        ),
        Text(
          b.kejadian.explanation.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        Text(
          '${namaBulan(b.periode)} · Sudah ditutup',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }
}

/// Detail regions a–e of the chosen Kejadian, column gap 16.
class RinciKejadian extends StatelessWidget {
  const RinciKejadian({super.key, required this.b, required this.d});
  final ButirKejadian b;
  final DaftarKejadian d;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final e = b.kejadian.explanation;
    final done = b.selesai;
    final draf = b.draf;
    const judul15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    final rinci = [
      ('Periode', '${namaBulan(b.periode)} · Sudah ditutup'),
      ('Transaksi', b.transaksi.isEmpty ? kosong : b.transaksi.join(', ')),
      ('Dampak pada rekonsiliasi', e.impact),
      ('Penanggung jawab', e.responsible),
      ('Hasil eskalasi', e.escalation ?? 'Tidak perlu eskalasi.'),
    ];
    return KolomCelah(
      celah: 16,
      anak: [
        KolomCelah(
          celah: 4,
          anak: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  b.kejadian.code,
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 13,
                    color: c.tinta2,
                  ),
                ),
                LencanaKejadian(done),
              ],
            ),
            Text(
              e.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: GarisStatus.ditutup.gaya(c).isi,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Kejadian hanya mencatat. Kejadian tidak mengubah angka apa pun, '
            'tidak menghapus selisih, dan tidak menghilangkan hambatan tutup '
            'buku.',
            style: TextStyle(fontSize: 14, color: c.permukaan),
          ),
        ),
        KolomCelah(
          celah: 4,
          anak: [
            const Text('Penjelasan', style: judul15),
            Text(e.facts, style: const TextStyle(fontSize: 15)),
          ],
        ),
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < rinci.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: i == 0
                      ? null
                      : BoxDecoration(
                          border: Border(top: BorderSide(color: c.garis)),
                        ),
                  child: LayoutBuilder(
                    builder: (context, k) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // `flex: none`, capped so a narrow window never overflows.
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: k.maxWidth * 0.6,
                          ),
                          child: Text(
                            rinci[i].$1,
                            style: TextStyle(fontSize: 14, color: c.tinta2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            rinci[i].$2,
                            textAlign: TextAlign.right,
                            // Sans, as drawn: the board wins over the spec's
                            // "mono (recommended)" (review-log).
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        KolomCelah(
          celah: 6,
          anak: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Penyelesaian keuangan '),
                  TextSpan(
                    text: '· dicatat terpisah dari penjelasan',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: c.tinta3,
                    ),
                  ),
                ],
              ),
              style: judul15,
            ),
            if (done)
              // Keyed by the resolved state only (motion.md rule 3).
              Gerak(
                Kerangka.muncul,
                lama: const Duration(milliseconds: 300),
                child: Text(
                  draf == null
                      ? b.kejadian.narrativeResolution!
                      : '${draf.description} · '
                            '${rp(draf.allocations.fold(0, (n, x) => n + x.amount))} · '
                            '${draf.isPosted ? draf.voucher : 'Draf, belum dibukukan'}',
                  style: const TextStyle(fontSize: 15),
                ),
              )
            else
              _FormPenyelesaian(
                key: ValueKey(b.kejadian.id),
                kejadian: b.kejadian,
              ),
            if (draf != null && !draf.isPosted)
              Align(
                alignment: Alignment.centerLeft,
                child: Tombol(
                  'Periksa dan bukukan',
                  lebarPenuh: false,
                  ukuran: UkuranTombol.sedang,
                  jenis: JenisTombol.kedua,
                  ke: Layar.draf,
                  param: {'id': draf.id},
                  onPressed: null,
                ),
              ),
            Text(
              'Angka dan laporan resmi ${namaBulan(b.periode)} tidak berubah.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
            if (d.hambatan > 0 && d.berikut != null)
              Text(
                'Hambatan tutup buku ${namaBulan(d.berikut!)} tetap ada.',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// "Catat penyelesaian keuangan" (07-kejadian.md): the textarea and the
/// button; PeriodRepository.resolveIncident records it.
class _FormPenyelesaian extends ConsumerStatefulWidget {
  const _FormPenyelesaian({super.key, required this.kejadian});
  final CloseIncident kejadian;

  @override
  ConsumerState<_FormPenyelesaian> createState() => _FormPenyelesaianState();
}

class _FormPenyelesaianState extends ConsumerState<_FormPenyelesaian> {
  final _isi = TextEditingController();
  Refusal? _tolak;

  @override
  void dispose() {
    _isi.dispose();
    super.dispose();
  }

  String get _alasan =>
      _isi.text.trim().isEmpty ? 'Penyelesaian keuangan belum diisi.' : '';

  Future<void> _simpan() async {
    final k = widget.kejadian;
    final r = await perintah(
      ref,
      (a, kunci) => ref
          .read(periodRepositoryProvider)
          .resolveIncident(
            a,
            k.id,
            _isi.text,
            expectedRevision: k.revision,
            idempotencyKey: kunci,
          ),
    );
    if (mounted) setState(() => _tolak = r?.refusal);
  }

  @override
  Widget build(BuildContext context) {
    return KolomCelah(
      celah: 8,
      anak: [
        Semantics(
          label: 'Penyelesaian keuangan',
          child: TextField(
            controller: _isi,
            minLines: 2,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText:
                  'Apa yang diputuskan dan dilakukan, setelah ada keputusan '
                  'Jemaat',
            ),
          ),
        ),
        TombolBersyarat(
          label: 'Catat penyelesaian keuangan',
          tindakan: 'Catat penyelesaian keuangan',
          alasan: _alasan,
          periksa: () => _alasan,
          sudahMulai: _isi.text.isNotEmpty,
          tinggi: 46,
          radius: 12,
          paddingH: 20,
          baris: const [],
          onPressed: _simpan,
        ),
        if (_tolak case final t?)
          Penolakan(tindakan: t.action, sebab: t.because, jalan: const []),
      ],
    );
  }
}

/// "Catat kejadian": the finding in the last closed month, recorded as it
/// is; the settlement, when given, becomes a draft in the open month.
class FormKejadian extends ConsumerWidget {
  const FormKejadian({super.key, required this.s, this.onCatat});
  final KeadaanKejadian s;

  /// After a recorded incident (the phone opens its detail).
  final VoidCallback? onCatat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final d = ref.watch(kejadianProvider);
    final p = d.ditutup;
    if (p == null) {
      return Text(
        'Belum ada bulan yang ditutup. Kejadian dicatat untuk bulan yang '
        'sudah ditutup.',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      );
    }
    return KolomCelah(
      celah: 14,
      anak: [
        Semantics(
          header: true,
          child: const Text(
            'Kejadian baru',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: GarisStatus.ditutup.gaya(c).isi,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Kejadian setelah tutup buku hanya mencatat. Kejadian tidak '
            'mengubah angka ${namaBulan(p)}, tidak menghapus selisih, dan '
            'tidak menghilangkan hambatan tutup buku.',
            style: TextStyle(fontSize: 14, color: c.permukaan),
          ),
        ),
        Text(
          'Periode: ${namaBulan(p)} · Sudah ditutup',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        IsianTeks(controller: s.judul, label: 'Judul', jarakLabel: 6),
        IsianTeks(
          controller: s.fakta,
          label: 'Penjelasan',
          petunjuk: 'Apa yang ditemukan, apa adanya',
          jarakLabel: 6,
          baris: 3,
        ),
        IsianTeks(
          controller: s.dampak,
          label: 'Dampak pada rekonsiliasi',
          petunjuk: 'Misalnya: tidak ada',
          jarakLabel: 6,
        ),
        IsianTeks(
          controller: s.pj,
          label: 'Penanggung jawab',
          petunjuk: 'Nama dan jabatan',
          jarakLabel: 6,
        ),
        Text(
          'Penyelesaian keuangan · bila ada, menjadi draf di bulan berjalan',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChipSatu(
              teks: 'Uang masuk ke Kas',
              dipilih: s.masuk,
              onTap: () => s.arah(true),
            ),
            ChipSatu(
              teks: 'Uang keluar dari Kas',
              dipilih: !s.masuk,
              onTap: () => s.arah(false),
            ),
          ],
        ),
        IsianTeks(
          controller: s.jumlah,
          label: 'Jumlah penyelesaian',
          petunjuk: 'Kosongkan bila tidak ada',
          keyboardType: TextInputType.number,
          formatters: [FilteringTextInputFormatter.digitsOnly],
          jarakLabel: 6,
        ),
        if (s.tolak != null)
          Penolakan(
            tindakan: s.tolak!.action,
            sebab: s.tolak!.because,
            jalan: const [],
            ukuranTeks: 14,
          ),
        Tombol(
          'Catat kejadian',
          onPressed: () async {
            if (await s.catat(ref, d) != null) onCatat?.call();
          },
        ),
        Tombol('Batal', jenis: JenisTombol.teks, onPressed: s.tutup),
      ],
    );
  }
}
