import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/batang_pembagian.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../ponsel/bagi_logika.dart';

/// Web · Bagi ke beberapa Mata Anggaran (spec 03, WebBagi). Same logic as
/// Bagi; the picker is inline option chips instead of a sheet.
class WebBagiScreen extends StatefulWidget {
  const WebBagiScreen({super.key});
  @override
  State<WebBagiScreen> createState() => _WebBagiScreenState();
}

class _WebBagiScreenState extends State<WebBagiScreen> with LogikaBagi {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pilihanSisa = pilihan;
    final kecil = TextStyle(fontSize: 14, color: c.tinta2);

    final kiri = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border.all(color: c.garis),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < baris.length; i++) _baris(context, i),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('Tambah baris', style: kecil),
        const SizedBox(height: 8),
        if (pilihanSisa.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in pilihanSisa)
                  Tekan(
                    onTap: () => tambah(k),
                    radius: 12,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: ShapeDecoration(
                        shape: GarisBorder.putus(c.putus, radius: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            k,
                            style: TextStyle(
                              fontFamily: PalakatText.mono,
                              fontSize: 13,
                              color: c.tinta2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // A flex item shrinks to its min-content: wraps.
                          Flexible(
                            child: Text(
                              maBagi[k]!,
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
      ],
    );

    final samping = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Jumlah (Rp)', style: kecil),
        const Text(
          'Rp1.250.000',
          style: TextStyle(
            fontFamily: PalakatText.mono,
            fontSize: 34,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        BatangPembagian(total: jumlahBagi, bagian: bagian(context)),
        const SizedBox(height: 12),
        SisaPembagian(label: labelSisa, jumlah: sisa.abs(), pas: sisa == 0),
        if (!pas) ...[const SizedBox(height: 12), Text(alasan, style: kecil)],
        if (dipakai) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            container: true,
            child: Text(
              status,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.laut,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        TekanAria(
          onTap: pakai,
          aktif: pas,
          petunjuk: pas ? null : alasan,
          radius: 14,
          child: RupaTombol(
            label: 'Pakai pembagian ini',
            isi: pas ? c.laut : c.garis,
            warnaTeks: pas ? c.diLaut : c.tinta3,
            radius: 14,
            tinggi: 52,
            paddingH: 20,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Di laporan, jumlahnya tampil sekali dengan daftar Mata Anggarannya.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );

    return DefaultTextHeightBehavior(
      textHeightBehavior: cssLeading,
      child: HalamanWeb(
        jabatanKosong: true,
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 1,
          pengguna: PenggunaKeuangan(),
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // An inline link on a 15 / 1.45 line (21.75); the 44 px target
              // overhangs below.
              MarginNegatif(
                bawah: 44 - 21.75,
                child: Tautan(
                  ke: 'WebCatat',
                  cara: Cara.naik,
                  // Tekan stretches its child to 44 high: keep the line on top.
                  child: const Align(
                    alignment: Alignment.topLeft,
                    widthFactor: 1,
                    child: SizedBox(
                      height: 21.75,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1,
                        child: TautanTeks('Catat transaksi', ukuran: 14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Bagi ke beberapa Mata Anggaran',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Belanja · Toko Sinar · satu pembayaran, satu No. Bukti',
                style: kecil,
              ),
            ],
          ),
          BarisLentur(
            jarak: 28,
            anak: [
              Lentur(dasar: 480, tumbuh: 999, child: kiri),
              Lentur(dasar: 340, child: samping),
            ],
          ),
        ],
      ),
    );
  }

  Widget _baris(BuildContext context, int i) {
    final c = context.warna;
    final b = baris[i];
    return Container(
      key: ValueKey(b.k),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: i > 0 ? Border(top: BorderSide(color: c.garis)) : null,
      ),
      child: BarisLentur(
        jarak: 14,
        jarakBaris: 10,
        rata: CrossAxisAlignment.center,
        anak: [
          Lentur(
            dasar: 12,
            tumbuh: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: warnaBaris(context, i),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Lentur(
            dasar: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belanja ${b.k}',
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 13,
                    color: c.tinta2,
                  ),
                ),
                ExcludeSemantics(
                  child: Text(
                    b.nama,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          if (bisaSisa(b))
            Lentur(
              dasar: _lebarIsiSisa(context),
              tumbuh: 0,
              child: IsiSisaBagi(onTap: () => isiSisa(b)),
            ),
          Lentur(
            dasar: 170,
            tumbuh: 0,
            child: IsianBarisBagi(
              label: b.nama,
              controller: isian(b),
              onChanged: (t) => ubah(b, t),
              lebar: 170,
            ),
          ),
          Lentur(
            dasar: 44,
            tumbuh: 0,
            child: Tekan(
              onTap: () => lepas(b),
              label: 'Lepas baris ${b.nama}',
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: PalakatIkon(Ikon.silang, ukuran: 18, warna: c.tinta3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The button's own width (flex basis auto): "Isi sisa" 14/700 plus 0 12.
  double _lebarIsiSisa(BuildContext context) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'Isi sisa',
        style: TextStyle(
          fontFamily: PalakatText.sans,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final w = tp.width + 24;
    tp.dispose();
    return w;
  }
}
