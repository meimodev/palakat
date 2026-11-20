import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mock/kolaborasi.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

const _opsi = [
  'Sedang dihitung',
  'Sudah diperiksa',
  'Ditetapkan',
  'Koreksi',
  'Petugas penghitung',
];

const _samping = 89;

/// 91 · Jumlah kehadiran: the people counter that never records names
/// (spec 22, Kehadiran).
class KehadiranScreen extends StatefulWidget {
  const KehadiranScreen({super.key});

  @override
  State<KehadiranScreen> createState() => _KehadiranScreenState();
}

class _KehadiranScreenState extends State<KehadiranScreen> {
  final _gulir = ScrollController();
  String? _k;
  String? _tweak;

  /// Pintu depan; survives view and tweak changes, resets when the route is left.
  int _n = kehadiranPenghitungMulai;

  @override
  void dispose() {
    _gulir.dispose();
    super.dispose();
  }

  void _ke(String k) {
    setState(() => _k = k);
    if (_gulir.hasClients) _gulir.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final t = context.tweak<String>('Kehadiran', 'keadaan');
    if (t != _tweak) {
      // A panel change resets the in-board view, keeps the count.
      // Not during build: jumping fires scroll notifications.
      if (_tweak != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _gulir.hasClients) _gulir.jumpTo(0);
        });
      }
      _tweak = t;
      _k = null;
    }
    final ki = _opsi.indexOf(_k ?? t).clamp(0, _opsi.length - 1);
    final keterangan = TextStyle(fontSize: 13, color: c.tinta3);
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Jumlah kehadiran',
            anakJudul: 'Menghitung orang, tidak pernah mencatat nama',
            kembaliKe: 'Ibadah',
            labelKembali: 'Kembali ke Ibadah dan kegiatan',
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _gulir,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  if (ki < 3) _kartuJumlah(c, ki, keterangan),
                  ...switch (ki) {
                    0 => [
                      _penghitung(c),
                      BarisTombol(
                        anak: [
                          Tombol(
                            'Kirim untuk diperiksa',
                            jenis: JenisTombol.kedua,
                            ukuran: UkuranTombol.sedang,
                            onPressed: () => _ke('Sudah diperiksa'),
                          ),
                        ],
                      ),
                    ],
                    1 => [
                      Text(
                        'Diperiksa oleh Pnt. Hendrik Rumagit, yang menyetujui '
                        'ibadah ini.',
                        style: keterangan,
                      ),
                      BarisTombol(
                        anak: [
                          Tombol(
                            'Tetapkan',
                            jenis: JenisTombol.tinta,
                            onPressed: () => _ke('Ditetapkan'),
                          ),
                          Tombol(
                            'Kembalikan ke penghitung',
                            jenis: JenisTombol.teks,
                            ukuran: UkuranTombol.sedang,
                            onPressed: () => _ke('Sedang dihitung'),
                          ),
                        ],
                      ),
                    ],
                    2 => [
                      Text(
                        'Ditetapkan oleh Pnt. Hendrik Rumagit, 15/11/2026 '
                        '11.20. Hanya jumlah yang Ditetapkan masuk ke Warta '
                        'Jemaat dan laporan.',
                        style: keterangan,
                      ),
                    ],
                    3 => [_koreksi(c, keterangan)],
                    _ => [
                      Kartu(
                        status: GarisStatus.terpilih,
                        radius: 12,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Petugas penghitung kehadiran',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text:
                                    ' untuk ibadah ini saja. Anda dapat '
                                    'menghitung; memeriksa dan menetapkan '
                                    'dilakukan yang menyetujui ibadah.',
                              ),
                            ],
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const Penolakan(
                        tindakan: 'Tetapkan',
                        sebab: 'penghitung tidak menetapkan jumlah.',
                        jalan: [],
                      ),
                    ],
                  },
                  Text(
                    'Tidak ada daftar hadir bernama, daftar yang tidak hadir, '
                    'atau nilai kehadiran per orang.',
                    style: keterangan,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The count card: chip per step, the two doors, the total under a `tinta` rule.
  Widget _kartuJumlah(PalakatWarna c, int ki, TextStyle keterangan) {
    final lencana = [
      const LencanaStatus('Sedang dihitung', bentuk: BentukLencana.laut),
      const LencanaStatus('Sudah diperiksa', bentuk: BentukLencana.lautGaris),
      const LencanaStatus('Ditetapkan', bentuk: BentukLencana.tinta),
    ][math.min(ki, 2)];
    final pos = kehadiranPagi.perPos.keys.toList();
    return Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          KepalaKartu(judul: kehadiranPagi.ibadah, ujung: lencana),
          _BarisAngka(pos[0], '$_n'),
          _BarisAngka(pos[1], '$_samping'),
          Container(
            padding: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.tinta, width: 1.5)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Jumlah',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_n + _samping}',
                  style: const TextStyle(
                    fontFamily: PalakatText.mono,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Jumlah per pos tetap terpisah di dalam; yang dipakai laporan '
            'hanya jumlahnya.',
            style: keterangan,
          ),
        ],
      ),
    );
  }

  /// The stepper: Pintu depan, −, the count, +.
  Widget _penghitung(PalakatWarna c) {
    Widget tombol(String t, String label, VoidCallback onTap, bool isi) =>
        Tekan(
          onTap: onTap,
          label: label,
          radius: 12,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: isi ? c.tinta : c.permukaan,
              shape: isi
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  : GarisBorder.penuh(c.garisTegas, radius: 12),
            ),
            child: ExcludeSemantics(
              child: Text(
                t,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isi ? c.permukaan : c.tinta,
                ),
              ),
            ),
          ),
        );
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          const Expanded(
            child: Text(
              'Pintu depan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          tombol(
            '−',
            'Kurangi satu',
            () => setState(() => _n = math.max(0, _n - 1)),
            false,
          ),
          Semantics(
            liveRegion: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48),
              child: Text(
                '$_n',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          tombol('+', 'Tambah satu', () => setState(() => _n++), true),
        ],
      ),
    );
  }

  /// Koreksi: a fixed 231 → 236, both kept.
  Widget _koreksi(PalakatWarna c, TextStyle keterangan) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        const KepalaKartu(
          judul: 'Koreksi jumlah',
          ujung: LencanaStatus('Ditetapkan', bentuk: BentukLencana.tinta),
        ),
        _BarisAngka('Jumlah semula', '${kehadiranKoreksi.dari}'),
        _BarisAngka('Jumlah koreksi', '${kehadiranKoreksi.ke}'),
        Text(
          kehadiranKoreksi.alasan,
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        Text(
          'Oleh Pnt. Hendrik Rumagit, ${kehadiranKoreksi.pada}. Kedua nilai '
          'disimpan.',
          style: keterangan,
        ),
      ],
    ),
  );
}

/// A count row: label `tinta2`, mono 500 value. Unlike `BarisInfo` the label
/// may shrink and wrap (CSS flex-shrink), so a long label never overflows.
class _BarisAngka extends StatelessWidget {
  const _BarisAngka(this.label, this.nilai);

  final String label, nilai;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Text(
          label,
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ),
      const SizedBox(width: 16),
      Text(
        nilai,
        textAlign: TextAlign.right,
        // The board's mono span sits inline on a sans line box (20.6 tall).
        strutStyle: const StrutStyle(
          fontFamily: PalakatText.sans,
          fontSize: 14,
          height: 1.4,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        style: const TextStyle(
          fontSize: 14,
          fontFamily: PalakatText.mono,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
