import 'package:flutter/material.dart';

import '../mock/format.dart';
import '../mock/jemaat.dart';
import '../motion/hitung.dart';
import '../motion/kerangka.dart';
import '../motion/ulang.dart';
import '../motion/urutan.dart';
import '../theme/palakat_tema.dart';
import '../widgets/batang_pembagian.dart';
import '../widgets/bertindak_sebagai.dart';
import '../widgets/butir_perhatian.dart';
import '../widgets/chip_pilihan.dart';
import '../widgets/garis_status.dart';
import '../widgets/ikon.dart';
import '../widgets/input_format.dart';
import '../widgets/isian_alasan.dart';
import '../widgets/isian_jumlah.dart';
import '../widgets/kartu_kasus.dart';
import '../widgets/kartu_persetujuan.dart';
import '../widgets/kartu_usulan_ai.dart';
import '../widgets/kecil.dart';
import '../widgets/lembar_bawah.dart';
import '../widgets/lencana_modul.dart';
import '../widgets/lencana_status.dart';
import '../widgets/panel_dokumen.dart';
import '../widgets/pemilih_mata_anggaran.dart';
import '../widgets/penghitung_pecahan.dart';
import '../widgets/penolakan.dart';
import '../widgets/pita_jabatan_kosong.dart';
import '../widgets/pita_laporan.dart';
import '../widgets/pita_peran.dart';
import '../widgets/pratinjau_layar_kunci.dart';
import '../widgets/rangka.dart';
import '../widgets/rangkaian_koreksi.dart';
import '../widgets/riwayat_alur.dart';
import '../widgets/sakelar.dart';
import '../widgets/status_simpan.dart';
import '../widgets/tahapan.dart';
import '../widgets/tampilan_nama.dart';
import '../widgets/tombol.dart';
import '../widgets/tombol_bersyarat.dart';
import 'halaman_web.dart';
import 'tautan.dart';

/// One gallery entry: the component name, the first sentence of its
/// design-system README, and its variants (one preview.html each).
typedef _Komponen = ({String nama, String teks, WidgetBuilder isi});

/// `/_komponen` (README M1 item 4): every component and variant, light and
/// dark side by side, in the design system's group order, each next to the
/// copy of its `preview.html`.
class KomponenGaleri extends StatelessWidget {
  const KomponenGaleri({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      nav: null,
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tautan(
              ke: '',
              cara: Cara.naik,
              child: const TautanTeks('Kembali ke daftar layar'),
            ),
            const SizedBox(height: 8),
            Semantics(
              header: true,
              child: Text(
                'Komponen',
                style: PalakatText.judulHalaman.copyWith(color: c.tinta),
              ),
            ),
            Text(
              '${_kelompok.fold(0, (n, k) => n + k.$2.length)} komponen · '
              'terang dan gelap berdampingan',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        for (final (judul, daftar) in _kelompok) ...[
          Semantics(
            header: true,
            child: Text(
              judul,
              style: PalakatText.judulBesar.copyWith(color: c.tinta),
            ),
          ),
          for (final k in daftar) _KartuKomponen(k),
        ],
      ],
    );
  }
}

class _KartuKomponen extends StatelessWidget {
  const _KartuKomponen(this.k);
  final _Komponen k;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          k.nama,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        Text(k.teks, style: TextStyle(fontSize: 14, color: c.tinta2)),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, b) {
            final terang = _Panel(Brightness.light, k.isi);
            final gelap = _Panel(Brightness.dark, k.isi);
            if (b.maxWidth < 820) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [terang, const SizedBox(height: 12), gelap],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: terang),
                const SizedBox(width: 12),
                Expanded(child: gelap),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// The preview's `.tanah` in one theme: `kertas`, 15 / 1.45 `tinta`, padding
/// 20, content at most 372 wide (`.pk`).
class _Panel extends StatelessWidget {
  const _Panel(this.kecerahan, this.isi);
  final Brightness kecerahan;
  final WidgetBuilder isi;

  @override
  Widget build(BuildContext context) => Theme(
    data: palakatTema(kecerahan),
    child: Builder(
      builder: (context) {
        final c = context.warna;
        return Material(
          color: c.kertas,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: c.garis),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: DefaultTextStyle(
            style: PalakatText.isiWeb.copyWith(color: c.tinta, height: 1.45),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kecerahan == Brightness.light ? 'Terang' : 'Gelap',
                    style: TextStyle(fontSize: 12, color: c.tinta3),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 372),
                    child: Builder(builder: isi),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// Column with the preview's gap 10.
Widget _pk(List<Widget> anak, {double jarak = 10}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    for (var i = 0; i < anak.length; i++) ...[
      if (i > 0) SizedBox(height: jarak),
      anak[i],
    ],
  ],
);

Widget _keterangan(BuildContext context, String teks) =>
    Text(teks, style: TextStyle(fontSize: 13, color: context.warna.tinta2));

/// Local state for a live variant: [awal], and a setter for the builder.
class _Hidup<T> extends StatefulWidget {
  const _Hidup(this.awal, this.builder);
  final T awal;
  final Widget Function(BuildContext, T, ValueChanged<T>) builder;

  @override
  State<_Hidup<T>> createState() => _HidupState<T>();
}

class _HidupState<T> extends State<_Hidup<T>> {
  late T nilai = widget.awal;

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, nilai, (v) => setState(() => nilai = v));
}

/// A text controller that lives as long as the variant.
class _DenganTeks extends StatefulWidget {
  const _DenganTeks(this.awal, this.builder);
  final String awal;
  final Widget Function(BuildContext, TextEditingController, VoidCallback)
  builder;

  @override
  State<_DenganTeks> createState() => _DenganTeksState();
}

class _DenganTeksState extends State<_DenganTeks> {
  late final k = TextEditingController(text: widget.awal);

  @override
  void dispose() {
    k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, k, () => setState(() {}));
}

void _diam() {}

final List<(String, List<_Komponen>)> _kelompok = [
  (
    'Fondasi',
    [
      (
        nama: 'GarisStatus',
        teks:
            'Bentuk garis adalah bahasa status uang: putus-putus belum masuk '
            'saldo, garis penuh sudah dibukukan, tinta gelap sudah ditutup.',
        isi: (ctx) => _pk([
          for (final (s, judul, sub) in const [
            (GarisStatus.draf, 'draf', 'Belum masuk saldo'),
            (GarisStatus.dibukukan, 'dibukukan', 'Masuk saldo dan laporan'),
            (GarisStatus.terpilih, 'terpilih', 'Sedang dikerjakan'),
            (GarisStatus.ditutup, 'ditutup', 'Sudah ditutup, resmi'),
            (GarisStatus.usulanAI, 'usulanAI', 'Usulan AI'),
            (GarisStatus.hambatan, 'hambatan', 'Hambatan, gagal'),
          ])
            Kartu(
              status: s,
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: s == GarisStatus.ditutup ? ctx.warna.kertas : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        judul,
                        style: const TextStyle(
                          fontFamily: PalakatText.mono,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        sub,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ]),
      ),
      (
        nama: 'Gerak',
        teks:
            'Gerak hanya dipakai saat status uang berubah. Semua gerak mati '
            'bila perangkat meminta gerak dikurangi.',
        isi: (ctx) => const _Gerak(),
      ),
    ],
  ),
  (
    'Status',
    [
      (
        nama: 'LencanaStatus',
        teks:
            'Lencana kecil yang menyebut status satu transaksi, satu bulan '
            'atau satu rekonsiliasi dengan kata dari glosarium.',
        isi: (ctx) => _pk([
          _keterangan(ctx, 'Transaksi'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in const [
                StatusUang.draf,
                StatusUang.sudahDiperiksa,
                StatusUang.dibukukan,
                StatusUang.dibalik,
                StatusUang.dibatalkan,
              ])
                LencanaStatus.uang(s),
            ],
          ),
          _keterangan(ctx, 'Bulan · rekonsiliasi'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in StatusUang.values.skip(5)) LencanaStatus.uang(s),
            ],
          ),
          _keterangan(ctx, 'Bentuk'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final b in BentukLencana.values)
                LencanaStatus(b.name, bentuk: b),
              const LencanaStatus(
                'Dibukukan',
                bentuk: BentukLencana.tinta,
                kepala: true,
              ),
            ],
          ),
        ]),
      ),
      (
        nama: 'LencanaModul',
        teks: 'Lencana keadaan modul dan jabatan.',
        isi: (ctx) => _pk([
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in KeadaanModul.values) LencanaModul.modul(k),
            ],
          ),
          _keterangan(ctx, 'Jabatan'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in KeadaanJabatan.values) LencanaModul.jabatan(k),
            ],
          ),
        ]),
      ),
      (
        nama: 'Tahapan',
        teks:
            'Deret chip bernomor yang menunjukkan langkah mana yang sudah '
            'dilewati.',
        isi: (ctx) => _pk([
          for (var i = 0; i <= 3; i++)
            Tahapan(
              langkah: const ['Draf', 'Sudah diperiksa', 'Diterbitkan'],
              selesai: i,
            ),
        ]),
      ),
      (
        nama: 'BatangPembagian',
        teks:
            'Batang yang memperlihatkan berapa bagian dari satu jumlah yang '
            'sudah dibagi dan berapa sisanya.',
        isi: (ctx) {
          final w = BatangPembagian.warnaBagian(ctx.warna);
          return _pk([
            BatangPembagian(
              total: 2000000,
              bagian: [BagianBatang(1000000, w[0]), BagianBatang(500000, w[1])],
            ),
            const SisaPembagian(
              label: 'Sisa belum dibagi',
              jumlah: 500000,
              pas: false,
            ),
            BatangPembagian(
              total: 2000000,
              bagian: [
                for (var i = 0; i < w.length; i++) BagianBatang(400000, w[i]),
              ],
            ),
            const SisaPembagian(
              label: 'Sisa belum dibagi',
              jumlah: 0,
              pas: true,
            ),
          ]);
        },
      ),
      (
        nama: 'Rangka',
        teks: 'Keadaan memuat untuk semua modul: bentuk isi tanpa isi.',
        isi: (ctx) => _pk([
          const Rangka(
            keterangan:
                'Bentuk isi tampil lebih dulu; tidak ada angka sementara yang '
                'bisa disangka angka sebenarnya.',
            balok: [
              RangkaBalok(lebar: .62, tinggi: 22),
              RangkaBalok(lebar: 1, tinggi: 64, radius: 14),
              RangkaBalok(lebar: .4, tinggi: 14),
            ],
          ),
          RangkaGagal(
            kalimat: 'Server tidak menjawab. Pembukuan Anda tidak berubah.',
            onCobaLagi: _diam,
          ),
        ]),
      ),
    ],
  ),
  (
    'Tindakan',
    [
      (
        nama: 'Tombol',
        teks:
            'Tombol utama, kedua, teks, dan tombol tahan untuk tindakan '
            'permanen.',
        isi: (ctx) => _pk([
          const Tombol('Bukukan', onPressed: _diam),
          const Tombol('Ubah', onPressed: _diam, jenis: JenisTombol.kedua),
          const Tombol(
            'Simpan sebagai draf',
            onPressed: _diam,
            jenis: JenisTombol.teks,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final j in JenisTombol.values)
                Tombol(
                  j.name,
                  onPressed: _diam,
                  jenis: j,
                  ukuran: UkuranTombol.kecil,
                  lebarPenuh: false,
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final u in UkuranTombol.values)
                Tombol(u.name, onPressed: _diam, ukuran: u, lebarPenuh: false),
            ],
          ),
          _Hidup<bool>(
            true,
            (ctx, siap, ubah) => TombolTahan(
              'Tutup buku Oktober 2026',
              siap: siap,
              onSelesai: () => ubah(false),
              petunjuk: siap
                  ? 'Tekan dan tahan tombol sampai penuh'
                  : 'Centang pernyataan di atas untuk melanjutkan',
            ),
          ),
          const Tombol('Bukukan', onPressed: _diam, nonaktif: true),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Tidak dapat dilakukan: ',
                  style: TextStyle(
                    color: ctx.warna.bata,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text:
                      'Mata Anggaran belum dipilih. Tombol nonaktif selalu '
                      'ditemani alasannya.',
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ]),
      ),
      (
        nama: 'Penolakan',
        teks:
            'Kalimat penolakan yang menyebut sebabnya dan menawarkan langkah '
            'yang memang tersedia.',
        isi: (ctx) => const Penolakan(
          tindakan: 'Bukukan',
          sebab: 'September 2026 sudah ditutup.',
          jalan: [
            Tombol(
              'Pindah tanggal',
              onPressed: _diam,
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
            ),
            Tombol(
              'Batalkan',
              onPressed: _diam,
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.sedang,
            ),
          ],
        ),
      ),
    ],
  ),
  (
    'Isian',
    [
      (
        nama: 'IsianJumlah',
        teks:
            'Isian angka rupiah bulat dengan titik pemisah ribuan saat '
            'mengetik.',
        isi: (ctx) => _pk([
          for (final u in UkuranJumlah.values)
            _DenganTeks(
              u == UkuranJumlah.standar ? '' : '1.250.000',
              (ctx, k, ubah) => IsianJumlah(
                label: 'Jumlah (Rp) · ${u.name}',
                controller: k,
                onChanged: (_) => ubah(),
                ukuran: u,
              ),
            ),
        ]),
      ),
      (
        nama: 'IsianAlasan',
        teks:
            'Isian teks dua baris untuk alasan yang wajib sebelum tindakan '
            'tertentu.',
        isi: (ctx) => _DenganTeks(
          '',
          (ctx, k, ubah) => _pk([
            IsianAlasan(
              controller: k,
              onChanged: (_) => ubah(),
              contoh: 'Contoh: Mata Anggaran keliru',
            ),
            Tombol(
              'Batalkan draf',
              onPressed: _diam,
              jenis: JenisTombol.bata,
              nonaktif: !IsianAlasan.terisi(k.text),
            ),
          ]),
        ),
      ),
      (
        nama: 'ChipPilihan',
        teks:
            'Chip untuk memilih satu dari sedikit pilihan yang semuanya '
            'terlihat.',
        isi: (ctx) => _Hidup<String>(
          'umum',
          (ctx, v, ubah) => ChipPilihan<String>(
            label: 'Diambil dari peruntukan',
            keterangan: '· uang siapa ini',
            pilihan: const [
              (nilai: 'umum', teks: 'Umum Jemaat'),
              (nilai: 'diakonia', teks: 'Diakonia'),
              (nilai: 'pembangunan', teks: 'Pembangunan'),
            ],
            terpilih: v,
            onPilih: ubah,
          ),
        ),
      ),
      (
        nama: 'PemilihMataAnggaran',
        teks:
            'Daftar Mata Anggaran yang dapat dicari, dengan judul kelompok '
            'yang tidak dapat dipilih, dan pembagian ke beberapa baris.',
        isi: (ctx) => _Hidup<BarisMataAnggaran?>(
          null,
          (ctx, v, ubah) => _pk([
            IsianMataAnggaran(pohon: 'Belanja', terpilih: v, onTap: _diam),
            SizedBox(
              height: 460,
              child: PemilihMataAnggaran(
                pohon: 'Belanja',
                baris: const [
                  BarisMataAnggaran('5.01.00.00', 'BELANJA RUTIN', grup: true),
                  BarisMataAnggaran('5.01.02.00', 'Listrik, air dan telepon'),
                  BarisMataAnggaran('5.02.00.00', 'BELANJA KANTOR', grup: true),
                  BarisMataAnggaran('5.02.01.00', 'Alat tulis dan fotokopi'),
                ],
                onPilih: ubah,
                onTanpa: () => ubah(null),
                keBagi: null,
              ),
            ),
          ]),
        ),
      ),
      (
        nama: 'Sakelar',
        teks: 'Sakelar hidup atau mati untuk pengaturan.',
        isi: (ctx) => _pk([
          for (final awal in [false, true])
            _Hidup<bool>(
              awal,
              (ctx, v, ubah) =>
                  Sakelar(nilai: v, onUbah: ubah, label: v ? 'Hidup' : 'Mati'),
            ),
          Sakelar(
            nilai: true,
            onUbah: (_) {},
            label: 'Nonaktif',
            nonaktif: true,
          ),
        ]),
      ),
      (
        nama: 'PenghitungPecahan',
        teks:
            'Baris hitung kas: pecahan, tombol kurang dan tambah, jumlah '
            'lembar, dan hasil kalinya.',
        isi: (ctx) => _Hidup<int>(
          5,
          (ctx, v, ubah) =>
              PenghitungPecahan(pecahan: 50000, lembar: v, onUbah: ubah),
        ),
      ),
    ],
  ),
  (
    'Kartu',
    [
      (
        nama: 'ButirPerhatian',
        teks:
            'Tiga tingkat perhatian: Hambatan, Perlu tindakan, dan Untuk '
            'diketahui.',
        isi: (ctx) => _pk([
          const ButirPerhatian(
            tingkat: TingkatPerhatian.hambatan,
            judul: 'Bank BNI ··4821 belum direkonsiliasi',
            keterangan: 'Selisih belum dijelaskan Rp515.000',
            labelTingkat: true,
            perbaikan: Tombol(
              'Buka rekonsiliasi',
              onPressed: _diam,
              jenis: JenisTombol.tinta,
              ukuran: UkuranTombol.kecil,
            ),
          ),
          const ButirPerhatian(
            tingkat: TingkatPerhatian.perluTindakan,
            judul: '2 draf belum dibukukan',
            keterangan: 'Perlu tindakan · belum masuk saldo',
            onTap: _diam,
          ),
          const ButirPerhatian(
            tingkat: TingkatPerhatian.untukDiketahui,
            judul: '2 uang muka dengan sisa belum dipertanggungjawabkan',
            keterangan: 'Untuk diketahui.',
            onTap: _diam,
          ),
        ]),
      ),
      (
        nama: 'PanelDokumen',
        teks:
            'Daftar dokumen pendukung satu transaksi dengan status tiap '
            'dokumen.',
        isi: (ctx) => _pk([
          PanelDokumen(
            dokumen: [
              for (final s in StatusDokumen.values)
                BarisDokumen(
                  status: s,
                  judul: 'nota-16-11.jpg',
                  keterangan: s.name,
                ),
            ],
          ),
          LampiranDokumen.belum(onLampirkan: _diam),
          const LampiranDokumen.mengunggah(),
          const LampiranDokumen.terlampir(),
        ]),
      ),
      (
        nama: 'KartuPersetujuan',
        teks: 'Kartu yang mencatat persetujuan yang terjadi di luar aplikasi.',
        isi: (ctx) => _pk([
          const KartuPersetujuan.belum(onCatat: _diam),
          const KartuPersetujuan.sudah(
            pemberi: 'Pnt. Jefry Wowor',
            jabatan: 'Ketua BPMJ',
            tanggal: '08/11/2026',
            cara: 'notulen rapat',
            dicatatOleh: 'Meiske L.',
            dicatatPada: '16/11/2026 11.20',
          ),
          const KartuPersetujuan.tidakDiperlukan(aturan: 'transaksi rutin'),
        ]),
      ),
      (
        nama: 'KartuUsulanAI',
        teks:
            'Kartu untuk usulan dari AI yang belum menjadi nilai apa pun '
            'sampai Bendahara memakainya.',
        isi: (ctx) => _pk([
          for (final ragu in [false, true])
            KartuUsulanAI(
              label: 'Usulan AI',
              isi: const Text('Belanja 5.01.02.00 Listrik, air dan telepon'),
              kurangYakin: ragu,
              onPakai: _diam,
              onUbah: _diam,
              onAbaikan: _diam,
            ),
        ]),
      ),
      (
        nama: 'KartuKasus',
        teks:
            'Kartu satu kasus Uang Muka, Titipan atau Penggantian biaya '
            'dengan sisa yang masih berjalan.',
        isi: (ctx) => _pk([
          const KartuKasus(
            nama: 'Panitia Natal',
            labelPihak: 'Diberikan kepada',
            pihak: 'Sdr. Rivo Mandagi',
            awal: 1500000,
            dipertanggungjawabkan: 850000,
            status: 'Sebagian dipertanggungjawabkan · jatuh tempo 30/11/2026',
            onTap: _diam,
          ),
          const KartuKasus(
            nama: 'Panitia Natal',
            labelPihak: 'Diberikan kepada',
            pihak: 'Sdr. Rivo Mandagi',
            awal: 1500000,
            dipertanggungjawabkan: 850000,
            status: 'Sebagian dipertanggungjawabkan · Lewat jatuh tempo',
            lewatTempo: true,
            onTap: _diam,
          ),
        ]),
      ),
      (
        nama: 'RangkaianKoreksi',
        teks:
            'Tiga kartu bersambung: transaksi yang dibalik, pembalikannya, '
            'dan transaksi koreksi.',
        isi: (ctx) => const RangkaianKoreksi(
          kartu: [
            KartuRangkaian(
              noBukti: 'BKU-2026-0139',
              lencana: 'Dibalik',
              dibalik: true,
            ),
            KartuRangkaian(
              noBukti: 'BKU-2026-0144 · Pembalikan',
              lencana: 'Dibukukan',
            ),
            KartuRangkaian(
              noBukti: 'BKU-2026-0145 · Transaksi koreksi',
              lencana: 'Dibukukan',
            ),
          ],
        ),
      ),
    ],
  ),
  (
    'Pita',
    [
      (
        nama: 'PitaLaporan',
        teks:
            'Pita di atas laporan yang menyebut apakah laporan itu sementara '
            'atau resmi.',
        isi: (ctx) => _pk([
          const PitaLaporan.sementara(
            kalimat: 'Bukan laporan resmi. Angka masih dapat berubah.',
          ),
          const PitaLaporan.resmi(
            dibekukan: 'saat tutup buku',
            idSalinan: 'SNP-2026-10-01',
          ),
          const PitaLaporan.a4Sementara(
            kalimat: 'Bukan laporan resmi. Angka masih dapat berubah.',
          ),
          const PitaLaporan.terbatas(
            kalimat:
                'File ini dibuat khusus untuk bagian peruntukan Diakonia. Ini '
                'bukan versi tersembunyi dari file seluruh Jemaat.',
          ),
        ]),
      ),
      (
        nama: 'PitaPeran',
        teks:
            'Pita yang menyebut peran pengguna atau keadaan yang mengunci '
            'layar.',
        isi: (ctx) => _pk(const [
          PitaPeran(
            jenis: JenisPita.peran,
            judul: 'Akses terbatas: Peruntukan Diakonia',
          ),
          PitaPeran(
            jenis: JenisPita.kunci,
            judul: 'Belum ada Bendahara aktif.',
            kalimat: 'Semua data hanya dapat dilihat.',
          ),
          PitaPeran(
            jenis: JenisPita.belumPasti,
            judul: 'Sementara.',
            kalimat: 'Aturannya belum diputuskan.',
          ),
        ]),
      ),
      (
        nama: 'PitaJabatanKosong',
        teks:
            'Pita yang selalu tampil selama seorang Operator menjalankan '
            'jabatan yang belum ada pemegangnya.',
        isi: (ctx) =>
            _pk(const [PitaJabatanKosong.ponsel(), PitaJabatanKosong.web()]),
      ),
      (
        nama: 'StatusSimpan',
        teks:
            'Teks dan pita yang selalu jujur tentang apakah isian sudah '
            'tersimpan.',
        isi: (ctx) => _pk([
          for (final k in KeadaanSimpan.values) StatusSimpan(k),
          const PitaGagalSimpan(onCobaLagi: _diam),
          const PitaDiubahOrangLain(
            oleh: 'Meiske L.',
            jam: '10.58',
            onMuat: _diam,
          ),
        ]),
      ),
    ],
  ),
  (
    'Wadah',
    [
      (
        nama: 'LembarBawah',
        teks:
            'Lembar yang naik dari bawah layar ponsel untuk pilihan atau '
            'isian singkat.',
        isi: (ctx) => _pk([
          // The sheet fills its parent (scrim + sheet at the bottom).
          SizedBox(
            height: 240,
            child: LembarBawah(
              judul: 'Catat apa?',
              onTutup: _diam,
              isi: [
                Text(
                  'Pendapatan · Belanja · Persembahan · Pindah antar Kas/Bank',
                  style: TextStyle(color: ctx.warna.tinta2),
                ),
              ],
            ),
          ),
          Tombol(
            'Buka lembar',
            onPressed: () => tampilkanLembarBawah<void>(
              ctx,
              judul: 'Catat apa?',
              isi: (_) => const Text(
                'Pendapatan · Belanja · Persembahan · Pindah antar Kas/Bank',
              ),
            ),
            jenis: JenisTombol.kedua,
          ),
        ]),
      ),
    ],
  ),
  (
    'Platform',
    [
      (
        nama: 'TombolBersyarat',
        teks:
            'Tombol tindakan utama di formulir alur: tampak mati sampai '
            'syaratnya terpenuhi, dan selalu disertai alasan.',
        isi: (ctx) => _DenganTeks('10/11/2026', (ctx, k, ubah) {
          final t = bacaTgl(k.text);
          final alasan = t == null || t <= hari
              ? 'tanggal berakhir harus setelah hari ini ($hariTeks).'
              : '';
          return _pk([
            IsianTeks(
              controller: k,
              label: 'Berlaku sampai',
              formatters: [TanggalInputFormatter()],
              keyboardType: TextInputType.datetime,
              onChanged: (_) => ubah(),
            ),
            TombolBersyarat(
              label: 'Buat pelimpahan',
              tindakan: 'Buat pelimpahan',
              alasan: alasan,
              onPressed: _diam,
            ),
          ]);
        }),
      ),
      (
        nama: 'BertindakSebagai',
        teks:
            'Cara satu orang dengan beberapa jabatan bekerja di satu Beranda, '
            'tanpa berganti jabatan.',
        isi: (ctx) => _pk([
          const DaftarJabatan(
            nama: 'Pnt. Hendrik Rumagit',
            jabatan: ['Penatua Kolom 7', 'Ketua Komisi Diakonia'],
          ),
          const LabelSebagai(
            jabatan: 'Penatua Kolom 7',
            rincian: '2 permohonan · 2 peristiwa',
          ),
          const BertindakSebagai.satu(jabatan: 'Penatua Kolom 7'),
          BertindakSebagai.pilih(
            jabatan: const ['Penatua Kolom 7', 'Ketua Komisi Diakonia'],
            onPilih: (_) {},
          ),
        ]),
      ),
      (
        nama: 'TampilanNama',
        teks:
            'Pilihan anggota tentang bagaimana namanya tampil di publikasi, '
            'dengan pratinjau.',
        isi: (ctx) => _Hidup<BentukNama>(
          BentukNama.keluargaKolom,
          (ctx, v, ubah) => TampilanNama(
            pilihan: v,
            contoh: {
              for (final (pilihan, tampil, cetak) in tampilanNama)
                BentukNama.values.firstWhere((b) => b.label == pilihan):
                    cetak.isEmpty ? tampil : cetak,
            },
            contohKalimat: 'Syukur HUT pernikahan: ',
            masihDikenali: v == BentukNama.bipra || v == BentukNama.bipraKolom
                ? tampilanNamaPeringatan
                : null,
            onPilih: ubah,
          ),
        ),
      ),
      (
        nama: 'RiwayatAlur',
        teks: 'Daftar singkat tindakan yang baru dijalankan, terbaru di atas.',
        isi: (ctx) => const RiwayatAlur(
          baris: [
            '16/11/2026 · Memverifikasi Peristiwa: Sidi · Gabriela Rompas · '
                'oleh Yanti Sumual, Operator · menjalankan jabatan kosong '
                'Penatua Kolom 2',
            '16/11/2026 · Mulai menjalankan jabatan kosong Penatua Kolom 2 · '
                'alasan: Penatua belum ditugaskan · Yanti Sumual, Operator',
          ],
        ),
      ),
      (
        nama: 'PratinjauLayarKunci',
        teks:
            'Contoh pemberitahuan dorong seperti yang terlihat di layar '
            'kunci, dipakai di Akun saya.',
        isi: (ctx) => const PratinjauLayarKunci(
          modul: 'Data jemaat',
          jumlah: 1,
          jenis: 'data menunggu verifikasi',
        ),
      ),
    ],
  ),
];

/// The Gerak card: the three money sequences and the wait loops, with
/// "Putar ulang" replaying them (new keys).
class _Gerak extends StatefulWidget {
  const _Gerak();

  @override
  State<_Gerak> createState() => _GerakState();
}

class _GerakState extends State<_Gerak> {
  var _putaran = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return KeyedSubtree(
      key: ValueKey(_putaran),
      child: _pk([
        Align(
          alignment: Alignment.centerLeft,
          child: Tombol(
            'Putar ulang',
            onPressed: () => setState(() => _putaran++),
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.kecil,
            lebarPenuh: false,
          ),
        ),
        // Bukukan: sapu, cap, hitung.
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Kartu(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Gerak(
                        Kerangka.cap,
                        lama: const Duration(milliseconds: 500),
                        tunda: const Duration(milliseconds: 500),
                        child: const Text(
                          'BKU-2026-0101',
                          style: TextStyle(
                            fontFamily: PalakatText.mono,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Hitung(
                      nilai: -1250000,
                      dari: 0,
                      builder: (_, n) => Text(
                        rp(n),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SapuTinta(),
            ],
          ),
        ),
        _keterangan(context, 'Tinta · 700 ms'),
        _keterangan(
          context,
          'Bukukan: tinta menyapu kartu, No. Bukti dicap, saldo berhitung '
          'ke angka baru.',
        ),
        // Cocokkan: two sides meet and hook.
        Row(
          children: [
            Expanded(
              child: Gerak(
                Kerangka.dariKiri(40),
                lama: const Duration(milliseconds: 450),
                kurva: PalakatMotion.keluar,
                child: const Kartu(child: Text('Mutasi bank −Rp15.000')),
              ),
            ),
            Gerak(
              Kerangka.kait,
              lama: const Duration(milliseconds: 450),
              tunda: const Duration(milliseconds: 450),
              child: PalakatIkon(Ikon.kait, ukuran: 15, warna: c.laut),
            ),
            Expanded(
              child: Gerak(
                Kerangka.dariKanan(40),
                lama: const Duration(milliseconds: 450),
                kurva: PalakatMotion.keluar,
                child: const Kartu(child: Text('Transaksi −Rp15.000')),
              ),
            ),
          ],
        ),
        _keterangan(context, 'Kait · 450 ms'),
        _keterangan(
          context,
          'Cocokkan: dua sisi bertemu dan terkait; selisih berhitung turun '
          'ke Rp0.',
        ),
        // Tutup buku: segel.
        Container(
          color: c.tinta,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: const SegelGembok(ukuran: 72),
        ),
        _keterangan(context, 'Segel · tahan 1600 ms, lalu 900 ms'),
        _keterangan(
          context,
          'Tutup buku: tombol ditahan sampai penuh, layar menggelap, '
          'lingkaran menutup, gembok terpasang.',
        ),
        // Tunggu: the loops.
        Row(
          children: [
            Putar(child: PalakatIkon(Ikon.cincinProses, warna: c.laut)),
            const SizedBox(width: 10),
            const Text('Sedang diunggah…'),
            const SizedBox(width: 10),
            const TitikAI(),
          ],
        ),
        const BatangIsi(lama: Duration(seconds: 2), tinggi: 4),
        const Row(
          children: [
            LingkarSelesai(ukuran: 56),
            SizedBox(width: 12),
            Expanded(child: RangkaBalok(lebar: 1, tinggi: 14)),
          ],
        ),
        _keterangan(context, 'Tunggu · selama prosesnya'),
        _keterangan(
          context,
          'Unggah, simpan, file laporan: selalu tampak sedang berjalan. '
          'Berhasil tidak pernah ditampilkan sebelum benar-benar berhasil.',
        ),
      ]),
    );
  }
}
