import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/sakelar.dart';
import '../../widgets/tekan.dart';

/// 26 · Pemberitahuan: the in-app notification list with per-type switches
/// (D28, C06). The list and switches are shared with WebPemberitahuan.
class PemberitahuanScreen extends StatefulWidget {
  const PemberitahuanScreen({super.key});

  @override
  State<PemberitahuanScreen> createState() => _PemberitahuanScreenState();
}

class _PemberitahuanScreenState extends State<PemberitahuanScreen>
    with PemberitahuanLogika {
  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: LayarPonsel(
      jabatanKosong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Pemberitahuan',
            kembaliKe: 'Main',
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CatatanPemberitahuan(),
                  const SizedBox(height: 16),
                  barisBelumDibaca(),
                  const SizedBox(height: 16),
                  kartuDaftar(),
                  const SizedBox(height: 16),
                  judulDitampilkan,
                  const SizedBox(height: 16),
                  kartuJenis(),
                  const SizedBox(height: 16),
                  keteranganJenis(context),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

typedef _Notif = ({
  String id,
  String jenis,
  String judul,
  String ket,
  String waktu,
});

const List<_Notif> _daftar = [
  (
    id: 'n1',
    jenis: 'tindak',
    judul: 'Oktober 2026 belum ditutup',
    ket: '1 hambatan · bulan berikutnya untuk tutup buku',
    waktu: 'Hari ini 08.00',
  ),
  (
    id: 'n2',
    jenis: 'file',
    judul: 'File Excel laporan gagal dibuat',
    ket: 'Laporan resmi September 2026 · cukup dibuat lagi',
    waktu: 'Hari ini 07.42',
  ),
  (
    id: 'n3',
    jenis: 'tempo',
    judul: 'Uang muka lewat jatuh tempo',
    ket: 'Retret Pemuda · sisa Rp500.000 · jatuh tempo 10/11/2026',
    waktu: '11/11/2026',
  ),
  (
    id: 'n4',
    jenis: 'tindak',
    judul: '1 dokumen pendukung wajib, belum ada',
    ket: 'BKU-2026-0143 · Sewa sound system',
    waktu: '11/11/2026',
  ),
  (
    id: 'n5',
    jenis: 'ai',
    judul: 'AI sedang tidak tersedia',
    ket: 'Pencatatan berjalan seperti biasa',
    waktu: '09/11/2026',
  ),
];

const List<({String kunci, String nama, String ket})> _jenis = [
  (
    kunci: 'tindak',
    nama: 'Perlu tindakan',
    ket: 'Hambatan, draf, dokumen pendukung',
  ),
  (kunci: 'tempo', nama: 'Jatuh tempo', ket: 'Uang muka dan titipan'),
  (kunci: 'file', nama: 'File laporan', ket: 'Siap diunduh atau gagal dibuat'),
  (kunci: 'ai', nama: 'Bantuan AI', ket: 'Tidak tersedia, batas biaya'),
];

/// The board's logic class: state `baca` / `atur` and handlers `buka`,
/// `semua`, `pick`, with the parts both boards draw from them.
mixin PemberitahuanLogika<T extends StatefulWidget> on State<T> {
  final Set<String> _baca = {};
  final Map<String, bool> _atur = {
    'tindak': true,
    'tempo': true,
    'file': true,
    'ai': false,
  };

  List<_Notif> get _tampil => [
    for (final n in _daftar)
      if (_atur[n.jenis]!) n,
  ];

  /// "Belum dibaca · n" with "Tandai semua dibaca".
  Widget barisBelumDibaca() {
    final c = context.warna;
    final n = _tampil.where((x) => !_baca.contains(x.id)).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 16,
      children: [
        Text(
          'Belum dibaca · $n',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        Flexible(
          child: Tekan(
            // Marks all five read, the hidden ones too.
            onTap: () => setState(() => _baca.addAll(_daftar.map((x) => x.id))),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  'Tandai semua dibaca',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.laut,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The list card, or its empty line when every type is off.
  Widget kartuDaftar() {
    final c = context.warna;
    final baris = _tampil;
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < baris.length; i++)
            _barisNotif(c, baris[i], pertama: i == 0),
          if (baris.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'Semua jenis pemberitahuan dimatikan.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _barisNotif(PalakatWarna c, _Notif n, {required bool pertama}) {
    final dibaca = _baca.contains(n.id);
    return Tekan(
      onTap: () => setState(() => _baca.add(n.id)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: pertama ? null : Border(top: BorderSide(color: c.garis)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dibaca ? null : c.laut,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.judul,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: dibaca ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  Text(n.ket, style: TextStyle(fontSize: 13, color: c.tinta3)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              n.waktu,
              softWrap: false,
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
      ),
    );
  }

  Widget get judulDitampilkan => const Text(
    'Yang ditampilkan',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );

  /// The four type switches.
  Widget kartuJenis() {
    final c = context.warna;
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _jenis.length; i++)
            Container(
              constraints: const BoxConstraints(minHeight: 60),
              decoration: BoxDecoration(
                border: i == 0 ? null : Border(top: BorderSide(color: c.garis)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _jenis[i].nama,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _jenis[i].ket,
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Sakelar(
                    nilai: _atur[_jenis[i].kunci]!,
                    label: 'Pemberitahuan ${_jenis[i].nama}',
                    onUbah: (v) => setState(() => _atur[_jenis[i].kunci] = v),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget keteranganJenis(BuildContext context) => Text(
    'Mematikan pemberitahuan tidak menyembunyikan hambatan: semuanya tetap '
    'ada di Beranda dan di kesiapan tutup buku.',
    style: TextStyle(fontSize: 13, color: context.warna.tinta3),
  );
}

/// The draf note "Hanya di dalam aplikasi."
class CatatanPemberitahuan extends StatelessWidget {
  const CatatanPemberitahuan({super.key});

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 14),
        children: [
          const TextSpan(
            text: 'Hanya di dalam aplikasi.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text:
                'Beranda sudah memuat semuanya di “Perlu tindakan”. Ini hanya '
                'daftar di dalam aplikasi: tanpa WhatsApp, SMS, email, atau '
                'pemberitahuan ke layar kunci. Kotak Pemberitahuan untuk semua '
                'modul ada di Putaran 2, dan pemberitahuan dorong lewat '
                'Firebase Cloud Messaging di Putaran 5.',
            style: TextStyle(color: context.warna.tinta2),
          ),
        ],
      ),
    ),
  );
}
