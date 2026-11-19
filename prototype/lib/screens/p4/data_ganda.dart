import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

const _stem = 'DataGanda';
const _bandingkan = 'Bandingkan',
    _gabungkan = 'Gabungkan',
    _bukan = 'Bukan orang yang sama';

/// 80 · Kemungkinan data ganda (spec 20, DataGanda).
class DataGandaScreen extends StatefulWidget {
  const DataGandaScreen({super.key});

  @override
  State<DataGandaScreen> createState() => _DataGandaScreenState();
}

class _DataGandaScreenState extends State<DataGandaScreen> {
  final _gulir = ScrollController();
  String? _k;
  String? _keadaan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final keadaan = context.tweak<String>(_stem, 'keadaan');
    // Board parity (CONVENTIONS, settled conflicts): a panel change does not
    // reset k; it changes the view only while k is null.
    if (_keadaan != null && keadaan != _keadaan && _k == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _keAtas());
    }
    _keadaan = keadaan;
  }

  void _keAtas() {
    if (mounted && _gulir.hasClients) _gulir.jumpTo(0);
  }

  void _ke(String k) {
    setState(() => _k = k);
    _keAtas();
  }

  @override
  void dispose() {
    _gulir.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _k ?? _keadaan!;
    const kuat = TextStyle(fontWeight: FontWeight.w700);
    Widget kartu(String status, BentukLencana bentuk, String asal) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          KepalaKartu(
            judul: 'Novita Wenas',
            ujung: LencanaStatus(status, bentuk: bentuk),
          ),
          const BarisInfo('Tanggal lahir', '14/03/1996'),
          const BarisInfo('Kolom', 'Kolom 7'),
          BarisInfo('Asal data', asal),
        ],
      ),
    );

    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Kemungkinan data ganda',
            anakJudul: 'Bandingkan dulu; tidak pernah digabung sendiri',
            kembaliKe: 'DataAnggota',
            labelKembali: 'Kembali ke Data jemaat',
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _gulir,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  KisiOtomatis(
                    minLebar: 300,
                    jarak: 16,
                    anak: [
                      kartu(
                        'Aktif',
                        BentukLencana.laut,
                        'Permohonan menjadi anggota',
                      ),
                      kartu(
                        'Belum dikonfirmasi',
                        BentukLencana.draf,
                        'Buku anggota · baris 23',
                      ),
                    ],
                  ),
                  if (k == _bandingkan)
                    BarisTombol(
                      anak: [
                        Tombol(
                          'Gabungkan',
                          onPressed: () => _ke(_gabungkan),
                          jenis: JenisTombol.tinta,
                        ),
                        Tombol(
                          'Bukan orang yang sama',
                          onPressed: () => _ke(_bukan),
                          jenis: JenisTombol.kedua,
                          ukuran: UkuranTombol.sedang,
                        ),
                      ],
                    ),
                  if (k == _gabungkan) ...[
                    const Pesan(
                      siaran: false,
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Digabungkan menjadi satu orang.',
                              style: kuat,
                            ),
                            TextSpan(
                              text:
                                  ' Riwayat keuangan, jabatan, keluarga, '
                                  'pelayanan dan Riwayat aktivitas keduanya '
                                  'tetap ada.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'Oleh Yanti Sumual, Operator · 17/11/2026 09.20',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                  if (k == _bukan)
                    const Kartu(
                      status: GarisStatus.terpilih,
                      radius: 12,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Ditandai: bukan orang yang sama.',
                              style: kuat,
                            ),
                            TextSpan(
                              text:
                                  ' Keduanya tetap sebagai dua orang dan '
                                  'tidak ditawarkan lagi sebagai data ganda.',
                            ),
                          ],
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
