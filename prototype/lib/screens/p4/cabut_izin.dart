import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

const _penjelasan = 'Penjelasan',
    _konfirmasi = 'Konfirmasi',
    _kertas = 'Permintaan lewat kertas',
    _dihapus = 'Sudah dihapus';
const _keterangan = 'Tombol aktif setelah pernyataan di atas dicentang.';

/// 79 · Cabut izin dan hapus data saya (spec 20, CabutIzin).
class CabutIzinScreen extends StatefulWidget {
  const CabutIzinScreen({super.key});

  @override
  State<CabutIzinScreen> createState() => _CabutIzinScreenState();
}

class _CabutIzinScreenState extends State<CabutIzinScreen> {
  final _gulir = ScrollController();
  String? _k;
  bool _centang = false;
  String? _keadaan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final keadaan = belumDipindah<String>('Penjelasan');
    // Board parity (CONVENTIONS, settled conflicts): a panel change does not
    // reset k; it changes the view only while k is null.
    if (_keadaan != null && keadaan != _keadaan && _k == null) {
      _centang = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _keAtas());
    }
    _keadaan = keadaan;
  }

  void _keAtas() {
    if (mounted && _gulir.hasClients) _gulir.jumpTo(0);
  }

  // A new view re-creates the board's checkbox, so it comes back unticked.
  void _ke(String k) {
    setState(() {
      _k = k;
      _centang = false;
    });
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
    final jelas = k == _penjelasan || k == _konfirmasi;
    final lini14 = TextStyle(fontSize: 14, color: c.tinta2);
    final lini13 = TextStyle(fontSize: 13, color: c.tinta3);
    const judul = TextStyle(fontWeight: FontWeight.w700);
    Widget kartu(List<Widget> isi, {GarisStatus s = GarisStatus.dibukukan}) =>
        Kartu(
          status: s,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: isi,
          ),
        );

    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Cabut izin dan hapus data saya',
            anakJudul: 'Hak anggota; data dihapus setelah dikonfirmasi',
            kembaliKe: Layar.dataAnggota,
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
                  if (jelas) ...[
                    kartu([
                      const Text('Yang dihapus', style: judul),
                      Text(
                        'Data pribadi Anda, riwayat keluarga dan Kolom, '
                        'peristiwa, jabatan yang sedang dipegang (menjadi '
                        'Jabatan kosong), dan akun Anda.',
                        style: lini14,
                      ),
                    ]),
                    kartu(s: GarisStatus.draf, [
                      const Text('Yang tetap ada', style: judul),
                      Text(
                        'Catatan keuangan Jemaat tetap menyimpan nama seperti '
                        'yang tercatat, sebagai bagian dari pembukuan gereja. '
                        'Warta Jemaat dan dokumen yang sudah diterbitkan tetap '
                        'persis seperti saat diterbitkan.',
                        style: lini14,
                      ),
                    ]),
                  ],
                  if (k == _penjelasan)
                    BarisTombol(
                      tautan: const {1: 32},
                      anak: [
                        Tombol(
                          'Lanjutkan',
                          onPressed: () => _ke(_konfirmasi),
                          jenis: JenisTombol.kedua,
                          ukuran: UkuranTombol.sedang,
                        ),
                        const Tombol(
                          'Kembali',
                          onPressed: null,
                          jenis: JenisTombol.teks,
                          ke: Layar.dataAnggota,
                          cara: Cara.naik,
                        ),
                      ],
                    ),
                  if (k == _konfirmasi) ...[
                    _Pernyataan(
                      nilai: _centang,
                      onUbah: () => setState(() => _centang = !_centang),
                    ),
                    BarisTombol(
                      anak: [
                        // The board's checkbox is not wired and its button is
                        // `disabled`: the condition is never met. Pressable
                        // per CONVENTIONS (TombolBersyarat); a press does
                        // nothing.
                        TombolBersyarat(
                          label: 'Cabut izin dan hapus data saya',
                          tindakan: 'Cabut izin dan hapus data saya',
                          alasan: _keterangan,
                          onPressed: () {},
                          sudahMulai: false,
                        ),
                        Tombol(
                          'Kembali',
                          onPressed: () => _ke(_penjelasan),
                          jenis: JenisTombol.teks,
                        ),
                      ],
                    ),
                    Text(_keterangan, style: lini13),
                  ],
                  if (k == _kertas) ...[
                    kartu([
                      const _KepalaSempit(
                        'Permintaan hapus · Ferry Wenas',
                        'Menunggu konfirmasi Penatua',
                      ),
                      Text(
                        'Dicatat Operator Yanti Sumual dari surat bertanda '
                        'tangan, 16/11/2026.',
                        style: lini14,
                      ),
                      Text(
                        'Permintaan lewat kertas dikonfirmasi Penatua Kolom 7 '
                        'sebelum dijalankan.',
                        style: lini13,
                      ),
                    ]),
                    BarisTombol(
                      anak: [
                        Tombol(
                          'Konfirmasi permintaan',
                          onPressed: () => _ke(_dihapus),
                          jenis: JenisTombol.tinta,
                        ),
                      ],
                    ),
                  ],
                  if (k == _dihapus)
                    kartu([
                      const KepalaKartu(
                        judul: 'Catatan penghapusan',
                        ujung: LencanaStatus(
                          'Selesai',
                          bentuk: BentukLencana.abu,
                        ),
                      ),
                      const BarisInfo('Dihapus pada', '17/11/2026 20.15'),
                      const BarisInfo('Atas permintaan', 'anggota sendiri'),
                      const BarisInfo(
                        'Dijalankan oleh',
                        'Pnt. Hendrik Rumagit',
                      ),
                      Text(
                        'Catatan ini tidak memuat data pribadi. Orangnya tidak '
                        'lagi punya status; anggota yang meninggal dunia tidak '
                        'pernah dihapus dengan cara ini.',
                        style: lini13,
                      ),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Statement checkbox (board `<label>`): the whole row toggles; row gap 12,
/// top-aligned, min-height 44, 14 px. The 24 px box has margin-top 2, which
/// the shared KotakCentang row lacks; its look is KotakCentang's.
class _Pernyataan extends StatelessWidget {
  const _Pernyataan({required this.nilai, required this.onUbah});

  final bool nilai;
  final VoidCallback onUbah;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onUbah,
      tercentang: nilai,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SizedBox.square(
              dimension: 24,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: nilai ? c.laut : c.permukaan,
                  shape: nilai
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        )
                      : GarisBorder.penuh(c.garisTegas, radius: 4),
                ),
                child: nilai
                    ? Center(
                        child: PalakatIkon(
                          Ikon.centang,
                          ukuran: 16,
                          warna: c.diLaut,
                          tebal: 3,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Saya mengerti data saya akan dihapus dan tidak dapat '
              'dikembalikan. Untuk menjadi anggota lagi saya harus '
              'mengajukan permohonan baru.',
              style: TextStyle(fontSize: 14, color: c.tinta),
            ),
          ),
        ],
      ),
    );
  }
}

/// k2 head row. The long badge leaves the title column barely wider than its
/// longest word; when it would be narrower (large text), the badge drops
/// under the title instead of overflowing the card (spec note on k2).
class _KepalaSempit extends StatelessWidget {
  const _KepalaSempit(this.judul, this.label);

  final String judul, label;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, ruang) {
      final dasar = DefaultTextStyle.of(context).style;
      double lebar(String s, TextStyle g) => (TextPainter(
        text: TextSpan(text: s, style: dasar.merge(g)),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout()).width;
      const tebal = TextStyle(fontWeight: FontWeight.w700);
      final kata = judul.split(' ').map((w) => lebar(w, tebal));
      // Badge: text, padding 9 + line 1.5 each side; then the gap 16.
      final sisa =
          ruang.maxWidth -
          lebar(
            label,
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ) -
          21 -
          16;
      final lencana = LencanaStatus(label, bentuk: BentukLencana.garis);
      if (kata.every((w) => w <= sisa)) {
        return KepalaKartu(judul: judul, ujung: lencana);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(judul, style: tebal),
          lencana,
        ],
      );
    },
  );
}
