import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'garis.dart';

/// The step chips "1 · Draf", "2 · Sudah diperiksa" … Not pressable.
class Tahapan extends StatelessWidget {
  const Tahapan({super.key, required this.langkah, required this.selesai});

  /// 'Draf', 'Sudah diperiksa', 'Diterbitkan'.
  final List<String> langkah;

  /// How many from the start are done.
  final int selesai;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Semantics(
      container: true,
      label:
          'Langkah $selesai dari ${langkah.length}: '
          '${[for (var i = 0; i < langkah.length; i++) '${i + 1} ${langkah[i]}'].join(', ')}',
      child: ExcludeSemantics(
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < langkah.length; i++)
              Container(
                // CSS content-box: min-height 30 plus the 1.5 line on both sides.
                constraints: const BoxConstraints(minHeight: 33),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: ShapeDecoration(
                  color: i < selesai ? c.tinta : null,
                  shape: i < selesai
                      ? GarisBorder.penuh(c.tinta, radius: 999)
                      : GarisBorder.putus(c.putus, radius: 999),
                ),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(
                    '${i + 1} · ${langkah[i]}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: i < selesai ? c.permukaan : c.tinta3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
