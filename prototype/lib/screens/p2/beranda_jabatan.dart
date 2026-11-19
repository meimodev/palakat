import 'package:flutter/widgets.dart';

import '../../mock/mock.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/bertindak_sebagai.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import 'beranda_jabatan_isi.dart';

/// Row targets of `berandaJabatan`, per person, "Perlu tindakan" then
/// "Untuk diketahui" (the board's `hal()` with `web = false`).
const _tujuan = [
  [
    (ke: 'AntreanVerifikasi'),
    (ke: 'Ibadah'),
    (ke: 'PermintaanDana'),
    (ke: 'KonfirmasiKeluarga'),
  ],
  [(ke: 'Main'), (ke: 'SelesaikanUnit'), (ke: 'Main')],
  [
    (ke: 'Pengumuman'),
    (ke: 'PermohonanSurat'),
    (ke: 'WartaEditor'),
    (ke: 'Pengumuman'),
  ],
  [
    (ke: 'KonfirmasiKeluarga'),
    (ke: 'PermohonanSurat'),
    (ke: 'JabatanKosong'),
    (ke: 'ImporBuku'),
  ],
  [
    (ke: 'PermohonanSurat'),
    (ke: 'WartaArsip'),
    (ke: 'Pengumuman'),
    (ke: 'PersembahanSaya'),
  ],
];

/// 46 · Beranda: one combined Beranda for every post a person holds.
class BerandaJabatanScreen extends StatefulWidget {
  const BerandaJabatanScreen({super.key});

  @override
  State<BerandaJabatanScreen> createState() => _BerandaJabatanScreenState();
}

class _BerandaJabatanScreenState extends State<BerandaJabatanScreen>
    with KeadaanBeranda {
  @override
  String get stem => 'BerandaJabatan';

  @override
  Widget build(BuildContext context) {
    final ki = indeks(context);
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Beranda',
            anakJudul: 'Satu Beranda untuk semua jabatan Anda',
            kembaliKe: 'BerandaJabatan',
            labelKembali: 'Kembali ke Beranda',
            diSini: ulang,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: bersela(switch (ki) {
                  5 => isiOtomatis(context, go0),
                  6 => isiDuaJabatan(context, go0),
                  _ => _daftar(ki),
                }, 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _daftar(int ki) {
    final d = berandaJabatan[ki];
    final ke = _tujuan[ki];
    final semua = [...d.tindak, ...d.tahu];
    assert(() {
      for (final (i, r) in semua.indexed) {
        if (r.ke != ke[i].ke) return false;
      }
      return true;
    }(), 'BerandaJabatan row targets differ from berandaJabatan');
    Widget baris(int i) => _KartuBaris(semua[i], ke: ke[i].ke);
    return [
      DaftarJabatan(nama: d.orang, jabatan: d.jabatan),
      if (d.tindak.isNotEmpty) ...[
        const JudulBagian('Perlu tindakan'),
        for (var i = 0; i < d.tindak.length; i++) baris(i),
      ],
      if (d.tahu.isNotEmpty) ...[
        const JudulBagian('Untuk diketahui'),
        for (var i = d.tindak.length; i < semua.length; i++) baris(i),
      ],
      const Keterangan(kalimatBeranda),
      const Tautan(
        ke: 'AkunSaya',
        child: SizedBox(
          height: 44,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TautanTeks('Akun saya', berat: FontWeight.w700, ukuran: 14),
          ),
        ),
      ),
    ];
  }
}

/// The row card (shared look with KotakMasuk): a full-width link.
class _KartuBaris extends StatelessWidget {
  const _KartuBaris(this.r, {required this.ke});
  final ItemKotak r;
  final String ke;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final lencana = lencanaBaris(r);
    return Tautan(
      ke: ke,
      radius: 14,
      child: Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.judul,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.sub,
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
              if (lencana != null) ...[const SizedBox(width: 12), lencana],
              const SizedBox(width: 12),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ),
        ),
      ),
    );
  }
}
