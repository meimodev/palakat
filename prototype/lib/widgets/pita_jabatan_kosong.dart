import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';

/// Shown while an Operator runs a vacant post (`role="status"`). The screen
/// or scaffold decides when (the global `jabatanKosong` switch, only on
/// boards with the tweak); this widget only draws it.
class PitaJabatanKosong extends StatelessWidget {
  /// Full width above the header and scroll area: `tinta` field, padding
  /// 10 24 8, 13 px, line height 1.3, centred, no radius.
  const PitaJabatanKosong.ponsel({super.key, this.jabatan = 'Bendahara Jemaat'})
    : _web = false,
      siaran = true,
      sejak = null,
      operator = null,
      padding = const EdgeInsets.fromLTRB(24, 10, 24, 8);

  /// First child of `main`: `tinta` field, radius 14, padding 12 16 (12 14
  /// on six boards), 14 px. Pass `sejak: null` for the Penatua Kolom 2 form
  /// ("Anda menjalankan jabatan kosong Penatua Kolom 2.").
  const PitaJabatanKosong.web({
    super.key,
    this.jabatan = 'Bendahara Jemaat',
    this.sejak = '16/11/2026 08.15',
    this.operator = 'Yanti Sumual',
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.siaran = true,
  }) : _web = true;

  final bool _web;
  final String jabatan;
  final String? sejak, operator;
  final EdgeInsetsGeometry padding;

  /// false where the board gives the banner no role (JabatanKosong,
  /// WebJabatanKosong, WebAlurJabatanKosong: plain text, not a live region).
  final bool siaran;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const tebal = TextStyle(fontWeight: FontWeight.w700);
    final Widget teks = _web
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      'Anda menjalankan jabatan kosong $jabatan'
                      '${sejak == null ? '' : ' sejak $sejak'}.',
                  style: tebal,
                ),
                TextSpan(
                  text:
                      ' Setiap tindakan dicatat sebagai dijalankan oleh '
                      'Operator $operator.',
                  style: TextStyle(color: c.diTinta2),
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.permukaan),
          )
        : Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Menjalankan jabatan kosong',
                  style: tebal,
                ),
                TextSpan(text: ' · $jabatan'),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.3, color: c.permukaan),
          );
    return Semantics(
      container: true,
      liveRegion: siaran,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: c.tinta,
          borderRadius: _web ? BorderRadius.circular(14) : null,
        ),
        child: teks,
      ),
    );
  }
}
