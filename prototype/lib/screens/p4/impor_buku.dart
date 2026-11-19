import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';

const _o = ['Ditampung', 'Lolos pengecekan', 'Sudah diimpor'];

/// The book rows: name, book text, read as, note, flag (1 duplicate, 2 not
/// imported).
const _baris = [
  (
    'Ferry Wenas',
    'WENAS FERRY, lhr 3-8-71, Kol 7',
    'Ferry Wenas · 03/08/1971 · Kolom 7',
    '',
    0,
  ),
  (
    'Agustina Lasut',
    'LASUT AGUSTINA (istri), 12-12-74',
    'Agustina Lasut · 12/12/1974 · Kolom 7',
    '',
    0,
  ),
  (
    'Novita Wenas',
    'WENAS NOVITA, 14-3-96',
    'Novita Wenas · 14/03/1996 · Kolom 7',
    'Kemungkinan data ganda: sudah ada Novita Wenas, Aktif',
    1,
  ),
  (
    '—',
    'RUMAGIT H., tgl lhr tdk terbaca',
    'Tanggal lahir tidak terbaca',
    'Tidak diimpor: tanggal lahir wajib. Dicatat dengan alasannya.',
    2,
  ),
];

/// 73 · Impor buku anggota (spec 19-alursurat.md): three states, `k ?? keadaan`.
class ImporBukuScreen extends StatefulWidget {
  const ImporBukuScreen({super.key});

  @override
  State<ImporBukuScreen> createState() => _ImporBukuScreenState();
}

class _ImporBukuScreenState extends State<ImporBukuScreen> {
  String? _k;
  String? _tweakLama;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tweak = context.tweak<String>('ImporBuku', 'keadaan');
    if (tweak != _tweakLama) {
      _tweakLama = tweak;
      _k = null;
    }
    final v = _k ?? tweak;
    final ki = _o.indexOf(v).clamp(0, 2);
    final st = const [
      ('Ditampung', BentukLencana.draf),
      ('Lolos pengecekan', BentukLencana.lautGaris),
      ('Sudah diimpor', BentukLencana.tinta),
    ][ki];
    final catatan = TextStyle(fontSize: 13, color: c.tinta3);
    final isi = <Widget>[
      const BarisInfo('Sumber', 'Buku anggota Kolom 7 · 2019–2026'),
      BarisInfo(
        'Baris',
        ki == 2
            ? '28 baris · 26 sudah diimpor · 1 kemungkinan ganda · 1 tidak '
                  'diimpor'
            : '28 baris · belum ada yang diimpor',
      ),
      for (final r in _baris)
        _KartuBaris(
          nama: r.$1,
          asal: r.$2,
          baca: r.$3,
          ket: ki > 0 || r.$5 == 2 ? r.$4 : '',
          lencana: r.$5 == 2
              ? ('Tidak diimpor', BentukLencana.bata)
              : r.$5 == 1 && ki > 0
              ? ('Kemungkinan data ganda', BentukLencana.bata)
              : st,
          putus: r.$5 != 0,
        ),
      ...switch (ki) {
        0 => [
          BarisTombol(
            anak: [
              Tombol(
                'Jalankan pengecekan',
                jenis: JenisTombol.tinta,
                onPressed: () => setState(() => _k = _o[1]),
              ),
            ],
          ),
          Text('Belum ada yang tersimpan sebagai data jemaat.', style: catatan),
          Text(
            'Tanggal lahir, jenis kelamin dan status pernikahan dibaca dari '
            'buku. Yang kosong dilengkapi keluarga saat mengonfirmasi; sampai '
            'itu Kategori BIPRA orangnya belum dihitung.',
            style: catatan,
          ),
        ],
        1 => [
          Text(
            'Kemungkinan data ganda ditandai, tidak pernah digabung sendiri.',
            style: catatan,
          ),
          // Not BarisTombol's 171 + 171: Chrome keeps the link at least as
          // wide as "Tinjau kemungkinan", so the board draws 154 + 188.
          // ponytail: fixed ratio for the 350 phone column only.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 154,
                  child: Tombol(
                    'Impor 26 baris',
                    jenis: JenisTombol.tinta,
                    onPressed: () => setState(() => _k = _o[2]),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  flex: 188,
                  child: Tombol(
                    'Tinjau kemungkinan data ganda',
                    onPressed: null,
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                    ke: 'DataGanda',
                  ),
                ),
              ],
            ),
          ),
        ],
        _ => [
          Kartu(
            status: GarisStatus.draf,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: '26 orang masuk sebagai Belum dikonfirmasi.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text:
                        'Hanya Penatua Kolom 7 dan Operator yang dapat '
                        'melihatnya. Tidak ada yang tampil di publikasi sampai '
                        'keluarganya mengonfirmasi dan memberi izin.',
                    style: TextStyle(color: c.tinta2),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const BarisTombol(
            anak: [
              Tombol(
                'Lihat konfirmasi keluarga',
                onPressed: null,
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                ke: 'KonfirmasiKeluarga',
              ),
            ],
          ),
        ],
      },
    ];
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Impor buku anggota',
            anakJudul:
                'Operator memasukkan buku anggota kertas; belum ada yang '
                'menjadi anggota aktif',
            kembaliKe: 'DataAnggota',
            labelKembali: 'Kembali ke Data jemaat',
          ),
          Expanded(
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
}

/// Import row card: radius 14, padding 12 16, gap 4; solid or dashed.
class _KartuBaris extends StatelessWidget {
  const _KartuBaris({
    required this.nama,
    required this.asal,
    required this.baca,
    required this.ket,
    required this.lencana,
    required this.putus,
  });

  final String nama, asal, baca, ket;
  final (String, BentukLencana) lencana;
  final bool putus;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    return Kartu(
      status: putus ? GarisStatus.draf : GarisStatus.dibukukan,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KepalaKartu, with the badge capped to the row: the test font
          // (Ahem) makes "Kemungkinan data ganda" wider than the card.
          LayoutBuilder(
            builder: (context, b) => Row(
              children: [
                Expanded(
                  child: Text(
                    nama,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: b.maxWidth - 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LencanaStatus(lencana.$1, bentuk: lencana.$2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Di buku: '),
                TextSpan(
                  text: asal,
                  style: const TextStyle(fontFamily: PalakatText.mono),
                ),
              ],
            ),
            style: kecil,
          ),
          const SizedBox(height: 4),
          Text('Dibaca sebagai: $baca', style: const TextStyle(fontSize: 14)),
          // An empty note still takes its 4 gap, as the board's empty div.
          const SizedBox(height: 4),
          if (ket.isNotEmpty) Text(ket, style: kecil),
        ],
      ),
    );
  }
}
