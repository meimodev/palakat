import 'package:flutter/material.dart';

import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'alur_anggota_bagian.dart';
import '../../app/layar.dart';

/// 83 · Alur · Peristiwa (21-aluranggota.md): Novita Wenas reports a life
/// event with its letter; the Penatua Kolom 7 verifies or returns it.
class AlurPeristiwaScreen extends StatefulWidget {
  const AlurPeristiwaScreen({super.key});

  @override
  State<AlurPeristiwaScreen> createState() => _AlurPeristiwaState();
}

class _AlurPeristiwaState extends State<AlurPeristiwaScreen> {
  static const _judul = 'Peristiwa';

  final _tanggal = TextEditingController();
  final _alasan = TextEditingController();

  String _pesan = '', _v = 'isi';
  final _akt = 'Pemohon';
  String _jenis = '', _untuk = '', _st = '', _kembali = '';
  bool _sentuh = false, _file = false;
  List<String> _riw = const [];

  @override
  void dispose() {
    _tanggal.dispose();
    _alasan.dispose();
    super.dispose();
  }

  void _catat(String t) => _riw = ['$hariIniTeks · $_judul $t', ..._riw];

  /// First unmet reason of "Ajukan", from the latest input.
  String _alasanAjukan() {
    final t = tglAlur(_tanggal.text);
    if (_jenis.isEmpty) return 'jenis peristiwa belum dipilih.';
    if (_untuk.isEmpty) return 'orangnya belum dipilih.';
    if (t == null) {
      return 'tanggal peristiwa tidak dikenali. Contoh: 08/11/2026.';
    }
    if (t > hariIni) return 'tanggal peristiwa belum tiba.';
    if (!_file) return 'surat atau piagam belum terlampir.';
    return '';
  }

  void _ajukan() => setState(() {
    _st = 'Diajukan';
    _v = 'isi';
    _pesan = 'Diajukan. Penatua Kolom 7 diberi tahu lewat Pemberitahuan.';
    _catat('diajukan · Novita Wenas');
  });

  void _verif() => setState(() {
    _st = 'Diverifikasi';
    _pesan = '';
    _catat('Diverifikasi · Pnt. Hendrik Rumagit, Penatua Kolom 7');
  });

  void _kembalikan() => setState(() {
    final al = _alasan.text.trim();
    _st = 'Dikembalikan';
    _v = 'isi';
    _kembali = al;
    _alasan.clear();
    _pesan = '';
    _catat('dikembalikan · alasan: $al · Pnt. Hendrik Rumagit');
  });

  void _ke(String v) => setState(() {
    _v = v;
    _pesan = '';
    if (v == 'kembali') _alasan.clear();
  });

  Widget _pil(
    String label,
    List<String> a,
    String nilai,
    ValueChanged<String> set,
  ) => ChipPilihan<String>(
    label: label,
    jarakLabel: 6,
    jarakBawah: 0,
    pilihan: [for (final n in a) (nilai: n, teks: n)],
    terpilih: nilai,
    onPilih: (n) => setState(() {
      set(n);
      _pesan = '';
    }),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pem = _akt == 'Pemohon';
    final antre = _st == 'Diajukan';
    final String tampilan;
    final List<Widget> isi;
    if (pem && (_st.isEmpty || _st == 'Dikembalikan')) {
      tampilan = 'isi';
      isi = _formulir(c);
    } else if (pem) {
      tampilan = 'status';
      isi = [
        kartuAlur([
          KepalaKartu(judul: _judul, ujung: lencanaSt(_st)),
          Text(
            _st == 'Diverifikasi'
                ? 'Diverifikasi $hariIniTeks · dapat masuk Warta Jemaat; nama mengikuti Tampilan nama keluarga'
                : 'Diajukan $hariIniTeks · menunggu Penatua Kolom 7',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ]),
        keteranganAlur(context, tidakTampil),
      ];
    } else if (antre && _v != 'kembali') {
      tampilan = 'antre';
      isi = [
        kartuAlur([
          KepalaKartu(judul: _judul, ujung: lencanaSt('Diajukan')),
          BarisInfo('Jenis', _jenis),
          BarisInfo('Untuk', _untuk),
          BarisInfo('Tanggal peristiwa', _tanggal.text),
          const BarisInfo('Lampiran', '1 file'),
        ]),
        keteranganAlur(context, hanyaKolom7),
        tombolPenatua(verif: _verif, keKembali: () => _ke('kembali')),
      ];
    } else if (antre) {
      tampilan = 'kembali';
      isi = formKembali(
        judul: _judul,
        alasan: _alasan,
        onUbah: () => setState(() {}),
        kembalikan: _kembalikan,
        batal: () => _ke('isi'),
      );
    } else {
      tampilan = 'kosong';
      isi = [
        kotakKosong(
          context,
          _st == 'Diverifikasi'
              ? 'Sudah Diverifikasi.'
              : 'Pengajuan dari Kolom 7 akan muncul di sini.',
        ),
      ];
    }
    return KerangkaAlur(
      kembaliKe: Layar.dataAnggota,
      judul: 'Alur · Peristiwa',
      anakJudul: 'Dari mengajukan sampai Diverifikasi dan boleh masuk Warta',
      tampilan: tampilan,
      blok: [
        if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
        ...isi,
        if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
      ],
    );
  }

  List<Widget> _formulir(PalakatWarna c) {
    final alasan = _alasanAjukan();
    final mulai = _sentuh || _file || _jenis.isNotEmpty || _untuk.isNotEmpty;
    return [
      if (_st == 'Dikembalikan') CatatanDikembalikan(_kembali),
      _pil(
        'Jenis peristiwa',
        ['Baptisan', 'Sidi', 'Pernikahan'],
        _jenis,
        (n) => _jenis = n,
      ),
      if (_jenis == 'Pernikahan')
        Text(
          'Setelah Diverifikasi, Kategori BIPRA kedua mempelai menjadi Bapa dan Ibu sejak tanggal pernikahan.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      _pil(
        'Untuk siapa',
        ['Gabriel Wenas (anak)', 'Saya sendiri'],
        _untuk,
        (n) => _untuk = n,
      ),
      IsianAlur(
        label: 'Tanggal peristiwa',
        controller: _tanggal,
        petunjuk: 'hh/bb/tttt',
        keterangan: 'Tanggal yang tertulis di suratnya.',
        onChanged: (_) => setState(() => _sentuh = true),
      ),
      kartuAlur([
        KepalaKartu(
          judul: 'Surat atau piagam',
          ujung: _file
              ? const LencanaStatus('Terlampir', bentuk: BentukLencana.garis)
              : const LencanaStatus(
                  'Wajib, belum ada',
                  bentuk: BentukLencana.bata,
                ),
        ),
        if (_file)
          Text(
            '1 file terlampir',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          )
        else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Tombol(
              'Pilih file',
              onPressed: () => setState(() => _file = true),
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              lebarPenuh: false,
            ),
          ),
      ], status: GarisStatus.draf),
      if (mulai && alasan.isNotEmpty)
        Penolakan(
          tindakan: 'Ajukan',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Ajukan',
            tindakan: 'Ajukan',
            alasan: alasan,
            periksa: _alasanAjukan,
            sudahMulai: false,
            onPressed: _ajukan,
          ),
        ],
      ),
    ];
  }
}
