import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

const _stem = 'WebDataGanda';
const _gabungkan = 'Gabungkan', _bukan = 'Bukan orang yang sama';

/// Web · Kemungkinan data ganda: the Operator compares two records that may
/// be the same person. Board state `{ k: null }`; the view is `k ?? keadaan`.
class WebDataGandaScreen extends StatefulWidget {
  const WebDataGandaScreen({super.key});

  @override
  State<WebDataGandaScreen> createState() => _WebDataGandaScreenState();
}

class _WebDataGandaScreenState extends State<WebDataGandaScreen> {
  String? _k;
  String? _keadaan;
  String? _tampil;
  final _gulir = ScrollController();

  void _ke(String o) => setState(() => _k = o);

  @override
  void dispose() {
    _gulir.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keadaan = context.tweak<String>(_stem, 'keadaan');
    if (keadaan != _keadaan) {
      _keadaan = keadaan;
      _k = null; // a change in the Keadaan panel resets the board state
    }
    final v = _k ?? keadaan;
    if (_tampil != null && v != _tampil) {
      // A new view starts at the top of the page.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_gulir.hasClients) _gulir.jumpTo(0);
      });
    }
    _tampil = v;
    final c = context.warna;

    Widget kartu(String asal, LencanaStatus lencana) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaKartu(judul: 'Novita Wenas', ujung: lencana),
          for (final b in [
            const BarisInfo('Tanggal lahir', '14/03/1996'),
            const BarisInfo('Kolom', 'Kolom 7'),
            BarisInfo('Asal data', asal),
          ]) ...[const SizedBox(height: 6), b],
        ],
      ),
    );

    const tebal = TextStyle(fontWeight: FontWeight.w700);
    final isi = <Widget>[
      KisiOtomatis(
        minLebar: 300,
        jarak: 16,
        anak: [
          kartu(
            'Permohonan menjadi anggota',
            const LencanaStatus('Aktif', bentuk: BentukLencana.laut),
          ),
          kartu(
            'Buku anggota · baris 23',
            const LencanaStatus(
              'Belum dikonfirmasi',
              bentuk: BentukLencana.draf,
            ),
          ),
        ],
      ),
      ...switch (v) {
        _gabungkan => [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: c.lautLembut,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Digabungkan menjadi satu orang.',
                    style: tebal,
                  ),
                  TextSpan(
                    text: ' Riwayat keuangan, jabatan, keluarga, pelayanan dan Riwayat aktivitas keduanya tetap ada.',
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Oleh Yanti Sumual, Operator · 17/11/2026 09.20',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
        _bukan => [
          const Kartu(
            status: GarisStatus.terpilih,
            radius: 12,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Ditandai: bukan orang yang sama.',
                    style: tebal,
                  ),
                  TextSpan(
                    text: ' Keduanya tetap sebagai dua orang dan tidak ditawarkan lagi sebagai data ganda.',
                  ),
                ],
              ),
            ),
          ),
        ],
        _ => [
          BarisTombol(
            anak: [
              Tombol(
                'Gabungkan',
                onPressed: () => _ke(_gabungkan),
                jenis: JenisTombol.tinta,
              ),
              Tombol(
                'Bukan orang yang sama',
                onPressed: () => _ke(_bukan),
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
              ),
            ],
          ),
        ],
      },
    ];

    // The breadcrumb line is 14 × 1.45 tall; its 44 px target overhangs it.
    const lebih = (44 - 14 * 1.45) / 2;
    return PrimaryScrollController(
      controller: _gulir,
      automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
      child: HalamanWeb(
        nav: const NavSamping(
          item: navPlatform,
          aktif: 5,
          pengguna: PenggunaNav(tebal: 'Yanti Sumual', biasa: ' · Operator'),
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarginNegatif(
                atas: lebih,
                bawah: lebih,
                child: Tautan(
                  ke: 'WebDataAnggota',
                  cara: Cara.naik,
                  child: const Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: TautanTeks('Data jemaat', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: Text(
                  'Kemungkinan data ganda',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Bandingkan dulu; tidak pernah digabung sendiri',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in isi.indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    w,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
