import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'alur_kit.dart';
import 'garis_status.dart';
import 'kecil.dart';
import 'lencana_status.dart';
import 'tombol.dart';

/// The 'Jabatan Anda' card (BerandaJabatan, WebBerandaJabatan): `Kartu`
/// padding 12 14, gap 8: name 700 over "Jabatan Anda" 13 `tinta3`, then the
/// posts as `peran` badges in a wrap, gap 6.
class DaftarJabatan extends StatelessWidget {
  const DaftarJabatan({super.key, required this.nama, required this.jabatan});

  final String nama;
  final List<String> jabatan;

  @override
  Widget build(BuildContext context) => Kartu(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nama, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(
          'Jabatan Anda',
          style: TextStyle(fontSize: 13, color: context.warna.tinta3),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final j in jabatan)
              LencanaStatus(j, bentuk: BentukLencana.peran),
          ],
        ),
      ],
    ),
  );
}

/// Second line of a work item: 'Sebagai {jabatan} · {rincian}', 13 `tinta3`.
/// Only for a person with more than one post.
class LabelSebagai extends StatelessWidget {
  const LabelSebagai({super.key, required this.jabatan, required this.rincian});

  final String jabatan;

  /// '2 permohonan · 2 peristiwa'.
  final String rincian;

  @override
  Widget build(BuildContext context) => Text(
    'Sebagai $jabatan · $rincian',
    style: TextStyle(fontSize: 13, color: context.warna.tinta3),
  );
}

/// The notice before confirming. [BertindakSebagai.satu]: `lautLembut`,
/// radius 12, padding 12 14, 14 px, "**Anda bertindak sebagai {jabatan}.**"
/// + [kalimat] in `tinta2`. [BertindakSebagai.pilih]: 1.5 `tinta`, radius 12,
/// `permukaan`, then one 48-high `kedua` [Tombol] per post in a [BarisTombol].
class BertindakSebagai extends StatelessWidget {
  const BertindakSebagai.satu({
    super.key,
    required String this.jabatan,
    this.kalimat = 'Hanya jabatan ini yang berwenang.',
  }) : pilihan = null,
       onPilih = null,
       jarak = 0;

  const BertindakSebagai.pilih({
    super.key,
    required List<String> jabatan,
    required ValueChanged<String> this.onPilih,
    this.kalimat = 'Pilih salah satu.',
    this.jarak = 16,
  }) : pilihan = jabatan,
       jabatan = null;

  final String? jabatan;
  final List<String>? pilihan;
  final ValueChanged<String>? onPilih;

  /// After the bold lead. Boards add more, e.g. "Hanya jabatan ini yang
  /// berwenang memverifikasi data Kolom 7." or "Pilih salah satu. Jabatan
  /// yang Anda pilih tercatat di Riwayat dan tidak dapat diubah setelahnya."
  final String kalimat;

  /// pilih: gap between the notice and its buttons, the body gap of the
  /// screen (16 phone; the web column's gap there).
  final double jarak;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const tebal = TextStyle(fontWeight: FontWeight.w700);
    if (pilihan == null) {
      return Semantics(
        container: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.lautLembut,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Anda bertindak sebagai $jabatan.',
                  style: tebal,
                ),
                TextSpan(
                  text: ' $kalimat',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    final n = pilihan!.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Kartu(
          status: GarisStatus.terpilih,
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: n == 2
                      ? 'Dua jabatan Anda dapat menyetujui ini.'
                      : '$n jabatan Anda dapat menyetujui ini.',
                  style: tebal,
                ),
                TextSpan(text: ' $kalimat'),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        SizedBox(height: jarak),
        BarisTombol(
          anak: [
            for (final j in pilihan!)
              Tombol(
                'Sebagai $j',
                onPressed: () => onPilih!(j),
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
              ),
          ],
        ),
      ],
    );
  }
}
