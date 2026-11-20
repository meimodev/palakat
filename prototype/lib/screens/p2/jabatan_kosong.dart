import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

const _stem = 'JabatanKosong';

/// The `keadaan` options, in board order (`O`).
const _o = [
  'Pita di setiap layar',
  'Konfirmasi tutup buku',
  'Tercatat di Riwayat',
  'Wajib pemeriksa kedua',
  'Jabatan sudah terisi',
];

/// 49 · Menjalankan jabatan kosong (screens/14, JabatanKosong). State
/// `{ k: null }`; the view is `k ?? keadaan`.
class JabatanKosongScreen extends StatefulWidget {
  const JabatanKosongScreen({super.key});

  @override
  State<JabatanKosongScreen> createState() => _JabatanKosongScreenState();
}

class _JabatanKosongScreenState extends State<JabatanKosongScreen> {
  final _gulir = ScrollController();
  String? _k;
  String? _tweak;
  bool _centang = false;

  @override
  void dispose() {
    _gulir.dispose();
    super.dispose();
  }

  void _keAtas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_gulir.hasClients) _gulir.jumpTo(0);
  });

  /// The board's `go<i>`.
  void _ke(int i) => setState(() {
    _k = _o[i];
    _centang = false;
    _keAtas();
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tweak = context.tweak<String>(_stem, 'keadaan');
    if (tweak != _tweak) {
      // A panel change resets `k` (screens/14 intro).
      if (_tweak != null) {
        _k = null;
        _centang = false;
        _keAtas();
      }
      _tweak = tweak;
    }
    final ki = (_o.indexOf(_k ?? tweak)).clamp(0, _o.length - 1);

    // PitaJabatanKosong.web's look, minus its live region: the board gives
    // this banner no role (spec: plain text). Shared fix in the review notes.
    final pita = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.tinta,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text:
                  'Anda menjalankan jabatan kosong Bendahara Jemaat sejak '
                  '16/11/2026 08.15.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text:
                  ' Setiap tindakan dicatat sebagai dijalankan oleh Operator '
                  'Yanti Sumual.',
              style: TextStyle(color: c.diTinta2),
            ),
          ],
        ),
        style: TextStyle(fontSize: 14, color: c.permukaan),
      ),
    );
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    Widget keterangan(String t) => Text(t, style: kecil);
    Widget tombol(List<Widget> anak) => BarisLentur(
      jarak: 8,
      anak: [for (final a in anak) Lentur(dasar: 150, maks: 340, child: a)],
    );
    Widget barisJudul(Widget judul, Widget ujung) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: judul),
        const SizedBox(width: 16),
        ujung,
      ],
    );
    Widget kartu(List<Widget> anak) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            anak[i],
          ],
        ],
      ),
    );
    const tebal = TextStyle(fontWeight: FontWeight.w700);
    final teks14 = TextStyle(fontSize: 14, color: c.tinta2);

    final List<Widget> isi = switch (ki) {
      0 => [
        pita,
        kartu([
          barisJudul(
            const Text('Saldo buku semua Kas/Bank', style: tebal),
            Text(
              'Rp38.415.000',
              style: PalakatText.jumlah.copyWith(color: c.tinta),
            ),
          ),
          keterangan('Hanya transaksi yang sudah dibukukan'),
        ]),
        kartu([
          barisJudul(
            const Text('Perlu tindakan', style: tebal),
            const LencanaStatus('4', bentuk: BentukLencana.bata),
          ),
          Text(
            'Oktober 2026 belum ditutup · 2 draf belum dibukukan',
            style: teks14,
          ),
        ]),
        keterangan(
          'Pita ini tampil di setiap layar Keuangan selama jabatan '
          'dijalankan: Beranda, Transaksi, Rekonsiliasi, Tutup buku, Laporan.',
        ),
        tombol([
          Tombol(
            'Lihat konfirmasi tutup buku',
            onPressed: () => _ke(1),
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
          ),
        ]),
      ],
      1 => [
        pita,
        kartu([
          const Text(
            'Tutup buku bulan Oktober 2026?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Ditutup oleh '),
                TextSpan(
                  text: 'Yanti Sumual, Operator',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
                ),
                const TextSpan(
                  text:
                      ', yang menjalankan jabatan kosong Bendahara Jemaat. '
                      'Nama dan keadaan ini tercatat pada tutup buku.',
                ),
              ],
            ),
            style: teks14,
          ),
          KotakCentang(
            nilai: _centang,
            onUbah: (v) => setState(() => _centang = v),
            jarakAtas: 2,
            label: const Text(
              'Saya sudah membaca ringkasan dan laporan sementara. Saya '
              'mengerti bahwa tutup buku ini bersifat permanen dan transaksi '
              'Oktober 2026 tidak dapat dikoreksi lagi.',
            ),
          ),
        ]),
        tombol([
          // Disabled on the board for good (no handler); see spec Notes.
          TekanAria(
            onTap: () {},
            aktif: false,
            radius: 14,
            petunjuk: 'Tombol aktif setelah pernyataan di atas dicentang.',
            child: RupaTombol(
              label: 'Tutup buku Oktober 2026',
              isi: c.garis,
              warnaTeks: c.tinta2,
              radius: 14,
              tinggi: 52,
              paddingH: 16,
            ),
          ),
          // Stretched to the 52 px neighbour, as the board's flex row does.
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Tombol(
              'Kembali',
              onPressed: () => _ke(0),
              jenis: JenisTombol.teks,
            ),
          ),
        ]),
        keterangan('Tombol aktif setelah pernyataan di atas dicentang.'),
      ],
      2 => [
        kartu([
          barisJudul(
            Text(
              'BKU-2026-0146',
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: c.tinta,
              ),
            ),
            LencanaStatus.uang(StatusUang.dibukukan),
          ),
          Text('Dibukukan pada 16/11/2026 11.42', style: teks14),
          keterangan(
            'Oleh Yanti Sumual, Operator · menjalankan jabatan kosong '
            'Bendahara Jemaat',
          ),
        ]),
        kartu([
          barisJudul(
            const Text('Rekonsiliasi Kas · Oktober 2026', style: tebal),
            LencanaStatus.uang(StatusUang.sudahDipastikan),
          ),
          keterangan(
            'Oleh Yanti Sumual, Operator · menjalankan jabatan kosong '
            'Bendahara Jemaat · 16/11/2026 10.20',
          ),
        ]),
        keterangan(
          'Riwayat menyimpan orang yang bertindak dan jabatan yang '
          'dijalankannya. Bendahara baru nanti tidak mewarisi tindakan ini '
          'sebagai miliknya.',
        ),
      ],
      3 => [
        pita,
        const Penolakan(
          tindakan: 'Bukukan',
          sebab:
              'Wajib pemeriksa kedua aktif, dan draf ini Anda catat sendiri.',
          jalan: [],
        ),
        keterangan(
          'Menjalankan jabatan kosong tidak menggantikan orang kedua. Yang '
          'dapat memeriksa: Pnt. Jefry Wowor.',
        ),
        tombol([
          Tombol(
            'Biarkan sebagai draf',
            onPressed: () => _ke(0),
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
          ),
        ]),
      ],
      _ => [
        Kartu(
          status: GarisStatus.terpilih,
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Bendahara Jemaat sudah terisi:', style: tebal),
                TextSpan(
                  text: ' Deitje Kawengian, wewenang aktif sejak 18/11/2026.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
        const Penolakan(
          tindakan: 'Bukukan',
          sebab: 'Anda tidak lagi menjalankan jabatan Bendahara Jemaat.',
          jalan: [],
        ),
        keterangan(
          'Draf yang Anda siapkan tetap ada dan dapat dibukukan oleh '
          'Bendahara Jemaat.',
        ),
        tombol([
          const Tombol(
            'Kembali ke Beranda',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            ke: 'BerandaJabatan',
            cara: Cara.naik,
          ),
        ]),
      ],
    };

    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Menjalankan jabatan kosong',
              anakJudul:
                  'Contoh keadaan: jabatan Bendahara Jemaat belum ada '
                  'pemegangnya',
              kembaliKe: 'BerandaJabatan',
              labelKembali: 'Kembali ke Beranda',
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _gulir,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < isi.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      isi[i],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
