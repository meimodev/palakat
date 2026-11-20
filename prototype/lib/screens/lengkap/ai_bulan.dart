import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// One suggestion of the board's `U` list.
typedef _Usul = ({
  String id,
  String label,
  String t,
  bool ragu,
  String pakaiTeks,
  String cat,
  String jadi,
});

const List<_Usul> _usul = [
  (
    id: 'cocok',
    label: 'Usulan AI · pencocokan',
    t:
        'Mutasi bank “TARIK TUNAI −Rp2.000.000” (30/10) kemungkinan cocok '
        'dengan BKU-2026-0127 Pindah antar Kas/Bank: Bank BNI ke Kas.',
    ragu: false,
    pakaiTeks: 'Buka untuk dicocokkan',
    cat: 'Belum mencocokkan apa pun.',
    jadi:
        'Dibuka di rekonsiliasi. Mutasi baru cocok setelah Anda menekan '
        'Cocokkan di sana.',
  ),
  (
    id: 'ganda',
    label: 'Usulan AI · mungkin perlu dicek',
    t:
        'BKU-2026-0101 dan draf “Toko Sinar okt” sama-sama Rp1.250.000 ke '
        'Toko Sinar pada 06/10/2026. Bisa jadi tercatat dua kali, bisa juga '
        'dua tagihan.',
    ragu: true,
    pakaiTeks: 'Lihat keduanya',
    cat: 'Hanya informasi.',
    jadi: 'Kedua transaksi dibuka berdampingan. Tidak ada yang diubah.',
  ),
];

/// 36 · Bantuan AI akhir bulan (spec 10-aifoto.md, AIBulan).
class AIBulanScreen extends StatefulWidget {
  const AIBulanScreen({super.key});

  @override
  State<AIBulanScreen> createState() => _AIBulanScreenState();
}

class _AIBulanScreenState extends State<AIBulanScreen> {
  /// `state.u`: id → 'pakai' | 'abai'. Survives `biayaAI` changes.
  final Map<String, String> _u = {};

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pct = int.parse(belumDipindah<String>('75%').replaceAll('%', ''));
    final mati = pct >= 100;
    final biayaCat = mati
        ? 'Batas tercapai.'
        : pct >= 90
        ? 'Hampir habis. AI memakai cara yang lebih hemat sampai akhir bulan.'
        : pct >= 70
        ? 'Sudah melewati 70% dari batas bulan ini.'
        : '';

    final biaya = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Batas biaya AI per bulan · ${rp((150000 * pct / 100).round())} '
          'dari Rp150.000',
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.permukaan,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (pct.clamp(0, 100)) / 100,
            heightFactor: 1,
            child: ColoredBox(color: c.laut),
          ),
        ),
        if (biayaCat.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            biayaCat,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );

    final panel = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.lautLembut,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _jarak(12, [
          Text(
            'BANTUAN AI · PILIHAN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.lautTua,
              letterSpacing: .3,
            ),
          ),
          biaya,
          if (!mati) ...[
            _KartuAI(
              label: 'Usulan AI · ringkasan',
              jarak: 6,
              anak: [
                Text(
                  'Selisih Rp515.000 di Bank BNI tampaknya terdiri dari satu '
                  'setoran Rp500.000 yang belum muncul di rekening koran dan '
                  'satu biaya administrasi Rp15.000 yang belum dicatat.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: c.lautTua,
                  ),
                ),
                Text(
                  'Angka resmi tetap yang ada di halaman rekonsiliasi.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
            for (final u in _usul) _kartuUsul(u),
          ],
          if (mati)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.permukaan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bantuan AI berhenti sampai Desember 2026.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.tinta,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' Rekonsiliasi, laporan dan tutup buku berjalan '
                          'seperti biasa. Ini tidak menghalangi tutup buku.',
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ),
          Text(
            'AI hanya mengusulkan. Panel ini tidak punya tombol tutup buku.',
            style: TextStyle(fontSize: 13, color: c.tinta2),
          ),
        ]),
      ),
    );

    return LayarPonsel(
      layarKeuangan: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Bantuan AI',
            anakJudul: 'Persiapan tutup buku Oktober 2026',
            kembaliKe: Layar.tutupBuku,
            labelKembali: 'Kembali ke Bulan',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  panel,
                  const SizedBox(height: 16),
                  const Tombol(
                    'Kembali ke kesiapan tutup buku',
                    onPressed: null,
                    ke: Layar.tutupBuku,
                    cara: Cara.naik,
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuUsul(_Usul u) {
    final c = context.warna;
    final v = _u[u.id];
    void set(String nilai) => setState(() => _u[u.id] = nilai);
    return _KartuAI(
      label: u.label,
      jarak: 8,
      anak: [
        Text(
          u.t,
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: c.lautTua,
          ),
        ),
        if (u.ragu)
          const Text(
            'AI kurang yakin, mohon dicek',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        if (v == null) ...[
          Row(
            children: [
              Expanded(
                child: Tombol(
                  u.pakaiTeks,
                  onPressed: () => set('pakai'),
                  ukuran: UkuranTombol.mini,
                  ukuranTeks: 14,
                ),
              ),
              const SizedBox(width: 8),
              Tombol(
                'Abaikan',
                onPressed: () => set('abai'),
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.mini,
                ukuranTeks: 14,
                lebarPenuh: false,
                paddingH: 16,
              ),
            ],
          ),
          Text(u.cat, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ] else
          Gerak(
            Kerangka.muncul,
            key: ValueKey('${u.id}-$v'),
            lama: const Duration(milliseconds: 300),
            child: Semantics(
              container: true,
              liveRegion: true,
              child: Text(
                v == 'pakai' ? u.jadi : 'Diabaikan. Tidak perlu alasan.',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The board's dotted card: `permukaan`, 1.5 dotted `laut`, radius 12,
/// padding 14, the `usulanAI` tag, then [anak] with gap [jarak].
class _KartuAI extends StatelessWidget {
  const _KartuAI({
    required this.label,
    required this.jarak,
    required this.anak,
  });

  final String label;
  final double jarak;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.usulanAI,
    radius: 12,
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _jarak(jarak, [
        Align(
          alignment: Alignment.centerLeft,
          child: LencanaStatus(label, bentuk: BentukLencana.usulanAI),
        ),
        ...anak,
      ]),
    ),
  );
}

/// CSS column `gap`.
List<Widget> _jarak(double g, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: g),
    anak[i],
  ],
];
