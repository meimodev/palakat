import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../motion/kerangka.dart';
import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/logo.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// Content shared by Masuk and WebMasuk (identical logic class and markup):
/// the logo row, then step email → kode → hasil. Each screen passes its own
/// link widgets, because the targets differ (Pemulihan / WebPemulihan …).
class LangkahMasuk extends StatefulWidget {
  const LangkahMasuk({
    super.key,
    required this.stem,
    required this.jarak,
    required this.pemulihan,
    required this.hubungkan,
    required this.awal,
    required this.beranda,
    required this.terbatas,
  });

  /// Board whose `setelahMasuk` tweak picks the outcome.
  final String stem;

  /// Gap under the logo row: 36 on the phone, 32 in the web card.
  final double jarak;

  /// Links: `Tautan(ke: …, child: TautanMasuk(…))` and `Tombol(ke: …)`.
  final Widget pemulihan, hubungkan, awal, beranda, terbatas;

  @override
  State<LangkahMasuk> createState() => _LangkahMasukState();
}

const teksPemulihan = 'Tidak bisa menerima kode? Pemulihan akun';
const teksHubungkan = 'Belum terhubung dengan Data jemaat? Hubungkan akun';
const teksAwal = 'Lihat langkah pengaturan awal';

final _nomor = RegExp(r'^08\d{8,11}$');

class _LangkahMasukState extends State<LangkahMasuk> {
  String _tahap = 'email';
  final _email = TextEditingController();
  final _kode = TextEditingController();

  bool get _okE => _nomor.hasMatch(_email.text);
  bool get _okK => _kode.text.length == 6;

  @override
  void dispose() {
    _email.dispose();
    _kode.dispose();
    super.dispose();
  }

  void _kirim() => setState(() => _tahap = 'kode');
  void _masuk() => setState(() => _tahap = 'hasil');
  void _ulang() => setState(() {
    _tahap = 'email';
    _kode.clear();
  });

  @override
  Widget build(BuildContext context) {
    final tinggi = DefaultTextStyle.of(context).style.height;
    // CSS line-height splits the leading evenly above and below the glyphs.
    return DefaultTextStyle.merge(
      style: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
      child: _isi(context, tinggi),
    );
  }

  Widget _isi(BuildContext context, double? tinggi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const TandaPalakat(ukuran: 40),
            const SizedBox(width: 12),
            KataPalakat(
              ukuran: 30,
              jarakHuruf: -.5,
              tinggiBaris: tinggi ?? 1.4,
            ),
          ],
        ),
        SizedBox(height: widget.jarak),
        switch (_tahap) {
          'email' => _langkahEmail(context),
          'kode' => Gerak(
            Kerangka.muncul,
            lama: const Duration(milliseconds: 300),
            child: _langkahKode(context),
          ),
          _ => _hasil(context),
        },
      ],
    );
  }

  Widget _kolom(List<Widget> anak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) const SizedBox(height: 14),
        anak[i],
      ],
    ],
  );

  Widget _judul(
    BuildContext context,
    String h1,
    Widget bawah, {
    double jarak = 4,
    double? tinggi,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        child: Text(
          h1,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: tinggi,
          ),
        ),
      ),
      SizedBox(height: jarak),
      bawah,
    ],
  );

  /// Rule A02: the sentence the board lacks, once [isian] is typed into.
  Widget _tombol(
    String label,
    bool Function() siap,
    String nama,
    TextEditingController isian,
    VoidCallback aksi,
  ) {
    String alasan() => siap() ? '' : '$nama belum diisi.';
    return TombolBersyarat(
      label: label,
      tindakan: label,
      alasan: alasan(),
      periksa: alasan,
      onPressed: aksi,
      sudahMulai: isian.text.isNotEmpty,
      warnaSiap: JenisTombol.utama,
      teksBelumRedup: true,
    );
  }

  Widget _langkahEmail(BuildContext context) {
    final c = context.warna;
    return _kolom([
      _judul(
        context,
        'Masuk',
        Text(
          'Satu akun untuk semua jabatan Anda di Jemaat.',
          style: TextStyle(fontSize: 15, color: c.tinta2),
        ),
      ),
      IsianTeks(
        controller: _email,
        label: 'Nomor ponsel',
        jarakLabel: 6,
        petunjuk: '08…',
        keyboardType: TextInputType.phone,
        formatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(13),
        ],
        onChanged: (_) => setState(() {}),
      ),
      _tombol('Kirim kode masuk', () => _okE, 'Nomor ponsel', _email, _kirim),
      Text(
        'Kode enam angka dikirim ke nomor ponsel Anda lewat WhatsApp atau SMS. Tidak ada kata sandi yang perlu diingat.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      widget.pemulihan,
      widget.hubungkan,
    ]);
  }

  Widget _langkahKode(BuildContext context) {
    final c = context.warna;
    return _kolom([
      _judul(
        context,
        'Masukkan kode',
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Dikirim ke '),
              TextSpan(
                text: _email.text,
                style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
              ),
            ],
          ),
          style: TextStyle(fontSize: 15, color: c.tinta2),
        ),
      ),
      _IsianKode(controller: _kode, onChanged: () => setState(() {})),
      _tombol('Masuk', () => _okK, 'Kode enam angka', _kode, _masuk),
      Tombol('Pakai nomor lain', onPressed: _ulang, jenis: JenisTombol.teks),
    ]);
  }

  Widget _hasil(BuildContext context) {
    final k = context.tweak<String>(widget.stem, 'setelahMasuk');
    final isi = switch (k) {
      'Bendahara' => _kolom([
        _judul(
          context,
          'Jemaat Karunia',
          const Text(
            'Meiske Lumentut · Wewenang Bendahara aktif',
            style: TextStyle(fontSize: 15),
          ),
          jarak: 6,
        ),
        widget.beranda,
      ]),
      'Akses terbatas' => _kolom([
        _judul(
          context,
          'Jemaat Karunia',
          const Text(
            'Dkn. Olga Tamba · Akses terbatas: Peruntukan Diakonia',
            style: TextStyle(fontSize: 15),
          ),
          jarak: 6,
        ),
        widget.terbatas,
      ]),
      'Administrator sistem' => _kolom([
        _judul(
          context,
          'Anda masuk sebagai administrator sistem',
          const Text(
            'Tidak ada tindakan keuangan yang tersedia.',
            style: TextStyle(fontSize: 15),
          ),
          jarak: 6,
          tinggi: 1.2,
        ),
        const _KartuAlasan(
          'administrator sistem mengurus sisi teknis, dan tidak dapat bertindak sebagai Bendahara atau pemberi persetujuan. Akses teknis saja tidak pernah memberi wewenang Bendahara.',
          'Yang memegang pembukuan:',
          'Bendahara Jemaat Karunia, lewat penunjukan yang sudah diverifikasi.',
        ),
      ]),
      _ => _kolom([
        Align(
          alignment: Alignment.centerLeft,
          child: SvgPicture.string(
            _cincin,
            width: 72,
            height: 72,
            theme: SvgTheme(currentColor: context.warna.tinta),
          ),
        ),
        _judul(
          context,
          'Menunggu verifikasi wewenang',
          const Text(
            'Anda sudah masuk, tetapi belum ada tindakan keuangan yang tersedia.',
            style: TextStyle(fontSize: 15),
          ),
          jarak: 6,
          tinggi: 1.2,
        ),
        const _KartuAlasan(
          'wewenang Bendahara hanya berasal dari keputusan Jemaat yang sudah diverifikasi. Akun saja tidak memberi wewenang.',
          'Yang perlu bertindak:',
          'Petugas verifikasi, setelah BPMJ mengirim surat penunjukan Anda.',
        ),
        // `<a>` is content-box: min-height 48 plus the 1.5 px line twice.
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 51),
          child: widget.awal,
        ),
      ]),
    };
    // Keyed on the outcome: a tweak change mounts it again and replays muncul.
    return Gerak(
      key: ValueKey(k),
      Kerangka.muncul,
      lama: const Duration(milliseconds: 300),
      child: isi,
    );
  }
}

const _cincin =
    '<svg viewBox="0 0 88 88"><circle cx="44" cy="44" r="38" fill="none" '
    'stroke="currentColor" stroke-width="4" stroke-dasharray="6 7"/></svg>';

/// "**Mengapa:** …" card: `permukaan`, 1 px `garis`, radius 14, padding 14 16, gap 6, 14 px.
class _KartuAlasan extends StatelessWidget {
  const _KartuAlasan(this.mengapa, this.kepala2, this.baris2);
  final String mengapa, kepala2, baris2;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    Widget baris(String kepala, String isi) => Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: kepala,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' $isi'),
        ],
      ),
      style: const TextStyle(fontSize: 14),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          baris('Mengapa:', mengapa),
          const SizedBox(height: 6),
          baris(kepala2, baris2),
        ],
      ),
    );
  }
}

/// Text link 14/700 `laut` (underlined, as the board's bare `<a>`), min height 44, left.
class TautanMasuk extends StatelessWidget {
  const TautanMasuk(this.teks, {super.key});
  final String teks;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 44),
    alignment: Alignment.centerLeft,
    child: TautanTeks(teks, berat: FontWeight.w700, ukuran: 14),
  );
}

/// The code field: as [IsianTeks] but min height 60, mono 26, letter spacing
/// 8, centred, digits only, at most 6.
class _IsianKode extends StatefulWidget {
  const _IsianKode({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final VoidCallback onChanged;

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
    final teks = DefaultTextStyle.of(context).style.merge(
      const TextStyle(
        fontFamily: PalakatText.mono,
        fontSize: 26,
        letterSpacing: 8,
      ),
    );
    final kotak = CincinFokus(
      tampil: _fokus.hasFocus,
      radius: 12,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.permukaan,
          border: Border.all(color: c.garisTegas),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: TextField(
            controller: widget.controller,
            focusNode: _fokus,
            onChanged: (_) => widget.onChanged(),
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textAlign: TextAlign.center,
            style: teks,
            cursorColor: c.laut,
            decoration: const InputDecoration.collapsed(hintText: null),
          ),
        ),
      ),
    );
    // `<label for="ik">`: tapping the label focuses the field.
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: _fokus.requestFocus,
            child: Text(
              'Kode enam angka',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
          const SizedBox(height: 6),
          kotak,
        ],
      ),
    );
  }
}
