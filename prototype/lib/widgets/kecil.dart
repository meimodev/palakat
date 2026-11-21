import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'garis_status.dart';
import 'ikon.dart';
import 'tata_letak.dart';
import 'tekan.dart';

/// The card box: `background: permukaan; border: 1px solid garis; radius 14`
/// by default; the line and fill follow [status]. CSS border-box: [padding]
/// sits inside the line.
class Kartu extends StatelessWidget {
  const Kartu({
    super.key,
    required this.child,
    this.status = GarisStatus.dibukukan,
    this.radius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.isi,
  });

  final Widget child;
  final GarisStatus status;
  final double radius;
  final EdgeInsetsGeometry padding;

  /// Overrides the status fill (lautLembut info cards, bataLembut failure cards).
  final Color? isi;

  @override
  Widget build(BuildContext context) {
    final g = status.gaya(context.warna, radius: radius);
    return Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: isi ?? g.isi,
        shape:
            g.garis ??
            GarisBorder(
              warna: Colors.transparent,
              tebal: 0,
              radius: BorderRadius.circular(radius),
            ),
      ),
      child: child,
    );
  }
}

/// A list row inside a `Kartu(padding: EdgeInsets.symmetric(horizontal: 16))`:
/// min height 60, gap 12, a 1 px `garis` rule above (none on the first row),
/// title 600, caption 13 `tinta3`, trailing `Ikon.lanjut` 18 `tinta3`.
/// With [onTap] it is a [Tekan]; for a board link wrap it in a `Tautan`.
class BarisDaftar extends StatelessWidget {
  const BarisDaftar({
    super.key,
    required this.judul,
    this.keterangan,
    this.pertama = false,
    this.lanjut = true,
    this.ukuranJudul = 15,
    this.onTap,
    this.label,
  });

  final String judul;
  final String? keterangan;

  /// First row: no rule above.
  final bool pertama;

  /// Show the trailing chevron.
  final bool lanjut;
  final double ukuranJudul;
  final VoidCallback? onTap;

  /// Semantics label (board aria-label) when [onTap] is set.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    Widget baris = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  judul,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: ukuranJudul,
                  ),
                ),
                if (keterangan != null)
                  Text(
                    keterangan!,
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
              ],
            ),
          ),
          if (lanjut) ...[
            const SizedBox(width: 12),
            PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
          ],
        ],
      ),
    );
    if (onTap != null) {
      baris = Tekan(onTap: onTap, label: label, child: baris);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!pertama) GarisLurus(warna: c.garis),
        baris,
      ],
    );
  }
}

/// Section heading `h2`: phone 16/700, web 17/700, margin 0, with an optional
/// [Hitungan] after it (gap 8).
class JudulBagian extends StatelessWidget {
  const JudulBagian(this.teks, {super.key, this.web = false, this.hitungan});

  final String teks;
  final bool web;
  final int? hitungan;

  @override
  Widget build(BuildContext context) {
    final judul = Semantics(
      header: true,
      child: Text(
        teks,
        style: TextStyle(fontSize: web ? 17 : 16, fontWeight: FontWeight.w700),
      ),
    );
    if (hitungan == null) return judul;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: judul),
        const SizedBox(width: 8),
        Hitungan(hitungan!),
      ],
    );
  }
}

/// The blocker/action counter: `bata` pill, `diBata` 13/700, min 22 × 22,
/// padding 0 6 ([rapat]: no horizontal padding, TutupBuku).
class Hitungan extends StatelessWidget {
  const Hitungan(this.n, {super.key, this.rapat = false});

  final int n;
  final bool rapat;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: EdgeInsets.symmetric(horizontal: rapat ? 0 : 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.bata,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$n',
        style: TextStyle(
          color: c.diBata,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

/// An inline text link (browser default `<a>`): [warna] (`laut`), underlined
/// in the same colour, [warnaAktif] (`lautTua`) on hover and press over
/// `sentuh`. Put it inside a `Tautan` or [Tekan] for the 44 × 44 target; in a
/// `Tautan` the hover covers the whole target ([SorotTautan]).
class TautanTeks extends StatefulWidget {
  const TautanTeks(
    this.teks, {
    super.key,
    this.berat = FontWeight.w600,
    this.ukuran,
    this.warna,
    this.warnaAktif,
    this.rata,
  });

  final String teks;
  final FontWeight berat;

  /// null = inherited.
  final double? ukuran;

  /// Default `laut`.
  final Color? warna;

  /// Default `lautTua` when [warna] is null, else [warna] (no hover change).
  final Color? warnaAktif;
  final TextAlign? rata;

  @override
  State<TautanTeks> createState() => _TautanTeksState();
}

class _TautanTeksState extends State<TautanTeks> {
  bool _layang = false, _tekan = false;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final biasa = widget.warna ?? c.laut;
    final aktif =
        widget.warnaAktif ?? (widget.warna == null ? c.lautTua : biasa);
    final warna = _layang || _tekan || SorotTautan.of(context) ? aktif : biasa;
    return MouseRegion(
      onEnter: (_) => setState(() => _layang = true),
      onExit: (_) => setState(() => _layang = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _tekan = true),
        onPointerUp: (_) => setState(() => _tekan = false),
        onPointerCancel: (_) => setState(() => _tekan = false),
        child: AnimatedDefaultTextStyle(
          duration: context.gerak(PalakatMotion.sentuh),
          curve: PalakatMotion.keluar,
          style: DefaultTextStyle.of(context).style.copyWith(
            color: warna,
            fontWeight: widget.berat,
            fontSize: widget.ukuran,
            decoration: TextDecoration.underline,
            decorationColor: warna,
            decorationThickness: 1,
          ),
          child: Text(widget.teks, textAlign: widget.rata),
        ),
      ),
    );
  }
}

/// The row of text links under a heading: wrap, gap 0 22, 14/600, margin
/// −8 top and bottom (phone) or −8 top only ([web]). Each child is a
/// `Tautan(…, child: TautanTeks(…))` (44 × 44 minimum).
class DeretTautan extends StatelessWidget {
  const DeretTautan({super.key, required this.anak, this.web = false});

  final List<Widget> anak;
  final bool web;

  @override
  Widget build(BuildContext context) => MarginNegatif(
    atas: 8,
    bawah: web ? 0 : 8,
    child: DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      child: Wrap(
        spacing: 22,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: anak,
      ),
    ),
  );
}

/// The one-line input (and with [baris] > 1 the textarea): min height 48,
/// padding 0 14, radius 12, 1 px `garisTegas`, `permukaan` ([latar] `kertas`
/// for search fields), label 14 `tinta2` above with gap [jarakLabel]
/// (8; 6 in flow boards), placeholder `tinta3` (clipped, no ellipsis), typed
/// text inherited (CSS `input{font:inherit}`; letter spacing 0 unless
/// inherited or set in [gaya]). Focus: the 2 px `laut` ring.
class IsianTeks extends StatefulWidget {
  const IsianTeks({
    super.key,
    this.controller,
    this.nilaiAwal,
    this.label,
    this.labelSemantik,
    this.petunjuk,
    this.onChanged,
    this.formatters,
    this.keyboardType,
    this.latar,
    this.jarakLabel = 8,
    this.gaya,
    this.baris = 1,
    this.padding,
    this.minTinggi,
    this.hanyaBaca = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  final TextEditingController? controller;

  /// Initial text when no [controller] is given.
  final String? nilaiAwal;

  /// Visible label above the field.
  final String? label;

  /// Board aria-label (fields without a visible label).
  final String? labelSemantik;

  /// Placeholder.
  final String? petunjuk;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;

  /// Box fill; default `permukaan`.
  final Color? latar;
  final double jarakLabel;

  /// Typed text style, merged over the inherited one (e.g. mono on Tanggal).
  final TextStyle? gaya;

  /// Lines: 1 = input; more = textarea (padding 12 14, min height 96).
  final int baris;
  final EdgeInsetsGeometry? padding;
  final double? minTinggi;
  final bool hanyaBaca;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Board `autocomplete` (e.g. `AutofillHints.oneTimeCode`).
  final Iterable<String>? autofillHints;

  @override
  State<IsianTeks> createState() => _IsianTeksState();
}

class _IsianTeksState extends State<IsianTeks> {
  FocusNode? _fokusSendiri;
  TextEditingController? _isiSendiri;
  FocusNode get _fokus => widget.focusNode ?? (_fokusSendiri ??= FocusNode());
  TextEditingController get _isi =>
      widget.controller ??
      (_isiSendiri ??= TextEditingController(text: widget.nilaiAwal));

  @override
  void initState() {
    super.initState();
    _fokus.addListener(_ubah);
  }

  @override
  void didUpdateWidget(IsianTeks old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _fokusSendiri)?.removeListener(_ubah);
      _fokus.addListener(_ubah);
    }
  }

  void _ubah() => setState(() {});

  @override
  void dispose() {
    _fokus.removeListener(_ubah);
    _fokusSendiri?.dispose();
    _isiSendiri?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final asal = DefaultTextStyle.of(context).style;
    // TextField merges the M3 bodyLarge (letterSpacing 0.5) under this.
    final teks = asal
        .copyWith(letterSpacing: asal.letterSpacing ?? 0)
        .merge(widget.gaya);
    final area = widget.baris > 1;
    Widget kotak = CincinFokus(
      tampil: _fokus.hasFocus,
      radius: 12,
      child: Container(
        constraints: BoxConstraints(
          minHeight: widget.minTinggi ?? (area ? 96 : 48),
        ),
        padding:
            widget.padding ??
            (area
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 14)),
        alignment: area ? Alignment.topLeft : Alignment.centerLeft,
        decoration: ShapeDecoration(
          color: widget.latar ?? c.permukaan,
          shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 12),
        ),
        // TextField needs a Material ancestor; screens may not have one.
        child: Material(
          type: MaterialType.transparency,
          child: TextField(
            controller: _isi,
            focusNode: _fokus,
            readOnly: widget.hanyaBaca,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            inputFormatters: widget.formatters,
            keyboardType: widget.keyboardType,
            autofillHints: widget.autofillHints,
            textInputAction: widget.textInputAction,
            minLines: area ? widget.baris : null,
            maxLines: widget.baris,
            style: teks,
            cursorColor: c.laut,
            decoration: InputDecoration.collapsed(
              hintText: area ? widget.petunjuk : null,
              hintStyle: teks.copyWith(
                color: c.tinta3,
                overflow: TextOverflow.clip,
              ),
              // An input's placeholder stays on one line, clipped mid-glyph.
              hint: area || widget.petunjuk == null
                  ? null
                  : Text(
                      widget.petunjuk!,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: teks.copyWith(color: c.tinta3),
                    ),
            ),
          ),
        ),
      ),
    );
    if (widget.labelSemantik != null) {
      kotak = Semantics(label: widget.labelSemantik, child: kotak);
    }
    if (widget.label == null) return kotak;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _fokus.requestFocus,
            child: Text(
              widget.label!,
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
          SizedBox(height: widget.jarakLabel),
          kotak,
        ],
      ),
    );
  }
}

/// Checkbox row: 24 × 24 box (radius 4; unticked 1.5 `garisTegas` on
/// `permukaan`; ticked `laut` with `Ikon.centang` 16 `diLaut` stroke 3), gap
/// 12, top-aligned [label] 14, min height 44. The whole row is the target.
/// [jarakAtas] pads the box only (the flow boards' `margin: 2px 0 0`).
class KotakCentang extends StatelessWidget {
  const KotakCentang({
    super.key,
    required this.nilai,
    required this.onUbah,
    this.label,
    this.ukuran = 24,
    this.labelSemantik,
    this.jarakAtas = 0,
  });

  final bool nilai;
  final ValueChanged<bool>? onUbah;
  final Widget? label;
  final double ukuran;
  final String? labelSemantik;
  final double jarakAtas;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kotak = SizedBox.square(
      dimension: ukuran,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: nilai ? c.laut : c.permukaan,
          shape: nilai
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
              : GarisBorder.penuh(c.garisTegas, radius: 4),
        ),
        child: nilai
            ? Center(
                child: PalakatIkon(Ikon.centang, ukuran: 16, warna: c.diLaut),
              )
            : null,
      ),
    );
    return Tekan(
      onTap: onUbah == null ? null : () => onUbah!(!nilai),
      tercentang: nilai,
      label: labelSemantik,
      child: _barisPilihan(
        label == null || jarakAtas == 0
            ? kotak
            : Padding(
                padding: EdgeInsets.only(top: jarakAtas),
                child: kotak,
              ),
        label,
      ),
    );
  }
}

/// Radio row: 22 × 22; unchosen 1.5 `tinta3` ring, chosen 6 px `tinta` ring
/// (TampilanNama). The whole row is the target.
class PilihanBulat extends StatelessWidget {
  const PilihanBulat({
    super.key,
    required this.nilai,
    required this.onPilih,
    this.label,
    this.ukuran = 22,
    this.labelSemantik,
  });

  final bool nilai;
  final VoidCallback? onPilih;
  final Widget? label;
  final double ukuran;
  final String? labelSemantik;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final bulat = SizedBox.square(
      dimension: ukuran,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.permukaan,
          border: Border.all(
            color: nilai ? c.tinta : c.tinta3,
            width: nilai ? 6 : 1.5,
          ),
        ),
      ),
    );
    return Tekan(
      onTap: onPilih,
      tercentang: nilai,
      label: labelSemantik,
      child: _barisPilihan(bulat, label),
    );
  }
}

Widget _barisPilihan(Widget tanda, Widget? label) {
  if (label == null) {
    return Center(widthFactor: 1, heightFactor: 1, child: tanda);
  }
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      tanda,
      const SizedBox(width: 12),
      Expanded(
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 14),
          child: label,
        ),
      ),
    ],
  );
}

/// The confirmation after an action in flow boards: `role="status"`,
/// `lautLembut`, radius 12, padding 12 14, 14 px. [siaran] false drops the
/// live region (the notice box of KitAlur).
class Pesan extends StatelessWidget {
  const Pesan(this.child, {super.key, this.siaran = true});

  final Widget child;
  final bool siaran;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: siaran,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.warna.lautLembut,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14),
        child: child,
      ),
    ),
  );
}
