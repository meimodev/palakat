import 'package:flutter/material.dart';

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
import '../../app/layar.dart';

/// Parts AlurAnggota and AlurPeristiwa draw identically (21-aluranggota.md):
/// the board's "two-person step" with the same header, cards and return form.

const hariIni = 20261116;
const hariIniTeks = '16/11/2026';
const penatua = 'Penatua Kolom 7';
const aktorAlur = ['Pemohon', penatua];

/// The boards' `tgl`: hh/bb/tttt with month 1–12 and day 1–31 (no month-length
/// check, as on the board) → yyyymmdd, else null.
int? tglAlur(String t) {
  final m = RegExp(r'^(\d\d)/(\d\d)/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), b = int.parse(m[2]!);
  if (b < 1 || b > 12 || d < 1 || d > 31) return null;
  return int.parse(m[3]!) * 10000 + b * 100 + d;
}

/// Phone frame with the header and a scrolling body whose blocks are 16 apart.
/// [tampilan] names the view: a new value starts the body at the top.
class KerangkaAlur extends StatelessWidget {
  const KerangkaAlur({
    super.key,
    required this.judul,
    required this.anakJudul,
    required this.tampilan,
    required this.kembaliKe,
    required this.blok,
  });

  final String judul, anakJudul, tampilan;

  /// Up link of the back arrow; a literal in each screen file (links_test).
  final Layar kembaliKe;
  final List<Widget> blok;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: judul,
            anakJudul: anakJudul,
            kembaliKe: kembaliKe,
            labelKembali: 'Kembali ke Data jemaat',
          ),
          Expanded(
            child: SingleChildScrollView(
              key: ValueKey(tampilan),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, b) in blok.indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    b,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Badge reading `st`: "Diverifikasi" `laut`, otherwise `garis`.
Widget lencanaSt(String st) => LencanaStatus(
  st,
  bentuk: st == 'Diverifikasi' ? BentukLencana.laut : BentukLencana.garis,
);

/// White card: column gap 6.
Widget kartuAlur(
  List<Widget> isi, {
  GarisStatus status = GarisStatus.dibukukan,
}) => Kartu(
  status: status,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (i, w) in isi.indexed) ...[
        if (i > 0) const SizedBox(height: 6),
        w,
      ],
    ],
  ),
);

/// Dashed note above the form after a return.
class CatatanDikembalikan extends StatelessWidget {
  const CatatanDikembalikan(this.alasan, {super.key});
  final String alasan;

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'Dikembalikan Penatua Kolom 7.',
            style: TextStyle(fontWeight: FontWeight.w700),
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

/// The Penatua's empty queue.
Widget kotakKosong(BuildContext context, String teks) => kartuAlur([
  const Text(
    'Tidak ada data yang menunggu verifikasi',
    style: TextStyle(fontWeight: FontWeight.w700),
  ),
  Text(teks, style: TextStyle(fontSize: 14, color: context.warna.tinta2)),
], status: GarisStatus.draf);

/// 13 `tinta3` caption.
Widget keteranganAlur(BuildContext context, String teks) =>
    Text(teks, style: TextStyle(fontSize: 13, color: context.warna.tinta3));

const tidakTampil =
    'Selama belum Diverifikasi, data ini tidak tampil di Warta Jemaat, surat atau laporan mana pun.';
const hanyaKolom7 =
    'Anda memverifikasi hanya data Kolom 7, dan bukan data keluarga Anda sendiri.';

/// "Verifikasi data" + "Kembalikan dengan alasan".
Widget tombolPenatua({
  required VoidCallback verif,
  required VoidCallback keKembali,
}) => BarisTombol(
  anak: [
    Tombol('Verifikasi data', onPressed: verif, jenis: JenisTombol.tinta),
    Tombol(
      'Kembalikan dengan alasan',
      onPressed: keKembali,
      jenis: JenisTombol.kedua,
      ukuran: UkuranTombol.sedang,
    ),
  ],
);

/// The Penatua's return form: head card, textarea, "Kembalikan" + "Batal".
/// The board's refusal slot can never show (`al && !al`), so only the hint.
List<Widget> formKembali({
  required String judul,
  required TextEditingController alasan,
  required VoidCallback onUbah,
  required VoidCallback kembalikan,
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
    // A02: the board's refusal slot is `al && !al` (dead); once typed, the
    // reason shows there.
    if (alasan.text.isNotEmpty && periksa().isNotEmpty)
      Penolakan(
        tindakan: 'Kembalikan',
        sebab: periksa(),
        jalan: const [],
        ukuranTeks: 14,
      ),
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: 'Kembalikan',
          tindakan: 'Kembalikan',
          alasan: periksa(),
          periksa: periksa,
          sudahMulai: false,
          onPressed: kembalikan,
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
