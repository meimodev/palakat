import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';

const _stem = 'KonfirmasiKeluarga';
const _k0 = 'Belum dikonfirmasi',
    _k1 = 'Dikonfirmasi di aplikasi',
    _k2 = 'Formulir kertas diunggah',
    _k3 = 'Aktif';
const _keluarga = 'Keluarga Wenas-Lasut';
const _anggota = 'Kolom 7 · 4 orang: Ferry, Agustina, Novita, Gabriel';

/// 74 · Konfirmasi keluarga (spec 20). View = `k ?? keadaan`; `k` resets
/// when the panel's `keadaan` changes.
class KonfirmasiKeluargaScreen extends StatefulWidget {
  const KonfirmasiKeluargaScreen({super.key});

  @override
  State<KonfirmasiKeluargaScreen> createState() => _State();
}

class _State extends State<KonfirmasiKeluargaScreen> {
  String? _k;
  String? _keadaan;

  void _ke(String k) => setState(() => _k = k);

  @override
  Widget build(BuildContext context) {
    final keadaan = context.tweak<String>(_stem, 'keadaan');
    if (_keadaan != null && keadaan != _keadaan) _k = null;
    _keadaan = keadaan;
    final view = _k ?? keadaan;
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Konfirmasi keluarga',
            anakJudul:
                'Keluarga dari buku anggota mengonfirmasi datanya dan '
                'memberi izin',
            kembaliKe: 'DataAnggota',
            labelKembali: 'Kembali ke Data jemaat',
          ),
          Expanded(
            // A new key per view: the scroll area jumps to the top.
            child: SingleChildScrollView(
              key: ValueKey(view),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: _isi(view),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _isi(String view) {
    final c = context.warna;
    Tombol kedua(String label, VoidCallback f) => Tombol(
      label,
      onPressed: f,
      jenis: JenisTombol.kedua,
      ukuran: UkuranTombol.sedang,
    );
    final verifikasi = Tombol(
      'Verifikasi data',
      onPressed: () => _ke(_k3),
      jenis: JenisTombol.tinta,
    );
    return switch (view) {
      _k1 => [
        const _KartuKeluarga(
          lencana: LencanaStatus(
            'Menunggu verifikasi',
            bentuk: BentukLencana.garis,
          ),
          catatan:
              'Wakil keluarga Agustina Lasut mengonfirmasi data 4 orang dan '
              'memberi izin, 16/11/2026 19.30.',
        ),
        Text(
          'Berikutnya: verifikasi Penatua Kolom 7.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
        BarisTombol(
          anak: [
            verifikasi,
            const _TombolTautan(
              'Kembalikan dengan alasan',
              ke: 'AntreanVerifikasi',
            ),
          ],
        ),
      ],
      _k2 => [
        const _KartuKeluarga(
          lencana: LencanaStatus(
            'Menunggu verifikasi',
            bentuk: BentukLencana.garis,
          ),
          catatan:
              'Formulir kertas bertanda tangan diunggah Pnt. Hendrik '
              'Rumagit, 16/11/2026. Dimasukkan oleh Operator Yanti Sumual '
              'untuk keluarga tanpa ponsel.',
        ),
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              const KepalaKartu(
                judul: 'formulir-wenas-lasut.jpg',
                ujung: LencanaStatus('Terlampir', bentuk: BentukLencana.garis),
              ),
              Text(
                'Memuat izin penggunaan data pribadi naskah versi 1.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        ),
        BarisTombol(anak: [verifikasi]),
      ],
      _k3 => [
        const _KartuKeluarga(
          lencana: LencanaStatus('Aktif', bentuk: BentukLencana.laut),
          catatan:
              'Diverifikasi oleh Pnt. Hendrik Rumagit, 17/11/2026 19.05. '
              'Sejak sekarang nama keluarga dapat tampil sesuai Tampilan '
              'nama yang dipilih.',
        ),
        const BarisTombol(
          anak: [
            _TombolTautan(
              'Buka data keluarga',
              ke: 'DataAnggota',
              cara: Cara.naik,
            ),
          ],
        ),
      ],
      _ => [
        const _KartuKeluarga(
          lencana: LencanaStatus(_k0, bentuk: BentukLencana.draf),
          catatan:
              'Diimpor 12/11/2026 dari buku anggota. Tidak tampil di Warta, '
              'surat atau laporan mana pun.',
        ),
        Text(
          'Dua jalan konfirmasi:',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        BarisTombol(
          anak: [
            kedua('Keluarga mengonfirmasi di aplikasi', () => _ke(_k1)),
            kedua('Unggah formulir kertas bertanda tangan', () => _ke(_k2)),
          ],
        ),
      ],
    };
  }
}

/// The family card: head + badge, members line 14, note 13.
class _KartuKeluarga extends StatelessWidget {
  const _KartuKeluarga({required this.lencana, required this.catatan});

  final Widget lencana;
  final String catatan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          KepalaKartu(judul: _keluarga, ujung: lencana),
          Text(_anggota, style: TextStyle(fontSize: 14, color: c.tinta2)),
          Text(catatan, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
      ),
    );
  }
}

/// The board's secondary link-button: an `<a>` is content-box, so min-height
/// 48 plus the 1.5 lines makes it 51 tall (a `<button>` is 48).
class _TombolTautan extends StatelessWidget {
  const _TombolTautan(this.label, {required this.ke, this.cara = Cara.dorong});

  final String label;
  final String ke;
  final Cara cara;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: ke,
      cara: cara,
      radius: 14,
      child: RupaTombol(
        label: label,
        isi: c.permukaan,
        garis: GarisBorder.penuh(c.tinta, radius: 14),
        warnaTeks: c.tinta,
        radius: 14,
        tinggi: 51,
        paddingH: 16,
      ),
    );
  }
}
