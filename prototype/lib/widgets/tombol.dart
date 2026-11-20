import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../shell/tautan.dart';
import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'tekan.dart';
import '../app/layar.dart';

enum JenisTombol {
  utama,
  tinta,
  kedua,
  teks,
  garisLaut,
  putus,
  bata,
  garisBata,
}

enum UkuranTombol {
  /// 52 / radius 14 / padding 0 16: bottom actions, form actions.
  besar(52, 14, 16),

  /// 48 / 14 / 0 16: secondary bottom actions, Penolakan options.
  sedang(48, 14, 16),

  /// 46 / 12 / 0 20: paired actions inside cards.
  ringkas(46, 12, 20),

  /// 44 / 12 / 0 16: web quick actions.
  kecil(44, 12, 16),

  /// 44 / 10 / 0 12: row actions, AI Pakai/Ubah/Abaikan.
  mini(44, 10, 12);

  const UkuranTombol(this.tinggi, this.radius, this.padding);
  final double tinggi, radius, padding;
}

/// The button: a [Tekan] with the board's fill, line and 700 text. No ink.
class Tombol extends StatelessWidget {
  const Tombol(
    this.label, {
    super.key,
    required this.onPressed,
    this.jenis = JenisTombol.utama,
    this.ukuran = UkuranTombol.besar,
    this.lebarPenuh = true,
    this.ikon,
    this.ukuranTeks,
    this.nonaktif = false,
    this.paddingH,
    this.warnaTeks,
    this.ke,
    this.param = const {},
    this.anak,
    this.cara = Cara.dorong,
  });

  /// Glossary verb, verbatim.
  final String label;
  final VoidCallback? onPressed;
  final JenisTombol jenis;
  final UkuranTombol ukuran;
  final bool lebarPenuh;

  /// Leading icon, gap 8.
  final Widget? ikon;

  /// 14 or 13 when the board says so; else inherited (16 phone, 15 web).
  final double? ukuranTeks;

  /// `garis` fill, `tinta3` text; still focusable, never runs [onPressed].
  /// Its reason must stand next to it in full-contrast text.
  final bool nonaktif;

  /// Horizontal padding when the board differs from [ukuran] (0 20, 0 14 …).
  final double? paddingH;

  /// Text colour when the board differs from [jenis]: `lautTua` on six
  /// `garisLaut` boards, `tinta` on TutupBuku's "Kembali".
  final Color? warnaTeks;

  /// When set, the button is a [Tautan] to this board (navigation.md 3.1);
  /// [onPressed] is then not used.
  final Layar? ke;

  /// Path parameters and child route of [ke].
  final Map<String, String> param;
  final String? anak;

  /// Push, go or up for [ke].
  final Cara cara;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final r = ukuran.radius;
    final (Color? isi, GarisBorder? garis, Color teks) = nonaktif
        ? (c.garis, null, c.tinta3)
        : switch (jenis) {
            JenisTombol.utama => (c.laut, null, c.diLaut),
            JenisTombol.tinta => (c.tinta, null, c.permukaan),
            JenisTombol.kedua => (
              c.permukaan,
              GarisBorder.penuh(c.tinta, radius: r),
              c.tinta,
            ),
            JenisTombol.teks => (null, null, c.laut),
            JenisTombol.garisLaut => (
              c.permukaan,
              GarisBorder.penuh(c.laut, radius: r),
              c.laut,
            ),
            JenisTombol.putus => (
              null,
              GarisBorder.putus(c.putus, radius: r),
              c.tinta2,
            ),
            JenisTombol.bata => (c.bata, null, c.diBata),
            JenisTombol.garisBata => (
              c.permukaan,
              GarisBorder.penuh(c.bata, radius: r),
              c.bata,
            ),
          };
    final rupa = RupaTombol(
      label: label,
      isi: isi,
      garis: garis,
      warnaTeks: warnaTeks ?? teks,
      radius: r,
      tinggi: jenis == JenisTombol.teks ? 44 : ukuran.tinggi,
      paddingH: paddingH ?? ukuran.padding,
      lebarPenuh: lebarPenuh,
      ikon: ikon,
      ukuranTeks: ukuranTeks,
    );
    if (nonaktif) {
      return TekanAria(onTap: () {}, aktif: false, radius: r, child: rupa);
    }
    if (ke != null) {
      return Tautan(
        ke: ke!,
        param: param,
        anak: anak,
        cara: cara,
        radius: r,
        child: rupa,
      );
    }
    return Tekan(onTap: onPressed, radius: r, child: rupa);
  }
}

/// The look of a button (fill, line, centred 700 label), without behaviour.
/// Shared by [Tombol] and `TombolBersyarat`.
class RupaTombol extends StatelessWidget {
  const RupaTombol({
    super.key,
    required this.label,
    required this.isi,
    required this.warnaTeks,
    required this.radius,
    required this.tinggi,
    required this.paddingH,
    this.garis,
    this.lebarPenuh = true,
    this.ikon,
    this.ukuranTeks,
  });

  final String label;
  final Color? isi;
  final GarisBorder? garis;
  final Color warnaTeks;
  final double radius, tinggi, paddingH;
  final bool lebarPenuh;
  final Widget? ikon;
  final double? ukuranTeks;

  @override
  Widget build(BuildContext context) => Container(
    // `<button>` is border-box: the min height includes the line.
    constraints: BoxConstraints(minHeight: tinggi),
    padding: EdgeInsets.symmetric(horizontal: paddingH),
    decoration: ShapeDecoration(
      color: isi,
      shape:
          garis ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    ),
    child: Center(
      widthFactor: lebarPenuh ? null : 1,
      heightFactor: 1,
      child: Text.rich(
        TextSpan(
          children: [
            if (ikon != null)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ikon,
                ),
              ),
            TextSpan(text: label),
          ],
        ),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: ukuranTeks,
          fontWeight: FontWeight.w700,
          color: warnaTeks,
        ),
      ),
    ),
  );
}

/// A pressable that stays focusable and pressable while it reads as disabled
/// (board `aria-disabled`): `Semantics(enabled: aktif, hint: petunjuk)`.
/// Same keyboard, cursor, focus ring and 44 minimum as [Tekan].
class TekanAria extends StatefulWidget {
  const TekanAria({
    super.key,
    required this.onTap,
    required this.aktif,
    required this.child,
    this.petunjuk,
    this.radius = 0,
    this.minLebar = 44,
    this.minTinggi = 44,
  });

  final VoidCallback onTap;
  final bool aktif;
  final String? petunjuk;
  final double radius, minLebar, minTinggi;
  final Widget child;

  @override
  State<TekanAria> createState() => _TekanAriaState();
}

const _pintasan = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
};

class _TekanAriaState extends State<TekanAria> {
  bool _sorot = false;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    enabled: widget.aktif,
    hint: widget.petunjuk,
    child: FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      shortcuts: _pintasan,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onTap(),
        ),
      },
      onShowFocusHighlight: (v) => setState(() => _sorot = v),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: CincinFokus(
          tampil: _sorot,
          radius: widget.radius,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minLebar,
              minHeight: widget.minTinggi,
            ),
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}

/// The permanent action (Tutup buku): press and hold until the `laut` fill is
/// full (1600 ms linear, `segelTahan`); [onSelesai] fires at 1650 ms. Release,
/// cancel or leaving the button earlier cancels and shrinks the fill (200 ms).
/// Enter, Space or a screen reader's activate closes at once. Nothing while not [siap].
class TombolTahan extends StatefulWidget {
  const TombolTahan(
    this.label, {
    super.key,
    required this.siap,
    required this.onSelesai,
    this.tinggi = 56,
    this.petunjuk,
  });

  /// 'Tutup buku Oktober 2026'.
  final String label;

  /// Statement ticked.
  final bool siap;
  final VoidCallback onSelesai;

  /// 56 phone (TutupBuku), 54 web (WebTutupBuku).
  final double tinggi;

  /// The phone's line under it, 13 `tinta3` centred, gap 6 (web draws its own).
  final String? petunjuk;

  static const tahanSampai = Duration(milliseconds: 1650);

  @override
  State<TombolTahan> createState() => _TombolTahanState();
}

class _TombolTahanState extends State<TombolTahan> {
  bool _tahan = false;
  bool _sorot = false;
  Timer? _t;

  void _mulai() {
    if (!widget.siap) return;
    setState(() => _tahan = true);
    _t?.cancel();
    _t = Timer(TombolTahan.tahanSampai, _selesai);
  }

  void _batal() {
    if (!_tahan) return;
    _t?.cancel();
    setState(() => _tahan = false);
  }

  void _selesai() {
    _t?.cancel();
    if (mounted) setState(() => _tahan = false);
    widget.onSelesai();
  }

  @override
  void didUpdateWidget(TombolTahan old) {
    super.didUpdateWidget(old);
    if (!widget.siap) _batal();
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final siap = widget.siap;
    final tombol = Semantics(
      container: true,
      button: true,
      enabled: siap,
      onTap: siap ? _selesai : null,
      child: FocusableActionDetector(
        // The board sets `disabled` until the statement is ticked.
        enabled: siap,
        mouseCursor: siap ? SystemMouseCursors.click : MouseCursor.defer,
        shortcuts: _pintasan,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => siap ? _selesai() : null,
          ),
        },
        onShowFocusHighlight: (v) => setState(() => _sorot = v),
        child: Builder(
          builder: (kotak) => Listener(
            onPointerDown: (_) => _mulai(),
            onPointerUp: (_) => _batal(),
            onPointerCancel: (_) => _batal(),
            onPointerMove: (e) {
              if (!(Offset.zero & kotak.size!).contains(e.localPosition)) {
                _batal();
              }
            },
            child: MouseRegion(
              onExit: (_) => _batal(),
              child: CincinFokus(
                tampil: _sorot && siap,
                radius: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ColoredBox(
                    color: siap ? c.tinta : c.garis,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedFractionallySizedBox(
                            duration: context.gerak(
                              _tahan
                                  ? PalakatMotion.segelTahan
                                  : const Duration(milliseconds: 200),
                            ),
                            curve: Curves.linear,
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: _tahan ? 1 : 0,
                            heightFactor: 1,
                            child: ColoredBox(color: c.laut),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: widget.tinggi,
                            minWidth: double.infinity,
                          ),
                          child: Center(
                            heightFactor: 1,
                            child: Padding(
                              // Chrome's default button padding.
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                widget.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: siap ? c.permukaan : c.tinta3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.petunjuk == null) return tombol;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tombol,
        const SizedBox(height: 6),
        Text(
          widget.petunjuk!,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }
}
