import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'garis.dart';

enum _BentukPita { sementara, resmi, a4Sementara, terbatas }

/// The banner above a report: provisional (dashed `putus`) or official
/// (`tinta` field, mono ID). The A4 forms are the print banners.
class PitaLaporan extends StatelessWidget {
  /// Laporan, WebLaporan: radius 14, 1.5 dashed `putus`, padding 12 16.
  const PitaLaporan.sementara({
    super.key,
    required String this.kalimat,
    this.sebaris = false,
  }) : _bentuk = _BentukPita.sementara,
       judul = 'Laporan sementara',
       dibekukan = null,
       idSalinan = null,
       versi = null;

  /// `tinta` field, `permukaan` text; line in `diTinta2`:
  /// "Dibekukan saat tutup buku {dibekukan} · ID {idSalinan}[ · Versi Mata Anggaran {versi}]".
  const PitaLaporan.resmi({
    super.key,
    required String this.dibekukan,
    required String this.idSalinan,
    this.versi,
    this.sebaris = false,
    this.judul = 'Laporan resmi',
  }) : _bentuk = _BentukPita.resmi,
       kalimat = null;

  /// A4Sementara: radius 8, 1.5 dashed `tinta3`, padding 10 14, 15 px,
  /// "**Laporan sementara.** {kalimat}".
  const PitaLaporan.a4Sementara({super.key, required String this.kalimat})
    : _bentuk = _BentukPita.a4Sementara,
      judul = 'Laporan sementara.',
      sebaris = false,
      dibekukan = null,
      idSalinan = null,
      versi = null;

  /// A4Terbatas: 2 px solid `tinta`, no radius, padding 10 14, 15 px,
  /// "**TERBATAS · Akses terbatas: Peruntukan Diakonia.** {kalimat}".
  const PitaLaporan.terbatas({
    super.key,
    required String this.kalimat,
    this.judul = 'TERBATAS · Akses terbatas: Peruntukan Diakonia.',
  }) : _bentuk = _BentukPita.terbatas,
       sebaris = false,
       dibekukan = null,
       idSalinan = null,
       versi = null;

  final _BentukPita _bentuk;
  final String judul;
  final String? kalimat, dibekukan, idSalinan, versi;

  /// Web: title and sentence on one wrapping row (gap 4 16, baseline),
  /// sentence 14 instead of the phone's 13.
  final bool sebaris;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final a4 =
        _bentuk == _BentukPita.a4Sementara || _bentuk == _BentukPita.terbatas;
    final resmi = _bentuk == _BentukPita.resmi;

    final Widget isi;
    if (a4) {
      isi = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: judul,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: ' $kalimat'),
          ],
        ),
        style: const TextStyle(fontSize: 15),
      );
    } else {
      final kecil = TextStyle(
        fontSize: sebaris ? 14 : 13,
        color: resmi ? c.diTinta2 : c.tinta2,
      );
      final Widget sub = resmi
          ? Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Dibekukan saat tutup buku $dibekukan · ID '),
                  TextSpan(
                    text: idSalinan,
                    style: const TextStyle(fontFamily: PalakatText.mono),
                  ),
                  if (versi != null)
                    TextSpan(text: ' · Versi Mata Anggaran $versi'),
                ],
              ),
              style: kecil,
            )
          : Text(kalimat!, style: kecil);
      final kepala = Text(
        judul,
        style: const TextStyle(fontWeight: FontWeight.w700),
      );
      isi = sebaris
          ? Wrap(
              spacing: 16,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [kepala, sub],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [kepala, sub],
            );
    }

    final ShapeBorder garis = switch (_bentuk) {
      _BentukPita.sementara => GarisBorder.putus(c.putus, radius: 14),
      _BentukPita.resmi => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      _BentukPita.a4Sementara => GarisBorder.putus(c.tinta3, radius: 8),
      _BentukPita.terbatas => GarisBorder.penuh(c.tinta, tebal: 2),
    };

    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: a4
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          color: resmi ? c.tinta : null,
          shape: garis,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: resmi ? c.permukaan : c.tinta),
          child: isi,
        ),
      ),
    );
  }
}
