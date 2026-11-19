import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

enum TahapPemulihan { mulai, kode, selesai }

/// The logic class of Pemulihan and WebPemulihan. Each board owns its own.
class KeadaanPemulihan {
  TahapPemulihan tahap = TahapPemulihan.mulai;
  String email = '';
  String kode = '';

  bool get okE => RegExp(r'.+@.+\..+').hasMatch(email);
  bool get okK => kode.length == 6;
  bool get ok => tahap == TahapPemulihan.mulai ? okE : okK;

  /// Any six digits are accepted; nothing moves backwards.
  void maju() {
    if (!ok) return;
    tahap = tahap == TahapPemulihan.mulai
        ? TahapPemulihan.kode
        : TahapPemulihan.selesai;
  }
}

/// Note for the Keadaan panel (the board accepts any code, no hint on screen).
const alatPemulihan = [Text('Kode: enam angka apa saja')];

/// The step block shared by both boards: `mulai`, `kode` or `selesai`.
class LangkahPemulihan extends StatefulWidget {
  const LangkahPemulihan({
    super.key,
    required this.akunSaya,
    required this.beranda,
  });

  /// "Pasang nomor ponsel baru di Akun saya" (an inline link; only its target
  /// and [Tautan.buka] are used).
  final Tautan akunSaya;

  /// "Buka Beranda".
  final Widget beranda;

  @override
  State<LangkahPemulihan> createState() => _LangkahPemulihanState();
}

class _LangkahPemulihanState extends State<LangkahPemulihan> {
  final _k = KeadaanPemulihan();
  final _email = TextEditingController();
  final _kode = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _kode.dispose();
    super.dispose();
  }

  void _maju() => setState(_k.maju);

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    Widget tombol(String label) =>
        Tombol(label, onPressed: _maju, nonaktif: !_k.ok);

    final List<Widget> isi = switch (_k.tahap) {
      TahapPemulihan.mulai => [
        _judul(
          context,
          'Pemulihan akun',
          const Text(
            'Untuk orang yang sama yang kehilangan nomor ponselnya. Bila Bendahara berganti orang, pakai Serah terima Bendahara.',
          ),
        ),
        IsianTeks(
          controller: _email,
          label: 'Email cadangan akun',
          jarakLabel: 6,
          petunjuk: 'nama@contoh.id',
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => setState(() => _k.email = v),
        ),
        tombol('Kirim kode pemulihan'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: _kartu(c),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text:
                      'Tidak punya email cadangan, atau tidak bisa membukanya?',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'Bendahara Jemaat: Petugas verifikasi memulihkan akun setelah memeriksa identitas Anda bersama BPMJ. Anggota dan pelayan lain: Operator memulihkan akun setelah Penatua Kolom memastikan identitas Anda.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
      TahapPemulihan.kode => [
        _judul(
          context,
          'Masukkan kode pemulihan',
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Dikirim ke '),
                TextSpan(
                  text: _k.email,
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
                ),
              ],
            ),
          ),
        ),
        _IsianKode(
          controller: _kode,
          onChanged: (v) => setState(() => _k.kode = v),
        ),
        tombol('Pulihkan akun'),
      ],
      TahapPemulihan.selesai => [
        _judul(
          context,
          'Akun dipulihkan',
          Text(
            'Meiske Lumentut · Wewenang Bendahara aktif',
            style: TextStyle(color: c.tinta),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: _kartu(c),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _baris(
                  c,
                  null,
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Orangnya sama, wewenangnya tetap.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' Tidak perlu surat penunjukan baru.'),
                      ],
                    ),
                  ),
                ),
                _baris(c, c.garis, _BarisAkunSaya(akunSaya: widget.akunSaya)),
                _baris(
                  c,
                  c.garis,
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Tercatat di Riwayat aktivitas',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: ' sebagai pemulihan akun, 16/11/2026 12.05.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        widget.beranda,
      ],
    };

    final blok = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < isi.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          isi[i],
        ],
      ],
    );
    if (_k.tahap == TahapPemulihan.mulai) return blok;
    return Gerak(
      Kerangka.muncul,
      key: ValueKey(_k.tahap),
      lama: const Duration(milliseconds: 300),
      child: blok,
    );
  }

  static Widget _judul(BuildContext context, String judul, Widget teks) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              judul,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 15, color: context.warna.tinta2),
            child: teks,
          ),
        ],
      );

  static ShapeDecoration _kartu(PalakatWarna c) => ShapeDecoration(
    color: c.permukaan,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: c.garis),
      borderRadius: BorderRadius.circular(14),
    ),
  );

  static Widget _baris(PalakatWarna c, Color? garisAtas, Widget anak) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: garisAtas == null
            ? null
            : BoxDecoration(
                border: Border(top: BorderSide(color: garisAtas)),
              ),
        child: anak,
      );
}

/// Row 2 of the `selesai` card: the link runs inline in the sentence, so it is
/// a tappable span; the row takes keyboard focus and opens the link on Enter.
// ponytail: the span is shorter than 44 px; a shared inline-link primitive
// would fix that for every board (see sharedNeeds).
class _BarisAkunSaya extends StatefulWidget {
  const _BarisAkunSaya({required this.akunSaya});
  final Tautan akunSaya;

  @override
  State<_BarisAkunSaya> createState() => _BarisAkunSayaState();
}

class _BarisAkunSayaState extends State<_BarisAkunSaya> {
  late final _ketuk = TapGestureRecognizer()..onTap = _buka;
  bool _sorot = false, _fokus = false;

  void _buka() => widget.akunSaya.buka(GoRouter.of(context));

  @override
  void dispose() {
    _ketuk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final warna = _sorot ? c.lautTua : c.laut;
    return FocusableActionDetector(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => _buka(),
        ),
      },
      onShowFocusHighlight: (v) => setState(() => _fokus = v),
      child: CincinFokus(
        tampil: _fokus,
        radius: 4,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Semua sesi lain diakhiri.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' Perangkat lain harus masuk lagi. '),
              TextSpan(
                text: 'Pasang nomor ponsel baru di Akun saya',
                recognizer: _ketuk,
                mouseCursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _sorot = true),
                onExit: (_) => setState(() => _sorot = false),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: warna,
                  decoration: TextDecoration.underline,
                  decorationColor: warna,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ),
    );
  }
}

/// The code input: as the email input, min height 60, mono 26, letter
/// spacing 8, centred; digits only, at most 6.
class _IsianKode extends StatefulWidget {
  const _IsianKode({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<_IsianKode> createState() => _IsianKodeState();
}

class _IsianKodeState extends State<_IsianKode> {
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final gaya = DefaultTextStyle.of(context).style
        .copyWith(fontFamily: PalakatText.mono, fontSize: 26, letterSpacing: 8);
    return Semantics(
      label: 'Kode enam angka',
      child: CincinFokus(
        tampil: _fokus.hasFocus,
        radius: 12,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          // Chrome centres the trailing 8 px letter spacing too: 4 px left.
          padding: const EdgeInsets.fromLTRB(14, 0, 22, 0),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: c.garisTegas),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: TextField(
              controller: widget.controller,
              focusNode: _fokus,
              onChanged: widget.onChanged,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textAlign: TextAlign.center,
              style: gaya,
              cursorColor: c.laut,
              decoration: const InputDecoration.collapsed(hintText: null),
            ),
          ),
        ),
      ),
    );
  }
}

class PemulihanScreen extends StatelessWidget {
  const PemulihanScreen({super.key});

  @override
  Widget build(BuildContext context) => AlatPrototipe(
    stem: 'Pemulihan',
    alat: alatPemulihan,
    child: LayarPonsel(
      child: ColoredBox(
        color: context.warna.permukaan,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Tidak bisa masuk',
              kembaliKe: 'Masuk',
              labelKembali: 'Kembali ke Masuk',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: LangkahPemulihan(
                  akunSaya: const Tautan(ke: 'AkunSaya', child: SizedBox()),
                  beranda: const Tombol(
                    'Buka Beranda',
                    onPressed: null,
                    ke: 'Main',
                    cara: Cara.ganti,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
