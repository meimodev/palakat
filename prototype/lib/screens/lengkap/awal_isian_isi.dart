import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// Shared by AwalIsian and WebAwalIsian: the boards' identical logic class
/// and the cards both lay out (phone in one column, web in two).

/// key · title · caption · placeholder, in the board's order.
const _bagian = [
  (
    'kas',
    'Kas/Bank',
    'Tempat uang berada. Jangan memakai nama peruntukan atau Lingkup.',
    'Misalnya: Bank SulutGo ··1107',
  ),
  ('per', 'Peruntukan', 'Uang siapa, bukan untuk apa.', 'Misalnya: Diakonia'),
  (
    'ling',
    'Lingkup',
    'Jemaat, Kolom, BIPRA, Komisi atau Panitia.',
    'Misalnya: Kolom 3',
  ),
  (
    'um',
    'Uang muka yang masih berjalan',
    'Per penerima dan peruntukan, pada tanggal mulai pencatatan.',
    'Penerima · peruntukan · jumlah',
  ),
  (
    'tt',
    'Titipan yang masih dipegang',
    'Per pihak yang berhak, pada tanggal mulai pencatatan.',
    'Titipan untuk · jumlah',
  ),
];

/// The board state `{ nama, zona, terbit, isi, d }`.
class KeadaanAwalIsian extends ChangeNotifier {
  final nama = TextEditingController(text: 'Jemaat Karunia');
  String zona = 'WITA';
  bool terbit = false;
  final isi = {for (final b in _bagian) b.$1: TextEditingController()};
  final d = <String, List<String>>{
    'kas': ['Kas', 'Bank BNI ··4821'],
    'per': ['Umum Jemaat'],
    'ling': ['Jemaat'],
    'um': [],
    'tt': [],
  };

  bool get _okNama => nama.text.trim().isNotEmpty;
  bool get _kurang => ['kas', 'per', 'ling'].any((k) => d[k]!.isEmpty);
  bool get bisa => _okNama && !_kurang && !terbit;
  bool get satu => d['per']!.length == 1 && d['ling']!.length == 1;
  String get alasan => !_okNama
      ? 'Nama Jemaat belum diisi.'
      : _kurang
      ? 'Kas/Bank, peruntukan dan Lingkup masing-masing perlu paling sedikit satu.'
      : 'Setelah diterbitkan, perubahan dilakukan lewat Pengaturan dan berlaku mulai bulan tertentu.';

  void ubah() => notifyListeners();

  void pilihZona(String z) {
    if (terbit) return;
    zona = z;
    notifyListeners();
  }

  void tambah(String k) {
    final v = isi[k]!.text.trim();
    if (terbit || v.isEmpty) return;
    d[k] = [...d[k]!, v];
    isi[k]!.clear();
    notifyListeners();
  }

  void buang(String k, int i) {
    if (terbit) return;
    d[k] = [...d[k]!]..removeAt(i);
    notifyListeners();
  }

  void terbitkan() {
    if (!bisa) return;
    terbit = true;
    notifyListeners();
  }

  @override
  void dispose() {
    nama.dispose();
    for (final c in isi.values) {
      c.dispose();
    }
    super.dispose();
  }
}

/// Inputs: undo the Material bodyLarge `letterSpacing: 0.5` that TextField
/// merges under IsianTeks, and clip the placeholder like Chrome (no ellipsis).
const _gayaIsian = TextStyle(letterSpacing: 0, overflow: TextOverflow.clip);

/// Chrome draws the input text ~2 px higher than Flutter's centred line.
const _padIsian = EdgeInsets.fromLTRB(14, 0, 14, 3);

Widget _kolom(List<Widget> anak, double jarak) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (var i = 0; i < anak.length; i++) ...[
      if (i > 0) SizedBox(height: jarak),
      anak[i],
    ],
  ],
);

/// Identity card: Nama Jemaat, Zona waktu, three fixed facts.
class KartuIdentitas extends StatelessWidget {
  const KartuIdentitas(this.k, {super.key});
  final KeadaanAwalIsian k;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    Widget fakta(String label, String nilai, {bool kanan = true}) => Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: _BarisSusut(
        kiri: label,
        gayaKiri: TextStyle(fontSize: 14, color: c.tinta2),
        kanan: nilai,
        gayaKanan: const TextStyle(fontWeight: FontWeight.w600),
        rataKanan: kanan,
      ),
    );
    return Kartu(
      padding: const EdgeInsets.all(16),
      child: _kolom([
        IsianTeks(
          controller: k.nama,
          label: 'Nama Jemaat',
          jarakLabel: 6,
          gaya: _gayaIsian,
          padding: _padIsian,
          hanyaBaca: k.terbit,
          onChanged: (_) => k.ubah(),
        ),
        ChipPilihan<String>(
          label: 'Zona waktu',
          pilihan: const [
            (nilai: 'WIB', teks: 'WIB'),
            (nilai: 'WITA', teks: 'WITA'),
            (nilai: 'WIT', teks: 'WIT'),
          ],
          terpilih: k.zona,
          onPilih: k.pilihZona,
        ),
        fakta('Tahun buku', 'Mulai 1 Januari · tidak dapat diubah'),
        fakta('Tanggal mulai pencatatan', '15 September 2026', kanan: false),
        fakta(
          'Bulan pertama pencatatan',
          'September 2026 · dari tanggal mulai',
        ),
      ], 12),
    );
  }
}

/// The five list cards, each with `margin-bottom: 14px`.
class DaftarAwal extends StatelessWidget {
  const DaftarAwal(this.k, {super.key});
  final KeadaanAwalIsian k;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final b in _bagian)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _KartuDaftar(k, b),
        ),
    ],
  );
}

class _KartuDaftar extends StatelessWidget {
  const _KartuDaftar(this.k, this.b);
  final KeadaanAwalIsian k;
  final (String, String, String, String) b;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (kunci, judul, cat, ph) = b;
    final butir = k.d[kunci]!;
    final berjalan = kunci == 'um' || kunci == 'tt';
    return Kartu(
      padding: const EdgeInsets.all(16),
      child: _kolom([
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              judul,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(cat, style: TextStyle(fontSize: 13, color: c.tinta3)),
          ],
        ),
        // Always present, also when empty (its 8 px gaps stay).
        butir.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < butir.length; i++)
                      _Butir(
                        butir[i],
                        onBuang: k.terbit ? null : () => k.buang(kunci, i),
                      ),
                  ],
                ),
              ),
        if (butir.isEmpty)
          Text(
            berjalan
                ? 'Tidak ada. Dicatat sebagai tidak ada, bukan dikosongkan.'
                : 'Belum ada. Paling sedikit satu.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: berjalan ? c.tinta2 : c.bata,
            ),
          ),
        if (!k.terbit)
          Row(
            children: [
              Expanded(
                child: IsianTeks(
                  controller: k.isi[kunci],
                  labelSemantik: judul,
                  petunjuk: ph,
                  gaya: _gayaIsian,
                  padding: _padIsian,
                  onChanged: (_) => k.ubah(),
                ),
              ),
              const SizedBox(width: 8),
              Tekan(
                onTap: () => k.tambah(kunci),
                radius: 12,
                child: RupaTombol(
                  label: 'Tambah',
                  isi: c.permukaan,
                  garis: GarisBorder.penuh(c.tinta, radius: 12),
                  warnaTeks: c.tinta,
                  radius: 12,
                  tinggi: 48,
                  paddingH: 16,
                  lebarPenuh: false,
                ),
              ),
            ],
          ),
      ], 8),
    );
  }
}

/// Removable item chip: a `<span>` (content-box, so 44 + 2 × 1.5 tall).
class _Butir extends StatelessWidget {
  const _Butir(this.teks, {required this.onBuang});
  final String teks;
  final VoidCallback? onBuang;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      constraints: const BoxConstraints(minHeight: 47),
      padding: const EdgeInsets.fromLTRB(14, 0, 4, 0),
      decoration: ShapeDecoration(
        shape: GarisBorder.penuh(c.tinta, radius: 999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              teks,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          if (onBuang != null) ...[
            const SizedBox(width: 2),
            Tekan(
              onTap: onBuang,
              label: 'Keluarkan $teks',
              radius: 22,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: PalakatIkon(
                    Ikon.silang,
                    ukuran: 16,
                    tebal: 2.4,
                    warna: c.tinta3,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dashed note, shown only with exactly one peruntukan and one Lingkup.
class CatatanSatu extends StatelessWidget {
  const CatatanSatu({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(c.putus, radius: 14),
      ),
      child: Text(
        'Hanya ada satu peruntukan dan satu Lingkup. Saat mencatat, keduanya terisi sendiri dan diringkas; keduanya tetap tercatat di setiap transaksi.',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
    );
  }
}

/// Note (when shown), then the reason line and button, or the result card.
List<Widget> akhirAwal(BuildContext context, KeadaanAwalIsian k) {
  final c = context.warna;
  return [
    if (k.satu) const CatatanSatu(),
    if (!k.terbit) ...[
      Semantics(
        liveRegion: true,
        child: Text(k.alasan, style: TextStyle(fontSize: 14, color: c.tinta2)),
      ),
      TombolBersyarat(
        label: 'Terbitkan pengaturan awal',
        tindakan: 'Terbitkan pengaturan awal',
        alasan: k.bisa ? '' : k.alasan,
        periksa: () => k.bisa ? '' : k.alasan,
        onPressed: k.terbitkan,
        sudahMulai: false,
        warnaSiap: JenisTombol.utama,
        teksBelumRedup: true,
        paddingH: 20,
      ),
    ] else
      Gerak(
        Kerangka.muncul,
        lama: const Duration(milliseconds: 300),
        child: Kartu(
          status: GarisStatus.terpilih,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pengaturan awal diterbitkan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Berlaku mulai September 2026. Perubahan berikutnya dilakukan lewat Pengaturan dan berlaku mulai bulan tertentu. Yang sudah dipakai hanya dapat dinonaktifkan.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
      ),
  ];
}

/// Column with a CSS `gap`.
Widget kolomAwal(List<Widget> anak, double jarak) => _kolom(anak, jarak);

/// CSS `display: flex; justify-content: space-between; gap: 16px` with two
/// text items that shrink in proportion to their natural width (flex-shrink 1).
class _BarisSusut extends StatelessWidget {
  const _BarisSusut({
    required this.kiri,
    required this.gayaKiri,
    required this.kanan,
    required this.gayaKanan,
    required this.rataKanan,
  });
  final String kiri, kanan;
  final TextStyle gayaKiri, gayaKanan;
  final bool rataKanan;

  @override
  Widget build(BuildContext context) {
    final dasar = DefaultTextStyle.of(context).style;
    final skala = MediaQuery.textScalerOf(context);
    int lebar(String t, TextStyle g) {
      final tp = TextPainter(
        text: TextSpan(text: t, style: dasar.merge(g)),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = tp.width;
      tp.dispose();
      return (w * 10).ceil().clamp(1, 1 << 30);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: lebar(kiri, gayaKiri),
          child: Text(kiri, style: gayaKiri),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: lebar(kanan, gayaKanan),
          child: Text(
            kanan,
            textAlign: rataKanan ? TextAlign.right : TextAlign.left,
            style: gayaKanan,
          ),
        ),
      ],
    );
  }
}
