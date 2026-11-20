import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../providers/keuangan/impor.dart';
import '../../widgets/penolakan.dart';

/// The phone's step captions; [d] null before anything was staged.
String keteranganImpor(DataImpor d, bool tunggu) => switch (d.langkah) {
  0 => 'Belum ada yang masuk saldo.',
  1 =>
    tunggu
        ? 'Putuskan dulu baris yang mungkin ganda.'
        : 'Pengecekan selesai. Baca sekali lagi.',
  2 => 'Siap diimpor.',
  _ =>
    '${d.diimpor} baris sudah diimpor · '
        '${d.baris.length - d.diimpor} tidak diimpor.',
};

/// A possible duplicate still waits for "Tetap impor" or "Tidak diimpor".
bool tungguImpor(DataImpor d, Map<String, bool> tetap) =>
    d.langkah == 1 && d.baris.any((b) => b.ganda && !tetap.containsKey(b.id));

class ImporScreen extends ConsumerStatefulWidget {
  const ImporScreen({super.key});

  @override
  ConsumerState<ImporScreen> createState() => _ImporScreenState();
}

class _ImporScreenState extends ConsumerState<ImporScreen> {
  /// The choice on each possible duplicate: true "Tetap impor".
  final _tetap = <String, bool>{};
  Refusal? _pesan;

  Future<void> _maju(DataImpor d) async {
    if (tungguImpor(d, _tetap)) return;
    final r = await majuImpor(ref, d, _tetap);
    if (mounted) setState(() => _pesan = r);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final d = ref.watch(imporProvider);
    final st = d?.langkah ?? 0;
    final tunggu = d != null && tungguImpor(d, _tetap);
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        layarKeuangan: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: 'Impor',
              anakJudul: d == null
                  ? 'Belum ada file'
                  : '${d.batch.fileName} · ${d.baris.length} baris',
              kembaliKe: Layar.pengaturan,
              labelKembali: 'Kembali ke Lainnya',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: i <= st
                            ? BoxDecoration(
                                color: c.tinta,
                                borderRadius: BorderRadius.circular(3),
                              )
                            : ShapeDecoration(
                                shape: GarisBorder.putus(c.putus, radius: 3),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${st + 1} dari 4 · ${langkahImpor[st]}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    d == null
                        ? 'Belum ada file yang ditampung.'
                        : keteranganImpor(d, tunggu),
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  if (_pesan case final r?)
                    Penolakan(
                      tindakan: r.action,
                      sebab: r.because,
                      jalan: const [],
                      ukuranTeks: 14,
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, b)
                        in (d?.baris ?? const <BarisImpor>[]).indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _kartu(context, i, b, st),
                      ),
                  ],
                ),
              ),
            ),
            if (d != null && st < 3)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                decoration: BoxDecoration(
                  color: c.permukaan,
                  border: Border(top: BorderSide(color: c.garis)),
                ),
                child: TombolBersyarat(
                  label: const [
                    'Jalankan pengecekan',
                    'Tandai sudah diperiksa',
                    'Impor',
                  ][st],
                  tindakan: 'Tandai sudah diperiksa',
                  alasan: tunggu
                      ? 'Putuskan dulu baris yang mungkin ganda.'
                      : '',
                  onPressed: () => _maju(d),
                  // The board's reason is the step caption above the list.
                  sudahMulai: false,
                  warnaSiap: st == 2 ? JenisTombol.utama : JenisTombol.tinta,
                  teksBelumRedup: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _kartu(BuildContext context, int i, BarisImpor d, int st) {
    final c = context.warna;
    final (:hasil, :nada, :cat, :pilih) = hasilBaris(d, st, _tetap[d.id]);
    final bentuk = BentukLencana.values.byName(nada.name);
    final kecil = TextStyle(fontSize: 13, color: c.tinta2);
    Widget keputusan(String label, bool nilai) => Expanded(
      child: Tekan(
        onTap: () => setState(() => _tetap[d.id] = nilai),
        radius: 10,
        child: RupaTombol(
          label: label,
          isi: c.permukaan,
          garis: GarisBorder.penuh(c.tinta, radius: 10),
          warnaTeks: c.tinta,
          radius: 10,
          tinggi: 44,
          paddingH: 0,
          ukuranTeks: 14,
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ShapeDecoration(
        color: st == 0 ? null : c.permukaan,
        shape: st == 0
            ? GarisBorder.putus(c.putus, radius: 14)
            : GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Baris ${i + 1}', style: kecil)),
              const SizedBox(width: 8),
              LencanaStatus(hasil, bentuk: bentuk),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Di file: ${d.baris.raw}',
            style: kecil.copyWith(fontFamily: PalakatText.mono),
          ),
          const SizedBox(height: 6),
          Text(
            d.ur,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text('Dibaca sebagai: ${d.baca}', style: kecil),
          Text(
            d.ma.isEmpty ? 'Mata Anggaran belum dipilih' : d.ma,
            style: kecil.copyWith(color: d.ma.isEmpty ? c.bata : c.tinta2),
          ),
          if (cat.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(cat, style: TextStyle(fontSize: 13, color: c.tinta)),
          ],
          if (pilih) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                keputusan('Tetap impor', true),
                const SizedBox(width: 8),
                keputusan('Tidak diimpor', false),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
