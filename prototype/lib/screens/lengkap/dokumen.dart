import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// One transaction of the board's `D` list.
typedef _Baris = ({
  String id,
  String no,
  String ur,
  String rp,
  String bulan,
  bool tutup,
});

const List<_Baris> _daftar = [
  (
    id: 'a',
    no: 'BKU-2026-0147',
    ur: 'Fotokopi warta jemaat',
    rp: '−Rp150.000',
    bulan: 'November 2026 · Belum ditutup',
    tutup: false,
  ),
  (
    id: 'b',
    no: 'BKU-2026-0143',
    ur: 'Sewa sound system',
    rp: '−Rp600.000',
    bulan: 'November 2026 · Belum ditutup',
    tutup: false,
  ),
  (
    id: 'c',
    no: 'BKU-2026-0116',
    ur: 'Pemeliharaan atap gedung',
    rp: '−Rp5.500.000',
    bulan: 'Oktober 2026 · Sudah ditutup',
    tutup: true,
  ),
  (
    id: 'd',
    no: 'BKU-2026-0145',
    ur: 'Konsumsi rapat majelis',
    rp: '−Rp750.000',
    bulan: 'November 2026 · Belum ditutup',
    tutup: false,
  ),
  (
    id: 'e',
    no: 'BKU-2026-0140',
    ur: 'Bensin operasional',
    rp: '−Rp200.000',
    bulan: 'November 2026 · Belum ditutup',
    tutup: false,
  ),
  (
    id: 'f',
    no: 'BKU-2026-0142',
    ur: 'Pindah antar Kas/Bank: Kas ke Bank BNI',
    rp: 'Rp1.000.000',
    bulan: 'November 2026 · Belum ditutup',
    tutup: false,
  ),
];

/// The board's `N`: status → label.
const _label = {
  'kosong': 'Wajib, belum ada',
  'unggah': 'Diunggah, belum diverifikasi',
  'verif': 'Terverifikasi (oleh Meiske L.)',
  'kecuali': 'Dikecualikan',
  'gagal': 'Gagal diunggah',
  'tahan': 'Ditahan (alasan keamanan)',
  'tidak': 'Tidak diperlukan (aturan: Pindah antar Kas/Bank)',
};

typedef _Item = ({String st, List<String> hist});

Map<String, _Item> _awal() => {
  'a': (
    st: 'unggah',
    hist: ['16/11/2026 10.41 · nota-16-11.jpg diunggah oleh Meiske L.'],
  ),
  'b': (st: 'kosong', hist: []),
  'c': (
    st: 'kecuali',
    hist: [
      '22/10/2026 · Dikecualikan · alasan: kuitansi menyusul · oleh Ketua BPMJ',
    ],
  ),
  'd': (
    st: 'gagal',
    hist: ['16/11/2026 11.05 · nota-sewa.jpg gagal diunggah · belum terlampir'],
  ),
  'e': (
    st: 'tahan',
    hist: ['15/11/2026 16.20 · scan-kuitansi.pdf ditahan (alasan keamanan)'],
  ),
  'f': (st: 'tidak', hist: []),
};

bool _beres(String st) => st == 'verif' || st == 'kecuali' || st == 'tidak';

/// The board state shared by `/Dokumen` and `/Dokumen/rinci`.
class _Dokumen extends ChangeNotifier {
  String pilih = 'a';
  String? form;
  Map<String, _Item> it = _awal();
  final alasan = TextEditingController();

  /// The textarea's focus: tapping its label focuses it (board `label for`).
  final fokus = FocusNode();

  void ulang() {
    pilih = 'a';
    form = null;
    it = _awal();
    alasan.clear();
    notifyListeners();
  }

  void pick(String id) {
    pilih = id;
    form = null;
    notifyListeners();
  }

  void tutupRinci() {
    if (form == null) return;
    form = null;
    notifyListeners();
  }

  void bukaForm(String f) {
    form = f;
    alasan.clear();
    notifyListeners();
  }

  void batalForm() {
    form = null;
    notifyListeners();
  }

  /// The board's `set(st, h)` on the chosen row.
  void set(String st, String h) {
    it = {
      ...it,
      pilih: (st: st, hist: [h, ...it[pilih]!.hist]),
    };
    form = null;
    alasan.clear();
    notifyListeners();
  }

  void ubahAlasan() => notifyListeners();

  @override
  void dispose() {
    alasan.dispose();
    fokus.dispose();
    super.dispose();
  }
}

class _Lingkup extends InheritedNotifier<_Dokumen> {
  const _Lingkup({required _Dokumen k, required super.child})
    : super(notifier: k);

  static _Dokumen of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

/// Owns the board state, the phone screen and the strip (navigation.md 2.1).
class DokumenKendali extends StatefulWidget {
  const DokumenKendali({super.key, required this.child});
  final Widget child;
  @override
  State<DokumenKendali> createState() => _DokumenKendaliState();
}

class _DokumenKendaliState extends State<DokumenKendali> {
  final _k = _Dokumen();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    k: _k,
    child: LayarPonsel(layarKeuangan: true, child: widget.child),
  );
}

/// 19 · Dokumen pendukung (06-bukti.md, Dokumen): the list at `/Dokumen`,
/// the chosen transaction at `/Dokumen/rinci`.
class DokumenScreen extends StatelessWidget {
  const DokumenScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.warna.kertas,
    child: anak == 'rinci' ? const _Rinci() : const _Daftar(),
  );
}

/// Board strings as drawn; the vacancy name comes from the audit actor (M1).
String Function(String) _jk(BuildContext context) =>
    (s) => s;

class _Daftar extends StatelessWidget {
  const _Daftar();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    final t = _jk(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Dokumen pendukung',
          anakJudul: 'Yang perlu diputuskan',
          kembaliKe: Layar.pengaturan,
          labelKembali: 'Kembali ke Lainnya',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final d in _daftar) ...[
                  _baris(context, k, d, t),
                  const SizedBox(height: 10),
                ],
                Text(
                  'Diunggah bukan terverifikasi. Tutup buku hanya menerima Terverifikasi atau Dikecualikan.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _baris(
    BuildContext context,
    _Dokumen k,
    _Baris d,
    String Function(String) t,
  ) {
    final c = context.warna;
    final st = k.it[d.id]!.st;
    final b = _beres(st);
    return Tekan(
      radius: 14,
      onTap: () {
        k.pick(d.id);
        context.dorongKe(Layar.dokumen, anak: 'rinci');
      },
      child: Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _kodeJumlah(c, d),
            const SizedBox(height: 3),
            Text(
              d.ur,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 3),
            Text(
              t(_label[st]!),
              style: TextStyle(
                fontSize: 14,
                color: b ? c.tinta : c.bata,
                fontWeight: b ? FontWeight.w500 : FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(d.bulan, style: TextStyle(fontSize: 13, color: c.tinta3)),
          ],
        ),
      ),
    );
  }
}

/// No. Bukti and amount: space-between, baseline, gap 16.
Widget _kodeJumlah(PalakatWarna c, _Baris d) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic,
  children: [
    Flexible(
      child: Text(
        d.no,
        style: TextStyle(
          fontFamily: PalakatText.mono,
          fontSize: 13,
          color: c.tinta2,
        ),
      ),
    ),
    const SizedBox(width: 16),
    Text(
      d.rp,
      style: const TextStyle(
        fontFamily: PalakatText.mono,
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
);

class _Rinci extends StatelessWidget {
  const _Rinci();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    final t = _jk(context);
    final cur = _daftar.firstWhere((d) => d.id == k.pilih);
    final it = k.it[cur.id]!;
    final beres = _beres(it.st);
    final catatan = cur.tutup
        ? 'Dokumen susulan disimpan dan mengubah Status sekarang. Laporan resmi Oktober 2026 tidak berubah.'
        : it.st == 'tidak'
        ? 'Aturan Jemaat tidak mewajibkan dokumen untuk transaksi ini.'
        : it.st == 'gagal'
        ? 'File belum terlampir. Coba lagi tidak membuat salinan ganda.'
        : it.st == 'tahan'
        ? 'File ini tidak dapat dibuka dan tidak dihitung sebagai dokumen pendukung. Tetap menjadi hambatan tutup buku.'
        : beres
        ? 'Memenuhi syarat tutup buku November 2026.'
        : 'Menjadi hambatan tutup buku November 2026 sampai terverifikasi atau dikecualikan.';

    // Action buttons: U (laut) and O (outline), min 48, padding 0 18, radius 12.
    Widget aksi(String n, VoidCallback on, {bool u = false}) => Tekan(
      onTap: on,
      radius: 12,
      child: RupaTombol(
        label: n,
        isi: u ? c.laut : c.permukaan,
        garis: u ? null : GarisBorder.penuh(c.tinta, radius: 12),
        warnaTeks: u ? c.diLaut : c.tinta,
        radius: 12,
        tinggi: 48,
        paddingH: 18,
        lebarPenuh: false,
      ),
    );
    final daftarAksi = <Widget>[
      if (k.form == null)
        ...switch (it.st) {
          'kosong' => [
            aksi(
              'Lampirkan dokumen pendukung',
              () => k.set(
                'unggah',
                '16/11/2026 11.30 · nota baru diunggah oleh Meiske L.',
              ),
              u: true,
            ),
            aksi('Catat pengecualian', () => k.bukaForm('kecuali')),
          ],
          'unggah' => [
            aksi(
              'Verifikasi',
              () => k.set(
                'verif',
                '16/11/2026 11.32 · Terverifikasi oleh Meiske L.',
              ),
              u: true,
            ),
            aksi('Tolak dengan alasan', () => k.bukaForm('tolak')),
            aksi(
              'Lepaskan file',
              () => k.set(
                'kosong',
                '16/11/2026 11.33 · File dilepas oleh Meiske L. · tetap di Riwayat',
              ),
            ),
          ],
          'gagal' => [
            aksi(
              'Coba lagi',
              () => k.set(
                'unggah',
                '16/11/2026 11.31 · nota-sewa.jpg diunggah oleh Meiske L.',
              ),
              u: true,
            ),
          ],
          'tahan' => [
            aksi(
              'Lampirkan file lain',
              () => k.set(
                'unggah',
                '16/11/2026 11.31 · kuitansi-foto.jpg diunggah oleh Meiske L.',
              ),
              u: true,
            ),
          ],
          'kecuali' => [
            aksi(
              cur.tutup
                  ? 'Lampirkan dokumen susulan'
                  : 'Lampirkan dokumen pendukung',
              () => k.set(
                'unggah',
                '16/11/2026 11.30 · ${cur.tutup ? 'dokumen susulan' : 'nota'} diunggah oleh Meiske L.',
              ),
            ),
          ],
          _ => const <Widget>[],
        },
    ];

    final tautan = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    Widget link(String teks) => Center(
      widthFactor: 1,
      heightFactor: 1,
      child: TautanTeks(teks, berat: FontWeight.w700, ukuran: 14),
    );

    final isi = <Widget>[
      Kartu(
        status: GarisStatus.terpilih,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _kodeJumlah(c, cur),
            const SizedBox(height: 4),
            Text(cur.ur, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(cur.bulan, style: TextStyle(fontSize: 13, color: c.tinta3)),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, w) in [
            Text(
              'Dokumen pendukung',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            if (cur.tutup) ...[
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Status saat tutup buku: '),
                    TextSpan(
                      text: 'Dikecualikan (alasan: kuitansi menyusul, oleh Ketua BPMJ)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 14),
              ),
              const Text('Status sekarang:', style: TextStyle(fontSize: 14)),
            ],
            Text(
              t(_label[it.st]!),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: beres ? c.tinta : c.bata,
              ),
            ),
            Text(t(catatan), style: TextStyle(fontSize: 14, color: c.tinta2)),
          ].indexed) ...[if (i > 0) const SizedBox(height: 4), w],
        ],
      ),
      if (k.form != null) _Form(key: ValueKey(k.form), k: k),
      // Always present: the empty row still takes its 16 px column gap.
      Wrap(spacing: 8, runSpacing: 8, children: daftarAksi),
      DefaultTextStyle.merge(
        style: tautan,
        child: Wrap(
          spacing: 22,
          children: [
            Tautan(
              ke: Layar.lihatDokumen,
              param: {'id': belumDipindahId},
              child: link('Lihat file'),
            ),
            Tautan(ke: Layar.fotoDokumen, child: link('Foto dengan kamera')),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Riwayat keputusan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          for (final (i, h) in it.hist.indexed) ...[
            const SizedBox(height: 6),
            // Keyed from the oldest line, so only a new top line enters.
            Gerak(
              Kerangka.muncul,
              key: ValueKey('${cur.id}-${it.hist.length - i}'),
              lama: const Duration(milliseconds: 300),
              child: Text(
                t(h),
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ),
          ],
          if (it.hist.isEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Belum ada file dan belum ada keputusan.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ],
      ),
    ];

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) k.tutupRinci();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Dokumen pendukung',
            labelKembali: 'Kembali',
            onKembali: () {
              k.tutupRinci();
              context.naikKe(Layar.dokumen);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
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

/// The reason form (exception or rejection), entering with `muncul` 300 ms.
class _Form extends StatelessWidget {
  const _Form({super.key, required this.k});
  final _Dokumen k;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kec = k.form == 'kecuali';
    final ok = k.alasan.text.trim().isNotEmpty;
    void simpan() {
      // Re-read the latest text at press time.
      final a = k.alasan.text.trim();
      if (a.isEmpty) return;
      kec
          ? k.set(
              'kecuali',
              '16/11/2026 11.35 · Dikecualikan · alasan: $a · oleh Ketua BPMJ · dicatat Meiske L.',
            )
          : k.set(
              'kosong',
              '16/11/2026 11.35 · File ditolak · alasan: $a · oleh Meiske L.',
            );
    }

    final isi = <Widget>[
      Text(
        kec ? 'Catat pengecualian' : 'Tolak dengan alasan',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      Text(
        kec
            ? 'Pemberi pengecualian: Ketua BPMJ, sesuai pengaturan Jemaat. Anda mencatat keputusannya.'
            : 'Sementara (draf EC07). File yang ditolak tetap ada di Riwayat, dan statusnya dihitung lagi.',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
      GestureDetector(
        onTap: k.fokus.requestFocus,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Alasan '),
              TextSpan(
                text: '· wajib',
                style: TextStyle(color: c.tinta, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ),
      IsianTeks(
        controller: k.alasan,
        focusNode: k.fokus,
        labelSemantik: 'Alasan · wajib',
        onChanged: (_) => k.ubahAlasan(),
        baris: 2,
        minTinggi: 0,
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          TekanAria(
            onTap: simpan,
            aktif: ok,
            petunjuk: ok ? null : 'Alasan wajib diisi',
            radius: 12,
            child: RupaTombol(
              label: kec ? 'Catat pengecualian' : 'Tolak file ini',
              isi: ok ? c.tinta : c.garis,
              warnaTeks: ok ? c.permukaan : c.tinta3,
              radius: 12,
              tinggi: 46,
              paddingH: 20,
              lebarPenuh: false,
            ),
          ),
          Tombol(
            'Kembali',
            onPressed: k.batalForm,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.ringkas,
            lebarPenuh: false,
          ),
        ],
      ),
    ];
    return Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 300),
      child: Kartu(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, w) in isi.indexed) ...[
              if (i > 0) const SizedBox(height: 10),
              w,
            ],
          ],
        ),
      ),
    );
  }
}
