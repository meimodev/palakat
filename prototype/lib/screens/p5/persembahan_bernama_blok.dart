import 'package:flutter/widgets.dart';

import '../../core/format.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// Shared by PersembahanBernama and WebPersembahanBernama: the `keadaan`
/// options, the transaction card and the five view blocks (spec 22).
const keadaanPemberi = [
  'Tanpa nama',
  'Pilih pemberi',
  'Tercatat atas nama anggota',
  'Belum dikonfirmasi',
  'Dilihat jabatan lain',
];

/// Board state `{ k: null }`: the view is `k ?? keadaan`; a panel change of
/// `keadaan` resets `k`; every view change jumps the page to the top.
mixin KeadaanPemberi<T extends StatefulWidget> on State<T> {
  String? _k;
  String? _tweak;

  /// Any widget inside the page's scroll view.
  final kunciIsi = GlobalKey();

  int ki(BuildContext context, String stem) {
    final t = belumDipindah<String>('Tanpa nama');
    if (t != _tweak) {
      _tweak = t;
      _k = null;
    }
    final i = keadaanPemberi.indexOf(_k ?? t);
    return i < 0 ? 0 : i;
  }

  void pilih(int i) {
    setState(() => _k = keadaanPemberi[i]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = kunciIsi.currentContext;
      if (ctx != null) Scrollable.maybeOf(ctx)?.position.jumpTo(0);
    });
  }
}

/// "Sampul syukur" fact card, every view.
class KartuSampul extends StatelessWidget {
  const KartuSampul({super.key});

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
              const Expanded(
                child: Text(
                  'Sampul syukur',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                rp(100000),
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          baris('Tanggal transaksi', '01/11/2026'),
          baris('Diterima di', 'Ibadah Minggu Pagi'),
          baris('Masuk ke peruntukan', 'Umum Jemaat'),
        ],
      ),
    );
  }
}

/// The view blocks under the transaction card, as flat children of the
/// board's column. [ke] is the "Lihat yang dilihat anggota" target; null
/// leaves the button out (the web has no PersembahanSaya, README 7.1 rule 4).
List<Widget> blokPemberi(
  BuildContext context, {
  required int ki,
  required ValueChanged<int> pilih,
  Layar? ke,
}) {
  final c = context.warna;
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
  Widget teks(String l, double tinggi, int ke) => SizedBox(
    height: tinggi,
    child: Tombol(l, jenis: JenisTombol.teks, onPressed: () => pilih(ke)),
  );

  return switch (ki) {
    0 => [
      fakta('Tanpa nama', BentukLencana.draf, const [
        'Bawaan. Persembahan kantong dan sampul tanpa nama tidak dicatat per orang.',
      ]),
      tombol([
        Tombol(
          'Catat nama pemberi',
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.sedang,
          onPressed: () => pilih(1),
        ),
      ]),
    ],
    1 => [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IsianTeks(
            label: 'Pemberi (anggota)',
            nilaiAwal: 'Novita Wenas',
            hanyaBaca: true,
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
        Tombol('Simpan', jenis: JenisTombol.tinta, onPressed: () => pilih(2)),
        teks('Batalkan', 52, 0),
      ]),
    ],
    2 => [
      fakta('Novita Wenas', BentukLencana.garis, const [
        'Tampil di “Persembahan saya” milik Novita Wenas setelah transaksi ini Dibukukan.',
        'Di Warta Jemaat namanya mengikuti Tampilan nama yang ia pilih: Tanpa nama.',
      ]),
      Text(
        'Nama pemberi bukan bagian dari jumlah: dapat dicatat atau dilepas tanpa pembalikan, dan setiap perubahan tercatat di Riwayat.',
        style: kecil,
      ),
      tombol([
        // An `<a>` is content-box: basis, max-width and min-height exclude
        // its padding 16 + 16 and line 1.5 + 1.5.
        if (ke != null)
          Lentur(
            dasar: 185,
            maks: 375,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 51),
              child: Tombol(
                'Lihat yang dilihat anggota',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                ke: ke,
                onPressed: null,
              ),
            ),
          ),
        teks('Lepas nama', 51, 0),
      ]),
    ],
    3 => [
      const Penolakan(
        tindakan: 'Catat nama pemberi',
        sebab: 'data Ferry Wenas masih Belum dikonfirmasi.',
        jalan: [],
      ),
      Text(
        'Namanya tetap boleh ditulis di Uraian sebagai catatan pembukuan, tetapi tidak ditautkan ke orangnya sampai datanya Diverifikasi.',
        style: kecil,
      ),
      tombol([teks('Kembali', 44, 0)]),
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
