import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'memuat_isi.dart';

/// Web · Memuat, gagal memuat, Bukukan tidak terjadi (spec 12, WebMemuat).
class WebMemuatScreen extends StatefulWidget {
  const WebMemuatScreen({super.key});
  @override
  State<WebMemuatScreen> createState() => _WebMemuatScreenState();
}

class _WebMemuatScreenState extends State<WebMemuatScreen>
    with PengendaliMemuat<WebMemuatScreen> {
  @override
  String get stem => 'WebMemuat';

  @override
  Widget build(BuildContext context) {
    final st = this.st;
    const h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.w700);
    final judul = beranda
        ? Semantics(header: true, child: const Text('Beranda', style: h1))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb: a 44 px target over the 14 × 1.45 line.
              const MarginNegatif(
                atas: 11.85,
                bawah: 11.85,
                child: Tautan(
                  ke: 'WebTransaksi',
                  cara: Cara.naik,
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: TautanTeks('Transaksi', ukuran: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text('Periksa dan bukukan', style: h1),
              ),
            ],
          );
    final isi = beranda
        ? isiBeranda(
            context,
            st,
            onCoba: coba,
            buka: Tautan(
              ke: 'WebBeranda',
              cara: Cara.ganti,
              radius: 14,
              child: rupaTautanKedua(
                context,
                'Buka Beranda',
                tinggi: 48,
                radius: 14,
              ),
            ),
          )
        : [
            ...isiPeriksa(context, st),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (st == KeadaanMemuat.aksi) ...[
                  Tombol(
                    'Coba lagi',
                    onPressed: cobaBuku,
                    jenis: JenisTombol.tinta,
                    ukuran: UkuranTombol.ringkas,
                    lebarPenuh: false,
                  ),
                  Tautan(
                    ke: 'WebTransaksi',
                    cara: Cara.naik,
                    radius: 12,
                    child: rupaTautanKedua(
                      context,
                      'Biarkan sebagai draf',
                      tinggi: 46,
                      radius: 12,
                      lebarPenuh: false,
                    ),
                  ),
                ] else
                  Tautan(
                    ke: 'WebTransaksi',
                    cara: Cara.naik,
                    radius: 12,
                    child: rupaTautanKedua(
                      context,
                      'Kembali ke Transaksi',
                      tinggi: 46,
                      radius: 12,
                      lebarPenuh: false,
                    ),
                  ),
              ],
            ),
          ];
    return HalamanWeb(
      // The board keeps "Beranda" active in both views.
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 0,
        pengguna: PenggunaKeuangan(ikutJabatanKosong: false),
      ),
      isi: [
        Align(alignment: Alignment.centerLeft, child: judul),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: kolom(16, isi),
          ),
        ),
      ],
    );
  }
}
