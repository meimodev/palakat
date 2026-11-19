import 'package:flutter/material.dart';

import '../../mock/jabatan_kosong.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/panel_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/status_simpan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

const _stem = 'WebDraf';
const _september = 'September 2026';

/// WebDraf: a draft dated in closed September 2026; Pindah tanggal and
/// Batalkan open a side panel (docs/build/screens/06-bukti.md).
class WebDrafScreen extends StatefulWidget {
  const WebDrafScreen({super.key});

  @override
  State<WebDrafScreen> createState() => _WebDrafScreenState();
}

class _WebDrafScreenState extends State<WebDrafScreen> {
  String _st = 'draf'; // draf | batal | hapus
  String _bulan = _september;
  String _tgl = '28 September 2026';
  String? _sheet; // null | pindah | batal
  String _ke = 'November 2026';
  bool _muat = false;
  String _alasanAkhir = '';
  List<String> _hist = ['28/09/2026 16.10 · Draf dicatat oleh Meiske L.'];
  final _alasan = TextEditingController();

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  bool get _konflik => context.tweak<bool>(_stem, 'konflik') && !_muat;
  bool get _ok => IsianAlasan.terisi(_alasan.text);

  void _buka(String sheet) {
    if (_konflik) return;
    _alasan.clear();
    setState(() => _sheet = sheet);
  }

  void _simpan() {
    if (!_ok) return;
    final a = _alasan.text.trim();
    setState(() {
      if (_sheet == 'pindah') {
        _bulan = _ke;
        _tgl = _ke == 'November 2026' ? '16 November 2026' : '31 Oktober 2026';
        _hist = [
          '16/11/2026 11.20 · Pindah tanggal ke $_ke · alasan: $a · oleh Meiske L.',
          ..._hist,
        ];
      } else {
        _st = 'batal';
        _alasanAkhir = a;
        _hist = [
          '16/11/2026 11.20 · Dibatalkan · alasan: $a · oleh Meiske L.',
          ..._hist,
        ];
      }
      _sheet = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final jk = context.prototipe.jabatanKosong;
    final kosong = context.tweak<bool>(_stem, 'drafKosong');
    final konflik = _konflik;
    final draf = _st == 'draf';
    final tutup = _bulan == _september;
    final oleh = plk(jk);
    String t(String s) => tukarJkPapan(_stem, jk, s);
    final teks13 = TextStyle(fontSize: 13, color: c.tinta3);
    final teks14 = TextStyle(fontSize: 14, color: c.tinta2);

    Widget kolom(List<Widget> anak, double jarak) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) SizedBox(height: jarak),
          anak[i],
        ],
      ],
    );

    Widget tombol(String label, VoidCallback onTap) => Tombol(
      label,
      onPressed: onTap,
      jenis: JenisTombol.kedua,
      ukuran: UkuranTombol.sedang,
      paddingH: 20,
      lebarPenuh: false,
    );

    final kiri = kolom([
      if (konflik && draf)
        PitaDiubahOrangLain(
          oleh: oleh,
          jam: '16/11/2026 10.58',
          onMuat: () => setState(() => _muat = true),
        ),
      if (draf) ...[
        Kartu(
          status: GarisStatus.draf,
          radius: 16,
          padding: const EdgeInsets.all(18),
          child: kolom([
            const Align(
              alignment: Alignment.centerLeft,
              child: LencanaStatus(
                'Draf · belum masuk saldo',
                bentuk: BentukLencana.draf,
              ),
            ),
            Text(
              kosong ? '—' : '−Rp650.000',
              style: PalakatText.jumlahIsian.copyWith(color: c.tinta2),
            ),
            Text(
              kosong ? 'Draf kosong' : 'Honor pemusik',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              kosong
                  ? 'Belum ada isian · dibuat 16/11/2026 11.02'
                  : 'Bank BNI ··4821 · tanggal transaksi $_tgl',
              style: teks13,
            ),
            Text(
              '$_bulan${tutup ? ' · Sudah ditutup' : ' · Belum ditutup'}',
              style: teks13,
            ),
          ], 6),
        ),
        if (tutup && !kosong)
          const Penolakan(
            tindakan: 'Bukukan',
            sebab:
                'September 2026 sudah ditutup, dan draf ini tidak pernah '
                'masuk laporannya. Yang masih dapat Anda lakukan: pindah '
                'tanggal ke bulan yang belum ditutup, atau batalkan.',
            jalan: [],
          ),
      ],
      if (_st == 'batal')
        Gerak(
          Kerangka.muncul,
          lama: const Duration(milliseconds: 300),
          child: Kartu(
            padding: const EdgeInsets.all(18),
            child: kolom([
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.garis,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Dibatalkan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.tinta2,
                    ),
                  ),
                ),
              ),
              Text(
                '−Rp650.000',
                style: PalakatText.jumlahIsian.copyWith(
                  color: c.tinta3,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: c.tinta3,
                ),
              ),
              const Text(
                'Honor pemusik',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('Alasan: $_alasanAkhir', style: teks14),
              Text(
                'Dibatalkan oleh $oleh, 16/11/2026 11.20 · tidak pernah punya '
                'No. Bukti · hanya dapat dilihat',
                style: teks13,
              ),
            ], 6),
          ),
        ),
      if (_st == 'hapus')
        Gerak(
          Kerangka.muncul,
          lama: const Duration(milliseconds: 300),
          child: Semantics(
            container: true,
            liveRegion: true,
            child: Kartu(
              status: GarisStatus.draf,
              padding: const EdgeInsets.all(18),
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Draf kosong dihapus.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text:
                          ' Hanya draf tanpa isian yang dapat dihapus; yang '
                          'lain dibatalkan dengan alasan.',
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      if (draf)
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!tutup && !kosong)
                const Tombol(
                  'Periksa dan bukukan',
                  onPressed: null,
                  ke: 'WebCatat',
                  paddingH: 20,
                  lebarPenuh: false,
                ),
              if (!kosong) ...[
                // Kept in full look while the conflict locks them; the
                // conflict card above is the reason.
                tombol('Pindah tanggal', () => _buka('pindah')),
                tombol('Batalkan', () => _buka('batal')),
              ],
              if (kosong)
                tombol('Hapus draf', () => setState(() => _st = 'hapus')),
            ],
          ),
        ),
      kolom([
        const Text(
          'Riwayat',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        for (final h in _hist) Text(t(h), style: teks14),
      ], 6),
    ], 16);

    final pindah = _sheet == 'pindah';
    final panel = _sheet == null
        ? null
        : PanelSamping(
            kotak: true,
            muncul: true,
            // flex-basis 360 is the content box: + padding 40 + border 2.
            dasar: 402,
            anak: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      pindah ? 'Pindah tanggal' : 'Batalkan draf',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    pindah
                        ? 'Hanya bulan sesudahnya yang belum ditutup. Draf '
                              'tetap Draf, dan tanda sudah diperiksa atau '
                              'persetujuan yang ada akan hilang.'
                        : 'Draf yang dibatalkan tidak pernah punya No. Bukti '
                              'dan tetap dapat dilihat bersama alasannya.',
                    style: teks14,
                  ),
                ],
              ),
              if (pindah)
                ChipPilihan<String>(
                  label: 'Pindah ke bulan',
                  pilihan: const [
                    (
                      nilai: 'Oktober 2026',
                      teks: 'Oktober 2026 · Belum ditutup',
                    ),
                    (
                      nilai: 'November 2026',
                      teks: 'November 2026 · Belum ditutup',
                    ),
                  ],
                  terpilih: _ke,
                  onPilih: (b) => setState(() => _ke = b),
                ),
              // The inline textarea leaves a line-box descent (4 px) under it.
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: IsianAlasan(
                  controller: _alasan,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Tombol(
                pindah ? 'Pindah tanggal ke $_ke' : 'Batalkan draf',
                onPressed: _simpan,
                jenis: JenisTombol.tinta,
                nonaktif: !_ok,
                paddingH: 20,
              ),
              Tombol(
                'Kembali',
                onPressed: () => setState(() => _sheet = null),
                jenis: JenisTombol.teks,
                warnaTeks: c.tinta,
              ),
            ],
          );

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        jabatanKosong: true,
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 1,
          pengguna: PenggunaKeuangan(),
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarginNegatif(
                atas: 12,
                bawah: 12,
                child: Tautan(
                  ke: 'WebTransaksi',
                  cara: Cara.naik,
                  child: const Align(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: TautanTeks('Transaksi', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Draf',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          BarisLentur(
            jarak: 24,
            anak: [
              Lentur(dasar: 460, tumbuh: 999, child: kiri),
              ?panel?.lentur,
            ],
          ),
        ],
      ),
    );
  }
}
