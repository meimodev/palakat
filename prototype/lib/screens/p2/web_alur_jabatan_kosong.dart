import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/actor.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/pita_jabatan_kosong.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

/// Web · Alur · Menjalankan jabatan kosong (screens/15-cariorang.md): the
/// Operator Yanti Sumual runs the vacant post Penatua Kolom 2 on her laptop.
/// Views `daftar` and `mulai` change in place.
class WebAlurJabatanKosongScreen extends ConsumerStatefulWidget {
  const WebAlurJabatanKosongScreen({super.key});

  @override
  ConsumerState<WebAlurJabatanKosongScreen> createState() =>
      _WebAlurJabatanKosongScreenState();
}

const _hariT = '16/11/2026';
const _jk = 'menjalankan jabatan kosong Penatua Kolom 2';

/// Queue: title, second line, own refusal cause ('' = none).
const _antre = [
  (
    'Permohonan menjadi anggota · Ferry Wenas',
    'Diajukan 14/11/2026 · izin data pribadi diberikan',
    '',
  ),
  ('Peristiwa: Sidi · Gabriela Rompas', 'Diajukan 12/11/2026', ''),
  (
    'Perubahan data · Keluarga Sumual',
    'Diajukan 15/11/2026',
    'ini data keluarga Anda sendiri. Diteruskan kepada Syamas Kolom 2.',
  ),
];

class _WebAlurJabatanKosongScreenState
    extends ConsumerState<WebAlurJabatanKosongScreen> {
  String _pesan = '', _v = 'daftar';
  List<String> _riw = [];
  bool _paham = false, _jalan = false;
  final _terisi = false;
  final List<int> _beres = [];
  final _alasanIsi = TextEditingController();
  final _kunci = GlobalKey();

  @override
  void dispose() {
    _alasanIsi.dispose();
    super.dispose();
  }

  String get _al => _alasanIsi.text.trim();

  String _alasan() => _al.isEmpty
      ? 'alasan belum diisi.'
      : (!_paham ? 'pernyataan belum dicentang.' : '');

  void _catat(String t) => _riw = ['$_hariT · $t', ..._riw];

  void _ke(String v) {
    final ctx = _kunci.currentContext;
    if (ctx != null) Scrollable.maybeOf(ctx)?.position.jumpTo(0);
    _v = v;
    _pesan = '';
  }

  void _mulaiJalan() => setState(() {
    final al = _al;
    _ke('daftar');
    _jalan = true;
    _pesan = 'Anda menjalankan jabatan kosong Penatua Kolom 2 sejak $_hariT.';
    _catat(
      'Mulai menjalankan jabatan kosong Penatua Kolom 2 · alasan: $al · '
      'Yanti Sumual, Operator',
    );
  });

  void _verifikasi(int i) => setState(() {
    _beres.add(i);
    _catat(
      'Memverifikasi ${_antre[i].$1} · oleh Yanti Sumual, Operator · $_jk',
    );
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 7),
      isi: [
        Column(
          key: _kunci,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The 44 px target overlaps the line above and below, so the
            // block keeps the board's line (the 14 px link sits on the
            // div's 15 × 1.45 strut).
            MarginNegatif(
              atas: (44 - 15 * 1.45) / 2,
              bawah: (44 - 15 * 1.45) / 2,
              child: Tautan(
                ke: Layar.jabatanKosong,
                cara: Cara.naik,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: TautanTeks('Menjalankan jabatan kosong', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: Text(
                'Alur · Menjalankan jabatan kosong',
                style: PalakatText.judulHalaman.copyWith(color: c.tinta),
              ),
            ),
            Text(
              'Operator menjalankan Penatua Kolom 2 sampai ada pemegangnya',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: _v == 'mulai' ? _mulai(context) : _daftar(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _kosong(BuildContext context, String baris2, [String? baris3]) {
    final c = context.warna;
    return Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          const KepalaKartu(
            judul: 'Penatua Kolom 2',
            ujung: LencanaStatus('Jabatan kosong', bentuk: BentukLencana.bata),
          ),
          Text(baris2, style: TextStyle(fontSize: 14, color: c.tinta2)),
          if (baris3 != null)
            Text(baris3, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
      ),
    );
  }

  List<Widget> _daftar(BuildContext context) {
    final c = context.warna;
    final belum = !_jalan && !_terisi;
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (belum) ...[
        _kosong(
          context,
          'Kosong sejak 31/10/2026 · 3 data Kolom 2 menunggu verifikasi',
          'Selama kosong, pekerjaan Kolom 2 tidak berjalan.',
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Jalankan jabatan kosong',
              jenis: JenisTombol.tinta,
              onPressed: () => setState(() => _ke('mulai')),
            ),
          ],
        ),
      ],
      // The board's running banner has no role="status" (spec 15).
      if (_jalan)
        PitaJabatanKosong.web(
          jabatan: 'Penatua Kolom 2',
          sejak: null,
          operator: ref.watch(jalanJabatanProvider('penatua-kolom-2')).operator,
          siaran: false,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  text:
                      ' Pnt. Altje Rompas, sejak 16/11/2026. Anda tidak lagi '
                      'menjalankan jabatan ini.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
      if (!belum)
        BarisLentur(
          jarak: 28,
          jarakBaris: 20,
          anak: [
            Lentur(
              dasar: 420,
              tumbuh: 1.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  _h2('Menunggu verifikasi · Kolom 2'),
                  for (var i = 0; i < _antre.length; i++) _butir(context, i),
                ],
              ),
            ),
            Lentur(dasar: 340, child: RiwayatAlur(baris: _riw, jarak: 12)),
          ],
        ),
      Text(
        'Menjalankan jabatan kosong tidak memberi wewenang atas data keluarga '
        'sendiri, dan berakhir sendiri begitu pemegang jabatan ditugaskan.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ];
  }

  Widget _h2(String t) => Semantics(
    header: true,
    child: Text(
      t,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );

  Widget _butir(BuildContext context, int i) {
    final c = context.warna;
    final (judul, baris2, sebab) = _antre[i];
    final b = _beres.contains(i);
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          KepalaKartu(
            judul: judul,
            ujung: LencanaStatus(
              b ? 'Diverifikasi' : 'Diajukan',
              bentuk: b ? BentukLencana.laut : BentukLencana.garis,
            ),
          ),
          Text(baris2, style: TextStyle(fontSize: 13, color: c.tinta3)),
          if (_jalan && !b && sebab.isEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Tombol(
                'Verifikasi data',
                jenis: JenisTombol.tinta,
                lebarPenuh: false,
                onPressed: () => _verifikasi(i),
              ),
            ),
          if (!b && (sebab.isNotEmpty || _terisi))
            Penolakan(
              tindakan: 'Verifikasi data',
              sebab: _terisi && sebab.isEmpty
                  ? 'Anda tidak lagi menjalankan jabatan Penatua Kolom 2.'
                  : sebab,
              jalan: const [],
              ukuranTeks: 14,
            ),
        ],
      ),
    );
  }

  List<Widget> _mulai(BuildContext context) {
    final alasan = _alasan();
    return [
      _kosong(
        context,
        'Anda akan menjalankan jabatan ini atas nama sendiri. Nama Anda, '
        'bukan nama jabatan, yang tercatat pada setiap tindakan.',
      ),
      IsianAlur(
        label: 'Alasan · wajib',
        controller: _alasanIsi,
        onChanged: (_) => setState(() {}),
        baris: 3,
      ),
      KotakCentang(
        nilai: _paham,
        onUbah: (v) => setState(() => _paham = v),
        jarakAtas: 2,
        label: const Text(
          'Saya mengerti setiap tindakan saya tercatat sebagai dijalankan oleh '
          'Operator, dan jabatan ini kembali kepada pemegangnya begitu '
          'ditugaskan.',
        ),
      ),
      if ((_al.isNotEmpty || _paham) && alasan.isNotEmpty)
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
            onPressed: () => setState(() => _ke('daftar')),
          ),
        ],
      ),
    ];
  }
}
