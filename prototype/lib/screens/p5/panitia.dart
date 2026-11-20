import 'package:flutter/widgets.dart';

import '../../core/format.dart';
import '../../mock/mock.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tahapan.dart';
import 'permintaan_dana_keadaan.dart';
import '../../app/layar.dart';

const _opsi = [
  'Perencanaan',
  'Aktif',
  'Penutupan keuangan',
  'Sisa uang',
  'Ditutup',
  'Diarsipkan',
];

/// Reached stages per view (spec 22): the current one is filled too.
const _selesai = {
  'Perencanaan': 1,
  'Aktif': 2,
  'Penutupan keuangan': 4,
  'Sisa uang': 4,
  'Ditutup': 5,
  'Diarsipkan': 6,
};

/// 89 · Panitia Natal 2026 (spec 22): six stages, switched from the panel only.
class PanitiaScreen extends StatelessWidget {
  const PanitiaScreen({super.key});

  @override
  Widget build(BuildContext context) => PapanKeadaan(
    stem: 'Panitia',
    opsi: _opsi,
    kepala: const KepalaPonsel(
      judul: 'Panitia Natal 2026',
      anakJudul: 'Unit sementara dengan peruntukannya sendiri',
      kembaliKe: Layar.beranda,
      labelKembali: 'Kembali ke Beranda',
    ),
    isi: (k, _) => [
      Tahapan(
        langkah: [for (final t in Panitia.tahap) t.split(' · ').last],
        selesai: _selesai[k]!,
      ),
      ..._isi(k),
    ],
  );
}

const _p = panitiaNatal;
const _t = panitiaPenutupan;

/// Text link 14/700 (an inline-flex `<a>`, min-height 44): start-aligned,
/// the target is as wide as its text.
Widget _teksTautan(String teks, {required Layar ke}) => Align(
  alignment: AlignmentDirectional.centerStart,
  child: Tautan(
    ke: ke,
    child: TautanTeks(teks, berat: FontWeight.w700, ukuran: 14),
  ),
);

/// Head row: title 700 and a mono 500 amount.
Widget _kepalaUang(String judul, String uang) => KepalaKartu(
  judul: judul,
  ujung: Text(
    uang,
    style: const TextStyle(
      fontFamily: PalakatText.mono,
      fontWeight: FontWeight.w500,
    ),
  ),
);

List<Widget> _isi(String k) => switch (k) {
  'Aktif' => [
    const _KartuPanitia(),
    KartuFakta(
      anak: [
        _kepalaUang(
          'Saldo buku peruntukan ${_p.peruntukan}',
          rp(panitiaSaldoAktif),
        ),
        const Keterangan(
          'Bendahara Panitia membukukan di peruntukan ini, pada '
          '$kasPanitiaNatal yang dikelolanya.',
        ),
      ],
    ),
  ],
  'Penutupan keuangan' => [
    KartuFakta(
      anak: [
        _kepalaUang(_t.sisa.$1, _t.sisa.$2),
        BarisFakta(
          _t.uangMuka.$1,
          _t.uangMuka.$2,
          mono: true,
          berat: FontWeight.w500,
        ),
        BarisFakta(_t.aset.$1, _t.aset.$2),
      ],
    ),
    const Penolakan(
      tindakan: 'Bukukan',
      sebab: 'Panitia Natal 2026 sedang dalam Penutupan keuangan.',
      jalan: [],
      ukuranTeks: 15,
    ),
    const Keterangan(
      'Sejak tahap ini Bendahara Panitia tidak membukukan transaksi biasa. '
      'Sisa uang dan aset harus punya tujuan yang disetujui.',
    ),
  ],
  'Sisa uang' => [
    KartuFakta(
      anak: [
        // One sans 700 string on the board (spec 22 Notes), not mono.
        KepalaLencana(
          '${_t.sisa.$1} ${_t.sisa.$2}',
          'Disetujui oleh ${_t.sisaDisetujuiOleh}',
          bentuk: BentukLencana.laut,
        ),
        BarisFakta('Tujuan', _t.sisaKe),
        Keterangan(
          'Tujuan sisa uang disetujui Bendahara Jemaat, ${_t.sisaPada}.',
        ),
      ],
    ),
    KartuFakta(
      anak: [
        const KepalaLencana(
          'Serah terima aset',
          'Diterbitkan',
          bentuk: BentukLencana.tinta,
        ),
        BarisPolos(
          'Dokumen gereja · Serah terima aset panitia · ${_t.asetKepada}',
        ),
        _teksTautan('Buka di Dokumen gereja', ke: Layar.dokumenGereja),
      ],
    ),
  ],
  'Ditutup' => [
    const KartuFakta(
      anak: [
        KepalaLencana(
          'Laporan pertanggungjawaban akhir',
          'Diterbitkan',
          bentuk: BentukLencana.tinta,
        ),
        Keterangan(
          'Peruntukan Panitia Natal bersaldo Rp0 dan dinonaktifkan untuk '
          'transaksi baru.',
        ),
      ],
    ),
  ],
  'Diarsipkan' => [
    const Catatan(
      status: GarisStatus.terpilih,
      tebal: 'Hanya baca.',
      sisa:
          'Panitia yang sudah diarsipkan tidak dihapus; riwayat keuangan dan '
          'dokumennya tetap dapat dibuka.',
    ),
  ],
  _ => [
    const _KartuPanitia(),
    const Keterangan(
      'Dibuat oleh Pimpinan Jemaat yang berwenang dari SK-nya. Hanya ia yang '
      'memindahkan tahap.',
    ),
    _teksTautan('Membentuk Panitia baru', ke: Layar.panitia),
  ],
};

/// Committee card: fact card without a badge.
class _KartuPanitia extends StatelessWidget {
  const _KartuPanitia();

  @override
  Widget build(BuildContext context) => KartuFakta(
    anak: [
      Text(_p.nama, style: const TextStyle(fontWeight: FontWeight.w700)),
      BarisFakta('Ketua', _p.ketua),
      BarisFakta('Sekretaris', _p.sekretaris),
      BarisFakta('Bendahara', _p.bendahara),
      BarisFakta('Peruntukan', _p.peruntukan),
      BarisFakta('Dasar', _p.dasar),
    ],
  );
}
