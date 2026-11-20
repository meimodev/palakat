import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../providers/keuangan/persembahan_bernama.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// Shared by PersembahanBernama and WebPersembahanBernama: the views, the
/// transaction card and the five view blocks (spec 22).
const keadaanPemberi = [
  'Tanpa nama',
  'Pilih pemberi',
  'Tercatat atas nama anggota',
  'Belum dikonfirmasi',
  'Dilihat jabatan lain',
];

/// The view follows the envelope (J1): Tanpa nama or Tercatat atas nama
/// anggota, and Dilihat jabatan lain for anyone but the Bendahara (P06).
/// "Catat nama pemberi" opens Pilih pemberi, and a refused Simpan shows
/// Belum dikonfirmasi. Every view change jumps the page to the top.
mixin KeadaanPemberi<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  int? _k;
  Refusal? tolakan;
  final nama = TextEditingController();

  /// Any widget inside the page's scroll view.
  final kunciIsi = GlobalKey();

  @override
  void dispose() {
    nama.dispose();
    super.dispose();
  }

  int ki(Sampul? s) {
    if (!ref.watch(bolehLihatPemberiProvider)) return 4;
    return _k ?? (s?.pemberi == null ? 0 : 2);
  }

  /// [i] null returns to the view the envelope gives.
  void pilih(int? i) {
    setState(() => _k = i);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = kunciIsi.currentContext;
      if (ctx != null) Scrollable.maybeOf(ctx)?.position.jumpTo(0);
    });
  }

  /// Simpan ([n] the typed name) or Lepas nama ([n] null).
  Future<void> simpan(Sampul s, String? n) async {
    final r = await catatPemberi(ref, s, n);
    if (!mounted) return;
    tolakan = r;
    pilih(r == null ? null : 3);
  }
}

/// "Sampul syukur" fact card, every view.
class KartuSampul extends StatelessWidget {
  const KartuSampul(this.s, {super.key});

  final Sampul s;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    Widget baris(String l, String n) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l, style: TextStyle(fontSize: 14, color: c.tinta2)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            n,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
    return Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.judul,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                rp(s.a.amount),
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          baris('Tanggal transaksi', s.tanggal),
          if (s.diterima != null) baris('Diterima di', s.diterima!),
          baris('Masuk ke peruntukan', s.peruntukan),
        ],
      ),
    );
  }
}

/// The view blocks under the transaction card, as flat children of the
/// board's column. [ke] is the "Lihat yang dilihat anggota" target; null
/// leaves the button out (the web has no PersembahanSaya, README 7.1 rule 4).
/// A booked envelope keeps its giver: its change buttons are left out.
List<Widget> blokPemberi(
  BuildContext context,
  WidgetRef ref, {
  required Sampul s,
  required int ki,
  required KeadaanPemberi k,
  Layar? ke,
}) {
  final c = context.warna;
  final draf = s.t.isDraft;
  final pemberi = s.pemberi;
  final kecil = TextStyle(fontSize: 13, color: c.tinta3);

  Widget fakta(String label, BentukLencana bentuk, List<String> ket) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pemberi',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 16),
            LencanaStatus(label, bentuk: bentuk),
          ],
        ),
        for (final k in ket) Text(k, style: kecil),
      ],
    ),
  );

  // `flex: 1 1 150px; max-width: 340px`, gap 8; the row stretches its items
  // to the tallest, so a text button gets that height.
  Widget tombol(List<Object> anak) => BarisLentur(
    jarak: 8,
    anak: [
      for (final w in anak)
        w is Lentur ? w : Lentur(dasar: 150, maks: 340, child: w as Widget),
    ],
  );
  Widget teks(String l, double tinggi, VoidCallback aksi) => SizedBox(
    height: tinggi,
    child: Tombol(l, jenis: JenisTombol.teks, onPressed: aksi),
  );

  return switch (ki) {
    0 => [
      fakta('Tanpa nama', BentukLencana.draf, const [
        'Bawaan. Persembahan kantong dan sampul tanpa nama tidak dicatat per orang.',
      ]),
      if (draf)
        tombol([
          Tombol(
            'Catat nama pemberi',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            onPressed: () {
              k.nama.clear();
              k.pilih(1);
            },
          ),
        ]),
    ],
    1 => [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IsianTeks(
            label: 'Pemberi (anggota)',
            controller: k.nama,
            jarakLabel: 6,
            // The board's `input { font: inherit; color: inherit }` from the label.
            gaya: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          const SizedBox(height: 6),
          Text('Cari di Data jemaat · hanya anggota yang Aktif', style: kecil),
        ],
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.lautLembut,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text.rich(
          const TextSpan(
            children: [
              TextSpan(
                text: 'Nama ini hanya dilihat pemberinya dan Bendahara Jemaat.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: ' Tidak tampil di laporan, dan tidak tampil bagi Penatua, Syamas, Sekretaris Jemaat atau Operator.',
              ),
            ],
          ),
          style: TextStyle(fontSize: 14, color: c.tinta),
        ),
      ),
      Text(
        'Bila anggota ini kelak mencabut izin dan datanya dihapus, catatan keuangan tetap menyimpan nama seperti yang tercatat.',
        style: kecil,
      ),
      tombol([
        Tombol(
          'Simpan',
          jenis: JenisTombol.tinta,
          onPressed: () => k.simpan(s, k.nama.text),
        ),
        teks('Batalkan', 52, () => k.pilih(null)),
      ]),
    ],
    2 => [
      fakta(pemberi?.name ?? '', BentukLencana.garis, [
        'Tampil di “Persembahan saya” milik ${pemberi?.name} setelah transaksi ini Dibukukan.',
        if (pemberi != null)
          'Di Warta Jemaat namanya mengikuti Tampilan nama yang ia pilih: ${ref.watch(tampilanNamaProvider(pemberi.id))}.',
      ]),
      Text(
        'Nama pemberi bukan bagian dari jumlah: dapat dicatat atau dilepas tanpa pembalikan, dan setiap perubahan tercatat di Riwayat.',
        style: kecil,
      ),
      tombol([
        // An `<a>` is content-box: basis, max-width and min-height exclude
        // its padding 16 + 16 and line 1.5 + 1.5.
        if (ke != null && pemberi != null)
          Lentur(
            dasar: 185,
            maks: 375,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 51),
              child: Tombol(
                'Lihat yang dilihat anggota',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                onPressed: () {
                  ref.read(pemberiDilihatProvider.notifier).pilih(pemberi.id);
                  context.dorongKe(ke);
                },
              ),
            ),
          ),
        if (draf) teks('Lepas nama', 51, () => k.simpan(s, null)),
      ]),
    ],
    3 => [
      Penolakan(
        tindakan: k.tolakan?.action ?? '',
        sebab: k.tolakan?.because ?? '',
        jalan: const [],
      ),
      Text(
        'Namanya tetap boleh ditulis di Uraian sebagai catatan pembukuan, tetapi tidak ditautkan ke orangnya sampai datanya Diverifikasi.',
        style: kecil,
      ),
      tombol([teks('Kembali', 44, () => k.pilih(null))]),
    ],
    _ => [
      Kartu(
        status: GarisStatus.terpilih,
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text.rich(
          const TextSpan(
            children: [
              TextSpan(
                text: 'Nama pemberi tidak ditampilkan.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: ' Hanya pemberinya dan Bendahara Jemaat yang melihatnya.',
              ),
            ],
          ),
          style: TextStyle(fontSize: 14, color: c.tinta),
        ),
      ),
      fakta('Tidak ditampilkan', BentukLencana.abu, const [
        'Jumlah dan peruntukannya tetap tampil sesuai wewenang jabatan Anda.',
      ]),
    ],
  };
}
