import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shell/perangkat_prototipe.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// The body column shared by AlurMasuk and WebAlurMasuk (16-alurmasuk.md):
/// the four steps `nomor`, `kode`, `kenal`, `tunggu`, changed in place. The
/// board links differ per form factor, so each screen passes them in.
class AlurMasukIsi extends StatefulWidget {
  const AlurMasukIsi({
    super.key,
    required this.stem,
    required this.pemulihan,
    required this.anggota,
    required this.warta,
    required this.beranda,
    required this.akun,
  });

  /// Board stem for the Keadaan panel devices.
  final String stem;

  /// "Tidak bisa menerima kode? Pemulihan akun" ([TautanPemulihan]).
  final Widget pemulihan;

  /// Link-buttons: "Ajukan permohonan menjadi anggota", "Buka Warta Jemaat",
  /// "Buka Beranda", "Tambah email cadangan".
  final TombolTautanAlur anggota, warta, beranda, akun;

  @override
  State<AlurMasukIsi> createState() => _AlurMasukIsiState();
}

/// A link-button of these boards: an `<a>`, so `box-sizing: content-box`:
/// min height 52 (ink, no line) or 48 + 2 × 1.5 (outline), padding 0 16 on
/// top of the flex basis and max width ([tambahan]).
class TombolTautanAlur extends StatelessWidget {
  const TombolTautanAlur(
    this.label, {
    super.key,
    required this.ke,
    this.tinta = false,
    this.cara = Cara.dorong,
  });

  final String label;
  final String ke;

  /// Ink fill (Buka Beranda); otherwise the outline.
  final bool tinta;
  final Cara cara;

  /// Padding plus border outside the content box.
  double get tambahan => tinta ? 32 : 35;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: ke,
      cara: cara,
      radius: 14,
      child: RupaTombol(
        label: label,
        isi: tinta ? c.tinta : c.permukaan,
        garis: tinta ? null : GarisBorder.penuh(c.tinta, radius: 14),
        warnaTeks: tinta ? c.permukaan : c.tinta,
        radius: 14,
        tinggi: tinta ? 52 : 51,
        paddingH: 16,
      ),
    );
  }
}

/// The wrap row of [TombolTautanAlur]s: CSS flex `1 1 150px`, `max-width:
/// 340px` on the content box, gap 8; lines break on the outer size, items on
/// a line grow equally up to their max and share the tallest height.
class _BarisTautan extends StatelessWidget {
  const _BarisTautan(this.anak);

  final List<TombolTautanAlur> anak;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, ruang) {
      final w = ruang.maxWidth;
      // Break into lines on the hypothetical outer size.
      final baris = <List<int>>[[]];
      var isi = 0.0;
      for (final (i, a) in anak.indexed) {
        final luar = 150 + a.tambahan;
        final b = baris.last;
        if (b.isNotEmpty && isi + 8 + luar > w) {
          baris.add([i]);
          isi = luar;
        } else {
          isi += (b.isEmpty ? 0 : 8) + luar;
          b.add(i);
        }
      }
      // Grow equally, freezing items at their max.
      List<double> lebar(List<int> b) {
        final l = [for (final i in b) 150 + anak[i].tambahan];
        final beku = List.filled(b.length, false);
        while (true) {
          final bebas = w - 8 * (b.length - 1) - l.fold(0.0, (s, x) => s + x);
          final n = beku.where((x) => !x).length;
          if (bebas <= 0.01 || n == 0) break;
          var ubah = false;
          for (var k = 0; k < b.length; k++) {
            if (beku[k]) continue;
            final maks = 340 + anak[b[k]].tambahan;
            l[k] += bebas / n;
            if (l[k] >= maks) {
              l[k] = maks;
              beku[k] = true;
              ubah = true;
            }
          }
          if (!ubah) break;
        }
        return [for (final x in l) x > w ? w : x];
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          for (final b in baris)
            IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  for (final (k, x) in lebar(b).indexed)
                    SizedBox(width: x, child: anak[b[k]]),
                ],
              ),
            ),
        ],
      );
    },
  );
}

/// The step-`nomor` text link: 14/700, min height 44, the whole strip.
class TautanPemulihan extends StatelessWidget {
  const TautanPemulihan({super.key, required this.ke});

  final String ke;

  @override
  Widget build(BuildContext context) => Tautan(
    ke: ke,
    child: Container(
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.centerLeft,
      child: const TautanTeks(
        'Tidak bisa menerima kode? Pemulihan akun',
        berat: FontWeight.w700,
        ukuran: 14,
      ),
    ),
  );
}

/// Today on the boards (`HARI`, `HARI_T`).
const _hari = 20261116, _hariT = '16/11/2026';

/// The board's `tgl`: `dd/mm/yyyy` after trimming, month 1–12, day 1–31.
int? _tgl(String t) {
  final m = RegExp(r'^(\d\d)/(\d\d)/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), b = int.parse(m[2]!);
  if (b < 1 || b > 12 || d < 1 || d > 31) return null;
  return int.parse(m[3]!) * 10000 + b * 100 + d;
}

class _AlurMasukIsiState extends State<AlurMasukIsi> {
  String _v = 'nomor', _kanal = 'WhatsApp', _cari = '', _st = '';
  int _salah = 0;
  final _hp = TextEditingController(),
      _kode = TextEditingController(),
      _nama = TextEditingController(),
      _lahir = TextEditingController();

  @override
  void dispose() {
    for (final c in [_hp, _kode, _nama, _lahir]) {
      c.dispose();
    }
    super.dispose();
  }

  // First unmet reasons, from the latest input ('' when met).
  String _alasanKirim() {
    final hp = _hp.text;
    if (hp.isEmpty) return 'nomor ponsel belum diisi.';
    if (!RegExp(r'^08\d{8,11}$').hasMatch(hp)) {
      return 'nomor ponsel tidak dikenali. Contoh: 081234567890.';
    }
    return '';
  }

  String _alasanMasuk() {
    if (_salah >= 3) return 'terlalu banyak percobaan. Minta kode baru.';
    if (_kode.text.length < 6) return 'kode belum lengkap.';
    return '';
  }

  String _alasanCari() {
    final t = _tgl(_lahir.text);
    if (_nama.text.trim().isEmpty) return 'nama belum diisi.';
    if (t == null) return 'tanggal lahir tidak dikenali. Contoh: 14/03/1996.';
    if (t >= _hari) return 'tanggal lahir harus sebelum hari ini.';
    return '';
  }

  /// Step change: set state, then jump the page to the top.
  void _ke(String v, [VoidCallback? lain]) {
    setState(() {
      _v = v;
      lain?.call();
    });
    Scrollable.maybeOf(context)?.position.jumpTo(0);
  }

  void _kirim() => _ke('kode', () {
    _kode.clear();
    _salah = 0;
  });

  void _ulang() => setState(() {
    _kode.clear();
    _salah = 0;
    // The board also sets `pesan` ("Kode baru dikirim lewat …"), never shown.
  });

  void _keNomor() => _ke('nomor', () {
    _kode.clear();
    _salah = 0;
  });

  void _cek() {
    if (_kode.text == '123456') {
      _ke('kenal');
    } else {
      setState(() {
        _salah++;
        _kode.clear();
      });
    }
  }

  void _cariData() => setState(() {
    final ya =
        RegExp('novita', caseSensitive: false).hasMatch(_nama.text) &&
        _tgl(_lahir.text) == 19960314;
    _cari = ya ? 'ya' : 'tidak';
  });

  void _ajukan() => _ke('tunggu', () => _st = 'Menunggu verifikasi');

  void _verif() => setState(() => _st = 'Terhubung');

  void _ubah(String _) => setState(() {});

  void _ubahData(String _) => setState(() => _cari = '');

  Widget _bersyarat(String label, String alasan, VoidCallback aksi) =>
      TombolBersyarat(
        label: label,
        tindakan: label,
        alasan: alasan,
        onPressed: aksi,
        periksa: switch (label) {
          'Kirim kode' => _alasanKirim,
          'Masuk' => _alasanMasuk,
          _ => _alasanCari,
        },
        sudahMulai: false,
      );

  Widget _tolak(String tindakan, String sebab) => Penolakan(
    tindakan: tindakan,
    sebab: sebab,
    jalan: const [],
    ukuranTeks: 14,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    final biasa = TextStyle(fontSize: 14, color: c.tinta2);

    List<Widget> nomor() {
      final a = _alasanKirim();
      return [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masuk ke Palakat',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            Text('Jemaat Karunia', style: biasa),
          ],
        ),
        IsianAlur(
          label: 'Nomor ponsel',
          controller: _hp,
          onChanged: _ubah,
          petunjuk: '08…',
          keterangan: 'Contoh: 081234567890',
          keyboard: TextInputType.phone,
          formatter: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
          ],
        ),
        ChipPilihan<String>(
          label: 'Kirim kode lewat',
          jarakLabel: 6,
          jarakBawah: 0,
          pilihan: const [
            (nilai: 'WhatsApp', teks: 'WhatsApp'),
            (nilai: 'SMS', teks: 'SMS'),
          ],
          terpilih: _kanal,
          onPilih: (k) => setState(() => _kanal = k),
        ),
        if (_hp.text.isNotEmpty && a.isNotEmpty) _tolak('Kirim kode', a),
        BarisTombol(anak: [_bersyarat('Kirim kode', a, _kirim)]),
        Text(
          'Satu orang satu akun, untuk semua jabatan. Nomor ponsel hanya '
          'dipakai untuk masuk.',
          style: kecil,
        ),
        widget.pemulihan,
      ];
    }

    List<Widget> kode() {
      final a = _alasanMasuk();
      final sebab = _salah >= 3
          ? a
          : (_salah > 0 && _kode.text.isEmpty
                ? 'kode tidak cocok. Sisa percobaan: ${3 - _salah}.'
                : '');
      return [
        Text(
          'Kode 6 angka dikirim ke ${_hp.text} lewat $_kanal. Kode hanya '
          'berlaku sebentar dan sekali pakai.',
          style: biasa,
        ),
        IsianAlur(
          label: 'Kode 6 angka',
          controller: _kode,
          onChanged: _ubah,
          petunjuk: '••••••',
          keyboard: TextInputType.number,
          formatter: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        if (sebab.isNotEmpty) _tolak('Masuk', sebab),
        BarisTombol(
          anak: [
            _bersyarat('Masuk', a, _cek),
            Tombol(
              'Kirim ulang kode',
              onPressed: _ulang,
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
            ),
            Tombol(
              'Ganti nomor',
              onPressed: _keNomor,
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.kecil,
            ),
          ],
        ),
      ];
    }

    List<Widget> kenal() {
      final a = _alasanCari();
      return [
        Kartu(
          status: GarisStatus.terpilih,
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Nomor ini belum terhubung dengan Data jemaat.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ' Isi nama dan tanggal lahir Anda; Penatua Kolom '
                      'memastikan itu memang Anda.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
        IsianAlur(
          label: 'Nama lengkap',
          controller: _nama,
          onChanged: _ubahData,
          petunjuk: 'Nama sesuai surat baptis',
        ),
        IsianAlur(
          label: 'Tanggal lahir',
          controller: _lahir,
          onChanged: _ubahData,
          petunjuk: 'hh/bb/tttt',
          keyboard: TextInputType.datetime,
        ),
        if ((_nama.text.isNotEmpty || _lahir.text.isNotEmpty) && a.isNotEmpty)
          _tolak('Cari data saya', a),
        BarisTombol(anak: [_bersyarat('Cari data saya', a, _cariData)]),
        if (_cari == 'ya') ...[
          Kartu(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const KepalaKartu(
                  judul: 'Satu data cocok',
                  ujung: LencanaStatus('Kolom 7', bentuk: BentukLencana.garis),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rinciannya tidak ditampilkan sampai Penatua Kolom 7 '
                  'memverifikasi.',
                  style: kecil,
                ),
              ],
            ),
          ),
          BarisTombol(
            anak: [
              Tombol(
                'Ajukan untuk diverifikasi',
                onPressed: _ajukan,
                jenis: JenisTombol.tinta,
              ),
            ],
          ),
        ],
        if (_cari == 'tidak') ...[
          Kartu(
            status: GarisStatus.draf,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tidak ada data yang cocok',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Periksa ejaan dan tanggal lahir. Bila Anda belum terdaftar, '
                  'ajukan permohonan menjadi anggota.',
                  style: biasa,
                ),
              ],
            ),
          ),
          _BarisTautan([widget.anggota]),
        ],
      ];
    }

    List<Widget> tunggu() {
      final hubung = _st == 'Terhubung';
      return [
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KepalaKartu(
                judul: 'Akun Anda',
                ujung: LencanaStatus(
                  _st,
                  bentuk: hubung ? BentukLencana.laut : BentukLencana.garis,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hubung
                    ? 'Terhubung dengan data Novita Wenas · Keluarga '
                          'Wenas-Lasut · Kolom 7.'
                    : 'Diajukan $_hariT · menunggu Penatua Kolom 7',
                style: biasa,
              ),
            ],
          ),
        ),
        if (_st == 'Menunggu verifikasi') ...[
          Text(
            'Sampai diverifikasi, Anda hanya melihat Warta Jemaat dan '
            'pengumuman untuk semua anggota.',
            style: kecil,
          ),
          _BarisTautan([widget.warta]),
        ],
        if (hubung) ...[
          _BarisTautan([widget.beranda, widget.akun]),
          Text(
            'Email cadangan tidak wajib. Dipakai hanya bila nomor ponsel Anda '
            'hilang.',
            style: kecil,
          ),
        ],
      ];
    }

    final blok = switch (_v) {
      'kode' => kode(),
      'kenal' => kenal(),
      'tunggu' => tunggu(),
      _ => nomor(),
    };

    return AlatPrototipe(
      stem: widget.stem,
      alat: [
        if (_v == 'kode')
          const Text('Di prototipe ini kode yang benar adalah 123456.'),
        if (_v == 'kenal')
          const Text('Di prototipe ini: Novita Wenas, 14/03/1996.'),
        if (_v == 'tunggu' && _st == 'Menunggu verifikasi')
          Tombol(
            'Contoh: diverifikasi',
            onPressed: _verif,
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            lebarPenuh: false,
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: blok,
      ),
    );
  }
}
