import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

/// 76 · Data anggota dan keluarga (phone). No handler changes the view: it is
/// the panel's `keadaan`, so the board state `k` is always null.
class DataAnggotaScreen extends StatelessWidget {
  const DataAnggotaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final keadaan = context.tweak<String>('DataAnggota', 'keadaan');
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Data anggota dan keluarga',
            anakJudul:
                'Satu data untuk setiap orang; keluarga menyimpan riwayatnya',
            kembaliKe: 'BerandaJabatan',
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              // A view change jumps to the top.
              key: ValueKey(keadaan),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: IsiDataAnggota(
                keadaan: keadaan,
                ajukan: (w) => Tautan(ke: 'Peristiwa', child: w),
                konfirmasi: (w) =>
                    Tautan(ke: 'KonfirmasiKeluarga', radius: 14, child: w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The views of DataAnggota and WebDataAnggota (identical markup; the body
/// size, 16 or 15, is inherited). Each screen wraps the two in-content links
/// itself so its own file names their targets.
class IsiDataAnggota extends StatelessWidget {
  const IsiDataAnggota({
    super.key,
    required this.keadaan,
    required this.ajukan,
    required this.konfirmasi,
  });

  final String keadaan;

  /// `Tautan(ke: 'Peristiwa')` around "Ajukan peristiwa".
  final Widget Function(Widget) ajukan;

  /// `Tautan(ke: 'KonfirmasiKeluarga')` around the secondary button look.
  final Widget Function(Widget) konfirmasi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    Widget baris13(String t) =>
        Text(t, style: TextStyle(fontSize: 13, color: c.tinta3));
    Widget baris14(String t) =>
        Text(t, style: TextStyle(fontSize: 14, color: c.tinta2));

    final kisi = KisiOtomatis(
      minLebar: 300,
      jarak: 16,
      anak: [
        _Kartu([
          const _Kepala('Novita Wenas', 'Aktif', BentukLencana.laut),
          const _Info(
            'Keluarga',
            'Wenas-Lasut · Wakil keluarga: Agustina Lasut',
          ),
          const _Info('Tanggal lahir', '14/03/1996'),
          const _Info('Status pernikahan', 'Belum pernah menikah'),
          const _Info('Tampilan nama', 'Keluarga + Kolom'),
        ]),
        _Kartu([
          const Text(
            'Kategori BIPRA',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const _Kepala(
            'Pemuda',
            'Dihitung dari data',
            BentukLencana.garis,
            berat: FontWeight.w600,
          ),
          baris13('Dasar: 30 tahun dan belum pernah menikah.'),
          baris13(
            'Anak: sampai sebelum 12 tahun. Remaja: 12 tahun sampai 17 tahun '
            '364 hari. Pemuda: 18 tahun ke atas dan belum pernah menikah. Bapa '
            'atau Ibu: sudah menikah. Yang pernah menikah tetap Bapa atau Ibu; '
            'yang belum pernah menikah tetap Pemuda, berapa pun umurnya. Aturan '
            'ini dari ketentuan GMIM; gereja tidak mengubahnya.',
          ),
          baris13(
            'Penatua Kolom dapat mengoreksi kategori satu orang dengan alasan '
            'yang tercatat.',
          ),
        ]),
        _Kartu([
          const Text('Kolom', style: TextStyle(fontWeight: FontWeight.w700)),
          const _Info('Kolom 7', 'sejak 01/06/2021'),
          const _Info('Kolom 4', '12/02/2009 – 31/05/2021'),
          baris13(
            'Penugasan lama disimpan dengan tanggal berakhirnya. Transaksi '
            'lama tetap pada Lingkup aslinya.',
          ),
        ]),
        _Kartu([
          const Text(
            'Peristiwa',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const _Info('Baptisan', '19/05/1996 · Diverifikasi'),
          const _Info('Sidi', '13/04/2014 · Diverifikasi'),
          const _Info('Pernikahan', '—'),
          ajukan(
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: const Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: TautanTeks(
                  'Ajukan peristiwa',
                  berat: FontWeight.w700,
                  ukuran: 14,
                ),
              ),
            ),
          ),
        ]),
      ],
    );

    final List<Widget> isi = switch (keadaan) {
      'Dilihat Sekretaris Jemaat' => [
        Kartu(
          status: GarisStatus.terpilih,
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'Hanya baca.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ' Sekretaris Jemaat membaca seluruh Data jemaat untuk '
                      'surat dan Warta, tetapi tidak mengubah atau '
                      'memverifikasinya.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.tinta),
          ),
        ),
        kisi,
      ],
      'Belum dikonfirmasi' => [
        _Kartu(status: GarisStatus.draf, [
          const _Kepala(
            'Ferry Wenas',
            'Belum dikonfirmasi',
            BentukLencana.draf,
          ),
          baris14('Dari buku anggota Kolom 7 · diimpor 12/11/2026'),
          baris13(
            'Hanya Penatua Kolom 7 dan Operator yang melihat data ini. Tidak '
            'tampil di publikasi, surat, pencarian jabatan lain atau laporan.',
          ),
        ]),
        BarisLentur(
          jarak: 8,
          anak: [
            Lentur(
              // The board's <a> is content-box: 150 and 340 plus padding 32
              // and line 3; min-height 48 likewise is 51 tall.
              dasar: 185,
              maks: 375,
              child: konfirmasi(
                RupaTombol(
                  label: 'Lihat konfirmasi keluarga',
                  isi: c.permukaan,
                  garis: GarisBorder.penuh(c.tinta, radius: 14),
                  warnaTeks: c.tinta,
                  radius: 14,
                  tinggi: 51,
                  paddingH: 16,
                ),
              ),
            ),
          ],
        ),
      ],
      'Meninggal dunia' => [
        _Kartu([
          const _Kepala(
            'Yohanis Rompas',
            'Meninggal dunia',
            BentukLencana.tinta,
          ),
          baris14('Kolom 2 · 03/02/1948 – 14/11/2026'),
          baris13(
            'Tidak pernah dihapus. Riwayat keluarga, jabatan, persembahan dan '
            'pelayanan tetap tersimpan. Akun dinonaktifkan, pemberitahuan '
            'dihentikan, dan jabatan Penatua Kolom 2 menjadi Jabatan kosong.',
          ),
        ]),
      ],
      'Penatua Kolom lain' => [
        const Penolakan(
          tindakan: 'Buka data anggota',
          sebab: 'Novita Wenas bukan anggota Kolom Anda.',
          jalan: [],
        ),
        baris13(
          'Penatua Kolom melihat data lengkap hanya untuk Kolomnya sendiri. '
          'Yang sudah diterbitkan tetap dapat dibaca di Warta Jemaat.',
        ),
      ],
      _ => [kisi],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < isi.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          isi[i],
        ],
      ],
    );
  }
}

/// Card (`dibukukan`, or `draf` dashed): padding 14 × 16, column gap 6.
class _Kartu extends StatelessWidget {
  const _Kartu(this.anak, {this.status = GarisStatus.dibukukan});

  final List<Widget> anak;
  final GarisStatus status;

  @override
  Widget build(BuildContext context) => Kartu(
    status: status,
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
}

/// Head row: title (wraps) and a badge that never shrinks, gap 16.
class _Kepala extends StatelessWidget {
  const _Kepala(
    this.judul,
    this.lencana,
    this.bentuk, {
    this.berat = FontWeight.w700,
  });

  final String judul, lencana;
  final BentukLencana bentuk;
  final FontWeight berat;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(judul, style: TextStyle(fontWeight: berat)),
      ),
      const SizedBox(width: 16),
      LencanaStatus(lencana, bentuk: bentuk),
    ],
  );
}

/// Info row 14: label `tinta2`, value right-aligned 600.
class _Info extends StatelessWidget {
  const _Info(this.label, this.nilai);

  final String label, nilai;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: const TextStyle(fontSize: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.warna.tinta2)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            nilai,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
