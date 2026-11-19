import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/rangka.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

/// The `keadaan` options of KeadaanUmum and WebKeadaanUmum, in board order.
const opsiKeadaanUmum = [
  'Memuat',
  'Gagal memuat',
  'Tanpa sambungan',
  'Tidak berwenang',
  'Modul tidak aktif',
  'Sesi berakhir',
];

/// The board state of both boards: `{ k: null }`, view `k ?? keadaan`.
/// A tweak change resets `k`; every view change jumps the scroll to the top.
mixin KeadaanUmumState<T extends StatefulWidget> on State<T> {
  String get stem;
  final gulir = ScrollController();
  String? _k;
  String? _tweak;

  String get keadaan {
    final v = _k ?? _tweak ?? opsiKeadaanUmum[0];
    return opsiKeadaanUmum.contains(v) ? v : opsiKeadaanUmum[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = context.tweak<String>(stem, 'keadaan');
    if (_tweak != null && t != _tweak) {
      _k = null;
      _keAtas();
    }
    _tweak = t;
  }

  void pilih(String v) => setState(() {
    _k = v;
    _keAtas();
  });

  void _keAtas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (gulir.hasClients) gulir.jumpTo(0);
  });

  @override
  void dispose() {
    gulir.dispose();
    super.dispose();
  }
}

/// The six state blocks, as direct items of the boards' gap-16 column. Body
/// text inherits 16 (phone) or 15 (web). [kembali] and [masuk] are the
/// boards' link buttons, built by each screen with its own target.
class IsiKeadaanUmum extends StatelessWidget {
  const IsiKeadaanUmum({
    super.key,
    required this.keadaan,
    required this.onCobaLagi,
    required this.kembali,
    required this.masuk,
  });

  final String keadaan;
  final VoidCallback onCobaLagi;
  final Widget kembali;
  final Widget masuk;

  /// [tambah]: the board's link buttons are `<a>` (content-box), so their
  /// basis and max-width exclude padding 32 and the line (350 on the phone,
  /// 375 / 372 on web); "Coba lagi" is a border-box `<button>` (340).
  static Widget baris(Widget tombol, {double tambah = 0}) => BarisLentur(
    jarak: 8,
    anak: [Lentur(dasar: 150 + tambah, maks: 340 + tambah, child: tombol)],
  );

  /// The outline link's `min-height: 48` is content-box too: 48 + 2 × 1.5.
  static Widget barisKembali(Widget tombol) => baris(
    ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 51),
      child: tombol,
    ),
    tambah: 35,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const tebal = TextStyle(fontWeight: FontWeight.w700);
    Widget catatan(String t) =>
        Text(t, style: TextStyle(fontSize: 13, color: c.tinta3));
    final cobaLagi = baris(
      Tombol('Coba lagi', onPressed: onCobaLagi, jenis: JenisTombol.tinta),
    );
    final anak = switch (keadaan) {
      'Gagal memuat' => [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: ShapeDecoration(
            color: c.bataLembut,
            shape: GarisBorder.penuh(c.bata, tebal: 1, radius: 12),
          ),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Gagal memuat.', style: tebal),
                TextSpan(text: ' Tidak ada yang berubah pada data Anda.'),
              ],
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
        cobaLagi,
      ],
      'Tanpa sambungan' => [
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Tidak ada sambungan.', style: tebal),
                const TextSpan(text: ' '),
                TextSpan(
                  text:
                      'Yang sudah tampil tetap bisa dibaca. Isian tetap di '
                      'layar; tidak ada yang disimpan di perangkat untuk '
                      'dikirim nanti.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        cobaLagi,
      ],
      'Tidak berwenang' => [
        const Penolakan(
          tindakan: 'Buka halaman ini',
          sebab: 'jabatan Anda tidak melihat data ini.',
          jalan: [],
        ),
        catatan(
          'Bila ini keliru, hubungi Pimpinan Jemaat yang berwenang; '
          'penugasan jabatan tidak diubah dari sini.',
        ),
        barisKembali(kembali),
      ],
      'Modul tidak aktif' => [
        Kartu(
          status: GarisStatus.draf,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Halaman ini tidak tersedia', style: tebal),
              const SizedBox(height: 6),
              Text(
                'Tautan yang Anda buka menuju bagian yang tidak dipakai '
                'Jemaat Karunia.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
        catatan(
          'Nama modulnya tidak disebut: modul yang tidak aktif tidak '
          'meninggalkan jejak.',
        ),
        barisKembali(kembali),
      ],
      'Sesi berakhir' => [
        const Kartu(
          status: GarisStatus.terpilih,
          radius: 12,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Sesi Anda berakhir.', style: tebal),
                TextSpan(
                  text:
                      ' Masuk lagi untuk melanjutkan. Isian yang belum '
                      'tersimpan tidak ikut tersimpan.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
        baris(masuk, tambah: 32),
      ],
      _ => [
        const Rangka(
          jarak: 12,
          balok: [
            RangkaBalok(lebar: 1, tinggi: 72, radius: 12, denyut: false),
            RangkaBalok(lebar: 1, tinggi: 56, radius: 12, denyut: false),
            RangkaBalok(lebar: 1, tinggi: 56, radius: 12, denyut: false),
          ],
        ),
        catatan(
          'Bentuk isi tampil lebih dulu; tidak ada angka sementara yang bisa '
          'disangka angka sebenarnya.',
        ),
      ],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          anak[i],
        ],
      ],
    );
  }
}

/// 61 · Keadaan umum (spec 17-keadaanumum.md).
class KeadaanUmumScreen extends StatefulWidget {
  const KeadaanUmumScreen({super.key});

  @override
  State<KeadaanUmumScreen> createState() => _KeadaanUmumScreenState();
}

class _KeadaanUmumScreenState extends State<KeadaanUmumScreen>
    with KeadaanUmumState {
  @override
  String get stem => 'KeadaanUmum';

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Keadaan umum',
          anakJudul: 'Satu pola untuk semua modul',
          kembaliKe: 'BerandaJabatan',
          labelKembali: 'Kembali ke Beranda',
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: gulir,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: IsiKeadaanUmum(
              keadaan: keadaan,
              onCobaLagi: () => pilih('Memuat'),
              kembali: const Tombol(
                'Kembali ke Beranda',
                onPressed: null,
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                ke: 'BerandaJabatan',
                cara: Cara.naik,
              ),
              masuk: const Tombol(
                'Masuk lagi',
                onPressed: null,
                jenis: JenisTombol.tinta,
                ke: 'AlurMasuk',
                cara: Cara.ganti,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
