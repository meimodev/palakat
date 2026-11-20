import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/kendali.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

const _stem = 'Kamera';

/// Board state shared by `/Kamera`, `/Kamera/tinjau` and `/Kamera/unggah`:
/// initial `{ st: 'bidik', hal: 1, sudahCoba: false }`.
class _PapanKamera extends ChangeNotifier {
  String st = 'bidik';
  int hal = 1;
  bool sudahCoba = false;

  /// Upload attempts; keys the status block so its bar replays each time.
  int percobaan = 0;
  Timer? _waktu;

  void _ubah(void Function() f) {
    f();
    notifyListeners();
  }

  /// `unggah`: "Pakai foto ini" and "Coba lagi". The tweak and `sudahCoba`
  /// are read at press time.
  void unggah(bool gagalUnggah) {
    final gagal = gagalUnggah && !sudahCoba;
    _waktu?.cancel();
    _ubah(() {
      st = 'unggah';
      percobaan++;
    });
    // Fakes the upload.
    _waktu = Timer(const Duration(milliseconds: 1500), () {
      _ubah(() {
        st = gagal ? 'gagal' : 'lampir';
        sudahCoba = true;
      });
    });
  }

  /// Leaving `/Kamera/unggah` (system Back): the camera again, no late change.
  void batalUnggah() {
    _waktu?.cancel();
    if (st == 'unggah') st = 'bidik';
  }

  void tambah() => _ubah(() {
    hal++;
    st = 'bidik';
  });

  void ulang() {
    _waktu?.cancel();
    _ubah(() {
      st = 'bidik';
      hal = 1;
      sudahCoba = false;
      percobaan = 0;
    });
  }

  @override
  void dispose() {
    _waktu?.cancel();
    super.dispose();
  }
}

class _LingkupKamera extends InheritedNotifier<_PapanKamera> {
  const _LingkupKamera({required super.notifier, required super.child});

  static _PapanKamera of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LingkupKamera>()!.notifier!;
}

/// Owns the board state, LayarPonsel and the reset (navigation.md 2.1).
class KameraKendali extends StatefulWidget {
  const KameraKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KameraKendali> createState() => _KameraKendaliState();
}

class _KameraKendaliState extends State<KameraKendali> {
  final _papan = _PapanKamera();
  int _generasi = 0;

  @override
  void initState() {
    super.initState();
    ulangPapan[_stem] = _ulang;
  }

  void _ulang() {
    _papan.ulang();
    setState(() => _generasi++);
  }

  @override
  void dispose() {
    if (ulangPapan[_stem] == _ulang) ulangPapan.remove(_stem);
    _papan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GenerasiPapan(
    generasi: _generasi,
    child: _LingkupKamera(
      notifier: _papan,
      child: LayarPonsel(child: widget.child),
    ),
  );
}

/// 39 · Foto dokumen pendukung (10-aifoto.md, Kamera). Views: camera
/// (`/Kamera`), review (`tinjau`) and the light upload page (`unggah`).
class KameraScreen extends StatelessWidget {
  const KameraScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) => switch (anak) {
    'tinjau' => const _Tinjau(),
    'unggah' => const _Unggah(),
    _ => const _Bidik(),
  };
}

/// Back arrow "Kembali ke Dokumen pendukung": pops the Kamera routes, then
/// goes up to [ke] (pops when it is below, else `go`).
void _keluarKe(BuildContext context, {required String ke}) {
  final router = GoRouter.of(context);
  var t = tumpukanHalaman(router);
  while (t.length > 2 && t.last.startsWith('/$_stem/')) {
    router.pop();
    final baru = tumpukanHalaman(router);
    if (baru.length >= t.length) break;
    t = baru;
  }
  kembaliKeDengan(router, '/$ke');
}

/// The photographed receipt (#FBFAF6 paper, the only shadow).
/// Ink on the receipt paper ([PalakatIlustrasi.kertasNota]), which stays
/// light in the Gelap theme too.
final _kertas = PalakatWarna.terang;

class _Nota extends StatelessWidget {
  const _Nota();

  @override
  Widget build(BuildContext context) {
    Widget baris(String a, String b, {bool tebal = false}) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      children: [
        Text(
          a,
          style: tebal ? const TextStyle(fontWeight: FontWeight.w600) : null,
        ),
        Text(
          b,
          style: tebal ? const TextStyle(fontWeight: FontWeight.w600) : null,
        ),
      ],
    );
    final putus = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GarisLurus(warna: _kertas.tinta3, gaya: GayaGaris.putus),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        color: PalakatIlustrasi.kertasNota,
        boxShadow: bayanganMelayang,
      ),
      child: SizedBox(
        width: 230,
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: PalakatText.mono,
            fontSize: 13,
            height: 1.55,
            leadingDistribution: TextLeadingDistribution.even,
            color: _kertas.tinta,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'CV NADA PRIMA',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Text('Jl. Sam Ratulangi 14', textAlign: TextAlign.center),
              putus,
              baris('Sewa sound system', ''),
              baris('1 hari', '600.000'),
              putus,
              baris('TOTAL', 'Rp600.000', tebal: true),
              const SizedBox(height: 8),
              const Text('11/11/2026'),
              const Text('LUNAS'),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dark full-screen view: `tinta` field, `permukaan` text and icons.
class _Gelap extends StatelessWidget {
  const _Gelap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return ColoredBox(
      color: c.tinta,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: c.permukaan),
        child: child,
      ),
    );
  }
}

/// *bidik*: the camera.
class _Bidik extends StatelessWidget {
  const _Bidik();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final papan = _LingkupKamera.of(context);
    void ambil() => context.push('/$_stem/tinjau');
    final sudut = BorderSide(color: c.permukaan, width: 3);
    Widget kurung({double? atas, double? bawah, double? kiri, double? kanan}) =>
        Positioned(
          top: atas,
          bottom: bawah,
          left: kiri,
          right: kanan,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              border: Border(
                top: atas != null ? sudut : BorderSide.none,
                bottom: bawah != null ? sudut : BorderSide.none,
                left: kiri != null ? sudut : BorderSide.none,
                right: kanan != null ? sudut : BorderSide.none,
              ),
            ),
          ),
        );
    return _Gelap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
            child: Row(
              spacing: 8,
              children: [
                Tekan(
                  onTap: () => _keluarKe(context, ke: 'Dokumen'),
                  label: 'Kembali ke Dokumen pendukung',
                  peran: PeranTekan.tautan,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: PalakatIkon(Ikon.kembali, warna: c.permukaan),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: const Text(
                          'Foto dokumen pendukung',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'BKU-2026-0143',
                              style: TextStyle(fontFamily: PalakatText.mono),
                            ),
                            TextSpan(text: ' · Sewa sound system · Rp600.000'),
                          ],
                        ),
                        style: TextStyle(fontSize: 13, color: c.diTinta2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 26,
                    ),
                    child: Transform.rotate(
                      angle: -3 * math.pi / 180,
                      child: const _Nota(),
                    ),
                  ),
                  kurung(atas: 0, kiri: 0),
                  kurung(atas: 0, kanan: 0),
                  kurung(bawah: 0, kiri: 0),
                  kurung(bawah: 0, kanan: 0),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Pastikan jumlah, tanggal dan nama penerima terbaca.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: c.diTinta),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Tekan(
                    onTap: ambil,
                    minLebar: 88,
                    // The browser's default button padding (1 px 6 px).
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1,
                        child: Text(
                          'Pilih file',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
                Tekan(
                  onTap: ambil,
                  label: 'Ambil foto',
                  radius: 38,
                  child: Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: c.permukaan, width: 4),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.permukaan,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 88),
                    child: Text(
                      'Halaman ${papan.hal}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 13, color: c.diTinta2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// *tinjau*: review the shot, under a white flash.
class _Tinjau extends StatelessWidget {
  const _Tinjau();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final papan = _LingkupKamera.of(context);
    // The flash stays white: `tinta` is the lightest token in the dark theme.
    final kilat = Theme.of(context).brightness == Brightness.dark
        ? c.tinta
        : c.permukaan;
    return _Gelap(
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: const Text(
                          'Terbaca dengan jelas?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'Foto yang buram akan ditolak saat verifikasi.',
                        style: TextStyle(fontSize: 13, color: c.diTinta2),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Gerak(
                    Kerangka.muncul,
                    lama: const Duration(milliseconds: 300),
                    child: Center(
                      child: Transform.scale(scale: 1.25, child: const _Nota()),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      Tekan(
                        onTap: () {
                          papan.unggah(
                            context.tweak<bool>(_stem, 'gagalUnggah'),
                          );
                          GoRouter.of(context)
                              .pushReplacement('/$_stem/unggah');
                        },
                        radius: 14,
                        child: RupaTombol(
                          label: 'Pakai foto ini',
                          isi: c.permukaan,
                          warnaTeks: c.tinta,
                          radius: 14,
                          tinggi: 52,
                          paddingH: 6,
                        ),
                      ),
                      Tekan(
                        onTap: () => context.pop(),
                        radius: 14,
                        child: RupaTombol(
                          label: 'Ulangi',
                          isi: null,
                          garis: GarisBorder.penuh(c.permukaan, radius: 14),
                          warnaTeks: c.permukaan,
                          radius: 14,
                          tinggi: 48,
                          paddingH: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: ExcludeSemantics(
              child: Gerak(
                Kerangka.kilat,
                lama: const Duration(milliseconds: 350),
                kurva: Curves.easeOut,
                child: ColoredBox(color: kilat),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// *unggah / gagal / lampir*: the light "Dokumen pendukung" page.
class _Unggah extends StatefulWidget {
  const _Unggah();
  @override
  State<_Unggah> createState() => _UnggahState();
}

class _UnggahState extends State<_Unggah> {
  _PapanKamera? _papan;

  @override
  void initState() {
    super.initState();
    // A deep link with no photo sent yet has nothing to upload: the camera.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _papan!.st == 'bidik') context.kembaliKe('/$_stem');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _papan = _LingkupKamera.of(context);
  }

  @override
  void dispose() {
    _papan?.batalUnggah();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final papan = _papan!;
    final st = papan.st;
    final tinta2 = TextStyle(fontSize: 14, color: c.tinta2);
    void lagi() => papan.unggah(context.tweak<bool>(_stem, 'gagalUnggah'));

    Widget? status = switch (st) {
      'unggah' => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          const Text(
            'Sedang diunggah…',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const BatangIsi(lama: Duration(milliseconds: 1500)),
          Text(
            'Belum terlampir sampai selesai.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
      'gagal' => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            'Gagal diunggah',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: c.bata,
            ),
          ),
          Text(
            'File belum terlampir, dan dokumen pendukung masih “Wajib, belum ada”. Coba lagi tidak membuat salinan ganda.',
            style: tinta2,
          ),
        ],
      ),
      'lampir' => Gerak(
        Kerangka.muncul,
        lama: const Duration(milliseconds: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(
              'Dokumen pendukung · ${papan.hal} file terlampir',
              style: tinta2,
            ),
            Text(
              'Diunggah, belum diverifikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: c.bata,
              ),
            ),
            Text(
              'Terlampir bukan terverifikasi. Tutup buku menunggu Terverifikasi atau Dikecualikan.',
              style: tinta2,
            ),
          ],
        ),
      ),
      _ => null,
    };
    if (status != null) {
      status = Semantics(
        key: ValueKey('$st${papan.percobaan}'),
        container: true,
        liveRegion: true,
        child: status,
      );
    }

    return ColoredBox(
      color: c.kertas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Dokumen pendukung',
            anakJudul: 'BKU-2026-0143 · Sewa sound system',
            labelKembali: 'Kembali ke Dokumen pendukung',
            onKembali: () => _keluarKe(context, ke: 'Dokumen'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  _KartuFile(hal: papan.hal),
                  ?status,
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            decoration: BoxDecoration(
              color: c.permukaan,
              border: Border(top: BorderSide(color: c.garis)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                if (st == 'gagal')
                  Tombol(
                    'Coba lagi',
                    jenis: JenisTombol.tinta,
                    paddingH: 6,
                    onPressed: lagi,
                  ),
                if (st == 'lampir') ...[
                  const Tombol(
                    'Lihat file dan verifikasi',
                    ke: 'LihatDokumen',
                    paddingH: 6,
                    onPressed: null,
                  ),
                  Tombol(
                    'Tambah halaman',
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                    paddingH: 6,
                    onPressed: () {
                      papan.tambah();
                      context.pop();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// File row with the document thumbnail.
class _KartuFile extends StatelessWidget {
  const _KartuFile({required this.hal});
  final int hal;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    Widget garis(Color w, double lebar, Alignment rata) => Align(
      alignment: rata,
      child: FractionallySizedBox(
        widthFactor: lebar,
        child: SizedBox(height: 2, child: ColoredBox(color: w)),
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        spacing: 14,
        children: [
          Container(
            width: 44,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              color: PalakatIlustrasi.kertasNota,
              border: Border.all(color: c.garisTegas),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                garis(_kertas.tinta, 1, Alignment.centerLeft),
                garis(_kertas.putus, 1, Alignment.centerLeft),
                garis(_kertas.putus, .7, Alignment.centerLeft),
                garis(_kertas.tinta, .5, Alignment.centerRight),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'nota-sewa-sound-$hal.jpg',
                  style: const TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '1,2 MB · halaman $hal',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
