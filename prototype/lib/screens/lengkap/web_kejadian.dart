import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/keuangan/akhir_bulan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import 'kejadian_bagian.dart';
import '../../app/layar.dart';

/// Web · Kejadian setelah tutup buku (07-kejadian.md): list and detail side
/// by side under the standard side nav.
class WebKejadianScreen extends ConsumerStatefulWidget {
  const WebKejadianScreen({super.key});
  @override
  ConsumerState<WebKejadianScreen> createState() => _WebKejadianScreenState();
}

class _WebKejadianScreenState extends ConsumerState<WebKejadianScreen> {
  final _s = KeadaanKejadian();

  @override
  void dispose() {
    _s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(kejadianProvider);
    return ListenableBuilder(
      listenable: _s,
      builder: (context, _) {
        final b = _s.cur(d);
        return HalamanWeb(
          layarKeuangan: true,
          nav: const NavSamping(item: navKeuangan, aktif: 4),
          isi: [
            _Judul(),
            if (d.hambatan > 0 && d.butir.isNotEmpty) PernyataanHambatan(d: d),
            BarisLentur(
              jarak: 24,
              anak: [
                Lentur(
                  dasar: 360,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (d.ditutup != null && !_s.membuka) ...[
                        Tombol(
                          'Catat kejadian baru',
                          jenis: JenisTombol.kedua,
                          onPressed: _s.buka,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _Daftar(s: _s, d: d),
                    ],
                  ),
                ),
                Lentur(
                  dasar: 520,
                  tumbuh: 999,
                  child: _s.membuka
                      ? FormKejadian(s: _s)
                      : b == null
                      ? const SizedBox.shrink()
                      : RinciKejadian(b: b, d: d),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Judul extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // A 44 px target drawn in the board's 15 × 1.45 line.
      const MarginNegatif(
        atas: (44 - 15 * 1.45) / 2,
        bawah: (44 - 15 * 1.45) / 2,
        child: Tautan(
          ke: Layar.tutupBuku,
          cara: Cara.naik,
          child: SizedBox(
            height: 44,
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: TautanTeks('Bulan dan tutup buku', ukuran: 14),
            ),
          ),
        ),
      ),
      const SizedBox(height: 2),
      Semantics(
        header: true,
        child: const Text(
          'Kejadian setelah tutup buku',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _Daftar extends StatelessWidget {
  const _Daftar({required this.s, required this.d});
  final KeadaanKejadian s;
  final DaftarKejadian d;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pilih = s.cur(d)?.kejadian.id;
    return Container(
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final b in d.butir)
              Tekan(
                dipilih: b.kejadian.id == pilih,
                onTap: () => s.pick(b.kejadian.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: b.kejadian.id == pilih ? c.lautLembut : c.permukaan,
                    border: Border(top: BorderSide(color: c.garis)),
                  ),
                  // `box-shadow: inset 3px 0 0 laut` on the chosen row.
                  foregroundDecoration: b.kejadian.id == pilih
                      ? BoxDecoration(
                          border: Border(
                            left: BorderSide(color: c.laut, width: 3),
                          ),
                        )
                      : null,
                  child: IsiKartuKejadian(b: b),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
