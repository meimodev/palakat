import 'package:flutter/material.dart';

import '../../mock/mock.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

const _stem = 'WebPenugasan';

/// The `keadaan` options, in board order (`O`).
const _o = [
  'Daftar jabatan',
  'Catat penugasan',
  'Menugaskan diri sendiri',
  'Menunggu verifikasi wewenang',
];

/// Web · Penugasan jabatan (screens/14, WebPenugasan). State `{ k: null }`;
/// the view is `k ?? keadaan`.
class WebPenugasanScreen extends StatefulWidget {
  const WebPenugasanScreen({super.key});

  @override
  State<WebPenugasanScreen> createState() => _WebPenugasanScreenState();
}

class _WebPenugasanScreenState extends State<WebPenugasanScreen> {
  final _isiKunci = GlobalKey();
  String? _k;
  String? _tweak;

  void _keAtas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = _isiKunci.currentContext;
    if (ctx != null) Scrollable.maybeOf(ctx)?.position.jumpTo(0);
  });

  /// The board's `go<i>`.
  void _ke(int i) => setState(() {
    _k = _o[i];
    _keAtas();
  });

  /// Self link (the active "Pengaturan" side-nav item): as
  /// reloading the board, `k` back to null and scroll to top.
  void _ulang() => setState(() {
    _k = null;
    _keAtas();
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tweak = context.tweak<String>(_stem, 'keadaan');
    if (tweak != _tweak) {
      if (_tweak != null) {
        _k = null;
        _keAtas();
      }
      _tweak = tweak;
    }
    final ki = (_o.indexOf(_k ?? tweak)).clamp(0, _o.length - 1);

    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    Widget tombol(List<Widget> anak) => BarisLentur(
      jarak: 8,
      anak: [for (final a in anak) Lentur(dasar: 150, maks: 340, child: a)],
    );
    Widget barisJudul(String judul, Widget lencana) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            judul,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 16),
        lencana,
      ],
    );
    Widget kolom(List<Widget> anak, double jarak) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) SizedBox(height: jarak),
          anak[i],
        ],
      ],
    );
    Widget isian(String label, String nilai, [String? petunjuk]) {
      final f = IsianTeks(
        key: ValueKey('$ki $label'),
        label: label,
        nilaiAwal: nilai,
        hanyaBaca: true,
        jarakLabel: 6,
        // letterSpacing 0: TextField otherwise keeps M3 bodyLarge's 0.5.
        gaya: TextStyle(fontSize: 14, color: c.tinta2, letterSpacing: 0),
      );
      if (petunjuk == null) return f;
      return kolom([f, Text(petunjuk, style: kecil)], 6);
    }

    Widget formulir(List<Widget> anak) => Kartu(child: kolom(anak, 12));
    // The board's flex row stretches the text button to its neighbour's
    // height, so its label centres on the same line.
    Widget batalkan(double tinggi) => ConstrainedBox(
      constraints: BoxConstraints(minHeight: tinggi),
      child: Tombol(
        'Batalkan',
        onPressed: () => _ke(0),
        jenis: JenisTombol.teks,
      ),
    );

    final List<Widget> isi = switch (ki) {
      0 => [
        KisiOtomatis(
          minLebar: 300,
          jarak: 16,
          anak: [
            for (final p in penugasan)
              Kartu(
                status: p.orangId == null
                    ? GarisStatus.draf
                    : GarisStatus.dibukukan,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: kolom([
                  barisJudul(
                    p.jabatan,
                    LencanaStatus(p.status.label, bentuk: p.status.gaya.bentuk),
                  ),
                  Text(
                    p.orangId == null
                        ? '—'
                        : semuaOrang.firstWhere((o) => o.id == p.orangId).nama,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(p.keterangan, style: kecil),
                ], 2),
              ),
          ],
        ),
        tombol([
          Tombol(
            'Catat penugasan',
            onPressed: () => _ke(1),
            jenis: JenisTombol.tinta,
          ),
        ]),
      ],
      1 => [
        BarisLentur(
          jarak: 28,
          jarakBaris: 20,
          anak: [
            Lentur(
              dasar: 420,
              tumbuh: 1.3,
              child: formulir([
                isian('Orang', 'Sym. Greis Mamahit'),
                isian('Jabatan', 'Syamas'),
                isian('Unit', 'Kolom 3'),
                KisiOtomatis(
                  minLebar: 300,
                  jarak: 16,
                  anak: [
                    isian('Mulai', '18/11/2026'),
                    isian('Berakhir', '—', 'Kosong: sampai dicatat berakhir'),
                  ],
                ),
                isian(
                  'Keputusan gereja',
                  'SK BPMJ No. 14/2026 · Dokumen gereja',
                  'Dilampirkan dari Dokumen gereja',
                ),
              ]),
            ),
            Lentur(
              dasar: 340,
              child: kolom([
                Text(
                  'Dicatat oleh Pdt. Lidya Rondonuwu, Pimpinan Jemaat yang '
                  'berwenang. Penugasan bukan persetujuan di aplikasi; '
                  'keputusannya ada di dokumen.',
                  style: kecil,
                ),
                tombol([
                  Tombol(
                    'Catat penugasan',
                    onPressed: () => _ke(0),
                    jenis: JenisTombol.tinta,
                  ),
                  batalkan(52),
                ]),
              ], 12),
            ),
          ],
        ),
      ],
      2 => [
        formulir([
          isian('Orang', 'Pdt. Lidya Rondonuwu'),
          isian('Jabatan', 'Ketua Komisi'),
          isian('Unit', 'Komisi Diakonia'),
        ]),
        const Penolakan(
          tindakan: 'Catat penugasan',
          sebab: 'Anda tidak dapat menugaskan jabatan kepada diri sendiri.',
          jalan: [],
        ),
        Text(
          'Penugasan Pimpinan Jemaat yang berwenang dicatat oleh Tim '
          'pengembang saat pengaturan awal.',
          style: kecil,
        ),
        tombol([
          Tombol(
            'Pilih orang lain',
            onPressed: () => _ke(1),
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
          ),
          batalkan(48),
        ]),
      ],
      _ => [
        Kartu(
          child: kolom([
            barisJudul(
              'Sekretaris Jemaat',
              const LencanaStatus(
                'Menunggu verifikasi wewenang',
                bentuk: BentukLencana.draf,
              ),
            ),
            Text(
              'Olvie Pangemanan · dicatat 03/11/2026',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Text(
              'Penunjukan Bendahara Jemaat dan Sekretaris Jemaat diperiksa '
              'Petugas verifikasi terhadap keputusan tertulis gereja sebelum '
              'wewenangnya aktif. Akses teknis saja tidak memberi wewenang.',
              style: kecil,
            ),
          ], 6),
        ),
        Kartu(
          child: kolom([
            barisJudul(
              'Operator',
              const LencanaStatus('Aktif', bentuk: BentukLencana.laut),
            ),
            Text(
              'Yanti Sumual · sejak 01/11/2026',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Text(
              'Penugasan Operator tidak melewati Petugas verifikasi.',
              style: kecil,
            ),
          ], 6),
        ),
      ],
    };

    // The breadcrumb keeps its 44 px target without growing the title block
    // (the inline 14 px link sits on the div's 15 × 1.45 strut).
    const lebihTautan = (44 - 15 * 1.45) / 2;
    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarginNegatif(
          atas: lebihTautan,
          bawah: lebihTautan,
          child: Tautan(
            ke: 'WebBerandaJabatan',
            cara: Cara.naik,
            child: const Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: TautanTeks('Beranda', ukuran: 14),
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Penugasan jabatan',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        Text(
          'Siapa memegang jabatan apa, di unit mana, sejak kapan',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: NavSamping(
          item: navPlatform,
          aktif: 9,
          diSini: _ulang,
          pengguna: const PenggunaNav(
            tebal: 'Pdt. Lidya Rondonuwu',
            biasa: ' · Ketua Jemaat',
            baris2: 'Pimpinan Jemaat yang berwenang',
          ),
        ),
        isi: [
          judul,
          Align(
            key: _isiKunci,
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: kolom(isi, 16),
            ),
          ),
        ],
      ),
    );
  }
}
