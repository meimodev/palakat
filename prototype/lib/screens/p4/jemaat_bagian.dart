import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// Parts the membership screens draw alike (the p4 boards and their Alur
/// flows, 21-aluranggota.md): the phone frame, cards, the verifier's buttons
/// and the reason form.

/// Phone frame: header with the back arrow (Data jemaat for officers, the
/// home for a member) and a scrolling body whose blocks are 16 apart.
/// [tampilan] names the view: a new value starts the body at the top.
class KerangkaJemaat extends ConsumerWidget {
  const KerangkaJemaat({
    super.key,
    required this.judul,
    required this.anakJudul,
    required this.tampilan,
    required this.blok,
  });

  final String judul, anakJudul;
  final Object tampilan;
  final List<Widget> blok;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ke = ref.watch(kembaliJemaatProvider);
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: judul,
              anakJudul: anakJudul,
              kembaliKe: ke,
              labelKembali: ke == Layar.beranda
                  ? 'Kembali ke Beranda'
                  : 'Kembali ke Data jemaat',
            ),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey(tampilan),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: kolomJemaat(blok),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [anak] 16 apart (a CSS flex column `gap: 16px`).
Widget kolomJemaat(List<Widget> anak, {double jarak = 16}) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    for (final (i, b) in anak.indexed) ...[
      if (i > 0) SizedBox(height: jarak),
      b,
    ],
  ],
);

/// Badge of an item status: "Diverifikasi" and "Aktif" `laut`, a return or
/// decline `bata`, otherwise `garis`.
Widget lencanaSt(String st) => LencanaStatus(
  st,
  bentuk: switch (st) {
    'Diverifikasi' || 'Aktif' => BentukLencana.laut,
    'Dikembalikan' || 'Tidak diterima' => BentukLencana.bata,
    'Belum dikonfirmasi' => BentukLencana.draf,
    _ => BentukLencana.garis,
  },
);

/// White card: column gap 6.
Widget kartuAlur(
  List<Widget> isi, {
  GarisStatus status = GarisStatus.dibukukan,
}) => Kartu(status: status, child: kolomJemaat(isi, jarak: 6));

/// 13 `tinta3` caption.
Widget keteranganAlur(BuildContext context, String teks) =>
    Text(teks, style: TextStyle(fontSize: 13, color: context.warna.tinta3));

/// 14 `tinta2` line.
Widget barisAlur(BuildContext context, String teks) =>
    Text(teks, style: TextStyle(fontSize: 14, color: context.warna.tinta2));

/// Dashed note above the form after a return.
class CatatanDikembalikan extends StatelessWidget {
  const CatatanDikembalikan(this.oleh, this.alasan, {super.key});
  final String oleh, alasan;

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Dikembalikan $oleh.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: alasan,
            style: TextStyle(color: context.warna.tinta2),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 14),
    ),
  );
}

/// The verifier's empty queue.
Widget kotakKosong(BuildContext context, String teks) => kartuAlur([
  const Text(
    'Tidak ada data yang menunggu verifikasi',
    style: TextStyle(fontWeight: FontWeight.w700),
  ),
  barisAlur(context, teks),
], status: GarisStatus.draf);

/// "Anda memverifikasi hanya data {Kolom}, dan bukan data keluarga Anda
/// sendiri."
String hanyaKolom(String kolom) =>
    'Anda memverifikasi hanya data $kolom, dan bukan data keluarga Anda '
    'sendiri.';

const tidakTampil =
    'Selama belum Diverifikasi, data ini tidak tampil di Warta Jemaat, surat '
    'atau laporan mana pun.';

/// "Verifikasi data" + "Kembalikan dengan alasan" (+ "Tidak diterima").
Widget tombolPenatua({
  required VoidCallback verif,
  required VoidCallback keKembali,
  VoidCallback? keTolak,
}) => BarisTombol(
  anak: [
    Tombol('Verifikasi data', onPressed: verif, jenis: JenisTombol.tinta),
    Tombol(
      'Kembalikan dengan alasan',
      onPressed: keKembali,
      jenis: JenisTombol.kedua,
      ukuran: UkuranTombol.sedang,
    ),
    if (keTolak != null)
      Tombol(
        'Tidak diterima',
        onPressed: keTolak,
        jenis: JenisTombol.teks,
        ukuran: UkuranTombol.sedang,
      ),
  ],
);

/// The verifier's reason form: head card, textarea, [tindakan] + "Batal".
List<Widget> formAlasan({
  required String judul,
  required String tindakan,
  required TextEditingController alasan,
  required VoidCallback onUbah,
  required VoidCallback kirim,
  required VoidCallback batal,
}) {
  String periksa() => alasan.text.trim().isEmpty ? 'alasan belum diisi.' : '';
  return [
    kartuAlur([KepalaKartu(judul: judul, ujung: lencanaSt('Diajukan'))]),
    IsianAlur(
      label: 'Alasan · wajib',
      controller: alasan,
      baris: 3,
      onChanged: (_) => onUbah(),
    ),
    if (alasan.text.isNotEmpty && periksa().isNotEmpty)
      Penolakan(
        tindakan: tindakan,
        sebab: periksa(),
        jalan: const [],
        ukuranTeks: 14,
      ),
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: tindakan,
          tindakan: tindakan,
          alasan: periksa(),
          periksa: periksa,
          sudahMulai: false,
          onPressed: kirim,
        ),
        Tombol(
          'Batal',
          onPressed: batal,
          jenis: JenisTombol.teks,
          ukuran: UkuranTombol.kecil,
        ),
      ],
    ),
  ];
}

/// A refused command as the boards draw it.
Widget penolakanDari(Refusal r) => Penolakan(
  tindakan: r.action,
  sebab: r.whoCanAct == null
      ? r.because
      : '${r.because} Yang perlu bertindak: ${r.whoCanAct}.',
  jalan: const [],
  ukuranTeks: 14,
);
