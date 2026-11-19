import 'package:flutter/material.dart';

import '../../shell/perangkat_prototipe.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'alur_anggota_bagian.dart';

/// 82 · Alur · Menjadi anggota (21-aluranggota.md): Novita Wenas asks to
/// become a member; the Penatua Kolom 7 verifies or returns it.
class AlurAnggotaScreen extends StatefulWidget {
  const AlurAnggotaScreen({super.key});

  @override
  State<AlurAnggotaScreen> createState() => _AlurAnggotaState();
}

class _AlurAnggotaState extends State<AlurAnggotaScreen> {
  static const _judul = 'Permohonan menjadi anggota';

  final _nama = TextEditingController();
  final _lahir = TextEditingController();
  final _alasan = TextEditingController();

  String _pesan = '', _v = 'isi', _akt = 'Pemohon';
  String _jk = '', _nikah = '', _kolom = '', _st = '', _kembali = '';
  bool _izin = false, _sentuh = false;
  List<String> _riw = const [];

  @override
  void dispose() {
    _nama.dispose();
    _lahir.dispose();
    _alasan.dispose();
    super.dispose();
  }

  void _catat(String t) => _riw = ['$hariIniTeks · $_judul $t', ..._riw];

  String get _kolomAtau => _kolom.isEmpty ? 'Kolom 7' : _kolom;

  /// First unmet reason of "Ajukan", from the latest input.
  String _alasanAjukan() {
    final t = tglAlur(_lahir.text);
    if (_nama.text.trim().isEmpty) return 'nama belum diisi.';
    if (t == null) return 'tanggal lahir tidak dikenali. Contoh: 14/03/1996.';
    if (t >= hariIni) return 'tanggal lahir harus sebelum hari ini.';
    if (_jk.isEmpty) return 'jenis kelamin belum dipilih.';
    if (_nikah.isEmpty) return 'status pernikahan belum dipilih.';
    if (_kolom.isEmpty) return 'Kolom belum dipilih.';
    if (!_izin) return 'izin penggunaan data pribadi belum diberikan.';
    return '';
  }

  /// Age in completed years on 16/11/2026, or null when no category shows.
  int? get _umur {
    final t = tglAlur(_lahir.text);
    if (t == null || t >= hariIni || _jk.isEmpty || _nikah.isEmpty) {
      return null;
    }
    return (hariIni - t) ~/ 10000;
  }

  String _bipra(int u) => _nikah == 'Sudah menikah'
      ? (_jk == 'Laki-laki' ? 'Bapa' : 'Ibu')
      : (u < 12 ? 'Anak' : (u < 18 ? 'Remaja' : 'Pemuda'));

  void _ajukan() => setState(() {
    _st = 'Diajukan';
    _v = 'isi';
    _pesan = 'Diajukan. Penatua $_kolomAtau diberi tahu lewat Pemberitahuan.';
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
    jarakBaris: 0,
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
    final antre = _st == 'Diajukan' && _kolomAtau == 'Kolom 7';
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
                ? 'Aktif sejak $hariIniTeks · Diverifikasi Pnt. Hendrik Rumagit'
                : 'Diajukan $hariIniTeks · menunggu Penatua $_kolomAtau',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ]),
        keteranganAlur(context, tidakTampil),
        if (_st == 'Diverifikasi')
          // An <a> is content-box on the board: max-width 340 plus padding
          // and line exceed 350, so it fills the row.
          const Tombol(
            'Atur Tampilan nama saya',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            ke: 'AlurNama',
          ),
      ];
    } else if (antre && _v != 'kembali') {
      tampilan = 'antre';
      final u = _umur;
      isi = [
        kartuAlur([
          KepalaKartu(judul: _judul, ujung: lencanaSt('Diajukan')),
          BarisInfo('Nama', _nama.text),
          BarisInfo('Tanggal lahir', _lahir.text),
          BarisInfo('Status pernikahan', _nikah),
          BarisInfo('Kategori BIPRA', u == null ? '' : _bipra(u)),
          BarisInfo('Kolom', _kolom),
          const BarisInfo('Izin data pribadi', 'Diberikan · naskah versi 1'),
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
          _st == 'Diajukan'
              ? 'Pengajuan ini ditujukan ke $_kolom; hanya Penatua Kolom itu yang melihatnya.'
              : (_st == 'Diverifikasi'
                    ? 'Sudah Diverifikasi.'
                    : 'Pengajuan dari Kolom 7 akan muncul di sini.'),
        ),
      ];
    }
    return AlatPrototipe(
      stem: 'AlurAnggota',
      alat: [
        DilihatSebagai(
          pilihan: aktorAlur,
          terpilih: _akt,
          onPilih: (a) => setState(() {
            _akt = a;
            _pesan = '';
          }),
        ),
      ],
      child: KerangkaAlur(
        kembaliKe: 'DataAnggota',
        judul: 'Alur · Menjadi anggota',
        anakJudul: 'Dari mengisi sendiri sampai Diverifikasi Penatua Kolom',
        tampilan: tampilan,
        blok: [
          if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
          ...isi,
          if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
        ],
      ),
    );
  }

  List<Widget> _formulir(PalakatWarna c) {
    final alasan = _alasanAjukan();
    final u = _umur;
    return [
      if (_st == 'Dikembalikan') CatatanDikembalikan(_kembali),
      IsianAlur(
        label: 'Nama lengkap',
        controller: _nama,
        petunjuk: 'Nama sesuai surat baptis',
        onChanged: (_) => setState(() => _sentuh = true),
      ),
      IsianAlur(
        label: 'Tanggal lahir',
        controller: _lahir,
        petunjuk: 'hh/bb/tttt',
        keterangan: 'Contoh: 14/03/1996.',
        onChanged: (_) => setState(() => _sentuh = true),
      ),
      _pil('Jenis kelamin', ['Perempuan', 'Laki-laki'], _jk, (n) => _jk = n),
      _pil(
        'Status pernikahan',
        ['Belum pernah menikah', 'Sudah menikah'],
        _nikah,
        (n) => _nikah = n,
      ),
      if (u != null)
        kartuAlur([
          KepalaKartu(
            judul: 'Kategori BIPRA',
            // The board's `terpilih` line: 1.5 tinta, tinta text, on white.
            ujung: LencanaStatus(_bipra(u), bentuk: BentukLencana.peran),
          ),
          Text(
            'Dasar: $u tahun pada $hariIniTeks, ${_nikah.toLowerCase()}. '
            'Dihitung sendiri; berubah sendiri saat umur atau status pernikahan berubah.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ]),
      _pil('Kolom', ['Kolom 7', 'Kolom 4'], _kolom, (n) => _kolom = n),
      kartuAlur([
        const Text(
          'Izin penggunaan data pribadi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
          'Naskah bawaan · versi 1 · 12/11/2026',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
        Text(
          'Data ini dipakai Jemaat Karunia untuk pelayanan, surat dan Warta Jemaat. '
          'Nama saya di publikasi mengikuti Tampilan nama yang saya pilih. '
          'Saya dapat mencabut izin dan meminta data saya dihapus.',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        KotakCentang(
          nilai: _izin,
          onUbah: (v) => setState(() => _izin = v),
          label: const Text('Saya memberi izin penggunaan data pribadi saya.'),
        ),
      ]),
      if (_sentuh && alasan.isNotEmpty)
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
