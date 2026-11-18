import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';

/// AkunSaya's lock-screen sample: caption, the `tinta` sample "Palakat" over
/// '{modul}: {jumlah} {jenis}', and the footnote; siblings 6 apart (the
/// card's column gap). Never a name, family, Kolom or amount.
class PratinjauLayarKunci extends StatelessWidget {
  const PratinjauLayarKunci({
    super.key,
    required this.modul,
    required this.jumlah,
    required this.jenis,
  });

  /// 'Data jemaat'.
  final String modul;
  final int jumlah;

  /// 'data menunggu verifikasi'.
  final String jenis;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Yang tampil di layar kunci', style: kecil),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: c.tinta,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: 14, color: c.permukaan),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Palakat',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text('$modul: $jumlah $jenis'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hanya modul dan jenis pekerjaannya. Tidak ada nama orang dan tidak '
          'ada jumlah uang di layar kunci.',
          style: kecil,
        ),
      ],
    );
  }
}
