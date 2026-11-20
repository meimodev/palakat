import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mock/mock.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

const _o = [
  'Daftar modul',
  'Mengaktifkan Data jemaat',
  'Menonaktifkan Warta Jemaat',
  'Dilihat jabatan lain',
];

/// 47 · Modul (docs/build/screens/14-berandajabatan.md). State `{ k: null }`;
/// view = `k ?? keadaan`. Nothing in the list changes after a confirmation.
class ModulScreen extends StatefulWidget {
  const ModulScreen({super.key});

  @override
  State<ModulScreen> createState() => _ModulScreenState();
}

class _ModulScreenState extends State<ModulScreen> {
  String? _k, _t;

  void _ke(int i) => setState(() => _k = _o[i]);

  @override
  Widget build(BuildContext context) {
    final t = belumDipindah<String>('Daftar modul');
    if (t != _t) {
      // A panel change resets the in-board view.
      _t = t;
      _k = null;
    }
    final ki = math.max(0, _o.indexOf(_k ?? t));
    final isi = switch (ki) {
      1 => _aktifkan(context),
      2 => _nonaktifkan(context),
      3 => _dilihat(context),
      _ => _daftar(),
    };
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Modul',
            anakJudul: 'Pimpinan Jemaat yang berwenang mengaktifkan modul saat orangnya siap',
            kembaliKe: Layar.beranda,
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
    const _KisiModul(),
    _BarisTombol([
      Tombol(
        'Aktifkan modul',
        onPressed: () => _ke(1),
        jenis: JenisTombol.kedua,
        ukuran: UkuranTombol.sedang,
      ),
      Tombol(
        'Nonaktifkan modul',
        onPressed: () => _ke(2),
        jenis: JenisTombol.kedua,
        ukuran: UkuranTombol.sedang,
      ),
    ]),
    const _Keterangan(
      'Modul yang tidak aktif tidak tampil di navigasi, pencarian, pemberitahuan atau keadaan kosong mana pun.',
    ),
    const _TautanBaris(
      'Tabel pemberi persetujuan',
      ke: Layar.pemberiPersetujuan,
    ),
    const _TautanBaris('Kas/Bank yang dikelola unit', ke: Layar.kasUnit),
  ];

  List<Widget> _aktifkan(BuildContext context) {
    final c = context.warna;
    return [
      _KartuKonfirmasi(
        anak: [
          const _JudulLencana(
            'Aktifkan modul: Data jemaat',
            LencanaStatus('Tidak aktif', bentuk: BentukLencana.draf),
          ),
          Text(
            'Yang harus ada lebih dulu:',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          const KunciNilai(
            'Aturan Kategori BIPRA',
            'Ketentuan GMIM · tidak dapat diubah gereja',
          ),
          const KunciNilai(
            'Naskah Izin penggunaan data pribadi',
            modulNaskahIzin,
          ),
          const KunciNilai(
            'Penatua Kolom untuk setiap Kolom',
            '11 dari 12 terisi',
          ),
          const _Keterangan(
            'Kolom 2 belum punya Penatua. Operator dapat menjalankan jabatan kosong itu.',
          ),
        ],
      ),
      _KartuKonfirmasi(
        anak: [
          const Text(
            'Kategori BIPRA',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          for (final (k, n) in _bipra) KunciNilai(k, n),
          const _Keterangan(
            'Yang pernah menikah tetap Bapa atau Ibu, termasuk yang ditinggal pasangannya. Yang belum pernah menikah tetap Pemuda, berapa pun umurnya. Yang menikah sebelum 18 tahun menjadi Bapa atau Ibu.',
          ),
          const _Keterangan(
            'Dihitung sendiri dari tanggal lahir, jenis kelamin dan status pernikahan. Bila GMIM mengubah ketentuannya, Palakat memperbaruinya dengan tanggal berlaku.',
          ),
        ],
      ),
      const _Keterangan(
        'Setelah aktif, anggota dan keluarga diminta mengonfirmasi datanya dan memberi izin. Yang Belum dikonfirmasi tidak tampil di publikasi apa pun.',
      ),
      _BarisTombol([
        Tombol(
          'Aktifkan modul',
          onPressed: () => _ke(0),
          jenis: JenisTombol.tinta,
        ),
        Tombol('Kembali', onPressed: () => _ke(0), jenis: JenisTombol.teks),
      ]),
    ];
  }

  List<Widget> _nonaktifkan(BuildContext context) {
    final c = context.warna;
    return [
      _KartuKonfirmasi(
        anak: [
          const _JudulLencana(
            'Nonaktifkan modul: Warta Jemaat',
            LencanaStatus('Aktif', bentuk: BentukLencana.laut),
          ),
          Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'Menonaktifkan tidak menghapus apa pun. Modul menjadi ',
                ),
                TextSpan(
                  text: 'Hanya baca',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ': $modulWartaEdisi tetap dapat dibaca, '
                      'tetapi tidak ada edisi baru.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          // The textarea inherits the label's 14 `tinta2` (`font: inherit`).
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 14, color: c.tinta2),
            child: const IsianTeks(
              label: 'Alasan · wajib',
              jarakLabel: 6,
              baris: 3,
              hanyaBaca: true,
              // TextField starts from the Material bodyLarge (letterSpacing
              // 0.5); the board's textarea has none.
              gaya: TextStyle(letterSpacing: 0),
              nilaiAwal: 'Sekretaris Jemaat sedang berganti; diaktifkan lagi setelah penugasan baru.',
            ),
          ),
        ],
      ),
      _BarisTombol([
        Tombol(
          'Nonaktifkan modul',
          onPressed: () => _ke(0),
          jenis: JenisTombol.tinta,
        ),
        Tombol('Kembali', onPressed: () => _ke(0), jenis: JenisTombol.teks),
      ]),
    ];
  }

  List<Widget> _dilihat(BuildContext context) => [
    const Kartu(
      status: GarisStatus.terpilih,
      radius: 12,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Hanya Pimpinan Jemaat yang berwenang',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: ' yang mengaktifkan atau menonaktifkan modul. Anda dapat melihat daftarnya.',
            ),
          ],
        ),
        style: TextStyle(fontSize: 14),
      ),
    ),
    const _KisiModul(),
  ];
}

const _bipra = [
  ('Anak', 'sampai sebelum 12 tahun'),
  ('Remaja', '12 tahun sampai 17 tahun 364 hari'),
  ('Pemuda', '18 tahun ke atas, belum pernah menikah'),
  ('Bapa · Ibu', 'sudah menikah'),
];

/// Grid of min 300 columns, gap 16, one card per module.
class _KisiModul extends StatelessWidget {
  const _KisiModul();

  @override
  Widget build(BuildContext context) => KisiOtomatis(
    minLebar: 300,
    jarak: 16,
    anak: [
      for (final m in semuaModul)
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _JudulLencana(
                m.nama,
                LencanaStatus(m.status, bentuk: m.gaya.bentuk),
              ),
              const SizedBox(height: 4),
              _Keterangan(m.keterangan),
            ],
          ),
        ),
    ],
  );
}

/// Card padding 14/16, column gap 6.
class _KartuKonfirmasi extends StatelessWidget {
  const _KartuKonfirmasi({required this.anak});
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, w) in anak.indexed) ...[
          if (i > 0) const SizedBox(height: 6),
          w,
        ],
      ],
    ),
  );
}

/// Row space-between, gap 16, centred: 700 title, badge (flex none).
class _JudulLencana extends StatelessWidget {
  const _JudulLencana(this.judul, this.lencana);
  final String judul;
  final Widget lencana;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 16),
      lencana,
    ],
  );
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

/// Underlined text link 14/700, min height 44, full-width target, text left.
class _TautanBaris extends StatelessWidget {
  const _TautanBaris(this.teks, {required this.ke});
  final String teks;
  final Layar ke;

  @override
  Widget build(BuildContext context) => Tautan(
    ke: ke,
    // Full-width child, so hovering anywhere on the row turns it `lautTua`.
    child: Container(
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: double.infinity,
        child: TautanTeks(teks, berat: FontWeight.w700, ukuran: 14),
      ),
    ),
  );
}

/// A key/value row (14; key `tinta2`, value 600 right-aligned): CSS
/// `display: flex; justify-content: space-between; gap: 16px` where both
/// spans shrink by their max-content width and never below their longest word.
class KunciNilai extends StatelessWidget {
  const KunciNilai(this.kunci, this.nilai, {super.key});
  final String kunci, nilai;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style
        .copyWith(fontSize: 14, color: c.tinta);
    final gk = dasar.copyWith(color: c.tinta2);
    final gn = dasar.copyWith(fontWeight: FontWeight.w600);
    final skala = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, b) {
        (double, double) ukur(String s, TextStyle g) {
          final p = TextPainter(
            text: TextSpan(text: s, style: g),
            textDirection: TextDirection.ltr,
            textScaler: skala,
          )..layout();
          final r = (
            p.minIntrinsicWidth.ceilToDouble(),
            p.width.ceilToDouble(),
          );
          p.dispose();
          return r;
        }

        final (minK, k) = ukur(kunci, gk);
        final (minN, n) = ukur(nilai, gn);
        var lk = k, ln = n;
        final lebih = k + n + 16 - b.maxWidth;
        if (lebih > 0) {
          lk = math.max(minK, k - lebih * k / (k + n));
          ln = math.max(minN, k + n - lebih - lk);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: lk,
              child: Text(kunci, style: gk),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: math.min(ln, b.maxWidth - lk - 16),
              child: Text(nilai, style: gn, textAlign: TextAlign.right),
            ),
          ],
        );
      },
    );
  }
}
