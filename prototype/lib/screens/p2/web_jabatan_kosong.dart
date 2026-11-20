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
import '../../widgets/penolakan.dart';
import '../../widgets/pita_jabatan_kosong.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

const _stem = 'WebJabatanKosong';
const _o = [
  'Pita di setiap layar',
  'Konfirmasi tutup buku',
  'Tercatat di Riwayat',
  'Wajib pemeriksa kedua',
  'Jabatan sudah terisi',
];

/// Web · Menjalankan jabatan kosong (spec 14). State `{k: null}`; the view
/// is `k ?? keadaan`. A panel change resets `k`; every view change scrolls up.
class WebJabatanKosongScreen extends StatefulWidget {
  const WebJabatanKosongScreen({super.key});
  @override
  State<WebJabatanKosongScreen> createState() => _WebJabatanKosongState();
}

class _WebJabatanKosongState extends State<WebJabatanKosongScreen> {
  String? _k, _keadaan, _tampil;
  bool _centang = false;
  final _atas = GlobalKey();

  void _ke(String v) => setState(() => _k = v);

  @override
  Widget build(BuildContext context) {
    final keadaan = context.tweak<String>(_stem, 'keadaan');
    if (keadaan != _keadaan) {
      _keadaan = keadaan;
      _k = null;
    }
    final tampil = _k ?? keadaan;
    if (tampil != _tampil) {
      if (_tampil != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = _atas.currentContext;
          if (ctx != null) Scrollable.maybeOf(ctx)?.position.jumpTo(0);
        });
      }
      _tampil = tampil;
      _centang = false; // the board's native checkbox is re-created
    }
    final c = context.warna;

    return HalamanWeb(
      nav: const NavSamping(
        item: navPlatform,
        aktif: 1,
        pengguna: PenggunaNav(tebal: 'Yanti Sumual', biasa: ' · Operator'),
      ),
      isi: [
        Column(
          key: _atas,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarginNegatif(
              atas: (44 - 14 * 1.45) / 2,
              bawah: (44 - 14 * 1.45) / 2,
              child: const Tautan(
                ke: 'WebBerandaJabatan',
                cara: Cara.naik,
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Beranda', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Menjalankan jabatan kosong',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Contoh keadaan: jabatan Bendahara Jemaat belum ada pemegangnya',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: switch (_o.indexOf(tampil)) {
                1 => _konfirmasi(c),
                2 => _riwayat(c),
                3 => _pemeriksa(c),
                4 => _terisi(c),
                _ => _pita(c),
              },
            ),
          ),
        ),
      ],
    );
  }

  static const _banner = PitaJabatanKosong.web(
    siaran: false,
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  List<Widget> _pita(PalakatWarna c) => [
    _banner,
    BarisLentur(
      jarak: 28,
      jarakBaris: 20,
      anak: [
        Lentur(
          dasar: 420,
          tumbuh: 1.3,
          child: _KartuCatatan(
            judul: const Text(
              'Saldo buku semua Kas/Bank',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            ujung: Text(
              'Rp38.415.000',
              style: PalakatText.jumlah.copyWith(fontSize: 15, color: c.tinta),
            ),
            baris: [
              Text(
                'Hanya transaksi yang sudah dibukukan',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        ),
        Lentur(
          dasar: 340,
          child: _KartuCatatan(
            judul: const Text(
              'Perlu tindakan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            ujung: const LencanaStatus('4', bentuk: BentukLencana.bata),
            baris: [
              Text(
                'Oktober 2026 belum ditutup · 2 draf belum dibukukan',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
      ],
    ),
    Text(
      'Pita ini tampil di setiap layar Keuangan selama jabatan dijalankan: '
      'Beranda, Transaksi, Rekonsiliasi, Tutup buku, Laporan.',
      style: TextStyle(fontSize: 13, color: c.tinta3),
    ),
    BarisTombol(
      anak: [
        Tombol(
          'Lihat konfirmasi tutup buku',
          onPressed: () => _ke(_o[1]),
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.sedang,
        ),
      ],
    ),
  ];

  List<Widget> _konfirmasi(PalakatWarna c) => [
    _banner,
    Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          const Text(
            'Tutup buku bulan Oktober 2026?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Ditutup oleh '),
                TextSpan(
                  text: 'Yanti Sumual, Operator',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
                ),
                const TextSpan(
                  text:
                      ', yang menjalankan jabatan kosong Bendahara Jemaat. '
                      'Nama dan keadaan ini tercatat pada tutup buku.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          KotakCentang(
            nilai: _centang,
            onUbah: (v) => setState(() => _centang = v),
            jarakAtas: 2,
            label: const Text(
              'Saya sudah membaca ringkasan dan laporan sementara. Saya '
              'mengerti bahwa tutup buku ini bersifat permanen dan transaksi '
              'Oktober 2026 tidak dapat dikoreksi lagi.',
            ),
          ),
        ],
      ),
    ),
    BarisTombol(
      anak: [
        // Disabled for good on the board (no handler), whatever the tick.
        Semantics(
          hint: 'Tombol aktif setelah pernyataan di atas dicentang.',
          child: Tombol(
            'Tutup buku Oktober 2026',
            onPressed: null,
            nonaktif: true,
            warnaTeks: c.tinta2,
          ),
        ),
        Tombol('Kembali', onPressed: () => _ke(_o[0]), jenis: JenisTombol.teks),
      ],
    ),
    Text(
      'Tombol aktif setelah pernyataan di atas dicentang.',
      style: TextStyle(fontSize: 13, color: c.tinta3),
    ),
  ];

  List<Widget> _riwayat(PalakatWarna c) => [
    _KartuCatatan(
      judul: Text(
        'BKU-2026-0146',
        style: TextStyle(
          fontFamily: PalakatText.mono,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: c.tinta,
        ),
      ),
      ujung: LencanaStatus.uang(StatusUang.dibukukan),
      baris: [
        Text(
          'Dibukukan pada 16/11/2026 11.42',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        Text(
          'Oleh Yanti Sumual, Operator · menjalankan jabatan kosong '
          'Bendahara Jemaat',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    ),
    _KartuCatatan(
      judul: const Text(
        'Rekonsiliasi Kas · Oktober 2026',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      ujung: LencanaStatus.uang(StatusUang.sudahDipastikan),
      baris: [
        Text(
          'Oleh Yanti Sumual, Operator · menjalankan jabatan kosong '
          'Bendahara Jemaat · 16/11/2026 10.20',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    ),
    Text(
      'Riwayat menyimpan orang yang bertindak dan jabatan yang '
      'dijalankannya. Bendahara baru nanti tidak mewarisi tindakan ini '
      'sebagai miliknya.',
      style: TextStyle(fontSize: 13, color: c.tinta3),
    ),
  ];

  List<Widget> _pemeriksa(PalakatWarna c) => [
    _banner,
    const Penolakan(
      tindakan: 'Bukukan',
      sebab: 'Wajib pemeriksa kedua aktif, dan draf ini Anda catat sendiri.',
      jalan: [],
    ),
    Text(
      'Menjalankan jabatan kosong tidak menggantikan orang kedua. Yang dapat '
      'memeriksa: Pnt. Jefry Wowor.',
      style: TextStyle(fontSize: 13, color: c.tinta3),
    ),
    BarisTombol(
      anak: [
        Tombol(
          'Biarkan sebagai draf',
          onPressed: () => _ke(_o[0]),
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.sedang,
        ),
      ],
    ),
  ];

  List<Widget> _terisi(PalakatWarna c) => [
    Kartu(
      status: GarisStatus.terpilih,
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Bendahara Jemaat sudah terisi:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: ' Deitje Kawengian, wewenang aktif sejak 18/11/2026.',
            ),
          ],
        ),
        style: TextStyle(fontSize: 14),
      ),
    ),
    const Penolakan(
      tindakan: 'Bukukan',
      sebab: 'Anda tidak lagi menjalankan jabatan Bendahara Jemaat.',
      jalan: [],
    ),
    Text(
      'Draf yang Anda siapkan tetap ada dan dapat dibukukan oleh Bendahara '
      'Jemaat.',
      style: TextStyle(fontSize: 13, color: c.tinta3),
    ),
    // An `<a>` is content-box: max-width 340 + padding 32 + line 3 = 375
    // wide, 48 + 3 = 51 high.
    Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 375),
        child: const SizedBox(
          width: double.infinity,
          height: 51,
          child: Tombol(
            'Kembali ke Beranda',
            onPressed: null,
            ke: 'WebBerandaJabatan',
            cara: Cara.naik,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
          ),
        ),
      ),
    ),
  ];
}

/// The board's record card: `permukaan`, 1 `garis`, radius 14, padding
/// 14 16, column gap 6; head row space-between, gap 16, centred.
class _KartuCatatan extends StatelessWidget {
  const _KartuCatatan({
    required this.judul,
    required this.ujung,
    required this.baris,
  });

  final Widget judul, ujung;
  final List<Widget> baris;

  @override
  Widget build(BuildContext context) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Row(
          children: [
            Expanded(child: judul),
            const SizedBox(width: 16),
            ujung,
          ],
        ),
        ...baris,
      ],
    ),
  );
}
