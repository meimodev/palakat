import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

const _mono = TextStyle(fontFamily: PalakatText.mono);

/// The board's `onChange`: digits only, leading zeros before a digit dropped
/// ("007" → "7", "0" stays), at most 5 characters, caret at the end.
class _FormatLembar extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue lama,
    TextEditingValue baru,
  ) {
    var s = baru.text
        .replaceAll(RegExp(r'\D'), '')
        .replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (s.length > 5) s = s.substring(0, 5);
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}

class WebHitungKasScreen extends StatefulWidget {
  const WebHitungKasScreen({super.key});
  @override
  State<WebHitungKasScreen> createState() => _WebHitungKasScreenState();
}

class _WebHitungKasScreenState extends State<WebHitungKasScreen> {
  static const _awal = ['80', '5', '5', '1', '2', '', ''];
  final _sel = [for (final v in _awal) TextEditingController(text: v)];
  bool _nol = false, _tersimpan = false;
  final _petugas = <String>[];

  @override
  void dispose() {
    for (final s in _sel) {
      s.dispose();
    }
    super.dispose();
  }

  int get _total {
    var t = 0;
    for (var i = 0; i < 7; i++) {
      final d = _sel[i].text;
      t += (d.isEmpty ? 0 : int.parse(d)) * HitungKas.pecahan[i];
    }
    return t;
  }

  bool get _dihitung => _sel.any((s) => s.text.isNotEmpty) || _nol;
  bool get _bisa => _dihitung && _petugas.isNotEmpty && !_tersimpan;

  void _kosong() => setState(() {
    for (final s in _sel) {
      s.clear();
    }
    _nol = true;
    _tersimpan = false;
  });

  void _pilih(String o) => setState(() {
    _petugas.contains(o) ? _petugas.remove(o) : _petugas.add(o);
    _tersimpan = false;
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final total = _total, dihitung = _dihitung, bisa = _bisa;
    final selisih = hitungKasSaldoBuku - total;
    final hasil = dihitung ? rp(total) : kosong;
    final warnaHasil = dihitung ? c.tinta : c.tinta3;
    final pesan = _tersimpan
        ? 'Hitung kas tersimpan · dihitung oleh ${_petugas.join(' dan ')}'
        : !dihitung
        ? 'Isi hasil hitung, atau catat Rp0 bila kas memang kosong.'
        : _petugas.isEmpty
        ? 'Pilih petugas penghitung.'
        : 'Siap disimpan.';

    Widget grid(Widget a, Widget b, Widget d) => Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        SizedBox(width: 120, child: b),
        const SizedBox(width: 16),
        Expanded(child: d),
      ],
    );
    Widget kanan(String s, TextStyle g) =>
        Text(s, textAlign: TextAlign.right, style: g);
    Widget barisAside(String a, Widget b) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(a, style: TextStyle(color: c.tinta2)),
        ),
        Flexible(child: b),
      ],
    );
    Widget chipBank(String teks) => Tautan(
      ke: 'WebRekonsiliasi',
      cara: Cara.ganti,
      radius: 22,
      child: ChipSatu(teks: teks, dipilih: false, onTap: null, padding: 16),
    );

    final kiri = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Hitung kas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                '16 November 2026 · 11.30',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.tinta2,
                  ),
                  child: grid(
                    const Text('Pecahan'),
                    const Text('Lembar', textAlign: TextAlign.right),
                    const Text('Jumlah', textAlign: TextAlign.right),
                  ),
                ),
              ),
              for (var i = 0; i < 7; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.garis)),
                  ),
                  child: _BarisPecahan(
                    pecahan: HitungKas.pecahan[i],
                    controller: _sel[i],
                    onChanged: (_) => setState(() {
                      _nol = false;
                      _tersimpan = false;
                    }),
                    grid: grid,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: c.tinta, width: 1.5)),
                ),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  child: grid(
                    const Text('Hasil hitung kas'),
                    const SizedBox.shrink(),
                    kanan(hasil, _mono.copyWith(color: warnaHasil)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          // flex-wrap: the button keeps its own width, the caption is
          // `flex: 1 1 240px` and wraps under it when there is no room.
          builder: (context, k) {
            final tombol = Tekan(
              onTap: _kosong,
              radius: 12,
              child: RupaTombol(
                label: 'Kas kosong: catat Rp0',
                isi: null,
                garis: GarisBorder.putus(c.putus, radius: 12),
                warnaTeks: c.tinta2,
                radius: 12,
                tinggi: 44,
                paddingH: 16,
                lebarPenuh: false,
              ),
            );
            final teks = Text(
              dihitung
                  ? (_nol && total == 0
                        ? 'Dihitung: Rp0. Nol dicatat sebagai hasil hitung, '
                              'bukan sebagai belum dihitung.'
                        : 'Sel kosong berarti pecahan itu tidak ada.')
                  : hitungKasKosongTeks,
              style: TextStyle(fontSize: 13, color: c.tinta3),
            );
            if (k.maxWidth >= 200 + 12 + 240) {
              return Row(
                children: [
                  tombol,
                  const SizedBox(width: 12),
                  Expanded(child: teks),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [tombol, const SizedBox(height: 12), teks],
            );
          },
        ),
      ],
    );

    final aside = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              barisAside(
                'Saldo buku',
                Text(
                  rp(hitungKasSaldoBuku),
                  style: _mono.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              barisAside(
                'Hasil hitung kas',
                Text(
                  hasil,
                  style: _mono.copyWith(
                    fontWeight: FontWeight.w500,
                    color: warnaHasil,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: c.tinta, width: 1.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Flexible(
                      child: Text(
                        'Selisih belum dijelaskan',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: AnimatedDefaultTextStyle(
                        duration: context.gerak(
                          const Duration(milliseconds: 300),
                        ),
                        style: PalakatText.isiWeb.merge(
                          _mono.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                            color: !dihitung
                                ? c.tinta3
                                : selisih == 0
                                ? c.laut
                                : c.bata,
                          ),
                        ),
                        child: Text(dihitung ? rp(selisih.abs()) : kosong),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                !dihitung
                    ? 'Selisih baru dapat dihitung setelah ada hasil hitung kas.'
                    : selisih == 0
                    ? 'Hasil hitung kas sama dengan Saldo buku.'
                    : '${selisih > 0 ? 'Uang di kas kurang dari buku. ' : 'Uang di kas lebih dari buku. '}'
                          'Hasil hitung disimpan apa adanya; tidak ada '
                          'tindakan untuk menyamakan angka.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: 'Petugas penghitung ',
                children: [
                  TextSpan(
                    text: '· paling sedikit satu',
                    style: TextStyle(color: c.tinta3),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in hitungKasPetugas)
                  ChipSatu(
                    teks: o,
                    dipilih: _petugas.contains(o),
                    onTap: () => _pilih(o),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Drawn like a control, but the board gives it no handler.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: ShapeDecoration(
            shape: GarisBorder.putus(c.putus, radius: 12),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Lampirkan dokumen pendukung',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.laut),
                ),
                const TextSpan(text: ' · foto lembar hitung kas'),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ),
        const SizedBox(height: 16),
        TekanAria(
          // TombolBersyarat: re-checks the latest input on press.
          onTap: () {
            if (_bisa) setState(() => _tersimpan = true);
          },
          aktif: bisa,
          petunjuk: bisa ? null : pesan,
          radius: 12,
          child: RupaTombol(
            label: 'Simpan hitung kas',
            isi: bisa ? c.laut : c.garis,
            warnaTeks: bisa ? c.diLaut : c.tinta3,
            radius: 12,
            tinggi: 50,
            paddingH: 6,
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          container: true,
          liveRegion: true,
          child: Text(
            pesan,
            style: TextStyle(
              fontSize: 14,
              color: _tersimpan ? c.laut : c.tinta2,
              fontWeight: _tersimpan ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        jabatanKosong: true,
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 3,
          pengguna: PenggunaKeuangan(),
        ),
        isi: [
          Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                text: 'Rekonsiliasi ',
                children: [
                  TextSpan(
                    text: '· November 2026',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.tinta3,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Semantics(
                // aria-current="page"
                selected: true,
                child: const ChipSatu(
                  teks: 'Kas · hitung kas',
                  dipilih: true,
                  onTap: null,
                  padding: 16,
                ),
              ),
              chipBank('Bank BNI ··4821'),
              chipBank('Bank SulutGo ··1107'),
            ],
          ),
          BarisLentur(
            anak: [
              Lentur(dasar: 420, tumbuh: 999, child: kiri),
              Lentur(dasar: 340, child: aside),
            ],
          ),
        ],
      ),
    );
  }
}

/// One denomination row: the label tied to its count field, the field
/// (radius 10, mono 15, right-aligned, placeholder "—") and the product.
class _BarisPecahan extends StatefulWidget {
  const _BarisPecahan({
    required this.pecahan,
    required this.controller,
    required this.onChanged,
    required this.grid,
  });

  final int pecahan;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Widget Function(Widget, Widget, Widget) grid;

  @override
  State<_BarisPecahan> createState() => _BarisPecahanState();
}

class _BarisPecahanState extends State<_BarisPecahan> {
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(_ubah);
  }

  void _ubah() => setState(() {});

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final d = widget.controller.text;
    final label = rp(widget.pecahan);
    final gaya = DefaultTextStyle.of(context).style
        .merge(_mono.copyWith(fontSize: 15));
    return widget.grid(
      GestureDetector(
        onTap: _fokus.requestFocus,
        child: ExcludeSemantics(
          child: Text(
            label,
            style: _mono.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      Semantics(
        label: label,
        child: CincinFokus(
          tampil: _fokus.hasFocus,
          radius: 10,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerRight,
            decoration: ShapeDecoration(
              color: c.permukaan,
              shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 10),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _fokus,
              onChanged: widget.onChanged,
              inputFormatters: [_FormatLembar()],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: gaya,
              cursorColor: c.laut,
              decoration: InputDecoration.collapsed(
                hintText: kosong,
                hintStyle: gaya.copyWith(color: c.tinta3),
              ),
            ),
          ),
        ),
      ),
      Text(
        d.isEmpty ? kosong : rp(int.parse(d) * widget.pecahan),
        textAlign: TextAlign.right,
        style: _mono.copyWith(color: d.isEmpty ? c.tinta3 : c.tinta),
      ),
    );
  }
}
