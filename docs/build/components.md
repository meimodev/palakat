# Components: Flutter build spec

This file specifies the theme layer, the shared primitives, the 31 design-system components, the app chrome and the icons of the Palakat prototype, as Flutter widgets. It is the M1 and M2 input of `README.md`. `CONVENTIONS.md` wins over this file; a board source wins over both on what a screen shows.

Sources read for this file: `docs/design/handoff/01-foundations.md`, `02-components.md`, the 31 `design-system/components/<Name>/README.md` and `preview.html` files plus `Cover/preview.html`, `design-system/README.md`, `tokens/palakat_tokens.dart`, and every board in `docs/design/handoff/canvas/boards/` (searched for how each component is really drawn). Where a board draws a component differently from its preview, the section says so under **Boards vs preview**, and the board's value is the one to build.

Conventions used below:

- Colours are token names (`laut`, `tinta2`, `putus` …) read from `context.warna`. "white" never appears: a white text on `laut` is `diLaut`, on `bata` is `diBata`, on `tinta` is `permukaan`.
- Sizes are logical pixels, equal to the boards' CSS pixels.
- "1.5 dashed `putus`" means a 1.5 px dashed line in `putus`, drawn by `GarisBorder` (section 2.1).
- File paths are under `prototype/lib/`.

---

## 1. Theme layer (`theme/`)

### 1.1 Files

| File | Holds |
| --- | --- |
| `theme/palakat_tokens.dart` | Copied unchanged from `docs/design/handoff/tokens/palakat_tokens.dart` |
| `theme/palakat_warna.dart` | `PalakatWarna` ThemeExtension, `PalakatIlustrasi` |
| `theme/palakat_tema.dart` | `palakatTema(Brightness)` building `ThemeData`, the text styles, `PalakatKonteks` extension |

The tokens file has no `tombolKedua` (48) and no `isian` (48) size and no line heights. Add them in `palakat_tema.dart`, not in the copied file:

```dart
abstract final class PalakatUkuran {
  static const double tombolKedua = 48; // size-tombolKedua
  static const double isian = 48;       // size-isian
}
```

### 1.2 `PalakatWarna`

```dart
@immutable
class PalakatWarna extends ThemeExtension<PalakatWarna> {
  const PalakatWarna({
    required this.kertas, required this.permukaan, required this.tinta,
    required this.tinta2, required this.tinta3, required this.putus,
    required this.garis, required this.garisTegas, required this.laut,
    required this.lautTua, required this.lautLembut, required this.bata,
    required this.bataLembut, required this.diTinta, required this.diTinta2,
    required this.diLaut, required this.diBata, required this.tirai,
  });

  final Color kertas, permukaan, tinta, tinta2, tinta3, putus, garis, garisTegas,
      laut, lautTua, lautLembut, bata, bataLembut, diTinta, diTinta2, diLaut, diBata;
  /// Scrim behind a bottom sheet. Boards: rgba(19,32,28,.45) = tinta at 45 %.
  final Color tirai;

  static const terang = PalakatWarna(
    kertas: PalakatColors.kertas, permukaan: PalakatColors.permukaan,
    tinta: PalakatColors.tinta, tinta2: PalakatColors.tinta2, tinta3: PalakatColors.tinta3,
    putus: PalakatColors.putus, garis: PalakatColors.garis, garisTegas: PalakatColors.garisTegas,
    laut: PalakatColors.laut, lautTua: PalakatColors.lautTua, lautLembut: PalakatColors.lautLembut,
    bata: PalakatColors.bata, bataLembut: PalakatColors.bataLembut,
    diTinta: PalakatColors.diTinta, diTinta2: PalakatColors.diTinta2,
    diLaut: PalakatColors.diLaut, diBata: PalakatColors.diBata,
    tirai: Color(0x7313201C),
  );
  static const gelap = PalakatWarna(/* same names from PalakatColorsGelap */ tirai: Color(0xB30E1513), /* … */);

  @override PalakatWarna copyWith({/* every field nullable */});
  @override PalakatWarna lerp(PalakatWarna? o, double t); // Color.lerp field by field
}
```

The only shadow, `bayanganMelayang` (`0 12px 32px rgba(0,0,0,.4)`), is a constant next to it, used only by the floating receipt in Kamera, LihatDokumen and WebLihatDokumen:

```dart
const bayanganMelayang = [BoxShadow(offset: Offset(0, 12), blurRadius: 32, color: Color(0x66000000))];
```

Illustration colours (CONVENTIONS allows them literal; keep them here so `lib/widgets` and `lib/screens` stay hex-free):

```dart
abstract final class PalakatIlustrasi {
  static const peruntukanKetiga = Color(0xFF86B5B8); // 3rd segment of BatangPembagian (Awal, Bagi, AlihPeruntukan)
  static const kertasNota = Color(0xFFFBFAF6);       // paper of the photographed receipt (Kamera, LihatDokumen, WebLihatDokumen)
  static const garisJawaban = Color(0xFFC9DAD9);     // 1px top rule inside the lautLembut answer card of Cari and WebCari
}
```

`#C9DAD9` is used only in `Cari.dc.html` line 41 and `WebCari.dc.html` line 67 (`border-top: 1px solid #C9DAD9` inside the answer card), not in A4Warta or WebWartaEditor as CONVENTIONS guessed.

### 1.3 Text

Family names must equal the `pubspec.yaml` font families: `PlusJakartaSans` (400, 500, 600, 700) and `IBMPlexMono` (400, 500, 600).

Boards set a line height once on the screen root and every element inherits the factor (CSS `line-height: 1.4`). Reproduce that with a root `DefaultTextStyle` and never set `height` on a child style unless the board does:

| Root | Style | Where |
| --- | --- | --- |
| Phone board | `PalakatText.isi` + `height: 1.4` | Every 390 × 844 board |
| Laptop and tablet board | `PalakatText.isiWeb` + `height: 1.45` | Every `Web*` and `Tab*` board |
| A4 page | sans 13, `height: 1.4` (A4Warta: 14, `height: 1.45`) | A4 boards |

Every root style also sets `leadingDistribution: TextLeadingDistribution.even` (CSS half-leading) and `color: warna.tinta`. A badge (13 px) inside a phone root therefore has a line box of 13 × 1.4 = 18.2, which is what gives the boards' badge height. Mono styles keep `FontFeature.tabularFigures()`.

`TextTheme` (both themes, colour `tinta` applied with `.apply(bodyColor:, displayColor:)`):

| TextTheme slot | Token style |
| --- | --- |
| headlineMedium | `judulHalaman` 26/700 |
| headlineSmall | `judulBesar` 22/700 |
| titleLarge | `judulLayar` 18/700 |
| titleMedium | `judulBagian` 16/700 |
| bodyLarge | `isi` 16/400 |
| bodyMedium | `pendamping` 14/400 |
| bodySmall | `keterangan` 13/400 |
| labelLarge | sans 16/700 (button text; inherits size on web: 15) |

Widgets use the `PalakatText` constants with `.copyWith(color: c.<token>)`. The boards' off-token sizes (17, 19, 20, 24, 30, 32, 34, 36, 38, 40, 56 px) are written as the board writes them.

### 1.4 `ThemeData`

`palakatTema(Brightness b)` returns Material 3 `ThemeData` with:

- `extensions: [b == Brightness.light ? PalakatWarna.terang : PalakatWarna.gelap]`
- `colorScheme` mapped as in `01-foundations.md` (kertas → surface, permukaan → surfaceContainerLowest, tinta → onSurface, tinta2 → onSurfaceVariant, putus → outline, garis → outlineVariant, laut → primary, diLaut → onPrimary, lautLembut → primaryContainer, bata → error, diBata → onError, bataLembut → errorContainer, diTinta → onInverseSurface, tinta → inverseSurface), from the matching palette. Note the copied `palakatTheme()` sets `onPrimary: permukaan`; use `diLaut` instead (same in light, different in dark).
- `scaffoldBackgroundColor: kertas`, `fontFamily: 'PlusJakartaSans'`, the text theme above.
- `splashFactory: NoSplash.splashFactory`, `highlightColor: Colors.transparent`, `hoverColor: Colors.transparent`: the boards have no ripple and no hover fill on buttons.
- `focusColor: Colors.transparent` (focus is drawn by `CincinFokus`, 1.6).
- Route transitions are set per route in `navigation.md` (child views use the `masuk` motion of `motion.md`); do not rely on the platform default page transition.
- `cardTheme`: `permukaan`, elevation 0, `RoundedRectangleBorder(radius 14, side 1 garis)` (kept for completeness; components below build their own boxes).
- `visualDensity: VisualDensity.standard`, `materialTapTargetSize: MaterialTapTargetSize.padded`.

### 1.5 Context extensions

```dart
extension PalakatKonteks on BuildContext {
  PalakatWarna get warna => Theme.of(this).extension<PalakatWarna>()!;
  /// True when the system asks for reduced motion or the Keadaan panel switch is on.
  bool get kurangiGerak => MediaQuery.disableAnimationsOf(this);
  /// Token duration, or zero under reduced motion.
  Duration gerak(Duration d) => kurangiGerak ? Duration.zero : d;
  /// CSS vw: percent of the window width (not the parent width).
  double vw(double persen) => MediaQuery.sizeOf(this).width * persen / 100;
  /// CSS clamp(min, <vw>vw, max).
  double jepit(double min, double vwPersen, double max) => vw(vwPersen).clamp(min, max);
}
```

Reduce motion from the Keadaan panel is applied once, at the app root: wrap the router's child in `MediaQuery(data: mq.copyWith(disableAnimations: mq.disableAnimations || prototipe.kurangiGerak))`. Every widget then reads one source.

### 1.6 Focus ring and the pressable base

Boards: `button:focus-visible, a:focus-visible, input:focus-visible { outline: 2px solid laut; outline-offset: 2px }`.

**`CincinFokus`** draws that ring. It paints only when the focus came from the keyboard (`FocusableActionDetector.onShowFocusHighlight`), never on touch or mouse. Geometry: the child's rounded rect inflated by 3 (2 offset + half of the 2 px stroke), corner radius = child radius + 3, stroke 2 `laut`. It is painted in a `Stack(clipBehavior: Clip.none)` so the ring is never clipped by the child.

**`Tekan`** is the base of every pressable thing in the prototype (buttons, chips, rows, links, tab items). It replaces `InkWell`.

```dart
class Tekan extends StatelessWidget {
  const Tekan({
    super.key,
    required this.onTap,          // VoidCallback?; null = really disabled (rare, see TombolBersyarat)
    required this.child,
    this.label,                   // String? → Semantics label (board aria-label)
    this.radius = 0,              // double, for the focus ring
    this.minLebar = 44,           // double
    this.minTinggi = 44,          // double
    this.dipilih,                 // bool? → Semantics selected (aria-pressed, selected tab)
    this.tercentang,              // bool? → Semantics checked / toggled (switch, checkbox)
    this.peran = PeranTekan.tombol, // tombol | tautan | sakelar
  });
}
```

It composes `FocusableActionDetector` (Enter and Space run `onTap`; `mouseCursor: SystemMouseCursors.click`), `GestureDetector(behavior: HitTestBehavior.opaque)`, `Semantics(button: peran == tombol, link: peran == tautan, toggled: …, selected: …, label: …)`, `ConstrainedBox(minWidth, minHeight)` and `CincinFokus`. No ink, no ripple, no press overlay: the boards show none. The only touch feedback on the boards is the colour change of a text link to `lautTua` (hover and press, `sentuh` 160 ms) and the switch track change (160 ms).

**`Tautan`** (CONVENTIONS) wraps `Tekan` and navigates:

```dart
Tautan({required String ke, required Widget child, String? label, double radius = 0, VoidCallback? diSini})
```

`ke` is the target board stem (`'WebTransaksi'`) or a child route (`'Main/catat'`). Whether it pushes or goes, and its Back behaviour, is decided in `navigation.md`. Every board link (`<a href>` and every JS-built link) is a `Tautan`; the link test greps for `Tautan(ke: '…')`.

**Self links** (`navigation.md` kind self): when `/<ke>` is the route open now, `Tautan` does not navigate (no second copy is pushed). It calls `diSini` instead, or does nothing when `diSini` is null. `diSini` is the in-board effect the screen spec gives the self link, for example `() => setState(() => k = null)` (on the canvas a self link reloads the board).

### 1.7 `GarisStatus`: the line language as code

```dart
enum GarisStatus { draf, dibukukan, terpilih, ditutup, usulanAI, hambatan }

extension GarisStatusGaya on GarisStatus {
  /// Border and fill for a card, badge or banner in this status.
  ({GarisBorder? garis, Color? isi}) gaya(PalakatWarna c, {double radius = 14}) => switch (this) {
    GarisStatus.draf      => (garis: GarisBorder.putus(c.putus, radius: radius), isi: null),
    GarisStatus.dibukukan => (garis: GarisBorder.penuh(c.garis, tebal: 1, radius: radius), isi: c.permukaan),
    GarisStatus.terpilih  => (garis: GarisBorder.penuh(c.tinta, radius: radius), isi: c.permukaan),
    GarisStatus.ditutup   => (garis: null, isi: c.tinta),
    GarisStatus.usulanAI  => (garis: GarisBorder.titik(c.laut, radius: radius), isi: c.permukaan),
    GarisStatus.hambatan  => (garis: GarisBorder.penuh(c.bata, radius: radius), isi: c.permukaan),
  };
}
```

Rules (not optional): a draft never has a fill (`transparent` on `kertas`); `ditutup` is used only for a closed month, an official report and a permanent statement; `usulanAI` always comes with italic `lautTua` text; `bata` is used for nothing but blockers and failures. In the dark theme `ditutup` becomes the light field because `tinta` is light there; nothing else changes.

---

## 2. Shared primitives (`widgets/`, `mock/`)

### 2.1 `GarisBorder`, `GarisPainter`, `GarisLurus`

Flutter has no dashed or dotted border, and the stack forbids `dotted_border`. One painter draws all of them.

**What the boards draw** (counted over all 199 boards):

| Line on the board | Count | Token | Where |
| --- | --- | --- | --- |
| `1.5px dashed` | 374 | `putus` | Every draft: cards, badges, rows, empty states, dashed buttons, bars |
| `1.5px dotted` | 28 | `laut` | AI suggestion cards and "Usulan AI" badges |
| `1px dotted` (top only) | 10 | `garisTegas` | Separator between AI suggestion rows: AIFoto, AIMataAnggaran, BantuanAI and their Web boards |
| `1px dashed` (top only) | 8 | `garisTegas` | "Dicatat oleh … Pernyataan Bendahara" rule in KartuPersetujuan: Bendahara, FormatLaporan, Koreksi, Persetujuan, WebFormatLaporan, WebKoreksi, WebLaporan, WebPersetujuan |
| `1px dashed` (top only) | 8 | `tinta3` | Rules on the photographed receipt (Kamera, LihatDokumen, WebLihatDokumen, AIFoto) |
| `1.5px dashed` | 1 | `garisTegas` | The toast in Main |
| `1.5px dashed` | 1 | `tinta3` | Provisional banner on A4Sementara |
| `1.5px dashed` | 1 | `tinta` | "tunggu" step circle in Awal |
| `1.5px dashed` | 1 | `bata` | Empty required amount cell in WebAwal (with `bataLembut` fill) |

**Dash geometry.** The boards are rendered by Chrome, which draws a CSS dashed border with dashes 3 × the width and gaps 2 × the width (for widths under 3 px), and a dotted border with square dots 1 × the width and gaps 1 × the width, then stretches the gaps so the pattern fits the edge evenly. Use these patterns:

| Style | Width | Dash | Gap | Cap |
| --- | --- | --- | --- | --- |
| `GayaGaris.putus` (dashed) | 1.5 | 4.5 | 3 | butt |
| `GayaGaris.putus` (dashed) | 1 | 3 | 2 | butt |
| `GayaGaris.titik` (dotted) | 1.5 | 1.5 | 1.5 | butt (square dots) |
| `GayaGaris.titik` (dotted) | 1 | 1 | 1 | butt |
| `GayaGaris.penuh` (solid) | any | — | — | — |

Fitting rule (one line of maths, applied per closed path or per straight line): `n = max(1, (panjang / (dash + gap)).round())`, then `gap' = panjang / n - dash` (closed path) or `gap' = (panjang - dash) / max(1, n - 1) - dash` with `n = ((panjang + gap) / (dash + gap)).round()` (open line, so it starts and ends with a dash). The design-system Cover draws its draft tiles with `stroke-dasharray: 4 3` at 1.5: the same look.

**API.**

```dart
enum GayaGaris { penuh, putus, titik }

class GarisBorder extends OutlinedBorder {
  const GarisBorder({required this.warna, this.tebal = 1.5, this.gaya = GayaGaris.penuh,
                     this.radius = BorderRadius.zero, super.side = BorderSide.none});
  const GarisBorder.penuh(Color warna, {double tebal = 1.5, double radius = 0});
  const GarisBorder.putus(Color warna, {double tebal = 1.5, double radius = 0});
  const GarisBorder.titik(Color warna, {double tebal = 1.5, double radius = 0});
  // dimensions => EdgeInsets.all(tebal): CSS border-box, padding sits inside the line.
  // paint(): RRect of the rect deflated by tebal/2, stroke width tebal; penuh draws the
  //          RRect, putus/titik draw it through GarisPainter.dashPath().
  // lerp, copyWith, scale: straightforward.
}

abstract final class GarisPainter {
  /// Dashes [sumber] with the pattern of [gaya]/[tebal], fitted as above (PathMetrics.extractPath).
  static Path dashPath(Path sumber, GayaGaris gaya, double tebal, {bool tertutup = true});
}

/// A one-sided rule: CSS border-top/border-bottom. Full width, height = tebal.
class GarisLurus extends StatelessWidget {
  const GarisLurus({super.key, required this.warna, this.tebal = 1, this.gaya = GayaGaris.penuh});
}
```

Use it as `DecoratedBox(decoration: ShapeDecoration(shape: GarisBorder.putus(c.putus, radius: 14), color: null))`, or through `Kartu` (2.8). A rounded `GarisBorder` with `gaya: penuh` is equivalent to `RoundedRectangleBorder(side:)` and may be used for every solid border too, so all boxes share one code path.

SVG dash arrays (the logo `3 3`, the circles `5 6`, `6 7`, `9 10`, `5 5`) are drawn by `flutter_svg` from the board markup (section 5). A widget test renders the logo and checks it paints; if `flutter_svg` ever ignores `stroke-dasharray`, draw those shapes with `GarisPainter` instead.

### 2.2 Formatters (`mock/format.dart`)

The boards all use the same `rp()`:

```js
rp(n) { var s = String(Math.abs(Math.round(n))).replace(/\B(?=(\d{3})+(?!\d))/g, '.'); return (n < 0 ? '−' : '') + 'Rp' + s; }
```

See mock-data.md 4.1 for the whole `format.dart` API (names, signatures, defaults). No `intl`. The flow boards' `HARI = 20261116` is `hari` there.

`test/format_test.dart`: `rp(-15000) == '−Rp15.000'`, `rp(1250000) == 'Rp1.250.000'`, `rp(0) == 'Rp0'`, `rp(999) == 'Rp999'`, `tgl(DateTime(2026,10,6)) == '06/10/2026'`, `tglPanjang(DateTime(2026,10,6)) == '6 Oktober 2026'`, `jam(DateTime(2026,1,1,11,5)) == '11.05'`.

### 2.3 Rupiah input formatter

Boards (three variants of one handler):

```js
e.target.value.replace(/\D/g, '').replace(/^0+/, '').slice(0, N)        // 17 handlers: "0" alone is cleared
e.target.value.replace(/\D/g, '').replace(/^0+(?=\d)/, '').slice(0, N)  // 15 handlers: a single "0" stays (Kas kosong, Rp0 rows)
e.target.value.replace(/\D/g, '').slice(0, N)                           // phone numbers and codes: digits only, leading zeros kept
```

`N`: 11 on most amount fields; 12 on Main, WebCatat, TabCatat, WebAwal and the statement-balance field of RekonIsi/WebRekonIsi; phone 13, date 10, code 6. Also 10 on `batas` of UbahPengaturan/WebUbahPengaturan, 5 on the piece counts of WebHitungKas, 4 on `akhir` of UbahPengaturan/WebUbahPengaturan. Dates use the filter of 2.4. Phone and code fields keep their leading zeros, so they do not go through `RupiahInputFormatter`.

and display with `jumlah.replace(/\B(?=(\d{3})+(?!\d))/g, '.')`.

```dart
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter({this.sisakanNol = false, this.maks = 11});
  final bool sisakanNol; // true = /^0+(?=\d)/ variant
  final int maks;        // N above: 12 and 10 only on the fields listed
  // formatEditUpdate: titik(hanyaAngka(newValue.text, max: maks, simpanNol: sisakanNol))
  // (mock-data.md 4.1), selection collapsed at the end. Empty stays empty.
}
int? angkaDari(String teks); // '1.250.000' → 1250000, '' → null (not filled is not zero)
```

Keyboard `TextInputType.number`. Each screen's spec says which variant its board uses.

### 2.4 Date input `hh/bb/tttt`

The boards do not insert slashes: the person types them. Tanggal and WebTanggal filter while typing, and the flow boards parse on every keystroke:

```js
onDok: function (e) { self.setState({ dokTeks: e.target.value.replace(/[^\d\/]/g, '').slice(0, 10) }); }
var tgl = function (t) { var m = /^(\d\d)\/(\d\d)\/(\d{4})$/.exec((t || '').trim()); if (!m) return null;
  var d = +m[1], b = +m[2]; if (b < 1 || b > 12 || d < 1 || d > 31) return null; return (+m[3]) * 10000 + b * 100 + d; };
```

```dart
class TanggalInputFormatter extends TextInputFormatter { // keeps [0-9/], at most 10 characters
  const TanggalInputFormatter();
}
/// Same rules as the boards' tgl(): exactly dd/mm/yyyy, month 1–12, day 1–31 (no month-length check).
int? bacaTgl(String t); // in format.dart (mock-data.md 4.1): '30/11/2026' → 20261130, '31/02/2026' → 20260231, '3/11/2026' → null
```

Placeholder `hh/bb/tttt` in `tinta3`; `TextInputType.datetime`. "Checked while typing" means the screen recomputes its `TombolBersyarat` reason from `bacaTgl` on every change; the reason sentences (for example "tanggal berakhir tidak dikenali. Contoh: 30/11/2026.") are in each screen spec. Date fields on the boards: 16 inputs on AlurAnggota, AlurDokumen, AlurIbadah, AlurKeluarga, AlurMasuk, AlurPanitia, AlurPelimpahan, AlurPenugasan, AlurPeristiwa, AlurWarta, Tanggal, WebAlurDokumen, WebAlurKeluarga, WebAlurMasuk, WebAlurWarta, WebTanggal. Style: `IsianTeks` (2.8); Tanggal's has `font-family: mono; max-width: 220px`.

Test: `bacaTgl` accepts `'16/11/2026'`, rejects `'16-11-2026'`, `'16/13/2026'`, `'00/11/2026'`, `' 16/11/2026 '` is accepted (trimmed).

### 2.5 `PalakatIkon`

The icons are inline SVG drawn one by one on the boards (section 5). Render the boards' own markup with `flutter_svg`, tinted by tokens.

```dart
@immutable
class IkonData {
  const IkonData({required this.viewBox, required this.isi, this.akar = '', this.tebal});
  final String viewBox; // '0 0 24 24'
  final String akar;    // attributes of the root <svg>, may contain {warna} and {tebal}
  final String isi;     // inner markup; colours are placeholders {warna} {laut} {diLaut} {bata} {diBata} {tinta} {tinta2} {tinta3} {putus} {garis} {permukaan}
  final double? tebal;  // default stroke width substituted for {tebal}
}

class PalakatIkon extends StatelessWidget {
  const PalakatIkon(this.ikon, {super.key, this.ukuran = 22, this.warna, this.tebal, this.label});
  final IkonData ikon;
  final double ukuran;  // width = height, as the board's width/height attributes
  final Color? warna;   // fills {warna}; default = DefaultTextStyle colour (CSS currentColor)
  final double? tebal;  // overrides ikon.tebal
  final String? label;  // board aria-label + role="img" → Semantics(image: true, label); null → ExcludeSemantics (aria-hidden)
}
```

Build: assemble `<svg xmlns="http://www.w3.org/2000/svg" viewBox="…" width="u" height="u" akar>isi</svg>`, replace each `{token}` with the hex of `context.warna.<token>` (`'#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'`, computed at runtime, so no hex literal leaves `lib/theme/`), replace `{warna}` and `{tebal}`, and draw with `SvgPicture.string`. Cache the resolved string per (ikon, warna, tebal, theme). Drop the boards' `style="animation…"` attributes: animated icons are driven from `lib/motion/` (5.3).

### 2.6 Logo: `TandaPalakat` and `KataPalakat`

The mark is the same inline SVG on 89 boards (88 at 26 px, 2 at 40 px): a dashed rounded square whose right half is filled, "a draft becoming a book". It is `Ikon.tanda` (5.1); its colour is `laut`, so the dark theme's light `laut` gives the `palakat-mark-terang` reading the design system describes (the SVG files themselves are not in the handoff; the board markup is the source).

```dart
class TandaPalakat extends StatelessWidget { const TandaPalakat({super.key, this.ukuran = 26}); } // aria-hidden
class KataPalakat extends StatelessWidget {  // word mark: 'palakat', lower case
  const KataPalakat({super.key, this.ukuran = 18, this.jarakHuruf = 0, this.tinggiBaris = 1.1});
}
```

| Where | Mark | Word mark | Beside it |
| --- | --- | --- | --- |
| Side nav brand (86 web and tablet boards) | 26, gap 10, padding `0 8` | 18/700, line height 1.1 | below the word mark: "Jemaat Karunia" 13 `tinta3` |
| Phone Beranda header (Main) | 26, gap 10 | none | "Jemaat Karunia" 17/700 |
| Awal (phone) | 26, gap 10 | 17/700 | — |
| Masuk, WebMasuk sign-in card | 40, gap 12 | 30/700, letter spacing −0.5 | — |

Inside a sentence the name is written "Palakat" (capital P).

### 2.7 Layout helpers for laptop pages

The laptop boards are CSS flex-wrap and auto-fit grids. Two small widgets reproduce them without intrinsic measurement (a `LayoutBuilder` inside an intrinsic pass throws, so never wrap these in `IntrinsicHeight`).

**`BarisLentur`** = `display: flex; flex-wrap: wrap; gap: g; align-items: flex-start`, children with `flex: grow 1 basis` and optional `max-width`.

```dart
class BarisLentur extends StatelessWidget {
  const BarisLentur({super.key, required this.anak, this.jarak = 24, this.jarakBaris, this.rata = CrossAxisAlignment.start});
  final List<Lentur> anak;
  final double jarak;        // column gap
  final double? jarakBaris;  // row gap, defaults to jarak (CSS `gap: 20px 28px` = jarakBaris 20, jarak 28)
}
class Lentur {
  const Lentur({required this.dasar, this.tumbuh = 1, this.maks, required this.child});
  final double dasar;   // flex-basis px
  final double tumbuh;  // flex-grow (999 for "main", 1 or 1.3 for "aside")
  final double? maks;   // max-width
  final Widget child;
}
```

Algorithm (LayoutBuilder, width W): put items on a line while the sum of bases plus gaps fits in W; an item wider than W alone takes W. On each line, share `W − Σbasis − gaps` by `tumbuh`, clamp each to `maks`, give each child a tight width. Lines stack with `jarakBaris`. This is exactly what decides when an `aside` drops below its `main` (for example `flex: 999 1 520px` + `flex: 1 1 360px` + gap 24 → side by side from 904 px of content width).

**`KisiOtomatis`** = `grid-template-columns: repeat(auto-fit, minmax(min(X, 100%), 1fr)); gap: g`.

```dart
class KisiOtomatis extends StatelessWidget {
  const KisiOtomatis({super.key, required this.minLebar, required this.anak, this.jarak = 12, this.jarakBaris});
}
```

Columns `n = max(1, ((W + jarak) / (minLebar + jarak)).floor())`, then `n = min(n, anak.length)` (auto-fit collapses empty tracks), each column `(W − jarak·(n−1)) / n`, rows of `n`, row height = tallest child (`Row(crossAxisAlignment: start)` per row; boards use `align-items: start`).

Used by every laptop board (main/aside rows, Beranda figure tiles `minmax(min(150px,100%),1fr)`, panels `minmax(min(360px,100%),1fr)`).

### 2.8 Small recurring pieces

These are not design-system components, but every screen spec assumes them.

**`Kartu`** – the card box.

```dart
class Kartu extends StatelessWidget {
  const Kartu({super.key, required this.child, this.status = GarisStatus.dibukukan, this.radius = 14,
               this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14), this.isi});
  final Color? isi; // overrides the status fill (lautLembut info cards, bataLembut failure cards)
}
```

Boards: `background: permukaan; border: 1px solid garis; border-radius: 14px` (thousands of uses), paddings `14px 16px`, `12px 14px`, `16px`, `18px`, `4px 16px` (row lists), `0 16px` (lists of 60-high rows). A selected card adds `border: 1.5px solid tinta` (`terpilih`). Large cards and panels use radius 16 (`kartuBesar`) and the AI panels and sign-in cards 18.

**`BarisDaftar`** – a list row inside a `Kartu` with `padding: 0 16px`: `min-height: 60px; gap: 12px; border-top: 1px solid garis` (none on the first row), a title 600 (15 on phone), a caption 13 `tinta3`, and a trailing `Ikon.lanjut` 18 `tinta3`. Built on `Tekan` or `Tautan`, full width.

**`JudulBagian`** – section heading: phone `h2` 16/700, web `h2` 17/700, margin 0. Optional `Hitungan` after it, gap 8.

**`Hitungan`** – the blocker/action counter: `bata` fill, `diBata` text 13/700, `border-radius: 999px; min-width: 22px; height: 22px; padding: 0 6px`, centred. Used next to "Perlu tindakan" (Main, WebBeranda, TabBeranda, BerandaJabatan, KotakMasuk …) and "Hambatan" (TutupBuku). (TutupBuku's has no horizontal padding.)

**`TautanTeks`** – an inline text link. Browser default for `<a>` without `text-decoration: none`: `laut`, underlined (thickness 1, same colour), weight as given (600 in link rows, 700 in some), turns `lautTua` on hover and press (160 ms). Inside a `Tautan` or `Tekan` with a 44 × 44 minimum.

**`DeretTautan`** – the row of text links under a heading: `display: flex; flex-wrap: wrap; gap: 0 22px; font-size: 14px; font-weight: 600; margin: -8px 0` (phone; web `margin-top: -8px`), each link `min-height: 44px; min-width: 44px`. Example (Main): "Rekonsiliasi" → TutupBuku, "Buat laporan sementara" → Laporan.

**`IsianTeks`** – the one-line input: `min-height: 48px; padding: 0 14px; border-radius: 12px; border: 1px solid garisTegas; background: permukaan` (search fields use `background: kertas`), label above `font-size: 14px; color: tinta2; margin-bottom: 8px` (6 in flow boards), placeholder `tinta3`. Built on `TextField` with `InputDecoration.collapsed` inside a `DecoratedBox`, so the box is the board's and Material adds nothing. Focused: the 2 px `laut` ring of 1.6 (no Material focus underline).

**`KotakCentang`** (checkbox) and **`PilihanBulat`** (radio). Boards use native inputs: checkbox `24 × 24` (22 in one place), `accent-color: laut`, inside `label { display: flex; gap: 12px; align-items: flex-start; min-height: 44px; font-size: 14px }` (17 places: AlurAnggota, AlurJabatanKosong, AlurKeluarga, AlurNama, AlurPulihkan, CabutIzin, JabatanKosong, PermohonanAnggota, TutupBuku and others); radio `22 × 22` in TampilanNama rows. Draw them: checkbox radius 4, unchecked 1.5 `garisTegas` on `permukaan`, checked `laut` fill with `Ikon.centang` 16 in `diLaut`, stroke 3; radio unchecked 1.5 `tinta3` ring, checked 6 px `tinta` ring (as the TampilanNama preview). The whole label row is the `Tekan` target (CONVENTIONS).

**`Pesan`** – the confirmation after an action in flow boards (30 places): `role="status"`, `background: lautLembut; border-radius: 12px; padding: 12px 14px; font-size: 14px`. Semantics `liveRegion: true`. `Pesan(child, {bool siaran = true})`: `siaran: false` drops the live region, for the notice box of 2.9.

**`Toast`** – only Main has one (5.4).

### 2.9 `KitAlur`: the parts of the flow boards (`widgets/alur_kit.dart`)

Built in **M1**, in `lib/widgets/alur_kit.dart`. The typed "Alur" flows and the `keadaan` boards beside them (screen specs 15, 16, 19, 21, 22 and 23, phone and web) draw one set of parts with the same inline values. Screen units use these parts as they are. They never redefine them and never edit `alur_kit.dart` (README, "Working in parallel"). A screen spec lists only where its boards differ. The values are the boards' own, checked on AlurMasuk, AlurPenugasan, AlurUnit, AlurSurat, AlurAnggota and PermintaanDana. "Body size" is inherited: 16 on phone, 15 on web.

Most parts are existing widgets with fixed arguments. The kit adds five small classes:

```dart
class IsianAlur extends StatelessWidget {
  const IsianAlur({super.key, required this.label, required this.controller, this.onChanged,
      this.petunjuk, this.keterangan, this.baris = 1, this.keyboard = TextInputType.text,
      this.formatter = const [], this.hanyaBaca = false});
  final String label;                        // 14 tinta2, verbatim: 'Nomor ponsel', 'Alasan · wajib'
  final String? petunjuk;                    // placeholder, 14 tinta3: '08…', 'hh/bb/tttt'
  final String? keterangan;                  // hint under the input, 13 tinta3: 'Contoh: 081234567890'
  final int baris;                           // 1 = input, 3 = textarea
  final List<TextInputFormatter> formatter;  // as the screen spec says; most flow date fields have none
}
class BarisTombol extends StatelessWidget {
  const BarisTombol({super.key, required this.anak}); // buttons, each flex 1 1 150, max 340
}
class KepalaKartu extends StatelessWidget {
  const KepalaKartu({super.key, required this.judul, this.ujung}); // ujung: a LencanaStatus or a mono amount
}
class BarisInfo extends StatelessWidget {
  const BarisInfo(this.label, this.nilai, {super.key, this.mono = false, this.berat = FontWeight.w600});
}
/// Prototype device: goes in AlatPrototipe.alat (4.9), never on the screen.
class DilihatSebagai extends StatelessWidget {
  const DilihatSebagai({super.key, required this.pilihan, required this.terpilih, required this.onPilih});
  final List<String> pilihan;   // the board's actors, in board order
  final String terpilih;        // the board's `akt`
  final ValueChanged<String> onPilih; // the board's `pick`
}
```

| Part (names the specs use) | Build with | Board values |
| --- | --- | --- |
| Phone header (K1) | `KepalaPonsel(judul:, anakJudul:, kembaliKe:, labelKembali:)` (4.1) | Row, centred, gap 8, padding 14 12 8, no fill, no rule; it does not scroll. Back target 44 × 44 with the chevron 22 (`M15 6l-6 6 6 6`, stroke 2, round caps, `tinta`). h1 18/700, margin 0. Subtitle 13 `tinta2` (the board writes 14 then 13; 13 wins). |
| Phone body (K2) | `LayarPonsel` body (4.1) | Scrolls. Padding 8 20 20. One column with gap 16 between every block, so the content is 350 wide. `sc-if` and `sc-for` add no wrapper, so every listed block is 16 from the next. |
| Field and textarea (K6, K6t) | `IsianAlur` | The label wraps everything: a column with gap 6, label 14 `tinta2`. Tapping the label focuses the input. Input: full width, min height 48, padding 0 14, radius 12, 1 `garisTegas`, `permukaan`. Typed text is sans 14 `tinta2` on phone and web: the board's `input{font:inherit;color:inherit}` takes the label's size and colour, so it is not body size `tinta`. Placeholder 14 `tinta3`. Hint 13 `tinta3` under the input. `baris: 3` is the textarea: padding 12 14, min height 96, 3 rows, no resize, no placeholder, no hint. Build it as `IsianTeks` (2.8): `InputDecoration.collapsed` inside the board's box, with the focus ring of 1.6. A read-only field (`hanyaBaca`) keeps the same look. |
| Chip group (K7, pill group) | `ChipPilihan(…, jarakLabel: 6)` (3.4) | Caption 14 `tinta2`, column gap 6, chips in a wrap with gap 8. Chip: min height 44, padding 0 14, radius 999, 600/14, 1.5 line. Selected: `tinta` fill and line, `permukaan` text. Unselected: `permukaan` fill, `garisTegas` line, `tinta` text. `aria-pressed` becomes selected semantics. A chip never deselects. Whether a pick clears `pesan` is per board. |
| Refusal line (K8, Penolakan) | `Penolakan(tindakan:, sebab:, jalan: const [], ukuranTeks: 14)` (3.3) | One paragraph at 14 px: "Tidak dapat dilakukan: {tindakan}." in 700 `bata`, a space, then the cause in 400 `tinta`. It is its own block in the body column, so it sits 16 above its button row (not at TombolBersyarat's own 6–8 gap). When it shows is per board. The board gives it no live region; add `liveRegion` semantics. |
| Conditional button | `TombolBersyarat(…, sudahMulai: false, warnaSiap: JenisTombol.tinta)` (3.3) | Min height 52, radius 14, no line, 700 body size, centred, padding 0 16. Met: `tinta` fill, `permukaan` text. Unmet: `garis` fill, `tinta2` text. `sudahMulai: false` because the refusal line above draws the sentence. Unmet, it stays focusable and pressable (`aria-disabled`, never `onPressed: null`), with the reason as its hint. A press re-reads the latest input (the controller text) and acts only when the condition holds. Pressing while unmet does nothing: no message, no shake. The first press after the input becomes valid works. |
| Primary, ink button | `Tombol(jenis: JenisTombol.tinta)` | As the met conditional button. |
| Secondary, outline button | `Tombol(jenis: JenisTombol.kedua, ukuran: UkuranTombol.sedang)` | Min height 48, radius 14, 1.5 `tinta` line, `permukaan`, `tinta` 700, centred, padding 0 16. |
| Text button | `Tombol(jenis: JenisTombol.teks, ukuran: UkuranTombol.kecil)` | Min height 44, no line, no fill, `laut` 700, centred, padding 0 16. |
| Link-button | the same button with `ke:` | The button's look, no underline. The label is centred and may wrap to two lines. |
| Button row (K9) | `BarisTombol` | Wrap, gap 8 both ways, start-aligned. Each button is `flex: 1 1 150px; max-width: 340px`. Lines break as in `BarisLentur` (2.7) with `Lentur(dasar: 150, tumbuh: 1, maks: 340)` and `jarak: 8`. Each line is an `IntrinsicHeight` around a `Row(crossAxisAlignment: stretch)`, so the buttons on one line take the tallest one's height (CSS `align-items: stretch`): a 48 secondary or a 44 text button beside a 52 button is 52, label centred. This is safe because buttons hold no `LayoutBuilder`. A label longer than its button wraps to centred lines and the button grows. Phone (350): one button is 340, two are 171 each, a third wraps to its own line at 340. Web right column (484): three fit at about 156 each. |
| Button outside a row (K10 alone, "intrinsic") | `Align(alignment: AlignmentDirectional.centerStart, child: Tombol(…, lebarPenuh: false))` | The board's `align-self: flex-start`: start-aligned and as wide as its label. |
| Card (K4, fact card) | `Kartu` (2.8), status `dibukukan` | `permukaan`, 1 `garis`, radius 14, content in a column with gap 6. Padding 14 16; 12 16 for list cards where the spec says so. |
| Card head row | `KepalaKartu` | Row, space-between, centred, gap 16. Title 700 body size; it wraps. On the right a badge, or an amount in IBM Plex Mono 500 body size; it never shrinks or wraps. |
| Info row (key–value, fact row) | `BarisInfo` | Space-between, gap 16, 14 px. Label `tinta2` on the left. Value right-aligned, 600 `tinta`. `mono: true` for money and phone numbers (IBM Plex Mono; `berat: FontWeight.w500` where the spec says). Used inside a card or loose. |
| Plain line, caption, footnote (K12) | `Text` | Plain line 14 `tinta2`. Caption and footnote 13 `tinta3`. |
| Dashed box | `Kartu(status: GarisStatus.draf)` | 1.5 dashed `putus`, radius 14, no fill, padding 14 16, column gap 6. |
| Dashed note | `Kartu(status: GarisStatus.draf)`, padding 12 14 | As the dashed box, at 14 px, one paragraph: a bold `tinta` lead, a space, then the rest in `tinta2`. |
| Terpilih note | `Kartu(status: GarisStatus.terpilih, radius: 12)`, padding 12 14 | 1.5 `tinta` line, radius 12, `permukaan`, 14 px. Its first run is 700. |
| Message banner (K3, status note, `pesan`) | `Pesan` (2.8) | `role="status"` live region. `lautLembut`, radius 12, padding 12 14, 14 `tinta`. No line, no icon, no auto-dismiss. Shown while `pesan` is not empty; only a handler clears or replaces it. |
| Notice box | `Pesan(siaran: false)` (2.8) | The banner's box without the live region: a bold lead, then plain text. |
| Badge (K5, status chip) | `LencanaStatus(label, bentuk:)` (3.2) | 13/700, radius 6, padding 3 9, 1.5 line, `flex: none`, no wrap. Board `LS` key to `bentuk`: `draf` → `draf`, `garis` → `garis`, `tinta` → `tinta`, `laut` → `laut`, `lautg` → `lautGaris`, `bata` → `bata`, `abu` → `abu` (colours in 3.2). |
| Riwayat (K11) | `RiwayatAlur(baris: riw)` (3.8) | Only when there is at least one row. h2 "Riwayat" 16/700, margin 0. Card `permukaan`, 1 `garis`, radius 14, padding 4 16, rows in a column with no gap. Row: padding 8 0, 1 `garis` top rule, margin-top −1, 13 `tinta3`. Newest first; every row starts "16/11/2026 · ". The first row's rule is drawn too, 3 px under the card's top edge, inset 16. |
| Text link | `TautanTeks` (2.8) | 14/700, `laut`, underlined, `lautTua` on hover and press. Min height 44, label vertically centred and left-aligned. It is `inline-flex` inside a flex column, so it stretches to the column width and the whole strip is the target. |
| "Dilihat sebagai" | `DilihatSebagai` in `AlatPrototipe.alat` (4.9) | A prototype device, never built on the screen. On the board it is the body's first block: the label "Dilihat sebagai" (14 `tinta2`) and one chip per actor. In the panel it is that label and a `ChipPilihan` with the board's actors, the current actor selected, `onPilih` calling the board's `pick`. The screen body starts with the block after it, with no empty gap. What `pick` keeps or clears is per board. |

Test `test/alur_kit_test.dart`: at width 350, `BarisTombol` lays out one button at 340, two at 171 each, and a third on a new line at 340; a text button beside a `TombolBersyarat` is 52 tall; `IsianAlur` shows typed text at 14 `tinta2`; `RiwayatAlur` with one row paints a rule 3 px under the card's top edge.

---

## 3. The 31 components (`widgets/`)

Every component: one file `widgets/<snake_name>.dart`, class name = component name. Each has a widget test per variant (section 6). "Boards" lists the boards on which the component (or its board form) appears, found by searching the board sources.

### 3.1 Foundations

#### GarisStatus

A rule, implemented as the `GarisStatus` enum of 1.7 and the `GarisBorder` of 2.1. No widget.

Gallery entry mirrors `GarisStatus/preview.html`: three 1.5-bordered cards (radius 16, padding 20, gap 6) for draf (`−Rp1.250.000` mono 28/500 `tinta2`, badge "Draf · belum masuk saldo"), dibukukan (`tinta` 1.5 line on `permukaan`, badge "Dibukukan" and the stamp `BKU-2026-0101`: mono 13/600 `laut`, 2 px `laut` line, radius 8, padding `3px 8px`, rotated −3°), ditutup (`tinta` field, badge "Sudah ditutup" in `permukaan` field with `tinta` text, "Oktober 2026", sentence in `diTinta2`); then six tiles (radius 12, padding `10px 12px`, min height 64) for the six lines.

Boards: every board.

#### Gerak

`PalakatMotion` durations and curve from the tokens; the Flutter implementations of the boards' keyframes live in `lib/motion/` and are specified in `motion.md`. Rules: motion only when the status of money changes; every motion completes instantly and pulses stop under reduced motion (`context.kurangiGerak`); upload, save and report generation always look in progress, success is never shown before it happened (the prototype's fake `Future.delayed` timers decide when).

Gallery entry mirrors `Gerak/preview.html`: four demos (tinta sweep + `cap` stamp on a 1.5 `tinta` card; `kait` two cards `dariKiri`/`dariKanan` meeting with a 26 `laut` dot; `segel` field darkening with the circle and lock; upload bar `isi` 1.2 s) and a "Putar ulang" button (44 high, radius 12, 1.5 `tinta`).

### 3.2 Status

#### LencanaStatus

```dart
enum BentukLencana { draf, garis, tinta, laut, lautGaris, bata, abu, peran, usulanAI, terbalik }

class LencanaStatus extends StatelessWidget {
  const LencanaStatus(this.label, {super.key, required this.bentuk, this.kepala = false, this.jarakHuruf = 0});
  /// The seven glossary statuses of a transaction, month or reconciliation, with their fixed shape.
  factory LencanaStatus.uang(StatusUang s);
  final String label;          // glossary word, verbatim
  final BentukLencana bentuk;
  final bool kepala;           // header variant, see below
  final double jarakHuruf;     // Main's transaction list adds .3
}
enum StatusUang { draf, sudahDiperiksa, dibukukan, sudahDitutup, dibalik, belumDitutup, sedangDikerjakan, dibatalkan, sudahDipastikan, perluDipastikanLagi }
```

Shapes. The 86 round-2–5 boards share one style map (`LS = {draf, garis, tinta, laut, lautg, bata, abu}`); the names below follow it.

| `bentuk` | Line | Fill | Text | Board key |
| --- | --- | --- | --- | --- |
| `draf` | 1.5 dashed `putus` | none | `tinta2` | `LS.draf` |
| `garis` | 1.5 solid `tinta3` | `permukaan` | `tinta2` | `LS.garis` |
| `tinta` | 1.5 solid `tinta` | `tinta` | `permukaan` | `LS.tinta` |
| `laut` | 1.5 solid `laut` | `laut` | `diLaut` | `LS.laut` |
| `lautGaris` | 1.5 solid `laut` | `permukaan` | `laut` | `LS.lautg` |
| `bata` | 1.5 solid `bata` | `permukaan` | `bata` | `LS.bata` |
| `abu` | 1.5 solid `garis` | `garis` | `tinta2` | `LS.abu` |
| `peran` | 1.5 solid `tinta` | `permukaan` | `tinta` | post chips in BertindakSebagai, "Sedang dipakai", "T2 dan T3" |
| `usulanAI` | 1.5 dotted `laut` | none | `lautTua` | AI badges, padding `2px 8px` |
| `terbalik` | none | `permukaan` | `tinta` | "Sudah ditutup" sitting on a `tinta` field |

Measurements: text 13/700 (`keterangan` bold), line height inherited from the root (18.2 on phone, 18.85 on web), `border-radius: 6px`, padding `3px 9px` inside the 1.5 line (outer = 4.5 × 10.5 around the text). `usulanAI`: padding `2px 8px`. `kepala: true` (badge in a screen header or on a dark field): no line, padding `4px 10px`, `margin-right: 8px` when it ends a phone header. Never wraps (`softWrap: false`) when the board says `white-space: nowrap`; `flex: none` in rows.

`LencanaStatus.uang` mapping (fixed, from `02-components.md`): Draf → `draf`; Sudah diperiksa → `lautGaris`; Dibukukan, Sudah ditutup → `tinta`; Dibalik, Belum ditutup, Sedang dikerjakan → `garis`; Dibatalkan → `abu`; Sudah dipastikan → `laut`; Perlu dipastikan lagi → `bata`.

Words and shapes as drawn on the boards (use these when a screen shows the word; the screen spec repeats the exact one):

| Shape | Words on the boards |
| --- | --- |
| `draf` | Draf; Draf · belum masuk saldo; Belum dikonfirmasi; Belum diterbitkan; Menunggu persetujuan; Menunggu verifikasi wewenang; Sementara; Tanpa nama; Tidak aktif |
| `garis` | Dibalik; Belum ditutup; Oktober 2026 · Belum ditutup; Sedang dikerjakan; Diajukan; Belum ditindaklanjuti; Dihitung dari data; Lolos pengecekan; Menunggu Anda; Menunggu konfirmasi Penatua; Menunggu verifikasi; Persetujuan sudah dicatat; Sedang diunggah…; Terlampir; Tidak diperlukan; Hanya baca; Selesai (one place); Kolom 7; Nama keluarga; BIPRA + Kolom; Novita Wenas |
| `tinta` | Dibukukan; Dibukukan · transaksi asal; Sudah ditutup; Ditutup; Diterbitkan; Ditetapkan; Tercatat; Revisi 2; Meninggal dunia; T1 jalur pertama; the tree badge Belanja / Pendapatan (`kepala`) |
| `laut` | Sudah dipastikan; Aktif; Disetujui; Disetujui oleh {nama}; Diverifikasi; Sedang berlangsung; Wewenang Bendahara aktif (`kepala`) |
| `lautGaris` | Sudah diperiksa; Dijadwalkan |
| `bata` | Perlu dipastikan lagi; Jabatan kosong; Belum ada; Wajib, belum ada; Dikembalikan; Kemungkinan data ganda; Tidak disetujui; Tidak diterbitkan; Tidak diterima; counters "2", "4" |
| `abu` | Dibatalkan; Berakhir; Diarsipkan; Digantikan oleh revisi 2; Selesai; Tidak ditampilkan |
| `usulanAI` | Usulan AI; Usulan AI · dari foto; Usulan AI · narasi bulanan; Usulan AI · penjelasan; Usulan AI · ringkasan |

Rules (not optional): the shape follows the status, never a free colour; Dibalik always sits with the line "Dibalik oleh No. Bukti …" (13 `tinta2`); there is no "Approve" status; an approval made in the app is "Disetujui oleh {nama}".

Accessibility: plain text, read as its word. No tap target.

Boards: all finance lists and details (Main, Koreksi, LihatTransaksi, Draf, Bukti, WebTransaksi, WebKoreksi …), every round-2–5 board (the `LS` map is in 86 boards), the AI boards (`usulanAI`).

**Boards vs preview:** the preview shows only the seven finance statuses; the boards use the same shapes for about 60 other words (table above), add the `abu` line (`border: 1.5px solid garis` on `garis` fill; the preview's Dibatalkan has no visible line, same look), and use the header form `4px 10px` without a line (Main detail, Koreksi, Terbatas, MataAnggaran, Bagi).

#### LencanaModul

Same widget as LencanaStatus (`typedef`-free: build `LencanaStatus` with these shapes; keep a thin `LencanaModul` class so screens name the concept):

```dart
enum KeadaanModul { aktif, tidakAktif, hanyaBaca }
enum KeadaanJabatan { aktif, berakhir, jabatanKosong }
class LencanaModul extends StatelessWidget {
  const LencanaModul.modul(KeadaanModul k, {super.key});   // Aktif → laut, Tidak aktif → draf, Hanya baca → garis
  const LencanaModul.jabatan(KeadaanJabatan k, {super.key}); // Aktif → laut, Berakhir → abu, Jabatan kosong → bata
}
```

Labels verbatim: "Aktif", "Tidak aktif", "Hanya baca", "Berakhir", "Jabatan kosong". Rules: a Tidak aktif module leaves no trace in navigation, search, notifications or empty states (its badge exists only on the Modul screen); turning a module off deletes nothing (it becomes Hanya baca); Jabatan kosong is `bata` because work is not being done.

Boards: Modul, AlurModul, AlurJabatanKosong, WebAlurJabatanKosong, JabatanKosong, WebJabatanKosong, Penugasan, WebPenugasan.

#### Tahapan

```dart
class Tahapan extends StatelessWidget {
  const Tahapan({super.key, required this.langkah, required this.selesai});
  final List<String> langkah; // 'Draf', 'Sudah diperiksa', 'Diterbitkan'
  final int selesai;          // how many from the start are done
}
```

Each chip label is "{n} · {langkah}" ("1 · Draf"). `Wrap(spacing: 6, runSpacing: 6)`. Chip: `min-height: 30px; padding: 0 10px; border-radius: 999px; font-size: 13px; font-weight: 700`. Done: `tinta` fill, 1.5 `tinta` line, `permukaan` text. Not reached: no fill, 1.5 dashed `putus`, `tinta3` text. Not pressable (30 high is fine because it is not a target).

Accessibility: the row is one `Semantics` label "Langkah {selesai} dari {n}: …" listing the steps.

Boards: Panitia, Pemeriksa, RekonIsi, WebRekonIsi, PetaLayar.

**Boards vs preview:** same. Awal and WebAwal draw a different step list (34 px numbered circles with states `ok` `laut` + "✓", `kini` `tinta`, `tunggu` 1.5 dashed `tinta`, `kunci`/`nanti` 1.5 dashed `putus` + `tinta3`), and Impor a 6 px segmented bar; those are screen-local and specified in their screen specs.

#### BatangPembagian

```dart
class BatangPembagian extends StatelessWidget {
  const BatangPembagian({super.key, required this.total, required this.bagian,
      this.tinggi = 18, this.garisPutus = true, this.durasi = const Duration(milliseconds: 450)});
  final int total;
  final List<BagianBatang> bagian;
  final double tinggi;    // 18 (Awal, Bagi, AlihPeruntukan), 14 (Kewajiban detail), 8 (KartuKasus)
  final bool garisPutus;  // false on AlihPeruntukan: the parts fill the whole bar
  final Duration durasi;  // 450 ms (Awal, Bagi), 500 ms (AlihPeruntukan, Kewajiban)
}
class BagianBatang { const BagianBatang(this.jumlah, this.warna); final int jumlah; final Color warna; }
```

Bar: height `tinggi`, `border-radius: tinggi / 2`, `GarisBorder.putus(putus)` when `garisPutus`, clipped, segments left to right in a `Row`; each segment's width = `jumlah / max(total, Σjumlah)` of the inner width (Bagi divides by `max(J, total)` so an overfull bar never overflows), clamped 0–100 %, animated with `AnimatedContainer(duration: context.gerak(durasi), curve: PalakatMotion.keluar)`. The unfilled part shows the dashed line on `kertas`/`permukaan`: the remainder is visibly not filled.

Segment colours, in order (Bagi `C = [...]`): `tinta`, `laut`, `PalakatIlustrasi.peruntukanKetiga`, `tinta2`, `garisTegas`.

Remainder line (separate widget `SisaPembagian`, under the bar, gap 8): `justify-content: space-between; align-items: baseline`; label 14/700, amount mono 18/600 (`rp(sisa)`), both in one colour: `bata` while a remainder or an excess exists, `laut` when it adds up (Bagi: "Total baris sama dengan Jumlah"; Awal: "Pas dengan Kas"). Labels are screen copy (Bagi: "Sisa belum dibagi" / "Total baris lebih dari Jumlah" / "Total baris sama dengan Jumlah"). The remainder is calculated, never typed.

Boards: Awal, Bagi, WebBagi, AlihPeruntukan, WebAlihPeruntukan (and the case bars of KartuKasus).

#### Rangka

```dart
class Rangka extends StatelessWidget {
  const Rangka({super.key, required this.balok, this.keterangan});
  final List<Widget> balok;   // laid out by the screen; use RangkaBalok inside Kartu as the board does
  final String? keterangan;   // visible line, e.g. 'Memuat saldo dan transaksi…' (14 tinta2)
}
class RangkaBalok extends StatelessWidget {
  const RangkaBalok({super.key, required this.lebar, required this.tinggi, this.radius = 8});
  final double lebar; // fraction of the parent width (0.62 = CSS width: 62%)
  final double tinggi;
}
```

Block: `garis` fill, radius 8, `aria-hidden`. Pulse: the board's `denyut 1.4s ease-in-out infinite` (Memuat: opacity 1 → 0.45 → 1); stops (opacity 1) under reduced motion. Container: `role="status"` → `Semantics(liveRegion: true, label: 'Memuat')`, column gap 16 (Memuat) or 12 (preview).

Rules: never shows a provisional figure, name or status; on failure it is replaced by the failure card (below) and the person's input stays; offline, what is shown stays readable and nothing is queued.

Failure card (Memuat, WebMemuat, KeadaanUmum): `role="alert"`, `bataLembut` fill, 1.5 `bata` line, radius 14, padding 16, column gap 6: title 17/700 ("Data belum dapat dimuat"), sentence 14 `tinta2`, then a `tinta` button "Coba lagi" (52 high, radius 14, padding `0 20px`, `margin-top: 6px`, aligned start, `min-width: 140px`).

Boards: Memuat, WebMemuat, KeadaanUmum, WebKeadaanUmum, HitungKas.

**Boards vs preview:** preview blocks are full-width with radius 12 and no pulse; Memuat draws partial widths (62 %, 44 %, 26 %, 34 %, 58 %, 32 %), heights 44/16/18/14, radius 8, inside real `Kartu`s, with the pulse. Build the board form.

### 3.3 Actions

#### Tombol

```dart
enum JenisTombol { utama, tinta, kedua, teks, garisLaut, putus, bata, garisBata }
enum UkuranTombol { besar, sedang, ringkas, kecil, mini }

class Tombol extends StatelessWidget {
  const Tombol(this.label, {super.key, required this.onPressed, this.jenis = JenisTombol.utama,
      this.ukuran = UkuranTombol.besar, this.lebarPenuh = true, this.ikon, this.ukuranTeks,
      this.nonaktif = false, this.ke, this.cara = Cara.dorong});
  final String label;          // glossary verb, verbatim
  final VoidCallback? onPressed;
  final Widget? ikon;          // leading icon, gap 8 (e.g. Ikon.kamera on "Lampirkan dokumen pendukung")
  final double? ukuranTeks;    // 14 or 13 when the board says so; else inherited (16 phone, 15 web)
  final bool nonaktif;         // garis fill, tinta3 text; still focusable; see rule below
  final String? ke;            // when set, the button is a Tautan to that board (literal: navigation.md 3.1)
  final Cara cara;             // push, go or up for ke (navigation.md 3.1)
}
```

Sizes (min height / radius / horizontal padding), from the boards:

| `ukuran` | Min height | Radius | Padding | Typical use |
| --- | --- | --- | --- | --- |
| `besar` | 52 | 14 | 0 16 (0 20 in some) | Bottom action of a phone screen, form actions |
| `sedang` | 48 | 14 | 0 16 | Secondary bottom actions, Penolakan options |
| `ringkas` | 46 | 12 | 0 20 | Paired actions inside cards (Persetujuan, Dokumen) |
| `kecil` | 44 | 12 | 0 16 to 0 18 | Web Beranda quick actions, header "+ Kasus baru" (0 14) |
| `mini` | 44 | 10 | 0 12 to 0 16 | Row actions, AI Pakai/Ubah/Abaikan, StatusSimpan "Coba lagi" (14 px text) |

Kinds:

| `jenis` | Fill | Line | Text | Board example |
| --- | --- | --- | --- | --- |
| `utama` | `laut` | none | `diLaut` 700 | "Periksa dan bukukan", "Bukukan", "+ Pendapatan" |
| `tinta` | `tinta` | none | `permukaan` 700 | "Buat pelimpahan" (met), "Buka rekonsiliasi", "Coba lagi" (Memuat) |
| `kedua` | `permukaan` | 1.5 `tinta` | `tinta` 700 | "Ubah", "Koreksi dengan pembalikan", "Pindah tanggal" |
| `teks` | none | none | `laut` 700, min height 44 (`tinta` on TutupBuku "Kembali") | "Simpan sebagai draf", "Kembali ke Beranda" |
| `garisLaut` | `permukaan` | 1.5 `laut` | `laut` (Main "Verifikasi") or `lautTua` (6 boards) 700 | "Verifikasi" |
| `putus` | none | 1.5 dashed `putus` | `tinta2` 700 | "Simpan tanpa Mata Anggaran", "Kas kosong: catat Rp0" |
| `bata` | `bata` | none | `diBata` 700 | StatusSimpan "Coba lagi" |
| `garisBata` | `permukaan` | 1.5 `bata` | `bata` 700 | PanelDokumen "Coba lagi", "Lampirkan" on Ditolak |

Rules (not optional): one `utama` per screen; `kedua` and `teks` for the rest; a disabled button (`nonaktif`: `garis` fill, `tinta3` text, 4.28:1, the one accepted contrast exception) always has its reason in full-contrast text next to it ("Tidak dapat dilakukan: …", 13 `tinta2` in the preview, 14 `bata`/600 on Main's Periksa screen); smallest target 44.

Behaviour: built on `Tekan` (no ripple); `lebarPenuh` stretches it (phone bottom bars use `display: flex; flex-direction: column`, so buttons are full width there); web rows use `flex: 1 1 150px; max-width: 340px` inside a `BarisLentur`.

Accessibility: `Semantics(button: true, enabled: !nonaktif)`; a disabled button that must read its reason is a `TombolBersyarat`, not this.

Boards: every board with an action.

**`TombolTahan`** (the permanent action, Tutup buku), in the same file:

```dart
class TombolTahan extends StatefulWidget {
  const TombolTahan(this.label, {super.key, required this.siap, required this.onSelesai,
      this.tinggi = 56, this.petunjuk});
  final String label;          // 'Tutup buku Oktober 2026'
  final bool siap;             // statement ticked
  final VoidCallback onSelesai;
  final double tinggi;         // 56 phone (TutupBuku), 54 web (WebTutupBuku, flex 1 1 240px)
  final String? petunjuk;      // the line under it, 13 tinta3 centred
}
```

Look: `position: relative; overflow: hidden; radius 14; 700`; `siap`: `tinta` field, `permukaan` text; not `siap`: `garis` field, `tinta3` text. The fill is a `laut` rectangle from the left edge growing to 100 % under the label. Board logic (TutupBuku lines 227–339): pointer down → fill grows `width 0 → 100%` linear over 1.6 s (`segelTahan`); a timer of **1650 ms** then calls `onSelesai`; pointer up or leave before that → cancel the timer and shrink the fill back over 0.2 s; keyboard activation (Enter/Space, the board's `onClick` with `detail === 0`) calls `onSelesai` at once; nothing happens while not `siap`. Under reduced motion the fill is not animated but the hold time still counts (the hold is the confirmation, not decoration). Petunjuk copy: "Tekan dan tahan tombol sampai penuh" / "Centang pernyataan di atas untuk melanjutkan".

Boards: TutupBuku, WebTutupBuku (the hold also exists in Cakupan, Dokumen, Ekspor, Kejadian as text; see their specs).

**Boards vs preview:** the preview's secondary is 52 high; the boards' secondary is mostly 48 (143 uses). The boards use a `tinta` filled primary 110 times (flow boards and blocker fixes) besides `laut`. The preview has no dashed or `bata` button; the boards have both.

#### TombolBersyarat

```dart
enum GayaAlasan { penolakan, kalimatBata, pendamping }

class TombolBersyarat extends StatelessWidget {
  const TombolBersyarat({super.key, required this.label, required this.tindakan, required this.alasan,
      required this.onPressed, this.sudahMulai = true, this.warnaSiap = JenisTombol.tinta,
      this.teksBelumRedup = false, this.gayaAlasan = GayaAlasan.penolakan, this.tinggi = 52});
  final String label;            // 'Buat pelimpahan'
  final String tindakan;         // verb used in the sentence: 'Buat pelimpahan'
  final String alasan;           // first unmet reason, '' when met (computed by the screen from the latest input)
  final VoidCallback onPressed;  // called only when alasan is empty at the moment of the press
  final bool sudahMulai;         // false while the form is untouched: no sentence shown
  final JenisTombol warnaSiap;   // tinta (flow boards, preview) or utama/laut (finance boards: btnBg laut)
  final bool teksBelumRedup;     // true = unmet text tinta3 (finance boards' btnFg = tinta3), false = tinta2 (flow boards, preview)
  final GayaAlasan gayaAlasan;
  final double tinggi;
}
```

Look: one button, never swapped. Met: `warnaSiap` fill, `diLaut`/`permukaan` text. Unmet: `garis` fill, `tinta2` (or `tinta3`) text. 52 high, radius 14, padding `0 16px`; in flow boards inside a wrap row: `flex: 1 1 150px; max-width: 340px`, gap 8.

Reason sentence, directly above the button (gap 6–8), only while unmet and only after `sudahMulai`:

| `gayaAlasan` | Form | Boards |
| --- | --- | --- |
| `penolakan` | 14 px: **"Tidak dapat dilakukan: {tindakan}."** in `bata` 700, then " " + alasan in `tinta` | Flow boards (AlurPelimpahan, AlurSurat, AlurWarta, AlurDokumen …), preview |
| `kalimatBata` | One sentence 14/600 `bata`: "Tidak dapat dilakukan: {alasan}" | Main Periksa ("… {n} syarat belum terpenuhi. Tidak ada yang dibukukan."), TabCatat, WebCatat |
| `pendamping` | 14 `tinta2`: "Belum dapat disimpan: {alasan}" | KasusBaru, WebKasusBaru |

Behaviour (not optional): `onPressed` re-checks: the widget calls the screen's callback and the screen re-evaluates the condition from the latest controller values before acting, so the first press after typing works (the flow boards wrap the handler: `R_[g[0]] = function () { var F = self.vals(); if (F[g[1]]) F[g[0] + 'Mentah'](); }`). Never `onPressed: null`: the button stays focusable and `Semantics(button: true, enabled: alasan.isEmpty, hint: alasan)` reads the reason (board `aria-disabled`). Only the first unmet reason is shown. An empty form opens without a refusal. Dates in the form are typed `hh/bb/tttt` and checked while typing (2.4).

Boards: 78 boards (all `Alur*` and `WebAlur*`, AkunSaya, AlihPeruntukan, AwalIsian, Bagi, Bendahara, Dokumen, Draf, FormatLaporan, HitungKas, Impor, KasUnit, KasusBaru, Kejadian, Kesiapan, Koreksi, Masuk, PemberiPersetujuan, Pemulihan, Pengembalian, Persembahan, Persetujuan, RekonIsi, TabCatat, UbahPengaturan and their Web boards, WebAwal, WebSerahTerima, WebVerifikasi).

**Boards vs preview:** finance boards colour the met state `laut` (13 places) or `tinta` (11), and the unmet text `tinta3`; flow boards use `tinta` / `tinta2` as the preview. Some finance boards use the HTML `disabled` attribute and show "Belum dapat disimpan:" in `tinta2`; build them with this widget too, keeping each board's colours and sentence.

#### Penolakan

```dart
class Penolakan extends StatelessWidget {
  const Penolakan({super.key, required this.tindakan, required this.sebab, required this.jalan, this.ukuranTeks = 15});
  final String tindakan;          // 'Bukukan'
  final String sebab;             // 'September 2026 sudah ditutup.'
  final List<Widget> jalan;       // available steps: Tombol(kedua, sedang) 'Pindah tanggal', 'Batalkan'
  final double ukuranTeks;        // 15 (preview, Draf), 14 (flow boards)
}
```

Sentence: **"Tidak dapat dilakukan: {tindakan}."** in `bata` 700 (`<strong>`), a space, then the cause in `tinta` 400. Steps below in a row, gap 8: `Tombol(jenis: kedua, ukuran: sedang)` (48, radius 14, padding `0 16px`).

Rules: every refusal offers a step that is really available; never mentions reopening a month.

Accessibility: the sentence is `Semantics(liveRegion: true)` when it appears after an action.

Boards: Draf, WebDraf, TabTransaksi, WebTransaksi, JabatanKosong, WebJabatanKosong, KeuanganUnit, Panitia, Penugasan, WebPenugasan, PersembahanBernama, WebPersembahanBernama, AlurIbadah, AlurPenugasan, AlurSurat, AlurUnit, AlurWarta and their Web boards.

**Boards vs preview:** Draf writes the ways forward inside the sentence ("Yang masih dapat Anda lakukan: pindah tanggal ke bulan yang belum ditutup, atau batalkan.") and offers them as the screen's own buttons.

### 3.4 Inputs

#### IsianJumlah

```dart
enum UkuranJumlah { besar, lebar, standar, sedang, baris }

class IsianJumlah extends StatelessWidget {
  const IsianJumlah({super.key, required this.label, required this.controller, required this.onChanged,
      this.ukuran = UkuranJumlah.standar, this.petunjuk = '0', this.sisakanNol = false,
      this.hanyaBaca = false, this.lebarMaks, this.warnaAngka});
  final String label;               // 'Jumlah (Rp)'
  final String petunjuk;            // '0' or '—' (grey hint, never a value)
  final double? lebarMaks;          // 280, 300, 420 on web boards
}
```

Layout: label (14 `tinta2`, `<label for>`) above; then a baseline row `gap: 6px; font-family: mono; border-bottom: 2px solid tinta; padding-bottom: 4px`: "Rp" in `tinta3`, then the `TextField` (no border, transparent, mono 500, `min-height: 44px`, `RupiahInputFormatter`, numeric keyboard, `hintText: petunjuk` in `tinta3`).

| `ukuran` | "Rp" | Figure | Letter spacing | Boards |
| --- | --- | --- | --- | --- |
| `besar` | 22 | 38 | −1 | Main |
| `lebar` | 24 | 40 | −1 | TabCatat, WebCatat |
| `standar` | 20 | 30 (`jumlahIsian`) | 0 | AlihPeruntukan, KasusBaru, Kewajiban, Pengembalian and their Web boards, preview |
| `sedang` | 18 (16 WebPersembahan) | 26 | 0 | RekonIsi, UbahPengaturan, WebKasus, WebRekonIsi, WebUbahPengaturan |
| `baris` | 14 | 17 (Bagi, Awal) or 18 (Persembahan) | 0 | Bagi, WebBagi, Awal, Persembahan: gap 4, **1.5** `tinta` underline, width 160, right-aligned, hint "—" |

Rules: empty shows the grey hint, not a value (not filled in is not zero: `angkaDari('') == null`); a negative is shown `−Rp15.000` wherever it is displayed (inputs take digits only); the label says "(Rp)".

Accessibility: label linked (`Semantics(textField: true, label: label)`).

Boards: AlihPeruntukan, Awal, Bagi, KasusBaru, Kewajiban, Main, Pengembalian, Persembahan, RekonIsi, TabCatat, UbahPengaturan, WebAlihPeruntukan, WebBagi, WebCatat, WebKasus, WebKasusBaru, WebPengembalian, WebPersembahan, WebRekonIsi, WebUbahPengaturan.

**Boards vs preview:** the preview's figure is 30 with letter spacing −1 inside a card; Main uses 38 with "Rp" 22 and no card. Build the size each board draws.

#### IsianAlasan

```dart
class IsianAlasan extends StatelessWidget {
  const IsianAlasan({super.key, required this.controller, required this.onChanged, this.contoh, this.label = 'Alasan'});
  final String? contoh; // hint, e.g. 'Contoh: Mata Anggaran keliru'
  static bool terisi(String t) => t.trim().isNotEmpty; // blank refused, no minimum length
}
```

Label row: "Alasan" 14 `tinta2` + **" · wajib"** 700 `tinta` (`<strong style="color: tinta">· wajib</strong>`), `margin-bottom: 6px`. Field: `TextField(minLines: 2, maxLines: 2)`, `padding: 12px 14px; border-radius: 12px; border: 1px solid garisTegas; background: permukaan`, font inherited, hint `tinta3`.

Rules: required for Batalkan, Pindah tanggal, a reversal, an exception and Bebaskan; the action it guards is disabled (TombolBersyarat or `Tombol.nonaktif` + reason) until `terisi`; the reason is recorded exactly as typed.

Boards: 45 (Draf, Dokumen, Kejadian, Kesiapan, Koreksi, Modul, Pengembalian, Pengumuman, PersembahanSaya, Persetujuan, SelesaikanUnit, TerbitDokumen, BukaNama, BantuanAI, AntreanVerifikasi, AlurAnggota, AlurDana, AlurDokumen, AlurIbadah, AlurJabatanKosong, AlurModul, AlurPengembalian, AlurPeristiwa, AlurSurat, AlurUnit, AlurWarta and their Web boards, WebVerifikasi).

#### ChipPilihan

```dart
class ChipPilihan<T> extends StatelessWidget {
  const ChipPilihan({super.key, required this.label, required this.pilihan, required this.terpilih,
      required this.onPilih, this.keterangan, this.padding = 14, this.jarakLabel = 8});
  final String label;                    // 'Diambil dari peruntukan'
  final double jarakLabel;               // gap under the label: 8, or 6 on the flow boards (2.9)
  final String? keterangan;              // '· uang siapa ini' in tinta3 after the label
  final List<({T nilai, String teks})> pilihan;
  final T? terpilih;                     // null = nothing chosen (never pre-filled)
  final ValueChanged<T> onPilih;
  final double padding;                  // 14 in forms, 16 in list filters
}
```

Label: 14 `tinta2`, `margin-bottom: 8px`, keterangan span `tinta3`. Chips: `Wrap(spacing: 8, runSpacing: 8)` (CSS `margin: 0 8px 8px 0`). Chip: `min-height: 44px; padding: 0 14px; border-radius: 999px; border: 1.5px; font-weight: 600; font-size: 14px`. Selected: `tinta` fill and line, `permukaan` text. Unselected: `permukaan` fill, `garisTegas` line, `tinta` text. Colour change instant (boards have no transition).

Rules: one choice of a few, all visible; Kas/Bank, peruntukan, Lingkup and Mata Anggaran are four separate fields, none guessed or pre-filled from another.

Accessibility: each chip `Tekan(dipilih: on)` (board `aria-pressed`).

Boards: 63 (Main, TabCatat, WebCatat, Bukti, Draf, Koreksi, Kewajiban, KasusBaru, HitungKas, Pengembalian, Persembahan, Tanggal, LihatTransaksi, MataAnggaran, FormatLaporan, UbahPengaturan, AwalIsian, AlihPeruntukan, KasUnit, Lainnya, PemberiPersetujuan, TabTransaksi, every `Alur*` with choices, and the Web boards of these).

**Boards vs preview:** the same chip shape is also used as a toggle in AkunSaya and WebAkunSaya (`role="switch"`, labels "Aktif"/"Mati", padding `0 14px`) and as list filters (padding `0 16px`, `margin: 0 8px 0 0`). Main's sheet "Catatan lain" links are chips with a 1.5 `garisTegas` line that navigate (`Tautan`).

#### PemilihMataAnggaran

```dart
class PemilihMataAnggaran extends StatefulWidget {
  const PemilihMataAnggaran({super.key, required this.pohon, required this.baris, required this.onPilih,
      required this.onTanpa, required this.keBagi, this.versi = '2026.1'});
  final String pohon;                       // 'Belanja' | 'Pendapatan'
  final List<BarisMataAnggaran> baris;      // published version, in order
  final ValueChanged<BarisMataAnggaran> onPilih;
  final VoidCallback onTanpa;               // 'Simpan tanpa Mata Anggaran'
  final String? keBagi;                     // board stem of 'Bagi ke beberapa Mata Anggaran' as a literal (Main: keBagi: 'Bagi'), null to hide
}
class BarisMataAnggaran { const BarisMataAnggaran(this.kode, this.nama, {this.grup = false}); }
```

As drawn in Main (`isMa` view, a full-screen view on `permukaan` that rises with `naik` 280 ms; a child route of Main whose name `navigation.md` fixes):

- Header: back (`Ikon.kembali`) + "Pilih Mata Anggaran" 18/700 + tree badge (`LencanaStatus(pohon, bentuk: tinta, kepala: true)`).
- Search: `padding: 4px 20px 10px`; `IsianTeks` on `kertas`, placeholder "Cari nomor atau nama", `aria-label` "Cari Mata Anggaran".
- List (`padding: 0 20px`, scrolls): group heading (not pressable) `padding: 14px 0 6px`: code mono 13 `tinta3`, name 14/700 `tinta2`, "Judul kelompok, tidak dapat dibukukan" 13 `tinta3`. Item (`Tekan`, full width): `min-height: 60px; border-top: 1px solid garis; padding: 6px 0 6px 14px`: "{pohon} {kode}" mono 13 `tinta2`, name 600/15.
- Filter on every keystroke: groups always shown; items kept when `('$kode $nama').toLowerCase().contains(q.toLowerCase())`.
- Footer (`padding: 12px 20px 22px; border-top: 1px solid garis; gap 8`): `Tautan(ke: keBagi)` "Bagi ke beberapa Mata Anggaran" (48, radius 14, 1.5 `tinta`, 700) and `Tombol.putus` "Simpan tanpa Mata Anggaran" (48, radius 14, `tinta2` 700).

The chosen value in the form (Main): a 56-high `Tekan` row, `padding: 10px 14px; radius 12`: chosen → `permukaan` fill, 1 px `garisTegas`, "{pohon} {kode}" mono 13 `tinta2`, name 600/15; not chosen → no fill, 1.5 dashed `putus`, "Draf boleh disimpan tanpa Mata Anggaran" / "Mata Anggaran belum dipilih"; trailing `Ikon.lanjut`.

Split mode (preview, and Bagi's bottom sheet "Pilih Mata Anggaran"): rows "kode nama … Rp" (14, code mono 13 `tinta2`, padding `8px 0`, top rule `garis`), total row with 1.5 `tinta` top rule, 700 `bata`: "Total baris harus sama dengan Jumlah" … "kurang Rp50.000".

Rules: number and name exactly as stored, always with the tree name; group headings cannot be posted to; no "Lainnya"; "Simpan tanpa Mata Anggaran" only saves a draft (dashed); split rows must add up to Jumlah.

Boards: Main, TabCatat, WebCatat, MataAnggaran, WebMataAnggaran, Laporan, WebExcel, WebExcelTerbatas, WebPaketLaporan, Bagi.

**Boards vs preview:** the preview is a card with a selected row (2 px `tinta` line + `Ikon.terpenuhi` 22 "Terpilih"); Main picks and returns at once, so the selected-row look appears only on WebCatat/TabCatat lists (see their specs). Not a `SearchAnchor`: build the board's list.

#### Sakelar

```dart
class Sakelar extends StatelessWidget {
  const Sakelar({super.key, required this.nilai, required this.onUbah, required this.label, this.nonaktif = false});
  final bool nilai;
  final ValueChanged<bool> onUbah;
  final String label;     // aria-label: 'Wajib pemeriksa kedua'
  final bool nonaktif;    // WebPengaturan disables it while no Bendahara is active
}
```

As drawn (Lainnya, Pemberitahuan, WebPengaturan, WebPemberitahuan): target `56 × 44`, `padding: 6px 0`; track `56 × 32`, radius 16, 1.5 `tinta` line, fill `tinta` (on) / `permukaan` (off), `transition: background .16s`; thumb `23 × 23` circle at `top: 3px`, `left: 28px` (on) / `3px` (off), `permukaan` (on) / `tinta` (off), `transition: left .16s` (`sentuh`, CSS default timing `ease` → `Curves.ease`; zero under reduced motion).

Rules: always accompanied by the sentence naming the month the change takes effect (screen copy, e.g. Lainnya's "Berlaku mulai …").

Accessibility: `Tekan(peran: sakelar, tercentang: nilai, label: label)` (board `aria-pressed`).

Boards: Lainnya, Pemberitahuan, WebPemberitahuan, WebPengaturan. AkunSaya and WebAkunSaya draw their push switches as `ChipPilihan`-shaped toggles ("Aktif"/"Mati", `role="switch"`), not as this switch.

#### PenghitungPecahan

```dart
class PenghitungPecahan extends StatelessWidget {
  const PenghitungPecahan({super.key, required this.pecahan, required this.lembar, required this.onUbah, this.garisAtas = true});
  final int pecahan;            // 100000
  final int lembar;             // count, ≥ 0
  final ValueChanged<int> onUbah; // new count, clamped at 0 (board: Math.max(0, m[i] + d))
  final bool garisAtas;         // false on the first row
}
```

Row (HitungKas): `min-height: 56px; gap: 8px; border-top: 1px solid garis`; inside a `Kartu` with `padding: 0 12px 0 16px`.

| Part | Look |
| --- | --- |
| Denomination | width 92, mono 15/500, `titik('$pecahan')` ("100.000") |
| Minus | `44 × 44`, radius 12, 1.5 `garisTegas`, `permukaan`, "−" 22/600, label "Kurangi satu lembar {rp(pecahan)}" |
| Count | width 36, centred, mono 17/600 |
| Plus | `44 × 44`, radius 12, `tinta` fill, `permukaan` "+" 22/600, label "Tambah satu lembar {rp(pecahan)}" |
| Product | flex, right, mono 14; `rp(lembar × pecahan)` in `tinta`, or "—" in `tinta3` when 0 |

Denominations on the board: 100000, 50000, 20000, 10000, 5000, 2000, 1000. The plus is darker than the minus because counting almost always adds.

Boards: HitungKas. WebHitungKas uses a numeric input per denomination instead (its spec). Kehadiran uses similar ± buttons for counts (its spec).

**Boards vs preview:** preview count 17/600, product 14: same; the board's denomination is 15 px (preview inherits 15).

### 3.5 Cards

#### ButirPerhatian

```dart
enum TingkatPerhatian { hambatan, perluTindakan, untukDiketahui }

class ButirPerhatian extends StatelessWidget {
  const ButirPerhatian({super.key, required this.tingkat, required this.judul, this.keterangan,
      this.perbaikan, this.labelTingkat = false, this.ke, this.cara = Cara.dorong, this.onTap, this.warnaKeterangan});
  final Widget? perbaikan;     // Hambatan: required button/Tautan to the fix
  final bool labelTingkat;     // preview's 'HAMBATAN' label (13/700 bata, letter spacing .3); boards omit it
  final String? ke;            // Perlu tindakan row target (literal: navigation.md 3.1)
  final Cara cara;             // push, go or up for ke
}
```

| Level | Look on the boards |
| --- | --- |
| Hambatan | `Kartu` `permukaan`, 1.5 `bata`, radius 14, padding 14 16 (16 on web), gap 4: title 700 (15 phone), keterangan 14 `tinta2`, then the fix: `tinta` button, `margin-top: 8px`, 44 high, radius 12 (phone: full width; web: `align-self: flex-start`, padding `0 16px`). Under a heading "Hambatan" + `Hitungan`. |
| Perlu tindakan | a `BarisDaftar` inside one card (`padding: 0 16px`): title 600/15, keterangan 13 `tinta3` (the first row of Main and WebBeranda uses `bata` 600/700 for "1 hambatan · bulan berikutnya untuk tutup buku"), chevron. |
| Untuk diketahui | Plain: heading "Untuk diketahui" (16/700 phone, 17/700 web) and a 14 `tinta2` `TautanTeks` line (Main: "2 uang muka dengan sisa belum dipertanggungjawabkan" → Kewajiban). No frame, no warning colour. |

Rules: a Hambatan always carries the button to its fix; `bata` for nothing else.

Boards: Main, TabBeranda, WebBeranda, BerandaJabatan, WebBerandaJabatan, KotakMasuk, WebKotakMasuk, AlurBeranda, JabatanKosong, WebJabatanKosong, KeuanganUnit, TutupBuku, WebTutupBuku, WebAI.

**Boards vs preview:** no board shows the "HAMBATAN" label; the level is named by the section heading.

#### PanelDokumen

```dart
enum StatusDokumen { wajibBelumAda, sedangDiunggah, gagalDiunggah, diunggah, terverifikasi, dikecualikan, ditolak, ditahan, tidakDiperlukan }

class PanelDokumen extends StatelessWidget {
  const PanelDokumen({super.key, required this.dokumen});
  final List<BarisDokumen> dokumen;
}
class BarisDokumen {
  const BarisDokumen({required this.status, required this.judul, this.keterangan, this.aksi});
  final Widget? aksi; // 'Lampirkan', 'Coba lagi', 'Verifikasi' button (mini, 13 px)
}
```

Preview form: `Kartu(padding: 0 16px)`; row `min-height: 60px; padding: 8px 0; gap: 12px; border-top: 1px solid garis`; thumbnail `34 × 42`, radius 6: wajib-belum-ada → no fill, 1.5 dashed `putus`; sedang diunggah / diunggah → `kertas` + 1 `garisTegas`; gagal / ditolak / ditahan → `bataLembut` + 1 `garisTegas`; terverifikasi / dikecualikan → `lautLembut` + 1 `garisTegas`. Title 600/14 (`bata` for Gagal diunggah, Ditolak, Ditahan), keterangan 13 `tinta3`. Action: `mini` button, `min-height: 40px` in the preview → **44** (target rule), padding `0 12px`, radius 10, 1.5 `tinta` (or `bata` for the failure rows), 700/13.

Board forms (build these where they appear):

- Main form (attached): `padding: 12px 14px; radius 12; 1px garisTegas; permukaan`, thumb `40 × 48` radius 6 `lautLembut` + 1 `garisTegas`, "nota-16-11.jpg · Terlampir" 14/600, "Diunggah, belum diverifikasi" 13 `tinta2`, appears with `muncul` 280 ms.
- Upload in progress (Main, Gerak): "Sedang diunggah…" 14/600, a 4 px bar (radius 2, `garis` track, `laut` fill `isi` 1.2 s linear), in the same box.
- Not attached: dashed button "Lampirkan dokumen pendukung" (56 high, radius 12, 1.5 dashed `putus`, `laut` 600 text, `Ikon.kamera` 20).
- Dokumen detail: status 20/700 (`bata` for gagal/ditahan), note 14 `tinta2`, action buttons 48 high radius 12 padding `0 18px` (`utama` or `kedua`), "Riwayat keputusan" list.

Status words (verbatim, Dokumen board): "Wajib, belum ada", "Diunggah, belum diverifikasi", "Terverifikasi (oleh Meiske L.)", "Dikecualikan", "Gagal diunggah", "Ditahan (alasan keamanan)", "Tidak diperlukan (aturan: Pindah antar Kas/Bank)"; plus "Ditolak" and "Sedang diunggah…" (preview).

Rules: uploaded is not verified; month close accepts only Terverifikasi or Dikecualikan; Gagal diunggah and Ditolak use `bata` and always offer the next step; a file refused at upload is not stored (EC07); an exception names its reason and who granted it ("Alasan: nota hilang · oleh Ketua BPMJ").

Boards: Main, Dokumen, WebDokumen, TabTransaksi, WebTransaksi, Pemeriksa, WebPemeriksa, HitungKas, Kamera, LihatDokumen, WebLihatDokumen, AIFoto, WebAIFoto, Persembahan, TerbitDokumen, WebTerbitDokumen, WebBukti, WebUnggah, WebTutupBuku, Cakupan, PetaPlatform, AlurAnggota, AlurDokumen, AlurKeluarga, AlurPanitia, AlurPeristiwa, AlurSurat, WebAlurDokumen, WebAlurKeluarga, WebAlurSurat.

#### KartuPersetujuan

```dart
enum KeadaanPersetujuan { belumDicatat, sudahDicatat, tidakDiperlukan }

class KartuPersetujuan extends StatelessWidget {
  const KartuPersetujuan.belum({super.key, required this.onCatat, this.judul = 'Persetujuan belum dicatat'});
  const KartuPersetujuan.sudah({super.key, required this.pemberi, required this.jabatan, required this.tanggal,
      required this.cara, required this.dicatatOleh, required this.dicatatPada, this.kepala});
  const KartuPersetujuan.tidakDiperlukan({super.key, required this.aturan});
}
```

| State | Look |
| --- | --- |
| belumDicatat | radius 14, 1.5 dashed `putus`, no fill, padding 14 16: title 700; button "Catat persetujuan" (`margin-top: 8px`, 44 high, radius 12, 1.5 `tinta`, `permukaan`, 700) |
| sudahDicatat | `Kartu` (1 `garis`), padding 14 16, gap 4: optional kicker "Persetujuan di luar aplikasi" 14 `tinta2` (Persetujuan board), title "Persetujuan sudah dicatat" 700; "Pemberi persetujuan: **{nama}**, {jabatan}" 14 (label in `tinta2`); "{tanggal} · cara: {cara}" 14 `tinta2`; rule line 13 `tinta3` with a **1 px dashed `garisTegas` top** (`GarisLurus(gaya: putus, tebal: 1)`), `margin-top: 8px; padding-top: 8px`: "Dicatat oleh {nama}, {tanggal jam}. Pernyataan Bendahara, bukan persetujuan di dalam aplikasi." |
| tidakDiperlukan | Plain 14 `tinta2`: **"Tidak diperlukan"** (700 `tinta`) + " (aturan: {aturan})" |

Rules: no "Approve" button, no imitation signature; the recorded line always says it is the Bendahara's statement.

Boards: Persetujuan, WebPersetujuan, Koreksi, WebKoreksi (rule line also in Bendahara, FormatLaporan, WebFormatLaporan, WebLaporan). On Persetujuan the "Catat persetujuan" action is a `utama` 46-high button below the card, not inside it.

#### KartuUsulanAI

```dart
class KartuUsulanAI extends StatelessWidget {
  const KartuUsulanAI({super.key, required this.label, required this.isi, this.kurangYakin = false,
      required this.onPakai, required this.onUbah, required this.onAbaikan, this.bingkai = true});
  final String label;        // 'Usulan AI' or 'Usulan AI · dari foto' …
  final Widget isi;          // the suggestion, rendered in italic lautTua
  final bool kurangYakin;    // shows 'AI kurang yakin, mohon dicek'
  final bool bingkai;        // the lautLembut panel around it (preview, WebAI aside)
}
```

Look: panel (when `bingkai`) `lautLembut`, radius 16 (preview) / 18 (WebAI aside, padding 18, gap 14). Card: `permukaan`, 1.5 dotted `laut`, radius 12, padding 14 (12 14 on some), column gap 6–8, appears with `muncul` 300 ms; badge `LencanaStatus(label, bentuk: usulanAI)`; suggestion 14 italic `lautTua` (600 when it is a Mata Anggaran line: "Belanja {no} {nama}"); "AI kurang yakin, mohon dicek" 13/600 `tinta`. Actions row, gap 8: Pakai (`utama`), Ubah (`kedua`), Abaikan (`kedua`), `mini` 44 high radius 10 padding `0 16px`, or 46 high radius 12 `flex: 1` (BantuanAI, AIFoto). Lists of suggestions (AIMataAnggaran): rows `padding: 8px 0` separated by a **1 px dotted `garisTegas`** top rule.

Rules: dotted `laut` and italic `lautTua` belong only to AI; a suggestion has no value until Pakai; when unsure, write "AI kurang yakin, mohon dicek" (8 boards write the shorter "AI kurang yakin" in other sentences; keep each board's copy).

Accessibility: the card is a group "Usulan AI"; Pakai is the first action in focus order.

Boards: AIBulan, AIFoto, AIMataAnggaran, BantuanAI, Cari, WebAI, WebAIFoto, WebAIMataAnggaran, WebBantuanAI, WebCari.

**Boards vs preview:** preview buttons are 40 high: build 44 (or 46 where the board says).

#### KartuKasus

```dart
class KartuKasus extends StatelessWidget {
  const KartuKasus({super.key, required this.nama, required this.labelPihak, required this.pihak,
      required this.awal, required this.dipertanggungjawabkan, required this.status, this.lewatTempo = false, this.ke, this.cara = Cara.dorong, this.onTap});
  final String labelPihak;          // 'Diberikan kepada' (Uang Muka), per kind from the board's LBL
  final String? ke;                 // card target (literal: navigation.md 3.1)
  final Cara cara;                  // push, go or up for ke
  final int awal, dipertanggungjawabkan; // sisa = awal - dipertanggungjawabkan, never typed
  final String status;              // 'Sebagian dipertanggungjawabkan · jatuh tempo 30/11/2026'
  final bool lewatTempo;            // status line in 700, no bata
}
```

Look (Kewajiban list): `Kartu` padding 14 16, gap 6 (a `Tekan`/`Tautan` row): name 700 + amount mono 500 on one line (space-between); "{labelPihak}: {pihak}" 13 `tinta2`; bar = `BatangPembagian(tinggi: 8, bagian: [dipertanggungjawabkan in tinta])` with 1.5 dashed `putus` (no animation in the list; 500 ms in the detail, where the bar is 14 high); status 13 `tinta2`, weight 700 when past due.

Rules: the remainder is calculated; the part not yet accounted for stays dashed; past due is bold, never `bata`.

Boards: Kewajiban, KasusBaru, WebKasus, WebKasusBaru, TerbitDokumen, WebTerbitDokumen (upload bar of the same shape).

#### RangkaianKoreksi

```dart
class RangkaianKoreksi extends StatelessWidget {
  const RangkaianKoreksi({super.key, required this.kartu});
  final List<KartuRangkaian> kartu; // 2 or 3: dibalik, pembalikan, koreksi (koreksi optional)
}
class KartuRangkaian {
  const KartuRangkaian({required this.noBukti, required this.lencana, this.judul, this.jumlah, this.keterangan, this.dibalik = false});
}
```

Cards: `permukaan`, radius 14, padding `10px 14px` (preview) / `12px 16px` (WebKoreksi), line 1.5 `tinta3` for the reversed one (badge Dibalik, `garis` shape) and 1.5 `tinta` for the reversal and the correction (badge Dibukukan, `tinta` shape). Header row: No. Bukti mono 13 `tinta2` (with " · Pembalikan" / " · Transaksi koreksi"), badge right. Optional body (WebKoreksi): title 600 + amount mono 500, note 13 `tinta3` ("Pembalikan dari No. Bukti BKU-2026-0139 · tidak dapat diubah atau dibalik"). Link line between cards: `2 × 16` (preview) / `2 × 18` (WebKoreksi) `tinta`, `margin-left: 28px`. On WebKoreksi the correction card appears with `muncul` 400 ms after 600 ms.

Rules: the vertical 2 px line means "linked to"; the reversed transaction stays visible with Dibalik; nothing deleted; also used for refunds and the Bendahara handover.

Boards: WebKoreksi (full chain); Koreksi, Main, LihatTransaksi, Bukti, TabTransaksi, WebTransaksi and the A4F02 pages show the "Dibalik oleh No. Bukti …" link line in lists.

### 3.6 Banners

#### PitaLaporan

```dart
class PitaLaporan extends StatelessWidget {
  const PitaLaporan.sementara({super.key, required this.kalimat, this.sebaris = false});
  const PitaLaporan.resmi({super.key, required this.dibekukan, required this.idSalinan, this.versi, this.sebaris = false});
  const PitaLaporan.terbatas({super.key, required this.kalimat}); // A4/print form
  final bool sebaris; // web: title and sentence on one wrapping row (gap 4 16, baseline)
}
```

| Form | Look | Copy |
| --- | --- | --- |
| sementara | radius 14, 1.5 dashed `putus`, padding 12 16: "Laporan sementara" 700, sentence 13 (phone) / 14 (web) `tinta2` | "Bukan laporan resmi. Angka masih dapat berubah sampai Oktober 2026 ditutup; file resmi dibuat setelah tutup buku." |
| resmi | `tinta` field, radius 14, padding 12 16, `permukaan` text: "Laporan resmi" 700; line 13 (phone) / 14 (web) `diTinta2`: "Dibekukan saat tutup buku 16/11/2026 11.05 · ID " + **mono** "SNP-2026-10-01" (web adds " · Versi Mata Anggaran 2026.1") | as left |
| A4 sementara | radius 8, 1.5 dashed `tinta3`, padding 10 14, 15 px: "**Laporan sementara.** Bukan laporan resmi. …" | A4Sementara |
| A4 terbatas | 2 px solid `tinta`, no radius, padding 10 14, 15 px: "**TERBATAS · Akses terbatas: Peruntukan Diakonia.** File ini dibuat khusus …" | A4Terbatas |

Rules: a provisional report never looks official; a restricted copy is titled TERBATAS; the ID is mono.

Accessibility: the banner is the first readable element of the report (`Semantics(header: false, container: true)`).

Boards: Laporan, WebLaporan, A4Sementara, A4Terbatas, LihatTransaksi, WebLihatTransaksi, WebPaketLaporan.

#### PitaPeran

```dart
enum JenisPita { peran, kunci, belumPasti }
class PitaPeran extends StatelessWidget {
  const PitaPeran({super.key, required this.jenis, required this.judul, this.kalimat, this.radius});
}
```

| `jenis` | Look | Board example |
| --- | --- | --- |
| peran | 1.5 solid `tinta`, radius 12, padding 10 14 (12 16 on web), 14 px: **judul** + kalimat `tinta2` on its own line | Terbatas: "Akses terbatas: Peruntukan Diakonia" / "Anda hanya melihat bagian Diakonia. Bagian lain tidak ditampilkan dan tidak ikut dijumlahkan." |
| kunci | `tinta` field, radius 14 (16 on Bendahara, WebPengaturan), padding 12 14 (18 / 18 20), `permukaan` text; title 700 (19/700 on Bendahara and WebPengaturan), sentences 14 `diTinta` | "Belum ada Bendahara aktif" |
| belumPasti | 1.5 dashed `putus`, radius 14, padding 10 14: **"Sementara."** + `tinta2` sentence | preview |

Rules: one short sentence; a locking state uses the `tinta` field; a role uses the solid line.

Boards: Terbatas, WebTerbatas, WebExcelTerbatas, A4Terbatas, Bendahara, WebPengaturan, WebSerahTerima, WebVerifikasi, Masuk, WebMasuk.

#### PitaJabatanKosong

```dart
class PitaJabatanKosong extends StatelessWidget {
  const PitaJabatanKosong.ponsel({super.key, this.jabatan = 'Bendahara Jemaat'});
  const PitaJabatanKosong.web({super.key, this.jabatan = 'Bendahara Jemaat', this.sejak = '16/11/2026 08.15',
      this.operator = 'Yanti Sumual', this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12)});
}
```

As drawn (driven by the global `jabatanKosong` switch, CONVENTIONS):

| Form | Look | Copy (verbatim) | Boards |
| --- | --- | --- | --- |
| Phone one-liner | `flex: none`, full width above everything in the phone frame (above the header and the scroll area), `tinta` field, `permukaan` text, `padding: 10px 24px 8px`, 13 px, line height 1.3, centred, no radius | "**Menjalankan jabatan kosong** · Bendahara Jemaat" | 31 phone boards: AIBulan, AIFoto, AIMataAnggaran, AlihPeruntukan, BantuanAI, Bagi, Bukti, Cari, Dokumen, Draf, Ekspor, FormatLaporan, HitungKas, Impor, KasusBaru, Kejadian, Kewajiban, Koreksi, Laporan, LihatDokumen, LihatTransaksi, Main, MataAnggaran, Pemberitahuan, Pengembalian, Persembahan, Persetujuan, PilihBulan, RekonIsi, Tanggal, TutupBuku |
| Web banner | first child of `main` (above the page title), `tinta` field, radius 14, padding 12 16 (12 14 on 6 boards), 14 px | "**Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.**" + " " + "Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." in `diTinta2` | 40 web boards (WebBeranda, WebTransaksi, WebRekonsiliasi, WebTutupBuku, WebLaporan … and the phone board JabatanKosong, which shows the card form) |
| Penatua Kolom 2 | web form | "**Anda menjalankan jabatan kosong Penatua Kolom 2.**" + the same `diTinta2` sentence | AlurJabatanKosong, WebAlurJabatanKosong |

Both are `role="status"` → `Semantics(liveRegion: true)`. With the switch on, the side-nav footer of the web boards reads "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat" instead of "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (`navigation.md`), and the 18 boards whose logic says `if (jk && true)` swap "Meiske L." for "Yanti Sumual, Operator" in strings dated 16/11/2026 (CONVENTIONS).

Rules: shown on every screen of the module while the post is run, gone as soon as a holder is assigned; every action records "oleh {nama}, Operator · menjalankan jabatan kosong {jabatan}"; closing a month names the Operator; it never replaces the second checker.

**Boards vs preview:** the preview's phone line has `padding: 9px 16px` and radius 6 inside a card; the boards draw it edge to edge, `10px 24px 8px`, no radius.

#### StatusSimpan

```dart
enum KeadaanSimpan { belum, tersimpan, mencoba, gagal }
class StatusSimpan extends StatelessWidget { const StatusSimpan(this.keadaan, {super.key}); } // header text
class PitaGagalSimpan extends StatelessWidget { const PitaGagalSimpan({super.key, required this.onCobaLagi}); }
class PitaDiubahOrangLain extends StatelessWidget { const PitaDiubahOrangLain({super.key, required this.oleh, required this.jam, required this.onMuat}); }
```

Header text (Main form, trailing in the phone header, `padding-right: 8px`): 13/600; "Belum tersimpan" `tinta3`, "Tersimpan" `laut`, "Mencoba menyimpan lagi…" `tinta3`, "Gagal disimpan" `bata`. (The preview shows 14/600.)

Failure banner (Main, under the header): `role="alert"`, `margin: 0 20px 8px`, `bataLembut` fill, **1 px** `bata` line, radius 12, padding 10 14, row gap 10, appears with `muncul` 200 ms: "**Gagal disimpan.** Isian Anda masih ada di layar ini." 14 `tinta` + button "Coba lagi" (`bata`, 44 high, padding `0 14px`, radius 10, 700/14). Coba lagi → "Mencoba menyimpan lagi…" → after **1100 ms** "Tersimpan" (Main `cobaLagi`).

Changed by someone else (Draf, WebDraf): `role="alert"`, `Kartu` with 1.5 `tinta`, padding 14 16, gap 8: "**Sudah diubah sejak Anda membukanya** (oleh {nama}, 16/11/2026 10.58, dari perangkat lain)." then "Isian Anda tidak menimpa perubahan itu. Muat versi terbaru, lalu lanj…" 14 `tinta2` (full copy in the Draf spec) and the load button.

Rules: never claims Tersimpan before it is; Coba lagi never creates a second transaction or No. Bukti; the input stays on screen.

Boards: Main (tweak `gagalSimpan`), Draf, WebDraf, Sambungan, WebSambungan, Cakupan, Memuat.

### 3.7 Containers

#### LembarBawah

```dart
Future<T?> tampilkanLembarBawah<T>(BuildContext context, {
  required String judul, required WidgetBuilder isi,
  bool pegangan = true,                    // the 40 × 4 handle
  Color? latar,                            // permukaan (default) or kertas (PilihBulan)
  EdgeInsets padding = const EdgeInsets.fromLTRB(20, 10, 20, 24),
  double ukuranJudul = 18,                 // 18; 19 Pemeriksa; 20 MataAnggaran
  String labelTirai = 'Kembali',           // aria-label of the scrim button (Main: 'Kembali ke Beranda')
});
```

As drawn on the 10 phone boards with a sheet (Bagi, Draf, Keluar, Kewajiban, Koreksi, Lainnya, Main, MataAnggaran, Pemeriksa, PilihBulan):

- Built inside the phone frame (an `OverlayEntry`/`Stack` of the screen, not a route; CONVENTIONS: a sheet is not a route), so it stays inside the 390 × 844 frame.
- Scrim: a full-size button, `tirai` (tinta 45 %), fades in with `pudar` 200 ms, tapping it closes the sheet; `Semantics(button, label: labelTirai)`.
- Sheet: bottom, full width, `latar`, top corners `radius-lembar` 22, padding `10px 20px 28px` (Main) / `10px 20px 24px` (others) / `18px 20px 24px` (no handle), column gap 14 on most; rises with `naik` (translateY 100 % → 0) **280 ms** `PalakatMotion.keluar` (Main, Bagi, Kewajiban, Koreksi, Lainnya, MataAnggaran, Pemeriksa); Draf, Keluar and PilihBulan use `muncul` 280 ms and no handle.
- Handle: `40 × 4`, radius 2, `garisTegas`, centred, `margin-bottom: 14px` (4 when the sheet has a 14 gap).
- Title: `h2`, 18/700 (`judulLayar`), `margin: 0 0 6px`.
- Content scrolls if taller than 85 % of the frame (a prototype safeguard; no board's sheet is that tall).

Rules: on web the same content is a side panel (`PanelSamping`, 4.6), not a sheet over the page.

Accessibility: focus moves into the sheet; Escape and system Back close it; `Semantics(scopesRoute: true, namesRoute: true, label: judul)`.

**Boards vs preview:** preview title 17/700; boards 18 (19, 20 in two). Preview handle margin 12; Main 14.

### 3.8 Platform

#### BertindakSebagai

```dart
class DaftarJabatan extends StatelessWidget {        // 'Jabatan Anda' card
  const DaftarJabatan({super.key, required this.nama, required this.jabatan});
}
class LabelSebagai extends StatelessWidget {         // second line of a work item
  const LabelSebagai({super.key, required this.jabatan, required this.rincian}); // 'Sebagai {jabatan} · {rincian}'
}
class BertindakSebagai extends StatelessWidget {     // the notice before confirming
  const BertindakSebagai.satu({super.key, required this.jabatan});
  const BertindakSebagai.pilih({super.key, required this.jabatan, required this.onPilih});
}
```

| Part | Look | Copy |
| --- | --- | --- |
| DaftarJabatan | `Kartu` padding 12 14, gap 8: name 700, "Jabatan Anda" 13 `tinta3`; post chips `LencanaStatus(bentuk: peran)` in a wrap, gap 6 | "Pnt. Hendrik Rumagit", "Penatua Kolom 7", "Ketua Komisi Diakonia" |
| Work item | `Kartu` padding 12 16: title 600; "Sebagai {jabatan} · …" 13 `tinta3` | "5 data menunggu verifikasi" / "Sebagai Penatua Kolom 7 · 2 permohonan · 2 peristiwa" |
| One post has authority | `lautLembut`, radius 12, padding 12 14, 14 px | "**Anda bertindak sebagai Penatua Kolom 7.** Hanya jabatan ini yang berwenang." (sentence in `tinta2`) |
| Two posts have authority | 1.5 `tinta`, radius 12, `permukaan`, padding 12 14, 14 px, then two `kedua` buttons (48 high on boards, 52 in preview; `flex: 1 1 150px; max-width: 340px`, gap 8) | "**Dua jabatan Anda dapat menyetujui ini.** Pilih salah satu." / "Sebagai Penatua Kolom 7" / "Sebagai Ketua Komisi Diakonia" |

Rules: one person, one account, one Beranda, no post switcher; a person with one post does not get the "Sebagai" label; when two posts have authority the app asks, never guesses; the post used is recorded in Riwayat and cannot be changed; another post never opens a way to approve one's own submission.

Boards: BerandaJabatan, WebBerandaJabatan, AlurBeranda, Kesiapan, WebKesiapan, Pemeriksa, WebPemeriksa, PermohonanAnggota, Masuk, WebMasuk.

#### TampilanNama

```dart
enum BentukNama { namaLengkap, namaKeluarga, keluargaKolom, kolom, bipra, bipraKolom, tanpaNama }
class TampilanNama extends StatelessWidget {
  const TampilanNama({super.key, required this.pilihan, required this.contoh, required this.onPilih,
      required this.contohKalimat, this.masihDikenali});
  final BentukNama pilihan;
  final Map<BentukNama, String> contoh;   // right-hand sample per row: 'Kel. Wenas-Lasut — Kolom 7'
  final String contohKalimat;             // 'Syukur HUT pernikahan: '
  final String? masihDikenali;            // sentence after 'Masih mudah dikenali.'
}
```

Labels (verbatim, in order): "Nama lengkap", "Nama keluarga", "Keluarga + Kolom", "Kolom", "BIPRA", "BIPRA + Kolom", "Tanpa nama".

Row (board): a `label` row = `Tekan`, `permukaan`, 1 `garis`, radius 14, padding 10 14, `min-height: 44px`, gap 12, 15 px: `PilihanBulat` 22, the form name (flex), the sample 13 `tinta3`. Preview card: `lautLembut`, radius 14, padding 14 16 (12 14 preview), gap 6: "Lihat tampilan nama saya" 13 `tinta3`, then 15 px "Syukur HUT pernikahan: **Kel. Wenas-Lasut — Kolom 7**". Warning: 1.5 dashed `putus`, radius 14, padding 12 14, 14 px: "**Masih mudah dikenali.** " + `tinta2` sentence (e.g. "Kolom 11 hanya punya satu anggota Remaja. Pilih “Kolom” atau “Tanpa nama” bila tidak ingin dikenali."). Footer note 13 `tinta3`.

Rules: the member's choice is followed in Warta Jemaat and every publication; a more private personal choice beats the family default; only the Sekretaris Jemaat can show a name as an exception, with a reason and a Riwayat record (BukaNama); a change applies to the next publication.

Accessibility: radio group semantics (`Semantics(inMutuallyExclusiveGroup: true, checked:)`).

Boards: TampilanNama, AlurNama, PetaPlatform (and the name shown in WartaEditor, A4Warta).

#### RiwayatAlur

```dart
class RiwayatAlur extends StatelessWidget {
  const RiwayatAlur({super.key, required this.baris, this.judul = 'Riwayat'});
  final List<String> baris; // newest first, each already '16/11/2026 · {what} · {who}, {post}'
}
```

As drawn on the flow boards: heading `h2` 16/700 "Riwayat", margin 0; `Kartu` padding `4px 16px`, column; row `padding: 8px 0; border-top: 1px solid garis; margin-top: -1px`, 13 `tinta3`. Draw the first row's rule too: the −1 only overlaps a rule with the row above, so with the card's 4 px top padding the first rule shows 3 px under the card's top edge, inset 16 (every board with this list draws it so). Shown only once there is at least one row (`riwAda`). New rows are prepended by the screen's handler (`catat()` puts `HARI_T + ' · ' + t` in front).

Rules: each row has date, what, who and the post used; a typed reason is recorded verbatim; an Operator row for a vacant post says so ("… · oleh Yanti Sumual, Operator · menjalankan jabatan kosong Penatua Kolom 2"); no actions, nothing editable.

Boards: 35 (all `Alur*` and `WebAlur*` with a history, AkunSaya, WebAkunSaya, Draf, WebDraf, KasUnit, WebKasUnit, PemberiPersetujuan, Main detail (plain 14 `tinta2` lines "10.42 · Dibukukan oleh {plk}"), TabTransaksi, WebTransaksi).

#### PratinjauLayarKunci

```dart
class PratinjauLayarKunci extends StatelessWidget {
  const PratinjauLayarKunci({super.key, required this.modul, required this.jumlah, required this.jenis});
  // renders '{modul}: {jumlah} {jenis}' – e.g. 'Data jemaat: 1 data menunggu verifikasi'
}
```

Look (AkunSaya): caption "Yang tampil di layar kunci" 13 `tinta3`; sample `tinta` field, radius 12, padding 10 14, 14 px, `permukaan` text: "Palakat" 700, then the line; caption after: "Hanya modul dan jenis pekerjaannya. Tidak ada nama orang dan tidak ada jumlah uang di layar kunci." 13 `tinta3`.

Rules: content is always "{modul}: {jumlah} {jenis pekerjaan}", never a name, family, Kolom or amount; details only after opening and signing in; push only supplements Beranda and Pemberitahuan; a refused permission is said once; push settings exist only on the phone (WebAkunSaya says they are set from the phone).

Boards: AkunSaya (WebAkunSaya shows the "set from the phone" sentence).

---

## 4. App chrome (`shell/`)

### 4.1 Phone screen scaffold `LayarPonsel`

Every phone board's root (all 101 phone boards):

```
SizedBox.expand (takes the frame's 390 × 844, or the full SafeArea when unframed; never a fixed 390 × 844), kertas, DefaultTextStyle isi h1.4, clip
└─ Column
   ├─ PitaJabatanKosong.ponsel        (only when the board has the tweak and it is on)
   └─ Expanded → Stack                 (the board's `position: relative; flex: 1; min-height: 0`)
        ├─ the current view            (absolute, inset 0)
        ├─ PonselTabBar                (Main, Lainnya only)
        ├─ Toast                       (Main only)
        └─ LembarBawah overlay
```

```dart
class LayarPonsel extends StatelessWidget {
  const LayarPonsel({super.key, required this.child, this.jabatanKosong = false, this.overlay = const []});
}
```

**Header `KepalaPonsel`** (85 boards use the identical container `display: flex; align-items: center; gap: 8px; padding: 14px 12px 8px`):

```dart
class KepalaPonsel extends StatelessWidget {
  const KepalaPonsel({super.key, required this.judul, this.anakJudul, this.kembaliKe, this.onKembali,
      this.diSini, this.labelKembali = 'Kembali', this.ujung, this.judulMono = false});
  final String judul;           // h1
  final String? anakJudul;      // subtitle under the title
  final String? kembaliKe;      // board stem → Tautan; or…
  final VoidCallback? onKembali;// …a view change inside the board (button)
  final VoidCallback? diSini;   // passed to the back Tautan: runs instead of navigating when kembaliKe is the current board (BerandaJabatan, KeuanganUnit)
  final String labelKembali;    // aria-label verbatim: 'Kembali', 'Kembali ke Beranda', 'Kembali ke Lainnya' …
  final Widget? ujung;          // trailing: StatusSimpan, LencanaStatus(kepala), or a small action
  final bool judulMono;         // No. Bukti titles
}
```

| Part | Look |
| --- | --- |
| Back | `44 × 44`, centred `Ikon.kembali` 22, stroke 2, colour `tinta` (`currentColor`); white on the dark Kamera board (`diLaut`/`permukaan` per its spec). A `Tautan` when the board uses `<a href>` (92 places), a `Tekan` when it uses `<button onClick>` (21) |
| Title | `h1` 18/700, `margin: 0`, `flex: 1`. With subtitle: a `flex: 1` column, subtitle 13 `tinta2`. Mono variant: mono 17/600 (Koreksi, Main detail, Terbatas) or mono 16/600 (LihatDokumen) |
| Trailing | save status 13/600 + `padding-right: 8px`; a `kepala` badge + `margin-right: 8px`; or an action (Kewajiban "+ Kasus baru": 44 high, padding `0 14px`, `margin-right: 8px`, radius 12, `laut`, `diLaut` 700) |
| Variants | Pemeriksa/Main periksa: title `margin-left: 8px` when the back button is hidden; one board uses bottom padding 4 |

**Body**: `Expanded` scroll, `padding: 8px 20px 20px` (24 bottom on some), column gap 16 (18 in forms, 12–14 in lists). Main screens without back (Beranda, Transaksi in Main): `padding: 24px 20px 28px`, gap 22/14, bottom inset 84 for the tab bar.

**Bottom action bar `AksiBawah`**: `padding: 12px 20px 22px; background: permukaan; border-top: 1px solid garis; display: flex; flex-direction: column; gap: 6px` (8 on most); full-width buttons.

**Child views** (`/Main/catat` …): enter with `masuk` (opacity 0 → 1, translateX 24 → 0, 280 ms, `keluar` curve); full-screen pickers with `naik` 280 ms; in-board view swaps with `pudar` 200 ms (`motion.md`).

### 4.2 Phone bottom tab bar `PonselTabBar`

From Main (lines 120–126) and Lainnya (line 54); no other board draws it.

```dart
enum TabPonsel { beranda, transaksi, bulan, lainnya }
class PonselTabBar extends StatelessWidget {
  const PonselTabBar({super.key, required this.aktif, this.beranda, this.transaksi, this.catat,
      this.diameterCatat = 58});
  final TabPonsel aktif;                       // which item is laut and Semantics selected
  final Widget Function(Widget isi)? beranda;  // wraps the drawn item (icon + label); null = drawn unwrapped
  final Widget Function(Widget isi)? transaksi;
  final Widget Function(Widget isi)? catat;    // wraps the circle
  final double diameterCatat;
  // Built in: Bulan → Tautan(ke: 'TutupBuku', cara: Cara.ganti); Lainnya → Tautan(ke: 'Lainnya', cara: Cara.ganti),
  // or a plain label when aktif == TabPonsel.lainnya
}
```

The three left items are builders, not callbacks, because Main and Lainnya wire them differently: Main runs in-board handlers, Lainnya links to Main. Each board's screen file spells out its own wrapper, so the link test finds `Tautan(ke: 'Main'` in `lainnya.dart` (navigation.md 3.1).

```dart
// Main (main.dart)
PonselTabBar(
  aktif: TabPonsel.beranda, // TabPonsel.transaksi on /Main/transaksi
  beranda: (isi) => Tekan(onTap: keBeranda, child: isi),
  transaksi: (isi) => Tekan(onTap: bukaDaftar, child: isi),
  catat: (isi) => Tekan(onTap: bukaSheet, label: 'Catat transaksi', radius: 999, child: isi),
)

// Lainnya (lainnya.dart)
PonselTabBar(
  aktif: TabPonsel.lainnya,
  beranda: (isi) => Tautan(ke: 'Main', cara: Cara.ganti, child: isi),
  transaksi: (isi) => Tautan(ke: 'Main', cara: Cara.ganti, child: isi),
  catat: (isi) => Tautan(ke: 'Main', cara: Cara.ganti, label: 'Catat transaksi', radius: 999, child: isi),
  diameterCatat: 66,
)
```

| Part | Look |
| --- | --- |
| Bar | `position: absolute; left 0; right 0; bottom 0; height: 84px`; `permukaan`; `border-top: 1px solid garis`; 5 equal columns; `align-items: start; padding-top: 8px` |
| Item | column, `min-height: 52px`, gap 3, centred, 13/600; icon 22; colour `laut` when active, `tinta3` otherwise (`navB`/`navT` in Main) |
| Items | Beranda (`Ikon.beranda`), Transaksi (`Ikon.transaksi`), centre Catat, Bulan (`Ikon.bulan`), Lainnya (`Ikon.lainnya`, filled dots) |
| Catat | centred in its column, circle `laut`, `margin-top: -22px`, `border: 4px solid kertas`, `Ikon.tambah` 24 stroke 2.4 in `diLaut`, `aria-label` "Catat transaksi"; Main: 58 × 58 outer (a `<button>` is border-box), Lainnya: 66 × 66 outer (`box-sizing: content-box`) – pass `diameterCatat: 58` / `66` |

Behaviour in Main: Beranda → view `beranda`, Transaksi → view `daftar`, Catat → opens the "Catat apa?" sheet (all three through the `Tekan` builders above), Bulan → `Tautan(ke: 'TutupBuku', cara: Cara.ganti)`, Lainnya → `Tautan(ke: 'Lainnya', cara: Cara.ganti)`. In Lainnya: Beranda, Transaksi and Catat are each passed in as `Tautan(ke: 'Main', cara: Cara.ganti)`; Bulan → TutupBuku; Lainnya is the active, non-link item (`laut`). The bar shows only on Main's `beranda` and `daftar` views (`showNav`). The bar itself marks the active item `Semantics(selected: true)`, so the builders do not pass `dipilih`.

### 4.3 Web side nav `NavSamping` and the "Menu" drawer

Identical on all 86 laptop and tablet boards (`class="pn"`):

```dart
class NavSamping extends StatelessWidget {
  const NavSamping({super.key, required this.item, required this.aktif, required this.pengguna, this.diSini});
  final List<({String teks, String ke})> item; // per board, from its `nav` array (navigation.md lists every variant)
  final int? aktif;                             // index drawn active; null when the board highlights no item
  final Widget pengguna;                        // footer block, e.g. '**Meiske L.** · Bendahara' / 'Wewenang Bendahara aktif'
  final VoidCallback? diSini;                   // passed to every item's Tautan; runs, instead of navigating, on an item whose `ke` is the current board
                                                // (the active item on most boards; "Pemulihan akun", not the active "Masuk", on WebPemulihan; all three items on WebTerbatas)
}
```

Wide (> 860 px window):

| Part | Look |
| --- | --- |
| Column | `flex: 1 1 220px` (width = 220 + (W − 780) / 1000, ≈ 221 at 1440); `padding: 24px 16px`; `permukaan`; `border-right: 1px solid garis`; column gap 20; full page height; scrolls with the page (not sticky) |
| Brand | row gap 10, `padding: 0 8px`: `TandaPalakat(26)`, then "palakat" 18/700 line height 1.1 and "Jemaat Karunia" 13 `tinta3` |
| Item | `Tautan`, `display: flex; align-items: center; min-height: 44px; padding: 0 12px; border-radius: 10px; font-weight: 600`, no underline; active: `tinta` fill, `permukaan` text; others: no fill, `tinta` text (same on all 86 boards) |
| Footer | `margin-top: auto` (bottom of the column), `padding: 12px 8px 0; border-top: 1px solid garis; font-size: 13px; color: tinta2`, names in `<strong>` `tinta` |

Narrow (≤ 860 px window, CSS `@media (max-width:860px)`), not a Material `Drawer` but the boards' inline top bar:

| Part | Look |
| --- | --- |
| Bar | full width row on top of the content, `flex-wrap: wrap; align-items: center; gap: 0 12px; padding: 8px 16px`; no right border; `border-bottom: 1px solid garis`; `permukaan` |
| Brand | as wide |
| Menu button | `margin-left: auto`; `min-height: 44px; padding: 0 16px; border-radius: 14px; border: 1.5px solid tinta; permukaan; 700/14`; label "Menu"; open: `tinta` fill, `permukaan` text, label "Tutup menu"; `Semantics(label: 'Menu', toggled: open)` (board: a checkbox with `aria-label="Menu"`) |
| Open | items appear below the brand row inside the bar (full width, `padding: 8px 0`), then the footer (`margin-top: 0; padding-bottom: 8px`); the content is pushed down, not covered |
| Closed | items and footer hidden |

Layout without intrinsics (the page scrolls as one): `SingleChildScrollView` → `ConstrainedBox(minHeight: viewport)` → wide: `Stack(children: [Positioned(left 0, top 0, bottom 0, width w, child: NavSamping column with Spacer before the footer), Padding(left: w, child: main)])`; narrow: `Column([NavSamping bar, main])`. Open/closed state lives in the page state (resets on navigation, as the board's checkbox does).

### 4.4 Laptop page scaffold `HalamanWeb`

```dart
class HalamanWeb extends StatelessWidget {
  const HalamanWeb({super.key, required this.nav, required this.isi, this.jarak = 20, this.jabatanKosong = false});
  final NavSamping? nav;  // null on pages without nav (sign-in, launcher)
  final List<Widget> isi; // children of <main>
  final double jarak;     // main column gap: 20 (81 boards), 24 (WebBeranda, TabBeranda), 22 (WebAwal, WebAwalIsian), 18 (WebLaporan)
}
```

- Root: `kertas`, `DefaultTextStyle(isiWeb, height 1.45)`, `min-height: 100vh`.
- `main`: `flex: 999 1 560px; min-width: 0; padding: 28px clamp(16px, 3vw, 40px) 40px` → horizontal padding `context.jepit(16, 3, 40)` (40 at 1440, 25.8 at 860, 16 at 390), top 28, bottom 40; column, gap `jarak`.
- First child when the switch is on: `PitaJabatanKosong.web`.
- Page title block (most boards): optional breadcrumb `TautanTeks` 14/600; `h1` 26/700 (`judulHalaman`), `margin: 2px 0 0` after a breadcrumb; subtitle 14 `tinta2`; trailing actions in a wrapping row (`flex-wrap: wrap; align-items: center; gap: 12px`, title `flex: 1 1 200px`).
- Main/aside rows: `BarisLentur` with the board's bases (common: `[Lentur(dasar: 520, tumbuh: 999), Lentur(dasar: 360)]` gap 24; `[1.3 1 420px, …]` with `gap: 20px 28px` on 25 boards).
- Must render without overflow at 1440, 1280, 860 and 390 wide (CONVENTIONS DoD).

Tablet boards (TabBeranda, TabCatat, TabTransaksi, 834 × 1112): the same scaffold; at 834 the narrow nav bar applies.

### 4.5 Toast `Toast`

Only Main draws one (after "Simpan sebagai draf"):

```dart
class Toast extends StatelessWidget { const Toast(this.teks, {super.key}); }
```

`position: absolute; left: 20px; right: 20px; bottom: 100px` (above the tab bar); `tinta` field; **1.5 dashed `garisTegas`** line (a draft is not in the balance); radius 14; padding 12 16; 14/600 `permukaan`; enters with `muncul` (opacity 0, translateY 8 → 0) 280 ms `keluar` curve; the screen hides it after **2600 ms** (`t4`). `role="status"` → live region. Copy: "Draf tersimpan · belum masuk saldo".

### 4.6 Side panel on web `PanelSamping`

What is a bottom sheet on the phone is an `aside` in the content row on web, not an overlay:

```dart
class PanelSamping extends StatelessWidget {
  const PanelSamping({super.key, required this.anak, this.berbingkai = false, this.dasar = 340, this.maks, this.jarak = 14});
  // used as the second Lentur of a BarisLentur
}
```

- Plain (WebPilihBulan, WebLaporan, WebPemeriksa …): column gap 12–16, no box; `flex: 1 1 280–400px`.
- Framed (WebKeluar): `permukaan`, 1.5 `tinta`, radius 14, padding 20, gap 12, `max-width: 420px`; boxed (WebTransaksi detail): `permukaan`, 1 `garis`, radius 14, padding 20, gap 10–14.
- AI panel (WebAI): `lautLembut`, radius 18, padding 18, gap 14.
- Opening: appears with `muncul` 300 ms where the board animates it (WebPilihBulan, WebKeluar, WebTransaksi); closes instantly.

### 4.7 A4 page scaffold `HalamanA4`

```dart
class HalamanA4 extends StatelessWidget {
  const HalamanA4({super.key, required this.ukuran, required this.kode, required this.judul, required this.subjudul,
      required this.kanan, required this.kakiKanan, required this.isi});
  final Size ukuran;           // Size(794, 1123) portrait | Size(1123, 794) landscape (A4F02a–c)
  final String kode;           // 'F01 · LAPORAN RESMI'
  final String judul;          // 'LAPORAN PERBENDAHARAAN BULANAN'
  final String subjudul;       // 'Jemaat Karunia · Periode laporan 1–31 Oktober 2026 · …'
  final List<String> kanan;    // mono lines: 'ID SNP-2026-10-01', 'Dibekukan 16/11/2026 11.05', 'Versi Mata Anggaran 2026.1'
  final String kakiKanan;      // 'F01 · halaman 1 dari 1'
  final List<Widget> isi;
}
```

- Page: fixed `ukuran`, `padding: 48px 52px 0`, clip, white paper: always rendered with `PalakatWarna.terang` (a printed page does not follow the dark theme), `permukaan` background, sans 13, line height 1.4, column gap 14.
- Presented centred on `kertas` with 24 margin, scaled down with `FittedBox(fit: BoxFit.scaleDown)` to fit narrower windows, scrolls (CONVENTIONS form factor).
- Header rule: row `justify-content: space-between; align-items: flex-end; gap: 24px; border-bottom: 2px solid tinta; padding-bottom: 10px`. Left: `kode` 600, letter spacing .4, `tinta2`; `judul` 20/700, letter spacing .2; `subjudul` 13. Right: `flex: none; text-align: right`, mono `tinta2`, one line per `kanan`.
- Footer: `position: absolute; left: 52px; right: 52px; bottom: 34px; display: flex; justify-content: space-between; gap: 24px; border-top: 1px solid tinta; padding-top: 8px; color: tinta2`: left "Palakat · format bawaan aplikasi, bukan formulir resmi GMIM · Jemaat Karunia", right mono `kakiKanan` (`flex: none`).
- Table rows inside are screen content (grid columns with `border-bottom: 1.5px solid tinta` header rows; see the A4 specs).

Boards: A4F01, A4F02a, A4F02b, A4F02c, A4F14, A4Sementara, A4Terbatas. **A4Warta** uses its own form (`HalamanA4.warta`): padding `56px 60px 0`, gap 20, sans 14 line height 1.45; centred header with `border-bottom: 2px solid tinta; padding-bottom: 12px`: "WARTA JEMAAT" 30/700 letter spacing 1, "GMIM Jemaat Karunia · Minggu, 22 November 2026" 15; section headings 13/700, letter spacing .5, upper case, `border-bottom: 1.5px solid tinta; padding-bottom: 3px; margin-bottom: 6px`; footer `left/right 60px, bottom 36px`, text "Diterbitkan 21/11/2026 oleh Sekretaris Jemaat · nama mengikuti Tampilan nama pilihan anggota" and mono "Edisi 22/11/2026 · halaman 1 dari 1", at **13 px** (the board's 12 px raised to the 13 px floor; also listed in the A4Warta spec).

### 4.8 Device frame `BingkaiPerangkat`

```dart
class BingkaiPerangkat extends StatelessWidget { const BingkaiPerangkat({super.key, required this.child}); }
```

- Window wider than 600 px and the panel's "Bingkai ponsel" switch on (default on): the phone board renders in a `390 × 844` box, `ClipRRect` radius **36** (canvas.json `radius: 36`), 1 px `garisTegas` outline, no shadow, centred on a `garis` backdrop with 24 margin; scaled down with `FittedBox(scaleDown)` when the window is shorter than 892. The board scrolls inside its own frame. `MediaQuery` inside the frame reports `Size(390, 844)` so `vw` and layout match the board.
- Window 600 px or narrower, or switch off: the board fills the screen (`SafeArea`), no frame.

### 4.9 Keadaan panel `PanelKeadaan` and `PrototypeState`

Prototype chrome, not app UI (CONVENTIONS "Prototype chrome"). It uses the same tokens but must never be mistaken for a screen element.

```dart
class PrototypeState extends ChangeNotifier {
  bool jabatanKosong = false;
  ThemeMode tema = ThemeMode.light;           // Terang / Gelap
  bool kurangiGerak = false;
  bool bingkaiPonsel = true;
  final Map<String, Map<String, Object>> tweak = {}; // stem → {tweak: value}, defaults from boards.dart
  final ValueNotifier<Map<String, List<Widget>>> perangkat = ValueNotifier(const {}); // stem → board-registered prototype devices; only the panel listens
  Object nilai(String stem, String nama);     // current value or the data-props default; 'jabatanKosong' reads the global field
  void setel(String stem, String nama, Object v); // 'jabatanKosong' writes the global field
  static PrototypeState of(BuildContext c);   // via InheritedNotifier at the app root
}
```

Placement:

| Form factor | Panel |
| --- | --- |
| Phone board in the device frame, window ≥ 800 wide | Always open, 320 wide column to the right of the frame, gap 24, scrolls |
| Phone board in the frame, window 601–799 wide | Floating button as for laptop boards |
| Phone board full screen (narrow window) | A `24 × 64` handle at the right edge, vertically centred, `tinta` fill, radius 12 on the left corners, label "Keadaan" (`Semantics(button)`); opens the panel as a sheet over the screen |
| Laptop, tablet, A4, sheet boards | A floating button bottom-right (inset 16), `48 × 48` circle, `tinta`, `Ikon.lainnya` in `permukaan`, `aria` "Keadaan"; opens a 320-wide panel on the right over the page with a `tirai` scrim |

Content, top to bottom (panel `permukaan`, 1 `garis` line, radius 16, padding 16, gap 16, `isiWeb` text):

1. The board's canvas title (16/700) and stem (mono 13 `tinta3`); a "Semua layar" link, `Tekan(onTap: () => context.go('/'), peran: PeranTekan.tautan)` (`/` is not a board stem, so not `Tautan`); and a "Kembali" action, `Tekan(onTap: () => router.routerDelegate.popRoute(), peran: PeranTekan.tautan)`, hidden at the launcher. "Kembali" pops exactly as system Back does (overlay first, child route to its parent view; navigation.md 5.1). It is the iOS way back from boards without a back control (TutupBuku, Awal, Terbatas list, Pemeriksa, Masuk, PilihBulan), since iOS has no system Back and `halaman` pages have no edge swipe.
2. **Tweak** section: one control per tweak of the board, labelled with the tweak's exact name: `boolean` → `Sakelar`; `enum` → `ChipPilihan` with the exact options; default selected = `data-props` default. Changing one calls `setel` and the screen rebuilds. The Tweak section skips `jabatanKosong`; `nilai(stem, 'jabatanKosong')` and `setel` read and write the global field.
3. **Semua layar** switches: "jabatanKosong" (labelled "Jabatan kosong · Operator Yanti Sumual menjalankan Bendahara Jemaat"; affects every board that has the tweak), "Terang" / "Gelap" (chips), "Kurangi gerak" (`Sakelar`), "Bingkai ponsel" (`Sakelar`).
4. **Alat prototipe** (only when the board registers some): the devices the handoff says not to build into screens – "Dilihat sebagai" chips, buttons starting with "Contoh:", the accepted code "123456", "Di prototipe ini: …" hints – each under a small 13 `tinta3` label "Hanya di prototipe". A screen registers them with:

   ```dart
   class AlatPrototipe extends StatefulWidget {
     const AlatPrototipe({super.key, required this.stem, required this.alat, required this.child});
     final String stem;
     final List<Widget> alat;
   }
   ```

   The screen builds `alat` from its own state in `build`, so a device that depends on that state (AlurUnit's "Contoh: … dibukukan" buttons, shown only while their item is not yet done; the current "Dilihat sebagai" selection) changes with it. `AlatPrototipe` publishes post-frame in `initState` and again on every `didUpdateWidget`, writing a new map `{...perangkat.value, stem: alat}`; on dispose it removes its `stem` entry, also post-frame (a notify during build or dispose hits a locked tree). Only the panel listens to `perangkat`, so publishing never rebuilds the screen. The panel shows the entry of the top board, the stem `BingkaiPerangkat` reads (navigation.md 5.2): a page pushed on top shows its own devices, and popping it shows the lower page's entry again.

5. **Tautan masuk**: every board that links here (`inbound` from the registry) as `Tautan` rows with their titles.

### 4.10 Launcher `Peluncur` (route `/`)

A laptop-style page (`HalamanWeb` without nav), title "Palakat · prototipe" (26/700), subtitle "199 layar · data contoh, tanpa server" (14 `tinta2`), a `ChipPilihan` "Urutkan menurut" with "Halaman kanvas" / "Perjalanan jabatan", then the groups:

- by canvas page, in canvas order (12 groups: Ponsel … Putaran 5), each a `JudulBagian` + a `Kartu` of `BarisDaftar` rows: canvas title (600) and stem (mono 13 `tinta3`), `Tautan(ke: stem)`;
- by role journey, the lists of `03-screens-and-flows.md` "Journeys by role" as given in `navigation.md`.

First row of the page: `Tautan(ke: '_komponen')` "Komponen" (the M1 gallery). The Keadaan panel button is present here too (global switches only).

---

## 5. Icons

25 distinct inline SVGs are drawn on the boards (the same 25 as `docs/build/icon-inventory.json`, regrouped with their root attributes): 306 `<svg>` elements in all. No board uses an `<img>`. Glyphs used as icons in text (`✓`, `+`, `−`, `⇄`) are text, not SVG.

### 5.1 Icon table

Dart identifiers live in `abstract final class Ikon` (`widgets/ikon.dart`). Default size and stroke are the most common board values; the per-use overrides are listed.

| Ikon | viewBox | Root attributes (`akar`) | Default size / stroke | Colour on boards | Uses | Boards |
| --- | --- | --- | --- | --- | --- | --- |
| `kembali` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round"` | 22 / 2 | `currentColor` = `tinta` (white on Kamera) | 115 | 98 phone boards: every back button |
| `tanda` (logo) | 0 0 24 24 | none | 26 (40 on Masuk, WebMasuk) | `laut` | 90 | Main, Awal, Masuk, TabBeranda, TabCatat, TabTransaksi, all 83 Web boards |
| `lanjut` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round"` | 18 / 2 | `tinta3` | 50 | 24: rows of Main, Awal, Lainnya, Laporan, TabBeranda, AlurBeranda, AntreanVerifikasi, BerandaJabatan, CariOrang, DokumenGereja, Keluar, KotakMasuk, Pengumuman, PermohonanSurat, WartaArsip and the Web boards of the last nine plus WebBeranda |
| `terpenuhi` | 0 0 24 24 | none | 22 (18, 20, 26) | `laut` + `diLaut` | 7 | Main, TabCatat, TutupBuku, WebCatat, WebTutupBuku; `role="img"` `aria-label` "Terpenuhi" in check lists |
| `belumTerpenuhi` | 0 0 24 24 | none | 22 (20) | `bata` + `diBata` | 4 | Main, TabCatat, TutupBuku, WebCatat; `aria-label` "Belum terpenuhi" |
| `untukDiketahui` | 0 0 24 24 | none | 22 (20) | `tinta3` | 3 | Main, TabCatat, WebCatat; `aria-label` "Untuk diketahui" |
| `beranda` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round" stroke-linejoin="round"` | 22 / 2 | `currentColor` | 2 | Main, Lainnya tab bar |
| `transaksi` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round"` | 22 / 2 | `currentColor` | 2 | Main, Lainnya tab bar |
| `tambah` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round"` | 24 / 2.4 | `diLaut` on `laut` | 2 | Main, Lainnya Catat button |
| `bulan` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round"` | 22 / 2 | `currentColor` | 2 | Main, Lainnya tab bar |
| `lainnya` | 0 0 24 24 | `fill="{warna}"` | 22 | `currentColor` | 2 | Main, Lainnya tab bar |
| `kamera` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round" stroke-linejoin="round"` | 20 / 2 | `laut` (button text colour) | 1 | Main "Lampirkan dokumen pendukung" |
| `silang` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round"` | 18 / 2 (16 / 2.4 on AwalIsian, WebAwalIsian) | `tinta3` | 4 | Bagi, WebBagi (remove row), AwalIsian, WebAwalIsian |
| `centang` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round" stroke-linejoin="round"` | 20 / 2.5 `laut`; 14 / 3.4 `permukaan` on a `tinta` checkbox | `laut` / `permukaan` | 4 | LihatTransaksi, WebLihatTransaksi, WebRekonsiliasi |
| `kait` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round"` | 16 / 2.6 (15 on WebRekonsiliasi) | `diLaut` inside a 32 (30) `laut` circle | 2 | TutupBuku, WebRekonsiliasi (the `kait` match dot) |
| `tanpaSambungan` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round"` | 22 / 2 | `bata` | 2 | Sambungan, WebSambungan |
| `unggah` | 0 0 24 24 | `fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round" stroke-linejoin="round"` | 36 / 1.8 | `tinta2` | 1 | WebUnggah drop zone |
| `sesiBerakhir` | 0 0 56 56 | `fill="none"` | 56 | `putus`, `tinta` | 2 | Sambungan, WebSambungan (session ended) |
| `cincinProses` | 0 0 56 56 | none | 56 (52 web) | `garis`, `tinta` | 2 | TutupBuku, WebTutupBuku "Sedang menutup buku…"; rotates `putar 1s linear infinite` |
| `lingkarBelum` | 0 0 88 88 | none | 88 | `putus` | 1 | Awal (state `wBelum`) |
| `lingkarTunggu` | 0 0 88 88 | none | 88 | `tinta` | 1 | Awal (state `wTunggu`); rotates `putar 6s linear infinite` |
| `lingkarMasuk` | 0 0 88 88 | none | 72 | `tinta` | 2 | Masuk, WebMasuk "Menunggu verifikasi wewenang"; static |
| `lingkarBendahara` | 0 0 88 88 | none | 34 | `tinta` | 1 | Bendahara (waiting for the Petugas verifikasi); rotates `putar 6s linear infinite` |
| `selesai` (animated) | 0 0 88 88 | none | 88 (56 on HitungKas) | `laut`, `diLaut` | 2 | Awal (`wAktif`), HitungKas (count matches) |
| `segel` (animated) | 0 0 104 104 | none | 104 | `permukaan` on `tinta` | 2 | TutupBuku, WebTutupBuku (month closed) |

### 5.2 Markup to embed

Exactly the boards' path data; only colours are replaced by placeholders (`{warna}` = the tint, `{tebal}` = stroke width, `{token}` = that token's current value).

```dart
abstract final class Ikon {
  static const _garis = 'fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round"';
  static const _garisSudut = '$_garis stroke-linejoin="round"';

  static const kembali = IkonData(viewBox: '0 0 24 24', akar: _garis, tebal: 2,
      isi: '<path d="M15 6l-6 6 6 6"/>');
  static const lanjut = IkonData(viewBox: '0 0 24 24', akar: _garis, tebal: 2,
      isi: '<path d="M9 6l6 6-6 6"/>');
  static const tanda = IkonData(viewBox: '0 0 24 24',
      isi: '<rect x="2" y="2" width="20" height="20" rx="6" fill="none" stroke="{laut}" stroke-width="2" stroke-dasharray="3 3"/>'
           '<path d="M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z" fill="{laut}"/>');
  static const terpenuhi = IkonData(viewBox: '0 0 24 24',
      isi: '<circle cx="12" cy="12" r="11" fill="{laut}"/>'
           '<path d="M7 12.5l3.2 3.2L17 9" fill="none" stroke="{diLaut}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>');
  static const belumTerpenuhi = IkonData(viewBox: '0 0 24 24',
      isi: '<rect x="1" y="1" width="22" height="22" rx="6" fill="{bata}"/>'
           '<path d="M12 6.5v7M12 17v.5" fill="none" stroke="{diBata}" stroke-width="2.4" stroke-linecap="round"/>');
  static const untukDiketahui = IkonData(viewBox: '0 0 24 24',
      isi: '<circle cx="12" cy="12" r="10" fill="none" stroke="{tinta3}" stroke-width="2" stroke-dasharray="3 3"/>');
  static const beranda = IkonData(viewBox: '0 0 24 24', akar: _garisSudut, tebal: 2,
      isi: '<path d="M4 11l8-7 8 7v9H4z"/>');
  static const transaksi = IkonData(viewBox: '0 0 24 24', akar: _garis, tebal: 2,
      isi: '<path d="M5 7h14M5 12h14M5 17h9"/>');
  static const tambah = IkonData(viewBox: '0 0 24 24', akar: _garis, tebal: 2.4,
      isi: '<path d="M12 5v14M5 12h14"/>');
  static const bulan = IkonData(viewBox: '0 0 24 24', akar: _garis, tebal: 2,
      isi: '<rect x="4" y="5" width="16" height="15" rx="3"/><path d="M4 10h16M9 3v4M15 3v4"/>');
  static const lainnya = IkonData(viewBox: '0 0 24 24', akar: 'fill="{warna}"',
      isi: '<circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/>');
  static const kamera = IkonData(viewBox: '0 0 24 24', akar: _garisSudut, tebal: 2,
      isi: '<path d="M4 8h3l2-3h6l2 3h3v11H4z"/><circle cx="12" cy="13" r="3.5"/>');
  static const silang = IkonData(viewBox: '0 0 24 24', akar: _garis, tebal: 2,
      isi: '<path d="M6 6l12 12M18 6L6 18"/>');
  static const centang = IkonData(viewBox: '0 0 24 24', akar: _garisSudut, tebal: 2.5,
      isi: '<path d="M5 12.5l4.5 4.5L19 7.5"/>');
  static const kait = IkonData(viewBox: '0 0 24 24', akar: _garis, tebal: 2.6,
      isi: '<path d="M9 15l6-6M10 6l1-1a5 5 0 0 1 7 7l-1 1M14 18l-1 1a5 5 0 0 1-7-7l1-1"/>');
  static const tanpaSambungan = IkonData(viewBox: '0 0 24 24', akar: _garis, tebal: 2,
      isi: '<path d="M2 8.5a15 15 0 0 1 20 0M5.5 12a10 10 0 0 1 13 0M9 15.5a5 5 0 0 1 6 0M3 3l18 18"/>'
           '<circle cx="12" cy="19" r="1" fill="{warna}"/>');
  static const unggah = IkonData(viewBox: '0 0 24 24', akar: _garisSudut, tebal: 1.8,
      isi: '<path d="M12 16V5M7.5 9.5L12 5l4.5 4.5M5 19h14"/>');
  static const sesiBerakhir = IkonData(viewBox: '0 0 56 56', akar: 'fill="none"',
      isi: '<circle cx="28" cy="28" r="26" stroke="{putus}" stroke-width="2" stroke-dasharray="5 5"/>'
           '<rect x="18" y="26" width="20" height="15" rx="3" fill="{tinta}"/>'
           '<path d="M22 26v-4a6 6 0 0 1 12 0v4" stroke="{tinta}" stroke-width="2.5"/>');
  static const cincinProses = IkonData(viewBox: '0 0 56 56',
      isi: '<circle cx="28" cy="28" r="24" fill="none" stroke="{garis}" stroke-width="4"/>'
           '<path d="M28 4a24 24 0 0 1 24 24" fill="none" stroke="{tinta}" stroke-width="4" stroke-linecap="round"/>');
  static const lingkarBelum = IkonData(viewBox: '0 0 88 88',
      isi: '<circle cx="44" cy="44" r="38" fill="none" stroke="{putus}" stroke-width="3" stroke-dasharray="5 6"/>');
  static const lingkarTunggu = IkonData(viewBox: '0 0 88 88',
      isi: '<circle cx="44" cy="44" r="38" fill="none" stroke="{tinta}" stroke-width="3" stroke-dasharray="5 6"/>');
  static const lingkarMasuk = IkonData(viewBox: '0 0 88 88',
      isi: '<circle cx="44" cy="44" r="38" fill="none" stroke="{tinta}" stroke-width="4" stroke-dasharray="6 7"/>');
  static const lingkarBendahara = IkonData(viewBox: '0 0 88 88',
      isi: '<circle cx="44" cy="44" r="38" fill="none" stroke="{tinta}" stroke-width="6" stroke-dasharray="9 10"/>');
  // Static end frames of the two animated icons (the motion draws the frames before it, 5.3):
  static const selesai = IkonData(viewBox: '0 0 88 88',
      isi: '<circle cx="44" cy="44" r="38" fill="{laut}" stroke="{laut}" stroke-width="3"/>'
           '<path d="M29 45l10 10 20-21" fill="none" stroke="{diLaut}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>');
  static const segel = IkonData(viewBox: '0 0 104 104',
      isi: '<circle cx="52" cy="52" r="46" fill="none" stroke="{permukaan}" stroke-width="3"/>'
           '<rect x="35" y="48" width="34" height="26" rx="5" fill="{permukaan}"/>'
           '<path d="M41 48v-8a11 11 0 0 1 22 0v8" fill="none" stroke="{permukaan}" stroke-width="4" stroke-linecap="round"/>');
}
```

Board markup of the two animated icons, colours written as tokens, for reference (the motion recreates them):

```html
<!-- selesai: Awal (88), HitungKas (56) -->
<circle cx="44" cy="44" r="38" fill="{laut}" stroke="{laut}" stroke-width="3" stroke-dasharray="239" transform="rotate(-90 44 44)" style="animation: lingkar .7s ease-out both"/>
<path d="M29 45l10 10 20-21" fill="none" stroke="{diLaut}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" style="animation: pudar .3s .5s both"/>
<!-- segel: TutupBuku, WebTutupBuku (104) -->
<circle cx="52" cy="52" r="46" fill="none" stroke="{permukaan}" stroke-width="3" stroke-dasharray="290" transform="rotate(-90 52 52)" style="animation: lingkar .9s .3s ease-out both"/>
<g style="transform-origin: 52px 52px; animation: cap .5s 1.1s cubic-bezier(.2,.8,.2,1) both"><rect x="35" y="48" width="34" height="26" rx="5" fill="{permukaan}"/><path d="M41 48v-8a11 11 0 0 1 22 0v8" fill="none" stroke="{permukaan}" stroke-width="4" stroke-linecap="round"/></g>
```

### 5.3 Animated and rotating icons

- `cincinProses`, `lingkarTunggu`, `lingkarBendahara`: `RotationTransition` around the `PalakatIkon`, one turn per 1 s / 6 s / 6 s, linear, repeating (`putar`); still under reduced motion.
- `selesai`, `segel`: drawn by a `CustomPainter` in `lib/motion/` (the `lingkar` stroke-dashoffset sweep from −90°, then `pudar` / `cap`), timings as above and in `motion.md`; under reduced motion show the static end frame (`Ikon.selesai`, `Ikon.segel`).
- Drop every `style="animation…"` from SVG strings before parsing (`flutter_svg` ignores CSS animation; leaving it in is harmless but misleading).

### 5.4 Larger illustrations that are not SVG

- The receipt in Kamera, LihatDokumen, WebLihatDokumen, AIFoto: a `230`-wide `PalakatIlustrasi.kertasNota` block, padding 18 16, mono 13 line height 1.55, `bayanganMelayang`, `rotate(-3deg)` or `scale(1.25)` per state (`transition: transform .25s`), 1 px dashed `tinta3` rules. Screen-local (their specs).
- The design-system Cover (`Cover/preview.html`, 960 × 288: word mark "palakat" 104/700, letter spacing −0.023em, and a tile illustration of `laut`, `lautLembut`, `tinta`, one `bata` tile and dashed `putus` tiles `stroke-dasharray: 4 3`) is not on any board; show it only at the top of the `/_komponen` gallery.

---

## 6. Tests for this layer

| Test file | Checks |
| --- | --- |
| `test/format_test.dart` | 2.2 list; `RupiahInputFormatter` both variants (`'0012'` → `'12'`, with `sisakanNol` `'0'` stays `'0'`, `'1250000'` → `'1.250.000'`, 12th digit dropped (default `maks` 11), letters dropped); `bacaTgl` (2.4) |
| `test/garis_test.dart` | `GarisPainter.dashPath` of a 100 px line at 1.5 dashed gives dashes of 4.5 and ends on a dash; dotted gives 1.5 squares; `GarisBorder.dimensions == EdgeInsets.all(tebal)` |
| `test/komponen/lencana_status_test.dart` | each `BentukLencana` → line style and colours of the table; `LencanaStatus.uang` mapping |
| `test/komponen/tombol_bersyarat_test.dart` | no sentence while `sudahMulai` is false; first unmet reason only; press with reason does not call the action; type then press once calls it; semantics hint = reason |
| `test/komponen/tombol_tahan_test.dart` | release at 1000 ms → no `onSelesai`, fill back to 0; hold 1650 ms → `onSelesai` once; keyboard Enter → at once; nothing while `!siap` |
| `test/komponen/<name>_test.dart` | one per remaining component: every variant renders with the colours and texts of its section |
| `test/chrome_test.dart` | `NavSamping` at 1440 (column, active item `tinta`), 860 (bar, "Menu" toggles "Tutup menu" and shows items), 390; `PonselTabBar` active colours and links; `PitaJabatanKosong` follows the global switch; `HalamanA4` footer text |
| `test/ikon_test.dart` | every `Ikon` resolves all placeholders (no `{` left), parses with `flutter_svg`, and contains no hex outside the token map |
| `test/gerak_test.dart` | (with `motion.md`) every component animation is zero under `disableAnimations` |

The `/_komponen` gallery shows every component and variant in both themes side by side, in the order of the design system's groups (Fondasi, Status, Tindakan, Isian, Kartu, Pita, Wadah, Platform), each next to the copy of its preview.
