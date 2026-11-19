import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

const _hari = 20261116, _hariT = '16/11/2026';
const _aktif = 'Aktif',
    _tutupKeu = 'Penutupan keuangan',
    _ditutup = 'Ditutup',
    _arsip = 'Diarsipkan';

/// The board's `tgl`: exactly dd/mm/yyyy after trimming, as yyyymmdd.
int? _tgl(String t) {
  final m = RegExp(r'^(\d\d)/(\d\d)/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), b = int.parse(m[2]!);
  if (b < 1 || b > 12 || d < 1 || d > 31) return null;
  return int.parse(m[3]!) * 10000 + b * 100 + d;
}

/// 97 · Alur · Panitia: closing Panitia Natal 2026 (23-alurunit.md).
class AlurPanitiaScreen extends StatefulWidget {
  const AlurPanitiaScreen({super.key});

  @override
  State<AlurPanitiaScreen> createState() => _AlurPanitiaScreenState();
}

class _AlurPanitiaScreenState extends State<AlurPanitiaScreen> {
  final _tglST = TextEditingController();
  var _st = _aktif;
  var _um = false, _sisa = false, _file = false;
  final _riw = <String>[];

  @override
  void dispose() {
    _tglST.dispose();
    super.dispose();
  }

  void _catat(String t) => _riw.insert(0, '$_hariT · $t');

  /// First unmet reason for "Tutup Panitia", from the latest input.
  String _alasan() {
    if (!_um) return 'masih ada Uang Muka yang belum dipertanggungjawabkan.';
    if (!_sisa) return 'sisa uang Panitia belum dikembalikan.';
    final t = _tgl(_tglST.text);
    if (_tglST.text.trim().isNotEmpty && t == null) {
      return 'tanggal serah terima tidak dikenali. Contoh: 16/11/2026.';
    }
    if (t != null && t > _hari) return 'tanggal serah terima belum tiba.';
    return '';
  }

  void _mulaiTutup() => setState(() {
    _st = _tutupKeu;
    _catat(
      'Penutupan keuangan Panitia Natal 2026 dimulai · Stevi Lengkong, Ketua Panitia',
    );
  });

  void _umBeres() => setState(() {
    _um = true;
    _catat(
      'Pertanggungjawaban Uang Muka Dekorasi Natal dibukukan · Rivo Mandagi, Bendahara Panitia',
    );
  });

  void _sisaBeres() => setState(() {
    _sisa = true;
    _catat(
      'Sisa Rp350.000 dialihkan ke peruntukan Umum Jemaat · Meiske Lumentut, Bendahara Jemaat',
    );
  });

  void _tutup() => setState(() {
    _st = _ditutup;
    // The board joins an empty date with two spaces; HTML shows one.
    final t = _tglST.text.trim();
    _catat(
      'Panitia Natal 2026 Ditutup · ${_file ? 'berita acara serah terima aset ${t.isEmpty ? '' : '$t '}terlampir' : 'tanpa berita acara serah terima aset'}',
    );
  });

  void _arsipkan() => setState(() {
    _st = _arsip;
    _catat('Panitia Natal 2026 Diarsipkan');
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    final alasan = _alasan();
    Widget intrinsik(Widget t) =>
        Align(alignment: AlignmentDirectional.centerStart, child: t);

    final isi = <Widget>[
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            KepalaKartu(
              judul: 'Panitia Natal 2026',
              ujung: LencanaStatus(
                _st,
                bentuk: switch (_st) {
                  _aktif => BentukLencana.laut,
                  _tutupKeu => BentukLencana.draf,
                  _ditutup => BentukLencana.tinta,
                  _ => BentukLencana.abu,
                },
              ),
            ),
            Text(
              'Ketua: Stevi Lengkong · Bendahara: Rivo Mandagi',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Text(switch (_st) {
              _aktif => 'Membukukan di peruntukan Panitia Natal 2026.',
              _tutupKeu =>
                'Tidak ada transaksi baru selain yang menyelesaikan penutupan.',
              _ditutup => 'Ditutup $_hariT.',
              _ => 'Diarsipkan $_hariT.',
            }, style: ket),
          ],
        ),
      ),
      if (_st == _aktif)
        BarisTombol(
          anak: [
            Tombol(
              'Mulai penutupan keuangan',
              onPressed: _mulaiTutup,
              jenis: JenisTombol.tinta,
            ),
          ],
        ),
      if (_st == _tutupKeu) ...[
        Semantics(
          header: true,
          child: const Text(
            'Uang harus selesai sebelum Panitia ditutup',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              KepalaKartu(
                judul: 'Uang Muka · Dekorasi Natal',
                ujung: _um
                    ? const LencanaStatus(
                        'Sudah dipertanggungjawabkan',
                        bentuk: BentukLencana.laut,
                      )
                    : const LencanaStatus(
                        'Belum dipertanggungjawabkan',
                        bentuk: BentukLencana.bata,
                      ),
              ),
              const _BarisUang('Diberikan', 'Rp300.000'),
            ],
          ),
        ),
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              KepalaKartu(
                judul: 'Sisa uang Panitia',
                ujung: _sisa
                    ? const LencanaStatus(
                        'Sudah dikembalikan',
                        bentuk: BentukLencana.laut,
                      )
                    : const LencanaStatus(
                        'Belum dikembalikan',
                        bentuk: BentukLencana.bata,
                      ),
              ),
              const _BarisUang(
                'Saldo peruntukan Panitia Natal 2026',
                'Rp350.000',
              ),
              Text(
                'Sisa dikembalikan ke peruntukan Umum Jemaat lewat Alih peruntukan oleh Bendahara Jemaat.',
                style: ket,
              ),
            ],
          ),
        ),
        Kartu(
          status: GarisStatus.draf,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              KepalaKartu(
                judul: 'Serah terima aset · bila ada',
                ujung: _file
                    ? const LencanaStatus(
                        'Terlampir',
                        bentuk: BentukLencana.garis,
                      )
                    : const LencanaStatus(
                        'Belum dilampirkan',
                        bentuk: BentukLencana.draf,
                      ),
              ),
              IsianAlur(
                label: 'Tanggal serah terima',
                controller: _tglST,
                petunjuk: 'hh/bb/tttt',
                keterangan: 'Sesuai berita acara.',
                onChanged: (_) => setState(() {}),
              ),
              if (!_file)
                intrinsik(
                  Tombol(
                    'Pilih file berita acara',
                    onPressed: () => setState(() => _file = true),
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                    lebarPenuh: false,
                  ),
                )
              else
                Text('berita-acara-serah-terima.pdf', style: ket),
              Text(
                'Tidak menghalangi penutupan. Lampirkan bila Panitia punya aset yang diserahkan.',
                style: ket,
              ),
            ],
          ),
        ),
        if (alasan.isNotEmpty)
          Penolakan(
            tindakan: 'Tutup Panitia',
            sebab: alasan,
            jalan: const [],
            ukuranTeks: 14,
          ),
        TombolBersyarat(
          label: 'Tutup Panitia',
          tindakan: 'Tutup Panitia',
          alasan: alasan,
          periksa: _alasan,
          onPressed: _tutup,
          sudahMulai: false,
          warnaSiap: JenisTombol.tinta,
          baris: const [],
        ),
      ],
      if (_st == _ditutup) ...[
        Text(
          'Panitia yang Ditutup tidak dapat membukukan lagi. Riwayat dan laporannya tetap dapat dibaca.',
          style: ket,
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Arsipkan',
              onPressed: _arsipkan,
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
            ),
          ],
        ),
      ],
      if (_st == _arsip)
        Text(
          'Diarsipkan: tidak tampil di daftar Panitia aktif, tetap dapat dicari dan dibaca.',
          style: ket,
        ),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];

    Widget contoh(String label, VoidCallback onTap) => intrinsik(
      Tombol(
        label,
        onPressed: onTap,
        jenis: JenisTombol.teks,
        ukuran: UkuranTombol.kecil,
        lebarPenuh: false,
      ),
    );

    return AlatPrototipe(
      stem: 'AlurPanitia',
      alat: [
        if (_st == _tutupKeu && !_um)
          contoh('Contoh: pertanggungjawaban dibukukan', _umBeres),
        if (_st == _tutupKeu && !_sisa)
          contoh('Contoh: alih peruntukan dibukukan', _sisaBeres),
      ],
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Alur · Panitia',
              anakJudul: 'Panitia Natal 2026 dari Aktif sampai Diarsipkan',
              kembaliKe: 'Panitia',
              labelKembali: 'Kembali ke Panitia',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: isi,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Info row with a money value. Unlike [BarisInfo], the label wraps and the
/// amount keeps its width, as the board's flex row does.
class _BarisUang extends StatelessWidget {
  const _BarisUang(this.label, this.nilai);

  final String label, nilai;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: c.tinta2)),
          ),
          const SizedBox(width: 16),
          Text(
            nilai,
            style: TextStyle(
              color: c.tinta,
              fontWeight: FontWeight.w500,
              fontFamily: PalakatText.mono,
            ),
          ),
        ],
      ),
    );
  }
}
