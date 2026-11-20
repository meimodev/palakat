import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_modul.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

const _hariT = '16/11/2026';
const _sebabSendiri =
    'ini data keluarga Anda sendiri. Diteruskan kepada Syamas Kolom 2.';

/// Queue of Kolom 2: title, second line, own refusal cause.
const _antre = [
  (
    'Permohonan menjadi anggota · Ferry Wenas',
    'Diajukan 14/11/2026 · izin data pribadi diberikan',
    '',
  ),
  ('Peristiwa: Sidi · Gabriela Rompas', 'Diajukan 12/11/2026', ''),
  ('Perubahan data · Keluarga Sumual', 'Diajukan 15/11/2026', _sebabSendiri),
];

/// 54 · Alur · Menjalankan jabatan kosong: list and start form change in place.
class AlurJabatanKosongScreen extends StatefulWidget {
  const AlurJabatanKosongScreen({super.key});

  @override
  State<AlurJabatanKosongScreen> createState() =>
      _AlurJabatanKosongScreenState();
}

class _AlurJabatanKosongScreenState extends State<AlurJabatanKosongScreen> {
  final _gulir = ScrollController();
  final _alasanTeks = TextEditingController();
  String _pesan = '';
  final _riw = <String>[];
  final _beres = <int>{};
  bool _mulai = false, _paham = false, _jalan = false;
  final _terisi = false;

  @override
  void dispose() {
    _gulir.dispose();
    _alasanTeks.dispose();
    super.dispose();
  }

  String _alasan() {
    if (_alasanTeks.text.trim().isEmpty) return 'alasan belum diisi.';
    if (!_paham) return 'pernyataan belum dicentang.';
    return '';
  }

  void _lihat(bool mulai, [VoidCallback? ubah]) {
    setState(() {
      ubah?.call();
      _mulai = mulai;
    });
    if (_gulir.hasClients) _gulir.jumpTo(0);
  }

  void _catat(String t) => _riw.insert(0, '$_hariT · $t');

  void _mulaiJalan() => _lihat(false, () {
    _jalan = true;
    _pesan = 'Anda menjalankan jabatan kosong Penatua Kolom 2 sejak $_hariT.';
    _catat(
      'Mulai menjalankan jabatan kosong Penatua Kolom 2 · alasan: ${_alasanTeks.text.trim()} · Yanti Sumual, Operator',
    );
  });

  @override
  Widget build(BuildContext context) {
    final body = _mulai ? _isiMulai(context) : _isiDaftar(context);
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Alur · Menjalankan jabatan kosong',
            anakJudul:
                'Operator menjalankan Penatua Kolom 2 sampai ada pemegangnya',
            kembaliKe: Layar.jabatanKosong,
            labelKembali: 'Kembali ke Menjalankan jabatan kosong',
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _gulir,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in body.indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    w,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuKosong(PalakatWarna c, List<Widget> isi) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaKartu(
          judul: 'Penatua Kolom 2',
          ujung: LencanaModul.jabatan(KeadaanJabatan.jabatanKosong),
        ),
        for (final w in isi) ...[const SizedBox(height: 6), w],
      ],
    ),
  );

  List<Widget> _isiDaftar(BuildContext context) {
    final c = context.warna;
    final belum = !_jalan && !_terisi;
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (belum) ...[
        _kartuKosong(c, [
          Text(
            'Kosong sejak 31/10/2026 · 3 data Kolom 2 menunggu verifikasi',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          Text(
            'Selama kosong, pekerjaan Kolom 2 tidak berjalan.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ]),
        BarisTombol(
          anak: [
            Tombol(
              'Jalankan jabatan kosong',
              jenis: JenisTombol.tinta,
              onPressed: () => _lihat(true, () => _pesan = ''),
            ),
          ],
        ),
      ],
      if (_jalan)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.tinta,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Anda menjalankan jabatan kosong Penatua Kolom 2.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual.',
                  style: TextStyle(color: c.diTinta2),
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.permukaan),
          ),
        ),
      if (_terisi)
        Kartu(
          status: GarisStatus.terpilih,
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Penatua Kolom 2 sudah terisi:',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' Pnt. Altje Rompas, sejak 16/11/2026. Anda tidak lagi menjalankan jabatan ini.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
      if (!belum) ...[
        Semantics(
          header: true,
          child: const Text(
            'Menunggu verifikasi · Kolom 2',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        for (final (i, a) in _antre.indexed) _butir(c, i, a),
        if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
      ],
      Text(
        'Menjalankan jabatan kosong tidak memberi wewenang atas data keluarga sendiri, dan berakhir sendiri begitu pemegang jabatan ditugaskan.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ];
  }

  Widget _butir(PalakatWarna c, int i, (String, String, String) a) {
    final b = _beres.contains(i);
    final bisa = _jalan && !b && a.$3.isEmpty;
    final tolak = !b && (a.$3.isNotEmpty || _terisi);
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaKartu(
            judul: a.$1,
            ujung: LencanaStatus(
              b ? 'Diverifikasi' : 'Diajukan',
              bentuk: b ? BentukLencana.laut : BentukLencana.garis,
            ),
          ),
          const SizedBox(height: 6),
          Text(a.$2, style: TextStyle(fontSize: 13, color: c.tinta3)),
          if (bisa) ...[
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Tombol(
                'Verifikasi data',
                jenis: JenisTombol.tinta,
                lebarPenuh: false,
                onPressed: () => setState(() {
                  _beres.add(i);
                  _catat(
                    'Memverifikasi ${a.$1} · oleh Yanti Sumual, Operator · menjalankan jabatan kosong Penatua Kolom 2',
                  );
                }),
              ),
            ),
          ],
          if (tolak) ...[
            const SizedBox(height: 6),
            Penolakan(
              tindakan: 'Verifikasi data',
              sebab: _terisi && a.$3.isEmpty
                  ? 'Anda tidak lagi menjalankan jabatan Penatua Kolom 2.'
                  : a.$3,
              jalan: const [],
              ukuranTeks: 14,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _isiMulai(BuildContext context) {
    final c = context.warna;
    final alasan = _alasan();
    final mulai = _alasanTeks.text.trim().isNotEmpty || _paham;
    return [
      _kartuKosong(c, [
        Text(
          'Anda akan menjalankan jabatan ini atas nama sendiri. Nama Anda, bukan nama jabatan, yang tercatat pada setiap tindakan.',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ]),
      IsianAlur(
        label: 'Alasan · wajib',
        controller: _alasanTeks,
        onChanged: (_) => setState(() {}),
        baris: 3,
      ),
      KotakCentang(
        nilai: _paham,
        onUbah: (v) => setState(() => _paham = v),
        jarakAtas: 2,
        label: Text(
          'Saya mengerti setiap tindakan saya tercatat sebagai dijalankan oleh Operator, dan jabatan ini kembali kepada pemegangnya begitu ditugaskan.',
          style: TextStyle(color: c.tinta),
        ),
      ),
      if (mulai && alasan.isNotEmpty)
        Penolakan(
          tindakan: 'Jalankan jabatan kosong',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Jalankan jabatan kosong',
            tindakan: 'Jalankan jabatan kosong',
            alasan: alasan,
            periksa: _alasan,
            sudahMulai: false,
            onPressed: _mulaiJalan,
          ),
          Tombol(
            'Batalkan',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _lihat(false, () => _pesan = ''),
          ),
        ],
      ),
    ];
  }
}
