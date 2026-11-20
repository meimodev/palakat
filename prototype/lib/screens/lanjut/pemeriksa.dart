import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tahapan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import 'pemeriksa_baris.dart';
import '../../app/belum_dipindah.dart';

enum _St { draf, periksa, buku }

enum _Gaya { utama, kedua, mati }

/// 13 · Wajib pemeriksa kedua (phone). One Belanja draft goes Draf → Sudah
/// diperiksa → Dibukukan; the viewer plays both people with `masukSebagai`.
class PemeriksaScreen extends StatefulWidget {
  const PemeriksaScreen({super.key});
  @override
  State<PemeriksaScreen> createState() => _PemeriksaScreenState();
}

class _PemeriksaScreenState extends State<PemeriksaScreen> {
  // Board parity: a tweak change keeps `st`.
  _St _st = _St.draf;
  bool _sheet = false;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final bend = belumDipindah<String>('Bendahara') == 'Bendahara';
    final ada = belumDipindah<bool>(true);
    final draf = _st == _St.draf, periksa = _St.periksa == _st;
    final buku = _st == _St.buku;

    var aksi = <(String, _Gaya, VoidCallback?)>[];
    var tolak = '', penjelasan = '';
    if (draf && bend) {
      tolak = ada
          ? 'Anda yang mencatat transaksi ini, jadi orang lain yang harus menandainya sudah diperiksa. Pemeriksa kedua: Pnt. Jefry Wowor.'
          : 'belum ada pemeriksa kedua yang ditunjuk. Yang perlu bertindak: BPMJ menunjuk pemeriksa kedua.';
      aksi = [
        ('Tandai sudah diperiksa', _Gaya.mati, null),
        ('Ubah', _Gaya.kedua, null), // no handler on the board
      ];
      penjelasan = 'Draf belum masuk saldo. Sampai diperiksa dan dibukukan, transaksi ini menjadi hambatan tutup buku November 2026.';
    } else if (draf) {
      aksi = [
        (
          'Tandai sudah diperiksa',
          _Gaya.utama,
          () => setState(() => _st = _St.periksa),
        ),
      ];
      penjelasan = 'Menandai sudah diperiksa bukan persetujuan dan belum memasukkan transaksi ke saldo. Bendahara yang membukukan.';
    } else if (periksa && bend) {
      aksi = [
        ('Bukukan', _Gaya.utama, () => setState(() => _st = _St.buku)),
        ('Ubah', _Gaya.kedua, () => setState(() => _sheet = true)),
      ];
      penjelasan = 'Sudah diperiksa, belum masuk saldo. Pindah tanggal dan Batalkan tetap tersedia dengan alasan.';
    } else if (periksa) {
      penjelasan = 'Anda sudah menandai transaksi ini. Menunggu Bendahara membukukan; tidak ada yang perlu Anda lakukan.';
    } else {
      penjelasan = 'Sudah masuk saldo. Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata Anggaran tidak dapat diubah lagi.';
    }

    final t14 = TextStyle(fontSize: 14, color: c.tinta2);

    final kartu = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Only the background has the 300 ms transition; the edge switches at once.
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              end: draf ? c.permukaan.withValues(alpha: 0) : c.permukaan,
            ),
            duration: gerakMati(context)
                ? Duration.zero
                : const Duration(milliseconds: 300),
            builder: (context, isi, child) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: ShapeDecoration(
                color: isi,
                shape: buku
                    ? GarisBorder.penuh(c.tinta, radius: 16)
                    : periksa
                    ? GarisBorder.penuh(c.laut, radius: 16)
                    : GarisBorder.putus(c.putus, radius: 16),
              ),
              child: child,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      // Never shrinks on the board; only guards narrow text.
                      fit: FlexFit.loose,
                      flex: buku ? 0 : 1,
                      child: LencanaStatus(
                        buku
                            ? 'Dibukukan'
                            : periksa
                            ? 'Sudah diperiksa · belum masuk saldo'
                            : 'Draf · belum masuk saldo',
                        bentuk: buku
                            ? BentukLencana.tinta
                            : periksa
                            ? BentukLencana.lautGaris
                            : BentukLencana.draf,
                      ),
                    ),
                    if (buku) ...[
                      const SizedBox(width: 8),
                      // CSS shrinks the stamp, not the one-word badge: it wraps.
                      Expanded(
                        child: Gerak(
                          Kerangka.cap,
                          key: const ValueKey('cap'),
                          lama: const Duration(milliseconds: 550),
                          tunda: const Duration(milliseconds: 350),
                          kurva: PalakatMotion.keluar,
                          child: _Cap(),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  rp(-900000),
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: buku ? c.tinta : c.tinta2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kas · diambil dari peruntukan Umum Jemaat · Lingkup Jemaat',
                  style: t14,
                ),
                const SizedBox(height: 6),
                Text(
                  'Belanja 5.05.02.00 Sewa peralatan · 16 November 2026',
                  style: t14,
                ),
              ],
            ),
          ),
          if (buku) const SapuTinta(key: ValueKey('sapu')),
        ],
      ),
    );

    Widget tombol((String, _Gaya, VoidCallback?) a) {
      final (n, g, on) = a;
      final rupa = RupaTombol(
        label: n,
        isi: switch (g) {
          _Gaya.utama => c.laut,
          _Gaya.kedua => c.permukaan,
          _Gaya.mati => c.garis,
        },
        garis: g == _Gaya.kedua ? GarisBorder.penuh(c.tinta, radius: 14) : null,
        warnaTeks: switch (g) {
          _Gaya.utama => c.diLaut,
          _Gaya.kedua => c.tinta,
          _Gaya.mati => c.tinta3,
        },
        radius: 14,
        tinggi: 50,
        paddingH: 6,
      );
      if (g == _Gaya.mati) {
        return TekanAria(
          onTap: () {},
          aktif: false,
          petunjuk: tolak,
          radius: 14,
          child: rupa,
        );
      }
      return Tekan(onTap: on ?? () {}, radius: 14, child: rupa);
    }

    final isi = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Masuk sebagai '),
                    TextSpan(
                      text: bend
                          ? 'Meiske L., Bendahara'
                          : 'Pnt. Jefry Wowor, Pemeriksa kedua',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.tinta,
                      ),
                    ),
                    const TextSpan(text: ' · Wajib pemeriksa kedua: hidup'),
                  ],
                ),
                style: TextStyle(fontSize: 13, color: c.tinta2),
              ),
              const SizedBox(height: 4),
              Semantics(
                header: true,
                child: const Text(
                  'Belanja · Sewa kursi ibadah padang',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Tahapan(
                    langkah: const ['Draf', 'Sudah diperiksa', 'Dibukukan'],
                    selesai: draf ? 1 : (periksa ? 2 : 3),
                  ),
                ),
                const SizedBox(height: 16),
                kartu,
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.permukaan,
                    border: Border.all(color: c.garis),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const BarisRincian(
                        'Dicatat oleh',
                        'Meiske L. · 16/11/2026 09.40',
                        atas: false,
                      ),
                      BarisRincian(
                        'Diperiksa oleh',
                        draf
                            ? 'Belum diperiksa'
                            : 'Pnt. Jefry Wowor · 16/11/2026 10.05',
                        warna: draf ? c.bata : c.tinta,
                        kanan: true,
                      ),
                      const BarisRincian(
                        'Dokumen pendukung',
                        'Diunggah, belum diverifikasi',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(penjelasan, style: t14),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border(top: BorderSide(color: c.garis)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final w in [
                if (tolak.isNotEmpty)
                  Semantics(
                    container: true,
                    liveRegion: true,
                    child: Text(
                      'Tidak dapat dilakukan: $tolak',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.bata,
                      ),
                    ),
                  ),
                for (final a in aksi) tombol(a),
              ].indexed) ...[if (w.$1 > 0) const SizedBox(height: 8), w.$2],
            ],
          ),
        ),
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        overlay: [
          if (_sheet)
            Positioned.fill(
              child: LembarBawah(
                judul: 'Ubah transaksi yang sudah diperiksa?',
                ukuranJudul: 19,
                labelTirai: 'Kembali ke transaksi',
                onTutup: () => setState(() => _sheet = false),
                isi: [
                  Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(text: 'Transaksi kembali menjadi '),
                        TextSpan(
                          text: 'Draf',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: '. Tanda sudah diperiksa dari Pnt. Jefry Wowor dan persetujuan yang sudah dicatat akan hilang, lalu perlu diberikan lagi.',
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 15, color: c.tinta),
                  ),
                  Tombol(
                    'Ubah dan kembalikan ke Draf',
                    jenis: JenisTombol.tinta,
                    onPressed: () => setState(() {
                      _st = _St.draf;
                      _sheet = false;
                    }),
                  ),
                  Tombol(
                    'Kembali',
                    jenis: JenisTombol.teks,
                    warnaTeks: c.tinta,
                    onPressed: () => setState(() => _sheet = false),
                  ),
                ],
              ),
            ),
        ],
        child: isi,
      ),
    );
  }
}

/// The No. Bukti stamp: mono 14/600 `laut`, 2 px `laut` line, radius 8.
class _Cap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: c.laut, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        // U+200B: Chrome breaks after the hyphen when the stamp shrinks; ICU does not.
        'No. Bukti BKU-2026-​0151',
        semanticsLabel: 'No. Bukti BKU-2026-0151',
        style: TextStyle(
          fontFamily: PalakatText.mono,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c.laut,
        ),
      ),
    );
  }
}
