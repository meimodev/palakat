import 'package:flutter/widgets.dart';

import '../../mock/mock.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/bertindak_sebagai.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'beranda_jabatan_isi.dart';

/// Row targets of `berandaJabatan`, per person, "Perlu tindakan" then
/// "Untuk diketahui" (the board's `hal()` with `web = true`).
const _tujuan = [
  [
    (ke: 'AntreanVerifikasi'),
    (ke: 'Ibadah'),
    (ke: 'PermintaanDana'),
    (ke: 'KonfirmasiKeluarga'),
  ],
  [(ke: 'WebBeranda'), (ke: 'WebSelesaikanUnit'), (ke: 'WebBeranda')],
  [
    (ke: 'WebPengumuman'),
    (ke: 'WebPermohonanSurat'),
    (ke: 'WebWartaEditor'),
    (ke: 'WebPengumuman'),
  ],
  [
    (ke: 'KonfirmasiKeluarga'),
    (ke: 'WebPermohonanSurat'),
    (ke: 'WebJabatanKosong'),
    (ke: 'WebImporBuku'),
  ],
  [
    (ke: 'WebPermohonanSurat'),
    (ke: 'WebWartaArsip'),
    (ke: 'WebPengumuman'),
    (ke: 'PersembahanSaya'),
  ],
];

/// Web · Beranda: the combined Beranda on the laptop, home of every platform
/// web board.
class WebBerandaJabatanScreen extends StatefulWidget {
  const WebBerandaJabatanScreen({super.key});

  @override
  State<WebBerandaJabatanScreen> createState() =>
      _WebBerandaJabatanScreenState();
}

class _WebBerandaJabatanScreenState extends State<WebBerandaJabatanScreen>
    with KeadaanBeranda {
  @override
  String get stem => 'WebBerandaJabatan';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ki = indeks(context);
    // HalamanWeb's page scroll view inherits this controller (scroll to top).
    return PrimaryScrollController(
      controller: scroll,
      automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
      child: HalamanWeb(
        nav: NavSamping(
          item: navPlatform,
          aktif: 0,
          pengguna: const PenggunaNav(
            tebal: 'Jemaat Karunia',
            biasa: ' · satu akun, semua jabatan',
          ),
          diSini: ulang,
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inline link, 21.75 high on the board; the 44 target overhangs.
              MarginNegatif(
                atas: 11.125,
                bawah: 11.125,
                child: Tautan(
                  ke: 'WebBerandaJabatan',
                  cara: Cara.naik,
                  diSini: ulang,
                  child: const SizedBox(
                    height: 44,
                    child: Align(
                      widthFactor: 1,
                      child: TautanTeks('Beranda', ukuran: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: Text('Beranda', style: PalakatText.judulHalaman),
              ),
              Text(
                'Satu Beranda untuk semua jabatan Anda',
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
                children: bersela(switch (ki) {
                  5 => isiOtomatis(context, go0),
                  6 => isiDuaJabatan(context, go0),
                  _ => _daftar(ki),
                }, 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _daftar(int ki) {
    final d = berandaJabatan[ki];
    final ke = _tujuan[ki];
    final semua = [...d.tindak, ...d.tahu];
    assert(() {
      for (final (i, r) in semua.indexed) {
        if (keWeb(r.ke) != ke[i].ke) return false;
      }
      return true;
    }(), 'WebBerandaJabatan row targets differ from berandaJabatan');
    Widget kolom(String judul, int dari, int sampai) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sampai > dari) ...[
          JudulBagian(judul),
          const SizedBox(height: 12),
          _KotakDaftar([
            for (var i = dari; i < sampai; i++) (r: semua[i], ke: ke[i].ke),
          ]),
        ],
      ],
    );
    return [
      DaftarJabatan(nama: d.orang, jabatan: d.jabatan),
      BarisLentur(
        jarak: 28,
        jarakBaris: 20,
        anak: [
          Lentur(
            dasar: 420,
            tumbuh: 1.3,
            child: kolom('Perlu tindakan', 0, d.tindak.length),
          ),
          Lentur(
            dasar: 340,
            child: kolom('Untuk diketahui', d.tindak.length, semua.length),
          ),
        ],
      ),
      const Keterangan(kalimatBeranda),
      const Tautan(
        ke: 'WebAkunSaya',
        child: SizedBox(
          height: 44,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TautanTeks('Akun saya', berat: FontWeight.w700, ukuran: 14),
          ),
        ),
      ),
    ];
  }
}

/// The list box (shared look with WebKotakMasuk): rows split by 1 px rules,
/// none above the first.
class _KotakDaftar extends StatelessWidget {
  const _KotakDaftar(this.baris);
  final List<({ItemKotak r, String ke})> baris;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, b) in baris.indexed)
            _Baris(b.r, ke: b.ke, pertama: i == 0),
        ],
      ),
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris(this.r, {required this.ke, required this.pertama});
  final ItemKotak r;
  final String ke;
  final bool pertama;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final judul = Text(
      r.judul,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
    final sub = Text(r.sub, style: TextStyle(fontSize: 13, color: c.tinta3));
    return Tautan(
      ke: ke,
      child: Container(
        // `<a>` is content-box: min-height 52 + padding 16 + the 1 px rule
        // (the first row's rule is hidden above the box).
        constraints: BoxConstraints(minHeight: pertama ? 68 : 69),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: pertama
            ? null
            : BoxDecoration(
                border: Border(top: BorderSide(color: c.garis)),
              ),
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, k) {
                  // flex-wrap: title (basis 260) and subtitle (basis 300,
                  // grow 1.4) share a baseline when both fit, gap 20.
                  if (k.maxWidth < 580) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [judul, const SizedBox(height: 2), sub],
                    );
                  }
                  final w = BarisLentur.lebar(
                    [
                      Lentur(dasar: 260, child: judul),
                      Lentur(dasar: 300, tumbuh: 1.4, child: sub),
                    ],
                    20,
                    k.maxWidth,
                  ).first;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      SizedBox(width: w[0], child: judul),
                      const SizedBox(width: 20),
                      SizedBox(width: w[1], child: sub),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            ?lencanaBaris(r),
            const SizedBox(width: 16),
            SizedBox(
              width: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
