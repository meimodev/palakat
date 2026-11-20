import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../providers/keuangan/ekspor.dart';
import '../../widgets/penolakan.dart';

/// The bar duration (ms) of each of the five contents.
const _lama = [1100, 1500, 2400, 1900, 2600];

enum _St { belum, jalan, selesai }

/// 18 · Ekspor data Jemaat (spec 06-bukti.md).
class EksporScreen extends ConsumerStatefulWidget {
  const EksporScreen({super.key});

  @override
  ConsumerState<EksporScreen> createState() => _EksporScreenState();
}

class _EksporScreenState extends ConsumerState<EksporScreen> {
  _St _st = _St.belum;
  bool _diunduh = false;
  Timer? _t;
  ExportManifest? _manifest;
  Refusal? _pesan;

  Future<void> _buat() async {
    final r = await buatEkspor(ref);
    if (!mounted) return;
    setState(() {
      _pesan = r.pesan;
      _manifest = r.manifest;
      _diunduh = false;
      if (r.manifest != null) _st = _St.jalan;
    });
    if (r.manifest == null) return;
    _t?.cancel();
    void selesai() => setState(() => _st = _St.selesai);
    _t = Timer(const Duration(milliseconds: 2800), selesai); // tiruan: ekspor
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final d = ref.watch(eksporProvider);
    final kurang = d.tanpaDokumen;
    final jalan = _st == _St.jalan, selesai = _st == _St.selesai;
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        layarKeuangan: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Ekspor data Jemaat',
              anakJudul: 'Salinan lengkap milik Jemaat',
              kembaliKe: Layar.pengaturan,
              labelKembali: 'Kembali ke Lainnya',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: c.permukaan,
                        border: Border.all(color: c.garis),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < d.isi.length; i++)
                            _Butir(i: i, st: _st, d: d),
                        ],
                      ),
                    ),
                    if (_st == _St.belum) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Mencakup ${d.mulai} sampai hari ini. Bulan '
                        'yang belum ditutup diekspor sebagai keadaan saat ini '
                        'dan ditandai Belum ditutup.',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                    ],
                    if (_pesan case final r?) ...[
                      const SizedBox(height: 14),
                      Penolakan(
                        tindakan: r.action,
                        sebab: r.because,
                        jalan: const [],
                      ),
                    ],
                    if (selesai && kurang.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Gerak(
                        Kerangka.muncul,
                        lama: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: c.permukaan,
                            border: Border.all(color: c.bata, width: 1.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Ekspor belum lengkap',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${kurang.length} transaksi tanpa dokumen '
                                'pendukung wajib:',
                                style: const TextStyle(fontSize: 14),
                              ),
                              for (final t in kurang) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${t.voucher} · ${t.description}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: c.tinta2,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                'Daftar isi mencatatnya beserta No. Bukti '
                                'dan alasannya.',
                                style: TextStyle(fontSize: 13, color: c.tinta3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              decoration: BoxDecoration(
                color: c.permukaan,
                border: Border(top: BorderSide(color: c.garis)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_st == _St.belum)
                    Tombol('Buat ekspor', onPressed: _buat, paddingH: 6),
                  if (jalan)
                    Semantics(
                      liveRegion: true,
                      child: const SizedBox(
                        height: 52,
                        child: Center(
                          child: Text(
                            'Sedang disiapkan…',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  if (selesai) ...[
                    Tombol(
                      _diunduh
                          ? 'Diunduh · ${_manifest?.fileName ?? ''}'
                          : kurang.isEmpty
                          ? 'Unduh ekspor'
                          : 'Unduh ekspor (belum lengkap)',
                      onPressed: () => setState(() => _diunduh = true),
                      paddingH: 6,
                    ),
                    const SizedBox(height: 8),
                    Tombol(
                      'Coba lagi',
                      onPressed: _buat,
                      jenis: JenisTombol.teks,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One contents row: name and badge, description, bar while preparing.
class _Butir extends StatelessWidget {
  const _Butir({required this.i, required this.st, required this.d});
  final int i;
  final _St st;
  final DataEkspor d;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (n, s) = d.isi[i];
    final lama = _lama[i];
    final kurang = st == _St.selesai && i == 2 && d.tanpaDokumen.isNotEmpty;
    final lencana = switch (st) {
      _St.belum => const LencanaStatus(
        'Akan disertakan',
        bentuk: BentukLencana.draf,
      ),
      _St.jalan => const LencanaStatus(
        'Sedang disiapkan',
        bentuk: BentukLencana.draf,
      ),
      _St.selesai =>
        kurang
            ? const LencanaStatus('Belum lengkap', bentuk: BentukLencana.bata)
            : const LencanaStatus('Disertakan', bentuk: BentukLencana.laut),
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: i == 0
          ? null
          : BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  n,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              lencana,
            ],
          ),
          Text(
            kurang
                ? '$s · ${d.tanpaDokumen.length} transaksi tanpa dokumen wajib'
                : s,
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
          if (st == _St.jalan) ...[
            const SizedBox(height: 8),
            BatangIsi(lama: Duration(milliseconds: lama), tinggi: 4),
          ],
        ],
      ),
    );
  }
}
