# Motion

Every animation on the Palakat canvas, and exactly how the prototype builds it in Flutter. `CONVENTIONS.md` wins over this file. The board source wins on what moves, when and for how long.

Sources: `01-foundations.md` (Motion), `02-components.md` (Gerak), `design-system/components/Gerak/` (README and preview), `tokens/palakat_tokens.dart` (`PalakatMotion`), and every board's `<style>` block and inline `style`. All numbers here come from the boards.

## What the boards contain

- 19 keyframe names. The list is confirmed against every board: `muncul`, `masuk`, `naik`, `pudar`, `cap`, `sapu`, `isi`, `titik`, `gelap`, `lingkar`, `putar`, `kait`, `dariKiri`, `dariKanan`, `balik`, `tali`, `denyut`, `turun`, `kilat`. There are no others. `segel` exists only in the Gerak preview. It is the same keyframe that `TutupBuku` and `WebTutupBuku` call `cap` (variant C below).
- 189 boards declare keyframes in their `<style>` block. 86 boards use a keyframe and 4 more (Pemberitahuan, WebPemberitahuan, WebBagi, WebHitungKas) have only CSS transitions: 90 boards move. The other 109 boards have no motion at all. A keyframe that a board declares but never uses is not built for that board.
- 305 inline `animation:` usages and 32 inline `transition:` usages. No CSS class carries motion. Besides the keyframes, the stylesheets hold the reduce-motion rule and static rules only; the one state style is `a:hover{color:#0A4249}`, an instant colour change to `lautTua`.
- 34 timer calls (`setTimeout`, `setInterval`) across 23 boards. They fake work (upload, AI, saving, generating, verification) or drive a counting figure.
- The full list of usages, board by board, is in "Appendix: every usage".

## Rules for every motion

1. **Motion marks a change in the status of money or of work.** The six named motions in `PalakatMotion` carry the money moments. The keyframes also do the ordinary entrances (a view, a sheet, a result) the boards draw.
2. **Nothing animates out.** On the boards a view, sheet, toast or card disappears the moment its `sc-if` turns false. Do not use `AnimatedSwitcher`, `showModalBottomSheet` or any exit or reverse transition. Removal is instant, and Back is instant.
3. **An entrance plays when its element mounts.** An `sc-if` that turns true mounts its content, and every `animation:` inside it plays from the start. In Flutter this is a widget that plays in `initState`. It must not replay on an ordinary rebuild (typing, a tick). It must replay when the board would remount it. Give every animated widget a `ValueKey` naming the state that shows it (`ValueKey('periksa')`, `ValueKey(posted)`), so that a state change remounts it. In lists (`sc-for`), key each item by a stable id, so that only new items animate.
4. **Fill mode.** `both` means the element shows the 0 % frame during its delay and keeps the 100 % frame after it ends. Every delayed one-shot on the boards uses `both`, so a delayed element is invisible until its delay ends. The 100 % frame matters for `cap` variant A: the No. Bukti stamp stays tilted −3° for good. Without `both` (for example `muncul .3s`), the element returns to its plain style after the end, which equals the 100 % frame in every such case. The one exception is `titik`: its delayed dots show their plain style (opacity 1) until their delay ends. See `titik`.
5. **Easing applies to each keyframe segment, not to the whole animation.** This is how CSS works. In `cap` (stops at 0, 55, 100 %) the curve runs once from 0 to 55 % and again from 55 to 100 %. Build multi-stop keyframes with the helper `ruas(t, a, b, kurva)` below on a linear controller. Never apply the curve to the whole animation.
6. **CSS easing names become Flutter curves:**

   | CSS | Flutter |
   | --- | --- |
   | none given (CSS default `ease`) | `Curves.ease` |
   | `ease-out` | `Curves.easeOut` |
   | `ease-in-out` | `Curves.easeInOut` |
   | `linear` | `Curves.linear` |
   | `cubic-bezier(.2,.8,.2,1)` | `PalakatMotion.keluar` (`Cubic(0.2, 0.8, 0.2, 1)`) |

   Keep the board's easing even where it differs from the token curve. Most `muncul .3s` uses are CSS `ease`, not `keluar`.
7. **Transform origin** is the element centre unless the board says otherwise. `sapu` uses the left edge, `balik` the top edge, and the lock in `segel` the centre of its 104 × 104 box (52, 52).
8. **Paint order.** On the boards an absolutely positioned overlay (`sapu`, `kilat`) paints over the in-flow content of its card. Put the overlay last in the `Stack`. The No. Bukti stamp paints above the sweep in the browser, because a transformed element stacks after the earlier overlay. The difference is a 20 % `laut` tint over a `laut` stamp for 350 ms, so putting the overlay above everything is acceptable.
9. **No press ripple.** The boards draw no pressed state (no `:active` style). Set `splashFactory: NoSplash.splashFactory` and transparent `highlightColor` and `hoverColor` in the theme. `sentuh` (160 ms) is used by Sakelar, the only touch feedback the boards animate. Hover on a link changes its colour to `lautTua` instantly.
10. **Durations are the board's.** Map them to `PalakatMotion` where they match (table below). Other durations are written as `Duration(milliseconds: …)` with the board's value in `lib/motion/` or at the call site. Colours always come from `context.warna`.
11. **Reduce motion.** When the system setting or the Keadaan panel switch is on, every motion completes at once, delays included, and repeating motion stands still. Timers that fake work keep their real duration. See "Reduce motion".

## Named motions (`PalakatMotion`)

| Token | Duration | Handoff meaning | What the boards do |
| --- | --- | --- | --- |
| `sentuh` | 160 ms | Touch feedback | Sakelar: track `background .16s` and knob `left .16s` (Lainnya, Pemberitahuan, WebPemberitahuan, WebPengaturan) |
| `pindahLayar` | 280 ms | Screen change, bottom sheet rising | `masuk .28s` (a full-screen view entering), `naik .28s` (a bottom sheet rising), `muncul .28s` (a toast, three sheets, two attached-file boxes). The page transition of every phone board route (decided in "Screen change and page transitions") |
| `kait` | 450 ms | Match: two sides meet and link; the difference counts down to Rp0 | `dariKiri` and `dariKanan` `.45s` (web) or `.4s` (phone), then the `kait` badge `.4s` after `.35s`/`.4s`, while the difference counts down over 660 ms |
| `tinta` | 700 ms | Bukukan: ink sweeps the card, the No. Bukti is stamped, the balance counts to the new figure | `sapu .7s`, plus `cap .55s` after `.35s`, plus the balance count from 750 to 1530 ms (Main) |
| `segelTahan` | 1600 ms | Tutup buku: the button is held until full | Hold fill `width 1.6s linear`; the close fires at 1650 ms |
| `segel` | 900 ms | Tutup buku: the screen darkens, the circle closes, the lock is set | `gelap .7s`, `lingkar .9s` after `.3s`, lock `cap .5s` after `1.1s` |
| `keluar` | curve | | `cubic-bezier(.2,.8,.2,1)` everywhere it appears |

`PalakatMotion.atau(context, d)` returns `Duration.zero` when animations are disabled. Use it for every implicit animation (`AnimatedContainer`, `AnimatedScale`, `AnimatedFractionallySizedBox`, `AnimatedDefaultTextStyle`).

## The motion library (`lib/motion/`)

Five small files cover every board. They all read reduce motion from `MediaQuery.disableAnimationsOf(context)`, which the app root forces on when the panel switch is on (see "Reduce motion").

| File | Contents |
| --- | --- |
| `gerak.dart` | `ruas`, `antara`, `KubikKeluar`, `gerakMati`, `GerakBuilder`, `Gerak`, `Bingkai` |
| `kerangka.dart` | `Kerangka`: one `Bingkai` per keyframe and variant |
| `ulang.dart` | `Ulang`: repeating motion (`titik`, `denyut`, `putar`) |
| `hitung.dart` | `Hitung`: counting figures |
| `halaman.dart` | `halaman(...)`: page transitions for go_router |

The hold button belongs to the Tombol component in `lib/widgets/` (`components.md`). Its motion and timing are specified under "Tutup buku" below.

### `gerak.dart`

```dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Eased progress (0..1) of one keyframe segment [a, b] at linear time t (0..1).
/// CSS applies the timing function per segment; this reproduces it.
double ruas(double t, double a, double b, Curve kurva) =>
    kurva.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

double antara(double a, double b, double p) => a + (b - a) * p;

/// The boards' counting curve, exactly: 1 − (1 − t)³. Curves.easeOutCubic is a
/// bezier approximation and is not used.
class KubikKeluar extends Curve {
  const KubikKeluar();
  @override
  double transformInternal(double t) => 1 - math.pow(1 - t, 3).toDouble();
}

bool gerakMati(BuildContext context) => MediaQuery.disableAnimationsOf(context);

/// One keyframe: draws [child] at linear time t with the board's timing function.
typedef Bingkai = Widget Function(
    BuildContext context, double t, Curve kurva, Widget child);

/// Plays once on mount: waits [tunda], then runs t from 0 to 1 over [lama].
/// Before the delay t = 0 (fill-mode both). After the end t stays 1.
/// Under reduce motion t is 1 at once, delay skipped. If reduce motion turns
/// on mid-run, it jumps to 1.
class GerakBuilder extends StatefulWidget {
  const GerakBuilder({
    super.key,
    required this.lama,
    this.tunda = Duration.zero,
    required this.builder,
  });
  final Duration lama, tunda;
  final Widget Function(BuildContext context, double t) builder;
  @override
  State<GerakBuilder> createState() => _GerakBuilderState();
}

class _GerakBuilderState extends State<GerakBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.lama);
  Timer? _tunda;
  bool _mulai = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (gerakMati(context)) {
      _tunda?.cancel();
      _c.value = 1;
      return;
    }
    if (_mulai) return;
    _mulai = true;
    if (widget.tunda == Duration.zero) {
      _c.forward();
    } else {
      _tunda = Timer(widget.tunda, () => _c.forward());
    }
  }

  @override
  void dispose() {
    _tunda?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _c, builder: (ctx, _) => widget.builder(ctx, _c.value));
}

/// A keyframe played once on mount. Give it a key naming the state that shows it.
class Gerak extends StatelessWidget {
  const Gerak(
    this.kerangka, {
    super.key,
    required this.lama,
    this.tunda = Duration.zero,
    this.kurva = Curves.ease,
    required this.child,
  });
  final Bingkai kerangka;
  final Duration lama, tunda;
  final Curve kurva;
  final Widget child;

  @override
  Widget build(BuildContext context) => GerakBuilder(
      lama: lama,
      tunda: tunda,
      builder: (ctx, t) => kerangka(ctx, t, kurva, child));
}
```

Usage, copying the board's declaration term by term:

```dart
// animation: muncul .3s .5s both
Gerak(Kerangka.muncul,
    key: const ValueKey('saldo-posted'),
    lama: const Duration(milliseconds: 300),
    tunda: const Duration(milliseconds: 500),
    child: kartuSaldo);

// animation: masuk .28s cubic-bezier(.2,.8,.2,1)
Gerak(Kerangka.masuk,
    key: const ValueKey('form'),
    lama: PalakatMotion.pindahLayar,
    kurva: PalakatMotion.keluar,
    child: form);
```

### `kerangka.dart`

Each keyframe, its exact CSS, and its `Bingkai`, are in "Keyframes" below. `Kerangka` is an `abstract final class` of static `Bingkai` values and of small factories for the variants that take a distance or a colour (`dariKiri(40)`, `gelap(dari: …)`).

### `ulang.dart`

```dart
/// Repeating motion. t is the position in the current cycle (0..1), or null
/// before the delay and under reduce motion; null means "draw the plain style".
class Ulang extends StatefulWidget {
  const Ulang({
    super.key,
    required this.periode,
    this.tunda = Duration.zero,
    required this.builder,
  });
  final Duration periode, tunda;
  final Widget Function(BuildContext context, double? t) builder;
  @override
  State<Ulang> createState() => _UlangState();
}

class _UlangState extends State<Ulang> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.periode);
  Timer? _tunda;
  bool _jalan = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tunda?.cancel();
    if (gerakMati(context)) {
      _c.stop();
      _jalan = false;
      return;
    }
    if (_jalan) return;
    _tunda = Timer(widget.tunda, () {
      if (!mounted) return;
      setState(() => _jalan = true);
      _c.repeat();
    });
  }

  @override
  void dispose() {
    _tunda?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _c,
      builder: (ctx, _) => widget.builder(ctx, _jalan ? _c.value : null));
}
```

Elements that pulse together (the skeleton blocks of `Memuat`) all start at the same mount, so separate `Ulang`s stay in step. One shared controller per screen is equally correct.

### `hitung.dart`

See "Counting figures".

### `halaman.dart`

See "Screen change and page transitions".

## Keyframes

Each entry gives the exact CSS from the boards, every variant in use, what it means, where and when it plays, and the Flutter `Bingkai`. "Declared, unused" variants are listed for completeness and are not built. The boards and conditions for each single use are in the appendix.

### `muncul`: something new appears in place

```css
@keyframes muncul{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}
```

Declared on 188 boards, used on 80. It is the standard entrance of a block that appears because state changed: a result, a status line, an AI suggestion card, a form that opens in place, a web side panel, a "ready" button.

| Variant | Easing | Where |
| --- | --- | --- |
| `.3s` | `ease` | The default: 71 boards. Status lines after an action, AI cards (`tAda`, `aiAda`, `nAda`), sign-in steps (`Masuk`, `WebMasuk`, `Pemulihan`, `WebPemulihan`), web side panels (`WebDraf`, `WebKeluar`, `WebKasus`, `WebPilihBulan`), new list rows (`Kewajiban` and `WebKasus` entries, `LihatTransaksi`, `WebUnggah` files), ready buttons ("Unduh PDF", "Unduh Excel", "Pastikan rekonsiliasi") |
| `.28s` | `ease` | Main and HitungKas attached-file box; the bottom sheets of Draf, Keluar and PilihBulan |
| `.28s cubic-bezier(.2,.8,.2,1)` | `keluar` | Main toast "Draf tersimpan · belum masuk saldo" |
| `.2s` | `ease` | Main alert "Gagal disimpan. Isian Anda masih ada di layar ini." |
| `.4s both` | `ease` | The No. Bukti chip or posted card where Bukukan has no sweep: AlihPeruntukan (phone), WebAlihPeruntukan, TabCatat, WebCatat, WebPemeriksa, WebPersembahan; KasusBaru and WebKasusBaru (`adaNo`); Memuat and WebMemuat (`isBuku`) |
| `.3s` after `.15s`, `.35s`, `.5s`, both | `ease` | HitungKas comparison rows |
| `.3s` after `.5s` both | `ease` | Main booked balance card; Persembahan first result row |
| `.3s` after `.6s` both | `ease` | Awal result list under the OPN card |
| `.3s` after `.7s`, `.9s` both | `ease` | Persembahan second and third result rows |
| `.3s` after `.8s` both | `ease` | Main posted footer; WebAwal "Mulai mencatat" |
| `.3s` after index × 90 ms, both | `ease` | Main Periksa check rows, cascading |
| `.4s` after `.2s`, `.6s`, `1s` both | `ease` | WebKoreksi result cards and "Pengaruh" row |
| `.4s` after `1.4s`, `1.7s` both | `ease` | Koreksi result; TutupBuku and WebTutupBuku Ditutup text and files card |
| `.4s` after `1.9s` both | `ease` | TutupBuku Ditutup caption and "Kembali ke Bulan" |

```dart
static Widget muncul(BuildContext c, double t, Curve k, Widget w) {
  final p = k.transform(t);
  return Opacity(
      opacity: p,
      child: Transform.translate(offset: Offset(0, 8 * (1 - p)), child: w));
}
```

### `masuk`: a full-screen view enters (`pindahLayar`)

```css
@keyframes masuk{from{opacity:0;transform:translateX(24px)}to{opacity:1;transform:none}}
```

One variant: `.28s cubic-bezier(.2,.8,.2,1)`. Used on 14 phone boards on the root of a full-screen view that a drill-in opens inside the board: Awal, Bendahara, Dokumen, HitungKas, Kejadian, Kewajiban, Koreksi, Lainnya, Laporan, Main, MataAnggaran, Persembahan, Terbatas, TutupBuku. Web boards never use it. It is also the page transition of every phone board route (see "Screen change and page transitions").

```dart
static Widget masuk(BuildContext c, double t, Curve k, Widget w) {
  final p = k.transform(t);
  return Opacity(
      opacity: p,
      child: Transform.translate(offset: Offset(24 * (1 - p), 0), child: w));
}
```

`lama: PalakatMotion.pindahLayar`, `kurva: PalakatMotion.keluar`.

### `naik`: a bottom sheet rises (`pindahLayar`)

```css
@keyframes naik{from{transform:translateY(100%)}to{transform:none}}
```

One variant: `.28s cubic-bezier(.2,.8,.2,1)`. No fade. The distance is the sheet's own height. Used on the bottom sheets of Bagi, Kewajiban, Koreksi, Lainnya, Main, MataAnggaran and Pemeriksa, and on Main's full-screen "Pilih Mata Anggaran" view (`isMa`), which rises instead of sliding in.

```dart
static Widget naik(BuildContext c, double t, Curve k, Widget w) =>
    FractionalTranslation(translation: Offset(0, 1 - k.transform(t)), child: w);
```

### `pudar`: fade in

```css
@keyframes pudar{from{opacity:0}to{opacity:1}}
```

| Variant | Easing | Where |
| --- | --- | --- |
| `.2s` | `ease` | Root views shown by a tab or a hub (Main Transaksi, TutupBuku Bulan, Kewajiban list, Laporan list, Terbatas list, Lainnya hub, Bendahara main, HitungKas count, Koreksi detail and result, Awal steps, MataAnggaran versions, Persembahan form, the Bukti gap block); the scrim of every phone sheet; TutupBuku "Sedang menutup buku…" and the failure view |
| `.25s` | `ease` | Keluar "Anda sudah keluar"; Sambungan session-ended view |
| `.3s` after `.5s` both | `ease` | The white check mark inside the success disc (Awal "Wewenang Bendahara aktif", HitungKas "Hitung kas tersimpan") |

```dart
static Widget pudar(BuildContext c, double t, Curve k, Widget w) =>
    Opacity(opacity: k.transform(t), child: w);
```

### `cap`: a stamp is pressed

Three variants. Keep them apart.

**A, rotated (the No. Bukti stamp).** Awal, Main, Pemeriksa, Persembahan, TabTransaksi, WebAwal, WebTransaksi.

```css
@keyframes cap{0%{opacity:0;transform:scale(1.7) rotate(-9deg)}55%{opacity:1;transform:scale(.94) rotate(-3deg)}100%{opacity:1;transform:scale(1) rotate(-3deg)}}
```

Used as `cap .55s cubic-bezier(.2,.8,.2,1) .35s both` on the mono "No. Bukti …" label (2 px `laut` border, radius 8, padding 4 10, 14 px 600 `laut`) when the card becomes Dibukukan. Part of `tinta`. The stamp stays tilted −3°.

**B, scale only from 1.7.** Used once: Koreksi, `cap .5s .2s both` (`ease`) on the "Dibalik" badge of the original transaction on the result view. Declared, unused, in Bendahara and MataAnggaran.

```css
@keyframes cap{0%{opacity:0;transform:scale(1.7)}55%{opacity:1;transform:scale(.94)}100%{opacity:1;transform:scale(1)}}
```

**C, scale only from 1.8 (the lock).** TutupBuku and WebTutupBuku. Identical to the Gerak preview's `segel` keyframe.

```css
@keyframes cap{0%{opacity:0;transform:scale(1.8)}60%{opacity:1;transform:scale(.92)}100%{opacity:1;transform:scale(1)}}
```

Used as `cap .5s 1.1s cubic-bezier(.2,.8,.2,1) both` on the lock group (body and shackle) in the Ditutup sequence (part of `segel`), and as `cap .5s cubic-bezier(.2,.8,.2,1)` on TutupBuku's dark "Oktober 2026 · Sudah ditutup" card on the Bulan view once the month is closed.

```dart
static Bingkai _cap(double dari, double henti, double akhir,
        {double putarDari = 0, double putar = 0}) =>
    (c, t, k, w) {
      final a = ruas(t, 0, henti, k), b = ruas(t, henti, 1, k);
      final skala = t < henti ? antara(dari, akhir, a) : antara(akhir, 1, b);
      final derajat = t < henti ? antara(putarDari, putar, a) : putar;
      return Opacity(
        opacity: t < henti ? a : 1,
        child: Transform.rotate(
          angle: derajat * math.pi / 180,
          child: Transform.scale(scale: skala, child: w),
        ),
      );
    };
static final Bingkai cap = _cap(1.7, .55, .94, putarDari: -9, putar: -3); // A
static final Bingkai capTegak = _cap(1.7, .55, .94);                       // B
static final Bingkai capSegel = _cap(1.8, .60, .92);                       // C
```

Rotation and uniform scale commute, so the order of the two transforms does not matter. Origin: centre (for the lock, the centre of the 104 × 104 box).

### `sapu`: ink sweeps the card (`tinta`)

```css
@keyframes sapu{0%{transform:scaleX(0);opacity:.2}65%{transform:scaleX(1);opacity:.2}100%{transform:scaleX(1);opacity:0}}
```

One variant: `.7s ease-out both`, on an overlay that fills the card (`position: absolute; inset: 0`), `laut`, `transform-origin: left`, ignoring the pointer, inside a card that clips (`overflow: hidden`, radius 16). From 0 to 455 ms a 20 % `laut` layer grows from the left edge to full width; from 455 to 700 ms it fades to nothing.

Where: the booked card on Main (Periksa), Awal and WebAwal (OPN-2026-0001), Persembahan (BKU-2026-0148), Pemeriksa (BKU-2026-0151), TabTransaksi and WebTransaksi (detail card of a row just booked). Always together with `cap` A. Also on the "Versi 2026.2" card when it is published, on MataAnggaran and WebMataAnggaran, without a stamp.

```dart
// Child: ColoredBox(color: context.warna.laut). Place as the last child of a
// Stack that is clipped with the card's radius, wrapped in IgnorePointer + Positioned.fill.
static Widget sapu(BuildContext c, double t, Curve k, Widget w) {
  final lebar = ruas(t, 0, .65, k);
  final opasitas = t < .65 ? .2 : antara(.2, 0, ruas(t, .65, 1, k));
  return Opacity(
    opacity: opasitas,
    child: Transform(
        alignment: Alignment.centerLeft,
        transform: Matrix4.diagonal3Values(lebar, 1, 1),
        child: w),
  );
}
```

`lama: PalakatMotion.tinta`, `kurva: Curves.easeOut`.

### `isi`: progress fills

```css
@keyframes isi{from{width:0}to{width:100%}}
```

Always `linear both`, on a `laut` fill (height 100 %) inside a `garis` track that clips.

| Board | Duration | Track | Wait it shows |
| --- | --- | --- | --- |
| Main | 1.2 s | 4 px, radius 2, margin top 8 | "Sedang diunggah…" (Lampirkan dokumen pendukung); state flips at 1300 ms |
| Kamera | 1.5 s | 6 px, radius 3 | "Sedang diunggah…"; flips at 1500 ms |
| WebUnggah | 1.5 s per file | 6 px, radius 3, margin top 6 | "Sedang diunggah…"; flips at 1500 ms |
| Sambungan, WebSambungan | 1.6 s | 6 px, radius 3 | "Mencoba menyimpan lagi…"; flips at 1600 ms |
| Ekspor, WebEkspor | 1.1 / 1.5 / 2.4 / 1.9 / 2.6 s (Buku, Versi, Dokumen pendukung, Laporan, Daftar isi) | 4 px, radius 2, margin top 8 | "Sedang disiapkan"; all flip together at 2800 ms |

The bar reaching the end is not success. It stays full, and the status text keeps saying it is in progress, until the timer flips the state. Declared on 168 boards, used on 7.

```dart
static Widget isi(BuildContext c, double t, Curve k, Widget w) =>
    FractionallySizedBox(
        alignment: Alignment.centerLeft, widthFactor: k.transform(t), child: w);
```

`kurva: Curves.linear`, child `ColoredBox(color: context.warna.laut)`, inside `ClipRRect` + `SizedBox(height: 4 or 6)` + `ColoredBox(context.warna.garis)`.

### `titik`: AI is thinking

```css
@keyframes titik{0%,100%{opacity:.25}50%{opacity:1}}
```

Three dots, 6 × 6, round, `laut`, 4 apart, after the words "Menyusun usulan" (14 px 600 `lautTua`, `role="status"`): `titik 1s infinite`, `titik 1s .2s infinite`, `titik 1s .4s infinite`, CSS `ease`. Only on BantuanAI and WebBantuanAI, while `tProses` (1300 ms after "Buat usulan dari kalimat ini"). Declared on 76 boards. The other AI waits ("Membaca foto…", "Menyusun penjelasan…") are static text: keep them static.

The delays have no `both`. Dot 2 is fully opaque for its first 200 ms and dot 3 for its first 400 ms, and then each starts at .25.

```dart
Widget titik(int i) => Ulang(
      periode: const Duration(seconds: 1),
      tunda: Duration(milliseconds: 200 * i),
      builder: (c, t) {
        final o = t == null
            ? 1.0
            : t < .5
                ? antara(.25, 1, ruas(t, 0, .5, Curves.ease))
                : antara(1, .25, ruas(t, .5, 1, Curves.ease));
        return Opacity(opacity: o, child: titikBulat); // 6 × 6, laut, circle
      },
    );
```

### `gelap`: the screen darkens (`segel`)

```css
/* TutupBuku (phone) */  @keyframes gelap{from{background:#F3F5F1}to{background:#13201C}}
/* WebTutupBuku */       @keyframes gelap{from{background:#FFFFFF}to{background:#13201C}}
```

Phone: `kertas` → `tinta` on the full-screen Ditutup view. Web: `permukaan` → `tinta` on the Ditutup panel (radius 18). `.7s ease-out both`. The text colour is `permukaan` throughout; the text is hidden by its own delays until the background is dark. The Gerak preview also animates text colour; the boards do not.

```dart
static Bingkai gelap(Color Function(PalakatWarna w) dari) => (c, t, k, w) =>
    ColoredBox(
        color: Color.lerp(dari(c.warna), c.warna.tinta, k.transform(t))!,
        child: w);
// Phone: Kerangka.gelap((w) => w.kertas). Web: Kerangka.gelap((w) => w.permukaan).
```

On the web panel, clip the `ColoredBox` with radius 18.

### `lingkar`: a circle closes

```css
/* Awal, HitungKas (r 38) */          @keyframes lingkar{from{stroke-dashoffset:239}to{stroke-dashoffset:0}}
/* TutupBuku, WebTutupBuku (r 46) */  @keyframes lingkar{from{stroke-dashoffset:290}to{stroke-dashoffset:0}}
```

The dash array equals the circumference (2π·38 ≈ 239, 2π·46 ≈ 290), and the circle is rotated −90°. So the stroke is drawn clockwise from 12 o'clock until the ring is closed. Butt line ends.

| Board | Use | Ring |
| --- | --- | --- |
| TutupBuku, WebTutupBuku | `lingkar .9s .3s ease-out both`, part of `segel` | 104 × 104 box, r 46, stroke 3 `permukaan`, no fill |
| Awal (wewenang aktif), HitungKas (tersimpan) | `lingkar .7s ease-out both`, success disc | 88 box (HitungKas draws it at 56), r 38, fill `laut` shown at once, stroke 3 `laut` traced. Because fill and stroke are the same colour, only the outer 1.5 px edge visibly grows. Then the check mark (`M29 45l10 10 20-21`, stroke 5 `permukaan`, round) fades in with `pudar .3s .5s both` |

```dart
class Cincin extends CustomPainter {
  Cincin(this.p, {required this.r, required this.tebal, required this.garis, this.isi});
  final double p, r, tebal; // p: eased progress 0..1
  final Color garis;
  final Color? isi;
  @override
  void paint(Canvas canvas, Size size) {
    final pusat = size.center(Offset.zero);
    if (isi != null) canvas.drawCircle(pusat, r, Paint()..color = isi!);
    canvas.drawArc(Rect.fromCircle(center: pusat, radius: r), -math.pi / 2,
        2 * math.pi * p, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = tebal
          ..strokeCap = StrokeCap.butt
          ..color = garis);
  }
  @override
  bool shouldRepaint(Cincin o) => o.p != p || o.garis != garis || o.isi != isi;
}
// GerakBuilder(lama: PalakatMotion.segel, tunda: 300ms,
//   builder: (c, t) => CustomPaint(size: Size.square(104),
//     painter: Cincin(Curves.easeOut.transform(t), r: 46, tebal: 3, garis: c.warna.permukaan)))
```

Scale the viewBox: HitungKas draws the 88-unit disc at 56 px, so multiply r and stroke by 56/88.

### `putar`: waiting turns

```css
@keyframes putar{to{transform:rotate(360deg)}}
```

| Variant | Where | What turns |
| --- | --- | --- |
| `1s linear infinite` | TutupBuku (56 px), WebTutupBuku (52 px), while "Sedang menutup buku…" (1500 ms) | Spinner: a full `garis` ring (r 24, stroke 4) and a `tinta` quarter arc `M28 4a24 24 0 0 1 24 24` (stroke 4, round), in a 56 viewBox |
| `6s linear infinite` | Awal (88 px) and Bendahara (34 px), while waiting for verification (2800 ms) | Dashed ring: Awal r 38 stroke 3 `tinta` dash `5 6`; Bendahara r 38 stroke 6 `tinta` dash `9 10` (88 viewBox) |

```dart
Ulang(
  periode: const Duration(seconds: 1), // or 6
  builder: (c, t) =>
      Transform.rotate(angle: 2 * math.pi * (t ?? 0), child: spinner),
);
```

Under reduce motion it stands at 0°.

### `kait`: the link is set (`kait`)

```css
@keyframes kait{0%{opacity:0;transform:scale(0)}70%{opacity:1;transform:scale(1.25)}100%{opacity:1;transform:scale(1)}}
```

On a round `laut` badge with a white chain-link icon (`M9 15l6-6M10 6l1-1a5 5 0 0 1 7 7l-1 1M14 18l-1 1a5 5 0 0 1-7-7l1-1`, stroke `permukaan` 2.6, round), centred between the two matched cards. CSS `ease` (no timing function given).

| Board | Use | Badge |
| --- | --- | --- |
| TutupBuku (rekonsiliasi) | `kait .4s .35s both` | 32 px, icon 16 |
| WebRekonsiliasi | `kait .4s .4s both` | 30 px, icon 16 |

```dart
static Widget kait(BuildContext c, double t, Curve k, Widget w) {
  final a = ruas(t, 0, .7, k), b = ruas(t, .7, 1, k);
  return Opacity(
      opacity: t < .7 ? a : 1,
      child: Transform.scale(
          scale: t < .7 ? antara(0, 1.25, a) : antara(1.25, 1, b), child: w));
}
```

### `dariKiri` and `dariKanan`: the two sides meet (`kait`)

```css
/* TutupBuku */        @keyframes dariKiri{from{opacity:0;transform:translateX(-40px)}to{opacity:1;transform:none}}
/* TutupBuku */        @keyframes dariKanan{from{opacity:0;transform:translateX(40px)}to{opacity:1;transform:none}}
/* WebRekonsiliasi */  @keyframes dariKiri{from{opacity:0;transform:translateX(-60px)}to{opacity:1;transform:none}}
/* WebRekonsiliasi */  @keyframes dariKanan{from{opacity:0;transform:translateX(60px)}to{opacity:1;transform:none}}
```

The bank-statement card ("Mutasi bank") comes from the left and the transaction card ("Transaksi · …") from the right. Both cards have a 1.5 `laut` line. TutupBuku: `.4s cubic-bezier(.2,.8,.2,1) both`, 40 px. WebRekonsiliasi: `.45s cubic-bezier(.2,.8,.2,1) both` (= `PalakatMotion.kait`), 60 px.

```dart
static Bingkai dariKiri(double jarak) => (c, t, k, w) {
      final p = k.transform(t);
      return Opacity(
          opacity: p,
          child: Transform.translate(offset: Offset(-jarak * (1 - p), 0), child: w));
    };
static Bingkai dariKanan(double jarak) => (c, t, k, w) {
      final p = k.transform(t);
      return Opacity(
          opacity: p,
          child: Transform.translate(offset: Offset(jarak * (1 - p), 0), child: w));
    };
```

### `balik`: the reversal flips down

```css
@keyframes balik{from{opacity:0;transform:perspective(700px) rotateX(-90deg)}to{opacity:1;transform:perspective(700px) rotateX(0)}}
```

Koreksi only: `balik .5s .7s cubic-bezier(.2,.8,.2,1) both` on the "BKU-2026-0144 · Dibukukan · Pembalikan" card, `transform-origin: top`. It swings down like a flap hinged on its top edge, under the original transaction. Part of the Koreksi chain (RangkaianKoreksi).

```dart
static Widget balik(BuildContext c, double t, Curve k, Widget w) {
  final p = k.transform(t);
  return Opacity(
    opacity: p,
    child: Transform(
      alignment: Alignment.topCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 1 / 700)
        ..rotateX(antara(-math.pi / 2, 0, p)),
      child: w,
    ),
  );
}
```

`Matrix4.rotateX` uses the same sign as CSS `rotateX`. Check by eye that at t = .5 the card's bottom edge is nearer the viewer than its top edge, as in the browser.

### `tali`: the connecting line grows

```css
/* Koreksi */    @keyframes tali{from{height:0}to{height:18px}}
/* Bendahara */  @keyframes tali{from{height:0}to{height:22px}}   (declared, unused)
```

Koreksi: a 2 px `tinta` vertical line, margin left 28, between the cards of the correction chain. `tali .25s .5s both` (first line) and `tali .25s 1.2s both` (second line, only with a correction transaction), CSS `ease`. The cards below move down by 18 px as each line grows; they already take their space while hidden.

```dart
static Bingkai tali(double tinggi) => (c, t, k, w) =>
    SizedBox(width: 2, height: tinggi * k.transform(t), child: w);
// child: ColoredBox(color: context.warna.tinta), inside Padding(left: 28)
```

### `denyut`: loading pulse

```css
/* Memuat, WebMemuat */  @keyframes denyut{0%,100%{opacity:1}50%{opacity:.45}}
/* HitungKas */          @keyframes denyut{0%{transform:scale(1)}40%{transform:scale(1.04)}100%{transform:scale(1)}}   (declared, unused)
```

Memuat and WebMemuat, Rangka state "Sedang memuat": every skeleton block (`garis`, radius 8, the widths and heights in the appendix) runs `denyut 1.4s ease-in-out infinite`, all in step. KeadaanUmum and WebKeadaanUmum draw their "Memuat" skeleton without motion: keep it still there.

```dart
Ulang(
  periode: const Duration(milliseconds: 1400),
  builder: (c, t) {
    final o = t == null
        ? 1.0
        : t < .5
            ? antara(1, .45, ruas(t, 0, .5, Curves.easeInOut))
            : antara(.45, 1, ruas(t, .5, 1, Curves.easeInOut));
    return Opacity(opacity: o, child: balok);
  },
);
```

### `turun`: suggested values drop into the fields

```css
@keyframes turun{from{opacity:0;transform:translateY(-14px)}to{opacity:1;transform:none}}
```

BantuanAI only. After "Pakai usulan", each field row that now has a value (Kas/Bank, Dibayar kepada, Tanggal transaksi, Mata Anggaran: rows 0 to 3) plays `turun .4s {index × 70}ms both` (CSS `ease`): delays 0, 70, 140, 210 ms. Empty rows do not move. WebBantuanAI writes the same `turun …` value but does not declare the keyframe, so on that board the fields fill without motion. Follow the board: no motion on WebBantuanAI. The fields mount with a key on `dipakai`, so the motion plays once when "Pakai usulan" is pressed.

```dart
static Widget turun(BuildContext c, double t, Curve k, Widget w) {
  final p = k.transform(t);
  return Opacity(
      opacity: p,
      child: Transform.translate(offset: Offset(0, -14 * (1 - p)), child: w));
}
```

### `kilat`: the camera flash

```css
@keyframes kilat{from{opacity:.9}to{opacity:0}}
```

Kamera only: `kilat .35s ease-out both` on a full-screen `permukaan` overlay that ignores the pointer, when the review view ("Terbaca dengan jelas?") mounts after "Ambil foto". The receipt area of that view also enters with `muncul .3s`.

```dart
static Widget kilat(BuildContext c, double t, Curve k, Widget w) =>
    IgnorePointer(child: Opacity(opacity: antara(.9, 0, k.transform(t)), child: w));
```

## CSS transitions

A transition animates a value that changes on an element that stays on screen. Build each with an implicit widget whose duration goes through `PalakatMotion.atau`.

| Board | Element | Property and timing | Changes when | Flutter |
| --- | --- | --- | --- | --- |
| Lainnya, Pemberitahuan, WebPemberitahuan, WebPengaturan | Sakelar track 56 × 32, radius 16, 1.5 `tinta` line | `background .16s` (`ease`): `permukaan` ↔ `tinta` | The switch is toggled | `AnimatedContainer`, `PalakatMotion.sentuh`, `Curves.ease` |
| same | Sakelar knob 23 px, top 3 | `left .16s`: 3 ↔ 28 px. The knob colour (`tinta` ↔ `permukaan`) changes at once | same | `AnimatedPositioned`, `sentuh`, `Curves.ease`; knob colour not animated |
| TutupBuku, WebTutupBuku | Hold fill (laut) inside "Tutup buku Oktober 2026" | `width 1.6s linear` while held, `width .2s linear` on release | Pointer down / up | See "Tutup buku" |
| TutupBuku, WebRekonsiliasi | Difference figure "Selisih belum dijelaskan" (mono 24 or 32, 600) | `color .3s` (`ease`): `bata` → `laut` when the shown figure is exactly Rp0, back to `bata` otherwise | The counted figure reaches or leaves 0 | `AnimatedDefaultTextStyle`, 300 ms, `Curves.ease`, inside `Hitung` |
| WebHitungKas | Difference figure (mono 28, 600) | `color .3s`: `tinta3` before counting is entered, `laut` at Rp0, `bata` otherwise. No count: the figure changes at once | Typing the counted cash | `AnimatedDefaultTextStyle`, 300 ms |
| WebTutupBuku | "Oktober 2026" month card (2 `tinta` line, radius 16) | `background .6s, color .6s` (`ease`): `permukaan`/`tinta` → `tinta`/`permukaan`. Its subtitle and badge colours change at once | The close completes (`tahap` becomes `sudah`), at the same moment as `gelap` | `AnimatedContainer` + `AnimatedDefaultTextStyle`, 600 ms |
| Awal (`belumOpn`), Bagi, WebBagi | BatangPembagian segments | `width .45s cubic-bezier(.2,.8,.2,1)` | An amount is typed or a row changes | `AnimatedFractionallySizedBox`, 450 ms, `keluar` |
| AlihPeruntukan, WebAlihPeruntukan | Bar segments | `width .5s cubic-bezier(.2,.8,.2,1)` | Amount moved changes | `AnimatedFractionallySizedBox`, 500 ms, `keluar` |
| Kewajiban, WebKasus | Settled share of an advance (`tinta` fill in a dashed `putus` track 14 px) | `width .5s cubic-bezier(.2,.8,.2,1)` | A settlement is booked | `AnimatedFractionallySizedBox`, 500 ms, `keluar`, runs alongside the 660 ms count of "sisa" |
| KasusBaru, WebKasusBaru | Effect card (radius 16) | `background .3s`: transparent ↔ `permukaan`. Its line switches dashed `putus` ↔ solid `tinta` at once | The case becomes concrete (`padat`) | `AnimatedContainer` 300 ms for the fill; the line is drawn by GarisPainter and swaps instantly |
| Pemeriksa | Transaction card | `background .3s`: transparent (Draf) → `permukaan`. Line dashed `putus` → solid `laut` (diperiksa) → solid `tinta` (dibukukan) swaps at once | Status moves | `AnimatedContainer` 300 ms |
| Sambungan, WebSambungan | Draft card (radius 16) | `border .3s`: colour `putus` → `tinta`; dashed → solid swaps at once (border style cannot be animated) | Save succeeds ("Tersimpan") | Animate the line colour 300 ms, swap the dash pattern at once |
| LihatDokumen, WebLihatDokumen | Paper of the receipt image | `transform .25s cubic-bezier(.2,.8,.2,1)`: `scale(zoom)`, zoom 0.75 to 2 in steps of .25 | "Perbesar", "Perkecil", page change resets to 1 | `AnimatedScale`, 250 ms, `keluar`, centre |
| Kamera | Receipt paper | `transform .25s cubic-bezier(.2,.8,.2,1)` declared, but rotate(−3°) and scale(1.25) are on two different elements in two different views, so nothing animates | | Draw both states statically |

## Screen change and page transitions

Decided here, following the boards and `pindahLayar` ("Screen change").

- **Phone board routes** (390 × 844): the page enters with `masuk`, 280 ms, `keluar`, whether reached by push or go. The board files never show a change between boards, so this applies the handoff's screen-change motion.
- **Laptop, tablet, A4 and sheet routes**: no page transition. The web boards never animate a screen change.
- **Child routes** (`/<Stem>/<sub>`, a full-screen view inside a board): the page enters with the keyframe the board puts on that view's root element, with the board's duration and easing (`masuk` for most phone drill-ins, `naik` for Main's `/Main/mata-anggaran`, `pudar` 200 ms for tab views such as `/Main/transaksi` and for result views). If the root element has no animation, there is no transition. If the view's root animates as the first step of a longer sequence (TutupBuku Ditutup, whose root runs `gelap`), the route has no transition and the whole sequence lives inside the view. Sequences started by an action inside a view (Bukukan on `/Main/periksa`) are `Gerak` widgets inside that view, keyed on the new state.
- **Back and pop**: instant everywhere (`reverseTransitionDuration: Duration.zero`). The page underneath stays as it was and does not replay its entrance. On the board, going back remounts the previous view and replays its entrance. The prototype does not copy that, so that Back feels like going back.
- **Views switched by board state** (not routes): wrap the view's root in `Gerak(<keyframe>, key: ValueKey(<state>))`. Do not use a route transition for these.
- A board's root view may also have its own entrance (for example TutupBuku's Bulan view with `pudar` 200 ms). It plays inside the page transition. Both run together; do not special-case.

```dart
// lib/motion/halaman.dart
Page<void> halaman(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  Bingkai? kerangka,
  Duration lama = PalakatMotion.pindahLayar,
  Curve kurva = PalakatMotion.keluar,
}) {
  final d = PalakatMotion.atau(context, lama);
  if (kerangka == null || d == Duration.zero) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: d,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (ctx, anim, _, c) => AnimatedBuilder(
      animation: anim,
      builder: (ctx, _) => kerangka(ctx, anim.value, kurva, c),
    ),
  );
}
// gen_boards.py emits, for a phone board:
//   pageBuilder: (c, s) => halaman(c, s, const MainScreen(), kerangka: Kerangka.masuk)
// and for every other form:
//   pageBuilder: (c, s) => halaman(c, s, const WebBerandaScreen())
// Child routes pass the keyframe, duration and curve their spec names.
```

### Bottom sheet, side panel, toast

- **Phone bottom sheet** (LembarBawah): part of the screen's `Stack`, not a route and not `showModalBottomSheet`. Scrim: a full-size button (label from the board, for example "Kembali ke Beranda") in `tinta` at 45 % opacity (`context.warna.tinta.withValues(alpha: .45)`), `pudar .2s` (`ease`). Sheet: pinned to the bottom, `permukaan`, top corners 22, `naik .28s` `keluar` (`pindahLayar`). Draf, Keluar and PilihBulan raise their sheet with `muncul .28s` (`ease`) instead: give LembarBawah a `masuk` parameter, default `Kerangka.naik`. LihatDokumen's sheet has no motion. Closing removes scrim and sheet at once.
- **Web side panel** (the phone sheet's web form, an `aside` beside the content): `muncul .3s` (`ease`) on mount (WebDraf, WebKeluar, WebKasus, WebPilihBulan). Closing is instant.
- **Toast** (Main): `muncul .28s` `keluar` on mount; a 2600 ms `Timer` removes it with no exit.

## Money-status sequences

Times are from the moment of the action (t = 0). Each line is a separate `Gerak` started at the same mount, which is how the CSS runs.

### Bukukan (`tinta`)

Main, Periksa dan bukukan, "Bukukan" pressed with no unmet check. The state flips to `posted`, the title becomes "Sudah dibukukan", the check list and its footer disappear at once, and the booked card, balance card and new footer mount.

| Time (ms) | What | Motion |
| --- | --- | --- |
| 0 | Booked card shown: 1.5 `tinta` line, `permukaan`, radius 16, padding 18, clipped. Badge "Dibukukan" (`tinta` field, `permukaan` text), amount mono 30 500, summary, "Dibukukan pada 16/11/2026 10.42 · tidak dapat diubah lagi" | none on the card itself |
| 0 → 455 | 20 % `laut` ink grows from the left edge to full width over the whole card | `sapu`, `ease-out` within the segment |
| 455 → 700 | Ink fades out | `sapu`, second segment |
| 350 → 652 | "No. Bukti BKU-2026-0147" stamp lands: opacity 0 → 1, scale 1.7 → .94, rotate −9° → −3° | `cap` A, `keluar` |
| 652 → 900 | Stamp settles: scale .94 → 1, stays at −3° | `cap` A |
| 500 → 800 | Balance card "Saldo buku {Kas/Bank}" rises in, showing the old balance; under it "Sebelumnya {old balance}" | `muncul .3s .5s both` |
| 750 → 1530 | Balance counts from the old to the new figure (up for Pendapatan, down for Belanja and for the source of a Pindah) | `Hitung`, 780 ms, `KubikKeluar`, after 750 ms |
| 800 → 1100 | Footer "Lihat transaksi" / "Kembali ke Beranda" rises in | `muncul .3s .8s both` |

Beranda's figures (Saldo buku, Pendapatan, Belanja) change without motion; only the balance card on Periksa counts.

Other boards use parts of the same sequence:

| Board | What plays on Bukukan |
| --- | --- |
| Awal, WebAwal (OPN-2026-0001, Rp32.300.000) | `sapu` + `cap` A; then Awal's result list `muncul .3s .6s`, WebAwal's "Mulai mencatat" `muncul .3s .8s`. No count |
| Persembahan (BKU-2026-0148) | View enters with `masuk`; `sapu` + `cap` A; result rows `muncul .3s` at 500, 700 and 900 ms. No count |
| Pemeriksa (BKU-2026-0151) | Card background `permukaan` fades in (300 ms) as it leaves Draf; on Bukukan `sapu` + `cap` A |
| TabTransaksi, WebTransaksi | `sapu` + `cap` A on the detail card while row 0 is selected and just booked; they replay each time row 0 is selected again while booked |
| TabCatat, WebCatat, WebPersembahan, WebPemeriksa, AlihPeruntukan, WebAlihPeruntukan | The No. Bukti chip or posted card appears with `muncul .4s both`. No sweep, no stamp, no count. Keep the board |
| MataAnggaran, WebMataAnggaran (publishing "Versi 2026.2") | `sapu` only on the version card |

### Cocokkan (`kait`)

**Phone, TutupBuku Rekonsiliasi.** "Buat transaksi dari mutasi ini" on the BIAYA ADM line (`buatBiaya`), with the difference at Rp515.000 (or Rp15.000 after "Tandai dalam perjalanan").

| Time (ms) | What | Motion |
| --- | --- | --- |
| 0 | The "Cocok" heading count becomes "· 13 mutasi bank"; the matched pair mounts | |
| 0 → 400 | Card "Mutasi bank · BIAYA ADM · −Rp15.000" slides in from 40 px left and fades in | `dariKiri .4s` `keluar` |
| 0 → 400 | Card "Transaksi · Dibukukan · BKU-2026-0133 · Biaya administrasi bank · −Rp15.000" slides in from 40 px right | `dariKanan .4s` `keluar` |
| 350 → 630 | Link badge grows from nothing to 1.25 and fades in | `kait .4s .35s both`, `ease` |
| 630 → 750 | Badge settles to 1 | `kait` |
| 0 → 660 | Difference counts from the shown figure to the new target (Rp515.000 → Rp500.000, or Rp15.000 → Rp0) | `Hitung`, 660 ms, `KubikKeluar` |
| at Rp0 + 300 | Difference colour `bata` → `laut` | `color .3s` |
| 0 → 300 | "Pastikan rekonsiliasi" appears as soon as the target is Rp0 (it does not wait for the count) | `muncul .3s` |

"Tandai dalam perjalanan" and "Lepaskan" run the same count (Rp515.000 ↔ Rp15.000, or Rp500.000 ↔ Rp0), and mount or remove the "Dalam perjalanan" card and the "Setoran dalam perjalanan + Rp500.000" row with `muncul .3s`.

**Web, WebRekonsiliasi.** "Cocokkan" with selected bank lines and transactions of equal total adds a matched group: `dariKiri .45s` and `dariKanan .45s` (60 px, `keluar`), badge `kait .4s .4s both` (400 → 680 grow, 680 → 800 settle). A manual match does not change the difference. "Buat transaksi dari mutasi ini" (BIAYA ADM) and "Tandai dalam perjalanan" add their group or card and run the 660 ms count, but only when the target differs from the shown figure. Existing groups do not replay; key groups by their content.

### Tutup buku (`segelTahan`, then `segel`)

**Hold.** TutupBuku Konfirmasi and WebTutupBuku Konfirmasi. The button "Tutup buku Oktober 2026" (min height 56, radius 14) is `garis` with `tinta3` text and does nothing until the statement checkbox is ticked. The hint under it says why: "Centang pernyataan di atas untuk melanjutkan" (web ends with "."). Ticked: `tinta` field, `permukaan` text, hint "Tekan dan tahan tombol sampai penuh" (web ends with "."). The colour change is instant.

| Event | Effect |
| --- | --- |
| Pointer down (ticked) | `tahan` on: a `laut` fill grows from the left edge across the whole button, width 0 → 100 %, linear, 1600 ms (`segelTahan`). The label stays on top. A 1650 ms timer starts |
| Pointer up, cancel, or the pointer leaves the button before 1650 ms | Timer cancelled; the fill shrinks back to 0, linear, 200 ms. Nothing is closed |
| 1650 ms reached | The close starts (`tutupBuku`). The fill is full from 1600 ms |
| Keyboard activation (Enter or Space) or a screen reader's activate action, ticked | The close starts at once, with no hold. The board does this for a click with `detail === 0` |

```dart
// Inside the Tombol hold variant (lib/widgets). aktif = checkbox ticked.
Listener(
  onPointerDown: (_) {
    if (!aktif) return;
    setState(() => tahan = true);
    _t?.cancel();
    _t = Timer(const Duration(milliseconds: 1650), selesai);
  },
  onPointerUp: (_) => batal(),
  onPointerCancel: (_) => batal(),
  onPointerMove: (e) {
    if (!(Offset.zero & context.size!).contains(e.localPosition)) batal();
  },
  child: MouseRegion(
    onExit: (_) => batal(),
    child: Stack(children: [
      Positioned.fill(
        child: AnimatedFractionallySizedBox(
          duration: PalakatMotion.atau(context,
              tahan ? PalakatMotion.segelTahan : const Duration(milliseconds: 200)),
          curve: Curves.linear,
          alignment: Alignment.centerLeft,
          widthFactor: tahan ? 1 : 0,
          child: ColoredBox(color: context.warna.laut),
        ),
      ),
      Center(child: Text('Tutup buku Oktober 2026', /* 700, permukaan */)),
    ]),
  ),
);
// batal(): if (!tahan) return; _t?.cancel(); setState(() => tahan = false);
// selesai(): setState(() => tahan = false); then the board's tutupBuku().
// Keyboard and semantics: wrap in FocusableActionDetector whose ActivateIntent calls
// selesai() only when aktif, and Semantics(button: true, onTap: aktif ? selesai : null).
```

**Closing.** `tutupBuku`: the screen shows "Sedang menutup buku…" (`role="status"`, 700 17) under a spinner (`putar 1s linear infinite`). On the phone this is a full-screen `permukaan` view entering with `pudar .2s`; on the web a card (radius 18, min height 320) with no entrance. After 1500 ms: if the tweak `gagalDiCekTerakhir` is on and has not failed yet (phone only), the failure view "Tutup buku tidak terjadi: ada perubahan sejak ringkasan ini ditampilkan." enters with `pudar .2s`. Otherwise Ditutup mounts and the seal plays.

**Seal (`segel`)**, from the moment Ditutup mounts:

| Time (ms) | What | Motion |
| --- | --- | --- |
| 0 → 700 | Background darkens: phone full screen `kertas` → `tinta`; web panel `permukaan` → `tinta` | `gelap .7s ease-out` |
| 0 → 600 | Web only: the "Oktober 2026" month card above turns `tinta` with `permukaan` text, badge "Sudah ditutup" | `background .6s, color .6s` |
| 300 → 1200 | The ring (r 46, stroke 3, `permukaan`) is drawn clockwise from the top until closed | `lingkar .9s .3s ease-out` (`segel` 900 ms) |
| 1100 → 1400 | The lock (body 34 × 26, radius 5, filled `permukaan`; shackle stroke 4, round) lands: opacity 0 → 1, scale 1.8 → .92 | `cap` C, `keluar` |
| 1400 → 1600 | Lock settles to scale 1 | `cap` C |
| 1400 → 1800 | "Buku bulan Oktober 2026 sudah ditutup." with "Angka laporan resmi sudah dibekukan; file laporannya sedang disiapkan." and "Dikonfirmasi oleh Meiske L. · 16/11/2026 11.05" | `muncul .4s 1.4s both` |
| 1700 → 2100 | Files card: "Laporan resmi · PDF · Sedang disiapkan", "Laporan resmi · Excel · Sedang disiapkan" | `muncul .4s 1.7s both` |
| 1900 → 2300 | Phone: "File yang gagal dibuat cukup dibuat lagi dari angka yang sama. Tutup buku tetap berlaku." and "Kembali ke Bulan" | `muncul .4s 1.9s both` |
| 3600 | PDF "Siap diunduh" with "Unduh PDF"; Excel "File gagal dibuat" (`bata`, 700) with "Coba lagi" | the buttons `muncul .3s` |
| "Coba lagi" + 1800 | Excel "Sedang disiapkan" → "Siap diunduh" with "Unduh Excel" | `muncul .3s` |

With `jabatanKosong` on, the confirmation line names "Yanti Sumual, Operator (menjalankan jabatan kosong Bendahara Jemaat)".

Back on the phone's Bulan view, the closed October card (`tinta` field) enters with `cap .5s` `keluar` (variant C, no delay).

### Correction chain (Koreksi)

"Bukukan pembalikan dan koreksi" (or "Bukukan pembalikan") with a reason. The result view "Koreksi dibukukan" enters with `pudar .2s`.

| Time (ms) | What | Motion |
| --- | --- | --- |
| 200 → 700 | "Dibalik" badge on BKU-2026-0139 (original transaction) stamps in | `cap` B `.5s .2s both`, `ease` |
| 500 → 750 | Line 1 grows to 18 px | `tali .25s .5s both` |
| 700 → 1200 | Card BKU-2026-0144 "Pembalikan Rp750.000" flips down from its top edge | `balik .5s .7s` `keluar` |
| 1200 → 1450 | Line 2 grows (with correction only) | `tali .25s 1.2s both` |
| 1400 → 1800 | Card BKU-2026-0145 "Transaksi koreksi −Rp750.000" rises in (with correction only) | `muncul .4s 1.4s both` |
| 1700 → 2100 | "Pengaruh pada Saldo buku Kas" row and "Alasan: …" | `muncul .4s 1.7s both` |

WebKoreksi uses only `muncul .4s`: card BKU-2026-0144 at 200, BKU-2026-0145 at 600 (with correction), "Pengaruh" at 1000.

### Settling an advance (Kewajiban, WebKasus)

"Bukukan pertanggungjawaban" (or "Bukukan pengembalian", "Bukukan penyaluran", "Bukukan pembayaran") closes the sheet, appends the new entry row (`muncul .3s`, only the new row), grows the settled bar (`width .5s keluar`) and counts "sisa" down over 660 ms (`Hitung`). When the booking leaves nothing, the status "{status} · tidak ada sisa" appears at once with `muncul .3s`; it does not wait for the count.

### Verification wait (Awal, Bendahara, WebSerahTerima)

"Kirim untuk diverifikasi" starts a 2800 ms wait. Awal shows "Menunggu verifikasi wewenang" under an 88 px dashed ring turning once per 6 s. Bendahara shows "{nama} · menunggu Petugas verifikasi memeriksa surat penunjukan." beside a 34 px dashed ring; WebSerahTerima shows the same sentence with no ring. Then "Wewenang Bendahara aktif": Awal draws the success disc (`lingkar .7s`, check `pudar .3s .5s`) and "Lanjut ke saldo awal pencatatan" (`muncul .3s`); Bendahara and WebSerahTerima show "{nama} · aktif sejak 16/11/2026 · SK-BPMJ-09-2026" with `muncul .3s`.

## Counting figures

The boards count with `setInterval(…, 30)` and an exact ease-out cubic: on tick i of n, `shown = round(from + (to − from) × (1 − (1 − i/n)³))`.

| Board | Figure | From → to | Ticks × 30 ms | Delay | Restart |
| --- | --- | --- | --- | --- | --- |
| Main | Saldo buku of the booked Kas/Bank (mono 26 500) | old balance → new balance | 26 = 780 ms | 750 ms | Each time the posted view mounts |
| TutupBuku | Difference (mono 24 600) | shown figure → new target | 22 = 660 ms | none | Every change of in-transit or fee; a new change starts from the figure on screen |
| WebRekonsiliasi | Difference (mono 32 600) | same | 22 = 660 ms | none | Same, skipped when the target equals the shown figure |
| Kewajiban, WebKasus | "Sisa" of the case (mono 36 500) | remainder → remainder − amount | 22 = 660 ms | none | Each booked entry; opening a case shows its remainder at once |

```dart
// lib/motion/hitung.dart
class Hitung extends StatefulWidget {
  const Hitung({
    super.key,
    required this.nilai,
    this.dari,
    this.lama = const Duration(milliseconds: 660),
    this.tunda = Duration.zero,
    required this.builder,
  });
  final int nilai;  // target
  final int? dari;  // start figure on first mount; null = show nilai at once
  final Duration lama, tunda;
  final Widget Function(BuildContext context, int tampil) builder;
  @override
  State<Hitung> createState() => _HitungState();
}

class _HitungState extends State<Hitung> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.lama);
  late double _awal = (widget.dari ?? widget.nilai).toDouble();
  late double _akhir = widget.nilai.toDouble();
  Timer? _tunda;

  int get _tampil =>
      antara(_awal, _akhir, const KubikKeluar().transform(_c.value)).round();

  @override
  void initState() {
    super.initState();
    if (_awal != _akhir) {
      _tunda = Timer(widget.tunda, () {
        if (mounted) _c.forward(from: 0);
      });
    }
  }

  @override
  void didUpdateWidget(Hitung oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nilai == oldWidget.nilai) return;
    _tunda?.cancel();
    _awal = _tampil.toDouble(); // continue from the figure on screen
    _akhir = widget.nilai.toDouble();
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _tunda?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        value: rp(widget.nilai), // assistive tech hears only the final figure
        child: ExcludeSemantics(
          child: gerakMati(context)
              ? widget.builder(context, widget.nilai)
              : AnimatedBuilder(
                  animation: _c,
                  builder: (ctx, _) => widget.builder(ctx, _tampil)),
        ),
      );
}
```

- Format every frame with `rp()` (`−Rp15.000`, dot thousands, U+2212). The figure is mono, so its width barely moves.
- Main: `Hitung(dari: saldoLama, nilai: saldoBaru, lama: 780 ms, tunda: 750 ms, …)`, keyed on `posted`. Before 750 ms it shows the old balance.
- TutupBuku and WebRekonsiliasi: `Hitung(nilai: target, …)` whose builder picks the colour from the shown figure (`tampil == 0 ? laut : bata`) through `AnimatedDefaultTextStyle` (300 ms, `ease`). The colour turns `laut` only when the shown figure reaches Rp0, at the very end of the count.
- Under reduce motion the final figure shows at once.

## Waiting and progress

Rules from the handoff, which the boards follow: upload, save and report generation always look in progress, and success is never shown before it has really happened. A bar that is full is not a success. The success text or element mounts only when the timer fires. A failure path (tweak) shows failure, never success.

Every timer becomes a cancellable `Timer` (a `Future.delayed` that can be cancelled) with the same milliseconds. Starting it again cancels the previous one (as `clearTimeout` does), and `dispose` cancels it. Timers keep their duration under reduce motion: they fake work, they are not motion.

| Board | Action (button) | While waiting | ms | Then |
| --- | --- | --- | --- | --- |
| Main | "Lampirkan dokumen pendukung" | "Sedang diunggah…" + `isi 1.2s` | 1300 | "nota-16-11.jpg · Terlampir" / "Diunggah, belum diverifikasi" (`muncul .28s`) |
| Main | "Coba lagi" after "Gagal disimpan" | "Mencoba menyimpan lagi…" | 1100 | "Tersimpan" |
| Main | "Simpan sebagai draf" | toast "Draf tersimpan · belum masuk saldo" | 2600 | toast removed |
| Main | "Bukukan" | | 750, then 26 × 30 | balance count (see Bukukan) |
| Kamera | "Pakai foto ini", "Coba lagi" | "Sedang diunggah…" + `isi 1.5s` | 1500 | "Gagal diunggah" the first time when `gagalUnggah` is on, else "Dokumen pendukung · {n} file terlampir" (`muncul .3s`) |
| WebUnggah | "Pilih file" (one file per press, up to 3), "Coba lagi" | "Sedang diunggah…" + `isi 1.5s` per file | 1500 each | "Gagal diunggah · belum terlampir" once when `gagalUnggah` is on, else "Terlampir"; "Lanjut ke verifikasi" `muncul .3s` |
| Sambungan, WebSambungan | "Coba lagi" | "Mencoba menyimpan lagi…" + `isi 1.6s` | 1600 | `sambunganKembali` on: "Tersambung lagi. Draf tersimpan." (`muncul .3s`); off: back to "Masih belum tersambung · percobaan ke-{n}" |
| Ekspor, WebEkspor | "Buat ekspor" | five rows "Sedang disiapkan" with their own `isi` | 2800 | "Ekspor belum lengkap" (`muncul .3s`); Dokumen pendukung "211 dari 214 file disertakan" |
| AIFoto, WebAIFoto | "Buat usulan dari foto ini" | "Membaca foto…" (static) | 1400 | "Usulan AI · dari foto" card (`muncul .3s`) |
| BantuanAI, WebBantuanAI | "Buat usulan dari kalimat ini" | "Menyusun usulan" + three `titik` dots | 1300 | "Usulan AI" card (`muncul .3s`) |
| Cari, WebCari | "Jelaskan hasil ini" | "Menyusun penjelasan…" (static) | 1300 | "Usulan AI · penjelasan" card (`muncul .3s`) |
| Memuat, WebMemuat | "Coba lagi" | skeleton with `denyut` | 1400 | balances (`muncul .3s`) |
| Awal, Bendahara, WebSerahTerima | "Kirim untuk diverifikasi" | waiting status (+ dashed ring on Awal, Bendahara; see Verification wait) | 2800 | "Wewenang Bendahara aktif" (see Verification wait) |
| TutupBuku, WebTutupBuku | hold "Tutup buku Oktober 2026" | hold fill | 1650 | close starts |
| TutupBuku, WebTutupBuku | (close) | "Sedang menutup buku…" + spinner | 1500 | Ditutup (or the failure view, phone tweak) |
| TutupBuku, WebTutupBuku | (Ditutup) | PDF and Excel "Sedang disiapkan" | 3600 | PDF ready, Excel failed |
| TutupBuku, WebTutupBuku | "Coba lagi" (Excel) | "Sedang disiapkan" | 1800 | Excel ready |
| TutupBuku, WebRekonsiliasi, Kewajiban, WebKasus | (see Counting figures) | | 22 × 30 | count ends |

No other board has a timer. Boards that show an upload or a load as a still state (TerbitDokumen's 62 % bar, KeadaanUmum's "Memuat" skeleton) stay still.

## Reduce motion

**Sources.** The system setting arrives as `MediaQuery.disableAnimations` (iOS Reduce Motion, Android "Remove animations", and on web what the engine reports). The Keadaan panel has a global switch "Kurangi gerak" (`PrototypeState.kurangiGerak`, default off) that forces it on. One override at the app root makes both look the same to every widget:

```dart
// main.dart, MaterialApp.router(builder: …): above the Router, so page builders see it too.
builder: (context, child) => ListenableBuilder(
  listenable: prototypeState,
  builder: (context, _) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
          disableAnimations: mq.disableAnimations || prototypeState.kurangiGerak),
      child: child!,
    );
  },
),
```

Turning the switch on while something runs jumps it to its end. Turning it off affects motion that starts afterwards.

**What each motion does then.** It completes at once, delays included (the boards' CSS keeps delays; `CONVENTIONS.md` says complete instantly, and that wins).

| Motion | Under reduce motion |
| --- | --- |
| `muncul`, `masuk`, `naik`, `pudar`, `turun`, `dariKiri`, `dariKanan`, `kait`, `tali`, `balik` | Shown in the end state at once |
| `cap` | End state at once; variant A still tilted −3° |
| `sapu` | Nothing visible (its end state is transparent) |
| `kilat` | Nothing visible |
| `gelap` | `tinta` at once |
| `lingkar` | Ring closed at once; the check mark shown at once |
| `isi` | Bar full at once; the status text keeps saying in progress until the timer fires |
| `titik` | Three dots at full opacity, still |
| `denyut` | Skeleton blocks at full opacity, still |
| `putar` | Spinner and dashed ring still at 0° |
| Counting (`Hitung`) | Final figure at once |
| Transitions (Sakelar, bars, colours, zoom, month card) | Change at once (`PalakatMotion.atau` gives zero) |
| Hold button | The fill jumps to full on press and to empty on release; the 1650 ms hold itself stays |
| Page transitions | None (`halaman` returns `NoTransitionPage`) |
| Timers | Unchanged |

## Gallery and tests

- `/_komponen` shows a Gerak card that copies `design-system/components/Gerak/preview.html`: four demos (Tinta · 700 ms; Kait · 450 ms; Segel · tahan 1600 ms, lalu 900 ms; Tunggu · selama prosesnya) with the preview's text, and "Putar ulang", which removes the demos and mounts them again 80 ms later (new keys) so every motion replays. The preview's demos differ slightly from the boards; copy the preview here: Kait uses `dariKiri`/`dariKanan` 40 px at `.45s` and `kait .4s .4s` on a 26 px dot; Segel's ring is r 28 (dash 176) in a 72 box with a 22 × 17 lock (radius 3, shackle stroke 3), and its `gelap` also turns the text colour from `tinta` to `permukaan`; Tunggu fills a 4 px bar with `isi 1.2s` under "Sedang diunggah…".
- `test/motion_test.dart`:
  1. Each `PalakatMotion` duration equals the token (160, 280, 450, 700, 1600, 900 ms) and `keluar` is `Cubic(0.2, 0.8, 0.2, 1)`.
  2. `Gerak` shows the 0 % frame during its delay and the 100 % frame after `lama + tunda`; `cap` ends with rotation −3°; `sapu` ends transparent.
  3. With `disableAnimations: true`, `Gerak`, `Ulang`, `Hitung` and the hold fill render their end or still state on the first frame, with no pending timers except the board's fake-work timers.
  4. `ruas` applies the curve per segment: for `cap` A at t = .55 the scale is exactly .94.
  5. `Hitung` from 24615000 to 24600000 over 660 ms shows 24615000 at 0 ms, a figure in between at 330 ms, and 24600000 at 660 ms; changing `nilai` mid-count continues from the figure on screen.
  6. Hold button: release at 1000 ms → no close, fill returns to 0 within 200 ms; hold 1650 ms → close called once; keyboard activation → close at once; unticked → nothing.
  7. `halaman` for a phone board returns a `CustomTransitionPage` of 280 ms with zero reverse duration, and a `NoTransitionPage` for a laptop board or under reduce motion.

## Notes on the boards

- `segel` (Gerak preview) is the boards' `cap` variant C. Do not add a separate keyframe.
- `cap` has three variants on the canvas and they differ in rotation and peak; keep A, B and C apart.
- Kamera declares a `transform` transition on the receipt, but the two transforms are on different elements, so nothing animates.
- WebBantuanAI uses `turun` without declaring it: no motion there, as on the board.
- Declared but unused, not built: `cap` B in Bendahara and MataAnggaran, `tali` 22 px in Bendahara, `denyut` scale in HitungKas, and every keyframe declared on the 109 boards without motion.
- On the board, Back to a previous view inside the board replays that view's entrance; in the prototype, pop is instant and nothing replays (see "Screen change and page transitions").
- The hold fill reaches full at 1600 ms; the close fires at 1650 ms, as on the board.
- On TutupBuku Rekonsiliasi, "Pastikan rekonsiliasi" appears when the target difference is Rp0, before the count reaches Rp0. This is the board's behaviour; keep it.

## Appendix: every usage

Generated from the board sources: every inline `animation:` and `transition:`, the element it is on (its role, or the first words of its text), and the board state that mounts it. "mounts when `a › b`" means the element sits inside `sc-if a`, then `sc-if b`; "each item of x" means it repeats in `sc-for x`. Timing terms are copied from the board; `both` is the fill mode. Durations written `.3s` are 300 ms.

| Board | Motion | On | Plays when |
| --- | --- | --- | --- |
| AIBulan | `muncul .3s` | status · “… Bantuan AI berhenti sampai Desember 2026. Rekonsiliasi, …” | mounts when `aiHidup › each item of usul › u.hasil` |
| AIFoto | `muncul .3s` | “Usulan AI · dari foto … …” | mounts when `tAda` |
| AIFoto | `muncul .3s` | status · “Tersimpan sebagai Draf · belum masuk saldo. Semua isian ma…” | mounts when `dipakai` |
| AIMataAnggaran | `muncul .3s` | “… … Mata Anggaran sudah dipilih oleh … Usulan AI tidak ter…” | mounts when `pakai` |
| AIMataAnggaran | `muncul .3s` | “Usulan diabaikan. Draf boleh disimpan tanpa Mata Anggaran,…” | mounts when `abai` |
| AlihPeruntukan | `muncul .4s both` | “No. Bukti BKU-2026-0152 Tidak berubah. Yang berubah hanya …” | mounts when `posted` |
| AlihPeruntukan | `width .5s cubic-bezier(.2,.8,.2,1)` (transition) | bar segment | value changes (shown while `each item of baris`) |
| AlihPeruntukan | `muncul .3s` | “Dibukukan pada 16/11/2026 11.55. Tidak muncul di Pendapata…” | mounts when `posted` |
| Awal | `pudar .2s` | full-screen view · “palakat Pengaturan” | mounts when `isLangkah` |
| Awal | `muncul .3s` | “Jemaat siap mencatat. Pencatatan dimulai 15 September 2026…” | mounts when `isLangkah › siap` |
| Awal | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isTunjuk` |
| Awal | `putar 6s linear infinite` | dashed waiting ring svg | mounts when `isTunjuk › wTunggu` |
| Awal | `lingkar .7s ease-out both` | ring circle (stroke) | mounts when `isTunjuk › wAktif` |
| Awal | `pudar .3s .5s both` | check-mark path | mounts when `isTunjuk › wAktif` |
| Awal | `muncul .3s` | button · “Lanjut ke saldo awal pencatatan” | mounts when `isTunjuk › wAktif` |
| Awal | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isSaldo` |
| Awal | `width .45s cubic-bezier(.2,.8,.2,1)` (transition) | bar segment | value changes (shown while `isSaldo › belumOpn`) |
| Awal | `width .45s cubic-bezier(.2,.8,.2,1)` (transition) | bar segment | value changes (shown while `isSaldo › belumOpn`) |
| Awal | `width .45s cubic-bezier(.2,.8,.2,1)` (transition) | bar segment | value changes (shown while `isSaldo › belumOpn`) |
| Awal | `sapu .7s ease-out both` | full overlay | mounts when `isSaldo › opn` |
| Awal | `cap .55s cubic-bezier(.2,.8,.2,1) .35s both` | “No. Bukti OPN-2026-0001 Saldo awal pencatatan · semua Kas/…” | mounts when `isSaldo › opn` |
| Awal | `muncul .3s .6s both` | “… …” | mounts when `isSaldo › opn` |
| Awal | `muncul .3s` | button · “Periksa dan bukukan saldo awal Kembali ke pengaturan awal” | mounts when `isSaldo › bisaOpn` |
| AwalIsian | `muncul .3s` | “Pengaturan awal diterbitkan Berlaku mulai September 2026. …” | mounts when `terbit` |
| Bagi | `width .45s cubic-bezier(.2,.8,.2,1)` (transition) | bar segment | value changes (shown while `each item of segmen`) |
| Bagi | `muncul .3s` | status · “Mata Anggaran sudah dipilih · dibagi ke … baris Pakai pemb…” | mounts when `dipakai` |
| Bagi | `pudar .2s` | full overlay, scrim button, button | mounts when `pilih` |
| Bagi | `naik .28s cubic-bezier(.2,.8,.2,1)` | bottom sheet · “Pilih Mata Anggaran” | mounts when `pilih` |
| BantuanAI | `titik 1s infinite` | dot 6×6 laut | mounts when `aiHidup › tProses` |
| BantuanAI | `titik 1s .2s infinite` | dot 6×6 laut | mounts when `aiHidup › tProses` |
| BantuanAI | `titik 1s .4s infinite` | dot 6×6 laut | mounts when `aiHidup › tProses` |
| BantuanAI | `muncul .3s` | “Usulan AI …” | mounts when `aiHidup › tAda` |
| BantuanAI | `turun .4s` after index × 70 ms, both (filled fields, after Pakai) | “… AI hanya mengusulkan. Membukukan, memverifikasi dokumen …” | mounts when `each item of isian` |
| Bendahara | `pudar .2s` | full-screen view | mounts when `isUtama` |
| Bendahara | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isSerah` |
| Bendahara | `putar 6s linear infinite` | dashed waiting ring svg | mounts when `isSerah › tTunggu` |
| Bendahara | `muncul .3s` | status · “… · aktif sejak 16/11/2026 · SK-BPMJ-09-2026 Yang terjadi …” | mounts when `isSerah › tAktif` |
| Bendahara | `muncul .3s` | button · “Lihat Bendahara dan sesi” | mounts when `isSerah › tAktif` |
| Bukti | `pudar .2s` | “Seri Biasa · BKU-2026-0001 sampai 0151 3 nomor tanpa trans…” | mounts when `isCelah` |
| Cari | `muncul .3s` | “Usulan AI · penjelasan Empat ibadah Minggu pagi di Oktober…” | mounts when `aiAda` |
| Cari | `muncul .3s` | “Usulan AI · narasi bulanan Pada Oktober 2026 Pendapatan Je…” | mounts when `nAda` |
| Dokumen | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isRinci` |
| Dokumen | `muncul .3s` | “… … Alasan · wajib” | mounts when `isRinci › adaForm` |
| Dokumen | `muncul .3s` | “… Belum ada file dan belum ada keputusan.” | mounts when `isRinci › each item of hist` |
| Draf | `muncul .3s` | “Dibatalkan −Rp650.000 Honor pemusik Alasan: … Dibatalkan o…” | mounts when `isBatal` |
| Draf | `muncul .3s` | status · “Draf kosong dihapus. Hanya draf tanpa isian yang dapat dih…” | mounts when `isHapus` |
| Draf | `pudar .2s` | full overlay, scrim button, button | mounts when `adaSheet` |
| Draf | `muncul .28s` | bottom sheet · “… … Pindah ke bulan” | mounts when `adaSheet` |
| Ekspor | `isi` 1.1 / 1.5 / 2.4 / 1.9 / 2.6 s per row, linear, both | progress fill | mounts when `each item of isi › x.jalan` |
| Ekspor | `muncul .3s` | “Ekspor belum lengkap 3 dari 214 dokumen pendukung tidak ik…” | mounts when `selesai` |
| FormatLaporan | `muncul .3s` | “Persetujuan format: sudah dicatat Pemberi persetujuan: … ,…” | mounts when `ada` |
| HitungKas | `pudar .2s` | full-screen view | mounts when `isHitung` |
| HitungKas | `muncul .28s` | “lembar-hitung-16-11.jpg · Terlampir Diunggah, belum diveri…” | mounts when `isHitung › dokAda` |
| HitungKas | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isBanding` |
| HitungKas | `muncul .3s .15s both` | “Hasil hitung kas … Selisih belum dijelaskan …” | mounts when `isBanding` |
| HitungKas | `muncul .3s .35s both` | “Selisih belum dijelaskan … … Hasil hitung disimpan apa ada…” | mounts when `isBanding` |
| HitungKas | `muncul .3s .5s both` | “… Hasil hitung disimpan apa adanya; tidak ada tindakan unt…” | mounts when `isBanding › adaSelisih` |
| HitungKas | `muncul .3s .5s both` | “Hasil hitung kas sama dengan Saldo buku.” | mounts when `isBanding › tanpaSelisih` |
| HitungKas | `muncul .3s` | div | mounts when `isBanding › tersimpan` |
| HitungKas | `lingkar .7s ease-out both` | ring circle (stroke) | mounts when `isBanding › tersimpan` |
| HitungKas | `pudar .3s .5s both` | check-mark path | mounts when `isBanding › tersimpan` |
| Kamera | `transform .25s cubic-bezier(.2,.8,.2,1)` (transition) | “… … … …” | value changes (shown while `isBidik`) |
| Kamera | `muncul .3s` | “… …” | mounts when `isTinjau` |
| Kamera | `transform .25s cubic-bezier(.2,.8,.2,1)` (transition) | “… … … …” | value changes (shown while `isTinjau`) |
| Kamera | `kilat .35s ease-out both` | full overlay | mounts when `isTinjau` |
| Kamera | `isi 1.5s linear both` | progress fill | mounts when `isTerang › isUnggah` |
| Kamera | `muncul .3s` | status · “Dokumen pendukung · … Diunggah, belum diverifikasi Terlamp…” | mounts when `isTerang › isLampir` |
| KasusBaru | `background .3s` (transition) | “… No. Bukti …” | value changes |
| KasusBaru | `muncul .4s both` | “No. Bukti … … … …” | mounts when `adaNo` |
| KasusBaru | `muncul .3s` | “… … …” | mounts when `selesai` |
| Kejadian | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isRinci` |
| Kejadian | `muncul .3s` | “… Angka dan laporan resmi … tidak berubah. Hambatan tutup …” | mounts when `isRinci › adaSelesai` |
| Keluar | `pudar .2s` | full overlay, scrim button, button | mounts when `isAkun › tanya` |
| Keluar | `muncul .28s` | bottom sheet · “Keluar dari perangkat ini? Yang sudah dibukukan dan draf y…” | mounts when `isAkun › tanya` |
| Keluar | `pudar .25s` | full-screen view · “Anda sudah keluar Sesi di perangkat ini berakhir. Masuk la…” | mounts when `isKeluar` |
| Kesiapan | `muncul .3s` | “… Anda menyatakan bahwa catatan peruntukan Diakonia untuk …” | mounts when `bend › beres` |
| Kesiapan | `muncul .3s` | “Alasan membebaskan · wajib” | mounts when `each item of rows › r.isForm` |
| Kewajiban | `pudar .2s` | full-screen view | mounts when `isDaftar` |
| Kewajiban | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isRinci` |
| Kewajiban | `width .5s cubic-bezier(.2,.8,.2,1)` (transition) | bar segment | value changes (shown while `isRinci`) |
| Kewajiban | `muncul .3s` | “… … · … · … … …” | mounts when `isRinci › each item of r.entri` |
| Kewajiban | `muncul .3s` | status · “… · tidak ada sisa” | mounts when `isRinci › tuntas` |
| Kewajiban | `pudar .2s` | full overlay, scrim button, button | mounts when `sheet` |
| Kewajiban | `naik .28s cubic-bezier(.2,.8,.2,1)` | bottom sheet · “… … Jumlah (Rp)” | mounts when `sheet` |
| Koreksi | `pudar .2s` | full-screen view | mounts when `isDetail` |
| Koreksi | `muncul .3s` | “Pemberi persetujuan: … , … 08/11/2026 · cara: … Dicatat ol…” | mounts when `isDetail › apAda` |
| Koreksi | `muncul .3s` | “Kejadian setelah tutup buku Belum ditindaklanjuti … Angka …” | mounts when `isDetail › kejadianAda` |
| Koreksi | `pudar .2s` | full overlay, scrim button, button | mounts when `isAp` |
| Koreksi | `naik .28s cubic-bezier(.2,.8,.2,1)` | bottom sheet · “Catat persetujuan Anda mencatat persetujuan yang diberikan…” | mounts when `isAp` |
| Koreksi | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isKoreksi` |
| Koreksi | `pudar .2s` | full-screen view · “Koreksi dibukukan …” | mounts when `isHasil` |
| Koreksi | `cap .5s .2s both` | “Dibalik Transaksi asal −Rp750.000 Belanja 5.02.01.00 Alat …” | mounts when `isHasil` |
| Koreksi | `tali .25s .5s both` | connector line 2 px tinta | mounts when `isHasil` |
| Koreksi | `balik .5s .7s cubic-bezier(.2,.8,.2,1) both` | “BKU-2026-0144 Dibukukan Pembalikan” | mounts when `isHasil` |
| Koreksi | `tali .25s 1.2s both` | connector line 2 px tinta | mounts when `isHasil › denganKoreksi` |
| Koreksi | `muncul .4s 1.4s both` | “BKU-2026-0145 Dibukukan Transa” | mounts when `isHasil › denganKoreksi` |
| Koreksi | `muncul .4s 1.7s both` | “Pengaruh pada Saldo buku Kas … Alasan: …” | mounts when `isHasil` |
| Koreksi | `muncul .4s 1.7s both` | “Alasan: … Kembali ke transaksi asal” | mounts when `isHasil` |
| Koreksi | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isKejadian` |
| Lainnya | `pudar .2s` | full-screen view · “Lainnya Jemaat Karunia WITA · tahun buku mulai 1 Januari (…” | mounts when `isHub` |
| Lainnya | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isKas` |
| Lainnya | `pudar .2s` | full overlay, scrim button, button | mounts when `sheet` |
| Lainnya | `naik .28s cubic-bezier(.2,.8,.2,1)` | bottom sheet · “Nonaktifkan … Transaksi lama tidak berubah dan tetap tampi…” | mounts when `sheet` |
| Lainnya | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isAturan` |
| Lainnya | `background .16s` (transition) | “Berlaku mulai Desember 2026. Sejak itu, Bukukan” | value changes (shown while `isAturan`) |
| Lainnya | `left .16s` (transition) | span | value changes (shown while `isAturan`) |
| Lainnya | `muncul .3s` | “Berlaku mulai Desember 2026. Sejak itu, Bukukan memerlukan…” | mounts when `isAturan › mc` |
| Lainnya | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isRiwayat` |
| Laporan | `pudar .2s` | full-screen view | mounts when `isDaftar` |
| Laporan | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isRinci` |
| LihatDokumen | `transform .25s cubic-bezier(.2,.8,.2,1)` (transition) | “… … … …” | value changes |
| LihatDokumen | `muncul .3s` | status · “Memenuhi syarat tutup buku November 2026. Tolak, lepaskan,…” | mounts when `sudah` |
| LihatTransaksi | `muncul .3s` | “… · … … …” | mounts when `each item of rows` |
| Main | `pudar .2s` | full-screen view · “Transaksi · November 2026 Pilih bulan” | mounts when `isDaftar` |
| Main | `muncul .28s cubic-bezier(.2,.8,.2,1)` | status · “Draf tersimpan · belum masuk saldo” | mounts when `toast` |
| Main | `pudar .2s` | full overlay, scrim button, button | mounts when `sheet` |
| Main | `naik .28s cubic-bezier(.2,.8,.2,1)` | bottom sheet · “Catat apa?” | mounts when `sheet` |
| Main | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isForm` |
| Main | `muncul .2s` | alert · “Gagal disimpan. Isian Anda masih ada di layar ini. Coba la…” | mounts when `isForm › simpanGagal` |
| Main | `isi 1.2s linear both` | progress fill | mounts when `isForm › dokUnggah` |
| Main | `muncul .28s` | “nota-16-11.jpg · Terlampir Diunggah, belum diverifikasi” | mounts when `isForm › dokAda` |
| Main | `naik .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isMa` |
| Main | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isPeriksa` |
| Main | `sapu .7s ease-out both` | full overlay | mounts when `isPeriksa › posted` |
| Main | `cap .55s cubic-bezier(.2,.8,.2,1) .35s both` | “No. Bukti … … … Dibukukan pada 16/11/2026 10.42 · tidak da…” | mounts when `isPeriksa › posted` |
| Main | `muncul .3s .5s both` | “Saldo buku … … Sebelumnya …” | mounts when `isPeriksa › posted` |
| Main | `muncul .3s` after index × 90 ms, both | div | mounts when `isPeriksa › belumPosted › each item of cek` |
| Main | `muncul .3s .8s both` | “Lihat transaksi Kembali ke Beranda” | mounts when `isPeriksa › posted` |
| Main | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isDetail` |
| Masuk | `muncul .3s` | “Masukkan kode Dikirim ke … Kode enam angka” | mounts when `tKode` |
| Masuk | `muncul .3s` | “Menunggu verifikasi wewenang Anda sudah masuk, tetapi belu…” | mounts when `tHasil › hTunggu` |
| Masuk | `muncul .3s` | “Jemaat Karunia Meiske Lumentut · Wewenang Bendahara aktif …” | mounts when `tHasil › hBend` |
| Masuk | `muncul .3s` | “Jemaat Karunia Dkn. Olga Tamba · Akses terbatas: Peruntuka…” | mounts when `tHasil › hTerbatas` |
| Masuk | `muncul .3s` | “Anda masuk sebagai administrator sistem Tidak ada tindakan…” | mounts when `tHasil › hAdmin` |
| MataAnggaran | `pudar .2s` | full-screen view | mounts when `isVersi` |
| MataAnggaran | `sapu .7s ease-out both` | full overlay | mounts when `isVersi › terbit` |
| MataAnggaran | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isRinci` |
| MataAnggaran | `muncul .3s` | button · “Terbitkan” | mounts when `isRinci › isPeriksa` |
| MataAnggaran | `pudar .2s` | full overlay, scrim button, button | mounts when `sheet` |
| MataAnggaran | `naik .28s cubic-bezier(.2,.8,.2,1)` | bottom sheet · “Terbitkan versi 2026.2? Versi yang diterbitkan tidak dapat…” | mounts when `sheet` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 62% × 44px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 44% × 16px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 26% × 16px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 44% × 16px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 26% × 16px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 44% × 16px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 26% × 16px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 34% × 18px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 58% × 14px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 32% × 14px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 58% × 14px | mounts when `isBeranda › isMuat` |
| Memuat | `denyut 1.4s ease-in-out infinite` | skeleton block 32% × 14px | mounts when `isBeranda › isMuat` |
| Memuat | `muncul .3s` | “Saldo buku · semua Kas/Bank Rp38.415.000 Hanya transaksi y…” | mounts when `isBeranda › isAda` |
| Memuat | `muncul .3s` | “Dibukukan No. Bukti BKU-2026-0155” | mounts when `isPeriksa › isBuku` |
| Memuat | `muncul .4s both` | “No. Bukti BKU-2026-0155 −Rp85.000 Air minum untuk rapat Di…” | mounts when `isPeriksa › isBuku` |
| Pemberitahuan | `background .16s` (transition) | “Mematikan pemberitahuan tidak menyembunyikan hambatan: sem…” | value changes (shown while `each item of atur`) |
| Pemberitahuan | `left .16s` (transition) | span | value changes (shown while `each item of atur`) |
| Pemeriksa | `background .3s` (transition) | “…” | value changes |
| Pemeriksa | `sapu .7s ease-out both` | full overlay | mounts when `isBuku` |
| Pemeriksa | `cap .55s cubic-bezier(.2,.8,.2,1) .35s both` | “No. Bukti BKU-2026-0151 −Rp900.000 Kas · diambil dari peru…” | mounts when `isBuku` |
| Pemeriksa | `pudar .2s` | full overlay, scrim button, button | mounts when `sheet` |
| Pemeriksa | `naik .28s cubic-bezier(.2,.8,.2,1)` | bottom sheet · “Ubah transaksi yang sudah diperiksa? Transaksi kembali men…” | mounts when `sheet` |
| Pemulihan | `muncul .3s` | “Masukkan kode pemulihan Dikirim ke …” | mounts when `tKode` |
| Pemulihan | `muncul .3s` | “Akun dipulihkan Meiske Lumentut · Wewenang Bendahara aktif…” | mounts when `tSelesai` |
| Pengembalian | `muncul .3s` | “Draf · belum masuk saldo … … Terkait dengan No. Bukti … · …” | mounts when `jadi` |
| Persembahan | `pudar .2s` | full-screen view | mounts when `isIsi` |
| Persembahan | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view · “Sudah dibukukan Satu persembahan, satu No. Bukti, … bagian…” | mounts when `isHasil` |
| Persembahan | `sapu .7s ease-out both` | full overlay | mounts when `isHasil` |
| Persembahan | `cap .55s cubic-bezier(.2,.8,.2,1) .35s both` | “No. Bukti BKU-2026-0148 … Persembahan Ibadah Minggu” | mounts when `isHasil` |
| Persembahan | `muncul .3s .5s both` | “Pendapatan bulan ini Bagian milik sendiri + … Titipan untu…” | mounts when `isHasil` |
| Persembahan | `muncul .3s .7s both` | “Titipan untuk: Sinode Uang titipan untuk pihak lain, bukan…” | mounts when `isHasil` |
| Persembahan | `muncul .3s .9s both` | “… tunai sekarang ada di Kas. Bila disetor, catat sebagai P…” | mounts when `isHasil` |
| Persetujuan | `muncul .3s` | “Persetujuan di luar aplikasi Persetujuan belum dicatat Dra…” | mounts when `belum` |
| Persetujuan | `muncul .3s` | “Mengubah jumlah membuat persetujuan tidak berlaku Persetuj…” | mounts when `peringatan` |
| Persetujuan | `muncul .3s` | “… … Pemberi persetujuan · wajib” | mounts when `adaForm` |
| Persetujuan | `muncul .3s` | “…, … · … · dicatat … …” | mounts when `adaLama › each item of lama` |
| PilihBulan | `pudar .2s` | full overlay, scrim button, button | mounts when `buka` |
| PilihBulan | `muncul .28s` | bottom sheet · “Pilih bulan Semua bulan sejak tanggal mulai pencatatan.” | mounts when `buka` |
| RekonIsi | `muncul .3s` | “mutasi-bni-okt.csv · 3 mutasi dibaca. Belum ada yang dicoc…” | mounts when `csvAda` |
| RekonIsi | `muncul .3s` | “↔ … Cocokkan · …” | mounts when `each item of lines › each item of l.dipakai` |
| RekonIsi | `muncul .3s` | “Perlu dipastikan lagi BKU-2026-0127 dibalik setelah rekons…” | mounts when `invalid` |
| RekonIsi | `muncul .3s` | “Sudah dipastikan oleh …, 16/11/2026. Perubahan pada buku O…” | mounts when `pasti` |
| Sambungan | `isi 1.6s linear both` | progress fill | mounts when `isForm › mencoba` |
| Sambungan | `muncul .3s` | status · “Tersambung lagi. Draf tersimpan. Tersimpan satu kali. Tida…” | mounts when `isForm › tersimpan` |
| Sambungan | `border .3s` (transition) | “… · Draf · belum masuk saldo −Rp85.000 Air minum untuk rap…” | value changes (shown while `isForm`) |
| Sambungan | `pudar .25s` | full-screen view · “… …” | mounts when `isSesi` |
| TabCatat | `muncul .4s both` | “No. Bukti BKU-2026-0147 … …” | mounts when `posted` |
| TabTransaksi | `sapu .7s ease-out both` | full overlay | mounts when `baruBuku` |
| TabTransaksi | `cap .55s cubic-bezier(.2,.8,.2,1) .35s both` | “No. Bukti …” stamp | mounts when `baruBuku` |
| Tanggal | `muncul .3s` | “Masuk laporan Oktober 2026 , bulan berikutnya untuk tutup …” | mounts when `okt` |
| Terbatas | `pudar .2s` | full-screen view · “Akses terbatas: Peruntukan Diakonia Anda hanya melihat bag…” | mounts when `isDaftar` |
| Terbatas | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isRinci` |
| TutupBuku | `pudar .2s` | full-screen view · “Bulan Bulan ditutup satu per satu, mulai dari yang paling …” | mounts when `isBulan` |
| TutupBuku | `cap .5s cubic-bezier(.2,.8,.2,1)` | “Oktober 2026 Sudah ditutup Periode laporan 1–31 Oktober 20…” | mounts when `isBulan › oktTutup` |
| TutupBuku | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isCek` |
| TutupBuku | `muncul .3s` | “Tidak ada hambatan. Oktober 2026 siap ditutup.” | mounts when `isCek › tanpaHambatan` |
| TutupBuku | `muncul .3s` | “Lanjut ke konfirmasi tutup buku” | mounts when `isCek › tanpaHambatan` |
| TutupBuku | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view | mounts when `isRekon` |
| TutupBuku | `muncul .3s` | “Setoran dalam perjalanan + Rp500.000 Saldo pembanding …” | mounts when `isRekon › perjalanan` |
| TutupBuku | `color .3s` (transition) | “… Belum cocok” | value changes (shown while `isRekon`) |
| TutupBuku | `muncul .3s` | “Setoran dalam perjalanan Rp500.000 · dibawa ke November 20…” | mounts when `isRekon › perjalanan` |
| TutupBuku | `dariKiri .4s cubic-bezier(.2,.8,.2,1) both` | “Mutasi bank BIAYA ADM −Rp15.000 Tra” | mounts when `isRekon › biaya` |
| TutupBuku | `dariKanan .4s cubic-bezier(.2,.8,.2,1) both` | “Transaksi · Dibukukan · BKU-2026-0133 Biaya administrasi b…” | mounts when `isRekon › biaya` |
| TutupBuku | `kait .4s .35s both` | “12 mutasi bank lain sudah cocok dengan transaksinya.” | mounts when `isRekon › biaya` |
| TutupBuku | `muncul .3s` | button · “Pastikan rekonsiliasi Kembali ke kesiapan tutup buku” | mounts when `isRekon › bisaPasti` |
| TutupBuku | `masuk .28s cubic-bezier(.2,.8,.2,1)` | full-screen view · “Tutup buku bulan Oktober 2026? Mohon baca ringkasan di baw…” | mounts when `isKonfirmasi` |
| TutupBuku | width 1.6 s linear while held, .2 s linear on release | span | value changes (shown while `isKonfirmasi`) |
| TutupBuku | `pudar .2s` | full-screen view · “Sedang menutup buku…” | mounts when `isProses` |
| TutupBuku | `putar 1s linear infinite` | spinner svg | mounts when `isProses` |
| TutupBuku | `pudar .2s` | full-screen view · “Oktober 2026 · Belum ditutup Tutup buku tidak terjadi: ada…” | mounts when `isGagal` |
| TutupBuku | `gelap .7s ease-out both` | full-screen view | mounts when `isSudah` |
| TutupBuku | `lingkar .9s .3s ease-out both` | ring circle (stroke) | mounts when `isSudah` |
| TutupBuku | `cap .5s 1.1s cubic-bezier(.2,.8,.2,1) both` | lock group (body + shackle) | mounts when `isSudah` |
| TutupBuku | `muncul .4s 1.4s both` | “Buku bulan Oktober 2026 sudah ditutup. Angka laporan resmi…” | mounts when `isSudah` |
| TutupBuku | `muncul .4s 1.7s both` | “Laporan resmi · PDF …” | mounts when `isSudah` |
| TutupBuku | `muncul .3s` | a · “Unduh PDF Laporan resmi · Excel …” | mounts when `isSudah › pdfSiap` |
| TutupBuku | `muncul .3s` | a · “Unduh Excel File yang gagal dibuat cukup dibuat lagi dari …” | mounts when `isSudah › xlsSiap` |
| TutupBuku | `muncul .4s 1.9s both` | “File yang gagal dibuat cukup dibuat lagi dari angka yang s…” | mounts when `isSudah` |
| TutupBuku | `muncul .4s 1.9s both` | button · “Kembali ke Bulan” | mounts when `isSudah` |
| UbahPengaturan | `muncul .3s` | “… Pengaturan tidak diubah di tempat. Versi lama tetap berl…” | mounts when `adaJadi › each item of jadi` |
| WebAI | `muncul .3s` | status · “… Bantuan AI berhenti sampai Desember 2026. Rekonsiliasi, …” | mounts when `aiHidup › each item of usul › u.hasil` |
| WebAIFoto | `muncul .3s` | status · “Tersimpan sebagai Draf · belum masuk saldo. Semua isian ma…” | mounts when `dipakai` |
| WebAIFoto | `muncul .3s` | “Usulan AI · dari foto … …” | mounts when `tAda` |
| WebAIMataAnggaran | `muncul .3s` | “… … Mata Anggaran sudah dipilih oleh … Usulan AI tidak ter…” | mounts when `pakai` |
| WebAIMataAnggaran | `muncul .3s` | “Usulan diabaikan. Draf boleh disimpan tanpa Mata Anggaran,…” | mounts when `abai` |
| WebAlihPeruntukan | `muncul .4s both` | “No. Bukti BKU-2026-0152 Tidak berubah. Yang berubah hanya …” | mounts when `posted` |
| WebAlihPeruntukan | `width .5s cubic-bezier(.2,.8,.2,1)` (transition) | bar segment | value changes (shown while `each item of baris`) |
| WebAlihPeruntukan | `muncul .3s` | “Dibukukan pada 16/11/2026 11.55. Tidak muncul di Pendapata…” | mounts when `posted` |
| WebAwal | `sapu .7s ease-out both` | full overlay | mounts when `opn` |
| WebAwal | `cap .55s cubic-bezier(.2,.8,.2,1) .35s both` | “No. Bukti OPN-2026-0001 Saldo awal pencatatan · semua Kas/…” | mounts when `opn` |
| WebAwal | `muncul .3s .8s both` | a · “Mulai mencatat” | mounts when `opn` |
| WebAwalIsian | `muncul .3s` | “Pengaturan awal diterbitkan Berlaku mulai September 2026. …” | mounts when `terbit` |
| WebBagi | `width .45s cubic-bezier(.2,.8,.2,1)` (transition) | bar segment | value changes (shown while `each item of segmen`) |
| WebBantuanAI | `titik 1s infinite` | dot 6×6 laut | mounts when `aiHidup › tProses` |
| WebBantuanAI | `titik 1s .2s infinite` | dot 6×6 laut | mounts when `aiHidup › tProses` |
| WebBantuanAI | `titik 1s .4s infinite` | dot 6×6 laut | mounts when `aiHidup › tProses` |
| WebBantuanAI | `muncul .3s` | “Usulan AI …” | mounts when `aiHidup › tAda` |
| WebBantuanAI | `turun .4s` after index × 70 ms (keyframe missing on this board: no visible motion) | “… Periksa dan bukukan” | mounts when `each item of isian` |
| WebCari | `muncul .3s` | “Usulan AI · penjelasan Empat ibadah Minggu pagi di Oktober…” | mounts when `aiAda` |
| WebCari | `muncul .3s` | “Usulan AI · narasi bulanan Pada Oktober 2026 Pendapatan Je…” | mounts when `nAda` |
| WebCatat | `muncul .4s both` | “No. Bukti BKU-2026-0147 … …” | mounts when `posted` |
| WebDokumen | `muncul .3s` | “… … Alasan · wajib” | mounts when `adaForm` |
| WebDokumen | `muncul .3s` | “… Belum ada file dan belum ada keputusan.” | mounts when `each item of hist` |
| WebDraf | `muncul .3s` | “Dibatalkan −Rp650.000 Honor pemusik Alasan: … Dibatalkan o…” | mounts when `isBatal` |
| WebDraf | `muncul .3s` | status · “Draf kosong dihapus. Hanya draf tanpa isian yang dapat dih…” | mounts when `isHapus` |
| WebDraf | `muncul .3s` | “… … Pindah ke bulan” | mounts when `adaSheet` |
| WebEkspor | `isi` 1.1 / 1.5 / 2.4 / 1.9 / 2.6 s per row, linear, both | progress fill | mounts when `each item of isi › x.jalan` |
| WebEkspor | `muncul .3s` | “Ekspor belum lengkap 3 dari 214 dokumen pendukung tidak ik…” | mounts when `selesai` |
| WebFormatLaporan | `muncul .3s` | “Persetujuan format: sudah dicatat Pemberi persetujuan: … ,…” | mounts when `ada` |
| WebHitungKas | `color .3s` (transition) | “… … Petugas penghitung · paling sedikit satu” | value changes |
| WebKasus | `width .5s cubic-bezier(.2,.8,.2,1)` (transition) | bar segment | value changes (shown while `isRinci`) |
| WebKasus | `muncul .3s` | “… … · … · … …” | mounts when `isRinci › each item of r.entri` |
| WebKasus | `muncul .3s` | “… … Rp” | mounts when `isRinci › sheet` |
| WebKasusBaru | `background .3s` (transition) | “… No. Bukti …” | value changes |
| WebKasusBaru | `muncul .4s both` | “No. Bukti … … … …” | mounts when `adaNo` |
| WebKasusBaru | `muncul .3s` | “… … …” | mounts when `selesai` |
| WebKejadian | `muncul .3s` | “… Angka dan laporan resmi … tidak berubah. Hambatan tutup …” | mounts when `adaSelesai` |
| WebKeluar | `muncul .3s` | “Keluar dari perangkat ini? Yang sudah dibukukan dan draf y…” | mounts when `isAkun › tanya` |
| WebKesiapan | `muncul .3s` | “Alasan membebaskan · wajib” | mounts when `each item of rows › r.isForm` |
| WebKesiapan | `muncul .3s` | “… Anda menyatakan bahwa catatan peruntukan Diakonia untuk …” | mounts when `bend › beres` |
| WebKoreksi | `muncul .3s` | “Pemberi persetujuan: Pdt. Lidya Rondonuwu , Ketua BPMJ · 0…” | mounts when `apAda` |
| WebKoreksi | `muncul .4s .2s both` | “BKU-2026-0144 Dibukukan Pembalikan” | mounts when `isHasil` |
| WebKoreksi | `muncul .4s .6s both` | “BKU-2026-0145 Dibukukan Transaksi koreks” | mounts when `isHasil › kor` |
| WebKoreksi | `muncul .4s 1s both` | “Pengaruh pada Saldo buku Kas … Alasan: …” | mounts when `isHasil` |
| WebLihatDokumen | `transform .25s cubic-bezier(.2,.8,.2,1)` (transition) | “… … … …” | value changes |
| WebLihatDokumen | `muncul .3s` | status · “Memenuhi syarat tutup buku November 2026. Tolak, lepaskan,…” | mounts when `sudah` |
| WebLihatTransaksi | `muncul .3s` | “… · … … …” | mounts when `each item of rows` |
| WebMasuk | `muncul .3s` | “Masukkan kode Dikirim ke … Kode enam angka” | mounts when `tKode` |
| WebMasuk | `muncul .3s` | “Menunggu verifikasi wewenang Anda sudah masuk, tetapi belu…” | mounts when `tHasil › hTunggu` |
| WebMasuk | `muncul .3s` | “Jemaat Karunia Meiske Lumentut · Wewenang Bendahara aktif …” | mounts when `tHasil › hBend` |
| WebMasuk | `muncul .3s` | “Jemaat Karunia Dkn. Olga Tamba · Akses terbatas: Peruntuka…” | mounts when `tHasil › hTerbatas` |
| WebMasuk | `muncul .3s` | “Anda masuk sebagai administrator sistem Tidak ada tindakan…” | mounts when `tHasil › hAdmin` |
| WebMataAnggaran | `sapu .7s ease-out both` | full overlay | mounts when `terbit` |
| WebMataAnggaran | `muncul .3s` | “Versi yang diterbitkan tidak dapat diubah. Perubahan berik…” | mounts when `konfirmasi` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 62% × 44px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 44% × 16px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 26% × 16px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 44% × 16px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 26% × 16px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 44% × 16px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 26% × 16px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 34% × 18px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 58% × 14px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 32% × 14px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 58% × 14px | mounts when `isBeranda › isMuat` |
| WebMemuat | `denyut 1.4s ease-in-out infinite` | skeleton block 32% × 14px | mounts when `isBeranda › isMuat` |
| WebMemuat | `muncul .3s` | “Saldo buku · semua Kas/Bank Rp38.415.000 Hanya transaksi y…” | mounts when `isBeranda › isAda` |
| WebMemuat | `muncul .3s` | “Dibukukan No. Bukti BKU-2026-0155” | mounts when `isPeriksa › isBuku` |
| WebMemuat | `muncul .4s both` | “No. Bukti BKU-2026-0155 −Rp85.000 Air minum untuk rapat Di…” | mounts when `isPeriksa › isBuku` |
| WebPemberitahuan | `background .16s` (transition) | “Mematikan pemberitahuan tidak menyembunyikan hambatan: sem…” | value changes (shown while `each item of atur`) |
| WebPemberitahuan | `left .16s` (transition) | span | value changes (shown while `each item of atur`) |
| WebPemeriksa | `muncul .4s both` | “No. Bukti … … … …” | mounts when `d.no` |
| WebPemulihan | `muncul .3s` | “Masukkan kode pemulihan Dikirim ke …” | mounts when `tKode` |
| WebPemulihan | `muncul .3s` | “Akun dipulihkan Meiske Lumentut · Wewenang Bendahara aktif…” | mounts when `tSelesai` |
| WebPengaturan | `background .16s` (transition) | “Berlaku mulai Desember 2026. Belum ada pemeriksa kedua yan…” | value changes |
| WebPengaturan | `left .16s` (transition) | span | value changes |
| WebPengaturan | `muncul .3s` | “Berlaku mulai Desember 2026. Belum ada pemeriksa kedua yan…” | mounts when `mc` |
| WebPengembalian | `muncul .3s` | “Draf · belum masuk saldo … … Terkait dengan No. Bukti … · …” | mounts when `jadi` |
| WebPersembahan | `muncul .4s both` | “No. Bukti BKU-2026-0148 … Milik sendiri · menjadi Pendapat…” | mounts when `posted` |
| WebPersembahan | `muncul .3s` | “… tunai sekarang ada di Kas. Setoran ke bank dicatat sebag…” | mounts when `posted` |
| WebPersetujuan | `muncul .3s` | “Persetujuan di luar aplikasi Persetujuan belum dicatat Dra…” | mounts when `belum` |
| WebPersetujuan | `muncul .3s` | “Mengubah jumlah membuat persetujuan tidak berlaku Persetuj…” | mounts when `peringatan` |
| WebPersetujuan | `muncul .3s` | “… … Pemberi persetujuan · wajib” | mounts when `adaForm` |
| WebPersetujuan | `muncul .3s` | “…, … · … · dicatat … …” | mounts when `adaLama › each item of lama` |
| WebPilihBulan | `muncul .3s` | “Pilih bulan Semua bulan sejak tanggal mulai pencatatan.” | mounts when `buka` |
| WebRekonIsi | `muncul .3s` | “mutasi-bni-okt.csv · 3 mutasi dibaca. Belum ada yang dicoc…” | mounts when `csvAda` |
| WebRekonIsi | `muncul .3s` | “Perlu dipastikan lagi BKU-2026-0127 dibalik setelah rekons…” | mounts when `invalid` |
| WebRekonIsi | `muncul .3s` | “Sudah dipastikan oleh …, 16/11/2026. Perubahan pada buku O…” | mounts when `pasti` |
| WebRekonIsi | `muncul .3s` | “↔ … Cocokkan · …” | mounts when `each item of lines › each item of l.dipakai` |
| WebRekonsiliasi | `color .3s` (transition) | “… Pastikan rekonsiliasi …” | value changes |
| WebRekonsiliasi | `muncul .3s` | “Dalam perjalanan · dibawa ke bulan berikutnya Setoran dala…” | mounts when `perjalanan` |
| WebRekonsiliasi | `dariKiri .45s cubic-bezier(.2,.8,.2,1) both` | “Mutasi bank … …” | mounts when `each item of grup` |
| WebRekonsiliasi | `dariKanan .45s cubic-bezier(.2,.8,.2,1) both` | “Transaksi · … … … Lepaskan” | mounts when `each item of grup` |
| WebRekonsiliasi | `kait .4s .4s both` | “12 mutasi bank lain sudah cocok dengan transaksinya.” | mounts when `each item of grup` |
| WebSambungan | `isi 1.6s linear both` | progress fill | mounts when `isForm › mencoba` |
| WebSambungan | `muncul .3s` | status · “Tersambung lagi. Draf tersimpan. Tersimpan satu kali. Tida…” | mounts when `isForm › tersimpan` |
| WebSambungan | `border .3s` (transition) | “… · Draf · belum masuk saldo −Rp85.000 Air minum untuk rap…” | value changes (shown while `isForm`) |
| WebSerahTerima | `muncul .3s` | status · “… · aktif sejak 16/11/2026 · SK-BPMJ-09-2026 Yang terjadi …” | mounts when `tAktif` |
| WebTanggal | `muncul .3s` | “Masuk laporan Oktober 2026 , bulan berikutnya untuk tutup …” | mounts when `okt` |
| WebTransaksi | `sapu .7s ease-out both` | full overlay | mounts when `baruBuku` |
| WebTransaksi | `cap .55s cubic-bezier(.2,.8,.2,1) .35s both` | “No. Bukti …” stamp | mounts when `baruBuku` |
| WebTutupBuku | `background .6s, color .6s` (transition) | “Oktober 2026 … …” | value changes |
| WebTutupBuku | width 1.6 s linear while held, .2 s linear on release | span | value changes (shown while `isKonfirmasi`) |
| WebTutupBuku | `putar 1s linear infinite` | spinner svg | mounts when `isProses` |
| WebTutupBuku | `gelap .7s ease-out both` | div | mounts when `isSudah` |
| WebTutupBuku | `lingkar .9s .3s ease-out both` | ring circle (stroke) | mounts when `isSudah` |
| WebTutupBuku | `cap .5s 1.1s cubic-bezier(.2,.8,.2,1) both` | lock group (body + shackle) | mounts when `isSudah` |
| WebTutupBuku | `muncul .4s 1.4s both` | “Buku bulan Oktober 2026 sudah ditutup. Angka laporan resmi…” | mounts when `isSudah` |
| WebTutupBuku | `muncul .4s 1.7s both` | “Laporan resmi · PDF …” | mounts when `isSudah` |
| WebUbahPengaturan | `muncul .3s` | “… Pengaturan tidak diubah di tempat. Versi lama tetap berl…” | mounts when `adaJadi › each item of jadi` |
| WebUnggah | `muncul .3s` | div | mounts when `each item of files` |
| WebUnggah | `isi 1.5s linear both` | progress fill | mounts when `each item of files › f.jalan` |
| WebUnggah | `muncul .3s` | a · “Lanjut ke verifikasi” | mounts when `adaLampir` |
| WebVerifikasi | `muncul .3s` | “Alasan dikembalikan · wajib” | mounts when `antre › adaForm` |
| WebVerifikasi | `muncul .3s` | “Wewenang Bendahara aktif Meiske Lumentut · Jemaat Karunia …” | mounts when `aktif` |
| WebVerifikasi | `muncul .3s` | “Dikembalikan ke BPMJ Alasan: … Meiske Lumentut tetap masuk…” | mounts when `kembali` |
| WebVerifikasi | `muncul .3s` | “Wewenang dicabut · Belum ada Bendahara aktif di Jemaat Kar…” | mounts when `dicabut` |
