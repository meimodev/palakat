import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mock/mock.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

const _o = [
  'Daftar jabatan',
  'Catat penugasan',
  'Menugaskan diri sendiri',
  'Menunggu verifikasi wewenang',
];

/// 48 · Penugasan jabatan (docs/build/screens/14-berandajabatan.md). State
/// `{ k: null }`; view = `k ?? keadaan`. The list never changes.
class PenugasanScreen extends StatefulWidget {
  const PenugasanScreen({super.key});

  @override
  State<PenugasanScreen> createState() => _PenugasanScreenState();
}

class _PenugasanScreenState extends State<PenugasanScreen> {
  String? _k, _t;

  void _ke(int i) => setState(() => _k = _o[i]);

  @override
  Widget build(BuildContext context) {
    final t = context.tweak<String>('Penugasan', 'keadaan');
    if (t != _t) {
      // A panel change resets the in-board view.
      _t = t;
      _k = null;
    }
    final ki = math.max(0, _o.indexOf(_k ?? t));
    final isi = switch (ki) {
      1 => _catat(),
      2 => _diriSendiri(),
      3 => _verifikasi(context),
      _ => _daftar(),
    };
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Penugasan jabatan',
            anakJudul: 'Siapa memegang jabatan apa, di unit mana, sejak kapan',
            kembaliKe: 'BerandaJabatan',
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            // Keyed by view: every view change starts at the top.
            child: SingleChildScrollView(
              key: ValueKey(ki),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in isi.indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    w,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _daftar() => [
    KisiOtomatis(
      minLebar: 300,
      jarak: 16,
      anak: [for (final p in penugasan) _KartuJabatan(p)],
    ),
    _BarisTombol([
      Tombol(
        'Catat penugasan',
        onPressed: () => _ke(1),
        jenis: JenisTombol.tinta,
      ),
    ]),
  ];

  List<Widget> _catat() => [
    const _KartuIsian([
      _Isian('Orang', 'Sym. Greis Mamahit'),
      _Isian('Jabatan', 'Syamas'),
      _Isian('Unit', 'Kolom 3'),
      // Date grid (min 300, gap 16): one column at phone width.
      _KisiTanggal(),
      _Isian(
        'Keputusan gereja',
        'SK BPMJ No. 14/2026 · Dokumen gereja',
        petunjuk: 'Dilampirkan dari Dokumen gereja',
      ),
    ]),
    const _Keterangan(
      'Dicatat oleh Pdt. Lidya Rondonuwu, Pimpinan Jemaat yang berwenang. Penugasan bukan persetujuan di aplikasi; keputusannya ada di dokumen.',
    ),
    _BarisTombol([
      Tombol(
        'Catat penugasan',
        onPressed: () => _ke(0),
        jenis: JenisTombol.tinta,
      ),
      Tombol('Batalkan', onPressed: () => _ke(0), jenis: JenisTombol.teks),
    ]),
  ];

  List<Widget> _diriSendiri() => [
    const _KartuIsian([
      _Isian('Orang', 'Pdt. Lidya Rondonuwu'),
      _Isian('Jabatan', 'Ketua Komisi'),
      _Isian('Unit', 'Komisi Diakonia'),
    ]),
    const Penolakan(
      tindakan: 'Catat penugasan',
      sebab: 'Anda tidak dapat menugaskan jabatan kepada diri sendiri.',
      jalan: [],
    ),
    const _Keterangan(
      'Penugasan Pimpinan Jemaat yang berwenang dicatat oleh Tim pengembang saat pengaturan awal.',
    ),
    _BarisTombol([
      Tombol(
        'Pilih orang lain',
        onPressed: () => _ke(1),
        jenis: JenisTombol.kedua,
        ukuran: UkuranTombol.sedang,
      ),
      Tombol('Batalkan', onPressed: () => _ke(0), jenis: JenisTombol.teks),
    ]),
  ];

  List<Widget> _verifikasi(BuildContext context) {
    final c = context.warna;
    Widget kartu(String judul, Widget lencana, String sub, String ket) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _JudulLencana(judul, lencana),
          const SizedBox(height: 6),
          Text(sub, style: TextStyle(fontSize: 14, color: c.tinta2)),
          const SizedBox(height: 6),
          _Keterangan(ket),
        ],
      ),
    );
    return [
      kartu(
        'Sekretaris Jemaat',
        _LencanaPutus(penugasanSekretarisMenunggu.status.label),
        penugasanSekretarisMenunggu.keterangan,
        'Penunjukan Bendahara Jemaat dan Sekretaris Jemaat diperiksa Petugas verifikasi terhadap keputusan tertulis gereja sebelum wewenangnya aktif. Akses teknis saja tidak memberi wewenang.',
      ),
      kartu(
        'Operator',
        const LencanaStatus('Aktif', bentuk: BentukLencana.laut),
        'Yanti Sumual · sejak 01/11/2026',
        'Penugasan Operator tidak melewati Petugas verifikasi.',
      ),
    ];
  }
}

/// Post card: vacant posts have a dashed `putus` line and no field.
class _KartuJabatan extends StatelessWidget {
  const _KartuJabatan(this.p);
  final Penugasan p;

  @override
  Widget build(BuildContext context) {
    final kosong = p.status == StatusPenugasan.jabatanKosong;
    final nama = p.orangId == null
        ? '—'
        : semuaOrang.firstWhere((o) => o.id == p.orangId).nama;
    return Kartu(
      status: kosong ? GarisStatus.draf : GarisStatus.dibukukan,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _JudulLencana(
            p.jabatan,
            LencanaStatus(p.status.label, bentuk: p.status.gaya.bentuk),
          ),
          const SizedBox(height: 2),
          Text(nama, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          _Keterangan(p.keterangan),
        ],
      ),
    );
  }
}

/// Form card: padding 14/16, column gap 12.
class _KartuIsian extends StatelessWidget {
  const _KartuIsian(this.anak);
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, w) in anak.indexed) ...[
          if (i > 0) const SizedBox(height: 12),
          w,
        ],
      ],
    ),
  );
}

class _KisiTanggal extends StatelessWidget {
  const _KisiTanggal();

  @override
  Widget build(BuildContext context) => const KisiOtomatis(
    minLebar: 300,
    jarak: 16,
    anak: [
      _Isian('Mulai', '18/11/2026'),
      _Isian('Berakhir', '—', petunjuk: 'Kosong: sampai dicatat berakhir'),
    ],
  );
}

/// Read-only field: label 14 `tinta2`, gap 6, the 48 field (value inherits
/// 14 `tinta2`), then an optional hint 13 `tinta3`.
class _Isian extends StatelessWidget {
  const _Isian(this.label, this.nilai, {this.petunjuk});
  final String label, nilai;
  final String? petunjuk;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return DefaultTextStyle.merge(
      style: TextStyle(fontSize: 14, color: c.tinta2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IsianTeks(
            label: label,
            jarakLabel: 6,
            hanyaBaca: true,
            nilaiAwal: nilai,
            // TextField starts from the Material bodyLarge (letterSpacing
            // 0.5); the board's inputs have none.
            gaya: const TextStyle(letterSpacing: 0),
          ),
          if (petunjuk != null) ...[
            const SizedBox(height: 6),
            _Keterangan(petunjuk!),
          ],
        ],
      ),
    );
  }
}

/// Row space-between, gap 16, centred: 700 title, badge (flex none). The
/// title wraps first; the badge never takes more than the title's longest
/// word leaves (at least 60 %), so a long badge wraps instead of overflowing.
class _JudulLencana extends StatelessWidget {
  const _JudulLencana(this.judul, this.lencana);
  final String judul;
  final Widget lencana;

  @override
  Widget build(BuildContext context) {
    final gaya = DefaultTextStyle.of(context).style
        .copyWith(fontWeight: FontWeight.w700);
    final skala = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, b) {
        final p = TextPainter(
          text: TextSpan(text: judul, style: gaya),
          textDirection: TextDirection.ltr,
          textScaler: skala,
        )..layout();
        final minJudul = p.minIntrinsicWidth.ceilToDouble();
        p.dispose();
        final maks = math.max(b.maxWidth * .6, b.maxWidth - 16 - minJudul);
        return Row(
          children: [
            Expanded(child: Text(judul, style: gaya)),
            const SizedBox(width: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maks),
              child: lencana,
            ),
          ],
        );
      },
    );
  }
}

/// The `draf` badge (LencanaStatus shape) whose text may wrap: LencanaStatus
/// itself never wraps.
class _LencanaPutus extends StatelessWidget {
  const _LencanaPutus(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: ShapeDecoration(shape: GarisBorder.putus(c.putus, radius: 6)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: c.tinta2,
        ),
      ),
    );
  }
}

class _Keterangan extends StatelessWidget {
  const _Keterangan(this.teks);
  final String teks;

  @override
  Widget build(BuildContext context) =>
      Text(teks, style: TextStyle(fontSize: 13, color: context.warna.tinta3));
}

/// The board's button row: wrap, gap 8, each `flex: 1 1 150px; max-width: 340px`.
class _BarisTombol extends StatelessWidget {
  const _BarisTombol(this.anak);
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => BarisLentur(
    jarak: 8,
    rata: CrossAxisAlignment.center,
    anak: [for (final w in anak) Lentur(dasar: 150, maks: 340, child: w)],
  );
}
