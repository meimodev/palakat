import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'warta_editor.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

class WebWartaEditorScreen extends StatefulWidget {
  const WebWartaEditorScreen({super.key});

  @override
  State<WebWartaEditorScreen> createState() => _WebWartaEditorScreenState();
}

class _WebWartaEditorScreenState extends State<WebWartaEditorScreen>
    with KeadaanWarta {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final i = ki('WebWartaEditor');
    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 4),
      isi: [
        Column(
          key: kunciIsi,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline breadcrumb in the 15 px page text (a 22 px line box):
            // the 44 px target overhangs it by 11 above and below.
            const MarginNegatif(
              atas: 11,
              bawah: 11,
              child: Tautan(
                ke: Layar.warta,
                cara: Cara.naik,
                child: SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    child: TautanTeks('Warta Jemaat', ukuran: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: Text(
                'Warta Jemaat · edisi 22/11/2026',
                style: PalakatText.judulHalaman.copyWith(color: c.tinta),
              ),
            ),
            Text(
              'Disusun dari data yang sudah ada; tidak diketik ulang',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(
              dasar: 520,
              maks: 880,
              child: IsiWartaEditor(
                ki: i,
                pilih: pilih,
                lihatPdf: const Tombol(
                  'Lihat PDF',
                  onPressed: null,
                  ke: Layar.wartaPdf,
                  param: {'edisi': belumDipindahId},
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                ),
                buatRalat: const Tombol(
                  'Buat ralat',
                  onPressed: null,
                  ke: Layar.warta,
                  cara: Cara.naik,
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                ),
                tampilkanNama: const Tautan(
                  ke: Layar.bukaNama,
                  param: {'edisi': belumDipindahId},
                  child: TautanTampilkanNama(),
                ),
              ),
            ),
            Lentur(
              dasar: 300,
              maks: 480,
              child: _Pratinjau(lengkap: i != 4, belum: i != 3),
            ),
          ],
        ),
      ],
    );
  }
}

/// The aside: "Pratinjau halaman 1", the miniature A4 page, the caption.
class _Pratinjau extends StatelessWidget {
  const _Pratinjau({required this.lengkap, required this.belum});

  final bool lengkap, belum;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    // Board 12 px → 13 (CONVENTIONS).
    final isi = TextStyle(fontSize: 13, color: c.tinta);

    Widget bagian(String judul, Widget badan) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 2),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.tinta)),
          ),
          child: Text(
            judul.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
            ),
          ),
        ),
        DefaultTextStyle.merge(style: isi, child: badan),
      ],
    );

    Widget baris(String a, String b) => Row(
      children: [
        Expanded(child: Text(a)),
        const SizedBox(width: 16),
        Text(b, style: const TextStyle(fontFamily: PalakatText.mono)),
      ],
    );

    final bagianBagian = [
      bagian(
        'Pengumuman',
        const Text(
          'Kerja bakti halaman gereja, Sabtu 21/11/2026.\n'
          'Pendaftaran katekisasi sidi 2027 dibuka.',
        ),
      ),
      if (lengkap) ...[
        bagian(
          'Ibadah minggu ini',
          const Text('Subuh 05.00 · Pagi 09.00 · Malam 18.00'),
        ),
        bagian(
          'Jumlah kehadiran 15/11/2026',
          const Text('412 orang: Subuh 96 · Pagi 231 · Malam 85'),
        ),
        bagian(
          'Peristiwa jemaat',
          const Text(
            'Syukur HUT pernikahan: Keluarga Wenas-Lasut — Kolom 7\n'
            'Sampul syukur: Tanpa nama, Kolom 4',
          ),
        ),
        bagian(
          'Ringkasan keuangan Oktober 2026',
          Column(
            children: [
              baris('Pendapatan', 'Rp14.820.000'),
              baris('Belanja', 'Rp11.455.000'),
            ],
          ),
        ),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              // Board h2.
              child: Semantics(
                header: true,
                child: const Text(
                  'Pratinjau halaman 1',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 16),
            belum
                ? const LencanaStatus(
                    'Belum diterbitkan',
                    bentuk: BentukLencana.draf,
                  )
                : const LencanaStatus(
                    'Diterbitkan',
                    bentuk: BentukLencana.tinta,
                  ),
          ],
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 210 / 297,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.permukaan,
              border: Border.all(color: c.garisTegas),
            ),
            // overflow: hidden; the page clips, it never grows.
            child: ClipRect(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 27,
                  vertical: 29,
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: c.tinta),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Column(
                        children: [
                          Text(
                            'WARTA JEMAAT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .5,
                            ),
                          ),
                          Text(
                            'GMIM Jemaat Karunia · Minggu, 22 November 2026',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      for (final b in bagianBagian) ...[
                        const SizedBox(height: 14),
                        b,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Yang tampil di sini sama dengan PDF: bagian dari modul yang tidak '
          'aktif tidak dicetak, dan nama mengikuti Tampilan nama.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }
}
