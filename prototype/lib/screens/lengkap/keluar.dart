import 'package:flutter/widgets.dart';

import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/tombol.dart';
import 'keluar_akun.dart';
import '../../app/layar.dart';
import '../../providers/session.dart';

/// Board state `st`: 'akun' or 'tanya' (sheet open). 'keluar' is the child
/// route `/Keluar/keluar`.
class _Keadaan extends InheritedWidget {
  const _Keadaan({required this.st, required super.child});
  final ValueNotifier<String> st;

  static ValueNotifier<String> of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_Keadaan>()!.st;

  @override
  bool updateShouldNotify(_Keadaan old) => old.st != st;
}

class KeluarKendali extends StatefulWidget {
  const KeluarKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KeluarKendali> createState() => _KeluarKendaliState();
}

class _KeluarKendaliState extends State<KeluarKendali> {
  final _st = ValueNotifier('akun');

  @override
  void dispose() {
    _st.dispose();
    super.dispose();
  }

  void _batal() => _st.value = 'akun';

  // Close the sheet and sign out: the router shows the picker (D7, D19).
  void _keluar() {
    _st.value = 'akun';
    keluarSesi(context);
  }

  @override
  Widget build(BuildContext context) => _Keadaan(
    st: _st,
    child: ValueListenableBuilder(
      valueListenable: _st,
      builder: (context, st, _) => LayarPonsel(
        overlay: [
          if (st == 'tanya')
            Positioned.fill(
              child: LembarBawah(
                judul: judulTanya,
                anakJudul: kalimatTanya,
                pegangan: false,
                jarak: 12,
                masuk: Kerangka.muncul,
                labelTirai: 'Kembali ke Akun',
                onTutup: _batal,
                isi: tombolTanya(context, onKeluar: _keluar, onKembali: _batal),
              ),
            ),
        ],
        child: widget.child,
      ),
    ),
  );
}

class KeluarScreen extends StatelessWidget {
  const KeluarScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) =>
      anak == 'keluar' ? const _SudahKeluar() : const _Akun();
}

class _Akun extends StatelessWidget {
  const _Akun();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return ColoredBox(
      color: c.kertas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Akun',
            kembaliKe: Layar.pengaturan,
            labelKembali: 'Kembali ke Lainnya',
          ),
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KartuProfil(ke: Layar.akun),
                  SizedBox(height: 16),
                  KartuSesi(ke: Layar.bendahara),
                  SizedBox(height: 16),
                  KalimatKeluar(),
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
            child: Tombol(
              'Keluar dari perangkat ini',
              onPressed: () => _Keadaan.of(context).value = 'tanya',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
            ),
          ),
        ],
      ),
    );
  }
}

class _SudahKeluar extends StatelessWidget {
  const _SudahKeluar();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.warna.kertas,
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [IsiSudahKeluar()],
      ),
    ),
  );
}
