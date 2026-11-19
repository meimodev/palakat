import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../mock/jabatan_kosong.dart';
import '../../mock/keuangan.dart';
import '../../mock/model.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/kendali.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

// ---------- Board state (MataAnggaran.dc.html logic class) ----------

enum _St { draf, periksa, terbit }

const _tabs = ['Belanja', 'Pendapatan'];
const _bolehAwal = {
  '5.01.02.00': 'Milik sendiri',
  '5.03.03.00': 'Milik sendiri',
  '5.06.01.00': '',
  '4.03.03.00': 'Milik sendiri',
  '1.3.53.07.00': 'Milik sendiri',
  '1.3.53.09.00': 'Milik sendiri',
  '2.1.01.02.00': 'Titipan',
  '1.4.10.02.00': 'Keduanya',
};

class _Keadaan extends ChangeNotifier {
  _St st = _St.draf;
  String tab = 'Belanja';
  bool sheet = false;
  final Map<String, String> boleh = {..._bolehAwal};

  void ulang() {
    st = _St.draf;
    tab = 'Belanja';
    sheet = false;
    boleh
      ..clear()
      ..addAll(_bolehAwal);
    notifyListeners();
  }

  void ubah(VoidCallback f) {
    f();
    notifyListeners();
  }

  void pick(String kode, String o) {
    if (st == _St.terbit) return;
    boleh[kode] = boleh[kode] == o ? '' : o;
    st = _St.draf;
    notifyListeners();
  }
}

class _Lingkup extends InheritedNotifier<_Keadaan> {
  const _Lingkup({required _Keadaan super.notifier, required super.child});
  static _Keadaan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
  static _Keadaan baca(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

/// Owns the board state and the phone root (strip, Terbitkan sheet) above
/// `/MataAnggaran` and `/MataAnggaran/rinci`.
class MataAnggaranKendali extends StatefulWidget {
  const MataAnggaranKendali({super.key, required this.child});
  final Widget child;
  @override
  State<MataAnggaranKendali> createState() => _MataAnggaranKendaliState();
}

class _MataAnggaranKendaliState extends State<MataAnggaranKendali> {
  final _k = _Keadaan();
  int _generasi = 0;

  @override
  void initState() {
    super.initState();
    ulangPapan['MataAnggaran'] = _ulang;
  }

  void _ulang() => setState(() {
    _k.ulang();
    _generasi++;
  });

  @override
  void dispose() {
    if (ulangPapan['MataAnggaran'] == _ulang) {
      ulangPapan.remove('MataAnggaran');
    }
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    notifier: _k,
    child: GenerasiPapan(
      generasi: _generasi,
      child: Material(
        type: MaterialType.transparency,
        child: ListenableBuilder(
          listenable: _k,
          builder: (context, _) => LayarPonsel(
            jabatanKosong: true,
            overlay: [if (_k.sheet) _LembarTerbit(k: _k)],
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}

class MataAnggaranScreen extends StatelessWidget {
  const MataAnggaranScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.warna.kertas,
    child: anak == 'rinci' ? const _Rinci() : const _Versi(),
  );
}

/// The 2026.2 status badge (header and card).
Widget _lencana(_St st) => switch (st) {
  _St.draf => LencanaStatus.uang(StatusUang.draf),
  _St.periksa => LencanaStatus.uang(StatusUang.sudahDiperiksa),
  _St.terbit => const LencanaStatus('Diterbitkan', bentuk: BentukLencana.tinta),
};

// ---------- Versi ----------

class _Versi extends StatelessWidget {
  const _Versi();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    final jk = context.prototipe.jabatanKosong;
    final terbit = k.st == _St.terbit;
    const judul = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    final v2Teks = terbit
        ? tukarJkPapan('MataAnggaran', jk, teksVersiUsulanDiterbitkan)
        : 'Belum berlaku · $berlakuVersiUsulan';

    // The whole view fades in (`pudar` on the board's view container).
    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Versi Mata Anggaran',
            kembaliKe: 'Lainnya',
            labelKembali: 'Kembali ke Lainnya',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Text(
                    'Versi yang diterbitkan tidak pernah berubah. Perubahan '
                    'menjadi versi baru yang berlaku mulai bulan berikutnya.',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  Tekan(
                    onTap: () => context.push('/MataAnggaran/rinci'),
                    radius: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Kartu(
                            status: k.st == _St.draf
                                ? GarisStatus.draf
                                : GarisStatus.terpilih,
                            radius: 16,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 4,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  spacing: 8,
                                  children: [
                                    const Flexible(
                                      child: Text('Versi 2026.2', style: judul),
                                    ),
                                    _lencana(k.st),
                                  ],
                                ),
                                Text(
                                  v2Teks,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: c.tinta2,
                                  ),
                                ),
                                Text(
                                  teksBedaVersiUsulan,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: c.tinta3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (terbit) const SapuTinta(),
                        ],
                      ),
                    ),
                  ),
                  Kartu(
                    status: GarisStatus.terpilih,
                    radius: 16,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 4,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Flexible(child: Text('Versi 2026.1', style: judul)),
                            LencanaStatus(
                              'Diterbitkan',
                              bentuk: BentukLencana.tinta,
                              kepala: true,
                            ),
                          ],
                        ),
                        Text(
                          'Berlaku mulai September 2026 · '
                          '${terbit ? 'dipakai sampai November 2026' : 'versi yang sedang dipakai'}',
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                        Text(
                          teksBarisVersiSekarang,
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Rinci ----------

class _Rinci extends StatelessWidget {
  const _Rinci();

  /// `keVersi`: pop to `/MataAnggaran` (closes the sheet too).
  static void _keVersi(BuildContext context) {
    final k = _Lingkup.baca(context);
    k.ubah(() => k.sheet = false);
    context.kembaliKe('/MataAnggaran');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    final terbit = k.st == _St.terbit;
    final rows = k.tab == 'Belanja' ? maUsulanBelanja : maUsulanPendapatan;
    final kosongN = k.boleh.values.where((v) => v.isEmpty).length;
    final kakiTeks = terbit
        ? 'Diterbitkan. Versi ini tidak dapat diubah lagi.'
        : k.st == _St.periksa
        ? 'Sudah diperiksa. Mengubah isi mengembalikan versi ini ke Draf.'
        : kosongN > 0
        ? '$kosongN baris belum punya “Boleh untuk”. Boleh dibiarkan kosong; '
              'baris itu tidak dapat menerima titipan.'
        : 'Semua baris contoh sudah punya “Boleh untuk”.';
    final garisAtas = BoxDecoration(
      border: Border(top: BorderSide(color: c.garis)),
    );

    return PopScope(
      // An open sheet takes system Back first (navigation.md 5.1).
      canPop: !k.sheet,
      onPopInvokedWithResult: (sudah, _) {
        if (!sudah) k.ubah(() => k.sheet = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Versi 2026.2',
            onKembali: () => _keVersi(context),
            ujung: _lencana(k.st),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Wrap(
              spacing: 8,
              children: [
                for (final t in _tabs)
                  ChipSatu(
                    teks: t,
                    dipilih: k.tab == t,
                    padding: 16,
                    onTap: () => k.ubah(() => k.tab = t),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final r in rows)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: garisAtas,
                      child: _baris(context, k, r, terbit),
                    ),
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: garisAtas,
                    child: Text(
                      'Contoh 5 dari ${k.tab == 'Belanja' ? 158 : 131} baris. '
                      '“Boleh untuk” diisi atas keputusan Pimpinan Jemaat yang '
                      'berwenang. Baris yang dibiarkan kosong tidak dapat '
                      'menerima titipan.',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ),
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
                Text(kakiTeks, style: TextStyle(fontSize: 14, color: c.tinta2)),
                if (k.st == _St.draf)
                  Tombol(
                    'Tandai sudah diperiksa',
                    jenis: JenisTombol.kedua,
                    onPressed: () => k.ubah(() => k.st = _St.periksa),
                  ),
                if (k.st == _St.periksa)
                  Gerak(
                    Kerangka.muncul,
                    lama: const Duration(milliseconds: 300),
                    child: Tombol(
                      'Terbitkan',
                      onPressed: () => k.ubah(() => k.sheet = true),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _baris(BuildContext context, _Keadaan k, MataAnggaran r, bool kunci) {
    final c = context.warna;
    final grup = r.judulKelompok;
    final cur = k.boleh[r.kode] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: 8,
          children: [
            Flexible(
              child: Text(
                '${k.tab} ${r.kode}',
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 13,
                  color: c.tinta2,
                ),
              ),
            ),
            if (r.tanda != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: ShapeDecoration(
                  shape: GarisBorder.penuh(c.laut, radius: 6),
                ),
                child: Text(
                  r.tanda!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.laut,
                  ),
                ),
              ),
          ],
        ),
        Text(
          r.nama,
          style: TextStyle(
            fontSize: 15,
            fontWeight: grup ? FontWeight.w700 : FontWeight.w600,
            color: grup ? c.tinta2 : c.tinta,
          ),
        ),
        if (grup)
          Text(
            'Judul kelompok, tidak dapat dibukukan',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Dapat dibukukan · Boleh untuk: ',
                    children: [
                      TextSpan(
                        text: cur.isEmpty ? 'belum diisi' : cur,
                        style: TextStyle(
                          color: cur.isEmpty ? c.bata : c.tinta,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 13, color: c.tinta2),
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final o in BolehUntuk.values)
                      if (o != BolehUntuk.kosong)
                        _ChipBoleh(
                          teks: o.label,
                          dipilih: cur == o.label,
                          onTap: kunci ? null : () => k.pick(r.kode, o.label),
                        ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// "Boleh untuk" chip: min height 44, padding 0 12, radius 10, 1.5 line,
/// 13/600; colours as [ChipSatu]. Null [onTap] once published (`disabled`).
class _ChipBoleh extends StatelessWidget {
  const _ChipBoleh({
    required this.teks,
    required this.dipilih,
    required this.onTap,
  });
  final String teks;
  final bool dipilih;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: 10,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih ? c.tinta : c.garisTegas,
            radius: 10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              teks,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dipilih ? c.permukaan : c.tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Terbitkan sheet ----------

class _LembarTerbit extends StatelessWidget {
  const _LembarTerbit({required this.k});
  final _Keadaan k;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    void tutup() => k.ubah(() => k.sheet = false);
    return LembarBawah(
      judul: 'Terbitkan versi 2026.2?',
      ukuranJudul: 20,
      labelTirai: 'Kembali ke versi 2026.2',
      onTutup: tutup,
      isi: [
        Kartu(
          status: GarisStatus.ditutup,
          child: Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'Versi yang diterbitkan tidak dapat diubah.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ' Perubahan berikutnya harus menjadi versi baru, berlaku '
                      'mulai bulan yang lebih kemudian.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.permukaan),
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Berlaku mulai Desember 2026.',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
              ),
              const TextSpan(
                text:
                    ' Transaksi sampai November 2026 tetap memakai versi '
                    '2026.1 dan tidak berubah.',
              ),
            ],
          ),
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        Builder(
          builder: (ctx) => Tombol(
            'Terbitkan, berlaku mulai Desember 2026',
            onPressed: () {
              k.ubah(() {
                k.st = _St.terbit;
                k.sheet = false;
              });
              _keRoot(ctx);
            },
          ),
        ),
        Tombol(
          'Kembali',
          jenis: JenisTombol.teks,
          warnaTeks: c.tinta,
          onPressed: tutup,
        ),
      ],
    );
  }

  /// `terbitkan` also switches the board to the Versi view.
  static void _keRoot(BuildContext context) {
    final router = GoRouter.of(context);
    kembaliKeDengan(router, '/MataAnggaran');
  }
}
