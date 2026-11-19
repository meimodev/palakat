import 'package:flutter/material.dart';

import '../../mock/mock.dart';
import '../../motion/kerangka.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol_bersyarat.dart';

/// Parts shared by Kejadian and WebKejadian (07-kejadian.md): the board state,
/// the badge, the blocker statement, a card's lines and the detail regions a–e.

// Board figures the mock lacks for K-2026-02 (its `eskalasi` and `beres`).
const _eskalasi = {'K-2026-02': 'Tidak perlu eskalasi.'};
const _beres = {
  'K-2026-02': 'Tidak ada penyelesaian keuangan; kuitansi dilampirkan sebagai dokumen susulan.',
};

/// The board's `state = { buka, pilih, selesai, isi }`; `buka` is the route
/// on the phone and unused on web. `isi` is the text field's controller.
class KeadaanKejadian extends ChangeNotifier {
  KeadaanKejadian() {
    isi.addListener(notifyListeners);
  }

  String pilih = kejadian.first.no;
  final Map<String, String> selesai = {};
  final isi = TextEditingController();

  Kejadian get cur => kejadian.firstWhere((k) => k.no == pilih);

  /// `k.beres || s.selesai[k.id] || ''`.
  String sel(Kejadian k) => _beres[k.no] ?? selesai[k.no] ?? '';

  bool get ok => isi.text.trim().isNotEmpty;

  /// `pick`: `pilih = id`, `isi = ''`.
  void pick(String no) {
    pilih = no;
    isi.clear();
    notifyListeners();
  }

  /// `simpan`: only when `isi.trim()` is not empty.
  void simpan() {
    if (!ok) return;
    selesai[pilih] = isi.text.trim();
    isi.clear();
    notifyListeners();
  }

  void ulang() {
    pilih = kejadian.first.no;
    selesai.clear();
    isi.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    isi.dispose();
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

/// The dark "Oktober 2026 tidak dapat ditutup" statement (ditutup).
class PernyataanHambatan extends StatelessWidget {
  const PernyataanHambatan({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 14, color: c.diTinta);
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
            'Oktober 2026 tidak dapat ditutup',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.permukaan,
            ),
          ),
          Text(
            'Kas punya selisih belum dijelaskan Rp85.000 yang berasal dari '
            'kejadian K-2026-01 di September 2026. November 2026 dan bulan '
            'sesudahnya ikut tertahan.',
            style: kecil,
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Aplikasi ini tidak menyediakan cara untuk memperbaikinya. ',
                ),
                TextSpan(
                  text: 'Yang perlu memutuskan: BPMJ Jemaat Karunia.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: c.permukaan,
                  ),
                ),
              ],
            ),
            style: kecil,
          ),
        ],
      ),
    );
  }
}

/// A card's three lines: code + badge, title 15/600, period.
class IsiKartuKejadian extends StatelessWidget {
  const IsiKartuKejadian({super.key, required this.k, required this.selesai});
  final Kejadian k;
  final bool selesai;

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
                k.no,
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 13,
                  color: c.tinta2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            LencanaKejadian(selesai),
          ],
        ),
        Text(
          k.judul,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        Text(
          '${k.periode} · Sudah ditutup',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }
}

/// Detail regions a–e of the chosen Kejadian, column gap 16.
class RinciKejadian extends StatelessWidget {
  const RinciKejadian({super.key, required this.s, required this.hambat});
  final KeadaanKejadian s;

  /// Tweak `menghambatBulanBerikutnya`.
  final bool hambat;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final d = s.cur;
    final sel = s.sel(d);
    final done = sel.isNotEmpty;
    const judul15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    final rinci = [
      ('Periode', '${d.periode} · Sudah ditutup'),
      ('Transaksi', d.transaksi),
      ('Dampak pada rekonsiliasi', d.dampak),
      ('Penanggung jawab', d.penanggungJawab),
      ('Hasil eskalasi', d.eskalasi ?? _eskalasi[d.no] ?? ''),
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
                  d.no,
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
              d.judul,
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
            Text(d.penjelasan, style: const TextStyle(fontSize: 15)),
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
            if (done) ...[
              // Keyed by the resolved state only: switching between two
              // resolved Kejadian keeps it mounted (motion.md rule 3).
              Gerak(
                Kerangka.muncul,
                lama: const Duration(milliseconds: 300),
                child: Text(sel, style: const TextStyle(fontSize: 15)),
              ),
              Text(
                'Angka dan laporan resmi ${d.periode} tidak berubah.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
              if (hambat && d.no == kejadian.first.no)
                const Text(
                  'Hambatan tutup buku Oktober 2026 tetap ada.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
            ] else ...[
              IsianTeks(
                controller: s.isi,
                labelSemantik: 'Penyelesaian keuangan',
                petunjuk: 'Apa yang diputuskan dan dilakukan, setelah ada keputusan Jemaat',
                baris: 2,
                minTinggi: 0,
                // The M3 bodyLarge letterSpacing .5 leaks into TextField.
                gaya: const TextStyle(letterSpacing: 0),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IntrinsicWidth(
                  child: TombolBersyarat(
                    label: 'Catat penyelesaian keuangan',
                    tindakan: 'Catat penyelesaian keuangan',
                    alasan: s.ok ? '' : 'Penyelesaian keuangan masih kosong',
                    periksa: () =>
                        s.ok ? '' : 'Penyelesaian keuangan masih kosong',
                    onPressed: s.simpan,
                    // The board shows no reason sentence (spec Notes).
                    sudahMulai: false,
                    teksBelumRedup: true,
                    tinggi: 46,
                    radius: 12,
                    paddingH: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
